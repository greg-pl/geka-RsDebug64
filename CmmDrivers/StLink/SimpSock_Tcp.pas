unit SimpSock_Tcp;

interface

uses
  Classes, Windows, Messages, Types, SysUtils, Contnrs,
  WinSock2,
  Rsd64Definitions;

const
  wm_SocketEvent = wm_user + 100;
  wm_CloseClient = wm_user + 101;

  wm_UserMin = wm_user + 1000;
  wm_SvrConnect = wm_UserMin + 1;
  wm_SvrDisconnect = wm_UserMin + 2;

  wm_UserMax = wm_user + 1200;

{
const
  stOk = 0;
  stTimeOut = 1;
  stErrorRecived = 2;
  stReplyFormatError = 3;
  stReplySumError = 4;
  stNotOpen = 12;
  stUserBreak = 15;
  stError = -1;
}
type
  TRdEvent = procedure(Sender: TObject; RecBuf: string; RecIp: string; RecPort: word) of object;
  TMsgFlow = procedure(Sender: TObject; R: real) of object;

  TSockCheckMthd = function(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer of object;

  TWSAEvent = (wsaREAD, wsaWRITE, wsaOOB, wsaACCEPT, wsaCONNECT, wsaCLOSE);
  TWSAEvents = set of TWSAEvent;

  TSimpSock = class(TObject)
  private
    fSd: TSocket;
    FMsgFlow: TMsgFlow;
    FAsync: boolean;
    FIp: string;
    FBinIp: cardinal;
    procedure WndProc(var AMessage: TMessage);
    procedure SetMsgFlow(R: real);
    function SockCheckRead(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer; // inline;
    function SockCheckWrite(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer; // inline;
    function SockCheckExcept(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer; // inline;
  protected
    FOwnHandle: THandle;
    FLastErr: integer;
    FPort: word;
    BreakFlag: boolean;
    FWsaEvents: TWSAEvents;
    FConnected: boolean;

    procedure FSetIp(aIp: string);
    procedure FSetBinIp(aBinIp: cardinal);
    function LoadLastErr(Res: TStatus): TStatus;
    procedure wmSocketEvent(var AMessage: TMessage); message wm_SocketEvent;

    procedure DoOnMsgRead; virtual;
    procedure DoOnMsgWrite; virtual;
    procedure DoOnMsgOOB; virtual;
    procedure DoOnAccept; virtual;
    procedure DoOnConnect; virtual;
    procedure DoOnClose; virtual;
    procedure DoOnException; virtual;
    function FillINetStruct(var Addr: TSockAddr; IP: string; Port: word): TStatus; overload;
    function FillINetStruct(var Addr: TSockAddr; IPd: cardinal; Port: word): TStatus; overload;
    // property  Sd: TSocket read fSd write fSd;
    function SetWsaEvents: integer;
    procedure FSetAsync(AAsync: boolean);
    function FGetAsync: boolean;
  public
    ExceptCnt: integer;
    RecWaitTime: integer;
    SndWaitTime: integer;
    OnMsgReadCnt: integer;
    property Sd: TSocket read fSd write fSd;
    constructor Create;
    destructor Destroy; override;
    function Open: TStatus; virtual;
    function Close: TStatus; virtual;
    procedure SetBreak(val: boolean);
    function GetHandle: THandle;
    procedure Freehandle;
    function SockCheck(const aCheckMthd: TSockCheckMthd): boolean; overload;
    function SockCheck(const aCheckMthd: TSockCheckMthd; aTime: integer): boolean; overload;
    function CheckRead: boolean; overload;
    function CheckRead(Time: integer): boolean; overload;
    function CheckWrite: boolean; // inline;
    function CheckExcept: boolean; // inline;
    function IsConnected: boolean; // inline;

    property LastErr: integer read FLastErr;
    property Port: word read FPort write FPort;
    property IP: string read FIp write FSetIp;
    property BinIp: cardinal read FBinIp write FSetBinIp;
    function DSwap(X: cardinal): cardinal;
    property MsgFlow: TMsgFlow read FMsgFlow write FMsgFlow;
    property Socket: TSocket read fSd;
    property Async: boolean read FGetAsync write FSetAsync;
  end;

  TTcpRdEvent = procedure(Sender: TObject; RecBuf: string) of object;

  TSimpTcp = class(TSimpSock)
  private
    MaxRecBuf: integer;
    MaxSndBuf: integer;
    mReadStrPart: AnsiString;
    mReadStrPartSt: TStatus;
  protected
    FNonBlkMode: boolean;
    procedure DoOnConnect; override;
    procedure DoOnClose; override;
    procedure DoOnMsgRead; override;
    procedure DoOnMsgWrite; override;
  public
    OnConnect: TNotifyEvent;
    OnClose: TNotifyEvent;
    OnMsgRead: TNotifyEvent;
    OnMsgWrite: TNotifyEvent;
    SendItemCnt: integer;
    SendNagleItemCnt: integer;
    constructor Create;
    destructor Destroy; override;
    function Open: TStatus; override;
    function Close: TStatus; override;
    function Connect: TStatus; virtual;
    function ReOpen: TStatus;
    function Write(buf: TBytes): TStatus; overload;
    function Write(txt: AnsiString): TStatus; overload;
    function WriteStr(txt: string): TStatus;
    function WriteStream(Stream: TMemoryStream): TStatus;
    function ReadStrPart(Var txt: AnsiString): TStatus;
    function Read(Var buf; var Len: integer): TStatus;
    function ReadStr(Var txt: string): TStatus;
    function ReadAnsiStr(Var txt: AnsiString): TStatus;

    // ReadStream: MaxBytes: zabezpieczenie przed allokacj¹ zbyt wielkich bloków pamiêci
    // MaxTimeMsec : Maksymalny okres oczekiwania na kompletacjê danych
    function ReadStream(Stream: TMemoryStream; MaxBytes: integer): TStatus;
    function ReadBinaryStream(Stream: TMemoryStream; MaxBytes: integer): TStatus;
    function ReciveToBufTime(StartT: cardinal; var buf; Count: integer): TStatus;
    function ClearInpBuf: TStatus;
  end;

function StrToInetAdr(IP: string; var IPd: cardinal): TStatus;
function DSwap(X: cardinal): cardinal;
function IpToStr(IP: cardinal): string;
procedure GetLocalAdresses(SL: TStrings);
function GetLocalAdress: string;
function GetHostName: string;
function StrToIP(s: string; var IP: cardinal): boolean;

var
  SocketsVersion: integer;
  SocketRevision: integer;
  SocketsOk: boolean;

implementation

const
  HPOS_EVENT = 0;
  HPOS_SOCKET = 1;

function StrToIP(s: string; var IP: cardinal): boolean;
var
  a: integer;
  b: array [0 .. 3] of cardinal;
  err: boolean;
  X, k, i, l: integer;
  s1: string;
begin
  IP := 0;
  l := length(s);
  i := 1;
  err := false;
  for k := 0 to 3 do
  begin
    X := i;
    while (i <= l) and (s[i] <> '.') do
      inc(i);
    s1 := copy(s, X, i - X);
    inc(i);
    if s1 <> '' then
    begin
      try
        a := StrToInt(s1);
        if (a > 255) or (a < 0) then
          err := false
        else
          b[k] := a;
      except
        err := true;
      end;
    end
    else
    begin
      err := true;
      break;
    end;
  end;
  if not(err) then
  begin
    IP := (b[3] shl 24) or (b[2] shl 16) or (b[1] shl 8) or b[0];
  end;
  Result := not(err);
end;

function DSwap(X: cardinal): cardinal;
begin
  Result := Swap(X shr 16) or (Swap(X and $FFFF) shl 16);
end;

function IpToStr(IP: cardinal): string;
var
  b1, b2, b3, b4: byte;
begin
  IP := DSwap(IP);
  b1 := (IP shr 24) and $FF;
  b2 := (IP shr 16) and $FF;
  b3 := (IP shr 8) and $FF;
  b4 := IP and $FF;
  Result := Format('%u.%u.%u.%u', [b1, b2, b3, b4]);
end;

function GetHostName: string;
var
  s1: string;
begin
  SetLength(s1, 250);
  WinSock2.GetHostName(PAnsiChar(s1), length(s1));
  Result := String(PChar(s1));
end;

procedure GetLocalAdresses(SL: TStrings);
type
  TaPInAddr = Array [0 .. 250] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  i: integer;
  AHost: PHostEnt;
  PAdrPtr: PaPInAddr;
begin
  SL.Clear;
  AHost := GetHostByName(PAnsiChar(GetHostName));
  if AHost <> nil then
  begin
    PAdrPtr := PaPInAddr(AHost^.h_addr_list);
    i := 0;
    while PAdrPtr^[i] <> nil do
    begin
      SL.Add(IpToStr(cardinal(PAdrPtr^[i].S_addr)));
      inc(i);
    end;
  end;
end;

function GetLocalAdress: string;
var
  SL: TStringList;
begin
  Result := '';
  SL := TStringList.Create;
  try
    GetLocalAdresses(SL);
    if SL.Count > 0 then
      Result := SL.Strings[0];
  finally
    SL.Free;
  end;
end;

function StrToInetAdr(IP: string; var IPd: cardinal): TStatus;
begin
  if IP <> '' then
  begin
    if not(StrToIP(IP, IPd)) then
    begin
      WSASetLastError(WSAEFAULT);
      Result := WSAEFAULT;
    end
    else
      Result := stOk;
  end
  else
  begin
    IPd := 0;
    Result := stOk;
  end;
end;


// -------------------------- TSimpSock ----------------------------------

constructor TSimpSock.Create;
begin
  inherited Create;
  Sd := INVALID_SOCKET;
  FOwnHandle := INVALID_HANDLE_VALUE;
  FPort := 0;
  FIp := '';
  ExceptCnt := 0;
  RecWaitTime := 200; // 200 milisekund
  SndWaitTime := 200; // 200 milisekund
  FWsaEvents := [wsaREAD, wsaCONNECT, wsaCLOSE];
end;

function TSimpSock.LoadLastErr(Res: TStatus): TStatus;
begin
  if (Res <> stOk) then
    FLastErr := WSAGetLastError
  else
    FLastErr := stOk;
  Result := FLastErr
end;

function TSimpSock.Open: TStatus;
begin
  Result := stOk;
  if Sd <> INVALID_SOCKET then
  begin
    Result := Close;
  end;
end;

function TSimpSock.Close: TStatus;
begin
  Result := stOk;
  if Sd <> INVALID_SOCKET then
  begin
    Result := shutdown(Sd, SD_Send);
    if Result = stOk then
      Result := CloseSocket(Sd);
    if Result = stOk then
      Sd := INVALID_SOCKET;
    Result := LoadLastErr(Result);
  end;
  FConnected := false;
end;

destructor TSimpSock.Destroy;
begin
  Close;
  Freehandle;
  inherited;
end;

procedure TSimpSock.SetBreak(val: boolean);
begin
  BreakFlag := val;
end;

function TSimpSock.GetHandle: THandle;
begin
  if FOwnHandle = INVALID_HANDLE_VALUE then
  begin
    FOwnHandle := Classes.AllocateHWnd(WndProc);
  end;
  Result := FOwnHandle;
end;

procedure TSimpSock.Freehandle;
begin
  if FOwnHandle <> INVALID_HANDLE_VALUE then
  begin
    Classes.DeallocateHWnd(FOwnHandle);
  end;
end;

procedure TSimpSock.SetMsgFlow(R: real);
begin
  if Assigned(FMsgFlow) then
    FMsgFlow(self, R);
end;

procedure TSimpSock.WndProc(var AMessage: TMessage);
begin
  inherited;
  Dispatch(AMessage);
end;

procedure TSimpSock.wmSocketEvent(var AMessage: TMessage);
var
  Ev: word;
begin
  try
    Ev := LoWord(AMessage.LParam);
    if (Ev and FD_READ) <> 0 then
      DoOnMsgRead;
    if (Ev and FD_WRITE) <> 0 then
      DoOnMsgWrite;
    if (Ev and FD_OOB) <> 0 then
      DoOnMsgOOB;
    if (Ev and FD_ACCEPT) <> 0 then
      DoOnAccept;
    if (Ev and FD_CONNECT) <> 0 then
      DoOnConnect;
    if (Ev and FD_CLOSE) <> 0 then
      DoOnClose;
  except
    DoOnException;
  end;
end;

procedure TSimpSock.DoOnMsgRead;
begin
  inc(OnMsgReadCnt);
end;

procedure TSimpSock.DoOnMsgWrite;
begin
end;

procedure TSimpSock.DoOnMsgOOB;
begin
end;

procedure TSimpSock.DoOnAccept;
begin
end;

procedure TSimpSock.DoOnConnect;
begin
end;

procedure TSimpSock.DoOnClose;
begin
  FConnected := false;
end;

procedure TSimpSock.DoOnException;
begin

end;

function TSimpSock.CheckRead(Time: integer): boolean;
begin
  Result := SockCheck(SockCheckRead, Time);
end;

function TSimpSock.CheckRead: boolean;
begin
  Result := SockCheck(SockCheckRead)
end;

function TSimpSock.CheckWrite: boolean;
begin
  Result := SockCheck(SockCheckWrite)
end;

function TSimpSock.FillINetStruct(var Addr: TSockAddr; IP: string; Port: word): TStatus;
var
  IPd: cardinal;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sa_family := PF_INET;
  sockaddr_in(Addr).sin_port := HToNs(Port);
  Result := StrToInetAdr(IP, IPd);
  sockaddr_in(Addr).sin_addr.S_addr := IPd;
end;

function TSimpSock.FillINetStruct(var Addr: TSockAddr; IPd: cardinal; Port: word): TStatus;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sa_family := PF_INET;
  sockaddr_in(Addr).sin_port := HToNs(Port);
  sockaddr_in(Addr).sin_addr.S_addr := integer(IPd);
  Result := stOk;
end;

function TSimpSock.SetWsaEvents: integer;
var
  w: cardinal;
begin
  w := 0;
  if wsaREAD in FWsaEvents then
    w := w or FD_READ;
  if wsaWRITE in FWsaEvents then
    w := w or FD_WRITE;
  if wsaOOB in FWsaEvents then
    w := w or FD_OOB;
  if wsaACCEPT in FWsaEvents then
    w := w or FD_ACCEPT;
  if wsaCONNECT in FWsaEvents then
    w := w or FD_CONNECT;
  if wsaCLOSE in FWsaEvents then
    w := w or FD_CLOSE;
  GetHandle;
  Result := WSAAsyncSelect(Sd, FOwnHandle, wm_SocketEvent, w);
  if Result <> 0 then
    Result := WSAGetLastError;
end;

procedure TSimpSock.FSetIp(aIp: string);
begin
  FIp := aIp;
  StrToIP(aIp, FBinIp);
end;

procedure TSimpSock.FSetBinIp(aBinIp: cardinal);
begin
  FBinIp := aBinIp;
  FIp := IpToStr(FBinIp);
end;

procedure TSimpSock.FSetAsync(AAsync: boolean);
var
  p: TStatus;
begin
  p := stOk;
  if AAsync then
  begin
    if not(FAsync) then
    begin
      GetHandle;
      p := SetWsaEvents;
    end;
  end
  else
  begin
    if FAsync then
    begin
      p := WSAAsyncSelect(Sd, FOwnHandle, 0, 0);
    end;
  end;
  FAsync := AAsync;
  LoadLastErr(p);
end;

function TSimpSock.FGetAsync: boolean;
begin
  Result := FAsync; // (FownHandle<>INVALID_HANDLE_VALUE);
end;

function TSimpSock.DSwap(X: cardinal): cardinal;
begin
  Result := Swap(X shr 16) or (Swap(X and $FFFF) shl 16);
end;

function TSimpSock.SockCheck(const aCheckMthd: TSockCheckMthd): boolean;
begin
  Result := SockCheck(aCheckMthd, RecWaitTime);
end;

{
  CONSTRUCTOR TComms.Create (VAR bSuccess : Boolean);
  BEGIN
  // 1.0 Inherit parent properties
  INHERITED Create(TRUE);

  // 1.1 Initialise Member Variables (Thread)
  FreeOnTerminate := FALSE;
  Priority        := tpHigher;

  // 1.2 Create the 'WM_QUIT' and Socket Events
  m_aSocketHandle[0] := CreateEvent (NIL, TRUE, FALSE, NIL);
  m_aSocketHandle[1] := WSACreateEvent;

  // 1.3 Configure the Security Attributes Structure
  m_tsSecAttrib.bInheritHandle       := TRUE;
  m_tsSecAttrib.lpSecurityDescriptor := NIL;
  m_tsSecAttrib.nLength              := sizeof(m_tsSecAttrib);

  // 1.4 Create a new Network Events Structure
  new (m_tpEvent);

  // 1.5 Initialise WinSock, Configure Socket, and 'Connect'
  m_dwErrorCode := InitialiseWinSock;

  // 1.6 Analyse Initialisation Result and Action
  IF (m_dwErrorCode = SUCCESS) THEN
  BEGIN
  bSuccess := TRUE;
  END
  ELSE
  BEGIN
  bSuccess := FALSE;
  END;
  END;
}

function TSimpSock.SockCheck(const aCheckMthd: TSockCheckMthd; aTime: integer): boolean;
const
  SOCKET_COUNT = 1;
var
  FdSet: TFdSet;
  TimeVal: TTimeVal;
begin
  Result := false;
  Assert(FD_SETSIZE >= SOCKET_COUNT);
  FdSet.fd_array[0] := fSd;
  FdSet.fd_count := SOCKET_COUNT;
  TimeVal.tv_sec := aTime div 1000;
  TimeVal.tv_usec := (aTime * 1000) mod 1000000;
  case aCheckMthd(TimeVal, FdSet) of
    0: // timeout
      FLastErr := WSAETIMEDOUT;
    SOCKET_ERROR:
      LoadLastErr(SOCKET_ERROR);
    1 .. FD_SETSIZE:
      Result := FdSet.fd_count = SOCKET_COUNT
  else
    Assert(false, 'TSimpSock.SockCheck()')
  end
end;

function TSimpSock.SockCheckExcept(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer;
begin
  Result := select(0, nil, nil, @aFdSet, @aTimeVal)
end;

function TSimpSock.SockCheckRead(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer;
begin
  Result := select(0, @aFdSet, nil, nil, @aTimeVal)
end;

function TSimpSock.SockCheckWrite(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer;
begin
  Result := select(0, nil, @aFdSet, nil, @aTimeVal)
end;

function TSimpSock.CheckExcept: boolean;
begin
  Result := SockCheck(SockCheckExcept)
end;

function TSimpSock.IsConnected: boolean;
begin
  Result := FConnected;
end;

// ------------------------- TSimpTCP -------------------------------------
constructor TSimpTcp.Create;
begin
  inherited Create;

  RecWaitTime := 1000; // 200 milisekund
  SndWaitTime := 1000; // 200 milisekund
  FNonBlkMode := true;
end;

destructor TSimpTcp.Destroy;
begin
  inherited;
end;

function TSimpTcp.Open: TStatus;
var
  n: integer;
  s: u_long;
  Size: integer;
begin
  FAsync := false;
  Result := inherited Open;
  Sd := WinSock2.Socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  if Result <> integer(INVALID_SOCKET) then
  begin
    if FNonBlkMode then
      s := 1 // 1-nonbloking mode;
    else
      s := 0; // 0-bloking mode;
    Result := ioctlsocket(Sd, FIONBIO, s);
  end;
  if Result = stOk then
  begin
    Size := $20000;
    Result := setsockopt(Sd, SOL_SOCKET, SO_RCVBUF, PAnsiChar(@Size), SizeOf(Size));
  end;
  if Result = stOk then
  begin
    n := SizeOf(MaxRecBuf);
    Result := GetSockOpt(Sd, SOL_SOCKET, SO_RCVBUF, PAnsiChar(@MaxRecBuf), n);
  end;
  if Result = stOk then
  begin
    Size := $20100;
    Result := setsockopt(Sd, SOL_SOCKET, SO_SNDBUF, PAnsiChar(@Size), SizeOf(Size));
  end;
  if Result = stOk then
  begin
    n := SizeOf(MaxSndBuf);
    Result := GetSockOpt(Sd, SOL_SOCKET, SO_SNDBUF, PAnsiChar(@MaxSndBuf), n);
  end;
  Result := LoadLastErr(Result);
end;

function TSimpTcp.Close: TStatus;
begin
  if cardinal(Sd) <> cardinal(INVALID_SOCKET) then
  begin
    shutdown(Sd, SD_Send);
    Result := CloseSocket(Sd);
    Sd := INVALID_SOCKET;
    Result := LoadLastErr(Result);
  end
  else
    Result := stOk;
  FConnected := false;
end;

procedure TSimpTcp.DoOnConnect;
begin
  inherited;
  if Assigned(OnConnect) then
    OnConnect(self);
end;

procedure TSimpTcp.DoOnClose;
begin
  inherited;
  if Assigned(OnClose) then
    OnClose(self);
end;

procedure TSimpTcp.DoOnMsgWrite;
begin
  inherited;
  if Assigned(OnMsgWrite) then
    OnMsgWrite(self);
end;

function TSimpTcp.Connect: TStatus;
var
  Addr: TSockAddr;
begin
  Result := stConnectError;
  FConnected := false;
  if FillINetStruct(Addr, FIp, FPort) = stOk then
  begin
    // socket is non-blocking (connection attempt cannot be completed immediately)
    // so there will be error on connect
    { Result := }
    WinSock2.Connect(Sd, Addr, SizeOf(Addr));
    FConnected := CheckWrite;
    if not(FConnected) then
    begin
      sleep(500);
      FConnected := CheckWrite;
      if not(FConnected) then
      begin
        sleep(500);
        FConnected := CheckWrite;
        if not(FConnected) then
        begin
          sleep(500);
          FConnected := CheckWrite;
        end;
      end;
    end;
    if FConnected then
      Result := stOk;
  end
end;

function TSimpTcp.ReOpen: TStatus;
begin
  Close;
  Result := Open;
  if Result = stOk then
    Result := Connect;
end;

function TSimpTcp.Write(buf: TBytes): TStatus;
begin
  inc(SendItemCnt);
  Result := send(Sd, buf[0], length(buf), 0);
  SetMsgFlow(length(buf));
  Result := LoadLastErr(Result);
end;

function TSimpTcp.Write(txt: AnsiString): TStatus;
begin
  inc(SendItemCnt);
  Result := send(Sd, txt[1], length(txt), 0);
  SetMsgFlow(length(txt));
  Result := LoadLastErr(Result);
end;

function TSimpTcp.WriteStr(txt: string): TStatus;
var
  txt1: AnsiString;
begin
  txt1 := AnsiString(txt);
  if txt1 <> '' then
  begin
    Result := Write(txt1);
  end
  else
    Result := stOk;
end;

function TSimpTcp.WriteStream(Stream: TMemoryStream): TStatus;
begin
  Result := send(Sd, pByte(Stream.memory)^, Stream.Size, 0);
end;

function TSimpTcp.Read(Var buf; var Len: integer): TStatus;
var
  l: integer;
begin
  l := recv(Sd, buf, Len, 0);
  if l <> SOCKET_ERROR then
  begin
    Len := l;
    Result := stOk;
  end
  else
  begin
    Result := WSAGetLastError;
  end;
  Result := LoadLastErr(Result);
end;

function TSimpTcp.ReadStrPart(Var txt: AnsiString): TStatus;
var
  l: u_long;
  Li: integer;
begin
  txt := '';
  Result := ioctlsocket(Sd, FIONREAD, l);
  if (Result = stOk) and (l > 0) then
  begin
    Li := l;
    SetLength(txt, Li);
    Result := Read(txt[1], Li);
  end;
end;

function TSimpTcp.ReadAnsiStr(Var txt: AnsiString): TStatus;
var
  tx1: AnsiString;
begin
  txt := '';
  repeat
    Result := ReadStrPart(tx1);
    txt := txt + tx1;
    if Result <> stOk then
      break;
    if (tx1 = '') and (txt = '') then
      sleep(50);
  until tx1 = '';
end;

function TSimpTcp.ReadStr(Var txt: string): TStatus;
var
  txt1: AnsiString;
begin
  Result := ReadAnsiStr(txt1);
  txt := string(txt1);
end;

procedure TSimpTcp.DoOnMsgRead;
begin
  inherited;
  if Assigned(OnMsgRead) then
    OnMsgRead(self)
end;

function TSimpTcp.ClearInpBuf: TStatus;
var
  buf: array of byte;
  l: u_long;
  Li: integer;
begin
  repeat
    Result := ioctlsocket(Sd, FIONREAD, l);
    if (Result = stOk) and (l > 0) then
    begin
      Li := l;
      SetLength(buf, Li);
      Result := Read(buf[0], Li);
    end;
  until (Result <> stOk) or (l = 0);
  Result := LoadLastErr(Result);
end;

function TSimpTcp.ReciveToBufTime(StartT: cardinal; var buf; Count: integer): TStatus;
type
  TByteArray = array [0 .. MAXINT - 1] of byte;
var
  Lu: u_long;
  l: integer;
  Done: boolean;
  Ptr: integer;
  Size: integer;
begin
  Ptr := 0;
  Size := Count;
  BreakFlag := false;
  SetMsgFlow(0);
  repeat
    Result := ioctlsocket(Sd, FIONREAD, Lu);
    l := Lu;
    if l > 0 then
    begin
      if l > Count then
        l := Count;
      Result := Read(TByteArray(buf)[Ptr], l);
      Count := Count - l;
      Ptr := Ptr + l;
      SetMsgFlow(Size - Count);
      StartT := GetTickCount;
    end
    else
      sleep(5);
    Done := (Count = 0);
  until (integer(GetTickCount - StartT) > RecWaitTime) or (Result <> stOk) or Done or BreakFlag;
  if BreakFlag then
  begin
    Result := stUserBreak;
    Exit;
  end;
  if not(Done) then
  begin
    WSASetLastError(WSAETIMEDOUT); // WSAEMSGSIZE
    Result := LoadLastErr(WSAETIMEDOUT);
  end;
end;

function TSimpTcp.ReadStream(Stream: TMemoryStream; MaxBytes: integer): TStatus;
var
  FrameSize: DWORD; // Wielkoœæ ramki
  Count: integer; //
  p, buf: PChar;
begin
  Count := SizeOf(FrameSize);
  Result := ReciveToBufTime(GetTickCount, FrameSize, Count);
  if Result <> stOk then
    Exit;
  FrameSize := DSwap(FrameSize); // -SizeOf(DWORD);

  if FrameSize > cardinal(MaxBytes) then
  begin
    Result := stFrmTooLarge;
    Exit;
  end;

  GetMem(buf, FrameSize + 1);
  p := buf;
  Result := ReciveToBufTime(GetTickCount, p^, FrameSize);
  if Result = stOk then
  begin
    inc(p, FrameSize);
    pByte(p)^ := 0;
    Stream.SetSize(FrameSize + 1);
    Stream.Seek(0, soFromBeginning);
    Stream.WriteBuffer(buf^, FrameSize + 1);
  end;

  if buf <> nil then
    FreeMem(buf);
end;

function TSimpTcp.ReadBinaryStream(Stream: TMemoryStream; MaxBytes: integer): TStatus;
var
  FrameSize: DWORD; // Wielkoœæ ramki
  Count: integer; //
  p, buf: PChar;
begin
  Count := SizeOf(FrameSize);
  Result := ReciveToBufTime(GetTickCount, FrameSize, Count);
  if Result <> stOk then
    Exit;
  FrameSize := DSwap(FrameSize); // -SizeOf(DWORD);

  if FrameSize > cardinal(MaxBytes) then
  begin
    Result := stFrmTooLarge;
    Exit;
  end;

  GetMem(buf, FrameSize + 1);
  p := buf;
  Result := ReciveToBufTime(GetTickCount, p^, FrameSize);
  if Result = stOk then
  begin
    Stream.SetSize(FrameSize);
    Stream.Seek(0, soFromBeginning);
    Stream.WriteBuffer(buf^, FrameSize);
  end;

  if buf <> nil then
    FreeMem(buf);
end;





// ------------------------- inicjalizacja WSA --------------------------------

procedure InitSockets;
var
  sData: TWSAData;
begin
  if WSAStartup($101, sData) <> SOCKET_ERROR then
  begin
    SocketsVersion := sData.wVersion;
    SocketRevision := sData.wHighVersion;
    SocketsOk := true;
  end
  else
  begin
    SocketsOk := false;
  end;
end;

procedure DoneSockets;
begin
  WSACleanup;
end;

initialization

InitSockets;

finalization

DoneSockets;

end.
