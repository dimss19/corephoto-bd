unit CP.Config.Manager;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.JSON, System.SyncObjs;

type
  TCPConfigManager = class
  strict private
    FConfigPath: string;
    FRoot: TJSONObject;
    FFileLock: TCriticalSection;
    procedure EnsureDefaults;
  private
    class var FInstance: TCPConfigManager;
    class var FLock: TCriticalSection;
  public
    constructor Create(const AConfigPath: string = '');
    destructor Destroy; override;
    class function Instance: TCPConfigManager;
    class destructor ClassDestroy;

    function Load: Boolean;
    function Save: Boolean;

    function GetString(const Section, Key, DefaultVal: string): string;
    function GetInteger(const Section, Key: string; DefaultVal: Integer): Integer;
    function GetFloat(const Section, Key: string; DefaultVal: Double): Double;
    function GetBool(const Section, Key: string; DefaultVal: Boolean): Boolean;

    procedure SetString(const Section, Key, Val: string; AutoSave: Boolean = True);
    procedure SetInteger(const Section, Key: string; Val: Integer; AutoSave: Boolean = True);
    procedure SetFloat(const Section, Key: string; Val: Double; AutoSave: Boolean = True);
    procedure SetBool(const Section, Key: string; Val: Boolean; AutoSave: Boolean = True);
  end;

function GetConfig: TCPConfigManager;

implementation

uses
  CP.Core.PyFormat;

function GetConfig: TCPConfigManager;
begin
  Result := TCPConfigManager.Instance;
end;

constructor TCPConfigManager.Create(const AConfigPath: string);
var
  AppDir: string;
begin
  inherited Create;
  FFileLock := TCriticalSection.Create;
  AppDir := ExtractFilePath(ParamStr(0));
  if AConfigPath <> '' then
    FConfigPath := AConfigPath
  else
    FConfigPath := TPath.Combine(AppDir, 'config\settings.json');

  FRoot := TJSONObject.Create;
  Load;
end;

destructor TCPConfigManager.Destroy;
begin
  FRoot.Free;
  FFileLock.Free;
  inherited Destroy;
end;

class function TCPConfigManager.Instance: TCPConfigManager;
begin
  if FInstance = nil then
  begin
    if FLock = nil then
      FLock := TCriticalSection.Create;
    FLock.Enter;
    try
      if FInstance = nil then
        FInstance := TCPConfigManager.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstance;
end;

class destructor TCPConfigManager.ClassDestroy;
begin
  FInstance.Free;
  FLock.Free;
end;

procedure TCPConfigManager.EnsureDefaults;
var
  Sec: TJSONObject;
begin
  if FRoot.Values['app'] = nil then
  begin
    Sec := TJSONObject.Create;
    Sec.AddPair('name', 'Core Photo');
    Sec.AddPair('version', '1.0.0');
    Sec.AddPair('theme', 'dark');
    Sec.AddPair('color_theme', 'blue');
    Sec.AddPair('language', 'id');
    FRoot.AddPair('app', Sec);
  end;
  if FRoot.Values['storage'] = nil then
  begin
    Sec := TJSONObject.Create;
    Sec.AddPair('base_dir', 'CorePhotoData');
    Sec.AddPair('backup_dir', 'CorePhotoData/Backup');
    Sec.AddPair('logs_dir', 'CorePhotoData/Logs');
    Sec.AddPair('sessions_dir', 'CorePhotoData/Sessions');
    Sec.AddPair('server_folder', '');
    FRoot.AddPair('storage', Sec);
  end;
  if FRoot.Values['camera'] = nil then
  begin
    Sec := TJSONObject.Create;
    Sec.AddPair('default_adapter', 'webcam');
    Sec.AddPair('connection_type', 'wifi_dslr');
    Sec.AddPair('wifi_ip', '192.168.1.120');
    Sec.AddPair('wifi_port', TJSONNumber.Create(15740));
    Sec.AddPair('tether_folder', 'C:\TestTether');
    Sec.AddPair('preferred_index', TJSONNumber.Create(0));
    Sec.AddPair('resolution_mode', 'best_native');
    Sec.AddPair('fps', TJSONNumber.Create(30));
    Sec.AddPair('device_id', '0');
    Sec.AddPair('camera_maker', 'Canon');
    Sec.AddPair('camera_model', 'Canon EOS 60D');
    Sec.AddPair('f_stop', 'f/10');
    Sec.AddPair('exposure_time', '1/3 sec.');
    Sec.AddPair('iso_speed', 'ISO-200');
    FRoot.AddPair('camera', Sec);
  end;
  if FRoot.Values['imaging'] = nil then
  begin
    Sec := TJSONObject.Create;
    Sec.AddPair('crop_width', TJSONNumber.Create(4276));
    Sec.AddPair('crop_height', TJSONNumber.Create(1998));
    Sec.AddPair('jpg_quality', TJSONNumber.Create(95));
    Sec.AddPair('min_photo_size_mb', TJSONNumber.Create(5.0));
    Sec.AddPair('max_photo_size_mb', TJSONNumber.Create(10.0));
    Sec.AddPair('max_raw_size_mb', TJSONNumber.Create(5.0));
    Sec.AddPair('max_thumbnail_size_mb', TJSONNumber.Create(4.0));
    Sec.AddPair('dpi', TJSONNumber.Create(72));
    Sec.AddPair('bit_depth', TJSONNumber.Create(24));
    Sec.AddPair('preserve_raw', TJSONBool.Create(True));
    FRoot.AddPair('imaging', Sec);
  end;
  if FRoot.Values['validation'] = nil then
  begin
    Sec := TJSONObject.Create;
    Sec.AddPair('min_interval_diff', TJSONNumber.Create(0.0));
    Sec.AddPair('require_comments', TJSONBool.Create(False));
    Sec.AddPair('strict_naming', TJSONBool.Create(True));
    FRoot.AddPair('validation', Sec);
  end;
  if FRoot.Values['transfer'] = nil then
  begin
    Sec := TJSONObject.Create;
    Sec.AddPair('server_url', 'http://127.0.0.1:8000/api/v1');
    Sec.AddPair('server_folder', '');
    Sec.AddPair('api_key', '');
    Sec.AddPair('timeout_seconds', TJSONNumber.Create(30));
    Sec.AddPair('max_retries', TJSONNumber.Create(3));
    Sec.AddPair('chunk_size_kb', TJSONNumber.Create(1024));
    FRoot.AddPair('transfer', Sec);
  end;
  if FRoot.Values['logging'] = nil then
  begin
    Sec := TJSONObject.Create;
    Sec.AddPair('level', 'INFO');
    Sec.AddPair('file_logging', TJSONBool.Create(True));
    Sec.AddPair('max_file_size_mb', TJSONNumber.Create(10));
    Sec.AddPair('backup_count', TJSONNumber.Create(5));
    FRoot.AddPair('logging', Sec);
  end;
end;

function TCPConfigManager.Load: Boolean;
var
  Content: string;
  Parsed: TJSONValue;
begin
  Result := False;
  FFileLock.Enter;
  try
    if TFile.Exists(FConfigPath) then
    begin
      try
        Content := TFile.ReadAllText(FConfigPath, TEncoding.UTF8);
        Parsed := TJSONObject.ParseJSONValue(Content);
        if Parsed is TJSONObject then
        begin
          FRoot.Free;
          FRoot := TJSONObject(Parsed);
          Result := True;
        end;
      except
      end;
    end;
    EnsureDefaults;
    if not Result then
      Save;
  finally
    FFileLock.Leave;
  end;
end;

function TCPConfigManager.Save: Boolean;
var
  PrettyJson: string;
  Dir: string;
begin
  Result := False;
  FFileLock.Enter;
  try
    try
      Dir := ExtractFilePath(FConfigPath);
      if not TDirectory.Exists(Dir) then
        TDirectory.CreateDirectory(Dir);
      PrettyJson := FRoot.Format(2);
      TFile.WriteAllText(FConfigPath, PrettyJson, TEncoding.UTF8);
      Result := True;
    except
    end;
  finally
    FFileLock.Leave;
  end;
end;

function TCPConfigManager.GetString(const Section, Key, DefaultVal: string): string;
var
  Sec: TJSONValue;
  Val: TJSONValue;
begin
  Result := DefaultVal;
  Sec := FRoot.Values[Section];
  if Sec is TJSONObject then
  begin
    Val := TJSONObject(Sec).Values[Key];
    if Val <> nil then
      Result := Val.Value;
  end;
end;

function TCPConfigManager.GetInteger(const Section, Key: string; DefaultVal: Integer): Integer;
var
  S: string;
begin
  S := GetString(Section, Key, IntToStr(DefaultVal));
  Result := StrToIntDef(S, DefaultVal);
end;

function TCPConfigManager.GetFloat(const Section, Key: string; DefaultVal: Double): Double;
var
  S: string;
  FS: TFormatSettings;
begin
  FS := GetInvariantFormatSettings;
  S := GetString(Section, Key, FloatToStr(DefaultVal, FS));
  Result := StrToFloatDef(S, DefaultVal, FS);
end;

function TCPConfigManager.GetBool(const Section, Key: string; DefaultVal: Boolean): Boolean;
var
  Sec: TJSONValue;
  Val: TJSONValue;
begin
  Result := DefaultVal;
  Sec := FRoot.Values[Section];
  if Sec is TJSONObject then
  begin
    Val := TJSONObject(Sec).Values[Key];
    if Val is TJSONBool then
      Result := TJSONBool(Val).AsBoolean
    else if Val <> nil then
      Result := SameText(Val.Value, 'true') or (Val.Value = '1');
  end;
end;

procedure TCPConfigManager.SetString(const Section, Key, Val: string; AutoSave: Boolean);
var
  Sec: TJSONValue;
  Obj: TJSONObject;
begin
  FFileLock.Enter;
  try
    Sec := FRoot.Values[Section];
    if not (Sec is TJSONObject) then
    begin
      Obj := TJSONObject.Create;
      FRoot.AddPair(Section, Obj);
    end
    else
      Obj := TJSONObject(Sec);

    Obj.RemovePair(Key);
    Obj.AddPair(Key, Val);
    if AutoSave then Save;
  finally
    FFileLock.Leave;
  end;
end;

procedure TCPConfigManager.SetInteger(const Section, Key: string; Val: Integer; AutoSave: Boolean);
begin
  SetString(Section, Key, IntToStr(Val), AutoSave);
end;

procedure TCPConfigManager.SetFloat(const Section, Key: string; Val: Double; AutoSave: Boolean);
var
  FS: TFormatSettings;
begin
  FS := GetInvariantFormatSettings;
  SetString(Section, Key, FloatToStr(Val, FS), AutoSave);
end;

procedure TCPConfigManager.SetBool(const Section, Key: string; Val: Boolean; AutoSave: Boolean);
var
  Sec: TJSONValue;
  Obj: TJSONObject;
begin
  FFileLock.Enter;
  try
    Sec := FRoot.Values[Section];
    if not (Sec is TJSONObject) then
    begin
      Obj := TJSONObject.Create;
      FRoot.AddPair(Section, Obj);
    end
    else
      Obj := TJSONObject(Sec);

    Obj.RemovePair(Key);
    Obj.AddPair(Key, TJSONBool.Create(Val));
    if AutoSave then Save;
  finally
    FFileLock.Leave;
  end;
end;

end.
