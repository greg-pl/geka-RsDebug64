unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  StLinkDriver, SimpSock_Tcp, Vcl.ExtCtrls,
  ErrorDefUnit;

type
  TForm2 = class(TForm)
    IpBox: TComboBox;
    PortBox: TComboBox;
    ReadMemAdrEdit: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ReadMemBtn: TButton;
    OpenTcpBtn: TButton;
    CloseTcpBtn: TButton;
    Memo1: TMemo;
    ReadMemCntEdit: TComboBox;
    Panel1: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Label4: TLabel;
    RCmdBtn: TButton;
    RCmdBox: TComboBox;
    Label5: TLabel;
    WriteMemAdrEdit: TComboBox;
    WriteMemValueEdit: TComboBox;
    WriteMemBtn: TButton;
    Panel2: TPanel;
    CmdSBtn: TButton;
    CmdCBtn: TButton;
    CmdGBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OpenTcpBtnClick(Sender: TObject);
    procedure CloseTcpBtnClick(Sender: TObject);
    procedure ReadMemBtnClick(Sender: TObject);
    procedure RCmdBtnClick(Sender: TObject);
    procedure IpBoxExit(Sender: TObject);
    procedure IpBoxKeyPress(Sender: TObject; var Key: Char);
    procedure WriteMemBtnClick(Sender: TObject);
    procedure CmdSBtnClick(Sender: TObject);
    procedure CmdCBtnClick(Sender: TObject);
    procedure CmdGBtnClick(Sender: TObject);
  private
    RecCnt: integer;
    StLinkDrv: TStLinkDrv;

    procedure Wr(s: string); overload;
    procedure Wr(SL: TStrings); overload;
    procedure StLinkDrvOnLogProc(Sender: TStLinkDrv; txt: string);

  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

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

procedure TForm2.FormCreate(Sender: TObject);
begin
  StLinkDrv := TStLinkDrv.Create;
  StLinkDrv.OnLog := StLinkDrvOnLogProc;

end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  StLinkDrv.Free;
end;

procedure TForm2.IpBoxExit(Sender: TObject);
var
  box: TComboBox;
  txt: string;
  n: integer;
begin
  box := Sender as TComboBox;
  txt := box.Text;
  n := box.Items.IndexOf(txt);
  if n <> 0 then
  begin
    if n > 0 then
    begin
      box.Items.Delete(n);
    end;
    box.Items.Insert(0, txt);
    box.ItemIndex := 0;
  end;
end;

procedure TForm2.IpBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    IpBoxExit(Sender);
end;

procedure TForm2.Wr(s: string);
begin
  Memo1.Lines.Add(s);
end;

procedure TForm2.Wr(SL: TStrings);
begin
  Memo1.Lines.AddStrings(SL);
end;

procedure TForm2.StLinkDrvOnLogProc(Sender: TStLinkDrv; txt: string);
begin
  Wr(txt);
end;

procedure TForm2.OpenTcpBtnClick(Sender: TObject);
var
  st: TStatus;
begin
  st := StLinkDrv.Open(IpBox.Text, StrToInt(PortBox.Text));
  Wr(Format('Open, st=%d', [st]));
end;

procedure TForm2.CloseTcpBtnClick(Sender: TObject);
begin
  StLinkDrv.close;

end;

procedure TForm2.ReadMemBtnClick(Sender: TObject);
var
  buf: TBytes;
  adr, cnt: integer;
  st: TStatus;
  SL: TStringList;
begin
  adr := StrToInt('$' + ReadMemAdrEdit.Text);
  cnt := StrToInt('$' + ReadMemCntEdit.Text);
  st := StLinkDrv.ReadMem(adr, cnt, buf);
  Wr(Format('ReadMem, st=%d', [st]));
  if st = stOk then
  begin
    SL := DumpBytes(adr, buf);
    Wr(SL);
    SL.Free;
  end
end;

procedure TForm2.RCmdBtnClick(Sender: TObject);
var
  st: TStatus;
begin
  st := StLinkDrv.RCommand(RCmdBox.Text);
  Wr(Format('RCmd, st=%d', [st]));
end;

procedure TForm2.CmdCBtnClick(Sender: TObject);
var
  st: TStatus;
begin
  st := StLinkDrv.RCommand_Continue;
  Wr(Format('Continue, st=%d', [st]));
end;

procedure TForm2.CmdSBtnClick(Sender: TObject);
var
  st: TStatus;
begin
  st := StLinkDrv.RCommand_Stop;
  Wr(Format('Stop, st=%d', [st]));
end;

procedure TForm2.CmdGBtnClick(Sender: TObject);
const
  REG_CNT = 16;
  RegName: array [0 .. REG_CNT - 1] of string = ( //
    'r0', 'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7', 'r8', 'r9', 'r10', 'r11', 'r12', 'sp', 'lr', 'pc');
var
  st: TStatus;
  repl: string;
  n, i: integer;
  vtxt: string;
  name: string;
  vv: cardinal;
begin
  st := StLinkDrv.RCommand('g', repl, false);
  if st = stOk then
  begin
    n := length(repl) div 8;
    for i := 0 to n - 1 do
    begin
      vtxt := copy(repl, 1 + 8 * i, 8);
      if TryStrToUInt('$' + vtxt, vv) then
      begin
        if vv = 0 then
          vtxt := '0'
        else
        begin
          vv := Dswap(vv);
          vtxt := Format('%.8X(%u)', [vv, vv]);
        end;

      end;
      name := '??';
      if i < REG_CNT then
        name := RegName[i];
      Wr(Format('%2d.%8s:%s', [i, name, vtxt]));
    end;
  end
  else
    Wr(Format('Registry, st=%d', [st]));
end;

procedure TForm2.WriteMemBtnClick(Sender: TObject);
var
  buf: TBytes;
  adr, cnt: integer;
  st: TStatus;
  SL: TStringList;
begin
  adr := StrToInt('$' + WriteMemAdrEdit.Text);
  buf := ParseArray(WriteMemValueEdit.Text);
  if length(buf) > 0 then
  begin
    st := StLinkDrv.WriteMem(adr, buf);
    Wr(Format('WriteMem %u bytes @ 0x%X, st=%d', [length(buf), adr, st]));
  end;
end;

end.
