unit CP.Camera.Intf;

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics,
  CP.Camera.Capabilities;

type
  TCameraState = (
    csDisconnected,
    csConnecting,
    csReady,
    csStreaming,
    csCapturing,
    csError
  );

  TCameraInfo = record
    Model: string;
    SerialNumber: string;
    Vendor: string;
    FirmwareVersion: string;
    AdapterName: string;
    DeviceId: string;
  end;

  TCaptureResult = record
    RawBytes: TBytes;
    Format: string; // 'png', 'jpg', 'raw'
    Width: Integer;
    Height: Integer;
    CameraModel: string;
    CameraSerial: string;
    PreviewBmp: TBitmap;
  end;

  TLiveFrameCallback = reference to procedure(FrameBmp: TBitmap);

  ICameraAdapter = interface
    ['{69A454F6-616E-44E8-A97F-A8FE2A540541}']
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

end.
