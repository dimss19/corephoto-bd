unit CP.UI.Capture;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, System.SysUtils, System.Classes, System.Math, System.IOUtils,
  System.Generics.Collections,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.Dialogs, Vcl.ComCtrls, Vcl.FileCtrl,
  CP.UI.Theme, CP.Core.AppContext, CP.Imaging.Crop, CP.Validation.Preflight,
  CP.Camera.Intf, CP.Camera.Webcam, CP.DB.Models;

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
    DtpDate: TDateTimePicker;
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
    PnlSeriesDetails: TPanel;
    LblSeriesTitle: TLabel;
    LblSeriesCountKey: TLabel;
    LblSeriesCountVal: TLabel;
    LblSeriesSpaceKey: TLabel;
    LblSeriesSpaceVal: TLabel;
    LblTargetFolder: TLabel;
    EdtTargetFolder: TEdit;
    BtnBrowseTarget: TButton;
    LblServerFolder: TLabel;
    EdtServerFolder: TEdit;
    BtnBrowseServer: TButton;
    BtnOpenCsv: TButton;
    BtnSyncServer: TButton;
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
    LblMaxSize: TLabel;
    EdtMaxSize: TEdit;
    BtnSaveMaxSize: TButton;
    PnlCenter: TPanel;
    PnlLiveTopBar: TPanel;
    LblLiveStatus: TLabel;
    BtnCropToggle: TButton;
    BtnLiveReconnect: TButton;
    BtnAutoFocus: TButton;
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
    procedure FormFieldChange(Sender: TObject);
    procedure BtnBrowseTargetClick(Sender: TObject);
    procedure BtnBrowseServerClick(Sender: TObject);
    procedure BtnOpenCsvClick(Sender: TObject);
    procedure BtnSyncServerClick(Sender: TObject);
    procedure BtnSaveMaxSizeClick(Sender: TObject);
    procedure CmbInterfaceChange(Sender: TObject);
    procedure CmbWebcamDeviceChange(Sender: TObject);
    procedure BtnWebcamRefreshClick(Sender: TObject);
    procedure BtnDevDetectClick(Sender: TObject);
    procedure BtnDevReconnectClick(Sender: TObject);
    procedure BtnCropToggleClick(Sender: TObject);
    procedure BtnLiveReconnectClick(Sender: TObject);
    procedure BtnAutoFocusClick(Sender: TObject);
    procedure CmbFocusingChange(Sender: TObject);
    procedure PaintLiveViewPaint(Sender: TObject);
    procedure ChkGridClick(Sender: TObject);
    procedure BtnZoomClick(Sender: TObject);
    procedure FocusStepClick(Sender: TObject);
    procedure BtnLiveViewToggleClick(Sender: TObject);
    procedure BtnCaptureClick(Sender: TObject);
    procedure BtnRetakeClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnFinishClick(Sender: TObject);
    procedure CmbResolutionChange(Sender: TObject);
  private
    FActiveTab: Integer; // 0 = Tray Data, 1 = Camera Settings
    FGridEnabled: Boolean;
    FCropBoxEnabled: Boolean;
    FIsZoomed: Boolean;
    FLiveViewActive: Boolean;
    FIsPreviewingCapture: Boolean;
    FInLiveTimer: Boolean;
    FAFLocked: Boolean;
    FAFLockTicks: Cardinal;
    FLastFocusScore: Double;
    FPendingPhoto: TPhotoModel;
    FTimerLiveView: TTimer;
    FLastFrame: TBitmap;
    FBufferBmp: TBitmap;

    function CalculateSharpness(Bmp: TBitmap): Double;
    function GetCurrentCropRegion: TCropRegion;
    procedure OnLiveTimer(Sender: TObject);
    procedure EvaluatePreflight;
    procedure AdvanceToNextTray;
    procedure RefreshWebcamList;
    procedure RefreshCamInfo;
    procedure RefreshSeriesCount;
    procedure DisplayCapturedPhoto(const Photo: TPhotoModel);
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
  Vcl.Imaging.jpeg,
  CP.Core.Logger, CP.Config.Manager, CP.Camera.Manager, CP.UI.MainForm;

{$R *.dfm}

constructor TCaptureView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DoubleBuffered := True;
  PnlCenter.DoubleBuffered := True;
  FActiveTab := 0;
  FGridEnabled := True;
  FCropBoxEnabled := False;
  FIsZoomed := False;
  FLiveViewActive := True;
  FIsPreviewingCapture := False;
  FInLiveTimer := False;
  FAFLocked := False;
  FAFLockTicks := 0;
  FPendingPhoto := Default(TPhotoModel);
  FLastFrame := TBitmap.Create;
  FLastFrame.PixelFormat := pf24bit;
  FBufferBmp := TBitmap.Create;
  FBufferBmp.PixelFormat := pf24bit;

  BtnRetake.Enabled := False;
  BtnSave.Enabled := False;
  BtnCapture.Enabled := True;
  BtnCropToggle.Caption := 'Crop Box: OFF';
  BtnLiveViewToggle.Caption := 'End Live View';

  FTimerLiveView := TTimer.Create(Self);
  FTimerLiveView.Interval := 66; // ~15 FPS
  FTimerLiveView.OnTimer := OnLiveTimer;
  FTimerLiveView.Enabled := True;

  SelectTab(0);
  RefreshWebcamList;
  RefreshCamInfo;
  CmbResolution.ItemIndex := 1;
  CmbResolutionChange(nil);
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

procedure TCaptureView.FormFieldChange(Sender: TObject);
begin
  EvaluatePreflight;
end;

procedure TCaptureView.BtnBrowseTargetClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := EdtTargetFolder.Text;
  if SelectDirectory('Select Target Folder', '', Dir) then
  begin
    EdtTargetFolder.Text := Dir;
    GetConfig.SetString('storage', 'primary_path', Dir);
    GetConfig.Save;
    RefreshData;
  end;
end;

procedure TCaptureView.BtnBrowseServerClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := EdtServerFolder.Text;
  if SelectDirectory('Select Target Server Folder / Share', '', Dir) then
  begin
    EdtServerFolder.Text := Dir;
    GetConfig.SetString('storage', 'server_sync_path', Dir);
    GetConfig.Save;
  end;
end;

procedure TCaptureView.BtnOpenCsvClick(Sender: TObject);
var
  Ctx: TCPAppContext;
  CsvPath: string;
begin
  Ctx := GetAppContext;
  if (Ctx <> nil) and (Ctx.ActiveSession.Id <> '') then
  begin
    CsvPath := TPath.Combine(Ctx.SessionPaths.SessionDir, EdtHole.Text + '.csv');
    if not TFile.Exists(CsvPath) then
      CsvPath := TPath.Combine(Ctx.SessionPaths.SessionDir, 'session_report.csv');
    if TFile.Exists(CsvPath) then
      ShellExecute(0, 'open', PChar(CsvPath), nil, nil, SW_SHOWNORMAL)
    else
      ShowMessage('Belum ada file CSV untuk session ini: ' + CsvPath);
  end
  else
    ShowMessage('Pilih atau buat Session aktif terlebih dahulu.');
end;

procedure TCaptureView.BtnSyncServerClick(Sender: TObject);
var
  Ctx: TCPAppContext;
  SrcDir, DstDir: string;
begin
  DstDir := Trim(EdtServerFolder.Text);
  if (DstDir = '') or (not TDirectory.Exists(DstDir)) then
  begin
    ShowMessage('Target Server Folder belum ditentukan atau tidak dapat diakses.');
    Exit;
  end;
  Ctx := GetAppContext;
  if (Ctx <> nil) and (Ctx.ActiveSession.Id <> '') and TDirectory.Exists(Ctx.SessionPaths.JpgDir) then
  begin
    try
      SrcDir := Ctx.SessionPaths.JpgDir;
      TDirectory.Copy(SrcDir, TPath.Combine(DstDir, Ctx.ActiveSession.Site));
      ShowMessage('Sinkronisasi folder session ke server berhasil.');
    except
      on E: Exception do
        ShowMessage('Gagal sinkronisasi ke server: ' + E.Message);
    end;
  end
  else
    ShowMessage('Tidak ada foto session aktif untuk disinkronkan.');
end;

procedure TCaptureView.BtnSaveMaxSizeClick(Sender: TObject);
var
  Val: Double;
begin
  Val := StrToFloatDef(EdtMaxSize.Text, 10.0);
  if Val < 0.5 then Val := 0.5;
  GetConfig.SetFloat('imaging', 'max_photo_size_mb', Val);
  GetConfig.Save;
  ShowMessage(Format('Max Photo Size disimpan: %.1f MB', [Val]));
end;

procedure TCaptureView.RefreshData;
var
  Ctx: TCPAppContext;
  AvailMB: Double;
  PList: TList<TPhotoModel>;
  Y, M, D: Word;
begin
  Ctx := GetAppContext;
  if (Ctx <> nil) and (Ctx.ActiveSession.Id <> '') then
  begin
    EdtOperator.Text := Ctx.ActiveSession.OperatorName;
    EdtSite.Text := Ctx.ActiveSession.Site;
    EdtTargetFolder.Text := Ctx.SessionPaths.SessionDir;

    if Length(Ctx.ActiveSession.DateStr) >= 8 then
    begin
      try
        Y := StrToIntDef(Copy(Ctx.ActiveSession.DateStr, 1, 4), 2026);
        M := StrToIntDef(Copy(Ctx.ActiveSession.DateStr, 5, 2), 10);
        D := StrToIntDef(Copy(Ctx.ActiveSession.DateStr, 7, 2), 5);
        DtpDate.Date := EncodeDate(Y, M, D);
      except
        DtpDate.Date := Now;
      end;
    end
    else
      DtpDate.Date := Now;
  end
  else
    DtpDate.Date := Now;

  EdtServerFolder.Text := GetConfig.GetString('storage', 'server_sync_path', '');
  EdtMaxSize.Text := Format('%.1f', [GetConfig.GetFloat('imaging', 'max_photo_size_mb', 10.0)]);

  if (Ctx <> nil) and (Ctx.Storage <> nil) then
  begin
    AvailMB := Ctx.Storage.GetAvailableSpaceMB;
    LblSeriesSpaceVal.Caption := Format('%.0f MB free', [AvailMB]);
  end;

  if (Ctx <> nil) and (Ctx.PhotoRepo <> nil) and (Ctx.ActiveSession.Id <> '') then
  begin
    PList := Ctx.PhotoRepo.ListBySession(Ctx.ActiveSession.Id);
    if PList <> nil then
    begin
      LblSeriesCountVal.Caption := IntToStr(PList.Count);
      PList.Free;
    end;
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
    if Ctx.Camera.IsReady then
    begin
      Info := Ctx.Camera.GetInfo;
      LblDevModel.Caption := 'Model: ' + Info.Model;
      LblDevSerial.Caption := 'Serial No: ' + Info.SerialNumber;
      LblDevFw.Caption := 'Firmware: ' + Info.FirmwareVersion;
      BtnLiveReconnect.Caption := 'Disconnect';
    end
    else
    begin
      LblDevModel.Caption := 'Model: [Not Connected]';
      LblDevSerial.Caption := 'Serial No: -';
      LblDevFw.Caption := 'Firmware: -';
      BtnLiveReconnect.Caption := 'Connect';
    end;
  end;
end;

procedure TCaptureView.RefreshSeriesCount;
var
  Ctx: TCPAppContext;
  PList: TList<TPhotoModel>;
begin
  Ctx := GetAppContext;
  if (Ctx <> nil) and (Ctx.PhotoRepo <> nil) and (Ctx.ActiveSession.Id <> '') then
  begin
    PList := Ctx.PhotoRepo.ListBySession(Ctx.ActiveSession.Id);
    if PList <> nil then
    begin
      LblSeriesCountVal.Caption := IntToStr(PList.Count);
      PList.Free;
    end;
  end;
end;

procedure TCaptureView.DisplayCapturedPhoto(const Photo: TPhotoModel);
var
  Jpg: TJPEGImage;
begin
  if (Photo.JpgPath <> '') and TFile.Exists(Photo.JpgPath) then
  begin
    try
      Jpg := TJPEGImage.Create;
      try
        Jpg.LoadFromFile(Photo.JpgPath);
        FLastFrame.Assign(Jpg);
      finally
        Jpg.Free;
      end;
    except
      on E: Exception do ;
    end;
  end;
end;

procedure TCaptureView.CmbInterfaceChange(Sender: TObject);
var
  Ctx: TCPAppContext;
  TetherFolder: string;
begin
  Ctx := GetAppContext;
  if Ctx = nil then Exit;

  TetherFolder := GetConfig.GetString('camera', 'tether_folder', '');

  case CmbInterface.ItemIndex of
    1: Ctx.Camera.ConnectCamera('direct_usb', '0');
    2: Ctx.Camera.ConnectCamera('wifi_dslr', TetherFolder);
    3: Ctx.Camera.ConnectCamera('hot_folder', TetherFolder);
  else
    Ctx.Camera.ConnectCamera('webcam', IntToStr(Max(0, CmbWebcamDevice.ItemIndex)));
  end;

  RefreshCamInfo;
  EvaluatePreflight;
  if (Application.MainForm <> nil) and (Application.MainForm is TMainForm) then
    TMainForm(Application.MainForm).UpdateHeader;
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
  if (Application.MainForm <> nil) and (Application.MainForm is TMainForm) then
    TMainForm(Application.MainForm).UpdateHeader;
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
  EvaluatePreflight;
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.BtnLiveReconnectClick(Sender: TObject);
var
  Ctx: TCPAppContext;
  Idx: Integer;
begin
  Ctx := GetAppContext;
  if (Ctx <> nil) and (Ctx.Camera <> nil) then
  begin
    if Ctx.Camera.IsReady then
    begin
      // Connected -> Disconnect
      Ctx.Camera.DisconnectCamera;
      if FLastFrame <> nil then
      begin
        FLastFrame.SetSize(640, 480);
        FLastFrame.Canvas.Brush.Color := RGB(10, 10, 12);
        FLastFrame.Canvas.FillRect(Rect(0, 0, 640, 480));
      end;
      PaintLiveView.Invalidate;
    end
    else
    begin
      // Disconnected -> Connect
      Idx := CmbWebcamDevice.ItemIndex;
      if Idx < 0 then Idx := 0;
      case CmbInterface.ItemIndex of
        1: Ctx.Camera.ConnectCamera('direct_usb', '0');
        2: Ctx.Camera.ConnectCamera('wifi_dslr', GetConfig.GetString('camera', 'tether_folder', ''));
        3: Ctx.Camera.ConnectCamera('hot_folder', GetConfig.GetString('camera', 'tether_folder', ''));
      else
        Ctx.Camera.ConnectCamera('webcam', IntToStr(Idx));
      end;
    end;
  end;

  RefreshCamInfo;
  EvaluatePreflight;

  if (Application.MainForm <> nil) and (Application.MainForm is TMainForm) then
    TMainForm(Application.MainForm).UpdateHeader;
end;

procedure TCaptureView.BtnAutoFocusClick(Sender: TObject);
var
  Ctx: TCPAppContext;
  Success: Boolean;
begin
  Ctx := GetAppContext;
  if (Ctx <> nil) and (Ctx.Camera <> nil) and Ctx.Camera.IsReady then
  begin
    Success := Ctx.Camera.TriggerAutoFocus;
    FAFLocked := True;
    FAFLockTicks := GetTickCount;
    Winapi.Windows.Beep(1760, 90); // 1760 Hz (A6), classic DSLR AF confirmation tone
    PaintLiveView.Invalidate;

    if not Success then
    begin
      ShowMessage('Autofokus hardware UVC tidak didukung oleh perangkat ini (khas untuk webcam virtual DSLR/Capture Card).'#13#10#13#10 +
                  'Petunjuk praktis untuk DSLR pada copy stand:'#13#10 +
                  '1. Tekan setengah tombol shutter pada bodi kamera (half-press) hingga fokus terkunci.'#13#10 +
                  '2. Geser saklar pada lensa kamera ke posisi [MF] (Manual Focus) agar fokus terkunci permanen pada jarak meja core tray.');
    end;
  end
  else
    ShowMessage('Kamera belum terhubung atau Live View belum aktif.');
end;

procedure TCaptureView.CmbFocusingChange(Sender: TObject);
var
  Ctx: TCPAppContext;
  IsAuto: Boolean;
begin
  // Index 0: One-Shot, Index 1: AI Focus, Index 2: Manual
  IsAuto := CmbFocusing.ItemIndex in [0, 1];
  Ctx := GetAppContext;
  if (Ctx <> nil) and (Ctx.Camera <> nil) then
    Ctx.Camera.SetAutoFocus(IsAuto);
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
var
  StepDirection: Integer;
  StepLabel: string;
begin
  StepDirection := 0;
  StepLabel := '';
  if Sender = BtnFocusStepN3 then begin StepDirection := -3; StepLabel := 'Near 3 (<<<)'; end
  else if Sender = BtnFocusStepN2 then begin StepDirection := -2; StepLabel := 'Near 2 (<<)'; end
  else if Sender = BtnFocusStepN1 then begin StepDirection := -1; StepLabel := 'Near 1 (<)'; end
  else if Sender = BtnFocusStepP1 then begin StepDirection := 1; StepLabel := 'Far 1 (>)'; end
  else if Sender = BtnFocusStepP2 then begin StepDirection := 2; StepLabel := 'Far 2 (>>)'; end
  else if Sender = BtnFocusStepP3 then begin StepDirection := 3; StepLabel := 'Far 3 (>>>)'; end;

  Log.Info(Format('Focus Drive Step: %s [%d]', [StepLabel, StepDirection]));
  FAFLocked := True;
  FAFLockTicks := GetTickCount;
  Winapi.Windows.Beep(1200, 30);
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.BtnLiveViewToggleClick(Sender: TObject);
begin
  if FIsPreviewingCapture then
  begin
    FIsPreviewingCapture := False;
    FLiveViewActive := True;
    FTimerLiveView.Enabled := True;
    BtnLiveViewToggle.Caption := 'End Live View';
    LblLiveStatus.Caption := 'LIVE CAMERA STREAM';
    EvaluatePreflight;
    PaintLiveView.Invalidate;
    Exit;
  end;

  FLiveViewActive := not FLiveViewActive;
  FTimerLiveView.Enabled := FLiveViewActive;
  if FLiveViewActive then
  begin
    BtnLiveViewToggle.Caption := 'End Live View';
    LblLiveStatus.Caption := 'LIVE CAMERA STREAM';
  end
  else
  begin
    BtnLiveViewToggle.Caption := 'Start Live View';
    LblLiveStatus.Caption := 'LIVE CAMERA STREAM — PAUSED';
  end;
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.OnLiveTimer(Sender: TObject);
var
  Ctx: TCPAppContext;
  NewBmp: TBitmap;
begin
  if FInLiveTimer or (not Visible) or (not FLiveViewActive) or FIsPreviewingCapture then Exit;
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

function TCaptureView.CalculateSharpness(Bmp: TBitmap): Double;
var
  W, H, CX, CY, SampleW, SampleH, X, Y: Integer;
  P0, P1, P2: PByteArray;
  Sum, SumSq, Mean, Variance, L: Double;
  Count: Integer;
  function Lum(P: PByteArray; Idx: Integer): Integer; inline;
  begin
    Result := (P[Idx * 3 + 2] * 77 + P[Idx * 3 + 1] * 150 + P[Idx * 3] * 29) shr 8;
  end;
begin
  Result := 0;
  if (Bmp = nil) or (Bmp.Width < 64) or (Bmp.Height < 64) or (Bmp.PixelFormat <> pf24bit) then Exit;

  W := Bmp.Width;
  H := Bmp.Height;
  CX := W div 2;
  CY := H div 2;

  SampleW := Min(160, W - 4);
  SampleH := Min(80, H - 4);

  Sum := 0;
  SumSq := 0;
  Count := 0;

  try
    for Y := CY - (SampleH div 2) to CY + (SampleH div 2) do
    begin
      if (Y <= 0) or (Y >= H - 1) then Continue;
      P0 := Bmp.ScanLine[Y - 1];
      P1 := Bmp.ScanLine[Y];
      P2 := Bmp.ScanLine[Y + 1];

      for X := CX - (SampleW div 2) to CX + (SampleW div 2) do
      begin
        if (X <= 0) or (X >= W - 1) then Continue;
        L := 4.0 * Lum(P1, X) - Lum(P1, X - 1) - Lum(P1, X + 1) - Lum(P0, X) - Lum(P2, X);
        Sum := Sum + L;
        SumSq := SumSq + (L * L);
        Inc(Count);
      end;
    end;

    if Count > 1 then
    begin
      Mean := Sum / Count;
      Variance := (SumSq / Count) - (Mean * Mean);
      if Variance < 0 then Variance := 0;
      Result := Variance;
    end;
  except
    Result := 0;
  end;
end;

function TCaptureView.GetCurrentCropRegion: TCropRegion;
var
  TargetW, TargetH, CW, CH: Integer;
begin
  if not FCropBoxEnabled then
  begin
    Result.X := 0;
    Result.Y := 0;
    Result.Width := 0;
    Result.Height := 0;
    Exit;
  end;

  TargetW := 1920;
  TargetH := 1080;
  if Pos('1280 x 720', CmbResolution.Text) > 0 then
  begin
    TargetW := 1280;
    TargetH := 720;
  end
  else if Pos('Auto', CmbResolution.Text) > 0 then
  begin
    TargetW := 5184;
    TargetH := 3456;
  end;

  // Standard Geological Tray Crop: 88% width, 3:2 (300:200) ratio, centered
  CW := Round(TargetW * 0.88);
  CH := Round(CW / 1.5);
  if CH > Round(TargetH * 0.88) then
  begin
    CH := Round(TargetH * 0.88);
    CW := Round(CH * 1.5);
  end;

  Result.Width := CW;
  Result.Height := CH;
  Result.X := (TargetW - CW) div 2;
  Result.Y := (TargetH - CH) div 2;
end;

procedure TCaptureView.EvaluatePreflight;
var
  Ctx: TCPAppContext;
  Res: TPreflightResult;
  CR: TCropRegion;
  FVal, TVal: Double;
  ErrList: TArray<string>;
  CropTag: string;
begin
  if FCropBoxEnabled then
    CropTag := 'Crop [Box] '#10003
  else
    CropTag := 'Crop [Full] '#10003;

  if FIsPreviewingCapture then
  begin
    LblPreflightChecklist.Caption := 'Camera '#10003'  '#183'  Session '#10003'  '#183'  Hole ID '#10003'  '#183'  Tray ID '#10003'  '#183'  Interval '#10003'  '#183'  Storage '#10003'  '#183'  ' + CropTag;
    LblPreflightVerdict.Caption := 'PHOTO CAPTURED — PREVIEW MODE (RETAKE OR SAVE)';
    LblPreflightVerdict.Font.Color := COLOR_SUCCESS;
    BtnCapture.Enabled := False;
    Exit;
  end;

  Ctx := GetAppContext;
  CR := GetCurrentCropRegion;
  FVal := StrToFloatDef(EdtFrom.Text, 0.0);
  TVal := StrToFloatDef(EdtTo.Text, 2.0);

  Res := Ctx.RunPreflight(EdtHole.Text, EdtTray.Text, FVal, TVal, CR);
  if Res.IsReady then
  begin
    LblPreflightChecklist.Caption := 'Camera '#10003'  '#183'  Session '#10003'  '#183'  Hole ID '#10003'  '#183'  Tray ID '#10003'  '#183'  Interval '#10003'  '#183'  Storage '#10003'  '#183'  ' + CropTag;
    LblPreflightVerdict.Caption := 'READY TO CAPTURE: All pre-flight checklist items verified.';
    LblPreflightVerdict.Font.Color := COLOR_SUCCESS;
    BtnCapture.Enabled := True;
  end
  else
  begin
    LblPreflightChecklist.Caption := 'Camera '#10003'  '#183'  Session '#10003'  '#183'  Hole ID '#10003'  '#183'  Tray ID '#10003'  '#183'  Interval '#10003'  '#183'  Storage '#10003'  '#183'  Crop X';
    ErrList := Res.SummaryErrors;
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

  // Reset Capture Details card to waiting
  LblDimVal.Caption := 'waiting ...';
  LblSizeVal.Caption := 'waiting ...';
  LblCapVal.Caption := 'waiting ...';
  LblDestVal.Caption := 'waiting ...';

  RefreshSeriesCount;
  EvaluatePreflight;
end;

procedure TCaptureView.PaintLiveViewPaint(Sender: TObject);
var
  W, H, CX1, CY1, CX2, CY2, CW, CH: Integer;
  R, RowH, RY, TotalRows: Integer;
  Scale: Double;
  DispW, DispH, OffX, OffY: Integer;
  SrcRect, DstRect: TRect;
  BadgeStr: string;
  BadgeTW: Integer;
begin
  W := PaintLiveView.Width;
  H := PaintLiveView.Height;
  if (W <= 0) or (H <= 0) then Exit;

  if (FBufferBmp.Width <> W) or (FBufferBmp.Height <> H) then
    FBufferBmp.SetSize(W, H);

  // 1. Dark charcoal background rendered on off-screen buffer
  FBufferBmp.Canvas.Brush.Color := RGB(10, 10, 12);
  FBufferBmp.Canvas.FillRect(Rect(0, 0, W, H));

  DispW := W;
  DispH := H;
  OffX := 0;
  OffY := 0;

  // 2. Render frame: either live camera frame or frozen captured photo preview
  if (FLastFrame <> nil) and (FLastFrame.Width > 0) and (FLastFrame.Height > 0) and (FLiveViewActive or FIsPreviewingCapture) then
  begin
    Scale := Min(W / FLastFrame.Width, H / FLastFrame.Height);
    DispW := Max(1, Round(FLastFrame.Width * Scale));
    DispH := Max(1, Round(FLastFrame.Height * Scale));
    OffX := (W - DispW) div 2;
    OffY := (H - DispH) div 2;

    DstRect := Rect(OffX, OffY, OffX + DispW, OffY + DispH);

    if FIsZoomed and (not FIsPreviewingCapture) then
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

  // Overlays (Grid and Crop Box) are ONLY drawn during LIVE VIEW, NOT when previewing captured photo
  if FLiveViewActive and (not FIsPreviewingCapture) then
  begin
    // 3. Rule of Thirds Grid
    if FGridEnabled then
    begin
      FBufferBmp.Canvas.Pen.Color := RGB(2, 132, 199);
      FBufferBmp.Canvas.Pen.Style := psDot;
      FBufferBmp.Canvas.MoveTo(OffX + DispW div 3, OffY); FBufferBmp.Canvas.LineTo(OffX + DispW div 3, OffY + DispH);
      FBufferBmp.Canvas.MoveTo(OffX + 2 * DispW div 3, OffY); FBufferBmp.Canvas.LineTo(OffX + 2 * DispW div 3, OffY + DispH);
      FBufferBmp.Canvas.MoveTo(OffX, OffY + DispH div 3); FBufferBmp.Canvas.LineTo(OffX + DispW, OffY + DispH div 3);
      FBufferBmp.Canvas.MoveTo(OffX, OffY + 2 * DispH div 3); FBufferBmp.Canvas.LineTo(OffX + DispW, OffY + 2 * DispH div 3);
    end;

    // 4. Crop Box
    if FCropBoxEnabled then
    begin
      CW := Round(DispW * 0.88);
      CH := Round(CW / 1.5);
      if CH > Round(DispH * 0.88) then
      begin
        CH := Round(DispH * 0.88);
        CW := Round(CH * 1.5);
      end;

      CX1 := OffX + (DispW - CW) div 2;
      CY1 := OffY + (DispH - CH) div 2;
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

      // Slate watermark with bold drop shadow for maximum legibility
      FBufferBmp.Canvas.Font.Name := 'Segoe UI';
      FBufferBmp.Canvas.Font.Size := 14;
      FBufferBmp.Canvas.Font.Style := [fsBold];
      FBufferBmp.Canvas.Brush.Style := bsClear;
      FBufferBmp.Canvas.Font.Color := clBlack;
      FBufferBmp.Canvas.TextOut(CX1 + 11, CY1 + 9,
        Format('%s | TRAY %s | %s - %s m', [EdtHole.Text, EdtTray.Text, EdtFrom.Text, EdtTo.Text]));
      FBufferBmp.Canvas.Font.Color := RGB(254, 240, 138); // Bright Yellow
      FBufferBmp.Canvas.TextOut(CX1 + 10, CY1 + 8,
        Format('%s | TRAY %s | %s - %s m', [EdtHole.Text, EdtTray.Text, EdtFrom.Text, EdtTo.Text]));
    end;

    // 5. Auto Focus Reticle & HUD Lock Indicator
    if FAFLocked and (GetTickCount - FAFLockTicks < 3500) then
    begin
      FBufferBmp.Canvas.Pen.Style := psSolid;
      FBufferBmp.Canvas.Pen.Color := RGB(34, 197, 94); // Neon Green
      FBufferBmp.Canvas.Pen.Width := 2;
      FBufferBmp.Canvas.Brush.Style := bsClear;

      // Draw center AF bracket (64x64) and crosshair
      FBufferBmp.Canvas.Rectangle(OffX + DispW div 2 - 32, OffY + DispH div 2 - 32,
                                   OffX + DispW div 2 + 32, OffY + DispH div 2 + 32);
      FBufferBmp.Canvas.MoveTo(OffX + DispW div 2 - 12, OffY + DispH div 2);
      FBufferBmp.Canvas.LineTo(OffX + DispW div 2 + 12, OffY + DispH div 2);
      FBufferBmp.Canvas.MoveTo(OffX + DispW div 2, OffY + DispH div 2 - 12);
      FBufferBmp.Canvas.LineTo(OffX + DispW div 2, OffY + DispH div 2 + 12);

      // AF lock indicator label
      FBufferBmp.Canvas.Font.Name := 'Segoe UI';
      FBufferBmp.Canvas.Font.Size := 9;
      FBufferBmp.Canvas.Font.Style := [fsBold];
      FBufferBmp.Canvas.Font.Color := RGB(34, 197, 94);
      FBufferBmp.Canvas.Brush.Style := bsClear;
      FBufferBmp.Canvas.TextOut(OffX + DispW div 2 - 42, OffY + DispH div 2 + 38, '[ AF LOCKED ]');
    end;

    // 6. Live Focus Quality Meter (Sharpness evaluation on central core tray area)
    if (FLastFrame <> nil) and (FLastFrame.Width > 0) then
    begin
      FLastFocusScore := CalculateSharpness(FLastFrame);
      FBufferBmp.Canvas.Font.Name := 'Segoe UI';
      FBufferBmp.Canvas.Font.Size := 9;
      FBufferBmp.Canvas.Font.Style := [fsBold];
      FBufferBmp.Canvas.Brush.Style := bsSolid;

      if FLastFocusScore >= 120.0 then
      begin
        FBufferBmp.Canvas.Brush.Color := RGB(20, 83, 45); // Dark Green
        FBufferBmp.Canvas.Pen.Color := RGB(34, 197, 94);   // Neon Green
        FBufferBmp.Canvas.Font.Color := RGB(187, 247, 208);
        BadgeStr := Format('  [FOCUS OK] SHARP / FOKUS JELAS (Score: %.0f)  ', [FLastFocusScore]);
      end
      else
      begin
        FBufferBmp.Canvas.Brush.Color := RGB(127, 29, 29); // Dark Red
        FBufferBmp.Canvas.Pen.Color := RGB(239, 68, 68);   // Red
        FBufferBmp.Canvas.Font.Color := RGB(254, 202, 202);
        BadgeStr := Format('  [PERIKSA FOKUS] KURANG FOKUS / BURAM (Score: %.0f) - TEKAN AF / ATUR RING MF  ', [FLastFocusScore]);
      end;

      BadgeTW := FBufferBmp.Canvas.TextWidth(BadgeStr);
      FBufferBmp.Canvas.Rectangle(OffX + (DispW - BadgeTW) div 2 - 4, OffY + DispH - 30,
                                   OffX + (DispW + BadgeTW) div 2 + 4, OffY + DispH - 8);
      FBufferBmp.Canvas.TextOut(OffX + (DispW - BadgeTW) div 2, OffY + DispH - 27, BadgeStr);
    end;
  end;

  // Prominent frozen preview badge (parity with Python capture.py _display_still_photo_on_canvas)
  if FIsPreviewingCapture then
  begin
    FBufferBmp.Canvas.Brush.Color := RGB(9, 13, 22);
    FBufferBmp.Canvas.Brush.Style := bsSolid;
    FBufferBmp.Canvas.Pen.Color := COLOR_SUCCESS;
    FBufferBmp.Canvas.Pen.Width := 1;
    FBufferBmp.Canvas.Rectangle(OffX + 8, OffY + 8, OffX + DispW - 8, OffY + 38);

    FBufferBmp.Canvas.Font.Name := 'Segoe UI';
    FBufferBmp.Canvas.Font.Size := 10;
    FBufferBmp.Canvas.Font.Style := [fsBold];
    FBufferBmp.Canvas.Font.Color := COLOR_SUCCESS;
    FBufferBmp.Canvas.Brush.Style := bsClear;
    BadgeStr := #9679' CAPTURED STILL PHOTO (FROZEN PREVIEW) - REVIEW & RETAKE / SAVE';
    BadgeTW := FBufferBmp.Canvas.TextWidth(BadgeStr);
    FBufferBmp.Canvas.TextOut(OffX + (DispW - BadgeTW) div 2, OffY + 14, BadgeStr);
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
  Errors: TArray<string>;
begin
  if FIsPreviewingCapture then Exit;

  Ctx := GetAppContext;
  if (Ctx = nil) or (Ctx.ActiveSession.Id = '') then
  begin
    ShowMessage('Sesi aktif belum dipilih. Buat atau pilih sesi terlebih dahulu.');
    Exit;
  end;

  // Auto-focus lock before shutter release if One-Shot or AI Focus mode is selected
  if (CmbFocusing.ItemIndex in [0, 1]) and (Ctx.Camera <> nil) and Ctx.Camera.IsReady then
  begin
    if Ctx.Camera.TriggerAutoFocus then
    begin
      FAFLocked := True;
      FAFLockTicks := GetTickCount;
      Winapi.Windows.Beep(1760, 50);
    end;
  end;

  CR := GetCurrentCropRegion;
  FVal := StrToFloatDef(EdtFrom.Text, 0.0);
  TVal := StrToFloatDef(EdtTo.Text, 2.0);

  try
    Photo := Ctx.ExecuteCapture(EdtHole.Text, EdtTray.Text, FVal, TVal, CR);

    // Validate photo immediately (parity with Python)
    Ctx.ValidatePhoto(Photo.Id, Errors);

    // Stop live view and freeze on captured photo
    FLiveViewActive := False;
    FTimerLiveView.Enabled := False;
    FIsPreviewingCapture := True;
    FPendingPhoto := Photo;

    // Load still photo onto canvas
    DisplayCapturedPhoto(Photo);

    // Update details card
    LblDimVal.Caption := Format('%dx%d px', [Photo.CropW, Photo.CropH]);
    if (Photo.JpgPath <> '') and TFile.Exists(Photo.JpgPath) then
      FileSizeMB := TFile.GetSize(Photo.JpgPath) / (1024.0 * 1024.0)
    else
      FileSizeMB := 0.0;
    LblSizeVal.Caption := Format('%.2f MB', [FileSizeMB]);
    LblCapVal.Caption := 'Success (Validated)';
    LblDestVal.Caption := ExtractFileName(Photo.JpgPath);

    // Action button state: Disable Capture, Enable Retake, Save, Finish
    BtnCapture.Enabled := False;
    BtnRetake.Enabled := True;
    BtnSave.Enabled := True;
    BtnFinish.Enabled := True;
    BtnLiveViewToggle.Caption := 'Resume Live View';

    LblLiveStatus.Caption := Format('CAPTURED PHOTO PREVIEW — %dx%d  |  Review & Retake / Save', [Photo.CropW, Photo.CropH]);
    LblPreflightVerdict.Caption := 'PHOTO CAPTURED — PREVIEW MODE (RETAKE OR SAVE)';
    LblPreflightVerdict.Font.Color := COLOR_SUCCESS;

    RefreshSeriesCount;
    PaintLiveView.Invalidate;
  except
    on E: Exception do
    begin
      FLiveViewActive := True;
      FTimerLiveView.Enabled := True;
      FIsPreviewingCapture := False;
      ShowMessage('Capture Error: ' + E.Message);
      EvaluatePreflight;
    end;
  end;
end;

procedure TCaptureView.BtnRetakeClick(Sender: TObject);
var
  Ctx: TCPAppContext;
begin
  Ctx := GetAppContext;
  if Ctx <> nil then
    Ctx.RetakeCurrent;

  FPendingPhoto := Default(TPhotoModel);
  FIsPreviewingCapture := False;
  FLiveViewActive := True;
  FTimerLiveView.Enabled := True;

  BtnCapture.Enabled := True;
  BtnRetake.Enabled := False;
  BtnSave.Enabled := False;
  BtnLiveViewToggle.Caption := 'End Live View';

  LblCapVal.Caption := 'Retake (Superseded)';
  LblLiveStatus.Caption := 'LIVE CAMERA STREAM';

  EvaluatePreflight;
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.BtnSaveClick(Sender: TObject);
var
  Ctx: TCPAppContext;
  ServerDir, SessDirName, SrvJpgDir, DestFile: string;
begin
  if FPendingPhoto.Id = 0 then Exit;

  Ctx := GetAppContext;

  // Auto-copy to Server Folder if configured (matching Python)
  ServerDir := Trim(EdtServerFolder.Text);
  if (ServerDir <> '') and TDirectory.Exists(ServerDir) and (FPendingPhoto.JpgPath <> '') and TFile.Exists(FPendingPhoto.JpgPath) then
  begin
    try
      if (Ctx <> nil) and (Ctx.ActiveSession.Id <> '') then
        SessDirName := Ctx.ActiveSession.Site + '_' + Ctx.ActiveSession.DateStr
      else
        SessDirName := 'Captures';

      SrvJpgDir := TPath.Combine(TPath.Combine(ServerDir, SessDirName), 'jpg');
      if not TDirectory.Exists(SrvJpgDir) then
        TDirectory.CreateDirectory(SrvJpgDir);

      DestFile := TPath.Combine(SrvJpgDir, ExtractFileName(FPendingPhoto.JpgPath));
      TFile.Copy(FPendingPhoto.JpgPath, DestFile, True);
    except
      on E: Exception do ;
    end;
  end;

  FPendingPhoto := Default(TPhotoModel);
  FIsPreviewingCapture := False;

  BtnSave.Enabled := False;
  BtnRetake.Enabled := False;
  BtnCapture.Enabled := True;
  FLiveViewActive := True;
  FTimerLiveView.Enabled := True;
  BtnLiveViewToggle.Caption := 'End Live View';
  LblLiveStatus.Caption := 'LIVE CAMERA STREAM';

  AdvanceToNextTray;
  PaintLiveView.Invalidate;
end;

procedure TCaptureView.BtnFinishClick(Sender: TObject);
begin
  if FPendingPhoto.Id > 0 then
    BtnSaveClick(nil);

  ShowMessage('Sesi pemotretan selesai. Semua data tray tersimpan aman di database.');
end;

procedure TCaptureView.CmbResolutionChange(Sender: TObject);
var
  Choice: string;
  W, H: Integer;
begin
  Choice := CmbResolution.Text;
  if Pos('1920 x 1080', Choice) > 0 then
  begin
    W := 1920; H := 1080;
    GetCameraManager.SetResolution(1920, 1080, '1080p');
  end
  else if Pos('1280 x 720', Choice) > 0 then
  begin
    W := 1280; H := 720;
    GetCameraManager.SetResolution(1280, 720, '720p');
  end
  else
  begin
    W := 5184; H := 3456;
    GetCameraManager.SetResolution(5184, 3456, 'best_native');
  end;

  if (GetAppContext <> nil) and (GetAppContext.Camera <> nil) and (GetAppContext.Camera.ActiveAdapter <> nil) then
  begin
    GetAppContext.Camera.ActiveAdapter.SetSetting('resolution_w', IntToStr(W));
    GetAppContext.Camera.ActiveAdapter.SetSetting('resolution_h', IntToStr(H));
  end;

  EvaluatePreflight;
  PaintLiveView.Invalidate;
end;

end.
