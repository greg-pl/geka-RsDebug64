object OpenConnectionDlg: TOpenConnectionDlg
  Left = 227
  Top = 108
  Caption = 'Dialog'
  ClientHeight = 397
  ClientWidth = 478
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    478
    397)
  PixelsPerInch = 96
  TextHeight = 13
  object OKBtn: TButton
    Left = 289
    Top = 357
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 385
    Top = 357
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
    Width = 478
    Height = 344
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    Tabs.Strings = (
      'MBUS'
      'ST-LINK')
    TabIndex = 0
    OnChange = TabControlChange
    object Panel1: TPanel
      Left = 4
      Top = 24
      Width = 470
      Height = 25
      Align = alTop
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
end
