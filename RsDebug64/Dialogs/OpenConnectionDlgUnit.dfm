object OpenConnectionDlg: TOpenConnectionDlg
  Left = 227
  Top = 108
  Caption = 'Dialog'
  ClientHeight = 485
  ClientWidth = 476
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    476
    485)
  PixelsPerInch = 96
  TextHeight = 13
  object OKBtn: TButton
    Left = 287
    Top = 445
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 383
    Top = 445
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object TabControl: TTabControl
    Left = 0
    Top = 0
    Width = 476
    Height = 432
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    Tabs.Strings = (
      'MBUS'
      'ST-LINK')
    TabIndex = 0
    OnChange = TabControlChange
    OnChanging = TabControlChanging
    object Panel1: TPanel
      Left = 4
      Top = 24
      Width = 468
      Height = 25
      Align = alTop
      ParentBackground = False
      TabOrder = 0
      object LibDescrLabel: TLabel
        Left = 5
        Top = 2
        Width = 78
        Height = 16
        Caption = 'LibDescrLabel'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object DefaultBtn: TButton
    Left = 191
    Top = 445
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Default'
    TabOrder = 3
    OnClick = DefaultBtnClick
  end
end
