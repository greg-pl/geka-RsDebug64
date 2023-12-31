unit CmmMain;

interface

uses
  Windows, Messages, SysUtils, Classes,
  System.AnsiStrings,
  System.Contnrs,
  System.JSON,
  SttObjectDefUnit,
  Rsd64Definitions,
  ModbusObj,
  ComUnit,
  LibUtils;

const

  LibPropertyStrV2: AnsiString = '<?xml version="1.0" standalone="yes"?>' + '<CMM_DESCR>' +
    '<CMM_INFO TYPE="RS" DESCR="Port RS (protocol Modbus+)" SIGN="MCOM"/>' + '<GROUP>' +
    '<ITEM NAME="COM" TYPE="COM_NR" DESCR="Port number" DEFVALUE="1" />' +
    '<ITEM NAME="DEV_NR" TYPE="INT" DESCR="Device number" DEFVALUE="1" MIN="1" MAX="240" />' +
    '<ITEM NAME="RS_SPEED" TYPE="SELECT" DESCR="Baudrate" DEFVALUE="19200" ' +
    'ITEMS="115200|57600|56000|38400|19200|14400|9600|4800|2400|1200|600|300|110"/>' +
    '<ITEM NAME="MODE" DESCR="Mode RTU/ASCII" TYPE="SELECT" ITEMS="RTU|ASCII" DEFVALUE="RTU"/>' +
    '<ITEM NAME="PARITY" DESCR="Parity" TYPE="SELECT" ITEMS="N|E|O" ITEMDESCR="No parity|Even|Odd"  DEFVALUE="N"/>' +
    '</GROUP>' + '</CMM_DESCR>';

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

const
  ToSetParamStr: AnsiString = 'DIVIDE_LEN;DRIVER_MODE;RS485_WAIT;CLR_RDCNT;';
  ToGetParamStr
    : AnsiString = 'REPEAT_CNT;FRAME_CNT;WAIT_CNT;RECIVE_TIME;SEND_TIME;DIVIDE_LEN;DRIVER_MODE;RS485_WAIT;CLR_RDCNT;';

function GetDrvParamList(ToSet: boolean): PAnsiChar; stdcall;
begin
  if ToSet then
    Result := PAnsiChar(ToSetParamStr)
  else
    Result := PAnsiChar(ToGetParamStr)
end;

// ConnectStr:
// MCOM;nr_rs;nr_dev;rs_speed;[ASCII|RTU];[N|E|O]
// MCOM;1;7;115200;RTU;N

function AddDev(ConnectStr: PAnsiChar): TAccId; stdcall;
begin
  Result := GlobDevList.AddDevice(ConnectStr);
end;

function DelDev(Id: TAccId): TStatus; stdcall;
begin
  Result := GlobDevList.DelDevice(Id);
end;

function GetDrvStatus(Id: TAccId; ParamName: PAnsiChar; ParamValue: PAnsiChar; MaxRpl: integer): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.GetDrvStatus(ParamName, ParamValue, MaxRpl)
  else
    Result := stBadId;
end;

function SetDrvParam(Id: TAccId; ParamName: PAnsiChar; ParamValue: PAnsiChar): TStatus; stdcall;
var
  Dev: TDevItem;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev <> nil then
    Result := Dev.SetDrvParam(ParamName, ParamValue)
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
    stAttSemError:
      R := 'B��d semafora dost�powego';
    stMaxAttachCom:
      R := 'Zbyt du�o otwartych dost�p�w.';
    stSemafErr:
      R := 'B��d semafora dost�pu do portu.';
    stCommErr:
      R := 'B��d otwarcia portu.';
    stBadId:
      R := 'Po��czenie nie nawi�zane.';
    stTimeErr:
      R := 'Time Out.';
    stNotOpen:
      R := 'Port nie otwarty.';
    stSetupErr:
      R := 'Z�e parametry portu.';
    stUserBreak:
      R := 'Operacja przerwana.';
    stNoSemafor:
      R := 'Brak dost�pu do semafora portu.';
    stBadRepl:
      R := 'Nieprawid�owa odpowied� urz�dzenia.';
    stBadArguments:
      R := 'Z�e argumenty dla zapytania MODBUS.';
  else
    Result := false;
    if (Code >= stMdbError) and (Code < stMdbExError) then
    begin
      R := Format('B��d protoko�u MODBUS :%u', [Code - stMdbError]);
      Result := True;
    end;
    if (Code >= stMdbExError) and (Code < stMdbExError + 256) then
    begin
      R := Format('B��d protoko�u MODBUS_EX :%u', [Code - stMdbExError]);
      Result := True;
    end;
  end;
  if not(Result) then
  begin
    Dev := GlobDevList.FindId(Id);
    if Dev <> nil then
    begin
      SetLength(s1, Max);
      Result := Dev.GetErrStr(Code, PAnsiChar(s1), Max);
      if Result then
      begin
        SetLength(s1, System.AnsiStrings.strlen(PAnsiChar(s1)));
        R := String(s1);
      end;
    end;
  end;
  if not(Result) then
  begin
    R := 'B��d' + ' ' + IntToStr(Code);
  end;
  System.AnsiStrings.StrPLCopy(s, AnsiString(R), Max);
end;

type
  TModbusType = (mdbRTU, mdbASCII);
  TMemoryAccessMode = (memAccGEKA, memAccDIEHL);

  TModbusLibPropertyBuilder = class(TLibPropertyBuilder)
  protected
  public
    constructor Create;
  end;

constructor TModbusLibPropertyBuilder.Create;
begin
  inherited;
  Params.shortName := 'MBUS2';
  Params.Description := 'Modbus2 on Uart';
  Params.ConnectionType := connTypUART;
  Params.SubGroups := [subBASE, subMEMORY, subTERMINAL, subMODBUS_STD, subMODBUS_FILE];

  Params.ConnectionParams.Add(TSttIntObjectJson.Create(UARTPARAM_COMNR, 'Port number', 1, NAN_INT, NAN_INT));
  Params.ConnectionParams.Add(TSttSelectObjectJson.Create(UARTPARAM_PARITY, 'Parity', ['N', 'E', 'O'],'N'));
  Params.ConnectionParams.Add(TSttSelectObjectJson.Create(UARTPARAM_BAUDRATE, 'Transmision speed', [300, 600, 1200, 2400, 4800,
    9600, 19200, 38400, 56000, 57600, 115200],115200));
  Params.ConnectionParams.Add(TSttSelectObjectJson.Create(UARTPARAM_BITCNT, 'Count of data bits', [6, 7, 8],8));

  Params.ConnectionParams.Add(TSttSelectObjectJson.Create('MdbMode', 'Modbus mode', ['XRTU', 'XASCI'],'RTU'));
  Params.ConnectionParams.Add(TSttSelectObjectJson.Create('MemAccessMode', 'Memory access mode', ['GEKA', 'DPC06'],'DPC06'));
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
