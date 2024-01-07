unit VarListUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ExtCtrls, Grids, ComCtrls, Contnrs, Clipbrd,
  Menus, StdCtrls, ImgList, Buttons, ActnList, ToolWin, IniFiles,
  MapParserUnit,
  ProgCfgUnit,
  Rsd64Definitions,
  TypeDefUnit,
  EditVarItemUnit,
  ToolsUnit,
  CommThreadUnit,
  RsdDll, System.Actions, System.ImageList,
  System.JSON,
  JSonUtils,
  EditSectionsDialog;

type
  TType = (ppByte, ppHex8, ppWord, ppInt16, ppHex16);

  TRdRegion = class(TObject)
    FRgIdx: integer;
    FVarCnt: integer;
    FBuf: array of byte;
    FAdr: cardinal;
    WorkItem: TWorkRdMemItem;
    Constructor Create(RgIdx, VarCnt, Adr, Size: integer);
    function GetSize: integer;
  end;

  TRdRegionList = class(TObjectList)
    function FGetRegion(Index: integer): TRdRegion;
    property Items[Index: integer]: TRdRegion read FGetRegion;
    function FindRegion(WorkItem: TWorkRdMemItem): TRdRegion;
  end;

  TViewVarList = class;

  TViewVar = class(TObject)
  private
    FOldFillFlag: boolean; // wype³niono obszar 'oldMem'
    FFillFlag: boolean; // wype³niono obszar 'Mem'
    FTypName: string;
    FTyp: THType;
    FRep: integer;
    OldMem: array of byte;
    FOwner: TViewVarList;
    Mem: array of byte;
    procedure FSetTypName(AName: string);
    procedure FSetRep(ARep: integer);
    procedure FSetFillFlag(AFlag: boolean);
    function FGetSize: integer;
  public
    Name: string;
    VarAdres: cardinal;
    TxMode: TShowMode;
    Manual: boolean;
    RgIdx: integer;

    property FillFlag: boolean read FFillFlag write FSetFillFlag;
    property TypName: string read FTypName write FSetTypName;
    property Typ: THType read FTyp;
    property Rep: integer read FRep write FSetRep;
    property Size: integer read FGetSize;
    Constructor Create(AOwner: TViewVarList);
    function ToText(ByteOrder: TByteOrder): string;
    function LoadFromTxt(ByteOrder: TByteOrder; tx: string): boolean;
    procedure TypeDefChg;
    procedure ReloadMapParser(OnMsg: TOnMsg);

    procedure SaveToIni(Ini: TDotIniFile; SName, IName: string);
    procedure LoadFromIni(Ini: TDotIniFile; SName, IName: string);

    function GetJSONObject: TJSONBuilder;
    procedure LoadfromJson(jLoader: TJSONLoader);

    function ISmemChg: boolean;
    function PhAdres: cardinal;
    procedure CopyDefFrom(Src: TViewVar);
  end;

  TViewVarList = class(TObjectList)
  private
    FOwnHandle: THandle;
    FOwnerHandle: THandle;
    RdRegionList: TRdRegionList;
    function GetIName(nr: integer): string;
    function GetItem(Index: integer): TViewVar;
    procedure wmReadMem1(var Msg: TMessage); message wm_ReadMem1;
    procedure wmWriteMem1(var Msg: TMessage); message wm_WriteMem1;
    procedure WndProc(var AMessage: TMessage);
  public
    constructor Create(aHandle: THandle);
    destructor Destroy; override;
    property Items[Index: integer]: TViewVar read GetItem;
    procedure TypeDefChg;
    procedure ReloadMapParser(OnMsg: TOnMsg);
    procedure ReadVars(CommThread: TCommThread; OnMsg: TOnMsg; dev: TCmmDevice);
    procedure WriteToDev(CommThread: TCommThread; dev: TCmmDevice; idx: integer);
    function FindVar(Nm: string): TViewVar;

    function GetJSONObject: TJSONValue;
    procedure LoadfromJson(jObj: TJSONValue);

    procedure SaveToIni(Ini: TDotIniFile; SName: string);
    procedure LoadFromIni(Ini: TDotIniFile; SName: string);
  end;

  TVarListForm = class(TChildForm)
    VarListView: TListView;
    Splitter: TSplitter;
    ShowVarGrid: TStringGrid;
    GridMenu: TPopupMenu;
    DelViewItem: TMenuItem;
    RefreshItem: TMenuItem;
    ListMenu: TPopupMenu;
    Odwie1: TMenuItem;
    EditItem: TMenuItem;
    CheckImageList: TImageList;
    ListPanel: TPanel;
    Panel3: TPanel;
    FilterEdit: TLabeledEdit;
    RefreshBtn: TSpeedButton;
    AddVarItem: TMenuItem;
    CopyItem: TMenuItem;
    ActionList1: TActionList;
    ReadVarAct: TAction;
    DeleteFromGridAct: TAction;
    EditValAct: TAction;
    EditValue1: TMenuItem;
    PropertyAct: TAction;
    AddVarAct: TAction;
    SortByNameAct: TAction;
    SortByAdresAct: TAction;
    Sortujwgadresu1: TMenuItem;
    Sortujwgnazwy1: TMenuItem;
    N1: TMenuItem;
    AutoReadAct: TAction;
    AutoRepTimer: TTimer;
    ShowMemAct: TAction;
    Showmemory1: TMenuItem;
    CopyAdrAct: TAction;
    EditTitleAct1: TMenuItem;
    ShowStructAct: TAction;
    ShowStructAct1: TMenuItem;
    AutoReadBtn: TToolButton;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
    ShowVarPanelBtn: TToolButton;
    AutoRepTmEdit: TComboBox;
    Label6: TLabel;
    ShowVarPanelAct: TAction;
    AddItem: TMenuItem;
    InsertVarAct: TAction;
    ToolButton4: TToolButton;
    SaveItemsBtn: TToolButton;
    AddItemsBtn: TToolButton;
    EditSectionsAct: TAction;
    ToolButton5: TToolButton;
    ReloadListAct: TAction;
    AddSectionToListAct: TAction;
    Addsectiontosectionlist1: TMenuItem;
    N2: TMenuItem;
    procedure FormActivate(Sender: TObject);
    procedure VarListViewCompare(Sender: TObject; Item1, Item2: TListItem; Data: integer; var Compare: integer);
    procedure VarListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ShowVarGridDragOver(Sender, Source: TObject; X, Y: integer; State: TDragState; var Accept: boolean);
    procedure ShowVarGridDragDrop(Sender, Source: TObject; X, Y: integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ShowVarGridRowMoved(Sender: TObject; FromIndex, ToIndex: integer);
    procedure RefreshItemClick(Sender: TObject);
    procedure Odwie1Click(Sender: TObject);
    procedure VarListViewGetImageIndex(Sender: TObject; Item: TListItem);
    procedure FilterOnBtnClick(Sender: TObject);
    procedure RefreshBtnClick(Sender: TObject);
    procedure FilterEditKeyPress(Sender: TObject; var Key: Char);
    procedure VarListViewDblClick(Sender: TObject);
    procedure ReadVarActExecute(Sender: TObject);
    procedure ReadVarActUpdate(Sender: TObject);
    procedure ShowVarGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DeleteFromGridActExecute(Sender: TObject);
    procedure DeleteFromGridActUpdate(Sender: TObject);
    procedure PropertyActExecute(Sender: TObject);
    procedure PropertyActUpdate(Sender: TObject);
    procedure EditValActExecute(Sender: TObject);
    procedure EditValActUpdate(Sender: TObject);
    procedure ShowVarGridDblClick(Sender: TObject);
    procedure AddVarActExecute(Sender: TObject);
    procedure AddVarActUpdate(Sender: TObject);
    procedure ShowVarGridKeyPress(Sender: TObject; var Key: Char);
    procedure ShowVarGridDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
    procedure SortByNameActExecute(Sender: TObject);
    procedure SortByNameActUpdate(Sender: TObject);
    procedure SortByAdresActExecute(Sender: TObject);
    procedure AutoReadActUpdate(Sender: TObject);
    procedure AutoReadActExecute(Sender: TObject);
    procedure AutoRepTimerTimer(Sender: TObject);
    procedure ShowMemActExecute(Sender: TObject);
    procedure ShowMemActUpdate(Sender: TObject);
    procedure CopyAdrActExecute(Sender: TObject);
    procedure ShowStructActExecute(Sender: TObject);
    procedure ShowStructActUpdate(Sender: TObject);
    procedure ShowVarPanelActExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InsertVarActExecute(Sender: TObject);
    procedure SaveItemsBtnClick(Sender: TObject);
    procedure AddItemsBtnClick(Sender: TObject);
    procedure EditSectionsActExecute(Sender: TObject);
    procedure EditSectionsActUpdate(Sender: TObject);
    procedure ReloadListActExecute(Sender: TObject);
    procedure AddSectionToListActExecute(Sender: TObject);
    procedure AddSectionToListActUpdate(Sender: TObject);
  private
    FSortType: integer;
    GridVarList: TViewVarList;
    FilterList: TStringList;
    LastCharTxMode: TShowMode;
    LastIntTxMode: TShowMode;
    LastLongTxMode: TShowMode;
    BufSt: boolean;
    ShowVarCfg: TSectionsCfg;
    procedure FillShowVarGrid;
    procedure PrepareFilter;
    function FilterAccept(s: string): boolean;
    procedure ReloadVarListNoMove;
    procedure wmAllDone(var Msg: TMessage); message wm_AllDone;
    procedure wmWriteMem1(var Msg: TMessage); message wm_WriteMem1;

  protected
    procedure CopyFromTemplateWin(TemplateWin: TChildForm); override;
  public

    function GetJSONObject: TJSONBuilder; override;
    procedure LoadfromJson(jParent: TJSONLoader); override;

    procedure ReloadVarList; override;
    procedure TypeDefChg; override;
    procedure SettingChg; override;
    function GetDefaultCaption: string; override;
  end;

var
  VarListForm: TVarListForm;

implementation

uses
  Main,
  Math, MemFrameUnit;

{$R *.dfm}

function BoolToStr(q: boolean): string;
begin
  if q then
    Result := '1'
  else
    Result := '0';
end;

function StrToBool(s: string): boolean;
begin
  Result := (s = '1');
end;

// ------------ TViewVar ------------------------------------------------------

constructor TViewVar.Create(AOwner: TViewVarList);
begin
  inherited Create;
  FOwner := AOwner;
  TypName := SysVarTxt[ssINT];
  TxMode := smDEFAULT;
  Rep := 1;
  Manual := false;
  RgIdx := -1;
end;

procedure TViewVar.FSetTypName(AName: string);
begin
  FTypName := AName;
  TypeDefChg;
end;

procedure TViewVar.FSetRep(ARep: integer);
begin
  FRep := ARep;
  TypeDefChg;
end;

procedure TViewVar.FSetFillFlag(AFlag: boolean);
begin
  if AFlag = false then
  begin
    if Length(OldMem) > 0 then
      move(Mem[0], OldMem[0], Length(OldMem));
    FOldFillFlag := FFillFlag;
  end;
  FFillFlag := AFlag;
end;

function TViewVar.ISmemChg: boolean;
var
  i: integer;
begin
  if FOldFillFlag then
  begin
    Result := false;
    for i := 0 to Length(Mem) - 1 do
      Result := Result or (Mem[i] <> OldMem[i]);
  end
  else
    Result := false;
end;

function TViewVar.PhAdres: cardinal;
begin
  Result := VarAdres;
end;

procedure TViewVar.CopyDefFrom(Src: TViewVar);
begin
  Manual := Src.Manual;
  Name := Src.Name;
  VarAdres := Src.VarAdres;
  TxMode := Src.TxMode;
  Rep := Src.Rep;
end;

function TViewVar.ToText(ByteOrder: TByteOrder): string;
var
  p: pbyte;
  i: integer;
  e: integer;
  txt: boolean;
begin
  if (FTyp <> nil) and (Length(Mem) > 0) and FillFlag then
  begin
    p := pbyte(@Mem[0]);
    Result := '';
    e := FTyp.GetSize(GlobTypeList);
    txt := (TxMode = smCHAR) and (e = 1);
    for i := 1 to Rep do
    begin
      Result := Result + FTyp.ToText(ByteOrder, p, GlobTypeList, TxMode);

      if (i <> Rep) and not(txt) then
        Result := Result + ';';
    end;
  end
  else
    Result := '';
end;

function TViewVar.LoadFromTxt(ByteOrder: TByteOrder; tx: string): boolean;
var
  p: pbyte;
  i: integer;
begin
  Result := false;
  if (FTyp <> nil) and (Length(Mem) > 0) then
  begin
    p := pbyte(@Mem[0]);
    Result := true;
    i := 0;
    while (i < Rep) and (tx <> '') do
    begin
      Result := Result and FTyp.LoadFromText(ByteOrder, p, GlobTypeList, TxMode, tx);
      inc(i);
    end;
  end;
end;

procedure TViewVar.TypeDefChg;
var
  n: integer;
begin
  n := 0;
  FTyp := GlobTypeList.FindType(FTypName);
  if FTyp <> nil then
  begin
    n := FRep * FTyp.GetSize(GlobTypeList);
  end;
  SetLength(Mem, n);
  SetLength(OldMem, n);
end;

function TViewVar.FGetSize: integer;
begin
  Result := Length(Mem);
end;

procedure TViewVar.ReloadMapParser(OnMsg: TOnMsg);
var
  A: cardinal;
begin
  if not(Manual) then
  begin
    A := MapParser.GetVarAdress(Name);
    if A <> UNKNOWN_ADRESS then
      VarAdres := A
    else
      OnMsg('nie odnaleziono zmiennej: ' + Name);
  end;
end;

procedure TViewVar.SaveToIni(Ini: TDotIniFile; SName, IName: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add(Name);
    SL.Add(TypName);
    SL.Add(IntToStr(Rep));
    SL.Add(ShowModeTxt[TxMode]);
    SL.Add('-');
    SL.Add(BoolToStr(Manual));
    SL.Add(IntToStr(VarAdres));
    Ini.WriteTStrings(SName, IName, SL);
  finally
    SL.Free;
  end;
end;

procedure TViewVar.LoadFromIni(Ini: TDotIniFile; SName, IName: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    Ini.ReadTStrings(SName, IName, SL);
    if SL.Count >= 1 then
      Name := SL.Strings[0];
    if SL.Count >= 2 then
      TypName := SL.Strings[1];
    if SL.Count >= 3 then
      Rep := StrToIntDef(SL.Strings[2], 1);
    if SL.Count >= 4 then
      TxMode := StrToShowMode(SL.Strings[3], smSIGN);
    if SL.Count >= 6 then
      Manual := StrToBool(SL.Strings[5]);
    if SL.Count >= 7 then
      VarAdres := StrToInt64(SL.Strings[6]);
  finally
    SL.Free;
  end;
end;

function TViewVar.GetJSONObject: TJSONBuilder;
begin
  Result.Init;
  Result.Add('Name', Name);
  Result.Add('TypName', TypName);
  Result.Add('Rep', Rep);
  Result.Add('TxMode', ShowModeTxt[TxMode]);
  Result.Add('Manual', Manual);
  Result.Add('AreaAdres', VarAdres);
end;

procedure TViewVar.LoadfromJson(jLoader: TJSONLoader);
begin
  jLoader.Load('Name', Name);
  TypName := jLoader.LoadDef('TypName', TypName);
  Rep := jLoader.LoadDef('Rep', Rep);
  TxMode := StrToShowMode(jLoader.LoadDef('TxMode', ShowModeTxt[TxMode]), smSIGN);
  jLoader.Load('Manual', Manual);
  VarAdres := jLoader.LoadDef('AreaAdres', integer(VarAdres));
end;

// ------------ TViewVarList --------------------------------------------------

Constructor TRdRegion.Create(RgIdx, VarCnt, Adr, Size: integer);
begin
  inherited Create;
  FRgIdx := RgIdx;
  FVarCnt := VarCnt;
  SetLength(FBuf, Size);
  FAdr := Adr;
  WorkItem := nil;
end;

function TRdRegion.GetSize: integer;
begin
  Result := Length(FBuf);
end;

function TRdRegionList.FGetRegion(Index: integer): TRdRegion;
begin
  Result := inherited GetItem(index) as TRdRegion;
end;

function TRdRegionList.FindRegion(WorkItem: TWorkRdMemItem): TRdRegion;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].WorkItem = WorkItem then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

// ------------ TViewVarList --------------------------------------------------

constructor TViewVarList.Create(aHandle: THandle);
begin
  inherited Create;
  FOwnerHandle := aHandle;
  RdRegionList := TRdRegionList.Create;
  FOwnHandle := Classes.AllocateHWnd(WndProc);
end;

destructor TViewVarList.Destroy;
begin
  inherited;
  RdRegionList.Free;
  Classes.DeallocateHWnd(FOwnHandle);
end;

procedure TViewVarList.WndProc(var AMessage: TMessage);
begin
  inherited;
  Dispatch(AMessage);
end;

function TViewVarList.GetItem(Index: integer): TViewVar;
begin
  Result := inherited Items[Index] as TViewVar;
end;

function TViewVarList.GetIName(nr: integer): string;
begin
  Result := 'ITEM' + IntToStr(nr);
end;

procedure TViewVarList.TypeDefChg;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].TypeDefChg;
end;

procedure TViewVarList.ReloadMapParser(OnMsg: TOnMsg);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].ReloadMapParser(OnMsg);
end;

function TViewVarList.FindVar(Nm: string): TViewVar;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].Name = Nm then
    begin
      Result := Items[i];
      break;
    end
  end;
end;

procedure TViewVarList.SaveToIni(Ini: TDotIniFile; SName: string);
var
  i: integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    Ini.ReadSection(SName, SL);
    for i := 0 to SL.Count - 1 do
    begin
      if copy(SL.Strings[i], 1, 4) = 'ITEM' then
        Ini.DeleteKey(SName, SL.Strings[i]);
    end;
  finally
    SL.Free;
  end;
  for i := 0 to Count - 1 do
  begin
    Items[i].SaveToIni(Ini, SName, GetIName(i));
  end;
end;

procedure TViewVarList.LoadFromIni(Ini: TDotIniFile; SName: string);
var
  i: integer;
  V: TViewVar;
begin
  i := 0;
  while Ini.ValueExists(SName, GetIName(i)) do
  begin
    V := TViewVar.Create(self);
    V.LoadFromIni(Ini, SName, GetIName(i));
    Add(V);
    inc(i);
  end;
end;

function TViewVarList.GetJSONObject: TJSONValue;
var
  i: integer;
begin
  Result := TJSONArray.Create;
  for i := 0 to Count - 1 do
  begin
    (Result as TJSONArray).AddElement(Items[i].GetJSONObject.jObj);
  end;
end;

procedure TViewVarList.LoadfromJson(jObj: TJSONValue);
var
  i: integer;
  V: TViewVar;
  jArr: TJSONArray;
  jLoader: TJSONLoader;
begin
  if jObj is TJSONArray then
  begin
    jArr := jObj as TJSONArray;
    for i := 0 to jArr.Count - 1 do
    begin
      if jLoader.Init(jArr.Items[i]) then
      begin
        V := TViewVar.Create(self);
        V.LoadfromJson(jLoader);
        Add(V);
      end;
    end;
  end;
end;

procedure TViewVarList.ReadVars(CommThread: TCommThread; OnMsg: TOnMsg; dev: TCmmDevice);
  procedure ClearFillFlags;
  var
    i: integer;
  begin
    for i := 0 to Count - 1 do
    begin
      Items[i].FillFlag := false;
      Items[i].RgIdx := -1;
    end;
  end;

// find for items with size!=0 and lowest Adr
  function FindMinAdrVar: TViewVar;
  var
    i: integer;
    AdrMin: cardinal;
  begin
    Result := nil;
    AdrMin := 0;
    for i := 0 to Count - 1 do
    begin
      if (Items[i].RgIdx < 0) and (Items[i].Size > 0) then
      begin
        if (Result = nil) or (Items[i].PhAdres < AdrMin) then
        begin
          Result := Items[i];
          AdrMin := Items[i].PhAdres;
        end;
      end;
    end;
  end;

const
  MAX_RD_ONE_SIZE = 4096;
var
  i: integer;
  AdrP: cardinal;
  AdrK, Adrk1: cardinal;
  VarInRegionCnt: integer;
  vVar: TViewVar;
  RdRegion: TRdRegion;
  RgIdx: integer;
begin
  ClearFillFlags;
  RdRegionList.Clear;
  RgIdx := 0;
  while true do
  begin

    AdrK := 0;
    AdrP := 0;
    VarInRegionCnt := 0;
    inc(RgIdx);
    while true do
    begin
      vVar := FindMinAdrVar;
      if not Assigned(vVar) then
        break; // no more variables

      if (VarInRegionCnt > 0) and (integer(vVar.PhAdres - AdrK) > ProgCfg.ScalMemCnt) then
        break; // distance too big

      if VarInRegionCnt = 0 then
        AdrP := vVar.PhAdres;

      Adrk1 := vVar.PhAdres + vVar.Size;
      if Adrk1 > AdrK then
        AdrK := Adrk1;

      if (VarInRegionCnt > 0) and (AdrK - AdrP >= MAX_RD_ONE_SIZE) then
        break; // record too big

      vVar.RgIdx := RgIdx;
      inc(VarInRegionCnt);
    end;
    if VarInRegionCnt = 0 then
      break;

    RdRegion := TRdRegion.Create(RgIdx, VarInRegionCnt, AdrP, AdrK - AdrP);
    RdRegionList.Add(RdRegion);
    // OnMsg(Format('AddRegion Adr=0x%8X size=%u', [RdRegion.FAdr, RdRegion.GetSize]));
  end;

  for i := 0 to RdRegionList.Count - 1 do
  begin
    RdRegion := RdRegionList.Items[i];

    RdRegion.WorkItem := TWorkRdMemItem.Create(FOwnHandle, wm_ReadMem1, RdRegion.FBuf[0], RdRegion.FAdr,
      RdRegion.GetSize);

    CommThread.AddToDoItem(RdRegion.WorkItem);
  end;
end;

procedure TViewVarList.wmReadMem1(var Msg: TMessage);
var
  Item: TWorkRdMemItem;
  RdRegion: TRdRegion;
  i: integer;
  Ofs: cardinal;
begin
  Item := TWorkRdMemItem(Msg.WParam);
  RdRegion := RdRegionList.FindRegion(Item);
  if Assigned(RdRegion) = false then
    raise Exception.Create('RdRegion not found');

  // MainForm.NL(Format('Read AddRegion Adr=0x%8X size=%u', [RdRegion.FAdr, RdRegion.GetSize]));

  for i := 0 to Count - 1 do
  begin
    if Items[i].RgIdx = RdRegion.FRgIdx then
    begin
      if Item.Result = stOK then
      begin
        Ofs := Items[i].VarAdres - RdRegion.FAdr;
        System.move(RdRegion.FBuf[Ofs], Items[i].Mem[0], Items[i].Size);
        Items[i].FillFlag := true;
      end;
    end;
  end;
  RdRegionList.Delete(RdRegionList.IndexOf(RdRegion));
  if RdRegionList.Count = 0 then
    PostMessage(FOwnerHandle, wm_AllDone, 0, 0);
  Item.Free;
end;

procedure TViewVarList.WriteToDev(CommThread: TCommThread; dev: TCmmDevice; idx: integer);
var
  WorkItem: TWorkWrMemItem;
begin
  if (idx < 0) or (idx >= Count) then
    raise Exception.Create('ViewVarList index error');

  if Items[idx].Size > 0 then
  begin
    WorkItem := TWorkWrMemItem.Create(FOwnHandle, wm_WriteMem1, Items[idx].Mem[0], Items[idx].VarAdres,
      Items[idx].Size);
    WorkItem.Tmp := idx;
    CommThread.AddToDoItem(WorkItem);
  end;
end;

procedure TViewVarList.wmWriteMem1(var Msg: TMessage);
var
  Item: TWorkWrMemItem;
begin
  Item := TWorkWrMemItem(Msg.WParam);
  PostMessage(FOwnerHandle, wm_WriteMem1, Item.Tmp, Item.Result);
  Item.Free;
end;



// ------------ TVarListForm --------------------------------------------------

procedure TVarListForm.FormCreate(Sender: TObject);
begin
  inherited;
  GridVarList := TViewVarList.Create(Handle);
  FilterList := TStringList.Create;
  LastCharTxMode := smHEX;
  LastIntTxMode := smUNSIGN;
  LastLongTxMode := smHEX;
  ShowVarCfg.Init;
  ShowVarCfg.CopyFrom(ProgCfg.SectionsCfg);

end;

procedure TVarListForm.FormDestroy(Sender: TObject);
begin
  inherited;
  GridVarList.Free;
  FilterList.Free;
  ShowVarCfg.Done;
end;

procedure TVarListForm.FormActivate(Sender: TObject);
begin
  inherited;
  ReloadVarList;
end;

procedure TVarListForm.FormShow(Sender: TObject);
begin
  inherited;
  ShowParamAct.Checked := true;
  ShowParamAct.Execute;
end;

procedure TVarListForm.CopyFromTemplateWin(TemplateWin: TChildForm);
var
  Src: TVarListForm;
  i: integer;
begin
  Src := TemplateWin as TVarListForm;
  for i := 0 to VarListView.Columns.Count - 1 do
    VarListView.Columns.Items[i].Width := Src.VarListView.Columns.Items[i].Width;

  for i := 1 to ShowVarGrid.ColCount - 1 do
    ShowVarGrid.ColWidths[i] := Src.ShowVarGrid.ColWidths[i];

  ListPanel.Width := Src.ListPanel.Width;

end;

function TVarListForm.GetJSONObject: TJSONBuilder;
begin
  Result := inherited GetJSONObject;
  Result.Add('ListColWidth', GetViewListColumnWidts(VarListView));
  Result.Add('GridColWidth', GetGridColumnWidts(ShowVarGrid));
  Result.Add('ListWidth', ListPanel.Width);
  Result.Add('ListVisible', ShowVarPanelAct.Checked);
  Result.Add('FilterStr', FilterEdit.Text);
  Result.Add('VarList', GridVarList.GetJSONObject);
  Result.Add('ShowVarCfg', ShowVarCfg.getJsonValue);

end;

procedure TVarListForm.LoadfromJson(jParent: TJSONLoader);
var
  jParent2: TJSONLoader;
begin
  inherited;
  SetViewListColumnWidts(VarListView, jParent.getDynIntArray('ListColWidth'));
  SetGridColumnWidts(ShowVarGrid, jParent.getDynIntArray('GridColWidth'));

  ListPanel.Width := jParent.LoadDef('ListWidth', ListPanel.Width);
  jParent.Load('ListVisible', ShowVarPanelAct);

  jParent.Load('FilterStr', FilterEdit);
  GridVarList.LoadfromJson(jParent.getArray('VarList'));
  if jParent2.Init(jParent, 'ShowVarCfg') then
    ShowVarCfg.JSONLoad(jParent2);
  ListPanel.Visible := ShowVarPanelAct.Checked;
  ReloadVarList;
  FillShowVarGrid;
end;

procedure TVarListForm.PrepareFilter;
var
  f: string;
  L: integer;
  dd: string;
  Quest: boolean;
  Asterix: boolean;
  i: integer;
begin
  FilterList.Clear;
  f := FilterEdit.Text;
  L := Length(f);
  dd := '';
  Quest := false;
  Asterix := false;
  for i := 1 to L do
  begin
    if f[i] = '*' then
    begin
      if dd <> '' then
        FilterList.Add(dd);
      dd := '';
      if not(Asterix) then
        FilterList.Add('*');
      Asterix := true;
    end
    else
    begin
      if f[i] = '?' then
      begin
        if not(Quest) then
        begin
          if dd <> '' then
            FilterList.Add(dd);
          dd := '';
        end;
        Quest := true;
      end
      else
      begin
        if Quest then
        begin
          if dd <> '' then
            FilterList.Add(dd);
          dd := '';
        end;
        Quest := false;
      end;
      dd := dd + f[i];
      Asterix := false;
    end;
  end;
  if dd <> '' then
    FilterList.Add(dd);
  {
    for i:=0 to FilterList.Count-1 do
    DoOnMsg(Format('[%s]',[FilterList.Strings[i]]));
  }
end;

function TVarListForm.FilterAccept(s: string): boolean;
var
  i: integer;
  L: integer;
  f: string;
  WasAsterix: boolean;
  X: integer;
begin
  s := UpperCase(s);
  Result := true;
  WasAsterix := false;
  for i := 0 to FilterList.Count - 1 do
  begin
    f := FilterList.Strings[i];
    f := UpperCase(f);
    L := Length(f);
    case f[1] of
      '*':
        WasAsterix := true;
      '?':
        begin
          s := RightCutStr(s, L);
          WasAsterix := false;
        end;
    else
      if WasAsterix then
      begin
        X := Pos(f, s);
        if X > 0 then
        begin
          s := RightCutStr(s, X + L);
        end
        else
          Result := false;
        WasAsterix := false;
      end
      else
      begin
        if Length(s) >= L then
        begin
          if copy(s, 1, L) = f then
            s := RightCutStr(s, L)
          else
            Result := false;
        end
        else
          Result := false;
      end;
    end;
    if not(Result) then
      break;
  end;
end;

procedure TVarListForm.ReloadListActExecute(Sender: TObject);
begin
  inherited;
  ReloadVarList;
end;

procedure TVarListForm.wmAllDone(var Msg: TMessage);
begin
  ReloadVarList;
end;

procedure TVarListForm.ReloadVarListNoMove;
var
  ptr: Pointer;
  i: integer;
begin
  ptr := nil;
  if Assigned(VarListView.Selected) then
    ptr := VarListView.Selected.Data;
  ReloadVarList;
  if Assigned(ptr) then
  begin
    for i := 0 to VarListView.Items.Count - 1 do
    begin
      if VarListView.Items[i].Data = ptr then
      begin
        VarListView.Items[i].Selected := true;
        break;
      end;
    end;
  end;
end;

procedure TVarListForm.ReloadVarList;
var
  i: integer;
  L: TListItem;
  M: TMapItem;
begin
  VarListView.Items.BeginUpdate;
  VarListView.Clear;
  PrepareFilter;
  for i := 0 to MapParser.MapItemList.Count - 1 do
  begin
    M := MapParser.MapItemList.Items[i];
    if M.IsNeeded(ShowVarCfg) and FilterAccept(M.Name) then
    begin
      L := VarListView.Items.Add;
      L.Caption := IntToStr(i);
      L.SubItems.Add(IntToHex(M.Adres, 6));
      if M.Size >= 0 then
        L.SubItems.Add(IntToStr(M.Size))
      else
        L.SubItems.Add('');
      L.SubItems.Add(M.Name);
      L.SubItems.Add(M.Section);
      L.Data := M;
    end;
  end;
  VarListView.AlphaSort;
  VarListView.Items.EndUpdate;
  GridVarList.ReloadMapParser(DoMsg);
  FillShowVarGrid;
  StatusBar.Panels[2].Text := Format('N=%u', [VarListView.Items.Count]);
end;

procedure TVarListForm.FilterOnBtnClick(Sender: TObject);
begin
  inherited;
  ReloadVarListNoMove;
end;

procedure TVarListForm.RefreshBtnClick(Sender: TObject);
begin
  inherited;
  ReloadVarList;
end;

procedure TVarListForm.TypeDefChg;
begin
  GridVarList.TypeDefChg;
  FillShowVarGrid;
end;

procedure TVarListForm.SettingChg;
begin
  inherited;
  ReloadVarList;

end;

function TVarListForm.GetDefaultCaption: string;
begin
  Result := 'VarList:' + IntToStr(ChildIndex);
end;

procedure TVarListForm.VarListViewColumnClick(Sender: TObject; Column: TListColumn);
begin
  inherited;
  FSortType := Column.ID;
  VarListView.AlphaSort;
end;

procedure TVarListForm.VarListViewCompare(Sender: TObject; Item1, Item2: TListItem; Data: integer;
  var Compare: integer);
var
  M1, M2: TMapItem;
  N1, N2: integer;
  s1, s2: string;
begin
  inherited;
  M1 := TMapItem(Item1.Data);
  M2 := TMapItem(Item2.Data);
  Compare := 0;
  case FSortType of
    0:
      begin
        N1 := MapParser.MapItemList.IndexOf(M1);
        N2 := MapParser.MapItemList.IndexOf(M2);
        if N1 > N2 then
          Compare := 1;
        if N1 < N2 then
          Compare := -1;
      end;
    1:
      begin
        if M1.Adres > M2.Adres then
          Compare := 1;
        if M1.Adres < M2.Adres then
          Compare := -1;
      end;
    2:
      begin
        if M1.Size > M2.Size then
          Compare := 1;
        if M1.Size < M2.Size then
          Compare := -1;
      end;
    3:
      begin
        s1 := UpperCase(M1.Name);
        s2 := UpperCase(M2.Name);
        if s1 > s2 then
          Compare := 1;
        if s1 < s2 then
          Compare := -1;
      end;
    4:
      begin
        s1 := UpperCase(M1.Section);
        s2 := UpperCase(M2.Section);
        if s1 > s2 then
          Compare := 1;
        if s1 < s2 then
          Compare := -1;
        if Compare = 0 then
        begin
          s1 := UpperCase(M1.Name);
          s2 := UpperCase(M2.Name);
          if s1 > s2 then
            Compare := 1;
          if s1 < s2 then
            Compare := -1;
        end;
      end;
  end;
end;

procedure TVarListForm.FillShowVarGrid;
var
  i: integer;
  M: TViewVar;
begin
  ShowVarGrid.Rows[0].CommaText := 'lp. Nazwa Adres Size Typ Value';
  if ShowVarGrid.RowCount < GridVarList.Count + 1 then
    ShowVarGrid.RowCount := GridVarList.Count + 1;
  for i := 0 to GridVarList.Count - 1 do
  begin
    M := GridVarList.Items[i];
    ShowVarGrid.Cells[0, i + 1] := IntToStr(i + 1);
    ShowVarGrid.Cells[1, i + 1] := M.Name;
    ShowVarGrid.Cells[2, i + 1] := IntToHex(M.VarAdres, 6);
    ShowVarGrid.Cells[3, i + 1] := ShowModeSymb[M.TxMode] + IntToStr(Length(M.Mem));

    ShowVarGrid.Cells[4, i + 1] := M.TypName;
    ShowVarGrid.Cells[5, i + 1] := M.ToText(ProgCfg.ByteOrder);
  end;
  for i := GridVarList.Count to ShowVarGrid.RowCount - 2 do
    ShowVarGrid.Rows[i + 1].CommaText := IntToStr(i + 1);
  // OnMsg('Count='+IntToStr(GridVarList.Count));
end;

procedure TVarListForm.ShowVarGridDragOver(Sender, Source: TObject; X, Y: integer; State: TDragState;
  var Accept: boolean);
begin
  inherited;
  Accept := (Source = VarListView);
end;

procedure TVarListForm.AddVarActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := (VarListView.Items.Count > 0) and (VarListView.Selected <> nil);
end;

procedure TVarListForm.AddSectionToListActUpdate(Sender: TObject);
var
  q: boolean;
  SectionName: string;
begin
  inherited;
  q := false;
  if (VarListView.Items.Count > 0) and (VarListView.Selected <> nil) then
  begin
    SectionName := TMapItem(VarListView.Selected.Data).Section;
    q := (ShowVarCfg.SelSections.IndexOf(SectionName) < 0);
  end;
  (Sender as TAction).Enabled := q;
end;

procedure TVarListForm.AddSectionToListActExecute(Sender: TObject);
var
  SectionName: string;
begin
  inherited;
  if VarListView.Selected <> nil then
  begin
    SectionName := TMapItem(VarListView.Selected.Data).Section;
    ShowVarCfg.SelSections.Add(SectionName);
    ReloadVarListNoMove;
  end;
end;

procedure TVarListForm.AddVarActExecute(Sender: TObject);
var
  i: integer;
  M: TMapItem;
  MN: TViewVar;
begin
  inherited;
  for i := 0 to VarListView.Items.Count - 1 do
  begin
    if VarListView.Items[i].Selected then
    begin
      M := TMapItem(VarListView.Items[i].Data);
      MN := TViewVar.Create(GridVarList);
      MN.Name := M.Name;
      MN.VarAdres := M.Adres;
      if M.Size = 1 then
      begin
        MN.TypName := 'char';
        MN.TxMode := LastCharTxMode;
      end
      else if M.Size = 2 then
      begin
        MN.TypName := 'int';
        MN.TxMode := LastIntTxMode;
      end
      else if M.Size = 4 then
      begin
        MN.TypName := 'long';
        MN.TxMode := LastLongTxMode;
      end
      else if M.Size > 0 then
      begin
        MN.TypName := 'char';
        MN.Rep := M.Size;
        MN.TxMode := smCHAR;
      end;
      GridVarList.Add(MN);
    end;
  end;
  VarListView.Refresh;
  FillShowVarGrid;
end;

procedure TVarListForm.VarListViewDblClick(Sender: TObject);
begin
  inherited;
  AddVarAct.Execute;
end;

procedure TVarListForm.ShowVarGridDragDrop(Sender, Source: TObject; X, Y: integer);
begin
  inherited;
  AddVarAct.Execute;
end;

procedure TVarListForm.DeleteFromGridActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := (GridVarList.Count > 0);
end;

procedure TVarListForm.DeleteFromGridActExecute(Sender: TObject);
const
  mbMY = [mbYes, mbNo, mbNoToAll, mbYesToAll];
var
  i: integer;
  M: TViewVar;
  s: string;
  YesToOne: boolean;
  YesToAll: boolean;
begin
  inherited;
  YesToAll := false;
  for i := ShowVarGrid.Selection.Bottom - 1 downto ShowVarGrid.Selection.Top - 1 do
  begin
    if i < GridVarList.Count then
    begin
      M := GridVarList.Items[i];
      YesToOne := false;
      if not(YesToAll) then
      begin
        s := 'Czy chcesz usun¹æ zmienn¹ :' + M.Name + ' ?';
        case MessageDlg(s, mtConfirmation, mbMY, 0) of
          mrNoToAll, mrCancel:
            break;
          mrYes:
            YesToOne := true;
          mrNo:
            YesToOne := false;
          mrYesToAll:
            begin
              YesToAll := true;
              YesToOne := true;
            end;
        end;
      end
      else
        YesToOne := true;
      if YesToOne then
      begin
        GridVarList.Delete(i);
      end;
    end;
  end;
  FillShowVarGrid;
end;

procedure TVarListForm.RefreshItemClick(Sender: TObject);
begin
  inherited;
  FillShowVarGrid;
end;

procedure TVarListForm.ShowVarGridRowMoved(Sender: TObject; FromIndex, ToIndex: integer);
begin
  inherited;
  FromIndex := FromIndex - 1;
  ToIndex := ToIndex - 1;
  if FromIndex < 0 then
    Exit;
  if ToIndex < 0 then
    Exit;
  if FromIndex >= GridVarList.Count then
    Exit;
  if ToIndex >= GridVarList.Count then
    ToIndex := GridVarList.Count - 1;
  GridVarList.move(FromIndex, ToIndex);
  FillShowVarGrid;
end;

procedure TVarListForm.Odwie1Click(Sender: TObject);
begin
  inherited;
  ReloadVarList;
end;

procedure TVarListForm.PropertyActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := (GridVarList.Count > 0);
end;

procedure TVarListForm.PropertyActExecute(Sender: TObject);
var
  Dlg: TEditVarItemForm;
  n: integer;
  M: TViewVar;
  i: integer;
  q1, q2, q3: boolean;
begin
  inherited;
  n := ShowVarGrid.Row - 1;
  if (n >= 0) and (n < GridVarList.Count) then
  begin
    M := GridVarList.Items[n];
    Dlg := TEditVarItemForm.Create(self);
    try
      GlobTypeList.LoadTypeList(Dlg.TypeList);
      Dlg.VarName := M.Name;
      Dlg.VarAdress := M.VarAdres;
      Dlg.Rep := M.Rep;
      Dlg.TypName := M.TypName;
      Dlg.ShowMode := M.TxMode;
      Dlg.Manual := M.Manual;
      if Dlg.ShowModal = mrOk then
      begin
        M.Name := Dlg.VarName;
        M.VarAdres := Dlg.VarAdress;
        if Dlg.TypName = 'char' then
          LastCharTxMode := Dlg.ShowMode;
        if Dlg.TypName = 'int' then
          LastIntTxMode := Dlg.ShowMode;
        if Dlg.TypName = 'long' then
          LastLongTxMode := Dlg.ShowMode;
        q1 := (M.Rep <> Dlg.Rep);
        q2 := (M.TypName <> Dlg.TypName);
        q3 := (M.TxMode <> Dlg.ShowMode);
        for i := ShowVarGrid.Selection.Top to ShowVarGrid.Selection.Bottom do
        begin
          n := i - 1;
          M := GridVarList.Items[n];
          if q1 then
            M.Rep := Dlg.Rep;
          if q2 then
            M.TypName := Dlg.TypName;
          if q3 then
            M.TxMode := Dlg.ShowMode;
        end;
        FillShowVarGrid;
      end;
    finally
      Dlg.Free;
    end;
  end;
end;

procedure TVarListForm.InsertVarActExecute(Sender: TObject);
var
  Dlg: TEditVarItemForm;
  n: integer;
  M: TViewVar;
begin
  inherited;
  Dlg := TEditVarItemForm.Create(self);
  try
    GlobTypeList.LoadTypeList(Dlg.TypeList);
    Dlg.VarName := 'New' + IntToStr(GridVarList.Count);
    Dlg.Rep := 1;
    Dlg.TypName := 'int';
    Dlg.ShowMode := smDEFAULT;
    Dlg.Manual := true;
    Dlg.VarAdress := 0;
    if Dlg.ShowModal = mrOk then
    begin
      M := TViewVar.Create(GridVarList);
      M.Manual := true;
      M.Name := Dlg.VarName;
      M.VarAdres := Dlg.VarAdress;
      M.TypName := Dlg.TypName;
      M.Rep := Dlg.Rep;
      M.TxMode := Dlg.ShowMode;
      n := ShowVarGrid.Row - 1;
      if n < GridVarList.Count then
        GridVarList.Insert(n, M)
      else
        GridVarList.Add(M);
    end;
    FillShowVarGrid;
  finally
    Dlg.Free;
  end;
end;

procedure TVarListForm.ShowVarPanelActExecute(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Checked := not((Sender as TAction).Checked);
  Splitter.Visible := (Sender as TAction).Checked;
  ListPanel.Visible := (Sender as TAction).Checked;
end;

procedure TVarListForm.ReadVarActExecute(Sender: TObject);
begin
  inherited;
  GridVarList.ReadVars(CommThread, DoMsg, dev);
  FillShowVarGrid;
end;

procedure TVarListForm.ReadVarActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := isDevConnected and not(AutoReadAct.Checked)
end;

procedure TVarListForm.VarListViewGetImageIndex(Sender: TObject; Item: TListItem);
var
  Nm: string;
begin
  inherited;
  Nm := TMapItem(Item.Data).Name;
  if GridVarList.FindVar(Nm) = nil then
    Item.ImageIndex := 1
  else
    Item.ImageIndex := 0;
end;

procedure TVarListForm.FilterEditKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #10 then
  begin
    ReloadVarList;
    Key := #0;
  end;
end;

procedure TVarListForm.ShowVarGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_DELETE then

end;

procedure TVarListForm.ShowVarGridKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #10 then
  begin
    EditValAct.Execute;
  end;
end;

procedure TVarListForm.ShowVarGridDblClick(Sender: TObject);
begin
  inherited;
  EditValAct.Execute;
end;

procedure TVarListForm.EditValActUpdate(Sender: TObject);
var
  n: integer;
  M: TViewVar;
  p: boolean;
begin
  inherited;
  p := false;
  n := ShowVarGrid.Row - 1;
  if (n >= 0) and (n < GridVarList.Count) then
  begin
    M := GridVarList.Items[n];
    if M.Typ <> nil then
      if M.Typ.IsSys then
        p := true;
  end;
  p := p and (GridVarList.Count > 0) and IsConnected;
  (Sender as TAction).Enabled := p;
end;

procedure TVarListForm.EditSectionsActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := (MapParser.MapItemList.Count > 0) and (ListPanel.Visible);
end;

procedure TVarListForm.EditSectionsActExecute(Sender: TObject);
var
  Dlg: TEditSectionsDlg;
begin
  inherited;
  Dlg := TEditSectionsDlg.Create(self);
  try
    Dlg.setSectionDef(ShowVarCfg);
    if Dlg.ShowModal = mrOk then
    begin
      Dlg.getSectionDef(ShowVarCfg);
      ReloadVarListNoMove;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TVarListForm.EditValActExecute(Sender: TObject);
var
  n: integer;
  M: TViewVar;
  i: integer;
  s: string;
  st: TStatus;
begin
  inherited;
  n := ShowVarGrid.Row - 1;
  if (n >= 0) and (n < GridVarList.Count) then
  begin
    M := GridVarList.Items[n];
    s := M.ToText(ProgCfg.ByteOrder);
    if InputQuery(M.Name, 'Podaj now¹ wartoœæ:', s) then
    begin
      for i := ShowVarGrid.Selection.Top to ShowVarGrid.Selection.Bottom do
      begin
        M := GridVarList.Items[i - 1];
        if M.LoadFromTxt(ProgCfg.ByteOrder, s) then
        begin
          GridVarList.WriteToDev(CommThread, dev, n);
        end
        else
          DoMsg('Niezrozumia³a wartoœæ dla zmiennej:' + M.Name);
      end;
      FillShowVarGrid;
    end;
  end;
end;

procedure TVarListForm.wmWriteMem1(var Msg: TMessage);
var
  Result: integer;
  idx: integer;
  vVar: TViewVar;
begin
  idx := Msg.WParam;
  Result := Msg.LParam;
  if Result <> stOK then
  begin
    vVar := GridVarList.Items[idx];
    DoMsg(Format('Error writing data to variable: %s  (idx=%u)', [vVar.Name, idx]));
  end;
end;

procedure TVarListForm.ShowStructActUpdate(Sender: TObject);
var
  n: integer;
  M: TViewVar;
  p: boolean;
begin
  inherited;
  p := false;
  n := ShowVarGrid.Row - 1;
  if (n >= 0) and (n < GridVarList.Count) then
  begin
    M := GridVarList.Items[n];
    if M.Typ <> nil then
      if M.Typ.IsStruct then
        p := true;
  end;
  (Sender as TAction).Enabled := p;
end;

procedure TVarListForm.ShowStructActExecute(Sender: TObject);
var
  n: integer;
  M: TViewVar;
begin
  inherited;
  n := ShowVarGrid.Row - 1;
  if (n >= 0) and (n < GridVarList.Count) then
  begin
    M := GridVarList.Items[n];
    if M.Typ <> nil then
      if M.Typ.IsStruct then
      begin
        AdrCpx.Adres := M.VarAdres;
        PostMessage(Application.MainForm.Handle, wm_ShowStruct, integer(@AdrCpx), cardinal(M.Typ));
      end;
  end;
end;

procedure TVarListForm.ShowVarGridDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
var
  s: string;
  Grid: TStringGrid;
  n: integer;
  M: TViewVar;
begin
  inherited;
  Grid := Sender as TStringGrid;
  if (ACol = 5) and (ARow > 0) then
  begin
    n := ARow - 1;
    if n < GridVarList.Count then
    begin
      M := GridVarList.Items[n];
      if M.ISmemChg then
      begin
        // Grid.Canvas.Font.Style := [fsBold];
        Grid.Canvas.Font.Color := clRed;
        s := ShowVarGrid.Cells[ACol, ARow];
        Grid.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, s);
      end;
    end;
  end;
end;

procedure TVarListForm.SortByNameActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := (GridVarList.Count > 1);
end;

function SortByAdressProc(Item1, Item2: Pointer): integer;
begin
  Result := 0;
  if TViewVar(Item1).VarAdres > TViewVar(Item2).VarAdres then
    Result := 1;
  if TViewVar(Item1).VarAdres < TViewVar(Item2).VarAdres then
    Result := -1;
end;

function SortByNameProc(Item1, Item2: Pointer): integer;
begin
  Result := 0;
  if TViewVar(Item1).Name > TViewVar(Item2).Name then
    Result := 1;
  if TViewVar(Item1).Name < TViewVar(Item2).Name then
    Result := -1;
end;

procedure TVarListForm.SortByNameActExecute(Sender: TObject);
begin
  inherited;
  GridVarList.Sort(SortByNameProc);
  FillShowVarGrid;
end;

procedure TVarListForm.SortByAdresActExecute(Sender: TObject);
begin
  inherited;
  GridVarList.Sort(SortByAdressProc);
  FillShowVarGrid;
end;

procedure TVarListForm.AutoReadActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := isConnected;
end;

procedure TVarListForm.AutoReadActExecute(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Checked := not((Sender as TAction).Checked);
  AutoRepTimer.Enabled := (Sender as TAction).Checked;
  try
    AutoRepTimer.Interval := StrToInt(AutoRepTmEdit.Text);
  except
    ShowMessage('le wprowadzony czas repetycji');
  end;
end;

procedure TVarListForm.AutoRepTimerTimer(Sender: TObject);
begin
  inherited;
  AutoRepTimer.Enabled := false;
  ReadVarActExecute(Sender);
  AutoRepTimer.Enabled := BufSt;
  AutoReadAct.Checked := BufSt;
end;

procedure TVarListForm.ShowMemActExecute(Sender: TObject);
var
  n: integer;
begin
  inherited;
  n := ShowVarGrid.Row - 1;
  if n < GridVarList.Count then
  begin
    AdrCpx.Adres := GridVarList.Items[n].VarAdres;
    AdrCpx.Size := GridVarList.Items[n].Size;
    AdrCpx.Caption := GridVarList.Items[n].Name;

    PostMessage(Application.MainForm.Handle, wm_ShowmemWin, integer(@AdrCpx), 0);
  end;
end;

procedure TVarListForm.ShowMemActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := (ShowVarGrid.Row - 1 < GridVarList.Count);
end;

procedure TVarListForm.CopyAdrActExecute(Sender: TObject);
var
  n: integer;
begin
  inherited;
  n := ShowVarGrid.Row - 1;
  if n < GridVarList.Count then
  begin
    clipboard.SetTextBuf(pchar('0x' + IntToHex(GridVarList.Items[n].VarAdres, 2)));
  end;
end;

procedure TVarListForm.SaveItemsBtnClick(Sender: TObject);
var
  Dlg: TSaveDialog;
  Ini: TDotIniFile;
  FName: string;
begin
  inherited;
  FName := '';
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.DefaultExt := '.ini';
    Dlg.Filter := 'Pliki ini|*.ini|Wszystkie pliki|*.*';
    if Dlg.Execute then
      FName := Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if FName <> '' then
  begin
    Ini := TDotIniFile.Create(FName);
    try
      GridVarList.SaveToIni(Ini, 'DEF');
    finally
      Ini.UpdateFile;
      Ini.Free;
    end;
  end;
end;

procedure TVarListForm.AddItemsBtnClick(Sender: TObject);
var
  Dlg: TOpenDialog;
  Ini: TDotIniFile;
  VList: TViewVarList;
  ViewVar: TViewVar;
  FName: string;
  i: integer;
begin
  inherited;
  FName := '';
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.DefaultExt := '.ini';
    Dlg.Filter := 'Pliki ini|*.ini|Wszystkie pliki|*.*';
    if Dlg.Execute then
      FName := Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if FName <> '' then
  begin
    VList := TViewVarList.Create(INVALID_HANDLE_VALUE);
    try
      Ini := TDotIniFile.Create(FName);
      try
        VList.LoadFromIni(Ini, 'DEF');
      finally
        Ini.Free;
      end;
      if VList.Count > 0 then
      begin
        for i := 0 to VList.Count - 1 do
        begin
          if VList.Items[i].Manual then
          begin
            ViewVar := TViewVar.Create(GridVarList);
            ViewVar.CopyDefFrom(VList.Items[i]);
            GridVarList.Add(ViewVar)
          end;
        end;
        VarListView.Refresh;
        FillShowVarGrid;
      end;
    finally
      VList.Free;
    end;
  end;
end;

end.
