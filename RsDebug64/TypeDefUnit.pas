unit TypeDefUnit;

interface

uses
  SysUtils,Classes,Contnrs,ComCtrls,
  MapParserUnit,
  ProgCfgUnit,
  ToolsUnit,
  IniFiles;

type
  TShowMode = (smDEFAULT,smSIGN,smUNSIGN,smHEX,smCHAR,smFRAC);
  TSysType  = (ssCHAR,ssINT,ssLONG,ssFLOAT,ssSFLOAT,ssINT64,ssDOUBLE,ssSDOUBLE);

const
  ShowModeTxt : array[TShowMode] of string = ('DEFAULT','SIGN','USIGN','HEX','CHAR','FRAC');
  ShowModeSymb: array[TShowMode] of char = ('?','S','U','H','C','R');

  SysVarTxt   : array[TSysType] of string = ('char','int','long','float','sfloat','int64','double','sdouble');
  SysVarSize  : array[TSysType] of integer = (1,2,4,4,4,8,8,8);


type
  THTypeList = class;
  THType = class(Tobject)
  private
    FFieldList : THTypeList;
    FStruct    : boolean;
    FParent    : THTypeList;
    function  GetWord(ByteOrder : TByteOrder; Dt : pbyte): word;
    function  GetDWord(ByteOrder : TByteOrder; Dt : pbyte): cardinal;
    function  GetDDWord(ByteOrder : TByteOrder; Dt : pbyte): int64;
    procedure SetWord(ByteOrder : TByteOrder; Dt : pbyte; w: word);
    procedure SetDWord(ByteOrder : TByteOrder; Dt : pbyte; w: cardinal);
    procedure SetDDWord(ByteOrder : TByteOrder; Dt : pbyte; w: int64);

    function  FGetStruct : boolean;
    function  GetIName(nr : integer):string;
    procedure SaveItemToIni(Ini :TDotIniFile; SName,Iname : string);
    procedure LoadItemFromIni(Ini :TDotIniFile; SName,Iname : string);
  public
    TName    : string;    // nazwa typu
    FldName  : string;    // nazwa pola w strukturze
    Rep      : integer;
    ShowMode : TShowMode;
    DtOfset  : integer;
    constructor Create(AParent: THTypeList); overload;
    constructor Create; overload;
    constructor Create(AParent: THTypeList; ATName: string; ARep : integer); overload;
    Destructor Destroy; override;
    function  GetFreeCopy : THType;

    function  FloatToFracStr(F : double):string;
    function  SwapI64(w : int64): int64;
    property  IsStruct : boolean read FGetStruct write FStruct;
    function  SimplToText(ByteOrder : TByteOrder; var Dt : pByte; TxMode : TShowMode) : string;
    function  ToText(ByteOrder : TByteOrder; var Dt : pByte; TypeList : THTypeList; TxMode : TShowMode) : string;
    function  LoadFromText(ByteOrder : TByteOrder; var Dt : pByte; TypeList : THTypeList; TxMode : TShowMode; var Tx : string): boolean;

    function  GetSize(TypeList :THTypeList) :integer;
    function  IsSys: boolean;
    function  IsSysBase: boolean;

    procedure SaveToIni(Ini :TDotIniFile; Sname : string);
    procedure LoadfromIni(Ini :TDotIniFile; Sname : string);
    property  FieldList : THTypeList read FFieldList;
    procedure AddField(F :THType);
    procedure InfoType(AHTypeList : THTypeList; SL :TStrings);
    function  GetItemOffset(AtypeList : THTypeList; Expl : boolean): integer;
    function  GetImageIndex : integer;

    function  Exploid(AtypeList : THTypeList) : THType;
    function  FillTree(Tree : TTreeView; Node : TTreeNode; ADtOfs : integer) : integer;
    function  ReadfromTree(Tree : TTreeView; N : TTreeNode; FindObj :THType) :THType;
  end;

  THTypeList = class(TObjectList)
  private
    FParent : THType;
    function  GetItem(Index: Integer): THType;
    function  GetSName(nr : integer):string;
  public
    constructor Create(AParent : THType);
    constructor CreateSys;
    procedure Add(Item : THType);
    property Items[Index: Integer]: THType read GetItem;
    function ToText(ByteOrder : TByteOrder; var Dt : pByte; TxMode : TShowMode) : string;
    function  GetSize(TypeList : THTypeList) : integer; overload;
    function  GetSize : integer; overload;
    procedure SaveToIni(Ini :  TDotIniFile);
    procedure LoadFromIni(Ini :  TDotIniFile);
    function  IsSys(AName : string):boolean;
    function  FindType(AName : string): THType;
    procedure LoadTypeList(SL : TStrings);
    function  GetItemOffset(AtypeList : THTypeList; AItem : THType; Expl : boolean): integer;
    function  FillTree(Tree : TTreeView; Node : TTreeNode; ADtOfs : integer): integer;
    function  ReadfromTree(Tree : TTreeView; N : TTreeNode; FindObj :THType) :THType; overload;
    function  ReadfromTree(Tree : TTreeView; FindObj :THType) :THType; overload;
    procedure SaveToFile(Fname : string);
  end;
var
  GlobTypeList : THTypeList;

function StrToShowMode(N : string; Default : TShowMode) : TShowMode;

implementation

function StrToShowMode(N : string; Default : TShowMode) : TShowMode;
var
  i : TShowMode;
begin
  Result := Default;
  for i:= low(TShowMode) to high(TShowMode) do
  begin
    if N = ShowModeTxt[i] then Result := i;
  end;
end;

function StrToSysType(N : string) : TSysType;
var
  i : TSysType;
begin
  for i:= low(TSysType) to high(TSysType) do
  begin
    if N = SysVarTxt[i] then
    begin
      Result := i;
      Exit;
    end;
  end;
  raise Exception.Create('This is no system type.');
end;


constructor THType.Create(AParent: THTypeList);
begin
  inherited Create;
  FParent := AParent;
  FFieldList := THTypeList.Create(Self);
  Rep := 1;
  FStruct := false;
end;

constructor THType.Create;
begin
  Create(nil);
end;

constructor THType.Create(AParent: THTypeList; ATName: string; ARep : integer);
begin
  Create(AParent);
  TName   := ATName;
  FldName := ATName;
  Rep := ARep;
end;

destructor THType.Destroy;
begin
  if FFieldList<>nil then
    FreeAndNil(FFieldList);
  inherited;
end;

function  THType.IsSys: boolean;
var
  i : TSysType;
begin
  Result := false;
  for i:=low(TSysType) to high(TSysType) do
  begin
    Result := Result or (TName=SysVarTxt[i]);
  end;
end;

function  THType.IsSysBase: boolean;
var
  i : TSysType;
begin
  Result := false;
  for i:=low(TSysType) to high(TSysType) do
  begin
    Result := Result or ((TName=SysVarTxt[i]) and (FldName=SysVarTxt[i]));
  end;
end;

function  THType.GetFreeCopy : THType;
begin
  Result := THType.Create(nil);
  Result.TName   := TName;
  Result.FldName := FldName;
  Result.Rep     := Rep;
  Result.ShowMode:= ShowMode;
  Result.FStruct := IsStruct;
end;

function  THType.FGetStruct : boolean;
begin
  Result := (FFieldList.Count<>0) or FStruct;
end;

function THType.GetWord(ByteOrder : TByteOrder; Dt : pbyte): word;
begin
  Result := ToolsUnit.GetWord(Dt,ByteOrder);
end;

function THType.GetDWord(ByteOrder : TByteOrder; Dt : pbyte): cardinal;
begin
  Result := ToolsUnit.GetDWord(Dt,ByteOrder);
end;

function  THType.GetDDWord(ByteOrder : TByteOrder; Dt : pbyte): int64;
begin
  Result := ToolsUnit.GetDDWord(Dt,ByteOrder);
end;

procedure THType.SetWord(ByteOrder : TByteOrder; Dt : pbyte; w: word);
begin
  ToolsUnit.SetWord(Dt,ByteOrder,w);
end;

procedure THType.SetDWord(ByteOrder : TByteOrder; Dt : pbyte; w: cardinal);
begin
  ToolsUnit.SetDWord(Dt,ByteOrder,w);
end;

procedure THType.SetDDWord(ByteOrder : TByteOrder; Dt : pbyte; w: int64);
begin
  ToolsUnit.SetDDWord(Dt,ByteOrder,w);
end;

function  THType.GetSize(TypeList :THTypeList) :integer;
var
  H : THType;
begin
  if not(IsStruct) then
  begin
    if IsSys then
      Result := SysVarSize[StrToSysType(TName)]
    else
    begin
      Result := 0;
      if TypeList<>nil then
      begin
        H := TypeList.FindType(TName);
        if H<>nil then
          Result := H.GetSize(TypeList)
      end;
    end;
  end
  else
    Result := FFieldList.GetSize(TypeList);
  Result := Result * Rep;
end;

procedure THType.AddField(F :THType);
begin
  F.FParent := FFieldList;
  FFieldList.Add(F);
end;

function THType.FloatToFracStr(F : double):string;
begin
  Result := Format('%0.9f',[f]);
end;

function THType.SwapI64(w : int64): int64;
begin
  Result := ((w shr 32) and $FFFFFFFF) or ((w and $FFFFFFFF) shl 32);
end;

function THType.SimplToText(ByteOrder : TByteOrder; var Dt : pByte; TxMode : TShowMode) : string;
var
  W   : word;
  D   : cardinal;
  I64 : int64;
  F   : Single;
  FD  : Double;
  T   : TSysType;
begin
  if TxMode=smDEFAULT then
    TxMode := ShowMode;
  Result := '';
  if IsSys then
  begin
    if  TxMode=smDEFAULT then TxMode := smSIGN;
    T := StrToSysType(TName);
    case T of
    ssCHAR :
      begin
        case TxMode of
        smSIGN    : Result := Result + InttoStr(ShortInt(Dt^));
        smUNSIGN  : Result := Result + InttoStr(Dt^);
        smHEX     : Result := Result + '0x'+IntTohex(Dt^,2);
        smCHAR    : if (DT^>=$20) then
                      Result := Result + chr(Dt^)
                    else
                      Result := Result + '.';
        smFRAC    : Result := Result + FloatToFracStr(ShortInt(Dt^)/$80);
        end;
        inc(Dt);
      end;
    ssINT:
      begin
        W := GetWord(ByteOrder,Dt);
        inc(Dt,2);
        case TxMode of
        smSIGN    : Result := Result + IntToStr(SmallInt(W));
        smUNSIGN  : Result := Result + InttoStr(W);
        smHEX     : Result := Result + '0x'+IntTohex(W,4);
        smFRAC    : Result := Result + FloatToFracStr(SmallInt(W)/$8000);
        end;
      end;
    ssLONG:
      begin
        D := GetDWord(ByteOrder,Dt);
        inc(Dt,4);
        case TxMode of
        smSIGN    : Result := Result + IntToStr(longint(D));
        smUNSIGN  : Result := Result + InttoStr(int64(D));
        smHEX     : Result := Result + '0x'+IntTohex(D,8);
        smFRAC    : Result := Result + FloatToFracStr(longint(D)/$80000000);
        end;
      end;
    ssFLOAT:
      begin
        D := GetDWord(ByteOrder,Dt);
        inc(Dt,4);
        F := pSingle(@D)^;
        Result := Result + FloatToStr(F);
      end;
    ssSFLOAT:
      begin
        D := GetDWord(ByteOrder,Dt);
        inc(Dt,4);
        D := DSwap(D);
        F := pSingle(@D)^;
        Result := Result + FloatToStr(F);
      end;
    ssINT64:
      begin
        I64 := GetDDWord(ByteOrder,Dt);
        inc(Dt,8);
        case TxMode of
        smSIGN,
        smUNSIGN  : Result := Result + InttoStr(I64);
        smHEX     : Result := Result + '0x'+IntTohex(I64,16);
        smFRAC    : Result := Result + FloatToFracStr(I64/$8000000000000000);
        end;
      end;
    ssDOUBLE:
      begin
        I64 := GetDDWord(ByteOrder,Dt);
        inc(Dt,8);
        FD := pDouble(@I64)^;
        Result := Result + FloatToStr(FD);
      end;
    ssSDOUBLE:
      begin
        I64 := GetDDWord(ByteOrder,Dt);
        inc(Dt,8);
        I64 := SwapI64(I64);
        FD := pDouble(@I64)^;
        Result := Result + FloatToStr(FD);
      end;
    end;
  end;
end;

function THType.ToText(ByteOrder : TByteOrder; var Dt : pByte; TypeList : THTypeList; TxMode : TShowMode) : string;
var
  i : integer;
  H : THType;
  T : TSysType;
begin
  if IsStruct then
  begin
    Result := '{'+FFieldList.ToText(ByteOrder,Dt,TxMode)+'} ';
  end
  else
  begin
    if TxMode=smDEFAULT then
      TxMode := ShowMode;
    Result := '';
    T := StrToSysType(TName);

    for i:=1 to Rep do
    begin
      if IsSys then
      begin
        Result := Result + SimplToText(ByteOrder, Dt,TxMode);
      end
      else
      begin
        H := TypeList.FindType(TName);
        if H<>nil then
          Result := Result + H.ToText(ByteOrder, Dt,TypeList,TxMode);
      end;
      if (i<>Rep) and (not((TxMode=smCHAR) and (T=ssCHAR))) then
        Result := Result + '; ';
    end;
  end;
end;


function  THType.LoadFromText(ByteOrder : TByteOrder; var Dt : pByte; TypeList : THTypeList; TxMode : TShowMode; var Tx : string): boolean;
var
  T   : TSysType;
  Tck : string;
  F   : single;
  FD  : double;
  I64 : int64;
  D   : Cardinal;
  N   : integer;
  W   : word;
begin
  Result:=false;
  if IsSys then
  begin
    if  TxMode=smDEFAULT then TxMode := smSIGN;
    T := StrToSysType(TName);
    try
      case T of
      ssCHAR :
        begin
          if TxMode=smChar then
          begin
            Dt^ := ord(Tx[1]);
            Tx := RightCutStr(Tx,2);
          end
          else
          begin
            Tck := GetTocken(tx);
            case TxMode of
            smSIGN,
            smUNSIGN,
            smHEX     : Dt^:=byte(StrToIntChex(Tck));
            smFRAC    : Dt^:=round(StrToFloat(Tck)*$80);
            end;
          end;
          inc(Dt);
        end;
      ssINT:
        begin
          Tck := GetTocken(tx);
          if TxMode<>smFRAC then
            W := word(StrToIntChex(Tck))
          else
            W := round(StrToFloat(Tck)*$8000);
          SetWord(ByteOrder,Dt,W);
          inc(Dt,2);
        end;
      ssLONG:
        begin
          Tck := GetTocken(tx);
          case TxMode of
          smFRAC:
            begin
              D := round(StrToFloat(Tck)*$80000000);
            end;
          smSIGN:
            begin
              N := StrToIntChex(Tck);
              D := cardinal(N);
            end;
          else
            D := StrToIntChex(Tck);
          end;
          SetDWord(ByteOrder,Dt,D);
          inc(Dt,4);
        end;
      ssFLOAT:
        begin
          Tck := GetTocken(tx);
          F := StrToFloat(Tck);
          D := PCardinal(@F)^;
          SetDWord(ByteOrder,Dt,D);
          inc(Dt,4);
        end;
      ssSFLOAT:
        begin
          Tck := GetTocken(tx);
          F := StrToFloat(Tck);
          D := PCardinal(@F)^;
          D := DSwap(D);
          SetDWord(ByteOrder,Dt,D);
          inc(Dt,4);
        end;
      ssINT64:
        begin
          Tck := GetTocken(tx);
          if TxMode<>smFRAC then
            I64  := StrToIntChex(Tck)
          else
            I64 := round(StrToFloat(Tck)*$8000000000000000);
          SetDDWord(ByteOrder,Dt,I64);
          inc(Dt,8);
        end;
      ssDOUBLE:
        begin
          Tck := GetTocken(tx);
          FD  := StrToFloat(Tck);
          I64 := pInt64(@FD)^;
          SetDDWord(ByteOrder,Dt,I64);
          inc(Dt,8);
        end;
      ssSDOUBLE:
        begin
          Tck := GetTocken(tx);
          FD  := StrToFloat(Tck);
          I64 := pInt64(@FD)^;
          I64 := SwapI64(I64);
          SetDDWord(ByteOrder,Dt,I64);
          inc(Dt,8);
        end;
      end;
      Result := true;
    except
      Result := false;
    end;
  end;
end;

function THType.GetIName(nr : integer):string;
begin
  Result := 'ITEM'+IntToStr(nr);
end;

procedure  THType.SaveToIni(Ini :TDotIniFile; Sname : string);
var
  i : integer;
begin
  Ini.WriteBool(Sname,'STRUCT',IsStruct);
  if IsStruct then
  begin
    Ini.WriteString(Sname,'NAME',FldName);
    for i:=0 to FFieldList.Count-1 do
    begin
      FFieldList.Items[i].SaveItemToIni(Ini,SName,GetIName(i));
    end;
    i := FFieldList.Count;
    while Ini.ValueExists(SName,GetIName(i)) do
    begin
      Ini.DeleteKey(SName,GetIName(i));
      inc(i);
    end;
  end
  else
    SaveItemToIni(Ini,SName,GetIName(0));
end;

procedure  THType.SaveItemToIni(Ini :TDotIniFile; SName,Iname : string);
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add(TName);
    SL.Add(FldName);
    SL.Add(IntToStr(Rep));
    SL.Add(ShowModeTxt[ShowMode]);
    Ini.WriteTStrings(Sname,IName,SL);
  finally
    SL.Free;
  end;
end;

procedure  THType.LoadfromIni(Ini :TDotIniFile; Sname : string);
var
  H     : THType;
  i     : integer;
  Struc : boolean;
begin
  Struc := Ini.ReadBool(Sname,'STRUCT',False);
  if Struc then
  begin
    FldName := Ini.readString(Sname,'NAME','');
    i := 0;
    while Ini.ValueExists(SName,GetIName(i)) do
    begin
      H := THType.Create(nil);
      H.LoadItemFromIni(Ini,SName,GetIname(i));
      AddField(H);
      inc(i);
    end;
  end
  else
    LoadItemFromIni(Ini,SName,GetIname(0));
end;


procedure THType.LoadItemFromIni(Ini :TDotIniFile; SName,Iname : string);
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    Ini.ReadTStrings(Sname,IName,SL);
    if SL.Count>=1 then  TName := SL.Strings[0]
                   else  TName := Iname;
    if SL.Count>=2 then  FldName := SL.Strings[1]
                   else  FldName := Iname;
    if SL.Count>=3 then  Rep := StrToIntDef(SL.Strings[2],1)
                   else  Rep := 1;
    if SL.Count>=4 then  ShowMode := StrToShowMode(SL.Strings[3],smSIGN)
                   else  ShowMode := smSIGN;
  finally
    SL.Free;
  end;
end;

function  THType.GetItemOffset(ATypeList : THTypeList; Expl : boolean): integer;
begin
  if FParent<>nil then
    Result := FParent.GetItemOffset(ATypeList,self,Expl)
  else
    Result := 0;
end;

function THType.GetImageIndex : integer;
begin
  if IsStruct then
  begin
    Result :=0;
  end
  else
  begin
    if IsSysBase then
      Result := 3
    else
    begin
      if IsSys then
        Result := 2
      else
        Result := 1;
    end;
  end;
end;  

function THType.Exploid(ATypeList : THTypeList) : THType;
var
  i,j : integer;
  H   : THType;
  H1  : THType;
  HT  : THType;
  k   : integer;
begin
  Result := GetFreeCopy;
  if Result.IsSys then Exit;
  if not(Result.IsStruct) then
  begin
    HT := ATypeList.FindType(Result.TName);
    if HT<>nil then
    begin
      for k:=0 to Rep-1 do
        Result.AddField(HT.Exploid(AtypeList));
    end;
  end
  else
  begin
    for i:=0 to FFieldList.Count-1 do
    begin
      H := FFieldList.Items[i];
      if H.IsSys then
      begin
        Result.AddField(H.GetFreeCopy);
      end
      else
      begin
        for k:=0 to H.Rep-1 do
        begin
          H1 := H.GetFreeCopy;
          if H.Rep>1 then
          begin
            H1.FldName := H1.FldName+Format('_%u',[k]);
            H1.Rep :=1;
          end;
          Result.AddField(H1);
          HT := ATypeList.FindType(H1.TName);
          if HT<>nil then
          begin
            if not(HT.IsStruct) then
            begin
              H1.AddField(HT.Exploid(AtypeList));
            end
            else
            begin
              for j:=0 to HT.FFieldList.Count-1 do
              begin
                H1.AddField(HT.FFieldList.Items[j].Exploid(AtypeList));
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  Result.Rep:=1;
end;


function  THType.FillTree(Tree : TTreeView; Node : TTreeNode; ADtOfs : integer) : integer;
var
  N : TTreeNode;
  H : THType;
begin
  H := GetFreeCopy;
  H.DtOfset := ADtOfs;
  N := Tree.Items.AddChildObject(Node,FldName,H);
  FieldList.FillTree(Tree,N,ADtOfs);
  Result := GetSize(nil);
end;

function  THType.ReadfromTree(Tree : TTreeView; N : TTreeNode; FindObj :THType) :THType;
begin
  Result := FFieldList.ReadfromTree(Tree,N.getFirstChild,FindObj);
end;


procedure THType.InfoType(AHTypeList : THTypeList; SL :TStrings);
begin
  SL.Clear;
  SL.Add('Nazwa .......:'+FldName);
  SL.Add('Typ .........:'+TName);
  SL.Add('Iloœæ .......:'+IntToStr(Rep));
  SL.Add('Wyœwietlanie.:'+ShowModeTxt[ShowMode]);
  SL.Add('----');
  SL.Add('Rozmiar......:'+IntToStr(GetSize(AHTypeList)));
  SL.Add('Offset.......:'+IntToStr(GetItemOffset(AHTypeList,false)));
  SL.Add('----');
  //SL.Add(ToText()
end;

//------- THTypeList -------------------------------------------------
constructor THTypeList.Create(AParent : THType);
begin
  inherited Create;
  FParent :=AParent;
end;

constructor THTypeList.CreateSys;
var
  i : TSysType;
begin
  Create(nil);
  for i:=low(TSysType) to high(TSysType) do
  begin
    Add(THType.Create(nil,SysVarTxt[i],1));
  end;
end;

procedure THTypeList.Add(Item : THType);
begin
  inherited Add(Item);
  Item.FParent := self;
end;

function  THTypeList.GetItem(Index: Integer): THType;
begin
  Result := inherited Items[Index] as THType;
end;

function  THTypeList.GetSize(TypeList : THTypeList) : integer;
var
  i : integer;
begin
  Result := 0;
  for i:=0 to Count-1 do
  begin
    Result := Result + Items[i].GetSize(TypeList);
  end;
end;

function  THTypeList.GetSize : integer;
begin
  Result := GetSize(Self);
end;

function  THTypeList.GetSName(nr : integer):string;
begin
  Result := 'TYPE_DEF_'+IntToStr(nr+1);
end;


function  THTypeList.FindType(AName : string): THType;
var
  i : integer;
begin
  Result := nil;
  for i:=0 to Count-1 do
  begin
    if Items[i].FldName=AName then
      Result := Items[i];
  end;
end;

function  THTypeList.IsSys(AName : string):boolean;
var
  H : THType;
begin
  Result := false;
  H := FindType(AName);
  if H<>nil then
    Result := H.IsSys;
end;

function THTypeList.ToText(ByteOrder : TByteOrder; var Dt : pByte; TxMode : TShowMode) : string;
var
  i : integer;
  H : THType;
begin
  Result := '';
  for i:=0 to Count-1 do
  begin
    H := Items[i];
    Result := Result + H.FldName+':'+H.ToText(ByteOrder,Dt,Self,TxMode);
    if i<>Count-1 then
      Result := Result + '; ';
  end;
end;

procedure THTypeList.SaveToIni(Ini :  TDotIniFile);
var
  i : integer;
  N : integer;
begin
  N :=0;
  for i:=0 to Count-1 do
  begin
    if not(Items[i].isSysBase) then
    begin
      Items[i].SaveToIni(Ini,GetSName(N));
      inc(N);
    end;
  end;
  while Ini.SectionExists(GetSName(N)) do
  begin
    Ini.EraseSection(GetSName(N));
    inc(N);
  end;
end;

procedure THTypeList.LoadFromIni(Ini :  TDotIniFile);
var
  n : integer;
  H : THType;
begin
  N := 0;
  while Ini.SectionExists(GetSName(N)) do
  begin
    H := THType.Create(self);
    H.LoadfromIni(Ini,GetSName(N));
    Add(H);
    inc(N);
  end;
end;

procedure THTypeList.LoadTypeList(SL : TStrings);
var
  i : integer;
begin
  SL.Clear;
  for i:=0 to Count-1 do
  begin
    SL.Add(Items[i].FldName);
  end;
end;

function  THTypeList.GetItemOffset(AtypeList : THTypeList; AItem : THType; Expl : boolean): integer;
var
  i : integer;
  s : integer;
begin
  Result := 0;
  S := 0;
  for i :=0 to Count-1 do
  begin
    if Items[i]=AItem then
    begin
      Result := S;
      Break;
    end;
    if (FParent<>nil) or Expl then
      S := S + Items[i].GetSize(AtypeList);
  end;
  if FParent<>nil then
    Result := Result+FParent.GetItemOffset(AtypeList,Expl);
end;

function  THTypeList.FillTree(Tree : TTreeView; Node : TTreeNode;ADtOfs : integer) : integer;
var
  i : integer;
begin
  for i:=0 to Count-1 do
  begin
    ADtOfs := ADtOfs + Items[i].FillTree(Tree,Node,ADtOfs);
  end;
  Result := ADtOfs;
end;


function  THTypeList.ReadfromTree(Tree : TTreeView; N : TTreeNode; FindObj :THType) :THType;
var
  H  : THType;
  H1 : THType;
begin
  Result := nil;
  while N<>nil do
  begin
    H := THType(N.Data);
    H1 := H.GetFreeCopy;
    Add(H1);
    if H=FindObj then
      Result := H1;
    H1 := H1.ReadFromTree(Tree,N,FindObj);
    if H1<>nil then
      Result := H1;
    N := N.getNextSibling;
  end;
end;

function  THTypeList.ReadfromTree(Tree : TTreeView; FindObj :THType) :THType;
begin
  Result := ReadfromTree(Tree,Tree.Items[0],FindObj);
end;

procedure THTypeList.SaveToFile(Fname : string);
var
  Ini :TDotIniFile;
begin
  Ini := TDotIniFile.Create(Fname);
  try
    SaveToIni(Ini);
  finally
    Ini.UpdateFile;
    Ini.Free;
  end;
end;


initialization
  GlobTypeList := THTypeList.CreateSys;
finalization
  GlobTypeList.Free;

end.
