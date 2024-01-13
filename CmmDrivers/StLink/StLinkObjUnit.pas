unit StLinkObjUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Math,
  System.AnsiStrings,
  System.Contnrs,
  System.JSON,
  StLinkDriver,
  LibUtils,
  JsonUtils,
  SttObjectDefUnit,
  CallProcessUnit,
  Registry,
  Rsd64Definitions,
  ErrorDefUnit;

const
  DRIVER_NAME = 'STLINK';

  OPEN_RUNSTLINK = 'RunStLink';
  OPEN_PERSISTANT = 'PersistantMode';
  OPEN_STLINKPATH = 'StLinkPath';
  OPEN_LOGINGENAB = 'EnabLeLog';
  OPEN_LOGINGPATH = 'LogPath';
  OPEN_VERBOSEMODE = 'Verbose';
  OPEN_VERBOSCALLERMODE = 'ThreadVerbose';
  OPEN_SWDMODE = 'SwdMode';
  OPEN_PATHTOPROGR = 'PathProgrammer';

type

  TAnsiChars = array of AnsiChar;
  PByteAr = ^TByteAr;
  TByteAr = array [0 .. 240 - 1 + 40] of byte;
  TTabBit = array [0 .. 32768] of boolean;
  TTabByte = array [0 .. 32768] of byte;
  TTabWord = array [0 .. 32768] of word;

  TDevItem = class;

  TTerminalThread = class(TThread)
  private
    FOwner: TDevItem;
    FEventHandle: THandle;
    function ExecuteRunState: TStatus;
    function isRun: boolean;
    function ReadOutLogger(vec: cardinal; var Buffer: TAnsiChars): TStatus;
  protected
    procedure Execute; override;
  public
    FRunFlag: boolean;
    FOutPipe: THandle;
    constructor Create(aOwner: TDevItem);
    destructor Destroy; override;
    procedure SetRunFlag(q: boolean);
    procedure Terminate;
  end;

  TDevItem = class(TObject)
  public type
    TOpenParams = record
      IP: string;
      Port: word;
      RunStLink: boolean;
      PersistantMode: boolean;
      StLinkPath: string;
      EnabLeLog: boolean;
      LogPath: string;
      Verbose: boolean;
      CallerVerbose: boolean;
      SwdMode: boolean;
      PathProgrammer: string;
      LoggerStartAddr: cardinal;
      procedure InitDefault;
      procedure SaveToDefault;
    end;

    TTerminalData = record
      PipeHandle: THandle;
      RunFlag: boolean;
      Thread: TTerminalThread;
    end;

  private
    AccId: integer;
    FOpenParams: TOpenParams;
    StLinkDrv: TStLinkDrv;

    FCountDivide: integer;
    DriverMode: string;

    FTermial: TTerminalData;

    FCallBackFunc: TCallBackFunc;
    FCmmId: integer;

    FBreakFlag: boolean;

    LastFinished: cardinal;
    FrameCnt: integer;
    FrameRepCnt: integer;
    WaitCnt: integer; // licznik wymuszonych przerw
    SumRecTime: integer;
    SumSendTime: integer;

    TerminalReadTime: integer;
    FClr_ToRdCnt: boolean; // odbiór ramki az do przerwy
    FStLinkThread: TThread;

    FLoggerFnd: boolean;
    FLoggerAddr: cardinal;

    procedure FindLoggerVector;

  protected
    procedure CallBackFunct(Ev: integer; R: real);
    procedure SetProgress(F: real); overload;
    procedure SetProgress(Cnt, Max: integer); overload;
    procedure MsgFlowSize(R: real);
    procedure SetWorkFlag(w: boolean);

  public
    constructor Create(AId: TAccId; OpenParams: TOpenParams);
    destructor Destroy; override;

    function Open: TStatus;
    procedure Close;
    function isOpen: boolean;
    function SetBreakFlag(Val: boolean): TStatus;

    function GetDrvInfo: String;
    function GetDrvParams: String;
    function SetDrvParams(const jsonParams: string): TStatus;

    procedure RegisterCallBackFun(ACallBackFunc: TCallBackFunc; CmmId: integer);
    // odczyt, zapis pamiêci
    function RdMemory(var Buf; Adress: cardinal; Count: cardinal): TStatus;
    function WrMemory(const Buf; Adress: cardinal; Count: cardinal): TStatus;

    // obsluga terminala
    function TerminalSendKey(key: AnsiChar): TStatus;
    function TerminalSetPipe(TerminalNr: integer; PipeHandle: THandle): TStatus;
    function TerminalSetRunFlag(TerminalNr: integer; RunFlag: boolean): TStatus;
  end;

  TDevList = class(TObjectList)
  private
    FCurrId: TAccId;
    FCriSection: TRTLCriticalSection;
    function GetId: TAccId;
  public
    constructor Create;
    destructor Destroy; override;
    function AddDevice(ConnectStr: PAnsiChar): TAccId;
    function DelDevice(AccId: TAccId): TStatus;
    function FindId(AccId: TAccId): TDevItem;
  end;

var
  GlobDevList: TDevList;

implementation

const
  REG_KEY = '\SOFTWARE\GEKA\STLINK_DRV';

function LastErr: Shortstring;
begin
  Result := AnsiString(IntToStr(GetLastError));
end;

// ---------------------  TTerminalThread ---------------------------
type

  LoggerBufferData_t = packed record
    Buffer: cardinal; // adres of buffer
    flags: word;
    BufferSize: word;
    HeadPtr: word;
    TailPtr: word;
  end;

  LoggerRec_t = packed record
    DefIdx: integer;
    OutBuf: LoggerBufferData_t;
    InpBuf: LoggerBufferData_t;
  end;

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

function TTerminalThread.isRun: boolean;
begin
  Result := FRunFlag and (FOutPipe <> INVALID_HANDLE_VALUE) and FOwner.isOpen;
end;

procedure TTerminalThread.Execute;
var
  st: TStatus;
begin
  Logger(1, '\wTerminalThread Start' + #10);
  while not(Terminated) do
  begin
    WaitForSingleObject(FEventHandle, 1000);
    if isRun then
    begin
      if FOwner.FLoggerFnd then
      begin
        st := ExecuteRunState;
        if st <> stOK then
          Logger(1, '\eTerminalThread Error' + #10);
      end
      else
      begin
        Logger(1, '\eTerminal struct not found' + #10);
      end;
    end;
  end;
  Logger(1, '\wTerminalThread Exit' + #10);
end;

function TTerminalThread.ReadOutLogger(vec: cardinal; var Buffer: TAnsiChars): TStatus;
var
  LoggerRec: LoggerRec_t;
  head: integer;
  tail: integer;
  size: integer;
  Cnt, cnt1: integer;
  bufAddr: cardinal;
  w: word;
  ofs1: integer;

begin
  Result := FOwner.RdMemory(LoggerRec, vec, sizeof(LoggerRec));
  if Result = stOK then
  begin
    head := LoggerRec.OutBuf.HeadPtr;
    tail := LoggerRec.OutBuf.TailPtr;
    size := LoggerRec.OutBuf.BufferSize;
    bufAddr := LoggerRec.OutBuf.Buffer;
    if head <> tail then
    begin
      if head > tail then
      begin
        Cnt := head - tail;
        setLength(Buffer, Cnt);
        Result := FOwner.RdMemory(Buffer[0], bufAddr + tail, Cnt);
      end
      else
      begin
        cnt1 := size - tail;
        Cnt := cnt1 + head;
        setLength(Buffer, Cnt);
        Result := FOwner.RdMemory(Buffer[0], bufAddr + tail, cnt1);
        if Result = stOK then
          Result := FOwner.RdMemory(Buffer[cnt1], bufAddr, Cnt - cnt1);
      end;
      if Result = stOK then
      begin
        w := word(head);
        ofs1 := integer(@LoggerRec.OutBuf.TailPtr) - integer(@LoggerRec);
        Result := FOwner.WrMemory(w, vec + ofs1, 2);
      end;
      // Logger(1, Format('LoggerRec: %u-%u %u', [LoggerRec.OutBuf.HeadPtr, LoggerRec.OutBuf.TailPtr, Cnt]) + #10);
    end
    else
      setLength(Buffer, 0);
  end;
  if Result <> stOK then
    setLength(Buffer, 0);
end;

function TTerminalThread.ExecuteRunState: TStatus;
var
  Buffer: TAnsiChars;
  WideCh: array of Char;
  rdcnt: integer;
  st: TStatus;
  BytesWritten: cardinal;
  i: integer;
begin
  while not(Terminated) and isRun do
  begin
    st := ReadOutLogger(FOwner.FLoggerAddr, Buffer);
    rdcnt := length(Buffer);
    //Logger(1, Format('terminal rd=%u', [rdcnt]) + #10);

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
  end;
  Result := stOK;
end;

procedure TTerminalThread.SetRunFlag(q: boolean);
begin
  FRunFlag := q;
  SetEvent(FEventHandle);
end;

procedure TTerminalThread.Terminate;
begin
  inherited;
  SetEvent(FEventHandle);
end;

// ---------------------  TDevItem ---------------------------
constructor TDevItem.Create(AId: TAccId; OpenParams: TOpenParams);
var
  i: integer;
begin
  inherited Create;
  AccId := AId;
  FOpenParams := OpenParams;

  FClr_ToRdCnt := false;
  TerminalReadTime := 500;

  LastFinished := GetTickCount;

  StLinkDrv := TStLinkDrv.Create;

  FTermial.PipeHandle := INVALID_HANDLE_VALUE;
  FTermial.RunFlag := false;
  FTermial.Thread := TTerminalThread.Create(self);
end;

destructor TDevItem.Destroy;
var
  i: integer;
begin
  inherited Destroy;
  StLinkDrv.Free;

  FTermial.Thread.Terminate;
  FTermial.Thread.SetRunFlag(false);
  FTermial.Thread.WaitFor;
  FTermial.Thread.Free;
end;

function TDevItem.Open: TStatus;
var
  Param: string;
  SendGo: boolean;
begin
  SendGo := false;
  FrameRepCnt := 0;
  FrameCnt := 0;
  WaitCnt := 0;
  SumRecTime := 0;
  SumSendTime := 0;
  if FOpenParams.RunStLink then
  begin
    Param := '-p ' + IntToStr(FOpenParams.Port);
    if FOpenParams.Verbose then
      Param := Param + ' -v';
    if FOpenParams.PersistantMode then
      Param := Param + ' -e';
    if FOpenParams.SwdMode then
      Param := Param + ' -d';
    Param := Param + ' -cp ' + FOpenParams.PathProgrammer;
    // C:\ST\STM32CubeIDE_1.11.2\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.cubeprogrammer.win32_2.0.500.202209151145\tools\bin

    FStLinkThread := CallHideProcess(AnsiChar_LoggerHandle, FOpenParams.StLinkPath, Param, WorkingPath,
      FOpenParams.CallerVerbose, false);

    sleep(200);
    SendGo := true
  end;

  Result := StLinkDrv.Open(FOpenParams.IP, FOpenParams.Port);
  if Result = stOK then
  begin
    FOpenParams.SaveToDefault;
    FindLoggerVector;
    if SendGo then
      StLinkDrv.RCommand_Continue;

  end;

end;

procedure TDevItem.Close;
begin
  StLinkDrv.Close;
  if Assigned(FStLinkThread) then
  begin
    StopHideProcess(FStLinkThread);
    FStLinkThread := nil;
  end;
end;

function TDevItem.isOpen: boolean;
begin
  Result := StLinkDrv.isOpen;
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

function TDevItem.SetBreakFlag(Val: boolean): TStatus;
begin
  FBreakFlag := Val;
  Result := stOK;
end;

procedure TDevItem.FindLoggerVector;
const
  LoggerSign: AnsiString = 'GEKA-LOGGER-';
  LoggerAllign = 16;

  function CompareSign(Buf: TAnsiChars; Ofs: cardinal): boolean;
  var
    i, n: integer;
  begin
    Result := true;
    n := length(LoggerSign);
    for i := 0 to n - 1 do
    begin
      if LoggerSign[i + 1] <> Buf[Ofs + i] then
      begin
        Result := false;
        break;
      end;
    end;
  end;

const
  LOGGER_VIEW_SIZE = 2048;
var
  Buffer: TAnsiChars;
  i, n: integer;
  st: TStatus;
begin
  FLoggerFnd := false;
  FLoggerAddr := 0;

  setLength(Buffer, LOGGER_VIEW_SIZE);

  st := RdMemory(Buffer[0], FOpenParams.LoggerStartAddr, LOGGER_VIEW_SIZE);
  if st = stOK then
  begin
    n := length(Buffer) div LoggerAllign;
    for i := 0 to n - 1 do
    begin
      if CompareSign(Buffer, LoggerAllign * i) then
      begin
        FLoggerFnd := true;
        FLoggerAddr := GetDWord(Buffer[LoggerAllign * i + 12]);
        break;
      end;
    end;
  end;
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

function TDevItem.GetDrvParams: String;

var
  jBuild: TJSONBuilder;
  vBuild: TJSONBuilder;
  p: TSttObjectListJson;
  sttObj: TSttObjectJson;
begin
  jBuild.Init;
  // description section
  p := TSttObjectListJson.Create;
  try
    sttObj := TSttIntObjectJson.Create(PAR_ITEM_DIVIDE_LEN, 'Read/write memory divide bloks', 128, 4096, 4096);
    sttObj.SetUniBool(true);
    // UniBool=true - allow change during open connection
    p.Add(sttObj);
    sttObj := TSttSelectObjectJson.Create(PAR_ITEM_DRIVER_MODE, 'Driver work mode', DriverModeName, 'STD');
    sttObj.SetUniBool(false);
    p.Add(sttObj);
    jBuild.Add(DRVPRAM_DEFINITION, p.getJSonObject);
  finally
    p.Free;
  end;

  // value section
  vBuild.Init;
  vBuild.Add(PAR_ITEM_DIVIDE_LEN, FCountDivide);
  vBuild.Add(PAR_ITEM_DRIVER_MODE, DriverMode);
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
    DriverMode := vTxt
  else
    Result := stBadArguments;
end;

procedure TDevItem.RegisterCallBackFun(ACallBackFunc: TCallBackFunc; CmmId: integer);
begin
  FCallBackFunc := ACallBackFunc;
  FCmmId := CmmId;
end;


// -----------------------------------------------------

{$Q-}

function TDevItem.RdMemory(var Buf; Adress: cardinal; Count: cardinal): TStatus;
var
  bBuf: TBytes;
  p: pByte;
  SCnt: cardinal;
  cnt1: cardinal;
begin
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  Result := stOK;
  p := pByte(@Buf);
  SCnt := 0;
  while SCnt < Count do
  begin
    cnt1 := Count - SCnt;
    if cnt1 > cardinal(FCountDivide) then
      cnt1 := FCountDivide;
    Result := StLinkDrv.ReadMem(Adress, cnt1, bBuf);
    if Result <> stOK then
      break;
    move(bBuf[0], p^, cnt1);

    inc(Adress, cnt1);
    inc(SCnt, cnt1);
    SetProgress(SCnt, Count);
    MsgFlowSize(SCnt);
  end;

  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
end;
{$Q+}
{$Q-}

function TDevItem.WrMemory(const Buf; Adress: cardinal; Count: cardinal): TStatus;
var
  bBuf: TBytes;
  p: pByte;
  SCnt: cardinal;
  cnt1: cardinal;
begin
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  Result := stOK;
  p := pByte(@Buf);
  SCnt := 0;
  while SCnt < Count do
  begin
    cnt1 := Count - SCnt;
    if cnt1 > cardinal(FCountDivide) then
      cnt1 := FCountDivide;
    setLength(bBuf, cnt1);
    move(p^, bBuf[0], cnt1);

    Result := StLinkDrv.WriteMem(Adress, bBuf);
    if Result <> stOK then
      break;

    inc(Adress, cnt1);
    inc(SCnt, cnt1);
    SetProgress(SCnt, Count);
    MsgFlowSize(SCnt);
  end;

  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
end;
{$Q+}

function TDevItem.TerminalSendKey(key: AnsiChar): TStatus;
var
  LoggerRec: LoggerRec_t;
  head: integer;
  head1: integer;
  tail: integer;
  size: integer;
  Cnt, cnt1: integer;
  bufAddr: cardinal;
  w: word;
  ofs1: integer;

begin
  if FLoggerFnd then
  begin
    Result := RdMemory(LoggerRec, FLoggerAddr, sizeof(LoggerRec));
    if Result = stOK then
    begin
      //Logger(1, Format('LoggerRec: %u-%u', [LoggerRec.InpBuf.HeadPtr, LoggerRec.InpBuf.TailPtr]) + #10);
      head := LoggerRec.InpBuf.HeadPtr;
      tail := LoggerRec.InpBuf.TailPtr;
      size := LoggerRec.InpBuf.BufferSize;
      bufAddr := LoggerRec.InpBuf.Buffer;
      head1 := head + 1;
      if head1 = size then
        head1 := 0;
      if head1 <> tail then
      begin
        Result := WrMemory(key, bufAddr + head, 1);
        if Result = stOK then
        begin
          // zapis do LoggerRec.InpBuf.HeadPtr
          w := head1;
          ofs1 := integer(@LoggerRec.InpBuf.HeadPtr) - integer(@LoggerRec);
          Result := WrMemory(w, FLoggerAddr + ofs1, 2);
        end;
      end;
    end;
    if Result = stOK then
      SetEvent(FTermial.Thread.FEventHandle);
  end
  else
    Result := stNoLogger;

end;

function TDevItem.TerminalSetPipe(TerminalNr: integer; PipeHandle: THandle): TStatus;
begin
  FTermial.PipeHandle := PipeHandle;
  FTermial.RunFlag := false;
  FTermial.Thread.FOutPipe := PipeHandle;
  Result := stOK;
end;

function TDevItem.TerminalSetRunFlag(TerminalNr: integer; RunFlag: boolean): TStatus;
begin
  FTermial.RunFlag := RunFlag;
  FTermial.Thread.SetRunFlag(RunFlag);
  Result := stOK;
end;

procedure TDevItem.TOpenParams.InitDefault;
var
  Reg: TRegistry;
begin
  IP := '127.0.0.1';
  Port := 50001;
  RunStLink := true;
  PersistantMode := true;
  StLinkPath := '';
  EnabLeLog := false;
  LogPath := '';
  Verbose := false;
  SwdMode := true;
  LoggerStartAddr := $8000000;

  Reg := TRegistry.Create;
  try
    if Reg.OpenKeyReadOnly(REG_KEY) then
    begin
      if Reg.ValueExists('StLinkPath') then
        StLinkPath := Reg.ReadString('StLinkPath');

      if Reg.ValueExists('PathProgrammer') then
        PathProgrammer := Reg.ReadString('PathProgrammer');
    end;
  finally
    Reg.Free;
  end;
end;

procedure TDevItem.TOpenParams.SaveToDefault;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if Reg.OpenKey(REG_KEY, true) then
    begin
      Reg.WriteString('StLinkPath', StLinkPath);
      Reg.WriteString('PathProgrammer', PathProgrammer);
    end;
  finally
    Reg.Free;
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

function TDevList.GetId: TAccId;
begin
  Result := FCurrId;
  inc(FCurrId);
end;

// ConnectStr - JSON format

function TDevList.AddDevice(ConnectStr: PAnsiChar): TAccId;
var
  jLoader: TJsonLoader;
  jParams: TJsonLoader;
  OpenParams: TDevItem.TOpenParams;
  DevItem: TDevItem;
  q: boolean;
  v: integer;
begin
  Result := -1;
  try
    OpenParams.InitDefault;;
    q := false;
    if jLoader.Init(String(ConnectStr)) then
    begin
      if jParams.Init(jLoader, CONNECTION_PARAMS_NAME) then
      begin
        q := jParams.Load(IPPARAM_IP, OpenParams.IP);
        q := q and jParams.Load(IPPARAM_PORT, v);
        OpenParams.Port := v;
        jParams.Load(OPEN_RUNSTLINK, OpenParams.RunStLink);
        jParams.Load(OPEN_PERSISTANT, OpenParams.PersistantMode);
        jParams.Load(OPEN_STLINKPATH, OpenParams.StLinkPath);
        jParams.Load(OPEN_LOGINGENAB, OpenParams.EnabLeLog);
        jParams.Load(OPEN_LOGINGPATH, OpenParams.LogPath);
        jParams.Load(OPEN_VERBOSEMODE, OpenParams.Verbose);
        jParams.Load(OPEN_VERBOSCALLERMODE, OpenParams.CallerVerbose);
        jParams.Load(OPEN_SWDMODE, OpenParams.SwdMode);
        jParams.Load(OPEN_PATHTOPROGR, OpenParams.PathProgrammer);

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
begin
  Result := stBadId;
  try
    EnterCriticalSection(FCriSection);
    for i := 0 to Count - 1 do
    begin
      t := Items[i] as TDevItem;
      if t.AccId = AccId then
      begin
        t.Close;
        Delete(i);
        Result := stOK;
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

initialization

GlobDevList := TDevList.Create;

finalization

GlobDevList.Free;

end.
