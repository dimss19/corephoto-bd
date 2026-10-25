unit CP.Ctl.Base;

interface

uses
  System.SysUtils, System.Classes, System.Types, Vcl.Controls, Vcl.Graphics,
  Vcl.StdCtrls, Vcl.ExtCtrls, CP.UI.Theme;

type
  TCPPanel = class(TCustomPanel)
  private
    FBorderColor: TColor;
    FCornerRadius: Integer;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property BorderColor: TColor read FBorderColor write FBorderColor;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius;
    property Color;
    property Align;
  end;

  TCPButton = class(TCustomControl)
  private
    FText: string;
    FFgColor: TColor;
    FHoverColor: TColor;
    FTextColor: TColor;
    FBorderColor: TColor;
    FCornerRadius: Integer;
    FIsHovered: Boolean;
    FOnClick: TNotifyEvent;
  protected
    procedure Paint; override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Caption: string read FText write FText;
    property FgColor: TColor read FFgColor write FFgColor;
    property HoverColor: TColor read FHoverColor write FHoverColor;
    property TextColor: TColor read FTextColor write FTextColor;
    property BorderColor: TColor read FBorderColor write FBorderColor;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

implementation

constructor TCPPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Color := COLOR_PANEL;
  FBorderColor := COLOR_BORDER;
  FCornerRadius := 4;
  BevelOuter := bvNone;
end;

procedure TCPPanel.Paint;
begin
  Canvas.Brush.Color := Color;
  Canvas.Pen.Color := FBorderColor;
  Canvas.Pen.Width := 1;
  Canvas.RoundRect(0, 0, Width, Height, FCornerRadius * 2, FCornerRadius * 2);
end;

constructor TCPButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 120;
  Height := 32;
  FFgColor := COLOR_ACCENT;
  FHoverColor := COLOR_ACCENT_HOVER;
  FTextColor := clWhite;
  FBorderColor := clNone;
  FCornerRadius := 4;
  Cursor := crHandPoint;
end;

procedure TCPButton.CMMouseEnter(var Message: TMessage);
begin
  FIsHovered := True;
  Invalidate;
end;

procedure TCPButton.CMMouseLeave(var Message: TMessage);
begin
  FIsHovered := False;
  Invalidate;
end;

procedure TCPButton.Click;
begin
  inherited Click;
  if Assigned(FOnClick) then FOnClick(Self);
end;

procedure TCPButton.Paint;
var
  BG: TColor;
  TW, TH: Integer;
begin
  if FIsHovered then BG := FHoverColor else BG := FFgColor;
  Canvas.Brush.Color := BG;
  if FBorderColor <> clNone then
  begin
    Canvas.Pen.Color := FBorderColor;
    Canvas.Pen.Width := 1;
  end
  else
    Canvas.Pen.Style := psClear;

  Canvas.RoundRect(0, 0, Width, Height, FCornerRadius * 2, FCornerRadius * 2);

  Canvas.Font.Name := FONT_FAMILY;
  Canvas.Font.Size := 10;
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := FTextColor;
  Canvas.Brush.Style := bsClear;

  TW := Canvas.TextWidth(FText);
  TH := Canvas.TextHeight(FText);
  Canvas.TextOut((Width - TW) div 2, (Height - TH) div 2, FText);
end;

end.
