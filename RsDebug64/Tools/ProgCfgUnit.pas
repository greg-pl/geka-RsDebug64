unit ProgCfgUnit;

interface

uses
  Winapi.Windows,
  Messages, SysUtils, IniFiles, Menus, Forms, Classes,
  graphics, Contnrs, math, StdCtrls,
  Vcl.Controls,
  GkStrUtils,
  System.JSON,
  JSonUtils,
  Registry,
  ToolsUnit;

const
  wm_TypeDefChg = wm_User + 0;
  wm_SettingsChg = wm_User + 1;
  wm_ShowmemWin = wm_User + 2;
  wm_ShowStruct = wm_User + 3;
  wm_TrnsProgress = wm_User + 4;
  wm_TrnsStartStop = wm_User + 5;
  wm_TrnsFlow = wm_User + 6;
  wm_ChildCaption = wm_User + 7;
  wm_ChildClosed = wm_User + 8;

  wm_WindowCmm = wm_User + 100;

  wm_ReadMem1 = wm_WindowCmm + 0;
  wm_ReadMem2 = wm_WindowCmm + 1;

  wm_WriteMem1 = wm_WindowCmm + 10;
  wm_WriteMem2 = wm_WindowCmm + 11;
  wm_WriteMem3 = wm_WindowCmm + 12;

  wm_AllDone = wm_WindowCmm + 20;

  INI_PARAM_DEV_STR = '_PrmDevStr_';

  JSON_WIN_TYPE = 'WinType';
  JSON_WIN_TITLE = 'Title';

type

  TDotIniFile = class(TMemIniFile)
    function ReadFloat(const Section, Name: string; Default: Double): Double; override;
    procedure WriteFloat(const Section, Name: string; Value: Double); override;
    function ReadYesNo(const Section, Name: string; Default: TYesNoAsk): TYesNoAsk;
    procedure WriteYesNo(const Section, Name: string; Value: TYesNoAsk);
    procedure ReadTStrings(const Section, Name: string; Value: TStrings);
    procedure WriteTStrings(const Section, Name: string; Value: TStrings);
  end;

  TClosedWin = class(TObject)
    Name: string;
    WinType: string;
    jObj: TJSONObject;
    function LoadFromJson(jLoader: TJSonLoader): boolean;
  end;

  TClosedWinList = class(TObjectList)
    function FGetItem(Index: integer): TClosedWin;
    property Items[Index: integer]: TClosedWin read FGetItem;
    procedure LoadFromJson(jArr: TJSONArray);
    function GetJSONObject: TJSONValue;
    procedure AddMenuItems(ParentItem: TMenuItem; Proc: TNotifyEvent);
  end;

  TJObjData = class(TObject)
  private
    FJsonTitle: string;
    FJsonAttrib: string;
  public
    ObjName: string;
    ObjData: TJSONObject;
    constructor Create(jsonTitle, jsonAttrib: string);
    function LoadFromJson(jLoader: TJSonLoader): boolean;
    function GetJSONObject: TJSONValue;
  end;

  TJobjDataList = class(TObjectList)
  private
    FJsonListName: string;
    FChildJsonTitle: string;
    FChildJsonAttrib: string;
    function FGetItem(Index: integer): TJObjData;
    function FindJObj(Name: string): TJObjData;
  public
    constructor Create(jsonListName, childJsonTitle, childJsonAttrib: string);
    property Items[Index: integer]: TJObjData read FGetItem;

    procedure AddJData(jObjName: string; jObj: TJSONObject);
    function GetJDataAsText(jObjName: string; var ObjAsText: String): boolean; overload;
    function GetJDataAsText(jObjName: string): string; overload;

    procedure LoadFromJson(jLoader: TJSonLoader);
    procedure AddToJson(jBuild: TJSONBuilder);
  end;

  TReopenItem = class(TObject)
    FileName: String;
  end;

  TReopenList = class(TObjectList)
  public const
    TAG_START = 210000;
    MAX_FILES = 100;

  private
    ReOpenDeep: integer;
    function GetItem(Index: integer): TReopenItem;
  public
    constructor Create(AReOpenDeep: integer); reintroduce;
    property Items[Index: integer]: TReopenItem read GetItem;
    function AddFile(Fname: string): TReopenItem;
    procedure AddToMenuItem(AIndex: integer; AParentItem: TMenuItem; AOnClickProc: TNotifyEvent);
    function GetFileName(FItem: TMenuItem): string;
    function GetLastFilename: string;
    procedure GetList(SL: TStrings);
    // registry
    procedure SaveToReg(Reg: TRegistry; keyName: string);
    procedure LoadFromReg(Reg: TRegistry; keyName: string);
    // JSON
    function GetJSONObject: TJSONValue;
    procedure LoadFromJObj(jArr: TJSONArray);
  end;

  TGetJsonObject = function: TJSONBuilder of object;
  TReadJsonObject = procedure(jLoader: TJSonLoader) of object;

  PAdrCpx = ^TAdrCpx;

  TAdrCpx = record
    Adres: integer;
    Size: integer;
    Caption: string;
  end;

  TWinTab = (wtOFF, wtTOP, wtBOTTOM);

  TSelSectionMode = (secALL, secShowSelected, secHideSelected);

  TSectionsCfg = record
    SelSections: TStringList;
    SelSectionMode: TSelSectionMode;
    procedure Init;
    procedure Done;
    procedure CopyFrom(Src: TSectionsCfg);
    procedure JSONLoad(jVal: TJSONValue);
    procedure JSONAdd(jBuild: TJSONBuilder);
    function getJsonValue: TJSONValue;
  end;

  TWinPosRect = record
    ChildName: string;
    valid: boolean;
    t, l, w, h: integer;
    procedure Init(chName: string);
    function Load_TLWH(ctrl: TControl): boolean;
    procedure Save_TLWH(ctrl: TControl);
    procedure AddToJson(jBuild: TJSONBuilder);
    function JSONLoad(jLoad: TJSonLoader): boolean;
  end;

  TProgCfg = class(TObject)
  private
    FOnWriteJsonCfg: TGetJsonObject;
    FOnReadJsonCfg: TReadJsonObject;

    FWorkSpaceFilename: string;

    procedure SaveToReg;
    procedure LoadFromReg;

  public
    ReOpenMapfileList: TReopenList;
    ReOpenWorkspaceList: TReopenList;

    WorkingMap: string;
    AutoSaveCfg: TYesNoAsk;
    AutoRefreshMap: TYesNoAsk;
    SectionsCfg: TSectionsCfg;
    ScalMemCnt: integer;
    MaxVarSize: integer;
    DevString: String;
    WinTab: TWinTab;
    ByteOrder: TByteOrder;
    ptrSize: TPtrSize;
    ShowUnknownMapLine: boolean;
    LoadMapFileOnStartUp: boolean;
    ShowMessageAboutSpeed: boolean;
    ObjDumpPath: string; // path to objdump.exe from GNU compiler

    ClosedWinList: TClosedWinList;
    DriverParamsList: TJobjDataList;
    DriverOpenList: TJobjDataList;

    OpenDialogRect: TWinPosRect;

    constructor Create;
    destructor Destroy; override;
    procedure OpenWorkSpaceFromWorkingDir;
    procedure OpenWorkspace(FileName: string);
    procedure SaveWorkspace;
    procedure SaveWorkspaceAs(FileName: string);
    function GetWorkingPath: string;
    function GetWorkSpacefile: string;

    procedure AddDriverSettings(DriverName: string; jObj: TJSONObject);
    function getDriverParams(DriverName: string): string;

    function GetDrvSettings(DrvName: string; var DrvStr: string): boolean;
    procedure AddDrvSettings(DriverName: string; DrvStr: string);

    property OnWriteJsonCfg: TGetJsonObject read FOnWriteJsonCfg write FOnWriteJsonCfg;
    property OnReadJsonCfg: TReadJsonObject read FOnReadJsonCfg write FOnReadJsonCfg;
  end;

const
  REG_KEY = '\SOFTWARE\GEKA\RSDEBUG_2';

var
  ProgCfg: TProgCfg;
  DotFormatSettings: TFormatSettings;

implementation

uses
  MapParserUnit;

function TDotIniFile.ReadFloat(const Section, Name: string; Default: Double): Double;
var
  FloatStr: string;
begin
  FloatStr := ReadString(Section, Name, '');
  Result := Default;
  if FloatStr <> '' then
    try
      Result := StrToFloat(FloatStr, DotFormatSettings);
    except
      on EConvertError do
        // Ignore EConvertError exceptions
      else
        raise;
    end;
end;

procedure TDotIniFile.WriteFloat(const Section, Name: string; Value: Double);
begin
  WriteString(Section, Name, FloatToStr(Value, DotFormatSettings));
end;

function TDotIniFile.ReadYesNo(const Section, Name: string; Default: TYesNoAsk): TYesNoAsk;
var
  n: integer;
begin
  n := ReadInteger(Section, Name, ord(Default));
  if (n >= ord(low(TYesNoAsk))) and (n <= ord(high(TYesNoAsk))) then
    Result := TYesNoAsk(n)
  else
    Result := Default;
end;

procedure TDotIniFile.WriteYesNo(const Section, Name: string; Value: TYesNoAsk);
begin
  WriteInteger(Section, Name, ord(Value));
end;

procedure TDotIniFile.ReadTStrings(const Section, Name: string; Value: TStrings);
var
  s: string;
begin
  Value.Delimiter := ';';
  Value.QuoteChar := '"';
  s := Value.DelimitedText;
  s := ReadString(Section, Name, s);
  Value.DelimitedText := s;
end;

procedure TDotIniFile.WriteTStrings(const Section, Name: string; Value: TStrings);
var
  s: string;
begin
  Value.Delimiter := ';';
  Value.QuoteChar := '"';
  s := Value.DelimitedText;
  WriteString(Section, name, s);
end;

// --------------------- TShowVarCfg ----------------------------------------

procedure TSectionsCfg.Init;
begin
  SelSections := TStringList.Create;;
end;

procedure TSectionsCfg.Done;
begin
  SelSections.Free;
end;

procedure TSectionsCfg.CopyFrom(Src: TSectionsCfg);
begin
  SelSectionMode := Src.SelSectionMode;
  SelSections.Clear;
  SelSections.AddStrings(Src.SelSections);
end;

procedure TSectionsCfg.JSONAdd(jBuild: TJSONBuilder);
var
  jBuild2: TJSONBuilder;
begin
  jBuild2.Init;
  jBuild2.Add('SectionsMode', ord(SelSectionMode));
  jBuild2.Add('Sections', SelSections);
  jBuild.Add('ShowVarCfg', jBuild2);
end;

procedure TSectionsCfg.JSONLoad(jVal: TJSONValue);
var
  jLoader2: TJSonLoader;
begin
  if jLoader2.Init(jVal) then
  begin
    SelSectionMode := TSelSectionMode(jLoader2.LoadDef('SectionsMode', ord(SelSectionMode)));
    jLoader2.Load('Sections', SelSections);
  end;
end;

function TSectionsCfg.getJsonValue: TJSONValue;
var
  jBuild: TJSONBuilder;
begin
  jBuild.Init;
  JSONAdd(jBuild);
  Result := jBuild.jObj;
end;

// --------------------- TWinPosRect ----------------------------------------

procedure TWinPosRect.Init(chName: string);
begin
  ChildName := chName;
  valid := false;
end;

procedure TWinPosRect.Save_TLWH(ctrl: TControl);
begin
  valid := true;
  t := ctrl.Top;
  l := ctrl.Left;
  w := ctrl.Width;
  h := ctrl.Height;
end;

function TWinPosRect.Load_TLWH(ctrl: TControl): boolean;
begin
  if valid then
  begin
    ctrl.Top := t;
    ctrl.Left := l;
    ctrl.Width := w;
    ctrl.Height := h;
  end;
  Result := valid;
end;

procedure TWinPosRect.AddToJson(jBuild: TJSONBuilder);
var
  jChild: TJSONBuilder;
begin
  if valid then
  begin
    jChild.Init;
    jChild.Add('Top', t);
    jChild.Add('Left', l);
    jChild.Add('Width', w);
    jChild.Add('Height', h);
    jBuild.Add(ChildName, jChild.jObj);
  end;
end;

function TWinPosRect.JSONLoad(jLoad: TJSonLoader): boolean;
var
  jChild: TJSonLoader;
begin
  Result := false;
  if jChild.Init(jLoad, ChildName) then
  begin
    Result := jChild.Load('Top', t) and jChild.Load('Left', l) and jChild.Load('Width', w) and jChild.Load('Height', h);
  end;
  valid := Result;
end;

// --------------------- TClosedWin ----------------------------------------

function TClosedWin.LoadFromJson(jLoader: TJSonLoader): boolean;
begin
  jObj := jLoader.jObj;
  Result := jLoader.Load(JSON_WIN_TITLE, Name) and jLoader.Load(JSON_WIN_TYPE, WinType);
end;

function TClosedWinList.FGetItem(Index: integer): TClosedWin;
begin
  Result := inherited GetItem(Index) as TClosedWin;
end;

procedure TClosedWinList.LoadFromJson(jArr: TJSONArray);
var
  i: integer;
  jChild: TJSonLoader;
  Win: TClosedWin;
begin
  Clear;
  if Assigned(jArr) then
  begin
    for i := 0 to jArr.Count - 1 do
    begin
      if jChild.Init(jArr.Items[i]) then
      begin
        Win := TClosedWin.Create;
        if Win.LoadFromJson(jChild) then
          Add(Win)
        else
          Win.Free;
      end;
    end;
  end;
end;

function TClosedWinList.GetJSONObject: TJSONValue;
var
  jArr: TJSONArray;
  i: integer;
begin
  jArr := TJSONArray.Create;
  for i := 0 to Count - 1 do
  begin
    jArr.AddElement(Items[i].jObj);
  end;
  Result := jArr;
end;

procedure TClosedWinList.AddMenuItems(ParentItem: TMenuItem; Proc: TNotifyEvent);
var
  Item: TMenuItem;
  i: integer;
begin
  for i := ParentItem.Count - 1 downto 0 do
  begin
    if ParentItem.Items[i].Tag <> 0 then
    begin
      ParentItem.Delete(i);
    end;
  end;

  for i := 0 to ProgCfg.ClosedWinList.Count - 1 do
  begin
    Item := TMenuItem.Create(Application.Mainform);
    Item.Caption := (ProgCfg.ClosedWinList.Items[i] as TClosedWin).Name;
    Item.Tag := 10 + i;
    Item.OnClick := Proc;
    ParentItem.Add(Item);
  end;
end;

// --------------------- TJobjDataList ----------------------------------------

constructor TJObjData.Create(jsonTitle, jsonAttrib: string);
begin
  inherited Create;
  FJsonTitle := jsonTitle;
  FJsonAttrib := jsonAttrib;
  ObjData := nil
end;

function TJObjData.LoadFromJson(jLoader: TJSonLoader): boolean;
begin
  Result := jLoader.Load(FJsonTitle, ObjName);
  ObjData := jLoader.GetObject(FJsonAttrib);
  Result := Result and Assigned(ObjData);
end;

function TJObjData.GetJSONObject: TJSONValue;
var
  jBuild: TJSONBuilder;
begin
  jBuild.Init;
  jBuild.Add(FJsonTitle, ObjName);
  jBuild.Add(FJsonAttrib, ObjData);
  Result := jBuild.jObj;
end;

constructor TJobjDataList.Create(jsonListName, childJsonTitle, childJsonAttrib: string);
begin
  inherited Create;
  FJsonListName := jsonListName;
  FChildJsonTitle := childJsonTitle;
  FChildJsonAttrib := childJsonAttrib;

end;

function TJobjDataList.FGetItem(Index: integer): TJObjData;
begin
  Result := inherited GetItem(Index) as TJObjData;
end;

function TJobjDataList.FindJObj(Name: string): TJObjData;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].ObjName = Name then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

procedure TJobjDataList.LoadFromJson(jLoader: TJSonLoader);
var
  jArr: TJSONArray;
  i: integer;
  jChild: TJSonLoader;
  drvParam: TJObjData;
begin
  Clear;
  jArr := jLoader.getArray(FJsonListName);
  if Assigned(jArr) then
  begin
    for i := 0 to jArr.Count - 1 do
    begin
      if jChild.Init(jArr.Items[i]) then
      begin
        drvParam := TJObjData.Create(FChildJsonTitle, FChildJsonAttrib);

        if drvParam.LoadFromJson(jChild) then
          Add(drvParam)
        else
          drvParam.Free;
      end;
    end;
  end;
end;

procedure TJobjDataList.AddToJson(jBuild: TJSONBuilder);
var
  jArr: TJSONArray;
  i: integer;
begin
  jArr := TJSONArray.Create;
  for i := 0 to Count - 1 do
  begin
    jArr.AddElement(Items[i].GetJSONObject);
  end;
  jBuild.Add(FJsonListName, jArr);
end;

procedure TJobjDataList.AddJData(jObjName: string; jObj: TJSONObject);
var
  jobjData: TJObjData;
begin
  jobjData := FindJObj(jObjName);
  if not Assigned(jobjData) then
  begin
    jobjData := TJObjData.Create(FChildJsonTitle, FChildJsonAttrib);
    jobjData.ObjName := jObjName;
    Add(jobjData);
  end;
  jobjData.ObjData := jObj;
end;

function TJobjDataList.GetJDataAsText(jObjName: string; var ObjAsText: String): boolean;
var
  jobjData: TJObjData;
begin
  Result := false;
  jobjData := FindJObj(jObjName);
  if Assigned(jobjData) then
  begin
    Result := true;
    ObjAsText := jobjData.ObjData.ToJSON;
  end;
end;

function TJobjDataList.GetJDataAsText(jObjName: string): string;
begin
  GetJDataAsText(jObjName, Result);
end;

// --------------------- TReopenItem ----------------------------------------
constructor TReopenList.Create(AReOpenDeep: integer);
begin
  inherited Create;
  ReOpenDeep := AReOpenDeep;
end;

function TReopenList.GetItem(Index: integer): TReopenItem;
begin
  Result := (inherited GetItem(Index)) as TReopenItem;
end;

function TReopenList.AddFile(Fname: string): TReopenItem;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].FileName = Fname then
    begin
      Move(i, 0);
      Result := Items[i];
    end;
  end;
  if Result = nil then
  begin
    Result := TReopenItem.Create;
    Result.FileName := Fname;
    Insert(0, Result);
  end;
end;

function TReopenList.GetJSONObject: TJSONValue;
var
  i: integer;
  n: integer;
begin
  Result := TJSONArray.Create;
  n := Count;
  if n > ReOpenDeep then
    n := ReOpenDeep;
  for i := 0 to n - 1 do
  begin
    (Result as TJSONArray).AddElement(TJsonStringEx.Create(Items[i].FileName));
  end;
end;

procedure TReopenList.LoadFromJObj(jArr: TJSONArray);
var
  i: integer;
begin
  Clear;
  if Assigned(jArr) then
  begin
    for i := 0 to jArr.Count - 1 do
    begin
      AddFile(jArr.Items[i].Value);
    end;
  end;
end;

procedure TReopenList.SaveToReg(Reg: TRegistry; keyName: string);
var
  i: integer;
  n: integer;
  SL: TStringList;
begin
  if Reg.OpenKey(keyName, true) then
  begin
    SL := TStringList.Create;
    try
      Reg.GetValueNames(SL);
      for i := 0 to SL.Count - 1 do
      begin
        Reg.DeleteValue(SL.Strings[i]);
      end;
    finally
      SL.Free;
    end;

    n := Count;
    if n > ReOpenDeep then
      n := ReOpenDeep;
    for i := 0 to n - 1 do
    begin
      Reg.WriteString('Item' + IntToStr(i), Items[i].FileName);
    end;
  end;
end;

procedure TReopenList.LoadFromReg(Reg: TRegistry; keyName: string);
var
  i: integer;
  nm: string;
begin
  Clear;
  if Reg.OpenKeyReadOnly(keyName) then
  begin
    i := 0;
    while true do
    begin
      nm := 'Item' + IntToStr(i);
      if not(Reg.ValueExists(nm)) then
        break;
      AddFile(Reg.ReadString(nm));
      inc(i);
    end;
  end;
end;

procedure TReopenList.AddToMenuItem(AIndex: integer; AParentItem: TMenuItem; AOnClickProc: TNotifyEvent);
var
  i, n: integer;
  MItem: TMenuItem;
begin
  if Assigned(AParentItem) then
  begin
    for i := AParentItem.Count - 1 downto 0 do
    begin
      if (AParentItem.Items[i].Tag >= TAG_START) and (AParentItem.Items[i].Tag < TAG_START + MAX_FILES) then
        AParentItem.Delete(i);
    end;

    AParentItem.Enabled := (Count > 0);

    n := Count;
    if n > ReOpenDeep then
      n := ReOpenDeep;
    for i := n - 1 downto 0 do
    begin
      MItem := TMenuItem.Create(Application.Mainform);
      MItem.Caption := IntToStr(i + 1) + '. ' + Items[i].FileName;
      MItem.OnClick := AOnClickProc;
      MItem.Tag := TAG_START + i;
      AParentItem.Insert(AIndex, MItem);
      // AIndex := AParentItem.IndexOf(MItem) + 1;
    end;
  end;
end;

function TReopenList.GetFileName(FItem: TMenuItem): string;
var
  idx: integer;
begin
  Result := '';
  idx := FItem.Tag - TAG_START;
  if (idx >= 0) and (idx < Count) then
    Result := Items[idx].FileName;
end;

function TReopenList.GetLastFilename: string;
begin
  if Count > 0 then
    Result := Items[0].FileName
  else
    Result := '';
end;

procedure TReopenList.GetList(SL: TStrings);
var
  i: integer;
begin
  SL.Clear;
  for i := 0 to Count - 1 do
  begin
    SL.Add(Items[i].FileName);
  end;
end;

// --------------------- ProgCFG ----------------------------------------

constructor TProgCfg.Create;
begin
  inherited;
  ClosedWinList := TClosedWinList.Create;
  DriverParamsList := TJobjDataList.Create('DriverParamsList', 'DriverName', 'Params');
  DriverOpenList := TJobjDataList.Create('DriverOpenList', 'DriverName', 'OpenParams');
  OpenDialogRect.Init('OpenDialog');

  ReOpenMapfileList := TReopenList.Create(10);
  ReOpenWorkspaceList := TReopenList.Create(10);
  FWorkSpaceFilename := IncludeTrailingPathDelimiter(GetCurrentDir) +
    ChangeFileExt(ExtractFileName(Application.ExeName), '.rsd');
  SectionsCfg.Init;
  LoadFromReg;

end;

destructor TProgCfg.Destroy;
begin
  SaveToReg;
  ReOpenMapfileList.Free;
  ReOpenWorkspaceList.Free;
  SectionsCfg.Done;
  DriverParamsList.Free;
  DriverOpenList.Free;
  ClosedWinList.Free;
  inherited;
end;

function TProgCfg.GetWorkingPath: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(FWorkSpaceFilename));
end;

function TProgCfg.GetWorkSpacefile: string;
begin
  Result := FWorkSpaceFilename;
end;

procedure TProgCfg.LoadFromReg;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if Reg.OpenKey(REG_KEY, true) then
    begin
      if ObjDumpPath = '' then
        if Reg.ValueExists('ObjDumpPath') then
          ObjDumpPath := Reg.ReadString('ObjDumpPath');

      if Reg.ValueExists('WorkSpaceFilename') then
        FWorkSpaceFilename := Reg.ReadString('WorkSpaceFilename');

      ReOpenWorkspaceList.LoadFromReg(Reg, 'ReOpenWorkspaceList');
    end;
  finally
    Reg.Free;
  end;
end;

procedure TProgCfg.SaveToReg;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if Reg.OpenKey(REG_KEY, true) then
    begin
      Reg.WriteString('ObjDumpPath', ObjDumpPath);
      Reg.WriteString('WorkSpaceFilename', FWorkSpaceFilename);

      ReOpenWorkspaceList.SaveToReg(Reg, 'ReOpenWorkspaceList');
    end;
  finally
    Reg.Free;
  end;
end;

procedure TProgCfg.OpenWorkSpaceFromWorkingDir;
begin
  OpenWorkspace(FWorkSpaceFilename);
end;

procedure TProgCfg.AddDriverSettings(DriverName: string; jObj: TJSONObject);
begin
  DriverParamsList.AddJData(DriverName, jObj);
end;

function TProgCfg.getDriverParams(DriverName: string): string;
begin
  Result := DriverParamsList.GetJDataAsText(DriverName);
end;

procedure TProgCfg.AddDrvSettings(DriverName: string; DrvStr: string);
var
  jVal: TJSONValue;
begin
  jVal := TJSONObject.ParseJSONValue(DevString);
  DriverOpenList.AddJData(DriverName, jVal as TJSONObject);
end;

function TProgCfg.GetDrvSettings(DrvName: string; var DrvStr: string): boolean;
begin
  Result := DriverOpenList.GetJDataAsText(DrvName, DrvStr);
end;

procedure TProgCfg.OpenWorkspace(FileName: string);
var
  txt: string;
  MS: TMemoryStream;
  jLoader: TJSonLoader;
  jLoader2: TJSonLoader;
  jVal: TJSONValue;
begin
  FWorkSpaceFilename := FileName;
  ReOpenWorkspaceList.AddFile(FWorkSpaceFilename);

  txt := '';
  MS := TMemoryStream.Create;
  try
    MS.LoadFromFile(FileName);
    if MS.Size > 0 then
    begin
      setLength(txt, MS.Size div 2);
      MS.read(txt[1], length(txt) * sizeof(char));
    end;
  finally
    MS.Free;
  end;

  if txt <> '' then
  begin
    try
      jLoader.Init(txt);
      if jLoader2.Init(jLoader, 'MainCfg') then
      begin
        jLoader2.Load('MapFile', WorkingMap);
        jVal := jLoader2.GetObject('DevString');
        if Assigned(jVal) then
          DevString := jVal.ToJSON;

        jLoader2.Load('AutoSave', AutoSaveCfg);
        jLoader2.Load('AutoRefresh', AutoRefreshMap);
        jLoader2.Load('MergeMemory', ScalMemCnt);
        jLoader2.Load('MaxVarSize', MaxVarSize);
        jLoader2.Load('ObjDumpPath', ObjDumpPath);
        jLoader2.Load('LoadMapFileOnStartUp', LoadMapFileOnStartUp);
        jLoader2.Load('ShowMessageAboutSpeed', ShowMessageAboutSpeed);
        try
          WinTab := TWinTab(jLoader2.LoadDef('WinTabPos', ord(WinTab)));
        except
          WinTab := wtTOP;
        end;

        ByteOrder := TByteOrder(jLoader2.LoadDef('ByteOrder', ord(ByteOrder)));
      end;

      SectionsCfg.JSONLoad(jLoader.GetObject('ShowVarCfg'));

      ReOpenMapfileList.LoadFromJObj(jLoader.getArray('ReOpenMapFileList'));
      ClosedWinList.LoadFromJson(jLoader.getArray('ClosedWin'));
      DriverParamsList.LoadFromJson(jLoader);
      DriverOpenList.LoadFromJson(jLoader);
      OpenDialogRect.JSONLoad(jLoader);

      if Assigned(FOnReadJsonCfg) then
      begin
        if jLoader2.Init(jLoader, 'DeskTop') then
          FOnReadJsonCfg(jLoader2);
      end;

    except

    end;
  end;

end;

procedure TProgCfg.SaveWorkspace;
begin
  SaveWorkspaceAs(FWorkSpaceFilename);
end;

procedure TProgCfg.SaveWorkspaceAs(FileName: string);
var
  jVal: TJSONValue;
  jBuild: TJSONBuilder;
  jBuild2: TJSONBuilder;
  txt: string;
  MS: TMemoryStream;
begin
  jBuild.Init;
  jBuild2.Init;
  jVal := TJSONObject.ParseJSONValue(DevString);
  jBuild2.Add('DevString', jVal);
  jBuild2.Add('MapFile', WorkingMap);
  jBuild2.Add('AutoSave', ord(AutoSaveCfg));
  jBuild2.Add('AutoRefresh', ord(AutoRefreshMap));

  jBuild2.Add('ByteOrder', ord(ByteOrder));
  jBuild2.Add('MergeMemory', ScalMemCnt);
  jBuild2.Add('MaxVarSize', MaxVarSize);
  jBuild2.Add('WinTabPos', ord(WinTab));
  jBuild2.Add('ShowUnknownMapLine', ShowUnknownMapLine);
  jBuild2.Add('ObjDumpPath', ObjDumpPath);
  jBuild2.Add('LoadMapFileOnStartUp', LoadMapFileOnStartUp);
  jBuild2.Add('ShowMessageAboutSpeed', ShowMessageAboutSpeed);

  jBuild.Add('MainCfg', jBuild2);
  SectionsCfg.JSONAdd(jBuild);

  if Assigned(FOnWriteJsonCfg) then
    jBuild.Add('DeskTop', FOnWriteJsonCfg.jObj);

  jBuild.Add('ReOpenMapFileList', ReOpenMapfileList.GetJSONObject);
  jBuild.Add('ClosedWin', ClosedWinList.GetJSONObject);
  DriverParamsList.AddToJson(jBuild);
  DriverOpenList.AddToJson(jBuild);

  OpenDialogRect.AddToJson(jBuild);


  // jBuild.Add('ReOpenWorkspaceList', ReOpenWorkspaceList.GetJSONObject);

  txt := jBuild.jObj.ToJSON;
  MS := TMemoryStream.Create;
  try
    MS.write(txt[1], length(txt) * sizeof(char));
    MS.SaveToFile(FileName);
    MS.SaveToFile(ChangeFileExt(FileName, '.json')); // TODO delete
    ReOpenWorkspaceList.AddFile(FWorkSpaceFilename);
    FWorkSpaceFilename := FileName;
  finally
    MS.Free;
  end;

end;

initialization

ProgCfg := TProgCfg.Create;
{$WARN SYMBOL_PLATFORM OFF}
DotFormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);
{$WARN SYMBOL_PLATFORM ON}
DotFormatSettings.DecimalSeparator := '.';

finalization

ProgCfg.Free;

end.
