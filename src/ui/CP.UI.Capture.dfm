object CaptureView: TCaptureView
  Left = 0
  Top = 0
  Width = 980
  Height = 650
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object PnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 650
    Align = alLeft
    BevelOuter = bvNone
    Color = 16579832
    ParentBackground = False
    TabOrder = 0
    object PnlTrayData: TPanel
      Left = 12
      Top = 12
      Width = 296
      Height = 360
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object LblTrayTitle: TLabel
        Left = 12
        Top = 12
        Width = 145
        Height = 17
        Caption = 'TRAY IDENTIFICATION'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LblHole: TLabel
        Left = 12
        Top = 45
        Width = 47
        Height = 15
        Caption = 'Hole ID:'
      end
      object EdtHole: TEdit
        Left = 12
        Top = 65
        Width = 270
        Height = 26
        TabOrder = 0
        Text = 'TSD168'
      end
      object LblTray: TLabel
        Left = 12
        Top = 100
        Width = 41
        Height = 15
        Caption = 'Tray ID:'
      end
      object EdtTray: TEdit
        Left = 12
        Top = 120
        Width = 270
        Height = 26
        TabOrder = 1
        Text = '1'
      end
      object LblFrom: TLabel
        Left = 12
        Top = 155
        Width = 105
        Height = 15
        Caption = 'Core Interval From:'
      end
      object EdtFrom: TEdit
        Left = 12
        Top = 175
        Width = 270
        Height = 26
        TabOrder = 2
        Text = '0.00'
      end
      object LblTo: TLabel
        Left = 12
        Top = 210
        Width = 89
        Height = 15
        Caption = 'Core Interval To:'
      end
      object EdtTo: TEdit
        Left = 12
        Top = 230
        Width = 270
        Height = 26
        TabOrder = 3
        Text = '2.00'
      end
      object LblRows: TLabel
        Left = 12
        Top = 265
        Width = 57
        Height = 15
        Caption = 'Tray Rows:'
      end
      object EdtRows: TEdit
        Left = 12
        Top = 285
        Width = 270
        Height = 26
        TabOrder = 4
        Text = '3'
      end
    end
    object PnlPreflight: TPanel
      Left = 12
      Top = 380
      Width = 296
      Height = 250
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object LblPreflightStatus: TLabel
        Left = 12
        Top = 12
        Width = 145
        Height = 17
        Caption = 'READY TO CAPTURE'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1483542
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object BtnCapture: TButton
        Left = 12
        Top = 45
        Width = 272
        Height = 54
        Caption = '[ CAPTURE ]'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = BtnCaptureClick
      end
      object BtnRetake: TButton
        Left = 12
        Top = 110
        Width = 272
        Height = 36
        Caption = 'Retake Photo'
        TabOrder = 1
        OnClick = BtnRetakeClick
      end
      object BtnSaveNext: TButton
        Left = 12
        Top = 155
        Width = 272
        Height = 36
        Caption = 'Save && Next Tray ->'
        TabOrder = 2
        OnClick = BtnSaveNextClick
      end
    end
  end
  object PnlCenter: TPanel
    Left = 320
    Top = 0
    Width = 660
    Height = 650
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object PnlLiveTopBar: TPanel
      Left = 0
      Top = 0
      Width = 660
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      Color = 16382456
      ParentBackground = False
      TabOrder = 0
      object LblLiveStatus: TLabel
        Left = 16
        Top = 12
        Width = 246
        Height = 15
        Caption = 'LIVE VIEW - 1920x1080 @ 30 FPS  |  DirectShow'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ChkGrid: TCheckBox
        Left = 450
        Top = 12
        Width = 60
        Height = 17
        Caption = 'Grid'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = ChkGridClick
      end
      object BtnZoom: TButton
        Left = 520
        Top = 8
        Width = 90
        Height = 26
        Caption = 'Zoom In'
        TabOrder = 1
        OnClick = BtnZoomClick
      end
    end
    object PaintLiveView: TPaintBox
      Left = 0
      Top = 40
      Width = 660
      Height = 610
      Align = alClient
      OnPaint = PaintLiveViewPaint
    end
  end
end
