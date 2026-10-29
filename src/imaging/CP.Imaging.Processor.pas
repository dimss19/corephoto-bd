unit CP.Imaging.Processor;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Math, System.IOUtils, System.JSON, Vcl.Graphics,
  Vcl.Imaging.jpeg,
  CP.DB.Models, CP.DB.Repositories, CP.Storage.Manager, CP.Imaging.Crop,
  CP.Imaging.Raw, CP.Imaging.Thumbnail, CP.Imaging.Exif;

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
  W, H, BannerH, FontSize, YPos, XRight, TextW, LeftW: Integer;
  LeftText, RightText, OpText: string;
  TwoLines: Boolean;
begin
  W := Img.Width;
  H := Img.Height;

  LeftText := Format('HOLE ID: %s  TRAY ID: %s  FROM: %s  TO: %s',
    [HoleId, TrayId, PyFmtG(FromVal), PyFmtG(ToVal)]);

  OpText := '';
  if Trim(OperatorName) <> '' then
    OpText := Format('OPERATOR: %s  ', [Trim(OperatorName)]);
  RightText := OpText + 'TIMESTAMP: ' + TimestampStr;

  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.SetSize(W, H);
  Result.Canvas.Draw(0, 0, Img);

  Result.Canvas.Font.Name := 'Segoe UI';
  Result.Canvas.Font.Style := [fsBold];
  Result.Canvas.Font.Color := clBlack;
  Result.Canvas.Brush.Style := bsClear;

  // 1. Initial banner calculation (default 8% of image height)
  BannerH := Round(H * 0.08);
  if BannerH < 26 then BannerH := 26;

  FontSize := Round(BannerH * 0.44);
  if FontSize < 9 then FontSize := 9;
  Result.Canvas.Font.Size := FontSize;

  LeftW := Result.Canvas.TextWidth(LeftText);
  TextW := Result.Canvas.TextWidth(RightText);

  // 2. Check if text fits on a single line with safe margins
  TwoLines := False;
  if LeftW + TextW + 28 > W then
  begin
    // Try reducing font size down to 8pt
    while (FontSize > 8) and (LeftW + TextW + 28 > W) do
    begin
      Dec(FontSize);
      Result.Canvas.Font.Size := FontSize;
      LeftW := Result.Canvas.TextWidth(LeftText);
      TextW := Result.Canvas.TextWidth(RightText);
    end;

    // If still too wide for single line, switch to 2-line layout
    if LeftW + TextW + 24 > W then
    begin
      TwoLines := True;
      BannerH := Max(Round(H * 0.12), 48);
      FontSize := Round(BannerH * 0.28);
      if FontSize < 8 then FontSize := 8;
      Result.Canvas.Font.Size := FontSize;
    end;
  end;

  // 3. Draw white background rectangle with crisp separator line
  Result.Canvas.Brush.Color := clWhite;
  Result.Canvas.Brush.Style := bsSolid;
  Result.Canvas.Pen.Color := RGB(180, 185, 190);
  Result.Canvas.Pen.Width := 1;
  Result.Canvas.Rectangle(0, H - BannerH, W, H);
  Result.Canvas.MoveTo(0, H - BannerH);
  Result.Canvas.LineTo(W, H - BannerH);

  Result.Canvas.Font.Color := clBlack;
  Result.Canvas.Font.Style := [fsBold];
  Result.Canvas.Brush.Style := bsClear;

  if TwoLines then
  begin
    // Clean two-line layout: Line 1 = geological info, Line 2 = operator & time
    YPos := H - BannerH + 4;
    Result.Canvas.TextOut(12, YPos, LeftText);
    YPos := YPos + FontSize + 6;
    Result.Canvas.TextOut(12, YPos, RightText);
  end
  else
  begin
    // Single-line layout: LeftText on left, RightText on right
    YPos := H - BannerH + (BannerH - FontSize) div 2;
    Result.Canvas.TextOut(12, YPos, LeftText);

    XRight := W - Result.Canvas.TextWidth(RightText) - 12;
    if XRight < LeftW + 16 then
      XRight := LeftW + 16;
    Result.Canvas.TextOut(XRight, YPos, RightText);
  end;
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
  InitialQuality, CurrentQuality: Integer;
  MaxBytes, FileSize: Int64;
  MinSizeMB, MaxSizeMBDbl: Double;
  ExifMeta: TExifMetadata;
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
      if (SafeCrop.Width <= 0) or (SafeCrop.Height <= 0) or
         ((SafeCrop.X = 0) and (SafeCrop.Y = 0) and (SafeCrop.Width >= DecodedBmp.Width) and (SafeCrop.Height >= DecodedBmp.Height)) then
      begin
        // Full Frame — No cropping! Keep complete camera frame
        CroppedBmp := TBitmap.Create;
        CroppedBmp.PixelFormat := pf24bit;
        CroppedBmp.SetSize(DecodedBmp.Width, DecodedBmp.Height);
        CroppedBmp.Canvas.Draw(0, 0, DecodedBmp);
        SafeCrop.X := 0;
        SafeCrop.Y := 0;
        SafeCrop.Width := DecodedBmp.Width;
        SafeCrop.Height := DecodedBmp.Height;
      end
      else
      begin
        // Tray Crop — crop framed region and ensure high resolution output
        CroppedBmp := SafeCrop.ApplyToBitmap(DecodedBmp, DecodedBmp.Width, DecodedBmp.Height);
      end;
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
          // 6. Encode JPEG with min/max photo size enforcement and EXIF metadata
          JpgFile := TPath.Combine(Paths.JpgDir, FilenameBase + '.jpg');
          InitialQuality := GetConfig.GetInteger('imaging', 'jpg_quality', 95);
          MinSizeMB := GetConfig.GetFloat('imaging', 'min_photo_size_mb', 5.0);
          MaxSizeMBDbl := GetConfig.GetFloat('imaging', 'max_photo_size_mb', 10.0);
          MaxBytes := Round(MaxSizeMBDbl * 1024.0 * 1024.0);

          CurrentQuality := InitialQuality;
          Jpg := TJPEGImage.Create;
          try
            Jpg.CompressionQuality := CurrentQuality;
            Jpg.Assign(SlatedBmp);
            Jpg.SaveToFile(JpgFile);

            // Progressive reduction if size exceeds MaxBytes
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

          // Inject EXIF Metadata matching Windows Properties (Canon EOS 60D, 72 DPI, Comments) & enforce min 5MB - max 10MB
          ExifMeta.Make := GetConfig.GetString('camera', 'camera_maker', 'Canon');
          ExifMeta.Model := GetConfig.GetString('camera', 'camera_model', 'Canon EOS 60D');
          ExifMeta.Software := 'CorePhoto BD ' + GetConfig.GetString('app', 'version', '1.0.1');
          ExifMeta.DateTime := Now;
          ExifMeta.Comments := Format('Site: %s Hole: %s', [Session.Site, Tray.HoleId]);
          if Trim(Tray.Comments) <> '' then
            ExifMeta.Comments := ExifMeta.Comments + ' Comments: ' + Trim(Tray.Comments);
          ExifMeta.XResolution := GetConfig.GetInteger('imaging', 'dpi', 72);
          ExifMeta.YResolution := GetConfig.GetInteger('imaging', 'dpi', 72);
          ExifMeta.ResolutionUnit := 2; // inches
          ExifMeta.FNumberNum := 10;
          ExifMeta.FNumberDen := 1;
          ExifMeta.ExposureTimeNum := 1;
          ExifMeta.ExposureTimeDen := 3;
          ExifMeta.ISOSpeed := 200;

          InjectExifAndEnforceFileSize(JpgFile, ExifMeta, MinSizeMB, MaxSizeMBDbl);

          Md5Jpg := TRawHandler.CalculateMD5(JpgFile);
          Result.JpgPath := JpgFile;
          Result.Md5Jpg := Md5Jpg;

          // 7. Generate Thumbnail (1024 x 473, matching properties and max 4MB)
          ThumbFile := TPath.Combine(Paths.ThumbnailDir, FilenameBase + '_thumb.jpg');
          TThumbnailGenerator.Generate(SlatedBmp, ThumbFile, 1024, 473);
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
            MetaObj.AddPair('max_size_mb', TJSONNumber.Create(MaxSizeMBDbl));
            MetaObj.AddPair('processing_version', '1.0');
            MetaObj.AddPair('application_version', GetConfig.GetString('app', 'version', '1.0.1'));

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
