object EditDrvParamsForm: TEditDrvParamsForm
  Left = 4037
  Top = 200
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'EditDrvParamsForm'
  ClientHeight = 183
  ClientWidth = 308
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object ParamGrid: TStringGrid
    Left = 0
    Top = 0
    Width = 308
    Height = 183
    Align = alClient
    ColCount = 3
    DefaultColWidth = 20
    DefaultRowHeight = 20
    RowCount = 20
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    TabOrder = 0
    OnKeyPress = ParamGridKeyPress
    OnSelectCell = ParamGridSelectCell
    ColWidths = (
      20
      144
      111)
  end
end
