inherited TypeDefEditForm: TTypeDefEditForm
  Left = 625
  Top = 458
  Width = 637
  Height = 554
  Caption = 'TypeDefEditForm'
  OldCreateOrder = True
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter [0]
    Left = 249
    Top = 70
    Width = 3
    Height = 397
    Cursor = crHSplit
  end
  object TypeDefTree: TTreeView [1]
    Left = 0
    Top = 70
    Width = 249
    Height = 397
    Align = alLeft
    DragMode = dmAutomatic
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    Images = TreeImages
    Indent = 19
    MultiSelect = True
    MultiSelectStyle = [msControlSelect, msShiftSelect]
    ParentFont = False
    PopupMenu = TreePopUpMenu
    TabOrder = 0
    OnChange = TypeDefTreeChange
    OnDblClick = TypeDefTreeDblClick
    OnDeletion = TypeDefTreeDeletion
    OnDragDrop = TypeDefTreeDragDrop
    OnDragOver = TypeDefTreeDragOver
    OnEdited = TypeDefTreeEdited
    OnEditing = TypeDefTreeEditing
    OnGetImageIndex = TypeDefTreeGetImageIndex
    OnGetSelectedIndex = TypeDefTreeGetSelectedIndex
  end
  object Panel1: TPanel [2]
    Left = 0
    Top = 467
    Width = 629
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object SaveBtn: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Save'
      ModalResult = 1
      TabOrder = 0
      OnClick = SaveBtnClick
    end
  end
  object Panel2: TPanel [3]
    Left = 252
    Top = 70
    Width = 377
    Height = 397
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 5
    object Splitter2: TSplitter
      Left = 0
      Top = 226
      Width = 377
      Height = 8
      Cursor = crVSplit
      Align = alBottom
    end
    object InfoMemo: TMemo
      Left = 0
      Top = 234
      Width = 377
      Height = 163
      TabStop = False
      Align = alBottom
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
    end
    object ExpandTreeView: TTreeView
      Left = 0
      Top = 0
      Width = 377
      Height = 226
      Align = alClient
      Images = TreeImages
      Indent = 19
      ReadOnly = True
      TabOrder = 1
      OnChange = ExpandTreeViewChange
      OnDeletion = TypeDefTreeDeletion
      OnGetImageIndex = TypeDefTreeGetImageIndex
      OnGetSelectedIndex = TypeDefTreeGetSelectedIndex
    end
  end
  inherited StatusBar: TStatusBar
    Top = 508
    Width = 629
    Visible = False
  end
  inherited ToolBar1: TToolBar
    Width = 629
  end
  inherited ParamPanel: TPanel
    Width = 629
  end
  object TreePopUpMenu: TPopupMenu [9]
    OnPopup = TreePopUpMenuPopup
    Left = 144
    Top = 200
    object EditItem: TMenuItem
      Caption = 'Edytuj'
      Default = True
      OnClick = EditItemClick
    end
    object EditNameItem: TMenuItem
      Caption = 'Zmie'#324' nazw'#281
      OnClick = EditNameItemClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object AddStruktItem: TMenuItem
      Caption = 'Dodaj struktur'#281
      OnClick = AddStruktItemClick
    end
    object AddSimleType: TMenuItem
      Caption = 'Dodaj typ prosty'
      OnClick = AddSimleTypeClick
    end
    object AddFieldItem: TMenuItem
      Caption = 'Dodaj pole typu'
      OnClick = AddFieldItemClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object DelItem: TMenuItem
      Caption = 'Usu'#324
      OnClick = DelItemClick
    end
  end
end
