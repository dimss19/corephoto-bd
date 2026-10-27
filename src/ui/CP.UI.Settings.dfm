object SettingsView: TSettingsView
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
    object PnlCamHardware: TPanel
      Left = 16
      Top = 12
      Width = 948
      Height = 90
      BevelOuter = bvNone
      Color = 16579832
      ParentBackground = False
      TabOrder = 0
      object LblCamTitle: TLabel
        Left = 16
        Top = 12
        Width = 222
        Height = 17
        Caption = 'CAMERA HARDWARE INTERFACE'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LblCamStatus: TLabel
        Left = 16
        Top = 36
        Width = 145
        Height = 15
        Caption = 'Camera: ? Disconnected'
      end
      object BtnDetectCam: TButton
        Left = 16
        Top = 56
        Width = 120
        Height = 26
        Caption = 'Detect Camera'
        TabOrder = 0
        OnClick = BtnDetectCamClick
      end
      object BtnReconnectCam: TButton
        Left = 144
        Top = 56
        Width = 120
        Height = 26
        Caption = 'Reconnect'
        TabOrder = 1
        OnClick = BtnReconnectCamClick
      end
    end
    object PnlPropertiesConfig: TPanel
      Left = 16
      Top = 110
      Width = 948
      Height = 130
      BevelOuter = bvNone
      Color = 16579832
      ParentBackground = False
      TabOrder = 1
      object LblPropertiesTitle: TLabel
        Left = 16
        Top = 12
        Width = 376
        Height = 17
        Caption = 'IMAGE PROPERTIES & FILE SIZE CONSTRAINTS (PROPERTIES SYNC)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LblJpgLimits: TLabel
        Left = 16
        Top = 40
        Width = 121
        Height = 15
        Caption = 'JPG Size Limits (Min-Max MB):'
      end
      object LblJpgTo: TLabel
        Left = 82
        Top = 64
        Width = 11
        Height = 15
        Caption = 'to'
      end
      object EdtJpgMin: TEdit
        Left = 16
        Top = 60
        Width = 60
        Height = 24
        TabOrder = 0
        Text = '5.0'
      end
      object EdtJpgMax: TEdit
        Left = 100
        Top = 60
        Width = 60
        Height = 24
        TabOrder = 1
        Text = '10.0'
      end
      object LblRawLimits: TLabel
        Left = 180
        Top = 40
        Width = 83
        Height = 15
        Caption = 'RAW Max (MB):'
      end
      object EdtRawMax: TEdit
        Left = 180
        Top = 60
        Width = 60
        Height = 24
        TabOrder = 2
        Text = '5.0'
      end
      object LblThumbLimits: TLabel
        Left = 280
        Top = 40
        Width = 135
        Height = 15
        Caption = 'Thumbnail / Tumb Max (MB):'
      end
      object EdtThumbMax: TEdit
        Left = 280
        Top = 60
        Width = 60
        Height = 24
        TabOrder = 3
        Text = '4.0'
      end
      object LblCamMaker: TLabel
        Left = 440
        Top = 40
        Width = 72
        Height = 15
        Caption = 'Camera Maker:'
      end
      object EdtCamMaker: TEdit
        Left = 440
        Top = 60
        Width = 90
        Height = 24
        TabOrder = 4
        Text = 'Canon'
      end
      object LblCamModel: TLabel
        Left = 545
        Top = 40
        Width = 76
        Height = 15
        Caption = 'Camera Model:'
      end
      object EdtCamModel: TEdit
        Left = 545
        Top = 60
        Width = 130
        Height = 24
        TabOrder = 5
        Text = 'Canon EOS 60D'
      end
      object LblDpi: TLabel
        Left = 690
        Top = 40
        Width = 24
        Height = 15
        Caption = 'DPI:'
      end
      object EdtDpi: TEdit
        Left = 690
        Top = 60
        Width = 50
        Height = 24
        TabOrder = 6
        Text = '72'
      end
      object BtnSaveProperties: TButton
        Left = 16
        Top = 94
        Width = 160
        Height = 26
        Caption = 'Save Properties'
        TabOrder = 7
        OnClick = BtnSavePropertiesClick
      end
    end
    object PnlStorageServer: TPanel
      Left = 16
      Top = 248
      Width = 948
      Height = 100
      BevelOuter = bvNone
      Color = 16579832
      ParentBackground = False
      TabOrder = 2
      object LblStorageTitle: TLabel
        Left = 16
        Top = 10
        Width = 299
        Height = 17
        Caption = 'STORAGE && SERVER REPOSITORY CONFIG'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LblServerFolder: TLabel
        Left = 16
        Top = 34
        Width = 116
        Height = 15
        Caption = 'Target Server Folder:'
      end
      object EdtServerFolder: TEdit
        Left = 16
        Top = 54
        Width = 750
        Height = 24
        TabOrder = 0
        Text = '\\192.168.1.50\CorePhotos'
      end
      object BtnSaveServer: TButton
        Left = 774
        Top = 54
        Width = 80
        Height = 24
        Caption = 'Save'
        TabOrder = 1
        OnClick = BtnSaveServerClick
      end
      object BtnTestServer: TButton
        Left = 860
        Top = 54
        Width = 80
        Height = 24
        Caption = 'Test'
        TabOrder = 2
        OnClick = BtnTestServerClick
      end
    end
    object PnlDiagLogs: TPanel
      Left = 16
      Top = 356
      Width = 948
      Height = 280
      BevelOuter = bvNone
      Color = 16579832
      ParentBackground = False
      TabOrder = 3
      object LblDiagTitle: TLabel
        Left = 16
        Top = 10
        Width = 252
        Height = 17
        Caption = 'TECHNICAL DIAGNOSTICS && LOGS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object BtnRunDiagnostics: TButton
        Left = 16
        Top = 34
        Width = 130
        Height = 26
        Caption = 'Run Diagnostics'
        TabOrder = 0
        OnClick = BtnRunDiagnosticsClick
      end
      object BtnRefreshLogs: TButton
        Left = 154
        Top = 34
        Width = 110
        Height = 26
        Caption = 'Refresh Logs'
        TabOrder = 1
        OnClick = BtnRefreshLogsClick
      end
      object MemoLogs: TMemo
        Left = 16
        Top = 68
        Width = 916
        Height = 200
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
  end
end
