program RsDebug64;

uses
  Forms,
  RsdDll in 'RsdDll.pas',
  GkStrUtils in 'GkStrUtils.pas',
  MapParserUnit in 'MapParserUnit.pas',
  ProgCfgUnit in 'ProgCfgUnit.pas',
  TypeDefUnit in 'TypeDefUnit.pas',
  ToolsUnit in 'ToolsUnit.pas',
  UpLoadDefUnit in 'UpLoadDefUnit.pas',
  ComTradeUnit in 'ComTradeUnit.pas',
  CommonDef in 'CommonDef.pas',
  CrcUnit in 'CrcUnit.pas',
  Main in 'Main.pas' {MainForm},
  MemFrameUnit in 'MemFrameUnit.pas' {MemFrame: TFrame},
  AnalogFrameUnit in 'AnalogFrameUnit.pas' {AnalogFrame: TFrame},
  BinaryFrameUnit in 'BinaryFrameUnit.pas' {BinaryFrame: TFrame},
  RmtChildUnit in 'RmtChildUnit.pas' {ChildForm},
  WavGenUnit in 'WavGenUnit.pas' {WavGenForm},
  PictureView in 'PictureView.pas' {PictureViewForm},
  MemUnit in 'MemUnit.pas' {MemForm},
  VarListUnit in 'VarListUnit.pas' {VarListForm},
  RfcUnit in 'RfcUnit.pas' {RfcForm},
  EditVarItemUnit in 'EditVarItemUnit.pas' {EditVarItemForm},
  StructShowUnit in 'StructShowUnit.pas' {StructShowForm},
  EditTypeItemUnit in 'EditTypeItemUnit.pas' {EditTypeItemForm},
  UpLoadFileUnit in 'UpLoadFileUnit.pas' {UpLoadFileForm},
  WrtControlUnit in 'WrtControlUnit.pas' {WrtControlForm},
  About in 'About.pas' {AboutForm},
  TerminalUnit in 'TerminalUnit.pas' {TerminalForm},
  RegMemUnit in 'RegMemUnit.pas' {RegMemForm: TMemForm},
  BinaryMemUnit in 'BinaryMemUnit.pas' {BinaryMemForm},
  Rz40EventsUnit in 'Rz40EventsUnit.pas' {Rz40EventsForm},
  SettingUnit in 'SettingUnit.pas' {SettingForm},
  TypeDefEditUnit in 'TypeDefEditUnit.pas' {TypeDefEditForm},
  DevStrEditUnit in 'DevStrEditUnit.pas' {DevStrEditForm},
  EditDrvParamsUnit in 'EditDrvParamsUnit.pas' {EditDrvParamsForm},
  CommThreadUnit in 'CommThreadUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
