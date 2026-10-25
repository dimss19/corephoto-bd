object DatePickerModal: TDatePickerModal
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'PILIH TANGGAL'
  ClientHeight = 310
  ClientWidth = 286
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object PnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 286
    Height = 44
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object LblMonthYear: TLabel
      Left = 70
      Top = 12
      Width = 146
      Height = 20
      Alignment = taCenter
      AutoSize = False
      Caption = 'October 2026'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BtnPrevMonth: TButton
      Left = 12
      Top = 10
      Width = 36
      Height = 26
      Caption = '<'
      TabOrder = 0
      OnClick = BtnPrevMonthClick
    end
    object BtnNextMonth: TButton
      Left = 238
      Top = 10
      Width = 36
      Height = 26
      Caption = '>'
      TabOrder = 1
      OnClick = BtnNextMonthClick
    end
  end
  object PnlGrid: TPanel
    Left = 0
    Top = 44
    Width = 286
    Height = 226
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
  end
  object BtnToday: TButton
    Left = 0
    Top = 270
    Width = 286
    Height = 40
    Align = alBottom
    Caption = 'Hari Ini (Today)'
    TabOrder = 2
    OnClick = BtnTodayClick
  end
end
