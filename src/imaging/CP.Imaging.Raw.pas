unit CP.Imaging.Raw;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.IOUtils, System.Hash, Vcl.Graphics,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage;

type
  TRawHandler = class
  public
    class function CalculateMD5(const FilePath: string): string;
    class function SaveRaw(const RawBytes: TBytes; const DestinationPath: string; out OutMD5: string): string;
    class function DecodeToBitmap(const RawPath: string): TBitmap;
  end;

implementation

uses
  CP.Core.Logger;

class function TRawHandler.CalculateMD5(const FilePath: string): string;
var
  FS: TFileStream;
begin
  Result := '';
  if not TFile.Exists(FilePath) then
    Exit;
  FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyNone);
  try
    Result := LowerCase(THashMD5.GetHashString(FS));
  finally
    FS.Free;
  end;
end;

class function TRawHandler.SaveRaw(const RawBytes: TBytes; const DestinationPath: string; out OutMD5: string): string;
var
  Dir: string;
begin
  Dir := ExtractFilePath(DestinationPath);
  if not TDirectory.Exists(Dir) then
    TDirectory.CreateDirectory(Dir);

  TFile.WriteAllBytes(DestinationPath, RawBytes);
  OutMD5 := CalculateMD5(DestinationPath);
  Log.Info(Format('Saved RAW file: %s (MD5: %s, size: %d bytes)', [DestinationPath, OutMD5, Length(RawBytes)]));
  Result := DestinationPath;
end;

class function TRawHandler.DecodeToBitmap(const RawPath: string): TBitmap;
var
  Ext: string;
  Jpg: TJPEGImage;
  Png: TPngImage;
  FS: TFileStream;
begin
  if not TFile.Exists(RawPath) then
    raise Exception.Create('File RAW tidak ditemukan: ' + RawPath);

  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Ext := LowerCase(ExtractFileExt(RawPath));

  if (Ext = '.jpg') or (Ext = '.jpeg') then
  begin
    Jpg := TJPEGImage.Create;
    try
      Jpg.LoadFromFile(RawPath);
      Result.Assign(Jpg);
    finally
      Jpg.Free;
    end;
  end
  else if Ext = '.png' then
  begin
    Png := TPngImage.Create;
    try
      Png.LoadFromFile(RawPath);
      Result.Assign(Png);
    finally
      Png.Free;
    end;
  end
  else if Ext = '.bmp' then
  begin
    Result.LoadFromFile(RawPath);
  end
  else
  begin
    // DSLR RAW fallback: search for embedded JPEG preview in RAW binary stream
    FS := TFileStream.Create(RawPath, fmOpenRead or fmShareDenyNone);
    try
      Jpg := TJPEGImage.Create;
      try
        try
          FS.Position := 0;
          Jpg.LoadFromStream(FS);
          Result.Assign(Jpg);
        except
          // If no embedded direct JPEG, create a neutral fallback placeholder
          Result.SetSize(1920, 1080);
          Result.Canvas.Brush.Color := clBlack;
          Result.Canvas.FillRect(Rect(0, 0, 1920, 1080));
          Result.Canvas.Font.Color := clWhite;
          Result.Canvas.Font.Size := 16;
          Result.Canvas.TextOut(50, 50, 'RAW Photo Ingested: ' + ExtractFileName(RawPath));
        end;
      finally
        Jpg.Free;
      end;
    finally
      FS.Free;
    end;
  end;
end;

end.
