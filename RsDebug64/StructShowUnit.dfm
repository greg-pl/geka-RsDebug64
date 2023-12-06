inherited StructShowForm: TStructShowForm
  Left = 2155
  Top = 123
  Width = 512
  Height = 417
  Caption = 'StructShowForm'
  OldCreateOrder = True
  Position = poDefaultPosOnly
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StructTreeView: TTreeView [0]
    Left = 0
    Top = 89
    Width = 496
    Height = 270
    Align = alClient
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier'
    Font.Style = []
    Images = TreeImages
    Indent = 19
    ParentFont = False
    PopupMenu = PopupMenu1
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    OnChange = StructTreeViewChange
    OnCollapsed = StructTreeViewCollapsed
    OnCustomDraw = StructTreeViewCustomDraw
    OnCustomDrawItem = StructTreeViewCustomDrawItem
    OnDblClick = StructTreeViewDblClick
    OnExpanded = StructTreeViewExpanded
    OnGetImageIndex = StructTreeViewGetImageIndex
    OnGetSelectedIndex = StructTreeViewGetSelectedIndex
    OnKeyPress = StructTreeViewKeyPress
  end
  inherited StatusBar: TStatusBar
    Top = 359
    Width = 496
  end
  inherited ToolBar1: TToolBar
    Width = 496
    object RdMemBtn: TToolButton
      Left = 178
      Top = 0
      Action = ReadMemAct
    end
    object AutoRepBtn: TToolButton
      Left = 201
      Top = 0
      Action = AutoReadAct
    end
    object ToolButton1: TToolButton
      Left = 224
      Top = 0
      Width = 18
      Caption = 'ToolButton1'
      ImageIndex = 8
      Style = tbsSeparator
    end
  end
  inherited ParamPanel: TPanel
    Width = 496
    Height = 60
    object Label1: TLabel
      Left = 8
      Top = 33
      Width = 76
      Height = 16
      Caption = 'Typ zmiennej'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 8
      Top = 9
      Width = 34
      Height = 16
      Caption = 'Adres'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 234
      Top = 9
      Width = 59
      Height = 16
      Caption = 'Io'#347#263' powt.'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 320
      Top = 9
      Width = 86
      Height = 16
      Caption = 'Czas rep [ms] '
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object AdresBox: TComboBox
      Left = 43
      Top = 4
      Width = 109
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      Text = '0'
      OnExit = AdresBoxExit
      Items.Strings = (
        '0'
        '0x4000'
        '0x8000'
        '0x800000')
    end
    object VarListBox: TComboBox
      Left = 158
      Top = 4
      Width = 50
      Height = 21
      Style = csDropDownList
      DropDownCount = 20
      ItemHeight = 13
      Sorted = True
      TabOrder = 1
      OnChange = VarListBoxChange
      OnDropDown = VarListBoxDropDown
      OnExit = VarListBoxExit
      Items.Strings = (
        '1000'
        '250'
        '500')
    end
    object TypeDefBox: TComboBox
      Left = 99
      Top = 28
      Width = 109
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
      OnChange = TypeDefBoxChange
      Items.Strings = (
        '0'
        '4000'
        '8000'
        '800000')
    end
    object RepCntEdit: TSpinEdit
      Left = 236
      Top = 28
      Width = 53
      Height = 22
      MaxValue = 10000
      MinValue = 1
      TabOrder = 3
      Value = 1
      OnChange = TypeDefBoxChange
    end
    object AutoRepTmEdit: TComboBox
      Left = 323
      Top = 28
      Width = 78
      Height = 21
      ItemHeight = 13
      TabOrder = 4
      Text = '500'
      OnExit = AutoRepTmEditExit
      Items.Strings = (
        '250'
        '500'
        '1000')
    end
  end
  object PopupMenu1: TPopupMenu [4]
    Left = 128
    Top = 224
    object Edytuj1: TMenuItem
      Action = EditAct
      Default = True
    end
    object Kopiujadres1: TMenuItem
      Action = CopyAdressAct
    end
    object Pokapami1: TMenuItem
      Action = ShowWinAct
    end
    object EditTitleAct1: TMenuItem
      Action = EditTitleAct
    end
    object Closewindow1: TMenuItem
      Caption = 'Close window'
      ImageIndex = 0
    end
  end
  object ActionList1: TActionList [5]
    Images = ToolBarImgList
    Left = 248
    Top = 224
    object AutoReadAct: TAction
      Caption = 'Auto'
      GroupIndex = 1
      ImageIndex = 7
      ShortCut = 119
      OnExecute = AutoReadActExecute
      OnUpdate = AutoReadActUpdate
    end
    object ShowWinAct: TAction
      Caption = 'Poka'#380' pami'#281#263
      OnExecute = ShowWinActExecute
      OnUpdate = ShowWinActUpdate
    end
    object CopyAdressAct: TAction
      Caption = 'Kopiuj adres'
      OnExecute = CopyAdressActExecute
      OnUpdate = ShowWinActUpdate
    end
    object ReadMemAct: TAction
      Caption = 'R'
      ImageIndex = 4
      ShortCut = 116
      OnExecute = ReadMemActExecute
      OnUpdate = ReadMemActUpdate
    end
    object EditAct: TAction
      Caption = 'Edytuj'
      OnExecute = EditActExecute
      OnUpdate = EditActUpdate
    end
    object TypeDefAct: TAction
      Caption = 'TypeDefAct'
      OnExecute = TypeDefActExecute
    end
  end
  inherited ActionList2: TActionList
    Left = 280
    Top = 224
  end
  inherited TreeImages: TImageList
    Left = 88
    Top = 224
  end
  object AutoRepTimer: TTimer [8]
    Enabled = False
    OnTimer = AutoRepTimerTimer
    Left = 312
    Top = 224
  end
  inherited ToolBarImgList: TImageList
    Left = 56
    Top = 224
  end
end
