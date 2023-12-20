unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
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
  WrtControlUnit,
  RfcUnit,
  About,
  Registry,
  ExtGMemoUnit, ImgList, System.ImageList, System.Actions;

type
  TMainForm = class(TForm, IMainWinInterf)
    ActionList1: TActionList;
    OpenCloseDevAct: TAction;
    StatusBar1: TStatusBar;
    Splitter1: TSplitter;
    MainMenu1: TMainMenu;
    Fiel1: TMenuItem;
    Exit1: TMenuItem;
    RZ301: TMenuItem;
    Open1: TMenuItem;
    SetConnStrItem: TMenuItem;
    Pami1: TMenuItem;
    FilemapItem: TMenuItem;
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
    ala1: TMenuItem;
    SygGenItem: TMenuItem;
    Rozkazykontrolne1: TMenuItem;
    Oprogramie1: TMenuItem;
    EditConnectionAct: TAction;
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
    RefreshComListAct: TAction;
    N6: TMenuItem;
    OdwielistCOMw1: TMenuItem;
    N7: TMenuItem;
    erminal1: TMenuItem;
    TerminalAct: TAction;
    ExtMemo: TExtGMemo;
    PictureWinAct: TAction;
    MemoryWinAct: TAction;
    VarListWinAct: TAction;
    StructWinAct: TAction;
    GeneratorWinAct: TAction;
    UploadWinAct: TAction;
    ControlWinAct: TAction;
    N8: TMenuItem;
    Obraz1: TMenuItem;
    ButtonBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ImageList1: TImageList;
    SaveSettingsAct: TAction;
    SettingsAct: TAction;
    RefreshMapFileAct: TAction;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    IsModbusStdAct: TAction;
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
    ToolButton5: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure OpenMapFileItemClick(Sender: TObject);
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
    procedure WinTabControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TerminalActUpdate(Sender: TObject);
    procedure TerminalActExecute(Sender: TObject);
    procedure MemoryWinActUpdate(Sender: TObject);
    procedure MemoryWinActExecute(Sender: TObject);
    procedure VarListWinActExecute(Sender: TObject);
    procedure StructWinActExecute(Sender: TObject);
    procedure GeneratorWinActExecute(Sender: TObject);
    procedure UploadWinActExecute(Sender: TObject);
    procedure ControlWinActExecute(Sender: TObject);
    procedure PictureWinActExecute(Sender: TObject);
    procedure SaveSettingsActExecute(Sender: TObject);
    procedure SettingsActExecute(Sender: TObject);
    procedure RefreshMapFileActExecute(Sender: TObject);
    procedure RefreshMapFileActUpdate(Sender: TObject);
    procedure IsModbusStdActUpdate(Sender: TObject);
    procedure MemBinaryInputActExecute(Sender: TObject);
    procedure MemCoilActExecute(Sender: TObject);
    procedure MemAnalogInputActExecute(Sender: TObject);
    procedure MemRegistersActExecute(Sender: TObject);
    procedure IsModbusStdActExecute(Sender: TObject);
    procedure actRZ40EventReaderExecute(Sender: TObject);
    procedure RfcWinActExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ConnectActExecute(Sender: TObject);
    procedure ConnectionconfigActExecute(Sender: TObject);
    procedure ConnectionconfigActUpdate(Sender: TObject);
  private
    function GetDev: TCmmDevice;
    function GetCommThread: TCommThread;
    procedure Msg(s: string);
    function FindIniDrvPrmSection(s: string): string;
  private
    FirstTime: boolean;
    FirstConnectBtn: TToolButton;
    TerminalChecked: boolean;
    TerminalValid: boolean;
    procedure OnWriteIniProc(Ini: TDotIniFile);
    procedure OnActivateAplic(Sender: TObject);
    procedure OnReadIniProc(Ini: TDotIniFile);
    procedure OnReOpenClickProc(Sender: TObject);
    procedure OnReloadedProc(Sender: TObject);
    function GetSName(N: Integer): string;
    procedure RestoreWinProc(Sender: TObject);
    procedure SetDriverParamsFromIni;
    procedure CloseEditDrvParamsForm;
    procedure SetupWinTabs;
    function ReOpenConnection: boolean;
  public
    Dev: TCmmDevice;
    CommThread: TCommThread;

    procedure NL(s: string);
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
  Rz40EventsUnit,
  EditDrvParamsUnit,
  PictureView,
  TerminalUnit,
  RegMemUnit,
  BinaryMemUnit,
  OpenConnectionDlgUnit;

function GetComNr(s: string): Integer;
begin
  Result := StrToInt(copy(s, 4, length(s) - 3));
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FirstTime := true;
  ProgCfg.OnReadIni := OnReadIniProc;
  ProgCfg.OnWriteIni := OnWriteIniProc;
  Application.OnActivate := OnActivateAplic;
  MapParser.OnReloaded := OnReloadedProc;
  Dev := TCmmDevice.Create(Handle, ProgCfg.DevString);
  CommThread := TCommThread.Create(Dev);

end;


procedure TMainForm.FormActivate(Sender: TObject);
begin
  if FirstTime then
  begin
    FirstTime := false;
    Caption := GetCurrentDir;
    ProgCfg.LoadMainCfg;
    ProgCfg.ReOpenBaseList.Konfig(0, FilemapItem, OnReOpenClickProc);
    SetupWinTabs;
    ExtMemo.SetCharSet;
  end
end;

procedure TMainForm.OnActivateAplic(Sender: TObject);
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

function TMainForm.FindIniDrvPrmSection(s: string): string;
var
  Ini: TIniFile;
  SL: TStringList;
  i: Integer;
  Item: string;
begin
  Result := '';
  Ini := TIniFile.Create(ProgCfg.MainIniFName);
  SL := TStringList.Create;
  try
    Ini.ReadSections(SL);
    if s <> '' then
    begin
      for i := 0 to SL.Count - 1 do
      begin
        Item := Ini.ReadString(SL.Strings[i], INI_PARAM_DEV_STR, '');
        if Item = s then
        begin
          Result := SL.Strings[i];
          break;
        end;
      end;
    end
    else
    begin
      i := 1;
      while true do
      begin
        Result := Format('DRV_PARAM_%u', [i]);
        if SL.IndexOf(Result) = -1 then
          break;
        inc(i);
      end;
    end;
  finally
    SL.Free;
    Ini.Free;
  end;
end;

procedure TMainForm.SetDriverParamsFromIni;
var
  SecName: string;
  SL: TStringList;
  Ini: TIniFile;
  i: Integer;
  pName, pVal: string;
begin
  SecName := FindIniDrvPrmSection(Dev.ConnectStr);
  if SecName <> '' then
  begin
    Ini := TIniFile.Create(ProgCfg.MainIniFName);
    SL := TStringList.Create;
    try
      Ini.ReadSection(SecName, SL);
      for i := 1 to SL.Count - 1 do
      begin
        pName := SL.Strings[i];
        if SL.Strings[i] <> INI_PARAM_DEV_STR then
        begin
          pVal := Ini.ReadString(SecName, pName, '');
          Dev.SetDrvParam(pName, pVal);
        end;
      end;
    finally
      Ini.Free;
      SL.Free;
    end;
  end;
end;

procedure TMainForm.WMTypeDefChg(var Msg: TMessage);
var
  i: Integer;
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
  i: Integer;
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
  R: Integer;
  s: string;
begin
  if MapParser = nil then
    Exit;
  if MapParser.NeedReload then
  begin
    q := ProgCfg.AutoRefreshMap;
    if q = crASK then
    begin
      s := 'Plik MAP ulegl zmianie.' + #13 + 'Cz za³adowaæ go ponownie ?';
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

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Dev.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  RsdSetLoggerHandle(ExtMemo.PipeInHandle);

end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  q: TYesNoAsk;
  R: Integer;
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
        ProgCfg.SaveMainCfg;
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

procedure TMainForm.ADL(s: string);
begin
  ExtMemo.Print(s);
end;


procedure TMainForm.ConnectActExecute(Sender: TObject);
begin
  ReOpenConnection;

end;


function TMainForm.ReOpenConnection: boolean;
var
  DevStr: string;
  st: TStatus;
  i: Integer;
begin
  if Dev.IsDevStrOk then
  begin
    NL(Format('CloseDev [%s]=%s', [Dev.ConnectStr, Dev.GetErrStr(Dev.CloseDev)]));
  end;
  FreeAndNil(Dev);


  DevStr := ProgCfg.DevString;

  Dev := TCmmDevice.Create(Handle, DevStr);
  CommThread.SetDev(Dev);

  if Dev.IsDevStrOk then
  begin
    st := Dev.OpenDev;
    NL(Format('OpenDev [%s]=%s', [Dev.ConnectStr, Dev.GetErrStr(st)]));
    if st <> stOK then
    begin
      FreeAndNil(Dev);
      Dev := TCmmDevice.Create(Handle, '');
      CommThread.SetDev(Dev);
    end
    else
    begin
      SetDriverParamsFromIni;
      CloseEditDrvParamsForm;
      TerminalChecked := false;
    end;
  end;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;


procedure TMainForm.EditConnectionActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not(Dev.IsDevStrOk);
end;

procedure TMainForm.MemoryWinActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Dev.Connected;
end;

procedure TMainForm.WMShowMemWin(var Msg: TMessage);
var
  Win: TMemForm;
  AdrCpx1: TAdrCpx;
begin
  Win := TMemForm.CreateIterf(self, self);
  AdrCpx1 := PAdrCpx(Msg.WParam)^;
  Win.ShowMem(AdrCpx1);
end;

procedure TMainForm.WMShowStruct(var Msg: TMessage);
var
  Win: TStructShowForm;
  AdrCpx1: TAdrCpx;
begin
  Win := TStructShowForm.CreateIterf(self, self);
  AdrCpx1 := PAdrCpx(Msg.WParam)^;
  Win.SetArea(AdrCpx1.AreaName);
  Win.SetStruct(AdrCpx1.Adres, THType(Msg.LParam));
end;

procedure TMainForm.WMChildCaption(var Msg: TMessage);
var
  Obj: TChildForm;
  N: Integer;
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
  N: Integer;
begin
  Obj := TChildForm(Msg.WParam);
  N := WinTabControl.Tabs.IndexOfObject(Obj);
  if N >= 0 then
    WinTabControl.Tabs.Delete(N);
end;

procedure TMainForm.MemoryWinActExecute(Sender: TObject);
begin
  TMemForm.CreateIterf(self, self);
end;

procedure TMainForm.VarListWinActExecute(Sender: TObject);
begin
  TVarListForm.CreateIterf(self, self);
end;

procedure TMainForm.StructWinActExecute(Sender: TObject);
begin
  TStructShowForm.CreateIterf(self, self);
end;

procedure TMainForm.GeneratorWinActExecute(Sender: TObject);
begin
  TWavGenForm.CreateIterf(self, self);
end;

procedure TMainForm.PictureWinActExecute(Sender: TObject);
begin
  TPictureViewForm.CreateIterf(self, self);
end;

procedure TMainForm.UploadWinActExecute(Sender: TObject);
begin
  TUpLoadFileForm.CreateIterf(self, self);
end;

function TMainForm.GetSName(N: Integer): string;
begin
  Result := Format('Win_%u', [N]);
end;

procedure TMainForm.OnWriteIniProc(Ini: TDotIniFile);
var
  i: Integer;
  N: Integer;
begin
  Ini.WriteInteger('MAIN', 'Top', Top);
  Ini.WriteInteger('MAIN', 'Left', Left);
  Ini.WriteInteger('MAIN', 'Width', Width);
  Ini.WriteInteger('MAIN', 'Height', Height);
  UpLoadList.SaveToIni(Ini);

  N := 1;
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TChildForm then
    begin
      Ini.EraseSection(GetSName(N));
      (MDIChildren[i] as TChildForm).SaveToIni(Ini, GetSName(N));
      inc(N);
    end;
  end;
  while Ini.SectionExists(GetSName(N)) do
  begin
    Ini.EraseSection(GetSName(N));
    inc(N);
  end;
  GlobTypeList.SaveToIni(Ini);
end;

procedure TMainForm.OnReadIniProc(Ini: TDotIniFile);
var
  WinType: string;
  Dlg: TChildForm;
  N: Integer;
begin
  if ProgCfg.WorkingMap <> '' then
    if MapParser.LoadMapFile(ProgCfg.WorkingMap) then
      NL('Load map file :' + MapParser.FileName);

  GlobTypeList.LoadfromIni(Ini);
  UpLoadList.LoadfromIni(Ini);

  Top := Ini.ReadInteger('MAIN', 'Top', Top);
  Left := Ini.ReadInteger('MAIN', 'Left', Left);
  Width := Ini.ReadInteger('MAIN', 'Width', Width);
  Height := Ini.ReadInteger('MAIN', 'Height', Height);

  N := 1;
  while Ini.SectionExists(GetSName(N)) do
  begin
    WinType := Ini.ReadString(GetSName(N), 'WinType', '');
    Dlg := nil;
    if WinType = 'TMemForm' then
      Dlg := TMemForm.CreateIterf(self, self);
    if WinType = 'TVarListForm' then
      Dlg := TVarListForm.CreateIterf(self, self);
    if WinType = 'TStructShowForm' then
      Dlg := TStructShowForm.CreateIterf(self, self);
    if WinType = 'TWavGenForm' then
      Dlg := TWavGenForm.CreateIterf(self, self);
    if WinType = 'TWrtControlForm' then
      Dlg := TWrtControlForm.CreateIterf(self, self);
    if WinType = 'TTerminalForm' then
      Dlg := TTerminalForm.CreateIterf(self, self);
    if WinType = 'TPictureViewForm' then
      Dlg := TPictureViewForm.CreateIterf(self, self);
    if WinType = 'TRegMemForm' then
      Dlg := TRegMemForm.CreateIterf(self, self);
    if WinType = 'TBinaryMemForm' then
      Dlg := TBinaryMemForm.CreateIterf(self, self);
    if WinType = 'TRz40EventsForm' then
      Dlg := TRz40EventsForm.CreateIterf(self, self);
    if WinType = 'TRfcForm' then
      Dlg := TRfcForm.CreateIterf(self, self);

    if Dlg <> nil then
    begin
      Dlg.LoadfromIni(Ini, GetSName(N));
    end;
    inc(N);
  end;
end;

procedure TMainForm.OnReOpenClickProc(Sender: TObject);
var
  FName: string;
begin
  FName := ProgCfg.ReOpenBaseList.GetFileName(Sender as TMenuItem);
  ProgCfg.ReOpenBaseList.AddFile(FName);
  ProgCfg.WorkingMap := FName;
  MapParser.LoadMapFile(FName);
end;

procedure TMainForm.OnReloadedProc(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TChildForm then
    begin
      (MDIChildren[i] as TChildForm).ReloadMapParser;
    end;
  end;
end;

procedure TMainForm.OpenMapFileItemClick(Sender: TObject);
var
  Dlg: TOpenDialog;
  FName: string;
begin
  FName := '';
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.DefaultExt := '.map';
    Dlg.Filter := 'Plik map|*.map|Keil 8051|*.m51';
    if Dlg.Execute then
      FName := Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if FName <> '' then
  begin
    ProgCfg.ReOpenBaseList.AddFile(FName);
    ProgCfg.WorkingMap := FName;
    MapParser.LoadMapFile(FName);
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

procedure TMainForm.SaveSettingsActExecute(Sender: TObject);
begin
  ProgCfg.SaveMainCfg;
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
  i: Integer;
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

  W := TTypeDefEditForm.CreateIterf(self, self);
  W.LoadTypeDefTree(GlobTypeList);
  W.Caption := 'Definicje typów';
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
      W := TTypeDefEditForm.CreateIterf(self, self);
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
  i: Integer;
begin
  for i := MDIChildCount - 1 downto 0 do
  begin
    MDIChildren[i].WindowState := wsMinimized;
  end;
end;

procedure TMainForm.RestoreAllActExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to MDIChildCount - 1 do
  begin
    MDIChildren[i].WindowState := wsNormal;
  end;
end;

procedure TMainForm.CloseAllActExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := MDIChildCount - 1 downto 0 do
  begin
    MDIChildren[i].Close;
  end;
end;

procedure TMainForm.MinimizeActExecute(Sender: TObject);
var
  N: Integer;
  Win: TChildForm;
begin
  N := WinTabControl.TabIndex;
  Win := WinTabControl.Tabs.Objects[N] as TChildForm;
  Win.WindowState := wsMinimized;
end;

procedure TMainForm.CloseActExecute(Sender: TObject);
var
  N: Integer;
  Win: TChildForm;
begin
  N := WinTabControl.TabIndex;
  Win := WinTabControl.Tabs.Objects[N] as TChildForm;
  Win.Close;
end;

procedure TMainForm.RestoreActExecute(Sender: TObject);
var
  N: Integer;
  Win: TChildForm;
begin
  N := WinTabControl.TabIndex;
  Win := WinTabControl.Tabs.Objects[N] as TChildForm;
  Win.WindowState := wsNormal;
end;

procedure TMainForm.OknoItemClick(Sender: TObject);
var
  Item: TMenuItem;
  i: Integer;
  N: Integer;
begin
  N := OknoItem.IndexOf(SplitWindowitem);
  for i := OknoItem.Count - 1 downto N + 1 do
    OknoItem.Delete(i);
  for i := 0 to MDIChildCount - 1 do
  begin
    Item := TMenuItem.Create(self);
    Item.Caption := MDIChildren[i].Caption;
    Item.Tag := cardinal(MDIChildren[i]);
    OknoItem.Add(Item);
    Item.OnClick := RestoreWinProc;
  end;
end;

procedure TMainForm.RestoreWinProc(Sender: TObject);
var
  F: TForm;
begin
  F := TForm((Sender as TMenuItem).Tag);
  if F.WindowState = wsMinimized then
    F.WindowState := wsNormal;
  F.BringToFront;
end;


procedure TMainForm.ControlWinActExecute(Sender: TObject);
begin
  TWrtControlForm.CreateIterf(self, self);
end;

procedure TMainForm.Oprogramie1Click(Sender: TObject);
begin
  ShowAboutDlg;
end;

procedure TMainForm.GetDrvParamsActExecute(Sender: TObject);
var
  s: string;
  ParValue: string;
  SL: TStringList;
  i: Integer;
begin
  s := Dev.GetDrvParamList(false);
  SL := TStringList.Create;
  try
    SL.QuoteChar := '"';
    SL.Delimiter := ';';
    SL.DelimitedText := s;
    for i := 0 to SL.Count - 1 do
    begin
      if Dev.GetDrvStatus(SL.Strings[i], ParValue) = stOK then
      begin
        NL(Format('%s = %s', [SL.Strings[i], ParValue]));
      end;
    end;
  finally
    SL.Free;
  end;
end;

procedure TMainForm.GetDrvParamsActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Dev.Connected;
end;

procedure TMainForm.SetDrvParamsActExecute(Sender: TObject);
var
  i: Integer;
  Form: TEditDrvParamsForm;
begin
  Form := nil;
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TEditDrvParamsForm then
    begin
      Form := MDIChildren[i] as TEditDrvParamsForm;
      Form.BringToFront;
    end;
  end;
  if Form = nil then
    TEditDrvParamsForm.CreateIterf(self, self);
end;

procedure TMainForm.CloseEditDrvParamsForm;
var
  i: Integer;
  Form: TEditDrvParamsForm;
begin
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i] is TEditDrvParamsForm then
    begin
      Form := MDIChildren[i] as TEditDrvParamsForm;
      if Form.Caption <> Dev.ConnectStr then
        Form.Close;
    end;
  end;
end;

procedure TMainForm.WinTabControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  nr: Integer;
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
  if not(TerminalChecked) then
  begin
    TerminalValid := false;
    if Dev.Connected then
    begin
      TerminalValid := Dev.CheckTerminalValid;
      TerminalChecked := true;
    end;
  end;
  (Sender as TAction).Enabled := TerminalValid;
end;

procedure TMainForm.TerminalActExecute(Sender: TObject);
begin
  TTerminalForm.CreateIterf(self, self);
end;

procedure TMainForm.IsModbusStdActExecute(Sender: TObject);
begin
  // musi tak pozostaæ !
end;

procedure TMainForm.IsModbusStdActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Dev.isStdModbus;
end;

procedure TMainForm.MemBinaryInputActExecute(Sender: TObject);
var
  Win: TBinaryMemForm;
begin
  Win := TBinaryMemForm.CreateIterf(self, self);
  Win.SetMemType(bmBINARYINP);
end;

procedure TMainForm.MemCoilActExecute(Sender: TObject);
var
  Win: TBinaryMemForm;
begin
  Win := TBinaryMemForm.CreateIterf(self, self);
  Win.SetMemType(bmCOILS);
end;

procedure TMainForm.MemAnalogInputActExecute(Sender: TObject);
var
  Win: TRegMemForm;
begin
  Win := TRegMemForm.CreateIterf(self, self);
  Win.SetMemType(rmANALOGINP);
end;

procedure TMainForm.MemRegistersActExecute(Sender: TObject);
var
  Win: TRegMemForm;
begin
  Win := TRegMemForm.CreateIterf(self, self);
  Win.SetMemType(rmREGISTERS);
end;

procedure TMainForm.actRZ40EventReaderExecute(Sender: TObject);
begin
  TRz40EventsForm.CreateIterf(self, self);
end;

procedure TMainForm.RfcWinActExecute(Sender: TObject);
begin
  TRfcForm.CreateIterf(self, self);
end;

procedure TMainForm.ConnectionconfigActExecute(Sender: TObject);
var
  Dlg: TOpenConnectionDlg;
begin
  Dlg := TOpenConnectionDlg.Create(self);
  try
    Dlg.SetConfig(ProgCfg.DevString);
    if Dlg.ShowModal = mrOk then
      ProgCfg.DevString:= Dlg.GetConfig;
  finally
    Dlg.Free;
  end;
end;


procedure TMainForm.ConnectionconfigActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not Dev.Connected;
end;

end.
