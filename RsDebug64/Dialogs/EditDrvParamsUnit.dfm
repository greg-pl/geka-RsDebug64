object EditDrvParamsForm: TEditDrvParamsForm
  Left = 4037
  Top = 200
  Caption = 'Driver params'
  ClientHeight = 347
  ClientWidth = 456
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 304
    Width = 456
    Height = 43
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      456
      43)
    object OkBtn: TButton
      Left = 279
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = OkBtnClick
    end
    object Button2: TButton
      Left = 368
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object DefaultBtn: TButton
      Left = 183
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Default'
      TabOrder = 2
      OnClick = DefaultBtnClick
    end
  end
end
