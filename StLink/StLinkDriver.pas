unit StLinkDriver;

interface

uses
  Classes, Windows, Messages, Types, SysUtils, Contnrs,
  WinSock2,
  ExtCtrls,
  SimpSock_Tcp;

type
  TStLinkDrv = class;
  TOnLog = procedure(Sender: TStLinkDrv; txt: string) of object;

  TStLinkDrv = class(TObject)

  private
    SimpTcp: TSimpTcp;

    procedure SimpTcpOnMsgReadProc(Sender: TObject);
    procedure SimpTcpOnConnectProc(Sender: TObject);
    procedure Log(s: string);
    function GetCmdSum(cmd: AnsiString): byte;
    function WriteCmd(cmd: AnsiString): TStatus;
    procedure FlushRecive;
    function WaitPlusReplay(var txt: AnsiString; time: cardinal): TStatus;
    function WaitReplay(var txt: AnsiString; time: cardinal): TStatus;
    function HexToBytes(var buf: TBytes; txt: AnsiString): boolean;

  public
    OnLog: TOnLog;
    constructor Create;
    destructor Destroy; override;
    function Open(IP: string; Port: integer): TStatus;
    function close: TStatus;
    function ReadMem(adr, cnt: integer; var buf: TBytes): TStatus;
    function RCommand(rcmd: string): TStatus;
  end;

function DumpBytes(Offset: integer; buf: TBytes): TStringList;

implementation

// 080004C0 : 00 20 FF F7 1B FF 00 20  FF F7 34 FF 00 20 FF F7
// address  : +0 +1 +2 +3 +4 +5 +6 +7  +8 +9 +A +B +C +D +E +F
// ---------+-------------------------------------------------

function DumpBytes(Offset: integer; buf: TBytes): TStringList;
var
  i, n: integer;
  txt: string;
  row: integer;
  Offset1: integer;
  beg: integer;

begin
  Result := TStringList.Create;
  Result.add('address  : +0 +1 +2 +3 +4 +5 +6 +7  +8 +9 +A +B +C +D +E +F');
  Result.add('---------+-------------------------------------------------');

  Offset1 := Offset and $FFFFFFF0;
  beg := Offset1 - Offset;

  row := 0;
  n := length(buf);
  for i := beg to n - 1 do
  begin
    if row = 0 then
      txt := IntToHex(Offset + i, 8) + ' : ';
    if i >= 0 then
      txt := txt + IntToHex(buf[i], 2)
    else
      txt := txt + '  ';

    if row = 7 then
      txt := txt + '  '
    else if row <> 15 then
      txt := txt + ' ';
    inc(row);

    if (Offset + i) mod 16 = 15 then
    begin
      Result.add(txt);
      txt := '';
      row := 0;
    end;

  end;
  if txt <> '' then
    Result.add(txt);

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

function TStLinkDrv.GetCmdSum(cmd: AnsiString): byte;
var
  i, n: integer;
  sum: byte;
begin
  n := length(cmd);
  sum := 0;
  for i := 1 to n do
  begin
    sum := sum + ord(cmd[i]);
  end;
  Result := sum;
end;

function TStLinkDrv.WriteCmd(cmd: AnsiString): TStatus;
var
  cmd2: AnsiString;
  sum: byte;
begin
  sum := GetCmdSum(cmd);
  cmd2 := '$' + cmd + '#' + IntToHex(sum, 2);
  Result := SimpTcp.Write_(cmd2);
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
  Result := stTimeOut;
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
  Result := stTimeOut;
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

function TStLinkDrv.ReadMem(adr, cnt: integer; var buf: TBytes): TStatus;
var
  st: TStatus;
  repl: AnsiString;
begin
  FlushRecive;
  st := WriteCmd(AnsiString(Format('m%x,%x', [adr, cnt])));
  if st = stOk then
  begin
    st := WaitPlusReplay(repl, 500);
    if st = stOk then
    begin
      if not HexToBytes(buf, repl) then
        st := stReplyFormatError;
    end;
  end;
  Result := st;

end;

function TStLinkDrv.RCommand(rcmd: string): TStatus;
var
  st: TStatus;
  txt: AnsiString;
begin
  FlushRecive;
  st := WriteCmd(AnsiString(rcmd));
  if st = stOk then
  begin
    st := WaitPlusReplay(txt, 500);
    Log(Format('RCmd [%s]', [txt]));
  end;
  Result := st;
end;

end.
