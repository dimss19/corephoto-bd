unit CP.Camera.Webcam;

interface

uses
  Winapi.Windows, Winapi.ActiveX, Winapi.DirectShow9, System.SysUtils, System.Classes,
  System.Types, System.Variants, System.SyncObjs, Vcl.Graphics,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg,
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
    FConnectedWidth, FConnectedHeight: Integer;
    FComInitialized: Boolean;

    // DirectShow COM interfaces
    FGraphBuilder: IGraphBuilder;
    FCaptureGraphBuilder: ICaptureGraphBuilder2;
    FVideoSource: IBaseFilter;
    FGrabberFilter: IBaseFilter;
    FSampleGrabber: ISampleGrabber;
    FNullRenderer: IBaseFilter;
    FMediaControl: IMediaControl;

    function InitDirectShow(DeviceIndex: Integer): Boolean;
    procedure TeardownDirectShow;
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

    class function ListDevices: TArray<string>;
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
  FConnectedWidth := 640;
  FConnectedHeight := 480;
  FComInitialized := False;

  FInfo.Model := 'Integrated USB Camera (Webcam)';
  FInfo.Vendor := 'UVC DirectShow';
  FInfo.SerialNumber := 'USB-CAM-01';
  FInfo.FirmwareVersion := 'DirectShow 9.0';
  FInfo.AdapterName := 'WebcamAdapter';
  FInfo.DeviceId := '0';
end;

destructor TWebcamAdapter.Destroy;
begin
  Disconnect;
  FLock.Free;
  inherited Destroy;
end;

class function TWebcamAdapter.ListDevices: TArray<string>;
var
  DevEnum: ICreateDevEnum;
  EnumMoniker: IEnumMoniker;
  Moniker: IMoniker;
  PropBag: IPropertyBag;
  PropVar: OleVariant;
  Fetched: ULONG;
  HR: HRESULT;
  DevList: TStringList;
  I: Integer;
begin
  DevList := TStringList.Create;
  try
    HR := CoCreateInstance(CLSID_SystemDeviceEnum, nil, CLSCTX_INPROC_SERVER, IID_ICreateDevEnum, DevEnum);
    if Succeeded(HR) and (DevEnum <> nil) then
    begin
      HR := DevEnum.CreateClassEnumerator(CLSID_VideoInputDeviceCategory, EnumMoniker, 0);
      if Succeeded(HR) and (EnumMoniker <> nil) then
      begin
        while EnumMoniker.Next(1, Moniker, @Fetched) = S_OK do
        begin
          if Succeeded(Moniker.BindToStorage(nil, nil, IPropertyBag, PropBag)) then
          begin
            PropVar := Unassigned;
            if Succeeded(PropBag.Read('FriendlyName', PropVar, nil)) then
              DevList.Add(VarToStr(PropVar))
            else
              DevList.Add('DirectShow Video Capture Device');
          end;
        end;
      end;
    end;

    SetLength(Result, DevList.Count);
    for I := 0 to DevList.Count - 1 do
      Result[I] := DevList[I];
  finally
    DevList.Free;
  end;
end;

function TWebcamAdapter.InitDirectShow(DeviceIndex: Integer): Boolean;
var
  DevEnum: ICreateDevEnum;
  EnumMoniker: IEnumMoniker;
  Moniker: IMoniker;
  PropBag: IPropertyBag;
  PropVar: OleVariant;
  Fetched: ULONG;
  CurIndex: Integer;
  Found: Boolean;
  HR: HRESULT;
  MT: TAMMediaType;
begin
  Result := False;
  TeardownDirectShow;

  if not FComInitialized then
  begin
    CoInitialize(nil);
    FComInitialized := True;
  end;

  // 1. Enumerate video devices to locate the requested device index
  Found := False;
  HR := CoCreateInstance(CLSID_SystemDeviceEnum, nil, CLSCTX_INPROC_SERVER, IID_ICreateDevEnum, DevEnum);
  if Succeeded(HR) and (DevEnum <> nil) then
  begin
    HR := DevEnum.CreateClassEnumerator(CLSID_VideoInputDeviceCategory, EnumMoniker, 0);
    if Succeeded(HR) and (EnumMoniker <> nil) then
    begin
      CurIndex := 0;
      while EnumMoniker.Next(1, Moniker, @Fetched) = S_OK do
      begin
        if CurIndex = DeviceIndex then
        begin
          if Succeeded(Moniker.BindToStorage(nil, nil, IPropertyBag, PropBag)) then
          begin
            PropVar := Unassigned;
            if Succeeded(PropBag.Read('FriendlyName', PropVar, nil)) then
            begin
              FInfo.Model := VarToStr(PropVar);
              FInfo.Vendor := 'UVC DirectShow';
            end;
          end;
          if Succeeded(Moniker.BindToObject(nil, nil, IID_IBaseFilter, FVideoSource)) then
            Found := True;
          Break;
        end;
        Inc(CurIndex);
      end;
    end;
  end;

  if not Found or (FVideoSource = nil) then
  begin
    Log.Warn(Format('DirectShow device index %d not found on system.', [DeviceIndex]));
    Exit;
  end;

  // 2. Build filter graph
  HR := CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER, IID_IGraphBuilder, FGraphBuilder);
  if Failed(HR) or (FGraphBuilder = nil) then Exit;

  HR := CoCreateInstance(CLSID_CaptureGraphBuilder2, nil, CLSCTX_INPROC_SERVER, IID_ICaptureGraphBuilder2, FCaptureGraphBuilder);
  if Failed(HR) or (FCaptureGraphBuilder = nil) then Exit;

  FCaptureGraphBuilder.SetFiltergraph(FGraphBuilder);
  FGraphBuilder.AddFilter(FVideoSource, 'Video Capture');

  // 3. Create SampleGrabber filter configured for RGB24
  HR := CoCreateInstance(CLSID_SampleGrabber, nil, CLSCTX_INPROC_SERVER, IID_IBaseFilter, FGrabberFilter);
  if Succeeded(HR) and (FGrabberFilter <> nil) then
  begin
    FGrabberFilter.QueryInterface(IID_ISampleGrabber, FSampleGrabber);
    if FSampleGrabber <> nil then
    begin
      FillChar(MT, SizeOf(TAMMediaType), 0);
      MT.majortype := MEDIATYPE_Video;
      MT.subtype := MEDIASUBTYPE_RGB24;
      MT.formattype := FORMAT_VideoInfo;
      FSampleGrabber.SetMediaType(MT);
      FSampleGrabber.SetBufferSamples(True);
      FSampleGrabber.SetOneShot(False);
      FGraphBuilder.AddFilter(FGrabberFilter, 'SampleGrabber');
    end;
  end;

  // 4. Create NullRenderer filter
  HR := CoCreateInstance(CLSID_NullRenderer, nil, CLSCTX_INPROC_SERVER, IID_IBaseFilter, FNullRenderer);
  if Succeeded(HR) and (FNullRenderer <> nil) then
    FGraphBuilder.AddFilter(FNullRenderer, 'NullRenderer');

  // 5. Connect capture stream: VideoSource -> SampleGrabber -> NullRenderer
  HR := FCaptureGraphBuilder.RenderStream(@PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, FVideoSource, FGrabberFilter, FNullRenderer);
  if Failed(HR) then
    HR := FCaptureGraphBuilder.RenderStream(@PIN_CATEGORY_PREVIEW, @MEDIATYPE_Video, FVideoSource, FGrabberFilter, FNullRenderer);

  if Succeeded(HR) then
  begin
    FGraphBuilder.QueryInterface(IID_IMediaControl, FMediaControl);
    if FMediaControl <> nil then
      FMediaControl.Run;

    Result := True;
    Log.Info('DirectShow webcam initialized and running successfully: ' + FInfo.Model);
  end
  else
  begin
    Log.Warn(Format('DirectShow RenderStream failed (HRESULT: 0x%x)', [HR]));
    TeardownDirectShow;
  end;
end;

procedure TWebcamAdapter.TeardownDirectShow;
begin
  if FMediaControl <> nil then
  begin
    try FMediaControl.Stop; except end;
    FMediaControl := nil;
  end;

  FSampleGrabber := nil;
  FGrabberFilter := nil;
  FNullRenderer := nil;
  FVideoSource := nil;
  FCaptureGraphBuilder := nil;
  FGraphBuilder := nil;

  if FComInitialized then
  begin
    try CoUninitialize; except end;
    FComInitialized := False;
  end;
end;

function TWebcamAdapter.Connect(const DeviceId: string): Boolean;
var
  Idx: Integer;
begin
  FLock.Enter;
  try
    FDeviceId := DeviceId;
    FState := csConnecting;
    FIsSimulated := (SameText(DeviceId, 'sim') or SameText(DeviceId, 'simulator'));

    if not FIsSimulated then
    begin
      Idx := StrToIntDef(DeviceId, 0);
      if InitDirectShow(Idx) then
      begin
        FIsSimulated := False;
        FInfo.DeviceId := DeviceId;
        FState := csReady;
        Result := True;
        Exit;
      end
      else
      begin
        Log.Warn('DirectShow hardware initialization failed. Falling back to internal standby simulator.');
        FIsSimulated := True;
      end;
    end;

    FInfo.Model := 'Standby (Simulator)';
    FInfo.Vendor := 'CorePhoto Internal';
    FInfo.DeviceId := DeviceId;
    FState := csReady;
    Log.Info('Webcam adapter connected in simulator mode.');
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
    TeardownDirectShow;
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

  Result.Canvas.Brush.Color := RGB(24, 24, 27);
  Result.Canvas.FillRect(Rect(0, 0, W, H));

  CX := W div 2;
  CY := H div 2;

  Result.Canvas.Pen.Color := RGB(60, 60, 75);
  Result.Canvas.Pen.Width := 1;
  Result.Canvas.Brush.Style := bsClear;
  for R := 1 to 5 do
    Result.Canvas.Ellipse(CX - R * 50, CY - R * 50, CX + R * 50, CY + R * 50);

  Result.Canvas.MoveTo(CX - 150, CY);
  Result.Canvas.LineTo(CX + 150, CY);
  Result.Canvas.MoveTo(CX, CY - 150);
  Result.Canvas.LineTo(CX, CY + 150);

  Result.Canvas.Font.Name := 'Segoe UI';
  Result.Canvas.Font.Size := 14;
  Result.Canvas.Font.Color := RGB(217, 83, 30);
  Result.Canvas.TextOut(CX - 120, CY - 30, 'CORE PHOTO — STANDBY / SIMULATOR');

  Result.Canvas.Font.Size := 10;
  Result.Canvas.Font.Color := RGB(160, 160, 170);
  Result.Canvas.TextOut(CX - 110, CY + 10, Format('Resolution: %dx%d  |  DirectShow', [W, H]));
end;

function TWebcamAdapter.GetLiveFrame: TBitmap;
var
  BufSize: Longint;
  HR: HRESULT;
  ConnMT: TAMMediaType;
  pVIH: PVideoInfoHeader;
  FW, FH: Integer;
  Buf: PByte;
  RowBytes, Y: Integer;
  SrcLine, DestLine: PByte;
begin
  if FIsSimulated or (FSampleGrabber = nil) then
  begin
    Result := GenerateStandbyFrame(FTargetW, FTargetH);
    Exit;
  end;

  BufSize := 0;
  HR := FSampleGrabber.GetCurrentBuffer(BufSize, nil);
  if (HR <> S_OK) or (BufSize <= 0) then
  begin
    Result := nil;
    Exit;
  end;

  FW := FConnectedWidth;
  FH := FConnectedHeight;

  FillChar(ConnMT, SizeOf(TAMMediaType), 0);
  if Succeeded(FSampleGrabber.GetConnectedMediaType(ConnMT)) then
  begin
    if (ConnMT.formattype = FORMAT_VideoInfo) and (ConnMT.pbFormat <> nil) then
    begin
      pVIH := PVideoInfoHeader(ConnMT.pbFormat);
      if pVIH^.bmiHeader.biWidth > 0 then FW := pVIH^.bmiHeader.biWidth;
      if pVIH^.bmiHeader.biHeight <> 0 then FH := Abs(pVIH^.bmiHeader.biHeight);
      FConnectedWidth := FW;
      FConnectedHeight := FH;
    end;
    if ConnMT.pbFormat <> nil then
      CoTaskMemFree(ConnMT.pbFormat);
  end;

  GetMem(Buf, BufSize);
  try
    HR := FSampleGrabber.GetCurrentBuffer(BufSize, Buf);
    if HR = S_OK then
    begin
      Result := TBitmap.Create;
      Result.PixelFormat := pf24bit;
      Result.SetSize(FW, FH);
      RowBytes := ((FW * 24 + 31) and not 31) div 8;

      // DirectShow RGB24 is standard bottom-up DIB:
      for Y := 0 to FH - 1 do
      begin
        SrcLine := Buf + (FH - 1 - Y) * RowBytes;
        DestLine := Result.ScanLine[Y];
        CopyMemory(DestLine, SrcLine, FW * 3);
      end;
    end
    else
      Result := nil;
  finally
    FreeMem(Buf);
  end;
end;

function TWebcamAdapter.Capture: TCaptureResult;
var
  Bmp: TBitmap;
  Png: TPngImage;
  MS: TMemoryStream;
begin
  FState := csCapturing;
  Bmp := GetLiveFrame;
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

function TWebcamAdapter.SetSetting(const Key, Value: string): Boolean;
begin
  Result := True;
end;

function TWebcamAdapter.GetSetting(const Key: string): string;
begin
  Result := '';
end;

end.
