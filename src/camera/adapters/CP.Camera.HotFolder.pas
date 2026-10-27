unit CP.Camera.HotFolder;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Types, System.IOUtils, System.SyncObjs, Vcl.Graphics,
  CP.Camera.Intf, CP.Camera.Capabilities;

type
  THotFolderAdapter = class(TInterfacedObject, ICameraAdapter)
  private
    FState: TCameraState;
    FInfo: TCameraInfo;
    FCaps: TCameraCapabilities;
    FWatchDir: string;
    FLock: TCriticalSection;
  public
    constructor Create(const AWatchDir: string = '');
    destructor Destroy; override;

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
    function TriggerAutoFocus: Boolean;
    function SetAutoFocus(Enable: Boolean): Boolean;
  end;

implementation

uses
  CP.Core.Logger, CP.Imaging.Raw;

constructor THotFolderAdapter.Create(const AWatchDir: string);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FState := csDisconnected;
  FCaps := TCameraCapabilities.DefaultCaps;
  FWatchDir := AWatchDir;

  FInfo.Model := 'Universal Hot-Folder Ingest';
  FInfo.Vendor := 'Camera Utility Hot-Folder';
  FInfo.SerialNumber := 'HOTFOLDER_01';
  FInfo.FirmwareVersion := '1.0';
  FInfo.AdapterName := 'HotFolderAdapter';
  FInfo.DeviceId := FWatchDir;
end;

destructor THotFolderAdapter.Destroy;
begin
  Disconnect;
  FLock.Free;
  inherited Destroy;
end;

function THotFolderAdapter.Connect(const DeviceId: string): Boolean;
begin
  FLock.Enter;
  try
    if DeviceId <> '' then
      FWatchDir := DeviceId;
    if FWatchDir <> '' then
      TDirectory.CreateDirectory(FWatchDir);
    FState := csReady;
    FInfo.DeviceId := FWatchDir;
    Log.Info('Hot-Folder adapter connected. Watch dir: ' + FWatchDir);
    Result := True;
  finally
    FLock.Leave;
  end;
end;

function THotFolderAdapter.Disconnect: Boolean;
begin
  FState := csDisconnected;
  Result := True;
end;

function THotFolderAdapter.GetState: TCameraState; begin Result := FState; end;
function THotFolderAdapter.GetInfo: TCameraInfo; begin Result := FInfo; end;
function THotFolderAdapter.GetCapabilities: TCameraCapabilities; begin Result := FCaps; end;
function THotFolderAdapter.StartLiveView(Callback: TLiveFrameCallback): Boolean; begin FState := csStreaming; Result := True; end;
function THotFolderAdapter.StopLiveView: Boolean; begin FState := csReady; Result := True; end;

function THotFolderAdapter.GetLiveFrame: TBitmap;
begin
  Result := TBitmap.Create;
  Result.SetSize(1280, 720);
  Result.Canvas.Brush.Color := RGB(24, 24, 27);
  Result.Canvas.FillRect(Rect(0, 0, 1280, 720));
  Result.Canvas.Font.Name := 'Segoe UI';
  Result.Canvas.Font.Size := 14;
  Result.Canvas.Font.Color := RGB(217, 83, 30);
  Result.Canvas.TextOut(50, 50, 'HOT-FOLDER INGEST ACTIVE');
  Result.Canvas.Font.Size := 10;
  Result.Canvas.Font.Color := clWhite;
  Result.Canvas.TextOut(50, 90, 'Watching: ' + FWatchDir);
end;

function THotFolderAdapter.Capture: TCaptureResult;
var
  Bmp: TBitmap;
  Bytes: TBytes;
begin
  FState := csCapturing;
  Bmp := GetLiveFrame;
  try
    SetLength(Bytes, 1024);
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

function THotFolderAdapter.SetSetting(const Key, Value: string): Boolean; begin Result := True; end;
function THotFolderAdapter.GetSetting(const Key: string): string; begin Result := ''; end;

function THotFolderAdapter.TriggerAutoFocus: Boolean;
begin
  Log.Info('Hot-Folder Ingestion: Simulated hardware autofocus acknowledged.');
  Result := True;
end;

function THotFolderAdapter.SetAutoFocus(Enable: Boolean): Boolean;
begin
  Result := True;
end;

end.
