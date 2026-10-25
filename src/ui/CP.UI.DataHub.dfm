object DataHubView: TDataHubView
  Left = 0
  Top = 0
  Width = 980
  Height = 650
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object PnlRoot: TPanel
    Left = 0
    Top = 0
    Width = 980
    Height = 650
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object PnlActiveCard: TPanel
      Left = 16
      Top = 16
      Width = 948
      Height = 72
      BevelOuter = bvNone
      Color = 16579832
      ParentBackground = False
      TabOrder = 0
      object LblActiveTitle: TLabel
        Left = 16
        Top = 12
        Width = 186
        Height = 20
        Caption = 'ACTIVE SESSION: [None]'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LblActiveDetails: TLabel
        Left = 16
        Top = 38
        Width = 227
        Height = 15
        Caption = 'No active borehole logging session loaded.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987154
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object BtnBackToCapture: TButton
        Left = 780
        Top = 20
        Width = 150
        Height = 32
        Caption = '<- Camera Capture'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = BtnBackToCaptureClick
      end
    end
    object PnlCreateForm: TPanel
      Left = 16
      Top = 104
      Width = 460
      Height = 520
      BevelOuter = bvNone
      Color = 16382456
      ParentBackground = False
      TabOrder = 1
      object LblCreateTitle: TLabel
        Left = 16
        Top = 16
        Width = 239
        Height = 17
        Caption = 'CREATE NEW BOREHOLE SESSION'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LblSite: TLabel
        Left = 16
        Top = 50
        Width = 118
        Height = 15
        Caption = 'Site / Project Code *'
      end
      object EdtSite: TEdit
        Left = 16
        Top = 70
        Width = 428
        Height = 28
        TabOrder = 0
        Text = 'GOSOWONG'
      end
      object LblOperator: TLabel
        Left = 16
        Top = 110
        Width = 86
        Height = 15
        Caption = 'Operator Name'
      end
      object EdtOperator: TEdit
        Left = 16
        Top = 130
        Width = 428
        Height = 28
        TabOrder = 1
        Text = 'Operator'
      end
      object LblDate: TLabel
        Left = 16
        Top = 170
        Width = 109
        Height = 15
        Caption = 'Date (YYYYMMDD) *'
      end
      object EdtDate: TEdit
        Left = 16
        Top = 190
        Width = 380
        Height = 28
        TabOrder = 2
        Text = '20261023'
      end
      object BtnPickDate: TButton
        Left = 402
        Top = 190
        Width = 42
        Height = 28
        Caption = '...'
        TabOrder = 3
        OnClick = BtnPickDateClick
      end
      object BtnCreateSession: TButton
        Left = 16
        Top = 240
        Width = 428
        Height = 36
        Caption = 'CREATE && ACTIVATE SESSION'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
        OnClick = BtnCreateSessionClick
      end
    end
    object PnlArchive: TPanel
      Left = 492
      Top = 104
      Width = 472
      Height = 520
      BevelOuter = bvNone
      Color = 16382456
      ParentBackground = False
      TabOrder = 2
      object LblArchiveTitle: TLabel
        Left = 16
        Top = 16
        Width = 117
        Height = 17
        Caption = 'SESSION ARCHIVE'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LstSessions: TListBox
        Left = 16
        Top = 50
        Width = 440
        Height = 410
        ItemHeight = 15
        TabOrder = 0
      end
      object BtnOpenSession: TButton
        Left = 16
        Top = 470
        Width = 210
        Height = 36
        Caption = 'Open Session'
        TabOrder = 1
        OnClick = BtnOpenSessionClick
      end
      object BtnDeleteSession: TButton
        Left = 246
        Top = 470
        Width = 210
        Height = 36
        Caption = 'Delete Session'
        TabOrder = 2
        OnClick = BtnDeleteSessionClick
      end
    end
  end
end
