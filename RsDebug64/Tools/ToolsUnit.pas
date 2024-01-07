unit ToolsUnit;

interface

uses
  windows, SysUtils, Classes, ComCtrls, math, Grids, StdCtrls, CheckLst,
  JSonUtils;

type
  TByteOrder = (boLittle, boBig);
  TPtrSize = (ps8, ps16, ps32);
  TDataSize = (sz8BIT, sz16BIT, sz32BIT);

  TByteBuffer = class(TObject)
  private
    FSize : integer;
  public
    Buf: array of byte;
    ByteOrder: TByteOrder;

    procedure SetSize(size: integer); virtual;
    property Size: integer read FSize;

    function GetByte(n: integer): byte;
    function GetWord(n: integer): Word;
    function GetDWord(n: integer): cardinal;
    function GetSingle(n: integer): Single;
    function GetDouble(n: integer): Double;

    procedure SetByte(n: integer; B: byte); virtual;
    procedure SetWord(n: integer; V: Word); virtual;
    procedure SetDWord(n: integer; V: cardinal); virtual;
    procedure SetSingle(n: integer; V: Single);
    procedure SetDouble(n: integer; V: Double);

    function GetSignedVal(dataSize: TDataSize; var adr: cardinal): integer;
    function GetUnSignedVal(dataSize: TDataSize; var adr: cardinal): cardinal;

    procedure SaveToFile(FName: string);
    function LoadFromFile(FName: string): boolean;
  end;

const
  ByteOrderName: array [TByteOrder] of string = ('L', 'B');
  PtrSizeName: array [TPtrSize] of string = ('8bit', '16bit', '32bit');

function GetViewListColumnWidtsStr(ListView: TListView): string;
function GetViewListColumnWidts(ListView: TListView): TIntArr;
procedure SetViewListColumnWidts(ListView: TListView; S: string); overload;
procedure SetViewListColumnWidts(ListView: TListView; arr: TIntArr); overload;

function GetGridColumnWidtsStr(Grid: TStringGrid): string;
function GetGridColumnWidts(Grid: TStringGrid): TIntArr;

procedure SetGridColumnWidts(Grid: TStringGrid; S: string); overload;
procedure SetGridColumnWidts(Grid: TStringGrid; arr: TIntArr); overload;

procedure AddToList(Combo: TComboBox);
function GetChckedAsString(Box: TCheckListBox): string;
procedure SetChckedFromString(Box: TCheckListBox; S: string);
function GetPointerAsString(Box: TCheckListBox): string;
procedure SetPointerFromString(Box: TCheckListBox; S: string);
function GetWord(p: pbyte; ByteOrder: TByteOrder): Word;
function GetDWord(p: pbyte; ByteOrder: TByteOrder): cardinal;
function GetDDWord(p: pbyte; ByteOrder: TByteOrder): int64;
procedure SetWord(p: pbyte; ByteOrder: TByteOrder; w: Word);
procedure SetDWord(p: pbyte; ByteOrder: TByteOrder; w: cardinal);
procedure SetDDWord(p: pbyte; ByteOrder: TByteOrder; w: int64);
function RemoveEmptyStrings(S: string): string;
function DSwap(D: cardinal): cardinal;
function GetPtrSize(Name: string; Default: TPtrSize): TPtrSize;
function GetPtrSizeName(ps: TPtrSize): string;
function StrToCInt(S: string; var V: cardinal): boolean;
function GetTempFile(const Extension: string): string;

implementation

procedure TByteBuffer.SetSize(size: integer);
begin
  FSize := size;
  SetLength(Buf, size);
end;


function TByteBuffer.GetByte(n: integer): byte;
begin
  if (n < 0) or (n + 1 > Length(Buf)) then
    raise Exception.Create('ToolByteArr out of range');
  Result := Buf[n];
end;

procedure TByteBuffer.SetByte(n: integer; B: byte);
begin
  if (n < 0) or (n + 1 > Length(Buf)) then
    raise Exception.Create('ToolByteArr out of range');
  Buf[n] := B;
end;

function TByteBuffer.GetWord(n: integer): Word;
begin
  if (n < 0) or (n + 2 > Length(Buf)) then
    raise Exception.Create('ToolByteArr out of range');

  if ByteOrder = boBig then
    Result := (Buf[n + 0] shl 8) or Buf[n + 1]
  else
    Result := (Buf[n + 1] shl 8) or Buf[n + 0];
end;

procedure TByteBuffer.SetWord(n: integer; V: Word);
begin
  if (n < 0) or (n + 2 > Length(Buf)) then
    raise Exception.Create('ToolByteArr out of range');
  if ByteOrder = boBig then
  begin
    Buf[n + 1] := V and $FF;
    Buf[n + 0] := (V shr 8) and $FF;
  end
  else
  begin
    Buf[n + 0] := V and $FF;
    Buf[n + 1] := (V shr 8) and $FF;
  end;
end;

function TByteBuffer.GetDWord(n: integer): cardinal;
begin
  if (n < 0) or (n + 4 > Length(Buf)) then
    raise Exception.Create('ToolByteArr out of range');
  if ByteOrder = boBig then
  begin
    Result := Buf[n + 3];
    Result := Result or (Buf[n + 2] shl 8);
    Result := Result or (Buf[n + 1] shl 16);
    Result := Result or (Buf[n + 0] shl 24);
  end
  else
  begin
    Result := Buf[n + 0];
    Result := Result or (Buf[n + 1] shl 8);
    Result := Result or (Buf[n + 2] shl 16);
    Result := Result or (Buf[n + 3] shl 24);
  end;
end;

procedure TByteBuffer.SetDWord(n: integer; V: cardinal);
begin
  if (n < 0) or (n + 4 > Length(Buf)) then
    raise Exception.Create('ToolByteArr out of range');
  if ByteOrder = boBig then
  begin
    Buf[n + 3] := V and $FF;
    Buf[n + 2] := (V shr 8) and $FF;
    Buf[n + 1] := (V shr 16) and $FF;
    Buf[n + 0] := (V shr 24) and $FF;
  end
  else
  begin
    Buf[n + 0] := V and $FF;
    Buf[n + 1] := (V shr 8) and $FF;
    Buf[n + 2] := (V shr 16) and $FF;
    Buf[n + 3] := (V shr 24) and $FF;
  end;
end;

procedure TByteBuffer.SetSingle(n: integer; V: Single);
var
  X: cardinal;
begin
  psingle(addr(X))^ := V;
  SetDWord(n, X);
end;

function TByteBuffer.GetSingle(n: integer): Single;
var
  X: cardinal;
begin
  X := GetDWord(n);
  Result := psingle(addr(X))^;
end;

function TByteBuffer.GetDouble(n: integer): Double;
var
  XT: array [0 .. 1] of cardinal;
begin
  if ByteOrder = boBig then
  begin
    XT[1] := GetDWord(n);
    XT[0] := GetDWord(n + 4);
  end
  else
  begin
    XT[0] := GetDWord(n);
    XT[1] := GetDWord(n + 4);
  end;
  Result := pDouble(addr(XT))^;
end;

procedure TByteBuffer.SetDouble(n: integer; V: Double);
var
  XT: array [0 .. 1] of cardinal;
begin
  pDouble(addr(XT))^ := V;
  if ByteOrder = boBig then
  begin
    SetDWord(n, XT[1]);
    SetDWord(n + 4, XT[0]);
  end
  else
  begin
    SetDWord(n, XT[0]);
    SetDWord(n + 4, XT[1]);
  end;
end;

function TByteBuffer.GetUnSignedVal(dataSize: TDataSize; var adr: cardinal): cardinal;
begin
  case dataSize of
    sz8BIT:
      begin
        Result := GetByte(adr);
        inc(adr, 1);
      end;
    sz16BIT:
      begin
        Result := GetWord(adr);
        inc(adr, 2);
      end;
    sz32BIT:
      begin
        Result := GetDWord(adr);
        inc(adr, 4);
      end;
  end;
end;

function TByteBuffer.GetSignedVal(dataSize: TDataSize; var adr: cardinal): integer;
begin
  case dataSize of
    sz8BIT:
      begin
        Result := short(GetByte(adr));
        inc(adr, 1);
      end;
    sz16BIT:
      begin
        Result := smallint(GetWord(adr));
        inc(adr, 2);
      end;
    sz32BIT:
      begin
        Result := integer(GetDWord(adr));
        inc(adr, 4);
      end;
  end;

end;

procedure TByteBuffer.SaveToFile(FName: string);
var
  Strm: TmemoryStream;
begin
  Strm := TmemoryStream.Create;
  try
    Strm.Write(Buf[0], Length(Buf));
    Strm.SaveToFile(FName);
  finally
    Strm.Free;
  end;
end;

function TByteBuffer.LoadFromFile(FName: string): boolean;
var
  Strm: TmemoryStream;
begin
  Result := false;
  Strm := TmemoryStream.Create;
  try
    Strm.LoadFromFile(FName);
    SetSize(Strm.Size);
    Strm.Read(Buf[0], Strm.Size);
    Result := true;
  finally
    Strm.Free;
  end;
end;


// ------------------------------------------------------------------------------

function GetViewListColumnWidtsStr(ListView: TListView): string;
var
  SL: TStringList;
  i: integer;
  A: integer;
begin
  SL := TStringList.Create;
  try
    for i := 0 to ListView.Columns.Count - 1 do
    begin
      A := ListView.Column[i].Width;
      SL.Add(IntToStr(A));
    end;
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

procedure SetViewListColumnWidts(ListView: TListView; S: string);
var
  SL: TStringList;
  i: integer;
  A: integer;
  n: integer;
begin
  SL := TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    SL.DelimitedText := S;
    n := Min(ListView.Columns.Count, SL.Count);
    for i := 0 to n - 1 do
    begin
      A := StrToIntDef(SL.Strings[i], 50);
      ListView.Column[i].Width := A;
    end;
  finally
    SL.Free;
  end;
end;

procedure SetViewListColumnWidts(ListView: TListView; arr: TIntArr);
var
  i: integer;
  n: integer;
begin
  n := Min(ListView.Columns.Count, Length(arr));
  for i := 0 to n - 1 do
    ListView.Column[i].Width := arr[i];
end;

function GetViewListColumnWidts(ListView: TListView): TIntArr;
var
  i: integer;
begin
  SetLength(Result, ListView.Columns.Count);
  for i := 0 to ListView.Columns.Count - 1 do
    Result[i] := ListView.Column[i].Width;
end;

function GetGridColumnWidtsStr(Grid: TStringGrid): string;
var
  SL: TStringList;
  i: integer;
  A: integer;
begin
  SL := TStringList.Create;
  try
    for i := 0 to Grid.ColCount - 2 do
    begin
      A := Grid.ColWidths[i + 1];
      SL.Add(IntToStr(A));
    end;
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

function GetGridColumnWidts(Grid: TStringGrid): TIntArr;
var
  i: integer;
begin
  SetLength(Result, Grid.ColCount - 1);
  for i := 0 to Grid.ColCount - 2 do
    Result[i] := Grid.ColWidths[i + 1];
end;

procedure SetGridColumnWidts(Grid: TStringGrid; S: string);
var
  SL: TStringList;
  i: integer;
  A: integer;
  n: integer;
begin
  SL := TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    SL.DelimitedText := S;
    n := Min(Grid.ColCount - 1, SL.Count);
    for i := 0 to n - 1 do
    begin
      A := StrToIntDef(SL.Strings[i], 50);
      Grid.ColWidths[i + 1] := A;
    end;
  finally
    SL.Free;
  end;
end;

procedure SetGridColumnWidts(Grid: TStringGrid; arr: TIntArr);
var
  i: integer;
  n: integer;
begin
  n := Min(Grid.ColCount - 1, Length(arr));
  for i := 0 to n - 1 do
  begin
    Grid.ColWidths[i + 1] := arr[i]
  end;
end;

procedure AddToList(Combo: TComboBox);
var
  k: integer;
  S: string;
begin
  S := Combo.Text;
  k := Combo.Items.IndexOf(S);
  if k >= 0 then
    Combo.Items.Delete(k);
  Combo.Items.Insert(0, S);
  Combo.Text := S;
end;

function GetChckedAsString(Box: TCheckListBox): string;
var
  SL: TStringList;
  i: integer;
begin
  SL := TStringList.Create;
  try
    for i := 0 to Box.Count - 1 do
    begin
      if Box.Checked[i] then
        SL.Add('1')
      else
        SL.Add('0');
    end;
    Result := SL.CommaText;
  finally
    SL.Free;
  end;
end;

procedure SetChckedFromString(Box: TCheckListBox; S: string);
var
  SL: TStringList;
  i: integer;
begin
  SL := TStringList.Create;
  try
    SL.CommaText := S;
    for i := 0 to Box.Count - 1 do
    begin
      if i < SL.Count then
        Box.Checked[i] := (SL.Strings[i] = '1')
      else
        Box.Checked[i] := false;
    end;
  finally
    SL.Free;
  end;
end;

function GetPointerAsString(Box: TCheckListBox): string;
var
  SL: TStringList;
  i: integer;
begin
  SL := TStringList.Create;
  try
    for i := 0 to Box.Count - 1 do
    begin
      SL.Add('$' + IntTohex(cardinal(Box.Items.Objects[i]), 6));
    end;
    Result := SL.CommaText;
  finally
    SL.Free;
  end;
end;

procedure SetPointerFromString(Box: TCheckListBox; S: string);
var
  SL: TStringList;
  i: integer;
begin
  SL := TStringList.Create;
  try
    SL.CommaText := S;
    for i := 0 to Box.Count - 1 do
    begin
      if i < SL.Count then
        Box.Items.Objects[i] := Pointer(StrToInt(SL.Strings[i]))
      else
        Box.Items.Objects[i] := nil;
    end;
  finally
    SL.Free;
  end;
end;

function GetWord(p: pbyte; ByteOrder: TByteOrder): Word;
begin
  if ByteOrder = boBig then
  begin
    Result := (p^) shl 8;
    inc(p);
    Result := Result or p^;
  end
  else
    Result := pWord(p)^;
end;

function GetDWord(p: pbyte; ByteOrder: TByteOrder): cardinal;
begin
  if ByteOrder = boBig then
  begin
    Result := (p^) shl 24;
    inc(p);
    Result := Result or ((p^) shl 16);
    inc(p);
    Result := Result or ((p^) shl 8);
    inc(p);
    Result := Result or p^;
  end
  else
    Result := pCardinal(p)^;
end;

function DSwap(D: cardinal): cardinal;
begin
  Result := ((D shr 24) and $000000FF) or ((D shr 8) and $0000FF00) or ((D shl 8) and $00FF0000) or
    ((D shl 24) and $FF000000);
end;

function GetDDWord(p: pbyte; ByteOrder: TByteOrder): int64;
var
  i: integer;
begin
  if ByteOrder = boBig then
  begin
    Result := 0;
    for i := 0 to 7 do
    begin
      Result := Result shl 8;
      Result := Result or p^;
      inc(p);
    end;
  end
  else
    Result := pInt64(p)^;
end;

procedure SetWord(p: pbyte; ByteOrder: TByteOrder; w: Word);
begin
  if ByteOrder = boBig then
  begin
    p^ := byte(w shr 8);
    inc(p);
    p^ := byte(w);
  end
  else
    pWord(p)^ := w;
end;

procedure SetDWord(p: pbyte; ByteOrder: TByteOrder; w: cardinal);
begin
  if ByteOrder = boBig then
  begin
    p^ := byte(w shr 24);
    inc(p);
    p^ := byte(w shr 16);
    inc(p);
    p^ := byte(w shr 8);
    inc(p);
    p^ := byte(w);
  end
  else
    pCardinal(p)^ := w;
end;

procedure SetDDWord(p: pbyte; ByteOrder: TByteOrder; w: int64);
var
  i: integer;
begin
  if ByteOrder = boBig then
  begin
    inc(p, 7);
    for i := 0 to 7 do
    begin
      p^ := w and $FF;
      w := w shr 8;
      dec(p);
    end;
  end
  else
    pInt64(p)^ := w;
end;

function RemoveEmptyStrings(S: string): string;
var
  SL: TStringList;
  i: integer;
begin
  SL := TStringList.Create;
  try
    SL.CommaText := S;
    for i := SL.Count - 1 downto 0 do
    begin
      if SL.Strings[i] = '' then
        SL.Delete(i);
    end;
    Result := SL.CommaText;
  finally
    SL.Free;
  end;
end;

function GetPtrSize(Name: string; Default: TPtrSize): TPtrSize;
var
  i: TPtrSize;
begin
  Result := Default;
  for i := low(TPtrSize) to high(TPtrSize) do
  begin
    if UpperCase(name) = UpperCase(PtrSizeName[i]) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function GetPtrSizeName(ps: TPtrSize): string;
begin
  if (ps < low(TPtrSize)) or (ps > high(TPtrSize)) then
    ps := ps32;
  Result := PtrSizeName[ps];
end;

function StrToCInt(S: string; var V: cardinal): boolean;
const
  DecDigits: set of char = ['0' .. '9'];
var
  E: integer;
begin
  Result := false;
  if S <> '' then
  begin
    if S[1] in DecDigits then
    begin
      if copy(S, 1, 2) = '0x' then
      begin
        S := '$' + copy(S, 3, Length(S) - 2);
      end;
      Val(S, V, E);
      Result := (E = 0);
    end
  end;
end;

function GetTempFile(const Extension: string): string;
var
  lpPathName: array [0 .. MAX_PATH] OF char;
  lpTempFileName: array [0 .. MAX_PATH] OF char;
begin
  GetTempPath(MAX_PATH - 1, lpPathName);
  GetTempFileName(lpPathName, '~', 0, lpTempFileName);
  Result := StrPas(lpTempFileName);
  Result := ChangeFileExt(Result, Extension);
end;

end.
