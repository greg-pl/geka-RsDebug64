unit StLinkDriver;

interface

uses
  Classes, Windows, Messages, Types, SysUtils, Contnrs,
  WinSock2,
  ExtCtrls,
  SimpSock_Tcp,
  ErrorDefUnit;
  //Rsd64Definitions;

type
  TStLinkDrv = class;
  TOnLog = procedure(Sender: TStLinkDrv; txt: string) of object;

  TStLinkDrv = class(TObject)

  private
    SimpTcp: TSimpTcp;

    procedure SimpTcpOnMsgReadProc(Sender: TObject);
    procedure SimpTcpOnConnectProc(Sender: TObject);
    procedure Log(s: string);
    function GetCmdSum(cmd: TBytes): byte;
    function WriteCmd(cmd: TBytes): TStatus; overload;
    function WriteCmd(cmd: AnsiString): TStatus; overload;
    procedure FlushRecive;
    function WaitPlusReplay(var txt: AnsiString; time: cardinal): TStatus;
    function WaitReplay(var txt: AnsiString; time: cardinal): TStatus;
    function HexToBytes(var buf: TBytes; txt: AnsiString): boolean;
    function GetGdbError(repl: string): TStatus;

  public
    OnLog: TOnLog;
    constructor Create;
    destructor Destroy; override;
    function Open(IP: string; Port: integer): TStatus;
    function close: TStatus;
    function isOpen: boolean;

    function ReadMem(adr, cnt: integer; var buf: TBytes): TStatus;
    function WriteMem(adr: cardinal; buf: TBytes): TStatus;

    function RCommand(rcmd: string; var repl: string; verbose: boolean): TStatus; overload;
    function RCommand(rcmd: string): TStatus; overload;

  end;

function ParseArray(txt: string): TBytes;
function StringToBytes(txt: AnsiString): TBytes;

implementation



function ParseArray(txt: string): TBytes;
var
  SL: TStringList;
  n, i: integer;
  b: integer;
begin
  SL := TStringList.Create;
  try
    SL.Delimiter := ' ';
    SL.DelimitedText := txt;
    setlength(Result, SL.Count);
    for i := 0 to SL.Count - 1 do
    begin
      if TryStrToInt('$' + SL.Strings[i], b) = false then
      begin
        setlength(Result, i);
        break;
      end;
      Result[i] := byte(b);
    end;
  finally
    SL.Free;
  end;

end;

function StringToBytes(txt: AnsiString): TBytes;
var
  n: integer;
begin
  n := length(txt);
  setlength(Result, n);
  if n > 0 then
    move(txt[1], Result[0], n);
end;

constructor TStLinkDrv.Create;
begin
  inherited;
  SimpTcp := TSimpTcp.Create;
  SimpTcp.OnMsgRead := SimpTcpOnMsgReadProc;
  SimpTcp.OnConnect := SimpTcpOnConnectProc;
end;

destructor TStLinkDrv.Destroy;
begin
  inherited;
  SimpTcp.Free;
end;

procedure TStLinkDrv.Log(s: string);
begin
  if Assigned(OnLog) then
    OnLog(self, s);
end;

procedure TStLinkDrv.SimpTcpOnMsgReadProc(Sender: TObject);
var
  txt: AnsiString;
  st: TStatus;
begin
  // st := SimpTcp.ReadAnsiStr(txt);
  // Log(Format('OnRead, st=%d [%s]', [st, txt]));
end;

procedure TStLinkDrv.SimpTcpOnConnectProc(Sender: TObject);
begin
  Log('OnConnect');
end;

function TStLinkDrv.Open(IP: string; Port: integer): TStatus;
var
  st: TStatus;
begin
  SimpTcp.IP := IP;
  SimpTcp.Port := Port;
  st := SimpTcp.Open;
  if st = stOk then
  begin
    SimpTcp.Async := true;
    st := SimpTcp.Connect;
  end;
  Result := st;
end;

function TStLinkDrv.close: TStatus;
begin
  Result := SimpTcp.close;
end;

function TStLinkDrv.isOpen: boolean;
begin
  Result := SimpTcp.IsConnected;
end;

function TStLinkDrv.GetCmdSum(cmd: TBytes): byte;
var
  i, n: integer;
  sum: byte;
begin
  n := length(cmd);
  sum := 0;
  for i := 0 to n - 1 do
  begin
    sum := byte(sum + cmd[i]);
  end;
  Result := sum;
end;

function TStLinkDrv.WriteCmd(cmd: TBytes): TStatus;
const
  HexChar: array [0 .. 15] of char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var
  sum: byte;
  cmd2: TBytes;
  i, n: integer;
begin
  FlushRecive;
  sum := GetCmdSum(cmd);
  n := length(cmd);
  setlength(cmd2, 1 + n + 3);
  for i := 0 to n - 1 do
    cmd2[1 + i] := cmd[i];
  cmd2[0] := ord('$');
  cmd2[n + 1] := ord('#');
  cmd2[n + 2] := ord(HexChar[sum shr 4]);
  cmd2[n + 3] := ord(HexChar[sum and $0F]);
  Result := SimpTcp.Write(cmd2);
end;

function TStLinkDrv.WriteCmd(cmd: AnsiString): TStatus;
begin
  Result := WriteCmd(StringToBytes(cmd));
end;

function TStLinkDrv.HexToBytes(var buf: TBytes; txt: AnsiString): boolean;
  function HexByte(var b: byte; txt: AnsiString): boolean;
  var
    bb: integer;
  begin
    Result := TryStrToInt('$' + txt, bb);
    b := byte(bb);
  end;

var
  i, n: integer;
  b: byte;
begin
  n := length(txt) div 2;
  setlength(buf, n);
  for i := 0 to n - 1 do
  begin
    Result := HexByte(b, copy(txt, 1 + 2 * i, 2));
    if not Result then
      break;
    buf[i] := b;
  end;

end;

function TStLinkDrv.WaitPlusReplay(var txt: AnsiString; time: cardinal): TStatus;
var
  tt: cardinal;
  st: TStatus;
  txt1: AnsiString;
  rdFlag: boolean;
  i, n: integer;
  sum: byte;
  sum2: byte;
begin
  tt := GetTickCount;
  rdFlag := false;
  Result := stTimeErr;
  while GetTickCount - tt < time do
  begin
    st := SimpTcp.ReadStrPart(txt1);
    if length(txt1) > 0 then
    begin
      if rdFlag = false then
      begin
        rdFlag := true;
        if txt1[1] <> '+' then
        begin
          Result := stErrorRecived;
          break;
        end;
        txt1 := copy(txt1, 2, length(txt1) - 1);
      end;
      n := length(txt1);
      if n >= 4 then
      begin
        if (txt1[1] = '$') and (txt1[n - 2] = '#') then
        begin
          sum2 := StrToInt('$' + copy(txt1, n - 1, 2));
          sum := 0;
          if n > 4 then
          begin
            for i := 2 to n - 3 do
              sum := byte(sum + ord(txt1[i]));
          end;
          if sum = sum2 then
          begin
            if n > 4 then
              txt := copy(txt1, 2, n - 4)
            else
              txt := '';
            Result := stOk;
          end
          else
            Result := stReplySumError
        end
        else
          Result := stReplyFormatError;
        break;
      end;
    end;
    sleep(5);
  end;
end;

procedure TStLinkDrv.FlushRecive;
var
  txt1: AnsiString;
  st: TStatus;
begin
  st := SimpTcp.ReadStrPart(txt1);
  if (st = stOk) and (txt1 <> '') then
  begin
    Log(Format('Flush [%s]', [txt1]));
  end;

end;

function TStLinkDrv.WaitReplay(var txt: AnsiString; time: cardinal): TStatus;
var
  tt: cardinal;
  st: TStatus;
  txt1: AnsiString;
  i, n: integer;
  sum: byte;
  sum2: byte;
begin
  tt := GetTickCount;
  Result := stTimeErr;
  while GetTickCount - tt < time do
  begin
    st := SimpTcp.ReadStrPart(txt1);
    n := length(txt1);
    if n >= 4 then
    begin
      if (txt1[1] = '$') and (txt1[n - 2] = '#') then
      begin
        sum2 := StrToInt('$' + copy(txt1, n - 1, 2));
        sum := 0;
        if n > 4 then
        begin
          for i := 2 to n - 3 do
            sum := byte(sum + ord(txt1[i]));
        end;
        if sum = sum2 then
        begin
          if n > 4 then
            txt := copy(txt1, 2, n - 4)
          else
            txt := '';
          Result := stOk;
        end
        else
          Result := stReplySumError
      end
      else
        Result := stReplyFormatError;
    end;
    sleep(5);
  end;
end;

function TStLinkDrv.GetGdbError(repl: string): TStatus;
var
  txt: string;
  bb: integer;
begin
  Result := stBadRepl;
  if length(repl) >= 3 then
  begin
    if repl[1] = 'E' then
    begin
      txt := copy(repl, 1, length(repl) - 1);
      if TryStrToInt('$' + txt, bb) then
        Result := TStatus(bb + stGDB_error);
    end;
  end
end;

function TStLinkDrv.ReadMem(adr, cnt: integer; var buf: TBytes): TStatus;
var
  st: TStatus;
  repl: AnsiString;
begin
  st := WriteCmd(AnsiString(Format('m%x,%x', [adr, cnt])));
  if st = stOk then
  begin
    st := WaitPlusReplay(repl, 500);
    if st = stOk then
    begin
      if not HexToBytes(buf, repl) then
        st := stReplyFormatError;
    end;
    if length(buf) <> cnt then
      st := GetGdbError(repl);
  end;
  Result := st;
end;

function TStLinkDrv.RCommand(rcmd: string): TStatus;
var
  repl: string;
begin
  Result := RCommand(rcmd, repl, true);
end;

function TStLinkDrv.RCommand(rcmd: string; var repl: string; verbose: boolean): TStatus;
var
  st: TStatus;
  txt: AnsiString;
begin
  st := WriteCmd(AnsiString(rcmd));
  if st = stOk then
  begin
    st := WaitPlusReplay(txt, 500);
    if verbose then
      Log(Format('RCmd [%s]', [txt]));
    repl := String(txt);
  end;
  Result := st;
end;

function TStLinkDrv.WriteMem(adr: cardinal; buf: TBytes): TStatus;
var
  buf2: TBytes;
  n, n2: integer;
  st: TStatus;
begin
  n := length(buf);
  buf2 := StringToBytes(AnsiString(Format('X%x,%x:', [adr, n])));
  n2 := length(buf2);
  setlength(buf2, n2 + n);
  move(buf[0], buf2[n2], n);
  st := WriteCmd(buf2);

  Result := st;
end;

end.
