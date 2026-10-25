unit CP.UI.MainForm;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, CP.UI.Theme, CP.Core.AppContext,
  CP.UI.Capture, CP.UI.Review, CP.UI.DataHub, CP.UI.Settings;

type
  TMainForm = class(TForm)
    PnlTopBar: TPanel;
    LblBrand: TLabel;
    PnlStatusSection: TPanel;
    BtnHeaderSession: TButton;
    LblHeaderCamera: TLabel;
    LblHeaderStorage: TLabel;
    BtnHeaderSettings: TButton;
    PnlBottomBar: TPanel;
    LblBottomStatus: TLabel;
    LblBottomDb: TLabel;
    PnlContent: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure BtnHeaderSessionClick(Sender: TObject);
    procedure BtnHeaderSettingsClick(Sender: TObject);
  private
    FCaptureView: TCaptureView;
    FReviewView: TReviewView;
    FDataHubView: TDataHubView;
    FSettingsView: TSettingsView;
    procedure UpdateHeader;
  public
    procedure NavigateTo(const Route: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Color := COLOR_BG;

  // Initialize Views inside content panel
  FCaptureView := TCaptureView.Create(Self);
  FCaptureView.Parent := PnlContent;
  FCaptureView.Align := alClient;

  FReviewView := TReviewView.Create(Self);
  FReviewView.Parent := PnlContent;
  FReviewView.Align := alClient;
  FReviewView.Visible := False;

  FDataHubView := TDataHubView.Create(Self);
  FDataHubView.Parent := PnlContent;
  FDataHubView.Align := alClient;
  FDataHubView.Visible := False;

  FSettingsView := TSettingsView.Create(Self);
  FSettingsView.Parent := PnlContent;
  FSettingsView.Align := alClient;
  FSettingsView.Visible := False;

  NavigateTo('capture');
  UpdateHeader;
end;

procedure TMainForm.NavigateTo(const Route: string);
var
  R: string;
begin
  R := LowerCase(Trim(Route));
  FCaptureView.Visible := (R = 'capture') or (R = 'dashboard');
  FReviewView.Visible := (R = 'review') or (R = 'browser');
  FDataHubView.Visible := (R = 'data') or (R = 'session');
  FSettingsView.Visible := (R = 'settings') or (R = 'diagnostics');

  if FCaptureView.Visible then FCaptureView.RefreshData;
  if FReviewView.Visible then FReviewView.RefreshData;
  if FDataHubView.Visible then FDataHubView.RefreshData;
  if FSettingsView.Visible then FSettingsView.RefreshData;

  UpdateHeader;
end;

procedure TMainForm.UpdateHeader;
var
  Ctx: TCPAppContext;
  AvailGB: Double;
begin
  Ctx := GetAppContext;
  if Ctx.ActiveSession.Id <> '' then
  begin
    BtnHeaderSession.Caption := 'Session: ' + Ctx.ActiveSession.Site;
    LblBottomStatus.Caption := Format('Session: %s  |  Operator: %s  |  Date: %s',
      [Ctx.ActiveSession.Site, Ctx.ActiveSession.OperatorName, Ctx.ActiveSession.DateStr]);
  end
  else
  begin
    BtnHeaderSession.Caption := 'Session: [None]';
    LblBottomStatus.Caption := 'No active session | Click "Session" in header to select';
  end;

  if Ctx.Camera.IsReady then
  begin
    LblHeaderCamera.Caption := '● Connected';
    LblHeaderCamera.Font.Color := COLOR_SUCCESS;
  end
  else
  begin
    LblHeaderCamera.Caption := '● Disconnected';
    LblHeaderCamera.Font.Color := COLOR_ERROR;
  end;

  AvailGB := Ctx.Storage.GetAvailableSpaceMB / 1024.0;
  LblHeaderStorage.Caption := Format('Storage: %.1f GB', [AvailGB]);
end;

procedure TMainForm.BtnHeaderSessionClick(Sender: TObject);
begin
  if FDataHubView.Visible then
    NavigateTo('capture')
  else
    NavigateTo('data');
end;

procedure TMainForm.BtnHeaderSettingsClick(Sender: TObject);
begin
  if FSettingsView.Visible then
    NavigateTo('capture')
  else
    NavigateTo('settings');
end;

end.
