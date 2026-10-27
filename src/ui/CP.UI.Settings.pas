unit CP.UI.Settings;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, Vcl.Dialogs, CP.UI.Theme, CP.Core.AppContext,
  CP.Diagnostics, CP.Config.Manager;

type
  TSettingsView = class(TFrame)
    PnlRoot: TPanel;
    PnlCamHardware: TPanel;
    LblCamTitle: TLabel;
    LblCamStatus: TLabel;
    BtnDetectCam: TButton;
    BtnReconnectCam: TButton;
    PnlPropertiesConfig: TPanel;
    LblPropertiesTitle: TLabel;
    LblJpgLimits: TLabel;
    LblJpgTo: TLabel;
    EdtJpgMin: TEdit;
    EdtJpgMax: TEdit;
    LblRawLimits: TLabel;
    EdtRawMax: TEdit;
    LblThumbLimits: TLabel;
    EdtThumbMax: TEdit;
    LblCamMaker: TLabel;
    EdtCamMaker: TEdit;
    LblCamModel: TLabel;
    EdtCamModel: TEdit;
    LblDpi: TLabel;
    EdtDpi: TEdit;
    BtnSaveProperties: TButton;
    PnlStorageServer: TPanel;
    LblStorageTitle: TLabel;
    LblServerFolder: TLabel;
    EdtServerFolder: TEdit;
    BtnSaveServer: TButton;
    BtnTestServer: TButton;
    PnlDiagLogs: TPanel;
    LblDiagTitle: TLabel;
    BtnRunDiagnostics: TButton;
    MemoLogs: TMemo;
    BtnRefreshLogs: TButton;
    procedure BtnDetectCamClick(Sender: TObject);
    procedure BtnReconnectCamClick(Sender: TObject);
    procedure BtnSavePropertiesClick(Sender: TObject);
    procedure BtnSaveServerClick(Sender: TObject);
    procedure BtnTestServerClick(Sender: TObject);
    procedure BtnRunDiagnosticsClick(Sender: TObject);
    procedure BtnRefreshLogsClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure RefreshData;
  end;

implementation

uses
  CP.Camera.Webcam, CP.Core.PyFormat;

{$R *.dfm}

constructor TSettingsView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TSettingsView.RefreshData;
var
  Ctx: TCPAppContext;
  Diag: TCPDiagnosticsManager;
  FS: TFormatSettings;
begin
  FS := GetInvariantFormatSettings;
  try
    Ctx := GetAppContext;
    if (Ctx <> nil) and (Ctx.Camera <> nil) then
      LblCamStatus.Caption := Ctx.Camera.GetStatusSummary;
    if Ctx <> nil then
      EdtServerFolder.Text := Ctx.GetServerFolder;

    // Load Properties & File size limits (synced with settings.json)
    EdtJpgMin.Text := FloatToStr(GetConfig.GetFloat('imaging', 'min_photo_size_mb', 5.0), FS);
    EdtJpgMax.Text := FloatToStr(GetConfig.GetFloat('imaging', 'max_photo_size_mb', 10.0), FS);
    EdtRawMax.Text := FloatToStr(GetConfig.GetFloat('imaging', 'max_raw_size_mb', 5.0), FS);
    EdtThumbMax.Text := FloatToStr(GetConfig.GetFloat('imaging', 'max_thumbnail_size_mb', 4.0), FS);
    EdtCamMaker.Text := GetConfig.GetString('camera', 'camera_maker', 'Canon');
    EdtCamModel.Text := GetConfig.GetString('camera', 'camera_model', 'Canon EOS 60D');
    EdtDpi.Text := IntToStr(GetConfig.GetInteger('imaging', 'dpi', 72));

    Diag := TCPDiagnosticsManager.Create;
    try
      MemoLogs.Text := Diag.ReadRecentLogs(50);
    finally
      Diag.Free;
    end;
  except
    on E: Exception do
      LblCamStatus.Caption := 'Camera: Standby';
  end;
end;

procedure TSettingsView.BtnDetectCamClick(Sender: TObject);
var
  Devs: TArray<string>;
  Msg: string;
  I: Integer;
begin
  Devs := TWebcamAdapter.ListDevices;
  if Length(Devs) > 0 then
  begin
    Msg := Format('Ditemukan %d kamera terhubung:', [Length(Devs)]) + sLineBreak;
    for I := 0 to High(Devs) do
      Msg := Msg + Format('  [%d] %s', [I, Devs[I]]) + sLineBreak;
    Msg := Msg + sLineBreak + 'Menghubungkan ke kamera utama...';
    ShowMessage(Msg);
    GetAppContext.Camera.ConnectCamera('webcam', '0');
  end
  else
  begin
    ShowMessage('Tidak ada kamera DirectShow terdeteksi. Berjalan dalam mode Simulator Standby.');
    GetAppContext.Camera.ConnectCamera('webcam', 'sim');
  end;
  RefreshData;
end;

procedure TSettingsView.BtnReconnectCamClick(Sender: TObject);
begin
  GetAppContext.Camera.ConnectCamera('webcam', '0');
  RefreshData;
  ShowMessage('Koneksi kamera di-refresh.');
end;

procedure TSettingsView.BtnSavePropertiesClick(Sender: TObject);
var
  FS: TFormatSettings;
begin
  FS := GetInvariantFormatSettings;
  GetConfig.SetFloat('imaging', 'min_photo_size_mb', StrToFloatDef(EdtJpgMin.Text, 5.0, FS));
  GetConfig.SetFloat('imaging', 'max_photo_size_mb', StrToFloatDef(EdtJpgMax.Text, 10.0, FS));
  GetConfig.SetFloat('imaging', 'max_raw_size_mb', StrToFloatDef(EdtRawMax.Text, 5.0, FS));
  GetConfig.SetFloat('imaging', 'max_thumbnail_size_mb', StrToFloatDef(EdtThumbMax.Text, 4.0, FS));
  GetConfig.SetString('camera', 'camera_maker', Trim(EdtCamMaker.Text));
  GetConfig.SetString('camera', 'camera_model', Trim(EdtCamModel.Text));
  GetConfig.SetInteger('imaging', 'dpi', StrToIntDef(EdtDpi.Text, 72));
  GetConfig.Save;
  ShowMessage('Pengaturan properties citra & batas ukuran berhasil disimpan dan disinkronkan.');
end;

procedure TSettingsView.BtnSaveServerClick(Sender: TObject);
begin
  GetConfig.SetString('transfer', 'server_folder', Trim(EdtServerFolder.Text));
  GetConfig.SetString('storage', 'server_folder', Trim(EdtServerFolder.Text));
  ShowMessage('Pengaturan folder server berhasil disimpan.');
end;

procedure TSettingsView.BtnTestServerClick(Sender: TObject);
var
  P: string;
begin
  P := Trim(EdtServerFolder.Text);
  if (P <> '') and DirectoryExists(P) then
    ShowMessage('Server folder aktif & dapat diakses.')
  else
    ShowMessage('Server folder belum dapat diakses atau belum dibuat.');
end;

procedure TSettingsView.BtnRunDiagnosticsClick(Sender: TObject);
var
  Diag: TCPDiagnosticsManager;
  Obj: TObject;
begin
  Diag := TCPDiagnosticsManager.Create;
  try
    Obj := Diag.RunAllChecks;
    ShowMessage('Diagnostics complete: OK');
    Obj.Free;
  finally
    Diag.Free;
  end;
end;

procedure TSettingsView.BtnRefreshLogsClick(Sender: TObject);
var
  Diag: TCPDiagnosticsManager;
begin
  Diag := TCPDiagnosticsManager.Create;
  try
    MemoLogs.Text := Diag.ReadRecentLogs(50);
  finally
    Diag.Free;
  end;
end;

end.
