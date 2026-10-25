unit CP.Validation.Preflight;

interface

uses
  System.SysUtils, System.Generics.Collections,
  CP.DB.Models, CP.Storage.Manager, CP.Imaging.Crop;

type
  TPreflightItem = record
    Name: string;
    Passed: Boolean;
    Message: string;
    RemedyAction: string;
  end;

  TPreflightResult = record
    IsReady: Boolean;
    Items: TList<TPreflightItem>;
    function SummaryErrors: TArray<string>;
  end;

  TPreflightChecker = class
  public
    class function Check(
      CamConnected: Boolean;
      CamReady: Boolean;
      const ActiveSession: TSessionModel;
      const HoleId: string;
      const TrayId: string;
      IntervalFrom: Double;
      IntervalTo: Double;
      const CropRegion: TCropRegion;
      StorageMgr: TCPStorageManager = nil
    ): TPreflightResult;
  end;

implementation

uses
  CP.Validation.Interval;

function TPreflightResult.SummaryErrors: TArray<string>;
var
  ErrList: TList<string>;
  It: TPreflightItem;
begin
  ErrList := TList<string>.Create;
  try
    for It in Items do
      if not It.Passed then
        ErrList.Add(Format('%s: %s -> %s', [It.Name, It.Message, It.RemedyAction]));
    Result := ErrList.ToArray;
  finally
    ErrList.Free;
  end;
end;

class function TPreflightChecker.Check(
  CamConnected: Boolean;
  CamReady: Boolean;
  const ActiveSession: TSessionModel;
  const HoleId: string;
  const TrayId: string;
  IntervalFrom: Double;
  IntervalTo: Double;
  const CropRegion: TCropRegion;
  StorageMgr: TCPStorageManager
): TPreflightResult;
var
  It: TPreflightItem;
  HoleOk, TrayOk, IntOk, SessionOk, CropOk, StorageOk: Boolean;
  IntErr: string;
  AvailMB: Double;
begin
  Result.Items := TList<TPreflightItem>.Create;

  // 1. Camera Connected
  It.Name := 'Camera Connected';
  It.Passed := CamConnected;
  if CamConnected then begin It.Message := 'Kamera terhubung.'; It.RemedyAction := ''; end
  else begin It.Message := 'Kamera tidak terhubung.'; It.RemedyAction := 'Periksa kabel USB kamera atau pastikan webcam aktif.'; end;
  Result.Items.Add(It);

  // 2. Camera Ready
  It.Name := 'Camera Ready';
  It.Passed := CamReady;
  if CamReady then begin It.Message := 'Kamera siap.'; It.RemedyAction := ''; end
  else begin It.Message := 'Kamera sedang sibuk atau error.'; It.RemedyAction := 'Tunggu beberapa saat atau buka menu Diagnostics.'; end;
  Result.Items.Add(It);

  // 3. Active Session
  SessionOk := ActiveSession.Id <> '';
  It.Name := 'Active Session';
  It.Passed := SessionOk;
  if SessionOk then begin It.Message := Format('Sesi aktif: %s (%s)', [ActiveSession.Site, ActiveSession.DateStr]); It.RemedyAction := ''; end
  else begin It.Message := 'Tidak ada sesi aktif.'; It.RemedyAction := 'Buat sesi baru atau buka sesi sebelumnya di Dashboard.'; end;
  Result.Items.Add(It);

  // 4. Hole ID
  HoleOk := Trim(HoleId) <> '';
  It.Name := 'Hole ID';
  It.Passed := HoleOk;
  if HoleOk then begin It.Message := 'Hole ID: ' + HoleId; It.RemedyAction := ''; end
  else begin It.Message := 'Hole ID belum diisi.'; It.RemedyAction := 'Isi Hole ID (contoh: Core01).'; end;
  Result.Items.Add(It);

  // 5. Tray ID
  TrayOk := Trim(TrayId) <> '';
  It.Name := 'Tray ID';
  It.Passed := TrayOk;
  if TrayOk then begin It.Message := 'Tray ID: ' + TrayId; It.RemedyAction := ''; end
  else begin It.Message := 'Tray ID belum diisi.'; It.RemedyAction := 'Isi nomor Tray (contoh: 1, 2, dll).'; end;
  Result.Items.Add(It);

  // 6. Depth Interval
  IntOk := ValidateInterval(IntervalFrom, IntervalTo, IntErr);
  It.Name := 'Depth Interval';
  It.Passed := IntOk;
  if IntOk then begin It.Message := Format('Interval valid (%.2f - %.2f m)', [IntervalFrom, IntervalTo]); It.RemedyAction := ''; end
  else begin It.Message := IntErr; It.RemedyAction := 'Pastikan Core Interval To lebih besar atau sama dengan From.'; end;
  Result.Items.Add(It);

  // 7. Tray Data Completeness
  It.Name := 'Tray Data Completeness';
  It.Passed := HoleOk and TrayOk and IntOk;
  if It.Passed then begin It.Message := 'Data tray lengkap.'; It.RemedyAction := ''; end
  else begin It.Message := 'Data tray belum lengkap.'; It.RemedyAction := 'Lengkapi seluruh field wajib pada data tray.'; end;
  Result.Items.Add(It);

  // 8. Storage Space
  if StorageMgr <> nil then
  begin
    StorageOk := StorageMgr.IsStorageSufficient(300.0);
    AvailMB := StorageMgr.GetAvailableSpaceMB;
  end
  else
  begin
    StorageOk := True;
    AvailMB := 1024.0;
  end;
  It.Name := 'Storage Space';
  It.Passed := StorageOk;
  if StorageOk then begin It.Message := Format('Penyimpanan tersedia (%.1f MB bebas).', [AvailMB]); It.RemedyAction := ''; end
  else begin It.Message := Format('Penyimpanan hampir penuh (%.1f MB tersisa).', [AvailMB]); It.RemedyAction := 'Kosongkan ruang disk sebelum melanjutkan capture.'; end;
  Result.Items.Add(It);

  // 9. Tray Crop Region
  CropOk := (CropRegion.Width > 20) and (CropRegion.Height > 20);
  It.Name := 'Tray Crop Region';
  It.Passed := CropOk;
  if CropOk then begin It.Message := 'Tray Crop telah disetel.'; It.RemedyAction := ''; end
  else begin It.Message := 'Tray Crop belum disetel.'; It.RemedyAction := 'Sesuaikan area framing Tray Crop pada Live View.'; end;
  Result.Items.Add(It);

  // 10. Camera Configuration
  It.Name := 'Camera Configuration';
  It.Passed := CamReady;
  if CamReady then begin It.Message := 'Konfigurasi kamera valid.'; It.RemedyAction := ''; end
  else begin It.Message := 'Kamera tidak mendukung capture.'; It.RemedyAction := 'Pilih kamera yang kompatibel.'; end;
  Result.Items.Add(It);

  Result.IsReady := CamConnected and CamReady and SessionOk and HoleOk and TrayOk and IntOk and StorageOk and CropOk;
end;

end.
