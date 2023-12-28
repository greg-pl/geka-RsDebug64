unit MemFrameUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Math,
  Grids, ComCtrls, TeEngine, Series, StdCtrls, Spin, CheckLst, TeeProcs, IniFiles,
  Chart, ExtCtrls, Menus, Buttons,
  CommonDef,
  ArrowCha, VclTee.TeeGDIPlus,
  System.JSON,
  JSonUtils;

const
  MAX_MEM_BOX = 3;

type
  TToBin = function(MemName: string; Mem: pbyte; Size: integer; TypeSign: char; Val: OleVariant): integer of object;
  TToValue = function(MemName: string; Buf: pbyte; TypeSign: char; var Val: OleVariant): integer of object;
  TOntxtToInt = function(Txt: string): integer of object;

  TMemFrame = class(TFrame)
    ShowTypePageCtrl: TPageControl;
    ByteSheet: TTabSheet;
    WordSheet: TTabSheet;
    FloatSheet: TTabSheet;
    DWordSheet: TTabSheet;
    DspProgSheet: TTabSheet;
    F1_15Sheet: TTabSheet;
    ByteGrid: TStringGrid;
    WordGRid: TStringGrid;
    DWordGrid: TStringGrid;
    FloatGrid: TStringGrid;
    DspProgGrid: TStringGrid;
    F1_15Grid: TStringGrid;
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
    ByteGridPanel: TPanel;
    Label4: TLabel;
    ByteColCntEdit: TSpinEdit;
    Panel6: TPanel;
    procedure GridDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ByteGridSelectCell(Sender: TObject; ACol, ARow: integer; var CanSelect: Boolean);
    procedure ByteGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
    procedure ByteSheetShow(Sender: TObject);
    procedure WordSheetShow(Sender: TObject);
    procedure WordGRidSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
    procedure DWordGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
    procedure DWordSheetShow(Sender: TObject);
    procedure FloatSheetShow(Sender: TObject);
    procedure DspProgSheetShow(Sender: TObject);
    procedure FloatGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
    procedure F1_15SheetShow(Sender: TObject);
    procedure F1_15GridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
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
    procedure GridGetEditText(Sender: TObject; ACol, ARow: integer; var Value: String);
    procedure DFloatSheetShow(Sender: TObject);
    procedure DFloatGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
    procedure AllOnItemClick(Sender: TObject);
    procedure AllOffItemClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure MeasurePanelEndDock(Sender, Target: TObject; X, Y: integer);
    procedure Button2Click(Sender: TObject);
    procedure SaveM1BtnClick(Sender: TObject);
    procedure RestoreM1BtnClick(Sender: TObject);
    procedure WordColCntEditChange(Sender: TObject);
    procedure ByteColCntEditChange(Sender: TObject);
  private
    FMemBufSize: cardinal;
    FSrcAdr: cardinal;
    SecoundTime: Boolean;
    EditCellMem: string;
    FOnToBin: TToBin;
    FOnToValue: TToValue;
    FRegisterSize: integer;
    LasPosPoint: TPoint;

    procedure FSetSize(ASize: cardinal);
    procedure FSetSrcAdr(ASrcAdr: cardinal);

    function GetState(n: integer; Size: byte): TCellState;
    procedure FSetChartSerCount(AChartSerCount: integer);
    function FGetChartSerCount: integer;
    procedure FSetWekSerCount(cnt: integer);
    procedure FillMeasureGridValues;
    procedure FillMeasureGridNames;

    procedure SetWord(n: integer; V: Word);
    procedure SetDWord(n: integer; V: cardinal);
    procedure SetSingle(n: integer; V: Single);
    function GetSingle(n: integer): Single;
    function GetDouble(n: integer): Double;
    procedure SetDSingle(n: integer; V: Single);
    function GetDSingle(n: integer): Single;
    function GetMulti(var n: cardinal): Double;
    function FirstColTxt(w: cardinal): string;
    function LiczFirstRow(w: real): integer;
    procedure DrawWekChart;

    function HexToInt(s: string; var Ok: Boolean): cardinal;
    function FloatToF1_15(w: real): Word;
    function F1_15ToFloat(w: Word): real;
    function GetDWord(n: integer): cardinal;
    function GetWord(n: integer): Word;
    function GetByte(n: integer): byte;
    procedure SetByte(n: integer; B: byte);
    function FGetActivPage: integer;
    procedure FSetActivPage(APageNr: integer);
    procedure FSetRegisterSize(ARegisterSize: integer);
    function ReadMinMaxBox(var R: TRect): Boolean;
    procedure SetMinMaxBox(const R: TRect);
    procedure ShowMinMaxBox(const R: TRect);
    procedure MakeMinMaxBoxHints;
  protected
    function GetSeria(n: integer): string;
    function LiczFirstCol(w: integer): cardinal;
    function GetWektor(n: integer): string;
    procedure AddSeria(s: string);
    procedure AddWektor(s: string);
    property ChartSerCount: integer read FGetChartSerCount write FSetChartSerCount;
  public
    MemState: array of TCellState;
    MemBuf: array of byte;
    MemBufCopy: array of byte;
    MemTypeStr: String;

    CharMinMaxTab: array [0 .. MAX_MEM_BOX - 1] of TRect;

    property OnToBin: TToBin read FOnToBin write FOnToBin;
    property OnToValue: TToValue read FOnToValue write FOnToValue;

    property SrcAdr: cardinal read FSrcAdr write FSetSrcAdr;
    property MemSize: cardinal read FMemBufSize write FSetSize;
    procedure PaintActivPage;
    procedure SetNewData;
    procedure ClrData;
    procedure FillZero;
    procedure FillOnes;
    procedure Fill(Val: byte);
    property ActivPage: integer read FGetActivPage write FSetActivPage;
    property RegisterSize: integer read FRegisterSize write FSetRegisterSize;

    procedure SaveToIni(Ini: TMemIniFile; SName: string);
    function GetJSONObject: TJSONObject;

    procedure LoadFromIni(Ini: TMemIniFile; SName: string);
    procedure CopyToStringList(SL: TStrings);
    procedure doParamVisible(vis: Boolean);
  end;

implementation

uses
  Types;

{$R *.dfm}

const
  DIRST_COL_WIDTH = 78;

function TMemFrame.FGetActivPage: integer;
begin
  Result := ShowTypePageCtrl.ActivePageIndex;
end;

procedure TMemFrame.FSetActivPage(APageNr: integer);
begin
  if APageNr >= ShowTypePageCtrl.PageCount then
    APageNr := 0;
  ShowTypePageCtrl.ActivePage := ShowTypePageCtrl.Pages[APageNr];
end;

procedure TMemFrame.FSetRegisterSize(ARegisterSize: integer);
begin
  FRegisterSize := ARegisterSize;
  PaintActivPage;
end;

function TMemFrame.HexToInt(s: string; var Ok: Boolean): cardinal;
var
  n: int64;
begin
  n := 0;
  Ok := true;
  while s <> '' do
  begin
    if (s[1] >= '0') and (s[1] <= '9') then
      n := 16 * n + (ord(s[1]) - ord('0'))
    else if (upcase(s[1]) >= 'A') and (upcase(s[1]) <= 'F') then
      n := 16 * n + (ord(upcase(s[1])) - ord('A') + 10)
    else
      Ok := false;
    s := copy(s, 2, length(s) - 1);
  end;
  Result := cardinal(n);
end;

function TMemFrame.GetByte(n: integer): byte;
var
  Val: OleVariant;
begin
  if FOnToValue(MemTypeStr, @MemBuf[n], 'B', Val) = 0 then
  begin
    Result := Val;
  end
  else
    raise exception.Create('Bl�d konwersji do liczby');
end;

procedure TMemFrame.SetByte(n: integer; B: byte);
begin
  FOnToBin(MemTypeStr, @MemBuf[n], 1, 'B', B);
end;

function TMemFrame.GetWord(n: integer): Word;
var
  Val: OleVariant;
begin
  if FOnToValue(MemTypeStr, @MemBuf[n], 'W', Val) = 0 then
  begin
    Result := Val;
  end
  else
    raise exception.Create('Bl�d konwersji do liczby');
end;

procedure TMemFrame.SetWord(n: integer; V: Word);
begin
  FOnToBin(MemTypeStr, @MemBuf[n], 2, 'W', V);
end;

function TMemFrame.GetDWord(n: integer): cardinal;
var
  Val: OleVariant;
begin
  if FOnToValue(MemTypeStr, @MemBuf[n], 'D', Val) = 0 then
  begin
    Result := Val;
  end
  else
    raise exception.Create('Bl�d konwersji do liczby');
end;

procedure TMemFrame.SetDWord(n: integer; V: cardinal);
begin
  FOnToBin(MemTypeStr, @MemBuf[n], 4, 'D', V);
end;

procedure TMemFrame.SetDSingle(n: integer; V: Single);
begin
  FOnToBin(MemTypeStr, @MemBuf[n], 4, 'G', V);
end;

function TMemFrame.GetDSingle(n: integer): Single;
var
  Val: OleVariant;
begin
  if FOnToValue(MemTypeStr, @MemBuf[n], 'G', Val) = 0 then
  begin
    Result := Val;
  end
  else
    raise exception.Create('Bl�d konwersji do liczby');
end;

procedure TMemFrame.SetSingle(n: integer; V: Single);
begin
  FOnToBin(MemTypeStr, @MemBuf[n], 4, 'F', V);
end;

function TMemFrame.GetSingle(n: integer): Single;
var
  Val: OleVariant;
begin
  if FOnToValue(MemTypeStr, @MemBuf[n], 'F', Val) = 0 then
  begin
    Result := Val;
  end
  else
    raise exception.Create('Bl�d konwersji do liczby');
end;

function TMemFrame.GetDouble(n: integer): Double;
var
  Val: OleVariant;
begin
  if FOnToValue(MemTypeStr, @MemBuf[n], 'E', Val) = 0 then
  begin
    Result := Val;
  end
  else
    raise exception.Create('Bl�d konwersji do liczby');
end;

function TMemFrame.GetMulti(var n: cardinal): Double;
begin
  Result := 0;
  if RZ30MemBox.Checked then
  begin
    Result := SmallInt(GetWord(n));
    inc(n, 2);
  end
  else
  begin
    case DataTypeBox.ItemIndex of
      0:
        begin
          case DataSizeBox.ItemIndex of
            0:
              begin
                Result := ShortInt(MemBuf[n]);
                inc(n, 1);
              end;
            1:
              begin
                Result := SmallInt(GetWord(n));
                inc(n, 2);
              end;
            2:
              begin
                Result := integer(GetDWord(n));
                inc(n, 4);
              end;
          else
            inc(n, 2);
          end;
        end;
      1:
        begin
          case DataSizeBox.ItemIndex of
            0:
              begin
                Result := MemBuf[n];
                inc(n, 1);
              end;
            1:
              begin
                Result := GetWord(n);
                inc(n, 2);
              end;
            2:
              begin
                Result := GetDWord(n);
                inc(n, 4);
              end;
          else
            inc(n, 2);
          end;
        end;
      2:
        begin // Float
          Result := GetSingle(n);
          inc(n, 4);
        end;
      3:
        begin // Double
          Result := GetDouble(n);
          inc(n, 8);

        end;
    end;
  end;
end;

function TMemFrame.GetState(n: integer; Size: byte): TCellState;
var
  i: integer;
begin
  Result := csEmpty;
  for i := 0 to Size - 1 do
  begin
    if n + i < length(MemState) then
      if MemState[n + i] > Result then
        Result := MemState[n + i];
  end;
end;

procedure TMemFrame.FSetSize(ASize: cardinal);
begin
  if RegisterSize = 0 then
    RegisterSize := 1;
  if FMemBufSize <> ASize then
  begin
    FMemBufSize := ASize;
    SetLength(MemState, FMemBufSize);
    SetLength(MemBuf, FMemBufSize);
    SetLength(MemBufCopy, FMemBufSize);
  end;
  PaintActivPage;
end;

procedure TMemFrame.FSetSrcAdr(ASrcAdr: cardinal);
begin
  FSrcAdr := ASrcAdr;
  PaintActivPage;
end;

procedure TMemFrame.PaintActivPage;
begin
  if ShowTypePageCtrl.ActivePage <> nil then
  begin
    if Assigned(ShowTypePageCtrl.ActivePage.OnShow) then
    begin
      ShowTypePageCtrl.ActivePage.OnShow(self);
    end;
  end;
end;

procedure TMemFrame.SetNewData;
var
  i: integer;
begin
  for i := 0 to length(MemState) - 1 do
  begin
    if MemBuf[i] = MemBufCopy[i] then
      MemState[i] := csFull
    else
      MemState[i] := csChg;
    MemBufCopy[i] := MemBuf[i];
  end;
  PaintActivPage;
end;

procedure TMemFrame.ClrData;
var
  i: integer;
begin
  for i := 0 to length(MemState) - 1 do
  begin
    MemState[i] := csEmpty;
  end;
  PaintActivPage;
end;

procedure TMemFrame.Fill(Val: byte);
var
  i: integer;
begin
  for i := 0 to length(MemState) - 1 do
  begin
    if MemBuf[i] <> Val then
    begin
      MemState[i] := csModify;
      MemBuf[i] := Val;
    end
    else
      MemState[i] := csFull;
  end;
  PaintActivPage;
end;

procedure TMemFrame.FillZero;
begin
  Fill(0);
end;

procedure TMemFrame.FillOnes;
begin
  Fill($FF);
end;

function TMemFrame.FloatToF1_15(w: real): Word;
var
  C: integer;
  n: SmallInt;
begin
  if abs(w) > 1 then
    Raise exception.Create('1.15 format error');
  C := Round(w * $8000 + 0.5);
  if C = $8000 then
    C := $7FFF;
  n := C;
  Result := Word(n);
end;

function TMemFrame.F1_15ToFloat(w: Word): real;
begin
  Result := SmallInt(w);
  Result := Result / 32768;
end;

procedure TMemFrame.GridDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
var
  s: string;
  CellSt: TCellState;
  Grid: TStringGrid;
  n: integer;
begin
  Grid := Sender as TStringGrid;
  Grid.Canvas.Font.Name := 'Courier';

  if (ACol = 0) or (ARow = 0) then
    Grid.Canvas.Brush.Color := clBtnFace
  else if not(gdFocused in State) then
    Grid.Canvas.Brush.Color := clWindow
  else
    Grid.Canvas.Brush.Color := clHighlight;

  if not(gdFocused in State) then
    Grid.Canvas.Font.Color := clBlack
  else
    Grid.Canvas.Font.Color := clWhite;

  Grid.Canvas.Font.Style := [];
  s := Grid.Cells[ACol, ARow];

  if (ACol > 0) and (ARow > 0) then
  begin
    CellSt := csEmpty;
    if Sender = ByteGrid then
    begin
      n := (ByteGrid.ColCount - 2) * (ARow - 1) + (ACol - 1);
      CellSt := GetState(n, 1);
      if ACol = ByteGrid.ColCount - 1 then // kolumna ASCII
      begin
        if CellSt <> csEmpty then
          CellSt := csFull;
      end
    end
    else if Sender = F1_15Grid then
    begin
      n := 2 * (16 * (ARow - 1) + (ACol - 1));
      CellSt := GetState(n, 2);
    end
    else if Sender = WordGRid then
    begin
      n := 2 * ((WordGRid.ColCount - 1) * (ARow - 1) + (ACol - 1));
      CellSt := GetState(n, 2);
    end
    else if (Sender = DWordGrid) or (Sender = FloatGrid) or (Sender = DFloatGrid) or (Sender = DspProgGrid) then
    begin
      n := 4 * (8 * (ARow - 1) + (ACol - 1));
      CellSt := GetState(n, 4);
    end;

    case CellSt of
      csEmpty:
        begin
          s := '';
        end;
      csFull:
        ;
      csModify:
        begin
          Grid.Canvas.Font.Color := clBlue;
          Grid.Canvas.Font.Style := [fsBold];
        end;
      csChg:
        begin
          Grid.Canvas.Font.Color := clFuchsia; // Lime;
          Grid.Canvas.Font.Style := [fsBold];
        end;
      csBad:
        begin
          Grid.Canvas.Font.Color := clRed;
          Grid.Canvas.Font.Style := [fsBold];
        end;
    end;
  end;
  Grid.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, s);
end;

procedure TMemFrame.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  k: Word;
  Grid: TStringGrid;
begin
  Grid := Sender as TStringGrid;
  k := Key;
  Key := 0;
  case k of
    VK_RETURN:
      begin
        if Grid.Col = Grid.ColCount - 1 then
        begin
          Grid.Col := 1;
          if Grid.Row = Grid.RowCount - 1 then
            Grid.Row := 1
          else
            Grid.Row := Grid.Row + 1;
        end
        else
          Grid.Col := Grid.Col + 1;
        Grid.EditorMode := false;
      end;
    27:
      begin
        Grid.Cells[Grid.Col, Grid.Row] := EditCellMem;
        Grid.EditorMode := false;
      end;
  else
    Key := k;
  end;
end;

procedure TMemFrame.GridGetEditText(Sender: TObject; ACol, ARow: integer; var Value: String);
begin
  EditCellMem := (Sender as TStringGrid).Cells[ACol, ARow];
end;

function TMemFrame.LiczFirstCol(w: integer): cardinal;
begin
  Result := trunc(w / RegisterSize);
end;

function TMemFrame.FirstColTxt(w: cardinal): string;
begin
  Result := '"' + IntToHex(w shr 16, 4) + ' ' + IntToHex(w and $FFFF, 4) + '"';
end;

function TMemFrame.LiczFirstRow(w: real): integer;
begin
  Result := trunc(w / RegisterSize);
end;


// ------------------ byte GRID ------------------------------------------

procedure TMemFrame.ByteColCntEditChange(Sender: TObject);
begin
  ByteSheetShow(nil);
end;

procedure TMemFrame.ByteSheetShow(Sender: TObject);
var
  i: cardinal;
  X, Y: integer;
  a: byte;
  s1: string;
  NN: integer;
begin
  NN := ByteColCntEdit.Value;
  ByteGrid.RowCount := 1 + (FMemBufSize + NN - 1) div NN;
  ByteGrid.ColCount := NN + 2;
  ByteGrid.Cells[0, 0] := MemTypeStr;
  ByteGrid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 1 to NN do
    ByteGrid.ColWidths[i] := 21;
  ByteGrid.ColWidths[NN + 1] := 8 * NN + 7;

  for i := 0 to NN - 1 do
  begin
    ByteGrid.Cells[i + 1, 0] := IntToHex(LiczFirstRow(i), 2);
  end;
  ByteGrid.Cells[NN + 1, 0] := 'ASCII';

  if Assigned(FOnToValue) then
  begin
    Y := 0;
    if FMemBufSize > 0 then
    begin
      for i := 0 to FMemBufSize - 1 do
      begin
        X := i mod NN;
        Y := i div NN;
        if X = 0 then
        begin
          ByteGrid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
          s1 := '';
        end;
        a := GetByte(i);
        ByteGrid.Cells[X + 1, Y + 1] := IntToHex(a, 2);
        if a < $20 then
          s1 := s1 + '.'
        else
          s1 := s1 + char(a);
        if X = NN - 1 then
        begin
          ByteGrid.Cells[NN + 1, Y + 1] := s1;
        end;
      end;
      ByteGrid.Cells[NN + 1, Y + 1] := s1;
    end;
    ByteGrid.Refresh;
  end;
end;

procedure TMemFrame.ByteGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
  k: TCellState;
  s: string;
  Ok: Boolean;
  V: integer;
  n: integer;
begin
  if Assigned(FOnToBin) then
  begin
    V := HexToInt(Value, Ok);
    n := (ByteGrid.ColCount - 2) * (ARow - 1) + (ACol - 1);
    if (V < $100) and Ok then
    begin
      k := MemState[n];
      if GetByte(n) <> V then
      begin
        SetByte(n, V);
        k := csModify;
      end;
      if not(ByteGrid.EditorMode) then
        ByteGrid.Cells[ACol, ARow] := IntToHex(V, 2);
      s := ByteGrid.Cells[ByteGrid.ColCount - 1, ARow];
      if V < $20 then
        V := ord('.');
      s[ACol] := chr(V);
      ByteGrid.Cells[ByteGrid.ColCount - 1, ARow] := s;
    end
    else
      k := csBad;
    MemState[n] := k;
    if (length(Value) = 2) and ByteGrid.EditorMode then
      ByteGrid.EditorMode := false;
    ByteGrid.Refresh;
  end;
end;

procedure TMemFrame.ByteGridSelectCell(Sender: TObject; ACol, ARow: integer; var CanSelect: Boolean);
begin
  CanSelect := (ACol <> 17);
end;

// ------------------ WORD GRID ------------------------------------------
procedure TMemFrame.WordColCntEditChange(Sender: TObject);
begin
  WordSheetShow(nil);
end;

procedure TMemFrame.WordSheetShow(Sender: TObject);
var
  i: cardinal;
  X, Y: integer;
  Val: OleVariant;
  a: Word;
  NN: integer;
  NN2: integer;
begin
  NN := WordColCntEdit.Value;
  NN2 := 2 * NN;
  WordGRid.RowCount := 1 + (FMemBufSize + NN2 - 1) div NN2;
  WordGRid.ColCount := 1 + NN;

  WordGRid.Cells[0, 0] := MemTypeStr;
  WordGRid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 0 to NN - 1 do
  begin
    WordGRid.Cells[i + 1, 0] := ' +' + IntToHex(LiczFirstRow(i * 2), 2);
  end;
  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i < FMemBufSize do
    begin
      X := (i mod NN2) div 2;
      Y := i div NN2;
      if X = 0 then
        WordGRid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
      if FOnToValue(MemTypeStr, @MemBuf[i], 'W', Val) = 0 then
      begin
        a := Val;
        WordGRid.Cells[X + 1, Y + 1] := IntToHex(a, 4)
      end;
      inc(i, 2);
    end;
  end;
  WordGRid.Refresh;
end;

procedure TMemFrame.WordGRidSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
  k: TCellState;
  Ok: Boolean;
  V: integer;
  n: integer;
begin
  V := HexToInt(Value, Ok);
  n := 2 * ((WordGRid.ColCount - 1) * (ARow - 1) + (ACol - 1));

  if (V < $10000) then
  begin
    if GetWord(n) <> V then
    begin
      SetWord(n, V);
      k := csModify;
    end
    else
      k := GetState(n, 2);
    if not(WordGRid.EditorMode) then
      WordGRid.Cells[ACol, ARow] := IntToHex(V, 4);
  end
  else
    k := csBad;
  MemState[n] := k;
  MemState[n + 1] := k;

  if (length(Value) = 4) and WordGRid.EditorMode then
    WordGRid.EditorMode := false
end;

// ------------------ DWORD GRID ------------------------------------------
procedure TMemFrame.DWordSheetShow(Sender: TObject);
var
  i: cardinal;
  X, Y: integer;
begin
  DWordGrid.RowCount := 1 + (FMemBufSize + 31) div 32;
  DWordGrid.Cells[0, 0] := MemTypeStr;
  DWordGrid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 0 to 7 do
  begin
    DWordGrid.Cells[i + 1, 0] := '     +' + IntToHex(LiczFirstRow(i * 4), 2);
  end;
  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i < FMemBufSize do
    begin
      X := (i mod 32) div 4;
      Y := i div 32;
      if X = 0 then
        DWordGrid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
      DWordGrid.Cells[X + 1, Y + 1] := IntToHex(GetDWord(i), 8);
      i := i + 4;
    end;
  end;
  DWordGrid.Refresh;
end;

procedure TMemFrame.DWordGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
  k: TCellState;
  Ok: Boolean;
  V: cardinal;
  n: integer;
begin
  V := HexToInt(Value, Ok);
  n := 4 * (8 * (ARow - 1) + (ACol - 1));
  Ok := true;
  if Ok then
  begin
    SetDWord(n, V);
    if not(DWordGrid.EditorMode) then
      DWordGrid.Cells[ACol, ARow] := IntToHex(V, 8);
    k := csModify;
  end
  else
    k := csBad;
  MemState[n] := k;
  MemState[n + 1] := k;
  MemState[n + 2] := k;
  MemState[n + 3] := k;

  if (length(Value) = 8) and DWordGrid.EditorMode then
    DWordGrid.EditorMode := false
end;

// ------------------ FLOAT GRID ------------------------------------------
procedure TMemFrame.FloatSheetShow(Sender: TObject);
var
  i: cardinal;
  X, Y: integer;
  s: string;
begin
  FloatGrid.RowCount := 1 + (FMemBufSize + 31) div 32;
  FloatGrid.Cells[0, 0] := MemTypeStr;
  FloatGrid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 0 to 7 do
    FloatGrid.Cells[i + 1, 0] := '     +' + IntToHex(LiczFirstRow(4 * i), 2);

  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i < FMemBufSize do
    begin
      X := (i mod 32) div 4;
      Y := i div 32;
      if X = 0 then
        FloatGrid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
      try
        s := Format('%.5f', [GetSingle(i)]);
      except
        s := '';
      end;
      FloatGrid.Cells[X + 1, Y + 1] := s;
      i := i + 4;
    end;
  end;
  FloatGrid.Refresh;
end;

procedure TMemFrame.FloatGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
  k: TCellState;
  Ok: Boolean;
  V: Single;
  n: integer;
begin
  try
    V := StrToFloat(Value);
    Ok := true;
  except
    Ok := false;
    V := 0;
  end;
  n := 4 * (8 * (ARow - 1) + (ACol - 1));

  if Ok then
  begin
    SetSingle(n, V);
    if not(FloatGrid.EditorMode) then
      FloatGrid.Cells[ACol, ARow] := Format('%.5f', [V]);
    k := csModify;
  end
  else
    k := csBad;
  MemState[n] := k;
  MemState[n + 1] := k;
  MemState[n + 2] := k;
  MemState[n + 3] := k;
end;

// ------------------ DFLOAT GRID ------------------------------------------
procedure TMemFrame.DFloatSheetShow(Sender: TObject);
var
  i: cardinal;
  X, Y: integer;
  s: string;
begin
  DFloatGrid.RowCount := 1 + (FMemBufSize + 31) div 32;
  DFloatGrid.Cells[0, 0] := MemTypeStr;
  DFloatGrid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 0 to 7 do
    DFloatGrid.Cells[i + 1, 0] := '     +' + IntToHex(LiczFirstRow(4 * i), 2);

  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i < FMemBufSize do
    begin
      X := (i mod 32) div 4;
      Y := i div 32;
      if X = 0 then
        DFloatGrid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
      try
        s := FloatToStrF(GetDSingle(i), ffGeneral, 3, 8);
      except
        s := '';
      end;
      DFloatGrid.Cells[X + 1, Y + 1] := s;
      i := i + 4;
    end;
  end;
  DFloatGrid.Refresh;
end;

procedure TMemFrame.DFloatGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
  k: TCellState;
  Ok: Boolean;
  V: Single;
  n: integer;
begin
  try
    V := StrToFloat(Value);
    Ok := true;
  except
    Ok := false;
    V := 0;
  end;
  n := 4 * (8 * (ARow - 1) + (ACol - 1));

  if Ok then
  begin
    SetDSingle(n, V);
    if not(DFloatGrid.EditorMode) then
      DFloatGrid.Cells[ACol, ARow] := FloatToStrF(V, ffGeneral, 3, 8);
    k := csModify;
  end
  else
    k := csBad;
  MemState[n] := k;
  MemState[n + 1] := k;
  MemState[n + 2] := k;
  MemState[n + 3] := k;
end;

// ------------------ DSPPROF GRID ------------------------------------------
procedure TMemFrame.DspProgSheetShow(Sender: TObject);
var
  i: cardinal;
  X, Y: integer;
  w, w1: cardinal;
  b1, b2, b3: byte;
begin
  DspProgGrid.RowCount := 1 + (FMemBufSize + 31) div 32;
  DspProgGrid.Cells[0, 0] := MemTypeStr;
  DspProgGrid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 0 to 7 do
    DspProgGrid.Cells[i + 1, 0] := ' +' + IntToHex(LiczFirstRow(4 * i), 2);

  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i < FMemBufSize do
    begin
      X := (i mod 32) div 4;
      Y := i div 32;
      if X = 0 then
        DspProgGrid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
      w := GetDWord(i);
      b1 := (w shr 24) and $FF;
      b2 := (w shr 8) and $FF;
      b3 := w and $FF;
      w1 := b1 or (b2 shl 8) or (b3 shl 16);
      DspProgGrid.Cells[X + 1, Y + 1] := IntToHex(w1, 6);
      i := i + 4;
    end;
  end;
  DspProgGrid.Refresh;
end;


// ------------------ F1_15 GRID ------------------------------------------

procedure TMemFrame.F1_15SheetShow(Sender: TObject);
var
  i: cardinal;
  X, Y: integer;
begin
  F1_15Grid.RowCount := 1 + (FMemBufSize + 31) div 32;
  F1_15Grid.Cells[0, 0] := MemTypeStr;
  F1_15Grid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 0 to 15 do
  begin
    F1_15Grid.Cells[i + 1, 0] := ' +' + IntToHex(LiczFirstRow(2 * i), 2);
  end;

  if Assigned(FOnToValue) then
  begin
    i := 0;
    while i < FMemBufSize do
    begin
      X := (i mod 32) div 2;
      Y := i div 32;
      if X = 0 then
        F1_15Grid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
      F1_15Grid.Cells[X + 1, Y + 1] := Format('%.5f', [F1_15ToFloat(GetWord(i))]);
      i := i + 2;
    end;
  end;
  F1_15Grid.Refresh;
end;

procedure TMemFrame.F1_15GridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
  k: TCellState;
  Ok: Boolean;
  V: Single;
  w: Word;
  n: integer;
begin
  try
    V := StrToFloat(Value);
    w := FloatToF1_15(V);
    Ok := true;
  except
    Ok := false;
    w := 0;
  end;
  n := 2 * (16 * (ARow - 1) + (ACol - 1));

  if Ok then
  begin
    SetWord(n, w);
    if not(F1_15Grid.EditorMode) then
    begin
      F1_15Grid.Cells[ACol, ARow] := Format('%.5f', [F1_15ToFloat(w)]);
    end;
    k := csModify;
  end
  else
    k := csBad;
  MemState[n] := k;
  MemState[n + 1] := k;
end;

// ------------------ CHART ------------------------------------------

procedure TMemFrame.AddSeria(s: string);
var
  SL: TStringList;
  LSer: TLineSeries;
  n: integer;
begin
  SL := TStringList.Create;
  SL.Delimiter := '|';
  SL.DelimitedText := s;
  if SL.Count >= 3 then
  begin
    LSer := TLineSeries.Create(self);
    LSer.Title := SL.Strings[0];
    LSer.SeriesColor := StrToInt(SL.Strings[1]);
    SeriesListBox.AddItem(SL.Strings[0], LSer);
    for n := 0 to 20 do
      LSer.AddXY(n, random(100));
    if SL.Strings[2] = '1' then
    begin
      LSer.ParentChart := MainChart;
      SeriesListBox.Checked[SeriesListBox.Count - 1] := true;
    end;
  end;
  SL.Free;
  SerCntEdit.Value := SeriesListBox.Count;
end;

function TMemFrame.GetSeria(n: integer): string;
var
  SL: TStringList;
  LSer: TLineSeries;
begin
  LSer := SeriesListBox.Items.Objects[n] as TLineSeries;
  SL := TStringList.Create;
  SL.Delimiter := '|';
  SL.Add(LSer.Title);
  SL.Add(IntToStr(LSer.SeriesColor));
  if LSer.ParentChart = nil then
    SL.Add('0')
  else
    SL.Add('1');
  Result := SL.DelimitedText;
  SL.Free;
end;

procedure TMemFrame.SerCntEditChange(Sender: TObject);
begin
  FSetChartSerCount(SerCntEdit.Value);
end;

function TMemFrame.FGetChartSerCount: integer;
begin
  Result := SeriesListBox.Count;
end;

procedure TMemFrame.FSetChartSerCount(AChartSerCount: integer);
var
  Series: TLineSeries;
  n: integer;
  s: string;
begin
  while SeriesListBox.Count < AChartSerCount do
  begin
    Series := TLineSeries.Create(self);
    Series.ParentChart := MainChart;
    s := Format('Seria_%u', [SeriesListBox.Count]);
    Series.Title := s;
    SeriesListBox.AddItem(s, Series);
    SeriesListBox.Checked[SeriesListBox.Count - 1] := true;
    for n := 0 to 20 do
      Series.AddXY(n, random(100));
  end;
  while SeriesListBox.Count > AChartSerCount do
  begin
    SeriesListBox.Items.Objects[SeriesListBox.Count - 1].Free;
    SeriesListBox.Items.Delete(SeriesListBox.Count - 1);
  end;
end;

procedure TMemFrame.SeriesListBoxClickCheck(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to SeriesListBox.Count - 1 do
  begin
    if SeriesListBox.Checked[i] then
      (SeriesListBox.Items.Objects[i] as TLineSeries).ParentChart := MainChart
    else
      (SeriesListBox.Items.Objects[i] as TLineSeries).ParentChart := nil;
  end;
end;

procedure TMemFrame.AllOnItemClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to SeriesListBox.Count - 1 do
  begin
    SeriesListBox.Checked[i] := true;
  end;
  SeriesListBoxClickCheck(Sender);
end;

procedure TMemFrame.AllOffItemClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to SeriesListBox.Count - 1 do
  begin
    SeriesListBox.Checked[i] := false;
  end;
  SeriesListBoxClickCheck(Sender);
end;

procedure TMemFrame.EditNameItemClick(Sender: TObject);
var
  s: string;
begin
  s := SeriesListBox.Items.Strings[SeriesListBox.ItemIndex];
  if InputQuery('Zmiana nazwy', 'Podaj now� nazw�', s) then
  begin
    (SeriesListBox.Items.Objects[SeriesListBox.ItemIndex] as TLineSeries).Title := s;
    SeriesListBox.Items.Strings[SeriesListBox.ItemIndex] := s;
  end;
end;

procedure TMemFrame.EditKolorItemClick(Sender: TObject);
var
  Color: TColor;
begin
  Color := (SeriesListBox.Items.Objects[SeriesListBox.ItemIndex] as TLineSeries).SeriesColor;
  ColorDialog1.Color := Color;
  if ColorDialog1.Execute then
    (SeriesListBox.Items.Objects[SeriesListBox.ItemIndex] as TLineSeries).SeriesColor := ColorDialog1.Color;
end;

procedure TMemFrame.DrawCharBtnClick(Sender: TObject);
var
  n: cardinal;
  cnt: cardinal;
  f: Double;
  i: cardinal;
  k: cardinal;
  Nr: integer;
  wsk: cardinal;
  LSer: TLineSeries;
  w: Word;
begin
  n := SeriesListBox.Count;
  if n <> 0 then
  begin
    for i := 0 to n - 1 do
      (SeriesListBox.Items.Objects[i] as TLineSeries).Clear;

    wsk := 0;
    if RZ30MemBox.Checked then
    begin
      i := 0;
      repeat
        w := GetWord(wsk);
        if (w and $0001) = 0 then
          inc(wsk, 2);
        inc(i);
      until ((w and $0001) <> 0) or (i > 40);
    end;

    case SerieTypeBox.ItemIndex of
      0:
        begin // abcabcabc
          i := 0;
          while wsk < FMemBufSize do
          begin
            LSer := SeriesListBox.Items.Objects[i mod n] as TLineSeries;
            f := GetMulti(wsk);
            LSer.AddXY(i div n, f);
            inc(i);
          end;
        end;
      1:
        begin // aaabbbccc
          cnt := (FMemBufSize div n) div 2;
          i := 0;
          while wsk < FMemBufSize do
          begin
            f := GetMulti(wsk);
            k := i div cnt;
            Nr := i mod cnt;
            if k < n then
            begin
              LSer := SeriesListBox.Items.Objects[k] as TLineSeries;
              LSer.AddXY(Nr, f);
            end;
            inc(i);
          end;
        end;
    end;
  end;
end;

procedure TMemFrame.PointsBoxClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to SeriesListBox.Count - 1 do
  begin
    (SeriesListBox.Items.Objects[i] as TLineSeries).Pointer.Visible := PointsBox.Checked;
  end;
end;

procedure TMemFrame.RZ30MemBoxClick(Sender: TObject);
begin
  // DataTypeBox.ItemIndex:=0;
  // DataSizeBox.ItemIndex:=1;
  DataTypeBox.Enabled := not((Sender as TCheckBox).Checked);
  SerieTypeBox.Enabled := not((Sender as TCheckBox).Checked);
  DataSizeBox.Enabled := not((Sender as TCheckBox).Checked);
end;

procedure TMemFrame.ChartSheetShow(Sender: TObject);
begin
  DrawCharBtnClick(Sender);
  AutoXYBoxClick(Sender);
  if MeasurePanel.Visible then
    FillMeasureGridValues;
end;

function TMemFrame.ReadMinMaxBox(var R: TRect): Boolean;
begin
  Result := true;
  try
    R.Bottom := StrToInt(MinYEdit.Text);
  except
    Result := false;
  end;
  try
    R.Top := StrToInt(MaxYEdit.Text);
  except
    Result := false;
  end;

  try
    R.Left := StrToInt(MinXEdit.Text);
  except
    Result := false;
  end;

  try
    R.Right := StrToInt(MaxXEdit.Text);
  except
    Result := false;
  end;
end;

procedure TMemFrame.SetMinMaxBox(const R: TRect);
begin
  MainChart.LeftAxis.Minimum := R.Bottom;
  MainChart.LeftAxis.Maximum := R.Top;
  MainChart.BottomAxis.Minimum := R.Left;
  MainChart.BottomAxis.Maximum := R.Right;
  MainChart.LeftAxis.AutomaticMaximum := false;
  MainChart.LeftAxis.AutomaticMinimum := false;
  MainChart.BottomAxis.AutomaticMaximum := false;
  MainChart.BottomAxis.AutomaticMinimum := false;
end;

procedure TMemFrame.ShowMinMaxBox(const R: TRect);
begin
  MinYEdit.Text := IntToStr(R.Bottom);
  MaxYEdit.Text := IntToStr(R.Top);
  MinXEdit.Text := IntToStr(R.Left);
  MaxXEdit.Text := IntToStr(R.Right);
end;

procedure TMemFrame.AutoXYBoxClick(Sender: TObject);
var
  R: TRect;
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
    MainChart.LeftAxis.AutomaticMaximum := true;
    MainChart.LeftAxis.AutomaticMinimum := true;
    MainChart.BottomAxis.AutomaticMaximum := true;
    MainChart.BottomAxis.AutomaticMinimum := true;
  end;
end;

procedure TMemFrame.Button2Click(Sender: TObject);
begin
  MinYEdit.Text := IntToStr(Round(MainChart.LeftAxis.Minimum));
  MaxYEdit.Text := IntToStr(Round(MainChart.LeftAxis.Maximum));
  MinXEdit.Text := IntToStr(Round(MainChart.BottomAxis.Minimum));
  MaxXEdit.Text := IntToStr(Round(MainChart.BottomAxis.Maximum));
end;

procedure TMemFrame.SaveM1BtnClick(Sender: TObject);
var
  Nr: integer;
begin
  Nr := (Sender as TButton).Tag - 1;
  if (Nr >= 0) and (Nr < MAX_MEM_BOX) then
  begin
    ReadMinMaxBox(CharMinMaxTab[Nr]);
    MakeMinMaxBoxHints;
  end;
end;

procedure TMemFrame.RestoreM1BtnClick(Sender: TObject);
var
  Nr: integer;
begin
  Nr := (Sender as TButton).Tag - 1;
  if (Nr >= 0) and (Nr < MAX_MEM_BOX) then
  begin
    ShowMinMaxBox(CharMinMaxTab[Nr]);
    SetMinMaxBox(CharMinMaxTab[Nr]);
  end;
end;

procedure TMemFrame.Button1Click(Sender: TObject);
var
  R: TRect;
  PT: TPoint;
begin
  if not(MeasurePanel.Visible) then
  begin
    if LasPosPoint.X = -1 then
    begin
      PT.X := MainChart.Width div 3;
      PT.Y := MainChart.Height div 3;
      PT := MeasurePanel.Parent.ClientToScreen(PT);
      LasPosPoint := PT;
    end
    else
    begin
      PT := LasPosPoint;
      if PT.X > Screen.DesktopWidth then
        PT.X := Screen.DesktopWidth - 50;
      if PT.Y > Screen.DesktopHeight then
        PT.Y := Screen.DesktopHeight - 50;
    end;
    R := Bounds(PT.X, PT.Y, MeasurePanel.Width, MeasurePanel.Height);

    MeasurePanel.ManualFloat(R);
    MeasurePanel.Visible := true;
    FillMeasureGridNames;
  end;
  FillMeasureGridValues;
end;

procedure TMemFrame.FillMeasureGridValues;
  procedure GetMeasure(Sr: TLineSeries; var RMS: real; var RMZ: real; var Avr: real; var aMin: integer;
    var aMax: integer);
  var
    n: integer;
    i: integer;
    a: real;
    aa: integer;
    Buf: array of real;
  begin
    Avr := 0;
    RMS := 0;
    n := Sr.Count;
    SetLength(Buf, n);
    for i := 0 to n - 1 do
    begin
      Buf[i] := Sr.YValue[i];
    end;

    for i := 0 to n - 1 do
    begin
      a := Buf[i];
      aa := Round(a);
      if i = 0 then
      begin
        aMin := aa;
        aMax := aa;
      end
      else
      begin
        aMin := Min(aMin, aa);
        aMax := Max(aMax, aa);
      end;

      Avr := Avr + a;
      RMS := RMS + a * a;
    end;
    Avr := Avr / n;
    RMS := Sqrt(RMS / n);

    RMZ := 0;
    for i := 0 to n - 1 do
    begin
      a := Buf[i] - Avr;
      RMZ := RMZ + a * a;
    end;
    RMZ := Sqrt(RMZ / n);
  end;

  function FindRow(s: string): integer;
  var
    i: integer;
  begin
    Result := 0;
    for i := 1 to MeasureGrid.RowCount - 1 do
    begin
      if MeasureGrid.Cells[1, i] = s then
      begin
        Result := i;
        break;
      end;
    end;
  end;

var
  i: integer;
  n: integer;
  Sr: TLineSeries;
  RMS: real;
  RMZ: real;
  Avr: real;
  aMin: integer;
  aMax: integer;
  RR: real;
begin
  case DataSizeBox.ItemIndex of
    0:
      RR := 128;
    1:
      RR := 32768;
    2:
      RR := 32768.0 * 65536;
  else
    RR := 32768;
  end;
  if DataTypeBox.ItemIndex = 1 then
    RR := RR * 2;

  for i := 0 to SeriesListBox.Count - 1 do
  begin

    Sr := SeriesListBox.Items.Objects[i] as TLineSeries;
    n := FindRow(Sr.Title);
    GetMeasure(Sr, RMS, RMZ, Avr, aMin, aMax);
    MeasureGrid.Cells[2, n] := Format('%.2f', [RMS]);
    MeasureGrid.Cells[3, n] := Format('%7.5f', [100 * RMS / RR]);
    MeasureGrid.Cells[4, n] := Format('%.2f', [RMZ]);
    MeasureGrid.Cells[5, n] := Format('%7.5f', [100 * RMZ / RR]);

    MeasureGrid.Cells[6, n] := Format('%.2f', [Avr]);
    MeasureGrid.Cells[7, n] := Format('%7.5f', [100 * Avr / RR]);
    MeasureGrid.Cells[8, n] := IntToStr(aMin);
    MeasureGrid.Cells[9, n] := IntToStr(aMax);
    MeasureGrid.Cells[10, n] := IntToStr(aMax - aMin);
  end;
end;

procedure TMemFrame.FillMeasureGridNames;
var
  i, j: integer;
  Sr: TLineSeries;
  s: string;
  Fnd: Boolean;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    MeasureGrid.Rows[0].CommaText := 'lp Nazwa RMS RMS% RMS/AC RMS/AC% AVR AVR% MIN MAX MAX-MIN';
    MeasureGrid.RowCount := SeriesListBox.Count + 1;

    // skasowanie nie uzywanych nazw
    for j := 1 to MeasureGrid.RowCount - 1 do
    begin
      MeasureGrid.Cells[0, j] := IntToStr(j);
      s := MeasureGrid.Cells[1, j];
      if SL.IndexOf(s) = -1 then
      begin
        SL.Add(s);
        Fnd := false;
        for i := 0 to SeriesListBox.Count - 1 do
        begin
          Sr := SeriesListBox.Items.Objects[i] as TLineSeries;
          Fnd := Fnd or (Sr.Title = s);
        end;
        if not(Fnd) then
          MeasureGrid.Cells[1, j] := '';
      end
      else
        MeasureGrid.Cells[1, j] := '';
    end;

    // Wpisanie niewpisanych serii
    for i := 0 to SeriesListBox.Count - 1 do
    begin
      Sr := SeriesListBox.Items.Objects[i] as TLineSeries;
      Fnd := false;
      for j := 1 to MeasureGrid.RowCount - 1 do
      begin
        Fnd := Fnd or (Sr.Title = MeasureGrid.Cells[1, j]);
      end;
      if not(Fnd) then
      begin
        for j := 1 to MeasureGrid.RowCount - 1 do
        begin
          if MeasureGrid.Cells[1, j] = '' then
          begin
            MeasureGrid.Cells[1, j] := Sr.Title;
            break;
          end;
        end;
      end;
    end;
  finally
    SL.Free;
  end;
end;

procedure TMemFrame.MeasurePanelEndDock(Sender, Target: TObject; X, Y: integer);
begin
  LasPosPoint := Point(X, Y);
end;

// ------------------ WEKCHART ------------------------------------------
procedure TMemFrame.WekSheetShow(Sender: TObject);
begin
  DrawWekChart;
  if not(SecoundTime) then
  begin
    WekChart.TopAxis.Visible := true;
    WekChart.TopAxis.Automatic := false;
    WekChart.TopAxis.Minimum := -1.2;
    WekChart.TopAxis.Maximum := 1.2;

    WekChart.LeftAxis.Automatic := false;
    WekChart.LeftAxis.Minimum := -1.2;
    WekChart.LeftAxis.Maximum := 1.2;
    SecoundTime := true;
  end;
end;

procedure TMemFrame.DrawWekChart;
var
  i: integer;
  x1, y1: Double;
begin
  if FMemBufSize < cardinal(WekListBox.Count) * 2 then
    FSetSize(WekListBox.Count * 2);

  WekSeries.Clear;
  if Assigned(FOnToValue) then
  begin
    for i := 0 to WekListBox.Count - 1 do
    begin
      x1 := F1_15ToFloat(GetWord(4 * i + 0));
      y1 := F1_15ToFloat(GetWord(4 * i + 2));
      WekSeries.AddArrow(0, 0, x1, y1, WekListBox.Items[i], cardinal(WekListBox.Items.Objects[i]))
    end;
  end;
end;

procedure TMemFrame.AddWektor(s: string);
var
  SL: TStringList;
  n: integer;
begin
  SL := TStringList.Create;
  SL.Delimiter := '|';
  SL.DelimitedText := s;
  if SL.Count >= 2 then
  begin
    n := StrToInt(SL.Strings[1]);
    WekListBox.AddItem(SL.Strings[0], Pointer(n));
  end;
  SL.Free;
  WekCntEdit.Value := WekListBox.Count;
end;

function TMemFrame.GetWektor(n: integer): string;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  SL.Delimiter := '|';
  SL.Add(WekListBox.Items[n]);
  SL.Add(IntToStr(cardinal(WekListBox.Items.Objects[n])));
  Result := SL.DelimitedText;
  SL.Free;
end;

procedure TMemFrame.FSetWekSerCount(cnt: integer);
var
  s: string;
begin
  while WekListBox.Count < cnt do
  begin
    s := Format('Wektor_%u', [WekListBox.Count]);
    WekListBox.AddItem(s, Pointer(clBlack));
  end;
  while WekListBox.Count > cnt do
  begin
    WekListBox.Items.Delete(WekListBox.Count - 1);
  end;
  DrawWekChart;
end;

procedure TMemFrame.WekCntEditChange(Sender: TObject);
begin
  FSetWekSerCount(WekCntEdit.Value);
end;

procedure TMemFrame.Zmienazw1Click(Sender: TObject);
var
  s: string;
begin
  s := WekListBox.Items.Strings[WekListBox.ItemIndex];
  if InputQuery('Zmiana nazwy', 'Podaj now� nazw�', s) then
  begin
    WekListBox.Items.Strings[WekListBox.ItemIndex] := s;
  end;
  DrawWekChart;
end;

procedure TMemFrame.Zmiekolor1Click(Sender: TObject);
var
  Color: TColor;
begin
  Color := TColor(WekListBox.Items.Objects[WekListBox.ItemIndex]);
  ColorDialog1.Color := Color;
  if ColorDialog1.Execute then
    WekListBox.Items.Objects[WekListBox.ItemIndex] := Pointer(ColorDialog1.Color);
  DrawWekChart;
end;

procedure TMemFrame.SaveToIni(Ini: TMemIniFile; SName: string);
var
  i: integer;
  n: string;
  SL: TStringList;
begin
  // zak�adka CHART
  Ini.WriteInteger(SName, 'Chart_Cnt', SerCntEdit.Value);
  Ini.WriteInteger(SName, 'Grid_word_Col_Cnt', WordColCntEdit.Value);
  Ini.WriteInteger(SName, 'Grid_Byte_Col_Cnt', ByteColCntEdit.Value);

  FSetChartSerCount(SerCntEdit.Value);
  for i := 0 to SerCntEdit.Value - 1 do
  begin
    n := Format('Chart_Item%u_Name', [i]);
    Ini.WriteString(SName, n, SeriesListBox.Items.Strings[i]);
    n := Format('Chart_Item%u_Color', [i]);
    Ini.WriteInteger(SName, n, (SeriesListBox.Items.Objects[i] as TLineSeries).SeriesColor);
  end;
  Ini.WriteBool(SName, 'Chart_Auto', AutoXYBox.Checked);
  Ini.WriteString(SName, 'Chart_MinX', MinXEdit.Text);
  Ini.WriteString(SName, 'Chart_MaxX', MaxXEdit.Text);
  Ini.WriteString(SName, 'Chart_MinY', MinYEdit.Text);
  Ini.WriteString(SName, 'Chart_MaxY', MaxYEdit.Text);
  Ini.WriteInteger(SName, 'Chart_DataType', DataTypeBox.ItemIndex);
  Ini.WriteInteger(SName, 'Chart_SereiesType', SerieTypeBox.ItemIndex);
  Ini.WriteInteger(SName, 'Chart_DataSize', DataSizeBox.ItemIndex);
  Ini.WriteBool(SName, 'Chart_RZ30Data', RZ30MemBox.Checked);
  Ini.WriteBool(SName, 'Chart_Points', PointsBox.Checked);
  SL := TStringList.Create;
  try
    SL.Assign(MeasureGrid.Cols[1]);
    SL.Delete(0);
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    Ini.WriteString(SName, 'MeasGrid_SortedNames', SL.DelimitedText);
    SL.Clear;
    for i := 1 to MeasureGrid.ColCount - 1 do
    begin
      SL.Add(IntToStr(MeasureGrid.ColWidths[i]));
    end;
    Ini.WriteString(SName, 'MeasGrid_ColWidth', SL.DelimitedText);

    SL.Clear;
    SL.Add(IntToStr(LasPosPoint.X));
    SL.Add(IntToStr(LasPosPoint.Y));
    SL.Add(IntToStr(MeasurePanel.Width));
    SL.Add(IntToStr(MeasurePanel.Height));
    Ini.WriteString(SName, 'MeasGrid_Pos', SL.DelimitedText);
    for i := 0 to MAX_MEM_BOX - 1 do
    begin
      SL.Clear;
      SL.Add(IntToStr(CharMinMaxTab[i].Left));
      SL.Add(IntToStr(CharMinMaxTab[i].Top));
      SL.Add(IntToStr(CharMinMaxTab[i].Right));
      SL.Add(IntToStr(CharMinMaxTab[i].Bottom));
      Ini.WriteString(SName, Format('MemBox%u', [i]), SL.DelimitedText);
    end;
  finally
    SL.Free;
  end;

  // zak�adka WEKTORY
  Ini.WriteInteger(SName, 'Wek_Cnt', WekCntEdit.Value);
  FSetWekSerCount(WekCntEdit.Value);
  for i := 0 to WekCntEdit.Value - 1 do
  begin
    n := Format('Wek_Item%u_Name', [i]);
    Ini.WriteString(SName, n, WekListBox.Items.Strings[i]);
    n := Format('Wek_Item%u_Color', [i]);
    Ini.WriteInteger(SName, n, integer(WekListBox.Items.Objects[i]));
  end;

end;

function TMemFrame.GetJSONObject: TJSONObject;
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

  // zak�adka BYTE
  jObj := TJSONObject.Create;
  jObj.AddPair(CreateJsonPairInt('Col_Cnt', ByteColCntEdit.Value));
  Result.AddPair('BytePage', jObj);

  // zak�adka WORD
  jObj := TJSONObject.Create;
  jObj.AddPair(CreateJsonPairInt('Col_Cnt', WordColCntEdit.Value));
  Result.AddPair('WordPage', jObj);

  // zak�adka CHART
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

  // zak�adka WEKTORY
  jObj := TJSONObject.Create;
  jArr := TJSONArray.Create;

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

procedure TMemFrame.LoadFromIni(Ini: TMemIniFile; SName: string);
var
  i: integer;
  n: string;
  s: string;
  C: integer;
  SL: TStringList;
  PT: TPoint;
begin
  // zak�adka Chart
  SL := TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.QuoteChar := '"';

    LasPosPoint.X := -1;
    SerCntEdit.Value := Ini.ReadInteger(SName, 'Chart_Cnt', 4);
    WordColCntEdit.Value := Ini.ReadInteger(SName, 'Grid_word_Col_Cnt', 16);
    ByteColCntEdit.Value := Ini.ReadInteger(SName, 'Grid_Byte_Col_Cnt', 16);

    FSetChartSerCount(SerCntEdit.Value);

    for i := 0 to SerCntEdit.Value - 1 do
    begin
      n := Format('Chart_Item%u_Name', [i]);
      s := Format('Sig_%u', [i]);
      s := Ini.ReadString(SName, n, s);
      (SeriesListBox.Items.Objects[i] as TLineSeries).Title := s;
      SeriesListBox.Items.Strings[i] := s;

      n := Format('Chart_Item%u_Color', [i]);
      C := (SeriesListBox.Items.Objects[i] as TLineSeries).SeriesColor;
      C := Ini.ReadInteger(SName, n, C);
      (SeriesListBox.Items.Objects[i] as TLineSeries).SeriesColor := C;
    end;
    AutoXYBox.Checked := Ini.ReadBool(SName, 'Chart_Auto', AutoXYBox.Checked);
    MinXEdit.Text := Ini.ReadString(SName, 'Chart_MinX', MinXEdit.Text);
    MaxXEdit.Text := Ini.ReadString(SName, 'Chart_MaxX', MaxXEdit.Text);
    MinYEdit.Text := Ini.ReadString(SName, 'Chart_MinY', MinYEdit.Text);
    MaxYEdit.Text := Ini.ReadString(SName, 'Chart_MaxY', MaxYEdit.Text);

    for i := 0 to MAX_MEM_BOX - 1 do
    begin
      s := Ini.ReadString(SName, Format('MemBox%u', [i]), '');
      if s <> '' then
      begin
        SL.DelimitedText := s;
        if SL.Count >= 4 then
        begin
          CharMinMaxTab[i].Left := StrToInt(SL.Strings[0]);
          CharMinMaxTab[i].Top := StrToInt(SL.Strings[1]);
          CharMinMaxTab[i].Right := StrToInt(SL.Strings[2]);
          CharMinMaxTab[i].Bottom := StrToInt(SL.Strings[3]);
        end;
      end;
    end;
    MakeMinMaxBoxHints;

    DataTypeBox.ItemIndex := Ini.ReadInteger(SName, 'Chart_DataType', DataTypeBox.ItemIndex);
    SerieTypeBox.ItemIndex := Ini.ReadInteger(SName, 'Chart_SereiesType', SerieTypeBox.ItemIndex);
    DataSizeBox.ItemIndex := Ini.ReadInteger(SName, 'Chart_DataSize', DataSizeBox.ItemIndex);
    RZ30MemBox.Checked := Ini.ReadBool(SName, 'Chart_RZ30Data', RZ30MemBox.Checked);
    PointsBox.Checked := Ini.ReadBool(SName, 'Chart_Points', PointsBox.Checked);

    SL.DelimitedText := Ini.ReadString(SName, 'MeasGrid_SortedNames', '');
    SL.Insert(0, 'Nazwa');
    if MeasureGrid.RowCount < SL.Count then
      MeasureGrid.RowCount := SL.Count;
    MeasureGrid.Cols[1].Assign(SL);

    SL.DelimitedText := Ini.ReadString(SName, 'MeasGrid_ColWidth', '');
    if MeasureGrid.ColCount < SL.Count + 1 then
      MeasureGrid.ColCount := SL.Count + 1;
    for i := 0 to SL.Count - 1 do
    begin
      MeasureGrid.ColWidths[i + 1] := StrToInt(SL.Strings[i]);
    end;

    SL.DelimitedText := Ini.ReadString(SName, 'MeasGrid_Pos', '');
    if SL.Count >= 4 then
    begin
      PT.X := StrToInt(SL.Strings[0]);
      PT.Y := StrToInt(SL.Strings[1]);
      MeasurePanel.Width := StrToInt(SL.Strings[2]);
      MeasurePanel.Height := StrToInt(SL.Strings[3]);
      LasPosPoint := PT;
    end;

    // zak�adka WEKTORY
    WekCntEdit.Value := Ini.ReadInteger(SName, 'Wek_Cnt', 4);
    FSetWekSerCount(WekCntEdit.Value);

    for i := 0 to WekCntEdit.Value - 1 do
    begin
      n := Format('Wek_Item%u_Name', [i]);
      s := WekListBox.Items.Strings[i];
      s := Ini.ReadString(SName, n, s);
      WekListBox.Items.Strings[i] := s;

      n := Format('Wek_Item%u_Color', [i]);
      C := integer(WekListBox.Items.Objects[i]);
      C := Ini.ReadInteger(SName, n, C);
      WekListBox.Items.Objects[i] := Pointer(C);
    end;
    DrawWekChart;
  finally
    SL.Free;
  end;
end;

procedure TMemFrame.MakeMinMaxBoxHints;
  function BuildHint(const R: TRect): string;
  begin
    Result := Format('Xmin=%d Xmax=%d Ymin=%d Ymax=%d', [R.Left, R.Right, R.Bottom, R.Top]);
  end;

begin
  SaveM1Btn.Hint := BuildHint(CharMinMaxTab[0]);
  RestoreM1Btn.Hint := SaveM1Btn.Hint;

  SaveM2Btn.Hint := BuildHint(CharMinMaxTab[1]);
  RestoreM2Btn.Hint := SaveM2Btn.Hint;

  SaveM3Btn.Hint := BuildHint(CharMinMaxTab[2]);
  RestoreM3Btn.Hint := SaveM3Btn.Hint;
end;

procedure TMemFrame.doParamVisible(vis: Boolean);
begin
  WordGridPanel.Visible := vis;
  ByteGridPanel.Visible := vis;
end;

procedure TMemFrame.CopyToStringList(SL: TStrings);
var
  Gr: TStringGrid;
  n: integer;
  i: integer;
  j: integer;
  s1: TStringList;
begin
  Gr := nil;
  n := 0;
  case ShowTypePageCtrl.ActivePageIndex of
    0:
      begin
        Gr := ByteGrid;
        n := 16;
      end;
    1:
      begin
        Gr := WordGRid;
        n := 16;
      end;
    2:
      begin
        Gr := DWordGrid;
        n := 8;
      end;
    3:
      begin
        Gr := FloatGrid;
        n := 8;
      end;
    4:
      begin
        Gr := DFloatGrid;
        n := 8;
      end;
    5:
      begin
        Gr := DspProgGrid;
        n := 8;
      end;
    6:
      begin
        Gr := F1_15Grid;
        n := 16;
      end;
  end;
  if Assigned(Gr) then
  begin
    s1 := TStringList.Create;
    try
      s1.Delimiter := ';';
      for j := 1 to Gr.RowCount - 1 do
      begin
        s1.Clear;
        for i := 0 to n - 1 do
        begin
          s1.Add(Gr.Cells[i + 1, j]);
        end;
        SL.Add(s1.DelimitedText);
      end;
    finally
      s1.Free;
    end;
  end;
end;

end.
