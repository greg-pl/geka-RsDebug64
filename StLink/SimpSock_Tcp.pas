unit SimpSock_Tcp;

interface

uses
  Classes, Windows, Messages, Types, SysUtils, Contnrs,
  WinSock2,
  ExtCtrls;

const
  wm_SocketEvent = wm_user + 100;
  wm_CloseClient = wm_user + 101;

  wm_UserMin = wm_user + 1000;
  wm_SvrConnect = wm_UserMin + 1;
  wm_SvrDisconnect = wm_UserMin + 2;

  wm_UserMax = wm_user + 1200;

type
  TStatus = integer;

const
  stOk = 0;
  stTimeOut = 1;
  stErrorRecived =2;
  stReplyFormatError = 3;
  stReplySumError = 4;
  stNotOpen = 12;
  stUserBreak = 15;
  stFrmTooLarge = 16;
  stError = -1;

  STR_B = #2;
  STR_K = #3;

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

  TSimpUdp = class(TSimpSock)
  protected
    RecBuf: string;
    RecIp: string;
    RecPort: word;
    FOnMsgRead: TRdEvent;
    procedure DoOnMsgRead; override;
  public
    VPort: word;
    constructor Create;
    function Open: TStatus; override;
    function Close: TStatus; override;
    function ReadFromSocket(var RecBuf: string; var RecIp: string; var RecPort: word): TStatus;
    function SendBuf(DestIp: string; DestPort: word; var buf; Len: integer): TStatus; overload;
    function SendBuf(DestIp: cardinal; DestPort: word; var buf; Len: integer): TStatus; overload;
    function SendStr(DestIp: string; DestPort: word; ToSnd: string): TStatus; overload;
    function SendStr(IPd: cardinal; DestPort: word; ToSnd: string): TStatus; overload;
    function BrodcastStr(DestPort: word; ToSnd: string): TStatus;
    function ClearRecBuf: TStatus;
    function EnableBrodcast(Enable: boolean): TStatus;
    property OnMsgRead: TRdEvent read FOnMsgRead write FOnMsgRead;
  end;

  TTcpRdEvent = procedure(Sender: TObject; RecBuf: string) of object;

  TSimpTcp = class(TSimpSock)
  private
    MaxRecBuf: integer;
    MaxSndBuf: integer;
    FRestReadStrLN: AnsiString;
    mReadStrPart: AnsiString;
    mReadStrPartSt: TStatus;
    mAlgStringZ: boolean;
    afterSTR_B: boolean;
    mNagleTm: integer;
    mNeagleaList: TStringList;
    mNeagleaTimer: TTimer;
    mNagleaFirstItemTick: cardinal;
    procedure OnNeagleaTimerProc(Sender: TObject);
    procedure SendNeagleList;
    procedure AddToRecString(txt: string);
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
    procedure SetAlgZtrZ(aAlg: boolean);
    function Open: TStatus; override;
    function Close: TStatus; override;
    function Connect: TStatus; virtual;
    function ReOpen: TStatus;
    function Write_(txt: AnsiString): TStatus;
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
    procedure SetNagleTm(tm: integer);
    function isNaglea: boolean;
  end;

  TLockString = class(TObject)
  private
    FMyStr: string;
    flNew: boolean;
    CriSection: TRTLCriticalSection;
    function FGetString: string;
    procedure FSetString(s: string);
    procedure Lock;
    procedure Unlock;
  public
    constructor Create;
    destructor Destroy; override;
    property s: string read FGetString write FSetString;
    function IsNew: boolean;
  end;

  TLockStringStack = class(TObject)
  private
    mList: TStringList;
    CriSection: TRTLCriticalSection;
    procedure Lock;
    procedure Unlock;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Push(txt: string);
    function Pop(var txt: string): boolean;
  end;

  // TCPServer

  TSimpServerTCP = class;

  TClientTaskList = class;

  TClientTask = class(TThread)
  private
    FSimpTcp: TSimpTcp;
    FOwner: TSimpServerTCP;
    mHandleTab: TWOHandleArray;
    m_tpEvent: TWSANetworkEvents;
    ToSendData: TLockStringStack;
    procedure OnMsgReadProc(Sender: TObject);
  protected
    mTickPeriod: integer; // czas oczekiwania w WaitMultileObject
    procedure Execute; override;
    procedure _SendCmd(s: string);
  protected
    procedure _doLoopTick; virtual; // wywo³ywana co mTickPeriod przez Thread
    procedure _doOnRead(txt: string); virtual;
    procedure _doOnUserEvent; virtual;
    procedure _DoOnException; virtual;
  protected
    procedure Start(aSd: TSocket; RecIp: string; RecPort: word); virtual;
  public
    ClientIP: string;
    ClientIPBin: cardinal;
    ClientPort: word;
    constructor Create(aOwner: TSimpServerTCP); virtual;
    destructor Destroy; override;
    procedure CloseMe;
    procedure WriteStr(txt: string);
  end;

  TClientTaskList = class(TObjectList)
  private
    FCriSection: TRTLCriticalSection;
    function FGetItem(Index: integer): TClientTask;
    procedure Lock;
    procedure Unlock;
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TClientTask read FGetItem;
    procedure WaitForAll;
    procedure Add(task: TClientTask);
    procedure Remoove(task: TClientTask);
    procedure CloseClients;
  end;

  TClientTaskClass = class of TClientTask;

  TSimpServerTCP = class(TThread)
  private
    mPort: word;
    mFlStopListen: boolean;
    mFlStartListen: boolean;

    FClientTaskClass: TClientTaskClass;
    FClientTaskList: TClientTaskList;
    mHandleTab: TWOHandleArray;
    m_tpEvent: TWSANetworkEvents;
    FSimpTcp: TSimpTcp;
    mListening: boolean;

  protected
    mTickPeriod: integer;
    procedure Execute; override;
    procedure _doAccept; virtual;
    procedure _doLoopTick; virtual;
    procedure _doDisConnect; virtual;
    procedure _doStartListen; virtual;
    procedure setMyEvent;
  public
    constructor Create(aClientTaskClass: TClientTaskClass);
    destructor Destroy; override;
    procedure Startlisten(Port: word);
    procedure StopListen;
    function GetClientsCnt: integer;
    function isListening: boolean;
  end;


  // TCPAsynchServer

  TAsynchClientList = class;
  TAsynchServerTCP = class;

  TAsynchClient = class(TSimpTcp)
  private
    FOwner: TAsynchServerTCP;
    procedure Start(aSd: TSocket; RecIp: string; RecPort: word);
  protected
    property Owner: TAsynchServerTCP read FOwner;
    procedure DoCloseMe;
    procedure DoOnClose; override;
    procedure DoOnStart; virtual;
  public
    constructor Create(aOwner: TAsynchServerTCP); virtual;
    destructor Destroy; override;
  end;

  TAsynchClientClass = class of TAsynchClient;

  TAsynchClientList = class(TObjectList)
  private
    function FGetItem(Index: integer): TAsynchClient;
  public
    property Items[Index: integer]: TAsynchClient read FGetItem;
    procedure Add(task: TAsynchClient);
  end;

  TAsynchServerTCP = class(TSimpTcp)
  private
    mListening: boolean;
    FClientList: TAsynchClientList;
    FClientClass: TAsynchClientClass;
    function FGetItem(Index: integer): TAsynchClient;
    procedure wmCloseClient(var AMessage: TMessage); message wm_CloseClient;
  protected
    procedure DoOnAccept; override;
  public
    property Items[Index: integer]: TAsynchClient read FGetItem;
    constructor Create(aAsynchClientClass: TAsynchClientClass);
    destructor Destroy; override;
    function Open: TStatus; override;
    function Startlisten(aPort: word): integer;
    procedure StopListen;
    function Count: integer;
    function IndexOf(Ob: TObject): integer;
    property isListening: boolean read mListening;
  end;

  TTcpThread = class(TThread)
  private
    FSimpTcp: TSimpTcp;
    mHandleTab: TWOHandleArray;
    m_tpEvent: TWSANetworkEvents;
    procedure OnMsgReadProc(Sender: TObject);
    function getRecFrameCnt: integer;
    procedure setFrameCnt(n: integer);
  protected
    mTickPeriod: integer; // czas oczekiwania w WaitMultileObject
    procedure Execute; override;
    procedure _SendCmd(s: string);
    procedure _Connect; virtual; //
    procedure _DisConnect; virtual; // wyo³ywana w momencie zamkniêcia socketu
    procedure _doLoopTick; virtual; // wywo³ywana co mTickPeriod przez Thread
    procedure _doOnRead(txt: string); virtual;
    procedure _doOnUserEvent; virtual;
    procedure _doConnect; virtual;
    procedure SetServerAddr(IP: string; Port: word);
    procedure PostThreadMsg(msg: integer);

  public
    constructor Create(CreateSuspended: boolean);
    destructor Destroy; override;
    function IsConnected: boolean;
    procedure SetAlgZtrZ(aAlg: boolean);
    property RecFrameCnt: integer read getRecFrameCnt write setFrameCnt;

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

// -------------------------- TSimpUdp ----------------------------------

constructor TSimpUdp.Create;
begin
  inherited Create;
  RecWaitTime := 200; // 200 milisekund
  SndWaitTime := 200; // 200 milisekund
  FAsync := false;
end;

function TSimpUdp.Open: TStatus;
var
  n: integer;
  LAddr: TSockAddr;
  Addr: TSockAddr;
begin
  Result := inherited Open;
  if Result = stOk then
  begin
    Sd := WinSock2.Socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
    if Sd = INVALID_SOCKET then
      Result := WSAGetLastError;
  end;
  EnableBrodcast(true);
  if Result = stOk then
    Result := FillINetStruct(Addr, FIp, FPort);
  if Result = stOk then
  begin
    Result := bind(Sd, Addr, SizeOf(Addr));
  end;
  if Result = stOk then
  begin
    n := SizeOf(LAddr);
    Result := GetSockName(Sd, LAddr, n);
  end;

  if Result = stOk then
  begin
    VPort := Ntohs(sockaddr_in(Addr).sin_port);
    FSetAsync(true);
  end;
  Result := LoadLastErr(Result);
end;

function TSimpUdp.Close: TStatus;
begin
  FSetAsync(false);
  Result := inherited Close;
end;

function TSimpUdp.EnableBrodcast(Enable: boolean): TStatus;
var
  State: integer;
begin
  if Enable then
    State := 1
  else
    State := 0;
  Result := setsockopt(Sd, SOL_SOCKET, SO_BROADCAST, @State, SizeOf(State));
  Result := LoadLastErr(Result);
end;

function TSimpUdp.SendBuf(DestIp: string; DestPort: word; var buf; Len: integer): TStatus;
var
  Addr: TSockAddr;
begin
  Result := FillINetStruct(Addr, DestIp, DestPort);
  if Result = stOk then
    Result := sendto(Sd, buf, Len, 0, @Addr, SizeOf(Addr));
  Result := LoadLastErr(Result);
end;

function TSimpUdp.SendBuf(DestIp: cardinal; DestPort: word; var buf; Len: integer): TStatus;
var
  Addr: TSockAddr;
begin
  Result := FillINetStruct(Addr, DestIp, DestPort);
  if Result = stOk then
    Result := sendto(Sd, buf, Len, 0, @Addr, SizeOf(Addr));
  Result := LoadLastErr(Result);
end;

function TSimpUdp.SendStr(DestIp: string; DestPort: word; ToSnd: string): TStatus;
begin
  if ToSnd <> '' then
    Result := SendBuf(DestIp, DestPort, ToSnd[1], length(ToSnd))
  else
    Result := stOk;
end;

function TSimpUdp.SendStr(IPd: cardinal; DestPort: word; ToSnd: string): TStatus;
begin
  if ToSnd <> '' then
    Result := SendBuf(IPd, DestPort, ToSnd[1], length(ToSnd))
  else
    Result := stOk;
end;

function TSimpUdp.BrodcastStr(DestPort: word; ToSnd: string): TStatus;
begin
  Result := SendStr('255.255.255.255', DestPort, ToSnd);
end;

function TSimpUdp.ClearRecBuf: TStatus;
var
  AddrSize: integer;
  RecAdr: TSockAddr;
  Len: u_long;
  st: integer;
  RecBuf: string;
begin
  repeat
    st := ioctlsocket(Sd, FIONREAD, Len);
    if st <> SOCKET_ERROR then
    begin
      if Len <> 0 then
      begin
        SetLength(RecBuf, Len + 1);
        AddrSize := SizeOf(RecAdr);
        st := recvfrom(Sd, RecBuf[1], length(RecBuf), 0, RecAdr, AddrSize);
      end;
    end;
  until (st = SOCKET_ERROR) or (Len = 0);
  Result := st;
end;

function TSimpUdp.ReadFromSocket(var RecBuf: string; var RecIp: string; var RecPort: word): TStatus;
var
  AddrSize: integer;
  RecAdr: TSockAddr;
  Len: u_long;
  l: integer;
begin
  l := 0;
  Result := ioctlsocket(Sd, FIONREAD, Len);
  if Result = stOk then
  begin
    if Len <> 0 then
    begin
      SetLength(RecBuf, Len + 1);
      AddrSize := SizeOf(RecAdr);
      l := recvfrom(Sd, RecBuf[1], length(RecBuf), 0, RecAdr, AddrSize);
      if l = SOCKET_ERROR then
        Result := WSAGetLastError;
    end;
  end;
  if Result = stOk then
  begin
    if l <> 0 then
    begin
      SetLength(RecBuf, l);
      RecIp := inet_ntoa(sockaddr_in(RecAdr).sin_addr);
      RecPort := HToNs(sockaddr_in(RecAdr).sin_port);
    end
    else
    begin
      RecBuf := '';
      RecIp := '';
      RecPort := 0;
    end;
    FLastErr := 0;
  end;
  LoadLastErr(Result);
end;

procedure TSimpUdp.DoOnMsgRead;
begin
  inherited;
  ReadFromSocket(RecBuf, RecIp, RecPort);
  if Assigned(FOnMsgRead) then
    FOnMsgRead(self, RecBuf, RecIp, RecPort);
end;

// ------------------------- TSimpTCP -------------------------------------
constructor TSimpTcp.Create;
begin
  inherited Create;

  RecWaitTime := 1000; // 200 milisekund
  SndWaitTime := 1000; // 200 milisekund
  FNonBlkMode := true;
  FRestReadStrLN := '';
  mAlgStringZ := false;
  afterSTR_B := false;
  mNagleTm := 0; // Algorytm  Nagle'a wy³¹czony (³aczenie komunikatów)
  mNeagleaList := nil;
  mNeagleaTimer := nil;
  mNagleaFirstItemTick := 0;
end;

destructor TSimpTcp.Destroy;
begin
  if Assigned(mNeagleaTimer) then
    FreeAndNil(mNeagleaTimer);
  inherited;
end;

procedure TSimpTcp.SetNagleTm(tm: integer);
begin
  mNagleTm := tm;
  if mNagleTm <> 0 then
  begin
    if not Assigned(mNeagleaList) then
      mNeagleaList := TStringList.Create;
    if not Assigned(mNeagleaTimer) then
    begin
      mNeagleaTimer := TTimer.Create(nil);
      mNeagleaTimer.OnTimer := OnNeagleaTimerProc;
      mNeagleaTimer.Enabled := false;
      mNeagleaTimer.Interval := mNagleTm;
    end;
  end
  else
  begin
    if Assigned(mNeagleaList) then
      FreeAndNil(mNeagleaList);
    if Assigned(mNeagleaTimer) then
      FreeAndNil(mNeagleaTimer);
  end;
end;

function TSimpTcp.isNaglea: boolean;
begin
  Result := (mNagleTm > 0);
end;

procedure TSimpTcp.SetAlgZtrZ(aAlg: boolean);
begin
  mAlgStringZ := aAlg;
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
  Result := stError;
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

procedure TSimpTcp.SendNeagleList;
var
  txt: string;
  txt1: AnsiString;
begin
  try
    txt := mNeagleaList.Text;
    mNeagleaList.Clear;
    if txt <> '' then
    begin
      txt1 := AnsiString(txt);
      send(Sd, txt1[1], length(txt1), 0);
      inc(SendNagleItemCnt);
    end;
  except
    raise;
  end;
end;

procedure TSimpTcp.OnNeagleaTimerProc(Sender: TObject);
begin
  SendNeagleList;
  mNeagleaTimer.Enabled := false;
end;

function TSimpTcp.Write_(txt: AnsiString): TStatus;
begin
  inc(SendItemCnt);
  if not isNaglea then
  begin
    Result := send(Sd, txt[1], length(txt), 0);
    SetMsgFlow(length(txt));
    Result := LoadLastErr(Result);
  end
  else
  begin
    if mNeagleaList.Count = 0 then
    begin
      mNagleaFirstItemTick := GetTickCount;
      mNeagleaList.Add(txt);
      mNeagleaTimer.Enabled := true;
    end
    else
    begin
      mNeagleaList.Add(txt);
      if GetTickCount - mNagleaFirstItemTick > 3 * mNagleTm then
      begin
        SendNeagleList;
      end
      else
      begin
        mNeagleaTimer.Enabled := false;
        mNeagleaTimer.Interval := mNagleTm;
        mNeagleaTimer.Enabled := true;
      end;
    end;
  end;
end;

function TSimpTcp.WriteStr(txt: string): TStatus;
var
  txt1 : AnsiString;
begin
  txt1 := AnsiString(txt);
  if txt1 <> '' then
  begin
    if mAlgStringZ then
      txt1 := STR_B + txt + STR_K;
    Result := Write_(txt1);
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
  if not(mAlgStringZ) then
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
  end
  else
  begin
    txt := mReadStrPart;
    Result := mReadStrPartSt;
    mReadStrPart := '';
  end;
end;


function TSimpTcp.ReadStr(Var txt: string): TStatus;
var
  txt1: AnsiString;
begin
  Result := ReadAnsiStr(txt1);
  txt := string(txt1);
end;

procedure TSimpTcp.AddToRecString(txt: string);
var
  i, n: integer;
  ch: char;
begin
  n := length(txt);
  for i := 1 to n do
  begin
    ch := txt[i];
    if afterSTR_B = false then
    begin
      if ch = STR_B then
        afterSTR_B := true;
    end
    else
    begin
      if ch = STR_K then
      begin
        afterSTR_B := false;
        if Assigned(OnMsgRead) then
          OnMsgRead(self);
        mReadStrPart := '';
      end
      else
      begin
        mReadStrPart := mReadStrPart + ch;
      end;
    end;
  end;
end;

procedure TSimpTcp.DoOnMsgRead;
var
  txt1: AnsiString;
begin
  inherited;
  if Assigned(OnMsgRead) then
  begin
    if mAlgStringZ = false then
      OnMsgRead(self)
    else
    begin
      mReadStrPartSt := ReadStrPart(txt1);
      AddToRecString(txt1);
    end;
  end;
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

// ------------------------- TLockString --------------------------------
constructor TLockString.Create;
begin
  inherited;
  InitializeCriticalSection(CriSection);
  flNew := false;
end;

destructor TLockString.Destroy;
begin
  DeleteCriticalSection(CriSection);
  inherited;
end;

procedure TLockString.Lock;
begin
  EnterCriticalSection(CriSection);
end;

procedure TLockString.Unlock;
begin
  LeaveCriticalSection(CriSection);
end;

function TLockString.FGetString: string;
begin
  Lock;
  Result := FMyStr;
  flNew := false;
  Unlock;
end;

procedure TLockString.FSetString(s: string);
begin
  Lock;
  FMyStr := s;
  flNew := true;
  Unlock;
end;

function TLockString.IsNew: boolean;
begin
  Result := flNew;
end;

// ------------------------- TLockStringStack --------------------------------
constructor TLockStringStack.Create;
begin
  inherited;
  InitializeCriticalSection(CriSection);
  mList := TStringList.Create;
end;

destructor TLockStringStack.Destroy;
begin
  DeleteCriticalSection(CriSection);
  mList.Free;
  inherited;
end;

procedure TLockStringStack.Lock;
begin
  EnterCriticalSection(CriSection);
end;

procedure TLockStringStack.Unlock;
begin
  LeaveCriticalSection(CriSection);
end;

procedure TLockStringStack.Push(txt: string);
begin
  Lock;
  try
    mList.Add(txt);
  finally
    Unlock;
  end;
end;

function TLockStringStack.Pop(var txt: string): boolean;
begin
  Lock;
  try
    Result := (mList.Count > 0);
    if Result then
    begin
      txt := mList.Strings[0];
      mList.Delete(0);
    end;
  finally
    Unlock;
  end;
end;

// ------------------------- TClientTask --------------------------------

constructor TClientTask.Create(aOwner: TSimpServerTCP);
begin
  inherited Create(true);
  FOwner := aOwner;
  FSimpTcp := TSimpTcp.Create;
  FSimpTcp.OnMsgRead := OnMsgReadProc;

  ToSendData := TLockStringStack.Create;
  FOwner.FClientTaskList.Add(self);
  mHandleTab[HPOS_EVENT] := CreateEvent(nil, false, true, nil);
  mHandleTab[HPOS_SOCKET] := WSACreateEvent;
  mTickPeriod := 1000;
end;

destructor TClientTask.Destroy;
begin
  Terminate;
  FSimpTcp.Free;
  FOwner.FClientTaskList.Remoove(self);
  CloseHandle(mHandleTab[HPOS_EVENT]);
  ToSendData.Free;
  inherited;
end;

procedure TClientTask.OnMsgReadProc(Sender: TObject);
Var
  txt: string;
begin
  if FSimpTcp.ReadStr(txt) = stOk then
    _doOnRead(txt);
end;

procedure TClientTask.Start(aSd: TSocket; RecIp: string; RecPort: word);
begin
  FSimpTcp.Sd := aSd;
  ClientIP := RecIp;
  ClientPort := RecPort;
  StrToIP(ClientIP, ClientIPBin);
  WSAEventSelect(FSimpTcp.Sd, mHandleTab[HPOS_SOCKET], FD_READ or FD_CLOSE or FD_WRITE);
  Resume;
end;

procedure TClientTask._SendCmd(s: string);
begin
  FSimpTcp.WriteStr(s);
end;

procedure TClientTask._doLoopTick;
begin

end;

procedure TClientTask._DoOnException;
begin

end;

procedure TClientTask._doOnRead(txt: string);
begin

end;

procedure TClientTask._doOnUserEvent;
begin

end;

procedure TClientTask.Execute;
var
  waitRes: DWORD;
  txt: string;
begin
  while not(Terminated) do
  begin
    waitRes := WaitForMultipleObjects(2, @mHandleTab, false, mTickPeriod);
    if waitRes = STATUS_TIMEOUT then
    begin
      try
        _doLoopTick;
      except
        _DoOnException;
      end;
    end
    else if waitRes = STATUS_WAIT_0 + HPOS_SOCKET then
    begin
      // Socket Events
      if WSAENUMNetworkEvents(FSimpTcp.Sd, mHandleTab[HPOS_SOCKET], m_tpEvent) <> SOCKET_ERROR then
      begin
        if (m_tpEvent.lNetworkEvents and FD_READ) <> 0 then
          FSimpTcp.DoOnMsgRead;
        if (m_tpEvent.lNetworkEvents and FD_CLOSE) <> 0 then
          Terminate;
        if (m_tpEvent.lNetworkEvents and FD_WRITE) <> 0 then
        begin
          if ToSendData.Pop(txt) then
            FSimpTcp.WriteStr(txt);
        end;
      end;
    end
    else if waitRes = STATUS_WAIT_0 + HPOS_EVENT then
    begin
      if ToSendData.Pop(txt) then
        FSimpTcp.WriteStr(txt);
      try
        _doOnUserEvent;
      except
        _DoOnException;
      end;
    end;
  end;
  FSimpTcp.Close;
  FreeOnTerminate := true;
end;

procedure TClientTask.WriteStr(txt: string);
begin
  ToSendData.Push(txt);
  SetEvent(mHandleTab[HPOS_EVENT]);
end;

procedure TClientTask.CloseMe;
begin
  Terminate;
  SetEvent(mHandleTab[HPOS_EVENT]);
  FSimpTcp.Close;
end;

// ------------------------- TClientTaskList --------------------------------
constructor TClientTaskList.Create;
begin
  inherited Create(false);
  InitializeCriticalSection(FCriSection);
end;

destructor TClientTaskList.Destroy;
var
  quit: boolean;
begin
  CloseClients;
  while true do
  begin
    Lock;
    quit := (Count = 0);
    Unlock;
    if quit then
      break;
    sleep(100);
  end;
  DeleteCriticalSection(FCriSection);
  inherited;
end;

procedure TClientTaskList.Add(task: TClientTask);
begin
  Lock;
  try
    inherited Add(task);
  finally
    Unlock;
  end;
end;

procedure TClientTaskList.Remoove(task: TClientTask);
var
  n: integer;
begin
  Lock;
  try
    n := IndexOf(task);
    if n >= 0 then
      Delete(n);
  finally
    Unlock;
  end;
end;

function TClientTaskList.FGetItem(Index: integer): TClientTask;
begin
  Result := inherited GetItem(index) as TClientTask;
end;

procedure TClientTaskList.Lock;
begin
  EnterCriticalSection(FCriSection);
end;

procedure TClientTaskList.Unlock;
begin
  LeaveCriticalSection(FCriSection);
end;

procedure TClientTaskList.CloseClients;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[i].CloseMe;
  end;
end;

procedure TClientTaskList.WaitForAll;
var
  i: integer;
begin
  for i := Count - 1 downto 0 do
  begin
    Items[i].WaitFor;
  end;
end;

// ------------------------- TSimpServerTCP --------------------------------
constructor TSimpServerTCP.Create(aClientTaskClass: TClientTaskClass);
begin
  inherited Create(true);
  FClientTaskClass := aClientTaskClass;
  FClientTaskList := TClientTaskList.Create;
  FSimpTcp := TSimpTcp.Create;
  mHandleTab[HPOS_EVENT] := CreateEvent(nil, false, true, nil);
  mHandleTab[HPOS_SOCKET] := WSACreateEvent;
  mTickPeriod := 1000;
  mListening := false;
  mFlStopListen := false;
  mFlStartListen := false;
  Resume;
end;

destructor TSimpServerTCP.Destroy;
begin
  if Suspended = false then
  begin
    Terminate;
    setMyEvent;
    WaitFor;
  end;
  FClientTaskList.Free;
  FSimpTcp.Free;
  CloseHandle(mHandleTab[HPOS_EVENT]);
  inherited;
end;

procedure TSimpServerTCP.setMyEvent;
begin
  SetEvent(mHandleTab[HPOS_EVENT]);
end;

procedure TSimpServerTCP._doLoopTick;
begin

end;

procedure TSimpServerTCP._doDisConnect;
begin

end;

procedure TSimpServerTCP._doStartListen;
begin

end;

procedure TSimpServerTCP._doAccept;
var
  AddrIn: TSockAddrIn;
  Addr_len: integer;
  NewSd: TSocket;
  RecIp: string;
  RecPort: word;
  NewTask: TClientTask;
begin
  NewSd := accept(FSimpTcp.Sd, @AddrIn, @Addr_len);
  RecIp := inet_ntoa(AddrIn.sin_addr);
  RecPort := HToNs(AddrIn.sin_port);
  NewTask := FClientTaskClass.Create(self);
  NewTask.Start(NewSd, RecIp, RecPort);
end;

procedure TSimpServerTCP.Execute;
var
  waitRes: DWORD;
  st: integer;
  Addr: TSockAddr;
begin
  mListening := false;
  while not(Terminated) do
  begin
    if mListening = false then
    begin
      waitRes := WaitForSingleObject(mHandleTab[HPOS_EVENT], mTickPeriod);
      if waitRes = STATUS_TIMEOUT then
      begin
        _doLoopTick;
      end
      else
      begin
        if mFlStartListen then
        begin
          mFlStartListen := false;
          st := FSimpTcp.Open;
          if st = stOk then
          begin
            st := WSAEventSelect(FSimpTcp.Sd, mHandleTab[HPOS_SOCKET], FD_ACCEPT or FD_READ or FD_CLOSE);
            if st <> SOCKET_ERROR then
            begin
              Addr.sa_family := AF_INET;
              sockaddr_in(Addr).sin_port := HToNs(mPort);
              sockaddr_in(Addr).sin_addr.S_addr := 0;
              st := bind(FSimpTcp.Sd, Addr, SizeOf(Addr));
              if st <> SOCKET_ERROR then
              begin
                st := listen(FSimpTcp.Sd, 100);
                if st <> SOCKET_ERROR then; // SOMAXCONN);
                mListening := true;
              end;
            end;
          end;
        end;
      end;
    end
    else
    begin
      waitRes := WaitForMultipleObjects(2, @mHandleTab, false, mTickPeriod);
      if waitRes = STATUS_TIMEOUT then
      begin
        _doLoopTick;
      end
      else if waitRes = STATUS_WAIT_0 + HPOS_SOCKET then
      begin
        // Socket Events
        if WSAENUMNetworkEvents(FSimpTcp.Sd, mHandleTab[HPOS_SOCKET], m_tpEvent) <> SOCKET_ERROR then
        begin
          if m_tpEvent.lNetworkEvents = FD_ACCEPT then
          begin
            _doAccept;
          end
          else if m_tpEvent.lNetworkEvents = FD_READ then
          begin
            FSimpTcp.DoOnMsgRead;
          end
          else if m_tpEvent.lNetworkEvents = FD_CLOSE then
          begin
            _doDisConnect;
          end;
        end;
      end
      else if waitRes = STATUS_WAIT_0 + HPOS_EVENT then
      begin
        if mFlStopListen then
        begin
          mFlStopListen := false;
          FSimpTcp.Close;
          mListening := false;
        end;
      end;
    end;
  end;
end;

procedure TSimpServerTCP.Startlisten(Port: word);
begin
  mPort := Port;
  mFlStartListen := true;
  setMyEvent;
end;

procedure TSimpServerTCP.StopListen;
begin
  mFlStopListen := true;
  setMyEvent;
end;

function TSimpServerTCP.GetClientsCnt: integer;
begin
  Result := FClientTaskList.Count;
end;

function TSimpServerTCP.isListening: boolean;
begin
  Result := mListening;
end;

// ---------------------------------------------------------------------------
// ASYNCH                                                              .
// ---------------------------------------------------------------------------

// ------------------------- TAsynchClient --------------------------------
constructor TAsynchClient.Create(aOwner: TAsynchServerTCP);
begin
  inherited Create;
  FOwner := aOwner;
end;

destructor TAsynchClient.Destroy;
begin
  FOwner.FClientList.Extract(self);
  inherited;
end;

procedure TAsynchClient.DoCloseMe;
begin
  PostMessage(FOwner.GetHandle, wm_CloseClient, integer(self), 0);
end;

procedure TAsynchClient.DoOnClose;
begin
  inherited;
  DoCloseMe;
end;

procedure TAsynchClient.Start(aSd: TSocket; RecIp: string; RecPort: word);
begin
  Sd := aSd;
  IP := RecIp;
  Port := RecPort;
  Async := true;
  DoOnStart;
end;

procedure TAsynchClient.DoOnStart;
begin

end;

// ------------------------- TAsynchClientList --------------------------------
function TAsynchClientList.FGetItem(Index: integer): TAsynchClient;
begin
  Result := inherited GetItem(index) as TAsynchClient;
end;

procedure TAsynchClientList.Add(task: TAsynchClient);
begin
  inherited Add(task);
end;

// ------------------------- TAsynchServerTCP --------------------------------
constructor TAsynchServerTCP.Create(aAsynchClientClass: TAsynchClientClass);
begin
  inherited Create;
  FClientList := TAsynchClientList.Create;
  FClientClass := aAsynchClientClass;
  mListening := false;
end;

destructor TAsynchServerTCP.Destroy;
begin
  FClientList.Free;
  inherited;
end;

function TAsynchServerTCP.FGetItem(Index: integer): TAsynchClient;
begin
  Result := FClientList.Items[Index];
end;

procedure TAsynchServerTCP.wmCloseClient(var AMessage: TMessage);
var
  Kli: TAsynchClient;
  n: integer;
begin
  Kli := TAsynchClient(AMessage.WParam);
  n := FClientList.IndexOf(Kli);
  if n >= 0 then
  begin
    try
      FClientList.Delete(n);
    except
      raise Exception.Create('*Destroy* Port=' + IntToStr(self.Port) + '  ' + (ExceptObject as Exception).Message);
    end;
  end;
end;

function TAsynchServerTCP.Count: integer;
begin
  Result := FClientList.Count;
end;

function TAsynchServerTCP.IndexOf(Ob: TObject): integer;
begin
  Result := FClientList.IndexOf(Ob);
end;

function TAsynchServerTCP.Open: TStatus;
var
  Size: integer;
begin
  Result := inherited Open;
  if Result = stOk then
  begin
    Size := $80000;
    Result := setsockopt(Sd, SOL_SOCKET, SO_RCVBUF, PAnsiChar(@Size), SizeOf(Size));
  end;
end;

procedure TAsynchServerTCP.DoOnAccept;
var
  NewSd: TSocket;
  AddrIn: TSockAddrIn;
  Addr_len: integer;
  RecIp: string;
  RecPort: word;
  ClientTask: TAsynchClient;
begin
  while true do
  begin
    try
      Addr_len := SizeOf(AddrIn);
      NewSd := accept(Sd, @AddrIn, @Addr_len);
      if NewSd <> INVALID_SOCKET then
      begin
        RecIp := inet_ntoa(AddrIn.sin_addr);
        RecPort := HToNs(AddrIn.sin_port);

        ClientTask := FClientClass.Create(self);
        FClientList.Add(ClientTask);
        ClientTask.Start(NewSd, RecIp, RecPort);
        FLastErr := stOk;
      end
      else
      begin
        FLastErr := WSAGetLastError;
        break;
      end;
    except
      break;
    end;
  end;
end;

function TAsynchServerTCP.Startlisten(aPort: word): integer;
var
  st: integer;
  Addr: TSockAddr;
begin
  Port := aPort;
  FNonBlkMode := true;
  st := Open;
  if st = stOk then
  begin
    Addr.sa_family := AF_INET;
    sockaddr_in(Addr).sin_port := HToNs(Port);
    sockaddr_in(Addr).sin_addr.S_addr := 0;
    st := bind(Sd, Addr, SizeOf(Addr));
    if st = stOk then
    begin
      FWsaEvents := FWsaEvents + [wsaACCEPT];
      Async := true;
      st := listen(Sd, 100); // SOMAXCONN);
      mListening := (st = stOk);
    end
    else
    begin
      st := WSAGetLastError;
    end;
  end;
  Result := st;
end;

procedure TAsynchServerTCP.StopListen;
begin
  CloseSocket(Sd);
  FClientList.Clear;
  mListening := false;
end;

// ------------------------- TTcpTread ---------------------------------------

constructor TTcpThread.Create(CreateSuspended: boolean);
begin
  inherited Create(true);
  FSimpTcp := TSimpTcp.Create;
  FSimpTcp.OnMsgRead := OnMsgReadProc;
  mHandleTab[HPOS_EVENT] := CreateEvent(nil, false, true, nil);
  mHandleTab[HPOS_SOCKET] := WSACreateEvent;
  mTickPeriod := 1000;
  if not(CreateSuspended) then
    Resume;
end;

destructor TTcpThread.Destroy;
begin
  Terminate;
  WaitFor;
  FSimpTcp.Free;
  CloseHandle(mHandleTab[HPOS_EVENT]);
  inherited;
end;

procedure TTcpThread.OnMsgReadProc(Sender: TObject);
Var
  txt: string;
begin
  if FSimpTcp.ReadStr(txt) = stOk then
    _doOnRead(txt);
end;

function TTcpThread.getRecFrameCnt: integer;
begin
  Result := FSimpTcp.OnMsgReadCnt;
end;

procedure TTcpThread.setFrameCnt(n: integer);
begin
  FSimpTcp.OnMsgReadCnt := 0;
end;

procedure TTcpThread.SetAlgZtrZ(aAlg: boolean);
begin
  FSimpTcp.SetAlgZtrZ(aAlg);
end;

procedure TTcpThread.Execute;
var
  waitRes: DWORD;
begin
  while not(Terminated) do
  begin
    waitRes := WaitForMultipleObjects(2, @mHandleTab, false, mTickPeriod);
    if waitRes = STATUS_TIMEOUT then
    begin
      _doLoopTick;
    end
    else if waitRes = STATUS_WAIT_0 + HPOS_SOCKET then
    begin
      // Socket Events
      if WSAENUMNetworkEvents(FSimpTcp.Sd, mHandleTab[HPOS_SOCKET], m_tpEvent) <> SOCKET_ERROR then
      begin
        if m_tpEvent.lNetworkEvents = FD_READ then
        begin
          FSimpTcp.DoOnMsgRead;
        end
        else if m_tpEvent.lNetworkEvents = FD_CLOSE then
        begin
          _DisConnect;
        end;
      end;
    end
    else if waitRes = STATUS_WAIT_0 + HPOS_EVENT then
    begin
      _doOnUserEvent;
    end;
  end;
end;

procedure TTcpThread._Connect;
begin
  FSimpTcp.Open;
  FSimpTcp.Connect;
  if FSimpTcp.IsConnected then
  begin
    WSAEventSelect(FSimpTcp.Sd, mHandleTab[HPOS_SOCKET], FD_READ OR FD_CLOSE);
  end;
end;

procedure TTcpThread._DisConnect;
begin
  if cardinal(FSimpTcp.Sd) <> INVALID_SOCKET then
    WSAEventSelect(FSimpTcp.Sd, mHandleTab[HPOS_SOCKET], 0);
  FSimpTcp.Close;
end;

procedure TTcpThread._SendCmd(s: string);
begin
  FSimpTcp.WriteStr(s);
end;

procedure TTcpThread._doConnect;
begin
  FSimpTcp.Open;
  FSimpTcp.Connect;

  if FSimpTcp.IsConnected then
  begin
    if WSAEventSelect(FSimpTcp.Sd, mHandleTab[HPOS_SOCKET], FD_READ OR FD_CLOSE) <> SOCKET_ERROR then
    begin

    end;
  end;
end;

procedure TTcpThread._doLoopTick;
begin

end;

procedure TTcpThread._doOnRead(txt: string);
begin

end;

procedure TTcpThread._doOnUserEvent;
begin

end;

// wywo³ywane z g³ównego w¹tku i Threada
function TTcpThread.IsConnected: boolean;
begin
  Result := FSimpTcp.IsConnected;
end;

procedure TTcpThread.SetServerAddr(IP: string; Port: word);
begin
  FSimpTcp.IP := IP;
  FSimpTcp.Port := Port;
end;

procedure TTcpThread.PostThreadMsg(msg: integer);
begin
  PostThreadMessage(ThreadID, msg, 0, 0);
  SetEvent(mHandleTab[HPOS_EVENT]);
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
