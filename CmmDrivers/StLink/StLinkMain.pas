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
{$INCLUDE ..\CmmCommon\FileAccessDef.inc}
{$INCLUDE ..\CmmCommon\StdModbusDef.inc}
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

procedure SetLoggerHandle(H: THandle); stdcall;
begin
  LoggerHandle := H;
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


// ----Standard modbus ----------------------------------------------------------------

function RdOutTable(Id: TAccId; var Buf; Adress: word; Count: word): TStatus; stdcall;

var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
  begin
    Result := Dev.RdOutTable(Buf, Adress, Count);
  end
  else
    Result := stBadId;
end;

function RdInpTable(Id: TAccId; var Buf; Adress: word; Count: word): TStatus; stdcall;

var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
  begin
    Result := Dev.RdInpTable(Buf, Adress, Count);
  end
  else
    Result := stBadId;
end;

function RdReg(Id: TAccId; var Buf; Adress: word; Count: word): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
  begin
    Result := Dev.RdReg(Buf, Adress, Count);
  end
  else
    Result := stBadId;
end;

function RdAnalogInp(Id: TAccId; var Buf; Adress: word; Count: word): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
  begin
    Result := Dev.RdAnalogInp(Buf, Adress, Count);
  end
  else
    Result := stBadId;
end;

function WrOutput(Id: TAccId; Adress: word; Val: word): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
  begin
    Result := Dev.WrOutput(Adress, Val <> 0);
  end
  else
    Result := stBadId;
end;

function WrReg(Id: TAccId; Adress: word; Val: word): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
  begin
    Result := Dev.WrReg(Adress, Val);
  end
  else
    Result := stBadId;
end;

function WrMultiReg(Id: TAccId; var Buf; Adress: word; Count: word): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
  begin
    Result := Dev.WrMultiReg(Buf, Adress, Count);
  end
  else
    Result := stBadId;
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


// ----File function ---------------------------------------------------------------------

function SeOpenSesion(Id: TAccId; var SesId: TSesID): TStatus; stdcall;

var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeOpenSesion(SesId)
  else
    Result := stBadId;
end;

function SeCloseSesion(Id: TAccId; SesId: TSesID): TStatus; stdcall;

var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeCloseSesion(SesId)
  else
    Result := stBadId;
end;

function SeOpenFile(Id: TAccId; SesId: TSesID; FName: PAnsiChar; Mode: byte; var FileNr: TFileNr): TStatus; stdcall;

var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeOpenFile(SesId, FName, Mode, FileNr)
  else
    Result := stBadId;
end;

function SeGetDir(Id: TAccId; SesId: TSesID; FName: PAnsiChar; Attrib: byte; Buffer: PAnsiChar; MaxLen: integer)
  : TStatus; stdcall;

var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeGetDir(SesId, FName, Attrib, Buffer, MaxLen)
  else
    Result := stBadId;
end;

function SeGetDrvList(Id: TAccId; SesId: TSesID; DrvList: PAnsiChar): TStatus;

var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeGetDrvList(SesId, DrvList)
  else
    Result := stBadId;
end;

function SeShell(Id: TAccId; SesId: TSesID; Command: PAnsiChar; ResultStr: PAnsiChar; MaxLen: integer)
  : TStatus; stdcall;

var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeShell(SesId, Command, ResultStr, MaxLen)
  else
    Result := stBadId;
end;

function SeReadFile(Id: TAccId; SesId: TSesID; FileNr: TFileNr; var Buf; var Cnt: integer): TStatus; stdcall;

var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeReadFile(SesId, FileNr, Buf, Cnt)
  else
    Result := stBadId;
end;

function SeWriteFile(Id: TAccId; SesId: TSesID; FileNr: TFileNr; const Buf; var Cnt: integer): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeWriteFile(SesId, FileNr, Buf, Cnt)
  else
    Result := stBadId;
end;

function SeSeek(Id: TAccId; SesId: TSesID; FileNr: TFileNr; Offset: integer; Orgin: byte; var Pos: integer): TStatus;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeSeek(SesId, FileNr, Offset, Orgin, Pos)
  else
    Result := stBadId;
end;

function SeGetFileSize(Id: TAccId; SesId: TSesID; FileNr: TFileNr; var FileSize: integer): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeGetFileSize(SesId, FileNr, FileSize)
  else
    Result := stBadId;
end;

function SeCloseFile(Id: TAccId; SesId: TSesID; FileNr: TFileNr): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeCloseFile(SesId, FileNr)
  else
    Result := stBadId;
end;

function SeGetGuid(Id: TAccId; SesId: TSesID; FileNr: TFileNr; var Guid: TSeGuid): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeGetGuid(SesId, FileNr, Guid)
  else
    Result := stBadId;
end;

function SeGetGuidEx(Id: TAccId; SesId: TSesID; FileName: PAnsiChar; var Guid: TSeGuid): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeGetGuidEx(SesId, FileName, Guid)
  else
    Result := stBadId;
end;

function SeReadFileEx(Id: TAccId; SesId: TSesID; FileName: PAnsiChar; autoclose: boolean; var Buf; var size: integer;
  var FileNr: TFileNr): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SeReadFileEx(SesId, FileName, autoclose, Buf, size, FileNr)
  else
    Result := stBadId;
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
  else
    Result := false;
    if (Code >= stMdbError) and (Code < stMdbExError) then
    begin
      R := Format('MODBUS protocol error :%u', [Code - stMdbError]);
      Result := True;
    end;
    if (Code >= stMdbExError) and (Code < stMdbExError + 256) then
    begin
      R := Format('MODBUS_EX protocol error :%u', [Code - stMdbExError]);
      Result := True;
    end;
  end;
  if not(Result) then
  begin
    Dev := GlobDevList.FindId(Id);
    if Dev <> nil then
    begin
      setlength(s1, Max);
      Result := Dev.GetErrStr(Code, PAnsiChar(s1), Max);
      if Result then
      begin
        setlength(s1, System.AnsiStrings.strLen(PAnsiChar(s1)));
        R := String(s1);
      end;
    end;
  end;
  if not(Result) then
  begin
    R := 'Error' + ' ' + IntToStr(Code);
  end;
  System.AnsiStrings.StrPLCopy(s, AnsiString(R), Max);
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
  Params.Description := 'Modbus on Uart';
  Params.ConnectionType := connTypUART;
  Params.SubGroups := [subBASE, subMEMORY, subTERMINAL, subMODBUS_STD, subMODBUS_FILE];

  Params.ConnectionParams.Add(TSttIntObjectJson.Create(UARTPARAM_COMNR, 'Port number', 1, NAN_INT, NAN_INT));
  Params.ConnectionParams.Add(TSttSelectObjectJson.Create(UARTPARAM_PARITY, 'Parity', ['N', 'E', 'O'], 'N'));
  Params.ConnectionParams.Add(TSttSelectObjectJson.Create(UARTPARAM_BAUDRATE, 'Transmision speed',
    [300, 600, 1200, 2400, 4800, 9600, 19200, 38400, 56000, 57600, 115200], 115200));
  Params.ConnectionParams.Add(TSttSelectObjectJson.Create(UARTPARAM_BITCNT, 'Count of data bits', [6, 7, 8], 8));

  Params.ConnectionParams.Add(TSttIntObjectJson.Create(MODBUS_DEVNR, 'Numer on modbus', 1, 254, 1));
  Params.ConnectionParams.Add(TSttSelectObjectJson.Create(MODBUS_MODE, 'Modbus mode', ['RTU', 'ASCI'], 'RTU'));
  Params.ConnectionParams.Add(TSttSelectObjectJson.Create(MODBUS_MEMACCESS, 'Memory access mode', ['GEKA', 'DPC06'],
    'DPC06'));
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
