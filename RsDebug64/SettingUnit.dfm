object SettingForm: TSettingForm
  Left = 470
  Top = 145
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'SettingForm'
  ClientHeight = 422
  ClientWidth = 450
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object OkBtn: TButton
    Left = 280
    Top = 392
    Width = 75
    Height = 25
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OkBtnClick
  end
  object Button2: TButton
    Left = 368
    Top = 392
    Width = 75
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object PageControl1: TPageControl
    Left = 5
    Top = 4
    Width = 444
    Height = 381
    ActivePage = TabSheet1
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Og'#243'lne'
      object Label1: TLabel
        Left = 74
        Top = 8
        Width = 200
        Height = 17
        Alignment = taRightJustify
        Caption = 'Zapisz ustawienia przy wyj'#347'ciu'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Left = 111
        Top = 32
        Width = 163
        Height = 17
        Alignment = taRightJustify
        Caption = 'Autom. od'#347'wie'#380' plik MAP'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label3: TLabel
        Left = 30
        Top = 56
        Width = 242
        Height = 17
        Alignment = taRightJustify
        Caption = #321#261'cz obszary do czytania poni'#380'ej (bt)'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label4: TLabel
        Left = 125
        Top = 80
        Width = 147
        Height = 17
        Alignment = taRightJustify
        Caption = 'Max. rozmiar zmiennej'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object MaxVarSizeEdit: TSpinEdit
        Left = 288
        Top = 80
        Width = 65
        Height = 22
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier'
        Font.Style = []
        MaxValue = 0
        MinValue = 0
        ParentFont = False
        TabOrder = 0
        Value = 16
      end
      object AutoRefreshmapBox: TComboBox
        Left = 287
        Top = 31
        Width = 73
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 1
        Text = 'TAK'
        Items.Strings = (
          'TAK'
          'NIE'
          'PYTAJ')
      end
      object AutoSaveBox: TComboBox
        Left = 287
        Top = 7
        Width = 73
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 2
        Text = 'TAK'
        Items.Strings = (
          'TAK'
          'NIE'
          'PYTAJ')
      end
      object GroupBox1: TGroupBox
        Left = 16
        Top = 120
        Width = 153
        Height = 73
        Caption = 'W listach zmienny umie'#347#263':'
        TabOrder = 3
        object SelectAsmBox: TCheckBox
          Left = 8
          Top = 16
          Width = 137
          Height = 17
          Caption = 'Zmienne assemblera'
          TabOrder = 0
        end
        object SelectC_Box: TCheckBox
          Left = 8
          Top = 32
          Width = 97
          Height = 17
          Caption = 'Zmienne "C"'
          TabOrder = 1
        end
        object SelectSysBox: TCheckBox
          Left = 8
          Top = 48
          Width = 129
          Height = 17
          Caption = 'Zmienne systemowe'
          TabOrder = 2
        end
      end
      object ScalMemEdit: TSpinEdit
        Left = 288
        Top = 56
        Width = 65
        Height = 22
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier'
        Font.Style = []
        MaxValue = 200
        MinValue = 2
        ParentFont = False
        TabOrder = 4
        Value = 10
      end
      object SectionBox: TGroupBox
        Left = 192
        Top = 120
        Width = 169
        Height = 161
        Caption = 'Przynale'#380'no'#347'c do sekcji '
        TabOrder = 5
        object AllSectionBox: TRadioButton
          Left = 8
          Top = 16
          Width = 113
          Height = 17
          Caption = 'Wszystkie zmienne'
          TabOrder = 0
        end
        object SelSectionBox: TRadioButton
          Left = 8
          Top = 32
          Width = 137
          Height = 17
          Caption = 'Tylko z zmienne z sekcji'
          TabOrder = 1
        end
        object SectionsEdit: TMemo
          Left = 8
          Top = 72
          Width = 153
          Height = 81
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier'
          Font.Style = []
          Lines.Strings = (
            '.text')
          ParentFont = False
          TabOrder = 2
        end
        object SelNoSectionBox: TRadioButton
          Left = 8
          Top = 48
          Width = 137
          Height = 17
          Caption = 'Za wyj'#261'tkiem sekcji'
          Checked = True
          TabOrder = 3
          TabStop = True
        end
      end
      object MotorolaBox: TRadioGroup
        Left = 16
        Top = 200
        Width = 153
        Height = 65
        Caption = 'Porz'#261'dek pami'#281'ci'
        ItemIndex = 0
        Items.Strings = (
          'Intel'
          'Motorola')
        TabOrder = 6
      end
      object WinTabsBox: TRadioGroup
        Left = 16
        Top = 272
        Width = 153
        Height = 65
        Caption = 'WinTabs'
        Items.Strings = (
          'Off'
          'Top'
          'Bottom')
        TabOrder = 7
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Obszary pami'#281'ci'
      ImageIndex = 1
      OnShow = TabSheet2Show
      object AreaGrid: TStringGrid
        Left = 0
        Top = 8
        Width = 433
        Height = 201
        ColCount = 6
        DefaultColWidth = 20
        DefaultRowHeight = 20
        RowCount = 30
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        OnSetEditText = AreaGridSetEditText
        ColWidths = (
          20
          40
          65
          95
          110
          74)
      end
      object MainPtrSizeGrp: TRadioGroup
        Left = 8
        Top = 208
        Width = 97
        Height = 65
        Caption = 'PtrSize'
        ItemIndex = 2
        Items.Strings = (
          '8bit'
          '16bit'
          '32bit')
        TabOrder = 1
      end
    end
  end
end
