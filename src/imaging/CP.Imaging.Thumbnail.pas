unit CP.Imaging.Thumbnail;

interface

uses
  System.SysUtils, System.Classes, System.Types, Vcl.Graphics, Vcl.Imaging.jpeg;

type
  TThumbnailGenerator = class
  public
    class procedure Generate(SourceBmp: TBitmap; const DestPath: string; ThumbW: Integer = 150; ThumbH: Integer = 100);
  end;

implementation

class procedure TThumbnailGenerator.Generate(SourceBmp: TBitmap; const DestPath: string; ThumbW, ThumbH: Integer);
var
  ThumbBmp: TBitmap;
  Jpg: TJPEGImage;
  SrcW, SrcH, NewW, NewH, OffsetX, OffsetY: Integer;
  Scale: Double;
  DstRect: TRect;
begin
  ThumbBmp := TBitmap.Create;
  try
    ThumbBmp.PixelFormat := pf24bit;
    ThumbBmp.SetSize(ThumbW, ThumbH);
    ThumbBmp.Canvas.Brush.Color := clBlack;
    ThumbBmp.Canvas.FillRect(Rect(0, 0, ThumbW, ThumbH));

    SrcW := SourceBmp.Width;
    SrcH := SourceBmp.Height;
    if (SrcW > 0) and (SrcH > 0) then
    begin
      Scale := ThumbW / SrcW;
      if (ThumbH / SrcH) < Scale then
        Scale := ThumbH / SrcH;

      NewW := Round(SrcW * Scale);
      NewH := Round(SrcH * Scale);
      if NewW < 1 then NewW := 1;
      if NewH < 1 then NewH := 1;

      OffsetX := (ThumbW - NewW) div 2;
      OffsetY := (ThumbH - NewH) div 2;

      DstRect := Rect(OffsetX, OffsetY, OffsetX + NewW, OffsetY + NewH);
      ThumbBmp.Canvas.StretchDraw(DstRect, SourceBmp);
    end;

    Jpg := TJPEGImage.Create;
    try
      Jpg.CompressionQuality := 80;
      Jpg.Assign(ThumbBmp);
      Jpg.SaveToFile(DestPath);
    finally
      Jpg.Free;
    end;
  finally
    ThumbBmp.Free;
  end;
end;

end.
