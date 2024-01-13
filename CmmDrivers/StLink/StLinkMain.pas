unit StLinkMain;

interface

uses
  Windows, Messages, SysUtils, Classes,
  System.AnsiStrings,
  System.Contnrs,
  System.JSON,
  SttObjectDefUnit,
  Rsd64Definitions,
  StLinkObjUnit,
  LibUtils;

{$INCLUDE ..\CmmCommon\CmmBaseDef.inc}
{$INCLUDE ..\CmmCommon\MemoryAccessDef.inc}
{$INCLUDE ..\CmmCommon\TerminalDef.inc}

implementation

// -------------------- Export ---------------------------------------------
var
  GlobLibProperty: AnsiString;

function LibIdentify: PGUID; stdcall;
begin
  Result := @CommLibGuid;
end;

function GetLibProperty: PAnsiChar; stdcall;
begin
  Result := PAnsiChar(GlobLibProperty);
end;

procedure SetLoggerHandle(H_WideChar, H_AnsiChar: THandle); stdcall;
begin
  WideChar_LoggerHandle := H_WideChar;
  AnsiChar_LoggerHandle := H_AnsiChar;
end;

procedure SetGetMemFunction(LibID: integer; GetMemFunc: TGetMemFunction); stdcall;
begin
  GlobLibID := LibID;
  GlobGetMemFunc := GetMemFunc;
end;

function AddDev(ConnectStr: PAnsiChar): TAccId; stdcall;
begin
  Result := GlobDevList.AddDevice(ConnectStr);
end;

function DelDev(Id: TAccId): TStatus; stdcall;
begin
  Result := GlobDevList.DelDevice(Id);
end;

// return information about current state
// JSON format
function GetDrvInfo(Id: TAccId): PAnsiChar; stdcall;
var
  Dev: TDevItem;
  s: AnsiString;
  n: integer;
begin
  Result := nil;
  if assigned(GlobGetMemFunc) then
  begin
    Dev := GlobDevList.FindId(Id);
    if Dev <> nil then
    begin
      s := AnsiString(Dev.GetDrvInfo);
      n := length(s);
      Result := PAnsiChar(GlobGetMemFunc(GlobLibID, n + 1));
      move(s[1], Result^, n);
      Result[n] := #0;
    end;
  end;
end;

// function return text as JSON
// caller should releas the memory
function GetDrvParams(Id: TAccId): PAnsiChar; stdcall;
var
  Dev: TDevItem;
  s: AnsiString;
  n: integer;
begin
  Result := nil;
  if assigned(GlobGetMemFunc) then
  begin
    Dev := GlobDevList.FindId(Id);
    if Dev <> nil then
    begin
      s := AnsiString(Dev.GetDrvParams);
      n := length(s);
      Result := PAnsiChar(GlobGetMemFunc(GlobLibID, n + 1));
      move(s[1], Result^, n);
      Result[n] := #0;
    end;
  end;
end;

function SetDrvParams(Id: TAccId; jsonParams: PAnsiChar): TStatus; stdcall;
var
  Dev: TDevItem;
  n: integer;
  s1: AnsiString;

begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
  begin
    n := System.AnsiStrings.strLen(jsonParams);
    setlength(s1, n);
    move(jsonParams^, s1[1], n);
    Result := Dev.SetDrvParams(String(s1));
  end
  else
    Result := stBadId;
end;

function SetBreakFlag(Id: TAccId; Val: boolean): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SetBreakFlag(Val)
  else
    Result := stBadId;
end;

function RegisterCallBackFun(Id: TAccId; CmmId: integer; CallBackFunc: TCallBackFunc): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
  begin
    Dev.RegisterCallBackFun(CallBackFunc, CmmId);
    Result := stOk;
  end
  else
    Result := stBadId;
end;

function OpenDev(Id: TAccId): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.Open
  else
    Result := stBadId;
end;

procedure CloseDev(Id: TAccId); stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
  begin
    Dev.Close;
  end;
end;

function GetErrStr(Id: TAccId; Code: TStatus; s: PAnsiChar; Max: integer): boolean; stdcall;
var
  Dev: TDevItem;
  R: string;
  s1: AnsiString;
begin
  Result := True;
  case Code of
    stOk:
      R := 'Ok';
    stBadId:
      R := 'Identificator error.';
    stTimeErr:
      R := 'Time Out.';
    stNotOpen:
      R := 'Port not open.';
    stNoReplay:
      R := 'No replay.';
    stSetupErr:
      R := 'Invalid parameters.';
    stUserBreak:
      R := 'Break used';
    stNoSemafor:
      R := 'Port access error.';
    stBadRepl:
      R := 'Improper slave answer.';
    stBadArguments:
      R := 'Incorrect Modbus ask parameters.';
    stBufferToSmall:
      R := 'Buffer too small';
    stToBigTerminalNr:
      R := 'Terminal Nr too big';
    stEND_OFF_DIR:
      R := 'End off dir';
    stDelphiError:
      R := 'Delphi error';
    stReplySumError:
      R := 'Replay sum error';
    stReplyFormatError:
      R := 'Replay format error';
    stConnectError:
      R := 'Connection error';
  else
    Result := false;
    if (Code >= stGDB_error) then
    begin
      R := Format('GdbError %u', [Code - stGDB_error]);
      Result := True;
    end;
  end;
  if not(Result) then
  begin
    R := 'Error' + ' ' + IntToStr(Code);
  end;
  System.AnsiStrings.StrPLCopy(s, AnsiString(R), Max);
end;


// ----RD/Wr Memory ---------------------------------------------------------------------

function ReadMem(Id: TAccId; var Buffer; adr: cardinal; size: cardinal): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.RdMemory(Buffer, adr, size)
  else
    Result := stBadId;
end;

function WriteMem(Id: TAccId; var Buffer; adr: cardinal; size: cardinal): TStatus; stdcall;

var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.WrMemory(Buffer, adr, size)
  else
    Result := stBadId;
end;

// ----Terminal ---------------------------------------------------------------------

function TerminalSendKey(Id: TAccId; key: AnsiChar): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.TerminalSendKey(key)
  else
    Result := stBadId;
end;

function TerminalRead(Id: TAccId; Buf: PAnsiChar; var rdcnt: integer): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.TerminalRead(Buf, rdcnt)
  else
    Result := stBadId;
end;

function TerminalSetPipe(Id: TAccId; TerminalNr: integer; PipeHandle: THandle): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.TerminalSetPipe(TerminalNr, PipeHandle)
  else
    Result := stBadId;
end;

function TerminalSetRunFlag(Id: TAccId; TerminalNr: integer; RunFlag: boolean): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.TerminalSetRunFlag(TerminalNr, RunFlag)
  else
    Result := stBadId;
end;

type
  TModbusLibPropertyBuilder = class(TLibPropertyBuilder)
  protected
  public
    constructor Create;
  end;

constructor TModbusLibPropertyBuilder.Create;
begin
  inherited;
  Params.DriverName := DRIVER_NAME;
  Params.Description := 'StLink via TCP';
  Params.ConnectionType := connTypTCPIP;
  Params.SubGroups := [subBASE, subMEMORY, subTERMINAL];

  Params.ConnectionParams.Add(TSttIPObjectJson.Create(IPPARAM_IP, 'IP Address'));
  Params.ConnectionParams.Add(TSttIntObjectJson.Create(IPPARAM_PORT, 'Port', 1, 65535, 514));

  Params.ConnectionParams.Add(TSttBoolObjectJson.Create(OPEN_RUNSTLINK, 'Run ST-Link gdb server', True));
  Params.ConnectionParams.Add(TSttStringObjectJson.Create(OPEN_STLINKPATH, 'Path to ST-Link gdb server', ''));
  Params.ConnectionParams.Add(TSttBoolObjectJson.Create(OPEN_SWDMODE, 'Enables SWD mode', True));

  Params.ConnectionParams.Add(TSttBoolObjectJson.Create(OPEN_PERSISTANT, 'Enables persistant mode', True));
  Params.ConnectionParams.Add(TSttBoolObjectJson.Create(OPEN_LOGINGENAB, 'Enables logging', false));
  Params.ConnectionParams.Add(TSttStringObjectJson.Create(OPEN_LOGINGPATH, 'Path to log file', ''));
  Params.ConnectionParams.Add(TSttBoolObjectJson.Create(OPEN_VERBOSEMODE, 'Verbose mode', false));
  Params.ConnectionParams.Add(TSttBoolObjectJson.Create(OPEN_VERBOSCALLERMODE, 'Gdb caller verbose mode', false));

  Params.ConnectionParams.Add(TSttStringObjectJson.Create(OPEN_PATHTOPROGR, 'Path to STM32CubeProgrammer', ''));

end;

procedure BuildLibProperty;
var
  lpb: TLibPropertyBuilder;
begin
  lpb := TModbusLibPropertyBuilder.Create;
  try
    GlobLibProperty := AnsiString(lpb.Build);
  finally
    lpb.Free;
  end;

end;

initialization

IsMultiThread := True; // Make memory manager thread safe
BuildLibProperty;

end.
