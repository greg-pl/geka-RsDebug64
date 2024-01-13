unit CallProcessUnit;

interface

uses
  SysUtils, Classes, Windows,
  System.Contnrs,
  Forms,
  Messages;

function CallHideProcess(OutMsgHandle: THandle; App, Param, WorkDir: string; Say, AddExitMsg: boolean): TThread;
function StopHideProcess(ProcessThread: TThread): boolean;

function ExecBatchFile(BatFileName, WorkDir: string): Cardinal;

const
  RD_BUFFER_LEN = 2000;
  END_OF_PROCESS_TXT = '&&&__END_LINE__&&&';

type
  TRdBuffer = array [0 .. RD_BUFFER_LEN - 1] of char;

  TPipeToStrings = class(TObject)
  private
    CriSection: TRTLCriticalSection;
    FOwnerHandle: THandle;
    wm_FMsgId: integer;
    FBuildStr: string;
    PipeRider: TThread;
    FPipeIn: THandle;
    FEndLiineFnd: boolean;
    SL: TStringList;
    procedure Lock;
    procedure Unlock;
    procedure AddToSL(s: string); overload;
    procedure AddToSL(const Buf: TRdBuffer; Len: integer); overload;

  public
    constructor Create(isAnsiChar: boolean);
    destructor Destroy; override;
    procedure SetAsynch(aOwnerHandle: THandle; MsgId: integer);
    property PipeIn: THandle read FPipeIn;
    function GetSL(FromIdx: integer): TStrings; overload;
    function GetSL: TStrings; overload;
    procedure SaveToFile(FileName: string);
    procedure Clear;
  end;

implementation

type

  TPipeRider = class(TThread)
  private
    FIsAnsiChar: boolean;
    FOwner: TPipeToStrings;
    PipeOut: THandle; // handle do odczytu rurki
    PipeIn: THandle; // handle do zapisu otwartej rurki
    function ReadPipe(var Buf: TRdBuffer): integer;
  public
    constructor Create(aOwner: TPipeToStrings; isAnsiChar: boolean);
    destructor Destroy; override;
    procedure Execute; override;
  end;

constructor TPipeRider.Create(aOwner: TPipeToStrings; isAnsiChar: boolean);
var
  SecurityAttributes: TSecurityAttributes;
begin
  inherited Create(true);
  NameThreadForDebugging('CallProcessUnit-TPipeRider');
  FOwner := aOwner;
  FIsAnsiChar := isAnsiChar;

  FillChar(SecurityAttributes, SizeOf(SecurityAttributes), 0);
  SecurityAttributes.nLength := SizeOf(SecurityAttributes);
  SecurityAttributes.bInheritHandle := true;
  CreatePipe(PipeOut, PipeIn, @SecurityAttributes, 100000);

  Resume;
end;

destructor TPipeRider.Destroy;
begin
  CloseHandle(PipeIn);
  inherited;
end;

function TPipeRider.ReadPipe(var Buf: TRdBuffer): integer;

  function readPipeHd(var Buf; size: integer): integer;
  var
    Overlapped: TOverlapped;
    BytesRead: Cardinal;
    q: boolean;
  begin
    Result := 0;
    FillChar(Overlapped, SizeOf(Overlapped), 0);
    Overlapped.hEvent := CreateEvent(nil, true, true, nil);
    ReadFile(PipeOut, Buf, size, BytesRead, @Overlapped);
    WaitForSingleObject(Overlapped.hEvent, 50);
    q := GetOverlappedResult(PipeOut, Overlapped, BytesRead, false);
    CloseHandle(Overlapped.hEvent);
    if q then
      Result := BytesRead;
  end;

var
  AnsiBuf: array [0 .. RD_BUFFER_LEN - 1] of AnsiChar;
  i: integer;
  N: integer;
begin
  // MainForm.NL_T('ReadPipe_Str');
  Result := 0;
  if not(FIsAnsiChar) then
  begin
    N := readPipeHd(Buf[0], SizeOf(Buf) * SizeOf(char));
    Result := N div SizeOf(char);
  end
  else
  begin
    Result := readPipeHd(AnsiBuf[0], SizeOf(AnsiBuf));
    if Result > 0 then
    begin
      for i := 0 to Result - 1 do
      begin
        Buf[i] := char(AnsiBuf[i]);
      end;
    end;
  end;
  // MainForm.NL_T('ReadPipe_End');
end;

procedure TPipeRider.Execute;
var
  Buf: TRdBuffer;
  N: integer;
begin
  while not(Terminated) do
  begin
    N := ReadPipe(Buf);
    if N > 0 then
    begin
      FOwner.AddToSL(Buf, N);
    end
    else
      sleep(200);
  end;
  CloseHandle(PipeOut);
end;

// ------------------------------------------------------------------------------

constructor TPipeToStrings.Create(isAnsiChar: boolean);
begin
  inherited Create;
  FOwnerHandle := INVALID_HANDLE_VALUE;
  PipeRider := TPipeRider.Create(Self, isAnsiChar);
  FPipeIn := (PipeRider as TPipeRider).PipeIn;
  SL := TStringList.Create;
  InitializeCriticalSection(CriSection);
  Lock;
  FBuildStr := '';
  FEndLiineFnd := false;
  Unlock;
end;

destructor TPipeToStrings.Destroy;
begin
  inherited;
  PipeRider.Terminate;
  PipeRider.Free;
  SL.Free;
  DeleteCriticalSection(CriSection);
end;

procedure TPipeToStrings.SetAsynch(aOwnerHandle: THandle; MsgId: integer);
begin
  FOwnerHandle := aOwnerHandle;
  wm_FMsgId := MsgId;
end;

procedure TPipeToStrings.Lock;
begin
  EnterCriticalSection(CriSection);
end;

procedure TPipeToStrings.Unlock;
begin
  LeaveCriticalSection(CriSection);
end;

procedure TPipeToStrings.Clear;
begin
  Lock;
  try
    SL.Clear;
    FBuildStr := '';
  finally
    Unlock;
  end;

end;

function TPipeToStrings.GetSL(FromIdx: integer): TStrings;
var
  i: integer;
begin
  Result := TStringList.Create;
  Lock;
  try
    for i := FromIdx to SL.Count - 1 do
    begin
      Result.Add(SL.Strings[i]);
    end;
  finally
    Unlock;
  end;
end;

function TPipeToStrings.GetSL: TStrings;
begin
  Result := GetSL(0);
end;

procedure TPipeToStrings.SaveToFile(FileName: string);
begin
  Lock;
  try
    SL.SaveToFile(FileName);
  finally
    Unlock;
  end;
end;

procedure TPipeToStrings.AddToSL(s: string);
begin
  if s = END_OF_PROCESS_TXT then
    FEndLiineFnd := true
  else
  begin
    Lock;
    try
      SL.Add(s);
    finally
      Unlock;
    end;
  end;
end;

procedure TPipeToStrings.AddToSL(const Buf: TRdBuffer; Len: integer);
var
  i: integer;
  ch: char;
begin
  if Len > 0 then
  begin
    for i := 0 to Len - 1 do
    begin
      ch := Buf[i];
      case ch of
        #13:
          ;
        #10:
          begin
            AddToSL(FBuildStr);
            FBuildStr := '';
          end;
      else
        FBuildStr := FBuildStr + ch;
      end
    end;
  end;
  if FOwnerHandle <> INVALID_HANDLE_VALUE then
    PostMessage(FOwnerHandle, wm_FMsgId, integer(Self), SL.Count);
  if FEndLiineFnd then
  begin
    FEndLiineFnd := false;
    PostMessage(FOwnerHandle, wm_FMsgId, integer(Self), -1);
  end;
end;

// ------------------------------------------------------------------------------
var
  GlobalListOfProcessCaller: TObjectList;

type
  TProcessCaller = class(TThread)
  private
    FExitEvent: THandle;
    ProcessInfo: TProcessInformation;
    FSay: boolean;
    FAddExitMessage: boolean;

    procedure WriteLn(s: string);
    procedure ifSay(s: string);
  protected
    procedure Execute; override;
  public
    MyPipeOut: THandle;
    MyPipeIn: THandle;

    FOutMsgHandle: THandle;
    App, Param, WorkDir: string;
    constructor Create;
    destructor Destroy; override;
    function StopProcess: boolean;
  end;

constructor TProcessCaller.Create;
var
  SecurityAttributes: TSecurityAttributes;
begin
  inherited Create(true);
  FExitEvent := CreateEvent(Nil, false, false, 'EXIT_EVENT');

  FillChar(SecurityAttributes, SizeOf(SecurityAttributes), 0);
  SecurityAttributes.nLength := SizeOf(SecurityAttributes);
  SecurityAttributes.bInheritHandle := true;
  CreatePipe(MyPipeOut, MyPipeIn, @SecurityAttributes, 256);
  FAddExitMessage := false;
  GlobalListOfProcessCaller.Add(Self);
end;

destructor TProcessCaller.Destroy;
var
  idx: integer;
begin
  inherited;
  idx := GlobalListOfProcessCaller.IndexOf(Self);
  if idx < 0 then
    raise Exception.Create('ProcessCaller outsize GlobalListOfProcessCaller');
  GlobalListOfProcessCaller.Remove(Self);
  CloseHandle(FExitEvent);
  CloseHandle(MyPipeOut);
end;

procedure TProcessCaller.WriteLn(s: string);
var
  M: Cardinal;
  s2: AnsiString;
begin
  s := s + #13 + #10;
  if FOutMsgHandle <> INVALID_HANDLE_VALUE then
  begin
    s2 := AnsiString(s);
    Windows.WriteFile(FOutMsgHandle, s2[1], length(s2), M, nil);
  end;
end;

procedure TProcessCaller.ifSay(s: string);
begin
  if FSay then
    WriteLn('\i' + s);
end;

procedure TProcessCaller.Execute;
var
  Info: TStartupInfo;
  TempHandle: THandle;

  ProcessCode: Cardinal;
  StartExec: Int64;
  EndExec: Int64;
  PerfFreq: Int64;
  s: string;
  tm: real;
  ErrorCode: integer;
  ProcessCaller: TProcessCaller;
  msgCnt: integer;
  UserBrak: boolean;

begin
  ifSay('');

  { Read end should not be inherited by child process }
  if Win32Platform <> VER_PLATFORM_WIN32_NT then
  begin
    if not DuplicateHandle(GetCurrentProcess, FOutMsgHandle, GetCurrentProcess, @TempHandle, 0, true,
      DUPLICATE_SAME_ACCESS) then
    begin
{$WARNINGS OFF}
      RaiseLastWin32Error;
{$WARNINGS ON}
    end;
    FOutMsgHandle := TempHandle;
  end;

  FillChar(Info, SizeOf(Info), 0);
  Info.cb := SizeOf(Info);
  Info.wShowWindow := SW_HIDE;
  Info.hStdOutput := FOutMsgHandle;
  Info.hStdError := FOutMsgHandle;
  Info.hStdInput := MyPipeOut;
  Info.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;

  // Czas pracy wywo³ywanego programu
  if QueryPerformanceFrequency(PerfFreq) then
    QueryPerformanceCounter(StartExec);

  ifSay(App);
  ifSay(Param);

  Param := '??? ' + Param;
  if CreateProcess(pchar(App), pchar(Param), nil, nil, true, CREATE_NO_WINDOW, nil, pchar(WorkDir), Info, ProcessInfo)
  then
  begin
    CloseHandle(ProcessInfo.hThread); { Nie odwo³ujemy siê do Handle w¹tku g³ównego }
    try

      msgCnt := 0;
      UserBrak := false;

      while not Terminated do
      begin
        if WaitForSingleObject(ProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
          break;

        if WaitForSingleObject(FExitEvent, 100) = WAIT_OBJECT_0 then
        begin
          UserBrak := true;
          break;
        end;

        inc(msgCnt);
        if msgCnt = 20 then
        begin
          ifSay('CallerTask run');
          msgCnt := 0;
        end;
      end;

      ifSay('');
      ifSay('-----------------------------------------');
      if UserBrak then
      begin
        ifSay('ThreadCaller terminated by user.');
        ifSay('Waiting for process terminate....');
        TerminateProcess(ProcessInfo.hProcess, 10);
        while WaitForSingleObject(ProcessInfo.hProcess, 50) = WAIT_TIMEOUT do
        begin
          Application.ProcessMessages;
        end;
        GetExitCodeProcess(ProcessInfo.hProcess, ProcessCode);
        ifSay(Format('Process terminated. code = %u', [ProcessCode]));
      end
      else
      begin
        GetExitCodeProcess(ProcessInfo.hProcess, ProcessCode);
        QueryPerformanceCounter(EndExec);
        if PerfFreq > 0 then
        begin
          tm := 1.0 * (EndExec - StartExec) / PerfFreq;
          if tm < 1 then
            ifSay(Format('Process working time: %.3f ms', [tm * 1000.0]))
          else
            ifSay(Format('Process working time: %.3f s', [tm]));
        end;
        ifSay(Format('Terminated code: %d', [ProcessCode]));
      end
    finally
      if ProcessInfo.hProcess <> INVALID_HANDLE_VALUE then
        CloseHandle(ProcessInfo.hProcess);
    end
  end
  else
  begin
    ErrorCode := GetLastError;
    if ErrorCode <> 0 then
      s := SysErrorMessage(ErrorCode);
    s := Format('Error program execution %s:%s', [App, s]);
    WriteLn(s);
  end;
  if FAddExitMessage then
    WriteLn(END_OF_PROCESS_TXT + #10);
end;

function TProcessCaller.StopProcess: boolean;
begin
  Terminate;
  SetEvent(FExitEvent);
  Result := true;
end;

function CallHideProcess(OutMsgHandle: THandle; App, Param, WorkDir: string; Say, AddExitMsg: boolean): TThread;
var
  ProcessCaller: TProcessCaller;
begin
  ProcessCaller := TProcessCaller.Create;
  ProcessCaller.FAddExitMessage := AddExitMsg;
  ProcessCaller.FOutMsgHandle := OutMsgHandle;
  ProcessCaller.App := App;
  ProcessCaller.Param := Param;
  ProcessCaller.WorkDir := WorkDir;
  ProcessCaller.FSay := Say;
  ProcessCaller.FreeOnTerminate := true;
  ProcessCaller.Resume;
  Result := ProcessCaller;
end;

function StopHideProcess(ProcessThread: TThread): boolean;
var
  idx: integer;
begin
  idx := GlobalListOfProcessCaller.IndexOf(ProcessThread);
  if idx >= 0 then
    Result := (ProcessThread as TProcessCaller).StopProcess
  else
    Result := true;
end;


// ---------------------------------------------------------------------------------------

function FindFileInPath(FileName: string): string;
var
  SL: TStringList;
  i: integer;
  Path: string;
begin
  Result := '';
  SL := TStringList.Create;
  try
    Path := GetEnvironmentVariable('Path');
    SL.Delimiter := ';';
    SL.DelimitedText := Path;
    for i := 0 to SL.Count - 1 do
    begin
      Path := IncludeTrailingPathDelimiter(SL.Strings[i]) + FileName;
      if FileExists(Path) then
      begin
        Result := Path;
        break;
      end;
    end;
  finally
    SL.Free;
  end;
end;

function ExecBatchFile(BatFileName, WorkDir: string): Cardinal;
var
  Info: TStartupInfo;
  ProcessInfo: TProcessInformation;

  SecurityAttributes: TSecurityAttributes;
  App: string;
  Param: string;
begin
  App := FindFileInPath('Cmd.exe');
  if App <> '' then
  begin
    Param := '/C ' + BatFileName;

    FillChar(SecurityAttributes, SizeOf(SecurityAttributes), 0);
    with SecurityAttributes do
    begin
      nLength := SizeOf(SecurityAttributes);
      bInheritHandle := true;
    end;

    { Read end should not be inherited by child process }
    if Win32Platform <> VER_PLATFORM_WIN32_NT then
    begin

    end;

    FillChar(Info, SizeOf(Info), 0);
    Info.cb := SizeOf(Info);
    Info.wShowWindow := SW_SHOW; // SW_HIDE;
    Info.dwFlags := STARTF_USESHOWWINDOW;

    // Param := '??? '+Param;
    if CreateProcess(pchar(App), pchar(Param), nil, nil, false, CREATE_NEW_CONSOLE,
      // or HIGH_PRIORITY_CLASS,// or CREATE_NEW_CONSOLE,// CREATE_NO_WINDOW
      nil, pchar(WorkDir), Info, ProcessInfo) then
    begin
      CloseHandle(ProcessInfo.hThread); { Nie odwo³ujemy siê do Handle w¹tku g³ównego }
      Result := 0;
    end
    else
    begin
      Result := GetLastError;
    end;
  end
  else
    Result := 2;
end;

initialization

GlobalListOfProcessCaller := TObjectList.Create(false);

finalization

GlobalListOfProcessCaller.Free;

end.
