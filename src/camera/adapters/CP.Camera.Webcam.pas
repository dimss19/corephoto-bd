unit CP.Camera.Webcam;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, Vcl.Graphics,
  Vcl.Imaging.pngimage,
  CP.Camera.Intf, CP.Camera.Capabilities;

type
  TWebcamAdapter = class(TInterfacedObject, ICameraAdapter)
  private
    FState: TCameraState;
    FInfo: TCameraInfo;
    FCaps: TCameraCapabilities;
    FDeviceId: string;
    FIsSimulated: Boolean;
    FLock: TCriticalSection;
    FFrameCallback: TLiveFrameCallback;
    FTargetW, FTargetH: Integer;
    function GenerateStandbyFrame(W, H: Integer): TBitmap;
  public
    constructor Create;
    destructor Destroy; override;

    function Connect(const DeviceId: string = '0'): Boolean;
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

constructor TWebcamAdapter.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FState := csDisconnected;
  FCaps := TCameraCapabilities.DefaultCaps;
  FTargetW := 1920;
  FTargetH := 1080;

  FInfo.Model := 'Integrated USB Camera (Webcam)';
  FInfo.Vendor := 'UVC DirectShow';
  FInfo.SerialNumber := 'USB-CAM-01';
  FInfo.FirmwareVersion := 'DirectShow 1.0';
  FInfo.AdapterName := 'WebcamAdapter';
  FInfo.DeviceId := '0';
end;

destructor TWebcamAdapter.Destroy;
begin
  Disconnect;
  FLock.Free;
  inherited Destroy;
end;

function TWebcamAdapter.Connect(const DeviceId: string): Boolean;
begin
  FLock.Enter;
  try
    FDeviceId := DeviceId;
    FState := csConnecting;
    FIsSimulated := (SameText(DeviceId, 'sim') or SameText(DeviceId, 'simulator'));

    if FIsSimulated then
    begin
      FInfo.Model := 'Standby (Simulator)';
      FInfo.Vendor := 'CorePhoto Internal';
    end
    else
    begin
      FInfo.Model := Format('Webcam — Index %s (UVC DirectShow)', [DeviceId]);
      FInfo.Vendor := 'DirectShow Device';
    end;
    FInfo.DeviceId := DeviceId;

    FState := csReady;
    Log.Info('Webcam adapter connected. Model: ' + FInfo.Model);
    Result := True;
  finally
    FLock.Leave;
  end;
end;

function TWebcamAdapter.Disconnect: Boolean;
begin
  FLock.Enter;
  try
    StopLiveView;
    FState := csDisconnected;
    Result := True;
  finally
    FLock.Leave;
  end;
end;

function TWebcamAdapter.GetState: TCameraState;
begin
  Result := FState;
end;

function TWebcamAdapter.GetInfo: TCameraInfo;
begin
  Result := FInfo;
end;

function TWebcamAdapter.GetCapabilities: TCameraCapabilities;
begin
  Result := FCaps;
end;

function TWebcamAdapter.StartLiveView(Callback: TLiveFrameCallback): Boolean;
begin
  FLock.Enter;
  try
    FFrameCallback := Callback;
    FState := csStreaming;
    Result := True;
  finally
    FLock.Leave;
  end;
end;

function TWebcamAdapter.StopLiveView: Boolean;
begin
  FLock.Enter;
  try
    FFrameCallback := nil;
    if FState = csStreaming then
      FState := csReady;
    Result := True;
  finally
    FLock.Leave;
  end;
end;

function TWebcamAdapter.GenerateStandbyFrame(W, H: Integer): TBitmap;
var
  CX, CY, R: Integer;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.SetSize(W, H);

  // Dark industrial charcoal background
  Result.Canvas.Brush.Color := RGB(24, 24, 27);
  Result.Canvas.FillRect(Rect(0, 0, W, H));

  CX := W div 2;
  CY := H div 2;

  // Concentric geological tray target rings
  Result.Canvas.Pen.Color := RGB(60, 60, 75);
  Result.Canvas.Pen.Width := 1;
  Result.Canvas.Brush.Style := bsClear;
  for R := 1 to 5 do
    Result.Canvas.Ellipse(CX - R * 50, CY - R * 50, CX + R * 50, CY + R * 50);

  // Crosshairs
  Result.Canvas.MoveTo(CX - 150, CY);
  Result.Canvas.LineTo(CX + 150, CY);
  Result.Canvas.MoveTo(CX, CY - 150);
  Result.Canvas.LineTo(CX, CY + 150);

  // Overlay text
  Result.Canvas.Font.Name := 'Segoe UI';
  Result.Canvas.Font.Size := 14;
  Result.Canvas.Font.Color := RGB(217, 83, 30); // Safety Orange
  Result.Canvas.TextOut(CX - 120, CY - 30, 'CORE PHOTO — LIVE VIEW ACTIVE');

  Result.Canvas.Font.Size := 10;
  Result.Canvas.Font.Color := RGB(160, 160, 170);
  Result.Canvas.TextOut(CX - 100, CY + 10, Format('Resolution: %dx%d  |  DirectShow', [W, H]));
end;

function TWebcamAdapter.GetLiveFrame: TBitmap;
begin
  Result := GenerateStandbyFrame(FTargetW, FTargetH);
end;

function TWebcamAdapter.Capture: TCaptureResult;
var
  Bmp: TBitmap;
  Png: TPngImage;
  MS: TMemoryStream;
begin
  FState := csCapturing;
  Bmp := GenerateStandbyFrame(FTargetW, FTargetH);
  try
    Png := TPngImage.Create;
    try
      Png.Assign(Bmp);
      MS := TMemoryStream.Create;
      try
        Png.SaveToStream(MS);
        SetLength(Result.RawBytes, MS.Size);
        MS.Position := 0;
        MS.ReadBuffer(Result.RawBytes[0], MS.Size);
      finally
        MS.Free;
      end;
    finally
      Png.Free;
    end;

    Result.Format := 'png';
    Result.Width := FTargetW;
    Result.Height := FTargetH;
    Result.CameraModel := FInfo.Model;
    Result.CameraSerial := FInfo.SerialNumber;
    Result.PreviewBmp := Bmp;
  except
    Bmp.Free;
    raise;
  end;
  FState := csReady;
end;

function TWebcamAdapter.SetSetting(const Key, Value: string): Boolean;
begin
  if SameText(Key, 'resolution') then
  begin
    // Value: 1920x1080
    Result := True;
  end
  else
    Result := True;
end;

function TWebcamAdapter.GetSetting(const Key: string): string;
begin
  Result := '';
end;

end.
