unit ProgCfgUnit;

interface

uses
  Winapi.Windows,
  Messages, SysUtils, IniFiles, Menus, Forms, Classes,
  graphics, Contnrs, math, StdCtrls,
  GkStrUtils,
  System.JSON,
  JSonUtils,
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

  INI_PARAM_DEV_STR = '_PrmDevStr_';

type

  TDotIniFile = class(TMemIniFile)
    function ReadFloat(const Section, Name: string; Default: Double): Double; override;
    procedure WriteFloat(const Section, Name: string; Value: Double); override;
    function ReadYesNo(const Section, Name: string; Default: TYesNoAsk): TYesNoAsk;
    procedure WriteYesNo(const Section, Name: string; Value: TYesNoAsk);
    procedure ReadTStrings(const Section, Name: string; Value: TStrings);
    procedure WriteTStrings(const Section, Name: string; Value: TStrings);
  end;

  TReopenItem = class(TObject)
    FileName: String;
    FileItem: TMenuItem;
  end;

  TReopenList = class(TObjectList)
  private
    FSectionName: string;
    FIndex: integer;
    FParentItem: TMenuItem;
    FOnClickProc: TNotifyEvent;
    ReOpenDeep: integer;
    function GetItem(Index: integer): TReopenItem;
    procedure AddToMenu;
  protected
    procedure LoadFromIni(IniFile: TDotIniFile);
    procedure SaveToIni(IniFile: TDotIniFile);
    function GetJSONObject: TJSONValue;
    procedure LoadFromJObj(jArr: TJSONArray);
    function FindItem(AItem: TMenuItem): boolean;
    function AddFile(Fname: string; UpdateMenu: boolean): TReopenItem; overload;
  public
    constructor Create(ASectionName: string; AReOpenDeep: integer); reintroduce;
    property Items[Index: integer]: TReopenItem read GetItem;
    function AddFile(Fname: string): TReopenItem; overload;
    procedure Konfig(AIndex: integer; AMenuItem: TMenuItem; AOnClickProc: TNotifyEvent);
    function GetFileName(FItem: TMenuItem): string;
    function GetLastFilename: string;
    procedure GetList(SL: TStrings);
  end;

  TIniIoProc = procedure(IniFile: TDotIniFile) of object;
  TGetJsonObject = function: TJSONBuilder of object;
  TReadJsonObject = procedure(jLoader: TJSONLoader) of object;

  PAdrCpx = ^TAdrCpx;

  TAdrCpx = record
    Adres: integer;
    Size: integer;
    Caption: string;
  end;

  TWinTab = (wtOFF, wtTOP, wtBOTTOM);

  TProgCfg = class(TObject)
  private
    FOnReadIni: TIniIoProc;
    FOnWriteIni: TIniIoProc;
    FOnWriteJsonCfg: TGetJsonObject;
    FOnReadJsonCfg: TReadJsonObject;

    FIniFilename: string;
  public
    ReOpenBaseList: TReopenList;
    WorkingMap: string;
    SelectAsmVar: boolean;
    SelectC_Var: boolean;
    SelectSysVar: boolean;
    AutoSaveCfg: TYesNoAsk;
    AutoRefreshMap: TYesNoAsk;
    SelSectionMode: integer;
    SelSections: TStringList;
    ScalMemCnt: integer;
    MaxVarSize: integer;
    DevString: String;
    WinTab: TWinTab;
    ByteOrder: TByteOrder;
    ptrSize: TPtrSize;

    constructor Create;
    destructor Destroy; override;
    procedure LoadMainCfg;
    procedure SaveMainCfg;

    property OnReadData: TIniIoProc read FOnReadIni write FOnReadIni;
    property OnWriteData: TIniIoProc read FOnWriteIni write FOnWriteIni;
    property OnWriteJsonCfg: TGetJsonObject read FOnWriteJsonCfg write FOnWriteJsonCfg;
    property OnReadJsonCfg: TReadJsonObject read FOnReadJsonCfg write FOnReadJsonCfg;

    property MainIniFName: string read FIniFilename;
  end;

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

// --------------------- TReopenItem ----------------------------------------
constructor TReopenList.Create(ASectionName: string; AReOpenDeep: integer);
begin
  inherited Create;
  FSectionName := ASectionName;
  ReOpenDeep := AReOpenDeep;
end;

function TReopenList.GetItem(Index: integer): TReopenItem;
begin
  Result := (inherited GetItem(Index)) as TReopenItem;
end;

function TReopenList.AddFile(Fname: string; UpdateMenu: boolean): TReopenItem;
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
    Result.FileItem := nil;
    Insert(0, Result);
  end;
  if UpdateMenu then
    AddToMenu;
end;

function TReopenList.AddFile(Fname: string): TReopenItem;
begin
  Result := AddFile(Fname, True);
end;

procedure TReopenList.LoadFromIni(IniFile: TDotIniFile);
var
  i, n: integer;
  M: string;
begin
  i := 0;
  while True do
  begin
    M := IniFile.ReadString(FSectionName, Format('N%u', [i]), '');
    if M = '' then
      break;
    inc(i);
  end;
  n := i;
  for i := n - 1 downto 0 do
  begin
    M := IniFile.ReadString(FSectionName, Format('N%u', [i]), '');
    AddFile(M, false);
  end;
  AddToMenu;
end;

procedure TReopenList.SaveToIni(IniFile: TDotIniFile);
var
  i: integer;
  n: integer;
begin
  n := Count;
  if n > ReOpenDeep then
    n := ReOpenDeep;
  for i := 0 to n - 1 do
  begin
    IniFile.WriteString(FSectionName, Format('N%u', [i]), Items[i].FileName);
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
      AddFile(jArr.Items[i].Value, false);
    end;
  end;
end;

function TReopenList.FindItem(AItem: TMenuItem): boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to Count - 1 do
  begin
    Result := Result or (Items[i].FileItem = AItem);
  end;
end;

procedure TReopenList.Konfig(AIndex: integer; AMenuItem: TMenuItem; AOnClickProc: TNotifyEvent);
begin
  FIndex := AIndex;
  FParentItem := AMenuItem;
  FOnClickProc := AOnClickProc;
  AddToMenu;
end;

procedure TReopenList.AddToMenu;
var
  i, n: integer;
  MItem: TMenuItem;
  Index: integer;
begin
  if Assigned(FParentItem) then
  begin
    for i := FParentItem.Count - 1 downto 0 do
    begin
      if FindItem(FParentItem.Items[i]) then
        FParentItem.Delete(i);
    end;

    Index := FIndex;
    n := Count;
    if n > ReOpenDeep then
      n := ReOpenDeep;
    for i := 0 to n - 1 do
    begin
      MItem := TMenuItem.Create(Application.Mainform);
      Items[i].FileItem := MItem;
      MItem.Caption := IntToStr(i + 1) + '. ' + Items[i].FileName;
      MItem.OnClick := FOnClickProc;
      MItem.Tag := cardinal(Self);
      FParentItem.Insert(Index, MItem);
      Index := FParentItem.IndexOf(MItem) + 1;
    end;
  end;
end;

function TReopenList.GetFileName(FItem: TMenuItem): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    if (Items[i].FileItem = FItem) then
    begin
      Result := Items[i].FileName;
    end;
  end;
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
  ReOpenBaseList := TReopenList.Create('REOPEN_CFG', 5);
  SelSections := TStringList.Create;
  FIniFilename := IncludeTrailingPathDelimiter(GetCurrentDir) +
    ChangeFileExt(ExtractFileName(Application.ExeName), '.ini');

end;

destructor TProgCfg.Destroy;
begin
  SelSections.Free;
  ReOpenBaseList.Free;
  inherited;
end;

procedure TProgCfg.LoadMainCfg;
var
  IniFile: TDotIniFile;

  jVal: TJSONValue;
  txt: string;
  MS: TMemoryStream;
  jLoader: TJSONLoader;
  jLoader2: TJSONLoader;
begin
  IniFile := TDotIniFile.Create(MainIniFName);
  try
    DevString := IniFile.ReadString('MAIN_CFG', 'DEVSTR', '');

    WorkingMap := IniFile.ReadString('MAIN_CFG', 'MAP_FILE', '');
    SelectAsmVar := IniFile.ReadBool('MAIN_CFG', 'ASM_VAR', false);
    SelectC_Var := IniFile.ReadBool('MAIN_CFG', 'C_VAR', True);
    SelectSysVar := IniFile.ReadBool('MAIN_CFG', 'SYS_VAR', false);
    AutoSaveCfg := IniFile.ReadYesNo('MAIN_CFG', 'AUTOSAVE', crYES);
    AutoRefreshMap := IniFile.ReadYesNo('MAIN_CFG', 'AUTOREFRESH', crYES);
    SelSectionMode := IniFile.ReadInteger('MAIN_CFG', 'SEL_SEC_MODE', 2);
    ScalMemCnt := IniFile.ReadInteger('MAIN_CFG', 'SCAL_MEM', 5);
    MaxVarSize := IniFile.ReadInteger('MAIN_CFG', 'MAX_VAR_SIZE', 4096);
    try
      WinTab := TWinTab(IniFile.ReadInteger('MAIN_CFG', 'WIN_TAB', ord(wtTOP)));
    except
      WinTab := wtTOP;
    end;

    SelSections.CommaText := 'bss,data';
    IniFile.ReadTStrings('MAIN_CFG', 'SEL_SEC', SelSections);
    ByteOrder := TByteOrder(IniFile.ReadInteger('MAIN_CFG', 'SYS_MOTOROLA', 0));

    if Assigned(FOnReadIni) then
      FOnReadIni(IniFile);

    ReOpenBaseList.LoadFromIni(IniFile);

  finally
    IniFile.Free;
  end;

  txt := '';
  MS := TMemoryStream.Create;
  try
    MS.LoadFromFile(ChangeFileExt(MainIniFName, '.json'));
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
      jVal := TJSONObject.ParseJSONValue(txt);
      jLoader.Init(jVal);
      if jLoader2.Init(jLoader, 'MainCfg') then
      begin
        jLoader2.Load('MAP_FILE', WorkingMap);
        jVal := jLoader2.GetObject('DEVSTR');
        if Assigned(jVal) then
           DevString := jVal.ToString;

        jLoader2.Load('ASM_VAR', SelectAsmVar);
        jLoader2.Load('C_VAR', SelectC_Var);
        jLoader2.Load('SYS_VAR', SelectSysVar);
        jLoader2.Load('AUTOSAVE', AutoSaveCfg);
        jLoader2.Load('AUTOREFRESH', AutoRefreshMap);
        jLoader2.Load('SEL_SEC_MODE', SelSectionMode);

        jLoader2.Load('SCAL_MEM', ScalMemCnt);
        jLoader2.Load('MAX_VAR_SIZE', MaxVarSize);

        try
          WinTab := TWinTab(jLoader2.LoadDef('WIN_TAB', ord(WinTab)));
        except
          WinTab := wtTOP;
        end;

        jLoader2.Load('SEL_SEC', SelSections);
        ByteOrder := TByteOrder(jLoader2.LoadDef('BYTE_ORDER', ord(ByteOrder)));
      end;

      if Assigned(FOnReadJsonCfg) then
      begin
        if jLoader2.Init(jLoader,'DeskTop') then
          FOnReadJsonCfg(jLoader2);
      end;
      ReOpenBaseList.LoadFromJObj(jLoader.getArray('ReOpenList'));

    except

    end;
  end;

end;

procedure TProgCfg.SaveMainCfg;
var
  IniFile: TDotIniFile;

  jVal: TJSONValue;
  jBuild: TJSONBuilder;
  jBuild2: TJSONBuilder;
  txt: string;
  MS: TMemoryStream;
begin

  IniFile := TDotIniFile.Create(MainIniFName);
  try
    IniFile.WriteString('MAIN_CFG', 'DEVSTR', DevString);

    IniFile.WriteString('MAIN_CFG', 'MAP_FILE', WorkingMap);
    IniFile.WriteBool('MAIN_CFG', 'ASM_VAR', SelectAsmVar);
    IniFile.WriteBool('MAIN_CFG', 'C_VAR', SelectC_Var);
    IniFile.WriteBool('MAIN_CFG', 'SYS_VAR', SelectSysVar);
    IniFile.WriteYesNo('MAIN_CFG', 'AUTOSAVE', AutoSaveCfg);
    IniFile.WriteYesNo('MAIN_CFG', 'AUTOREFRESH', AutoRefreshMap);
    IniFile.WriteInteger('MAIN_CFG', 'SEL_SEC_MODE', SelSectionMode);
    IniFile.WriteTStrings('MAIN_CFG', 'SEL_SEC', SelSections);
    IniFile.WriteInteger('MAIN_CFG', 'BYTE_ORDER', ord(ByteOrder));
    IniFile.WriteInteger('MAIN_CFG', 'SCAL_MEM', ScalMemCnt);
    IniFile.WriteInteger('MAIN_CFG', 'MAX_VAR_SIZE', MaxVarSize);
    IniFile.WriteInteger('MAIN_CFG', 'WIN_TAB', ord(WinTab));

    if Assigned(FOnWriteIni) then
      FOnWriteIni(IniFile);

    ReOpenBaseList.SaveToIni(IniFile);
  finally
    IniFile.UpdateFile;
    IniFile.Free;
  end;

  jBuild.Init;

  jBuild2.Init;

  jVal := TJSONObject.ParseJSONValue(DevString);

  jBuild2.Add('DEVSTR', jVal);
  jBuild2.Add('MAP_FILE', WorkingMap);
  jBuild2.Add('ASM_VAR', SelectAsmVar);
  jBuild2.Add('C_VAR', SelectC_Var);
  jBuild2.Add('SYS_VAR', SelectSysVar);
  jBuild2.Add('AUTOSAVE', ord(AutoSaveCfg));
  jBuild2.Add('AUTOREFRESH', ord(AutoRefreshMap));
  jBuild2.Add('SEL_SEC_MODE', SelSectionMode);

  jBuild2.Add('SEL_SEC', SelSections);
  jBuild2.Add('SYS_MOTOROLA', ord(ByteOrder));
  jBuild2.Add('SCAL_MEM', ScalMemCnt);
  jBuild2.Add('MAX_VAR_SIZE', MaxVarSize);
  jBuild2.Add('WIN_TAB', ord(WinTab));

  jBuild2.Add('SEL_SEC', SelSections);
  jBuild2.Add('SYS_MOTOROLA', ord(ByteOrder));

  jBuild.Add('MainCfg', jBuild2);

  if Assigned(FOnWriteJsonCfg) then
    jBuild.Add('DeskTop', FOnWriteJsonCfg.jobj);

  jBuild.Add('ReOpenList', ReOpenBaseList.GetJSONObject);

  txt := jBuild.jobj.ToString;
  MS := TMemoryStream.Create;
  try
    MS.write(txt[1], length(txt) * sizeof(char));
    MS.SaveToFile(ChangeFileExt(MainIniFName, '.json'));
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
