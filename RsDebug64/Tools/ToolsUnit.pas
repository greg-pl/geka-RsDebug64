unit ToolsUnit;

interface
uses
  windows,SysUtils,Classes,ComCtrls,math,Grids,StdCtrls,CheckLst;

type
  TByteOrder = (boLittle, boBig);
  TPtrSize   = (ps8,ps16,ps32);
const
  ByteOrderName : array[TByteOrder] of string = ('L','B');
  PtrSizeName   : array[TPtrSize] of string = ('8bit','16bit','32bit');


function GetViewListColumnWidtsStr(ListView : TListView):string;
procedure SetViewListColumnWidts(ListView : TListView; S:string);

function GetGridColumnWidtsStr(Grid : TStringGrid):string;
procedure SetGridColumnWidts(Grid : TStringGrid; S:string);
procedure AddToList(Combo : TComboBox);
function GetChckedAsString(Box : TCheckListBox):string;
procedure SetChckedFromString(Box : TCheckListBox; s : string);
function GetPointerAsString(Box : TCheckListBox):string;
procedure SetPointerFromString(Box : TCheckListBox; s : string);
function GetWord(p : pbyte; ByteOrder: TByteOrder): word;
function GetDWord(p : pbyte; ByteOrder: TByteOrder): cardinal;
function GetDDWord(p : pbyte; ByteOrder: TByteOrder): int64;
procedure SetWord(p : pbyte; ByteOrder: TByteOrder; w: word);
procedure SetDWord(p : pbyte; ByteOrder: TByteOrder; w: cardinal);
procedure SetDDWord(p : pbyte; ByteOrder: TByteOrder; w: int64);
function RemoveEmptyStrings(s : string):string;
function DSwap(D : cardinal):cardinal;
function GetPtrSize(Name : string; Default : TPtrSize):TPtrSize;
function GetPtrSizeName(ps : TPtrSize):string;
function  StrToCInt(s :string; var V :cardinal): boolean;
function  GetTempFile(const Extension: string): string;




implementation

function GetViewListColumnWidtsStr(ListView : TListView):string;
var
  SL :TStringList;
  i  : integer;
  A  : integer;
begin
  SL :=TStringList.Create;
  try
    for i:=0 to ListView.Columns.Count-1 do
    begin
      A:=ListView.Column[i].Width;
      SL.Add(IntToStr(A));
    end;
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

procedure SetViewListColumnWidts(ListView : TListView; S:string);
var
  SL :TStringList;
  i  : integer;
  A  : integer;
  N  : integer;
begin
  SL :=TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    SL.DelimitedText := S;
    N := Min(ListView.Columns.Count,Sl.Count);
    for i:=0 to N-1 do
    begin
      A := StrToIntDef(SL.Strings[i],50);
      ListView.Column[i].Width := A;
    end;
  finally
    SL.Free;
  end;
end;

function GetGridColumnWidtsStr(Grid : TStringGrid):string;
var
  SL :TStringList;
  i  : integer;
  A  : integer;
begin
  SL :=TStringList.Create;
  try
    for i:=0 to Grid.ColCount-2 do
    begin
      A:=Grid.ColWidths[i+1];
      SL.Add(IntToStr(A));
    end;
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

procedure SetGridColumnWidts(Grid : TStringGrid; S:string);
var
  SL :TStringList;
  i  : integer;
  A  : integer;
  N  : integer;
begin
  SL :=TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.QuoteChar := '"';
    SL.DelimitedText := S;
    N := Min(Grid.ColCount-1,Sl.Count);
    for i:=0 to N-1 do
    begin
      A := StrToIntDef(SL.Strings[i],50);
      Grid.ColWidths[i+1] := A;
    end;
  finally
    SL.Free;
  end;
end;

procedure AddToList(Combo : TComboBox);
var
  k : integer;
  s : string;
begin
  s := Combo.Text;
  k := Combo.Items.IndexOf(s);
  if k>=0 then
    Combo.Items.Delete(k);
  Combo.Items.Insert(0,s);
  Combo.Text := s;
end;

function GetChckedAsString(Box : TCheckListBox):string;
var
  SL : TStringList;
  i  : integer;
begin
  SL := TStringList.Create;
  try
    for i:= 0 to Box.Count-1  do
    begin
      if Box.Checked[i] then SL.Add('1')
                        else SL.Add('0');
    end;
    Result := Sl.CommaText;
  finally
    SL.Free;
  end;
end;

procedure SetChckedFromString(Box : TCheckListBox; s : string);
var
  SL : TStringList;
  i  : integer;
begin
  SL := TStringList.Create;
  try
    Sl.CommaText := S;
    for i:= 0 to Box.Count-1  do
    begin
      if i<SL.Count then
        Box.Checked[i]:= (Sl.Strings[i]='1')
      else
        Box.Checked[i]:= false;
    end;
  finally
    SL.Free;
  end;
end;


function GetPointerAsString(Box : TCheckListBox):string;
var
  SL : TStringList;
  i  : integer;
begin
  SL := TStringList.Create;
  try
    for i:= 0 to Box.Count-1  do
    begin
      SL.Add('$'+IntTohex(Cardinal(Box.Items.Objects[i]),6));
    end;
    Result := Sl.CommaText;
  finally
    SL.Free;
  end;
end;

procedure SetPointerFromString(Box : TCheckListBox; s : string);
var
  SL : TStringList;
  i  : integer;
begin
  SL := TStringList.Create;
  try
    Sl.CommaText := S;
    for i:= 0 to Box.Count-1  do
    begin
      if i<SL.Count then
        Box.Items.Objects[i] := Pointer(StrToInt(Sl.Strings[i]))
      else
        Box.Items.Objects[i] := nil;
    end;
  finally
    SL.Free;
  end;
end;

function GetWord(p : pbyte; ByteOrder: TByteOrder): word;
begin
  if ByteOrder=boBig then
  begin
    Result := (P^) shl 8;
    inc(P);
    Result  := result or P^;
  end
  else
    Result := pWord(P)^;
end;

function GetDWord(p : pbyte; ByteOrder: TByteOrder): cardinal;
begin
  if ByteOrder=boBig then
  begin
    Result := (P^) shl 24;
    inc(P);
    Result := Result or ((P^) shl 16);
    inc(P);
    Result := Result or ((P^) shl 8);
    inc(P);
    Result  := Result or P^;
  end
  else
    Result  := pCardinal(P)^;
end;

function DSwap(D : cardinal):cardinal;
begin
  Result := ((D shr 24) and $000000ff) or
            ((D shr 8)  and $0000ff00) or
            ((D shl 8)  and $00ff0000) or
            ((D shl 24) and $ff000000);
end;

function GetDDWord(p : pbyte; ByteOrder: TByteOrder): int64;
var
  i : integer;
begin
  if ByteOrder=boBig then
  begin
    Result := 0;
    for i:=0 to 7 do
    begin
      Result := Result shl 8;
      Result := Result or P^;
      inc(p);
    end;
  end
  else
    Result  := pInt64(P)^;
end;

procedure SetWord(p : pbyte; ByteOrder: TByteOrder; w: word);
begin
  if ByteOrder=boBig then
  begin
    P^ := byte(w shr 8);
    inc(P);
    P^ := byte(w);
  end
  else
    pWord(P)^ := w;
end;

procedure SetDWord(p : pbyte; ByteOrder: TByteOrder; w: cardinal);
begin
  if ByteOrder=boBig then
  begin
    P^ := byte(w shr 24);
    inc(P);
    P^ := byte(w shr 16);
    inc(P);
    P^ := byte(w shr 8);
    inc(P);
    P^ := byte(w);
  end
  else
    pCardinal(P)^ := w;
end;

procedure SetDDWord(p : pbyte; ByteOrder: TByteOrder; w: int64);
var
  i : integer;
begin
  if ByteOrder=boBig then
  begin
    inc(p,7);
    for i:=0 to 7 do
    begin
      P^ := w and $ff;
      w := w shr 8;
      dec(p);
    end;
  end
  else
    pInt64(P)^ := w;
end;

function RemoveEmptyStrings(s : string):string;
var
  SL : TStringList;
  i  : integer;
begin
  SL := TStringList.Create;
  try
    SL.CommaText :=s;
    for i:= SL.Count-1 downto 0 do
    begin
      if SL.Strings[i]='' then
        SL.Delete(i);
    end;
    Result := SL.CommaText;
  finally
    SL.Free;
  end;
end;

function GetPtrSize(Name : string; Default : TPtrSize):TPtrSize;
var
  i : TPtrSize;
begin
  Result := Default;
  for i:=low(TPtrSize) to high(TPtrSize) do
  begin
    if UpperCase(name) = UpperCase(PtrSizeName[i]) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function GetPtrSizeName(ps : TPtrSize):string;
begin
  if  (ps<low(TPtrSize)) or (ps>high(TPtrSize)) then
    ps := ps32;
  result := PtrSizeName[ps];
end;


function  StrToCInt(s :string; var V :cardinal): boolean;
const
  DecDigits : set of char = ['0'..'9'];
var
  E     : integer;
begin
  Result := false;
  if s<>'' then
  begin
    if s[1] in DecDigits then
    begin
      if copy(s,1,2)='0x' then
      begin
        s := '$'+Copy(s,3,length(s)-2);
      end;
      Val(S, V, E);
      Result :=  (E = 0);
    end
  end;
end;


function GetTempFile(const Extension: string): string;
var
   Buffer: array[0..MAX_PATH] OF Char;
begin
  GetTempPath(Sizeof(Buffer)-1,Buffer);
  GetTempFileName(Buffer,'~',0,Buffer);
  result := StrPas(Buffer);
  Result := ChangeFileExt(Result,Extension);
end;

end.
