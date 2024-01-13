unit TerminalUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ImgList, ActnList, ExtCtrls, StdCtrls, ComCtrls,
  ToolWin,
  ExtG2MemoUnit,
  RsdDll,
  Rsd64Definitions,
  ProgCfgUnit, System.ImageList, System.Actions, ExtGMemoUnit,
  System.JSON,
  JSonUtils,
  ErrorDefUnit;

type
  TTerminalForm = class(TChildForm)
    ReadBtn: TToolButton;
    ClearBtn: TToolButton;
    ClrTerminalAct: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure RdBoxClick(Sender: TObject);
    procedure ReadBtnClick(Sender: TObject);
    procedure ClrTerminalActExecute(Sender: TObject);
  private
    TermMemo: TExtG2Memo;
    procedure TerminalKeyPressEventProc(Sender: TObject; var Key: Char);
  protected
    function GetDefaultCaption: string; override;

  public
    function GetJSONObject: TJSONBuilder; override;
    procedure LoadfromJson(jLoader: TJSONLoader); override;

    procedure AfterConnChanged; override;
  end;

implementation

{$R *.dfm}

procedure TTerminalForm.FormCreate(Sender: TObject);
begin
  inherited;
  TermMemo := TExtG2Memo.Create(self);
  TermMemo.Parent := self;
  TermMemo.Align := alClient;
  TermMemo.SetColorScheme(ColorSchemeBlue);
  TermMemo.TerminalKeyPressEvent := TerminalKeyPressEventProc;
  TermMemo.DetectSlash := false;

end;

procedure TTerminalForm.FormActivate(Sender: TObject);
begin
  inherited;
  ShowCaption;
  if isDevConnected then
    dev.TerminalSetPipe(TERMINAL_ZERO, TermMemo.PipeInHandle);
end;

procedure TTerminalForm.TerminalKeyPressEventProc(Sender: TObject; var Key: Char);
var
  st: TStatus;
begin
  inherited;
  if IsConnected then
  begin
    st := dev.TerminalSendKey(Handle, Key);
    Key := #0;
{
    if st = stOK then
    begin
      ReadBtn.Down := true;
    end;
}
  end;
end;

procedure TTerminalForm.RdBoxClick(Sender: TObject);
begin
  inherited;
  if isDevConnected then
  begin
    if dev.TerminalSetRunFlag(TERMINAL_ZERO, ReadBtn.Down) <> stOK then
      ReadBtn.Down := false;
  end;
end;

procedure TTerminalForm.AfterConnChanged;
var
  st: TStatus;
begin
  if isDevConnected then
  begin
    st := dev.TerminalSetPipe(TERMINAL_ZERO, TermMemo.PipeInHandle);
    if st <> stOK then
      DoMsg(Format('TerminalSetPipe : %s', [dev.GetErrStr(st)]));

    st := dev.TerminalSetRunFlag(TERMINAL_ZERO, ReadBtn.Down);
    if st <> stOK then
      DoMsg(Format('TerminalSetRunFlag : %s', [dev.GetErrStr(st)]));

    if st <> stOK then
      ReadBtn.Down := false;
  end;
end;

function TTerminalForm.GetDefaultCaption: string;
begin
  Result := 'Terminal';
end;

function TTerminalForm.GetJSONObject: TJSONBuilder;
begin
  Result := inherited GetJSONObject;
  Result.Add('AddTimeToLog', TermMemo.AddTimeToLog);
  Result.Add('ScrollToEnd', TermMemo.ScrollToEnd);
  Result.Add('Logging', TermMemo.Logging);
  Result.Add('LogFileName', TermMemo.LogFileName);
end;

procedure TTerminalForm.LoadfromJson(jLoader: TJSONLoader);
var
  q: boolean;
  s: string;
begin
  inherited;
  if jLoader.Load('AddTimeToLog', q) then
    TermMemo.AddTimeToLog := q;

  if jLoader.Load('ScrollToEnd', q) then
    TermMemo.ScrollToEnd := q;

  if jLoader.Load('LogFileName', s) then
    TermMemo.LogFileName := s;

  if jLoader.Load('Logging', q) then
    TermMemo.Logging := q;
end;

procedure TTerminalForm.ReadBtnClick(Sender: TObject);
var
  st: TStatus;
begin
  inherited;
  AfterConnChanged;
end;

procedure TTerminalForm.ClrTerminalActExecute(Sender: TObject);
begin
  inherited;
  TermMemo.Clear;
end;

end.
