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
    PnlBottomBar: TPanel;
    LblBottomStatus: TLabel;
    LblBottomDb: TLabel;
    PnlContent: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure BtnHeaderSessionClick(Sender: TObject);
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

  try
    FCaptureView := TCaptureView.Create(Self);
    FCaptureView.Parent := PnlContent;
    FCaptureView.Align := alClient;
  except
    FCaptureView := nil;
  end;

  try
    FReviewView := TReviewView.Create(Self);
    FReviewView.Parent := PnlContent;
    FReviewView.Align := alClient;
    FReviewView.Visible := False;
  except
    FReviewView := nil;
  end;

  try
    FDataHubView := TDataHubView.Create(Self);
    FDataHubView.Parent := PnlContent;
    FDataHubView.Align := alClient;
    FDataHubView.Visible := False;
  except
    FDataHubView := nil;
  end;

  try
    FSettingsView := TSettingsView.Create(Self);
    FSettingsView.Parent := PnlContent;
    FSettingsView.Align := alClient;
    FSettingsView.Visible := False;
  except
    FSettingsView := nil;
  end;

  NavigateTo('capture');
  UpdateHeader;
end;

procedure TMainForm.NavigateTo(const Route: string);
var
  R: string;
begin
  R := LowerCase(Trim(Route));
  if Assigned(FCaptureView) then FCaptureView.Visible := (R = 'capture') or (R = 'dashboard');
  if Assigned(FReviewView) then FReviewView.Visible := (R = 'review') or (R = 'browser');
  if Assigned(FDataHubView) then FDataHubView.Visible := (R = 'data') or (R = 'session');
  if Assigned(FSettingsView) then FSettingsView.Visible := (R = 'settings') or (R = 'diagnostics');

  if Assigned(FCaptureView) and FCaptureView.Visible then FCaptureView.RefreshData;
  if Assigned(FReviewView) and FReviewView.Visible then FReviewView.RefreshData;
  if Assigned(FDataHubView) and FDataHubView.Visible then FDataHubView.RefreshData;
  if Assigned(FSettingsView) and FSettingsView.Visible then FSettingsView.RefreshData;

  UpdateHeader;
end;

procedure TMainForm.UpdateHeader;
var
  Ctx: TCPAppContext;
  AvailGB: Double;
begin
  try
    Ctx := GetAppContext;
    if (Ctx <> nil) and (Ctx.ActiveSession.Id <> '') then
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

    if (Ctx <> nil) and (Ctx.Camera <> nil) and Ctx.Camera.IsReady then
    begin
      LblHeaderCamera.Caption := '● Connected';
      LblHeaderCamera.Font.Color := COLOR_SUCCESS;
    end
    else
    begin
      LblHeaderCamera.Caption := '● Disconnected';
      LblHeaderCamera.Font.Color := COLOR_ERROR;
    end;

    if (Ctx <> nil) and (Ctx.Storage <> nil) then
    begin
      AvailGB := Ctx.Storage.GetAvailableSpaceMB / 1024.0;
      LblHeaderStorage.Caption := Format('Storage: %.1f GB', [AvailGB]);
    end;
  except
    on E: Exception do ;
  end;
end;

procedure TMainForm.BtnHeaderSessionClick(Sender: TObject);
begin
  if Assigned(FDataHubView) and FDataHubView.Visible then
    NavigateTo('capture')
  else
    NavigateTo('data');
end;

end.
