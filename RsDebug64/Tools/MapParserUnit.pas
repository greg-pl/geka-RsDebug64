unit MapParserUnit;

interface

uses
  SysUtils, Classes, Contnrs, Messages,
  ProgCfgUnit,
  CallProcessUnit;

type
  TChars = set of AnsiChar;

const
  TcknChar: TChars = ['0' .. '9', 'a' .. 'z', 'A' .. 'Z', '_', '$'];
  TcknCharDot: TChars = ['0' .. '9', 'a' .. 'z', 'A' .. 'Z', '_', '$', '.'];
  Spaces: TChars = [' ', #9];
  wm_ProcessEnd = wm_user + 100;

type

  TMapItem = class(TObject)
    ID: integer;
    Name: string;
    Adres: cardinal;
    Section: string;
    Size: integer; // -1 nie znana dlugoœæ
    function ToText: string;
    function IsNeeded(ShowVarCfg: TSectionsCfg): boolean;
    procedure CopyTo(M: TMapItem); virtual;
  end;

  TMapItemList = class(TObjectList)
  private
    function GetItem(Index: integer): TMapItem;
  public
    property Items[Index: integer]: TMapItem read GetItem;
    function FindItem(AName: string): TMapItem; overload;
    function FindItem(Adr: cardinal): TMapItem; overload;
    procedure LoadToList(SL: TStrings; ShowVarCfg: TSectionsCfg); overload;
    procedure LoadToList(Prefix: string; SL: TStrings; ShowVarCfg: TSectionsCfg); overload;
    procedure Add(Mapitem: TMapItem);
    procedure SetItemsSize;
  end;

  TTextInp = class(TStringList)
  private
    LnWsk: integer;
  public
    procedure Reset;
    procedure LoadFromFile(const FileName: string); override;
    function ReadLn: string;
    function Eof: boolean;
    function ScrollTo(Pattern: string): boolean;
  end;

  TMapParser = class(TObject)
  private
    TextInp: TTextInp;
    FFname: string;
    FFileSize: integer;
    FFileDate: TDateTime;
    FOnReloaded: TNotifyEvent;
    PipeToStrings: TPipeToStrings;
    FOwnHandle: THandle;

    function IsTocken(s: string; chars: TChars): boolean;
    function GetTocken(var ln: string; chars: TChars): string;

    procedure SaveMapFileInfo(FName: string);
    procedure GetMapFileInfo(FName: string; var AFileDate: TDateTime; var AFileSize: integer);
    function LoadGnuH8MapFile: boolean;
    function LoadToshibaMapFile: boolean;
    function LoadToshibaMapFile2: boolean;
    function LoadRsDebugUniMapFile: boolean;
    function LoadKeil51MapFile: boolean;
    function LoadElfFile(FName: string): boolean;
    procedure WndProc(var AMessage: TMessage);
    procedure wmProcessEnd(var AMessage: TMessage); message wm_ProcessEnd;

  public
    MapItemList: TMapItemList;
    constructor Create;
    destructor Destroy; override;
    function LoadMapFile(FName: string): boolean; overload;
    function LoadMapFile: boolean; overload;
    function NeedReload: boolean;
    property FileName: string read FFname;
    function StrToCInt(s: string; var V: cardinal): boolean;
    function StrToAdr(s: string): cardinal;
    property OnReloaded: TNotifyEvent read FOnReloaded write FOnReloaded;
    function GetVarAdress(VarName: string): cardinal;
    function IntToVarName(Adr: integer): string;
    function isLoaded: boolean;
  end;

var
  MapParser: TMapParser;

const
  UNKNOWN_ADRESS = $FFFFFFFF;

function RightCutStr(s: string; x: integer): string;
function LeftStr(s: string): string;
function GetTocken(var Tx: string): string;
function StrToIntChex(s: string): int64;

implementation

uses
  Main;

function StrToIntChex(s: string): int64;
begin
  if copy(s, 1, 2) = '0x' then
  begin
    s := '$' + copy(s, 3, length(s) - 2);
  end;
  Result := StrToInt64(s);
end;

function RightCutStr(s: string; x: integer): string;
var
  k: integer;
begin
  k := length(s);
  if k >= x then
    Result := Trim(copy(s, x, k - x + 1))
  else
    Result := '';
end;

function LeftStr(s: string): string;
var
  k: integer;
begin
  k := length(s);
  Result := '';
  while k > 0 do
  begin
    if s[k] in Spaces then
      break;
    Result := s[k] + Result;
    dec(k);
  end;
end;

function GetTocken(var Tx: string): string;
const
  IsSpace: set of char = [';', ' '];
var
  k: integer;
  i: integer;
begin
  k := length(Tx);
  for i := 1 to k do
  begin
    if not(Tx[i] in IsSpace) then
      break;
  end;
  if i <> 1 then
  begin
    Tx := RightCutStr(Tx, i);
    k := length(Tx);
  end;
  if Tx <> '' then
  begin
    for i := 1 to k do
    begin
      if Tx[i] in IsSpace then
        break;
    end;
    Result := copy(Tx, 1, i - 1);
    Tx := RightCutStr(Tx, i + 1);
  end
  else
    Result := '';
end;

function TMapItem.ToText: string;
begin
  Result := Format('%6X [%s]', [Adres, Name]);
end;

function TMapItem.IsNeeded(ShowVarCfg: TSectionsCfg): boolean;
  function isInSelectionList(sname: string): boolean;
  var
    i: integer;
    s: string;
    n: integer;
  begin
    Result := false;
    for i := 0 to ShowVarCfg.SelSections.Count - 1 do
    begin
      s := ShowVarCfg.SelSections.Strings[i];
      n := length(s);
      if n > 0 then
      begin
        if s[n] = '*' then
        begin
          if copy(s, 1, n - 1) = copy(sname, 1, n - 1) then
          begin
            Result := true;
            break;
          end;
        end
        else
        begin
          if s = sname then
          begin
            Result := true;
            break;
          end;
        end;
      end;
    end;
  end;

begin
  Result := true;
  case ShowVarCfg.SelSectionMode of
    secShowSelected:
      Result := isInSelectionList(Section);
    secHideSelected:
      Result := not(isInSelectionList(Section));
  end;
end;

procedure TMapItem.CopyTo(M: TMapItem);
begin
  M.Name := Name;
  M.Adres := Adres;
  M.Section := Section;
end;

function TMapItemList.GetItem(Index: integer): TMapItem;
begin
  Result := inherited Items[Index] as TMapItem;
end;

function TMapItemList.FindItem(AName: string): TMapItem;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].Name = AName then
    begin
      Result := Items[i];
      Exit;
    end;
  end;
end;

function TMapItemList.FindItem(Adr: cardinal): TMapItem;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].Adres = Adr then
    begin
      Result := Items[i];
      Exit;
    end;
  end;
end;

procedure TMapItemList.Add(Mapitem: TMapItem);
begin
  Mapitem.ID := Count + 1;
  inherited Add(Mapitem);
end;

procedure TMapItemList.LoadToList(SL: TStrings; ShowVarCfg: TSectionsCfg);
var
  i: integer;
  s: string;
begin
  SL.Clear;
  for i := 0 to Count - 1 do
  begin
    if Items[i].IsNeeded(ShowVarCfg) then
    begin
      s := Items[i].Name;
      SL.Add(s);
    end;
  end;
end;

procedure TMapItemList.LoadToList(Prefix: string; SL: TStrings; ShowVarCfg: TSectionsCfg);
var
  i: integer;
  n: integer;
  s, s1: string;

begin
  n := length(Prefix);
  SL.Clear;
  SL.BeginUpdate;
  try
    for i := 0 to Count - 1 do
    begin
      if Items[i].IsNeeded(ShowVarCfg) then
      begin
        s := Items[i].Name;
        s1 := copy(s, 1, n);
        if s1 = Prefix then
          SL.Add(copy(s, 1 + n, length(s) - n));
      end;
    end;
  finally
    SL.EndUpdate;
  end;
end;

function SortByAdressProc(Item1, Item2: Pointer): integer;
begin
  Result := 0;
  if TMapItem(Item1).Adres > TMapItem(Item2).Adres then
    Result := 1;
  if TMapItem(Item1).Adres < TMapItem(Item2).Adres then
    Result := -1;
end;

function SortByIDProc(Item1, Item2: Pointer): integer;
begin
  Result := 0;
  if TMapItem(Item1).ID > TMapItem(Item2).ID then
    Result := 1;
  if TMapItem(Item1).ID < TMapItem(Item2).ID then
    Result := -1;
end;

procedure TMapItemList.SetItemsSize;
var
  M: cardinal;
  i: integer;
begin
  Sort(SortByAdressProc);
  if Count > 0 then
    Items[Count - 1].Size := -1;
  if Count > 1 then
  begin
    for i := 0 to Count - 2 do
    begin
      M := Items[i + 1].Adres - Items[i].Adres;
      if M <= ProgCfg.MaxVarSize then
        Items[i].Size := M
      else
        Items[i].Size := -1;
    end;
  end;
  Sort(SortByIDProc);
end;

// ------------------  TMapParser  -----------------------------------------

procedure TTextInp.Reset;
begin
  LnWsk := 0;
end;

procedure TTextInp.LoadFromFile(const FileName: string);
begin
  inherited LoadFromFile(FileName);
  Reset;
end;

function TTextInp.ReadLn: string;
begin
  if LnWsk < Count then
  begin
    Result := Strings[LnWsk];
    inc(LnWsk);
  end
  else
    Result := '';
end;

function TTextInp.ScrollTo(Pattern: string): boolean;
var
  ln: string;
  x: integer;
begin

  Result := false;
  while not(Result) and not(Eof) do
  begin
    ln := ReadLn;
    x := pos(Pattern, ln);
    Result := (x <> 0);
  end;
end;

function TTextInp.Eof: boolean;
begin
  Result := (LnWsk = Count);
end;

// ------------------  TMapParser  -----------------------------------------
constructor TMapParser.Create;
begin
  inherited;
  MapItemList := TMapItemList.Create;
  TextInp := TTextInp.Create;
  PipeToStrings := TPipeToStrings.Create(true);
  FOwnHandle := Classes.AllocateHWnd(WndProc);
end;

destructor TMapParser.Destroy;
begin
  Classes.DeallocateHWnd(FOwnHandle);
  PipeToStrings.Free;
  MapItemList.Free;
  TextInp.Free;
  inherited;
end;

procedure TMapParser.WndProc(var AMessage: TMessage);
begin
  inherited;
  Dispatch(AMessage);
end;

procedure TMapParser.GetMapFileInfo(FName: string; var AFileDate: TDateTime; var AFileSize: integer);
var
  Strm: TFileStream;
begin
  if FileExists(FName) then
  begin
    AFileDate := FileDateToDateTime(FileAge(FName));
    Strm := TFileStream.Create(FName, fmOpenRead or fmShareDenyNone);
    try
      AFileSize := Strm.Size;
    finally
      Strm.Free;
    end;
  end
  else
  begin
    AFileDate := 0.0;
    AFileSize := 0;
  end;
end;

procedure TMapParser.SaveMapFileInfo(FName: string);
begin
  FFname := FName;
  GetMapFileInfo(FName, FFileDate, FFileSize);
end;

function TMapParser.NeedReload: boolean;
var
  AFileDate: TDateTime;
  AFileSize: integer;
begin
  GetMapFileInfo(FFname, AFileDate, AFileSize);
  NeedReload := (AFileDate <> FFileDate) or (AFileSize <> FFileSize);
end;

function TMapParser.IsTocken(s: string; chars: TChars): boolean;
var
  i: integer;
begin
  Result := true;
  for i := 1 to length(s) do
    Result := Result and (AnsiChar(s[i]) in chars);
end;

function TMapParser.GetTocken(var ln: string; chars: TChars): string;
var
  k: integer;
  i: integer;
begin
  k := length(ln);
  i := 1;
  while (i <= k) and (ln[i] in Spaces) do
    inc(i);
  Result := '';
  while (i <= k) and (ln[i] in chars) do
  begin
    Result := Result + ln[i];
    inc(i);
  end;
  ln := RightCutStr(ln, i)
end;

function TMapParser.LoadToshibaMapFile: boolean;
var
  Fnd: boolean;
  ln: string;
  s: string;
  x: integer;
  n: integer;
  Mapitem: TMapItem;
  AAdress: int64;
  CurrSect: string;
  Name: string;
begin
  Result := false;
  TextInp.Reset;
  Fnd := false;
  n := 0;
  while not(Fnd) and not(TextInp.Eof) and (n < 5) do
  begin
    ln := TextInp.ReadLn;
    x := pos('TOSHIBA CORPORATION', ln);
    Fnd := (x <> 0);
    inc(n);
  end;
  if not(Fnd) then
    Exit;
  Fnd := false;
  while not(Fnd) and not(TextInp.Eof) do
  begin
    ln := TextInp.ReadLn;
    x := pos('Symbol table for', ln);
    Fnd := (x <> 0);
  end;
  if not(Fnd) then
    Exit;
  ln := TextInp.ReadLn;
  ln := TextInp.ReadLn;

  CurrSect := '';
  while not(TextInp.Eof) do
  begin
    ln := TextInp.ReadLn;
    if length(ln) > 4 then
    begin
      x := pos('Input module :', ln);
      if x > 0 then
      begin
        CurrSect := RightCutStr(ln, 17);
      end
      else
      begin
        if copy(ln, 1, 4) = '    ' then
        begin
          ln := RightCutStr(ln, 5);
          Name := GetTocken(ln, TcknChar);
          if ln = '' then
          begin
            ln := TextInp.ReadLn;
          end;
          s := GetTocken(ln, TcknChar);
          if s = 'EXTDEF' then
          begin
            s := GetTocken(ln, TcknChar);
            try
              s := '$' + s;
              AAdress := StrToIntDef(s, -1);
              if IsTocken(Name, TcknChar) and (AAdress >= 0) then
              begin
                Mapitem := TMapItem.Create;
                Mapitem.Name := Name;
                Mapitem.Adres := AAdress;
                Mapitem.Section := CurrSect;
                MapItemList.Add(Mapitem);
              end;
            except

            end;
          end;
        end;
      end;
    end;
  end;
  Result := (MapItemList.Count <> 0);
end;

function TMapParser.LoadToshibaMapFile2: boolean;
var
  Fnd: boolean;
  ln: string;
  s: string;
  x: integer;
  n: integer;
  Mapitem: TMapItem;
  AAdress: int64;
  CurrSect: string;
  Name: string;
begin
  Result := false;
  TextInp.Reset;
  Fnd := false;
  n := 0;
  while not(Fnd) and not(TextInp.Eof) and (n < 5) do
  begin
    ln := TextInp.ReadLn;
    x := pos('Toshiba Unified Linkage Editor', ln);
    Fnd := (x <> 0);
    inc(n);
  end;
  if not(Fnd) then
    Exit;
  Fnd := false;
  while not(Fnd) and not(TextInp.Eof) do
  begin
    ln := TextInp.ReadLn;
    x := pos('Symbol table for', ln);
    Fnd := (x <> 0);
  end;
  if not(Fnd) then
    Exit;
  ln := TextInp.ReadLn;
  ln := TextInp.ReadLn;

  CurrSect := '';
  while not(TextInp.Eof) do
  begin
    ln := TextInp.ReadLn;
    if length(ln) > 4 then
    begin
      x := pos('Input module :', ln);
      if x > 0 then
      begin
        CurrSect := LeftStr(ln);
      end
      else
      begin
        if copy(ln, 1, 4) = '    ' then
        begin
          ln := RightCutStr(ln, 5);
          Name := GetTocken(ln, TcknCharDot);
          if ln = '' then
          begin
            ln := TextInp.ReadLn;
          end;
          s := GetTocken(ln, TcknCharDot);
          try
            if NAme = '' then
              Name := Name + ' ';
            s := '$' + s;
            AAdress := StrToIntDef(s, -1);
            if IsTocken(Name, TcknCharDot) and (AAdress >= 0) then
            begin
              Mapitem := TMapItem.Create;
              Mapitem.Name := Name;
              Mapitem.Adres := AAdress;
              Mapitem.Section := CurrSect;
              MapItemList.Add(Mapitem);
            end;
          except

          end;
        end;
      end;
    end;
  end;
  Result := (MapItemList.Count <> 0);
end;

function TMapParser.LoadGnuH8MapFile: boolean;
var
  Fin: boolean;
  ln: string;
  s: string;
  Mapitem: TMapItem;
  AAdress: int64;
  CurrSect: string;
begin
  TextInp.Reset;
  Result := TextInp.ScrollTo('Linker script and memory map');

  if not(Result) then
    Exit;

  Fin := false;
  CurrSect := '';
  while not(Fin) and not(TextInp.Eof) do
  begin
    ln := TextInp.ReadLn;
    if length(ln) > 42 then
    begin
      if copy(ln, 1, 16) = '                ' then
      begin
        try
          s := '$' + copy(ln, 19, 8);
          AAdress := cardinal(StrToIntDef(s, -1));
          s := copy(ln, 43, length(ln) - 42);
          if IsTocken(s, TcknChar) and (AAdress >= 0) then
          begin
            Mapitem := TMapItem.Create;
            Mapitem.Name := s;
            Mapitem.Adres := AAdress;
            Mapitem.Section := CurrSect;
            MapItemList.Add(Mapitem);
          end;
        except

        end;
      end
      else
      begin
        CurrSect := Trim(copy(ln, 1, 16));
      end;
    end;
    // x := pos('LOAD ',ln);
    // Fin := (x=1);
  end;
  ln := TextInp.ReadLn;
  Result := (MapItemList.Count <> 0);
end;

function TMapParser.LoadKeil51MapFile: boolean;
const
  SIGN = '* * * * * * *   D A T A   M E M O R Y   * * * * * * *';
  MemCodes: set of char = ['D', 'B', 'I', 'X', 'C'];
  BIT_NR: set of char = ['0' .. '7'];
var
  Fnd: boolean;
  ln: string;
  s: string;
  s1: string;
  x: integer;
  Mapitem: TMapItem;
  SL: TStringList;
  ch: char;
  DoAdd: boolean;
begin
  TextInp.Reset;
  Fnd := false;
  while not(Fnd) and not(TextInp.Eof) do
  begin
    ln := TextInp.ReadLn;
    x := pos(SIGN, ln);
    Fnd := (x <> 0);
  end;
  Result := Fnd;
  if not(Fnd) then
    Exit;

  SL := TStringList.Create;
  try
    while not(TextInp.Eof) do
    begin
      ln := TextInp.ReadLn;
      SL.CommaText := ln;
      if SL.Count >= 3 then
      begin
        s := SL[0];
        if (length(s) > 2) and (s[2] = ':') and (s[7] = 'H') and (s[1] in MemCodes) then
        begin
          ch := s[1];
          Mapitem := TMapItem.Create;
          DoAdd := true;
          s1 := copy(s, 3, 4);
          try
            Mapitem.Adres := StrToInt('$' + s1);
          except
            DoAdd := false;
          end;
          Mapitem.Name := SL.Strings[2];
          if SL.Strings[1] = 'LINE#' then
            DoAdd := false;
          case ch of
            'D':
              begin
                Mapitem.Section := 'DATA';
                if Mapitem.Adres >= $80 then
                  DoAdd := false;
              end;
            'I':
              begin
                Mapitem.Section := 'IDATA';
              end;
            'X':
              begin
                Mapitem.Adres := Mapitem.Adres + $10000;
                Mapitem.Section := 'XDATA';
              end;
            'C':
              begin
                Mapitem.Adres := Mapitem.Adres + $20000;
                Mapitem.Section := 'CODE';
              end;
            'B':
              begin
                if (s[8] = '.') and (s[9] in BIT_NR) then
                begin
                  Mapitem.Adres := 8 * (Mapitem.Adres - $20);
                  if Mapitem.Adres < $100 then
                  begin
                    inc(Mapitem.Adres, $100);
                    inc(Mapitem.Adres, cardinal(ord(s[9]) - ord('0')));
                  end
                  else
                    DoAdd := false;
                end
                else
                  DoAdd := false;
                Mapitem.Section := 'BIT';
              end;
          end;
          if DoAdd then
            MapItemList.Add(Mapitem)
          else
            Mapitem.Free;
        end;
      end;
    end;
  finally
    SL.Free;
  end;
  Result := (MapItemList.Count <> 0);
end;

function TMapParser.LoadRsDebugUniMapFile: boolean;
var
  ln: string;
  SL: TStringList;
  Adr: cardinal;
  ASize: cardinal;
  IName: string;
  Mapitem: TMapItem;
begin
  TextInp.Reset;
  ln := TextInp.ReadLn;
  Result := false;
  if ln = 'RSDEBUGER VAR LIST' then
  begin
    SL := TStringList.Create;
    SL.Delimiter := ';';
    try
      while not(TextInp.Eof) do
      begin
        ln := TextInp.ReadLn;
        SL.DelimitedText := ln;
        while SL.Count < 4 do
          SL.Add('');
        if StrToCInt(SL.Strings[0], Adr) and StrToCInt(SL.Strings[1], ASize) then
        begin
          IName := SL.Strings[2];
          Mapitem := TMapItem.Create;
          Mapitem.Name := IName;
          Mapitem.Adres := Adr;
          Mapitem.Section := SL.Strings[3];
          Mapitem.Size := ASize;
          MapItemList.Add(Mapitem);
        end;
      end;
    finally
      SL.Free;
    end;
  end;
end;

procedure TMapParser.wmProcessEnd(var AMessage: TMessage); // message ;
var
  SL: TStrings;
  Fnd: boolean;
  s1, s2, sx: string;
  Mapitem: TMapItem;
  x: integer;
begin
  if AMessage.LParam = -1 then
  begin
    SL := PipeToStrings.GetSL;
    TextInp.Clear;
    TextInp.AddStrings(SL);
    // SL.SaveToFile('SL._a');
    SL.Free;

    TextInp.Reset;
    Fnd := TextInp.ScrollTo('SYMBOL TABLE');
    if Fnd then
    begin
      while TextInp.Eof = false do
      begin
        Mapitem := TMapItem.Create;
        try
          s1 := TextInp.ReadLn;
          s2 := s1;
          // 08000e7c  w    F .text	00000002 USART2_IRQHandler
          {
            Mapitem.Adres := StrToUInt('$'+GetTocken(s1, TcknCharDot));
            GetTocken(s1, TcknCharDot);
            GetTocken(s1, TcknCharDot);
          }
          Mapitem.Adres := StrToUInt('$' + copy(s1, 1, 8));
          s1 := RightCutStr(s1, 18);

          Mapitem.Section := GetTocken(s1, TcknCharDot);
          Mapitem.Size := StrToUInt('$' + GetTocken(s1, TcknCharDot));
          Mapitem.Name := GetTocken(s1, TcknCharDot);
          MapItemList.Add(Mapitem);
        except
          Mapitem.Free;
          if ProgCfg.ShowUnknownMapLine then

            MainForm.NL_T(s2);
        end;

      end;

      if Assigned(FOnReloaded) then
        FOnReloaded(self);

    end;
  end;
end;

function TMapParser.LoadElfFile(FName: string): boolean;
var
  Param: string;
begin
  PipeToStrings.Clear;
  PipeToStrings.SetAsynch(FOwnHandle, wm_ProcessEnd);

  Param := '-t ' + FName;
  MainForm.NL_T('Map/Elf parser start');
  CallHideProcess(PipeToStrings.PipeIn, ProgCfg.ObjDumpPath, Param, ProgCfg.GetWorkingPath, false,true);
  MainForm.NL_T('Map/Elf parser stop');
end;

function TMapParser.LoadMapFile(FName: string): boolean;
var
  ext: string;
begin
  SaveMapFileInfo(FName);
  MapItemList.Clear;

  ext := ExtractFileExt(FName);
  if ext = '.elf' then
  begin
    Result := LoadElfFile(FName);
  end
  else
  begin
    TextInp.LoadFromFile(FName);
    Result := LoadRsDebugUniMapFile;
    if not(Result) then
      Result := LoadToshibaMapFile;
    if not(Result) then
      Result := LoadToshibaMapFile2;
    if not(Result) then
      Result := LoadGnuH8MapFile;
    if not(Result) then
      Result := LoadKeil51MapFile;
    if Result then
      MapItemList.SetItemsSize;
    if Assigned(FOnReloaded) then
      FOnReloaded(self);
  end;
end;

function TMapParser.LoadMapFile: boolean;
begin
  if FFname <> '' then
    Result := LoadMapFile(FFname)
  else
    Result := false;
end;

function TMapParser.isLoaded: boolean;
begin
  Result := (FFname <> '');
end;

function TMapParser.StrToCInt(s: string; var V: cardinal): boolean;
const
  DecDigits: set of char = ['0' .. '9'];
var
  E: integer;
begin
  Result := false;
  if s <> '' then
  begin
    if s[1] in DecDigits then
    begin
      if copy(s, 1, 2) = '0x' then
      begin
        s := '$' + copy(s, 3, length(s) - 2);
      end;
      Val(s, V, E);
      Result := (E = 0);
    end
  end;
end;

function TMapParser.StrToAdr(s: string): cardinal;
const
  DecDigits: set of char = ['0' .. '9'];
var
  MItem: TMapItem;
begin
  Result := UNKNOWN_ADRESS;
  if s <> '' then
  begin
    if s[1] in DecDigits then
    begin
      StrToCInt(s, Result);
    end
    else
    begin
      MItem := MapItemList.FindItem(s);
      if MItem <> nil then
        Result := MItem.Adres
    end;
  end;
end;

function TMapParser.GetVarAdress(VarName: string): cardinal;
var
  MItem: TMapItem;
begin
  MItem := MapItemList.FindItem(VarName);
  if MItem <> nil then
    Result := MItem.Adres
  else
    Result := UNKNOWN_ADRESS;
end;

function TMapParser.IntToVarName(Adr: integer): string;
var
  MItem: TMapItem;
begin
  MItem := MapItemList.FindItem(Adr);
  if MItem <> nil then
    Result := MItem.Name
  else
    Result := '0x' + InttoHex(Adr, 6);
end;

initialization

MapParser := TMapParser.Create;

finalization

FreeAndNil(MapParser);

end.
