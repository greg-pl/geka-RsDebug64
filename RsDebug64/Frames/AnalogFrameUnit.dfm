object AnalogFrame: TAnalogFrame
  Left = 0
  Top = 0
  Width = 499
  Height = 436
  TabOrder = 0
  object ShowTypePageCtrl: TPageControl
    Left = 0
    Top = 0
    Width = 499
    Height = 436
    ActivePage = WordSheet
    Align = alClient
    TabOrder = 0
    TabPosition = tpBottom
    object WordSheet: TTabSheet
      Caption = 'WORD'
      ImageIndex = 1
      OnShow = WordSheetShow
      object WordGRid: TStringGrid
        Left = 0
        Top = 33
        Width = 491
        Height = 377
        Align = alClient
        ColCount = 17
        DefaultColWidth = 40
        DefaultRowHeight = 18
        DefaultDrawing = False
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        ScrollBars = ssVertical
        TabOrder = 0
        OnDrawCell = GridDrawCell
        OnGetEditText = GridGetEditText
        OnKeyDown = GridKeyDown
        OnSetEditText = WordGRidSetEditText
      end
      object WordGridPanel: TPanel
        Left = 0
        Top = 0
        Width = 491
        Height = 33
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object Label3: TLabel
          Left = 8
          Top = 8
          Width = 58
          Height = 13
          Caption = 'ilo'#347#263' kolumn'
        end
        object WordColCntEdit: TSpinEdit
          Left = 76
          Top = 3
          Width = 57
          Height = 22
          MaxValue = 100
          MinValue = 4
          TabOrder = 0
          Value = 16
          OnChange = WordColCntEditChange
        end
      end
    end
    object DWordSheet: TTabSheet
      Caption = 'DWord'
      ImageIndex = 3
      OnShow = DWordSheetShow
      object DWordGrid: TStringGrid
        Left = 0
        Top = 0
        Width = 491
        Height = 410
        Align = alClient
        ColCount = 9
        DefaultColWidth = 90
        DefaultRowHeight = 18
        DefaultDrawing = False
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        TabOrder = 0
        OnDrawCell = GridDrawCell
        OnGetEditText = GridGetEditText
        OnKeyDown = GridKeyDown
        OnSetEditText = DWordGridSetEditText
      end
    end
    object FloatSheet: TTabSheet
      Caption = 'FLOAT'
      ImageIndex = 2
      OnShow = FloatSheetShow
      object FloatGrid: TStringGrid
        Left = 0
        Top = 0
        Width = 651
        Height = 563
        Align = alClient
        ColCount = 9
        DefaultColWidth = 90
        DefaultRowHeight = 18
        DefaultDrawing = False
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
        TabOrder = 0
        OnDrawCell = GridDrawCell
        OnGetEditText = GridGetEditText
        OnKeyDown = GridKeyDown
        OnSetEditText = FloatGridSetEditText
      end
    end
    object DFloatSheet: TTabSheet
      Caption = 'DFLOAT'
      ImageIndex = 8
      OnShow = DFloatSheetShow
      object DFloatGrid: TStringGrid
        Left = 0
        Top = 0
        Width = 651
        Height = 563
        Align = alClient
        ColCount = 9
        DefaultColWidth = 90
        DefaultRowHeight = 18
        DefaultDrawing = False
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
        TabOrder = 0
        OnDrawCell = GridDrawCell
        OnGetEditText = GridGetEditText
        OnKeyDown = GridKeyDown
        OnSetEditText = DFloatGridSetEditText
      end
    end
    object DspProgSheet: TTabSheet
      Caption = 'DspProg'
      ImageIndex = 4
      OnShow = DspProgSheetShow
      object DspProgGrid: TStringGrid
        Left = 0
        Top = 0
        Width = 651
        Height = 563
        Align = alClient
        ColCount = 9
        DefaultColWidth = 60
        DefaultRowHeight = 18
        DefaultDrawing = False
        TabOrder = 0
        OnDrawCell = GridDrawCell
        OnGetEditText = GridGetEditText
      end
    end
    object F1_15Sheet: TTabSheet
      Caption = '1.15'
      ImageIndex = 5
      OnShow = F1_15SheetShow
      object F1_15Grid: TStringGrid
        Left = 0
        Top = 0
        Width = 651
        Height = 563
        Align = alClient
        ColCount = 17
        DefaultRowHeight = 18
        DefaultDrawing = False
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        TabOrder = 0
        OnDrawCell = GridDrawCell
        OnGetEditText = GridGetEditText
        OnSetEditText = F1_15GridSetEditText
      end
    end
    object ChartSheet: TTabSheet
      Caption = 'Chart'
      ImageIndex = 6
      OnShow = ChartSheetShow
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 97
        Height = 410
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object SeriesListBox: TCheckListBox
          Left = 0
          Top = 49
          Width = 97
          Height = 216
          OnClickCheck = SeriesListBoxClickCheck
          Align = alTop
          ItemHeight = 13
          PopupMenu = ChartListMenu
          TabOrder = 0
        end
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 97
          Height = 49
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object Label1: TLabel
            Left = 0
            Top = 0
            Width = 67
            Height = 13
            Align = alTop
            Caption = 'Ilo'#347#263' kana'#322#243'w'
          end
          object SerCntEdit: TSpinEdit
            Left = 0
            Top = 19
            Width = 73
            Height = 22
            MaxValue = 32
            MinValue = 1
            TabOrder = 0
            Value = 4
            OnChange = SerCntEditChange
          end
        end
        object DataSizeBox: TRadioGroup
          Left = 0
          Top = 393
          Width = 97
          Height = 65
          Align = alTop
          Caption = 'Rozmiar danych'
          ItemIndex = 1
          Items.Strings = (
            'Byte'
            'Word'
            'DWord')
          TabOrder = 2
        end
        object SerieTypeBox: TRadioGroup
          Left = 0
          Top = 345
          Width = 97
          Height = 48
          Align = alTop
          Caption = 'Serie danych'
          ItemIndex = 0
          Items.Strings = (
            'abcabcabc'
            'aaabbbccc')
          TabOrder = 3
        end
        object DrawCharBtn: TButton
          Left = 0
          Top = 468
          Width = 79
          Height = 25
          Caption = 'Rysuj'
          TabOrder = 4
          OnClick = DrawCharBtnClick
        end
        object PointsBox: TCheckBox
          Left = 0
          Top = 496
          Width = 97
          Height = 17
          Caption = 'PointsBox'
          TabOrder = 5
          OnClick = PointsBoxClick
        end
        object RZ30MemBox: TCheckBox
          Left = 0
          Top = 453
          Width = 97
          Height = 17
          Caption = 'RZ30-Mem'
          TabOrder = 6
          OnClick = RZ30MemBoxClick
        end
        object DataTypeBox: TRadioGroup
          Left = 0
          Top = 265
          Width = 97
          Height = 80
          Align = alTop
          Caption = 'Typ danych'
          ItemIndex = 0
          Items.Strings = (
            'Singned'
            'Unsigned'
            'Float'
            'Double')
          TabOrder = 7
        end
        object Button1: TButton
          Left = 0
          Top = 520
          Width = 75
          Height = 25
          Caption = 'Analizuj'
          TabOrder = 8
          OnClick = Button1Click
        end
      end
      object Panel4: TPanel
        Left = 97
        Top = 0
        Width = 394
        Height = 410
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object MainChart: TChart
          Left = 0
          Top = 33
          Width = 554
          Height = 530
          BackWall.Brush.Color = clWhite
          BackWall.Brush.Style = bsClear
          Title.Text.Strings = (
            'TChart')
          Title.Visible = False
          Legend.Visible = False
          View3D = False
          View3DWalls = False
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object MeasurePanel: TPanel
            Left = 96
            Top = 168
            Width = 313
            Height = 225
            Caption = 'Pomiary'
            DragKind = dkDock
            DragMode = dmAutomatic
            TabOrder = 0
            Visible = False
            OnEndDock = MeasurePanelEndDock
            object MeasureGrid: TStringGrid
              Left = 1
              Top = 1
              Width = 311
              Height = 223
              Align = alClient
              ColCount = 11
              DefaultColWidth = 25
              DefaultRowHeight = 18
              RowCount = 7
              Font.Charset = EASTEUROPE_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Courier'
              Font.Style = []
              Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowMoving, goRowSelect]
              ParentFont = False
              TabOrder = 0
              ColWidths = (
                25
                82
                59
                48
                52
                25
                25
                25
                25
                25
                25)
            end
          end
        end
        object Panel5: TPanel
          Left = 0
          Top = 0
          Width = 554
          Height = 33
          Align = alTop
          BevelInner = bvLowered
          BevelOuter = bvNone
          TabOrder = 1
          object MinXEdit: TLabeledEdit
            Left = 96
            Top = 5
            Width = 49
            Height = 21
            EditLabel.Width = 30
            EditLabel.Height = 13
            EditLabel.Caption = 'X_Min'
            LabelPosition = lpLeft
            TabOrder = 0
            Text = '-1'
          end
          object MaxXEdit: TLabeledEdit
            Left = 200
            Top = 5
            Width = 49
            Height = 21
            EditLabel.Width = 33
            EditLabel.Height = 13
            EditLabel.Caption = 'X_Max'
            LabelPosition = lpLeft
            TabOrder = 1
            Text = '1'
          end
          object MinYEdit: TLabeledEdit
            Left = 296
            Top = 5
            Width = 49
            Height = 21
            EditLabel.Width = 30
            EditLabel.Height = 13
            EditLabel.Caption = 'Y_Min'
            LabelPosition = lpLeft
            TabOrder = 2
            Text = '-1'
          end
          object MaxYEdit: TLabeledEdit
            Left = 400
            Top = 5
            Width = 49
            Height = 21
            EditLabel.Width = 33
            EditLabel.Height = 13
            EditLabel.Caption = 'Y_Max'
            LabelPosition = lpLeft
            TabOrder = 3
            Text = '1'
          end
          object AutoXYBox: TCheckBox
            Left = 8
            Top = 7
            Width = 49
            Height = 17
            Caption = 'Auto'
            TabOrder = 4
            OnClick = AutoXYBoxClick
          end
          object Button2: TButton
            Left = 455
            Top = 5
            Width = 32
            Height = 21
            Caption = '<<'
            TabOrder = 5
            OnClick = Button2Click
          end
          object SaveM1Btn: TButton
            Tag = 1
            Left = 503
            Top = 4
            Width = 34
            Height = 21
            Caption = '-> M1'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 6
            OnClick = SaveM1BtnClick
          end
          object RestoreM1Btn: TButton
            Tag = 1
            Left = 543
            Top = 4
            Width = 34
            Height = 21
            Caption = 'M1->'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 7
            OnClick = RestoreM1BtnClick
          end
          object SaveM2Btn: TButton
            Tag = 2
            Left = 599
            Top = 4
            Width = 34
            Height = 21
            Caption = '-> M2'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 8
            OnClick = SaveM1BtnClick
          end
          object RestoreM2Btn: TButton
            Tag = 2
            Left = 639
            Top = 4
            Width = 34
            Height = 21
            Caption = 'M2->'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 9
            OnClick = RestoreM1BtnClick
          end
          object SaveM3Btn: TButton
            Tag = 3
            Left = 695
            Top = 4
            Width = 34
            Height = 21
            Caption = '-> M3'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 10
            OnClick = SaveM1BtnClick
          end
          object RestoreM3Btn: TButton
            Tag = 3
            Left = 735
            Top = 4
            Width = 34
            Height = 21
            Caption = 'M3->'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 11
            OnClick = RestoreM1BtnClick
          end
        end
      end
    end
    object WekSheet: TTabSheet
      Caption = 'Wektory'
      ImageIndex = 7
      OnShow = WekSheetShow
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 113
        Height = 410
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object Label2: TLabel
          Left = 0
          Top = 0
          Width = 113
          Height = 13
          Align = alTop
          Caption = 'Ilo'#347#263' wektor'#243'w'
        end
        object WekCntEdit: TSpinEdit
          Left = 0
          Top = 19
          Width = 105
          Height = 22
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier'
          Font.Style = []
          MaxValue = 32
          MinValue = 1
          ParentFont = False
          TabOrder = 0
          Value = 4
          OnChange = WekCntEditChange
        end
        object WekListBox: TListBox
          Left = 0
          Top = 48
          Width = 105
          Height = 265
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          PopupMenu = WekListMenu
          TabOrder = 1
        end
      end
      object WekChart: TChart
        Left = 113
        Top = 0
        Width = 378
        Height = 410
        BackWall.Brush.Color = clWhite
        BackWall.Brush.Style = bsClear
        Title.Text.Strings = (
          'TChart')
        Title.Visible = False
        BottomAxis.DateTimeFormat = 'yy-MM-dd'
        BottomAxis.LabelStyle = talValue
        LeftAxis.LabelsSize = 4
        LeftAxis.MinorTickCount = 5
        Legend.ColorWidth = 80
        Legend.LegendStyle = lsValues
        TopAxis.LabelsMultiLine = True
        TopAxis.LabelsSeparation = 90
        TopAxis.LabelsSize = 2
        TopAxis.LabelStyle = talValue
        TopAxis.MinorTickCount = 9
        View3D = False
        Align = alClient
        TabOrder = 1
        object WekSeries: TArrowSeries
          HorizAxis = aTopAxis
          Marks.ArrowLength = 0
          Marks.Frame.Visible = False
          Marks.Transparent = True
          Marks.Visible = False
          SeriesColor = clRed
          Pointer.HorizSize = 5
          Pointer.InflateMargins = False
          Pointer.Style = psRectangle
          Pointer.VertSize = 10
          Pointer.Visible = True
          XValues.DateTime = False
          XValues.Name = 'X'
          XValues.Multiplier = 1.000000000000000000
          XValues.Order = loAscending
          YValues.DateTime = False
          YValues.Name = 'Y'
          YValues.Multiplier = 1.000000000000000000
          YValues.Order = loNone
          EndXValues.DateTime = True
          EndXValues.Name = 'EndX'
          EndXValues.Multiplier = 1.000000000000000000
          EndXValues.Order = loNone
          EndYValues.DateTime = False
          EndYValues.Name = 'EndY'
          EndYValues.Multiplier = 1.000000000000000000
          EndYValues.Order = loNone
          StartXValues.DateTime = False
          StartXValues.Name = 'X'
          StartXValues.Multiplier = 1.000000000000000000
          StartXValues.Order = loAscending
          StartYValues.DateTime = False
          StartYValues.Name = 'Y'
          StartYValues.Multiplier = 1.000000000000000000
          StartYValues.Order = loNone
        end
      end
    end
  end
  object ChartListMenu: TPopupMenu
    Left = 40
    Top = 112
    object EditNameItem: TMenuItem
      Caption = 'Zmie'#324' nazw'#281
      OnClick = EditNameItemClick
    end
    object EditKolorItem: TMenuItem
      Caption = 'Zmiene'#324' kolor'
      OnClick = EditKolorItemClick
    end
    object AllOnItem: TMenuItem
      Caption = 'Za'#322#261'cz wszystkie'
      OnClick = AllOnItemClick
    end
    object AllOffItem: TMenuItem
      Caption = 'Wy'#322#261'cz wszystkie'
      OnClick = AllOffItemClick
    end
  end
  object ColorDialog1: TColorDialog
    Left = 80
    Top = 72
  end
  object WekListMenu: TPopupMenu
    Left = 40
    Top = 72
    object Zmienazw1: TMenuItem
      Caption = 'Zmie'#324' nazw'#281
      OnClick = Zmienazw1Click
    end
    object Zmiekolor1: TMenuItem
      Caption = 'Zmie'#324' kolor'
      OnClick = Zmiekolor1Click
    end
  end
end
