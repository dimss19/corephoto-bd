unit CP.Diagnostics;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.JSON,
  CP.Storage.Manager, CP.DB.Manager, CP.DB.Repositories;

type
  TCPDiagnosticsManager = class
  private
    FStorage: TCPStorageManager;
    FDB: TCPDatabaseManager;
    FPhotoRepo: TPhotoRepository;
  public
    constructor Create(AStorage: TCPStorageManager = nil; ADB: TCPDatabaseManager = nil; APhotoRepo: TPhotoRepository = nil);
    function RunAllChecks: TJSONObject;
    function ReadRecentLogs(MaxLines: Integer = 100): string;
    function ResumeIncompleteCaptures: Integer;
    function ExportReport(const DestPath: string): string;
  end;

implementation

uses
  CP.Core.Logger;

constructor TCPDiagnosticsManager.Create(AStorage: TCPStorageManager; ADB: TCPDatabaseManager; APhotoRepo: TPhotoRepository);
begin
  inherited Create;
  if AStorage <> nil then FStorage := AStorage else FStorage := GetStorageManager;
  if ADB <> nil then FDB := ADB else FDB := GetDB;
  FPhotoRepo := APhotoRepo;
end;

function TCPDiagnosticsManager.RunAllChecks: TJSONObject;
var
  StorageObj, DbObj, SysObj, RecObj: TJSONObject;
  Sessions: TArray<string>;
  Incomplete: TList<TPhotoModel>;
begin
  Result := TJSONObject.Create;
  Result.AddPair('timestamp', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Now));

  // Storage
  StorageObj := TJSONObject.Create;
  StorageObj.AddPair('base_dir', FStorage.BaseDir);
  StorageObj.AddPair('free_space_mb', TJSONNumber.Create(FStorage.GetAvailableSpaceMB));
  StorageObj.AddPair('sufficient', TJSONBool.Create(FStorage.IsStorageSufficient(500.0)));
  Sessions := FStorage.ListSessions;
  StorageObj.AddPair('sessions_count', TJSONNumber.Create(Length(Sessions)));
  Result.AddPair('storage', StorageObj);

  // Database
  DbObj := TJSONObject.Create;
  try
    if FDB <> nil then
    begin
      DbObj.AddPair('status', 'OK');
      DbObj.AddPair('session_db', FDB.DbPath);
    end
    else
      DbObj.AddPair('status', 'NO_DB');
  except
    on E: Exception do
      DbObj.AddPair('error', E.Message);
  end;
  Result.AddPair('database', DbObj);

  // System
  SysObj := TJSONObject.Create;
  SysObj.AddPair('mode', 'Delphi Native Win64 Standalone');
  SysObj.AddPair('status', 'OK');
  Result.AddPair('system', SysObj);

  // Crash recovery
  RecObj := TJSONObject.Create;
  if FPhotoRepo <> nil then
  begin
    Incomplete := FPhotoRepo.GetIncompletePhotos;
    try
      RecObj.AddPair('incomplete_captures_found', TJSONNumber.Create(Incomplete.Count));
    finally
      Incomplete.Free;
    end;
  end
  else
    RecObj.AddPair('incomplete_captures_found', TJSONNumber.Create(0));
  Result.AddPair('recovery', RecObj);
end;

function TCPDiagnosticsManager.ReadRecentLogs(MaxLines: Integer): string;
var
  LogFile: string;
  Lines: TStringList;
  I, StartIdx: Integer;
  SB: TStringBuilder;
begin
  LogFile := TPath.Combine(FStorage.LogsDir, 'corephoto.log');
  if not TFile.Exists(LogFile) then
    Exit('File log belum dibuat.');

  Lines := TStringList.Create;
  SB := TStringBuilder.Create;
  try
    Lines.LoadFromFile(LogFile, TEncoding.UTF8);
    StartIdx := Lines.Count - MaxLines;
    if StartIdx < 0 then StartIdx := 0;
    for I := StartIdx to Lines.Count - 1 do
      SB.AppendLine(Lines[I]);
    Result := SB.ToString;
  finally
    Lines.Free;
    SB.Free;
  end;
end;

function TCPDiagnosticsManager.ResumeIncompleteCaptures: Integer;
var
  Incomplete: TList<TPhotoModel>;
begin
  Result := 0;
  if FPhotoRepo = nil then Exit;
  Incomplete := FPhotoRepo.GetIncompletePhotos;
  try
    Result := Incomplete.Count;
  finally
    Incomplete.Free;
  end;
end;

function TCPDiagnosticsManager.ExportReport(const DestPath: string): string;
var
  Obj: TJSONObject;
  Dir: string;
begin
  Obj := RunAllChecks;
  try
    Dir := ExtractFilePath(DestPath);
    if not TDirectory.Exists(Dir) then
      TDirectory.CreateDirectory(Dir);
    TFile.WriteAllText(DestPath, Obj.Format(2), TEncoding.UTF8);
    Result := DestPath;
  finally
    Obj.Free;
  end;
end;

end.
