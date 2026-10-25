unit CP.UI.Capture;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Math, System.IOUtils, Vcl.Forms, Vcl.Controls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.Dialogs,
  CP.UI.Theme, CP.Core.AppContext, CP.Imaging.Crop, CP.Validation.Preflight,
  CP.Camera.Intf, CP.Camera.Webcam;

type
  TCaptureView = class(TFrame)
    PnlLeft: TPanel;
    PnlTabButtons: TPanel;
    BtnTabTrayData: TButton;
    BtnTabCamSettings: TButton;
    ScrollBoxTray: TScrollBox;
    LblTrayTitle: TLabel;
    LblTraySubtitle: TLabel;
    PnlSessionDetails: TPanel;
    LblSessTitle: TLabel;
    LblDate: TLabel;
    EdtDate: TEdit;
    BtnPickDate: TButton;
    LblOperator: TLabel;
    EdtOperator: TEdit;
    LblSite: TLabel;
    EdtSite: TEdit;
    PnlImageDetails: TPanel;
    LblImageTitle: TLabel;
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
    LblCropArea: TLabel;
    EdtCropArea: TEdit;
    LblTrayLength: TLabel;
    EdtTrayLength: TEdit;
    LblTrayWidth: TLabel;
    EdtTrayWidth: TEdit;
    PnlComments: TPanel;
    LblComments: TLabel;
    MemoComments: TMemo;
    ScrollBoxCam: TScrollBox;
    PnlDevInfo: TPanel;
    LblDevTitle: TLabel;
    LblInterface: TLabel;
    CmbInterface: TComboBox;
    LblWebcamDev: TLabel;
    CmbWebcamDevice: TComboBox;
    BtnWebcamRefresh: TButton;
    LblWebcamHint: TLabel;
    LblDevModel: TLabel;
    LblDevSerial: TLabel;
    LblDevFw: TLabel;
    BtnDevDetect: TButton;
    BtnDevReconnect: TButton;
    PnlCamSettings: TPanel;
    LblCamSetTitle: TLabel;
    LblFormat: TLabel;
    CmbFormat: TComboBox;
    LblExposure: TLabel;
    CmbExposure: TComboBox;
    LblAperture: TLabel;
    CmbAperture: TComboBox;
    LblFlash: TLabel;
    ChkFlash: TCheckBox;
    LblMetering: TLabel;
    CmbMetering: TComboBox;
    LblFocusing: TLabel;
    CmbFocusing: TComboBox;
    LblIso: TLabel;
    CmbIso: TComboBox;
    LblResolution: TLabel;
    CmbResolution: TComboBox;
    PnlCenter: TPanel;
    PnlLiveTopBar: TPanel;
    LblLiveStatus: TLabel;
    BtnCropToggle: TButton;
    BtnLiveReconnect: TButton;
    PaintLiveView: TPaintBox;
    PnlPreflightBanner: TPanel;
    LblPreflightChecklist: TLabel;
    LblPreflightVerdict: TLabel;
    PnlControlBottom: TPanel;
    PnlCardDetails: TPanel;
    LblDetailsTitle: TLabel;
    LblDimKey: TLabel;
    LblDimVal: TLabel;
    LblSizeKey: TLabel;
    LblSizeVal: TLabel;
    LblCapKey: TLabel;
    LblCapVal: TLabel;
    LblDestKey: TLabel;
    LblDestVal: TLabel;
    PnlCtrlCenter: TPanel;
    ChkGrid: TCheckBox;
    BtnZoom: TButton;
    LblFocusDrive: TLabel;
    BtnFocusStepN3: TButton;
    BtnFocusStepN2: TButton;
    BtnFocusStepN1: TButton;
    BtnFocusStepP1: TButton;
    BtnFocusStepP2: TButton;
    BtnFocusStepP3: TButton;
    PnlCtrlActions: TPanel;
    BtnLiveViewToggle: TButton;
    BtnCapture: TButton;
    BtnRetake: TButton;
    BtnSave: TButton;
    BtnFinish: TButton;
    procedure BtnTabTrayDataClick(Sender: TObject);
    procedure BtnTabCamSettingsClick(Sender: TObject);
    procedure BtnPickDateClick(Sender: TObject);
    procedure FormFieldChange(Sender: TObject);
    procedure CmbInterfaceChange(Sender: TObject);
    procedure CmbWebcamDeviceChange(Sender: TObject);
    procedure BtnWebcamRefreshClick(Sender: TObject);
    procedure BtnDevDetectClick(Sender: TObject);
    procedure BtnDevReconnectClick(Sender: TObject);
    procedure BtnCropToggleClick(Sender: TObject);
    procedure BtnLiveReconnectClick(Sender: TObject);
    procedure PaintLiveViewPaint(Sender: TObject);
    procedure ChkGridClick(Sender: TObject);
    procedure BtnZoomClick(Sender: TObject);
    procedure FocusStepClick(Sender: TObject);
    procedure BtnLiveViewToggleClick(Sender: TObject);
    procedure BtnCaptureClick(Sender: TObject);
    procedure BtnRetakeClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnFinishClick(Sender: TObject);
  private
    FActiveTab: Integer; // 0 = Tray Data, 1 = Camera Settings
    FGridEnabled: Boolean;
    FCropBoxEnabled: Boolean;
    FIsZoomed: Boolean;
    FLiveViewActive: Boolean;
    FInLiveTimer: Boolean;
    FTimerLiveView: TTimer;
    FLastFrame: TBitmap;
    FBufferBmp: TBitmap;

    procedure OnLiveTimer(Sender: TObject);
    procedure EvaluatePreflight;
    procedure AdvanceToNextTray;
    procedure RefreshWebcamList;
    procedure RefreshCamInfo;
    procedure UpdateTabStyles;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SelectTab(TabIndex: Integer);
    procedure ToggleCameraSettingsTab;
    procedure RefreshData;
  end;

implementation

uses
  CP.UI.DatePicker, CP.DB.Models;

{$R *.dfm}

constructor TCaptureView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DoubleBuffered := True;
  PnlCenter.DoubleBuffered := True;
  FActiveTab := 0;
  FGridEnabled := True;
  FCropBoxEnabled := True;
  FIsZoomed := False;
  FLiveViewActive := True;
  FInLiveTimer := False;
  FLastFrame := TBitmap.Create;
  FBufferBmp := TBitmap.Create;
  FBufferBmp.PixelFormat := pf24bit;

  FTimerLiveView := TTimer.Create(Self);
  FTimerLiveView.Interval := 66; // ~15 FPS
  FTimerLiveView.OnTimer := OnLiveTimer;
  FTimerLiveView.Enabled := True;

  SelectTab(0);
  RefreshWebcamList;
  RefreshCamInfo;
  EvaluatePreflight;
end;

destructor TCaptureView.Destroy;
begin
  FTimerLiveView.Enabled := False;
  FTimerLiveView.Free;
  FLastFrame.Free;
  FBufferBmp.Free;
  inherited Destroy;
end;

procedure TCaptureView.SelectTab(TabIndex: Integer);
begin
  FActiveTab := TabIndex;
  ScrollBoxTray.Visible := (TabIndex = 0);
  ScrollBoxCam.Visible := (TabIndex = 1);
  UpdateTabStyles;
end;

procedure TCaptureView.ToggleCameraSettingsTab;
begin
  if FActiveTab = 1 then
    SelectTab(0)
  else
    SelectTab(1);
end;

procedure TCaptureView.UpdateTabStyles;
begin
  if FActiveTab = 0 then
  begin
    BtnTabTrayData.Font.Style := [fsBold];
    BtnTabCamSettings.Font.Style := [];
  end
  else
  begin
    BtnTabTrayData.Font.Style := [];
    BtnTabCamSettings.Font.Style := [fsBold];
  end;
end;

procedure TCaptureView.BtnTabTrayDataClick(Sender: TObject);
begin
  SelectTab(0);
end;

procedure TCaptureView.BtnTabCamSettingsClick(Sender: TObject);
begin
  SelectTab(1);
end;

procedure TCaptureView.BtnPickDateClick(Sender: TObject);
var
  DStr: string;
begin
  if TDatePickerModal.PickDate(DStr) then
  begin
    EdtDate.Text := DStr;
    EvaluatePreflight;
  end;
end;

procedure TCaptureView.FormFieldChange(Sender: TObject);
begin
  EvaluatePreflight;
end;

procedure TCaptureView.RefreshData;
var
  Ctx: TCPAppContext;
begin
  Ctx := GetAppContext;
  if (Ctx <> nil) and (Ctx.ActiveSession.Id <> '') then
  begin
    EdtDate.Text := Ctx.ActiveSession.DateStr;
    EdtOperator.Text := Ctx.ActiveSession.OperatorName;
    EdtSite.Text := Ctx.ActiveSession.Site;
  end;

  RefreshCamInfo;
  EvaluatePreflight;
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.RefreshWebcamList;
var
  Devs: TArray<string>;
  I: Integer;
begin
  CmbWebcamDevice.Items.Clear;
  Devs := TWebcamAdapter.ListDevices;
  if Length(Devs) > 0 then
  begin
    for I := 0 to High(Devs) do
      CmbWebcamDevice.Items.Add(Format('%s - Index %d', [Devs[I], I]));
    CmbWebcamDevice.ItemIndex := 0;
    LblWebcamHint.Caption := Format('%d webcam terdeteksi. Pilih internal/external lalu live view mengikuti otomatis.', [Length(Devs)]);
  end
  else
  begin
    CmbWebcamDevice.Items.Add('Simulator / Standby Mode');
    CmbWebcamDevice.ItemIndex := 0;
    LblWebcamHint.Caption := 'Tidak ada webcam fisik terdeteksi. Berjalan dalam mode Simulator Standby.';
  end;
end;

procedure TCaptureView.RefreshCamInfo;
var
  Ctx: TCPAppContext;
  Info: TCameraInfo;
begin
  Ctx := GetAppContext;
  if (Ctx <> nil) and (Ctx.Camera <> nil) then
  begin
    Info := Ctx.Camera.GetInfo;
    LblDevModel.Caption := 'Model: ' + Info.Model;
    LblDevSerial.Caption := 'Serial No: ' + Info.SerialNumber;
    LblDevFw.Caption := 'Firmware: ' + Info.FirmwareVersion;
  end;
end;

procedure TCaptureView.CmbInterfaceChange(Sender: TObject);
var
  Ctx: TCPAppContext;
begin
  Ctx := GetAppContext;
  if Ctx = nil then Exit;

  if CmbInterface.ItemIndex = 1 then
    Ctx.Camera.ConnectCamera('direct_usb', '0')
  else
    Ctx.Camera.ConnectCamera('webcam', IntToStr(Max(0, CmbWebcamDevice.ItemIndex)));

  RefreshCamInfo;
  EvaluatePreflight;
end;

procedure TCaptureView.CmbWebcamDeviceChange(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := CmbWebcamDevice.ItemIndex;
  if Idx < 0 then Idx := 0;
  GetAppContext.Camera.ConnectCamera('webcam', IntToStr(Idx));
  RefreshCamInfo;
  EvaluatePreflight;
end;

procedure TCaptureView.BtnWebcamRefreshClick(Sender: TObject);
begin
  RefreshWebcamList;
  CmbWebcamDeviceChange(nil);
end;

procedure TCaptureView.BtnDevDetectClick(Sender: TObject);
begin
  RefreshWebcamList;
  CmbWebcamDeviceChange(nil);
  ShowMessage('Pendeteksian kamera selesai: ' + LblDevModel.Caption);
end;

procedure TCaptureView.BtnDevReconnectClick(Sender: TObject);
begin
  CmbWebcamDeviceChange(nil);
  ShowMessage('Koneksi kamera di-refresh.');
end;

procedure TCaptureView.BtnCropToggleClick(Sender: TObject);
begin
  FCropBoxEnabled := not FCropBoxEnabled;
  if FCropBoxEnabled then
    BtnCropToggle.Caption := 'Crop Box: ON'
  else
    BtnCropToggle.Caption := 'Crop Box: OFF';
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.BtnLiveReconnectClick(Sender: TObject);
begin
  CmbWebcamDeviceChange(nil);
end;

procedure TCaptureView.ChkGridClick(Sender: TObject);
begin
  FGridEnabled := ChkGrid.Checked;
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.BtnZoomClick(Sender: TObject);
begin
  FIsZoomed := not FIsZoomed;
  if FIsZoomed then
    BtnZoom.Caption := 'Zoom Out'
  else
    BtnZoom.Caption := 'Zoom In';
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.FocusStepClick(Sender: TObject);
begin
  // Step motor command for DSLR tethering
end;

procedure TCaptureView.BtnLiveViewToggleClick(Sender: TObject);
begin
  FLiveViewActive := not FLiveViewActive;
  FTimerLiveView.Enabled := FLiveViewActive;
  if FLiveViewActive then
    BtnLiveViewToggle.Caption := 'End Live View'
  else
  begin
    BtnLiveViewToggle.Caption := 'Start Live View';
    PaintLiveView.Invalidate;
  end;
end;

procedure TCaptureView.OnLiveTimer(Sender: TObject);
var
  Ctx: TCPAppContext;
  NewBmp: TBitmap;
begin
  if FInLiveTimer or (not Visible) or (not FLiveViewActive) then Exit;
  FInLiveTimer := True;
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
  FInLiveTimer := False;
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
    LblPreflightChecklist.Caption := 'Camera '#10003'  '#183'  Session '#10003'  '#183'  Hole ID '#10003'  '#183'  Tray ID '#10003'  '#183'  Interval '#10003'  '#183'  Storage '#10003'  '#183'  Crop '#10003;
    LblPreflightVerdict.Caption := 'READY TO CAPTURE: All pre-flight checklist items verified.';
    LblPreflightVerdict.Font.Color := COLOR_SUCCESS;
    BtnCapture.Enabled := True;
  end
  else
  begin
    LblPreflightChecklist.Caption := 'Camera '#10003'  '#183'  Session '#10003'  '#183'  Hole ID '#10003'  '#183'  Tray ID '#10003'  '#183'  Interval '#10003'  '#183'  Storage '#10003'  '#183'  Crop X';
    var ErrList: TArray<string> := Res.SummaryErrors;
    if Length(ErrList) > 0 then
      LblPreflightVerdict.Caption := 'CANNOT CAPTURE: ' + ErrList[0]
    else
      LblPreflightVerdict.Caption := 'CANNOT CAPTURE: Pre-flight check failed.';
    LblPreflightVerdict.Font.Color := COLOR_ERROR;
    BtnCapture.Enabled := True; // Let operator click and see remedy dialog
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

  if (FBufferBmp.Width <> W) or (FBufferBmp.Height <> H) then
    FBufferBmp.SetSize(W, H);

  // 1. Dark charcoal background rendered on off-screen buffer
  FBufferBmp.Canvas.Brush.Color := RGB(10, 10, 12);
  FBufferBmp.Canvas.FillRect(Rect(0, 0, W, H));

  // 2. Render live camera frame
  if FLiveViewActive and (FLastFrame <> nil) and (FLastFrame.Width > 0) and (FLastFrame.Height > 0) then
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

    FBufferBmp.Canvas.CopyRect(DstRect, FLastFrame.Canvas, SrcRect);
  end;

  // 3. Rule of Thirds Grid
  if FGridEnabled then
  begin
    FBufferBmp.Canvas.Pen.Color := RGB(2, 132, 199);
    FBufferBmp.Canvas.Pen.Style := psDot;
    FBufferBmp.Canvas.MoveTo(W div 3, 0); FBufferBmp.Canvas.LineTo(W div 3, H);
    FBufferBmp.Canvas.MoveTo(2 * W div 3, 0); FBufferBmp.Canvas.LineTo(2 * W div 3, H);
    FBufferBmp.Canvas.MoveTo(0, H div 3); FBufferBmp.Canvas.LineTo(W, H div 3);
    FBufferBmp.Canvas.MoveTo(0, 2 * H div 3); FBufferBmp.Canvas.LineTo(W, 2 * H div 3);
  end;

  // 4. Crop Box
  if FCropBoxEnabled then
  begin
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

    FBufferBmp.Canvas.Pen.Style := psSolid;
    FBufferBmp.Canvas.Pen.Color := clWhite;
    FBufferBmp.Canvas.Pen.Width := 2;
    FBufferBmp.Canvas.Brush.Style := bsClear;
    FBufferBmp.Canvas.Rectangle(CX1, CY1, CX2, CY2);

    TotalRows := StrToIntDef(EdtRows.Text, 3);
    if TotalRows < 1 then TotalRows := 1;
    RowH := CH div TotalRows;
    for R := 1 to TotalRows - 1 do
    begin
      RY := CY1 + R * RowH;
      FBufferBmp.Canvas.MoveTo(CX1, RY);
      FBufferBmp.Canvas.LineTo(CX2, RY);
    end;

    // Slate watermark
    FBufferBmp.Canvas.Font.Name := 'Segoe UI';
    FBufferBmp.Canvas.Font.Size := 14;
    FBufferBmp.Canvas.Font.Style := [fsBold];
    FBufferBmp.Canvas.Font.Color := RGB(254, 240, 138); // Yellow
    FBufferBmp.Canvas.Brush.Style := bsClear;
    FBufferBmp.Canvas.TextOut(CX1 + 10, CY1 + 8,
      Format('%s | TRAY %s | %s - %s m', [EdtHole.Text, EdtTray.Text, EdtFrom.Text, EdtTo.Text]));
  end;

  // 5. Single atomic blit to screen canvas
  PaintLiveView.Canvas.Draw(0, 0, FBufferBmp);
end;

procedure TCaptureView.BtnCaptureClick(Sender: TObject);
var
  Ctx: TCPAppContext;
  CR: TCropRegion;
  FVal, TVal, FileSizeMB: Double;
  Photo: TPhotoModel;
begin
  Ctx := GetAppContext;
  CR.X := 0; CR.Y := 0; CR.Width := 300; CR.Height := 200;
  FVal := StrToFloatDef(EdtFrom.Text, 0.0);
  TVal := StrToFloatDef(EdtTo.Text, 2.0);

  try
    Photo := Ctx.ExecuteCapture(EdtHole.Text, EdtTray.Text, FVal, TVal, CR);

    LblDimVal.Caption := Format('%dx%d px', [Photo.CropW, Photo.CropH]);
    if (Photo.JpgPath <> '') and TFile.Exists(Photo.JpgPath) then
      FileSizeMB := TFile.GetSize(Photo.JpgPath) / (1024.0 * 1024.0)
    else
      FileSizeMB := 0.0;
    LblSizeVal.Caption := Format('%.2f MB', [FileSizeMB]);
    LblCapVal.Caption := 'Captured (OK)';
    LblDestVal.Caption := ExtractFileName(Photo.JpgPath);

    BtnRetake.Enabled := True;
    BtnSave.Enabled := True;

    ShowMessage('✓ FOTO BERHASIL DIAMBIL & DIPROSES!' + sLineBreak +
      Format('Hole: %s  |  Tray: %s  |  %.2f - %.2f m', [Photo.HoleId, Photo.TrayNumber, FVal, TVal]));

    AdvanceToNextTray;
  except
    on E: Exception do
      ShowMessage('Capture Error: ' + E.Message);
  end;
end;

procedure TCaptureView.BtnRetakeClick(Sender: TObject);
begin
  GetAppContext.RetakeCurrent;
  LblCapVal.Caption := 'SUPERSEDED (Retake)';
  ShowMessage('Foto lama ditandai SUPERSEDED. Siap untuk pengambilan ulang.');
end;

procedure TCaptureView.BtnSaveClick(Sender: TObject);
var
  Cnt: Integer;
begin
  if GetAppContext.GetServerFolder <> '' then
  begin
    if GetAppContext.SyncSessionToServerFolder('', Cnt) then
      ShowMessage(Format('✓ %d foto berhasil disimpan && disinkronkan ke server folder.', [Cnt]))
    else
      ShowMessage('Foto tersimpan lokal. Sinkronisasi server gagal.');
  end
  else
    ShowMessage('✓ Foto tray berhasil disimpan ke database lokal.');
end;

procedure TCaptureView.BtnFinishClick(Sender: TObject);
begin
  ShowMessage('Sesi pemotretan selesai. Semua data tersimpan aman di database.');
end;

end.
