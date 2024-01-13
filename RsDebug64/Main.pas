unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  System.Contnrs,
  Dialogs, ActnList, StdCtrls, ComCtrls, ExtCtrls, Menus, ToolWin, IniFiles,
  SettingUnit,
  TypeDefEditUnit,
  ProgCfgUnit,
  MapParserUnit,
  RsdDll,
  CommThreadUnit,
  MemUnit,
  VarListUnit,
  TypeDefUnit,
  RmtChildUnit,
  StructShowUnit,
  UpLoadFileUnit,
  WavGenUnit,
  UpLoadDefUnit,
  RfcUnit,
  About,
  Registry,
  System.JSON,
  ImgList, System.ImageList, System.Actions,
  ExtG2MemoUnit,
  JSonUtils,
  CallProcessUnit;

type
  TMainForm = class(TForm, IMainWinInterf)
    ActionList1: TActionList;
    StatusBar1: TStatusBar;
    SplitterBottom: TSplitter;
    MainMenu1: TMainMenu;
    Fiel1: TMenuItem;
    Exit1: TMenuItem;
    RZ301: TMenuItem;
    SetConnStrItem: TMenuItem;
    Pami1: TMenuItem;
    ReopenMapFileItem: TMenuItem;
    OpenMapFileItem: TMenuItem;
    SettingItem: TMenuItem;
    SaveSettings: TMenuItem;
    ReloadMapFileItem: TMenuItem;
    N1: TMenuItem;
    VarListItem: TMenuItem;
    definicje1: TMenuItem;
    DefTypesItem: TMenuItem;
    ImportTypesItem: TMenuItem;
    Struktury1: TMenuItem;
    N2: TMenuItem;
    UpLoadFileItem: TMenuItem;
    N3: TMenuItem;
    Definicjioperacji1: TMenuItem;
    OknoItem: TMenuItem;
    MinimizeAllAct: TAction;
    CloseAllAct: TAction;
    Minimizeall1: TMenuItem;
    Closeall1: TMenuItem;
    SplitWindowitem: TMenuItem;
    SygGenItem: TMenuItem;
    Oprogramie1: TMenuItem;
    ConnectAct: TAction;
    GetDrvParamsAct: TAction;
    Pokaparametrydrivera1: TMenuItem;
    SetDrvParamsAct: TAction;
    Ustawparametrydrivera1: TMenuItem;
    WinTabPanel: TPanel;
    WinTabControl: TTabControl;
    WinTabMenu: TPopupMenu;
    MinimizeAllItem: TMenuItem;
    N5: TMenuItem;
    CloseItem: TMenuItem;
    MinimizeItem: TMenuItem;
    RestoreItem: TMenuItem;
    MinimizeAct: TAction;
    CloseAct: TAction;
    RestoreAct: TAction;
    RestoreAllAct: TAction;
    RestoreAll1: TMenuItem;
    CoolBar1: TCoolBar;
    N7: TMenuItem;
    erminal1: TMenuItem;
    TerminalAct: TAction;
    PictureWinAct: TAction;
    MemoryWinAct: TAction;
    VarListWinAct: TAction;
    StructWinAct: TAction;
    GeneratorWinAct: TAction;
    UploadWinAct: TAction;
    Obraz1: TMenuItem;
    ButtonBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ImageList1: TImageList;
    SaveWorkSpaceAct: TAction;
    SettingsAct: TAction;
    RefreshMapFileAct: TAction;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ModbusStd1: TMenuItem;
    MemRegistersAct: TAction;
    MemAnalogInputAct: TAction;
    MemCoilAct: TAction;
    MemBinaryInputAct: TAction;
    BinaryInputs1: TMenuItem;
    Coils1: TMenuItem;
    AnalogInputs1: TMenuItem;
    Registers1: TMenuItem;
    actRZ40EventReader: TAction;
    N4: TMenuItem;
    Rz40EventReader1: TMenuItem;
    RfcWinAct: TAction;
    RfcExecute1: TMenuItem;
    ConnectionconfigAct: TAction;
    ConnectBtn: TToolButton;
    BottomPanel: TPanel;
    ToolButton8: TToolButton;
    OpenMapFile: TAction;
    Deleteallclosedwindows1: TMenuItem;
    RestoreAllClosedWinAct: TAction;
    DeleteAllClosedWinAct: TAction;
    Restoreallclosedwindows1: TMenuItem;
    ToolButton5: TToolButton;
    OpenWorkSpaceAct: TAction;
    ToolButton6: TToolButton;
    SaveWorkSpaceAsAct: TAction;
    N8: TMenuItem;
    Openworkspace1: TMenuItem;
    Saveworkspaceas1: TMenuItem;
    N6: TMenuItem;
    ReopenWorkspaceItem: TMenuItem;
    ToolButton7: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    OnLine1: TMenuItem;
    Pocz1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure DefTypesItemClick(Sender: TObject);
    procedure ImportTypesItemClick(Sender: TObject);
    procedure MinimizeAllActExecute(Sender: TObject);
    procedure CloseAllActExecute(Sender: TObject);
    procedure OknoItemClick(Sender: TObject);
    procedure Oprogramie1Click(Sender: TObject);
    procedure EditConnectionActUpdate(Sender: TObject);
    procedure GetDrvParamsActExecute(Sender: TObject);
    procedure GetDrvParamsActUpdate(Sender: TObject);
    procedure SetDrvParamsActExecute(Sender: TObject);
    procedure MinimizeActExecute(Sender: TObject);
    procedure CloseActExecute(Sender: TObject);
    procedure RestoreActExecute(Sender: TObject);
    procedure RestoreAllActExecute(Sender: TObject);
    procedure WinTabControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure TerminalActUpdate(Sender: TObject);
    procedure TerminalActExecute(Sender: TObject);
    procedure MemoryWinActUpdate(Sender: TObject);
    procedure MemoryWinActExecute(Sender: TObject);
    procedure VarListWinActExecute(Sender: TObject);
    procedure StructWinActExecute(Sender: TObject);
    procedure GeneratorWinActExecute(Sender: TObject);
    procedure UploadWinActExecute(Sender: TObject);
    procedure PictureWinActExecute(Sender: TObject);
    procedure SaveWorkSpaceActExecute(Sender: TObject);
    procedure SettingsActExecute(Sender: TObject);
    procedure RefreshMapFileActExecute(Sender: TObject);
    procedure RefreshMapFileActUpdate(Sender: TObject);
    procedure MemBinaryInputActExecute(Sender: TObject);
    procedure MemCoilActExecute(Sender: TObject);
    procedure MemAnalogInputActExecute(Sender: TObject);
    procedure MemRegistersActExecute(Sender: TObject);
    procedure actRZ40EventReaderExecute(Sender: TObject);
    procedure RfcWinActExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ConnectActExecute(Sender: TObject);
    procedure ConnectionconfigActExecute(Sender: TObject);
    procedure ConnectionconfigActUpdate(Sender: TObject);
    procedure OpenMapFileExecute(Sender: TObject);
    procedure RestoreAllClosedWinActUpdate(Sender: TObject);
    procedure DeleteAllClosedWinActUpdate(Sender: TObject);
    procedure DeleteAllClosedWinActExecute(Sender: TObject);
    procedure RestoreAllClosedWinActExecute(Sender: TObject);
    procedure ConnectActUpdate(Sender: TObject);
    procedure OpenWorkSpaceActExecute(Sender: TObject);
    procedure SaveWorkSpaceAsActExecute(Sender: TObject);
    procedure Fiel1Click(Sender: TObject);
    procedure SetDrvParamsActUpdate(Sender: TObject);
  private
    function GetDev: TCmmDevice;
    function GetCommThread: TCommThread;
    procedure Msg(s: string);
  private
    function CfgProcWriteToJson: TJSONBuilder;
    procedure CfgProcLoadFromJson(jLoader: TJSonLoader);
  private
    FirstTime: boolean;
    ExtMemo: TExtG2Memo;
    PipeToStrings: TPipeToStrings;
    StatrtTick: cardinal;
    procedure ProgCfgOnActivateAplic(Sender: TObject);
    procedure OnReOpenMapFileClickProc(Sender: TObject);
    procedure OnReOpenWorkSpaceClickProc(Sender: TObject);

    procedure OnReloadedProc(Sender: TObject);
    function GetSName(N: integer): string;
    procedure RestoreClosedWinProc(Sender: TObject);
    procedure SetupWinTabs;
    function isDevConnected: boolean;
    function isDevReady: boolean;
    procedure UpdateStatusBarConnInfoStr;
    procedure AfterConnChanged;
    function CreateChildForm(WinType: string): TChildForm;
    procedure RestoreFromClosedList(Idx: integer);
    procedure InitConnectionDev;
    function CreateChildWindow(ChildClass: TChildFormClass): TChildForm;

  public
    Dev: TCmmDevice;
    CommThread: TCommThread;

    procedure NL(s: string);
    procedure NL_T(s: string);

    procedure ADL(s: string);
    procedure ReloadMap;

    procedure WMTypeDefChg(var Msg: TMessage); message wm_TypeDefChg;
    procedure WMSettingsChg(var Msg: TMessage); message wm_SettingsChg;
    procedure WMShowMemWin(var Msg: TMessage); message wm_ShowmemWin;
    procedure WMShowStruct(var Msg: TMessage); message wm_ShowStruct;
    procedure WMChildCaption(var Msg: TMessage); message wm_ChildCaption;
    procedure WMChildClosed(var Msg: TMessage); message wm_ChildClosed;

  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  ElfParserUnit,
  Rsd64Definitions,
  Rz40EventsUnit,
  EditDrvParamsUnit,
  PictureView,
  TerminalUnit,
  RegMemUnit,
  BinaryMemUnit,
  OpenConnectionDlgUnit,
  ShowDrvInfoUnit;

function GetComNr(s: string): integer;
begin
  Result := StrToInt(copy(s, 4, length(s) - 3));
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin

  StatrtTick := GetTickCount;
  FirstTime := true;
  ProgCfg.OnWriteJsonCfg := CfgProcWriteToJson;
  ProgCfg.OnReadJsonCfg := CfgProcLoadFromJson;
  Application.OnActivate := ProgCfgOnActivateAplic;
  MapParser.OnReloaded := OnReloadedProc;
  Dev := nil;
  CommThread := TCommThread.Create;
  ExtMemo := TExtG2Memo.Create(self);
  ExtMemo.Name := 'BottomExtMemo';
  ExtMemo.Parent := BottomPanel;
  ExtMemo.Align := alClient;

  PipeToStrings := TPipeToStrings.Create(true);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  PipeToStrings.Free;
  if Assigned(Dev) then
    Dev.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  RsdSetLoggerHandle(ExtMemo.PipeInHandle,ExtMemo.AnsiPipeInHandle);
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  if FirstTime then
  begin
    FirstTime := false;
    ProgCfg.OpenWorkSpaceFromWorkingDir;

    SetupWinTabs;
    ExtMemo.SetCharSet;

    if ProgCfg.LoadMapFileOnStartUp then
    begin
      if ProgCfg.ReOpenMapfileList.Count > 0 then
      begin
        MapParser.LoadMapFile(ProgCfg.WorkingMap);
      end;
    end;

  end
end;

procedure TMainForm.InitConnectionDev;
var
  txt: string;
begin
  if Assigned(Dev) then
    FreeAndNil(Dev);

  Dev := TCmmDevice.Create(Handle, ProgCfg.DevString);
  if Dev.isDevReady then
  begin
    txt := ProgCfg.getDriverParams(Dev.getDriverName);
    Dev.SetDrvParams(txt);

    CommThread.SetDev(Dev);
  end
  else
  begin
    FreeAndNil(Dev);
  end;
  UpdateStatusBarConnInfoStr;
end;

procedure TMainForm.ConnectActExecute(Sender: TObject);
var
  st: TStatus;
  memConnected: boolean;
begin
  if Assigned(Dev) then
  begin
    memConnected := isDevConnected;
    if isDevConnected then
    begin
      Dev.CloseDev;
    end
    else
    begin
      st := Dev.OpenDev;
      NL(Format('OpenDev [%s]=%s', [Dev.getDriverName, Dev.GetErrStr(st)]));
    end;
    ConnectBtn.Down := isDevConnected;
    if memConnected <> isDevConnected then
      AfterConnChanged;
  end;
  UpdateStatusBarConnInfoStr;
end;

procedure TMainForm.ConnectActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(Dev);
end;

procedure TMainForm.ConnectionconfigActExecute(Sender: TObject);
var
  Dlg: TOpenConnectionDlg;
  dStr: string;
begin
  Dlg := TOpenConnectionDlg.Create(self);
  try
    Dlg.SetConfig(ProgCfg.DevString);
    if Dlg.ShowModal = mrOk then
    begin
      if Dlg.GetConfig(dStr) then
      begin
        ProgCfg.DevString := dStr;
        if Assigned(Dev) then
          FreeAndNil(Dev);
        InitConnectionDev;
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.ProgCfgOnActivateAplic(Sender: TObject);
begin
  ReloadMap;
end;

function TMainForm.GetDev: TCmmDevice;
begin
  Result := Dev;
end;

function TMainForm.GetCommThread: TCommThread;
begin
  Result := CommThread;
end;

procedure TMainForm.Msg(s: string);
begin
  NL(s);
end;

procedure TMainForm.Fiel1Click(Sender: TObject);
begin
  ProgCfg.ReOpenMapfileList.AddToMenuItem(0, ReopenMapFileItem, OnReOpenMapFileClickProc);
  ProgCfg.ReOpenWorkspaceList.AddToMenuItem(0, ReopenWorkspaceItem, OnReOpenWorkSpaceClickProc);
end;


procedure TMainForm.AfterConnChanged;
var
  i: integer;
begin
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TChildForm then
    begin
      (MDIChildren[i] as TChildForm).AfterConnChanged;
    end;
  end;
end;

procedure TMainForm.WMTypeDefChg(var Msg: TMessage);
var
  i: integer;
begin
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TChildForm then
    begin
      (MDIChildren[i] as TChildForm).TypeDefChg;
    end;
  end;
end;

procedure TMainForm.SetupWinTabs;
begin
  case ProgCfg.WinTab of
    wtOFF:
      begin
        WinTabPanel.Visible := false;
      end;
    wtTOP:
      begin
        WinTabPanel.Visible := true;
        WinTabPanel.Align := alTop;
        WinTabControl.TabPosition := tpTop;
      end;
    wtBOTTOM:
      begin
        WinTabPanel.Visible := true;
        WinTabPanel.Align := alBottom;
        WinTabControl.TabPosition := tpBottom;
      end;
  end;
end;

procedure TMainForm.WMSettingsChg(var Msg: TMessage);
var
  i: integer;
begin
  SetupWinTabs;
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TChildForm then
    begin
      (MDIChildren[i] as TChildForm).SettingChg;
    end;
  end;
end;

procedure TMainForm.ReloadMap;
var
  q: TYesNoAsk;
  R: integer;
  s: string;
begin
  if MapParser = nil then
    Exit;
  if MapParser.NeedReload then
  begin
    q := ProgCfg.AutoRefreshMap;
    if q = crASK then
    begin
      s := 'Plik MAP ulegl zmianie.' + #13 + 'Czy za³adowaæ go ponownie ?';
      R := Application.MessageBox(pchar(s), 'OnActivate', mb_yesNo);
      case R of
        idYes:
          q := crYES;
        idNo:
          q := crNo;
      end;
    end;
    if q = crYES then
    begin
      RefreshMapFileAct.Execute;
    end;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  q: TYesNoAsk;
  R: integer;
  DoExit: boolean;
  s: string;
begin
  Action := caFree;
  q := ProgCfg.AutoSaveCfg;
  if q = crASK then
  begin
    R := Application.MessageBox('Czy zapisaæ ustawienia ?', 'Zamknij', mb_yesNoCancel);
    case R of
      idYes:
        q := crYES;
      idNo:
        q := crNo;
      idCancel:
        Action := caNone;
    end;
  end;

  if (Action = caFree) and (q = crYES) then
  begin
    repeat
      try
        ProgCfg.SaveWorkspace;
        DoExit := true;
      except
        DoExit := false;
        s := (ExceptObject as Exception).Message + #13 + 'Powtórzyæ ?';
        if Application.MessageBox(pchar(s), 'Error', mb_yesNo or MB_ICONHAND) = idNo then
        begin
          DoExit := true;
        end;
      end;
    until DoExit;
  end;
  if (Action = caFree) and (Dev <> nil) then
  begin
    Dev.CloseDev;
  end;
end;

procedure TMainForm.NL(s: string);
begin
  ExtMemo.Print(s + '\n');
end;

procedure TMainForm.NL_T(s: string);
var
  tt: double;
  s2: string;
begin
  tt := (GetTickCount - StatrtTick) / 1000.0;
  s2 := Format('%7.3f %s', [tt, s]) + '\n';
  ExtMemo.PrintToPipe(s2);
end;

procedure TMainForm.ADL(s: string);
begin
  ExtMemo.Print(s);
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.EditConnectionActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not(isDevReady);
end;

procedure TMainForm.MemoryWinActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(Dev) and Dev.isMemFunctions;
end;

procedure TMainForm.WMShowMemWin(var Msg: TMessage);
var
  Win: TMemForm;
  AdrCpx1: TAdrCpx;
begin
  Win := CreateChildWindow(TMemForm) as TMemForm;
  AdrCpx1 := PAdrCpx(Msg.WParam)^;
  Win.ShowMem(AdrCpx1);
end;

procedure TMainForm.WMShowStruct(var Msg: TMessage);
var
  Win: TStructShowForm;
  AdrCpx1: TAdrCpx;
begin
  Win := CreateChildWindow(TStructShowForm) as TStructShowForm;
  AdrCpx1 := PAdrCpx(Msg.WParam)^;
  Win.SetStruct(AdrCpx1.Adres, THType(Msg.LParam));
end;

procedure TMainForm.WMChildCaption(var Msg: TMessage);
var
  Obj: TChildForm;
  N: integer;
begin
  Obj := TChildForm(Msg.WParam);
  N := WinTabControl.Tabs.IndexOfObject(Obj);
  if N < 0 then
    N := WinTabControl.Tabs.AddObject(Obj.Caption, Obj)
  else
    WinTabControl.Tabs.Strings[N] := Obj.Caption;
  WinTabControl.TabIndex := N;
end;

procedure TMainForm.WMChildClosed(var Msg: TMessage);
var
  Obj: TChildForm;
  N: integer;
begin
  Obj := TChildForm(Msg.WParam);
  N := WinTabControl.Tabs.IndexOfObject(Obj);
  if N >= 0 then
    WinTabControl.Tabs.Delete(N);
end;

function TMainForm.CreateChildWindow(ChildClass: TChildFormClass): TChildForm;
var
  i: integer;
  TemplateWin: TChildForm;
begin
  TemplateWin := nil;
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is ChildClass then
    begin
      TemplateWin := MDIChildren[i] as TChildForm;
      break;
    end;
  end;
  Result := ChildClass.CreateIterf(self, self, TemplateWin);
end;

procedure TMainForm.MemoryWinActExecute(Sender: TObject);
begin
  CreateChildWindow(TMemForm);
end;

procedure TMainForm.VarListWinActExecute(Sender: TObject);
begin
  CreateChildWindow(TVarListForm);
end;

procedure TMainForm.StructWinActExecute(Sender: TObject);
begin
  CreateChildWindow(TStructShowForm);
end;

procedure TMainForm.GeneratorWinActExecute(Sender: TObject);
begin
  CreateChildWindow(TWavGenForm);
end;

procedure TMainForm.PictureWinActExecute(Sender: TObject);
begin
  CreateChildWindow(TPictureViewForm);
end;

procedure TMainForm.UploadWinActExecute(Sender: TObject);
begin
  CreateChildWindow(TUpLoadFileForm);
end;

function TMainForm.GetSName(N: integer): string;
begin
  Result := Format('Win_%u', [N]);
end;

function getChildClass(WinType: string): TChildFormClass;
begin
  if WinType = 'TMemForm' then
    Result := TMemForm
  else if WinType = 'TVarListForm' then
    Result := TVarListForm
  else if WinType = 'TStructShowForm' then
    Result := TStructShowForm
  else if WinType = 'TWavGenForm' then
    Result := TWavGenForm
  else if WinType = 'TTerminalForm' then
    Result := TTerminalForm
  else if WinType = 'TPictureViewForm' then
    Result := TPictureViewForm
  else if WinType = 'TRegMemForm' then
    Result := TRegMemForm
  else if WinType = 'TBinaryMemForm' then
    Result := TBinaryMemForm
  else if WinType = 'TRz40EventsForm' then
    Result := TRz40EventsForm
  else if WinType = 'TRfcForm' then
    Result := TRfcForm
  else
    Result := nil;
end;

function TMainForm.CreateChildForm(WinType: string): TChildForm;
var
  ChildClass: TChildFormClass;
begin
  Result := nil;
  ChildClass := getChildClass(WinType);
  if Assigned(ChildClass) then
    Result := CreateChildWindow(ChildClass)
end;

procedure TMainForm.CfgProcLoadFromJson(jLoader: TJSonLoader);
var
  jArr: TJSonArray;
  i: integer;
  jChild: TJSonLoader;
  WinType: string;
  Dlg: TChildForm;
  Win: TClosedWin;

begin
  if Assigned(Dev) then
  begin
    Dev.CloseDev;
    FreeAndNil(Dev);
  end;
  ConnectAct.Checked := false;
  ConnectBtn.Down := false;

  jLoader.Load_TLWH(self);
  BottomPanel.Height := jLoader.LoadDef('MemoHeight', BottomPanel.Height);

  ExtMemo.AddTimeToLog := jLoader.LoadDef('AddTimeToLog', ExtMemo.AddTimeToLog);
  ExtMemo.ScrollToEnd := jLoader.LoadDef('ScrollToEnd', ExtMemo.ScrollToEnd);

  // Child okienka
  for i := MDIChildCount - 1 downto 0 do
  begin
    if MDIChildren[i] is TChildForm then
    begin
      (MDIChildren[i] as TChildForm).NoAddToClosedList;
    end;
    MDIChildren[i].Close;
  end;

  jArr := jLoader.getArray('ChildForms');
  if Assigned(jArr) then
  begin
    for i := 0 to jArr.Count - 1 do
    begin
      if jChild.Init(jArr.Items[i]) then
      begin
        if jChild.Load(JSON_WIN_TYPE, WinType) then
        begin
          Dlg := CreateChildForm(WinType);
          if Dlg <> nil then
            Dlg.LoadFromJson(jChild);
        end;
      end;
    end;
  end;

  // GlobTypeList.LoadfromIni(Ini);
  // UpLoadList.LoadfromIni(Ini);

  ProgCfg.ReOpenMapfileList.AddToMenuItem(0, ReopenMapFileItem, OnReOpenMapFileClickProc);
  ProgCfg.ReOpenWorkspaceList.AddToMenuItem(0, ReopenWorkspaceItem, OnReOpenWorkSpaceClickProc);

  Caption := ProgCfg.GetWorkSpacefile;
  InitConnectionDev;
end;

function TMainForm.CfgProcWriteToJson: TJSONBuilder;
var
  jArr: TJSonArray;
  i: integer;
begin
  Result.Init;
  Result.Add_TLWH(self);
  Result.Add('MemoHeight', BottomPanel.Height);
  Result.Add('UpLoadList', UpLoadList.GetJSONObject);
  Result.Add('AddTimeToLog', ExtMemo.AddTimeToLog);
  Result.Add('ScrollToEnd', ExtMemo.ScrollToEnd);

  Result.Add('UpLoadList', UpLoadList.GetJSONObject);

  jArr := TJSonArray.Create;
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TChildForm then
    begin
      jArr.AddElement((MDIChildren[i] as TChildForm).GetJSONObject.jObj);
    end;
  end;
  Result.Add('ChildForms', jArr);

  // GlobTypeList.SaveToIni(Ini);
end;

function TMainForm.isDevConnected: boolean;
begin
  Result := Assigned(Dev) and Dev.Connected;
end;

function TMainForm.isDevReady: boolean;
begin
  Result := Assigned(Dev) and Dev.isDevReady;
end;

procedure TMainForm.OnReOpenMapFileClickProc(Sender: TObject);
var
  FName: string;
begin
  FName := ProgCfg.ReOpenMapfileList.GetFileName(Sender as TMenuItem);
  ProgCfg.ReOpenMapfileList.AddFile(FName);
  ProgCfg.WorkingMap := FName;
  MapParser.LoadMapFile(FName);
end;

procedure TMainForm.OnReOpenWorkSpaceClickProc(Sender: TObject);
var
  FName: string;
begin
  FName := ProgCfg.ReOpenWorkspaceList.GetFileName(Sender as TMenuItem);
  ProgCfg.OpenWorkspace(FName);
end;

procedure TMainForm.OnReloadedProc(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TChildForm then
    begin
      (MDIChildren[i] as TChildForm).ReloadVarList;
    end;
  end;
end;

procedure TMainForm.OpenMapFileExecute(Sender: TObject);
var
  Dlg: TOpenDialog;
  FName: string;
begin
  FName := '';
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.DefaultExt := '.map';
    Dlg.Filter := 'elf file|*.elf|MAP file|*.map|Keil 8051|*.m51';
    if Dlg.Execute then
      FName := Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if FName <> '' then
  begin
    ProgCfg.ReOpenMapfileList.AddFile(FName);
    ProgCfg.WorkingMap := FName;
    MapParser.LoadMapFile(FName);
  end;
end;

procedure TMainForm.OpenWorkSpaceActExecute(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.Filter := 'WorkSpace configuration|*.rsd';
    if Dlg.Execute then
    begin
      ProgCfg.OpenWorkspace(Dlg.FileName);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.SaveWorkSpaceAsActExecute(Sender: TObject);
var
  Dlg: TSaveDialog;
  FName: string;
begin
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.Filter := 'WorkSpace configuration|*.rsd';
    if Dlg.Execute then
    begin
      FName := ChangeFileExt(Dlg.FileName, '.rsd');
      ProgCfg.SaveWorkspaceAs(FName);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.SettingsActExecute(Sender: TObject);
var
  Dlg: TSettingForm;
begin
  Dlg := TSettingForm.Create(self);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.SaveWorkSpaceActExecute(Sender: TObject);
begin
  ProgCfg.SaveWorkspace;
end;

procedure TMainForm.RefreshMapFileActExecute(Sender: TObject);
begin
  if MapParser.LoadMapFile then
    NL('Load map file :' + MapParser.FileName);
end;

procedure TMainForm.RefreshMapFileActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := MapParser.isLoaded;
end;

procedure TMainForm.DefTypesItemClick(Sender: TObject);
var
  W: TTypeDefEditForm;
  i: integer;
begin
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TTypeDefEditForm then
    begin
      if (MDIChildren[i] as TTypeDefEditForm).MyData then
      begin
        MDIChildren[i].BringToFront;
        Exit;
      end;
    end;
  end;

  W := CreateChildWindow(TTypeDefEditForm) as TTypeDefEditForm;
  W.LoadTypeDefTree(GlobTypeList);
  W.Caption := 'Definicje typów';
end;

procedure TMainForm.DeleteAllClosedWinActExecute(Sender: TObject);
begin
  if Application.MessageBox('Do you want delete all closed windows ?', 'Question', mb_yesNo) = idYes then
    ProgCfg.ClosedWinList.Clear;
end;

procedure TMainForm.DeleteAllClosedWinActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (ProgCfg.ClosedWinList.Count > 0);

end;

procedure TMainForm.ImportTypesItemClick(Sender: TObject);
var
  W: TTypeDefEditForm;
  H: THTypeList;
  Dlg: TOpenDialog;
  FName: string;
  Ini: TDotIniFile;
begin
  FName := '';
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.Filter := 'pliki ini|*.ini';
    if Dlg.Execute then
      FName := Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if FName <> '' then
  begin
    H := THTypeList.CreateSys;
    Ini := TDotIniFile.Create(FName);
    try
      H.LoadfromIni(Ini);
      W := CreateChildWindow(TTypeDefEditForm) as TTypeDefEditForm;
      W.LoadTypeDefTree(H);
      W.Caption := FName;
    finally
      H.Free;
      Ini.Free;
    end;
  end;
end;

procedure TMainForm.MinimizeAllActExecute(Sender: TObject);
var
  i: integer;
begin
  for i := MDIChildCount - 1 downto 0 do
  begin
    MDIChildren[i].WindowState := wsMinimized;
  end;
end;

procedure TMainForm.RestoreAllActExecute(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to MDIChildCount - 1 do
  begin
    MDIChildren[i].WindowState := wsNormal;
  end;
end;

procedure TMainForm.RestoreAllClosedWinActExecute(Sender: TObject);
var
  Idx: integer;
begin
  for Idx := ProgCfg.ClosedWinList.Count - 1 downto 0 do
    RestoreFromClosedList(Idx);
end;

procedure TMainForm.RestoreAllClosedWinActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (ProgCfg.ClosedWinList.Count > 0);
end;

procedure TMainForm.CloseAllActExecute(Sender: TObject);
var
  i: integer;
begin
  for i := MDIChildCount - 1 downto 0 do
  begin
    MDIChildren[i].Close;
  end;
end;

procedure TMainForm.MinimizeActExecute(Sender: TObject);
var
  N: integer;
  Win: TChildForm;
begin
  N := WinTabControl.TabIndex;
  Win := WinTabControl.Tabs.Objects[N] as TChildForm;
  Win.WindowState := wsMinimized;
end;

procedure TMainForm.CloseActExecute(Sender: TObject);
var
  N: integer;
  Win: TChildForm;
begin
  N := WinTabControl.TabIndex;
  Win := WinTabControl.Tabs.Objects[N] as TChildForm;
  Win.Close;
end;

procedure TMainForm.RestoreActExecute(Sender: TObject);
var
  N: integer;
  Win: TChildForm;
begin
  N := WinTabControl.TabIndex;
  Win := WinTabControl.Tabs.Objects[N] as TChildForm;
  Win.WindowState := wsNormal;
end;

procedure TMainForm.OknoItemClick(Sender: TObject);
begin
  ProgCfg.ClosedWinList.AddMenuItems(OknoItem, RestoreClosedWinProc);
end;

procedure TMainForm.RestoreClosedWinProc(Sender: TObject);
var
  Idx: integer;
begin
  Idx := (Sender as TMenuItem).Tag - 10;
  RestoreFromClosedList(Idx);
end;

procedure TMainForm.RestoreFromClosedList(Idx: integer);
var
  Item: TClosedWin;
  Dlg: TChildForm;
  jLoader: TJSonLoader;
begin
  if (Idx >= 0) and (Idx < ProgCfg.ClosedWinList.Count) then
  begin
    Item := ProgCfg.ClosedWinList.Items[Idx];
    Dlg := CreateChildForm(Item.WinType);
    if Dlg <> nil then
    begin
      jLoader.Init(Item.jObj);
      Dlg.LoadFromJson(jLoader);
    end;
    ProgCfg.ClosedWinList.Delete(Idx);
  end;
end;

procedure TMainForm.Oprogramie1Click(Sender: TObject);
begin
  ShowAboutDlg;
end;

procedure TMainForm.GetDrvParamsActExecute(Sender: TObject);
var
  Dlg: TShowDrvInfoForm;
  s: string;
  ParValue: string;
  SL: TStringList;
  i: integer;
begin
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TShowDrvInfoForm then
    begin
      Dlg := MDIChildren[i] as TShowDrvInfoForm;
      Dlg.BringToFront;
      break;
    end;
  end;
  if not Assigned(Dlg) then
  begin
    Dlg := TShowDrvInfoForm.CreateIterf(self, self);
    Dlg.Show;
  end;
end;

procedure TMainForm.GetDrvParamsActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(Dev) and Dev.isDevReady
end;

procedure TMainForm.SetDrvParamsActExecute(Sender: TObject);
var
  i: integer;
  Dlg: TEditDrvParamsForm;
begin
  if Assigned(Dev) then
  begin
    Dlg := TEditDrvParamsForm.Create(self);
    try
      Dlg.SetMainWinInterf(self);
      Dlg.ShowModal;
    finally
      Dlg.Free;
    end;
  end;
end;

procedure TMainForm.SetDrvParamsActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(Dev) and Dev.isDevReady;
end;

procedure TMainForm.WinTabControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  nr: integer;
  Win: TChildForm;
begin
  if Button = mbLeft then
  begin
    nr := WinTabControl.IndexOfTabAt(X, Y);
    if nr >= 0 then
    begin
      Win := (Sender as TTabControl).Tabs.Objects[nr] as TChildForm;
      if Win.WindowState = wsMinimized then
      begin
        Win.WindowState := wsNormal;
      end
      else
      begin
        if Win = MDIChildren[0] then
        begin
          Win.WindowState := wsMinimized;
        end;
      end;
      Win.BringToFront;
    end;
  end;
end;

procedure TMainForm.TerminalActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(Dev) and Dev.isTerminalFunctions;
end;

procedure TMainForm.TerminalActExecute(Sender: TObject);
begin
  CreateChildWindow(TTerminalForm);
end;

procedure TMainForm.MemBinaryInputActExecute(Sender: TObject);
var
  Win: TBinaryMemForm;
begin
  Win := CreateChildWindow(TBinaryMemForm) as TBinaryMemForm;
  Win.SetMemType(bmBINARYINP);
end;

procedure TMainForm.MemCoilActExecute(Sender: TObject);
var
  Win: TBinaryMemForm;
begin
  Win := CreateChildWindow(TBinaryMemForm) as TBinaryMemForm;
  Win.SetMemType(bmCOILS);
end;

procedure TMainForm.MemAnalogInputActExecute(Sender: TObject);
var
  Win: TRegMemForm;
begin
  Win := CreateChildWindow(TRegMemForm) as TRegMemForm;
  Win.SetMemType(rmANALOGINP);
end;

procedure TMainForm.MemRegistersActExecute(Sender: TObject);
var
  Win: TRegMemForm;
begin
  Win := CreateChildWindow(TRegMemForm) as TRegMemForm;
  Win.SetMemType(rmREGISTERS);
end;

procedure TMainForm.actRZ40EventReaderExecute(Sender: TObject);
begin
  CreateChildWindow(TRz40EventsForm);
end;

procedure TMainForm.RfcWinActExecute(Sender: TObject);
begin
  CreateChildWindow(TRfcForm);
end;

procedure TMainForm.UpdateStatusBarConnInfoStr;
var
  ConnInfoStr: string;
begin
  if ExtractConnInfoStr(ProgCfg.DevString, ConnInfoStr) then
    StatusBar1.Panels[1].Text := ConnInfoStr;
  if Assigned(Dev) then
  begin
    if Dev.Connected then
      StatusBar1.Panels[2].Text := 'Open'
    else
      StatusBar1.Panels[2].Text := 'Close'
  end
  else
    StatusBar1.Panels[2].Text := 'Driverr error';
end;

procedure TMainForm.ConnectionconfigActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not(isDevConnected);
end;

end.
