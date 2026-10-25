unit CP.Camera.WiFiDslr;

interface

uses
  Winapi.Windows, Winapi.Winsock2, System.SysUtils, System.Classes, System.Types, System.IOUtils, System.SyncObjs, Vcl.Graphics,
  CP.Camera.Intf, CP.Camera.Capabilities;

type
  TWiFiDslrAdapter = class(TInterfacedObject, ICameraAdapter)
  private
    FState: TCameraState;
    FInfo: TCameraInfo;
    FCaps: TCameraCapabilities;
    FTetherDir: string;
    FCameraIP: string;
    FCameraPort: Integer;
    FIsIpConnected: Boolean;
    FLock: TCriticalSection;
    function DiscoverDefaultTetherDir: string;
  public
    constructor Create(const ATetherDir: string = ''; const ACameraIP: string = '192.168.1.100'; ACameraPort: Integer = 15740);
    destructor Destroy; override;

    class function TestIPReachability(const IP: string; Port: Integer = 15740; TimeoutSec: Double = 0.8): Boolean; static;

    function Connect(const DeviceId: string = ''): Boolean;
    function Disconnect: Boolean;
    function GetState: TCameraState;
    function GetInfo: TCameraInfo;
    function GetCapabilities: TCameraCapabilities;
    function StartLiveView(Callback: TLiveFrameCallback = nil): Boolean;
    function StopLiveView: Boolean;
    function GetLiveFrame: TBitmap;
    function Capture: TCaptureResult;
    function SetSetting(const Key: string; const Value: string): Boolean;
    function GetSetting(const Key: string): string;
  end;

implementation

uses
  CP.Core.Logger;

constructor TWiFiDslrAdapter.Create(const ATetherDir: string; const ACameraIP: string; ACameraPort: Integer);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FState := csDisconnected;
  FCaps := TCameraCapabilities.DefaultCaps;
  FCameraIP := ACameraIP;
  FCameraPort := ACameraPort;

  if ATetherDir <> '' then
    FTetherDir := ATetherDir
  else
    FTetherDir := DiscoverDefaultTetherDir;

  FInfo.Model := 'Wi-Fi DSLR (Canon / Sony / Nikon)';
  FInfo.Vendor := 'Wi-Fi Tethered';
  FInfo.SerialNumber := 'WIFI_CAM_01';
  FInfo.FirmwareVersion := 'Wi-Fi v2.0';
  FInfo.AdapterName := 'WiFiDslrAdapter';
  FInfo.DeviceId := FTetherDir;
end;

destructor TWiFiDslrAdapter.Destroy;
begin
  Disconnect;
  FLock.Free;
  inherited Destroy;
end;

function TWiFiDslrAdapter.DiscoverDefaultTetherDir: string;
var
  Pics: string;
begin
  Pics := TPath.Combine(TPath.GetHomePath, 'Pictures');
  if TDirectory.Exists(TPath.Combine(Pics, 'EOS Utility')) then
    Exit(TPath.Combine(Pics, 'EOS Utility'));
  if TDirectory.Exists(TPath.Combine(Pics, 'Canon EOS Utility')) then
    Exit(TPath.Combine(Pics, 'Canon EOS Utility'));
  if TDirectory.Exists(TPath.Combine(Pics, 'Imaging Edge')) then
    Exit(TPath.Combine(Pics, 'Imaging Edge'));
  Result := TPath.Combine(Pics, 'CorePhoto_Tether');
  TDirectory.CreateDirectory(Result);
end;

class function TWiFiDslrAdapter.TestIPReachability(const IP: string; Port: Integer; TimeoutSec: Double): Boolean;
var
  WSAData: TWSAData;
  Sock: TSocket;
  Addr: TSockAddrIn;
  Mode: u_long;
  FD: TFDSet;
  TimeVal: TTimeVal;
  Res: Integer;
begin
  Result := False;
  if Trim(IP) = '' then Exit;

  if WSAStartup($0202, WSAData) <> 0 then Exit;
  try
    Sock := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if Sock = INVALID_SOCKET then Exit;
    try
      Mode := 1;
      ioctlsocket(Sock, Longint(FIONBIO), Mode); // Non-blocking

      FillChar(Addr, SizeOf(Addr), 0);
      Addr.sin_family := AF_INET;
      Addr.sin_port := htons(Port);
      Addr.sin_addr.S_addr := inet_addr(PAnsiChar(AnsiString(IP)));

      Winapi.Winsock2.connect(Sock, TSockAddr(Addr), SizeOf(Addr));

      FD_ZERO(FD);
      _FD_SET(Sock, FD);
      TimeVal.tv_sec := Trunc(TimeoutSec);
      TimeVal.tv_usec := Trunc(Frac(TimeoutSec) * 1000000);

      Res := select(0, nil, @FD, nil, @TimeVal);
      Result := (Res > 0);
    finally
      closesocket(Sock);
    end;
  finally
    WSACleanup;
  end;
end;

function TWiFiDslrAdapter.Connect(const DeviceId: string): Boolean;
begin
  FLock.Enter;
  try
    FState := csConnecting;
    if DeviceId <> '' then
      FTetherDir := DeviceId;
    TDirectory.CreateDirectory(FTetherDir);

    FIsIpConnected := TestIPReachability(FCameraIP, FCameraPort, 0.5);
    if FIsIpConnected then
      FInfo.Model := 'Wi-Fi DSLR (Connected IP ' + FCameraIP + ')'
    else
      FInfo.Model := 'Wi-Fi DSLR Tethered (Ready for Shutter)';

    FInfo.DeviceId := FTetherDir;
    FState := csReady;
    Log.Info('Wi-Fi DSLR adapter connected. Model: ' + FInfo.Model);
    Result := True;
  finally
    FLock.Leave;
  end;
end;

function TWiFiDslrAdapter.Disconnect: Boolean;
begin
  FState := csDisconnected;
  Result := True;
end;

function TWiFiDslrAdapter.GetState: TCameraState; begin Result := FState; end;
function TWiFiDslrAdapter.GetInfo: TCameraInfo; begin Result := FInfo; end;
function TWiFiDslrAdapter.GetCapabilities: TCameraCapabilities; begin Result := FCaps; end;
function TWiFiDslrAdapter.StartLiveView(Callback: TLiveFrameCallback): Boolean; begin FState := csStreaming; Result := True; end;
function TWiFiDslrAdapter.StopLiveView: Boolean; begin FState := csReady; Result := True; end;

function TWiFiDslrAdapter.GetLiveFrame: TBitmap;
begin
  Result := TBitmap.Create;
  Result.SetSize(1920, 1080);
  Result.Canvas.Brush.Color := RGB(24, 24, 27);
  Result.Canvas.FillRect(Rect(0, 0, 1920, 1080));
  Result.Canvas.Font.Name := 'Segoe UI';
  Result.Canvas.Font.Size := 16;
  Result.Canvas.Font.Color := RGB(217, 83, 30);
  Result.Canvas.TextOut(80, 80, 'Wi-Fi DSLR Wireless Tethering Active');
  Result.Canvas.Font.Size := 11;
  Result.Canvas.Font.Color := clWhite;
  Result.Canvas.TextOut(80, 120, 'Tether Directory: ' + FTetherDir);
end;

function TWiFiDslrAdapter.Capture: TCaptureResult;
var
  Bmp: TBitmap;
  Bytes: TBytes;
begin
  FState := csCapturing;
  Bmp := GetLiveFrame;
  try
    SetLength(Bytes, 2048);
    Result.RawBytes := Bytes;
    Result.Format := 'png';
    Result.Width := Bmp.Width;
    Result.Height := Bmp.Height;
    Result.CameraModel := FInfo.Model;
    Result.CameraSerial := FInfo.SerialNumber;
    Result.PreviewBmp := Bmp;
  except
    Bmp.Free;
    raise;
  end;
  FState := csReady;
end;

function TWiFiDslrAdapter.SetSetting(const Key, Value: string): Boolean; begin Result := True; end;
function TWiFiDslrAdapter.GetSetting(const Key: string): string; begin Result := ''; end;

end.
