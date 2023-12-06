unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  StLinkDriver, SimpSock_Tcp, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    IpBox: TComboBox;
    PortBox: TComboBox;
    ReadMemAdrEdit: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SendTcpBtn: TButton;
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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OpenTcpBtnClick(Sender: TObject);
    procedure CloseTcpBtnClick(Sender: TObject);
    procedure SendTcpBtnClick(Sender: TObject);
    procedure RCmdBtnClick(Sender: TObject);
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

procedure TForm2.FormCreate(Sender: TObject);
begin
  StLinkDrv := TStLinkDrv.Create;
  StLinkDrv.OnLog := StLinkDrvOnLogProc;

end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  StLinkDrv.Free;
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

procedure TForm2.SendTcpBtnClick(Sender: TObject);
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


end.
