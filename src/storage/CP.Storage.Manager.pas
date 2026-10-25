unit CP.Storage.Manager;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.IOUtils, System.RegularExpressions,
  Winapi.Windows;

type
  TSessionPaths = record
    SessionDir: string;
    RawDir: string;
    JpgDir: string;
    ThumbnailDir: string;
    DbPath: string;
    function Exists: Boolean;
  end;

  TCPStorageManager = class
  private
    FBaseDir: string;
    FSessionsDir: string;
    FLogsDir: string;
    FConfigDir: string;
    FBackupDir: string;
    procedure EnsureBaseStructure;
  public
    constructor Create(const ABaseDir: string = '');
    class function SanitizeIdentifier(const Value: string): string;

    function GetSessionPaths(const FolderName: string): TSessionPaths;
    function CreateSessionStorage(const Site, DateStr: string; const Suffix: string = ''): TSessionPaths;
    function ListSessions: TArray<string>;
    function DeleteSession(const FolderName: string): Boolean;
    function GetAvailableSpaceMB(const TargetPath: string = ''): Double;
    function IsStorageSufficient(MinMB: Double = 500.0; const TargetPath: string = ''): Boolean;

    property BaseDir: string read FBaseDir;
    property SessionsDir: string read FSessionsDir;
    property LogsDir: string read FLogsDir;
    property BackupDir: string read FBackupDir;
  end;

function GetStorageManager: TCPStorageManager;

implementation

uses
  CP.Config.Manager, CP.Core.Logger;

var
  GStorageManager: TCPStorageManager = nil;

function GetStorageManager: TCPStorageManager;
begin
  if GStorageManager = nil then
    GStorageManager := TCPStorageManager.Create;
  Result := GStorageManager;
end;

function TSessionPaths.Exists: Boolean;
begin
  Result := TDirectory.Exists(SessionDir);
end;

constructor TCPStorageManager.Create(const ABaseDir: string);
var
  AppDir, CfgBase: string;
begin
  inherited Create;
  AppDir := ExtractFilePath(ParamStr(0));
  if ABaseDir <> '' then
    FBaseDir := TPath.GetFullPath(ABaseDir)
  else
  begin
    CfgBase := GetConfig.GetString('storage', 'base_dir', 'CorePhotoData');
    if TPath.IsPathRooted(CfgBase) then
      FBaseDir := TPath.GetFullPath(CfgBase)
    else
      FBaseDir := TPath.GetFullPath(TPath.Combine(AppDir, CfgBase));
  end;

  FSessionsDir := TPath.Combine(FBaseDir, 'Sessions');
  FLogsDir := TPath.Combine(FBaseDir, 'Logs');
  FConfigDir := TPath.Combine(FBaseDir, 'Config');
  FBackupDir := TPath.Combine(FBaseDir, 'Backup');

  EnsureBaseStructure;
end;

procedure TCPStorageManager.EnsureBaseStructure;
begin
  TDirectory.CreateDirectory(FBaseDir);
  TDirectory.CreateDirectory(FSessionsDir);
  TDirectory.CreateDirectory(FLogsDir);
  TDirectory.CreateDirectory(FConfigDir);
  TDirectory.CreateDirectory(FBackupDir);
end;

class function TCPStorageManager.SanitizeIdentifier(const Value: string): string;
var
  Clean: string;
begin
  if Trim(Value) = '' then
    Exit('unnamed');
  Clean := TRegEx.Replace(Trim(Value), '[/\:*?"<>|.]+', '_');
  Clean := TRegEx.Replace(Clean, '_+', '_');
  while (Length(Clean) > 0) and (Clean[1] = '_') do
    Delete(Clean, 1, 1);
  while (Length(Clean) > 0) and (Clean[Length(Clean)] = '_') do
    Delete(Clean, Length(Clean), 1);
  if Clean = '' then
    Result := 'unnamed'
  else
    Result := Clean;
end;

function TCPStorageManager.GetSessionPaths(const FolderName: string): TSessionPaths;
var
  SafeName, ResolvedPath, FullSessions: string;
begin
  SafeName := SanitizeIdentifier(FolderName);
  ResolvedPath := TPath.GetFullPath(TPath.Combine(FSessionsDir, SafeName));
  FullSessions := TPath.GetFullPath(FSessionsDir);

  if not ResolvedPath.StartsWith(FullSessions, True) then
    raise Exception.Create('Path traversal detected: ' + FolderName);

  Result.SessionDir := ResolvedPath;
  Result.RawDir := TPath.Combine(ResolvedPath, 'raw');
  Result.JpgDir := TPath.Combine(ResolvedPath, 'jpg');
  Result.ThumbnailDir := TPath.Combine(ResolvedPath, 'thumbs');
  Result.DbPath := TPath.Combine(ResolvedPath, 'session.db');
end;

function TCPStorageManager.CreateSessionStorage(const Site, DateStr: string; const Suffix: string): TSessionPaths;
var
  SafeSite, SafeDate, BaseFolder, FolderName: string;
  Counter: Integer;
begin
  SafeSite := SanitizeIdentifier(Site);
  SafeDate := SanitizeIdentifier(DateStr);
  BaseFolder := SafeSite + '_' + SafeDate;

  FolderName := BaseFolder;
  if Suffix <> '' then
    FolderName := BaseFolder + '_' + SanitizeIdentifier(Suffix);

  Counter := 1;
  Result := GetSessionPaths(FolderName);
  while Result.Exists and (Suffix = '') do
  begin
    FolderName := Format('%s_%0.2d', [BaseFolder, Counter]);
    Result := GetSessionPaths(FolderName);
    Inc(Counter);
  end;

  TDirectory.CreateDirectory(Result.SessionDir);
  TDirectory.CreateDirectory(Result.RawDir);
  TDirectory.CreateDirectory(Result.JpgDir);
  TDirectory.CreateDirectory(Result.ThumbnailDir);

  Log.Info('Session storage created at: ' + Result.SessionDir);
end;

function TCPStorageManager.ListSessions: TArray<string>;
var
  Dirs: TArray<string>;
  I: Integer;
begin
  if not TDirectory.Exists(FSessionsDir) then
    Exit(nil);
  Dirs := TDirectory.GetDirectories(FSessionsDir);
  SetLength(Result, Length(Dirs));
  for I := 0 to High(Dirs) do
    Result[I] := ExtractFileName(Dirs[I]);
end;

function TCPStorageManager.DeleteSession(const FolderName: string): Boolean;
var
  Paths: TSessionPaths;
begin
  Result := False;
  try
    Paths := GetSessionPaths(FolderName);
    if Paths.Exists then
    begin
      TDirectory.Delete(Paths.SessionDir, True);
      Log.Info('Session storage deleted: ' + Paths.SessionDir);
      Result := True;
    end;
  except
    on E: Exception do
      Log.Error('Failed deleting session ' + FolderName + ': ' + E.Message);
  end;
end;

function TCPStorageManager.GetAvailableSpaceMB(const TargetPath: string): Double;
var
  PathCheck: string;
  FreeBytesAvailable, TotalNumberOfBytes, TotalNumberOfFreeBytes: Int64;
begin
  Result := 0.0;
  if TargetPath <> '' then
    PathCheck := TargetPath
  else
    PathCheck := FBaseDir;

  if GetDiskFreeSpaceEx(PChar(PathCheck), FreeBytesAvailable, TotalNumberOfBytes, @TotalNumberOfFreeBytes) then
    Result := FreeBytesAvailable / (1024.0 * 1024.0);
end;

function TCPStorageManager.IsStorageSufficient(MinMB: Double; const TargetPath: string): Boolean;
begin
  Result := GetAvailableSpaceMB(TargetPath) >= MinMB;
end;

initialization
finalization
  GStorageManager.Free;
end.
