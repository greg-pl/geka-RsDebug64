library StLinkTcp;

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
  System.SysUtils,
  System.Classes,
  SttObjectDefUnit in '..\..\JSonSTT\SttObjectDefUnit.pas',
  Rsd64Definitions in '..\..\Common\Rsd64Definitions.pas',
  JSonUtils in '..\..\Common\JSonUtils.pas',
  LibUtils in '..\CmmCommon\LibUtils.pas',
  StLinkMain in 'StLinkMain.pas',
  StLinkObjUnit in 'StLinkObjUnit.pas',
  SimpSock_Tcp in 'SimpSock_Tcp.pas',
  StLinkDriver in 'StLinkDriver.pas' {$R *.res},
  CallProcessUnit in '..\..\Common\CallProcessUnit.pas';

{$R *.res}

begin



end.
