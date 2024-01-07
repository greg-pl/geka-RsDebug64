object SettingForm: TSettingForm
  Left = 470
  Top = 145
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'SettingForm'
  ClientHeight = 609
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  DesignSize = (
    425
    609)
  PixelsPerInch = 96
  TextHeight = 13
  object OkBtn: TButton
    Left = 250
    Top = 577
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OkBtnClick
    ExplicitLeft = 221
    ExplicitTop = 518
  end
  object Button2: TButton
    Left = 338
    Top = 577
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
    ExplicitLeft = 309
    ExplicitTop = 518
  end
  object PageControl1: TPageControl
    Left = 5
    Top = 4
    Width = 414
    Height = 566
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    ExplicitWidth = 385
    ExplicitHeight = 507
    object TabSheet1: TTabSheet
      Caption = 'Og'#243'lne'
      ExplicitWidth = 377
      ExplicitHeight = 479
      object Label1: TLabel
        Left = 4
        Top = 4
        Width = 167
        Height = 17
        Alignment = taRightJustify
        Caption = 'Save setting on shutdown'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Left = 4
        Top = 28
        Width = 174
        Height = 17
        Alignment = taRightJustify
        Caption = 'Autom. refresh of variables'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label3: TLabel
        Left = 25
        Top = 102
        Width = 233
        Height = 17
        Alignment = taRightJustify
        Caption = 'Connect memory regions below (bt)'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label4: TLabel
        Left = 143
        Top = 126
        Width = 115
        Height = 17
        Alignment = taRightJustify
        Caption = 'Max. variable size'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object MaxVarSizeEdit: TSpinEdit
        Left = 274
        Top = 125
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
        TabOrder = 4
        Value = 16
      end
      object AutoRefreshmapBox: TComboBox
        Left = 191
        Top = 27
        Width = 73
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 1
        Text = 'NO'
        Items.Strings = (
          'NO'
          'YES'
          'ASK')
      end
      object AutoSaveBox: TComboBox
        Left = 191
        Top = 3
        Width = 73
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'NO'
        Items.Strings = (
          'NO'
          'YES'
          'ASK')
      end
      object ScalMemEdit: TSpinEdit
        Left = 274
        Top = 102
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
        TabOrder = 3
        Value = 10
      end
      object MotorolaBox: TRadioGroup
        Left = 10
        Top = 160
        Width = 96
        Height = 76
        Caption = 'Byte order'
        ItemIndex = 0
        Items.Strings = (
          'Litle indian'
          'Big indian')
        TabOrder = 5
      end
      object WinTabsBox: TRadioGroup
        Left = 245
        Top = 160
        Width = 75
        Height = 76
        Caption = 'WinTabs'
        Items.Strings = (
          'Off'
          'Top'
          'Bottom')
        TabOrder = 7
      end
      object MainPtrSizeGrp: TRadioGroup
        Left = 126
        Top = 160
        Width = 95
        Height = 76
        Caption = 'PtrSize'
        ItemIndex = 2
        Items.Strings = (
          '8bit'
          '16bit'
          '32bit')
        TabOrder = 6
      end
      object ObjdumpPathEdit: TLabeledEdit
        Left = 11
        Top = 322
        Width = 349
        Height = 25
        EditLabel.Width = 151
        EditLabel.Height = 17
        EditLabel.Caption = 'Path to "objdump" tools'
        EditLabel.Font.Charset = EASTEUROPE_CHARSET
        EditLabel.Font.Color = clWindowText
        EditLabel.Font.Height = -15
        EditLabel.Font.Name = 'Arial'
        EditLabel.Font.Style = []
        EditLabel.ParentFont = False
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        TabOrder = 8
      end
      object LoadOnStartUpBox: TCheckBox
        Left = 3
        Top = 69
        Width = 247
        Height = 17
        Caption = 'Load last map file on start up'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object ShowSpeedBox: TCheckBox
        Left = 14
        Top = 277
        Width = 247
        Height = 17
        Caption = 'Show message abou transfer speed'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        TabOrder = 9
      end
    end
  end
  inline SectionsDefFrame: TSectionsDefFrame
    Left = 20
    Top = 392
    Width = 349
    Height = 161
    TabOrder = 3
    ExplicitLeft = 20
    ExplicitTop = 392
    ExplicitWidth = 349
    ExplicitHeight = 161
    inherited Panel1: TPanel
      Width = 349
      Height = 161
      ExplicitWidth = 349
      ExplicitHeight = 178
      inherited Label1: TLabel
        Width = 108
        Font.Name = 'MS Sans Serif'
        ExplicitWidth = 108
      end
      inherited SectionsListMemo: TMemo
        Width = 159
        Height = 139
        ExplicitWidth = 159
        ExplicitHeight = 156
      end
    end
  end
end
