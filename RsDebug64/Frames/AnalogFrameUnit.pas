unit AnalogFrameUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,Math,
  Grids, ComCtrls, TeEngine, Series, StdCtrls, Spin, CheckLst, TeeProcs,IniFiles,
  Chart, ExtCtrls, Menus,Buttons,
  CommonDef,
  ArrowCha, VclTee.TeeGDIPlus,
  System.JSON,
  JSonUtils;

const
  MAX_MEM_BOX =3;
type
  TToBin = function(MemName : string; Mem : pbyte; Size:integer; TypeSign:char; Val:OleVariant): integer of object;
  TToValue = function(MemName : string; Buf : pByte; TypeSign:char; var Val:OleVariant): integer of object;
  TOntxtToInt = function(Txt: string):integer of object;

  TAnalogFrame = class(TFrame)
    ShowTypePageCtrl: TPageControl;
    WordSheet: TTabSheet;
    FloatSheet: TTabSheet;
    DWordSheet: TTabSheet;
    DspProgSheet: TTabSheet;
    F1_15Sheet: TTabSheet;
    WordGRid    : TStringGrid;
    DWordGrid   : TStringGrid;
    FloatGrid   : TStringGrid;
    DspProgGrid : TStringGrid;
    F1_15Grid   : TStringGrid;
    ChartSheet: TTabSheet;
    Panel1: TPanel;
    SeriesListBox: TCheckListBox;
    Panel2: TPanel;
    SerCntEdit: TSpinEdit;
    Label1: TLabel;
    ChartListMenu: TPopupMenu;
    EditNameItem: TMenuItem;
    EditKolorItem: TMenuItem;
    ColorDialog1: TColorDialog;
    DataSizeBox: TRadioGroup;
    SerieTypeBox: TRadioGroup;
    DrawCharBtn: TButton;
    PointsBox: TCheckBox;
    RZ30MemBox: TCheckBox;
    WekSheet: TTabSheet;
    Panel3: TPanel;
    Label2: TLabel;
    WekCntEdit: TSpinEdit;
    WekListBox: TListBox;
    WekListMenu: TPopupMenu;
    Zmiekolor1: TMenuItem;
    Zmienazw1: TMenuItem;
    WekChart: TChart;
    WekSeries: TArrowSeries;
    Panel4: TPanel;
    MainChart: TChart;
    Panel5: TPanel;
    MinXEdit: TLabeledEdit;
    MaxXEdit: TLabeledEdit;
    MinYEdit: TLabeledEdit;
    MaxYEdit: TLabeledEdit;
    AutoXYBox: TCheckBox;
    DataTypeBox: TRadioGroup;
    DFloatSheet: TTabSheet;
    DFloatGrid: TStringGrid;
    AllOnItem: TMenuItem;
    AllOffItem: TMenuItem;
    MeasurePanel: TPanel;
    Button1: TButton;
    MeasureGrid: TStringGrid;
    Button2: TButton;
    SaveM1Btn: TButton;
    RestoreM1Btn: TButton;
    SaveM2Btn: TButton;
    RestoreM2Btn: TButton;
    SaveM3Btn: TButton;
    RestoreM3Btn: TButton;
    WordGridPanel: TPanel;
    WordColCntEdit: TSpinEdit;
    Label3: TLabel;
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure GridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WordSheetShow(Sender: TObject);
    procedure WordGRidSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure DWordGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure DWordSheetShow(Sender: TObject);
    procedure FloatSheetShow(Sender: TObject);
    procedure DspProgSheetShow(Sender: TObject);
    procedure FloatGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure F1_15SheetShow(Sender: TObject);
    procedure F1_15GridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure SerCntEditChange(Sender: TObject);
    procedure SeriesListBoxClickCheck(Sender: TObject);
    procedure EditNameItemClick(Sender: TObject);
    procedure EditKolorItemClick(Sender: TObject);
    procedure DrawCharBtnClick(Sender: TObject);
    procedure PointsBoxClick(Sender: TObject);
    procedure RZ30MemBoxClick(Sender: TObject);
    procedure ChartSheetShow(Sender: TObject);
    procedure WekCntEditChange(Sender: TObject);
    procedure WekSheetShow(Sender: TObject);

    procedure Zmienazw1Click(Sender: TObject);
    procedure Zmiekolor1Click(Sender: TObject);
    procedure AutoXYBoxClick(Sender: TObject);
    procedure GridGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure DFloatSheetShow(Sender: TObject);
    procedure DFloatGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure AllOnItemClick(Sender: TObject);
    procedure AllOffItemClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure MeasurePanelEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure Button2Click(Sender: TObject);
    procedure SaveM1BtnClick(Sender: TObject);
    procedure RestoreM1BtnClick(Sender: TObject);
    procedure WordColCntEditChange(Sender: TObject);
  private
    FMemBufSize : cardinal;
    FSrcAdr     : cardinal;
    SecoundTime : boolean;
    EditCellMem : string;
    FOnToBin    : TToBin;
    FOnToValue  : TToValue;
    LasPosPoint : TPoint;

    procedure FSetSize(ASize :cardinal);
    procedure FSetSrcAdr(ASrcAdr : cardinal);

    function  GetState(n : integer; Size: byte):TCellState;
    procedure FSetChartSerCount(AChartSerCount: integer);
    function  FGetChartSerCount: integer;
    procedure FSetWekSerCount(cnt : integer);
    procedure FillMeasureGridValues;
    procedure FillMeasureGridNames;


    procedure SetWord(n : integer; V : word);
    procedure SetDWord(n : integer; V : Cardinal);
    procedure SetSingle(n : integer; V : Single);
    function  GetSingle(n : integer) : Single;
    function  GetDouble(n : integer) : Double;
    procedure SetDSingle(n : integer; V : Single);
    function  GetDSingle(n : integer) : Single;
    function  GetMulti(var n : cardinal):Double;
    function  FirstColTxt(w : cardinal):string;
    function  LiczFirstRow(w : real):integer;
    procedure DrawWekChart;

    function  HexToInt(s : string; var Ok : boolean):Cardinal;
    function  FloatToF1_15(W: real):word;
    function  F1_15ToFloat(W: word):real;
    function  GetDWord(n : integer):Cardinal;
    function  GetWord(n : integer):word;
    function  GetByte(n : integer):byte;
    procedure SetByte(n : integer; B:byte);
    function  FGetActivPage : integer;
    procedure FSetActivPage(APageNr : integer);
    function  ReadMinMaxBox(var R: TRect):boolean;
    procedure SetMinMaxBox(const R : TRect);
    procedure ShowMinMaxBox(const R : TRect);
    procedure MakeMinMaxBoxHints;
  protected
    function  GetSeria(n : integer): string;
    function  LiczFirstCol(w : integer):cardinal;
    function  GetWektor(n : integer): string;
    procedure AddSeria(s : string);
    procedure AddWektor(s : string);
    property  ChartSerCount : integer read FGetChartSerCount write FSetChartSerCount;
  public
    MemState     : array of TCellState;
    MemBuf       : array of word;
    MemBufCopy   : array of word;
    CharMinMaxTab : array[0..MAX_MEM_BOX-1] of TRect;
    WordOrder     : TWordOrder;

    constructor Create(AOwner: TComponent); override;

    property  OnToBin    : TToBin read FOnToBin write FOnToBin;
    property  OnToValue  : TToValue read FOnToValue write FOnToValue;

    property  SrcAdr : cardinal read FSrcAdr write FSetSrcAdr;
    property  MemSize : cardinal read FMemBufSize write FSetSize;
    procedure PaintActivPage;
    procedure SetNewData;
    procedure ClrData;
    procedure FillZero;
    procedure FillOnes;
    procedure Fill(val: word);
    property  ActivPage : integer read FGetActivPage write FSetActivPage;
    procedure SaveToIni(Ini : TMemIniFile; SName : string);
    function GetJSONObject: TJSONObject;

    procedure LoadFromIni(Ini : TMemIniFile; SName : string);
    procedure CopyToStringList(SL : TStrings);
    procedure doParamVisible(vis : boolean);
  end;


implementation

uses
  Types;

{$R *.dfm}

const
  FIRST_COL_WIDTH = 78;

constructor TAnalogFrame.Create(AOwner: TComponent);
begin
  inherited;
  WordOrder := woLitleIndian;
end;

function  TAnalogFrame.FGetActivPage : integer;
begin
  Result := ShowTypePageCtrl.ActivePageIndex;
end;

procedure TAnalogFrame.FSetActivPage(APageNr : integer);
begin
  if APageNr>=ShowTypePageCtrl.PageCount then
    APageNr :=0;
  ShowTypePageCtrl.ActivePage := ShowTypePageCtrl.Pages[APageNr];
end;


function TAnalogFrame.HexToInt(s : string; var Ok : boolean):Cardinal;
var
  N : int64;
begin
  N := 0;
  Ok := true;
  while s<>'' do
  begin
    if (s[1]>='0') and (s[1]<='9') then
      N := 16*N + (ord(s[1])-ord('0'))
    else  if (upcase(s[1])>='A') and (upcase(s[1])<='F') then
      N := 16*N + (ord(upcase(s[1]))-ord('A')+10)
    else
      ok := false;
    s := copy(s,2,length(s)-1);
  end;
  Result := Cardinal(N);
end;


function TAnalogFrame.GetByte(n : integer):byte;
var
  Val : OleVariant;
begin
  if FOnToValue('B',@MemBuf[n],'B',Val)=0 then
  begin
    Result := Val;
  end
  else
    raise exception.Create('Bl¹d konwersji do liczby');
end;
procedure TAnalogFrame.SetByte(n : integer; B:byte);
begin
  FOnToBin('B',@MemBuf[N],1,'B',B);
end;

function TAnalogFrame.GetWord(n : integer):word;
begin
  Result := MemBuf[n]
end;

procedure TAnalogFrame.SetWord(n : integer; V : word);
begin
  MemBuf[N]:=v;
end;

function TAnalogFrame.GetDWord(n : integer):Cardinal;
begin
  case WordOrder of
  woBigIndian:
  begin
     Result := MemBuf[n];
     Result := Result shl 16;
     Result := Result or MemBuf[n+1];
  end;
  woLitleIndian:
  begin
     Result := MemBuf[n+1];
     Result := Result shl 16;
     Result := Result or MemBuf[n];
  end;
  else
    raise exception.Create('Nieznany porz¹dek s³ów');
  end;
end;

procedure TAnalogFrame.SetDWord(n : integer; V : Cardinal);
begin
  case WordOrder of
  woBigIndian:
  begin
     MemBuf[n+0] := V shr 16;
     MemBuf[n+1] := V and $ffff;
  end;
  woLitleIndian:
  begin
     MemBuf[n+0] := V and $ffff;
     MemBuf[n+1] := V shr 16;
  end;
  else
    raise exception.Create('Nieznany porz¹dek s³ów');
  end;
end;


procedure TAnalogFrame.SetDSingle(n : integer; V : Single);
begin
  SetDWord(n,pCardinal(@V)^);
end;

function TAnalogFrame.GetDSingle(n : integer) : Single;
var
  Val : cardinal;
begin
  Val := GetDWord(n);
  result := pSingle(@val)^;
end;

procedure TAnalogFrame.SetSingle(n : integer; V : Single);
var
  vv : cardinal;
begin
  vv := pcardinal(@V)^;
  SetDWord(n,VV);
end;

function TAnalogFrame.GetSingle(n : integer) : Single;
var
  Val : cardinal;
begin
  Val := GetDWord(n);
  result := pSingle(@val)^;
end;

function TAnalogFrame.GetDouble(n : integer) : Double;
var
  Val : OleVariant;
begin
  if FOnToValue('B',@MemBuf[n],'E',Val)=0 then
  begin
    Result := Val;
  end
  else
    raise exception.Create('Bl¹d konwersji do liczby');
end;



function TAnalogFrame.GetMulti(var n : cardinal):Double;
begin
  Result := 0;
  if RZ30MemBox.Checked then
  begin
    Result := SmallInt(GetWord(n));
    inc(n,2);
  end
  else
  begin
    case DataTypeBox.ItemIndex of
    0 : begin
          case DataSizeBox.ItemIndex of
          0 : begin
                Result := ShortInt(MemBuf[n]);
                inc(n,1);
              end;
          1 : begin
                Result := SmallInt(GetWord(n));
                inc(n,2);
              end;
          2 : begin
                Result := Integer(GetDWord(n));
                inc(n,4);
              end;
          else
            inc(n,2);
          end;
        end;
    1 : begin
          case DataSizeBox.ItemIndex of
          0 : begin
                Result := MemBuf[n];
                inc(n,1);
              end;
          1 : begin
                Result := GetWord(n);
                inc(n,2);
              end;
          2 : begin
                Result := GetDWord(n);
                inc(n,4);
              end;
          else
            inc(n,2);
          end;
        end;
     2: begin   //Float
           Result := GetSingle(n);
           inc(n,4);
         end;
     3: begin   //Double
           Result := GetDouble(n);
           inc(n,8);

        end;
     end;
  end;
end;




function TAnalogFrame.GetState(n : integer; Size: byte):TCellState;
var
  i : integer;
begin
  Result := csEmpty;
  for i:=0 to Size-1 do
  begin
    if n+i<length(MemState) then
      if MemState[n+i]>Result then Result := MemState[n+i];
  end;
end;

procedure TAnalogFrame.FSetSize(ASize :cardinal);
begin
  if FMemBufSize <>ASize then
  begin
    FMemBufSize := ASize;
    SetLength(MemState,FMemBufSize);
    SetLength(MemBuf,FMemBufSize);
    SetLength(MemBufCopy,FMemBufSize);
  end;
  PaintActivPage;
end;

procedure TAnalogFrame.FSetSrcAdr(ASrcAdr : cardinal);
begin
  FSrcAdr := ASrcAdr;
  PaintActivPage;
end;


procedure TAnalogFrame.PaintActivPage;
begin
  if ShowTypePageCtrl.ActivePage<>nil then
  begin
    if Assigned(ShowTypePageCtrl.ActivePage.OnShow) then
    begin
      ShowTypePageCtrl.ActivePage.OnShow(self);
    end;
  end;
end;

procedure TAnalogFrame.SetNewData;
var
  i : integer;
begin
  for i:=0 to length(MemState)-1 do
  begin
    if MemBuf[i]=MemBufCopy[i] then
      MemState[i]:=csFull
    else
      MemState[i]:=csChg;
    MemBufCopy[i]:=MemBuf[i];
  end;
  PaintActivPage;
end;

procedure TAnalogFrame.ClrData;
var
  i : integer;
begin
  for i:=0 to length(MemState)-1 do
  begin
    MemState[i]:=csEmpty;
  end;
  PaintActivPage;
end;

procedure TAnalogFrame.Fill(val: word);
var
  i : integer;
begin
  for i:=0 to length(MemState)-1 do
  begin
    if MemBuf[i]<>val then
    begin
      MemState[i]:=csModify;
      MemBuf[i]:=val;
    end
    else
      MemState[i]:=csFull;
  end;
  PaintActivPage;
end;


procedure TAnalogFrame.FillZero;
begin
  Fill(0);
end;

procedure TAnalogFrame.FillOnes;
begin
  Fill($ff);
end;


function  TAnalogFrame.FloatToF1_15(W: real):word;
var
  C    : integer;
  n    : smallInt;
begin
  if abs(w)>1 then
    Raise Exception.Create('1.15 format error');
  C:=Round(W*$8000+0.5);
  if C = $8000 then
    C := $7fff;
  n := C;
  Result := word(n);
end;

function TAnalogFrame.F1_15ToFloat(W: word):real;
begin
  Result := SmallInt(W);
  Result := Result/32768;
end;


procedure TAnalogFrame.GRidDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  s      : string;
  CellSt : TCellState;
  Grid   : TStringGrid;
  N      : integer;
begin
  Grid := Sender as TStringGrid;
  Grid.Canvas.Font.Name:='Courier';

  if (Acol=0) or (Arow=0) then Grid.Canvas.Brush.Color := clBtnFace
  else  if not(gdFocused in State) then  Grid.Canvas.Brush.Color := clWindow
  else  Grid.Canvas.Brush.Color := clHighlight;

  if not(gdFocused in State) then  Grid.Canvas.Font.Color:=clBlack
                             else  Grid.Canvas.Font.Color:=clWhite;

  Grid.Canvas.Font.Style:=[];
  s:=Grid.Cells[Acol,Arow];


  if (ACol>0) and (ARow>0) then
  begin
    CellSt := csEmpty;
    if Sender=F1_15Grid then
    begin
      N := 16*(ARow-1)+(ACol-1);
      CellSt := GetState(N,1);
    end
    else if Sender=WordGrid then
    begin
      N := (WordGrid.ColCount-1)*(ARow-1)+(ACol-1);
      CellSt := GetState(N,1);
    end
    else if (Sender=DWordGrid) or (Sender=FloatGrid) or (Sender=DFloatGrid) or (Sender=DspProgGrid) then
    begin
      N := 2*(8*(ARow-1)+(ACol-1));
      CellSt := GetState(N,2);
    end;

    case CellSt of
    csEmpty: begin
               s := '';
             end;
    csFull:  ;
    csModify:begin
               Grid.Canvas.Font.Color:=clBlue;
               Grid.Canvas.Font.Style:=[fsBold];
             end;
    csChg:   begin
               Grid.Canvas.Font.Color:=clFuchsia;// Lime;
               Grid.Canvas.Font.Style:=[fsBold];
             end;
    csBad:   begin
               Grid.Canvas.Font.Color:=clRed;
               Grid.Canvas.Font.Style:=[fsBold];
             end;
    end;
  end;
  Grid.Canvas.TextRect(Rect,Rect.Left+2,Rect.Top+2,s);
end;

procedure TAnalogFrame.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  k : word;
  Grid : TStringGrid;
begin
  Grid:= Sender as TStringGrid;
  k := key;
  key:=0;
  case k of
  VK_RETURN : begin
                if Grid.Col=Grid.ColCount-1 then
                begin
                  Grid.Col:=1;
                  if Grid.Row=Grid.RowCount-1 then
                    Grid.Row:=1
                  else
                    Grid.Row:=GRid.Row+1;
                end
                else
                  Grid.Col:=Grid.Col+1;
                Grid.EditorMode := False;
             end;
  27       : begin
               Grid.Cells[Grid.Col,Grid.Row]:= EditCellMem;
               Grid.EditorMode := False;
             end;
  else
    key:=k;
  end;
end;

procedure TAnalogFrame.GridGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
  EditCellMem := (Sender as TStringGrid).Cells[ACol,ARow];
end;

function TAnalogFrame.LiczFirstCol(w : integer):cardinal;
begin
  Result:= w;
end;

function  TAnalogFrame.FirstColTxt(w : cardinal):string;
begin
  Result := '"'+IntToHex(w shr 16,4)+' '+IntToHex(w and $ffff,4)+'"';
end;

function TAnalogFrame.LiczFirstRow(w : real):integer;
begin
  Result := trunc(W);
end;



// ------------------ WORD GRID ------------------------------------------
procedure TAnalogFrame.WordColCntEditChange(Sender: TObject);
begin
  WordSheetShow(nil);
end;

procedure TAnalogFrame.WordSheetShow(Sender: TObject);
var
  i   : cardinal;
  x,y : integer;
  NN  : integer;
begin
  NN := WordColCntEdit.Value;
  WordGrid.RowCount  := 1+(FMemBufSize+NN-1) div NN;
  WordGrid.ColCount  := 1+NN;

  WordGrid.Cells[0,0]:='B';
  WordGrid.ColWidths[0]:=FIRST_COL_WIDTH;
  for i:=0 to NN-1 do
  begin
    WordGrid.Cells[i+1,0]:=' +'+IntToHex(i+1,2);
  end;
  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i<FMemBufSize do
    begin
      x := (i  mod NN);
      y := i  div NN;
      if x=0 then
        WordGrid.Rows[y+1].CommaText:=FirstColTxt(FSrcAdr+LiczFirstCol(i));
      WordGrid.Cells[x+1,y+1]:=IntToHex(MemBuf[i],4);
      inc(i);
    end;
  end;
  WordGrid.Refresh;
end;

procedure TAnalogFrame.WordGRidSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
  k  : TCellState;
  OK : boolean;
  V  : integer;
  n  : integer;
begin
  V:=HexToInt(Value,OK);
  n:=(WordGrid.ColCount-1)*(ARow-1)+(ACol-1);

  if (V<$10000) then
  begin
    if GetWord(n)<>V then
    begin
      SetWord(n,V);
      k:=csModify;
    end
    else
      k:=GetState(n,1);
    if not(WordGrid.EditorMode) then
      WordGrid.Cells[Acol,ARow]:=IntToHex(V,4);
  end
  else
    k :=csBad;
  MemState[n]:=k;

  if (Length(Value)=4) and WordGrid.EditorMode then
    WordGrid.EditorMOde := False
end;

// ------------------ DWORD GRID ------------------------------------------
procedure TAnalogFrame.DWordSheetShow(Sender: TObject);
var
  i   : cardinal;
  x,y : integer;
begin
  DWordGrid.RowCount := 1+(FMemBufSize+15) div 16;
  DWordGrid.Cells[0,0]:='B';
  DWordGrid.ColWidths[0]:=FIRST_COL_WIDTH;
  for i:=0 to 7 do
  begin
    DWordGrid.Cells[i+1,0]:='     +'+IntToHex(LiczFirstRow(1+i*2),2);
  end;
  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i<FMemBufSize do
    begin
      x := (i  mod 16) div 2;
      y := i  div 16;
      if x=0 then
        DWordGrid.Rows[y+1].CommaText:=FirstColTxt(FSrcAdr+LiczFirstCol(i));
      DWordGrid.Cells[X+1,y+1]:=IntToHex(GetDWord(i),8);
      inc(i,2);
    end;
  end;
  DWordGrid.Refresh;
end;

procedure TAnalogFrame.DWordGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
  k  : TCellState;
  OK : boolean;
  V  : Cardinal;
  n  : integer;
begin
  V:=HexToInt(Value,OK);
  n:=2*(8*(ARow-1)+(ACol-1));
  OK := true;
  if Ok  then
  begin
    SetDWord(n,V);
    if not(DWordGrid.EditorMode) then
      DWordGrid.Cells[Acol,ARow]:=IntToHex(V,8);
    k:=csModify;
  end
  else
    k :=csBad;
  MemState[n]:=k;
  MemState[n+1]:=k;

  if (Length(Value)=8) and DWordGrid.EditorMode then
    DWordGrid.EditorMOde := False
end;

// ------------------ FLOAT GRID ------------------------------------------
procedure TAnalogFrame.FloatSheetShow(Sender: TObject);
var
  i   : cardinal;
  x,y : integer;
  s   : string;
begin
  FloatGrid.RowCount := 1+(FMemBufSize+15) div 16;
  FloatGrid.Cells[0,0]:='B';
  FloatGrid.ColWidths[0]:=FIRST_COL_WIDTH;
  for i:=0 to 7 do
     FloatGrid.Cells[i+1,0]:='     +'+IntToHex(LiczFirstRow(1+2*i),2);

  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i<FMemBufSize do
    begin
      x := (i  mod 16) div 2;
      y := i  div 16;
      if x=0 then
        FloatGrid.Rows[y+1].CommaText:=FirstColTxt(FSrcAdr+LiczFirstCol(i));
      try
        s := Format('%.5f',[GetSingle(i)]);
      except
        s :='';
      end;
      FloatGrid.Cells[X+1,y+1]:=s;
      inc(i,2);
    end;
  end;
  FloatGrid.Refresh;
end;

procedure TAnalogFrame.FloatGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
  k  : TCellState;
  OK : boolean;
  V  : Single;
  n  : integer;
begin
  try
    V  := StrToFloat(Value);
    Ok := True;
  except
    Ok := False;
    V  := 0;
  end;
  n:=2*(8*(ARow-1)+(ACol-1));

  if Ok then
  begin
    SetSingle(n,V);
    if not(FloatGrid.EditorMode) then
      FloatGrid.Cells[Acol,ARow]:=Format('%.5f',[V]);
    k:=csModify;
  end
  else
    k :=csBad;
  MemState[n]:=k;
  MemState[n+1]:=k;
end;

// ------------------ DFLOAT GRID ------------------------------------------
procedure TAnalogFrame.DFloatSheetShow(Sender: TObject);
var
  i   : cardinal;
  x,y : integer;
  s   : string;
begin
  DFloatGrid.RowCount := 1+(FMemBufSize+15) div 16;
  DFloatGrid.Cells[0,0]:='B';
  DFloatGrid.ColWidths[0]:=FIRST_COL_WIDTH;
  for i:=0 to 7 do
     DFloatGrid.Cells[i+1,0]:='     +'+IntToHex(LiczFirstRow(1+2*i),2);

  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i<FMemBufSize do
    begin
      x := (i  mod 16) div 2;
      y := i  div 16;
      if x=0 then
        DFloatGrid.Rows[y+1].CommaText:=FirstColTxt(FSrcAdr+LiczFirstCol(i));
      try
        s := FloatToStrF(GetDSingle(i),ffGeneral,3,8);
      except
        s :='';
      end;
      DFloatGrid.Cells[X+1,y+1]:=s;
      inc(i,2);
    end;
  end;
  DFloatGrid.Refresh;
end;

procedure TAnalogFrame.DFloatGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
  k  : TCellState;
  OK : boolean;
  V  : Single;
  n  : integer;
begin
  try
    V  := StrToFloat(Value);
    Ok := True;
  except
    Ok := False;
    V  := 0;
  end;
  n:=2*(8*(ARow-1)+(ACol-1));

  if Ok then
  begin
    SetDSingle(n,V);
    if not(DFloatGrid.EditorMode) then
      DFloatGrid.Cells[Acol,ARow]:=FloatToStrF(V,ffGeneral,3,8);
    k:=csModify;
  end
  else
    k :=csBad;
  MemState[n]:=k;
  MemState[n+1]:=k;
end;


// ------------------ DSPPPROG GRID ------------------------------------------
procedure TAnalogFrame.DspProgSheetShow(Sender: TObject);
var
  i   : cardinal;
  x,y : integer;
  w,w1: cardinal;
  b1,b2,b3 : byte;
begin
  DspProgGrid.RowCount := 1+(FMemBufSize+15) div 16;
  DspProgGrid.Cells[0,0]:='B';
  DspProgGrid.ColWidths[0]:=FIRST_COL_WIDTH;
  for i:=0 to 7 do
     DspProgGrid.Cells[i+1,0]:=' +'+IntToHex(LiczFirstRow(1+2*i),2);

  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i<FMemBufSize do
    begin
      x := (i  mod 16) div 2;
      y := i  div 16;
      if x=0 then
        DspProgGrid.Rows[y+1].CommaText:=FirstColTxt(FSrcAdr+LiczFirstCol(i));
      w := GetDWord(i);
      b1 := (w shr 24) and $ff;
      b2 := (w shr 8) and $ff;
      b3 := w and $ff;
      w1 := b1 or (b2 shl 8) or (b3 shl 16);
      DspProgGrid.Cells[X+1,y+1]:=IntToHex(w1,6);
      inc(i,2);
    end;
  end;
  DspProgGrid.Refresh;
end;


// ------------------ F1_15 GRID ------------------------------------------

procedure TAnalogFrame.F1_15SheetShow(Sender: TObject);
var
  i   : cardinal;
  x,y : integer;
begin
  F1_15Grid.RowCount  := 1+(FMemBufSize+15) div 16;
  F1_15Grid.Cells[0,0]:='B';
  F1_15Grid.ColWidths[0]:=FIRST_COL_WIDTH;
  for i:=0 to 15 do
  begin
    F1_15Grid.Cells[i+1,0]:=' +'+IntToHex(LiczFirstRow(1+i),2);
  end;

  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i<FMemBufSize do
    begin
      x := i  mod 16 ;
      y := i  div 16;
      if x=0 then
        F1_15Grid.Rows[y+1].CommaText:=FirstColTxt(FSrcAdr+LiczFirstCol(i));
      F1_15Grid.Cells[x+1,y+1]:=Format('%.5f',[F1_15ToFloat(GetWord(i))]);
      inc(i);
    end;
  end;
  F1_15Grid.Refresh;
end;

procedure TAnalogFrame.F1_15GridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
  k  : TCellState;
  OK : boolean;
  V  : Single;
  w  : word;
  n  : integer;
begin
  try
    V := StrToFloat(Value);
    w := FloatToF1_15(V);
    Ok := True;
  except
    Ok := False;
    w := 0;
  end;
  n:=16*(ARow-1)+(ACol-1);

  if Ok then
  begin
    SetWord(n,W);
    if not(F1_15Grid.EditorMode) then
    begin
      F1_15Grid.Cells[Acol,ARow]:=Format('%.5f',[F1_15ToFloat(W)]);
    end;
    k:=csModify;
  end
  else
    k :=csBad;
  MemState[n]:=k;
  MemState[n+1]:=k;
end;

// ------------------ CHART ------------------------------------------

procedure TAnalogFrame.AddSeria(s : string);
var
  SL   : TStringList;
  LSer : TLineSeries;
  n    : integer;
begin
  SL := TStringList.Create;
  SL.Delimiter := '|';
  SL.DelimitedText := s;
  if SL.Count>=3 then
  begin
    LSer:= TLineSeries.Create(self);
    LSer.Title := SL.Strings[0];
    LSer.SeriesColor := StrToInt(SL.Strings[1]);
    SeriesListBox.AddItem(SL.Strings[0],LSer);
    for n:=0 to 20 do
      LSer.AddXY(n,random(100));
    if SL.Strings[2]='1' then
    begin
      LSer.ParentChart := MainChart;
      SeriesListBox.Checked[SeriesListBox.Count-1]:=True;
    end;
  end;
  SL.Free;
  SerCntEdit.Value := SeriesListBox.Count;
end;

function TAnalogFrame.GetSeria(n : integer): string;
var
  SL : TStringList;
  LSer : TLineSeries;
begin
  LSer := SeriesListBox.Items.Objects[n] as TLineSeries;
  SL := TStringList.Create;
  SL.Delimiter := '|';
  SL.Add(LSer.Title);
  SL.Add(IntToStr(LSer.SeriesColor));
  if LSer.ParentChart=nil then  SL.Add('0')
                          else  SL.Add('1');
  Result := SL.DelimitedText;
  SL.Free;
end;

procedure TAnalogFrame.SerCntEditChange(Sender: TObject);
begin
  FSetChartSerCount(SerCntEdit.Value);
end;

function  TAnalogFrame.FGetChartSerCount: integer;
begin
  Result := SeriesListBox.Count;
end;

procedure TAnalogFrame.FSetChartSerCount(AChartSerCount: integer);
var
  Series: TLineSeries;
  n     : integer;
  s     : string;
begin
  while SeriesListBox.Count<AChartSerCount do
  begin
    Series:= TLineSeries.Create(self);
    Series.ParentChart := MainChart;
    s := Format('Seria_%u',[SeriesListBox.COunt]);
    Series.Title := s;
    SeriesListBox.AddItem(s,Series);
    SeriesListBox.Checked[SeriesListBox.Count-1]:=True;
    for n:=0 to 20 do
      Series.AddXY(n,random(100));
  end;
  while SeriesListBox.Count>AChartSerCount do
  begin
    SeriesListBox.Items.Objects[SeriesListBox.Count-1].Free;
    SeriesListBox.Items.Delete(SeriesListBox.Count-1);
  end;
end;




procedure TAnalogFrame.SeriesListBoxClickCheck(Sender: TObject);
var
  i : integer;
begin
  for i:=0 to SeriesListBox.Count-1 do
  begin
    if SeriesListBox.Checked[i] then
      (SeriesListBox.Items.Objects[i] as TLineSeries).ParentChart := MainChart
    else
      (SeriesListBox.Items.Objects[i] as TLineSeries).ParentChart := nil;
  end;
end;

procedure TAnalogFrame.AllOnItemClick(Sender: TObject);
var
  i : integer;
begin
  for i:=0 to SeriesListBox.Count-1 do
  begin
    SeriesListBox.Checked[i] := true;
  end;
  SeriesListBoxClickCheck(Sender);
end;

procedure TAnalogFrame.AllOffItemClick(Sender: TObject);
var
  i : integer;
begin
  for i:=0 to SeriesListBox.Count-1 do
  begin
    SeriesListBox.Checked[i] := false;
  end;
  SeriesListBoxClickCheck(Sender);
end;


procedure TAnalogFrame.EditNameItemClick(Sender: TObject);
var
  s : string;
begin
  s := SeriesListBox.Items.Strings[SeriesListBox.ItemIndex];
  if InputQuery('Zmiana nazwy','Podaj now¹ nazwê',s) then
  begin
    (SeriesListBox.Items.Objects[SeriesListBox.ItemIndex] as TLineSeries).Title:=s;
    SeriesListBox.Items.Strings[SeriesListBox.ItemIndex]:=s;
  end;
end;

procedure TAnalogFrame.EditKolorItemClick(Sender: TObject);
var
  Color  : TColor;
begin
  Color := (SeriesListBox.Items.Objects[SeriesListBox.ItemIndex] as TLineSeries).SeriesColor;
  ColorDialog1.Color := Color;
  if ColorDialog1.Execute then
    (SeriesListBox.Items.Objects[SeriesListBox.ItemIndex] as TLineSeries).SeriesColor:= ColorDialog1.Color;
end;





procedure TAnalogFrame.DrawCharBtnClick(Sender: TObject);
var
  N       : cardinal;
  Cnt     : cardinal;
  f       : Double;
  i       : cardinal;
  K       : cardinal;
  Nr      : integer;
  wsk     : cardinal;
  LSer    : TLineSeries;
  w       : word;
begin
  N := SeriesListBox.Count;
  if N<>0 then
  begin
    for i:=0 to N-1 do
     (SeriesListBox.Items.Objects[i] as TLineSeries).Clear;

    wsk := 0;
    if RZ30MemBox.Checked then
    begin
      i:=0;
      repeat
        w:=GetWord(wsk);
        if (w and $0001)=0 then
          inc(wsk,2);
        inc(i);
      until ((w and $0001)<>0) or (i>40);
    end;

    case SerieTypeBox.ItemIndex of
    0:begin                            //abcabcabc
        i   := 0;
        while wsk<FMemBufSize do
        begin
          LSer := SeriesListBox.Items.Objects[i mod N] as TLineSeries;
          f  := GetMulti(wsk);
          LSer.AddXY(i div N,f);
          inc(i);
        end;
      end;
    1:begin                           //aaabbbccc
        Cnt := (FMemBufSize div N) div 2;
        i   := 0;
        while wsk<FMemBufSize do
        begin
          f  := GetMulti(wsk);
          K  := i div Cnt;
          Nr := i mod Cnt;
          if K<N then
          begin
            LSer := SeriesListBox.Items.Objects[K] as TLineSeries;
            LSer.AddXY(Nr,f);
          end;
          inc(i);
        end;
      end;
    end;
  end;
end;

procedure TAnalogFrame.PointsBoxClick(Sender: TObject);
var
  i : integer;
begin
  for i :=0 to SeriesListBox.Count-1 do
  begin
    (SeriesListBox.Items.Objects[i] as TLineSeries).Pointer.Visible := PointsBox.Checked;
  end;
end;

procedure TAnalogFrame.RZ30MemBoxClick(Sender: TObject);
begin
//  DataTypeBox.ItemIndex:=0;
//  DataSizeBox.ItemIndex:=1;
  DataTypeBox.Enabled  := not((sender as TCheckBox).Checked);
  SerieTypeBox.Enabled := not((sender as TCheckBox).Checked);
  DataSizeBox.Enabled  := not((sender as TCheckBox).Checked);
end;

procedure TAnalogFrame.ChartSheetShow(Sender: TObject);
begin
  DrawCharBtnClick(Sender);
  AutoXYBoxClick(Sender);
  if MeasurePanel.Visible then
    FillMeasureGridValues;
end;

function TAnalogFrame.ReadMinMaxBox(var R: TRect):boolean;
begin
  Result :=true;
  try
    R.Bottom := StrToInt(MinYEdit.Text);
  except
    Result := false;
  end;
  try
    R.Top:= StrToInt(MaxYEdit.Text);
  except
    Result := false;
  end;

  try
    R.Left := StrToInt(MinXEdit.Text);
  except
    Result := false;
  end;

  try
    R.Right:= StrToInt(MaxXEdit.Text);
  except
    Result := false;
  end;
end;

procedure TAnalogFrame.SetMinMaxBox(const R : TRect);
begin
  MainChart.LeftAxis.Minimum := R.Bottom;
  MainChart.LeftAxis.Maximum := R.Top;
  MainChart.BottomAxis.Minimum := R.Left;
  MainChart.BottomAxis.Maximum := R.Right;
  MainChart.LeftAxis.AutomaticMaximum:=False;
  MainChart.LeftAxis.AutomaticMinimum:=False;
  MainChart.BottomAxis.AutomaticMaximum:=False;
  MainChart.BottomAxis.AutomaticMinimum:=False;
end;

procedure TAnalogFrame.ShowMinMaxBox(const R : TRect);
begin
  MinYEdit.Text := IntToStr(R.Bottom);
  MaxYEdit.Text := IntToStr(R.Top);
  MinXEdit.Text := IntToStr(R.Left);
  MaxXEdit.Text := IntToStr(R.Right);
end;


procedure TAnalogFrame.AutoXYBoxClick(Sender: TObject);
var
  R : TRect;
begin
  if not(AutoXYBox.Checked) then
  begin
    if ReadMinMaxBox(R) then
      SetMinMaxBox(R)
    else
      AutoXYBox.Checked := true;
  end
  else
  begin
    MainChart.LeftAxis.AutomaticMaximum:=True;
    MainChart.LeftAxis.AutomaticMinimum:=True;
    MainChart.BottomAxis.AutomaticMaximum:=True;
    MainChart.BottomAxis.AutomaticMinimum:=True;
  end;
end;

procedure TAnalogFrame.Button2Click(Sender: TObject);
begin
  MinYEdit.Text := IntToStr(round(MainChart.LeftAxis.Minimum));
  MaxYEdit.Text := IntToStr(round(MainChart.LeftAxis.Maximum));
  MinXEdit.Text := IntToStr(round(MainChart.BottomAxis.Minimum));
  MaxXEdit.Text := IntToStr(round(MainChart.BottomAxis.Maximum));
end;


procedure TAnalogFrame.SaveM1BtnClick(Sender: TObject);
var
  Nr : integer;
begin
  Nr := (Sender as TButton).Tag-1;
  if (Nr>=0) and (Nr<MAX_MEM_BOX) then
  begin
    ReadMinMaxBox(CharMinMaxTab[nr]);
    MakeMinMaxBoxHints;
  end;
end;

procedure TAnalogFrame.RestoreM1BtnClick(Sender: TObject);
var
  Nr : integer;
begin
  Nr := (Sender as TButton).Tag-1;
  if (Nr>=0) and (Nr<MAX_MEM_BOX) then
  begin
    ShowMinMaxBox(CharMinMaxTab[nr]);
    SetMinMaxBox(CharMinMaxTab[nr]);
  end;
end;


procedure TAnalogFrame.Button1Click(Sender: TObject);
var
  R  : TRect;
  PT : TPoint;
begin
  if not(MeasurePanel.Visible) then
  begin
    if LasPosPoint.X=-1 then
    begin
      Pt.X := MainChart.Width div 3;
      Pt.Y := MainChart.Height div 3;
      Pt := MeasurePanel.Parent.ClientToScreen(Pt);
      LasPosPoint := Pt;
    end
    else
    begin
      Pt := LasPosPoint;
      if PT.x>Screen.DesktopWidth  then PT.x:=Screen.DesktopWidth-50;
      if PT.y>Screen.DesktopHeight then PT.y:=Screen.DesktopHeight-50;
    end;
    R := Bounds(Pt.X,Pt.Y,MeasurePanel.Width,MeasurePanel.Height);

    MeasurePanel.ManualFloat(R);
    MeasurePanel.Visible := true;
    FillMeasureGridNames;
  end;
  FillMeasureGridValues;
end;


procedure TAnalogFrame.FillMeasureGridValues;
  procedure GetMeasure(Sr : TLineSeries; var RMS:real; var RMZ:real; var Avr : real; var aMin : integer; var aMax : integer);
  var
    n   : integer;
    i   : integer;
    a   : real;
    aa  : integer;
    Buf : array of real;
  begin
    Avr := 0;
    RMS := 0;
    n := Sr.Count;
    SetLength(Buf,n);
    for i:=0 to n-1 do
    begin
      Buf[i] := Sr.YValue[i];
    end;

    for i:=0 to n-1 do
    begin
      a := Buf[i];
      aa := round(a);
      if i=0 then
      begin
        aMin := aa;
        aMax := aa;
      end
      else
      begin
        aMin := Min(aMin,aa);
        aMax := Max(aMax,aa);
      end;

      Avr := Avr + a;
      Rms := Rms + a*a;
    end;
    Avr := Avr/n;
    Rms := Sqrt(Rms/n);

    Rmz := 0;
    for i:=0 to n-1 do
    begin
      a := Buf[i]-Avr;
      Rmz := Rmz + a*a;
    end;
    Rmz := Sqrt(Rmz/n);
  end;

function FindRow(s : string):integer;
var
  i: integer;
begin
  Result := 0;
  for i:=1 to MeasureGrid.RowCount-1 do
  begin
    if MeasureGrid.Cells[1,i]=s then
    begin
      Result := i;
      break;
    end;
  end;
end;

var
  i    : integer;
  n    : integer;
  Sr   : TLineSeries;
  RMS  : real;
  RMZ  : real;
  Avr  : real;
  aMin : integer;
  aMax : integer;
  RR   : real;
begin
  case DataSizeBox.ItemIndex of
  0 : RR := 128;
  1 : RR := 32768;
  2 : RR := 32768.0*65536;
  else
    RR := 32768;
  end;
  if DataTypeBox.ItemIndex=1 then
    RR := RR*2;

  for i:=0 to SeriesListBox.Count-1 do
  begin

    Sr := SeriesListBox.Items.Objects[i] as TLineSeries;
    n := FindRow(Sr.Title);
    GetMeasure(Sr,RMS,RMZ,Avr,aMin,aMax);
    MeasureGrid.Cells[2,n] := Format('%.2f',[RMS]);
    MeasureGrid.Cells[3,n] := Format('%7.5f',[100*RMS/RR]);
    MeasureGrid.Cells[4,n] := Format('%.2f',[RMZ]);
    MeasureGrid.Cells[5,n] := Format('%7.5f',[100*RMZ/RR]);

    MeasureGrid.Cells[6,n] := Format('%.2f',[Avr]);
    MeasureGrid.Cells[7,n] := Format('%7.5f',[100 * Avr/RR]);
    MeasureGrid.Cells[8,n] := IntToStr(aMin);
    MeasureGrid.Cells[9,n] := IntToStr(aMax);
    MeasureGrid.Cells[10,n] := IntToStr(aMax-aMin);
  end;
end;

procedure TAnalogFrame.FillMeasureGridNames;
var
  i,j  : integer;
  Sr   : TLineSeries;
  s    : string;
  Fnd  : boolean;
  SL   : TStringList;
begin
  SL := TStringList.Create;
  try
    MeasureGrid.Rows[0].CommaText := 'lp Nazwa RMS RMS% RMS/AC RMS/AC% AVR AVR% MIN MAX MAX-MIN';
    MeasureGrid.RowCount := SeriesListBox.Count+1;

    // skasowanie nie uzywanych nazw
    for j:=1 to MeasureGrid.RowCount-1 do
    begin
      MeasureGrid.Cells[0,j] := IntToStr(j);
      s := MeasureGrid.Cells[1,j];
      if SL.IndexOf(s)=-1 then
      begin
        SL.Add(s);
        Fnd := false;
        for i:=0 to SeriesListBox.Count-1 do
        begin
          Sr := SeriesListBox.Items.Objects[i] as TLineSeries;
          Fnd := Fnd or  (Sr.Title=s);
        end;
        if not(Fnd) then
          MeasureGrid.Cells[1,j]:='';
      end
      else
        MeasureGrid.Cells[1,j]:='';
    end;

    // Wpisanie niewpisanych serii
    for i:=0 to SeriesListBox.Count-1 do
    begin
      Sr := SeriesListBox.Items.Objects[i] as TLineSeries;
      Fnd := false;
      for j:=1 to MeasureGrid.RowCount-1 do
      begin
        Fnd := Fnd or (Sr.Title=MeasureGrid.Cells[1,j]);
      end;
      if not(Fnd) then
      begin
        for j:=1 to MeasureGrid.RowCount-1 do
        begin
          if MeasureGrid.Cells[1,j]='' then
          begin
            MeasureGrid.Cells[1,j] := Sr.Title;
            break;
          end;
        end;
      end;
    end;
  finally
    SL.Free;
  end;
end;


procedure TAnalogFrame.MeasurePanelEndDock(Sender, Target: TObject; X,
  Y: Integer);
begin
  LasPosPoint := Point(X,Y);
end;


// ------------------ WEKCHART ------------------------------------------
procedure TAnalogFrame.WekSheetShow(Sender: TObject);
begin
  DrawWekChart;
  if not(SecoundTime) then
  begin
    WekChart.TopAxis.Visible:=True;
    WekChart.TopAxis.Automatic:=False;
    WekChart.TopAxis.Minimum:=-1.2;
    WekChart.TopAxis.Maximum:=1.2;

    WekChart.LeftAxis.Automatic:=False;
    WekChart.LeftAxis.Minimum:=-1.2;
    WekChart.LeftAxis.Maximum:=1.2;
    SecoundTime := True;
  end;
end;


procedure TAnalogFrame.DrawWekChart;
var
  i     : integer;
  x1,y1 : Double;
begin
  if FMemBufSize<cardinal(WekListBox.Count)*2 then
    FSetSize(WekListBox.Count*2);

  WekSeries.Clear;
  if Assigned(FOnToValue) then
  begin
    for i:=0 to WekListBox.Count-1 do
    begin
      x1 := F1_15ToFloat(GetWord(4*i+0));
      y1 := F1_15ToFloat(GetWord(4*i+2));
      WekSeries.AddArrow(0,0,x1,y1,WekListBox.Items[i],Cardinal(WekListBox.Items.Objects[i]))
    end;
  end;
end;

procedure TAnalogFrame.AddWektor(s : string);
var
  SL   : TStringList;
  n    : integer;
begin
  SL := TStringList.Create;
  SL.Delimiter := '|';
  SL.DelimitedText := s;
  if SL.Count>=2 then
  begin
    n := StrToInt(SL.Strings[1]);
    WekListBox.AddItem(SL.Strings[0],Pointer(n));
  end;
  SL.Free;
  WekCntEdit.Value := WekListBox.Count;
end;

function TAnalogFrame.GetWektor(n : integer): string;
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  SL.Delimiter := '|';
  SL.Add(WekListBox.Items[n]);
  SL.Add(IntToStr(Cardinal(WekListBox.Items.Objects[n])));
  Result := SL.DelimitedText;
  SL.Free;
end;

procedure TAnalogFrame.FSetWekSerCount(cnt : integer);
var
  s     : string;
begin
  while WekListBox.Count<Cnt do
  begin
    s := Format('Wektor_%u',[WekListBox.Count]);
    WekListBox.AddItem(s,Pointer(clBlack));
  end;
  while WekListBox.Count>Cnt do
  begin
    WekListBox.Items.Delete(WekListBox.Count-1);
  end;
  DrawWekChart;
end;

procedure TAnalogFrame.WekCntEditChange(Sender: TObject);
begin
  FSetWekSerCount(WekCntEdit.Value);
end;


procedure TAnalogFrame.Zmienazw1Click(Sender: TObject);
var
  s : string;
begin
  s := WekListBox.Items.Strings[WekListBox.ItemIndex];
  if InputQuery('Zmiana nazwy','Podaj now¹ nazwê',s) then
  begin
    WekListBox.Items.Strings[WekListBox.ItemIndex]:=s;
  end;
  DrawWekChart;
end;


procedure TAnalogFrame.Zmiekolor1Click(Sender: TObject);
var
  Color  : TColor;
begin
  Color := TColor(WekListBox.Items.Objects[WekListBox.ItemIndex]);
  ColorDialog1.Color := Color;
  if ColorDialog1.Execute then
    WekListBox.Items.Objects[WekListBox.ItemIndex]:=Pointer(ColorDialog1.Color);
  DrawWekChart;
end;

procedure TAnalogFrame.SaveToIni(Ini : TMemIniFile; SName : string);
var
  i : integer;
  n : string;
  SL : TStringList;
begin
  // zak³adka CHART
  Ini.WriteInteger(SName,'Chart_Cnt',SerCntEdit.Value);
  Ini.WriteInteger(SName,'Grid_word_Col_Cnt', WordColCntEdit.Value);

  FSetChartSerCount(SerCntEdit.Value);
  for i:=0 to SerCntEdit.Value-1 do
  begin
    n := Format('Chart_Item%u_Name',[i]);
    Ini.WriteString(SName,n,SeriesListBox.Items.Strings[i]);
    n := Format('Chart_Item%u_Color',[i]);
    Ini.WriteInteger(SName,n,(SeriesListBox.Items.Objects[i] as TLineSeries).SeriesColor);
  end;
  Ini.WriteBool(SName,'Chart_Auto',AutoXYBox.Checked);
  Ini.WriteString(SName,'Chart_MinX',MinXEdit.Text);
  Ini.WriteString(SName,'Chart_MaxX',MaxXEdit.Text);
  Ini.WriteString(SName,'Chart_MinY',MinYEdit.Text);
  Ini.WriteString(SName,'Chart_MaxY',MaxYEdit.Text);
  Ini.WriteInteger(SName,'Chart_DataType',DataTypeBox.ItemIndex);
  Ini.WriteInteger(SName,'Chart_SereiesType',SerieTypeBox.ItemIndex);
  Ini.WriteInteger(SName,'Chart_DataSize',DataSizeBox.ItemIndex);
  Ini.WriteBool(SName,'Chart_RZ30Data',RZ30MemBox.Checked);
  Ini.WriteBool(SName,'Chart_Points',PointsBox.Checked);
  SL := TStringList.Create;
  try
    SL.Assign(MeasureGrid.Cols[1]);
    SL.Delete(0);
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    Ini.WriteString(SName,'MeasGrid_SortedNames',SL.DelimitedText);
    SL.Clear;
    for i:=1 to MeasureGrid.ColCount-1 do
    begin
      SL.Add(IntToStr(MeasureGrid.ColWidths[i]));
    end;
    Ini.WriteString(SName,'MeasGrid_ColWidth',SL.DelimitedText);

    SL.Clear;
    SL.Add(IntToStr(LasPosPoint.X));
    SL.Add(IntToStr(LasPosPoint.Y));
    SL.Add(IntToStr(MeasurePanel.Width));
    SL.Add(IntToStr(MeasurePanel.Height));
    Ini.WriteString(SName,'MeasGrid_Pos',SL.DelimitedText);
    for i:=0 to MAX_MEM_BOX-1 do
    begin
      SL.Clear;
      SL.Add(IntToStr(CharMinMaxTab[i].Left));
      SL.Add(IntToStr(CharMinMaxTab[i].Top));
      SL.Add(IntToStr(CharMinMaxTab[i].Right));
      SL.Add(IntToStr(CharMinMaxTab[i].Bottom));
      Ini.WriteString(SName,Format('MemBox%u',[i]),SL.DelimitedText);
    end;
  finally
    SL.Free;
  end;


  // zak³adka WEKTORY
  Ini.WriteInteger(SName,'Wek_Cnt',WekCntEdit.Value);
  FSetWekSerCount(WekCntEdit.Value);
  for i:=0 to WekCntEdit.Value-1 do
  begin
    n := Format('Wek_Item%u_Name',[i]);
    Ini.WriteString(SName,n,WekListBox.Items.Strings[i]);
    n := Format('Wek_Item%u_Color',[i]);
    Ini.WriteInteger(SName,n,integer(WekListBox.Items.Objects[i]));
  end;

end;

function TAnalogFrame.GetJSONObject: TJSONObject;
var
  i: integer;
  n: string;
  SL: TStringList;
  jObj: TJSONObject;
  jObj2: TJSONObject;
  jArr: TJSONArray;
  IntArr: TIntDynArr;
begin
  Result := TJSONObject.Create;

  // zak³adka WORD
  jObj := TJSONObject.Create;
  jObj.AddPair(CreateJsonPairInt('Col_Cnt', WordColCntEdit.Value));
  Result.AddPair('WordPage', jObj);

  // zak³adka CHART
  jObj := TJSONObject.Create;
  jObj.AddPair(CreateJsonPairInt('Chart_Cnt', SerCntEdit.Value));

  jArr := TJSONArray.Create;
  FSetChartSerCount(SerCntEdit.Value);
  for i := 0 to SerCntEdit.Value - 1 do
  begin
    jObj2 := TJSONObject.Create;
    jObj2.AddPair('Name', SeriesListBox.Items.Strings[i]);
    JSonAddPairColor(jObj2, 'Color', (SeriesListBox.Items.Objects[i] as TLineSeries).SeriesColor);
    jArr.AddElement(jObj2);
  end;
  jObj.AddPair('Signals', jArr);

  JSonAddPair(jObj, 'Auto', AutoXYBox.Checked);
  JSonAddPair(jObj, 'MinX', MinXEdit.Text);
  JSonAddPair(jObj, 'MaxX', MaxXEdit.Text);
  JSonAddPair(jObj, 'MinY', MinYEdit.Text);
  JSonAddPair(jObj, 'MaxY', MaxYEdit.Text);
  JSonAddPair(jObj, 'DataType', DataTypeBox.ItemIndex);
  JSonAddPair(jObj, 'SereiesType', SerieTypeBox.ItemIndex);
  JSonAddPair(jObj, 'DataSize', DataSizeBox.ItemIndex);
  JSonAddPair(jObj, 'RZ30Data', RZ30MemBox.Checked);
  JSonAddPair(jObj, 'Points', PointsBox.Checked);

  jArr := TJSONArray.Create;
  for i := 0 to MAX_MEM_BOX - 1 do
  begin
    jObj2 := CreateJsonObjectTRect(CharMinMaxTab[i]);
    jArr.AddElement(jObj2);
  end;
  jObj.AddPair('CharRanges', jArr);

  jObj2 := TJSONObject.Create;
  JSonAddPair(jObj2, LasPosPoint);
  JSonAddPair(jObj2, 'W', MeasurePanel.Width);
  JSonAddPair(jObj2, 'H', MeasurePanel.Height);
  SL := TStringList.Create;
  try
    SL.Assign(MeasureGrid.Cols[1]);
    SL.Delete(0);
    JSonAddPair(jObj2, 'Names', SL);
  finally
    SL.Free;
  end;

  SetLength(IntArr, MeasureGrid.ColCount - 1);
  for i := 0 to MeasureGrid.ColCount - 2 do
    IntArr[i] := MeasureGrid.ColWidths[i + 1];
  JSonAddPair(jObj2, 'ColWidth', IntArr);

  jObj.AddPair('MeasGrid', jObj2);
  Result.AddPair('Chart', jObj);

  FSetWekSerCount(WekCntEdit.Value);
  for i := 0 to WekCntEdit.Value - 1 do
  begin
    jObj2 := TJSONObject.Create;
    JSonAddPair(jObj2, 'Name', WekListBox.Items.Strings[i]);
    JSonAddPairColor(jObj2, 'Color', integer(WekListBox.Items.Objects[i]));
    jArr.AddElement(jObj2);
  end;
  jObj.AddPair('Signals', jArr);
  Result.AddPair('Vector', jObj);

end;

procedure TAnalogFrame.LoadFromIni(Ini : TMemIniFile; SName : string);
var
  i : integer;
  n : string;
  s : string;
  c : integer;
  SL : TStringList;
  Pt : TPoint;
begin
  // zak³adka Chart
  SL := TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.QuoteChar := '"';

    LasPosPoint.X:=-1;
    SerCntEdit.Value := Ini.ReadInteger(SName,'Chart_Cnt',4);
    WordColCntEdit.Value := Ini.ReadInteger(SName,'Grid_word_Col_Cnt',16);


    FSetChartSerCount(SerCntEdit.Value);

    for i:=0 to SerCntEdit.Value-1 do
    begin
      n := Format('Chart_Item%u_Name',[i]);
      s := Format('Sig_%u',[i]);
      s := Ini.ReadString(SName,n,s);
      (SeriesListBox.Items.Objects[i] as TLineSeries).Title := s;
      SeriesListBox.Items.Strings[i]:=s;

      n := Format('Chart_Item%u_Color',[i]);
      c := (SeriesListBox.Items.Objects[i] as TLineSeries).SeriesColor;
      c := Ini.ReadInteger(SName,n,c);
      (SeriesListBox.Items.Objects[i] as TLineSeries).SeriesColor := c;
    end;
    AutoXYBox.Checked := Ini.ReadBool(SName,'Chart_Auto',AutoXYBox.Checked);
    MinXEdit.Text := Ini.ReadString(SName,'Chart_MinX',MinXEdit.Text);
    MaxXEdit.Text := Ini.ReadString(SName,'Chart_MaxX',MaxXEdit.Text);
    MinYEdit.Text := Ini.ReadString(SName,'Chart_MinY',MinYEdit.Text);
    MaxYEdit.Text := Ini.ReadString(SName,'Chart_MaxY',MaxYEdit.Text);

    for i:=0 to MAX_MEM_BOX-1 do
    begin
      S := Ini.ReadString(SName,Format('MemBox%u',[i]),'');
      if s<>'' then
      begin
        SL.DelimitedText :=s;
        if Sl.Count>=4 then
        begin
          CharMinMaxTab[i].Left := StrToInt(SL.Strings[0]);
          CharMinMaxTab[i].Top := StrToInt(SL.Strings[1]);
          CharMinMaxTab[i].Right := StrToInt(SL.Strings[2]);
          CharMinMaxTab[i].Bottom := StrToInt(SL.Strings[3]);
        end;
      end;
    end;
    MakeMinMaxBoxHints;


    DataTypeBox.ItemIndex  := Ini.ReadInteger(SName,'Chart_DataType',DataTypeBox.ItemIndex);
    SerieTypeBox.ItemIndex := Ini.ReadInteger(SName,'Chart_SereiesType',SerieTypeBox.ItemIndex);
    DataSizeBox.ItemIndex  := Ini.ReadInteger(SName,'Chart_DataSize',DataSizeBox.ItemIndex);
    RZ30MemBox.Checked     := Ini.ReadBool(SName,'Chart_RZ30Data',RZ30MemBox.Checked);
    PointsBox.Checked      := Ini.ReadBool(SName,'Chart_Points',PointsBox.Checked);

    SL.DelimitedText := Ini.ReadString(SName,'MeasGrid_SortedNames','');
    SL.Insert(0,'Nazwa');
    if MeasureGrid.RowCount<SL.Count then MeasureGrid.RowCount:=SL.Count;
    MeasureGrid.Cols[1].Assign(SL);

    SL.DelimitedText := Ini.ReadString(SName,'MeasGrid_ColWidth','');
    if MeasureGrid.ColCount<SL.Count+1 then MeasureGrid.ColCount:=SL.Count+1;
    for i:=0 to SL.Count-1 do
    begin
      MeasureGrid.ColWidths[i+1] := StrToInt(SL.Strings[i]);
    end;

    SL.DelimitedText := Ini.ReadString(SName,'MeasGrid_Pos','');
    if Sl.Count>=4 then
    begin
      Pt.X   := StrToInt(Sl.Strings[0]);
      Pt.Y   := StrToInt(Sl.Strings[1]);
      MeasurePanel.Width := StrToInt(Sl.Strings[2]);
      MeasurePanel.Height:= StrToInt(Sl.Strings[3]);
      LasPosPoint := Pt;
    end;


    // zak³adka WEKTORY
    WekCntEdit.Value := Ini.ReadInteger(SName,'Wek_Cnt',4);
    FSetWekSerCount(WekCntEdit.Value);

    for i:=0 to WekCntEdit.Value-1 do
    begin
      n := Format('Wek_Item%u_Name',[i]);
      s := WekListBox.Items.Strings[i];
      s := Ini.ReadString(SName,n,s);
      WekListBox.Items.Strings[i] := s;

      n := Format('Wek_Item%u_Color',[i]);
      c := integer(WekListBox.Items.Objects[i]);
      c := Ini.ReadInteger(SName,n,c);
      WekListBox.Items.Objects[i] := pointer(c);
    end;
    DrawWekChart;
  finally
    SL.Free;
  end;
end;

procedure TAnalogFrame.MakeMinMaxBoxHints;
  function BuildHint(const R:TRect): string;
  begin
    Result := Format('Xmin=%d Xmax=%d Ymin=%d Ymax=%d',[R.Left,R.Right,R.Bottom,R.Top]);
  end;
begin
  SaveM1Btn.Hint := BuildHint(CharMinMaxTab[0]);
  RestoreM1Btn.Hint := SaveM1Btn.Hint;

  SaveM2Btn.Hint := BuildHint(CharMinMaxTab[1]);
  RestoreM2Btn.Hint := SaveM2Btn.Hint;

  SaveM3Btn.Hint := BuildHint(CharMinMaxTab[2]);
  RestoreM3Btn.Hint := SaveM3Btn.Hint;
end;

procedure TAnalogFrame.doParamVisible(vis : boolean);
begin
  WordGridPanel.Visible := vis;
end;

procedure TAnalogFrame.CopyToStringList(SL : TStrings);
var
  Gr    : TStringGrid;
  N     : integer;
  i     : integer;
  j     : integer;
  S1    : TStringList;
begin
  Gr := nil;
  N  := 0;
  case ShowTypePageCtrl.ActivePageIndex of
  0 : begin Gr := WordGrid;    N := 16; end;
  1 : begin Gr := DWordGrid;   N := 8; end;
  2 : begin Gr := FloatGrid;   N := 8; end;
  3 : begin Gr := DFloatGrid;  N := 8; end;
  4 : begin Gr := DspProgGrid; N := 8; end;
  5 : begin Gr := F1_15Grid;   N := 16; end;
  end;
  if Assigned(Gr) then
  begin
    S1    := TStringList.Create;
    try
      S1.Delimiter:=';';
      for j:=1 to Gr.RowCount-1 do
      begin
        S1.Clear;
        for i:=0 to N-1 do
        begin
          S1.Add(Gr.Cells[i+1,j]);
        end;
        SL.Add(S1.DelimitedText);
      end;
    finally
      S1.Free;
    end;
  end;
end;







end.
