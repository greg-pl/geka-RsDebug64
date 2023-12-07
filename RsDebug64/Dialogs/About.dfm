object AboutForm: TAboutForm
  Left = 852
  Top = 471
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'AboutForm'
  ClientHeight = 213
  ClientWidth = 356
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnActivate = FormActivate
  OnMouseMove = FormMouseMove
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 188
    Height = 37
    Caption = 'RsDebuger'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
  end
  object Version: TLabel
    Left = 224
    Top = 8
    Width = 22
    Height = 29
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 16
    Top = 48
    Width = 113
    Height = 16
    Caption = 'Grzegorz Kania'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
  end
  object Mail2Label: TLabel
    Left = 21
    Top = 65
    Width = 140
    Height = 13
    Caption = 'email: gkania@poczta.onet.pl'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = Mail2LabelClick
    OnMouseMove = Mail2LabelMouseMove
  end
  object Memo1: TMemo
    Left = 8
    Top = 96
    Width = 345
    Height = 113
    TabStop = False
    Color = clInfoBk
    ReadOnly = True
    TabOrder = 0
  end
end
