unit CP.Validation.Runner;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections,
  CP.DB.Models, CP.DB.Repositories;

type
  TCPValidationRunner = class
  private
    FPhotoRepo: TPhotoRepository;
    FValRepo: TValidationRepository;
  public
    constructor Create(APhotoRepo: TPhotoRepository; AValRepo: TValidationRepository);
    function ValidatePhoto(PhotoId: Integer; out Errors: TArray<string>): Boolean;
  end;

implementation

uses
  CP.Config.Manager, CP.Core.Logger, CP.Imaging.Raw,
  CP.Validation.Filename, CP.Validation.Interval;

constructor TCPValidationRunner.Create(APhotoRepo: TPhotoRepository; AValRepo: TValidationRepository);
begin
  inherited Create;
  FPhotoRepo := APhotoRepo;
  FValRepo := AValRepo;
end;

function TCPValidationRunner.ValidatePhoto(PhotoId: Integer; out Errors: TArray<string>): Boolean;
var
  Photo: TPhotoModel;
  ErrList: TList<string>;
  TargetId, FNameMsg, IntMsg, CalcMd5, MetaJson: string;
  RawOk, JpgOk, SizeOk: Boolean;
  ActualMB, MaxMB: Double;
  procedure RecordCheck(const Rule: string; IsValid: Boolean; const Msg: string);
  var
    M: TValidationResultModel;
  begin
    M.TargetType := 'photo';
    M.TargetId := TargetId;
    if IsValid then M.IsValid := 1 else M.IsValid := 0;
    M.RuleName := Rule;
    M.Message := Msg;
    if FValRepo <> nil then FValRepo.AddResult(M);
    if not IsValid then ErrList.Add(Format('[%s] %s', [Rule, Msg]));
  end;
begin
  Photo := FPhotoRepo.GetById(PhotoId);
  if Photo.Id = 0 then
  begin
    Errors := ['Foto tidak ditemukan di database.'];
    Exit(False);
  end;

  TargetId := IntToStr(PhotoId);
  if FValRepo <> nil then FValRepo.ClearForTarget('photo', TargetId);
  ErrList := TList<string>.Create;
  try
    // 1. Filename validation
    RecordCheck('FILENAME_FORMAT', ValidateFilename(Photo.FilenameBase, FNameMsg), FNameMsg);

    // 2. Interval validation
    RecordCheck('DEPTH_INTERVAL', ValidateInterval(Photo.IntervalFrom, Photo.IntervalTo, IntMsg), IntMsg);

    // 3. RAW existence & integrity
    if (Photo.RawPath = '') or (not TFile.Exists(Photo.RawPath)) then
      RecordCheck('RAW_FILE_EXISTS', False, 'File RAW tidak ditemukan pada path: ' + Photo.RawPath)
    else
    begin
      CalcMd5 := TRawHandler.CalculateMD5(Photo.RawPath);
      RawOk := (Photo.Md5Raw = '') or (CalcMd5 = Photo.Md5Raw);
      RecordCheck('RAW_MD5_INTEGRITY', RawOk, 'Integritas RAW cocok');

      // 3b. RAW file size validation (maks 5MB)
      MaxMB := GetConfig.GetFloat('imaging', 'max_raw_size_mb', 5.0);
      ActualMB := TFile.GetSize(Photo.RawPath) / (1024.0 * 1024.0);
      SizeOk := ActualMB <= (MaxMB + 0.05);
      RecordCheck('RAW_FILE_SIZE', SizeOk, Format('Ukuran RAW %.2f MB (Maks: %.1f MB)', [ActualMB, MaxMB]));
    end;

    // 4. JPG existence & integrity
    if (Photo.JpgPath = '') or (not TFile.Exists(Photo.JpgPath)) then
      RecordCheck('JPG_FILE_EXISTS', False, 'File JPG tidak ditemukan pada path: ' + Photo.JpgPath)
    else
    begin
      CalcMd5 := TRawHandler.CalculateMD5(Photo.JpgPath);
      JpgOk := (Photo.Md5Jpg = '') or (CalcMd5 = Photo.Md5Jpg);
      RecordCheck('JPG_MD5_INTEGRITY', JpgOk, 'Integritas JPG cocok');

      // 4b. JPG file size validation (min 5MB, maks 10MB)
      ActualMB := TFile.GetSize(Photo.JpgPath) / (1024.0 * 1024.0);
      SizeOk := (ActualMB >= (GetConfig.GetFloat('imaging', 'min_photo_size_mb', 5.0) - 0.05)) and
                (ActualMB <= (GetConfig.GetFloat('imaging', 'max_photo_size_mb', 10.0) + 0.05));
      RecordCheck('JPG_FILE_SIZE', SizeOk, Format('Ukuran JPG %.2f MB (Min: %.1f MB, Maks: %.1f MB)',
        [ActualMB, GetConfig.GetFloat('imaging', 'min_photo_size_mb', 5.0), GetConfig.GetFloat('imaging', 'max_photo_size_mb', 10.0)]));
    end;

    // 5. Thumbnail existence & file size (trump / thumb maks 4MB)
    if (Photo.ThumbnailPath = '') or (not TFile.Exists(Photo.ThumbnailPath)) then
      RecordCheck('THUMBNAIL_EXISTS', False, 'Thumbnail tidak ditemukan')
    else
    begin
      RecordCheck('THUMBNAIL_EXISTS', True, 'Thumbnail tersedia');
      MaxMB := GetConfig.GetFloat('imaging', 'max_thumbnail_size_mb', 4.0);
      ActualMB := TFile.GetSize(Photo.ThumbnailPath) / (1024.0 * 1024.0);
      SizeOk := ActualMB <= (MaxMB + 0.05);
      RecordCheck('THUMBNAIL_FILE_SIZE', SizeOk, Format('Ukuran Thumbnail %.2f MB (Maks: %.1f MB)', [ActualMB, MaxMB]));
    end;

    // 6. Metadata sidecar
    if Photo.JpgPath <> '' then
    begin
      MetaJson := TPath.ChangeExtension(Photo.JpgPath, '.json');
      RecordCheck('METADATA_SIDECAR', TFile.Exists(MetaJson), 'Metadata sidecar JSON tersedia');
    end;

    Result := (ErrList.Count = 0);
    if Result then
      FPhotoRepo.UpdateStatus(PhotoId, psValid)
    else
      FPhotoRepo.UpdateStatus(PhotoId, psInvalid);

    Errors := ErrList.ToArray;
  finally
    ErrList.Free;
  end;
end;

end.
