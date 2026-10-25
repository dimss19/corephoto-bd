unit CP.Imaging.Crop;

interface

uses
  System.SysUtils, System.Types, Vcl.Graphics;

type
  TCropRegion = record
    X: Integer;
    Y: Integer;
    Width: Integer;
    Height: Integer;
    function ValidateBounds(FrameW, FrameH: Integer): TCropRegion;
    function ApplyToBitmap(SourceBmp: TBitmap; TargetW: Integer = 0; TargetH: Integer = 0): TBitmap;
  end;

implementation

function TCropRegion.ValidateBounds(FrameW, FrameH: Integer): TCropRegion;
begin
  if FrameW <= 10 then FrameW := 100;
  if FrameH <= 10 then FrameH := 100;

  Result.X := X;
  if Result.X < 0 then Result.X := 0;
  if Result.X > FrameW - 10 then Result.X := FrameW - 10;

  Result.Y := Y;
  if Result.Y < 0 then Result.Y := 0;
  if Result.Y > FrameH - 10 then Result.Y := FrameH - 10;

  Result.Width := Width;
  if Result.Width < 10 then Result.Width := 10;
  if Result.Width > FrameW - Result.X then Result.Width := FrameW - Result.X;

  Result.Height := Height;
  if Result.Height < 10 then Result.Height := 10;
  if Result.Height > FrameH - Result.Y then Result.Height := FrameH - Result.Y;
end;

function TCropRegion.ApplyToBitmap(SourceBmp: TBitmap; TargetW, TargetH: Integer): TBitmap;
var
  Safe: TCropRegion;
  SrcRect, DstRect: TRect;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;

  Safe := ValidateBounds(SourceBmp.Width, SourceBmp.Height);
  SrcRect := Rect(Safe.X, Safe.Y, Safe.X + Safe.Width, Safe.Y + Safe.Height);

  if (TargetW > 0) and (TargetH > 0) then
  begin
    Result.SetSize(TargetW, TargetH);
    DstRect := Rect(0, 0, TargetW, TargetH);
    Result.Canvas.StretchDraw(DstRect, SourceBmp);
  end
  else
  begin
    Result.SetSize(Safe.Width, Safe.Height);
    DstRect := Rect(0, 0, Safe.Width, Safe.Height);
    Result.Canvas.CopyRect(DstRect, SourceBmp.Canvas, SrcRect);
  end;
end;

end.
