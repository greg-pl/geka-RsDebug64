object MainForm: TMainForm
  Left = 2288
  Top = 341
  Caption = 'MainForm'
  ClientHeight = 532
  ClientWidth = 714
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SplitterBottom: TSplitter
    Left = 0
    Top = 509
    Width = 714
    Height = 4
    Cursor = crVSplit
    Align = alBottom
    Color = clBtnFace
    ParentColor = False
    ExplicitTop = 380
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 513
    Width = 714
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 150
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object WinTabPanel: TPanel
    Left = 0
    Top = 487
    Width = 714
    Height = 22
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object WinTabControl: TTabControl
      Left = 0
      Top = 0
      Width = 714
      Height = 22
      Align = alClient
      PopupMenu = WinTabMenu
      TabOrder = 0
      OnMouseDown = WinTabControlMouseDown
    end
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 714
    Height = 28
    Bands = <
      item
        Control = ButtonBar
        ImageIndex = -1
        Width = 717
      end>
    Color = clBtnFace
    EdgeInner = esNone
    EdgeOuter = esNone
    ParentColor = False
    object ButtonBar: TToolBar
      Left = 11
      Top = 0
      Width = 703
      Height = 25
      Caption = 'ButtonBar'
      Images = ImageList1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Action = SaveSettingsAct
      end
      object ToolButton2: TToolButton
        Left = 23
        Top = 0
        Action = SettingsAct
      end
      object ToolButton3: TToolButton
        Left = 46
        Top = 0
        Action = RefreshMapFileAct
      end
      object ToolButton4: TToolButton
        Left = 69
        Top = 0
        Action = ConnectionconfigAct
      end
      object ConnectBtn: TToolButton
        Left = 92
        Top = 0
        Action = ConnectAct
      end
    end
  end
  object ActionList1: TActionList
    Images = ImageList1
    Left = 248
    Top = 88
    object OpenCloseDevAct: TAction
      Caption = 'Open/Close'
      Hint = 'Open/Close'
      ShortCut = 123
    end
    object MinimizeAllAct: TAction
      Category = 'WIN'
      Caption = 'Minimize all'
      OnExecute = MinimizeAllActExecute
    end
    object CloseAllAct: TAction
      Category = 'WIN'
      Caption = 'Close all'
      OnExecute = CloseAllActExecute
    end
    object EditConnectionAct: TAction
      Caption = 'Po'#322#261'czenie'
      OnUpdate = EditConnectionActUpdate
    end
    object ConnectAct: TAction
      Caption = 'Po'#322#261'cz'
      Hint = 'Connect/Disconnect'
      ImageIndex = 4
      OnExecute = ConnectActExecute
    end
    object GetDrvParamsAct: TAction
      Caption = 'Poka'#380' parametry drivera'
      OnExecute = GetDrvParamsActExecute
      OnUpdate = GetDrvParamsActUpdate
    end
    object SetDrvParamsAct: TAction
      Caption = 'Ustaw parametry drivera'
      OnExecute = SetDrvParamsActExecute
      OnUpdate = GetDrvParamsActUpdate
    end
    object MinimizeAct: TAction
      Category = 'WIN'
      Caption = 'Minimize'
      OnExecute = MinimizeActExecute
    end
    object CloseAct: TAction
      Category = 'WIN'
      Caption = 'Close'
      OnExecute = CloseActExecute
    end
    object RestoreAct: TAction
      Category = 'WIN'
      Caption = 'Restore'
      ImageIndex = 3
      OnExecute = RestoreActExecute
    end
    object RestoreAllAct: TAction
      Category = 'WIN'
      Caption = 'Restore All'
      OnExecute = RestoreAllActExecute
    end
    object RefreshComListAct: TAction
      Caption = 'Od'#347'wie'#380' list'#281' COM'#39#243'w'
      ShortCut = 16507
    end
    object TerminalAct: TAction
      Category = 'DebugWin'
      Caption = 'Terminal'
      OnExecute = TerminalActExecute
      OnUpdate = TerminalActUpdate
    end
    object PictureWinAct: TAction
      Category = 'DebugWin'
      Caption = 'Obraz'
      OnExecute = PictureWinActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object MemoryWinAct: TAction
      Category = 'DebugWin'
      Caption = 'Pami'#281#263
      ShortCut = 16464
      OnExecute = MemoryWinActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object VarListWinAct: TAction
      Category = 'DebugWin'
      Caption = 'Lista zmiennych'
      OnExecute = VarListWinActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object StructWinAct: TAction
      Category = 'DebugWin'
      Caption = 'Struktury'
      OnExecute = StructWinActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object GeneratorWinAct: TAction
      Category = 'DebugWin'
      Caption = 'Generator sygna'#322#243'w'
      OnExecute = GeneratorWinActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object UploadWinAct: TAction
      Category = 'DebugWin'
      Caption = 'Upload/Download'
      OnExecute = UploadWinActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object SaveSettingsAct: TAction
      Caption = 'Zapisz ustawienia'
      Hint = 'Zapisz ustawienia'
      ImageIndex = 0
      OnExecute = SaveSettingsActExecute
    end
    object SettingsAct: TAction
      Caption = 'Ustawienia'
      Hint = 'Ustawienia'
      ImageIndex = 1
      OnExecute = SettingsActExecute
    end
    object RefreshMapFileAct: TAction
      Caption = 'Od'#347'wie'#380' plik MAP'
      Hint = 'Od'#347'wie'#380' plik MAP'
      ImageIndex = 2
      OnExecute = RefreshMapFileActExecute
      OnUpdate = RefreshMapFileActUpdate
    end
    object IsModbusStdAct: TAction
      Category = 'ModbusStd'
      Caption = 'Modbus_Std'
      OnExecute = IsModbusStdActExecute
      OnUpdate = IsModbusStdActUpdate
    end
    object MemRegistersAct: TAction
      Category = 'ModbusStd'
      Caption = 'Registers'
      OnExecute = MemRegistersActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object MemAnalogInputAct: TAction
      Category = 'ModbusStd'
      Caption = 'Analog Inputs'
      OnExecute = MemAnalogInputActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object MemCoilAct: TAction
      Category = 'ModbusStd'
      Caption = 'Coils'
      OnExecute = MemCoilActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object MemBinaryInputAct: TAction
      Category = 'ModbusStd'
      Caption = 'Binary Inputs'
      OnExecute = MemBinaryInputActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object actRZ40EventReader: TAction
      Category = 'ModbusStd'
      Caption = 'Rz40 Event Reader'
      OnExecute = actRZ40EventReaderExecute
    end
    object RfcWinAct: TAction
      Category = 'DebugWin'
      Caption = 'Rfc Execute'
      OnExecute = RfcWinActExecute
      OnUpdate = MemoryWinActUpdate
    end
    object ConnectionconfigAct: TAction
      Caption = 'ConnectionconfigAct'
      Hint = 'Connection configuration'
      ImageIndex = 3
      OnExecute = ConnectionconfigActExecute
      OnUpdate = ConnectionconfigActUpdate
    end
  end
  object MainMenu1: TMainMenu
    Left = 296
    Top = 32
    object Fiel1: TMenuItem
      Caption = 'Plik'
      Hint = 'Zapisz ustawienia'
      OnClick = SaveSettingsActExecute
      object Open1: TMenuItem
        Action = OpenCloseDevAct
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object SetConnStrItem: TMenuItem
        Action = EditConnectionAct
      end
      object SettingItem: TMenuItem
        Action = SettingsAct
      end
      object SaveSettings: TMenuItem
        Action = SaveSettingsAct
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object OdwielistCOMw1: TMenuItem
        Action = RefreshComListAct
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object OpenMapFileItem: TMenuItem
        Caption = 'Otw'#243'rz plik map'
        OnClick = OpenMapFileItemClick
      end
      object ReloadMapFileItem: TMenuItem
        Caption = 'Od'#347'wie'#380' plik MAP'
      end
      object FilemapItem: TMenuItem
        Caption = 'Pliki Map'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object definicje1: TMenuItem
      Caption = 'Definicje'
      GroupIndex = 30
      object DefTypesItem: TMenuItem
        Caption = 'Definicje typ'#243'w'
        OnClick = DefTypesItemClick
      end
      object ImportTypesItem: TMenuItem
        Caption = 'Import typ'#243'w ...'
        OnClick = ImportTypesItemClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Definicjioperacji1: TMenuItem
        Caption = 'Operacje definiowane'
      end
    end
    object RZ301: TMenuItem
      Caption = 'Debug'
      GroupIndex = 30
      object Pokaparametrydrivera1: TMenuItem
        Action = GetDrvParamsAct
      end
      object Ustawparametrydrivera1: TMenuItem
        Action = SetDrvParamsAct
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object erminal1: TMenuItem
        Action = TerminalAct
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Pami1: TMenuItem
        Action = MemoryWinAct
        GroupIndex = 31
      end
      object VarListItem: TMenuItem
        Action = VarListWinAct
        GroupIndex = 31
      end
      object Struktury1: TMenuItem
        Action = StructWinAct
        GroupIndex = 31
      end
      object SygGenItem: TMenuItem
        Action = GeneratorWinAct
        GroupIndex = 31
      end
      object Obraz1: TMenuItem
        Action = PictureWinAct
        GroupIndex = 31
      end
      object UpLoadFileItem: TMenuItem
        Action = UploadWinAct
        GroupIndex = 31
      end
      object RfcExecute1: TMenuItem
        Action = RfcWinAct
        GroupIndex = 31
      end
    end
    object ModbusStd1: TMenuItem
      Action = IsModbusStdAct
      GroupIndex = 30
      object BinaryInputs1: TMenuItem
        Action = MemBinaryInputAct
      end
      object Coils1: TMenuItem
        Action = MemCoilAct
      end
      object AnalogInputs1: TMenuItem
        Action = MemAnalogInputAct
      end
      object Registers1: TMenuItem
        Action = MemRegistersAct
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Rz40EventReader1: TMenuItem
        Action = actRZ40EventReader
      end
    end
    object OknoItem: TMenuItem
      Caption = 'Okno'
      GroupIndex = 30
      OnClick = OknoItemClick
      object Minimizeall1: TMenuItem
        Action = MinimizeAllAct
      end
      object Closeall1: TMenuItem
        Action = CloseAllAct
      end
      object SplitWindowitem: TMenuItem
        Caption = '-'
      end
      object ala1: TMenuItem
        Caption = 'ala'
      end
    end
    object Oprogramie1: TMenuItem
      Caption = 'O programie'
      GroupIndex = 30
      OnClick = Oprogramie1Click
    end
  end
  object WinTabMenu: TPopupMenu
    Left = 384
    Top = 32
    object MinimizeItem: TMenuItem
      Action = MinimizeAct
    end
    object RestoreItem: TMenuItem
      Action = RestoreAct
    end
    object CloseItem: TMenuItem
      Action = CloseAct
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object MinimizeAllItem: TMenuItem
      Action = MinimizeAllAct
    end
    object RestoreAll1: TMenuItem
      Action = RestoreAllAct
    end
  end
  object ImageList1: TImageList
    Left = 185
    Top = 56
    Bitmap = {
      494C0101060009004C0010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF0000FF000000FF0000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF0000FF00000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF0000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C00000FF000000FF000000FF000000FF000000FF
      0000C0C0C000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000FF00
      0000FF00000000000000000000000000000000000000FF000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C00000FF000000FF000000FF
      0000C0C0C000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FF0000FF000000000000000000000000000000FF000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C00000FF000000FF000000FF000000FF
      0000C0C0C000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000FF00
      0000FF00000000000000000000000000000000000000FF000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C00000FF000000FF000000FF0000C0C0C00000FF
      0000C0C0C000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF0000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000C0C0
      C00000FF000000FF000000FF000000FF000000FF0000C0C0C000C0C0C00000FF
      0000C0C0C000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF0000FF00000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000C0C0
      C00000FF000000FF000000FF000000FF0000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF0000FF000000FF0000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FF000000FF
      000000FF000000FF000000FF000000FF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000800000000000
      000000000000FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF000000FF000000FF000000FF00000000000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080000000800000008000
      000000000000FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000C6C6C6000000
      00000084840000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FF000000FF000000FF000000FF00000000000000FF000000FF000000FF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000080000000800000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000C6C6C6000000
      00000084840000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF000000FF000000FF000000FF0000000000000000000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000000000000000
      00000084840000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000FF000000FF
      000000FF00000000000000FF000000FF000000000000000000000000000000FF
      000000FF000000FF000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000008484000084840000848400008484000084840000848400008484000084
      84000084840000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000FF000000FF
      000000000000000000000000000000FF00000000000000000000000000000000
      000000FF000000FF000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000000000000084
      84000084840000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000084840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      00000084840000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF000000
      0000000000000000000000000000800000000000000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000084840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      00000084840000000000000000000000000000000000FFFFFF00000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000080000000800000000000000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000084840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008000000080000000000000000000000000FF000000FF
      00000000000000000000000000000000000000FF000000000000000000000000
      000000FF000000FF000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000084840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C6000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008000000080000000000000000000000000FF000000FF
      000000FF000000000000000000000000000000FF000000FF00000000000000FF
      000000FF000000FF000000000000000000000000000000000000000000000000
      0000000000008000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000800000008000000000000000000000000000000000FF
      000000FF000000FF0000000000000000000000FF000000FF000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      0000800000008000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000000000000000000000000000000000
      000000FF000000FF000000FF00000000000000FF000000FF000000FF000000FF
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000800000008000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000000000000000000000000000000000
      00000000000000FF000000FF00000000000000FF000000FF000000FF000000FF
      000000FF000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000800000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FF000000FF000000FF000000FF
      000000FF000000FF000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF00000000FFFFC00300000000
      E3FF800100000000E0FF800100000000E07F800100000000E01F800100000000
      E007800100000000E003800100000000E007800100000000E01F800100000000
      E07F800100000000E0FF800100000000E3FF800100000000FFFF800100000000
      FFFFC00300000000FFFFFFFF00000000FF7EFFFFFFFFFFB0BFFF000FC0FFFF90
      F003000FE09FFE00E003000FF08FFE90E003000FE0C7FEBFE003000FC4E3FEFF
      E003000FCEF3FEFF2003000F9FF9FEFFE002008E9FF9FEFFE00311449FF9FEFF
      E0030AB8CF73FEFFE003057CC723FAFFE003FAFCE30702FFFFFFFDF8F10F00FF
      BF7DFE04F90703FF7F7EFFFFFF030BFF00000000000000000000000000000000
      000000000000}
  end
end
