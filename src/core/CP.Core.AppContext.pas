unit CP.Core.AppContext;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.IOUtils, System.Generics.Collections,
  Vcl.Graphics,
  CP.Config.Manager, CP.Storage.Manager, CP.DB.Manager, CP.DB.Models,
  CP.DB.Repositories, CP.Camera.Manager, CP.Imaging.Processor,
  CP.Imaging.Crop, CP.Validation.Runner, CP.Validation.Preflight;

type
  TCPAppContext = class
  private
    class var FInstance: TCPAppContext;
    FConfig: TCPConfigManager;
    FStorage: TCPStorageManager;
    FCamera: TCPCameraManager;

    FActiveSession: TSessionModel;
    FSessionPaths: TSessionPaths;
    FSessionDB: TCPDatabaseManager;

    FSessionRepo: TSessionRepository;
    FTrayRepo: TTrayRepository;
    FPhotoRepo: TPhotoRepository;
    FTransferRepo: TTransferRepository;
    FValidationRepo: TValidationRepository;
    FEventRepo: TEventRepository;

    FImageProcessor: TCPImageProcessor;
    FValidationRunner: TCPValidationRunner;

    FLastPhoto: TPhotoModel;
    procedure BindSession(const Session: TSessionModel; const Paths: TSessionPaths; DB: TCPDatabaseManager);
    procedure AutoRestoreSession;
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance: TCPAppContext;
    class destructor ClassDestroy;

    function CreateNewSession(const Site, OperatorName, DateStr: string): TSessionModel;
    function OpenSession(const FolderName: string): Boolean;
    procedure CloseActiveSession;
    function UpdateSession(const FolderName, Site, OperatorName, DateStr: string): Boolean;
    function DeleteSession(const FolderName: string): Boolean;
    function ListAvailableSessions: TArray<string>;

    function RunPreflight(const HoleId, TrayId: string; IntervalFrom, IntervalTo: Double; const CropRegion: TCropRegion): TPreflightResult;
    function ExecuteCapture(const HoleId, TrayId: string; IntervalFrom, IntervalTo: Double; const CropRegion: TCropRegion; const Comments: string = ''; TrayRows: Integer = 1; TrayLength: Double = 0; TrayWidth: Double = 0): TPhotoModel;
    procedure RetakeCurrent;
    function ValidatePhoto(PhotoId: Integer; out Errors: TArray<string>): Boolean;

    function GetServerFolder: string;
    function TransferPhotoToServerFolder(const Photo: TPhotoModel; const ServerDir: string = ''): Boolean;
    function SyncSessionToServerFolder(const ServerDir: string = ''; out SyncedCount: Integer): Boolean;

    property Config: TCPConfigManager read FConfig;
    property Storage: TCPStorageManager read FStorage;
    property Camera: TCPCameraManager read FCamera;
    property ActiveSession: TSessionModel read FActiveSession;
    property SessionPaths: TSessionPaths read FSessionPaths;
    property LastPhoto: TPhotoModel read FLastPhoto;
    property PhotoRepo: TPhotoRepository read FPhotoRepo;
    property TrayRepo: TTrayRepository read FTrayRepo;
    property SessionRepo: TSessionRepository read FSessionRepo;
  end;

function GetAppContext: TCPAppContext;

implementation

uses
  CP.Core.Logger, CP.Camera.Intf;

function GetAppContext: TCPAppContext;
begin
  Result := TCPAppContext.Instance;
end;

constructor TCPAppContext.Create;
begin
  inherited Create;
  FConfig := GetConfig;
  FStorage := GetStorageManager;
  FCamera := GetCameraManager;
  AutoRestoreSession;
end;

destructor TCPAppContext.Destroy;
begin
  CloseActiveSession;
  inherited Destroy;
end;

class function TCPAppContext.Instance: TCPAppContext;
begin
  if FInstance = nil then
    FInstance := TCPAppContext.Create;
  Result := FInstance;
end;

class destructor TCPAppContext.ClassDestroy;
begin
  FInstance.Free;
end;

procedure TCPAppContext.AutoRestoreSession;
var
  Sessions: TArray<string>;
  I: Integer;
  Paths: TSessionPaths;
  DB: TCPDatabaseManager;
  SRepo: TSessionRepository;
  Active: TSessionModel;
begin
  try
    Sessions := FStorage.ListSessions;
    if Length(Sessions) = 0 then Exit;
    TArray.Sort<string>(Sessions);

    for I := High(Sessions) downto 0 do
    begin
      Paths := FStorage.GetSessionPaths(Sessions[I]);
      if TFile.Exists(Paths.DbPath) then
      begin
        DB := TCPDatabaseManager.Create(Paths.DbPath);
        SRepo := TSessionRepository.Create(DB);
        try
          Active := SRepo.GetActive;
          if Active.Id <> '' then
          begin
            BindSession(Active, Paths, DB);
            Log.Info('Auto-restored active session: ' + Active.Id);
            Break;
          end
          else
            DB.Free;
        finally
          SRepo.Free;
        end;
      end;
    end;
  except
    on E: Exception do
      Log.Error('Error during session auto-restore: ' + E.Message);
  end;
end;

procedure TCPAppContext.BindSession(const Session: TSessionModel; const Paths: TSessionPaths; DB: TCPDatabaseManager);
begin
  CloseActiveSession;
  FActiveSession := Session;
  FSessionPaths := Paths;
  FSessionDB := DB;

  FSessionRepo := TSessionRepository.Create(FSessionDB);
  FTrayRepo := TTrayRepository.Create(FSessionDB);
  FPhotoRepo := TPhotoRepository.Create(FSessionDB);
  FTransferRepo := TTransferRepository.Create(FSessionDB);
  FValidationRepo := TValidationRepository.Create(FSessionDB);
  FEventRepo := TEventRepository.Create(FSessionDB);

  FImageProcessor := TCPImageProcessor.Create(FPhotoRepo);
  FValidationRunner := TCPValidationRunner.Create(FPhotoRepo, FValidationRepo);

  FEventRepo.LogEvent(FActiveSession.Id, 'SESSION_ACTIVE', Format('Session %s bound', [FActiveSession.Id]));
end;

procedure TCPAppContext.CloseActiveSession;
begin
  FreeAndNil(FValidationRunner);
  FreeAndNil(FImageProcessor);
  FreeAndNil(FEventRepo);
  FreeAndNil(FValidationRepo);
  FreeAndNil(FTransferRepo);
  FreeAndNil(FPhotoRepo);
  FreeAndNil(FTrayRepo);
  FreeAndNil(FSessionRepo);
  FreeAndNil(FSessionDB);
  FillChar(FActiveSession, SizeOf(FActiveSession), 0);
  FillChar(FSessionPaths, SizeOf(FSessionPaths), 0);
end;

function TCPAppContext.CreateNewSession(const Site, OperatorName, DateStr: string): TSessionModel;
var
  Paths: TSessionPaths;
  DB: TCPDatabaseManager;
  SRepo: TSessionRepository;
begin
  Paths := FStorage.CreateSessionStorage(Site, DateStr);
  DB := TCPDatabaseManager.Create(Paths.DbPath);
  SRepo := TSessionRepository.Create(DB);
  try
    Result.Id := ExtractFileName(Paths.SessionDir);
    Result.Site := Site;
    Result.DateStr := DateStr;
    Result.OperatorName := OperatorName;
    Result.Status := 'ACTIVE';
    Result := SRepo.CreateSession(Result);
    BindSession(Result, Paths, DB);
  finally
    SRepo.Free;
  end;
end;

function TCPAppContext.OpenSession(const FolderName: string): Boolean;
var
  Paths: TSessionPaths;
  DB: TCPDatabaseManager;
  SRepo: TSessionRepository;
  Sess: TSessionModel;
begin
  Result := False;
  Paths := FStorage.GetSessionPaths(FolderName);
  if not TFile.Exists(Paths.DbPath) then Exit;

  DB := TCPDatabaseManager.Create(Paths.DbPath);
  SRepo := TSessionRepository.Create(DB);
  try
    Sess := SRepo.GetActive;
    if Sess.Id = '' then
    begin
      var AllList := SRepo.ListAll;
      try
        if AllList.Count > 0 then Sess := AllList[0];
      finally
        AllList.Free;
      end;
    end;
    if Sess.Id <> '' then
    begin
      BindSession(Sess, Paths, DB);
      Result := True;
    end
    else
      DB.Free;
  finally
    SRepo.Free;
  end;
end;

function TCPAppContext.UpdateSession(const FolderName, Site, OperatorName, DateStr: string): Boolean;
var
  Paths: TSessionPaths;
  DB: TCPDatabaseManager;
  SRepo: TSessionRepository;
  Sess: TSessionModel;
begin
  Result := False;
  Paths := FStorage.GetSessionPaths(FolderName);
  if not TFile.Exists(Paths.DbPath) then Exit;

  if (FSessionPaths.SessionDir = Paths.SessionDir) and (FSessionRepo <> nil) then
  begin
    FActiveSession.Site := Site;
    FActiveSession.OperatorName := OperatorName;
    FActiveSession.DateStr := DateStr;
    Result := FSessionRepo.UpdateSession(FActiveSession);
    Exit;
  end;

  DB := TCPDatabaseManager.Create(Paths.DbPath);
  try
    SRepo := TSessionRepository.Create(DB);
    try
      Sess := SRepo.GetActive;
      if Sess.Id <> '' then
      begin
        Sess.Site := Site;
        Sess.OperatorName := OperatorName;
        Sess.DateStr := DateStr;
        Result := SRepo.UpdateSession(Sess);
      end;
    finally
      SRepo.Free;
    end;
  finally
    DB.Free;
  end;
end;

function TCPAppContext.DeleteSession(const FolderName: string): Boolean;
begin
  if ExtractFileName(FSessionPaths.SessionDir) = FolderName then
    CloseActiveSession;
  Result := FStorage.DeleteSession(FolderName);
end;

function TCPAppContext.ListAvailableSessions: TArray<string>;
begin
  Result := FStorage.ListSessions;
end;

function TCPAppContext.RunPreflight(const HoleId, TrayId: string; IntervalFrom, IntervalTo: Double; const CropRegion: TCropRegion): TPreflightResult;
begin
  Result := TPreflightChecker.Check(
    FCamera.IsReady,
    FCamera.IsReady,
    FActiveSession,
    HoleId,
    TrayId,
    IntervalFrom,
    IntervalTo,
    CropRegion,
    FStorage
  );
end;

function TCPAppContext.ExecuteCapture(
  const HoleId, TrayId: string;
  IntervalFrom, IntervalTo: Double;
  const CropRegion: TCropRegion;
  const Comments: string;
  TrayRows: Integer;
  TrayLength, TrayWidth: Double
): TPhotoModel;
var
  Tray: TTrayModel;
  CapRes: TCaptureResult;
  Info: TCameraInfo;
begin
  if FActiveSession.Id = '' then raise Exception.Create('Tidak ada sesi aktif.');
  if not FCamera.IsReady then raise Exception.Create('Kamera tidak siap untuk capture.');

  if FTrayRepo <> nil then
  begin
    Tray := FTrayRepo.GetByHoleAndTray(FActiveSession.Id, HoleId, TrayId);
    if Tray.Id = 0 then
    begin
      Tray.SessionId := FActiveSession.Id;
      Tray.HoleId := HoleId;
      Tray.TrayId := TrayId;
      Tray.IntervalFrom := IntervalFrom;
      Tray.IntervalTo := IntervalTo;
      Tray.TrayRows := TrayRows;
      Tray.TrayLength := TrayLength;
      Tray.TrayWidth := TrayWidth;
      Tray.Comments := Comments;
      Tray.Status := 'IN_PROGRESS';
      Tray := FTrayRepo.CreateTray(Tray);
    end;
  end;

  CapRes := FCamera.Capture;
  Info := FCamera.GetInfo;

  Result := FImageProcessor.ProcessCapture(
    CapRes.RawBytes,
    FSessionPaths,
    FActiveSession,
    Tray,
    CropRegion,
    Info.Model,
    Info.SerialNumber,
    CapRes.Format
  );
  FLastPhoto := Result;
end;

procedure TCPAppContext.RetakeCurrent;
begin
  if (FLastPhoto.Id > 0) and (FPhotoRepo <> nil) then
  begin
    FPhotoRepo.MarkAsSuperseded(FLastPhoto.Id);
    if FEventRepo <> nil then
      FEventRepo.LogEvent(FActiveSession.Id, 'RETAKE', Format('Photo %d marked as SUPERSEDED for retake', [FLastPhoto.Id]));
  end;
end;

function TCPAppContext.ValidatePhoto(PhotoId: Integer; out Errors: TArray<string>): Boolean;
begin
  if FValidationRunner <> nil then
    Result := FValidationRunner.ValidatePhoto(PhotoId, Errors)
  else
  begin
    Errors := ['Validation runner not initialized'];
    Result := False;
  end;
end;

function TCPAppContext.GetServerFolder: string;
begin
  Result := FConfig.GetString('transfer', 'server_folder', '');
  if Result = '' then
    Result := FConfig.GetString('storage', 'server_folder', '');
end;

function TCPAppContext.TransferPhotoToServerFolder(const Photo: TPhotoModel; const ServerDir: string): Boolean;
var
  TargetDir, SessFolder, DestJpg, DestRaw, DestThumbs: string;
begin
  Result := False;
  TargetDir := ServerDir;
  if TargetDir = '' then TargetDir := GetServerFolder;
  if TargetDir = '' then Exit;

  try
    SessFolder := TPath.Combine(TargetDir, ExtractFileName(FSessionPaths.SessionDir));
    DestJpg := TPath.Combine(SessFolder, 'jpg');
    DestRaw := TPath.Combine(SessFolder, 'raw');
    DestThumbs := TPath.Combine(SessFolder, 'thumbs');

    TDirectory.CreateDirectory(DestJpg);
    TDirectory.CreateDirectory(DestRaw);
    TDirectory.CreateDirectory(DestThumbs);

    if (Photo.JpgPath <> '') and TFile.Exists(Photo.JpgPath) then
      TFile.Copy(Photo.JpgPath, TPath.Combine(DestJpg, ExtractFileName(Photo.JpgPath)), True);
    if (Photo.RawPath <> '') and TFile.Exists(Photo.RawPath) then
      TFile.Copy(Photo.RawPath, TPath.Combine(DestRaw, ExtractFileName(Photo.RawPath)), True);
    if (Photo.ThumbnailPath <> '') and TFile.Exists(Photo.ThumbnailPath) then
      TFile.Copy(Photo.ThumbnailPath, TPath.Combine(DestThumbs, ExtractFileName(Photo.ThumbnailPath)), True);

    if FTransferRepo <> nil then
    begin
      var TM: TTransferModel;
      TM.PhotoId := Photo.Id;
      TM.ServerUrl := TargetDir;
      TM.Status := 'SUCCESS';
      FTransferRepo.CreateTransfer(TM);
    end;
    Result := True;
  except
    on E: Exception do Log.Error('Transfer photo failed: ' + E.Message);
  end;
end;

function TCPAppContext.SyncSessionToServerFolder(const ServerDir: string; out SyncedCount: Integer): Boolean;
var
  TargetDir, SessFolder, DestJpg, DestRaw, DestThumbs: string;
  Files: TArray<string>;
  I: Integer;
begin
  SyncedCount := 0;
  Result := False;
  TargetDir := ServerDir;
  if TargetDir = '' then TargetDir := GetServerFolder;
  if TargetDir = '' then Exit;

  try
    SessFolder := TPath.Combine(TargetDir, ExtractFileName(FSessionPaths.SessionDir));
    DestJpg := TPath.Combine(SessFolder, 'jpg');
    DestRaw := TPath.Combine(SessFolder, 'raw');
    DestThumbs := TPath.Combine(SessFolder, 'thumbs');

    TDirectory.CreateDirectory(DestJpg);
    TDirectory.CreateDirectory(DestRaw);
    TDirectory.CreateDirectory(DestThumbs);

    if TDirectory.Exists(FSessionPaths.JpgDir) then
    begin
      Files := TDirectory.GetFiles(FSessionPaths.JpgDir, '*.jpg');
      for I := 0 to High(Files) do
      begin
        TFile.Copy(Files[I], TPath.Combine(DestJpg, ExtractFileName(Files[I])), True);
        Inc(SyncedCount);
      end;
    end;

    if TDirectory.Exists(FSessionPaths.RawDir) then
    begin
      Files := TDirectory.GetFiles(FSessionPaths.RawDir, '*.*');
      for I := 0 to High(Files) do
        TFile.Copy(Files[I], TPath.Combine(DestRaw, ExtractFileName(Files[I])), True);
    end;

    if TDirectory.Exists(FSessionPaths.ThumbnailDir) then
    begin
      Files := TDirectory.GetFiles(FSessionPaths.ThumbnailDir, '*.jpg');
      for I := 0 to High(Files) do
        TFile.Copy(Files[I], TPath.Combine(DestThumbs, ExtractFileName(Files[I])), True);
    end;

    Files := TDirectory.GetFiles(FSessionPaths.SessionDir, '*.csv');
    for I := 0 to High(Files) do
      TFile.Copy(Files[I], TPath.Combine(SessFolder, ExtractFileName(Files[I])), True);

    Result := True;
  except
    on E: Exception do Log.Error('Sync session failed: ' + E.Message);
  end;
end;

end.
