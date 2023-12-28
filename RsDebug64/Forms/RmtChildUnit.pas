unit RmtChildUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, StdCtrls,
  Dialogs, IniFiles, RsdDll, CommThreadUnit, ImgList, ComCtrls, ActnList, ToolWin, ExtCtrls,
  ProgCfgUnit, System.ImageList, System.Actions,
  System.JSON,
  JSonUtils;

type
  IMainWinInterf = interface
    ['{A948FC8E-E75C-4C9C-BF4C-CE4B7D0CDBE2}']
    function GetDev: TCmmDevice;
    function GetCommThread: TCommThread;
    procedure Msg(s: string);
    function FindIniDrvPrmSection(s: string): string;
  end;

  TOnMsg = procedure(s: string) of object;

  TChildForm = class(TForm)
    StatusBar: TStatusBar;
    ActionList2: TActionList;
    EditTitleAct: TAction;
    ToolBar1: TToolBar;
    TitleBtn: TToolButton;
    ToolButton3: TToolButton;
    ParamPanel: TPanel;
    ParamPanelBtn: TToolButton;
    ShowParamAct: TAction;
    TreeImages: TImageList;
    ToolBarImgList: TImageList;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
    procedure EditTitleActExecute(Sender: TObject);
    procedure ShowParamActExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FTrnLamp: boolean;
    FProgress: real;
    MainWinInterf: IMainWinInterf;
    procedure DrawtrnLamp;
    procedure DrawProgress;
    function FGetDev: TCmmDevice;
    function FGetCommThread: TCommThread;
  protected
    Title: string;
    AdrCpx: TAdrCpx;
    procedure DoMsg(s: string);
    procedure ShowCaption; virtual;
    procedure FSetTrnLamp(ALamp: boolean);
    function IsConnected: boolean;
    procedure doParamsVisible(vis: boolean); virtual;
  public
    constructor CreateIterf(AMainWinInterf: IMainWinInterf; AOwner: TComponent);
    property Dev: TCmmDevice read FGetDev;
    function isDevConnected: boolean;
    property CommThread: TCommThread read FGetCommThread;

    procedure Start; virtual;
    procedure SaveToIni(Ini: TDotIniFile; SName: string); virtual;
    function GetJSONObject: TJSONObject; virtual;
    procedure LoadFromIni(Ini: TDotIniFile; SName: string); virtual;
    procedure ReloadMapParser; virtual;
    procedure TypeDefChg; virtual;
    procedure SettingChg; virtual;
    function GetDefaultCaption: string; virtual;
    procedure AfterConnChanged; virtual;

    procedure WMTrnsProgress(var Msg: TMessage); message wm_TrnsProgress;
    procedure WMTrnsStartStop(var Msg: TMessage); message wm_TrnsStartStop;

  end;

var
  ChildForm: TChildForm;

implementation

{$R *.dfm}

constructor TChildForm.CreateIterf(AMainWinInterf: IMainWinInterf; AOwner: TComponent);
begin
  Create(AOwner);
  MainWinInterf := AMainWinInterf;
end;

procedure TChildForm.FormDestroy(Sender: TObject);
begin
  if Assigned(Application.MainForm) then // nil jesli aplikacja zamykana
    PostMessage(Application.MainForm.Handle, wm_ChildClosed, integer(self), 0);
end;

procedure TChildForm.FormActivate(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle, wm_ChildCaption, integer(self), 0);
end;

procedure TChildForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

function TChildForm.isDevConnected: boolean;
var
  dev1: TCmmDevice;
begin
  dev1 := Dev;
  Result := Assigned(dev1) and dev1.Connected;
end;

procedure TChildForm.DoMsg(s: string);
begin
  MainWinInterf.Msg(s);
end;

procedure TChildForm.Start;
begin

end;

function TChildForm.GetDefaultCaption: string;
begin
  Result := '';
end;

procedure TChildForm.SaveToIni(Ini: TDotIniFile; SName: string);
begin
  Ini.WriteString(SName, 'WinType', ClassName);
  Ini.WriteString(SName, 'Title', Title);
  Ini.WriteInteger(SName, 'WinState', ord(WindowState));
  Ini.WriteBool(SName, 'ParamPanel', ParamPanelBtn.Down);
  if WindowState = wsNormal then
  begin
    Ini.WriteInteger(SName, 'Top', Top);
    Ini.WriteInteger(SName, 'Left', Left);
    Ini.WriteInteger(SName, 'Width', Width);
    Ini.WriteInteger(SName, 'Height', Height);
  end;
end;

function TChildForm.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('WinType', ClassName);
  Result.AddPair('Title', Title);
  Result.AddPair(CreateJsonPairInt('WinState', ord(WindowState)));
  Result.AddPair(CreateJsonPairBool('ParamPanel', ParamPanelBtn.Down));
  if WindowState = wsNormal then
    JSONAddPair_TLWH(Result,self);
end;

procedure TChildForm.LoadFromIni(Ini: TDotIniFile; SName: string);
var
  s: string;
  N: integer;
begin
  WindowState := TWindowState(Ini.ReadInteger(SName, 'WinState', ord(wsNormal)));
  Title := Ini.ReadString(SName, 'Title', '');
  Top := Ini.ReadInteger(SName, 'Top', Top);
  Left := Ini.ReadInteger(SName, 'Left', Left);
  Width := Ini.ReadInteger(SName, 'Width', Width);
  Height := Ini.ReadInteger(SName, 'Height', Height);
  ParamPanelBtn.Down := Ini.ReadBool(SName, 'ParamPanel', ParamPanelBtn.Down);
  ParamPanel.Visible := ParamPanelBtn.Down;
  ShowParamAct.Checked := ParamPanelBtn.Down;

  ShowCaption;
end;

procedure TChildForm.ReloadMapParser;
begin

end;

procedure TChildForm.TypeDefChg;
begin

end;

procedure TChildForm.AfterConnChanged;
begin

end;

procedure TChildForm.SettingChg;
begin

end;

procedure TChildForm.DrawtrnLamp;
var
  R: TRect;
begin
  R.Left := 5;
  R.Right := R.Left + StatusBar.Panels[0].Width - 12;
  R.Top := 4;
  R.Bottom := StatusBar.Height - 2;
  if FTrnLamp then
    StatusBar.Canvas.Brush.Color := clLime
  else
    StatusBar.Canvas.Brush.Color := clSilver;
  StatusBar.Canvas.Ellipse(R);
end;

procedure TChildForm.WMTrnsProgress(var Msg: TMessage);
begin
  FProgress := (Msg.WParam / 10);
  DrawProgress;
end;

procedure TChildForm.WMTrnsStartStop(var Msg: TMessage);
begin
  FTrnLamp := (Msg.WParam <> 0);
  DrawtrnLamp;
end;

procedure TChildForm.DrawProgress;
var
  R: TRect;
  R1: TRect;
  R2: TRect;
  W, x: integer;

begin
  R.Left := StatusBar.Panels[0].Width + 8;
  R.Right := R.Left + StatusBar.Panels[1].Width - 12;
  R.Top := 6;
  R.Bottom := StatusBar.Height - 4;

  if FProgress < 0 then
    FProgress := 0;
  if FProgress > 100 then
    FProgress := 100;

  W := R.Right - R.Left;
  x := round(FProgress * W / 100) + R.Left;
  R1 := R;
  R1.Right := x;
  R2 := R;
  R2.Left := x - 1;
  StatusBar.Canvas.Brush.Color := clBlue;
  StatusBar.Canvas.Rectangle(R1);
  StatusBar.Canvas.Brush.Color := clWhite;
  StatusBar.Canvas.Rectangle(R2);

  // OutputDebugString(pchar(format('F=%f',[FProgress])));
end;

procedure TChildForm.FSetTrnLamp(ALamp: boolean);
begin
  FTrnLamp := ALamp;
  DrawtrnLamp;
end;

function TChildForm.IsConnected: boolean;
begin
  Result := false;
  if Dev <> nil then
    Result := Dev.Connected;
end;

function TChildForm.FGetDev: TCmmDevice;
begin
  if Assigned(MainWinInterf) then
    Result := MainWinInterf.GetDev
  else
    Result := nil;
end;

function TChildForm.FGetCommThread: TCommThread;
begin
  Result := MainWinInterf.GetCommThread;
end;

procedure TChildForm.StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
begin
  if Panel.ID = 0 then
    DrawtrnLamp;
  if Panel.ID = 1 then
    DrawProgress;
end;

procedure TChildForm.EditTitleActExecute(Sender: TObject);
var
  s: string;
begin
  s := Title;
  if InputQuery('Title', 'Input title :', s) then
  begin
    Title := s;
    ShowCaption;
  end;
end;

procedure TChildForm.ShowCaption;
begin
  if Title <> '' then
    Caption := Title
  else
    Caption := GetDefaultCaption;
  PostMessage(Application.MainForm.Handle, wm_ChildCaption, integer(self), 0);
end;

procedure TChildForm.ShowParamActExecute(Sender: TObject);
var
  vis: boolean;
begin
  vis := not(Sender as TAction).Checked;
  (Sender as TAction).Checked := vis;
  ParamPanel.Visible := vis;
  doParamsVisible(vis);
end;

procedure TChildForm.doParamsVisible(vis: boolean);
begin

end;


end.
