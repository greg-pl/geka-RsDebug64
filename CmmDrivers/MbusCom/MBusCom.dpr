library MBusCom;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$E cmm2}

uses
  Windows,
  SysUtils,
  Classes,
  Rsd64Definitions in '..\..\Common\Rsd64Definitions.pas',
  SttObjectDefUnit in '..\..\JSonSTT\SttObjectDefUnit.pas',
  CrcUnit in '..\..\Common\CrcUnit.pas',
  JSonUtils in '..\..\Common\JSonUtils.pas',
  LibUtils in '..\CmmCommon\LibUtils.pas' {$R *.res},
  CmmMain in 'CmmMain.pas',
  ModbusObj in 'ModbusObj.pas',
  ComUnit in 'ComUnit.pas' {$R *.res},
  ErrorDefUnit in '..\..\Common\ErrorDefUnit.pas';

{$R *.res}

begin

end.
