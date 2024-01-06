unit MemFrameUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Math,
  Grids, ComCtrls, TeEngine, Series, StdCtrls, Spin, CheckLst, TeeProcs, IniFiles,
  Chart, ExtCtrls, Menus, Buttons,
  ArrowCha,
  VclTee.TeeGDIPlus,

  ToolsUnit,
  CommonDef,
  System.JSON,
  JSonUtils;

const
  MAX_MEM_BOX = 3;

type
  TOntxtToInt = function(Txt: string): integer of object;

  TChangeByteBuffer = class(TByteBuffer)
  private
    procedure SetChangeTab(n: integer; cnt: integer; st: TCellState);
  public
    BufCopy: array of byte;
    MemState: array of TCellState;
    procedure SetLen(len: integer); override;
    function GetState(n: integer; Size: byte): TCellState;
    procedure SetNewData;
    procedure ClrData;
    procedure Fill(Val: byte);

    procedure SetByte(n: integer; B: byte); override;
    procedure SetWord(n: integer; V: Word); override;
    procedure SetDWord(n: integer; V: cardinal); override;

    procedure SetError(n: integer; cnt: integer);

  end;

  TMemFrame = class(TFrame)
    ShowTypePageCtrl: TPageControl;
    ByteSheet: TTabSheet;
    WordSheet: TTabSheet;
    FloatSheet: TTabSheet;
    DWordSheet: TTabSheet;
    F1_15Sheet: TTabSheet;
    ByteGrid: TStringGrid;
    WordGRid: TStringGrid;
    DWordGrid: TStringGrid;
    FloatGrid: TStringGrid;
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
    WekListMenu: TPopupMenu;
    Zmiekolor1: TMenuItem;
    Zmienazw1: TMenuItem;
    Panel4: TPanel;
    MainChart: TChart;
    Panel5: TPanel;
    MinXEdit: TLabeledEdit;
    MaxXEdit: TLabeledEdit;
    MinYEdit: TLabeledEdit;
    MaxYEdit: TLabeledEdit;
    AutoXYBox: TCheckBox;
    DataTypeBox: TRadioGroup;
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
    procedure AutoXYBoxClick(Sender: TObject);
    procedure GridGetEditText(Sender: TObject; ACol, ARow: integer; var Value: String);
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
    FSrcAdr: cardinal;
    EditCellMem: string;
    FRegisterSize: integer;
    LasPosPoint: TPoint;
    ChartMinMaxTab: array [0 .. MAX_MEM_BOX - 1] of TRect;

    procedure FSetSize(ASize: cardinal);
    function FGetSize: cardinal;
    procedure FSetSrcAdr(ASrcAdr: cardinal);

    procedure FSetChartSerCount(AChartSerCount: integer);
    function FGetChartSerCount: integer;
    procedure FillMeasureGridValues;
    procedure FillMeasureGridNames;

    function GetMulti(var n: cardinal): Double;
    function FirstColTxt(w: cardinal): string;
    function LiczFirstRow(w: real): integer;

    function HexToInt(s: string; var Ok: Boolean): cardinal;
    function FloatToF1_15(w: real): Word;
    function F1_15ToFloat(w: Word): real;
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
    procedure AddSeria(s: string);
    property ChartSerCount: integer read FGetChartSerCount write FSetChartSerCount;
  public
    MemBuf: TChangeByteBuffer;

    MemTypeStr: String;


    procedure Init;
    procedure Done;
    procedure setByteOrder(ord : TByteOrder);


    property SrcAdr: cardinal read FSrcAdr write FSetSrcAdr;
    property MemSize: cardinal read FGetSize write FSetSize;
    procedure PaintActivPage;
    procedure SetNewData;
    procedure ClrData;
    procedure FillZero;
    procedure FillOnes;
    procedure Fill(Val: byte);
    property ActivPage: integer read FGetActivPage write FSetActivPage;
    property RegisterSize: integer read FRegisterSize write FSetRegisterSize;


    function GetJSONObject: TJSONBuilder;
    procedure LoadfromJson(jParent: TJSONLoader);

    procedure CopyToStringList(SL: TStrings);
    procedure doParamVisible(vis: Boolean);
  end;

implementation

uses
  Types;

{$R *.dfm}

procedure TChangeByteBuffer.SetLen(len: integer);
begin
  inherited;
  setlength(BufCopy, len);
  setlength(MemState, len);
end;

function TChangeByteBuffer.GetState(n: integer; Size: byte): TCellState;
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

procedure TChangeByteBuffer.SetNewData;
var
  i: integer;
begin
  for i := 0 to length(MemState) - 1 do
  begin
    if Buf[i] = BufCopy[i] then
      MemState[i] := csFull
    else
      MemState[i] := csChg;
    BufCopy[i] := Buf[i];
  end;
end;

procedure TChangeByteBuffer.ClrData;
var
  i: integer;
begin
  for i := 0 to len - 1 do
  begin
    MemState[i] := csEmpty;
  end;
end;

procedure TChangeByteBuffer.Fill(Val: byte);
var
  i: integer;
begin
  for i := 0 to length(MemState) - 1 do
  begin
    if Buf[i] <> Val then
    begin
      MemState[i] := csModify;
      Buf[i] := Val;
    end
    else
      MemState[i] := csFull;
  end;
end;

procedure TChangeByteBuffer.SetByte(n: integer; B: byte);
begin
  if GetByte(n) <> B then
  begin
    SetChangeTab(n, 1, csModify);
    inherited;
  end;
end;

procedure TChangeByteBuffer.SetWord(n: integer; V: Word);
begin
  if GetWord(n) <> V then
  begin
    SetChangeTab(n, 2, csModify);
    inherited;
  end;
end;

procedure TChangeByteBuffer.SetDWord(n: integer; V: cardinal);
begin
  if GetDWord(n) <> V then
  begin
    SetChangeTab(n, 4, csModify);
    inherited;
  end;

end;

procedure TChangeByteBuffer.SetChangeTab(n: integer; cnt: integer; st: TCellState);
var
  i: integer;
begin
  for i := 0 to cnt - 1 do
  begin
    if n + i > len then
      break;
    MemState[n + i] := st;
  end;
end;

procedure TChangeByteBuffer.SetError(n: integer; cnt: integer);
begin
  SetChangeTab(n, cnt, csBad);
end;

// ---------------------------------------------------------------------------------------
const
  DIRST_COL_WIDTH = 78;

procedure TMemFrame.Init;
begin
  MemBuf := TChangeByteBuffer.Create;
  RegisterSize := 1;
end;

procedure TMemFrame.Done;
begin
  MemBuf.Free;
end;

procedure TMemFrame.setByteOrder(ord : TByteOrder);
begin
  MemBuf.ByteOrder := ord;
end;

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

function TMemFrame.GetMulti(var n: cardinal): Double;
begin
  Result := 0;
  if RZ30MemBox.Checked then
  begin
    Result := SmallInt(MemBuf.GetWord(n));
    inc(n, 2);
  end
  else
  begin
    case DataTypeBox.ItemIndex of
      0:
        Result := MemBuf.GetSignedVal(TDataSize(DataSizeBox.ItemIndex), n);
      1:
        Result := MemBuf.GetUnSignedVal(TDataSize(DataSizeBox.ItemIndex), n);
      2:
        begin // Float
          Result := MemBuf.GetSingle(n);
          inc(n, 4);
        end;
      3:
        begin // Double
          Result := MemBuf.GetDouble(n);
          inc(n, 8);

        end;
    end;
  end;
end;

function TMemFrame.FGetSize: cardinal;
begin
  Result := MemBuf.len;
end;

procedure TMemFrame.FSetSize(ASize: cardinal);
begin
  if RegisterSize = 0 then
    RegisterSize := 1;
  MemBuf.SetLen(ASize);
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
begin
  MemBuf.SetNewData;
  PaintActivPage;
end;

procedure TMemFrame.ClrData;
begin
  MemBuf.ClrData;
  PaintActivPage;
end;

procedure TMemFrame.Fill(Val: byte);
begin
  MemBuf.Fill(Val);
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
      CellSt := MemBuf.GetState(n, 1);
      if ACol = ByteGrid.ColCount - 1 then // kolumna ASCII
      begin
        if CellSt <> csEmpty then
          CellSt := csFull;
      end
    end
    else if Sender = F1_15Grid then
    begin
      n := 2 * (16 * (ARow - 1) + (ACol - 1));
      CellSt := MemBuf.GetState(n, 2);
    end
    else if Sender = WordGRid then
    begin
      n := 2 * ((WordGRid.ColCount - 1) * (ARow - 1) + (ACol - 1));
      CellSt := MemBuf.GetState(n, 2);
    end
    else if (Sender = DWordGrid) or (Sender = FloatGrid) then
    begin
      n := 4 * (8 * (ARow - 1) + (ACol - 1));
      CellSt := MemBuf.GetState(n, 4);
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
  ByteGrid.RowCount := 1 + (MemSize + NN - 1) div NN;
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

  Y := 0;
  if MemSize > 0 then
  begin
    for i := 0 to MemSize - 1 do
    begin
      X := i mod NN;
      Y := i div NN;
      if X = 0 then
      begin
        ByteGrid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
        s1 := '';
      end;
      a := MemBuf.GetByte(i);
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

procedure TMemFrame.ByteGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
  s: string;
  Ok: Boolean;
  V: integer;
  n: integer;
begin
  n := (ByteGrid.ColCount - 2) * (ARow - 1) + (ACol - 1);
  V := HexToInt(Value, Ok);
  if Ok and (V < $100) then
  begin
    MemBuf.SetByte(n, V);

    if not(ByteGrid.EditorMode) then
      ByteGrid.Cells[ACol, ARow] := IntToHex(V, 2);
    s := ByteGrid.Cells[ByteGrid.ColCount - 1, ARow];
    if V < $20 then
      V := ord('.');
    s[ACol] := chr(V);
    ByteGrid.Cells[ByteGrid.ColCount - 1, ARow] := s;
  end
  else
    MemBuf.SetError(n, 1);

  if (length(Value) = 2) and ByteGrid.EditorMode then
    ByteGrid.EditorMode := false;
  ByteGrid.Refresh;
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
  a: Word;
  NN: integer;
  NN2: integer;
begin
  NN := WordColCntEdit.Value;
  NN2 := 2 * NN;
  WordGRid.RowCount := 1 + (MemSize + NN2 - 1) div NN2;
  WordGRid.ColCount := 1 + NN;

  WordGRid.Cells[0, 0] := MemTypeStr;
  WordGRid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 0 to NN - 1 do
  begin
    WordGRid.Cells[i + 1, 0] := ' +' + IntToHex(LiczFirstRow(i * 2), 2);
  end;
  i := 0;
  while i < MemSize do
  begin
    X := (i mod NN2) div 2;
    Y := i div NN2;
    if X = 0 then
      WordGRid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
    a := MemBuf.GetWord(i);
    WordGRid.Cells[X + 1, Y + 1] := IntToHex(a, 4);
    inc(i, 2);
  end;
  WordGRid.Refresh;
end;

procedure TMemFrame.WordGRidSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
  Ok: Boolean;
  V: integer;
  n: integer;
begin
  n := 2 * ((WordGRid.ColCount - 1) * (ARow - 1) + (ACol - 1));

  V := HexToInt(Value, Ok);
  if Ok and (V < $10000) then
  begin
    MemBuf.SetWord(n, V);

    if not(WordGRid.EditorMode) then
      WordGRid.Cells[ACol, ARow] := IntToHex(V, 4);
  end
  else
    MemBuf.SetError(n, 2);

  if (length(Value) = 4) and WordGRid.EditorMode then
    WordGRid.EditorMode := false
end;

// ------------------ DWORD GRID ------------------------------------------
procedure TMemFrame.DWordSheetShow(Sender: TObject);
var
  i: cardinal;
  X, Y: integer;
begin
  DWordGrid.RowCount := 1 + (MemSize + 31) div 32;
  DWordGrid.Cells[0, 0] := MemTypeStr;
  DWordGrid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 0 to 7 do
  begin
    DWordGrid.Cells[i + 1, 0] := '     +' + IntToHex(LiczFirstRow(i * 4), 2);
  end;
  i := 0;
  while i < MemSize do
  begin
    X := (i mod 32) div 4;
    Y := i div 32;
    if X = 0 then
      DWordGrid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
    DWordGrid.Cells[X + 1, Y + 1] := IntToHex(MemBuf.GetDWord(i), 8);
    i := i + 4;
  end;
  DWordGrid.Refresh;
end;

procedure TMemFrame.DWordGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
  Ok: Boolean;
  V: cardinal;
  n: integer;
begin
  V := HexToInt(Value, Ok);
  n := 4 * (8 * (ARow - 1) + (ACol - 1));
  Ok := true;
  if Ok then
  begin
    MemBuf.SetDWord(n, V);
    if not(DWordGrid.EditorMode) then
      DWordGrid.Cells[ACol, ARow] := IntToHex(V, 8);
  end
  else
    MemBuf.SetError(n, 4);

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
  FloatGrid.RowCount := 1 + (MemSize + 31) div 32;
  FloatGrid.Cells[0, 0] := MemTypeStr;
  FloatGrid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 0 to 7 do
    FloatGrid.Cells[i + 1, 0] := '     +' + IntToHex(LiczFirstRow(4 * i), 2);

  i := 0;
  while i < MemSize do
  begin
    X := (i mod 32) div 4;
    Y := i div 32;
    if X = 0 then
      FloatGrid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
    try
      s := Format('%.5f', [MemBuf.GetSingle(i)]);
    except
      s := '';
    end;
    FloatGrid.Cells[X + 1, Y + 1] := s;
    i := i + 4;
  end;
  FloatGrid.Refresh;
end;

procedure TMemFrame.FloatGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
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
    MemBuf.SetSingle(n, V);
    if not(FloatGrid.EditorMode) then
      FloatGrid.Cells[ACol, ARow] := Format('%.5f', [V]);
  end
  else
    MemBuf.SetError(n, 4);
end;


// ------------------ F1_15 GRID ------------------------------------------

procedure TMemFrame.F1_15SheetShow(Sender: TObject);
var
  i: cardinal;
  X, Y: integer;
begin
  F1_15Grid.RowCount := 1 + (MemSize + 31) div 32;
  F1_15Grid.Cells[0, 0] := MemTypeStr;
  F1_15Grid.ColWidths[0] := DIRST_COL_WIDTH;
  for i := 0 to 15 do
  begin
    F1_15Grid.Cells[i + 1, 0] := ' +' + IntToHex(LiczFirstRow(2 * i), 2);
  end;

  i := 0;
  while i < MemSize do
  begin
    X := (i mod 32) div 2;
    Y := i div 32;
    if X = 0 then
      F1_15Grid.Rows[Y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
    F1_15Grid.Cells[X + 1, Y + 1] := Format('%.5f', [F1_15ToFloat(MemBuf.GetWord(i))]);
    i := i + 2;
  end;
  F1_15Grid.Refresh;
end;

procedure TMemFrame.F1_15GridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
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
    MemBuf.SetWord(n, w);
    if not(F1_15Grid.EditorMode) then
    begin
      F1_15Grid.Cells[ACol, ARow] := Format('%.5f', [F1_15ToFloat(w)]);
    end;
  end
  else
    MemBuf.SetError(n, 2);
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
  if InputQuery('Zmiana nazwy', 'Podaj now¹ nazwê', s) then
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
        w := MemBuf.GetWord(wsk);
        if (w and $0001) = 0 then
          inc(wsk, 2);
        inc(i);
      until ((w and $0001) <> 0) or (i > 40);
    end;

    case SerieTypeBox.ItemIndex of
      0:
        begin // abcabcabc
          i := 0;
          while wsk < MemSize do
          begin
            LSer := SeriesListBox.Items.Objects[i mod n] as TLineSeries;
            f := GetMulti(wsk);
            LSer.AddXY(i div n, f);
            inc(i);
          end;
        end;
      1:
        begin // aaabbbccc
          cnt := (MemSize div n) div 2;
          i := 0;
          while wsk < MemSize do
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
    ReadMinMaxBox(ChartMinMaxTab[Nr]);
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
    ShowMinMaxBox(ChartMinMaxTab[Nr]);
    SetMinMaxBox(ChartMinMaxTab[Nr]);
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
    setlength(Buf, n);
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

// -----------------------------------------------------------------------------

function TMemFrame.GetJSONObject: TJSONBuilder;
var
  i: integer;
  jBuild: TJSONBuilder;
  jBuild2: TJSONBuilder;
  jArr: TJSONArray;
  IntArr: TIntArr;
begin
  Result.Init;

  // zak³adka BYTE
  jBuild.Init;
  jBuild.Add('Col_Cnt', ByteColCntEdit.Value);
  Result.Add('BytePage', jBuild);

  // zak³adka WORD
  jBuild.Init;
  jBuild.Add('Col_Cnt', WordColCntEdit.Value);
  Result.Add('WordPage', jBuild);

  // zak³adka CHART
  jBuild.Init;

  jArr := TJSONArray.Create;
  FSetChartSerCount(SerCntEdit.Value);
  for i := 0 to SerCntEdit.Value - 1 do
  begin
    jBuild2.Init;
    jBuild2.Add('Name', SeriesListBox.Items.Strings[i]);
    jBuild2.AddColor('Color', (SeriesListBox.Items.Objects[i] as TLineSeries).SeriesColor);
    jArr.AddElement(jBuild2.jobj);
  end;
  jBuild.Add('Signals', jArr);

  jBuild.Add('Auto', AutoXYBox.Checked);
  jBuild.Add('MinX', MinXEdit.Text);
  jBuild.Add('MaxX', MaxXEdit.Text);
  jBuild.Add('MinY', MinYEdit.Text);
  jBuild.Add('MaxY', MaxYEdit.Text);
  jBuild.Add('DataType', DataTypeBox.ItemIndex);
  jBuild.Add('SeriesType', SerieTypeBox.ItemIndex);
  jBuild.Add('DataSize', DataSizeBox.ItemIndex);
  jBuild.Add('RZ30Data', RZ30MemBox.Checked);
  jBuild.Add('Points', PointsBox.Checked);

  jArr := TJSONArray.Create;
  for i := 0 to MAX_MEM_BOX - 1 do
  begin
    jBuild2.Init;
    jBuild2.Add(ChartMinMaxTab[i]);
    jArr.AddElement(jBuild2.jobj);
  end;
  jBuild.Add('CharRanges', jArr);

  jBuild2.Init;
  jBuild2.Add(LasPosPoint);
  jBuild2.Add('W', MeasurePanel.Width);
  jBuild2.Add('H', MeasurePanel.Height);

  setlength(IntArr, MeasureGrid.ColCount - 1);
  for i := 0 to MeasureGrid.ColCount - 2 do
    IntArr[i] := MeasureGrid.ColWidths[i + 1];
  jBuild2.Add('ColWidth', IntArr);

  jBuild.Add('MeasGrid', jBuild2.jobj);
  Result.Add('Chart', jBuild.jobj);
end;

procedure TMemFrame.LoadfromJson(jParent: TJSONLoader);
var
  n, i: integer;
  s: string;
  jArr: TJSONArray;
  IntArr: TIntArr;
  C: integer;
  jLoader: TJSONLoader;
  jLoader2: TJSONLoader;
begin

  // zak³adka BYTE
  if jLoader.Init(jParent.GetObject('BytePage')) then
  begin
    jLoader.Load('Col_Cnt', ByteColCntEdit);
  end;

  // zak³adka WORD
  if jLoader.Init(jParent.GetObject('WordPage')) then
  begin
    jLoader.Load('Col_Cnt', WordColCntEdit);
  end;

  // zak³adka CHART

  if jLoader.Init(jParent.GetObject('Chart')) then
  begin
    jArr := jLoader.getArray('Signals');
    if Assigned(jArr) then
    begin
      SerCntEdit.Value := jArr.Count;
      FSetChartSerCount(SerCntEdit.Value);
      if MeasureGrid.RowCount < jArr.Count then
        MeasureGrid.RowCount := jArr.Count;

      for i := 0 to SerCntEdit.Value - 1 do
      begin
        jLoader2.Init(jArr.Items[i]);

        s := Format('Sig_%u', [i]);
        jLoader2.Load('Name', s);
        (SeriesListBox.Items.Objects[i] as TLineSeries).Title := s;
        SeriesListBox.Items.Strings[i] := s;
        MeasureGrid.Cells[1, 1 + i] := s;

        C := (SeriesListBox.Items.Objects[i] as TLineSeries).SeriesColor;
        jLoader2.Load('Color', C);
        (SeriesListBox.Items.Objects[i] as TLineSeries).SeriesColor := C;
      end;
    end;

    jLoader.Load('Auto', AutoXYBox);
    jLoader.Load('MinX', MinXEdit);
    jLoader.Load('MaxX', MaxXEdit);
    jLoader.Load('MinY', MinYEdit);
    jLoader.Load('MaxY', MaxYEdit);

    jLoader.Load('DataType', DataTypeBox);
    jLoader.Load('SeriesType', SerieTypeBox);
    jLoader.Load('DataSize', DataSizeBox);

    jLoader.Load('RZ30Data', RZ30MemBox);
    jLoader.Load('Points', PointsBox);

    jArr := jLoader.getArray('CharRanges');
    if Assigned(jArr) then
    begin
      n := Math.Min(MAX_MEM_BOX, jArr.Count);
      for i := 0 to n - 1 do
      begin
        jLoader2.Init(jArr.Items[i]);
        jLoader2.Load(ChartMinMaxTab[i]);
      end;
    end;

    if jLoader2.Init(jLoader, 'MeasGrid') then
    begin
      jLoader2.Load(LasPosPoint);
      jLoader2.Load_WH(MeasurePanel);
      jLoader2.Load('ColWidth', IntArr);
      n := Min(MeasureGrid.ColCount - 1, length(IntArr));
      for i := 0 to n - 1 do
        MeasureGrid.ColWidths[i + 1] := IntArr[i];
    end;
  end;

end;

procedure TMemFrame.MakeMinMaxBoxHints;
  function BuildHint(const R: TRect): string;
  begin
    Result := Format('Xmin=%d Xmax=%d Ymin=%d Ymax=%d', [R.Left, R.Right, R.Bottom, R.Top]);
  end;

begin
  SaveM1Btn.Hint := BuildHint(ChartMinMaxTab[0]);
  RestoreM1Btn.Hint := SaveM1Btn.Hint;

  SaveM2Btn.Hint := BuildHint(ChartMinMaxTab[1]);
  RestoreM2Btn.Hint := SaveM2Btn.Hint;

  SaveM3Btn.Hint := BuildHint(ChartMinMaxTab[2]);
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
