unit CP.Core.PyFormat;

interface

uses
  System.SysUtils;

function PyFmtZeroPad(Val: Double; TotalLen, Decimals: Integer): string;
function PyFmtG(Val: Double): string;
function FormatCoreFilename(const HoleId, TrayNumber: string; FromVal, ToVal: Double): string;
function GetInvariantFormatSettings: TFormatSettings;

implementation

function GetInvariantFormatSettings: TFormatSettings;
begin
  Result := TFormatSettings.Invariant;
  Result.DecimalSeparator := '.';
  Result.ThousandSeparator := ',';
end;

function PyFmtZeroPad(Val: Double; TotalLen, Decimals: Integer): string;
var
  FS: TFormatSettings;
  Raw: string;
  DotPos, IntPartLen, NeededZeroes: Integer;
begin
  FS := GetInvariantFormatSettings;
  Raw := FloatToStrF(Val, ffFixed, 15, Decimals, FS);
  DotPos := Pos('.', Raw);
  if DotPos > 0 then
    IntPartLen := DotPos - 1
  else
    IntPartLen := Length(Raw);

  NeededZeroes := (TotalLen - Decimals - 1) - IntPartLen;
  if NeededZeroes > 0 then
    Result := StringOfChar('0', NeededZeroes) + Raw
  else
    Result := Raw;
end;

function PyFmtG(Val: Double): string;
var
  FS: TFormatSettings;
  S: string;
begin
  FS := GetInvariantFormatSettings;
  S := FloatToStrF(Val, ffGeneral, 6, 0, FS);
  Result := S;
end;

function FormatCoreFilename(const HoleId, TrayNumber: string; FromVal, ToVal: Double): string;
var
  CleanHole, CleanTray, FromStr, ToStr: string;
  FS: TFormatSettings;
begin
  FS := GetInvariantFormatSettings;
  CleanHole := StringReplace(Trim(HoleId), ' ', '_', [rfReplaceAll]);
  CleanTray := StringReplace(Trim(TrayNumber), ' ', '_', [rfReplaceAll]);
  FromStr := PyFmtZeroPad(FromVal, 6, 2);
  ToStr := FloatToStrF(ToVal, ffFixed, 15, 2, FS);
  Result := Format('%s_%s_%s_%s', [CleanHole, CleanTray, FromStr, ToStr]);
end;

end.
