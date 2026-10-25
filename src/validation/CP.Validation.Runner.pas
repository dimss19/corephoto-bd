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
    end;

    // 4. JPG existence & integrity
    if (Photo.JpgPath = '') or (not TFile.Exists(Photo.JpgPath)) then
      RecordCheck('JPG_FILE_EXISTS', False, 'File JPG tidak ditemukan pada path: ' + Photo.JpgPath)
    else
    begin
      CalcMd5 := TRawHandler.CalculateMD5(Photo.JpgPath);
      JpgOk := (Photo.Md5Jpg = '') or (CalcMd5 = Photo.Md5Jpg);
      RecordCheck('JPG_MD5_INTEGRITY', JpgOk, 'Integritas JPG cocok');

      // 4b. Max file size validation
      MaxMB := GetConfig.GetFloat('imaging', 'max_photo_size_mb', 10.0);
      ActualMB := TFile.GetSize(Photo.JpgPath) / (1024.0 * 1024.0);
      SizeOk := ActualMB <= (MaxMB + 0.05);
      RecordCheck('MAX_FILE_SIZE', SizeOk, Format('Ukuran JPG %.2f MB (Maks: %.1f MB)', [ActualMB, MaxMB]));
    end;

    // 5. Thumbnail existence
    RecordCheck('THUMBNAIL_EXISTS', (Photo.ThumbnailPath <> '') and TFile.Exists(Photo.ThumbnailPath), 'Thumbnail tersedia');

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
