unit CP.UI.DatePicker;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, CP.UI.Theme;

type
  TDatePickerModal = class(TForm)
    PnlHeader: TPanel;
    LblMonthYear: TLabel;
    BtnPrevMonth: TButton;
    BtnNextMonth: TButton;
    PnlGrid: TPanel;
    BtnToday: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnPrevMonthClick(Sender: TObject);
    procedure BtnNextMonthClick(Sender: TObject);
    procedure BtnTodayClick(Sender: TObject);
  private
    FSelectedDate: TDate;
    FCurrentYear, FCurrentMonth: Word;
    FDayButtons: array[1..42] of TButton;
    procedure RenderCalendar;
    procedure DayButtonClick(Sender: TObject);
  public
    class function PickDate(var ADateStr: string): Boolean;
  end;

implementation

{$R *.dfm}

class function TDatePickerModal.PickDate(var ADateStr: string): Boolean;
var
  Dlg: TDatePickerModal;
begin
  Dlg := TDatePickerModal.Create(nil);
  try
    Result := (Dlg.ShowModal = mrOk);
    if Result then
      ADateStr := FormatDateTime('yyyymmdd', Dlg.FSelectedDate);
  finally
    Dlg.Free;
  end;
end;

procedure TDatePickerModal.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  Color := COLOR_PANEL;
  DecodeDate(Now, FCurrentYear, FCurrentMonth, I);
  FSelectedDate := Now;

  for I := 1 to 42 do
  begin
    FDayButtons[I] := TButton.Create(Self);
    FDayButtons[I].Parent := PnlGrid;
    FDayButtons[I].OnClick := DayButtonClick;
  end;
  RenderCalendar;
end;

procedure TDatePickerModal.RenderCalendar;
var
  FirstDay: TDate;
  StartCol, DaysInMonth, I, DayNum: Integer;
  Row, Col, X, Y: Integer;
begin
  LblMonthYear.Caption := FormatDateTime('mmmm yyyy', EncodeDate(FCurrentYear, FCurrentMonth, 1));
  FirstDay := EncodeDate(FCurrentYear, FCurrentMonth, 1);
  StartCol := DayOfWeek(FirstDay) - 1; // 0..6
  DaysInMonth := MonthDays[IsLeapYear(FCurrentYear), FCurrentMonth];

  for I := 1 to 42 do
  begin
    Row := (I - 1) div 7;
    Col := (I - 1) mod 7;
    X := Col * 38 + 10;
    Y := Row * 32 + 30;

    FDayButtons[I].SetBounds(X, Y, 36, 30);
    DayNum := I - StartCol;
    if (DayNum >= 1) and (DayNum <= DaysInMonth) then
    begin
      FDayButtons[I].Caption := IntToStr(DayNum);
      FDayButtons[I].Tag := DayNum;
      FDayButtons[I].Visible := True;
    end
    else
      FDayButtons[I].Visible := False;
  end;
end;

procedure TDatePickerModal.DayButtonClick(Sender: TObject);
var
  D: Integer;
begin
  D := (Sender as TButton).Tag;
  FSelectedDate := EncodeDate(FCurrentYear, FCurrentMonth, D);
  ModalResult := mrOk;
end;

procedure TDatePickerModal.BtnPrevMonthClick(Sender: TObject);
begin
  if FCurrentMonth = 1 then
  begin
    FCurrentMonth := 12;
    Dec(FCurrentYear);
  end
  else
    Dec(FCurrentMonth);
  RenderCalendar;
end;

procedure TDatePickerModal.BtnNextMonthClick(Sender: TObject);
begin
  if FCurrentMonth = 12 then
  begin
    FCurrentMonth := 1;
    Inc(FCurrentYear);
  end
  else
    Inc(FCurrentMonth);
  RenderCalendar;
end;

procedure TDatePickerModal.BtnTodayClick(Sender: TObject);
begin
  FSelectedDate := Now;
  ModalResult := mrOk;
end;

end.
