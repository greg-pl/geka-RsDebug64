unit ProgCfgUnit;

interface

uses
  Winapi.Windows,
  Messages,SysUtils,IniFiles,Menus,Forms,Classes,
  graphics,Contnrs,math,StdCtrls,
  GkStrUtils,ToolsUnit;

const
  wm_TypeDefChg = wm_User+0;
  wm_SettingsChg = wm_User+1;
  wm_ShowmemWin  = wm_User+2;
  wm_ShowStruct  = wm_User+3;
  wm_TrnsProgress = wm_User+4;
  wm_TrnsStartStop = wm_User+5;
  wm_ChildCaption = wm_User+6;
  wm_ChildClosed = wm_User+7;

  wm_WindowCmm = wm_User+100;

  wm_ReadMem1  = wm_WindowCmm+0;
  wm_ReadMem2  = wm_WindowCmm+1;

  wm_WriteMem1 = wm_WindowCmm+10;
  wm_WriteMem2 = wm_WindowCmm+11;


  INI_PARAM_DEV_STR = '_PrmDevStr_';

type
  TYesNoAsk = (crYES,crNO,crASK);
  TDotIniFile=class(TMemIniFile)
    function  ReadFloat(const Section, Name: string; Default: Double): Double; override;
    procedure WriteFloat(const Section, Name: string; Value: Double); override;
    function  ReadYesNo(const Section, Name: string; Default : TYesNoAsk):TYesNoAsk;
    procedure WriteYesNo(const Section, Name: string; value : TYesNoAsk);
    procedure ReadTStrings(const Section, Name: string; value : TStrings);
    procedure WriteTStrings(const Section, Name: string; value : TStrings);
  end;


  TReopenItem = class(TObject)
    FileName : String;
    FileItem : TMenuItem;
  end;

  TReopenList = class(TObjectList)
  private
    FSectionName     : string;
    FIndex           : integer;
    FParentItem      : TMenuItem;
    FOnClickProc     : TNotifyEvent;
    ReOpenDeep       : integer;
    function GetItem(Index: Integer): TReopenItem;
    procedure AddToMenu;
  protected
    procedure LoadFromIni(IniFile: TDotIniFile);
    procedure SaveToIni(IniFile: TDotIniFile);
    function  FindItem(AItem: TMenuItem): boolean;
    function  AddFile(Fname: string; UpdateMenu : boolean): TReopenItem; overload;
  public
    constructor Create(ASectionName : string; AReOpenDeep:integer); reintroduce;
    property  Items[Index: Integer]: TReopenItem read GetItem;
    function  AddFile(Fname: string): TReopenItem; overload;
    procedure Konfig(AIndex : integer; AMenuItem : TMenuItem; AOnClickProc : TNotifyEvent);
    function  GetFileName(FItem : TMenuItem):string;
    function  GetLastFilename:string;
    procedure GetList(SL : TStrings);
  end;

  TIniIoProc = procedure(IniFile : TDotIniFile) of object;

  PAdrCpx = ^TAdrCpx; 
  TAdrCpx = record
    AreaName : string;
    Adres    : integer;
    Size     : integer;
    Caption  : string;
  end;

  TAreaDefItem = class (TObject)
    Name      : string;
    Offset    : string;
    ByteOrder : TByteOrder;
    RegSize   : byte;
    PtrSize   : TPtrSize;
    function ToText : string;
    procedure LoadFromText(s : string);
    procedure CopyFrom(Src :TAreaDefItem);
    function GetPhAdr(Adr : cardinal):cardinal;
  end;

  TAreaDefList = class (TObjectList)
  private
    function FGetItem(Index : integer):TAreaDefItem;
  public
    MainArea : TAreaDefItem;
    constructor Create;
    destructor Destroy; override;
    property Items[Index : integer] : TAreaDefItem read FGetItem;
    function  NewItem:TAreaDefItem;
    procedure LoadFromIni(IniFile: TDotIniFile);
    procedure SaveToIni(IniFile: TDotIniFile);
    procedure LoadAreaNames(SL : TStrings);
    function  FindArea(AName : string): TAreaDefItem;
  end;

  TWinTab = (wtOFF,wtTOP,wtBOTTOM);
  TProgCfg = class(TObject)
  private
    FOnReadIni    : TIniIoProc;
    FOnWriteIni   : TIniIoProc;
    FIniFilename  : string;
  public
    ReOpenBaseList : TReopenList;
    WorkingMap     : string;
    SelectAsmVar   : boolean;
    SelectC_Var    : boolean;
    SelectSysVar   : boolean;
    AutoSaveCfg    : TYesNoAsk;
    AutoRefreshMap : TYesNoAsk;
    SelSectionMode : integer;
    SelSections    : TStringList;
    ScalMemCnt     : cardinal;
    MaxVarSize     : cardinal;
    HistDevStr     : TStringList;
    DevString      : String;
    AreaDefList    : TAreaDefList;
    WinTab         : TWinTab;

    constructor Create;
    destructor  Destroy; override;
    procedure   LoadMainCfg;
    procedure   SaveMainCfg;

    property    OnReadIni  : TIniIoProc read FOnReadIni  write FOnReadIni;
    property    OnWriteIni : TIniIoProc read FOnWriteIni write FOnWriteIni;
    property    MainIniFName : string read FIniFilename;
  end;

var
  ProgCfg : TProgCfg;
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
    Result := StrToFloat(FloatStr,DotFormatSettings);
  except
    on EConvertError do
      // Ignore EConvertError exceptions
    else
      raise;
  end;
end;


procedure TDotIniFile.WriteFloat(const Section, Name: string; Value: Double);
var
  Sep : char;
begin
  WriteString(Section, Name, FloatToStr(Value,DotFormatSettings));
end;

function  TDotIniFile.ReadYesNo(const Section, Name: string; Default : TYesNoAsk):TYesNoAsk;
var
  n: integer;
begin
  N := ReadInteger(Section,Name,ord(Default));
  if (N>=ord(low(TYesNoAsk))) and (N<=ord(high(TYesNoAsk))) then
    Result := TYesNoAsk(N)
  else
    Result := Default;
end;
procedure TDotIniFile.WriteYesNo(const Section, Name: string; value : TYesNoAsk);
begin
  WriteInteger(Section,Name,ord(Value));
end;
procedure TDotIniFile.ReadTStrings(const Section, Name: string; value : TStrings);
var
  s : string;
begin
  Value.Delimiter := ';';
  Value.QuoteChar := '"';
  s := value.DelimitedText;
  s := ReadString(Section,Name,s);
  value.DelimitedText := s;
end;


procedure TDotIniFile.WriteTStrings(const Section, Name: string; value : TStrings);
var
  s : string;
begin
  Value.Delimiter := ';';
  Value.QuoteChar := '"';
  s := Value.DelimitedText;
  WriteString(Section,name,s);
end;


// --------------------- TReopenItem ----------------------------------------
constructor TReopenList.Create(ASectionName : string; AReOpenDeep:integer);
begin
  inherited Create;
  FSectionName := ASectionName;
  ReOpenDeep := AReOpenDeep;
end;

function TReopenList.GetItem(Index: Integer): TReopenItem;
begin
  Result := (inherited GetItem(Index)) as TReopenItem;
end;

function  TReopenList.AddFile(Fname: string; UpdateMenu : boolean): TReopenItem;
var
  i   : integer;
begin
  Result := nil;
  for i:=0 to Count-1 do
  begin
    if Items[i].FileName=Fname then
    begin
      Move(i,0);
      Result := Items[i];
    end;
  end;
  if Result=nil then
  begin
    Result := TReopenItem.Create;
    Result.FileName := FName;
    Result.FileItem:=nil;
    Insert(0,Result);
  end;
  if UpdateMenu then
     AddToMenu;
end;

function TReopenList.AddFile(Fname: string): TReopenItem;
begin
  Result := AddFile(Fname,True);
end;

procedure TReopenList.LoadFromIni(IniFile: TDotIniFile);
var
  i,n : integer;
  M   : string;
begin
  i:=0;
  while true do
  begin
    M := IniFile.ReadString(FSectionName,Format('N%u',[i]),'');
    if M='' then break;
    inc(i);
  end;
  n:=i;
  for i:=n-1 downto 0 do
  begin
    M := IniFile.ReadString(FSectionName,Format('N%u',[i]),'');
    AddFile(M,false);
  end;
  AddToMenu;
end;

procedure TReopenList.SaveToIni(IniFile: TDotIniFile);
var
  i : integer;
  N : integer;
begin
  N := Count;
  if N>ReOpenDeep then N :=ReOpenDeep;
  for i:=0 to N-1 do
  begin
    IniFile.WriteString(FSectionName,Format('N%u',[i]),Items[i].FileName);
  end;
end;

function  TReopenList.FindItem(AItem: TMenuItem): boolean;
var
  i : integer;
begin
  Result := False;
  for i:=0 to Count-1 do
  begin
    Result := Result or (Items[i].FileItem=AItem);
  end;
end;

procedure TReopenList.Konfig(AIndex : integer; AMenuItem : TMenuItem; AOnClickProc : TNotifyEvent);
begin
  FIndex := AIndex;
  FParentItem := AMenuItem;
  FOnClickProc := AOnClickProc;
  AddToMenu;
end;

procedure TReopenList.AddToMenu;
var
  i,N    : integer;
  MItem  : TMenuItem;
  Index  : integer;
begin
  if Assigned(FParentItem) then
  begin
    for i:=FParentItem.Count-1 downto 0 do
    begin
      if FindItem(FParentItem.Items[i]) then
        FParentItem.Delete(i);
    end;

    Index  := FIndex;
    N:= Count;
    if N>ReOpenDeep then N :=ReOpenDeep;
    for i:=0 to N-1 do
    begin
      MItem := TMenuItem.Create(Application.Mainform);
      Items[i].FileItem := MItem;
      MItem.Caption := IntToStr(i+1)+'. '+ Items[i].FileName;
      MItem.OnClick := FOnClickProc;
      MItem.Tag     := Cardinal(Self);
      FParentItem.Insert(Index,MItem);
      Index:=FParentItem.IndexOf(MItem)+1;
    end;
  end;
end;

function  TReopenList.GetFileName(FItem : TMenuItem):string;
var
  i    : integer;
begin
  Result := '';
  for i:=0 to Count-1 do
  begin
    if (Items[i].FileItem=FItem) then
    begin
      Result := Items[i].FileName;
    end;
  end;
end;
function  TReopenList.GetLastFilename:string;
begin
  if Count>0 then
    Result := Items[0].FileName
  else
    Result := '';
end;

procedure TReopenList.GetList(SL : TStrings);
var
  i    : integer;
begin
  SL.Clear;
  for i:=0 to Count-1 do
  begin
    SL.Add(Items[i].FileName);
  end;
end;

// --------------------- ProgCFG ----------------------------------------
function TAreaDefItem.ToText : string;
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add(Name);
    SL.Add(Offset);
    SL.Add(IntToStr(RegSize));
    case ByteOrder of
    boLittle : SL.Add('L');
    boBig    : SL.Add('B');
    end;
    SL.Add(IntToStr(ord(PtrSize)));
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

procedure TAreaDefItem.LoadFromText(s : string);
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    SL.DelimitedText := s;
    while SL.Count<5 do SL.Add('');
    Name   := SL.Strings[0];
    Offset := SL.Strings[1];
    RegSize := StrToInt(SL.Strings[2]);
    if SL.Strings[3]='B' then
      ByteOrder := boBig
    else
      ByteOrder := boLittle;
    PtrSize := TPtrSize(StrToIntDef(SL.Strings[4],ord(ps32)));
  finally
    SL.Free;
  end;
end;

procedure TAreaDefItem.CopyFrom(Src :TAreaDefItem);
begin
  Name      := Src.Name;
  Offset    := Src.Offset;
  ByteOrder := Src.ByteOrder;
  RegSize   := Src.RegSize;
  PtrSize   := Src.PtrSize;
end;

function TAreaDefItem.GetPhAdr(Adr : cardinal):cardinal;
begin
  Result := MapParser.StrToAdr(Offset);
  Result := Result+Adr*RegSize;
end;

constructor TAreaDefList.Create;
begin
  inherited;
  MainArea := TAreaDefItem.Create;
  MainArea.Name := '***';
  MainArea.Offset := '0';
  MainArea.RegSize := 1;
  MainArea.ByteOrder := boLittle;
  MainArea.PtrSize := ps32;
end;

destructor TAreaDefList.Destroy;
begin
  MainArea.Free;
  inherited;
end;

function TAreaDefList.FGetItem(Index : integer):TAreaDefItem;
begin
  Result := inherited GetItem(Index) as TAreaDefItem;
end;

function TAreaDefList.NewItem:TAreaDefItem;
begin
  Result := TAreaDefItem.Create;
  Add(Result);
end;

procedure TAreaDefList.LoadFromIni(IniFile: TDotIniFile);
var
  i : integer;
  s : string;
begin
  try
    MainArea.PtrSize :=  TPtrSize(IniFile.ReadInteger('AREA_DEF','MainAreaPtrSize',ord(ps32)));
  except
    MainArea.PtrSize := ps32;
  end;

  Clear;
  i :=0;
  while true do
  begin
    s := IniFile.ReadString('AREA_DEF',Format('AREA%u',[i]),'');
    if s='' then break;
    NewItem.LoadFromText(s);
    inc(i);
  end;
end;

procedure TAreaDefList.SaveToIni(IniFile: TDotIniFile);
var
  i : integer;
begin
  IniFile.EraseSection('AREA_DEF');
  IniFile.WriteInteger('AREA_DEF','MainAreaPtrSize',ord(MainArea.PtrSize));

  for i:=0 to Count-1 do
  begin
    IniFile.WriteString('AREA_DEF',Format('AREA%u',[i]),Items[i].ToText);
  end;
end;

procedure TAreaDefList.LoadAreaNames(SL : TStrings);
var
  i: integer;
begin
  SL.Clear;
  SL.Add(MainArea.Name);
  for i:=0 to Count-1 do
  begin
    SL.Add(Items[i].Name);
  end;
end;

function  TAreaDefList.FindArea(AName : string): TAreaDefItem;
var
  i: integer;
begin
  Result := MainArea;
  for i:=0 to Count-1 do
  begin
    if AName = Items[i].Name then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

// --------------------- ProgCFG ----------------------------------------

constructor TProgCfg.Create;
begin
  inherited;
  ReOpenBaseList := TReopenList.Create('REOPEN_CFG',5);
  HistDevStr     := TStringList.Create;
  SelSections    := TStringList.Create;
  AreaDefList    := TAreaDefList.Create;
  FIniFilename   := IncludeTrailingPathDelimiter(GetCurrentDir)+
    ChangeFileExt(ExtractFileName(Application.ExeName),'.ini');

end;

destructor TProgCfg.Destroy;
begin
  SelSections.Free;
  HistDevStr.Free;
  ReOpenBaseList.Free;
  AreaDefList.Free;
  inherited;
end;


procedure   TProgCfg.LoadMainCfg;
var
  IniFile : TDotIniFile;
  S       : string;
begin
  IniFile:= TDotIniFile.Create(MainIniFName);
  try
    DevString := IniFile.ReadString('MAIN_CFG','DEVSTR','');

    s := IniFile.ReadString('MAIN_CFG','HISTSTR','');
    if s='' then
      s := 'RTCP;10.20.0.1;8040|RCOM;%RS;255;115200|MCOM;%RS;1;115200|MCOM;%RS;1;115200|UCOM;%RS;1;115200;RTU;E';
    HistDevStr.Delimiter := '"';
    HistDevStr.Delimiter := '|';
    HistDevStr.DelimitedText:=s;


    WorkingMap := IniFile.ReadString('MAIN_CFG','MAP_FILE','');
    SelectAsmVar := IniFile.ReadBool('MAIN_CFG','ASM_VAR',false);
    SelectC_Var  := IniFile.ReadBool('MAIN_CFG','C_VAR',true);
    SelectSysVar := IniFile.ReadBool('MAIN_CFG','SYS_VAR',false);
    AutoSaveCfg  := IniFile.ReadyesNo('MAIN_CFG','AUTOSAVE',crYES);
    AutoRefreshMap := IniFile.ReadYesNo('MAIN_CFG','AUTOREFRESH',crYES);
    SelSectionMode := IniFile.ReadInteger('MAIN_CFG','SEL_SEC_MODE',2);
    ScalMemCnt     := IniFile.ReadInteger('MAIN_CFG','SCAL_MEM',5);
    MaxVarSize     := IniFile.ReadInteger('MAIN_CFG','MAX_VAR_SIZE',4096);
    try
      WinTab := TWinTab(IniFile.ReadInteger('MAIN_CFG','WIN_TAB',ord(wtTOP)));
    except
      WinTab := wtTOP;
    end;




    SelSections.CommaText := 'bss,data';
    IniFile.ReadTStrings('MAIN_CFG','SEL_SEC',SelSections);
    AreaDefList.MainArea.ByteOrder := TByteOrder(IniFile.ReadInteger('MAIN_CFG','SYS_MOTOROLA',0));

    AreaDefList.LoadFromIni(IniFile);
    
    if Assigned(FOnReadIni) then
      FOnReadIni(IniFile);

    ReOpenBaseList.LoadFromIni(IniFile);

  finally
    IniFile.Free;
  end;
end;

procedure TProgCfg.SaveMainCfg;
var
  IniFile : TDotIniFile;
  S       : string;
begin
  IniFile:= TDotIniFile.Create(MainIniFName);
  try
    IniFile.WriteString('MAIN_CFG','DEVSTR',DevString);

    HistDevStr.Delimiter := '"';
    HistDevStr.Delimiter := '|';
    s := HistDevStr.DelimitedText;
    IniFile.WriteString('MAIN_CFG','HISTSTR',s);


    IniFile.WriteString('MAIN_CFG','MAP_FILE',WorkingMap);
    IniFile.WriteBool('MAIN_CFG','ASM_VAR',SelectAsmVar);
    IniFile.WriteBool('MAIN_CFG','C_VAR',SelectC_Var);
    IniFile.WriteBool('MAIN_CFG','SYS_VAR',SelectSysVar);
    IniFile.WriteYesNo('MAIN_CFG','AUTOSAVE',AutoSaveCfg);
    IniFile.WriteYesNo('MAIN_CFG','AUTOREFRESH',AutoRefreshMap);
    IniFile.WriteInteger('MAIN_CFG','SEL_SEC_MODE',SelSectionMode);
    IniFile.WriteTStrings('MAIN_CFG','SEL_SEC',SelSections);
    IniFile.WriteInteger('MAIN_CFG','SYS_MOTOROLA',ord(AreaDefList.MainArea.ByteOrder));
    IniFile.WriteInteger('MAIN_CFG','SCAL_MEM',ScalMemCnt);
    IniFile.WriteInteger('MAIN_CFG','MAX_VAR_SIZE',MaxVarSize);
    IniFile.WriteInteger('MAIN_CFG','WIN_TAB',ord(WinTab));

    if Assigned(FOnWriteIni) then
      FOnWriteIni(IniFile);

    ReOpenBaseList.SaveToIni(IniFile);
    AreaDefList.SaveToIni(IniFile);
  finally
    IniFile.UpdateFile;
    IniFile.Free;
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
