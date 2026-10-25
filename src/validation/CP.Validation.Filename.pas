unit CP.Validation.Filename;

interface

uses
  System.SysUtils, System.RegularExpressions;

function ValidateFilename(const Filename: string; out ErrorMsg: string): Boolean;

implementation

uses
  CP.Core.PyFormat;

const
  FILENAME_PATTERN = '^([A-Za-z0-9_-]+)_([A-Za-z0-9]+)_(\d+(\.\d+)?)_(\d+(\.\d+)?)\.?[a-zA-Z0-9]*$';

function ValidateFilename(const Filename: string; out ErrorMsg: string): Boolean;
var
  M: TMatch;
  FVal, TVal: Double;
  FS: TFormatSettings;
begin
  ErrorMsg := '';
  if Trim(Filename) = '' then
  begin
    ErrorMsg := 'Nama file tidak boleh kosong.';
    Exit(False);
  end;

  M := TRegEx.Match(Trim(Filename), FILENAME_PATTERN);
  if not M.Success then
  begin
    ErrorMsg := Format('Format nama file ''%s'' tidak valid. Harus mengikuti konvensi: ID_Drillhole_NoTray_IntervalKedalaman', [Filename]);
    Exit(False);
  end;

  FS := GetInvariantFormatSettings;
  FVal := StrToFloatDef(M.Groups[3].Value, 0.0, FS);
  TVal := StrToFloatDef(M.Groups[5].Value, 0.0, FS);
  if TVal < FVal then
  begin
    ErrorMsg := Format('Interval kedalaman dalam nama file tidak valid: To (%.2f) < From (%.2f).', [TVal, FVal]);
    Exit(False);
  end;

  Result := True;
end;

end.
