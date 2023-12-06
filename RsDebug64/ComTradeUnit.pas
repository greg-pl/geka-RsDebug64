unit ComTradeUnit;

interface

uses
  Windows,Classes,SysUtils,Contnrs,DateUtils,Math,Graphics,IniFiles;

type
  STR64 = string[64];
  STR32 = string[32];
  STR2  = string[2];

  TSourceVal = (svPrimary,svSecoundary);
  TDataMode = (dmPrimary,dmSecoundary,dmBinary,dmProc);
  TDataFileMode = (fmASCII,fmBINARY);
  


  TFileParam = record
    Station_Name      : STR64;          {NCr}  // nazwa obiektu
    Rec_Dev_Id        : STR64;          {NCr}  // nazwa urz¹dzenia generuj¹cego dane
    Rev_Year          : word;           {NCr}  // Rok stworzenia revisji pliku
    NominalLineFreq   : real;           {NCr}  // Czêstotliwoœc systemu
    StartPomTime      : TDateTime;      { Cr}  // Czas pierwszej probki
    WzwTime           : TDateTime;      { Cr}  // Czas wyzwolenia pomiaru
    TimeStamp         : real;           { Cr}  // odleg³oœæ miêdzy próbkami
  end;

  TViewParam = class(TObject)
  private
    FStart : double;
    FStop  : double;
    procedure FSetStart(A : double);
    procedure FSetStop(A : double);
    function  FGetIsSet: boolean;
  public
    constructor Create;
    property Start : double read FStart write  FSetStart;
    property Stop  : double read FStop  write  FSetStop;
    property IsSet : boolean read FGetIsSet;
  end;

  TSygDescr = class(TObject)
  private
    FName       : STR64;      {NCr}      // nazwa kana³u
    FOpis       : STR64;      {NCr}      // opis sygna³u
    procedure FSetName(AName : STR64);
    procedure FSetOpis(AName : STR64);
  protected
    FBufferSize : integer;
    function  StrValidate(AName : string) : string;
    procedure ValidDataWsk(var Start : integer; var Stop: integer);
  public
    Index     : integer;    { Cr}      // numer kana³u
    PhaseIden : STR2;       {NCr}      // numer fazy
    Visible   : boolean;    // zapisywany w Hdr
    PenColor  : TColor;     // zapisywany w Hdr
    BkColor   : TColor;     // zapisywany w Hdr
    Tag       : integer;
    TagR      : real;
    constructor Create;
    property Name : STR64 read Fname write FSetName;
    property Opis : STR64 read FOpis write FSetOpis;
  end;


  TMemMode = (mmINT16,mmINT32,mmFLOAT,mmDOUBLE);
  TAnalogDescr = class(TSygDescr)
  private
    SDATA       : array of smallint;
    IDATA       : array of integer;
    FData       : array of Single;
    RData       : array of double;
    FMemMode    : TMemMode;
    FUnits      : STR32;      { Cr}      // jednostka
    FDataMode   : TDataMode;
    procedure FSetUnits(AUnit : STR32);
    function  FGetValue(Index: integer):Double;
    procedure FSetValue(Index: integer; aValue:Double);
    function  FGetBinValue(Index: integer):smallint;
    procedure FSetBinValue(Index: integer; aValue:smallint);
    procedure FSetDataMode(mode : TDataMode);
    function  FGetDataMode : TDataMode;
    procedure FSetBufferSize(ASize : integer);
  protected
    procedure SaveToHdrFile(IniF : TMemIniFile; Nr : integer); virtual;
    procedure LoadFromHdrFile(IniF : TMemIniFile; Nr : integer); virtual;

  public
    Primary   : real;       { Cr}      // wartoœæ wielkosci strony pierwotnej
    Secondary : real;       { Cr}      // wartoœæ wielkosci strony wtórnej
    RangMin   : integer;    { Cr}      // minimalna wartoœæ próbki
    RangMax   : integer;    { Cr}      // maxymalna wartoœæ próbki
    Multipl   : real;       { Cr}      // zakres wejsciowy
    Offset    : real;       { Cr}      // offset
    PS        : TSourceVal; { Cr}      // wartoœci dla strony wtórnej lub pierwotnej
    TimeSkew  : real;       {NCr}      // przesuniêcie próbki w uS
    AutoScale : boolean;
    UniPolar  : boolean;

    constructor Create; overload;
    constructor Create(MemMode : TMemMode); overload;
    destructor  Destroy; override;
    property    BufferSize : integer read FBufferSize write FSetBufferSize;

    property    Units : STR32 read FUnits write FSetUnits;
    property    Value[index: integer]: Double read FGetValue write FSetValue;
    property    BinValue[index: integer]: smallint read FGetBinValue write FSetBinValue;
    property    DataMode : TDataMode read FGetDataMode write FSetDataMode;
    function    GetDataModeValue(Mode : TDataMode; D : integer) : double;
    procedure   ScaleAnalog;
    function    GetUnits: string;
    function    GetDataMax : double;
    function    GetDataMin : double;
    function    GetZakres : double;
    function    GetValueMode(Mode: TDataMode; NrProb: integer; var Exist : boolean):Double;
    function    GetModeValueStr(Mode: TDataMode; NrProb: integer):string;
    function    GetValue(NrProb: integer; var Exist : boolean):Double; overload;
    function    GetValue(NrProb: integer):Double; overload;
    procedure   KorrektRanges;
    function    ToComtrTxt(FullStd: boolean):string;
  end;

  TAnalogList = class(TObjectList)
  private
    function GetItem(Index: Integer): TAnalogDescr;
    procedure SetItem(Index: Integer; AObject: TAnalogDescr);
  protected
    procedure SaveToHdrFile(IniF : TMemIniFile); virtual;
    procedure LoadFromHdrFile(IniF : TMemIniFile); virtual;
  public
    property  Items[Index: Integer]: TAnalogDescr read GetItem write SetItem;
    function  AddSyg(AmemMode : TMemMode): TAnalogDescr; virtual;
    function  GetCommaNames :string;
    function  FindSygnal(AName : string): TAnalogDescr;
    procedure KorrektRanges;
    procedure ScaleAnalog;
    procedure ToComtrTxt(SL :TStringList ;FullStd: boolean);
  end;

  TCyfrDescr = class(TSygDescr)
  private
    BData      : array of boolean;
    function  FGetValue(Index: integer):boolean;
    procedure FSetValue(Index: integer; aValue:boolean);
    procedure FSetBufferSize(ASize : integer);
  protected
//    procedure SaveToHdrFile(IniF : TMemIniFile; Nr : integer); virtual;
//    procedure LoadFromHdrFile(IniF : TMemIniFile; Nr : integer); virtual;
  public
    NomState  : boolean;    { Cr}      // stan nominalny sygna³u
    constructor Create;
    destructor  Destroy; override;
    property    BufferSize : integer read FBufferSize write FSetBufferSize;
    function    GetValue(NrProb: integer; var Exist : boolean):boolean;
    property    Value[index: integer]: boolean read FGetValue write FSetValue;
    function    ToComtrTxt(FullStd: boolean):string;
  end;
  TCyfrList = class(TObjectList)
  private
    function GetItem(Index: Integer): TCyfrDescr;
  protected
//    procedure SaveToHdrFile(IniF : TMemIniFile); virtual;
//    procedure LoadFromHdrFile(IniF : TMemIniFile); virtual;
  public
    property  Items[Index: Integer]: TCyfrDescr read GetItem;
    function  AddSyg: TCyfrDescr; virtual;
    procedure ToComtrTxt(SL :TStringList; FullStd: boolean);
  end;

  TRateList = class;
  TRateDescr = class(TObject)
  private
    FOwner : TRateList;
  public
    Freq         : real;
    SamplNumber  : integer;
    constructor Create(AOwner:TRateList); reintroduce;
    function GetSamplCnt : integer;
    function GetTimeLen : double; overload;
    function GetTimeLen(nrProbki:integer) : double; overload;
    function StartSamplNr : integer;
  end;
  TRateList = class(TObjectList)
  private
    function GetItem(Index: Integer): TRateDescr;
  public
    property Items[Index: Integer]: TRateDescr read GetItem;
    function AddRate : TRateDescr;
    function SecFromBegin(NR: integer):double;
    function GetNrProbki(Time : double):integer;
    function GetTimeLength:double;
    function GetComtrProbCnt : integer;
    procedure ToComtrTxt(SL :TStringList; Start,Stop:integer);
  end;

  TTimeDescr = class(TObject)
  private
    FBufferSize : integer;
    FTabArray : array of Double;
    procedure FSetBufferSize(ASize : integer);
    function  FGetTime(Index: integer):double;
    procedure FSetTime(Index: integer; aTime:double);
    procedure ResolveTime(var Tmin : double; var Tmax : double; var Tsr  : double);
  public
    property Buffersize: integer read FBufferSize write FSetBufferSize;
    function CheckPeriodEqu : boolean;
    function GetMediumFrequ : double;
    property Time[index: integer]: double read FGettime write FSetTime;
  end;

  { TODO : zapis do pliku HDR }
  TComTrade = class(TObject)
  private
    old_decimal_separator : char;
    old_date_separator    : char;
    old_time_separator    : char;
    old_date_format       : String;
    FOnDrawComtrade       : TNotifyEvent;
    FDataFileMode         : TDataFileMode;
    function  GetTocken(s : string; var ptr: integer): string;
    procedure SetComTradeLocal;
    procedure ReturnLocal;
    procedure ParseCfg(CfgList : TStringLIst);
    procedure StoreCfg(FName : string;Mode : TDataFileMode; Start,Stop : integer; LocAnList:TAnalogList; LocCyList:TCyfrList);

    procedure LoadData(FName : string);
    procedure LoadAsciiData(FName : string);
    procedure LoadBinData(FName : string);
    procedure SaveData(FName : string; Start,Stop : integer; LocAnList  : TAnalogList; LocCyList  : TCyfrList; Mode : TDataFileMode);
    procedure SaveAsciiData(FName : string; Start,Stop : integer; LocAnList  : TAnalogList; LocCyList  : TCyfrList);
    procedure SaveBinData(FName : string; Start,Stop : integer; LocAnList  : TAnalogList; LocCyList  : TCyfrList);

    function  ComStrToFloat(s : string):real;
    function  ComStrToInt(s : string):integer; overload;
    function  ComStrToInt(s : string; Def : integer):integer; overload;
    function  ComStrToDate(s : string):TDateTime;
    function  FGetIsaStandard : boolean;
    procedure FSetIsaStandard(AIsaStandard : boolean);
    procedure FSetDataMode(mode : TDataMode);
    function  FGetDataMode : TDataMode;
    function  FgetBufSize  : integer;
    procedure FSetBufSize(ASize:integer);
  protected
    FRateList : TRateList;
    FAnList   : TAnalogList;
    FCyList   : TCyfrList;
    FTmDescr  : TTimeDescr;
    procedure GetVisList(Vis : boolean; var AnL:TAnalogList; var CfL:TCyfrList);
  protected
    procedure SaveToHdrFile(IniF : TMemIniFile); virtual;
    procedure LoadFromHdrFile(IniF : TMemIniFile); virtual;
  public
    FileParam : TFileParam;
    ViewParam : TViewParam;
    DataOk    : boolean;
    FileName  : string;
    HdrList   : TStringList;
    constructor Create;
    destructor  Destroy; Override;
    procedure   Clear;
    function  CheckComtrade(AFileName : string): boolean;
    procedure LoadFromFile(AFileName : string);
    procedure SaveToFile(AFileName : string; SelectPart : boolean; Mode : TDataFileMode; OnlyVisible : boolean);

    function  GetComtrProbCnt : integer;
    procedure DoDrawComtrade;
    property  BuffSize : integer read FgetBufSize write FSetBufSize;
    property  CyfList  : TCyfrList   read FCyList;
    property  AnList   : TAnalogList read FAnList;
    property  RateList : TRateList   read FRateList;
    property  TmDescr  : TTimeDescr  read FTmDescr;
    property  DataFileMode : TDataFileMode read FDataFileMode write FDataFileMode;
    property  IsaStandard: boolean read FGetIsaStandard write FSetIsaStandard;
    property  OnDrawComtrade : TNotifyEvent read FOnDrawComtrade write FOnDrawComtrade;
    property  DataMode : TDataMode read FGetDataMode write FSetDataMode;
  end;


implementation

function CmdFloatToStr(r : real;dt :integer): string;
begin
  Result := Format('%1.*f',[dt,r]);
end;

// ---------------------------------------------------------------------------
// --------------  TComtrade i podobiekty ------------------------------------
// ---------------------------------------------------------------------------

constructor TViewParam.Create;
begin
  inherited;
  FStart := -1;
  FStop  := -1;
end;

procedure TViewParam.FSetStart(A : double);
begin
  FStart := A;
end;

procedure TViewParam.FSetStop(A : double);
begin
  FStop := A;
end;

function  TViewParam.FGetIsSet: boolean;
begin
  Result := (FStart<>-1) and (FStop<>-1);
end;

constructor TSygDescr.Create;
begin
  inherited Create;
  PenColor  := clBlack;
  BkColor   := clWhite;
  Visible   := true;
  FBufferSize := 0;
end;

function TSygDescr.StrValidate(AName : string) : string;
var
  i : integer;
begin
  for i:=1 to Length(AName) do
  begin
    if Aname[i]=',' then Aname[i]:='.';
  end;
  Result := AName;
end;

procedure TSygDescr.ValidDataWsk(var Start : integer; var Stop: integer);
begin
  if Start=-1 then Start:=0;
  if Stop=-1  then Stop:=FBufferSize-1;
  if (Start<0) then
    raise Exception.Create('WskaŸnik pocz¹tku danych < 0');
  if (Start>=FBufferSize) then
    raise Exception.Create('WskaŸnik pocz¹tku danych > d³ugoœci bufora');
  if (Stop<0) then
    raise Exception.Create('WskaŸnik koñca danych < 0');
  if (Stop>=FBufferSize) then
    raise Exception.Create('WskaŸnik koñca danych > d³ugoœci bufora');
  if (Start>=Stop) then
    raise Exception.Create('WskaŸnik pocz¹tku >= koñca danych ');
end;

procedure TSygDescr.FSetName(AName : STR64);
begin
  FName := StrValidate(AName);
end;

procedure TSygDescr.FSetOpis(AName : STR64);
begin
  FOpis:= StrValidate(AName);
end;

// ------- TAnalogDescr ----------
constructor TAnalogDescr.Create(MemMode : TMemMode);
begin
  inherited Create;
  FMemMode := MemMode;
  FBufferSize := 0;
  PhaseIden:='';
  Primary := 1;
  Secondary := 1;
  RData :=nil;
  AutoScale := false;
  UniPolar  := false;
  SDATA := nil;
  IDATA := nil;
  FData := nil;
  RData := nil;
end;


constructor TAnalogDescr.Create;
begin
  Create(mmINT16);
end;

destructor TAnalogDescr.Destroy;
begin
  if SDATA<>nil then SetLength(SData,0);
  if IDATA<>nil then SetLength(IData,0);
  if FDATA<>nil then SetLength(FData,0);
  if RDATA<>nil then SetLength(RData,0);
  inherited;
end;

procedure TAnalogDescr.SaveToHdrFile(IniF : TMemIniFile; Nr : integer);
var
  SName : string;
begin
  SName := Format('ANALOG_%u',[Nr]);


end;

procedure TAnalogDescr.LoadFromHdrFile(IniF : TMemIniFile; Nr : integer);
var
  SName : string;
begin
  SName := Format('ANALOG_%u',[Nr]);


end;

procedure TAnalogDescr.FSetBufferSize(ASize : integer);
begin
  FBufferSize := ASize;
  case FMemMode of
  mmINT16  : SetLength(SData,ASize);
  mmINT32  : SetLength(IData,ASize);
  mmFLOAT  : SetLength(FData,ASize);
  mmDOUBLE : SetLength(RData,ASize);
  else
    raise Exception.Create('Unknown format of memory for analog buffer.');
  end;
end;

procedure TAnalogDescr.FSetUnits(AUnit : STR32);
begin
  FUnits := StrValidate(AUnit);
end;

function TAnalogDescr.ToComtrTxt(FullStd: boolean):string;
begin
  Result := IntToStr(Index)+',';
  Result := Result + Name+',';
  if PhaseIden<>'' then
    Result := Result + PhaseIden;
  Result := Result + ',';
  Result := Result + Opis+',';
  Result := Result + Units+',';
  Result := Result + CmdFloatToStr(Multipl,12)+',';
  Result := Result + CmdFloatToStr(Offset,4)+',';
  if TimeSkew<>0 then
    Result := Result + CmdFloatToStr(TimeSkew,4);
  Result := Result + ',';
  Result := Result + IntToStr(RangMin)+',';
  Result := Result + IntToStr(RangMax)+',';
  if FullStd then
  begin
    Result := Result + CmdFloatToStr(Primary,3)+',';
    Result := Result + CmdFloatToStr(Secondary,3)+',';
    case PS of
    svSecoundary : Result := Result + 'S';
    svPrimary    : Result := Result + 'P';
    end;
  end
  else
  begin
    Result := Result + IntToStr(round(Primary/Secondary));
  end;
end;

function TAnalogDescr.FGetValue(Index: integer):Double;
begin
  if Index>=FBufferSize then
    raise Exception.Create('Index out of buffer range.');
  case FMemMode of
  mmINT16  : Result :=  SData[Index]*Multipl+Offset;
  mmINT32  : Result :=  IData[Index]*Multipl+Offset;
  mmFLOAT  : Result :=  FData[Index];
  mmDOUBLE : Result :=  RData[Index];
  else
    raise Exception.Create('Unknown format of memory for analog buffer.');
  end;
end;

procedure TAnalogDescr.FSetValue(Index: integer; aValue:Double);
var
  R : double;
  C : integer;
begin
  if Index>=FBufferSize then
    raise Exception.Create('Index out of buffer range.');
  case FMemMode of
  mmINT16,
  mmINT32  : begin
               R := (aValue-Offset)/Multipl;
               if R>RangMax then  C := RangMax
               else if R<RangMin then  C := RangMin
               else C := round(R);
               if FMemMode=mmINT16 then
                 SData[Index] := C
               else
                 IData[Index] := C
             end;
  mmFLOAT  : FData[Index] := aValue;
  mmDOUBLE : RData[Index] := aValue;
  else
    raise Exception.Create('Unknown format of memory for analog buffer.');
  end;
end;

function  TAnalogDescr.FGetBinValue(Index: integer):smallint;
var
  V     : double;
begin
  if Index>=FBufferSize then
    raise Exception.Create('Index out of buffer range.');

  if Multipl=0 then
    Raise Exception.Create('Multipl=0');

  case FMemMode of
  mmINT16  : Result :=  SData[Index];
  mmINT32  : begin
               Result :=  IData[Index];
             end;
  mmFLOAT,
  mmDOUBLE : begin
               if FMemMode=mmFloat then
                 V := FData[index]
               else
                 V := RData[index];
               V := V-Offset;
               V := V/Multipl;
               if V>RangMax then  Result := RangMax
               else if V<RangMin then  Result := RangMin
               else Result := round(V);
             end;
  else
    raise Exception.Create('Unknown format of memory for analog buffer.');
  end;
end;

procedure TAnalogDescr.FSetBinValue(Index: integer; aValue:smallint);
begin
  if Index>=FBufferSize then
    raise Exception.Create('Index out of buffer range.');

  if Multipl=0 then
    Raise Exception.Create('Multipl=0');

  if aValue>RangMax then aValue:=RangMax;
  if aValue<RangMin then aValue:=RangMin;

  case FMemMode of
  mmINT16  : SData[Index] := aValue;
  mmINT32  : IData[Index] := aValue;
  mmFLOAT  : FData[Index] := aValue*Multipl + Offset;
  mmDOUBLE : RData[Index] := aValue*Multipl + Offset;
  else
    raise Exception.Create('Unknown format of memory for analog buffer.');
  end;
end;

function TAnalogDescr.GetValueMode(Mode: TDataMode; NrProb: integer; var Exist : boolean):Double;
begin
  if NrProb<FBufferSize then
  begin
    Result :=  FGetValue(NrProb);
    case Mode of
    dmPrimary   : begin
                    if PS=svSecoundary then
                      Result := Result * Primary/Secondary;
                  end;
    dmSecoundary: begin
                    if PS=svPrimary then
                      Result := Result * Secondary/Primary;
                  end;
    dmBinary    : Result := (Result-Offset)/Multipl;
    dmProc      : begin
                    Result := (Result-Offset)/Multipl;
                    if not(UniPolar) then
                      Result := 200*(Result-RangMin)/(RangMax-RangMin)-100
                    else
                      Result := 100*(Result-RangMin)/(RangMax-RangMin);
                  end;
    else
      raise exception.Create('Unknown data mode');
    end;
    Exist  :=  True;
  end
  else
  begin
    Result :=  0;
    Exist := False;
  end;
end;

function  TAnalogDescr.GetModeValueStr(Mode: TDataMode; NrProb: integer):string;
var
  V     : double;
  Exist : boolean;
begin
  Result := '';
  V := GetValueMode(Mode,NrProb,Exist);
  if Exist then
  begin
    case Mode of
    dmPrimary   : begin
                    Result := FloatToStr(V);
                  end;
    dmSecoundary: begin
                    Result := FloatToStr(V);
                  end;
    dmBinary    : begin
                    Result := IntToStr(round(V))
                  end;
    dmProc      : begin
                    if Exist  then
                      Result := Format('%.2f',[V]);
                  end;
    else
      raise exception.Create('Unknown data mode');
    end;
    Exist  :=  True;
  end;
end;


function TAnalogDescr.GetValue(NrProb: integer; var Exist : boolean):Double;
begin
  Result := GetValueMode(FDataMode,NrProb,Exist);
end;

function TAnalogDescr.GetValue(NrProb: integer):Double;
var
  Exist : boolean;
begin
  Result := GetValue(NrProb,Exist);
  if not(Exist) then
    raise Exception.Create('Data no Exist');
end;

procedure TAnalogDescr.KorrektRanges;
var
  i         : integer;
  RMax,Rmin : double;
  Max,Min   : double;
  A         : double;
begin
  RMax := RangMax*Multipl+Offset;
  Rmin := RangMin*Multipl+Offset;
  Min:=0;
  Max:=0;
  for i:=0 to FBufferSize-1 do
  begin
     A := FGetValue(i);
     if (i=0) or(A>Max) then Max := A;
     if (i=0) or(A<Min) then Min := A;
  end;
  if Max > RMax then
  begin
    RMax := Max;
    RangMax := round((RMax-Offset)/Multipl);
  end;
  if Min < RMin then
  begin
    if RMin=0 then  RMin:= -RMax;
    if Min < RMin then
    begin
      Rmin :=Min;
    end;
    RangMin := round((RMin-Offset)/Multipl);
  end;
end;

procedure TAnalogDescr.ScaleAnalog;
var
  N,i       : integer;
  FMax,FMin : double;
  Mn        : double;
  A         : double;
begin
  if not(AutoScale) then Exit;
  N := FBufferSize;

  A := FGetValue(0);
  FMin := A;
  FMax := A;

  for i:=0 to N-1 do
  begin
    A := FGetValue(i);
    if FMin>A then FMin:=A;
    if FMax<A then FMax:=A;
  end;
  Mn := Max(Abs(FMin),Abs(FMax));
  Mn := 1.2*Mn;
  Primary := Mn;
  Secondary := Mn;
  PS := svSecoundary;
  RangMax := 32767;
  RangMin := -32767;
  Offset := 0;
  Multipl := MN/RangMax;
end;

procedure TAnalogDescr.FSetDataMode(mode : TDataMode);
begin
  FDataMode := Mode;
end;

function TAnalogDescr.FGetDataMode : TDataMode;
begin
  Result := FDataMode;
end;


function TAnalogDescr.GetDataModeValue(Mode : TDataMode; D : integer) : double;
begin
  case Mode of
  dmPrimary   : begin
                  Result := D *Multipl+Offset;
                  if PS=svSecoundary then
                    Result := Result * Primary/Secondary;
                end;
  dmSecoundary: begin
                  Result := D*Multipl+Offset;
                  if PS=svPrimary then
                    Result := Result * Secondary/Primary;
                end;
  dmBinary    : Result := D;
  dmProc      : begin
                  if not(UniPolar) then
                    Result := 200*(D-RangMin)/(RangMax-RangMin)-100
                  else
                    Result := 100*(D-RangMin)/(RangMax-RangMin);
                end;
  else
    raise exception.Create('Unknown data mode');
  end;
end;


function TAnalogDescr.GetDataMax : double;
begin
  Result := GetDataModeValue(FDataMode,RangMax);
end;

function TAnalogDescr.GetDataMin : double;
begin
  Result := GetDataModeValue(FDataMode,RangMin);
end;

function TAnalogDescr.GetZakres : double;
begin
  Result := GetDataMax-GetDataMin;
  if not(UniPolar) then
    Result := Result/2;
end;

function TAnalogDescr.GetUnits: string;
begin
  case FDataMode of
  dmPrimary,
  dmSecoundary: Result := Units;
  dmBinary    : Result := 'q';
  dmProc      : Result := '%';
  else
    raise exception.Create('Unknown data mode');
  end;
end;

// ------- TAnalogList ----------
function TAnalogList.GetItem(Index: Integer): TAnalogDescr;
begin
  Result := (inherited GetItem(Index)) as TAnalogDescr;
end;

procedure TAnalogList.SetItem(Index: Integer; AObject: TAnalogDescr);
begin
  inherited SetItem(Index,AObject);
end;
procedure TAnalogList.SaveToHdrFile(IniF : TMemIniFile);
var
  i : integer;
begin
  for i:=0 to Count-1 do
  begin
    Items[i].SaveToHdrFile(IniF,i);
  end;
end;

procedure TAnalogList.LoadFromHdrFile(IniF : TMemIniFile);
var
  i : integer;
begin
  for i:=0 to Count-1 do
  begin
    Items[i].LoadFromHdrFile(IniF,i);
  end;
end;


function TAnalogList.GetCommaNames :string;
var
  i: integer;
begin
  Result :='';
  for i:=0 to Count-1 do
  begin
    if Result<>'' then Result:= Result + ', ';
    Result := Result + '"'+Items[i].Name+'"';
  end;
end;



function TAnalogList.AddSyg(AMemMode : TMemMode): TAnalogDescr;
begin
  Result := TAnalogDescr.Create(AMemMode);
  Add(Result);
  Result.Index := Count;
end;

function TAnalogList.FindSygnal(AName : string): TAnalogDescr;
var
  i: integer;
begin
  Result := nil;
  for i:=0 to Count-1 do
  begin
    if AName=Items[i].Name then Result:= Items[i];
  end;
end;

procedure TAnalogList.KorrektRanges;
var
  i: integer;
begin
  for i:=0 to Count-1 do
    Items[i].KorrektRanges;
end;

procedure TAnalogList.ScaleAnalog;
var
  i: integer;
begin
  for i:=0 to Count-1 do
    Items[i].ScaleAnalog;
end;



procedure TAnalogList.ToComtrTxt(SL :TStringList; FullStd: boolean);
var
  i: integer;
begin
  for i:=0 to Count-1 do
  begin
    SL.Add(Items[i].ToComtrTxt(FullStd));
  end;
end;

// ------- TCyfrDescr ----------
constructor TCyfrDescr.Create;
begin
  inherited;
  PhaseIden:='';
  BData :=nil;
end;

destructor TCyfrDescr.Destroy;
begin
  SetLength(BData,0);
  inherited;
end;

procedure TCyfrDescr.FSetBufferSize(ASize : integer);
begin
  FBufferSize := ASize;
  SetLength(BData,ASize);
end;

function  TCyfrDescr.FGetValue(Index: integer):boolean;
begin
  if index>=FBufferSize then
    raise Exception.Create('Index out of buffer range.');
  Result :=  BData[Index];
end;

procedure TCyfrDescr.FSetValue(Index: integer; aValue:boolean);
begin
  if index>=FBufferSize then
    raise Exception.Create('Index out of buffer range.');
  BData[Index]:=aValue;
end;

function TCyfrDescr.GetValue(NrProb: integer; var Exist : boolean):boolean;
begin
  if NrProb<FBufferSize then
  begin
    Exist  := true;
    Result :=  BData[NrProb]
  end
  else
  begin
    Result := NomState;
    Exist := False;
  end
end;

function TCyfrDescr.ToComtrTxt(FullStd: boolean):string;
begin
  Result := IntToStr(Index)+',';
  Result := Result + Name+',';
  if FullStd then
  begin
    if PhaseIden<>'' then
      Result := Result + PhaseIden;
    Result := Result + ',';
    Result := Result + Opis+',';
  end;
  if NomState then Result := Result + '1'
              else Result := Result + '0';
end;

// ------- TCyfrList ----------
function TCyfrList.GetItem(Index: Integer): TCyfrDescr;
begin
  Result := (inherited GetItem(Index)) as TCyfrDescr;
end;
function TCyfrList.AddSyg: TCyfrDescr;
begin
  Result := TCyfrDescr.Create;
  Add(Result);
  Result.Index := Count;
end;
procedure TCyfrList.ToComtrTxt(SL :TStringList; FullStd: boolean);
var
  i: integer;
begin
  for i:=0 to Count-1 do
  begin
    SL.Add(Items[i].ToComtrTxt(FullStd));
  end;
end;



// ------- TRateDescr ----------
constructor TRateDescr.Create(AOwner:TRateList);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TRateDescr.StartSamplNr : integer;
var
  N : integer;
begin
  N:=FOwner.IndexOf(self);
  case N of
  0  : Result := 0;
  -1 : raise Exception.Create('RateItem is out of list');
  else
    Result := FOwner.Items[N-1].SamplNumber;
  end;
end;

function TRateDescr.GetSamplCnt : integer;
begin
  Result := SamplNumber-StartSamplNr;
end;

function TRateDescr.GetTimeLen : double;
begin
  Result := GetSamplCnt/Freq;
end;

function TRateDescr.GetTimeLen(nrProbki:integer) : double;
begin
  if (NrProbki<StartSamplNr) or (NrProbki>=SamplNumber) then
    raise Exception.Create('Index out of part range.');
  Result := (NrProbki-StartSamplNr)/Freq;
end;

// ------- TRateList ----------
function TRateList.GetItem(Index: Integer): TRateDescr;
begin
  Result := (inherited GetItem(Index)) as TRateDescr;
end;

function TRateList.AddRate : TRateDescr;
begin
  Result := TRateDescr.Create(Self);
  Add(Result);
end;

function TRateList.SecFromBegin(NR: integer):double;
var
  i   : integer;
begin
  Result := 0;
  for i:=0 to Count-1 do
  begin
    if (NR>Items[i].SamplNumber) then
      Result := Result + Items[i].GetTimeLen
    else
    begin
      Result := Result + Items[i].GetTimeLen(NR);
      Break;
    end;
  end;
end;

function TRateList.GetTimeLength:double;
var
  i   : integer;
begin
  Result := 0;
  for i:=0 to Count-1 do
    Result := Result + Items[i].GetTimeLen;
end;

// Time czas w sekundach
function TRateList.GetNrProbki(Time : double):integer;
var
  i   : integer;
  RD  : TRateDescr;
  Tm  : double;
begin
  Tm :=0;
  Result :=0;
  i:=0;
  while Time>Tm do
  begin
    RD := Items[i];
    if Time-Tm>RD.GetTimeLen then
    begin
      Result := RD.SamplNumber;
      Tm := Tm + RD.GetTimeLen;
    end
    else
    begin
      Result := Result + Round((Time-Tm)*RD.Freq);
      Tm := Time;
    end;
    inc(i);
  end;
end;

function  TRateList.GetComtrProbCnt : integer;
begin
  if Count=0 then
    Raise Exception.Create('Nie zdefiniowane przedzia³y danych');
  Result := Items[Count-1].SamplNumber;
end;

procedure TRateList.ToComtrTxt(SL :TStringList; Start,Stop:integer);
var
  i,L  : integer;
  s    : string;
  RCnt : integer;
begin
  if (Start=-1) and (Stop=-1) then
  begin
    SL.Add(IntToStr(Count));
    for i:=0 to Count-1 do
    begin
      S := CmdFloatToStr(Items[i].Freq,3)+',';
      S := S+IntToStr(Items[i].SamplNumber);
      SL.Add(s);
    end;
  end
  else
  begin
    if Start=-1 then Start:=0;
    if Stop=-1  then Stop := GetComtrProbCnt;
    RCnt:=0;
    L:=0;
    for i:=0 to Count-1 do
    begin
      if (Start<Items[i].SamplNumber) and (Stop>L) then
       inc(RCnt);
      L := Items[i].SamplNumber;
    end;
    SL.Add(IntToStr(RCnt));

    L:=0;
    for i:=0 to Count-1 do
    begin
      if (Start<Items[i].SamplNumber) and (Stop>L) then
      begin
        RCnt := Items[i].SamplNumber-Start;
        if Stop<Items[i].SamplNumber then
           RCnt:=RCnt-(Items[i].SamplNumber-Stop);
        S := CmdFloatToStr(Items[i].Freq,3)+',';
        S := S+INtToStr(RCnt);
        SL.Add(s);
      end;
      L := Items[i].SamplNumber;
    end;
  end;
end;

// ------- TTimeDescr ----------

procedure TTimeDescr.FSetBufferSize(ASize : integer);
begin
  FBufferSize := Asize;
  Setlength(FTabArray,Asize);
end;

procedure TTimeDescr.ResolveTime(var Tmin : double; var Tmax : double; var Tsr  : double);
var
  i    : integer;
  T    : double;
begin
  Tmin:=0;
  Tmax:=0;
  Tsr:=0;
  if FBufferSize>1 then
  begin
    T := FTabArray[1]-FTabArray[0];
    Tmin := T;
    Tmax := T;

    for i:=0 to FBufferSize-2 do
    begin
      T := FTabArray[i+1]-FTabArray[i];
      if T>Tmax then Tmax := T;
      if T<Tmin then Tmin := T;
      Tsr := Tsr+T;
    end;
    Tsr := Tsr/(FBufferSize-1);
  end;
end;

function TTimeDescr.CheckPeriodEqu : boolean;
var
  Tmin : double;
  Tmax : double;
  Tsr  : double;
begin
  ResolveTime(Tmin,Tmax,Tsr);
  if Tsr<>0 then
    Result := ((Tmax-Tmin)/Tsr<0.001)
  else
    Result := false;
end;

function TTimeDescr.GetMediumFrequ : double;
var
  Tmin : double;
  Tmax : double;
  Tsr  : double;
begin
  ResolveTime(Tmin,Tmax,Tsr);
  if Tsr<>0 then
    Result := 1/Tsr
  else
    Result := 0;
end;

function  TTimeDescr.FGetTime(Index: integer):double;
begin
  if index>=FBufferSize then
    raise Exception.Create('Index out of time buffer range.');
  Result :=  FTabArray[Index];
end;

procedure TTimeDescr.FSetTime(Index: integer; aTime:double);
begin
  if index>=FBufferSize then
    raise Exception.Create('Index out of time buffer range.');
  FTabArray[Index]:=aTime;
end;

// ------- TComTrade ----------
constructor TComTrade.Create;
begin
  inherited;
  HdrList  := TStringList.Create;
  FAnList  := TAnalogList.Create;
  FCyList  := TCyfrList.Create;
  FRateList := TRateList.Create;
  ViewParam := TViewParam.Create;
  FTmDescr  := TTimeDescr.Create;
  Clear;
end;

destructor  TComTrade.Destroy;
begin
  HdrList.Free;
  FAnList.Free;
  FCyList.Free;
  FRateList.Free;
  ViewParam.Free;
  FTmDescr.Free;
  inherited;
end;

procedure TComTrade.Clear;
begin
  FAnList.Clear;
  FCyList.Clear;
  FRateList.Clear;
  FileParam.Rev_Year := 1;
  FileParam.NominalLineFreq := 50.0;
  DataOk := false;
end;

procedure TComTrade.SaveToHdrFile(IniF : TMemIniFile);
begin
//  FAnList.SaveToHdrFile(IniF);
//  FCyList.SaveToHdrFile(IniF);
end;

procedure TComTrade.LoadFromHdrFile(IniF : TMemIniFile);
begin
//  FAnList.LoadFromHdrFile(IniF);
//  FCyList.LoadFromHdrFile(IniF);
end;

function  TComTrade.FGetIsaStandard : boolean;
begin
  Result := (FileParam.Rev_Year=1);
end;

procedure TComTrade.FSetIsaStandard(AIsaStandard : boolean);
begin
  if AIsaStandard then
    FileParam.Rev_Year := 1
  else
    FileParam.Rev_Year := 1997;
end;

function  TComTrade.GetComtrProbCnt : integer;
begin
  Result := FRateList.GetComtrProbCnt;
end;

function TComTrade.CheckComtrade(AFileName : string): boolean;
var
  CTrd    : TComTrade;
  CfgList : TStringList;
begin
  //AFileName := ChangeFileExt(AFileName,'.CFG');
  CTrd      := TComTrade.Create;
  CfgList   := TStringList.Create;
  try
    try
      CfgList.LoadFromFile(AFileName);
      CTrd.ParseCfg(CfgList);
      Result := true;
    finally
      CTrd.Free;
      CfgList.Free;
    end;
  except
    Result := false;
  end;
end;

procedure TComTrade.LoadFromFile(AFileName : string);
var
  DName   : string;
  Hname   : string;
  CfgList : TStringList;
  IniF    : TMemIniFile;
begin
  Clear;
  FileName := AFileName;
  CfgList  := TStringList.Create;
  try
    //FileName := ChangeFileExt(FileName,'.CFG');
    DName := ChangeFileExt(FileName,'.DAT');
    Hname := ChangeFileExt(FileName,'.HDR');
    try
      CfgList.LoadFromFile(FileName);
      try
        HdrList.LoadFromFile(HName);
      except
      end;
    except
      Raise Exception.Create('B³¹d otwarcia zbioru :'+FileName);
    end;
    ParseCfg(CfgList);
    LoadData(DName);
    IniF := TMemIniFile.Create('');
    try
      IniF.SetStrings(HdrList);
      LoadFromHdrFile(IniF);
    finally
      IniF.Free;
    end;
    DataOk  := True;
  finally
    CfgList.Free;
  end;
end;

procedure TComTrade.GetVisList(Vis : boolean; var AnL:TAnalogList; var CfL:TCyfrList);
var
  i: integer;
begin
  if Vis then
  begin
    AnL := TAnalogList.Create(false);
    for i:=0 to FAnList.Count-1 do
    begin
      if FAnList.Items[i].Visible then
        AnL.Add(FAnList.Items[i]);
    end;

    CfL := TCyfrList.Create(false);
    for i:=0 to FCyList.Count-1 do
    begin
      if FCyList.Items[i].Visible then
        CfL.Add(FCyList.Items[i]);
    end;
  end
  else
  begin
    AnL := FAnList;
    CfL := FCyList;
  end;
end;

procedure TComTrade.SaveToFile(AFileName : string; SelectPart : boolean; Mode : TDataFileMode; OnlyVisible : boolean);
var
  DName,HName : string;
  LocAnList   : TAnalogList;
  LocCyList   : TCyfrList;
  Start,Stop  : integer;
begin
  if SelectPart then
  begin
    Start := RateList.GetNrProbki(ViewParam.Start);
    Stop  := RateList.GetNrProbki(ViewParam.Stop);
  end
  else
  begin
    Start := -1;
    Stop  := -1;
  end;

  AFileName := ChangeFileExt(AFileName,'.CFG');
  DName := ChangeFileExt(AFileName,'.DAT');
  HName := ChangeFileExt(AFileName,'.HDR');

  FAnList.ScaleAnalog;
  GetVisList(OnlyVisible,LocAnList,LocCyList);

  StoreCfg(AFileName,Mode,Start,Stop,LocAnList,LocCyList);
  SaveData(DName,Start,Stop,LocAnList,LocCyList,Mode);

  HdrList.SaveToFile(HName);

  if LocAnList<>FAnList then
    LocAnList.Free;

  if LocCyList<>FCyList then
    LocCyList.Free;
end;


function TComTrade.GetTocken(s : string; var ptr: integer): string;
var
  p,k : integer;
begin
  p := ptr;
  while (ptr<=length(s)) and (s[ptr]<>#0) and (s[ptr]<>',') do
  begin
    inc(ptr);
  end;
  k := ptr;
  if (ptr<=length(s)) then
    if s[ptr]=',' then inc(ptr);
  Result := copy(s,p,k-p);
end;

procedure TComTrade.SetComTradeLocal;
begin
  old_decimal_separator := decimalseparator;
  decimalseparator :='.';
  old_date_separator := dateseparator;
  dateseparator      := '/';
  old_time_separator := timeseparator;
  timeseparator      := ':';
  old_date_format := ShortDateFormat;
  ShortDateFormat := 'dd/mm/yyyy';
end;

procedure TComTrade.ReturnLocal;
begin
  decimalseparator := old_decimal_separator;
  dateseparator    := old_date_separator;
  timeseparator    := old_time_separator;
  ShortDateFormat  := old_date_format;
end;


function TComTrade.ComStrToFloat(s : string):real;
begin
  Result := StrToFloat(Trim(s));
end;

function TComTrade.ComStrToInt(s : string):integer;
begin
  Result := StrToInt(Trim(s));
end;

function  TComTrade.ComStrToInt(s : string; Def : integer):integer;
begin
  s := Trim(s);
  Result := StrToIntDef(s,Def);
end;

//dd-mm-yy
function  TComTrade.ComStrToDate(s : string):TDateTime;
var
  s1      : string;
  r,m,d,x : word;
begin
  try
    if s[3]<>s[6] then
      raise Exception.Create(s+' is not valid date');
    begin
      s1 := copy(s,1,2);
      d := StrToInt(s1);
      s1 := copy(s,4,2);
      m := StrToInt(s1);
      s1 := copy(s,7,length(s)-6);
      r := StrToInt(s1);
      if length(s1)<4 then
      begin
        r := r mod 100;
        if r>50 then
          r :=  1900+r
        else
          r :=  2000+r;
      end;
      if m>12 then
      begin
        // wygl¹da na to, ¿e format daty to mm/dd/rr
        x := d;
        d := m;
        m := x;
      end;
      Result := EncodeDate(r,m,d);
    end;
  except
    raise Exception.Create(s+' is not valid date');
  end;
end;

{
  Index,
  Name,
  PhaseIden,
  Opis,
  Units,
  Multipl,
  Offset,
  TimeSkew,
  RangMin,
  RangMax,
  Primary,
  Secondary,
  S/P,
}
procedure TComTrade.ParseCfg(CfgList : TStringLIst);
  // Dane wejœciowe mog¹ wygl¹daæ hh/mm/ss.xxxxxx - i nie przejd¹ przez standardowe strtotime
  function ComTradeStrToTime(s : String): TDateTime;
  var
    rest : String;
    msec : real;
  begin
    rest := Copy(s,Pos('.',s)+1,6);
    s := Copy(s,1,Pos('.',s)-1);
    try
      result := StrToTime(s);
      Rest := Copy(rest+'000000',1,6);
      s := copy(rest,1,3)+decimalseparator+copy(rest,4,3);
      msec := StrToFloat(s);
      result := result + msec/MSecsPerDay;
    except
      Result :=0;
    end
  end;

var
  P                    : integer;
  s,s1                 : string;
  AllCnt,AnCnt,DigiCnt : integer;
  i,l_nr               : integer;
  AnalogDescr          : TAnalogDescr;
  CyfrDescr            : TCyfrDescr;
  RateDescr            : TRateDescr;
  Tm,DT                : TDateTime;
  NRates               : integer;
begin
  SetComtradeLocal;
  try
    l_nr := 1;
    try
      S := CfgList.Strings[l_nr-1];
      P := 1;
      // pierwsza linia
      FileParam.Station_Name := GetTocken(s,p);
      FileParam.Rec_Dev_Id   := GetTocken(s,p);
      S1 := Trim(GetTocken(s,p));
      if S1<>'' then
        FileParam.Rev_Year := ComStrToInt(s1,1997);
      if FileParam.Rev_Year=1 then
        ShortDateFormat := 'mm/dd/yy';

      // druga linia
      inc(l_nr);
      S := CfgList.Strings[l_nr-1];
      p:=1;
      s1 := GetTocken(s,p);
      AllCnt := ComStrToInt(s1);
      s1 := GetTocken(s,p);
      if s1[length(s1)]<>'A' then Exception.Create('');
      AnCnt := ComStrToInt(copy(s1,1,length(s1)-1));
      s1 := GetTocken(s,p);
      if s1[length(s1)]<>'D' then Exception.Create('');
      DigiCnt := ComStrToInt(copy(s1,1,length(s1)-1));
      if AllCnt<>AnCnt+DigiCnt then
        Raise Exception.Create('Nie zgadza siê iloœæ kana³ów analogowych,cyfrowych i ich suma');

      // Ladaowanie opisu kana³ów analogowych
      l_nr := 3;
      for i:=0 to AnCnt-1 do
      begin
        S := CfgList.Strings[l_nr-1];
        p:=1;
        AnalogDescr := FAnList.AddSyg(mmINT16);
        try
          AnalogDescr.Index := ComStrToInt(GetTocken(s,p));
          AnalogDescr.Name := GetTocken(s,p);
          s1 := GetTocken(s,p);
          if s1<>'' then
            AnalogDescr.PhaseIden := s1;
          AnalogDescr.Opis := GetTocken(s,p);
          AnalogDescr.Units := GetTocken(s,p);
          AnalogDescr.Multipl := ComStrToFloat(GetTocken(s,p));
          AnalogDescr.Offset  := ComStrToFloat(GetTocken(s,p));
          s1 := GetTocken(s,p);
          if s1<>'' then
            AnalogDescr.TimeSkew := ComStrToFloat(s1);
          AnalogDescr.RangMin := ComStrToInt(GetTocken(s,p));
          AnalogDescr.RangMax := ComStrToInt(GetTocken(s,p));
          if FileParam.Rev_Year>1 then
          begin
            AnalogDescr.Primary := ComStrToFloat(GetTocken(s,p));
            AnalogDescr.Secondary := ComStrToFloat(GetTocken(s,p));
            s1 := GetTocken(s,p);
            if s1='' then
              Raise Exception.Create('Brak informacji - [Primary/Secoundary]');
            case s1[1] of
            'S' : AnalogDescr.PS := svSecoundary;
            'P' : AnalogDescr.PS := svPrimary;
            else
              raise Exception.Create('');
            end;
          end
          else
          begin
            s1 := GetTocken(s,p);
            if S1<>'' then
            begin
              AnalogDescr.Primary := StrToFloat(s1);
            end;
          end;
        except
          AnalogDescr.Free;
          raise;
        end;
        inc(l_nr);
      end;

      // Ladaowanie opisu kana³ów cyfrowych
      for i:=0 to DigiCnt-1 do
      begin
        S := CfgList.Strings[l_nr-1];
        p:=1;
        CyfrDescr := FCyList.AddSyg;
        FCyList.Extract(CyfrDescr);
        try
          CyfrDescr.Index := ComStrToInt(GetTocken(s,p));
          CyfrDescr.Name  := GetTocken(s,p);
          if FileParam.Rev_Year>1 then
          begin
            s1 := GetTocken(s,p);
            if s1<>'' then
              CyfrDescr.PhaseIden := s1;
            CyfrDescr.Opis := GetTocken(s,p);
          end;
          s1 := GetTocken(s,p);
          if s1='' then
            Raise Exception.Create('Brak informacji - [Nominal state]');
          case s1[1] of
          '0' : CyfrDescr.NomState := false;
          '1' : CyfrDescr.NomState := true;
          else
            raise Exception.Create('');
          end;
          FCyList.Add(CyfrDescr);
        except
          CyfrDescr.Free;
          raise;
        end;
        inc(l_nr);
      end;

      S := CfgList.Strings[l_nr-1];
      if s<>'' then
        FileParam.NominalLineFreq := ComStrToFloat(s);
      inc(l_nr);

      // Ladaowanie listy przedzia³ów o ró¿nej czestotliwoœci
      S := CfgList.Strings[l_nr-1];
      NRates:=ComStrToInt(s);
      inc(l_nr);
      for i:=0 to NRates-1 do
      begin
        S := CfgList.Strings[l_nr-1];
        p:=1;
        RateDescr := FRateList.AddRate;
        try
          RateDescr.Freq := ComStrToFloat(GetTocken(s,p));
          RateDescr.SamplNumber  := ComStrToInt(GetTocken(s,p));
        except
          FRateList.Delete(FRateList.IndexOf(RateDescr));
          raise;
        end;
        inc(l_nr);
      end;

      S := CfgList.Strings[l_nr-1];
      p:=1;
      s1 := GetTocken(s,p);
      Dt := ComStrToDate(s1);
      s1 := GetTocken(s,p);
      Tm := ComTradeStrToTime(s1);
      FileParam.StartPomTime := Dt+Tm;
      inc(l_nr);

      S := CfgList.Strings[l_nr-1];
      p:=1;
      s1 := GetTocken(s,p);
      Dt := ComStrToDate(s1);
      s1 := GetTocken(s,p);
      Tm := ComTradeStrToTime(s1);
      FileParam.WzwTime := Dt+Tm;
      inc(l_nr);

      S := UpperCase(CfgList.Strings[l_nr-1]);
      if S='ASCII' then
        FDataFileMode := fmASCII
      else if S='BINARY' then
        FDataFileMode := fmBINARY
      else
        raise Exception.Create('Z³y format pliku danych');
      inc(l_nr);

      if FileParam.Rev_Year>1 then
      begin
        S := CfgList.Strings[l_nr-1];
        FileParam.TimeStamp := ComStrToFloat(s);
        inc(l_nr);
      end
      else
      begin
        FileParam.TimeStamp := 1000000/(FRateList.Items[0] as TRateDescr).Freq;
      end;
    except
      s:= (ExceptObject as Exception).Message;
      raise Exception.Create(Format('B³¹d w %u linii pliku .cfg : %s',[l_nr,s]));
    end;
  finally
    ReturnLocal;
  end;
end;


procedure TComTrade.StoreCfg(FName : string;Mode : TDataFileMode; Start,Stop : integer; LocAnList :TAnalogList; LocCyList :TCyfrList);
  function TimeToCmdStr(Tm : TDateTime): string;
  begin
    Result := TimeToStr(Tm);
    Result := Result +'.'+Format('%.06u',[1000*MilliSecondOf(Tm)]);
  end;
var
  CfgList   : TStringList;
  StrPomDt  : TDateTime;
  DMili     : integer;
  s         : string;
begin
  CfgList  := TStringList.Create;
  try
    SetComtradeLocal;
    if FileParam.Rev_Year=1 then
      ShortDateFormat := 'mm/dd/yy';

    CfgList.Clear;
    CfgList.Add(Format('%s,%s,%04u',[FileParam.Station_Name,FileParam.Rec_Dev_Id,FileParam.Rev_Year]));
    CfgList.Add(Format('%u,%02uA,%02uD',[LocAnList.Count+LocCyList.Count,LocAnList.Count,LocCyList.Count]));

    LocAnList.ToComtrTxt(CfgList,FileParam.Rev_Year>1);
    LocCyList.ToComtrTxt(CfgList,FileParam.Rev_Year>1);

    CfgList.Add(CmdFloatToStr(FileParam.NominalLineFreq,0));

    FRateList.ToComtrTxt(CfgList,Start,Stop);

    DMili := 0;
    if Start<>-1 then
      DMili := round(1000*FRateList.SecFromBegin(Start));
    StrPomDt := IncMilliSecond(FileParam.StartPomTime,DMili);

    s := DateToStr(StrPomDt)+','+TimeToCmdStr(StrPomDt);
    CfgList.Add(s);
    s := DateToStr(FileParam.WzwTime)+','+TimeToCmdStr(FileParam.WzwTime);
    CfgList.Add(s);
    case Mode of
    fmASCII  : CfgList.Add('ASCII');
    fmBINARY : CfgList.Add('BINARY');
    end;
    if FileParam.Rev_Year>1 then
    begin
      CfgList.Add(CmdFloatToStr(FileParam.TimeStamp,12));
    end;
    CfgList.SaveToFile(FName);
  finally
    CfgList.Free;
    ReturnLocal;
  end;
end;

procedure TComTrade.LoadData(FName : string);
begin
  case FDataFileMode of
  fmASCII  : LoadAsciiData(FName);
  fmBINARY : LoadBinData(FName);
  end;
  FAnList.KorrektRanges;
end;

function  TComTrade.FgetBufSize  : integer;
begin
  if FAnList.Count>0 then
  begin
    Result := FAnList.Items[0].BufferSize;
    Exit;
  end;
  if FCyList.Count>0 then
  begin
    Result := FCyList.Items[0].BufferSize;
    Exit;
  end;
  Result := 0;
end;

procedure TComTrade.FSetBufSize(ASize:integer);
var
  i : integer;
begin
  FTmDescr.Buffersize := ASize;
  for i:=0 to FAnList.Count-1 do
  begin
    FAnList.Items[i].BufferSize:=ASize;
  end;
  for i:=0 to FCyList.Count-1 do
  begin
    FCyList.Items[i].BufferSize:=ASize;
  end;
end;

procedure TComTrade.FSetDataMode(mode : TDataMode);
var
  i: integer;
begin
  for i:=0 to AnList.Count-1 do
    AnList.Items[i].FSetDataMode(Mode);
end;

function  TComTrade.FGetDataMode : TDataMode;
begin
  if AnList.Count>0 then
    Result := AnList.Items[0].FDataMode
  else
    Result := dmPrimary;
end;


procedure TComTrade.LoadAsciiData(FName : string);
var
  Dane : TStringList;
  i,j  : integer;
  Vi   : smallint;
  Vq   : boolean;
  s,s1 : string;
  p    : integer;
  NN   : integer;
  l_nr : integer;
begin
  Dane := TStringList.Create;
  try
    Dane.LoadFromFile(Fname);
    NN := Dane.Count;
    if GetComtrProbCnt<NN then
      NN := GetComtrProbCnt;
    FSetBufSize(NN);
    l_nr := 0;
    try
      for i:=0 to NN-1 do
      begin
        l_nr := i;
        s := Dane.Strings[i];
        p := 1;
        s1 := GetTocken(s,p);
        s1 := GetTocken(s,p);
        for j:=0 to FAnList.Count-1 do
        begin
          s1 := GetTocken(s,p);
          Vi := ComStrToInt(s1);
          FAnList.Items[j].BinValue[i]:=Vi;
        end;
        for j:=0 to FCyList.Count-1 do
        begin
          s1 := GetTocken(s,p);
          Vi := ComStrToInt(s1);
          Vq := (Vi<>0);
          FCyList.Items[j].BData[i]:=Vq;
        end;
      end;
    except
      s:= (ExceptObject as Exception).Message;
      raise Exception.Create(Format('B³¹d w %u linii pliku .dat : %s',[l_nr,s]));
    end;
  finally
    Dane.Free
  end;
end;

procedure TComTrade.LoadBinData(FName : string);
var
  Stream  : TMemoryStream;
  NN    : integer;
  KCyf    : integer;
  N       : integer;
  V       : word;
  Vi      : smallint;
  i,j     : integer;
  ci,cj   : integer;
  mask    : word;
begin
  Stream   := TMemoryStream.Create;
  try
    Stream.LoadFromFile(FName);
    KCyf := (FCyList.Count+15) div 16;
    NN := GetComtrProbCnt;
    FSetBufSize(NN);

    for i:=0 to NN-1 do
    begin
      Stream.Read(N,4);
      Stream.Read(N,4);
      j :=0;
      while j < FAnList.Count do
      begin
        Stream.Read(Vi,2);
        FAnList.Items[j].BinValue[i]:=Vi;
        inc(j);
      end;

      j  := 0;
      ci := 0;
      while j < KCyf do
      begin
        Stream.Read(V,2);
        cj:=0;
        mask := $0001;
        while (ci<FCyList.count) and (cj<16) do
        begin
          FCyList.Items[ci].BData[i]:=((V and mask)<>0);
          mask := word(mask shl 1);
          inc(ci);
          inc(cj);
        end;
        inc(j);
      end;
    end;

  finally
    Stream.Free;
  end
end;

procedure TComTrade.SaveData(FName : string; Start,Stop : integer; LocAnList:TAnalogList; LocCyList:TCyfrList; Mode : TDataFileMode);
begin
  case Mode of
  fmASCII  : SaveAsciiData(FName,Start,Stop,LocAnList,LocCyList);
  fmBINARY : SaveBinData(FName,Start,Stop,LocAnList,LocCyList);
  end;
end;

procedure TComTrade.SaveAsciiData(FName : string; Start,Stop : integer; LocAnList :TAnalogList; LocCyList :TCyfrList);
var
  Dane : TStringList;
  i,j  : integer;
  s    : string;
begin
  Dane := TStringList.Create;
  try
    if Start = -1 then Start:=0;
    if Stop  = -1 then Stop := GetComtrProbCnt;
    for i:=Start to Stop-1 do
    begin
      s := IntToStr(i+1-Start)+',';
      for j:=0 to LocAnList.Count-1 do
      begin
        s := s+ ','+IntToStr(LocAnList.Items[j].BinValue[i]);
      end;
      for j:=0 to LocCyList.Count-1 do
      begin
        if LocCyList.Items[j].BData[i] then
          S := S+',1'
        else
          S := S+',0'
      end;
      Dane.Add(s);
    end;
    Dane.SaveToFile(FName);
  finally
    Dane.Free
  end;
end;

procedure TComTrade.SaveBinData(FName : string; Start,Stop:integer; LocAnList:TAnalogList; LocCyList:TCyfrList);
var
  Stream     : TMemoryStream;
  KCyf       : integer;
  N          : integer;
  V          : word;
  Vi         : smallint;
  i,j        : integer;
  ci,cj      : integer;
  mask       : word;
begin
  Stream   := TMemoryStream.Create;
  try
    KCyf := (LocCyList.Count+15) div 16;
    if Start = -1 then Start:=0;
    if Stop  = -1 then Stop := GetComtrProbCnt;
    for i:=Start to Stop-1 do
    begin
      N := i+1-Start;
      Stream.Write(N,4);
      N := i-Start;
      Stream.Write(N,4);
      j :=0;
      while j < LocAnList.Count do
      begin
        Vi := LocAnList.Items[j].BinValue[i];
        Stream.Write(Vi,2);
        inc(j);
      end;

      j  := 0;
      ci := 0;
      while j < KCyf do
      begin
        cj:=0;
        mask := $0001;
        V := 0;
        while (ci<LocCyList.count) and (cj<16) do
        begin
          if LocCyList.Items[ci].BData[i] then
            V := V or mask;
          mask := word(mask shl 1);
          inc(ci);
          inc(cj);
        end;
        Stream.Write(V,2);
        inc(j);
      end;
    end;
    Stream.SaveToFile(FName);
  finally
    Stream.Free;
  end
end;

procedure TComTrade.DoDrawComtrade;
begin
  if Assigned(FOnDrawComtrade) then
    FOnDrawComtrade(Self);
end;

end.
