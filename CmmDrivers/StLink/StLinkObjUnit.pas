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
  TERMINAL_CNT = 1;

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

    FTermialTab: array [0 .. TERMINAL_CNT - 1] of TTerminalData;

    FCallBackFunc: TCallBackFunc;
    FCmmId: integer;

    FBreakFlag: boolean;
    ErrStr: Shortstring;

    LastFinished: cardinal;
    FrameCnt: integer;
    FrameRepCnt: integer;
    WaitCnt: integer; // licznik wymuszonych przerw
    SumRecTime: integer;
    SumSendTime: integer;

    FAskNumber: word;
    TerminalReadTime: integer;
    FClr_ToRdCnt: boolean; // odbiór ramki az do przerwy
    FStLinkThread: TThread;


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
    function TerminalRead(Buf: PAnsiChar; var rdcnt: integer): TStatus;
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
  FOpenParams := OpenParams;

  FClr_ToRdCnt := false;
  TerminalReadTime := 100;

  LastFinished := GetTickCount;

  StLinkDrv := TStLinkDrv.Create;

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
  StLinkDrv.Free;

  for i := 0 to TERMINAL_CNT - 1 do
  begin
    FTermialTab[i].Thread.Terminate;
    FTermialTab[i].Thread.SetRunFlag(false);
    FTermialTab[i].Thread.WaitFor;
    FTermialTab[i].Thread.Free;
  end;
end;

function TDevItem.Open: TStatus;
var
  Param: string;
begin
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
  end;

  Result := StLinkDrv.Open(FOpenParams.IP, FOpenParams.Port);
  if Result = stOK then
    FOpenParams.SaveToDefault;
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
  Cnt1: cardinal;
begin
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  p := pByte(@Buf);
  SCnt := 0;
  while SCnt < Count do
  begin
    Cnt1 := Count - SCnt;
    if Cnt1 > FCountDivide then
      Cnt1 := FCountDivide;
    Result := StLinkDrv.ReadMem(Adress, Cnt1, bBuf);
    if Result <> stOK then
      break;
    move(bBuf[0], p^, Cnt1);

    inc(Adress, Cnt1);
    inc(SCnt, Cnt1);
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
  Cnt1: cardinal;
begin
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  p := pByte(@Buf);
  SCnt := 0;
  while SCnt < Count do
  begin
    Cnt1 := Count - SCnt;
    if Cnt1 > FCountDivide then
      Cnt1 := FCountDivide;
    setLength(bBuf, Cnt1);
    move(p^, bBuf[0], Cnt1);

    Result := StLinkDrv.WriteMem(Adress, bBuf);
    if Result <> stOK then
      break;

    inc(Adress, Cnt1);
    inc(SCnt, Cnt1);
    SetProgress(SCnt, Count);
    MsgFlowSize(SCnt);
  end;

  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
end;
{$Q+}

function TDevItem.TerminalSendKey(key: AnsiChar): TStatus;
begin

end;

function TDevItem.TerminalRead(Buf: PAnsiChar; var rdcnt: integer): TStatus;
begin

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
