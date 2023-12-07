program RsDebug64;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  RsdDll in 'Tools\RsdDll.pas',
  GkStrUtils in 'Tools\GkStrUtils.pas',
  MapParserUnit in 'Tools\MapParserUnit.pas',
  ProgCfgUnit in 'Tools\ProgCfgUnit.pas',
  TypeDefUnit in 'Tools\TypeDefUnit.pas',
  ToolsUnit in 'Tools\ToolsUnit.pas',
  CommThreadUnit in 'Tools\CommThreadUnit.pas',
  ComTradeUnit in 'Tools\ComTradeUnit.pas',
  CommonDef in 'Tools\CommonDef.pas',
  CrcUnit in 'Tools\CrcUnit.pas',
  SettingUnit in 'Dialogs\SettingUnit.pas' {SettingForm},
  EditTypeItemUnit in 'Dialogs\EditTypeItemUnit.pas' {EditTypeItemForm},
  EditVarItemUnit in 'Dialogs\EditVarItemUnit.pas' {EditVarItemForm},
  EditDrvParamsUnit in 'Dialogs\EditDrvParamsUnit.pas' {EditDrvParamsForm},
  DevStrEditUnit in 'Dialogs\DevStrEditUnit.pas' {DevStrEditForm},
  About in 'Dialogs\About.pas' {AboutForm},
  MemFrameUnit in 'Frames\MemFrameUnit.pas' {MemFrame: TFrame},
  AnalogFrameUnit in 'Frames\AnalogFrameUnit.pas' {AnalogFrame: TFrame},
  BinaryFrameUnit in 'Frames\BinaryFrameUnit.pas' {BinaryFrame: TFrame},
  StructShowUnit in 'Forms\StructShowUnit.pas' {StructShowForm},
  RegMemUnit in 'Forms\RegMemUnit.pas' {RegMemForm: TMemForm},
  BinaryMemUnit in 'Forms\BinaryMemUnit.pas' {BinaryMemForm},
  TerminalUnit in 'Forms\TerminalUnit.pas' {TerminalForm},
  MemUnit in 'Forms\MemUnit.pas' {MemForm},
  PictureView in 'Forms\PictureView.pas' {PictureViewForm},
  Rz40EventsUnit in 'Forms\Rz40EventsUnit.pas' {Rz40EventsForm},
  RmtChildUnit in 'Forms\RmtChildUnit.pas' {ChildForm},
  RfcUnit in 'Forms\RfcUnit.pas' {RfcForm},
  Wykres3Unit in '..\Wykres3\Wykres3Unit.pas',
  WykresEngUnit in '..\Wykres3\WykresEngUnit.pas',
  WrtControlUnit in 'Forms\WrtControlUnit.pas' {WrtControlForm},
  TypeDefEditUnit in 'Forms\TypeDefEditUnit.pas' {TypeDefEditForm},
  UpLoadDefUnit in 'Tools\UpLoadDefUnit.pas',
  WavGenUnit in 'Forms\WavGenUnit.pas' {WavGenForm},
  VarListUnit in 'Forms\VarListUnit.pas' {VarListForm},
  UpLoadFileUnit in 'Forms\UpLoadFileUnit.pas' {UpLoadFileForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
