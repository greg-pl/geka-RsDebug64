object OKRightDlg: TOKRightDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Dialog'
  ClientHeight = 407
  ClientWidth = 488
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    488
    407)
  PixelsPerInch = 96
  TextHeight = 13
  object OKBtn: TButton
    Left = 299
    Top = 367
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 395
    Top = 367
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
    Width = 488
    Height = 354
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    Tabs.Strings = (
      'MBUS'
      'ST-LINK')
    TabIndex = 0
    OnChange = TabControlChange
    ExplicitTop = 7
  end
end
