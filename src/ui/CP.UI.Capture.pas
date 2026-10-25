unit CP.UI.Capture;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Math, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, Vcl.Dialogs, CP.UI.Theme, CP.Core.AppContext,
  CP.Imaging.Crop, CP.Validation.Preflight;

type
  TCaptureView = class(TFrame)
    PnlLeft: TPanel;
    PnlCenter: TPanel;
    PnlTrayData: TPanel;
    LblTrayTitle: TLabel;
    LblHole: TLabel;
    EdtHole: TEdit;
    LblTray: TLabel;
    EdtTray: TEdit;
    LblFrom: TLabel;
    EdtFrom: TEdit;
    LblTo: TLabel;
    EdtTo: TEdit;
    LblRows: TLabel;
    EdtRows: TEdit;
    PnlPreflight: TPanel;
    LblPreflightStatus: TLabel;
    BtnCapture: TButton;
    BtnRetake: TButton;
    BtnSaveNext: TButton;
    PaintLiveView: TPaintBox;
    PnlLiveTopBar: TPanel;
    LblLiveStatus: TLabel;
    ChkGrid: TCheckBox;
    BtnZoom: TButton;
    procedure PaintLiveViewPaint(Sender: TObject);
    procedure BtnCaptureClick(Sender: TObject);
    procedure BtnRetakeClick(Sender: TObject);
    procedure BtnSaveNextClick(Sender: TObject);
    procedure ChkGridClick(Sender: TObject);
    procedure BtnZoomClick(Sender: TObject);
  private
    FGridEnabled: Boolean;
    FIsZoomed: Boolean;
    FTimerLiveView: TTimer;
    FLastFrame: TBitmap;
    procedure OnLiveTimer(Sender: TObject);
    procedure EvaluatePreflight;
    procedure AdvanceToNextTray;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RefreshData;
  end;

implementation

{$R *.dfm}

constructor TCaptureView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGridEnabled := True;
  FIsZoomed := False;
  FLastFrame := TBitmap.Create;

  FTimerLiveView := TTimer.Create(Self);
  FTimerLiveView.Interval := 66; // ~15 FPS live preview
  FTimerLiveView.OnTimer := OnLiveTimer;
  FTimerLiveView.Enabled := True;

  EvaluatePreflight;
end;

destructor TCaptureView.Destroy;
begin
  FTimerLiveView.Enabled := False;
  FTimerLiveView.Free;
  FLastFrame.Free;
  inherited Destroy;
end;

procedure TCaptureView.OnLiveTimer(Sender: TObject);
var
  Ctx: TCPAppContext;
  NewBmp: TBitmap;
begin
  if not Visible then Exit;
  try
    Ctx := GetAppContext;
    if (Ctx <> nil) and (Ctx.Camera <> nil) then
    begin
      NewBmp := Ctx.Camera.GetLiveFrame;
      if NewBmp <> nil then
      begin
        try
          FLastFrame.Assign(NewBmp);
        finally
          NewBmp.Free;
        end;
        PaintLiveView.Invalidate;
      end;
    end;
  except
  end;
end;

procedure TCaptureView.RefreshData;
begin
  EvaluatePreflight;
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.EvaluatePreflight;
var
  Ctx: TCPAppContext;
  Res: TPreflightResult;
  CR: TCropRegion;
  FVal, TVal: Double;
begin
  Ctx := GetAppContext;
  CR.X := 0; CR.Y := 0; CR.Width := 300; CR.Height := 200;
  FVal := StrToFloatDef(EdtFrom.Text, 0.0);
  TVal := StrToFloatDef(EdtTo.Text, 2.0);

  Res := Ctx.RunPreflight(EdtHole.Text, EdtTray.Text, FVal, TVal, CR);
  if Res.IsReady then
  begin
    LblPreflightStatus.Caption := 'READY TO CAPTURE';
    LblPreflightStatus.Font.Color := COLOR_SUCCESS;
    BtnCapture.Enabled := True;
  end
  else
  begin
    LblPreflightStatus.Caption := 'PRE-FLIGHT INCOMPLETE';
    LblPreflightStatus.Font.Color := COLOR_ERROR;
    BtnCapture.Enabled := True;
  end;
  Res.Items.Free;
end;

procedure TCaptureView.AdvanceToNextTray;
var
  TNum: Integer;
  FVal, TVal, Diff: Double;
begin
  TNum := StrToIntDef(EdtTray.Text, 1);
  EdtTray.Text := IntToStr(TNum + 1);

  FVal := StrToFloatDef(EdtFrom.Text, 0.0);
  TVal := StrToFloatDef(EdtTo.Text, 2.0);
  Diff := TVal - FVal;
  if Diff <= 0 then Diff := 2.0;

  EdtFrom.Text := FloatToStr(TVal);
  EdtTo.Text := FloatToStr(TVal + Diff);

  EvaluatePreflight;
end;

procedure TCaptureView.PaintLiveViewPaint(Sender: TObject);
var
  W, H, CX1, CY1, CX2, CY2, CW, CH: Integer;
  R, RowH, RY, TotalRows: Integer;
  Scale: Double;
  DispW, DispH, OffX, OffY: Integer;
  SrcRect, DstRect: TRect;
begin
  W := PaintLiveView.Width;
  H := PaintLiveView.Height;
  if (W <= 0) or (H <= 0) then Exit;

  // 1. Fill dark charcoal background
  PaintLiveView.Canvas.Brush.Color := RGB(24, 24, 27);
  PaintLiveView.Canvas.FillRect(Rect(0, 0, W, H));

  // 2. Render live frame if available
  if (FLastFrame <> nil) and (FLastFrame.Width > 0) and (FLastFrame.Height > 0) then
  begin
    Scale := Min(W / FLastFrame.Width, H / FLastFrame.Height);
    DispW := Max(1, Round(FLastFrame.Width * Scale));
    DispH := Max(1, Round(FLastFrame.Height * Scale));
    OffX := (W - DispW) div 2;
    OffY := (H - DispH) div 2;

    DstRect := Rect(OffX, OffY, OffX + DispW, OffY + DispH);

    if FIsZoomed then
    begin
      SrcRect := Rect(
        FLastFrame.Width div 4,
        FLastFrame.Height div 4,
        3 * FLastFrame.Width div 4,
        3 * FLastFrame.Height div 4
      );
    end
    else
      SrcRect := Rect(0, 0, FLastFrame.Width, FLastFrame.Height);

    PaintLiveView.Canvas.CopyRect(DstRect, FLastFrame.Canvas, SrcRect);
  end;

  // 3. Draw Grid (Rule of Thirds) in dashed cyan/blue if enabled
  if FGridEnabled then
  begin
    PaintLiveView.Canvas.Pen.Color := RGB(2, 132, 199);
    PaintLiveView.Canvas.Pen.Style := psDot;
    PaintLiveView.Canvas.MoveTo(W div 3, 0); PaintLiveView.Canvas.LineTo(W div 3, H);
    PaintLiveView.Canvas.MoveTo(2 * W div 3, 0); PaintLiveView.Canvas.LineTo(2 * W div 3, H);
    PaintLiveView.Canvas.MoveTo(0, H div 3); PaintLiveView.Canvas.LineTo(W, H div 3);
    PaintLiveView.Canvas.MoveTo(0, 2 * H div 3); PaintLiveView.Canvas.LineTo(W, 2 * H div 3);
  end;

  // 4. Geological Tray Crop Box (300 x 200 ratio)
  CW := Round(W * 0.88);
  CH := Round(CW / 1.5);
  if CH > Round(H * 0.88) then
  begin
    CH := Round(H * 0.88);
    CW := Round(CH * 1.5);
  end;

  CX1 := (W - CW) div 2;
  CY1 := (H - CH) div 2;
  CX2 := CX1 + CW;
  CY2 := CY1 + CH;

  // Bounding rectangle
  PaintLiveView.Canvas.Pen.Style := psSolid;
  PaintLiveView.Canvas.Pen.Color := clWhite;
  PaintLiveView.Canvas.Pen.Width := 2;
  PaintLiveView.Canvas.Brush.Style := bsClear;
  PaintLiveView.Canvas.Rectangle(CX1, CY1, CX2, CY2);

  // Row dividers matching Tray Rows
  TotalRows := StrToIntDef(EdtRows.Text, 3);
  if TotalRows < 1 then TotalRows := 1;
  RowH := CH div TotalRows;
  for R := 1 to TotalRows - 1 do
  begin
    RY := CY1 + R * RowH;
    PaintLiveView.Canvas.MoveTo(CX1, RY);
    PaintLiveView.Canvas.LineTo(CX2, RY);
  end;

  // Watermark Slate: Hole ID, Tray ID, Interval
  PaintLiveView.Canvas.Font.Name := 'Segoe UI';
  PaintLiveView.Canvas.Font.Size := 14;
  PaintLiveView.Canvas.Font.Style := [fsBold];
  PaintLiveView.Canvas.Font.Color := RGB(254, 240, 138); // Yellow
  PaintLiveView.Canvas.TextOut(CX1 + 10, CY1 + 8,
    Format('%s | TRAY %s | %s - %s m', [EdtHole.Text, EdtTray.Text, EdtFrom.Text, EdtTo.Text]));
end;

procedure TCaptureView.BtnCaptureClick(Sender: TObject);
var
  Ctx: TCPAppContext;
  CR: TCropRegion;
  FVal, TVal: Double;
begin
  Ctx := GetAppContext;
  CR.X := 0; CR.Y := 0; CR.Width := 300; CR.Height := 200;
  FVal := StrToFloatDef(EdtFrom.Text, 0.0);
  TVal := StrToFloatDef(EdtTo.Text, 2.0);

  try
    Ctx.ExecuteCapture(EdtHole.Text, EdtTray.Text, FVal, TVal, CR);
    ShowMessage('✓ FOTO BERHASIL DIAMBIL & DIPROSES!' + sLineBreak +
      Format('Hole: %s  |  Tray: %s  |  %.2f - %.2f m', [EdtHole.Text, EdtTray.Text, FVal, TVal]));
    AdvanceToNextTray;
  except
    on E: Exception do
      ShowMessage('Capture Error: ' + E.Message);
  end;
end;

procedure TCaptureView.BtnRetakeClick(Sender: TObject);
begin
  GetAppContext.RetakeCurrent;
  ShowMessage('Retake aktif: Foto lama ditandai SUPERSEDED.');
end;

procedure TCaptureView.BtnSaveNextClick(Sender: TObject);
var
  Cnt: Integer;
begin
  AdvanceToNextTray;
  if GetAppContext.GetServerFolder <> '' then
  begin
    if GetAppContext.SyncSessionToServerFolder('', Cnt) then
      ShowMessage(Format('Tray lanjut. %d file disinkronkan ke server folder.', [Cnt]));
  end
  else
    ShowMessage('Tray berhasil disimpan. Lanjut ke tray berikutnya!');
end;

procedure TCaptureView.ChkGridClick(Sender: TObject);
begin
  FGridEnabled := ChkGrid.Checked;
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.BtnZoomClick(Sender: TObject);
begin
  FIsZoomed := not FIsZoomed;
  if FIsZoomed then BtnZoom.Caption := 'Zoom Out' else BtnZoom.Caption := 'Zoom In';
  PaintLiveView.Invalidate;
end;

end.
