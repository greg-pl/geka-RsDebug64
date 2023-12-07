unit TerminalUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ImgList, ActnList, ExtCtrls, StdCtrls, ComCtrls,
  ToolWin,
  RsdDll,
  ProgCfgUnit;

const
  MAX_MEMO_LINES_CNT = 1500;
type
  TCharArr = array of char;
  TTerminalForm = class(TChildForm)
    TermMemo: TMemo;
    AutoRepTmEdit: TComboBox;
    Label5: TLabel;
    Timer1: TTimer;
    ReadBtn: TToolButton;
    ClearBtn: TToolButton;
    ClrTerminalAct: TAction;
    MaxLineEdit: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TermMemoKeyPress(Sender: TObject; var Key: Char);
    procedure AutoRepTmEditChange(Sender: TObject);
    procedure RdBoxClick(Sender: TObject);
    procedure ReadBtnClick(Sender: TObject);
    procedure ClrTerminalActExecute(Sender: TObject);
    procedure MaxLineEditKeyPress(Sender: TObject; var Key: Char);
    procedure MaxLineEditExit(Sender: TObject);
  private
    Interval : integer;
    LineSz   : integer;
    procedure MemoAddChars(buf : TCharArr);
    procedure SetAtBottom;
  public
    procedure SaveToIni(Ini : TDotIniFile; SName : string); override;
    procedure LoadFromIni(Ini : TDotIniFile; SName : string); override;
  end;


implementation

{$R *.dfm}

procedure TTerminalForm.FormCreate(Sender: TObject);
begin
  inherited;
  Interval := 10;
  LineSz := 80;
end;

procedure TTerminalForm.FormActivate(Sender: TObject);
begin
  inherited;
  if Title='' then
    Title:='Term';
  ShowCaption;
end;


procedure TTerminalForm.MemoAddChars(buf : TCharArr);
var
  i ,n : integer;
  ch   : char;
  CursPt : TPoint;
  s      : string;
  sPos   : integer;
begin
  n := length(buf);
  TermMemo.Lines.BeginUpdate;
  try
    if TermMemo.Lines.Count=0 then
      TermMemo.Lines.Add('');

    s := TermMemo.Lines.Strings[TermMemo.Lines.Count-1];
    sPos := length(s);
    setlength(s,LineSz);
    for i:=0 to n-1 do
    begin
      ch := buf[i];
      case ch of
        #8  : begin  //BackSpace
                if sPos>0 then
                  dec(sPos);
              end;
        #13 : ;
        #10 : begin
                setlength(s,sPos);
                TermMemo.Lines.Strings[TermMemo.Lines.Count-1] := s;
                TermMemo.Lines.Add('');
                s := '';
                setlength(s,LineSz);
                sPos :=0;
              end;

        else
        begin
          inc(sPos);
          s[sPos]:=ch;
          if sPos=LineSz then
          begin
            TermMemo.Lines.Strings[TermMemo.Lines.Count-1] := s;
            TermMemo.Lines.Add('');
            setlength(s,LineSz);
            sPos := 0;
          end;
        end;
      end;
    end;
    setlength(s,sPos);
    TermMemo.Lines.Strings[TermMemo.Lines.Count-1] := s;

    while TermMemo.Lines.Count>MAX_MEMO_LINES_CNT do
    begin
      TermMemo.Lines.Delete(0);
    end;

    CursPt.X := length(TermMemo.Lines.Strings[TermMemo.Lines.Count-1]);
    CursPt.Y := TermMemo.Lines.Count-1;
    TermMemo.CaretPos:=CursPt;
  finally
    TermMemo.Lines.EndUpdate;
  end;
end;

procedure TTerminalForm.SetAtBottom;
begin
  SendMessage(TermMemo.Handle,WM_VSCROLL,SB_BOTTOM,0);
end;


procedure TTerminalForm.Timer1Timer(Sender: TObject);
const
  MaxCnt = 1000;
var
  buf    : TCharArr;
  rdcnt  : integer;
  rdsuma : integer;
  st     : TStatus;
  repCnt : integer;
begin
  inherited;
  if Dev.Connected and  ReadBtn.Down then
  begin
    repCnt:=0;
    rdsuma:=0;
    while repCnt<10 do
    begin
      setlength(buf,MaxCnt);
      st := Dev.TerminalRead(Handle,buf[0],rdcnt);
      if st<>stOK then
      begin
        Timer1.Enabled := false;
        ReadBtn.Down := false;
        break;
      end;
      if rdcnt=0 then
      begin
        break;
      end;
      rdsuma := rdsuma + rdCnt;
      setlength(buf,rdcnt);

      MemoAddChars(buf);
      inc(repCnt);
    end;
    if rdsuma>0 then
    begin
      SetAtBottom;
      StatusBar.Panels[2].Text := IntToStr(TermMemo.Lines.Count);
    end;
  end;
end;

procedure TTerminalForm.TermMemoKeyPress(Sender: TObject; var Key: Char);
var
  st : TStatus;
begin
  inherited;
  st := Dev.TerminalSendKey(Handle,key);
  Key := #0;
  if st=stOK then
  begin
    Timer1.Enabled := false;
    Timer1Timer(nil);
    Timer1.Enabled := true;
    ReadBtn.Down := true;
  end;
end;

procedure TTerminalForm.AutoRepTmEditChange(Sender: TObject);
begin
  inherited;
  Timer1.Interval := StrToInt(AutoRepTmEdit.Text);
end;

procedure TTerminalForm.RdBoxClick(Sender: TObject);
begin
  inherited;
  Timer1.Enabled := ReadBtn.Down;
end;


procedure TTerminalForm.SaveToIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  Ini.WriteString(SName,'RepTime',AutoRepTmEdit.Text);
  Ini.WriteString(SName,'RepTimes',AutoRepTmEdit.Items.CommaText);

  Ini.WriteString(SName,'LineSz',MaxLineEdit.Text);

end;

procedure TTerminalForm.LoadFromIni(Ini : TDotIniFile; SName : string);
var
  s : string;
  tm : integer;
begin
  inherited;
  s := Ini.ReadString(SName,'RepTimes','');
  if s<>'' then
    AutoRepTmEdit.Items.CommaText := s;
  AutoRepTmEdit.Text := Ini.ReadString(SName,'RepTime',AutoRepTmEdit.Text);
  MaxLineEdit.Text := Ini.ReadString(SName,'LineSz',MaxLineEdit.Text);
  if not(TryStrToInt(MaxLineEdit.Text,LineSz)) then
  begin
    LineSz := 80;
    MaxLineEdit.Text := IntToStr(LineSz);
  end;
  if TryStrToInt(AutoRepTmEdit.Text,tm) then
    Timer1.Interval := tm;
  if LineSz<10 then
    LineSz:=10; 
end;

procedure TTerminalForm.ReadBtnClick(Sender: TObject);
begin
  inherited;
  Timer1.Enabled := ReadBtn.Down;
end;

procedure TTerminalForm.ClrTerminalActExecute(Sender: TObject);
begin
  inherited;
  TermMemo.Lines.Clear;
end;

procedure TTerminalForm.MaxLineEditKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
  if Key=#13 then
    (Sender as TLabeledEdit).OnExit(Sender);
end;

procedure TTerminalForm.MaxLineEditExit(Sender: TObject);
begin
  inherited;
  if not(TryStrToInt((sender as TLabeledEdit).Text,LineSz)) then
  begin
    (sender as TLabeledEdit).Text := IntToStr(LineSz);
  end;
end;

end.
