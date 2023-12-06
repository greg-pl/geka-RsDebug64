unit BinaryFrameUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,Math,
  Grids, ComCtrls, TeEngine, Series, StdCtrls, Spin, CheckLst, TeeProcs,IniFiles,
  Chart, ExtCtrls, Menus,Buttons,
  CommonDef,
  ArrowCha;

const
  MAX_MEM_BOX =3;
type
  TToBin = function(MemName : string; Mem : pbyte; Size:integer; TypeSign:char; Val:OleVariant): integer of object;
  TToValue = function(MemName : string; Buf : pByte; TypeSign:char; var Val:OleVariant): integer of object;
  TOntxtToInt = function(Txt: string):integer of object;

  TBinaryFrame = class(TFrame)
    ByteGrid    : TStringGrid;
    ByteGridPanel: TPanel;
    Label4: TLabel;
    ByteColCntEdit: TSpinEdit;
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure GridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ByteGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure ByteGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure ByteSheetShow(Sender: TObject);

    procedure GridGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure ByteColCntEditChange(Sender: TObject);
  private
    FMemBufSize : cardinal;
    FSrcAdr     : cardinal;
    EditCellMem : string;
    FRegisterSize : integer;

    procedure FSetSize(ASize :cardinal);
    procedure FSetSrcAdr(ASrcAdr : cardinal);

    function  GetState(n : integer; Size: byte):TCellState;


    function  FirstColTxt(w : cardinal):string;

    procedure FSetRegisterSize(ARegisterSize : integer);
  protected
    function  LiczFirstCol(w : integer):cardinal;
  public
    MemState     : array of TCellState;
    MemBuf       : array of boolean;
    MemBufCopy   : array of boolean;
    MemTypeName  : string;

    CharMinMaxTab : array[0..MAX_MEM_BOX-1] of TRect;
    property  SrcAdr : cardinal read FSrcAdr write FSetSrcAdr;
    property  MemSize : cardinal read FMemBufSize write FSetSize;
    procedure PaintActivPage;
    procedure SetNewData;
    procedure ClrData;
    procedure FillZero;
    procedure FillOnes;
    procedure Fill(val: boolean);
    property  RegisterSize : integer read FRegisterSize write FSetRegisterSize;
    procedure SaveToIni(Ini : TMemIniFile; SName : string);
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

function BoolStr(q : boolean): string;
begin
  if q then
    Result := '1'
  else
    Result := '0';
end;

procedure TBinaryFrame.FSetRegisterSize(ARegisterSize : integer);
begin
  FRegisterSize := ARegisterSize;
  PaintActivPage;
end;









function TBinaryFrame.GetState(n : integer; Size: byte):TCellState;
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

procedure TBinaryFrame.FSetSize(ASize :cardinal);
begin
  if RegisterSize=0 then
    RegisterSize:=1; 
  if FMemBufSize <>ASize then
  begin
    FMemBufSize := ASize;
    SetLength(MemState,FMemBufSize);
    SetLength(MemBuf,FMemBufSize);
    SetLength(MemBufCopy,FMemBufSize);
  end;
  PaintActivPage;
end;

procedure TBinaryFrame.FSetSrcAdr(ASrcAdr : cardinal);
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

procedure TBinaryFrame.ClrData;
var
  i : integer;
begin
  for i:=0 to length(MemState)-1 do
  begin
    MemState[i]:=csEmpty;
  end;
  PaintActivPage;
end;

procedure TBinaryFrame.Fill(val: boolean);
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


procedure TBinaryFrame.FillZero;
begin
  Fill(false);
end;

procedure TBinaryFrame.FillOnes;
begin
  Fill(true);
end;


procedure TBinaryFrame.GRidDrawCell(Sender: TObject; ACol,
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
    if Sender=ByteGrid then
    begin
      N := (ByteGrid.ColCount-1)*(ARow-1)+(ACol-1);
      CellSt := GetState(N,1);
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

procedure TBinaryFrame.GridKeyDown(Sender: TObject; var Key: Word;
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

procedure TBinaryFrame.GridGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
  EditCellMem := (Sender as TStringGrid).Cells[ACol,ARow];
end;

function TBinaryFrame.LiczFirstCol(w : integer):cardinal;
begin
  Result:= trunc(w / RegisterSize);
end;

function  TBinaryFrame.FirstColTxt(w : cardinal):string;
begin
  Result := '"'+IntToHex(w shr 16,4)+' '+IntToHex(w and $ffff,4)+'"';
end;



// ------------------ byte GRID ------------------------------------------

procedure TBinaryFrame.ByteColCntEditChange(Sender: TObject);
begin
  ByteSheetShow(nil);
end;

procedure TBinaryFrame.ByteSheetShow(Sender: TObject);
var
  i   : integer;
  x,y : integer;
  NN  : integer;
begin
  NN := ByteColCntEdit.Value;

  ByteGrid.RowCount  := 1+(integer(FMemBufSize)+NN-1) div NN;
  ByteGrid.ColCount := NN+1;
  ByteGrid.Cells[0,0]:=MemTypeName;
  ByteGrid.ColWidths[0]:=FIRST_COL_WIDTH;
  for i:=1 to NN do
    ByteGrid.ColWidths[i]:=21;

  for i:=0 to NN-1 do
  begin
    ByteGrid.Cells[i+1,0]:=IntToHex(i+1,2);
  end;

  if FMemBufSize>0 then
  begin
    for i:=0 to FMemBufSize-1 do
    begin
       x := i mod NN;
       y := i div NN;
       if x=0 then
       begin
         ByteGrid.Rows[y+1].CommaText:=FirstColTxt(FSrcAdr+LiczFirstCol(i));
       end;
       ByteGrid.Cells[x+1,y+1]:=BoolStr(MemBuf[i]);
    end;
    ByteGrid.Refresh;
  end;
end;

procedure TBinaryFrame.ByteGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
  k  : TCellState;
  V  : boolean;
  N  : integer;
begin
  N := (ByteGrid.ColCount-1)*(ARow-1)+(Acol-1);
  if (Value='0') or (Value='1') then
  begin
    V:=(Value='1');
    k:=MemState[N];
    if MemBuf[N]<>V then
    begin
      MemBuf[N]:=V;
      k:=csModify;
    end;
    if not(ByteGrid.EditorMode) then
      ByteGrid.Cells[Acol,ARow]:=BoolStr(V);
  end
  else
    k := csBad;
  MemState[N]:=k;
  if (Length(Value)=1) and ByteGrid.EditorMode then
    ByteGrid.EditorMode:= False;
  ByteGrid.Refresh;
end;


procedure TBinaryFrame.ByteGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect:=(ACol<>17);
end;



procedure TBinaryFrame.SaveToIni(Ini : TMemIniFile; SName : string);
begin

end;


procedure TBinaryFrame.LoadFromIni(Ini : TMemIniFile; SName : string);
begin

end;


procedure TBinaryFrame.doParamVisible(vis : boolean);
begin
  ByteGridPanel.Visible := vis;
end;

procedure TBinaryFrame.CopyToStringList(SL : TStrings);
var
  Gr    : TStringGrid;
  N     : integer;
  i     : integer;
  j     : integer;
  S1    : TStringList;
begin
  Gr := ByteGrid;
  N  := 16;
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
