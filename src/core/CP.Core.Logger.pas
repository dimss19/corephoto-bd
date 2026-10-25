unit CP.Core.Logger;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.SyncObjs;

type
  TCPLogger = class
  private
    class var FInstance: TCPLogger;
    class var FLock: TCriticalSection;
    FLogFile: string;
    FMaxBytes: Int64;
    FBackupCount: Integer;
    FFileLock: TCriticalSection;
    procedure RotateIfNeeded;
    procedure WriteLine(const Level, Msg: string);
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance: TCPLogger;
    class destructor ClassDestroy;
    procedure Init(const LogDir: string; MaxMB: Integer = 10; BackupCount: Integer = 5);
    procedure Info(const Msg: string);
    procedure Warn(const Msg: string);
    procedure Error(const Msg: string);
    procedure Debug(const Msg: string);
  end;

function Log: TCPLogger;

implementation

function Log: TCPLogger;
begin
  Result := TCPLogger.Instance;
end;

constructor TCPLogger.Create;
begin
  inherited Create;
  FFileLock := TCriticalSection.Create;
  FMaxBytes := 10 * 1024 * 1024;
  FBackupCount := 5;
end;

destructor TCPLogger.Destroy;
begin
  FFileLock.Free;
  inherited Destroy;
end;

class function TCPLogger.Instance: TCPLogger;
begin
  if FInstance = nil then
  begin
    if FLock = nil then
      FLock := TCriticalSection.Create;
    FLock.Enter;
    try
      if FInstance = nil then
        FInstance := TCPLogger.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstance;
end;

class destructor TCPLogger.ClassDestroy;
begin
  FInstance.Free;
  FLock.Free;
end;

procedure TCPLogger.Init(const LogDir: string; MaxMB: Integer; BackupCount: Integer);
begin
  FFileLock.Enter;
  try
    TDirectory.CreateDirectory(LogDir);
    FLogFile := TPath.Combine(LogDir, 'corephoto.log');
    FMaxBytes := Int64(MaxMB) * 1024 * 1024;
    FBackupCount := BackupCount;
  finally
    FFileLock.Leave;
  end;
  Info('Logging initialized. File: ' + FLogFile);
end;

procedure TCPLogger.RotateIfNeeded;
var
  I: Integer;
  Src, Dst: string;
begin
  if not TFile.Exists(FLogFile) then Exit;
  if TFile.GetSize(FLogFile) < FMaxBytes then Exit;

  for I := FBackupCount - 1 downto 1 do
  begin
    Src := FLogFile + '.' + IntToStr(I);
    Dst := FLogFile + '.' + IntToStr(I + 1);
    if TFile.Exists(Src) then
    begin
      if TFile.Exists(Dst) then TFile.Delete(Dst);
      TFile.Move(Src, Dst);
    end;
  end;
  Dst := FLogFile + '.1';
  if TFile.Exists(Dst) then TFile.Delete(Dst);
  TFile.Move(FLogFile, Dst);
end;

procedure TCPLogger.WriteLine(const Level, Msg: string);
var
  Line: string;
  FS: TFileStream;
  Bytes: TBytes;
begin
  Line := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' [' + Level + '] ' + Msg + sLineBreak;
  FFileLock.Enter;
  try
    if FLogFile <> '' then
    begin
      RotateIfNeeded;
      if TFile.Exists(FLogFile) then
        FS := TFileStream.Create(FLogFile, fmOpenWrite or fmShareDenyNone)
      else
        FS := TFileStream.Create(FLogFile, fmCreate or fmShareDenyNone);
      try
        FS.Seek(0, soEnd);
        Bytes := TEncoding.UTF8.GetBytes(Line);
        FS.WriteBuffer(Bytes[0], Length(Bytes));
      finally
        FS.Free;
      end;
    end;
  finally
    FFileLock.Leave;
  end;
end;

procedure TCPLogger.Info(const Msg: string);  begin WriteLine('INFO', Msg); end;
procedure TCPLogger.Warn(const Msg: string);  begin WriteLine('WARN', Msg); end;
procedure TCPLogger.Error(const Msg: string); begin WriteLine('ERROR', Msg); end;
procedure TCPLogger.Debug(const Msg: string); begin WriteLine('DEBUG', Msg); end;

end.
