unit CP.Camera.Manager;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, Vcl.Graphics,
  CP.Camera.Intf, CP.Camera.Capabilities, CP.Camera.Webcam,
  CP.Camera.DirectUsb, CP.Camera.HotFolder, CP.Camera.WiFiDslr;

type
  TCPCameraManager = class
  strict private
    FActiveAdapter: ICameraAdapter;
    FTargetW, FTargetH: Integer;
    FResolutionMode: string;
  private
    class var FInstance: TCPCameraManager;
    class var FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance: TCPCameraManager;
    class destructor ClassDestroy;

    function ConnectCamera(const AdapterName: string = 'webcam'; const DeviceId: string = '0'): Boolean;
    function DisconnectCamera: Boolean;
    function IsReady: Boolean;
    function GetStatusSummary: string;
    function GetInfo: TCameraInfo;
    function GetCapabilities: TCameraCapabilities;
    function StartLiveView(Callback: TLiveFrameCallback = nil): Boolean;
    function StopLiveView: Boolean;
    function GetLiveFrame: TBitmap;
    function Capture: TCaptureResult;
    function SetResolution(Width, Height: Integer; const Mode: string = 'custom'): Boolean;
    function TestWiFiConnection(const IP: string; Port: Integer = 15740): Boolean;

    property ActiveAdapter: ICameraAdapter read FActiveAdapter;
  end;

function GetCameraManager: TCPCameraManager;

implementation

uses
  CP.Core.Logger, CP.Config.Manager;

function GetCameraManager: TCPCameraManager;
begin
  Result := TCPCameraManager.Instance;
end;

constructor TCPCameraManager.Create;
begin
  inherited Create;
  FTargetW := 5184;
  FTargetH := 3456;
  FResolutionMode := 'best_native';
end;

destructor TCPCameraManager.Destroy;
begin
  DisconnectCamera;
  inherited Destroy;
end;

class function TCPCameraManager.Instance: TCPCameraManager;
begin
  if FInstance = nil then
  begin
    if FLock = nil then FLock := TCriticalSection.Create;
    FLock.Enter;
    try
      if FInstance = nil then FInstance := TCPCameraManager.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstance;
end;

class destructor TCPCameraManager.ClassDestroy;
begin
  FInstance.Free;
  FLock.Free;
end;

function TCPCameraManager.ConnectCamera(const AdapterName, DeviceId: string): Boolean;
var
  LowName: string;
begin
  DisconnectCamera;
  LowName := LowerCase(Trim(AdapterName));

  if (LowName = 'wifi_dslr') or (LowName = 'wifi') or (LowName = 'dslr_wifi') then
    FActiveAdapter := TWiFiDslrAdapter.Create
  else if (LowName = 'direct_usb') or (LowName = 'direct') or (LowName = 'ptp') then
    FActiveAdapter := TDirectUsbAdapter.Create
  else if (LowName = 'hot_folder') or (LowName = 'hotfolder') then
    FActiveAdapter := THotFolderAdapter.Create
  else
    FActiveAdapter := TWebcamAdapter.Create;

  Result := FActiveAdapter.Connect(DeviceId);
  if not Result then
  begin
    // Fallback chain matching Python manager.py
    Log.Warn('Camera adapter failed. Initiating auto-fallback chain...');
    FActiveAdapter := TWebcamAdapter.Create;
    Result := FActiveAdapter.Connect('0');
    if not Result then
    begin
      FActiveAdapter := TWebcamAdapter.Create;
      Result := FActiveAdapter.Connect('sim');
    end;
  end;
end;

function TCPCameraManager.DisconnectCamera: Boolean;
begin
  Result := True;
  if FActiveAdapter <> nil then
  begin
    Result := FActiveAdapter.Disconnect;
    FActiveAdapter := nil;
  end;
end;

function TCPCameraManager.IsReady: Boolean;
begin
  Result := (FActiveAdapter <> nil) and (FActiveAdapter.GetState in [csReady, csStreaming, csCapturing]);
end;

function TCPCameraManager.GetStatusSummary: string;
var
  Info: TCameraInfo;
begin
  if FActiveAdapter = nil then Exit('Camera: None — Disconnected');
  Info := FActiveAdapter.GetInfo;
  case FActiveAdapter.GetState of
    csReady, csStreaming, csCapturing: Result := Format('Camera: %s — Connected', [Info.Model]);
    csConnecting: Result := Format('Camera: %s — Connecting...', [Info.Model]);
    csError: Result := Format('Camera: %s — Error', [Info.Model]);
  else
    Result := 'Camera: Disconnected';
  end;
end;

function TCPCameraManager.GetInfo: TCameraInfo;
begin
  if FActiveAdapter <> nil then Result := FActiveAdapter.GetInfo
  else Result := Default(TCameraInfo);
end;

function TCPCameraManager.GetCapabilities: TCameraCapabilities;
begin
  if FActiveAdapter <> nil then Result := FActiveAdapter.GetCapabilities
  else Result := TCameraCapabilities.DefaultCaps;
end;

function TCPCameraManager.StartLiveView(Callback: TLiveFrameCallback): Boolean;
begin
  if FActiveAdapter <> nil then Result := FActiveAdapter.StartLiveView(Callback)
  else Result := False;
end;

function TCPCameraManager.StopLiveView: Boolean;
begin
  if FActiveAdapter <> nil then Result := FActiveAdapter.StopLiveView
  else Result := False;
end;

function TCPCameraManager.GetLiveFrame: TBitmap;
begin
  if FActiveAdapter <> nil then Result := FActiveAdapter.GetLiveFrame
  else Result := nil;
end;

function TCPCameraManager.Capture: TCaptureResult;
begin
  if FActiveAdapter = nil then raise Exception.Create('No camera connected.');
  Result := FActiveAdapter.Capture;
end;

function TCPCameraManager.SetResolution(Width, Height: Integer; const Mode: string): Boolean;
begin
  FTargetW := Width;
  FTargetH := Height;
  FResolutionMode := Mode;
  if FActiveAdapter <> nil then
  begin
    FActiveAdapter.SetSetting('resolution_w', IntToStr(Width));
    FActiveAdapter.SetSetting('resolution_h', IntToStr(Height));
    FActiveAdapter.SetSetting('resolution_mode', Mode);
  end;
  GetConfig.SetString('camera', 'resolution_mode', Mode);
  GetConfig.Save;
  Result := True;
end;

function TCPCameraManager.TestWiFiConnection(const IP: string; Port: Integer): Boolean;
begin
  Result := TWiFiDslrAdapter.TestIPReachability(IP, Port);
end;

end.
