object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Core Photo - Drill Core Photography System'
  ClientHeight = 800
  ClientWidth = 1320
  Color = 16053748
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object PnlTopBar: TPanel
    Left = 0
    Top = 0
    Width = 1320
    Height = 44
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object LblBrand: TLabel
      Left = 16
      Top = 12
      Width = 98
      Height = 17
      Caption = 'CORE PHOTO'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 1775900
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    object PnlStatusSection: TPanel
      Left = 700
      Top = 0
      Width = 620
      Height = 44
      Align = alRight
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object LblHeaderCamera: TLabel
        Left = 200
        Top = 13
        Width = 84
        Height = 15
        Caption = '● Disconnected'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2500316
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LblHeaderStorage: TLabel
        Left = 320
        Top = 13
        Width = 95
        Height = 15
        Caption = 'Storage: Checking'
      end
      object BtnHeaderSession: TButton
        Left = 20
        Top = 8
        Width = 150
        Height = 28
        Caption = 'Session: [None]'
        TabOrder = 0
        OnClick = BtnHeaderSessionClick
      end
      object BtnHeaderSettings: TButton
        Left = 460
        Top = 8
        Width = 140
        Height = 28
        Caption = '⚙ Camera Settings'
        TabOrder = 1
        OnClick = BtnHeaderSettingsClick
      end
    end
  end
  object PnlBottomBar: TPanel
    Left = 0
    Top = 774
    Width = 1320
    Height = 26
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object LblBottomStatus: TLabel
      Left = 16
      Top = 5
      Width = 247
      Height = 15
      Caption = 'System Ready  |  WebcamAdapter Standby Active'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5987154
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LblBottomDb: TLabel
      Left = 1100
      Top = 5
      Width = 200
      Height = 15
      Alignment = taRightJustify
      Caption = 'System Ready  |  SQLite Database OK'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 7434609
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object PnlContent: TPanel
    Left = 0
    Top = 44
    Width = 1320
    Height = 730
    Align = alClient
    BevelOuter = bvNone
    Color = 16053748
    ParentBackground = False
    TabOrder = 2
  end
end
