unit WrtControlUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ActnList, ImgList, ComCtrls, Menus, ExtCtrls,
  StdCtrls, Spin,ToolWin,IniFiles,
  RsdDll,
  ProgCfgUnit,
  MapParserUnit;

type
  TWrtControlForm = class(TChildForm)
    PopupMenu1: TPopupMenu;
    Edittitle1: TMenuItem;
    Closewindow1: TMenuItem;
    Panel1: TPanel;
    Status: TLabel;
    StatusText: TEdit;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    ControlNrEdit: TSpinEdit;
    ControlValueEdit: TEdit;
    VectorTxt: TEdit;
    Label3: TLabel;
    RdSignBtn: TToolButton;
    RdSemafBtn: TToolButton;
    WrSemafBtn: TToolButton;
    ToolButton5: TToolButton;
    RdSemafAct: TAction;
    WrSemafAct: TAction;
    RdVecAct: TAction;
    procedure FormActivate(Sender: TObject);
    procedure RdSemafActExecute(Sender: TObject);
    procedure WrSemafActExecute(Sender: TObject);
    procedure RdVecActExecute(Sender: TObject);
    procedure RdSemafActUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SaveToIni(Ini : TDotIniFile; SName : string); override;
    procedure LoadFromIni(Ini : TDotIniFile; SName : string); override;
  end;

var
  WrtControlForm: TWrtControlForm;

implementation



{$R *.dfm}

procedure TWrtControlForm.FormActivate(Sender: TObject);
begin
  inherited;
  ShowParamAct.Checked := true;
  ShowParamAct.Execute;
end;

procedure TWrtControlForm.SaveToIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  Ini.WriteInteger(SName,'CtrlByte',ControlNrEdit.Value);
  Ini.WriteString(SName,'CtrlValue',ControlValueEdit.Text);
end;

procedure TWrtControlForm.LoadFromIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  ControlNrEdit.Value := Ini.ReadInteger(SName,'CtrlByte',ControlNrEdit.Value);
  ControlValueEdit.Text := Ini.ReadString(SName,'CtrlValue',ControlValueEdit.Text);
end;

procedure TWrtControlForm.RdSemafActExecute(Sender: TObject);
var
  st : TStatus;
  V  : byte;
begin
  inherited;
  st :=Dev.ReadCtrl(Handle,ControlNrEdit.Value,V);
  ControlValueEdit.Text := '0x'+INtToHex(V,2);
  DoMsg(Caption+':'+Dev.GetErrStr(st));
end;

procedure TWrtControlForm.WrSemafActExecute(Sender: TObject);
var
  st : TStatus;
  V  : Integer;
begin
  inherited;
  V := StrToIntChex(ControlValueEdit.Text);
  st :=Dev.WriteCtrl(Handle,ControlNrEdit.Value,V);
  DoMsg(Caption+':'+Dev.GetErrStr(st));
end;

procedure TWrtControlForm.RdVecActExecute(Sender: TObject);
var
  Vec : Cardinal;
  S   : string;
  st  :TStatus;
begin
  inherited;
  st := Dev.ReadS(Handle,S,Vec);
  if st=stOk then
  begin
    StatusText.Text := S;
    VectorTxt.Text  := Format('%.8X',[Vec]);
  end
  else
  begin
    StatusText.Text :='???';
    VectorTxt.Text := '???';
    DoMsg('ReadStatus:'+Dev.GetErrStr(st));
  end;
end;
procedure TWrtControlForm.RdSemafActUpdate(Sender: TObject);
var
  q : boolean;
begin
  inherited;
  q := false;
  if Dev<>nil then
    q := Dev.Connected;
  (Sender  as TAction).Enabled := q;
end;

end.
