unit CP.UI.DataHub;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, CP.UI.Theme, CP.Core.AppContext;

type
  TDataHubView = class(TFrame)
    PnlRoot: TPanel;
    PnlActiveCard: TPanel;
    LblActiveTitle: TLabel;
    LblActiveDetails: TLabel;
    BtnBackToCapture: TButton;
    BtnEditSession: TButton;
    PnlCreateForm: TPanel;
    LblCreateTitle: TLabel;
    LblSite: TLabel;
    EdtSite: TEdit;
    LblOperator: TLabel;
    EdtOperator: TEdit;
    LblDate: TLabel;
    EdtDate: TEdit;
    BtnPickDate: TButton;
    BtnCreateSession: TButton;
    PnlArchive: TPanel;
    LblArchiveTitle: TLabel;
    LstSessions: TListBox;
    BtnOpenSession: TButton;
    BtnDeleteSession: TButton;
    procedure BtnBackToCaptureClick(Sender: TObject);
    procedure BtnCreateSessionClick(Sender: TObject);
    procedure BtnOpenSessionClick(Sender: TObject);
    procedure BtnDeleteSessionClick(Sender: TObject);
    procedure BtnPickDateClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure RefreshData;
  end;

implementation

uses
  CP.UI.DatePicker;

{$R *.dfm}

constructor TDataHubView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RefreshData;
end;

procedure TDataHubView.RefreshData;
var
  Ctx: TCPAppContext;
  Sessions: TArray<string>;
  I: Integer;
begin
  Ctx := GetAppContext;
  if Ctx.ActiveSession.Id <> '' then
  begin
    LblActiveTitle.Caption := 'ACTIVE SESSION: ' + Ctx.ActiveSession.Site;
    LblActiveDetails.Caption := Format('Site: %s  |  Operator: %s  |  Date: %s',
      [Ctx.ActiveSession.Site, Ctx.ActiveSession.OperatorName, Ctx.ActiveSession.DateStr]);
  end
  else
  begin
    LblActiveTitle.Caption := 'ACTIVE SESSION: [None]';
    LblActiveDetails.Caption := 'No active borehole logging session loaded.';
  end;

  LstSessions.Items.Clear;
  Sessions := Ctx.ListAvailableSessions;
  for I := 0 to High(Sessions) do
    LstSessions.Items.Add(Sessions[I]);
end;

procedure TDataHubView.BtnBackToCaptureClick(Sender: TObject);
begin
  // Parent MainForm navigation
end;

procedure TDataHubView.BtnCreateSessionClick(Sender: TObject);
var
  Site, Op, Dt: string;
begin
  Site := Trim(EdtSite.Text);
  Op := Trim(EdtOperator.Text);
  Dt := Trim(EdtDate.Text);
  if (Site = '') or (Dt = '') then
  begin
    ShowMessage('Site dan Date wajib diisi.');
    Exit;
  end;
  GetAppContext.CreateNewSession(Site, Op, Dt);
  RefreshData;
end;

procedure TDataHubView.BtnOpenSessionClick(Sender: TObject);
var
  Sel: string;
begin
  if LstSessions.ItemIndex < 0 then Exit;
  Sel := LstSessions.Items[LstSessions.ItemIndex];
  GetAppContext.OpenSession(Sel);
  RefreshData;
end;

procedure TDataHubView.BtnDeleteSessionClick(Sender: TObject);
var
  Sel: string;
begin
  if LstSessions.ItemIndex < 0 then Exit;
  Sel := LstSessions.Items[LstSessions.ItemIndex];
  GetAppContext.DeleteSession(Sel);
  RefreshData;
end;

procedure TDataHubView.BtnPickDateClick(Sender: TObject);
var
  DStr: string;
begin
  if TDatePickerModal.PickDate(DStr) then
    EdtDate.Text := DStr;
end;

end.
