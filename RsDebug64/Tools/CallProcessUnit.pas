unit CallProcessUnit;

interface

uses
  SysUtils, Classes, Windows, Forms, Messages;

function CallHideProcess(OutMsgHandle, BreakHandle: THandle; App, Param, WorkDir: string; Say: boolean): Cardinal;
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

uses
  Main;

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
  with SecurityAttributes do
  begin
    nLength := SizeOf(SecurityAttributes);
    bInheritHandle := true;
  end;
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
//  MainForm.NL_T('ReadPipe_Str');
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
  //MainForm.NL_T('ReadPipe_End');
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
type
  TProcessCaller = class(TThread)
  private
    FAsyncMutex: THandle;
    procedure WriteLn(s: string);
  protected
    procedure Execute; override;
  public
    FOutMsgHandle: THandle;
    FBreakHandle: THandle;
    App, Param, WorkDir: string;
    Say: boolean;
    constructor Create;
    destructor Destroy; override;
  end;

constructor TProcessCaller.Create;
begin
  inherited Create(true);
  FAsyncMutex := CreateEvent(Nil, true, False, 'FRE_EVENT');
  //MainForm.NL_T('TProcessCaller.Create');
end;

destructor TProcessCaller.Destroy;
begin
  inherited ;
  CloseHandle(FAsyncMutex);
//  MainForm.NL_T('TProcessCaller.Destroy');
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

procedure TProcessCaller.Execute;
var
  Info: TStartupInfo;
  ProcessInfo: TProcessInformation;
  TempHandle: THandle;

  SecurityAttributes: TSecurityAttributes;
  ProcessCode: Cardinal;
  StartExec: Int64;
  EndExec: Int64;
  PerfFreq: Int64;
  s: string;
  tm: real;
  ErrorCode: integer;
  UserBrak: boolean;
  ProcessCaller: TProcessCaller;

begin
  if Say then
  begin
    WriteLn('');
    WriteLn(App);
  end;
  FillChar(SecurityAttributes, SizeOf(SecurityAttributes), 0);
  with SecurityAttributes do
  begin
    nLength := SizeOf(SecurityAttributes);
    bInheritHandle := true;
  end;

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
  Info.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;

  // Czas pracy wywo³ywanego programu
  if QueryPerformanceFrequency(PerfFreq) then
    QueryPerformanceCounter(StartExec);

  Param := '??? ' + Param;
  if CreateProcess(pchar(App), pchar(Param), nil, nil, true, CREATE_NO_WINDOW,
    // or HIGH_PRIORITY_CLASS,// or CREATE_NEW_CONSOLE,//
    nil, pchar(WorkDir), Info, ProcessInfo) then
  begin
    CloseHandle(ProcessInfo.hThread); { Nie odwo³ujemy siê do Handle w¹tku g³ównego }
    try

      UserBrak := false;
      while WaitForSingleObject(ProcessInfo.hProcess, 50) = WAIT_TIMEOUT do
      begin
        if FBreakHandle <> INVALID_HANDLE_VALUE then
        begin
          if WaitForSingleObject(FBreakHandle, 0) = WAIT_OBJECT_0 then
          begin
            UserBrak := true;
            Break;
          end;
        end;
        Application.ProcessMessages;
        sleep(4);
      end;

      if Say then
      begin
        WriteLn('');
        WriteLn('-----------------------------------------');
        if not(UserBrak) then
        begin
          GetExitCodeProcess(ProcessInfo.hProcess, ProcessCode);
          QueryPerformanceCounter(EndExec);
          if PerfFreq > 0 then
          begin
            tm := 1.0 * (EndExec - StartExec) / PerfFreq;
            if tm < 1 then
              s := format('Czas pracy processu: %.3f ms', [tm * 1000.0])
            else
              s := format('Czas pracy processu: %.3f s', [tm]);
            WriteLn(s);
          end;
          s := format('Kod zakoñczenia programu : %d', [ProcessCode]);
          WriteLn(s);
        end
        else
        begin
          WriteLn('Operacja przerwana przez u¿ytkownika');
          WriteLn('Oczekiwanie na zakoñczenie procesu');
          TerminateProcess(ProcessInfo.hProcess, 10);
          while WaitForSingleObject(ProcessInfo.hProcess, 50) = WAIT_TIMEOUT do
          begin
            Application.ProcessMessages;
          end;
          WriteLn('Proces zakoñczony');
        end;
      end
    finally
      CloseHandle(ProcessInfo.hProcess);
    end
  end
  else
  begin
    ErrorCode := GetLastError;
    if ErrorCode <> 0 then
      s := SysErrorMessage(ErrorCode);
    s := format('B³¹d wywo³ania programu %s:%s', [App, s]);
    WriteLn(s);
  end;
  WriteLn(END_OF_PROCESS_TXT + #10);
end;

function CallHideProcess(OutMsgHandle, BreakHandle: THandle; App, Param, WorkDir: string; Say: boolean): Cardinal;
var
  ProcessCaller: TProcessCaller;
begin
  ProcessCaller := TProcessCaller.Create;
  ProcessCaller.FOutMsgHandle := OutMsgHandle;
  ProcessCaller.FBreakHandle := BreakHandle;
  ProcessCaller.App := App;
  ProcessCaller.Param := Param;
  ProcessCaller.WorkDir := WorkDir;
  ProcessCaller.Say := Say;
  ProcessCaller.FreeOnTerminate := true;
  ProcessCaller.Resume;
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
        Break;
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

end.
