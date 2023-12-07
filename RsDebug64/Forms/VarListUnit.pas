unit VarListUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ExtCtrls, Grids, ComCtrls,Contnrs,Clipbrd,
  Menus, StdCtrls, ImgList, Buttons, ActnList, ToolWin,IniFiles,
  MapParserUnit,
  ProgCfgUnit,
  TypeDefUnit,
  EditVarItemUnit,
  ToolsUnit,
  RsdDll;


type
  TType = (ppByte,ppHex8,ppWord,ppInt16,ppHex16);
  TViewVarList  =class;
  TViewVar = class(TObject)
  private
    FOldFillFlag : boolean;  // wype≥niono obszar 'oldMem'
    FFillFlag : boolean;     // wype≥niono obszar 'Mem'
    FTypName : string;
    FTyp     : THType;
    FRep     : integer;
    OldMem   : array of byte;
    FOwner   : TViewVarList;
    procedure FSetTypName(AName : string);
    procedure FSetRep(ARep : integer);
    procedure FSetFillFlag(AFlag :boolean);
  public
    Name       : string;
    AreaAdres  : cardinal;
    TxMode     : TShowMode;
    Manual     : boolean;
    Mem        : array of byte;
    property FillFlag : boolean read FFillFlag write FSetFillFlag;
    property TypName : string read FTypName write FSetTypName;
    property Typ     : THType read FTyp;
    property Rep     : integer read FRep write FSetRep;
    Constructor Create(AOwner : TViewVarList);
    function ToText(ByteOrder :TByteOrder): string;
    function LoadFromTxt(ByteOrder :TByteOrder; tx : string): boolean;
    function WriteToDev(RHan: THandle;dev : TCmmDevice):TStatus;
    procedure TypeDefChg;
    procedure ReloadMapParser(OnMsg :  TOnMsg);
    procedure SaveToIni(Ini : TDotIniFile; SName,IName : string);
    procedure LoadFromIni(Ini : TDotIniFile; SName,IName : string);
    function  ISmemChg: boolean;
    function  PhAdres : cardinal;
    procedure CopyDefFrom(Src : TViewVar);
  end;

  TViewVarList = class(TObjectList)
  private
    AreaDefItem : TAreaDefItem;
    function  GetIName(nr : integer):string;
    function  GetItem(Index: Integer): TViewVar;
  public
    constructor Create(OwnsObject : boolean);
    destructor Destroy; override;
    property Items[Index: Integer]: TViewVar read GetItem;
    procedure TypeDefChg;
    procedure ReloadMapParser(OnMsg :  TOnMsg);
    procedure SaveToIni(Ini : TDotIniFile; SName : string);
    procedure LoadFromIni(Ini : TDotIniFile; SName : string);
    function  ReadVars(RHan: THandle; OnMsg :  TOnMsg; Dev : TCmmDevice): boolean;
    function  FindVar(Nm: string):TViewVar;
    procedure GetAreaDefItem(AAreaDefItem : TAreaDefItem);
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
    Closewindow1: TMenuItem;
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
    procedure FormActivate(Sender: TObject);
    procedure VarListViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure VarListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ShowVarGridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ShowVarGridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ShowVarGridRowMoved(Sender: TObject; FromIndex,
      ToIndex: Integer);
    procedure RefreshItemClick(Sender: TObject);
    procedure Odwie1Click(Sender: TObject);
    procedure VarListViewGetImageIndex(Sender: TObject; Item: TListItem);
    procedure FilterOnBtnClick(Sender: TObject);
    procedure RefreshBtnClick(Sender: TObject);
    procedure FilterEditKeyPress(Sender: TObject; var Key: Char);
    procedure VarListViewDblClick(Sender: TObject);
    procedure ReadVarActExecute(Sender: TObject);
    procedure ReadVarActUpdate(Sender: TObject);
    procedure ShowVarGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
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
    procedure ShowVarGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
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
    procedure AreaSelectChange(Sender: TObject);
  private
    FSortType : integer;
    GridVarList    : TViewVarList;
    FilterList     : TStringList;
    LastCharTxMode : TShowMode;
    LastIntTxMode  : TShowMode;
    LastLongTxMode : TShowMode;
    BufSt          : boolean;
    procedure FillShowVarGrid;
    procedure PrepareFilter;
    function  FilterAccept(s : string) : boolean;
  public
    procedure SaveToIni(Ini : TDotIniFile; SName : string); override;
    procedure LoadFromIni(Ini : TDotIniFile; SName : string); override;
    procedure ReloadMapParser; override;
    procedure TypeDefChg; override;
    procedure SettingChg; override;
    function  GetDefaultCaption : string; override;
  end;

var
  VarListForm: TVarListForm;

implementation

uses
  Math, MemFrameUnit;

{$R *.dfm}


function BoolToStr(q : boolean):string;
begin
  if q then Result := '1'
       else Result := '0';
end;
function StrToBool(s : string):boolean;
begin
  Result := (s='1');
end;

// ------------ TViewVar ------------------------------------------------------

constructor TViewVar.Create(AOwner : TViewVarList);
begin
  inherited create;
  FOwner := AOwner;
  TypName := SysVarTxt[ssINT];
  TxMode  := smDEFAULT;
  Rep     := 1;
  Manual  := false;
end;

procedure TViewVar.FSetTypName(AName : string);
begin
  FTypName := AName;
  TypeDefChg;
end;

procedure TViewVar.FSetRep(ARep : integer);
begin
  FRep := ARep;
  TypeDefChg;
end;

procedure TViewVar.FSetFillFlag(AFlag :boolean);
begin
  if AFlag=false then
  begin
    if Length(OldMem)>0 then
      move(mem[0],oldmem[0],length(OldMem));
    FOldFillFlag := FFillFlag;
  end;
  FFillFlag := AFlag;
end;

function TViewVar.ISmemChg: boolean;
var
  i : integer;
begin
  if FOldFillFlag then
  begin
    Result := false;
    for i:=0 to Length(Mem)-1 do
      Result := Result or (mem[i]<>Oldmem[i]);
  end
  else
    Result := false;
end;

function TViewVar.PhAdres : cardinal;
begin
  Result := FOwner.AreaDefItem.GetPhAdr(AreaAdres)
end;

procedure TViewVar.CopyDefFrom(Src : TViewVar);
begin
  Manual    := Src.Manual;
  Name      := Src.Name;
  AreaAdres := Src.AreaAdres;
  TxMode    := Src.TxMode;
  Rep       := Src.Rep;
end;

function TViewVar.ToText(ByteOrder :TByteOrder): string;
var
  p : pbyte;
  i : integer;
  e : integer;
  txt : boolean;
begin
  if (FTyp<>nil) and (length(Mem)>0) and FillFlag then
  begin
    p := pbyte(@Mem[0]);
    Result := '';
    e := FTyp.GetSize(GlobTypeList);
    txt := (TxMode=smCHAR) and (e=1);
    for i:=1 to Rep do
    begin
      Result := Result + FTyp.ToText(ByteOrder,p,GlobTypeList,TxMode);

      if (i<>rep) and not(txt) then
        Result := Result + ';';
    end;
  end
  else
    Result := '';
end;

function TViewVar.LoadFromTxt(ByteOrder :TByteOrder; tx : string): boolean;
var
  p : pbyte;
  i : integer;
begin
  Result := false;
  if (FTyp<>nil) and (length(Mem)>0) then
  begin
    p := pbyte(@Mem[0]);
    Result := true;
    i:=0;
    while (i<rep) and (tx<>'') do
    begin
      Result := Result and FTyp.LoadFromText(ByteOrder, p,GlobTypeList,TxMode,Tx);
      inc(i);
    end;
  end;
end;

function TViewVar.WriteToDev(RHan: THandle; dev : TCmmDevice):TStatus;
begin
  if Length(Mem)>0 then
    Result := Dev.WriteDevMem(RHan,Mem[0],PhAdres,length(Mem))
  else
    Result := stOK;
end;

procedure TViewVar.TypeDefChg;
var
  n : integer;
begin
  N :=0;
  FTyp := GlobTypeList.FindType(FTypName);
  if FTyp<>nil then
  begin
    N := FRep*FTyp.GetSize(GlobTypeList);
  end;
  SetLength(Mem,N);
  SetLength(OldMem,N);
end;

procedure TViewVar.ReloadMapParser(OnMsg :  TOnMsg);
var
  A : cardinal;
begin
  if not(Manual) then
  begin
    A:=MapParser.GetVarAdress(Name);
    if A<>UNKNOWN_ADRESS then
      AreaAdres := A
    else
      OnMsg('nie odnaleziono zmiennej: '+Name);
  end;    
end;

procedure TViewVar.SaveToIni(Ini : TDotIniFile; SName,IName : string);

var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add(Name);
    SL.Add(TypName);
    SL.Add(IntToStr(Rep));
    SL.Add(ShowModeTxt[TxMode]);
    SL.Add('-');
    SL.Add(BoolToStr(Manual));
    SL.Add(IntToStr(AreaAdres));
    Ini.WriteTStrings(Sname,IName,SL);
  finally
    SL.Free;
  end;
end;


procedure TViewVar.LoadFromIni(Ini : TDotIniFile; SName,IName : string);
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    Ini.ReadTStrings(Sname,IName,SL);
    if SL.Count>=1 then  Name    := SL.Strings[0];
    if SL.Count>=2 then  TypName := SL.Strings[1];
    if SL.Count>=3 then  Rep     := StrToIntDef(SL.Strings[2],1);
    if SL.Count>=4 then  txMode  := StrToShowMode(SL.Strings[3],smSIGN);
    if SL.Count>=6 then  Manual  := StrToBool(SL.Strings[5]);
    if SL.Count>=7 then  AreaAdres := StrToInt64(SL.Strings[6]);
  finally
    SL.Free;
  end;
end;

// ------------ TViewVarList --------------------------------------------------
constructor TViewVarList.Create(OwnsObject : boolean);
begin
  inherited Create(OwnsObject);
  AreaDefItem := TAreaDefItem.Create;
end;
destructor TViewVarList.Destroy;
begin
  AreaDefItem.Free;
  inherited;
end;

function  TViewVarList.GetItem(Index: Integer): TViewVar;
begin
  Result := inherited Items[Index] as TViewVar;
end;
function TViewVarList.GetIName(nr : integer):string;
begin
  Result := 'ITEM'+IntToStr(nr);
end;

procedure TViewVarList.TypeDefChg;
var
  i : integer;
begin
  for i:=0 to Count-1 do
    Items[i].TypeDefChg;
end;
procedure TViewVarList.ReloadMapParser(OnMsg :  TOnMsg);
var
  i : integer;
begin
  for i:=0 to Count-1 do
    Items[i].ReloadMapParser(OnMsg);
end;

function  TViewVarList.FindVar(Nm: string):TViewVar;
var
  i : integer;
begin
  Result := nil;
  for i:=0 to Count-1 do
  begin
    if Items[i].Name = Nm then
    begin
      result := Items[i];
      Break;
    end
  end;
end;

procedure TViewVarList.SaveToIni(Ini : TDotIniFile; SName : string);
var
  i     : integer;
  SL    : TStringList;
begin
  SL := TStringList.Create;
  try
    Ini.ReadSection(SName,SL);
    for i:=0 to SL.Count-1 do
    begin
      if copy(SL.Strings[i],1,4) = 'ITEM' then
        Ini.DeleteKey(SName,SL.Strings[i]);
    end;
  finally
    SL.Free;
  end;
  for i:=0 to Count-1 do
  begin
    Items[i].SaveToIni(Ini,SName,GetIName(i));
  end;
end;

procedure TViewVarList.LoadFromIni(Ini : TDotIniFile; SName : string);
var
  i  : integer;
  V  : TViewVar;
begin
  i := 0;
  while Ini.ValueExists(SName,GetIName(i)) do
  begin
    V := TViewVar.Create(self);
    V.LoadFromIni(Ini,SName,GetIname(i));
    Add(V);
    inc(i);
  end;
end;


function TViewVarList.ReadVars(RHan: THandle; OnMsg :  TOnMsg; Dev : TCmmDevice): boolean;
  procedure ClearFillFlags;
  var
    i : integer;
  begin
    for i:=0 to Count-1 do
      Items[i].FillFlag:=False;
  end;

  function FindMinAdrVar : TViewVar;
  var
    i      : integer;
    AdrMin : cardinal;
  begin
    Result := nil;
    AdrMin :=0;
    for i:=0 to Count-1 do
    begin
      if not(Items[i].FillFlag) then
      begin
        if (Result=nil) or (Items[i].PhAdres<AdrMin) then
        begin
          Result := Items[i];
          Adrmin := Items[i].PhAdres;
        end;
      end;
    end;
  end;

const
  MAX_RD_ONE_SIZE = 4096;
var
  i       : integer;
  AdrP    : cardinal;
  AdrK    : cardinal;
  LT      : TViewVarList;
  VVar    : TViewVar;
  Size    : integer;
  ScalMem : array of byte;
  Ofs     : integer;
  st      : TStatus;
begin
  LT   := TViewVarList.Create(false);
  try
    ClearFillFlags;
    repeat
      Lt.Clear;
      Adrk := 0;
      AdrP := 0;
      repeat
        VVar := FindMinAdrVar;
        if VVar<>nil then
        begin
          if Length(VVar.Mem)<>0 then
          begin
            if (LT.Count=0) or (AdrK+ProgCfg.ScalMemCnt>VVar.PhAdres) then
            begin
              if (LT.Count=0) then
                AdrP := VVar.PhAdres;
              AdrK := VVar.PhAdres+Cardinal(Length(VVar.Mem));
              if AdrK-AdrP<MAX_RD_ONE_SIZE then
              begin
                VVar.FillFlag := true;
                LT.Add(VVar);
              end
              else
                VVar:=nil;
            end
            else
              VVar:=nil;
          end
          else
          begin
            VVar.FillFlag := true;
          end;
        end;
      until VVar=nil;

      st:=stOk;
      if LT.Count<>0 then
      begin
        Size := AdrK-AdrP;
        Setlength(ScalMem,size);
{
        s := Format('Adr=%X Size=%u N=%u',[AdrP,Size,Lt.Count]);
        for i:=0 to Lt.Count-1 do
           s := s +', '+ Lt.Items[i].Name;
        OnMsg(s);
}
        st := Dev.ReadDevMem(RHan,ScalMem[0],AdrP,size);
        for i:=0 to Lt.Count-1 do
        begin
          if st=stOk then
          begin
            Ofs := LT.Items[i].PhAdres-AdrP;
            System.Move(ScalMem[ofs],LT.Items[i].Mem[0],length(LT.Items[i].Mem));
          end
          else
          begin
            LT.Items[i].FillFlag:=false;
          end
        end
      end;
    until (LT.Count=0) or (st<>stOK);
  finally
    LT.Free;
  end;
  Result := st=stOK;
//  OnMsg(Format('Time=%u [ms]',[TT]));

end;

procedure TViewVarList.GetAreaDefItem(AAreaDefItem : TAreaDefItem);
begin
  AreaDefItem.CopyFrom(AAreaDefItem);
end;

// ------------ TVarListForm --------------------------------------------------

procedure TVarListForm.FormCreate(Sender: TObject);
begin
  inherited;
  GridVarList := TViewVarList.Create(true);
  FilterList  := TStringList.Create;
  LastCharTxMode := smHEX;
  LastIntTxMode  := smUNSIGN;
  LastLongTxMode := smHEX;
end;

procedure TVarListForm.FormDestroy(Sender: TObject);
begin
  inherited;
  GridVarList.Free;
  FilterList.Free;
end;

procedure TVarListForm.FormActivate(Sender: TObject);
begin
  inherited;
  ReloadMapParser;
  AreaSelectChange(Sender);
end;

procedure TVarListForm.FormShow(Sender: TObject);
begin
  inherited;
  ShowParamAct.Checked := true;
  ShowParamAct.Execute;
end;

procedure TVarListForm.SaveToIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  Ini.WriteString(SName,'ListColWidth',GetViewListColumnWidtsStr(VarListView));
  Ini.WriteString(SName,'GridColWidth',GetGridColumnWidtsStr(ShowVarGrid));
  Ini.WriteInteger(SName,'ListWidth',ListPanel.Width);
  Ini.WriteBool(SName,'ListVisible',ShowVarPanelAct.Checked);
  Ini.WriteString(SName,'FilterStr',FilterEdit.Text);
  GridVarList.SaveToIni(Ini,SName);
end;

procedure TVarListForm.LoadFromIni(Ini : TDotIniFile; SName : string);
var
  s : string;
begin
  inherited;
  s := Ini.ReadString(SName,'ListColWidth','');
  SetViewListColumnWidts(VarListView,s);

  s := Ini.ReadString(SName,'GridColWidth','');
  SetGridColumnWidts(ShowVarGrid,s);

  ListPanel.Width := Ini.ReadInteger(SName,'ListWidth',VarListView.Width);
  ShowVarPanelAct.Checked  := not(Ini.ReadBool(SName,'ListVisible',true));
  ShowVarPanelAct.Execute; // negacja cheked
  FilterEdit.Text :=  Ini.ReadString(SName,'FilterStr','');

  GridVarList.LoadFromIni(Ini,SName);

  GridVarList.GetAreaDefItem(AreaDefItem);

  ReloadMapParser;
  FillShowVarGrid;
end;

procedure TVarListForm.PrepareFilter;
var
  f : string;
  L : integer;
  dd  : string;
  Quest   : boolean;
  Asterix : boolean;
  i       : integer;
begin
  FilterList.Clear;
  f := FilterEdit.Text;
  L := length(f);
  dd := '';
  Quest := false;
  Asterix := false;
  for i:=1 to L do
  begin
    if f[i]='*' then
    begin
      if dd<>'' then FilterList.Add(dd);
      dd:='';
      if not(Asterix) then
        FilterList.Add('*');
      Asterix := true;
    end
    else
    begin
      if f[i]='?' then
      begin
        if not(Quest) then
        begin
          if dd<>'' then FilterList.Add(dd);
          dd := '';
        end;
        Quest := true;
      end
      else
      begin
        if Quest then
        begin
          if dd<>'' then FilterList.Add(dd);
          dd := '';
        end;
        Quest := false;
      end;
      dd := dd + f[i];
      Asterix := false;
    end;
  end;
  if dd<>'' then FilterList.Add(dd);
{
  for i:=0 to FilterList.Count-1 do
    DoOnMsg(Format('[%s]',[FilterList.Strings[i]]));
}    
end;

function  TVarListForm.FilterAccept(s : string) : boolean;
var
  i          : integer;
  L          : integer;
  f          : string;
  WasAsterix : boolean;
  x          : integer;
begin
  s := UpperCase(s);
  Result := true;
  WasAsterix := false;
  for i:=0 to FilterList.Count-1 do
  begin
    f := FilterList.Strings[i];
    f := UpperCase(f);
    L := length(f);
    case f[1] of
    '*' : WasAsterix := true;
    '?' :
      begin
        s := RightCutStr(s,L);
        WasAsterix := false;
      end;
    else
      if WasAsterix then
      begin
        x:=Pos(F,s);
        if x>0 then
        begin
          s := RightCutStr(s,x+L);
        end
        else
          Result := false;
        WasAsterix := false;
      end
      else
      begin
        if length(s)>=L then
        begin
          if copy(s,1,L)=f then
            s := RightCutStr(s,L)
          else
            Result := false;
        end
        else
          Result := false;
      end;
    end;
    if not(Result) then Break;
  end;
end;


procedure TVarListForm.ReloadMapParser;
var
  i : integer;
  L : TListItem;
  M : TMapItem;
begin
  VarListView.Items.BeginUpdate;
  VarListView.Clear;
  PrepareFilter;
  for i:=0 to MapParser.MapItemList.Count-1 do
  begin
    M := MapParser.MapItemList.Items[i];
    if M.IsNeeded and FilterAccept(M.Name) then
    begin
      L := VarListView.Items.Add;
      L.Caption := IntToStr(i);
      L.SubItems.Add(IntToHex(M.Adres,6));
      if M.Size>=0 then
        L.SubItems.Add(IntToStr(M.Size))
      else
        L.SubItems.Add('');
      L.SubItems.Add(M.Name);
      L.SubItems.Add(M.Section);
      L.Data := M;
    end;
  end;
  VarListView.Items.EndUpdate;
  GridVarList.ReloadMapParser(DoMsg);
  FillShowVarGrid;
  StatusBar.Panels[2].Text := Format('N=%u',[VarListView.Items.Count]);
end;

procedure TVarListForm.FilterOnBtnClick(Sender: TObject);
begin
  inherited;
  ReloadMapParser;
end;

procedure TVarListForm.RefreshBtnClick(Sender: TObject);
begin
  inherited;
  ReloadMapParser;
end;

procedure TVarListForm.TypeDefChg;
begin
  GridVarList.TypeDefChg;
  FillShowVarGrid;
end;

procedure TVarListForm.SettingChg;
begin
  inherited;
  ReloadMapParser;
  
end;

function  TVarListForm.GetDefaultCaption : string;
begin
  Result := MapParser.FileName;
end;

procedure TVarListForm.VarListViewColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  inherited;
  FSortType := Column.ID;
  VarListView.AlphaSort;
end;

procedure TVarListForm.VarListViewCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  M1,M2 : TMapItem;
  N1,N2 : integer;
  s1,s2 : string;
begin
  inherited;
  M1 := TMapItem(Item1.data);
  M2 := TMapItem(Item2.data);
  Compare := 0;
  case FSortType of
  0: begin
       N1 := MapParser.MapItemList.IndexOf(M1);
       N2 := MapParser.MapItemList.IndexOf(M2);
       if N1>N2 then Compare := 1;
       if N1<N2 then Compare := -1;
     end;
  1: begin
       if M1.Adres>M2.Adres then Compare := 1;
       if M1.Adres<M2.Adres then Compare := -1;
     end;
  2: begin
       if M1.Size>M2.Size then Compare := 1;
       if M1.Size<M2.Size then Compare := -1;
     end;
  3: begin
       s1 := UpperCase(M1.Name);
       s2 := UpperCase(M2.Name);
       if s1>s2 then Compare := 1;
       if s1<s2 then Compare := -1;
     end;
  4: begin
       s1 := UpperCase(M1.Section);
       s2 := UpperCase(M2.Section);
       if s1>s2 then Compare := 1;
       if s1<s2 then Compare := -1;
       if Compare=0 then
       begin
         s1 := UpperCase(M1.Name);
         s2 := UpperCase(M2.Name);
         if s1>s2 then Compare := 1;
         if s1<s2 then Compare := -1;
       end;
     end;
  end;
end;

procedure TVarListForm.FillShowVarGrid;
var
  i  : integer;
  M  : TViewVar;
begin
  ShowVarGrid.Rows[0].CommaText := 'lp. Nazwa Adres Size Typ Value';
  if ShowVarGrid.RowCount<GridVarList.Count+1 then
    ShowVarGrid.RowCount:=GridVarList.Count+1;
  for i:=0 to GridVarList.Count-1 do
  begin
    M := GridVarList.Items[i];
    ShowVarGrid.Cells[0,i+1] := intToStr(i+1);
    ShowVarGrid.Cells[1,i+1] := M.Name;
    ShowVarGrid.Cells[2,i+1] := IntToHex(M.AreaAdres,6);
    ShowVarGrid.Cells[3,i+1] := ShowModeSymb[M.TxMode]+IntToStr(Length(M.Mem));

    ShowVarGrid.Cells[4,i+1] := M.TypName;
    ShowVarGrid.Cells[5,i+1] := M.ToText(AreaDefItem.ByteOrder);
  end;
  for i:=GridVarList.Count to ShowVarGrid.RowCount-2 do
    ShowVarGrid.Rows[i+1].CommaText := intToStr(i+1);
//  OnMsg('Count='+IntToStr(GridVarList.Count));
end;

procedure TVarListForm.ShowVarGridDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited;
  Accept := (Source = VarListView);
end;

procedure TVarListForm.AddVarActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := (VarListView.Items.Count>0) and
     (VarListView.Selected<>nil);
end;

procedure TVarListForm.AddVarActExecute(Sender: TObject);
var
  i  : integer;
  M  : TMapItem;
  MN : TViewVar;
begin
  inherited;
  for i:=0 to VarListView.Items.Count-1 do
  begin
    if VarListView.Items[i].Selected then
    begin
      M := TMapItem(VarListView.Items[i].Data);
      MN := TViewVar.Create(GridVarList);
      Mn.Name := M.Name;
      Mn.AreaAdres := M.Adres;
      if M.Size=1 then
      begin
        Mn.TypName := 'char';
        Mn.TxMode  := LastCharTxMode;
      end
      else if M.Size=2 then
      begin
        Mn.TypName := 'int';
        Mn.TxMode  := LastIntTxMode;
      end
      else if M.Size=4 then
      begin
        Mn.TypName := 'long';
        Mn.TxMode  := LastLongTxMode;
      end
      else if M.Size>0 then
      begin
        Mn.TypName := 'char';
        Mn.Rep     := M.Size;
        Mn.TxMode  := smCHAR;
      end;
      GridVarList.Add(Mn);
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


procedure TVarListForm.ShowVarGridDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  inherited;
  AddVarAct.Execute;
end;



procedure TVarListForm.DeleteFromGridActUpdate(Sender: TObject);
begin
  inherited;
  (sender as TAction).Enabled := (GridVarList.Count>0);
end;

procedure TVarListForm.DeleteFromGridActExecute(Sender: TObject);
const
  mbMY = [mbYes,mbNo,mbNoToAll,mbYesToAll];
var
  i : integer;
  M : TViewVar;
  s : string;
  YesToOne : boolean;
  YesToAll : boolean;
begin
  inherited;
  YesToAll := false;
  for i:= ShowVarGrid.Selection.Bottom-1 downto ShowVarGrid.Selection.Top-1 do
  begin
    if i<GridVarList.Count then
    begin
      M := GridVarList.Items[i];
      YesToOne := False;
      if not (YesToAll) then
      begin
        s := 'Czy chcesz usunπÊ zmiennπ :'+M.Name+' ?';
        case MessageDlg(s,mtConfirmation, mbMY,0) of
        mrNoToAll,
        mrCancel    : break;
        mrYes       : YesToOne:=True;
        mrNo        : YesToOne:=False;
        mrYesToAll  : begin
                        YesToAll:=True;
                        YesToOne:=True;
                      end;
        end;
      end
      else
        YesToOne := True;
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

procedure TVarListForm.ShowVarGridRowMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
begin
  inherited;
  FromIndex := FromIndex-1;
  ToIndex := ToIndex-1;
  if FromIndex<0 then Exit;
  if ToIndex<0   then Exit;
  if FromIndex>=GridVarList.Count then Exit;
  if ToIndex>=GridVarList.Count then
    ToIndex:=GridVarList.Count-1;
  GridVarList.Move(FromIndex,ToIndex);
  FillShowVarGrid;
end;


procedure TVarListForm.Odwie1Click(Sender: TObject);
begin
  inherited;
  ReloadMapParser;
end;


procedure TVarListForm.PropertyActUpdate(Sender: TObject);
begin
  inherited;
  (sender as TAction).Enabled := (GridVarList.Count>0);
end;

procedure TVarListForm.PropertyActExecute(Sender: TObject);
var
  Dlg : TEditVarItemForm;
  N   : integer;
  M   : TViewVar;
  i   : integer;
  q1,q2,q3 : boolean;
begin
  inherited;
  N := ShowVarGrid.Row-1;
  if (N>=0) and (N<GridVarList.Count) then
  begin
    M := GridVarList.Items[n];
    Dlg := TEditVarItemForm.Create(self);
    try
      GlobTypeList.LoadTypeList(Dlg.TypeList);
      Dlg.VarName  := M.Name;
      Dlg.VarAdress:= M.AreaAdres;
      Dlg.Rep      := M.Rep;
      Dlg.Typname  := M.TypName;
      Dlg.ShowMode := M.TxMode;
      Dlg.Manual   := M.Manual;
      if Dlg.ShowModal=mrOk then
      begin
        M.Name := Dlg.VarName;
        M.AreaAdres := Dlg.VarAdress;
        if Dlg.Typname='char' then
          LastCharTxMode := Dlg.ShowMode;
        if Dlg.Typname='int' then
          LastIntTxMode := Dlg.ShowMode;
        if Dlg.Typname='long' then
          LastLongTxMode := Dlg.ShowMode;
        q1 := (M.Rep <> Dlg.Rep);
        q2 := (M.TypName <> Dlg.TypName);
        q3 := (M.TxMode  <> Dlg.ShowMode);
        for i:=ShowVarGrid.Selection.Top to ShowVarGrid.Selection.Bottom do
        begin
          n := i-1;
          M := GridVarList.Items[n];
          if q1 then
             M.Rep     := Dlg.Rep;
          if q2 then
            M.TypName := Dlg.Typname;
          if q3 then
            M.TxMode  := Dlg.ShowMode;
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
  Dlg : TEditVarItemForm;
  N   : integer;
  M   : TViewVar;
begin
  inherited;
  Dlg := TEditVarItemForm.Create(self);
  try
    GlobTypeList.LoadTypeList(Dlg.TypeList);
    Dlg.VarName  := 'New'+IntToStr(GridVarList.Count);
    Dlg.Rep      := 1;
    Dlg.Typname  := 'int';
    Dlg.ShowMode := smDEFAULT;
    Dlg.Manual   := true;
    Dlg.VarAdress := 0;
    if Dlg.ShowModal=mrOk then
    begin
      M   := TViewVar.Create(GridVarList);
      M.Manual := true;
      M.Name := Dlg.VarName;
      M.AreaAdres := Dlg.VarAdress;
      M.TypName := Dlg.Typname;
      M.Rep := Dlg.Rep;
      M.TxMode := Dlg.ShowMode;
      N := ShowVarGrid.Row-1;
      if N<GridVarList.Count then
        GridVarList.Insert(N,M)
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
  BufSt := GridVarList.ReadVars(Handle,DoMsg,Dev);
  FillShowVarGrid;
end;
procedure TVarListForm.ReadVarActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := Dev.Connected and not(AutoReadAct.Checked)
end;


procedure TVarListForm.VarListViewGetImageIndex(Sender: TObject;
  Item: TListItem);
var
  Nm : string;
begin
  inherited;
  Nm := TMapItem(Item.Data).Name;
  if GridVarList.FindVar(Nm)=nil then
    Item.ImageIndex :=1
  else
    Item.ImageIndex :=0;
end;

procedure TVarListForm.FilterEditKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key=#10 then
  begin
    ReloadMapParser;
    Key:=#0;
  end;
end;

procedure TVarListForm.ShowVarGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if Key=VK_DELETE then

end;

procedure TVarListForm.ShowVarGridKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if key=#10 then
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
  N   : integer;
  M   : TViewVar;
  p : boolean;
begin
  inherited;
  p         := false;
  N := ShowVarGrid.Row-1;
  if (N>=0) and (N<GridVarList.Count) then
  begin
    M := GridVarList.Items[n];
    if M.Typ<>nil then
      if M.Typ.IsSys then
        p := true;
  end;
  p := p and (GridVarList.Count>0) and Dev.Connected;
  (sender as TAction).Enabled := p;
end;

procedure TVarListForm.EditValActExecute(Sender: TObject);
var
  N   : integer;
  M   : TViewVar;
  i   : integer;
  s   : string;
  st  : TStatus;
begin
  inherited;
  N := ShowVarGrid.Row-1;
  if (N>=0) and (N<GridVarList.Count) then
  begin
    M := GridVarList.Items[n];
    s := M.ToText(AreaDefItem.ByteOrder);
    if InputQuery(M.Name,'Podaj nowπ wartoúÊ:',s) then
    begin
      for i:=ShowVarGrid.Selection.Top to ShowVarGrid.Selection.Bottom do
      begin
        M := GridVarList.Items[i-1];
        if M.LoadFromTxt(AreaDefItem.ByteOrder,s) then
        begin
          st := M.WriteToDev(Handle,Dev);
          if st<>stOk then
            DoMsg(Dev.GetErrStr(st));
        end
        else
          DoMsg('Niezrozumia≥a wartoúÊ dla zmiennej:'+M.Name);
      end;
      FillShowVarGrid;
    end;
  end;
end;


procedure TVarListForm.ShowStructActUpdate(Sender: TObject);
var
  N   : integer;
  M   : TViewVar;
  p : boolean;
begin
  inherited;
  p := false;
  N := ShowVarGrid.Row-1;
  if (N>=0) and (N<GridVarList.Count) then
  begin
    M := GridVarList.Items[n];
    if M.Typ<>nil then
      if M.Typ.IsStruct then
        p := true;
  end;
  (sender as TAction).Enabled := p;
end;

procedure TVarListForm.ShowStructActExecute(Sender: TObject);
var
  N   : integer;
  M   : TViewVar;
begin
  inherited;
  N := ShowVarGrid.Row-1;
  if (N>=0) and (N<GridVarList.Count) then
  begin
    M := GridVarList.Items[n];
    if M.Typ<>nil then
      if M.Typ.IsStruct then
      begin
        AdrCpx.AreaName := AreaDefItem.Name;
        AdrCpx.Adres := M.AreaAdres;
        PostMessage(Application.MainForm.Handle,wm_ShowStruct,integer(@AdrCpx),cardinal(M.Typ));
      end;
  end;
end;

procedure TVarListForm.ShowVarGridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  s    : string;
  Grid : TStringGrid;
  N    : integer;
  M   : TViewVar;
begin
  inherited;
  Grid := sender as  TStringGrid;
  if (ACol=5) and (ARow>0) then
  begin
    N := ARow-1;
    if N< GridVarList.Count then
    begin
      M := GridVarList.Items[n];
      if M.ISmemChg then
      begin
        //Grid.Canvas.Font.Style := [fsBold];
        Grid.Canvas.Font.Color := clRed;
        s := ShowVarGrid.Cells[ACol,ARow];
        Grid.Canvas.TextRect(Rect,Rect.Left+2,Rect.Top+2,s);
      end;
    end;  
  end;
end;

procedure TVarListForm.SortByNameActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := (GridVarList.Count>1);
end;

function SortByAdressProc(Item1, Item2: Pointer): Integer;
begin
  Result := 0;
  if TViewVar(Item1).AreaAdres > TViewVar(Item2).AreaAdres then Result :=1;
  if TViewVar(Item1).AreaAdres < TViewVar(Item2).AreaAdres then Result :=-1;
end;

function SortByNameProc(Item1, Item2: Pointer): Integer;
begin
  Result := 0;
  if TViewVar(Item1).Name > TViewVar(Item2).Name then Result :=1;
  if TViewVar(Item1).Name < TViewVar(Item2).Name then Result :=-1;
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
var
  q : boolean;
begin
  inherited;
  q := false;
  if Dev<>nil then
    q :=  Dev.Connected;
  (sender as TAction).Enabled := q;
end;

procedure TVarListForm.AutoReadActExecute(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Checked := not((Sender as TAction).Checked);
  AutoRepTimer.Enabled := (Sender as TAction).Checked;
  try
    AutoRepTimer.Interval := StrToInt(AutoRepTmEdit.Text);
  except
    ShowMessage('èle wprowadzony czas repetycji');
  end;
end;


procedure TVarListForm.AutoRepTimerTimer(Sender: TObject);
begin
  inherited;
  AutoRepTimer.Enabled:=false;
  ReadVarActExecute(Sender);
  AutoRepTimer.Enabled:=BufSt;
  AutoReadAct.Checked := BufSt;
end;

procedure TVarListForm.ShowMemActExecute(Sender: TObject);
var
   N : integer;
begin
  inherited;
  N := ShowVarGrid.Row-1;
  if N<GridVarList.Count then
  begin
    AdrCpx.AreaName := AreaDefItem.Name;
    AdrCpx.Adres := GridVarList.Items[N].AreaAdres;
    PostMessage(Application.MainForm.Handle,wm_ShowmemWin,integer(@AdrCpx),0);
  end;
end;

procedure TVarListForm.ShowMemActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := (ShowVarGrid.Row-1<GridVarList.Count);
end;

procedure TVarListForm.CopyAdrActExecute(Sender: TObject);
var
  N: integer;
begin
  inherited;
  N := ShowVarGrid.Row-1;
  if N<GridVarList.Count then
  begin
    clipboard.SetTextBuf(pchar(GridVarList.Items[N].Name));
  end;
end;

procedure TVarListForm.SaveItemsBtnClick(Sender: TObject);
var
  Dlg : TSaveDialog;
  Ini : TDotIniFile;
  FName : string;
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
  if Fname <>'' then
  begin
    Ini := TDotIniFile.Create(FName);
    try
      GridVarList.SaveToIni(Ini,'DEF');
    finally
      Ini.UpdateFile;
      Ini.Free;
    end;
  end;
end;

procedure TVarListForm.AddItemsBtnClick(Sender: TObject);
var
  Dlg   : TOpenDialog;
  Ini   : TDotIniFile;
  VList : TViewVarList;
  ViewVar : TViewVar;
  FName : string;
  i     : integer;
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
  if Fname <>'' then
  begin
    VList := TViewVarList.Create(true);
    try
      Ini := TDotIniFile.Create(FName);
      try
        VList.LoadFromIni(Ini,'DEF');
      finally
        Ini.Free;
      end;
      if VList.Count>0 then
      begin
        for i:=0 to VList.Count-1 do
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

procedure TVarListForm.AreaSelectChange(Sender: TObject);
begin
  inherited;
  GridVarList.AreaDefItem.CopyFrom(AreaDefItem);
end;

end.
