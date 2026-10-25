unit CP.Validation.Interval;

interface

uses
  System.SysUtils;

function ValidateInterval(FromVal, ToVal: Double; out ErrorMsg: string): Boolean;

implementation

function ValidateInterval(FromVal, ToVal: Double; out ErrorMsg: string): Boolean;
begin
  ErrorMsg := '';
  if FromVal < 0 then
  begin
    ErrorMsg := 'Interval kedalaman From tidak boleh bernilai negatif.';
    Exit(False);
  end;
  if ToVal < 0 then
  begin
    ErrorMsg := 'Interval kedalaman To tidak boleh bernilai negatif.';
    Exit(False);
  end;
  if ToVal < FromVal then
  begin
    ErrorMsg := Format('Interval kedalaman To (%.2f) harus lebih besar atau sama dengan From (%.2f).', [ToVal, FromVal]);
    Exit(False);
  end;
  Result := True;
end;

end.
