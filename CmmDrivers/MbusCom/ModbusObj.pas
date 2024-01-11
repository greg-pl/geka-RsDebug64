unit ModbusObj;

interface

uses
  Windows, Messages, SysUtils, Classes, Math,
  System.AnsiStrings,
  System.Contnrs,
  System.JSON,
  ComUnit,
  LibUtils,
  JsonUtils,
  SttObjectDefUnit,
  Rsd64Definitions;

const
  DRIVER_NAME = 'MBUS';

  MAX_MDB_FRAME_SIZE = 240;
  MAX_MDB_STD_FRAME_SIZE = 112;
  DRIVER_SHORT_NAME = 'MCOM';
  TERMINAL_CNT = 1;

  MODBUS_DEVNR = 'MdbDevNr';
  MODBUS_MODE = 'MdbMode';
  MODBUS_MEMACCESS = 'MemAccessMode';

type

  TComPort = integer;
  TBaudRate = (br110, br300, br600, br1200, br2400, br4800, br9600, br14400, br19200, br38400, br56000, br57600,
    br115200);
  TDriverMode = (dmSTD, dmSLOW, dmFAST);

  PByteAr = ^TByteAr;
  TByteAr = array [0 .. MAX_MDB_FRAME_SIZE - 1 + 40] of byte;
  TTabBit = array [0 .. 32768] of boolean;
  TTabByte = array [0 .. 32768] of byte;
  TTabWord = array [0 .. 32768] of word;

  TMdbMode = (mdbRTU, mdbASCII);
  TMemoryAccessMode = (memAccGEKA, memAccDIEHL);

  TParity = (paNONE, paEVEN, paODD);
  TMdbMemAccess = (mdbmemGEKA, mdbmemDPC06);

  TBitCnt = (bit8, bit7, bit6);

  TDevItem = class;

  TTerminalThread = class(TThread)
  private
    FOwner: TDevItem;
    FEventHandle: THandle;
  protected
    procedure Execute; override;
  public
    FRunFlag: boolean;
    FOutPipe: THandle;
    constructor Create(aOwner: TDevItem);
    destructor Destroy; override;
    procedure SetRunFlag(q: boolean);
  end;

  TDevItem = class(TObject)
  public type
    TOpenParams = record
      ComNr: TComPort;
      DevNr: integer;
      BaudRate: TBaudRate;
      Parity: TParity;
      BitCnt: TBitCnt;
      MdbMode: TMdbMode;
      MdbMemAccess: TMdbMemAccess;
      procedure InitDefault;
    end;

    TTerminalData = record
      PipeHandle: THandle;
      RunFlag: boolean;
      Thread: TTerminalThread;
    end;

  private
    AccId: integer;
    ComNr: integer;
    FDevNr: integer;
    BaudRate: TBaudRate;
    FMdbMode: TMdbMode;
    FParity: TParity;
    FBitCnt: TBitCnt;
    FMdbMemAccess: TMdbMemAccess;
    FTermialTab: array [0 .. TERMINAL_CNT - 1] of TTerminalData;

    FCallBackFunc: TCallBackFunc;
    FCmmId: integer;

    FBreakFlag: boolean;

    ComHandle: THandle;
    SemHandle: THandle;
    ErrStr: Shortstring;

    LastFinished: cardinal;
    FrameCnt: integer;
    FrameRepCnt: integer;
    WaitCnt: integer; // licznik wymuszonych przerw
    SumRecTime: integer;
    SumSendTime: integer;

    FCountDivide: integer;
    FMdbStdCndDiv: integer; // podzia³ na krótsze ramki dla standardowych zapytañ MODBUS
    FAskNumber: word;
    DriverMode: TDriverMode;
    Rs485Wait: boolean;
    TerminalReadTime: integer;
    FClr_ToRdCnt: boolean; // odbiór ramki az do przerwy

    function GetNewAskNr: word;

    procedure FSetCountDivide(AValue: integer);
    procedure FSetMdbStdCndDiv(AValue: integer);
    function GetComAcces: boolean;
    procedure ReleaseComAcces;

    function RsWrite(Buffer: TBytes): integer;
    function RsRead(var Buffer; Count: integer): integer;
    procedure PurgeInOut;
    function Konwers(showProgress: boolean; RepZad: integer; Buf: TBytes; var OutBuf: TBytes): TStatus; overload;
    function Konwers(showProgress: boolean; Buf: TBytes; var OutBuf: TBytes): TStatus; overload;
    function Konwers(Buf: TBytes; var OutBuf: TBytes): TStatus; overload;

    function ReciveRTUAnswer(var Buffer: TBytes): boolean;
    function ReciveASCIIAnswer(var Buffer: TBytes): boolean;
    function RdRegHd(var QA: TBytes; Adress: word; Count: word): TStatus;
    function RdAbnalogInpHd(var QA: TBytes; Adress: word; Count: word): TStatus;
    function WrMultiRegHd(Adress: word; Count: word; pW: pWord): TStatus;
    // function  GetSmallInt(const b):Smallint;
    procedure SetSmallInt(const b; Val: Smallint);
    function GetLongInt(const b): cardinal;
    procedure SetLongInt(const b; Val: cardinal);
    function GetDWord(const b): cardinal;
    // procedure SetDWord(const b; Val :cardinal);
    function SeGetDirHd(First: boolean; SesId: TSesID; FName: PAnsiChar; Attrib: byte; Buffer: PAnsiChar;
      MaxLen: integer; var Len: integer): TStatus;
    function SeReadFileHd(SesId: TSesID; FileNr: TFileNr; var Buf; var Cnt: integer): TStatus;
    function SeWriteFileHd(SesId: TSesID; FileNr: TFileNr; const Buf; var Cnt: integer): TStatus;
  protected
    procedure CallBackFunct(Ev: integer; R: real);
    procedure SetProgress(F: real); overload;
    procedure SetProgress(Cnt, Max: integer); overload;
    procedure MsgFlowSize(R: real);
    procedure SetWorkFlag(w: boolean);

    function RsReadByte(var b: byte): boolean;
    function InQue: integer;
    function OutQue: integer;
  public
    MaxTimeWaitSemafor: integer;
    constructor Create(AId: TAccId; OpenParams: TOpenParams);
    destructor Destroy; override;
    property CountDivide: integer read FCountDivide write FSetCountDivide;
    property MdbStdCndDiv: integer read FMdbStdCndDiv write FSetMdbStdCndDiv;

    function ValidHandle: boolean;
    function SetupState: TStatus;
    function Open: TStatus;
    procedure Close;
    function isOpen: boolean;
    procedure BreakPulse;
    property DevNr: integer read FDevNr;
    function SetBreakFlag(Val: boolean): TStatus;

    function GetDrvInfo: String;
    function GetDrvParams: String;
    function SetDrvParams(const jsonParams: string): TStatus;

    procedure RegisterCallBackFun(ACallBackFunc: TCallBackFunc; CmmId: integer);
    // funkcje podstawowe Modbusa
    function RdOutTable(var Buf; Adress: word; Count: word): TStatus;
    function RdInpTable(var Buf; Adress: word; Count: word): TStatus;
    function RdReg(var Buf; Adress: word; Count: word): TStatus;
    function RdAnalogInp(var Buf; Adress: word; Count: word): TStatus;
    function WrOutput(Adress: word; Val: boolean): TStatus;
    function RdStatus(var Val: byte): TStatus;
    function WrReg(Adress: word; Val: word): TStatus;
    function WrMultiReg(var Buf; Adress: word; Count: word): TStatus;
    // odczyt, zapis pamiêci
    function RdMemory(var Buf; Adress: cardinal; Count: cardinal): TStatus;
    function WrMemory(const Buf; Adress: cardinal; Count: cardinal): TStatus;

    // obsluga terminala
    function TerminalSendKey(key: AnsiChar): TStatus;
    function TerminalRead(Buf: PAnsiChar; var rdcnt: integer): TStatus;
    function TerminalSetPipe(TerminalNr: integer; PipeHandle: THandle): TStatus;
    function TerminalSetRunFlag(TerminalNr: integer; RunFlag: boolean): TStatus;

    // dostep do sesji i plików
    function GetErrStr(Code: TStatus; Buffer: PAnsiChar; MaxLen: integer): boolean;
    function SeOpenSesion(var SesId: TSesID): TStatus;
    function SeCloseSesion(SesId: TSesID): TStatus;
    function SeOpenFile(SesId: TSesID; FName: PAnsiChar; Mode: byte; var FileNr: TFileNr): TStatus;
    function SeGetDir(SesId: TSesID; FName: PAnsiChar; Attrib: byte; Buffer: PAnsiChar; MaxLen: integer): TStatus;

    function SeGetDrvList(SesId: TSesID; DrvList: PAnsiChar): TStatus;
    function SeShell(SesId: TSesID; Command: PAnsiChar; ResultStr: PAnsiChar; MaxLen: integer): TStatus;
    function SeGetGuidEx(SesId: TSesID; FileName: PAnsiChar; var Guid: TSeGuid): TStatus;
    function SeReadFileEx(SesId: TSesID; FileName: PAnsiChar; autoclose: boolean; var Buf; var size: integer;
      var FileNr: TFileNr): TStatus;
    function SeReadFile(SesId: TSesID; FileNr: TFileNr; var Buf; var Cnt: integer): TStatus;
    function SeWriteFile(SesId: TSesID; FileNr: TFileNr; const Buf; var Cnt: integer): TStatus;
    function SeSeek(SesId: TSesID; FileNr: TFileNr; Offset: integer; Orgin: byte; var Pos: integer): TStatus;
    function SeGetFileSize(SesId: TSesID; FileNr: TFileNr; var FileSize: integer): TStatus;
    function SeCloseFile(SesId: TSesID; FileNr: TFileNr): TStatus;
    function SeGetGuid(SesId: TSesID; FileNr: TFileNr; var Guid: TSeGuid): TStatus;
  end;

  TDevList = class(TObjectList)
  private
    FCurrId: TAccId;
    FCriSection: TRTLCriticalSection;
    function GetBoudRate(BdTxt: String; var Baund: TBaudRate): boolean;
    function GetMdbMode(BdTxt: String; var MdbMode: TMdbMode): boolean;
    function GetParity(BdTxt: String; var Parity: TParity): boolean;
    function GetBitCnt(Txt: String; var BitCnt: TBitCnt): boolean;
    function GetMdbMemAccess(Txt: String; var MemAcc: TMdbMemAccess): boolean;
    function GetTocken(s: PAnsiChar; var p: integer): String;
    function GetId: TAccId;
  public
    constructor Create;
    destructor Destroy; override;
    function AddDevice(ConnectStr: PAnsiChar): TAccId;
    function DelDevice(AccId: TAccId): TStatus;
    function FindId(AccId: TAccId): TDevItem;
    function isAnyDevWithOpenCom(ComNr: integer): boolean;
    procedure UpdateCom(ComNr: integer);

  end;

var
  GlobDevList: TDevList;

implementation

uses
  CrcUnit;

function lolo(w: cardinal): byte;
begin
  lolo := w and $FF;
end;

function lohi(w: cardinal): byte;
begin
  lohi := (w shr 8) and $FF;
end;

function hilo(w: cardinal): byte;
begin
  hilo := (w shr 16) and $FF;
end;

const
  dcb_Binary = $00000001;
  dcb_Parity = $00000002;
  dcb_OutxCtsFlow = $00000004;
  dcb_OutxDsrFlow = $00000008;
  dcb_DtrControl = $00000030;
  dcb_DsrSensivity = $00000040;
  dcb_TXContinueOnXOff = $00000080;
  dcb_OutX = $00000100;
  dcb_InX = $00000200;
  dcb_ErrorChar = $00000400;
  dcb_Null = $00000800;
  dcb_RtsControl = $00003000;
  dcb_AbortOnError = $00004000;

function LastErr: Shortstring;
begin
  Result := AnsiString(IntToStr(GetLastError));
end;


// ---------------------  TTerminalThread ---------------------------

constructor TTerminalThread.Create(aOwner: TDevItem);
begin
  FOwner := aOwner;
  FRunFlag := false;
  FOutPipe := INVALID_HANDLE_VALUE;
  FEventHandle := CreateEvent(nil, false, false, nil);

  inherited Create(false);
end;

destructor TTerminalThread.Destroy;
begin
  inherited;
  CloseHandle(FEventHandle);
end;

procedure TTerminalThread.Execute;
var
  Buffer: array of AnsiChar;
  WideCh: array of Char;
  rdcnt: integer;
  st: TStatus;
  BytesWritten: cardinal;
  // idx: integer;
  i: integer;
begin
  Logger(1, '\wTerminalThread Start' + #10);
  setLength(Buffer, 512);
  // idx := 0;
  while not(Terminated) do
  begin
    if FRunFlag and (FOutPipe <> INVALID_HANDLE_VALUE) then
    begin
      rdcnt := 0;
      st := FOwner.TerminalRead(@Buffer[0], rdcnt);
      if (st = stOK) and (rdcnt > 0) then
      begin
        setLength(WideCh, rdcnt);
        for i := 0 to rdcnt - 1 do
        begin
          WideCh[i] := Char(Buffer[i]);
        end;

        WriteFile(FOutPipe, WideCh[0], rdcnt * sizeof(Char), BytesWritten, nil);
      end
      else
        WaitForSingleObject(FEventHandle, FOwner.TerminalReadTime);
    end
    else
    begin
      WaitForSingleObject(FEventHandle, 1000);
      // Logger(1, Format('\iTerminalThread wait %d', [idx]) + #10);
      // inc(idx);
    end;
  end;
  Logger(1, '\wTerminalThread Exit' + #10);

end;

procedure TTerminalThread.SetRunFlag(q: boolean);
begin
  FRunFlag := q;
  SetEvent(FEventHandle);
end;

// ---------------------  TDevItem ---------------------------
constructor TDevItem.Create(AId: TAccId; OpenParams: TOpenParams);
var
  i: integer;
begin
  inherited Create;
  AccId := AId;
  ComNr := OpenParams.ComNr;
  FDevNr := OpenParams.DevNr;
  BaudRate := OpenParams.BaudRate;
  FMdbMode := OpenParams.MdbMode;
  FParity := OpenParams.Parity;
  FBitCnt := OpenParams.BitCnt;
  FMdbMemAccess := OpenParams.MdbMemAccess;

  DriverMode := dmFAST; // ;
  Rs485Wait := false;
  FClr_ToRdCnt := false;
  TerminalReadTime := 100;

  LastFinished := GetTickCount;
  MaxTimeWaitSemafor := 5000;
  CountDivide := 128;
  MdbStdCndDiv := MAX_MDB_STD_FRAME_SIZE;

  for i := 0 to TERMINAL_CNT - 1 do
  begin
    FTermialTab[i].PipeHandle := INVALID_HANDLE_VALUE;
    FTermialTab[i].RunFlag := false;
    FTermialTab[i].Thread := TTerminalThread.Create(self);
  end;

end;

destructor TDevItem.Destroy;
var
  i: integer;
begin
  inherited Destroy;
  for i := 0 to TERMINAL_CNT - 1 do
  begin
    FTermialTab[i].Thread.Terminate;
    FTermialTab[i].Thread.SetRunFlag(false);
    FTermialTab[i].Thread.WaitFor;
    FTermialTab[i].Thread.Free;
  end;
end;

function TDevItem.ValidHandle: boolean;
begin
  Result := (ComHandle <> INVALID_HANDLE_VALUE);
end;

const
  TabCharSize: array [TBaudRate] of real = (10 * (1000 / 110), // br110
    10 * (1000 / 300), // br300
    10 * (1000 / 600), // br600
    10 * (1000 / 1200), // br1200
    10 * (1000 / 2400), // br2400
    10 * (1000 / 4800), // br4800
    10 * (1000 / 9600), // br9600
    10 * (1000 / 14400), // br14400
    10 * (1000 / 19200), // br19200
    10 * (1000 / 38400), // br38400
    10 * (1000 / 56000), // br56000
    10 * (1000 / 57600), // br57600
    10 * (1000 / 115200)); // br115200

function TDevItem.SetupState: TStatus;
var
  DCB: TDCB;
  Timeouts: TCommTimeouts;
  RMode: TFPURoundingMode;
  t: cardinal;
  ErrCode: integer;
  s: string;
begin
  FillChar(DCB, sizeof(DCB), 0);
  DCB.DCBlength := sizeof(DCB);
  DCB.Flags := DCB.Flags or dcb_Binary;
  if FParity <> paNONE then
  begin
    DCB.Flags := DCB.Flags or dcb_Parity;
    if FParity = paEVEN then
      DCB.Parity := EVENPARITY;
    if FParity = paODD then
      DCB.Parity := ODDPARITY;
  end
  else
    DCB.Parity := NOPARITY;
  DCB.StopBits := ONESTOPBIT;
  case BaudRate of
    br110:
      DCB.BaudRate := CBR_110;
    br300:
      DCB.BaudRate := CBR_300;
    br600:
      DCB.BaudRate := CBR_600;
    br1200:
      DCB.BaudRate := CBR_1200;
    br2400:
      DCB.BaudRate := CBR_2400;
    br4800:
      DCB.BaudRate := CBR_4800;
    br9600:
      DCB.BaudRate := CBR_9600;
    br14400:
      DCB.BaudRate := CBR_14400;
    br19200:
      DCB.BaudRate := CBR_19200;
    br38400:
      DCB.BaudRate := CBR_38400;
    br56000:
      DCB.BaudRate := CBR_56000;
    br57600:
      DCB.BaudRate := CBR_57600;
    br115200:
      DCB.BaudRate := CBR_115200;
  end;
  case FBitCnt of
    bit8:
      DCB.ByteSize := 8;
    bit7:
      DCB.ByteSize := 7;
    bit6:
      DCB.ByteSize := 6;
  else
    DCB.ByteSize := 8;
  end;

  DCB.XonLim := 2048;
  DCB.XoffLim := 1024;
  DCB.XonChar := #17;
  DCB.XoffChar := #19;

  Result := stSetupErr;
  if not SetCommState(ComHandle, DCB) then
  begin
    ErrCode := GetLastError;
    s := SysErrorMessage(ErrCode);
    Exit;
  end;
  if not GetCommTimeouts(ComHandle, Timeouts) then
    Exit;

  if DriverMode = dmSTD then
  begin
    RMode := GetRoundMode;
    SetRoundMode(rmUp);
    Timeouts.ReadIntervalTimeout := round(10 * TabCharSize[BaudRate]);
    t := round(4 * TabCharSize[BaudRate]);
    if t < 5 then
      t := 5;
    Timeouts.ReadTotalTimeoutMultiplier := t;

    Timeouts.ReadIntervalTimeout := 30;
    Timeouts.ReadTotalTimeoutMultiplier := 1; // todo
    Timeouts.ReadTotalTimeoutConstant := 100;
    SetRoundMode(RMode);
  end
  else
  begin
    Timeouts.ReadIntervalTimeout := MAXDWORD;
    Timeouts.ReadTotalTimeoutMultiplier := 0;
    Timeouts.ReadTotalTimeoutConstant := 0;
  end;

  Timeouts.WriteTotalTimeoutMultiplier := 0;
  Timeouts.WriteTotalTimeoutConstant := 0;
  if not SetCommTimeouts(ComHandle, Timeouts) then
    Exit;
  if not SetupComm(ComHandle, $400, $400) then
    Exit;
  Result := stOK;
end;

function TDevItem.Open: TStatus;
begin
  FrameRepCnt := 0;
  FrameCnt := 0;
  WaitCnt := 0;
  SumRecTime := 0;
  SumSendTime := 0;

  Result := stNotOpen;
  if GlobComList.GetComAccessHandle(ComNr, ComHandle, SemHandle) then
  begin
    if GetComAcces then
    begin
      Result := SetupState;
      ReleaseComAcces;
    end
    else
      Result := stNoSemafor;
  end;
end;

procedure TDevItem.Close;
begin
  ComHandle := INVALID_HANDLE_VALUE;
  SemHandle := INVALID_HANDLE_VALUE;
  GlobDevList.UpdateCom(ComNr);
end;

function TDevItem.isOpen: boolean;
begin
  Result := (ComHandle <> INVALID_HANDLE_VALUE)
end;

procedure TDevItem.SetSmallInt(const b; Val: Smallint);
var
  p: pByte;
begin
  p := @b;
  p^ := byte(Val shr 8);
  inc(p);
  p^ := byte(Val);
end;

function TDevItem.GetLongInt(const b): cardinal;
var
  p: pByte;
begin
  p := @b;
  Result := p^;
  inc(p);
  Result := (Result shl 8) or p^;
  inc(p);
  Result := (Result shl 8) or p^;
  inc(p);
  Result := LongInt((Result shl 8) or p^);
end;

procedure TDevItem.SetLongInt(const b; Val: cardinal);
var
  p: pByte;
begin
  p := @b;
  p^ := byte(Val shr 24);
  inc(p);
  p^ := byte(Val shr 16);
  inc(p);
  p^ := byte(Val shr 8);
  inc(p);
  p^ := byte(Val);
end;

function TDevItem.GetDWord(const b): cardinal;
var
  p: pByte;
begin
  p := @b;
  Result := p^;
  inc(p);
  Result := (Result shl 8) or p^;
  inc(p);
  Result := (Result shl 8) or p^;
  inc(p);
  Result := (Result shl 8) or p^;
end;

{
  procedure TDevItem.SetDWord(const b; Val :cardinal);
  var
  p : pByte;
  begin
  p := @b;
  p^ := byte(Val shr 24);
  inc(p);
  p^ := byte(Val shr 16);
  inc(p);
  p^ := byte(Val shr 8);
  inc(p);
  p^ := byte(Val);
  end;
}

// -------------------- Obsluga RS  -----------------------------------------

function TDevItem.GetComAcces: boolean;
begin
  Result := (WaitForSingleObject(SemHandle, MaxTimeWaitSemafor) = WAIT_OBJECT_0);
end;

procedure TDevItem.ReleaseComAcces;
var
  LCnt: cardinal;
begin
  ReleaseSemaphore(SemHandle, 1, @LCnt);
end;

function TDevItem.InQue: integer;
var
  Errors: cardinal;
  ComStat: TComStat;
begin
  ClearCommError(ComHandle, Errors, @ComStat);
  Result := ComStat.cbInQue;
end;

function TDevItem.OutQue: integer;
var
  Errors: cardinal;
  ComStat: TComStat;
begin
  ClearCommError(ComHandle, Errors, @ComStat);
  Result := ComStat.cbOutQue;
end;

function TDevItem.RsWrite(Buffer: TBytes): integer;
var
  Overlapped: TOverlapped;
  BytesWritten: cardinal;
  q: boolean;
  TT: cardinal;
begin
  TT := GetTickCount;
  FillChar(Overlapped, sizeof(Overlapped), 0);
  Overlapped.hEvent := CreateEvent(nil, true, true, nil);
  WriteFile(ComHandle, Buffer[0], length(Buffer), BytesWritten, @Overlapped);

  WaitForSingleObject(Overlapped.hEvent, INFINITE);
  q := GetOverlappedResult(ComHandle, Overlapped, BytesWritten, false);
  CloseHandle(Overlapped.hEvent);
  Result := BytesWritten;
  if not(q) then
    Result := 0;
  TT := cardinal(GetTickCount - TT);
  inc(SumSendTime, TT);
end;

var
  TTTT: cardinal;
  TTTT2: cardinal;

function TDevItem.RsRead(var Buffer; Count: integer): integer;
var
  Overlapped: TOverlapped;
  BytesRead: cardinal;
  q: boolean;
begin
  TTTT := GetTickCount;
  FillChar(Overlapped, sizeof(Overlapped), 0);
  Overlapped.hEvent := CreateEvent(nil, true, true, nil);
  ReadFile(ComHandle, Buffer, Count, BytesRead, @Overlapped);
  TTTT2 := GetTickCount;
  WaitForSingleObject(Overlapped.hEvent, 1000);
  TTTT2 := GetTickCount - TTTT2;
  q := GetOverlappedResult(ComHandle, Overlapped, BytesRead, false);
  CloseHandle(Overlapped.hEvent);
  Result := BytesRead;
  if not(q) then
    Result := 0;
  TTTT := GetTickCount - TTTT;
end;

function TDevItem.RsReadByte(var b: byte): boolean;
begin
  Result := (RsRead(b, 1) = 1);
end;

procedure TDevItem.PurgeInOut;
begin
  PurgeComm(ComHandle, PURGE_RXABORT or PURGE_RXCLEAR or PURGE_TXABORT or PURGE_TXCLEAR);
end;

procedure TDevItem.CallBackFunct(Ev: integer; R: real);
begin
  if Assigned(FCallBackFunc) then
    FCallBackFunc(AccId, FCmmId, Ev, R);
end;

procedure TDevItem.SetProgress(F: real);
begin
  CallBackFunct(evProgress, F);
end;

procedure TDevItem.SetProgress(Cnt, Max: integer);
Var
  R: real;
begin
  if Max <> 0 then
    R := 100 * (Cnt / Max)
  else
    R := 100;
  SetProgress(R);
end;

procedure TDevItem.MsgFlowSize(R: real);
begin
  CallBackFunct(evFlow, R);
end;

procedure TDevItem.SetWorkFlag(w: boolean);
begin
  if w then
    CallBackFunct(evWorkOnOff, 1)
  else
    CallBackFunct(evWorkOnOff, 0);
end;

procedure TDevItem.FSetCountDivide(AValue: integer);
begin
  if AValue > MAX_MDB_FRAME_SIZE then
    AValue := MAX_MDB_FRAME_SIZE;
  FCountDivide := AValue;
end;

procedure TDevItem.FSetMdbStdCndDiv(AValue: integer);
begin
  if AValue > MAX_MDB_STD_FRAME_SIZE then
    AValue := MAX_MDB_STD_FRAME_SIZE;
  FMdbStdCndDiv := AValue;
end;

// -----------------------------------------------------------------------------
// --------   OBSLUGA PROTOKOLU    ---------------------------------------------
// -----------------------------------------------------------------------------
function TDevItem.ReciveRTUAnswer(var Buffer: TBytes): boolean;
{
  function ShiftToBuf(var Buffer; RecLen:integer; var SrcBuf; L:integer): integer;
  var
  p : pByte;
  begin
  if L<>0 then
  begin
  p := pByte(@Buffer);
  inc(p,RecLen);
  move(SrcBuf,p^,L);
  inc(RecLen,L);
  end;
  Result := RecLen;
  end;
}
const
  TIME_TO_RPL = 200;
var
  TT: cardinal;
  T2: cardinal;
  q: TByteAr;
  dT: cardinal;
  L: integer;
  TimeFlag: boolean;
  ToReadCnt: integer;
  RecLen: integer;
begin
  ToReadCnt := length(Buffer);

  if FClr_ToRdCnt then
    ToReadCnt := 0;
  if ToReadCnt = 0 then
    setLength(Buffer, MAX_MDB_FRAME_SIZE);

  T2 := GetTickCount;
  if DriverMode = dmSTD then
  begin
    RecLen := RsRead(Buffer[0], length(Buffer));
    setLength(Buffer, RecLen);
  end
  else
  begin
    dT := round(5 * TabCharSize[BaudRate]);
    if dT < 10 then
      dT := 10;

    TT := GetTickCount;
    RecLen := 0;
    while RecLen = 0 do
    begin
      L := RsRead(q[RecLen], sizeof(q) - RecLen);
      inc(RecLen, L);
      if (DriverMode = dmSLOW) and (L = 0) then
        sleep(dT);
      if GetTickCount - TT > TIME_TO_RPL then
      begin
        break;
      end;
    end;

    TT := GetTickCount;
    TimeFlag := false;
    while true do
    begin
      if RecLen = sizeof(q) then
        break;
      try
        L := RsRead(q[RecLen], sizeof(q) - RecLen);
      except
        L := 0;
      end;
      inc(RecLen, L);
      if L <> 0 then
      begin
        TT := GetTickCount;
        TimeFlag := false;
      end;
      if (ToReadCnt <> 0) and (ToReadCnt = RecLen) then
      begin
        break;
      end;
      if GetTickCount - TT > dT then
      begin
        if TimeFlag then
        begin
          break;
        end
        else
        begin
          sleep(dT);
        end;
        TimeFlag := true;
      end;
      if (DriverMode = dmSLOW) and (L = 0) then
        sleep(dT);
    end;

    if RecLen > length(Buffer) then
      RecLen := length(Buffer);
    move(q, Buffer[0], RecLen);
  end;
  T2 := GetTickCount - T2;
  inc(SumRecTime, T2);

  if (ToReadCnt = 0) or (ToReadCnt = RecLen) then
  begin
    setLength(Buffer, RecLen);
    if RecLen > 0 then
      Result := TCrc.CheckCRC(Buffer[0], RecLen)
    else
      Result := false;
  end
  else
    Result := false;
end;

function TDevItem.ReciveASCIIAnswer(var Buffer: TBytes): boolean;
// ReciveASCIIAnswer(var Buffer; ToReadCnt: integer; var RecLen: integer): boolean;
  function HexVal(ch: Char): byte;
  begin
    if (ch >= '0') and (ch <= '9') then
      Result := ord(ch) - ord('0')
    else if (ch >= 'A') and (ch <= 'F') then
      Result := ord(ch) - ord('A') + 10
    else if (ch >= 'a') and (ch <= 'f') then
      Result := ord(ch) - ord('a') + 10
    else
      Result := 0;
  end;

var
  RecBuf: array of Char;
  n: integer;
  Len: cardinal;
  i: integer;
  a: byte;
  sum: byte;
begin
  Result := false;
  n := sizeof(TByteAr) * 2 + 3;
  setLength(RecBuf, n);
  Len := RsRead(RecBuf[0], n);
  if (Len > 3) and (RecBuf[0] = ':') and (RecBuf[Len - 1] = #10) and (RecBuf[Len - 2] = #13) then
  begin
    n := (Len - 3) div 2;
    setLength(Buffer, n);
    sum := 0;
    for i := 0 to n - 1 do
    begin
      a := 16 * HexVal(RecBuf[2 * i + 1]) + HexVal(RecBuf[2 * i + 2]);
      Buffer[i] := a;
      sum := byte(sum + a);
    end;
    if sum = 0 then
      Result := true;
  end
  else
    setLength(Buffer, 0);
  setLength(RecBuf, 0);
end;

function TDevItem.Konwers(showProgress: boolean; Buf: TBytes; var OutBuf: TBytes): TStatus;
begin
  Result := Konwers(showProgress, 5, Buf, OutBuf);
end;

function TDevItem.Konwers(Buf: TBytes; var OutBuf: TBytes): TStatus;
begin
  Result := Konwers(true, 5, Buf, OutBuf);
end;

function TDevItem.Konwers(showProgress: boolean; RepZad: integer; Buf: TBytes; var OutBuf: TBytes): TStatus;
label
  ExitP;
  procedure WriteToFile(const Buf; Len: integer);
  var
    Str: TMemoryStream;
  begin
    Str := TMemoryStream.Create;
    try
      Str.Write(Buf, Len);
      Str.SaveToFile('Buffer.bin');
    finally
      Str.Free;
    end;
  end;

// procedure BildAsciiBuf(var BufToSnd; const b; Count: integer);
  function BildAsciiBuf(Buf: TBytes): TBytes;
    procedure PlaceChar(Buf: TBytes; var wsk: integer; b: AnsiChar);
    begin
      Buf[wsk] := ord(b);
      inc(wsk);
    end;

    procedure PlaceByte(Buf: TBytes; var wsk: integer; b: byte);
    const
      HexCyfr: array [0 .. 15] of AnsiChar = '0123456789ABCDEF';
    begin
      PlaceChar(Buf, wsk, HexCyfr[(b shr 4) and $0F]);
      PlaceChar(Buf, wsk, HexCyfr[b and $0F]);
    end;

  var
    i: integer;
    a: byte;
    sum: byte;
    n: integer;
    wsk: integer;
  begin
    n := length(Buf);
    setLength(Result, 1 + 2 * (n + 1) + 2);

    wsk := 0;
    PlaceChar(Result, wsk, ':');

    sum := 0;
    for i := 0 to n - 1 do
    begin
      a := Buf[i];
      sum := byte(sum + a);
      PlaceByte(Result, wsk, a);
    end;
    sum := $100 - sum;
    PlaceByte(Result, wsk, sum);

    PlaceChar(Result, wsk, #$0D);
    PlaceChar(Result, wsk, #$0A);
  end;

  function BuilBufToSnd(Buf: TBytes): TBytes;
  var
    n: integer;
    w: word;
  begin
    case FMdbMode of
      mdbRTU:
        begin
          n := length(Buf);
          setLength(Result, n + 2);
          move(Buf[0], Result[0], n);
          w := TCrc.MakeCRC(Result[0], n);
          Result[n] := lo(w);
          Result[n + 1] := hi(w);
        end;
      mdbASCII:
        Result := BildAsciiBuf(Buf);
    else
      Result := nil;
    end;
  end;

var
  w: word;
  Rep: byte;
  q: boolean;
  BufToSnd: TBytes;
  CntToSnd: integer;
  Cmd: byte;
  CmdRep: byte;
  ToReadCnt: integer;
begin
  if not(ValidHandle) then
  begin
    ErrStr := 'Nie otwarty port.';
    Result := stNotOpen;
    goto ExitP;
  end;
  if GetComAcces then
  begin
    ToReadCnt := length(OutBuf);
    if showProgress then
    begin
      SetProgress(0);
      MsgFlowSize(0);
      SetWorkFlag(true);
    end;

    BufToSnd := BuilBufToSnd(Buf);

    if BufToSnd <> nil then
    begin
      if Buf[0] <> 0 then // !Brodcast
      begin
        Rep := RepZad;
        repeat
          q := true;
          CmdRep := 0;
          if not(FBreakFlag) then
          begin
            PurgeInOut;
            inc(FrameCnt);
            if Rs485Wait then
            begin
              while GetTickCount - LastFinished < 2 do
              begin
                sleep(1);
                inc(WaitCnt);
              end;
            end;
            RsWrite(BufToSnd);

            case FMdbMode of
              mdbRTU:
                q := ReciveRTUAnswer(OutBuf);
              mdbASCII:
                q := ReciveASCIIAnswer(OutBuf);
            else
              q := false;
            end;
            if q and (length(OutBuf) > 4) then
            begin
              Cmd := Buf[1];
              CmdRep := OutBuf[1];
              q := (OutBuf[0] = FDevNr) and (Cmd = (CmdRep and $7F));
            end;

            if not(q) then
            begin
              inc(FrameRepCnt);
              dec(Rep);
              if (Rep <> 0) then
              begin
                sleep(10)
              end;
            end;
            LastFinished := GetTickCount;
          end;
        until (Rep = 0) or q or FBreakFlag;

        Result := stOK;
        if FBreakFlag then
        begin
          Result := stUserBreak;
        end
        else if Rep = 0 then
        begin
          if length(OutBuf) = 0 then
            Result := stNoReplay
          else
            Result := stBadRepl;
        end
        else if not(q) then
        begin
          Result := stTimeErr;
        end
        else
        begin
          if (CmdRep and $80) <> 0 then
          begin
            if OutBuf[2] <> 4 then
              Result := stMdbError + OutBuf[2]
            else
              Result := stMdbExError + OutBuf[3];
          end;
        end;
        if showProgress then
        begin
          SetProgress(100);
          SetWorkFlag(false);
        end;
      end
      else
      begin // Brodcast
        PurgeInOut;
        RsWrite(BufToSnd);
        Result := stOK;
      end;
    end;
    setLength(BufToSnd, 0);
    ReleaseComAcces;
  end
  else
    Result := stNoSemafor;
ExitP:

end;

procedure TDevItem.BreakPulse;
begin
  if ValidHandle then
  begin
    if GetComAcces then
    begin
      SetCommBreak(ComHandle);
      sleep(10);
      ClearCommBreak(ComHandle);
      ReleaseComAcces;
    end;
  end;
end;

function TDevItem.SetBreakFlag(Val: boolean): TStatus;
begin
  FBreakFlag := Val;
  Result := stOK;
end;

function TDevItem.GetDrvInfo: String;
  procedure AddItem(jArr: TJSONArray; Name, descr, Val: string); overload;
  var
    jBuild: TJSONBuilder;
  begin
    jBuild.Init;
    jBuild.Add(DRVINFO_NAME, Name);
    jBuild.Add(DRVINFO_DESCR, descr);
    jBuild.Add(DRVINFO_VALUE, Val);
    jArr.AddElement(jBuild.jobj);
  end;

  procedure AddItem(jArr: TJSONArray; Name, descr: string; Val: integer); overload;
  begin
    AddItem(jArr, Name, descr, IntToStr(Val));
  end;

var
  s: String;
  ParamName: String;
  jBuild: TJSONBuilder;
  jArr: TJSONArray;
begin
  jArr := TJSONArray.Create;
  AddItem(jArr, 'FRAME_CNT', 'Count of transmited frames', FrameCnt);
  AddItem(jArr, 'REPEAT_CNT', 'Count of repetition', FrameRepCnt);
  AddItem(jArr, 'WAIT_CNT', '', WaitCnt);
  AddItem(jArr, 'RECIVE_TIME', '', SumRecTime);
  AddItem(jArr, 'SEND_TIME', '', SumSendTime);

  jBuild.Init;
  jBuild.Add(DRVINFO_LIST, jArr);
  jBuild.Add(DRVINFO_TIME, TimeToStr(Now));

  Result := jBuild.jobj.ToString;

end;

const
  PAR_ITEM_DIVIDE_LEN = 'DIVIDE_LEN';
  PAR_ITEM_DRIVER_MODE = 'DRIVER_MODE';
  DriverModeName: TStringArr = ['STD', 'SLOW', 'FAST'];

function getDriverMode(Txt: string; default: TDriverMode): TDriverMode;
var
  i: TDriverMode;
begin
  Result := default;
  for i := low(TDriverMode) to high(TDriverMode) do
  begin
    if Txt = DriverModeName[ord(i)] then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TDevItem.GetDrvParams: String;

var
  jBuild: TJSONBuilder;
  vBuild: TJSONBuilder;
  p: TSttObjectListJson;
  sttObj : TSttObjectJson;
begin
  jBuild.Init;
  //description section
  p := TSttObjectListJson.Create;
  try
    sttObj := TSttIntObjectJson.Create(PAR_ITEM_DIVIDE_LEN, 'Read/write memory divide bloks', 40, 240, 128);
    sttObj.SetUniBool(true); //UniBool=true - allow change during open connection
    p.Add(sttObj);
    sttObj := TSttSelectObjectJson.Create(PAR_ITEM_DRIVER_MODE, 'Driver work mode', DriverModeName, 'STD');
    sttObj.SetUniBool(false);
    p.Add(sttObj);
    jBuild.Add(DRVPRAM_DEFINITION, p.getJSonObject);
  finally
    p.Free;
  end;

  //value section
  vBuild.Init;
  vBuild.Add(PAR_ITEM_DIVIDE_LEN, FCountDivide);
  vBuild.Add(PAR_ITEM_DRIVER_MODE, DriverModeName[ord(DriverMode)]);
  jBuild.Add(DRVPRAM_VALUES, vBuild.jobj);
  jBuild.Add(DRVPRAM_DRIVER_NAME, DRIVER_NAME);

  Result := jBuild.jobj.ToString;
end;

function TDevItem.SetDrvParams(const jsonParams: string): TStatus;
var
  jLoader: TJsonLoader;
  vInt: integer;
  vTxt: string;
begin
  Result := stOK;
  jLoader.Init(TJSONObject.ParseJSONValue(jsonParams));
  if jLoader.Load(PAR_ITEM_DIVIDE_LEN, vInt) then
    FCountDivide := vInt
  else
    Result := stBadArguments;
  if jLoader.Load(PAR_ITEM_DRIVER_MODE, vTxt) then
    DriverMode := getDriverMode(vTxt, DriverMode)
  else
    Result := stBadArguments;
end;

procedure TDevItem.RegisterCallBackFun(ACallBackFunc: TCallBackFunc; CmmId: integer);
begin
  FCallBackFunc := ACallBackFunc;
  FCmmId := CmmId;
end;


// -----------------------------------------------------

function TDevItem.RdOutTable(var Buf; Adress: word; Count: word): TStatus;
var
  q: TBytes;
  QA: TBytes;
  i: word;
  b, mask: byte;
begin
  setLength(q, 6);
  q[0] := FDevNr;
  q[1] := $01;
  SetSmallInt(q[2], Smallint(Adress));
  SetSmallInt(q[4], Smallint(Count));
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    if (QA[0] = FDevNr) and (QA[1] = 1) then
    begin
      for i := 0 to Count - 1 do
      begin
        b := QA[3 + (i div 8)];
        mask := $01 shl (i mod 8);
        TTabBit(Buf)[i] := ((b and mask) <> 0);
      end;
    end
    else
      Result := stBadRepl;
  end;
end;

function TDevItem.RdInpTable(var Buf; Adress: word; Count: word): TStatus;
var
  q: TBytes;
  QA: TBytes;
  i: word;
  b, mask: byte;
begin
  setLength(q, 6);
  q[0] := FDevNr;
  q[1] := $02;
  SetSmallInt(q[2], Smallint(Adress));
  SetSmallInt(q[4], Smallint(Count));
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    if (QA[0] = FDevNr) and (QA[1] = 2) then
    begin
      for i := 0 to Count - 1 do
      begin
        b := QA[3 + (i div 8)];
        mask := $01 shl (i mod 8);
        TTabBit(Buf)[i] := ((b and mask) <> 0);
      end;
    end
    else
      Result := stBadRepl;
  end;
end;

function TDevItem.RdRegHd(var QA: TBytes; Adress: word; Count: word): TStatus;
var
  q: TBytes;
begin
  if Adress > 0 then
  begin
    setLength(q, 6);
    dec(Adress);
    q[0] := FDevNr;
    q[1] := $03;
    SetSmallInt(q[2], Smallint(Adress));
    SetSmallInt(q[4], Smallint(Count));
    Result := Konwers(false, q, QA);
    if Result = stOK then
    begin
      if not((QA[0] = FDevNr) and (QA[1] = $03)) then
        Result := stBadRepl;
    end;
  end
  else
    Result := stBadArguments;
end;

function TDevItem.RdReg(var Buf; Adress: word; Count: word): TStatus;
var
  Cnt: word;
  QA: TBytes;
  i: word;
  w: word;
  st: TStatus;
  n: integer;
  SCnt: integer;
  Count1: integer;
begin
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  n := 0;
  st := stOK;
  Count1 := Count;
  SCnt := 0;
  while (Count <> 0) and (st = stOK) do
  begin
    Cnt := Count;
    if Cnt > FMdbStdCndDiv then
      Cnt := FMdbStdCndDiv;
    st := RdRegHd(QA, Adress, Cnt);
    if st = stOK then
    begin
      for i := 0 to Cnt - 1 do
      begin
        w := QA[2 * i + 3] * 256 + QA[2 * i + 4];
        TTabWord(Buf)[n] := w;
        inc(n);
      end;
    end;

    Adress := word(Adress + Cnt);
    Count := Count - Cnt;
    SCnt := SCnt + Cnt;

    SetProgress(SCnt, Count1);
    MsgFlowSize(SCnt);
  end;

  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
  Result := st;
end;

function TDevItem.RdAbnalogInpHd(var QA: TBytes; Adress: word; Count: word): TStatus;
var
  q: TBytes;
begin
  if Adress > 0 then
  begin
    setLength(q, 6);
    dec(Adress);
    q[0] := FDevNr;
    q[1] := $04;
    SetSmallInt(q[2], Smallint(Adress));
    SetSmallInt(q[4], Smallint(Count));
    setLength(QA, 0);
    Result := Konwers(false, q, QA);
    if Result = stOK then
    begin
      if not((QA[0] = FDevNr) and (QA[1] = $04) and (QA[2] = Count * 2) and (length(QA) = 3 + 2 * Count + 2)) then
        Result := stBadRepl;
    end;
  end
  else
    Result := stBadArguments;
end;

function TDevItem.RdAnalogInp(var Buf; Adress: word; Count: word): TStatus;
var
  Cnt: word;
  QA: TBytes;
  i: word;
  w: word;
  st: TStatus;
  n: integer;
  SCnt: integer;
  Count1: integer;
begin
  try
    SetProgress(0);
    MsgFlowSize(0);
    SetWorkFlag(true);

    n := 0;
    st := stOK;
    Count1 := Count;
    SCnt := 0;
    while (Count <> 0) and (st = stOK) do
    begin
      Cnt := Count;
      if Cnt > FMdbStdCndDiv then
        Cnt := FMdbStdCndDiv;
      st := RdAbnalogInpHd(QA, Adress, Cnt);
      if st = stOK then
      begin
        for i := 0 to Cnt - 1 do
        begin
          w := QA[2 * i + 3] * 256 + QA[2 * i + 4];
          TTabWord(Buf)[n] := w;
          inc(n);
        end;
      end;

      Adress := word(Adress + Cnt);
      Count := Count - Cnt;
      SCnt := SCnt + Cnt;

      SetProgress(SCnt, Count1);
      MsgFlowSize(SCnt);
    end;
    SetProgress(100);
    MsgFlowSize(Count);
    SetWorkFlag(false);
  except
    st := stDelphiError;
  end;
  Result := st;
end;

function TDevItem.WrOutput(Adress: word; Val: boolean): TStatus;
var
  q: TBytes;
  QA: TBytes;
  i: byte;
begin
  setLength(q, 6);
  dec(Adress);
  q[0] := FDevNr;
  q[1] := $05;
  SetSmallInt(q[2], Smallint(Adress));
  if Val then
    q[4] := $FF
  else
    q[4] := $00;
  q[5] := $00;
  setLength(QA, 8);
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    if FDevNr <> 0 then
    begin
      for i := 0 to 5 do
        if q[i] <> QA[i] then
          Result := stBadRepl;
    end;
  end;
end;

function TDevItem.WrReg(Adress: word; Val: word): TStatus;
var
  q: TBytes;
  QA: TBytes;
  i: integer;
begin
  setLength(q, 6);
  dec(Adress);
  q[0] := FDevNr;
  q[1] := $06;
  SetSmallInt(q[2], Smallint(Adress));
  SetSmallInt(q[4], Smallint(Val));
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    if FDevNr <> 0 then
    begin
      for i := 0 to 5 do
        if q[i] <> QA[i] then
          Result := stBadRepl;
    end;
  end;
end;

function TDevItem.RdStatus(var Val: byte): TStatus;
var
  q: TBytes;
  QA: TBytes;
begin
  setLength(q, 2);
  q[0] := FDevNr;
  q[1] := $07;
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
    if not((QA[0] = FDevNr) and (QA[1] = 7)) then
      Result := stBadRepl;
  if Result = stOK then
    Val := QA[2];
end;

function TDevItem.WrMultiRegHd(Adress: word; Count: word; pW: pWord): TStatus;
var
  q: TBytes;
  QA: TBytes;
  w: word;
  i: integer;
  rCnt: word;
  rAdr: word;
begin
  setLength(q, 7 + 2 * Count);
  dec(Adress);
  q[0] := FDevNr;
  q[1] := 16;
  SetSmallInt(q[2], Smallint(Adress));
  SetSmallInt(q[4], Smallint(Count));
  q[6] := 2 * Count;
  for i := 0 to Count - 1 do
  begin
    w := pW^;
    inc(pW);
    q[7 + i * 2 + 0] := byte(w shr 8);
    q[7 + i * 2 + 1] := byte(w);
  end;
  setLength(QA, 0);
  Result := Konwers(false, q, QA);
  if Result = stOK then
  begin
    rAdr := QA[2] * 256 + QA[3];
    rCnt := QA[4] * 256 + QA[5];
    if FDevNr <> 0 then
    begin
      if not((QA[0] = FDevNr) and (QA[1] = 16) and (rCnt = Count) and (rAdr = Adress)) then
        Result := stBadRepl;
    end;
  end;
end;

function TDevItem.WrMultiReg(var Buf; Adress: word; Count: word): TStatus;
var
  Cnt: word;
  st: TStatus;
  pW: pWord;
  SCnt: integer;
begin
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  st := stOK;
  pW := pWord(@Buf);
  SCnt := 0;
  while (Count <> 0) and (st = stOK) do
  begin
    Cnt := Count;
    if Cnt > FMdbStdCndDiv then
      Cnt := FMdbStdCndDiv;
    st := WrMultiRegHd(Adress, Cnt, pW);
    inc(pW, Cnt);
    Adress := word(Adress + Cnt);
    dec(Count, Cnt);
    inc(SCnt, Cnt);
    SetProgress(SCnt, Count);
    MsgFlowSize(SCnt);
  end;

  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);

  Result := st;
end;

{$Q-}

function TDevItem.RdMemory(var Buf; Adress: cardinal; Count: cardinal): TStatus;

  function RdMemoryHd(FDevNr: byte; Adress: cardinal; Count: byte; var QA: TBytes): TStatus;
  var
    q: TBytes;
  begin
    setLength(q, 8);
    q[0] := FDevNr;
    q[1] := 41;
    q[2] := Count;
    q[3] := 0;
    SetLongInt(q[4], Adress);
    setLength(QA, Count + 10);

    Result := Konwers(false, q, QA);
    if Result = stOK then
      if not((QA[0] = FDevNr) and (QA[1] = 41)) then
        Result := stBadRepl;
  end;

var
  Cnt: integer;
  QA: TBytes;
  i: word;
  st: TStatus;
  p: pByte;
  SCnt: cardinal;
begin
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  st := stOK;
  p := pByte(@Buf);
  SCnt := 0;
  while (SCnt <> Count) and (st = stOK) do
  begin
    Cnt := Count - SCnt;
    if Cnt > FCountDivide then
      Cnt := FCountDivide;
    st := RdMemoryHd(FDevNr, Adress, Cnt, QA);
    if st = stOK then
    begin
      for i := 0 to Cnt - 1 do
      begin
        p^ := QA[i + 8];
        inc(p);
      end;
    end;
    inc(Adress, Cnt);
    inc(SCnt, Cnt);
    SetProgress(SCnt, Count);
    MsgFlowSize(SCnt);
  end;
  Result := st;
  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
end;
{$Q+}
{$Q-}

function TDevItem.WrMemory(const Buf; Adress: cardinal; Count: cardinal): TStatus;

  function WrMemoryHd(FDevNr: byte; Adress: cardinal; Count: byte; p: pByte): TStatus;
  var
    q: TBytes;
    QA: TBytes;
  begin
    setLength(q, 8 + Count);
    q[0] := FDevNr;
    q[1] := 42;
    q[2] := Count;
    q[3] := 0;
    SetLongInt(q[4], Adress);
    move(p^, q[8], Count);
    setLength(QA, 10);
    Result := Konwers(false, q, QA);
    if Result = stOK then
      if not((QA[0] = FDevNr) and (QA[1] = 42)) then
        Result := stBadRepl;
  end;

var
  Cnt: integer;
  st: TStatus;
  p: pByte;
  SCnt: cardinal;
begin
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  st := stOK;
  p := pByte(@Buf);
  SCnt := 0;
  while (Count <> SCnt) and (st = stOK) do
  begin
    Cnt := Count - SCnt;
    if Cnt > FCountDivide then
      Cnt := FCountDivide;
    st := WrMemoryHd(FDevNr, Adress, Cnt, p);
    inc(p, Cnt);
    inc(Adress, Cnt);
    inc(SCnt, Cnt);
    SetProgress(SCnt, Count);
    MsgFlowSize(SCnt);
  end;
  Result := st;
  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
end;
{$Q+}

function TDevItem.TerminalSendKey(key: AnsiChar): TStatus;
var
  q: TBytes;
  QA: TBytes;
begin
  setLength(q, 3);
  q[0] := FDevNr;
  q[1] := 45;
  q[2] := ord(key);
  setLength(QA, 4);
  Result := Konwers(false, q, QA);
end;

function TDevItem.TerminalRead(Buf: PAnsiChar; var rdcnt: integer): TStatus;
var
  q: TBytes;
  QA: TBytes;
begin
  setLength(q, 2);
  q[0] := FDevNr;
  q[1] := 46;
  setLength(QA, 0);
  Result := Konwers(false, 1, q, QA);
  if Result = stBadRepl then
  begin
    q[0] := FDevNr;
    q[1] := 47;
    setLength(QA, 0);
    Result := Konwers(false, q, QA);
  end;

  if Result = stOK then
  begin
    rdcnt := length(QA) - 4;
    if rdcnt < 0 then
      rdcnt := 0;
    if rdcnt > 0 then
      move(QA[2], Buf^, rdcnt);
  end
  else
    rdcnt := 0;
end;

function TDevItem.TerminalSetPipe(TerminalNr: integer; PipeHandle: THandle): TStatus;
begin
  if TerminalNr < TERMINAL_CNT then
  begin
    FTermialTab[TerminalNr].PipeHandle := PipeHandle;
    FTermialTab[TerminalNr].RunFlag := false;
    FTermialTab[TerminalNr].Thread.FOutPipe := PipeHandle;
    Result := stOK;
  end
  else
    Result := stToBigTerminalNr;
end;

function TDevItem.TerminalSetRunFlag(TerminalNr: integer; RunFlag: boolean): TStatus;
begin
  if TerminalNr < TERMINAL_CNT then
  begin
    FTermialTab[TerminalNr].RunFlag := RunFlag;
    FTermialTab[TerminalNr].Thread.SetRunFlag(RunFlag);
    Result := stOK;
  end
  else
    Result := stToBigTerminalNr;
end;


// -- Files -----------------------------------------------------------------------------------------------

const
  crdOpenSesion = 50;
  crdCloseSesion = 51;
  crdOpenFile = 52;
  crdGetDirs = 53;
  // crdGetErrorStr  = 54;
  crdGetDriveList = 55;
  crdShell = 56;
  crdReadEx = 57;
  crdGetGuidEx = 58;
  crdGetErrorStr = 59;

  crdRead = 64; // wymagaja podania FileNr
  crdWrite = 65;
  crdSeek = 66;
  crdGetFileSize = 67;
  crdClose = 68; // ostatnia komenda z grupy FILE
  crdGetGuid = 69;

  MAX_DATA_BUF_SIZE = MAX_MDB_FRAME_SIZE - 4;

type
  // struktura zapytania z kana³u komunikacyjnego

  FSTR160 = array [0 .. 159] of AnsiChar;
  FSTR236 = array [0 .. 235] of AnsiChar;
  BUF234 = array [0 .. 233] of AnsiChar;

  PSEAskFrame = ^TSEAskFrame;

  TSEAskFrame = packed record
    AskCnt: word;
    SesionID: cardinal;
  end;

  PSEAskFrameWr = ^TSEAskFrameWr;

  TSEAskFrameWr = packed record
    AskCnt: word;
    SesionID: cardinal;
    FileNr: byte;
    Free: byte;
    Buf: BUF234;
  end;

  PSEAskFrameCmd = ^TSEAskFrameCmd;

  TSEAskFrameCmd = packed record
    AskCnt: word;
    SesionID: cardinal;
    Command: FSTR236;
  end;

  PSEAskFrameFile = ^TSEAskFrameFile;

  TSEAskFrameFile = packed record
    AskCnt: word;
    SesionID: cardinal;
    FileNr: byte;
    BArg1: byte;
    Arg1: cardinal;
  end;

  PSEAskFrameOpenFile = ^TSEAskFrameOpenFile;

  TSEAskFrameOpenFile = packed record
    AskCnt: word;
    SesionID: cardinal;
    OpenMode: byte;
    Free: byte;
    FName: FSTR160;
  end;

  PSEAskFrameReadEx = ^TSEAskFrameReadEx;

  TSEAskFrameReadEx = packed record
    AskCnt: word;
    SesionID: cardinal;
    autoclose: byte;
    SizeToRead: byte;
    FName: FSTR160;
  end;

  PSEAskFrameError = ^TSEAskFrameError;

  TSEAskFrameError = packed record
    ErrCode: Smallint;
  end;

  PSEAskFrameDir = ^TSEAskFrameDir;

  TSEAskFrameDir = packed record
    AskCnt: word;
    SesionID: cardinal;
    First: byte;
    Attrib: byte;
    Free: Smallint;
    Name: FSTR160;
  end;

  PSERplFrame = ^TSERplFrame;

  TSERplFrame = packed record
    Arg1: cardinal;
  end;

  PSERplFrameOpen = ^TSERplFrameOpen;

  TSERplFrameOpen = packed record
    FileNr: byte;
    Free: byte;
  end;

procedure TDevItem.TOpenParams.InitDefault;
begin
  ComNr := 1;
  DevNr := 1;
  BaudRate := br115200;
  BitCnt := bit8;
  Parity := paNONE;
  MdbMode := mdbRTU;
  MdbMemAccess := mdbmemGEKA;
end;

function TDevItem.GetNewAskNr: word;
begin
  inc(FAskNumber);
  Result := FAskNumber;
end;

function TDevItem.GetErrStr(Code: TStatus; Buffer: PAnsiChar; MaxLen: integer): boolean;

var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameError;
  st: TStatus;
begin
  setLength(q, 2 + sizeof(p^));
  q[0] := FDevNr;
  q[1] := crdGetErrorStr;
  p := PSEAskFrameError(@q[2]);
  p^.ErrCode := swap(Code);
  setLength(QA, 0);
  st := Konwers(q, QA);
  if st = stOK then
  begin
    System.AnsiStrings.StrPLCopy(Buffer, PAnsiChar(@QA[2]), MaxLen);
  end;
  Result := (st = stOK);
end;

function TDevItem.SeOpenSesion(var SesId: TSesID): TStatus;

var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrame;
begin
  setLength(q, 2 + 2);
  q[0] := FDevNr;
  q[1] := crdOpenSesion;
  p := PSEAskFrame(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
    SesId := GetDWord(QA[2]);
end;

function TDevItem.SeCloseSesion(SesId: TSesID): TStatus;
var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrame;
begin
  setLength(q, 2 + sizeof(p^));
  q[0] := FDevNr;
  q[1] := crdCloseSesion;
  p := PSEAskFrame(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  setLength(QA, 0);
  Result := Konwers(q, QA);
end;

function TDevItem.SeOpenFile(SesId: TSesID; FName: PAnsiChar; Mode: byte; var FileNr: TFileNr): TStatus;

var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameOpenFile;
  L: integer;
begin
  L := 2 + (2 + 4 + 2 + System.AnsiStrings.strlen(FName) + 1);
  setLength(q, L);
  q[0] := FDevNr;
  q[1] := crdOpenFile;
  p := PSEAskFrameOpenFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.OpenMode := Mode;
  System.AnsiStrings.StrPLCopy(p^.FName, FName, sizeof(p^.FName));
  setLength(QA, 0);
  Result := Konwers(q, QA);
  FileNr := QA[2];
end;

function TDevItem.SeGetDirHd(First: boolean; SesId: TSesID; FName: PAnsiChar; Attrib: byte; Buffer: PAnsiChar;
  MaxLen: integer; var Len: integer): TStatus;

var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameDir;
  RecLen: integer;
  L: integer;
begin
  if First then
    L := 2 + (2 + 4 + 4 + System.AnsiStrings.strlen(FName) + 1)
  else
    L := 2 + (2 + 4 + 1);
  setLength(q, L);

  q[0] := FDevNr;
  q[1] := crdGetDirs;
  p := PSEAskFrameDir(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  if First then
  begin
    p^.First := 1;
    p^.Attrib := Attrib;
    p^.Free := 0;
    System.AnsiStrings.StrPLCopy(p^.Name, FName, sizeof(p^.Name));
  end
  {
    TSEAskFrameDir = packed record
    AskCnt   : word;
    SesionID : cardinal;
    First    : byte;
    Attrib   : byte;
    Free     : smallint;
    Name     : FSTR160;
    end;
  }
  else
  begin
    p^.First := 0;
  end;
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    Len := RecLen - 4;
    if Len > MaxLen then
      Len := MaxLen;
    if Len <> 0 then
      move(QA[2], Buffer^, Len);
  end;
end;

function TDevItem.SeGetDir(SesId: TSesID; FName: PAnsiChar; Attrib: byte; Buffer: PAnsiChar; MaxLen: integer): TStatus;
var
  Len: integer;
  pch: PAnsiChar;
begin
  pch := Buffer;
  Result := SeGetDirHd(true, SesId, FName, Attrib, pch, MaxLen, Len);
  while (Result = stOK) and (Len <> 0) and (MaxLen <> 0) do
  begin
    pch := @pch[Len];
    dec(MaxLen, Len);

    if pch[-1] = #0 then
    begin
      break;
    end;

    Result := SeGetDirHd(false, SesId, FName, Attrib, pch, MaxLen, Len);
  end;
  // dopisanie zera gdyby nie by³o
  if (pch[-1] <> #0) and (MaxLen <> 0) then
  begin
    pch[0] := #0;
  end;

  if MaxLen = 0 then
    Result := stBufferToSmall;

  if Result = stEND_OFF_DIR then
    Result := stOK;

end;

function TDevItem.SeGetDrvList(SesId: TSesID; DrvList: PAnsiChar): TStatus;
var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrame;
begin
  setLength(q, 2 + sizeof(p^));
  q[0] := FDevNr;
  q[1] := crdGetDriveList;
  p := PSEAskFrame(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    System.AnsiStrings.StrPLCopy(DrvList, PAnsiChar(@QA[2]), 20);
  end;
end;

function TDevItem.SeShell(SesId: TSesID; Command: PAnsiChar; ResultStr: PAnsiChar; MaxLen: integer): TStatus;
var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameCmd;
  L: integer;
begin
  L := 2 + (2 + 4 + System.AnsiStrings.strlen(Command) + 1);
  setLength(q, L);

  q[0] := FDevNr;
  q[1] := crdShell;
  p := PSEAskFrameCmd(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  System.AnsiStrings.StrPLCopy(p^.Command, Command, sizeof(p^.Command));
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    if (MaxLen > 0) and Assigned(ResultStr) then
      System.AnsiStrings.StrPLCopy(ResultStr, PAnsiChar(@QA[2]), MaxLen);
  end;
end;

function TDevItem.SeReadFileEx(SesId: TSesID; FileName: PAnsiChar; autoclose: boolean; var Buf; var size: integer;
  var FileNr: TFileNr): TStatus;

var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameReadEx;
  L: integer;
  RecLen: integer;
begin
  L := 2 + (2 + 4 + 2 + System.AnsiStrings.strlen(FileName) + 1);
  setLength(q, L);

  q[0] := FDevNr;
  q[1] := crdReadEx;
  p := PSEAskFrameReadEx(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.autoclose := byte(autoclose);
  if size > MAX_MDB_FRAME_SIZE then
    size := MAX_MDB_FRAME_SIZE;
  p^.SizeToRead := size;
  System.AnsiStrings.StrPLCopy(p^.FName, FileName, sizeof(p^.FName));
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    RecLen := length(QA) - 6; // cztery bajty z przodu i CRC z ty³u
    if RecLen > size then
      RecLen := size;
    move(QA[4], Buf, RecLen);
    FileNr := QA[2];
    size := RecLen;
  end;
end;

function TDevItem.SeGetGuidEx(SesId: TSesID; FileName: PAnsiChar; var Guid: TSeGuid): TStatus;

var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameOpenFile;
  L: integer;
begin
  L := 2 + (2 + 4 + 2 + System.AnsiStrings.strlen(FileName) + 1);
  setLength(q, L);
  q[0] := FDevNr;
  q[1] := crdGetGuidEx;
  p := PSEAskFrameOpenFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.OpenMode := 0;
  p^.Free := 0;
  System.AnsiStrings.StrPLCopy(p^.FName, FileName, sizeof(p^.FName));
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    Guid.d1 := DSwap(pCardinal(@QA[2])^);
    Guid.d2 := DSwap(pCardinal(@QA[6])^);
  end;
end;

function TDevItem.SeReadFileHd(SesId: TSesID; FileNr: TFileNr; var Buf; var Cnt: integer): TStatus;

var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameFile;
  L: integer;
  RecLen: integer;
begin
  setLength(q, 2 + sizeof(p^));

  q[0] := FDevNr;
  q[1] := crdRead;
  p := PSEAskFrameFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  p^.BArg1 := 0;
  L := Cnt;
  if L > MAX_DATA_BUF_SIZE then
    L := MAX_DATA_BUF_SIZE;
  p^.Arg1 := DSwap(L);
  setLength(QA, 0);
  Result := Konwers(false, q, QA);
  if Result = stOK then
  begin
    RecLen := length(QA) - 4; // dwa bajty z przodu i CRC z ty³u
    if RecLen > Cnt then
      RecLen := Cnt;
    move(QA[2], Buf, RecLen);
    Cnt := RecLen;
  end;
end;

function TDevItem.SeReadFile(SesId: TSesID; FileNr: TFileNr; var Buf; var Cnt: integer): TStatus;
var
  Cnt1: integer;
  CntS: integer;
  p: pByte;
begin
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);
  p := pByte(@Buf);
  CntS := 0;
  repeat
    Cnt1 := Cnt - CntS;
    Result := SeReadFileHd(SesId, FileNr, p^, Cnt1);
    if Result = stOK then
    begin
      inc(CntS, Cnt1);
      inc(p, Cnt1);
    end;
    SetProgress(CntS, Cnt);
    MsgFlowSize(CntS);
  until (Result <> stOK) or (Cnt = CntS) or (Cnt1 = 0);
  Cnt := CntS;
  SetProgress(100);
  MsgFlowSize(Cnt);
  SetWorkFlag(false);
end;

function TDevItem.SeWriteFileHd(SesId: TSesID; FileNr: TFileNr; const Buf; var Cnt: integer): TStatus;
var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameWr;
  L: integer;
  HS: integer;
begin
  HS := sizeof(p^) - sizeof(BUF234);
  L := Cnt;
  if L > MAX_DATA_BUF_SIZE - HS then
    L := MAX_DATA_BUF_SIZE - HS;
  setLength(q, 2 + HS + L);
  q[0] := FDevNr;
  q[1] := crdWrite;
  p := PSEAskFrameWr(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  p^.Free := 0;
  move(Buf, q[2 + HS], L);
  setLength(QA, 0);
  Result := Konwers(false, q, QA);
  if (Result = stOK) and (length(QA) >= 8) then
  begin
    Cnt := GetLongInt(QA[2]);
  end
  else
    Cnt := 0;
end;

function TDevItem.SeWriteFile(SesId: TSesID; FileNr: TFileNr; const Buf; var Cnt: integer): TStatus;
var
  Cnt1: integer;
  CntS: integer;
  p: pByte;
begin
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);
  p := pByte(@Buf);
  CntS := 0;
  repeat
    Cnt1 := Cnt - CntS;
    Result := SeWriteFileHd(SesId, FileNr, p^, Cnt1);
    if Result = stOK then
    begin
      inc(p, Cnt1);
      inc(CntS, Cnt1);
    end;
    SetProgress(CntS, Cnt);
    MsgFlowSize(CntS);
  until (Result <> stOK) or (Cnt = CntS);
  Cnt := CntS;
  SetProgress(100);
  MsgFlowSize(Cnt);
  SetWorkFlag(false);
end;

function TDevItem.SeSeek(SesId: TSesID; FileNr: TFileNr; Offset: integer; Orgin: byte; var Pos: integer): TStatus;
var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameFile;
begin
  setLength(q, 2 + sizeof(p^));
  q[0] := FDevNr;
  q[1] := crdSeek;
  p := PSEAskFrameFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  p^.BArg1 := Orgin;
  p^.Arg1 := DSwap(cardinal(Offset));
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    Pos := GetLongInt(QA[2]);
  end;
end;

function TDevItem.SeGetFileSize(SesId: TSesID; FileNr: TFileNr; var FileSize: integer): TStatus;
var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameFile;
begin
  setLength(q, 2 + 2 + 4 + 1);
  q[0] := FDevNr;
  q[1] := crdGetFileSize;
  p := PSEAskFrameFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    FileSize := GetLongInt(QA[2]);
  end;
end;

function TDevItem.SeCloseFile(SesId: TSesID; FileNr: TFileNr): TStatus;
var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameFile;
begin
  setLength(q, 2 + 2 + 4 + 1);
  q[0] := FDevNr;
  q[1] := crdClose;
  p := PSEAskFrameFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  setLength(QA, 0);
  Result := Konwers(q, QA);
end;

function TDevItem.SeGetGuid(SesId: TSesID; FileNr: TFileNr; var Guid: TSeGuid): TStatus;
var
  q: TBytes;
  QA: TBytes;
  p: PSEAskFrameFile;
begin
  setLength(q, 2 + 2 + 4 + 1);
  q[0] := FDevNr;
  q[1] := crdGetGuid;
  p := PSEAskFrameFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  setLength(QA, 0);
  Result := Konwers(q, QA);
  if Result = stOK then
  begin
    Guid.d1 := DSwap(pCardinal(@QA[2])^);
    Guid.d2 := DSwap(pCardinal(@QA[6])^);
  end;
end;

// ---------------------  TDevAcces ---------------------------
constructor TDevList.Create;
begin
  inherited Create;
  FCurrId := TAccId(1);
  InitializeCriticalSection(FCriSection);
end;

destructor TDevList.Destroy;
begin
  DeleteCriticalSection(FCriSection);
  inherited;
end;

function TDevList.GetBoudRate(BdTxt: String; var Baund: TBaudRate): boolean;
begin
  Result := true;
  if BdTxt = '110' then
    Baund := br110
  else if BdTxt = '300' then
    Baund := br300
  else if BdTxt = '600' then
    Baund := br600
  else if BdTxt = '1200' then
    Baund := br1200
  else if BdTxt = '2400' then
    Baund := br2400
  else if BdTxt = '4800' then
    Baund := br4800
  else if BdTxt = '9600' then
    Baund := br9600
  else if BdTxt = '14400' then
    Baund := br14400
  else if BdTxt = '19200' then
    Baund := br19200
  else if BdTxt = '38400' then
    Baund := br38400
  else if BdTxt = '56000' then
    Baund := br56000
  else if BdTxt = '57600' then
    Baund := br57600
  else if BdTxt = '115200' then
    Baund := br115200
  else
    Result := false;
end;

function TDevList.GetMdbMode(BdTxt: String; var MdbMode: TMdbMode): boolean;
begin
  Result := true;
  if BdTxt = 'RTU' then
    MdbMode := mdbRTU
  else if BdTxt = 'ASCII' then
    MdbMode := mdbASCII
  else
    Result := false;
end;

function TDevList.GetParity(BdTxt: String; var Parity: TParity): boolean;
begin
  Result := true;
  if BdTxt = 'N' then
    Parity := paNONE
  else if BdTxt = 'E' then
    Parity := paEVEN
  else if BdTxt = 'O' then
    Parity := paODD
  else
    Result := false;
end;

function TDevList.GetBitCnt(Txt: String; var BitCnt: TBitCnt): boolean;
begin
  Result := true;
  if Txt = '8' then
    BitCnt := bit8
  else if Txt = '7' then
    BitCnt := bit7
  else if Txt = '6' then
    BitCnt := bit6
  else
    Result := false;
end;

function TDevList.GetMdbMemAccess(Txt: String; var MemAcc: TMdbMemAccess): boolean;
begin
  Result := true;
  if Txt = 'GEKA' then
    MemAcc := mdbmemGEKA
  else if Txt = 'DPC06' then
    MemAcc := mdbmemDPC06
  else
    Result := false;

end;

function TDevList.GetTocken(s: PAnsiChar; var p: integer): String;
begin
  Result := '';
  while (s[p] <> ';') and (s[p] <> #0) and (p <= length(s)) do
  begin
    Result := Result + Char(s[p]);
    inc(p);
  end;
  inc(p);
end;

function TDevList.GetId: TAccId;
begin
  Result := FCurrId;
  inc(FCurrId);
end;

// ConnectStr - JSON format

function TDevList.AddDevice(ConnectStr: PAnsiChar): TAccId;
  function GetJsonVal(jobj: TJSONObject; Name: string; var valStr: string): boolean;
  var
    jPair: TJSonPair;
  begin
    jPair := jobj.Get(Name);
    Result := Assigned(jPair);
    if Result then
      valStr := jPair.JsonValue.Value;
  end;

  function GetComNr(s: string; var ComNr: integer): boolean;
  begin
    Result := TryStrToInt(copy(s, 4, length(s) - 3), ComNr);
  end;

var
  OpenParams: TDevItem.TOpenParams;

  DevItem: TDevItem;
  jVal: TJSONValue;
  jobj: TJSONObject;
  jObj2: TJSONObject;
  tmpStr: string;
  q: boolean;
begin
  Result := -1;
  try
    jVal := TJSONObject.ParseJSONValue(String(ConnectStr));
    jobj := jVal as TJSONObject;
    OpenParams.InitDefault;

    q := false;
    if Assigned(jobj) then
    begin
      jObj2 := jobj.Get(CONNECTION_PARAMS_NAME).JsonValue as TJSONObject;
      if Assigned(jObj2) then
      begin
        if GetJsonVal(jObj2, UARTPARAM_COMNR, tmpStr) then
          q := GetComNr(tmpStr, OpenParams.ComNr);
        q := q and GetJsonVal(jObj2, UARTPARAM_BAUDRATE, tmpStr);
        if q then
          q := GetBoudRate(tmpStr, OpenParams.BaudRate);
        if GetJsonVal(jObj2, UARTPARAM_PARITY, tmpStr) then
          q := q and GetParity(tmpStr, OpenParams.Parity);
        if GetJsonVal(jObj2, UARTPARAM_BITCNT, tmpStr) then
          q := q and GetBitCnt(tmpStr, OpenParams.BitCnt);

        q := q and GetJsonVal(jObj2, MODBUS_DEVNR, tmpStr);
        if q then
          q := TryStrToInt(tmpStr, OpenParams.DevNr);

        if GetJsonVal(jObj2, MODBUS_MODE, tmpStr) then
          q := q and GetMdbMode(tmpStr, OpenParams.MdbMode);

        if GetJsonVal(jObj2, MODBUS_MEMACCESS, tmpStr) then
          q := q and GetMdbMemAccess(tmpStr, OpenParams.MdbMemAccess);

      end;

    end;

    if q then
    begin
      try
        EnterCriticalSection(FCriSection);
        DevItem := TDevItem.Create(GetId, OpenParams);
        Add(DevItem);
        Result := DevItem.AccId;
      finally
        LeaveCriticalSection(FCriSection);
      end;
    end
  except
    Result := -1;
  end;
end;

function TDevList.DelDevice(AccId: TAccId): TStatus;
var
  i: integer;
  t: TDevItem;
  ComNr: integer;
begin
  Result := stBadId;
  try
    EnterCriticalSection(FCriSection);
    for i := 0 to Count - 1 do
    begin
      t := Items[i] as TDevItem;
      if t.AccId = AccId then
      begin
        ComNr := t.ComNr;
        t.Close;
        Delete(i);
        Result := stOK;
        GlobDevList.UpdateCom(ComNr);
        break;
      end;
    end;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

function TDevList.FindId(AccId: TAccId): TDevItem;
var
  i: integer;
  t: TDevItem;
begin
  Result := nil;
  if AccId >= 0 then
  begin
    try
      EnterCriticalSection(FCriSection);
      for i := 0 to Count - 1 do
      begin
        t := Items[i] as TDevItem;
        if t.AccId = AccId then
        begin
          Result := t;
          break;
        end;
      end;
    finally
      LeaveCriticalSection(FCriSection);
    end;
  end;
end;

function TDevList.isAnyDevWithOpenCom(ComNr: integer): boolean;
var
  i: integer;
  dev: TDevItem;
begin
  Result := false;
  try
    EnterCriticalSection(FCriSection);
    for i := 0 to Count - 1 do
    begin
      dev := Items[i] as TDevItem;

      if (dev.ComNr = ComNr) and dev.isOpen then
      begin
        Result := true;
        break;
      end;
    end;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

procedure TDevList.UpdateCom(ComNr: integer);
begin
  if not GlobDevList.isAnyDevWithOpenCom(ComNr) then
  begin
    GlobComList.RemoveCom(ComNr);
  end;
end;

initialization

GlobDevList := TDevList.Create;

finalization

GlobDevList.Free;

end.
