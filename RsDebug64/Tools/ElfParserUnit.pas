unit ElfParserUnit;

interface

uses
  SysUtils, Classes, Winapi.Windows;

type
  TMsg = procedure(txt: string) of object;
function ElfParse(Msg: TMsg; FName: string): boolean;

implementation

type
  TELFHeader = packed record
    EI_MAG0: cardinal;
    EI_CLASS: byte;
    EI_DATA: byte;
    EI_VERSION: byte;
    EI_OSABI: byte;
    EI_ABIVERSION: byte;
    EI_PAD: array [0 .. 7 - 1] of byte;
    e_type: word;
    e_machine: word;
    e_version: cardinal;
    e_entry: cardinal;
    e_phoff: cardinal;
    e_shoff: cardinal;
    e_flags: cardinal;
    e_ehsize: word;
    e_phentsize: word;
    e_phnum: word;
    e_shentsize: word;
    e_shnum: word;
    e_shstrndx: word;
    procedure dump(Msg: TMsg);
  end;

procedure TELFHeader.dump(Msg: TMsg);
begin
  Msg(Format('sizeof(TELFHeader): 0x%X', [sizeof(TELFHeader)]));
  Msg(Format('EI_MAG0: 0x%8X', [EI_MAG0]));
  Msg(Format('EI_CLASS:%u', [EI_CLASS]));
  Msg(Format('EI_DATA:%u', [EI_DATA]));
  Msg(Format('EI_VERSION:%u', [EI_VERSION]));
  Msg(Format('EI_OSABI: %u', [EI_OSABI]));
  Msg(Format('EI_ABIVERSION: %u', [EI_ABIVERSION]));
  // EI_PAD: array [0 .. 7 - 1] of byte;
  Msg(Format('e_type: %u', [e_type]));
  Msg(Format('e_machine: 0x%X', [e_machine]));
  Msg(Format('e_version: %u', [e_version]));
  Msg(Format('e_entry: %u (0x%X)', [e_entry, e_entry]));
  Msg(Format('e_phoff: %u (0x%X)', [e_phoff, e_phoff]));
  Msg(Format('e_shoff: %u (0x%X) Points to the start of the section header table.', [e_shoff, e_shoff]));
  Msg(Format('e_flags: %u (0x%X)', [e_flags, e_flags]));
  Msg(Format('e_ehsize: %u', [e_ehsize]));
  Msg(Format('e_phentsize: %u (Size of a program header table entry.)', [e_phentsize]));
  Msg(Format('e_phnum: %u (Number of entries in the program header table.)', [e_phnum]));
  Msg(Format('e_shentsize: %u (Size of a section header table entry.)', [e_shentsize]));
  Msg(Format('e_shnum: %u (The number of entries in the section header table.)', [e_shnum]));
  Msg(Format('e_shstrndx: %u (index of the section header table entry that contains the section names.)',
    [e_shstrndx]));
  Msg('-----------------');
end;

type
  TGetSysString = function(StrOfs: integer): string of object;

  TSectionHeader = packed record
    sh_name: cardinal;
    sh_type: cardinal;
    sh_flags: cardinal;
    sh_addr: cardinal;
    sh_offset: cardinal;
    sh_size: cardinal;
    sh_link: cardinal;
    sh_info: cardinal;
    sh_addralign: cardinal;
    sh_entsize: cardinal;
    procedure load(Var data);
    procedure dump(Msg: TMsg; GetSysString: TGetSysString);
    procedure dump2(Msg: TMsg; GetSysString: TGetSysString; Mem: TBytes);
    procedure SaveToFile(Mem: TBytes; SName: string);
  end;

procedure TSectionHeader.load(var data);
begin
  move(data, self, sizeof(self));
end;

procedure TSectionHeader.dump(Msg: TMsg; GetSysString: TGetSysString);
begin
  Msg(Format('sh_name: %u  %s', [sh_name, GetSysString(sh_name)]));
  Msg(Format('sh_type: %X', [sh_type]));
  Msg(Format('sh_flags: 0x%.8X', [sh_flags]));
  if sh_addr <> 0 then
    Msg(Format('sh_addr: 0x%.8X', [sh_addr]));
  Msg(Format('sh_offset: %u (0x%X)', [sh_offset, sh_offset]));
  Msg(Format('sh_size: %u', [sh_size]));
  if sh_link <> 0 then
    Msg(Format('sh_link: %u', [sh_link]));
  if sh_info <> 0 then
    Msg(Format('sh_info: 0x%.8X', [sh_info]));
  Msg(Format('sh_addralign: %u', [sh_addralign]));
  if sh_entsize <> 0 then
    Msg(Format('sh_entsize: %u', [sh_entsize]));
  Msg('-----------------');

end;

procedure TSectionHeader.dump2(Msg: TMsg; GetSysString: TGetSysString; Mem: TBytes);
var
  SName: string;
  AddrText: string;
begin
  SName := GetSysString(sh_name);
  AddrText := '          ';
  if sh_addr <> 0 then
    AddrText := Format('0x%.8X', [sh_addr]);

  Msg(Format('0x%.8X %20s %8u %8u %8u %s', [sh_type, SName, sh_offset, sh_size, sh_offset + sh_size, AddrText]));
  SaveToFile(Mem, SName);
end;

procedure TSectionHeader.SaveToFile(Mem: TBytes; SName: string);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.Write(Mem[sh_offset], sh_size);
    Stream.SaveToFile('Sections/Sec_' + SName + '.bin');
  finally
    Stream.Free;
  end;
end;

const
  SHT_STRTAB = $03;

type

  TElfParser = class(TObject)
    FMsg: TMsg;
    Mem: TBytes;

    SecNamesSL: TStringList;
    NamesSL: TStringList;
    SectionNameOffset: cardinal;
    SecNamesHeader: TSectionHeader;
    NamesHeader: TSectionHeader;

    ELFHeader: TELFHeader;
    procedure StartSectionNames;
    procedure DumpSections;
    procedure LoadStringTab;
    procedure LoadStringSection(SHeader: TSectionHeader; SL: TStrings);
    function GetStringAt(adr: cardinal): string; overload;
    function GetStringAt(SHeader: TSectionHeader; var ofs: integer): string; overload;
    function GetSectionName(StrOfs: integer): string;
    function GetSecHeaderByName(var Header: TSectionHeader; Name: string): boolean;

  private
    constructor Create(Msg: TMsg);
    destructor Destroy; override;
    function LoadFile(FName: string): boolean;
    function Parse(FName: string): boolean;

  end;

constructor TElfParser.Create(Msg: TMsg);
var
  i: integer;
begin
  inherited Create;
  FMsg := Msg;
  SecNamesSL := TStringList.Create;
  NamesSL := TStringList.Create;
end;

destructor TElfParser.Destroy;
var
  i: integer;
begin
  inherited;
  SecNamesSL.Free;
  NamesSL.Free;
end;

function TElfParser.LoadFile(FName: string): boolean;
var
  Stream: TMemoryStream;
begin
  Result := false;
  Stream := TMemoryStream.Create;
  try
    Stream.LoadFromFile(FName);
    SetLength(Mem, Stream.Size);
    Stream.Read(Mem[0], Stream.Size);
    Result := true;
  finally
    Stream.Free;
  end;
end;

function TElfParser.GetStringAt(adr: cardinal): string;
var
  L1: integer;
  txt: AnsiString;
begin
  L1 := StrLen(PAnsiChar(@Mem[adr]));
  if L1 > 0 then
  begin
    SetLength(txt, L1);
    move(Mem[adr], txt[1], L1);
  end
  else
    txt := '';
  Result := String(txt);
end;

function TElfParser.GetStringAt(SHeader: TSectionHeader; var ofs: integer): string;
var
  L1: integer;
begin
  Result := GetStringAt(SHeader.sh_offset + ofs);
  ofs := ofs + Length(Result) + 1;
end;

function TElfParser.GetSectionName(StrOfs: integer): string;
begin
  Result := GetStringAt(SectionNameOffset + StrOfs);
end;

function TElfParser.GetSecHeaderByName(var Header: TSectionHeader; Name: string): boolean;
var
  i: integer;
  SHeader: TSectionHeader;
  adr: cardinal;
  SName: string;
begin
  Result := false;
  adr := ELFHeader.e_shoff;
  for i := 0 to ELFHeader.e_shnum - 1 do
  begin
    SHeader.load(Mem[adr]);
    SName := GetSectionName(SHeader.sh_name);
    if Name = SName then
    begin
      Header := SHeader;
      Result := true;
      break;
    end;
    inc(adr, sizeof(TSectionHeader));
  end;
end;

procedure TElfParser.LoadStringSection(SHeader: TSectionHeader; SL: TStrings);
var
  Size: cardinal;
  txt: AnsiString;
  ofs: integer;
  i: integer;
begin
  Size := SHeader.sh_size;
  ofs := 0;
  i := 0;
  while ofs < Size do
  begin
    txt := GetStringAt(SHeader, ofs);
    // FMsg(Format('%u. %u %s', [i, ofs, txt]));
    if Assigned(SL) then
      SL.Add(txt);
    inc(i);
  end;
end;

procedure TElfParser.LoadStringTab;
var
  i: integer;
  SHeader: TSectionHeader;
  adr: cardinal;
  SL: TStringList;
begin
  adr := ELFHeader.e_shoff;
  for i := 0 to ELFHeader.e_shnum - 1 do
  begin
    SHeader.load(Mem[adr]);
    if SHeader.sh_type = SHT_STRTAB then
    begin
      if i = ELFHeader.e_shstrndx then
      begin
        SL := SecNamesSL;
        SecNamesHeader := SHeader;
      end
      else
      begin
        SL := NamesSL;
        NamesHeader := SHeader;
      end;
      LoadStringSection(SHeader, SL);
    end;
    inc(adr, sizeof(TSectionHeader));
  end;
end;

procedure TElfParser.DumpSections;
var
  i: integer;
  SHeader: TSectionHeader;
  adr: cardinal;
begin
  FMsg(Format('sizeof(TSectionHeader): 0x%X', [sizeof(TSectionHeader)]));

  adr := ELFHeader.e_shoff;
  for i := 0 to ELFHeader.e_shnum - 1 do
  begin
    SHeader.load(Mem[adr]);
    SHeader.dump2(FMsg, GetSectionName, Mem);
    inc(adr, sizeof(TSectionHeader));
  end;
end;

procedure TElfParser.StartSectionNames;
var
  ofs: cardinal;
  SHeader: TSectionHeader;
begin
  ofs := ELFHeader.e_shoff + sizeof(TSectionHeader) * ELFHeader.e_shstrndx;
  SHeader.load(Mem[ofs]);
  SectionNameOffset := SHeader.sh_offset
end;

function TElfParser.Parse(FName: string): boolean;
var
  Header: TSectionHeader;
  SL: TStringList;
begin
  if LoadFile(FName) then
  begin
    move(Mem[0], ELFHeader, sizeof(TELFHeader));
    StartSectionNames;

    ELFHeader.dump(FMsg);
    // LoadStringTab;
    DumpSections;

    SL := TStringList.Create;
    try
      if GetSecHeaderByName(Header, '.debug_str') then
      begin
        LoadStringSection(Header, SL);
        SL.SaveToFile('Sections/debug_str.txt');
      end;
    finally
      SL.Free;
    end;
  end;
end;

function ElfParse(Msg: TMsg; FName: string): boolean;
var
  ElfParser: TElfParser;
begin
  ElfParser := TElfParser.Create(Msg);
  try
    ElfParser.Parse(FName);
  finally
    ElfParser.Free;
  end;
end;

end.
