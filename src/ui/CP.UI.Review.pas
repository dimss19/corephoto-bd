unit CP.UI.Review;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, Vcl.Dialogs, Vcl.Imaging.jpeg, CP.UI.Theme, CP.Core.AppContext, CP.DB.Models;

type
  TReviewView = class(TFrame)
    PnlRoot: TPanel;
    PnlTopNav: TPanel;
    BtnInspectTab: TButton;
    BtnCatalogTab: TButton;
    PnlInspect: TPanel;
    ImgPreview: TImage;
    PnlInspectSidebar: TPanel;
    LblInspectTitle: TLabel;
    LblHoleVal: TLabel;
    LblTrayVal: TLabel;
    LblDepthVal: TLabel;
    LblStatusVal: TLabel;
    BtnApproveNext: TButton;
    BtnSyncServer: TButton;
    BtnRetake: TButton;
    PnlCatalog: TPanel;
    EdtSearch: TEdit;
    LstPhotos: TListBox;
    BtnRefreshCatalog: TButton;
    procedure BtnInspectTabClick(Sender: TObject);
    procedure BtnCatalogTabClick(Sender: TObject);
    procedure BtnApproveNextClick(Sender: TObject);
    procedure BtnSyncServerClick(Sender: TObject);
    procedure BtnRetakeClick(Sender: TObject);
    procedure LstPhotosClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure RefreshData;
  end;

implementation

{$R *.dfm}

constructor TReviewView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  PnlInspect.Visible := True;
  PnlCatalog.Visible := False;
end;

procedure TReviewView.RefreshData;
var
  Ctx: TCPAppContext;
  P, Ph: TPhotoModel;
  AllPhotos: TList<TPhotoModel>;
begin
  Ctx := GetAppContext;
  P := Ctx.LastPhoto;
  if P.Id > 0 then
  begin
    LblHoleVal.Caption := 'Hole ID: ' + P.HoleId;
    LblTrayVal.Caption := 'Tray Number: ' + P.TrayNumber;
    LblDepthVal.Caption := Format('Depth: %.2f - %.2f m', [P.IntervalFrom, P.IntervalTo]);
    LblStatusVal.Caption := 'Status: ' + P.Status;
    if (P.JpgPath <> '') and FileExists(P.JpgPath) then
    begin
      try
        ImgPreview.Picture.LoadFromFile(P.JpgPath);
      except
      end;
    end;
  end;

  if (Ctx.ActiveSession.Id <> '') and (Ctx.PhotoRepo <> nil) then
  begin
    LstPhotos.Items.Clear;
    AllPhotos := Ctx.PhotoRepo.ListBySession(Ctx.ActiveSession.Id);
    try
      for Ph in AllPhotos do
        LstPhotos.Items.Add(Format('%s — Tray %s (%.2f-%.2f m) [%s]',
          [Ph.HoleId, Ph.TrayNumber, Ph.IntervalFrom, Ph.IntervalTo, Ph.Status]));
    finally
      AllPhotos.Free;
    end;
  end;
end;

procedure TReviewView.BtnInspectTabClick(Sender: TObject);
begin
  PnlInspect.Visible := True;
  PnlCatalog.Visible := False;
end;

procedure TReviewView.BtnCatalogTabClick(Sender: TObject);
begin
  PnlInspect.Visible := False;
  PnlCatalog.Visible := True;
end;

procedure TReviewView.BtnApproveNextClick(Sender: TObject);
var
  Ctx: TCPAppContext;
begin
  Ctx := GetAppContext;
  if Ctx.LastPhoto.Id > 0 then
    Ctx.TransferPhotoToServerFolder(Ctx.LastPhoto);
  ShowMessage('Foto disetujui & ditransfer. Siap untuk tray berikutnya.');
end;

procedure TReviewView.BtnSyncServerClick(Sender: TObject);
var
  Cnt: Integer;
begin
  if GetAppContext.SyncSessionToServerFolder('', Cnt) then
    ShowMessage(Format('Berhasil sinkronisasi %d foto ke folder server.', [Cnt]))
  else
    ShowMessage('Gagal sinkronisasi folder server.');
end;

procedure TReviewView.BtnRetakeClick(Sender: TObject);
begin
  GetAppContext.RetakeCurrent;
  ShowMessage('Foto sebelumnya ditandai SUPERSEDED untuk retake.');
end;

procedure TReviewView.LstPhotosClick(Sender: TObject);
var
  Ctx: TCPAppContext;
  AllPhotos: TList<TPhotoModel>;
  Idx: Integer;
  P: TPhotoModel;
begin
  Idx := LstPhotos.ItemIndex;
  if Idx < 0 then Exit;
  Ctx := GetAppContext;
  if (Ctx.ActiveSession.Id <> '') and (Ctx.PhotoRepo <> nil) then
  begin
    AllPhotos := Ctx.PhotoRepo.ListBySession(Ctx.ActiveSession.Id);
    try
      if (Idx >= 0) and (Idx < AllPhotos.Count) then
      begin
        P := AllPhotos[Idx];
        LblHoleVal.Caption := 'Hole ID: ' + P.HoleId;
        LblTrayVal.Caption := 'Tray Number: ' + P.TrayNumber;
        LblDepthVal.Caption := Format('Depth: %.2f - %.2f m', [P.IntervalFrom, P.IntervalTo]);
        LblStatusVal.Caption := 'Status: ' + P.Status;
        if (P.JpgPath <> '') and FileExists(P.JpgPath) then
        begin
          try
            ImgPreview.Picture.LoadFromFile(P.JpgPath);
          except
          end;
        end;
        PnlInspect.Visible := True;
        PnlCatalog.Visible := False;
      end;
    finally
      AllPhotos.Free;
    end;
  end;
end;

end.
