program RsDebug64;

uses
  Forms,
  Main in 'Main.pas' {MainForm},

  ExtG2MemoUnit in 'DComp\ExtG2MemoUnit.pas',

  RsdDll in 'Tools\RsdDll.pas',
  GkStrUtils in 'Tools\GkStrUtils.pas',
  MapParserUnit in 'Tools\MapParserUnit.pas',
  ProgCfgUnit in 'Tools\ProgCfgUnit.pas',
  TypeDefUnit in 'Tools\TypeDefUnit.pas',
  ToolsUnit in 'Tools\ToolsUnit.pas',
  CommThreadUnit in 'Tools\CommThreadUnit.pas',
  ComTradeUnit in 'Tools\ComTradeUnit.pas',
  CommonDef in 'Tools\CommonDef.pas',
  UpLoadDefUnit in 'Tools\UpLoadDefUnit.pas',
  ElfParserUnit in 'Tools\ElfParserUnit.pas',
  ProgressWindowUnit in 'Tools\ProgressWindowUnit.pas' {ProgressForm},

  About in 'Dialogs\About.pas' {AboutForm},
  SettingUnit in 'Dialogs\SettingUnit.pas' {SettingForm},
  EditTypeItemUnit in 'Dialogs\EditTypeItemUnit.pas' {EditTypeItemForm},
  EditVarItemUnit in 'Dialogs\EditVarItemUnit.pas' {EditVarItemForm},
  ShowDrvInfoUnit in 'Dialogs\ShowDrvInfoUnit.pas' {ShowDrvInfoForm},
  EditSectionsDialog in 'Dialogs\EditSectionsDialog.pas' {EditSectionsDlg},
  OpenConnectionDlgUnit in 'Dialogs\OpenConnectionDlgUnit.pas' {OpenConnectionDlg},

  MemFrameUnit in 'Frames\MemFrameUnit.pas' {MemFrame: TFrame},
  AnalogFrameUnit in 'Frames\AnalogFrameUnit.pas' {AnalogFrame: TFrame},
  BinaryFrameUnit in 'Frames\BinaryFrameUnit.pas' {BinaryFrame: TFrame},
  SectionsDefUnit in 'Frames\SectionsDefUnit.pas' {SectionsDefFrame: TFrame},

  StructShowUnit in 'Forms\StructShowUnit.pas' {StructShowForm},
  RegMemUnit in 'Forms\RegMemUnit.pas' {RegMemForm: TMemForm},
  BinaryMemUnit in 'Forms\BinaryMemUnit.pas' {BinaryMemForm},
  TerminalUnit in 'Forms\TerminalUnit.pas' {TerminalForm},
  MemUnit in 'Forms\MemUnit.pas' {MemForm},
  PictureView in 'Forms\PictureView.pas' {PictureViewForm},
  Rz40EventsUnit in 'Forms\Rz40EventsUnit.pas' {Rz40EventsForm},
  RmtChildUnit in 'Forms\RmtChildUnit.pas' {ChildForm},
  RfcUnit in 'Forms\RfcUnit.pas' {RfcForm},
  TypeDefEditUnit in 'Forms\TypeDefEditUnit.pas' {TypeDefEditForm},
  WavGenUnit in 'Forms\WavGenUnit.pas' {WavGenForm},
  VarListUnit in 'Forms\VarListUnit.pas' {VarListForm},
  UpLoadFileUnit in 'Forms\UpLoadFileUnit.pas' {UpLoadFileForm},

  Wykres3Unit in '..\Wykres3\Wykres3Unit.pas',
  WykresEngUnit in '..\Wykres3\WykresEngUnit.pas',

  Rsd64Definitions in '..\Common\Rsd64Definitions.pas',
  CrcUnit in '..\Common\CrcUnit.pas',
  CallProcessUnit in '..\Common\CallProcessUnit.pas',
  JSonUtils in '..\Common\JSonUtils.pas',


  SttObjectDefUnit in '..\JSonSTT\SttObjectDefUnit.pas',
  SttFrameUartUnit in '..\JSonSTT\SttFrameUartUnit.pas' {SttFrameUart},
  SttFrameBaseUnit in '..\JSonSTT\SttFrameBaseUnit.pas' {SttFrameBase: TFrame},
  SttFrameIntUnit in '..\JSonSTT\SttFrameIntUnit.pas' {SttFrameInt: TFrame},
  SttFrameFloatUnit in '..\JSonSTT\SttFrameFloatUnit.pas' {SttFrameFloat: TFrame},
  SttFrameSelectUnit in '..\JSonSTT\SttFrameSelectUnit.pas' {SttFrameSelect: TFrame},
  SttFrameBoolUnit in '..\JSonSTT\SttFrameBoolUnit.pas' {SttFrameBool: TFrame},
  SttFrameIpUnit in '..\JSonSTT\SttFrameIpUnit.pas' {SttFrameIp: TFrame},
  SttFrameAddrIpUnit in '..\JSonSTT\SttFrameAddrIpUnit.pas' {SttFrameAddrIp: TFrame},
  SttScrollBoxUnit in '..\JSonSTT\SttScrollBoxUnit.pas',
  SttFrameStrUnit in '..\JSonSTT\SttFrameStrUnit.pas' {SttFrameStr: TFrame},

  EditDrvParamsUnit in 'Dialogs\EditDrvParamsUnit.pas' {EditDrvParamsForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
