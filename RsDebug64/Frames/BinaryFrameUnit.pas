unit BinaryFrameUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Math,
  Grids, ComCtrls, TeEngine, Series, StdCtrls, Spin, CheckLst, TeeProcs, IniFiles,
  Chart, ExtCtrls, Menus, Buttons,
  CommonDef,
  ArrowCha,
  System.JSON,
  JSonUtils;

const
  MAX_MEM_BOX = 3;

type
  TToBin = function(MemName: string; Mem: pbyte; Size: integer; TypeSign: char; Val: OleVariant): integer of object;
  TToValue = function(MemName: string; Buf: pbyte; TypeSign: char; var Val: OleVariant): integer of object;
  TOntxtToInt = function(Txt: string): integer of object;

  TBinaryFrame = class(TFrame)
    ByteGrid: TStringGrid;
    ByteGridPanel: TPanel;
    Label4: TLabel;
    ByteColCntEdit: TSpinEdit;
    procedure GridDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ByteGridSelectCell(Sender: TObject; ACol, ARow: integer; var CanSelect: Boolean);
    procedure ByteGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
    procedure ByteSheetShow(Sender: TObject);

    procedure GridGetEditText(Sender: TObject; ACol, ARow: integer; var Value: String);
    procedure ByteColCntEditChange(Sender: TObject);
  private
    FMemBufSize: cardinal;
    FSrcAdr: cardinal;
    EditCellMem: string;
    FRegisterSize: integer;

    procedure FSetSize(ASize: cardinal);
    procedure FSetSrcAdr(ASrcAdr: cardinal);

    function GetState(n: integer; Size: byte): TCellState;

    function FirstColTxt(w: cardinal): string;

    procedure FSetRegisterSize(ARegisterSize: integer);
  protected
    function LiczFirstCol(w: integer): cardinal;
  public
    MemState: array of TCellState;
    MemBuf: array of Boolean;
    MemBufCopy: array of Boolean;
    MemTypeName: string;

    CharMinMaxTab: array [0 .. MAX_MEM_BOX - 1] of TRect;
    property SrcAdr: cardinal read FSrcAdr write FSetSrcAdr;
    property MemSize: cardinal read FMemBufSize write FSetSize;
    procedure PaintActivPage;
    procedure SetNewData;
    procedure ClrData;
    procedure FillZero;
    procedure FillOnes;
    procedure Fill(Val: Boolean);
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
  FIRST_COL_WIDTH = 78;

function BoolStr(q: Boolean): string;
begin
  if q then
    Result := '1'
  else
    Result := '0';
end;

procedure TBinaryFrame.FSetRegisterSize(ARegisterSize: integer);
begin
  FRegisterSize := ARegisterSize;
  PaintActivPage;
end;

function TBinaryFrame.GetState(n: integer; Size: byte): TCellState;
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

procedure TBinaryFrame.FSetSize(ASize: cardinal);
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

procedure TBinaryFrame.FSetSrcAdr(ASrcAdr: cardinal);
begin
  FSrcAdr := ASrcAdr;
  PaintActivPage;
end;

procedure TBinaryFrame.PaintActivPage;
begin
  ByteSheetShow(nil);
end;

procedure TBinaryFrame.SetNewData;
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

procedure TBinaryFrame.ClrData;
var
  i: integer;
begin
  for i := 0 to length(MemState) - 1 do
  begin
    MemState[i] := csEmpty;
  end;
  PaintActivPage;
end;

procedure TBinaryFrame.Fill(Val: Boolean);
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

procedure TBinaryFrame.FillZero;
begin
  Fill(false);
end;

procedure TBinaryFrame.FillOnes;
begin
  Fill(true);
end;

procedure TBinaryFrame.GridDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
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
      n := (ByteGrid.ColCount - 1) * (ARow - 1) + (ACol - 1);
      CellSt := GetState(n, 1);
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

procedure TBinaryFrame.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TBinaryFrame.GridGetEditText(Sender: TObject; ACol, ARow: integer; var Value: String);
begin
  EditCellMem := (Sender as TStringGrid).Cells[ACol, ARow];
end;

function TBinaryFrame.LiczFirstCol(w: integer): cardinal;
begin
  Result := trunc(w / RegisterSize);
end;

function TBinaryFrame.FirstColTxt(w: cardinal): string;
begin
  Result := '"' + IntToHex(w shr 16, 4) + ' ' + IntToHex(w and $FFFF, 4) + '"';
end;



// ------------------ byte GRID ------------------------------------------

procedure TBinaryFrame.ByteColCntEditChange(Sender: TObject);
begin
  ByteSheetShow(nil);
end;

procedure TBinaryFrame.ByteSheetShow(Sender: TObject);
var
  i: integer;
  x, y: integer;
  NN: integer;
begin
  NN := ByteColCntEdit.Value;

  ByteGrid.RowCount := 1 + (integer(FMemBufSize) + NN - 1) div NN;
  ByteGrid.ColCount := NN + 1;
  ByteGrid.Cells[0, 0] := MemTypeName;
  ByteGrid.ColWidths[0] := FIRST_COL_WIDTH;
  for i := 1 to NN do
    ByteGrid.ColWidths[i] := 21;

  for i := 0 to NN - 1 do
  begin
    ByteGrid.Cells[i + 1, 0] := IntToHex(i + 1, 2);
  end;

  if FMemBufSize > 0 then
  begin
    for i := 0 to FMemBufSize - 1 do
    begin
      x := i mod NN;
      y := i div NN;
      if x = 0 then
      begin
        ByteGrid.Rows[y + 1].CommaText := FirstColTxt(FSrcAdr + LiczFirstCol(i));
      end;
      ByteGrid.Cells[x + 1, y + 1] := BoolStr(MemBuf[i]);
    end;
    ByteGrid.Refresh;
  end;
end;

procedure TBinaryFrame.ByteGridSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
var
  k: TCellState;
  V: Boolean;
  n: integer;
begin
  n := (ByteGrid.ColCount - 1) * (ARow - 1) + (ACol - 1);
  if (Value = '0') or (Value = '1') then
  begin
    V := (Value = '1');
    k := MemState[n];
    if MemBuf[n] <> V then
    begin
      MemBuf[n] := V;
      k := csModify;
    end;
    if not(ByteGrid.EditorMode) then
      ByteGrid.Cells[ACol, ARow] := BoolStr(V);
  end
  else
    k := csBad;
  MemState[n] := k;
  if (length(Value) = 1) and ByteGrid.EditorMode then
    ByteGrid.EditorMode := false;
  ByteGrid.Refresh;
end;

procedure TBinaryFrame.ByteGridSelectCell(Sender: TObject; ACol, ARow: integer; var CanSelect: Boolean);
begin
  CanSelect := (ACol <> 17);
end;

procedure TBinaryFrame.SaveToIni(Ini: TMemIniFile; SName: string);
begin

end;

function TBinaryFrame.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
end;

procedure TBinaryFrame.LoadFromIni(Ini: TMemIniFile; SName: string);
begin

end;

procedure TBinaryFrame.doParamVisible(vis: Boolean);
begin
  ByteGridPanel.Visible := vis;
end;

procedure TBinaryFrame.CopyToStringList(SL: TStrings);
var
  Gr: TStringGrid;
  n: integer;
  i: integer;
  j: integer;
  S1: TStringList;
begin
  Gr := ByteGrid;
  n := 16;
  if Assigned(Gr) then
  begin
    S1 := TStringList.Create;
    try
      S1.Delimiter := ';';
      for j := 1 to Gr.RowCount - 1 do
      begin
        S1.Clear;
        for i := 0 to n - 1 do
        begin
          S1.Add(Gr.Cells[i + 1, j]);
        end;
        SL.Add(S1.DelimitedText);
      end;
    finally
      S1.Free;
    end;
  end;
end;

end.
