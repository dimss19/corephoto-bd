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
      Top = 16
      Width = 948
      Height = 110
      BevelOuter = bvNone
      Color = 16579832
      ParentBackground = False
      TabOrder = 0
      object LblCamTitle: TLabel
        Left = 16
        Top = 16
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
        Top = 45
        Width = 145
        Height = 15
        Caption = 'Camera: ? Disconnected'
      end
      object BtnDetectCam: TButton
        Left = 16
        Top = 70
        Width = 130
        Height = 28
        Caption = 'Detect Camera'
        TabOrder = 0
        OnClick = BtnDetectCamClick
      end
      object BtnReconnectCam: TButton
        Left = 156
        Top = 70
        Width = 130
        Height = 28
        Caption = 'Reconnect'
        TabOrder = 1
        OnClick = BtnReconnectCamClick
      end
    end
    object PnlStorageServer: TPanel
      Left = 16
      Top = 140
      Width = 948
      Height = 130
      BevelOuter = bvNone
      Color = 16579832
      ParentBackground = False
      TabOrder = 1
      object LblStorageTitle: TLabel
        Left = 16
        Top = 16
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
        Top = 45
        Width = 116
        Height = 15
        Caption = 'Target Server Folder:'
      end
      object EdtServerFolder: TEdit
        Left = 16
        Top = 65
        Width = 750
        Height = 28
        TabOrder = 0
        Text = '\\192.168.1.50\CorePhotos'
      end
      object BtnSaveServer: TButton
        Left = 16
        Top = 95
        Width = 130
        Height = 28
        Caption = 'Save Server'
        TabOrder = 1
        OnClick = BtnSaveServerClick
      end
      object BtnTestServer: TButton
        Left = 156
        Top = 95
        Width = 130
        Height = 28
        Caption = 'Test Access'
        TabOrder = 2
        OnClick = BtnTestServerClick
      end
    end
    object PnlDiagLogs: TPanel
      Left = 16
      Top = 284
      Width = 948
      Height = 340
      BevelOuter = bvNone
      Color = 16579832
      ParentBackground = False
      TabOrder = 2
      object LblDiagTitle: TLabel
        Left = 16
        Top = 16
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
        Top = 45
        Width = 140
        Height = 28
        Caption = 'Run Diagnostics'
        TabOrder = 0
        OnClick = BtnRunDiagnosticsClick
      end
      object BtnRefreshLogs: TButton
        Left = 166
        Top = 45
        Width = 120
        Height = 28
        Caption = 'Refresh Logs'
        TabOrder = 1
        OnClick = BtnRefreshLogsClick
      end
      object MemoLogs: TMemo
        Left = 16
        Top = 85
        Width = 916
        Height = 240
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
