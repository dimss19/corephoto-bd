unit CP.Imaging.Processor;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, System.JSON, Vcl.Graphics,
  Vcl.Imaging.jpeg,
  CP.DB.Models, CP.DB.Repositories, CP.Storage.Manager, CP.Imaging.Crop,
  CP.Imaging.Raw, CP.Imaging.Thumbnail;

type
  TCPImageProcessor = class
  private
    FPhotoRepo: TPhotoRepository;
    function AddMetadataSlateBanner(
      Img: TBitmap;
      const HoleId, TrayId: string;
      FromVal, ToVal: Double;
      const OperatorName, TimestampStr: string
    ): TBitmap;
    procedure AppendHoleCSV(
      const SessionPaths: TSessionPaths;
      const Session: TSessionModel;
      const Tray: TTrayModel;
      const JpgPath, Md5Jpg, TimestampStr: string;
      const CropRegion: TCropRegion;
      OrigW, OrigH: Integer
    );
  public
    constructor Create(APhotoRepo: TPhotoRepository = nil);
    function ProcessCapture(
      const RawBytes: TBytes;
      const Paths: TSessionPaths;
      const Session: TSessionModel;
      const Tray: TTrayModel;
      const CropRegion: TCropRegion;
      const CameraModel: string = 'Unknown Camera';
      const CameraSerial: string = 'N/A';
      const RawFormat: string = 'png'
    ): TPhotoModel;
  end;

implementation

uses
  CP.Config.Manager, CP.Core.Logger, CP.Core.PyFormat;

constructor TCPImageProcessor.Create(APhotoRepo: TPhotoRepository);
begin
  inherited Create;
  FPhotoRepo := APhotoRepo;
end;

function TCPImageProcessor.AddMetadataSlateBanner(
  Img: TBitmap;
  const HoleId, TrayId: string;
  FromVal, ToVal: Double;
  const OperatorName, TimestampStr: string
): TBitmap;
var
  W, H, BannerH, FontSize, YPos, XRight, TextW: Integer;
  LeftText, RightText, OpText: string;
begin
  W := Img.Width;
  H := Img.Height;
  BannerH := Round(H * 0.08);
  if BannerH < 18 then BannerH := 18;

  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.SetSize(W, H);
  Result.Canvas.Draw(0, 0, Img);

  // White banner background
  Result.Canvas.Brush.Color := clWhite;
  Result.Canvas.Pen.Color := RGB(210, 215, 220);
  Result.Canvas.Pen.Width := 1;
  Result.Canvas.Rectangle(0, H - BannerH, W, H);
  Result.Canvas.MoveTo(0, H - BannerH);
  Result.Canvas.LineTo(W, H - BannerH);

  FontSize := Round(BannerH * 0.45);
  if FontSize < 8 then FontSize := 8;

  Result.Canvas.Font.Name := 'Segoe UI';
  Result.Canvas.Font.Size := FontSize;
  Result.Canvas.Font.Color := RGB(15, 20, 25);
  Result.Canvas.Brush.Style := bsClear;

  LeftText := Format('HOLE ID: %s  TRAY ID: %s  FROM: %s  TO: %s',
    [HoleId, TrayId, PyFmtG(FromVal), PyFmtG(ToVal)]);

  OpText := '';
  if Trim(OperatorName) <> '' then
    OpText := Format('OPERATOR: %s  ', [Trim(OperatorName)]);
  RightText := OpText + 'TIMESTAMP: ' + TimestampStr;

  YPos := H - BannerH + (BannerH - FontSize) div 2;
  Result.Canvas.TextOut(8, YPos, LeftText);

  TextW := Result.Canvas.TextWidth(RightText);
  XRight := W - TextW - 8;
  if XRight < 8 then XRight := 8;
  Result.Canvas.TextOut(XRight, YPos, RightText);
end;

procedure TCPImageProcessor.AppendHoleCSV(
  const SessionPaths: TSessionPaths;
  const Session: TSessionModel;
  const Tray: TTrayModel;
  const JpgPath, Md5Jpg, TimestampStr: string;
  const CropRegion: TCropRegion;
  OrigW, OrigH: Integer
);
var
  CleanHole, CsvFile, HeaderLine, DataLine, CropStr: string;
  WriteHdr: Boolean;
  Nx1, Ny1, Nx2, Ny2: Double;
  FS: TFormatSettings;
begin
  FS := GetInvariantFormatSettings;
  CleanHole := StringReplace(Trim(Tray.HoleId), ' ', '_', [rfReplaceAll]);
  CsvFile := TPath.Combine(SessionPaths.SessionDir, CleanHole + '.csv');
  WriteHdr := not TFile.Exists(CsvFile);

  if (OrigW > 0) and (OrigH > 0) and (CropRegion.Width > 0) then
  begin
    Nx1 := CropRegion.X / OrigW;
    Ny1 := CropRegion.Y / OrigH;
    Nx2 := (CropRegion.X + CropRegion.Width) / OrigW;
    Ny2 := (CropRegion.Y + CropRegion.Height) / OrigH;
    CropStr := Format('%.4f %.4f %.4f %.4f', [Nx1, Ny1, Nx2, Ny2], FS);
  end
  else
    CropStr := '0.0025 0.3006 0.9645 0.6335';

  HeaderLine := 'HoleID,CoreIntervalFrom,CoreIntervalTo,TrayID,Path,Comments,Date,Name,Site,MD5,Timestamp,TrayRows,TrayLength,TrayWidth,TrayCrop' + sLineBreak;
  DataLine := Format('%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%d,%s,%s,%s' + sLineBreak,
    [Tray.HoleId,
     PyFmtG(Tray.IntervalFrom),
     PyFmtG(Tray.IntervalTo),
     Tray.TrayId,
     JpgPath,
     StringReplace(Tray.Comments, ',', ' ', [rfReplaceAll]),
     Session.DateStr,
     Session.OperatorName,
     Session.Site,
     Md5Jpg,
     FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
     Tray.TrayRows,
     PyFmtG(Tray.TrayLength),
     PyFmtG(Tray.TrayWidth),
     CropStr]);

  if WriteHdr then
    TFile.WriteAllText(CsvFile, HeaderLine + DataLine, TEncoding.UTF8)
  else
    TFile.AppendAllText(CsvFile, DataLine, TEncoding.UTF8);
end;

function TCPImageProcessor.ProcessCapture(
  const RawBytes: TBytes;
  const Paths: TSessionPaths;
  const Session: TSessionModel;
  const Tray: TTrayModel;
  const CropRegion: TCropRegion;
  const CameraModel: string;
  const CameraSerial: string;
  const RawFormat: string
): TPhotoModel;
var
  FilenameBase, RawExt, RawFile, JpgFile, ThumbFile, MetaFile: string;
  Md5Raw, Md5Jpg, TimestampStr, DisplayTime: string;
  DecodedBmp, CroppedBmp, SlatedBmp: TBitmap;
  Jpg: TJPEGImage;
  InitialQuality, CurrentQuality, CropW, CropH: Integer;
  MaxSizeMB, MaxBytes, FileSize: Int64;
  SafeCrop: TCropRegion;
  MetaObj: TJSONObject;
begin
  TimestampStr := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Now);
  DisplayTime := FormatDateTime('mm/dd/yyyy hh:nn:ss AM/PM', Now);
  FilenameBase := FormatCoreFilename(Tray.HoleId, Tray.TrayId, Tray.IntervalFrom, Tray.IntervalTo);

  // 1. Save RAW bytes immediately
  RawExt := RawFormat;
  if RawExt = '' then RawExt := 'png';
  RawFile := TPath.Combine(Paths.RawDir, FilenameBase + '.' + RawExt);
  TRawHandler.SaveRaw(RawBytes, RawFile, Md5Raw);

  CropW := GetConfig.GetInteger('imaging', 'crop_width', 300);
  CropH := GetConfig.GetInteger('imaging', 'crop_height', 200);

  // 2. Initial DB model record (CAPTURED)
  Result.SessionId := Session.Id;
  Result.TrayId := Tray.Id;
  Result.HoleId := Tray.HoleId;
  Result.TrayNumber := Tray.TrayId;
  Result.IntervalFrom := Tray.IntervalFrom;
  Result.IntervalTo := Tray.IntervalTo;
  Result.FilenameBase := FilenameBase;
  Result.RawPath := RawFile;
  Result.JpgPath := '';
  Result.ThumbnailPath := '';
  Result.Md5Raw := Md5Raw;
  Result.Md5Jpg := '';
  Result.CropX := CropRegion.X;
  Result.CropY := CropRegion.Y;
  Result.CropW := CropRegion.Width;
  Result.CropH := CropRegion.Height;
  Result.CameraModel := CameraModel;
  Result.CameraSerial := CameraSerial;
  Result.Status := PhotoStatusToString(psCaptured);
  Result.IsActive := 1;
  Result.CapturedAt := TimestampStr;

  if FPhotoRepo <> nil then
  begin
    Result := FPhotoRepo.CreatePhoto(Result);
    FPhotoRepo.UpdateStatus(Result.Id, psProcessing);
  end;

  try
    // 3. Decode RAW to 24-bit bitmap
    DecodedBmp := TRawHandler.DecodeToBitmap(RawFile);
    try
      // 4. Apply Tray Crop
      SafeCrop := CropRegion;
      if (SafeCrop.Width <= 10) or (SafeCrop.Height <= 10) then
      begin
        SafeCrop.Width := Round(DecodedBmp.Width * 0.88);
        SafeCrop.Height := Round(SafeCrop.Width / 1.5);
        SafeCrop.X := (DecodedBmp.Width - SafeCrop.Width) div 2;
        SafeCrop.Y := (DecodedBmp.Height - SafeCrop.Height) div 2;
      end;
      CroppedBmp := SafeCrop.ApplyToBitmap(DecodedBmp);
      try
        // 5. Add Geological metadata slate banner
        SlatedBmp := AddMetadataSlateBanner(
          CroppedBmp,
          Tray.HoleId,
          Tray.TrayId,
          Tray.IntervalFrom,
          Tray.IntervalTo,
          Session.OperatorName,
          DisplayTime
        );
        try
          // 6. Encode JPEG with max photo size enforcement
          JpgFile := TPath.Combine(Paths.JpgDir, FilenameBase + '.jpg');
          InitialQuality := GetConfig.GetInteger('imaging', 'jpg_quality', 95);
          MaxSizeMB := Round(GetConfig.GetFloat('imaging', 'max_photo_size_mb', 10.0));
          MaxBytes := MaxSizeMB * 1024 * 1024;

          CurrentQuality := InitialQuality;
          Jpg := TJPEGImage.Create;
          try
            Jpg.CompressionQuality := CurrentQuality;
            Jpg.Assign(SlatedBmp);
            Jpg.SaveToFile(JpgFile);

            // Progressive reduction if size exceeds
            FileSize := TFile.GetSize(JpgFile);
            while (FileSize > MaxBytes) and (CurrentQuality > 35) do
            begin
              Dec(CurrentQuality, 5);
              Jpg.CompressionQuality := CurrentQuality;
              Jpg.SaveToFile(JpgFile);
              FileSize := TFile.GetSize(JpgFile);
            end;
          finally
            Jpg.Free;
          end;

          Md5Jpg := TRawHandler.CalculateMD5(JpgFile);
          Result.JpgPath := JpgFile;
          Result.Md5Jpg := Md5Jpg;

          // 7. Generate Thumbnail
          ThumbFile := TPath.Combine(Paths.ThumbnailDir, FilenameBase + '_thumb.jpg');
          TThumbnailGenerator.Generate(SlatedBmp, ThumbFile, 150, 100);
          Result.ThumbnailPath := ThumbFile;

          // 8. Write Sidecar JSON
          MetaObj := TJSONObject.Create;
          try
            MetaObj.AddPair('hole_id', Tray.HoleId);
            MetaObj.AddPair('tray_id', Tray.TrayId);
            MetaObj.AddPair('interval_from', TJSONNumber.Create(Tray.IntervalFrom));
            MetaObj.AddPair('interval_to', TJSONNumber.Create(Tray.IntervalTo));
            MetaObj.AddPair('path_raw', RawFile);
            MetaObj.AddPair('path_jpg', JpgFile);
            MetaObj.AddPair('path_thumbnail', ThumbFile);
            MetaObj.AddPair('comments', Tray.Comments);
            MetaObj.AddPair('date', Session.DateStr);
            MetaObj.AddPair('operator', Session.OperatorName);
            MetaObj.AddPair('site', Session.Site);
            MetaObj.AddPair('md5_raw', Md5Raw);
            MetaObj.AddPair('md5_jpg', Md5Jpg);
            MetaObj.AddPair('timestamp', TimestampStr);
            MetaObj.AddPair('tray_rows', TJSONNumber.Create(Tray.TrayRows));
            MetaObj.AddPair('tray_length', TJSONNumber.Create(Tray.TrayLength));
            MetaObj.AddPair('tray_width', TJSONNumber.Create(Tray.TrayWidth));
            MetaObj.AddPair('camera_model', CameraModel);
            MetaObj.AddPair('camera_serial', CameraSerial);
            MetaObj.AddPair('max_size_mb', TJSONNumber.Create(MaxSizeMB));
            MetaObj.AddPair('processing_version', '1.0');
            MetaObj.AddPair('application_version', GetConfig.GetString('app', 'version', '1.0.0'));

            MetaFile := TPath.Combine(Paths.JpgDir, FilenameBase + '.json');
            TFile.WriteAllText(MetaFile, MetaObj.Format(2), TEncoding.UTF8);
          finally
            MetaObj.Free;
          end;

          // 9. Append to Hole CSV
          AppendHoleCSV(Paths, Session, Tray, JpgFile, Md5Jpg, TimestampStr, SafeCrop, DecodedBmp.Width, DecodedBmp.Height);

          // 10. Update DB record to PROCESSED
          Result.Status := PhotoStatusToString(psProcessed);
          if FPhotoRepo <> nil then
          begin
            FPhotoRepo.UpdateProcessedData(Result.Id, JpgFile, ThumbFile, Md5Raw, Md5Jpg, psProcessed);
          end;
          Log.Info('Successfully processed core photo: ' + FilenameBase);
        finally
          SlatedBmp.Free;
        end;
      finally
        CroppedBmp.Free;
      end;
    finally
      DecodedBmp.Free;
    end;
  except
    on E: Exception do
    begin
      Log.Error('Processing failed for ' + FilenameBase + ': ' + E.Message);
      if FPhotoRepo <> nil then
        FPhotoRepo.UpdateStatus(Result.Id, psInvalid);
      raise;
    end;
  end;
end;

end.
