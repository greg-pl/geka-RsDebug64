object ShowDrvInfoForm: TShowDrvInfoForm
  Left = 4037
  Top = 200
  BorderIcons = [biSystemMenu]
  Caption = 'Driver info'
  ClientHeight = 217
  ClientWidth = 452
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object ParamGrid: TStringGrid
    Left = 0
    Top = 41
    Width = 452
    Height = 176
    Align = alClient
    ColCount = 4
    DefaultColWidth = 20
    DefaultRowHeight = 20
    RowCount = 20
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitTop = 36
    ColWidths = (
      20
      103
      205
      74)
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 452
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 152
    ExplicitTop = 80
    ExplicitWidth = 185
    object RefreshBtn: TSpeedButton
      Left = 16
      Top = 8
      Width = 23
      Height = 22
      Hint = 'Refresh'
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00222222222222
        222222AAAAAA22222222222AAAAA2AA222222222AAAA2AAA2222222AAAAA22AA
        A22222AAA2AA222AAA2222AA222A2222AA222AA2222222222AA22AA222222222
        2AA22AA2222222222AA222AA2222A222AA2222AAA222AA2AAA22222AAA22AAAA
        A2222222AAA2AAAA222222222AA2AAAAA22222222222AAAAAA22}
      OnClick = RefreshBtnClick
    end
    object TimeLabel: TLabel
      Left = 56
      Top = 11
      Width = 28
      Height = 16
      Caption = 'Time'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
  end
end
