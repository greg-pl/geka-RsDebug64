object BinaryFrame: TBinaryFrame
  Left = 0
  Top = 0
  Width = 499
  Height = 436
  TabOrder = 0
  object ByteGrid: TStringGrid
    Left = 0
    Top = 33
    Width = 499
    Height = 403
    Align = alClient
    ColCount = 18
    DefaultColWidth = 21
    DefaultRowHeight = 18
    DefaultDrawing = False
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    TabOrder = 0
    OnDrawCell = GridDrawCell
    OnGetEditText = GridGetEditText
    OnKeyDown = GridKeyDown
    OnSelectCell = ByteGridSelectCell
    OnSetEditText = ByteGridSetEditText
  end
  object ByteGridPanel: TPanel
    Left = 0
    Top = 0
    Width = 499
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label4: TLabel
      Left = 8
      Top = 8
      Width = 58
      Height = 13
      Caption = 'ilo'#347#263' kolumn'
    end
    object ByteColCntEdit: TSpinEdit
      Left = 76
      Top = 3
      Width = 57
      Height = 22
      MaxValue = 100
      MinValue = 4
      TabOrder = 0
      Value = 16
      OnChange = ByteColCntEditChange
    end
  end
end
