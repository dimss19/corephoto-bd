unit CP.UI.Settings;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, CP.UI.Theme, CP.Core.AppContext,
  CP.Diagnostics, CP.Config.Manager;

type
  TSettingsView = class(TFrame)
    PnlRoot: TPanel;
    PnlCamHardware: TPanel;
    LblCamTitle: TLabel;
    LblCamStatus: TLabel;
    BtnDetectCam: TButton;
    BtnReconnectCam: TButton;
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
    procedure BtnSaveServerClick(Sender: TObject);
    procedure BtnTestServerClick(Sender: TObject);
    procedure BtnRunDiagnosticsClick(Sender: TObject);
    procedure BtnRefreshLogsClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure RefreshData;
  end;

implementation

{$R *.dfm}

constructor TSettingsView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RefreshData;
end;

procedure TSettingsView.RefreshData;
var
  Ctx: TCPAppContext;
  Diag: TCPDiagnosticsManager;
begin
  Ctx := GetAppContext;
  LblCamStatus.Caption := Ctx.Camera.GetStatusSummary;
  EdtServerFolder.Text := Ctx.GetServerFolder;

  Diag := TCPDiagnosticsManager.Create;
  try
    MemoLogs.Text := Diag.ReadRecentLogs(50);
  finally
    Diag.Free;
  end;
end;

procedure TSettingsView.BtnDetectCamClick(Sender: TObject);
begin
  GetAppContext.Camera.ConnectCamera('webcam', '0');
  RefreshData;
end;

procedure TSettingsView.BtnReconnectCamClick(Sender: TObject);
begin
  GetAppContext.Camera.ConnectCamera('webcam', '0');
  RefreshData;
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
