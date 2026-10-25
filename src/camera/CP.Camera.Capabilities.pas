unit CP.Camera.Capabilities;

interface

uses
  System.Types;

type
  TCameraCapabilities = record
    CanCapture: Boolean;
    CanLiveView: Boolean;
    SupportsISO: Boolean;
    SupportsExposure: Boolean;
    SupportsAperture: Boolean;
    SupportsFocus: Boolean;
    SupportsZoom: Boolean;
    SupportedResolutions: TArray<TPoint>;
    class function DefaultCaps: TCameraCapabilities; static;
  end;

implementation

class function TCameraCapabilities.DefaultCaps: TCameraCapabilities;
begin
  Result.CanCapture := True;
  Result.CanLiveView := True;
  Result.SupportsISO := True;
  Result.SupportsExposure := True;
  Result.SupportsAperture := True;
  Result.SupportsFocus := True;
  Result.SupportsZoom := True;
  SetLength(Result.SupportedResolutions, 6);
  Result.SupportedResolutions[0] := Point(6000, 4000);
  Result.SupportedResolutions[1] := Point(5184, 3456);
  Result.SupportedResolutions[2] := Point(4000, 3000);
  Result.SupportedResolutions[3] := Point(3840, 2160);
  Result.SupportedResolutions[4] := Point(1920, 1080);
  Result.SupportedResolutions[5] := Point(1280, 720);
end;

end.
