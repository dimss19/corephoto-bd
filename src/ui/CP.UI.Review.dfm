object ReviewView: TReviewView
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
    object PnlTopNav: TPanel
      Left = 0
      Top = 0
      Width = 980
      Height = 44
      Align = alTop
      BevelOuter = bvNone
      Color = 16382456
      ParentBackground = False
      TabOrder = 0
      object BtnInspectTab: TButton
        Left = 16
        Top = 8
        Width = 140
        Height = 28
        Caption = 'TRAY INSPECTION'
        TabOrder = 0
        OnClick = BtnInspectTabClick
      end
      object BtnCatalogTab: TButton
        Left = 164
        Top = 8
        Width = 140
        Height = 28
        Caption = 'PHOTO BROWSER'
        TabOrder = 1
        OnClick = BtnCatalogTabClick
      end
    end
    object PnlInspect: TPanel
      Left = 0
      Top = 44
      Width = 980
      Height = 606
      Align = alClient
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object ImgPreview: TImage
        Left = 0
        Top = 0
        Width = 660
        Height = 606
        Align = alClient
        Center = True
        Proportional = True
      end
      object PnlInspectSidebar: TPanel
        Left = 660
        Top = 0
        Width = 320
        Height = 606
        Align = alRight
        BevelOuter = bvNone
        Color = 16579832
        ParentBackground = False
        TabOrder = 0
        object LblInspectTitle: TLabel
          Left = 16
          Top = 16
          Width = 166
          Height = 17
          Caption = 'TRAY RECORD && METADATA'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object LblHoleVal: TLabel
          Left = 16
          Top = 50
          Width = 59
          Height = 15
          Caption = 'Hole ID: -'
        end
        object LblTrayVal: TLabel
          Left = 16
          Top = 80
          Width = 83
          Height = 15
          Caption = 'Tray Number: -'
        end
        object LblDepthVal: TLabel
          Left = 16
          Top = 110
          Width = 47
          Height = 15
          Caption = 'Depth: -'
        end
        object LblStatusVal: TLabel
          Left = 16
          Top = 140
          Width = 47
          Height = 15
          Caption = 'Status: -'
        end
        object BtnApproveNext: TButton
          Left = 16
          Top = 220
          Width = 288
          Height = 44
          Caption = 'APPROVE && NEXT TRAY'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = BtnApproveNextClick
        end
        object BtnSyncServer: TButton
          Left = 16
          Top = 280
          Width = 288
          Height = 36
          Caption = 'SYNC SESSION TO SERVER'
          TabOrder = 1
          OnClick = BtnSyncServerClick
        end
        object BtnRetake: TButton
          Left = 16
          Top = 330
          Width = 288
          Height = 36
          Caption = 'RETAKE THIS TRAY'
          TabOrder = 2
          OnClick = BtnRetakeClick
        end
      end
    end
    object PnlCatalog: TPanel
      Left = 0
      Top = 44
      Width = 980
      Height = 606
      Align = alClient
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      Visible = False
      object EdtSearch: TEdit
        Left = 16
        Top = 16
        Width = 800
        Height = 28
        TabOrder = 0
        TextHint = 'Filter Hole ID or Tray...'
      end
      object BtnRefreshCatalog: TButton
        Left = 824
        Top = 16
        Width = 140
        Height = 28
        Caption = 'Refresh'
        TabOrder = 1
      end
      object LstPhotos: TListBox
        Left = 16
        Top = 56
        Width = 948
        Height = 530
        ItemHeight = 15
        TabOrder = 2
        OnClick = LstPhotosClick
      end
    end
  end
end
