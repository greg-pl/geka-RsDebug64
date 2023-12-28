unit ModbusObj;

interface

uses
  Windows, Messages, SysUtils, Classes, Math,
  System.AnsiStrings,
  System.Contnrs,
  ComUnit,
  LibUtils,
  Rsd64Definitions;

const
  MAX_MDB_FRAME_SIZE = 240;
  MAX_MDB_STD_FRAME_SIZE = 112;
  DRIVER_SHORT_NAME = 'MCOM';

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
  TParity = (paNONE, paEVEN, paODD);

  TDevItem = class(TObject)
  private
    CriSection: TRTLCriticalSection;
    AccId: integer;
    ComNr: integer;
    FDevNr: integer;
    BaudRate: TBaudRate;
    FMdbMode: TMdbMode;
    FParity: TParity;
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
    glProgress: boolean; // false -> progress wysy³a procedura Konwers
    DriverMode: TDriverMode;
    Rs485Wait: boolean;
    FClr_ToRdCnt: boolean; // odbiór ramki az do przerwy

    function GetNewAskNr: word;

    procedure FSetCountDivide(AValue: integer);
    procedure FSetMdbStdCndDiv(AValue: integer);
    function GetComAcces: boolean;
    procedure ReleaseComAcces;

    function RsWrite(var Buffer; Count: integer): integer;
    function RsRead(var Buffer; Count: integer): integer;
    procedure PurgeInOut;
    function Konwers(RepZad: integer; var Buf; Count: byte; var OutBuf; var RecLen: integer): TStatus; overload;
    function Konwers(var Buf; Count: byte; var OutBuf; var RecLen: integer): TStatus; overload;
    function Konwers(var Buf; Count: byte; var OutBuf): TStatus; overload;

    // function  ProceddCRC(CRC : word; Data : byte):word;
    function ProceddCRC_1(CRC: word; Data: byte): word;
    function CheckCRC(const p; Count: word): boolean;
    function MakeCRC(const p; Count: word): word;
    function ReciveRTUAnswer(var Buffer; ToReadCnt: integer; var RecLen: integer): boolean;
    function ReciveASCIIAnswer(var Buffer; ToReadCnt: integer; var RecLen: integer): boolean;
    function RdRegHd(var QA: TByteAr; Adress: word; Count: word): TStatus;
    function RdAbnalogInpHd(var QA: TByteAr; Adress: word; Count: word): TStatus;
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
    procedure LockComm;
    procedure UnlockComm;
  protected
    procedure GoBackFunct(Ev: integer; R: real);
    procedure SetProgress(F: real); overload;
    procedure SetProgress(Cnt, Max: integer); overload;
    procedure MsgFlowSize(R: real);
    procedure SetWorkFlag(w: boolean);

    function RsReadByte(var b: byte): boolean;
    function InQue: integer;
    function OutQue: integer;
    procedure RsWriteByte(b: byte);
    procedure RsWriteWord(b: word);
  public
    MaxTime: integer;
    constructor Create(AId: TAccId; AComNr: TComPort; ADevNr: integer; ABaudRate: TBaudRate; AMode: TMdbMode;
      AParity: TParity);
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
    function GetDrvStatus(ParamName: PAnsiChar; ParamValue: PAnsiChar; MaxRpl: integer): TStatus;
    function SetDrvParam(ParamName: PAnsiChar; ParamValue: PAnsiChar): TStatus;

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
    function RdDevInfo(DevName: pchar; var TabVec: cardinal): TStatus;
    function RdCtrlByte(Nr: byte; var Val: byte): TStatus;
    function WrCtrlByte(Nr: byte; Val: byte): TStatus;

    // obsluga terminala
    function TerminalSendKey(key: AnsiChar): TStatus;
    function TerminalSetPipe(TerminalNr: integer; PipeHandle: THandle): TStatus;
    function TerminalSetRunFlag(TerminalNr: integer; RunFlag: boolean): TStatus;
    function TerminalRead(Buf: PAnsiChar; var rdcnt: integer): TStatus;

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

// ---------------------  TDevItem ---------------------------
constructor TDevItem.Create(AId: TAccId; AComNr: TComPort; ADevNr: integer; ABaudRate: TBaudRate; AMode: TMdbMode;
  AParity: TParity);
begin
  inherited Create;
  AccId := AId;
  ComNr := AComNr;
  FDevNr := ADevNr;
  BaudRate := ABaudRate;
  FMdbMode := AMode;
  FParity := AParity;
  DriverMode := dmFAST; // ;
  Rs485Wait := false;
  FClr_ToRdCnt := false;

  LastFinished := GetTickCount;
  MaxTime := 5000;
  CountDivide := 128;
  MdbStdCndDiv := MAX_MDB_STD_FRAME_SIZE;
  InitializeCriticalSection(CriSection);
end;

destructor TDevItem.Destroy;
begin
  inherited Destroy;
  DeleteCriticalSection(CriSection);
end;

procedure TDevItem.LockComm;
begin
  EnterCriticalSection(CriSection);
end;

procedure TDevItem.UnlockComm;
begin
  LeaveCriticalSection(CriSection);
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
  FillChar(DCB, SizeOf(DCB), 0);
  DCB.DCBlength := SizeOf(DCB);
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
  case FMdbMode of
    mdbRTU:
      DCB.ByteSize := 8;
    mdbASCII:
      DCB.ByteSize := 7;
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
  Result := stOk;
end;

function TDevItem.Open: TStatus;
begin
  FrameRepCnt := 0;
  FrameCnt := 0;
  WaitCnt := 0;
  SumRecTime := 0;
  SumSendTime := 0;

  Result := stBadArguments;
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
  Result := (WaitForSingleObject(SemHandle, MaxTime) = WAIT_OBJECT_0);
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

function TDevItem.RsWrite(var Buffer; Count: integer): integer;
var
  Overlapped: TOverlapped;
  BytesWritten: cardinal;
  q: boolean;
  TT: cardinal;
begin
  TT := GetTickCount;
  FillChar(Overlapped, SizeOf(Overlapped), 0);
  Overlapped.hEvent := CreateEvent(nil, True, True, nil);
  WriteFile(ComHandle, Buffer, Count, BytesWritten, @Overlapped);

  WaitForSingleObject(Overlapped.hEvent, INFINITE);
  q := GetOverlappedResult(ComHandle, Overlapped, BytesWritten, false);
  CloseHandle(Overlapped.hEvent);
  Result := BytesWritten;
  if not(q) then
    Result := 0;
  TT := cardinal(GetTickCount - TT);
  inc(SumSendTime, TT);
end;

procedure TDevItem.RsWriteByte(b: byte);
begin
  RsWrite(b, 1);
end;

procedure TDevItem.RsWriteWord(b: word);
begin
  RsWrite(b, 2);
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
  FillChar(Overlapped, SizeOf(Overlapped), 0);
  Overlapped.hEvent := CreateEvent(nil, True, True, nil);
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

procedure TDevItem.GoBackFunct(Ev: integer; R: real);
begin
  if Assigned(FCallBackFunc) then
    FCallBackFunc(AccId, FCmmId, Ev, R);
end;

procedure TDevItem.SetProgress(F: real);
begin
  GoBackFunct(evProgress, F);
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
  GoBackFunct(evFlow, R);
end;

procedure TDevItem.SetWorkFlag(w: boolean);
begin
  if w then
    GoBackFunct(evWorkOnOff, 1)
  else
    GoBackFunct(evWorkOnOff, 0);
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
const
  CrcTab: array [0 .. 255] of word = ($0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241, $C601, $06C0, $0780,
    $C741, $0500, $C5C1, $C481, $0440, $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40, $0A00, $CAC1, $CB81,
    $0B40, $C901, $09C0, $0880, $C841, $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40, $1E00, $DEC1, $DF81,
    $1F40, $DD01, $1DC0, $1C80, $DC41, $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641, $D201, $12C0, $1380,
    $D341, $1100, $D1C1, $D081, $1040, $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240, $3600, $F6C1, $F781,
    $3740, $F501, $35C0, $3480, $F441, $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41, $FA01, $3AC0, $3B80,
    $FB41, $3900, $F9C1, $F881, $3840, $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41, $EE01, $2EC0, $2F80,
    $EF41, $2D00, $EDC1, $EC81, $2C40, $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640, $2200, $E2C1, $E381,
    $2340, $E101, $21C0, $2080, $E041, $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240, $6600, $A6C1, $A781,
    $6740, $A501, $65C0, $6480, $A441, $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41, $AA01, $6AC0, $6B80,
    $AB41, $6900, $A9C1, $A881, $6840, $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41, $BE01, $7EC0, $7F80,
    $BF41, $7D00, $BDC1, $BC81, $7C40, $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640, $7200, $B2C1, $B381,
    $7340, $B101, $71C0, $7080, $B041, $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241, $9601, $56C0, $5780,
    $9741, $5500, $95C1, $9481, $5440, $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40, $5A00, $9AC1, $9B81,
    $5B40, $9901, $59C0, $5880, $9841, $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40, $4E00, $8EC1, $8F81,
    $4F40, $8D01, $4DC0, $4C80, $8C41, $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641, $8201, $42C0, $4380,
    $8341, $4100, $81C1, $8081, $4040);

function TDevItem.ProceddCRC_1(CRC: word; Data: byte): word;
begin
  Result := CrcTab[(CRC xor Data) and $FF] xor (CRC shr 8);
end;

{
  function  TDevItem.ProceddCRC(CRC : word; Data : byte):word;
  const
  Gen_poly:word= $A001;
  var
  i    : byte;
  begin
  Crc:=Crc xor Data;
  for i:=1 to 8 do
  begin
  if Crc mod 2=1 then
  Crc:=((Crc div 2) xor Gen_Poly)
  else
  crc:=crc div 2;
  end;
  Result:= Crc;
  end;
}

function TDevItem.MakeCRC(const p; Count: word): word;
const
  Gen_poly: word = $A001;
var
  a: word;
  CRC: word;
  n: word;
begin
  CRC := $FFFF;
  for n := 0 to Count - 1 do
  begin
    a := TByteAr(p)[n];
    CRC := ProceddCRC_1(CRC, a);
  end;
  Result := CRC;
end;

function TDevItem.CheckCRC(const p; Count: word): boolean;
begin
  Result := (MakeCRC(p, Count) = 0);
end;

function TDevItem.ReciveRTUAnswer(var Buffer; ToReadCnt: integer; var RecLen: integer): boolean;
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
begin
  if FClr_ToRdCnt then
    ToReadCnt := 0;
  T2 := GetTickCount;
  if DriverMode = dmSTD then
  begin
    if (ToReadCnt = 0) or (ToReadCnt > SizeOf(TByteAr)) then
      RecLen := RsRead(Buffer, SizeOf(TByteAr))
    else
    begin
      RecLen := RsRead(Buffer, ToReadCnt);
    end;
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
      L := RsRead(q[RecLen], SizeOf(q) - RecLen);
      inc(RecLen, L);
      if (DriverMode = dmSLOW) and (L = 0) then
        Sleep(dT);
      if GetTickCount - TT > TIME_TO_RPL then
      begin
        break;
      end;
    end;

    TT := GetTickCount;
    TimeFlag := false;
    while True do
    begin
      if RecLen = SizeOf(q) then
        break;
      try
        L := RsRead(q[RecLen], SizeOf(q) - RecLen);
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
          Sleep(dT);
        end;
        TimeFlag := True;
      end;
      if (DriverMode = dmSLOW) and (L = 0) then
        Sleep(dT);
    end;
    T2 := GetTickCount - T2;
    inc(SumRecTime, T2);
    move(q, Buffer, RecLen);
  end;

  if (ToReadCnt = 0) or (ToReadCnt = RecLen) then
  begin
    if RecLen > 0 then
      Result := CheckCRC(Buffer, RecLen)
    else
      Result := false;
  end
  else
    Result := false;
end;

function TDevItem.ReciveASCIIAnswer(var Buffer; ToReadCnt: integer; var RecLen: integer): boolean;
  function HexVal(ch: char): byte;
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
  RecBuf: array of char;
  n: integer;
  Len: cardinal;
  i: integer;
  a: byte;
  sum: byte;
begin
  Result := false;
  n := SizeOf(TByteAr) * 2 + 3;
  SetLength(RecBuf, n);
  Len := RsRead(RecBuf[0], n);
  if (Len > 3) and (RecBuf[0] = ':') and (RecBuf[Len - 1] = #10) and (RecBuf[Len - 2] = #13) then
  begin
    n := (Len - 3) div 2;
    sum := 0;
    for i := 0 to n - 1 do
    begin
      a := 16 * HexVal(RecBuf[2 * i + 1]) + HexVal(RecBuf[2 * i + 2]);
      TByteAr(Buffer)[i] := a;
      sum := byte(sum + a);
    end;
    if sum = 0 then
      Result := True;
    RecLen := n;
  end
  else
    RecLen := 0;
  SetLength(RecBuf, 0);
end;

function TDevItem.Konwers(var Buf; Count: byte; var OutBuf; var RecLen: integer): TStatus;
begin
  Result := Konwers(5, Buf, Count, OutBuf, RecLen);
end;

function TDevItem.Konwers(RepZad: integer; var Buf; Count: byte; var OutBuf; var RecLen: integer): TStatus;

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

  procedure BildAsciiBuf(var BufToSnd; const b; Count: integer);
    procedure PlaceChar(var p: pchar; b: char);
    begin
      p^ := b;
      inc(p);
    end;
    procedure PlaceByte(var p: pchar; b: byte);
    const
      HexCyfr: array [0 .. 15] of char = '0123456789ABCDEF';
    begin
      PlaceChar(p, HexCyfr[(b shr 4) and $0F]);
      PlaceChar(p, HexCyfr[b and $0F])
    end;

  var
    p: pchar;
    i: integer;
    a: byte;
    sum: byte;
  begin
    p := pchar(@BufToSnd);
    PlaceChar(p, ':');
    sum := 0;
    for i := 0 to Count - 1 do
    begin
      a := ord(pchar(@b)[i]);
      sum := byte(sum + a);
      PlaceByte(p, a);
    end;
    sum := $100 - sum;
    PlaceByte(p, sum);
    PlaceChar(p, #$0D);
    PlaceChar(p, #$0A);
  end;

var
  w: word;
  Rep: byte;
  q: boolean;
  MyBuf: array of byte;
  CntToSnd: integer;
  Cmd: byte;
  CmdRep: byte;
  ToReadCnt: integer;
begin
  ToReadCnt := RecLen;
  if not(ValidHandle) then
  begin
    ErrStr := 'Nie otwarty port.';
    Result := stNotOpen;
    Exit;
  end;
  if GetComAcces then
  begin
    if not(glProgress) then
    begin
      SetProgress(0);
      MsgFlowSize(0);
      SetWorkFlag(True);
    end;

    case FMdbMode of
      mdbRTU:
        begin
          CntToSnd := Count + 2;
          SetLength(MyBuf, CntToSnd);
          move(Buf, MyBuf[0], Count);
          w := MakeCRC(MyBuf[0], Count);
          MyBuf[Count] := lo(w);
          MyBuf[Count + 1] := hi(w);
        end;
      mdbASCII:
        begin
          CntToSnd := 1 + 2 * (Count + 1) + 2;
          SetLength(MyBuf, CntToSnd);
          BildAsciiBuf(MyBuf[0], Buf, Count);
        end;
    else
      CntToSnd := 0;
    end;

    if TByteAr(Buf)[0] <> 0 then
    begin
      Rep := RepZad;
      repeat
        q := True;
        CmdRep := 0;
        if not(FBreakFlag) then
        begin
          PurgeInOut;
          inc(FrameCnt);
          if Rs485Wait then
          begin
            while GetTickCount - LastFinished < 2 do
            begin
              Sleep(1);
              inc(WaitCnt);
            end;
          end;
          RsWrite(MyBuf[0], CntToSnd);

          case FMdbMode of
            mdbRTU:
              q := ReciveRTUAnswer(OutBuf, ToReadCnt, RecLen);
            mdbASCII:
              q := ReciveASCIIAnswer(OutBuf, ToReadCnt, RecLen);
          else
            q := false;
          end;

          Cmd := TByteAr(Buf)[1];
          CmdRep := TByteAr(OutBuf)[1];
          if (TByteAr(OutBuf)[0] <> FDevNr) or (Cmd <> (CmdRep and $7F)) then
          begin
            q := false; // odebrano nie t¹ ramkê
          end;

          if not(q) then
          begin
            inc(FrameRepCnt);
            dec(Rep);
            if (Rep <> 0) then
            begin
              Sleep(10)
            end;
          end;
          LastFinished := GetTickCount;
        end;
      until (Rep = 0) or q or FBreakFlag;

      Result := stOk;
      if FBreakFlag then
      begin
        Result := stUserBreak;
      end
      else if Rep = 0 then
      begin
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
          if TByteAr(OutBuf)[2] <> 4 then
            Result := stMdbError + TByteAr(OutBuf)[2]
          else
            Result := stMdbExError + TByteAr(OutBuf)[3]
        end;
      end;
      if not(glProgress) then
      begin
        SetProgress(100);
        SetWorkFlag(false);
      end;
    end
    else
    begin // Brodcast
      PurgeInOut;
      RsWrite(Buf, Count + 2);
      Result := stOk;
    end;
    SetLength(MyBuf, 0);
    ReleaseComAcces;
  end
  else
    Result := stNoSemafor;
end;

function TDevItem.Konwers(var Buf; Count: byte; var OutBuf): TStatus;
var
  RecLen: integer;
begin
  RecLen := 0;
  Result := Konwers(Buf, Count, OutBuf, RecLen);
end;

procedure TDevItem.BreakPulse;
begin
  if ValidHandle then
  begin
    if GetComAcces then
    begin
      SetCommBreak(ComHandle);
      Sleep(10);
      ClearCommBreak(ComHandle);
      ReleaseComAcces;
    end;
  end;
end;

function TDevItem.SetBreakFlag(Val: boolean): TStatus;
begin
  FBreakFlag := Val;
  Result := stOk;
end;

function TDevItem.GetDrvStatus(ParamName: PAnsiChar; ParamValue: PAnsiChar; MaxRpl: integer): TStatus;
var
  s: String;
begin
  s := '';
  if ParamName = 'REPEAT_CNT' then
    s := IntToStr(FrameRepCnt)
  else if ParamName = 'FRAME_CNT' then
    s := IntToStr(FrameCnt)
  else if ParamName = 'WAIT_CNT' then
    s := IntToStr(WaitCnt)
  else if ParamName = 'RECIVE_TIME' then
    s := IntToStr(SumRecTime)
  else if ParamName = 'SEND_TIME' then
    s := IntToStr(SumSendTime)
  else if ParamName = 'DIVIDE_LEN' then
    s := IntToStr(CountDivide)
  else if ParamName = 'DRIVER_MODE' then
    s := IntToStr(ord(DriverMode))
  else if ParamName = 'RS485_WAIT' then
    s := IntToStr(byte(Rs485Wait))
  else if ParamName = 'CLR_RDCNT' then
    s := IntToStr(byte(FClr_ToRdCnt));

  if s <> '' then
  begin
    System.AnsiStrings.StrPLCopy(ParamValue, AnsiString(s), MaxRpl);
    Result := stOk;
  end
  else
    Result := stBadArguments;
end;

function TDevItem.SetDrvParam(ParamName: PAnsiChar; ParamValue: PAnsiChar): TStatus;
var
  n: integer;
begin
  Result := stOk;
  if ParamName = 'DIVIDE_LEN' then
  begin
    CountDivide := StrToIntDef(pchar(ParamValue), MAX_MDB_FRAME_SIZE);
  end
  else if ParamName = 'DRIVER_MODE' then
  begin
    n := StrToIntDef(pchar(ParamValue), ord(dmSTD));
    if (n >= ord(low(TDriverMode))) and (n <= ord(high(TDriverMode))) then
    begin
      DriverMode := TDriverMode(n);
      SetupState;
    end;
  end
  else if ParamName = 'RS485_WAIT' then
  begin
    n := StrToIntDef(pchar(ParamValue), 1);
    Rs485Wait := (n <> 0);
  end
  else if ParamName = 'CLR_RDCNT' then
  begin
    n := StrToIntDef(pchar(ParamValue), 1);
    FClr_ToRdCnt := (n <> 0);
  end
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
  q: TByteAr;
  QA: TByteAr;
  i: word;
  b, mask: byte;
begin
  q[0] := FDevNr;
  q[1] := $01;
  SetSmallInt(q[2], Smallint(Adress));
  SetSmallInt(q[4], Smallint(Count));
  Result := Konwers(q, 6, QA);
  if Result = stOk then
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
  q: TByteAr;
  QA: TByteAr;
  i: word;
  b, mask: byte;
begin
  q[0] := FDevNr;
  q[1] := $02;
  SetSmallInt(q[2], Smallint(Adress));
  SetSmallInt(q[4], Smallint(Count));
  Result := Konwers(q, 6, QA);
  if Result = stOk then
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

function TDevItem.RdRegHd(var QA: TByteAr; Adress: word; Count: word): TStatus;
var
  q: TByteAr;
begin
  if Adress > 0 then
  begin
    dec(Adress);
    q[0] := FDevNr;
    q[1] := $03;
    SetSmallInt(q[2], Smallint(Adress));
    SetSmallInt(q[4], Smallint(Count));
    Result := Konwers(q, 6, QA);
    if Result = stOk then
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
  QA: TByteAr;
  i: word;
  w: word;
  st: TStatus;
  n: integer;
  SCnt: integer;
  Count1: integer;
begin
  glProgress := True;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(True);

  n := 0;
  st := stOk;
  Count1 := Count;
  SCnt := 0;
  while (Count <> 0) and (st = stOk) do
  begin
    Cnt := Count;
    if Cnt > FMdbStdCndDiv then
      Cnt := FMdbStdCndDiv;
    st := RdRegHd(QA, Adress, Cnt);
    if st = stOk then
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
  glProgress := false;
  Result := st;
end;

function TDevItem.RdAbnalogInpHd(var QA: TByteAr; Adress: word; Count: word): TStatus;
var
  q: TByteAr;
  RecLen: integer;
begin
  if Adress > 0 then
  begin
    dec(Adress);
    q[0] := FDevNr;
    q[1] := $04;
    SetSmallInt(q[2], Smallint(Adress));
    SetSmallInt(q[4], Smallint(Count));
    RecLen := 0;
    Result := Konwers(q, 6, QA, RecLen);
    if Result = stOk then
    begin
      if not((QA[0] = FDevNr) and (QA[1] = $04) and (QA[2] = Count * 2) and (RecLen = 3 + 2 * Count + 2)) then
        Result := stBadRepl;
    end;
  end
  else
    Result := stBadArguments;
end;

function TDevItem.RdAnalogInp(var Buf; Adress: word; Count: word): TStatus;
var
  Cnt: word;
  QA: TByteAr;
  i: word;
  w: word;
  st: TStatus;
  n: integer;
  SCnt: integer;
  Count1: integer;
begin
  try
    glProgress := True;
    SetProgress(0);
    MsgFlowSize(0);
    SetWorkFlag(True);

    n := 0;
    st := stOk;
    Count1 := Count;
    SCnt := 0;
    while (Count <> 0) and (st = stOk) do
    begin
      Cnt := Count;
      if Cnt > FMdbStdCndDiv then
        Cnt := FMdbStdCndDiv;
      st := RdAbnalogInpHd(QA, Adress, Cnt);
      if st = stOk then
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
  q: TByteAr;
  QA: TByteAr;
  i: byte;
  RecLen: integer;
begin
  dec(Adress);
  q[0] := FDevNr;
  q[1] := $05;
  SetSmallInt(q[2], Smallint(Adress));
  if Val then
    q[4] := $FF
  else
    q[4] := $00;
  q[5] := $00;
  RecLen := 8;
  Result := Konwers(q, 6, QA, RecLen);
  if Result = stOk then
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
  q: TByteAr;
  QA: TByteAr;
  i: integer;
begin
  dec(Adress);
  q[0] := FDevNr;
  q[1] := $06;
  SetSmallInt(q[2], Smallint(Adress));
  SetSmallInt(q[4], Smallint(Val));
  Result := Konwers(q, 6, QA);
  if Result = stOk then
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
  q: TByteAr;
  QA: TByteAr;
begin
  q[0] := FDevNr;
  q[1] := $07;
  Result := Konwers(q, 2, QA);
  if Result = stOk then
    if not((QA[0] = FDevNr) and (QA[1] = 7)) then
      Result := stBadRepl;
  if Result = stOk then
    Val := QA[2];
end;

function TDevItem.WrMultiRegHd(Adress: word; Count: word; pW: pWord): TStatus;
var
  q: TByteAr;
  QA: TByteAr;
  w: word;
  i: integer;
  rCnt: word;
  rAdr: word;
begin
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
  Result := Konwers(q, 7 + 2 * Count, QA);
  if Result = stOk then
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
  glProgress := True;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(True);

  st := stOk;
  pW := pWord(@Buf);
  SCnt := 0;
  while (Count <> 0) and (st = stOk) do
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
  glProgress := false;

  Result := st;
end;

{$Q-}

function TDevItem.RdMemory(var Buf; Adress: cardinal; Count: cardinal): TStatus;

  function RdMemoryHd(FDevNr: byte; Adress: cardinal; Count: byte; var QA: TByteAr): TStatus;
  var
    q: TByteAr;
    RecLen: integer;
  begin
    q[0] := FDevNr;
    q[1] := 41;
    q[2] := Count;
    q[3] := 0;
    SetLongInt(q[4], Adress);
    RecLen := Count + 10;
    Result := Konwers(q, 8, QA, RecLen);
    if Result = stOk then
      if not((QA[0] = FDevNr) and (QA[1] = 41)) then
        Result := stBadRepl;
  end;

var
  Cnt: integer;
  QA: TByteAr;
  i: word;
  st: TStatus;
  p: pByte;
  SCnt: cardinal;
begin
  glProgress := True;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(True);

  st := stOk;
  p := pByte(@Buf);
  SCnt := 0;
  while (SCnt <> Count) and (st = stOk) do
  begin
    Cnt := Count - SCnt;
    if Cnt > FCountDivide then
      Cnt := FCountDivide;
    st := RdMemoryHd(FDevNr, Adress, Cnt, QA);
    if st = stOk then
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
    SetWorkFlag(True);
  end;
  Result := st;
  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
  glProgress := false;
end;
{$Q+}
{$Q-}

function TDevItem.WrMemory(const Buf; Adress: cardinal; Count: cardinal): TStatus;

  function WrMemoryHd(FDevNr: byte; Adress: cardinal; Count: byte; p: pByte): TStatus;
  var
    q: TByteAr;
    QA: TByteAr;
    RecLen: integer;
  begin
    q[0] := FDevNr;
    q[1] := 42;
    q[2] := Count;
    q[3] := 0;
    SetLongInt(q[4], Adress);
    move(p^, q[8], Count);
    RecLen := 10;
    Result := Konwers(q, 8 + Count, QA, RecLen);
    if Result = stOk then
      if not((QA[0] = FDevNr) and (QA[1] = 42)) then
        Result := stBadRepl;
  end;

var
  Cnt: integer;
  st: TStatus;
  p: pByte;
  SCnt: cardinal;
begin
  glProgress := True;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(True);

  st := stOk;
  p := pByte(@Buf);
  SCnt := 0;
  while (Count <> SCnt) and (st = stOk) do
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
  glProgress := false;
end;
{$Q+}

function TDevItem.RdDevInfo(DevName: pchar; var TabVec: cardinal): TStatus;
var
  q: TByteAr;
  QA: TByteAr;
  i: integer;
  RecLen: integer;
begin
  q[0] := FDevNr;
  q[1] := 40;
  RecLen := 16;
  Result := Konwers(q, 2, QA, RecLen);
  if Result = stOk then
    if not((QA[0] = FDevNr) and (QA[1] = 40)) then
      Result := stBadRepl;
  if Result = stOk then
  begin
    for i := 0 to 7 do
    begin
      DevName^ := chr(QA[i + 2]);
      inc(DevName);
    end;
    DevName^ := #0;
    TabVec := QA[10] shl 24;
    TabVec := TabVec or (QA[11] shl 16);
    TabVec := TabVec or (QA[12] shl 8);
    TabVec := TabVec or QA[13];
  end;
end;

function TDevItem.RdCtrlByte(Nr: byte; var Val: byte): TStatus;
var
  q: TByteAr;
  QA: TByteAr;
begin
  q[0] := FDevNr;
  q[1] := 43;
  q[2] := Nr;
  Result := Konwers(q, 3, QA);
  Val := QA[3];
end;

function TDevItem.WrCtrlByte(Nr: byte; Val: byte): TStatus;
var
  q: TByteAr;
  QA: TByteAr;
  RecLen: integer;
begin
  q[0] := FDevNr;
  q[1] := 44;
  q[2] := Nr;
  q[3] := Val;
  RecLen := 5;
  Result := Konwers(q, 4, QA, RecLen);
end;

function TDevItem.TerminalSendKey(key: AnsiChar): TStatus;
var
  q: TByteAr;
  QA: TByteAr;
  RecLen: integer;
begin
  q[0] := FDevNr;
  q[1] := 45;
  q[2] := ord(key);
  RecLen := 4;
  Result := Konwers(q, 3, QA, RecLen);
end;

function TDevItem.TerminalRead(Buf: PAnsiChar; var rdcnt: integer): TStatus;
var
  q: TByteAr;
  QA: TByteAr;
  RecLen: integer;
begin
  q[0] := FDevNr;
  q[1] := 46;
  RecLen := 0;

  Result := Konwers(1, q, 2, QA, RecLen);
  if Result = stBadRepl then
  begin
    q[0] := FDevNr;
    q[1] := 47;
    RecLen := 0;
    Result := Konwers(q, 2, QA, RecLen);
  end;

  if Result = stOk then
  begin
    rdcnt := RecLen - 4;
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

end;

function TDevItem.TerminalSetRunFlag(TerminalNr: integer; RunFlag: boolean): TStatus;
begin

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

function TDevItem.GetNewAskNr: word;
begin
  inc(FAskNumber);
  Result := FAskNumber;
end;

function TDevItem.GetErrStr(Code: TStatus; Buffer: PAnsiChar; MaxLen: integer): boolean;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameError;
  st: TStatus;
begin
  q[0] := FDevNr;
  q[1] := crdGetErrorStr;
  p := PSEAskFrameError(@q[2]);
  p^.ErrCode := swap(Code);
  st := Konwers(q, 2 + SizeOf(p^), QA);
  if st = stOk then
  begin
    System.AnsiStrings.StrPLCopy(Buffer, PAnsiChar(@QA[2]), MaxLen);
  end;
  Result := (st = stOk);
end;

function TDevItem.SeOpenSesion(var SesId: TSesID): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrame;
begin
  q[0] := FDevNr;
  q[1] := crdOpenSesion;
  p := PSEAskFrame(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  Result := Konwers(q, 2 + 2, QA);
  if Result = stOk then
    SesId := GetDWord(QA[2]);
end;

function TDevItem.SeCloseSesion(SesId: TSesID): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrame;
begin
  q[0] := FDevNr;
  q[1] := crdCloseSesion;
  p := PSEAskFrame(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  Result := Konwers(q, 2 + SizeOf(p^), QA);
end;

function TDevItem.SeOpenFile(SesId: TSesID; FName: PAnsiChar; Mode: byte; var FileNr: TFileNr): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameOpenFile;
  L: integer;
begin
  q[0] := FDevNr;
  q[1] := crdOpenFile;
  p := PSEAskFrameOpenFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.OpenMode := Mode;
  System.AnsiStrings.StrPLCopy(p^.FName, FName, SizeOf(p^.FName));
  L := 2 + 4 + 2 + System.AnsiStrings.strlen(FName) + 1;
  Result := Konwers(q, 2 + L, QA);
  FileNr := QA[2];
end;

function TDevItem.SeGetDirHd(First: boolean; SesId: TSesID; FName: PAnsiChar; Attrib: byte; Buffer: PAnsiChar;
  MaxLen: integer; var Len: integer): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameDir;
  RecLen: integer;
  L: integer;
begin
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
    System.AnsiStrings.StrPLCopy(p^.Name, FName, SizeOf(p^.Name));
    L := 2 + 4 + 4 + System.AnsiStrings.strlen(FName) + 1;
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
    L := 2 + 4 + 1;
  end;
  RecLen := 0;
  Result := Konwers(q, 2 + L, QA, RecLen);
  if Result = stOk then
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
  Result := SeGetDirHd(True, SesId, FName, Attrib, pch, MaxLen, Len);
  while (Result = stOk) and (Len <> 0) and (MaxLen <> 0) do
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
    Result := stOk;

end;

function TDevItem.SeGetDrvList(SesId: TSesID; DrvList: PAnsiChar): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrame;
begin
  q[0] := FDevNr;
  q[1] := crdGetDriveList;
  p := PSEAskFrame(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  Result := Konwers(q, 2 + SizeOf(p^), QA);
  if Result = stOk then
  begin
    System.AnsiStrings.StrPLCopy(DrvList, PAnsiChar(@QA[2]), 20);
  end;
end;

function TDevItem.SeShell(SesId: TSesID; Command: PAnsiChar; ResultStr: PAnsiChar; MaxLen: integer): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameCmd;
  L: integer;
begin
  q[0] := FDevNr;
  q[1] := crdShell;
  p := PSEAskFrameCmd(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  System.AnsiStrings.StrPLCopy(p^.Command, Command, SizeOf(p^.Command));
  L := 2 + 4 + System.AnsiStrings.strlen(Command) + 1;
  Result := Konwers(q, 2 + L, QA);
  if Result = stOk then
  begin
    if (MaxLen > 0) and Assigned(ResultStr) then
      System.AnsiStrings.StrPLCopy(ResultStr, PAnsiChar(@QA[2]), MaxLen);
  end;
end;

function TDevItem.SeReadFileEx(SesId: TSesID; FileName: PAnsiChar; autoclose: boolean; var Buf; var size: integer;
  var FileNr: TFileNr): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameReadEx;
  L: integer;
  RecLen: integer;
begin
  q[0] := FDevNr;
  q[1] := crdReadEx;
  p := PSEAskFrameReadEx(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.autoclose := byte(autoclose);
  if size > MAX_MDB_FRAME_SIZE then
    size := MAX_MDB_FRAME_SIZE;
  p^.SizeToRead := size;
  System.AnsiStrings.StrPLCopy(p^.FName, FileName, SizeOf(p^.FName));
  L := 2 + 4 + 2 + System.AnsiStrings.strlen(FileName) + 1;
  RecLen := 0;
  Result := Konwers(q, 2 + L, QA, RecLen);
  if Result = stOk then
  begin
    RecLen := RecLen - 6; // cztery bajty z przodu i CRC z ty³u
    if RecLen > size then
      RecLen := size;
    move(QA[4], Buf, RecLen);
    FileNr := QA[2];
    size := RecLen;
  end;
end;

function TDevItem.SeGetGuidEx(SesId: TSesID; FileName: PAnsiChar; var Guid: TSeGuid): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameOpenFile;
  L: integer;
begin
  q[0] := FDevNr;
  q[1] := crdGetGuidEx;
  p := PSEAskFrameOpenFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.OpenMode := 0;
  p^.Free := 0;
  System.AnsiStrings.StrPLCopy(p^.FName, FileName, SizeOf(p^.FName));
  L := 2 + 4 + 2 + System.AnsiStrings.strlen(FileName) + 1;
  Result := Konwers(q, 2 + L, QA);
  Guid.d1 := DSwap(pCardinal(@QA[2])^);
  Guid.d2 := DSwap(pCardinal(@QA[6])^);
end;

function TDevItem.SeReadFileHd(SesId: TSesID; FileNr: TFileNr; var Buf; var Cnt: integer): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameFile;
  L: integer;
  RecLen: integer;
begin
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
  RecLen := 0;
  Result := Konwers(q, 2 + SizeOf(p^), QA, RecLen);
  if Result = stOk then
  begin
    dec(RecLen, 4); // dwa bajty z przodu i CRC z ty³u
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
  glProgress := True;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(True);
  p := pByte(@Buf);
  CntS := 0;
  repeat
    Cnt1 := Cnt - CntS;
    Result := SeReadFileHd(SesId, FileNr, p^, Cnt1);
    if Result = stOk then
    begin
      inc(CntS, Cnt1);
      inc(p, Cnt1);
    end;
    SetProgress(CntS, Cnt);
    MsgFlowSize(CntS);
  until (Result <> stOk) or (Cnt = CntS) or (Cnt1 = 0);
  Cnt := CntS;
  SetProgress(100);
  MsgFlowSize(Cnt);
  SetWorkFlag(false);
  glProgress := false;
end;

function TDevItem.SeWriteFileHd(SesId: TSesID; FileNr: TFileNr; const Buf; var Cnt: integer): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameWr;
  L: integer;
  RecLen: integer;
  HS: integer;
begin
  q[0] := FDevNr;
  q[1] := crdWrite;
  p := PSEAskFrameWr(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  p^.Free := 0;
  HS := SizeOf(p^) - SizeOf(BUF234);
  L := Cnt;
  if L > MAX_DATA_BUF_SIZE - HS then
    L := MAX_DATA_BUF_SIZE - HS;
  move(Buf, q[2 + HS], L);
  RecLen := 0;
  Result := Konwers(q, 2 + HS + L, QA, RecLen);
  if (Result = stOk) and (RecLen >= 8) then
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
  glProgress := True;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(True);
  p := pByte(@Buf);
  CntS := 0;
  repeat
    Cnt1 := Cnt - CntS;
    Result := SeWriteFileHd(SesId, FileNr, p^, Cnt1);
    if Result = stOk then
    begin
      inc(p, Cnt1);
      inc(CntS, Cnt1);
    end;
    SetProgress(CntS, Cnt);
    MsgFlowSize(CntS);
  until (Result <> stOk) or (Cnt = CntS);
  Cnt := CntS;
  SetProgress(100);
  MsgFlowSize(Cnt);
  SetWorkFlag(false);
  glProgress := false;
end;

function TDevItem.SeSeek(SesId: TSesID; FileNr: TFileNr; Offset: integer; Orgin: byte; var Pos: integer): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameFile;
begin
  q[0] := FDevNr;
  q[1] := crdSeek;
  p := PSEAskFrameFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  p^.BArg1 := Orgin;
  p^.Arg1 := DSwap(cardinal(Offset));
  Result := Konwers(q, 2 + SizeOf(p^), QA);
  if Result = stOk then
  begin
    Pos := GetLongInt(QA[2]);
  end;
end;

function TDevItem.SeGetFileSize(SesId: TSesID; FileNr: TFileNr; var FileSize: integer): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameFile;
begin
  q[0] := FDevNr;
  q[1] := crdGetFileSize;
  p := PSEAskFrameFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  Result := Konwers(q, 2 + 2 + 4 + 1, QA);
  if Result = stOk then
  begin
    FileSize := GetLongInt(QA[2]);
  end;
end;

function TDevItem.SeCloseFile(SesId: TSesID; FileNr: TFileNr): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameFile;
begin
  q[0] := FDevNr;
  q[1] := crdClose;
  p := PSEAskFrameFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  Result := Konwers(q, 2 + 2 + 4 + 1, QA);
end;

function TDevItem.SeGetGuid(SesId: TSesID; FileNr: TFileNr; var Guid: TSeGuid): TStatus;

var
  q: TByteAr;
  QA: TByteAr;
  p: PSEAskFrameFile;
begin
  q[0] := FDevNr;
  q[1] := crdGetGuid;
  p := PSEAskFrameFile(@q[2]);
  p^.AskCnt := swap(GetNewAskNr);
  p^.SesionID := DSwap(SesId);
  p^.FileNr := FileNr;
  Result := Konwers(q, 2 + 2 + 4 + 1, QA);
  Guid.d1 := DSwap(pCardinal(@QA[2])^);
  Guid.d2 := DSwap(pCardinal(@QA[6])^);
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
  Result := True;
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
  Result := True;
  if BdTxt = 'RTU' then
    MdbMode := mdbRTU
  else if BdTxt = 'ASCII' then
    MdbMode := mdbASCII
  else
    Result := false;
end;

function TDevList.GetParity(BdTxt: String; var Parity: TParity): boolean;
begin
  Result := True;
  if BdTxt = 'N' then
    Parity := paNONE
  else if BdTxt = 'E' then
    Parity := paEVEN
  else if BdTxt = 'O' then
    Parity := paODD
  else
    Result := false;
end;

function TDevList.GetTocken(s: PAnsiChar; var p: integer): String;
begin
  Result := '';
  while (s[p] <> ';') and (s[p] <> #0) and (p <= length(s)) do
  begin
    Result := Result + char(s[p]);
    inc(p);
  end;
  inc(p);
end;

function TDevList.GetId: TAccId;
begin
  Result := FCurrId;
  inc(FCurrId);
end;

// MCOM;nr_rs;nr_dev;rs_speed;[ASCII|RTU];[N|E|O]
// MCOM;1;7;115200;RTU;N

function TDevList.AddDevice(ConnectStr: PAnsiChar): TAccId;
var
  ComNr: TComPort;
  DevNr: integer;
  BaudRate: TBaudRate;
  OkStr: boolean;
  DevItem: TDevItem;
  MdbMode: TMdbMode;
  Parity: TParity;
  SL: TStringList;
begin
  OkStr := false;
  SL := TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.DelimitedText := String(ConnectStr);
    if SL.Count >= 3 then
    begin
      if SL.Strings[0] = DRIVER_SHORT_NAME then
      begin
        OkStr := True;
        MdbMode := mdbRTU;
        Parity := paNONE;
        BaudRate := br115200;
        try
          ComNr := TComPort(StrToInt(SL.Strings[1]));
          DevNr := StrToInt(SL.Strings[2]);
          if SL.Count > 3 then
          begin
            OkStr := GetBoudRate(SL.Strings[3], BaudRate);
          end;
          if SL.Count > 4 then
          begin
            OkStr := OkStr and GetMdbMode(SL.Strings[4], MdbMode);
          end;
          if SL.Count > 5 then
          begin
            OkStr := OkStr and GetParity(SL.Strings[5], Parity);
          end;
        except
          OkStr := false;
        end;
      end;

    end;
  finally
    SL.Free;
  end;

  Result := -1;
  if OkStr then
  begin
    try
      EnterCriticalSection(FCriSection);
      DevItem := TDevItem.Create(GetId, ComNr, DevNr, BaudRate, MdbMode, Parity);
      Add(DevItem);
      Result := DevItem.AccId;
    finally
      LeaveCriticalSection(FCriSection);
    end;
  end
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
        Result := stOk;
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
        Result := True;
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
