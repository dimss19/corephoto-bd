object CaptureView: TCaptureView
  Left = 0
  Top = 0
  Width = 1200
  Height = 720
  Color = 16053748
  DoubleBuffered = True
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object PnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 350
    Height = 720
    Align = alLeft
    BevelOuter = bvNone
    Color = 16579832
    ParentBackground = False
    TabOrder = 0
    object PnlTabButtons: TPanel
      Left = 8
      Top = 8
      Width = 334
      Height = 36
      BevelOuter = bvNone
      Color = 15921906
      ParentBackground = False
      TabOrder = 0
      object BtnTabTrayData: TButton
        Left = 4
        Top = 4
        Width = 120
        Height = 28
        Caption = 'Tray Data'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = BtnTabTrayDataClick
      end
      object BtnTabCamSettings: TButton
        Left = 128
        Top = 4
        Width = 130
        Height = 28
        Caption = 'Camera Settings'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2500134
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = BtnTabCamSettingsClick
      end
    end
    object ScrollBoxTray: TScrollBox
      Left = 8
      Top = 48
      Width = 334
      Height = 664
      HorzScrollBar.Visible = False
      VertScrollBar.Tracking = True
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      Color = 16579832
      ParentColor = False
      TabOrder = 1
      object LblTrayTitle: TLabel
        Left = 6
        Top = 6
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
      object LblTraySubtitle: TLabel
        Left = 6
        Top = 26
        Width = 155
        Height = 13
        Caption = 'Core tray parameters && interval.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 8684676
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object PnlImageDetails: TPanel
        Left = 4
        Top = 48
        Width = 310
        Height = 280
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        object LblImageTitle: TLabel
          Left = 8
          Top = 6
          Width = 76
          Height = 15
          Caption = 'Image Details:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 2500134
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object LblHole: TLabel
          Left = 8
          Top = 30
          Width = 41
          Height = 13
          Caption = 'Hole ID:'
        end
        object EdtHole: TEdit
          Left = 110
          Top = 26
          Width = 190
          Height = 23
          TabOrder = 0
          Text = 'TSD168'
          OnChange = FormFieldChange
        end
        object LblTray: TLabel
          Left = 8
          Top = 58
          Width = 39
          Height = 13
          Caption = 'Tray ID:'
        end
        object EdtTray: TEdit
          Left = 110
          Top = 54
          Width = 190
          Height = 23
          TabOrder = 1
          Text = '1'
          OnChange = FormFieldChange
        end
        object LblFrom: TLabel
          Left = 8
          Top = 86
          Width = 98
          Height = 13
          Caption = 'Core Interval From:'
        end
        object EdtFrom: TEdit
          Left = 110
          Top = 82
          Width = 190
          Height = 23
          TabOrder = 2
          Text = '0'
          OnChange = FormFieldChange
        end
        object LblTo: TLabel
          Left = 8
          Top = 114
          Width = 84
          Height = 13
          Caption = 'Core Interval To:'
        end
        object EdtTo: TEdit
          Left = 110
          Top = 110
          Width = 190
          Height = 23
          TabOrder = 3
          Text = '2'
          OnChange = FormFieldChange
        end
        object LblRows: TLabel
          Left = 8
          Top = 142
          Width = 55
          Height = 13
          Caption = 'Tray Rows:'
        end
        object EdtRows: TEdit
          Left = 110
          Top = 138
          Width = 190
          Height = 23
          TabOrder = 4
          Text = '3'
          OnChange = FormFieldChange
        end
        object LblCropArea: TLabel
          Left = 8
          Top = 170
          Width = 80
          Height = 13
          Caption = 'Tray Crop Area:'
        end
        object EdtCropArea: TEdit
          Left = 110
          Top = 166
          Width = 190
          Height = 23
          TabOrder = 5
          Text = '0.0025 0.3006 0.9645 0.6335'
        end
        object LblTrayLength: TLabel
          Left = 8
          Top = 198
          Width = 91
          Height = 13
          Caption = 'Tray Length (mm):'
        end
        object EdtTrayLength: TEdit
          Left = 110
          Top = 194
          Width = 190
          Height = 23
          TabOrder = 6
          Text = '700'
        end
        object LblTrayWidth: TLabel
          Left = 8
          Top = 226
          Width = 86
          Height = 13
          Caption = 'Tray Width (mm):'
        end
        object EdtTrayWidth: TEdit
          Left = 110
          Top = 222
          Width = 190
          Height = 23
          TabOrder = 7
          Text = '300'
        end
      end
      object PnlComments: TPanel
        Left = 4
        Top = 330
        Width = 310
        Height = 110
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
        object LblComments: TLabel
          Left = 8
          Top = 6
          Width = 61
          Height = 15
          Caption = 'Comments:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 2500134
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object MemoComments: TMemo
          Left = 8
          Top = 26
          Width = 292
          Height = 74
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
      end
      object PnlSeriesDetails: TPanel
        Left = 4
        Top = 446
        Width = 310
        Height = 215
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 3
        object LblSeriesTitle: TLabel
          Left = 8
          Top = 6
          Width = 75
          Height = 15
          Caption = 'Series Details:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 2500134
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object LblSeriesCountKey: TLabel
          Left = 8
          Top = 26
          Width = 67
          Height = 13
          Caption = 'Image Count:'
        end
        object LblSeriesCountVal: TLabel
          Left = 110
          Top = 26
          Width = 6
          Height = 13
          Caption = '0'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object LblSeriesSpaceKey: TLabel
          Left = 8
          Top = 46
          Width = 55
          Height = 13
          Caption = 'Total Used:'
        end
        object LblSeriesSpaceVal: TLabel
          Left = 110
          Top = 46
          Width = 120
          Height = 13
          Caption = 'waiting...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5987154
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object LblTargetFolder: TLabel
          Left = 8
          Top = 68
          Width = 71
          Height = 13
          Caption = 'Target Folder:'
        end
        object EdtTargetFolder: TEdit
          Left = 8
          Top = 84
          Width = 262
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -10
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object BtnBrowseTarget: TButton
          Left = 274
          Top = 84
          Width = 28
          Height = 23
          Caption = '...'
          TabOrder = 1
          OnClick = BtnBrowseTargetClick
        end
        object LblServerFolder: TLabel
          Left = 8
          Top = 112
          Width = 106
          Height = 13
          Caption = 'Target Server Folder:'
        end
        object EdtServerFolder: TEdit
          Left = 8
          Top = 128
          Width = 262
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -10
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object BtnBrowseServer: TButton
          Left = 274
          Top = 128
          Width = 28
          Height = 23
          Caption = '...'
          TabOrder = 3
          OnClick = BtnBrowseServerClick
        end
        object BtnOpenCsv: TButton
          Left = 8
          Top = 158
          Width = 142
          Height = 26
          Caption = 'Open CSV Report (Excel)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -10
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 4
          OnClick = BtnOpenCsvClick
        end
        object BtnSyncServer: TButton
          Left = 156
          Top = 158
          Width = 146
          Height = 26
          Caption = 'Sync Session to Server'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -10
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 5
          OnClick = BtnSyncServerClick
        end
      end
    end
    object ScrollBoxCam: TScrollBox
      Left = 8
      Top = 48
      Width = 334
      Height = 664
      HorzScrollBar.Visible = False
      VertScrollBar.Tracking = True
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      Color = 16579832
      ParentColor = False
      TabOrder = 2
      Visible = False
      object PnlSessionDetails: TPanel
        Left = 4
        Top = 6
        Width = 310
        Height = 126
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object LblSessTitle: TLabel
          Left = 8
          Top = 6
          Width = 84
          Height = 15
          Caption = 'Session Details:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 2500134
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object LblDate: TLabel
          Left = 8
          Top = 30
          Width = 27
          Height = 13
          Caption = 'Date:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object DtpDate: TDateTimePicker
          Left = 52
          Top = 26
          Width = 248
          Height = 23
          Date = 46321.000000000000000000
          Time = 46321.000000000000000000
          DateFormat = dfShort
          TabOrder = 0
          OnChange = FormFieldChange
        end
        object LblOperator: TLabel
          Left = 8
          Top = 60
          Width = 32
          Height = 13
          Caption = 'Name:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object EdtOperator: TEdit
          Left = 52
          Top = 56
          Width = 248
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object LblSite: TLabel
          Left = 8
          Top = 90
          Width = 22
          Height = 13
          Caption = 'Site:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object EdtSite: TEdit
          Left = 52
          Top = 86
          Width = 248
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          Text = 'TESTSITE'
        end
      end
      object PnlDevInfo: TPanel
        Left = 4
        Top = 138
        Width = 310
        Height = 270
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object LblDevTitle: TLabel
          Left = 8
          Top = 6
          Width = 190
          Height = 15
          Caption = 'Device Information && Connection:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 2500134
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object LblInterface: TLabel
          Left = 8
          Top = 28
          Width = 92
          Height = 13
          Caption = 'Camera Interface:'
        end
        object CmbInterface: TComboBox
          Left = 8
          Top = 46
          Width = 292
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 0
          Text = 'Physical USB Webcam'
          OnChange = CmbInterfaceChange
          Items.Strings = (
            'Physical USB Webcam'
            'Direct USB DSLR (Cable)')
        end
        object LblWebcamDev: TLabel
          Left = 8
          Top = 76
          Width = 192
          Height = 13
          Caption = 'Webcam Device (Internal / External):'
        end
        object CmbWebcamDevice: TComboBox
          Left = 8
          Top = 94
          Width = 220
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 1
          Text = 'Integrated / Primary Webcam - Index 0'
          OnChange = CmbWebcamDeviceChange
          Items.Strings = (
            'Integrated / Primary Webcam - Index 0')
        end
        object BtnWebcamRefresh: TButton
          Left = 234
          Top = 94
          Width = 66
          Height = 23
          Caption = 'Refresh'
          TabOrder = 2
          OnClick = BtnWebcamRefreshClick
        end
        object LblWebcamHint: TLabel
          Left = 8
          Top = 124
          Width = 292
          Height = 26
          AutoSize = False
          Caption = '1 webcam terdeteksi. Pilih internal/external lalu live view mengikuti otomatis.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 8684676
          Font.Height = -10
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
        object LblDevModel: TLabel
          Left = 8
          Top = 154
          Width = 292
          Height = 15
          AutoSize = False
          Caption = 'Model: Integrated Webcam (Index 0)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object LblDevSerial: TLabel
          Left = 8
          Top = 174
          Width = 292
          Height = 13
          AutoSize = False
          Caption = 'Serial No: USB-VIDEO-0'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5987154
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object LblDevFw: TLabel
          Left = 8
          Top = 192
          Width = 292
          Height = 13
          AutoSize = False
          Caption = 'Firmware: DirectShow 9.0'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5987154
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object BtnDevDetect: TButton
          Left = 8
          Top = 220
          Width = 140
          Height = 28
          Caption = 'Detect Camera'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 3
          OnClick = BtnDevDetectClick
        end
        object BtnDevReconnect: TButton
          Left = 158
          Top = 220
          Width = 142
          Height = 28
          Caption = 'Reconnect'
          TabOrder = 4
          OnClick = BtnDevReconnectClick
        end
      end
      object PnlCamSettings: TPanel
        Left = 4
        Top = 414
        Width = 310
        Height = 310
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        object LblCamSetTitle: TLabel
          Left = 8
          Top = 6
          Width = 47
          Height = 15
          Caption = 'Settings:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 2500134
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object LblFormat: TLabel
          Left = 8
          Top = 30
          Width = 40
          Height = 13
          Caption = 'Format:'
        end
        object CmbFormat: TComboBox
          Left = 100
          Top = 26
          Width = 200
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 0
          Text = 'JPEG'
          Items.Strings = (
            'JPEG'
            'PNG'
            'RAW')
        end
        object LblExposure: TLabel
          Left = 8
          Top = 60
          Width = 51
          Height = 13
          Caption = 'Exposure:'
        end
        object CmbExposure: TComboBox
          Left = 100
          Top = 56
          Width = 200
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 1
          Text = 'Not valid/no settings'
          Items.Strings = (
            'Not valid/no settings'
            'Auto'
            'Manual')
        end
        object LblAperture: TLabel
          Left = 8
          Top = 90
          Width = 48
          Height = 13
          Caption = 'Aperture:'
        end
        object CmbAperture: TComboBox
          Left = 100
          Top = 86
          Width = 200
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 2
          Text = '10'
          Items.Strings = (
            '10'
            'f/4.0'
            'f/5.6'
            'f/8.0'
            'f/11')
        end
        object LblFlash: TLabel
          Left = 8
          Top = 120
          Width = 66
          Height = 13
          Caption = 'Enable Flash:'
        end
        object ChkFlash: TCheckBox
          Left = 100
          Top = 118
          Width = 24
          Height = 17
          TabOrder = 3
        end
        object LblMetering: TLabel
          Left = 8
          Top = 148
          Width = 79
          Height = 13
          Caption = 'Metering Mode:'
        end
        object CmbMetering: TComboBox
          Left = 100
          Top = 144
          Width = 200
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 4
          Text = 'Center-Weighted Average'
          Items.Strings = (
            'Center-Weighted Average'
            'Evaluative'
            'Spot')
        end
        object LblFocusing: TLabel
          Left = 8
          Top = 178
          Width = 50
          Height = 13
          Caption = 'Focusing:'
        end
        object CmbFocusing: TComboBox
          Left = 100
          Top = 174
          Width = 200
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 5
          Text = 'One-Shot'
          Items.Strings = (
            'One-Shot'
            'AI Focus'
            'Manual')
        end
        object LblIso: TLabel
          Left = 8
          Top = 208
          Width = 57
          Height = 13
          Caption = 'Film Speed:'
        end
        object CmbIso: TComboBox
          Left = 100
          Top = 204
          Width = 200
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 6
          Text = '100'
          Items.Strings = (
            '100'
            '200'
            '400'
            '800'
            'Auto')
        end
        object LblResolution: TLabel
          Left = 8
          Top = 238
          Width = 58
          Height = 13
          Caption = 'Resolution:'
        end
        object CmbResolution: TComboBox
          Left = 100
          Top = 234
          Width = 200
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 7
          Text = 'Auto (Best Native DSLR - 18MP/24MP+)'
          Items.Strings = (
            'Auto (Best Native DSLR - 18MP/24MP+)'
            '1920 x 1080 (Full HD)'
            '1280 x 720 (HD)')
        end
      end
            object LblMaxSize: TLabel
          Left = 8
          Top = 266
          Width = 78
          Height = 13
          Caption = 'Max Size (MB):'
        end
        object EdtMaxSize: TEdit
          Left = 100
          Top = 262
          Width = 140
          Height = 23
          TabOrder = 8
          Text = '10.0'
        end
        object BtnSaveMaxSize: TButton
          Left = 246
          Top = 262
          Width = 54
          Height = 23
          Caption = 'Set'
          TabOrder = 9
          OnClick = BtnSaveMaxSizeClick
        end
end
  end
  object PnlCenter: TPanel
    Left = 350
    Top = 0
    Width = 850
    Height = 720
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    DoubleBuffered = True
    ParentBackground = False
    TabOrder = 1
    object PnlLiveTopBar: TPanel
      Left = 0
      Top = 0
      Width = 850
      Height = 38
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object LblLiveStatus: TLabel
        Left = 16
        Top = 10
        Width = 143
        Height = 17
        Caption = 'LIVE CAMERA STREAM'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2500134
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object BtnLiveReconnect: TButton
        Left = 744
        Top = 5
        Width = 90
        Height = 28
        Anchors = [akTop, akRight]
        Caption = 'Reconnect'
        TabOrder = 0
        OnClick = BtnLiveReconnectClick
      end
      object BtnCropToggle: TButton
        Left = 644
        Top = 5
        Width = 95
        Height = 28
        Anchors = [akTop, akRight]
        Caption = 'Crop Box: ON'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = BtnCropToggleClick
      end
    end
    object PaintLiveView: TPaintBox
      Left = 0
      Top = 38
      Width = 850
      Height = 487
      Align = alClient
      OnPaint = PaintLiveViewPaint
    end
    object PnlPreflightBanner: TPanel
      Left = 0
      Top = 525
      Width = 850
      Height = 50
      Align = alBottom
      BevelOuter = bvNone
      Color = 15007487
      ParentBackground = False
      TabOrder = 1
      object LblPreflightChecklist: TLabel
        Left = 16
        Top = 6
        Width = 478
        Height = 15
        Caption = 'Camera '#10003'  '#183'  Session '#10003'  '#183'  Hole ID '#10003'  '#183'  Tray ID '#10003'  '#183'  Interval '#10003'  '#183'  Storage '#10003'  '#183'  Crop '#10003
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 7434609
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object LblPreflightVerdict: TLabel
        Left = 16
        Top = 24
        Width = 356
        Height = 17
        Caption = 'READY TO CAPTURE: All pre-flight checklist items verified.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1483542
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object PnlControlBottom: TPanel
      Left = 0
      Top = 575
      Width = 850
      Height = 145
      Align = alBottom
      BevelOuter = bvNone
      Color = 16382456
      ParentBackground = False
      TabOrder = 2
      object PnlCardDetails: TPanel
        Left = 10
        Top = 6
        Width = 230
        Height = 132
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object LblDetailsTitle: TLabel
          Left = 10
          Top = 6
          Width = 84
          Height = 15
          Caption = 'Capture Details'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 2500134
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object LblDimKey: TLabel
          Left = 10
          Top = 28
          Width = 63
          Height = 13
          Caption = 'Dimensions:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 7434609
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object LblDimVal: TLabel
          Left = 90
          Top = 28
          Width = 47
          Height = 13
          Caption = 'waiting ...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object LblSizeKey: TLabel
          Left = 10
          Top = 50
          Width = 43
          Height = 13
          Caption = 'File Size:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 7434609
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object LblSizeVal: TLabel
          Left = 90
          Top = 50
          Width = 47
          Height = 13
          Caption = 'waiting ...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object LblCapKey: TLabel
          Left = 10
          Top = 72
          Width = 43
          Height = 13
          Caption = 'Capture:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 7434609
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object LblCapVal: TLabel
          Left = 90
          Top = 72
          Width = 47
          Height = 13
          Caption = 'waiting ...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object LblDestKey: TLabel
          Left = 10
          Top = 94
          Width = 62
          Height = 13
          Caption = 'Destination:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 7434609
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object LblDestVal: TLabel
          Left = 90
          Top = 94
          Width = 130
          Height = 32
          AutoSize = False
          Caption = 'waiting ...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -10
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
      end
      object PnlCtrlCenter: TPanel
        Left = 246
        Top = 6
        Width = 444
        Height = 132
        Anchors = [akLeft, akTop, akRight]
        BevelOuter = bvNone
        Color = 16382456
        ParentBackground = False
        TabOrder = 1
        object ChkGrid: TCheckBox
          Left = 8
          Top = 6
          Width = 60
          Height = 20
          Caption = 'Grid'
          Checked = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          State = cbChecked
          TabOrder = 0
          OnClick = ChkGridClick
        end
        object BtnZoom: TButton
          Left = 8
          Top = 28
          Width = 356
          Height = 28
          Anchors = [akLeft, akTop]
          Caption = 'Zoom In'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = BtnZoomClick
        end
        object LblFocusDrive: TLabel
          Left = 8
          Top = 64
          Width = 166
          Height = 13
          Caption = 'Lens Focus Drive (DSLR Tethered):'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 8684676
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object BtnFocusStepN3: TButton
          Left = 8
          Top = 84
          Width = 56
          Height = 28
          Anchors = [akLeft, akTop]
          Caption = '<<<'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = FocusStepClick
        end
        object BtnFocusStepN2: TButton
          Left = 68
          Top = 84
          Width = 56
          Height = 28
          Anchors = [akLeft, akTop]
          Caption = '<<'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 3
          OnClick = FocusStepClick
        end
        object BtnFocusStepN1: TButton
          Left = 128
          Top = 84
          Width = 56
          Height = 28
          Anchors = [akLeft, akTop]
          Caption = '<'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 4
          OnClick = FocusStepClick
        end
        object BtnFocusStepP1: TButton
          Left = 188
          Top = 84
          Width = 56
          Height = 28
          Anchors = [akLeft, akTop]
          Caption = '>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 5
          OnClick = FocusStepClick
        end
        object BtnFocusStepP2: TButton
          Left = 248
          Top = 84
          Width = 56
          Height = 28
          Anchors = [akLeft, akTop]
          Caption = '>>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 6
          OnClick = FocusStepClick
        end
        object BtnFocusStepP3: TButton
          Left = 308
          Top = 84
          Width = 56
          Height = 28
          Anchors = [akLeft, akTop]
          Caption = '>>>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 7
          OnClick = FocusStepClick
        end
      end
      object PnlCtrlActions: TPanel
        Left = 696
        Top = 6
        Width = 144
        Height = 132
        Anchors = [akTop, akRight]
        BevelOuter = bvNone
        Color = 16382456
        ParentBackground = False
        TabOrder = 2
        object BtnLiveViewToggle: TButton
          Left = 4
          Top = 2
          Width = 136
          Height = 24
          Caption = 'End Live View'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = BtnLiveViewToggleClick
        end
        object BtnCapture: TButton
          Left = 4
          Top = 28
          Width = 136
          Height = 26
          Caption = 'Capture'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = BtnCaptureClick
        end
        object BtnRetake: TButton
          Left = 4
          Top = 55
          Width = 136
          Height = 24
          Caption = 'Retake'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = BtnRetakeClick
        end
        object BtnSave: TButton
          Left = 4
          Top = 80
          Width = 136
          Height = 24
          Caption = 'Save'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 3
          OnClick = BtnSaveClick
        end
        object BtnFinish: TButton
          Left = 4
          Top = 105
          Width = 136
          Height = 24
          Caption = 'Finish'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          OnClick = BtnFinishClick
        end
      end
    end
  end
end
