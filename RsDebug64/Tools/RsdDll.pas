unit RsdDll;

interface

uses
  Classes, Windows, Messages, SysUtils, Contnrs, Registry,
  GkStrUtils,
  ProgCfgUnit,
  Rsd64Definitions;

const
  stOk = 0;
  stError = 100;
  stNotOpen = 101;
  stUndefCommand = 102;
  stNoImpl = 217;

type
  TAccId = integer;
  TStatus = integer;

  PCmmDevice = ^TCmmDevice;

  TCmmDevice = class(TObject)
  private
    FID: TAccId;
    DllHandle: THandle;
    FConnected: boolean;
    FToTrnsSize: integer;
    ProgressHandle: THandle;
    FConnectStr: string;
  public
    constructor Create(AHandle: THandle; ConnectStr: string);
    destructor Destroy; override;
    function OpenDev: TStatus; virtual;
    function CloseDev: TStatus; virtual;
    function GetDevNr: byte;

    property ID: TAccId read FID;
    function GetErrStr(Code: TStatus; S: pAnsiChar; Max: integer): boolean; overload;
    function GetErrStr(Code: TStatus): string; overload;
    procedure SetProgress(Ev: integer; R: real);
    property Connected: boolean read FConnected;
    property ConnectStr: string read FConnectStr;

    function IsDevStrOk: boolean;

  public
    // funkcje podstawowe Modbusa
    function RdOutTable(RHan: THandle; var Buf; Adress: word; Count: word): TStatus;
    function RdInpTable(RHan: THandle; var Buf; Adress: word; Count: word): TStatus;
    function RdReg(RHan: THandle; var Buf; Adress: word; Count: word): TStatus;
    function RdAnalogInp(RHan: THandle; var Buf; Adress: word; Count: word): TStatus;
    function WrOutput(RHan: THandle; Adress: word; Val: boolean): TStatus;
    function WrReg(RHan: THandle; Adress: word; Val: word): TStatus;
    function WrMultiReg(RHan: THandle; var Buf; Adress: word; Count: word): TStatus;
    function ReadWriteRegs(RHan: THandle; var RdBuf; RdAdress: word; RdCount: word; const WrBuf; WrAdress: word;
      WrCount: word): TStatus;

    // Funkcje dodatkowe
    function ReadS(RHan: THandle; var S: string; var Vec: Cardinal): TStatus;
    function ReadDevMem(RHan: THandle; var Buffer; adr: Cardinal; size: Cardinal): TStatus;
    function ReadDevWord(RHan: THandle; adr: Cardinal; var w: word): TStatus;
    function ReadDevByte(RHan: THandle; adr: Cardinal; var w: byte): TStatus;

    function WriteDevMem(RHan: THandle; const Buffer; adr: Cardinal; size: Cardinal): TStatus;
    function WriteDWord(RHan: THandle; adr: Cardinal; w: Cardinal): TStatus;
    function WriteWord(RHan: THandle; adr: Cardinal; w: word): TStatus;
    function WriteByte(RHan: THandle; adr: Cardinal; w: byte): TStatus;

    function ReadCtrl(RHan: THandle; nr: byte; var b: byte): TStatus;
    function WriteCtrl(RHan: THandle; nr: byte; b: byte): TStatus;

    function GetDrvParamList(ToSet: boolean): string; stdcall;
    function SetDrvParam(ParamName, ParamValue: string): TStatus; stdcall;
    function GetDrvStatus(ParamName: string; var ParamValue: string): TStatus; stdcall;
    function TerminalSendKey(RHan: THandle; key: char): TStatus;
    function TerminalRead(RHan: THandle; var Buf; var rdcnt: integer): TStatus;
    function CheckTerminalValid: boolean;

    function isStdModbus: boolean;

  end;

  TCmmDevList = class(TObjectList)
  private
    function GetItem(Index: integer): TCmmDevice;
  public
    property Items[Index: integer]: TCmmDevice read GetItem;
    function FindDev(AId: TAccId): TCmmDevice;
  end;

  TCmmLibrary = class(TObject)
  private
    MemList: TObjectList;
    function FindMemoryObj(ptr: pointer): integer;
  public
    LibParams: TLibParams;
    // Working variables
    CmmHandle: THandle;
    FileName: string;
    LibProperty: string;
    LibID: integer;
    procedure SetLibProperty(txt: string);
    procedure SetLoggerHandle(H: THandle);
    procedure RegisterMe;
    function LibraryGetMemFunc(size: integer): pointer;
    function FreeLibMemory(ptr: pointer): boolean;
  end;

  TCmmLibraryList = class(TObjectList)
  private const
    LIB_ID_OFFEST = 100;
  private
    Me: TCmmLibraryList;
    function TryToAddLibrary(FName: string): boolean;
    function FGetItem(Index: integer): TCmmLibrary;
  public
    constructor Create;
    procedure ScanLibrary;
    property Items[Index: integer]: TCmmLibrary read FGetItem;
    procedure SetLoggerHandle(H: THandle);
    function FindLibraryByName(Name: string): THandle;
    function FindLibraryByLibID(LibID: integer): TCmmLibrary;
    function LibraryGetMemFunc(LibID: integer; size: integer): pointer;
    procedure LoadDriverList(LibList: TStrings);
  end;

var
  CmmLibraryList: TCmmLibraryList;
  CmmDevList: TCmmDevList;

procedure RsdSetLoggerHandle(H: THandle);
function LoadRsPorts: TStrings;

implementation

type
  TMemoryObj = class(TObject)
  private
    mMemory: pByte;
    mSize: integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AllocMemory(size: integer);
    class function AllocMemObject(size: integer): TMemoryObj;
  end;

type

  TLibIdentify = function: PGUID; stdcall;

  TGetLibProperty = function: pAnsiChar; stdcall;
  TSetLoggerHandle = procedure(H: THandle); stdcall;
  TGetDrvParamList = function(ToSet: boolean): pAnsiChar; stdcall;
  TSetGetMemFunction = procedure(LibID: integer; GetMemFunc: TGetMemFunction); stdcall;

  TGetErrStr = function(ID: TAccId; Code: TStatus; S: pAnsiChar; Max: integer): boolean; stdcall;
  TAddDev = function(ConnectStr: pAnsiChar): TAccId; stdcall;
  TDelDev = function(ID: TAccId): TStatus; stdcall;
  TOpenDev = function(ID: TAccId): TStatus; stdcall;
  TCloseDev = procedure(ID: TAccId); stdcall;

  TRegisterCallBackFun = function(ID: TAccId; CmmId: integer; CallBackFunc: TCallBackFunc): TStatus; stdcall;
  TSetBreakFlag = function(ID: TAccId; Val: boolean): TStatus; stdcall;

  TGetDrvStatus = function(ID: TAccId; ParamName: pAnsiChar; ParamValue: pAnsiChar; MaxRpl: integer): TStatus; stdcall;
  TSetDrvParam = function(ID: TAccId; ParamName: pAnsiChar; ParamValue: pAnsiChar): TStatus; stdcall;

  // funkcje podstawowe Modbusa
  TRdOutTable = function(ID: TAccId; var Buf; Adress: word; Count: word): TStatus; stdcall;
  TRdInpTable = function(ID: TAccId; var Buf; Adress: word; Count: word): TStatus; stdcall;
  TRdReg = function(ID: TAccId; var Buf; Adress: word; Count: word): TStatus; stdcall;
  TRdAnalogInp = function(ID: TAccId; var Buf; Adress: word; Count: word): TStatus; stdcall;
  TWrOutput = function(ID: TAccId; Adress: word; Val: word): TStatus; stdcall;
  TWrReg = function(ID: TAccId; Adress: word; Val: word): TStatus; stdcall;
  TWrMultiReg = function(ID: TAccId; var Buf; Adress: word; Count: word): TStatus; stdcall;
  TRdWrMultiReg = function(ID: TAccId; var RdBuf; RdAdress: word; RdCount: word; const WrBuf; WrAdress: word;
    WrCount: word): TStatus; stdcall;

  // odczyt, zapis pamiêci
  TReadMem = function(ID: TAccId; var Buffer; adr: Cardinal; size: Cardinal): TStatus; stdcall;
  TWriteMem = function(ID: TAccId; const Buffer; adr: Cardinal; size: Cardinal): TStatus; stdcall;

  // Terminal
  TTerminalSendKey = function(ID: TAccId; key: char): TStatus; stdcall;
  TTerminalRead = function(ID: TAccId; var Buffer; var rdcnt: integer): TStatus; stdcall;

  // obsoleted
  TReadS = function(ID: TAccId; var Sign; var Vec: Cardinal): TStatus; stdcall;
  TReadReg = function(ID: TAccId; var Buffer): TStatus; stdcall;
  TFillMem = function(ID: TAccId; adr: Cardinal; size: word; Sign: byte): TStatus; stdcall;
  TMoveMem = function(ID: TAccId; src: Cardinal; Des: Cardinal; size: word): TStatus; stdcall;
  TSemaforWr = function(ID: TAccId; nr: byte; b: byte): TStatus; stdcall;
  TSemaforRd = function(ID: TAccId; nr: byte; var b: byte): TStatus; stdcall;
  TGetDevNr = function(ID: TAccId): byte; stdcall;

function TCmmDevList.GetItem(Index: integer): TCmmDevice;
begin
  Result := inherited Items[Index] as TCmmDevice;
end;

function TCmmDevList.FindDev(AId: TAccId): TCmmDevice;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].FID = AId then
      Result := Items[i];
  end;
end;

procedure CallBackFunc(ID: TAccId; CmmId: integer; Ev: integer; R: real); stdcall;
var
  Dev: TCmmDevice;
begin
  Dev := CmmDevList.FindDev(ID);
  if Dev <> nil then
    Dev.SetProgress(Ev, R);
end;

constructor TCmmDevice.Create(AHandle: THandle; ConnectStr: string);
var
  _AddDev: TAddDev;
  _RegBeck: TRegisterCallBackFun;
  SL: TStringList;
  S: string;
  channel: integer;
  AnsiConnectStr: AnsiString;
begin
  inherited Create;
  ProgressHandle := AHandle;
  FConnectStr := ConnectStr;
  FID := -1;
  SL := TStringList.Create;
  try
    DllHandle := INVALID_HANDLE_VALUE;
    ExtractStrings([';'], [], pchar(ConnectStr), SL);
    if SL.Count > 0 then
    begin
      DllHandle := CmmLibraryList.FindLibraryByName(SL.Strings[0]);

      if DllHandle <> INVALID_HANDLE_VALUE then
      begin
        AnsiConnectStr := AnsiString(ConnectStr);
        @_AddDev := GetProcAddress(DllHandle, 'AddDev');
        if Assigned(_AddDev) then
          FID := _AddDev(pAnsiChar(AnsiConnectStr));
        _RegBeck := GetProcAddress(DllHandle, 'RegisterCallBackFun');
        if Assigned(_RegBeck) then
          _RegBeck(FID, Cardinal(TCmmDevice), CallBackFunc);
        if SL.Count > 3 then
        begin
          S := SL.Strings[3];
          if length(S) >= 1 then
          begin
            channel := ord(S[1]) - ord('A');
            if (channel >= 0) and (channel < 10) then
              FID := FID + channel;
          end;
        end;
        CmmDevList.Add(self);
      end;
    end;
  finally
    SL.free;
  end;
end;

destructor TCmmDevice.Destroy;
var
  _DelDev: TDelDev;
begin
  CmmDevList.Extract(self);
  @_DelDev := GetProcAddress(DllHandle, 'DelDev');
  if Assigned(_DelDev) then
    _DelDev(FID);
  inherited;
end;

function TCmmDevice.IsDevStrOk: boolean;
begin
  Result := (DllHandle <> INVALID_HANDLE_VALUE);
end;

function TCmmDevice.OpenDev: TStatus;
var
  _OpenDev: TOpenDev;
begin
  @_OpenDev := GetProcAddress(DllHandle, 'OpenDev');
  if Assigned(_OpenDev) then
  begin
    Result := _OpenDev(FID);
    FConnected := (Result = stOk);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.CloseDev: TStatus;
var
  _CloseDev: TCloseDev;
begin
  @_CloseDev := GetProcAddress(DllHandle, 'CloseDev');
  if Assigned(_CloseDev) then
    _CloseDev(FID);
  FConnected := False;
  Result := stOk;
end;

function TCmmDevice.GetDevNr: byte;
var
  _GetDevNr: TGetDevNr;
begin
  @_GetDevNr := GetProcAddress(DllHandle, 'GetDevNr');
  if Assigned(_GetDevNr) then
    Result := _GetDevNr(FID)
  else
    Result := 255;
end;

function TCmmDevice.isStdModbus: boolean;
var
  _RdOutTable: TRdOutTable;
  _RdInpTable: TRdInpTable;
  _RdReg: TRdReg;
  _RdAnalogInp: TRdAnalogInp;
  _WrOutput: TWrOutput;
  _WrReg: TWrReg;
  _WrMultiReg: TWrMultiReg;
begin
  if DllHandle <> 0 then
  begin
    @_RdOutTable := GetProcAddress(DllHandle, 'RdOutTable');
    @_RdInpTable := GetProcAddress(DllHandle, 'RdInpTable');
    @_RdReg := GetProcAddress(DllHandle, 'RdReg');
    @_RdAnalogInp := GetProcAddress(DllHandle, 'RdAnalogInp');
    @_WrOutput := GetProcAddress(DllHandle, 'WrOutput');
    @_WrReg := GetProcAddress(DllHandle, 'WrReg');
    @_WrMultiReg := GetProcAddress(DllHandle, 'WrMultiReg');
    Result := Assigned(_RdOutTable) and Assigned(_RdInpTable) and Assigned(_RdReg) and Assigned(_RdAnalogInp) and
      Assigned(_WrOutput) and Assigned(_WrReg) and Assigned(_WrMultiReg);
  end
  else
    Result := False;
end;

function TCmmDevice.RdOutTable(RHan: THandle; var Buf; Adress: word; Count: word): TStatus;
var
  _RdOutTable: TRdOutTable;
begin
  ProgressHandle := RHan;
  @_RdOutTable := GetProcAddress(DllHandle, 'RdOutTable');
  if Assigned(_RdOutTable) then
  begin
    Result := _RdOutTable(FID, Buf, Adress, Count);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.RdInpTable(RHan: THandle; var Buf; Adress: word; Count: word): TStatus;
var
  _RdInpTable: TRdInpTable;
begin
  ProgressHandle := RHan;
  @_RdInpTable := GetProcAddress(DllHandle, 'RdInpTable');
  if Assigned(_RdInpTable) then
  begin
    Result := _RdInpTable(FID, Buf, Adress, Count);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.RdReg(RHan: THandle; var Buf; Adress: word; Count: word): TStatus;
var
  _RdReg: TRdReg;
begin
  ProgressHandle := RHan;
  @_RdReg := GetProcAddress(DllHandle, 'RdReg');
  if Assigned(_RdReg) then
  begin
    Result := _RdReg(FID, Buf, Adress, Count);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.RdAnalogInp(RHan: THandle; var Buf; Adress: word; Count: word): TStatus;
var
  _RdAnalogInp: TRdAnalogInp;
begin
  ProgressHandle := RHan;
  @_RdAnalogInp := GetProcAddress(DllHandle, 'RdAnalogInp');
  if Assigned(_RdAnalogInp) then
  begin
    Result := _RdAnalogInp(FID, Buf, Adress, Count);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.WrOutput(RHan: THandle; Adress: word; Val: boolean): TStatus;
var
  _WrOutput: TWrOutput;
  w: word;
begin
  ProgressHandle := RHan;
  @_WrOutput := GetProcAddress(DllHandle, 'WrOutput');
  if Assigned(_WrOutput) then
  begin
    w := 0;
    if Val then
      w := 1;
    Result := _WrOutput(FID, Adress, w);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.WrReg(RHan: THandle; Adress: word; Val: word): TStatus;
var
  _WrReg: TWrReg;
begin
  ProgressHandle := RHan;
  @_WrReg := GetProcAddress(DllHandle, 'WrReg');
  if Assigned(_WrReg) then
  begin
    Result := _WrReg(FID, Adress, Val);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.WrMultiReg(RHan: THandle; var Buf; Adress: word; Count: word): TStatus;
var
  _WrMultiReg: TWrMultiReg;
begin
  ProgressHandle := RHan;
  @_WrMultiReg := GetProcAddress(DllHandle, 'WrMultiReg');
  if Assigned(_WrMultiReg) then
  begin
    Result := _WrMultiReg(FID, Buf, Adress, Count);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.ReadWriteRegs(RHan: THandle; var RdBuf; RdAdress: word; RdCount: word; const WrBuf; WrAdress: word;
  WrCount: word): TStatus;
var
  _RdWrMultiReg: TRdWrMultiReg;
begin
  ProgressHandle := RHan;
  @_RdWrMultiReg := GetProcAddress(DllHandle, 'RdWrMultiReg');
  if Assigned(_RdWrMultiReg) then
  begin
    Result := _RdWrMultiReg(FID, RdBuf, RdAdress, RdCount, WrBuf, WrAdress, WrCount);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.ReadS(RHan: THandle; var S: string; var Vec: Cardinal): TStatus;
var
  _ReadS: TReadS;
begin
  ProgressHandle := RHan;
  @_ReadS := GetProcAddress(DllHandle, 'ReadS');
  if Assigned(_ReadS) then
  begin
    FToTrnsSize := 20;
    setlength(S, 20);
    Result := _ReadS(FID, S[1], Vec);
    setlength(S, strlen(pchar(S)));
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.ReadDevMem(RHan: THandle; var Buffer; adr: Cardinal; size: Cardinal): TStatus;
var
  _ReadMem: TReadMem;
begin
  ProgressHandle := RHan;
  @_ReadMem := GetProcAddress(DllHandle, 'ReadMem');
  if Assigned(_ReadMem) then
  begin
    FToTrnsSize := size;
    Result := _ReadMem(FID, Buffer, adr, size);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.ReadDevWord(RHan: THandle; adr: Cardinal; var w: word): TStatus;
begin
  Result := ReadDevMem(RHan, w, adr, sizeof(w));
end;

function TCmmDevice.ReadDevByte(RHan: THandle; adr: Cardinal; var w: byte): TStatus;
begin
  Result := ReadDevMem(RHan, w, adr, sizeof(w));
end;

function TCmmDevice.WriteDevMem(RHan: THandle; const Buffer; adr: Cardinal; size: Cardinal): TStatus;
var
  _WriteMem: TWriteMem;
begin
  ProgressHandle := RHan;
  @_WriteMem := GetProcAddress(DllHandle, 'WriteMem');
  if Assigned(_WriteMem) then
  begin
    FToTrnsSize := size;
    Result := _WriteMem(FID, Buffer, adr, size);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.WriteDWord(RHan: THandle; adr: Cardinal; w: Cardinal): TStatus;
begin
  Result := WriteDevMem(RHan, w, adr, sizeof(w));
end;

function TCmmDevice.WriteWord(RHan: THandle; adr: Cardinal; w: word): TStatus;
begin
  Result := WriteDevMem(RHan, w, adr, sizeof(w));
end;

function TCmmDevice.WriteByte(RHan: THandle; adr: Cardinal; w: byte): TStatus;
begin
  Result := WriteDevMem(RHan, w, adr, sizeof(w));
end;

function TCmmDevice.WriteCtrl(RHan: THandle; nr: byte; b: byte): TStatus;
var
  _SemaforWr: TSemaforWr;
begin
  ProgressHandle := RHan;
  @_SemaforWr := GetProcAddress(DllHandle, 'WriteCtrl');
  if Assigned(_SemaforWr) then
  begin
    Result := _SemaforWr(FID, nr, b);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.ReadCtrl(RHan: THandle; nr: byte; var b: byte): TStatus;
var
  _SemaforRd: TSemaforRd;
begin
  ProgressHandle := RHan;
  @_SemaforRd := GetProcAddress(DllHandle, 'ReadCtrl');
  if Assigned(_SemaforRd) then
  begin
    Result := _SemaforRd(FID, nr, b);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.TerminalRead(RHan: THandle; var Buf; var rdcnt: integer): TStatus;
var
  _TerminalRead: TTerminalRead;
begin
  ProgressHandle := RHan;
  @_TerminalRead := GetProcAddress(DllHandle, 'TerminalRead');
  if Assigned(_TerminalRead) then
  begin
    Result := _TerminalRead(FID, Buf, rdcnt);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.TerminalSendKey(RHan: THandle; key: char): TStatus;
var
  _TerminalSendKey: TTerminalSendKey;
begin
  ProgressHandle := RHan;
  @_TerminalSendKey := GetProcAddress(DllHandle, 'TerminalSendKey');
  if Assigned(_TerminalSendKey) then
  begin
    Result := _TerminalSendKey(FID, key);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.CheckTerminalValid: boolean;
begin
  Result := (TerminalSendKey(INVALID_HANDLE_VALUE, #0) = stOk);
end;

function TCmmDevice.GetErrStr(Code: TStatus; S: pAnsiChar; Max: integer): boolean;
var
  _GetErrStr: TGetErrStr;
begin
  @_GetErrStr := GetProcAddress(DllHandle, 'GetErrStr');
  if Assigned(_GetErrStr) then
    Result := _GetErrStr(FID, Code, S, Max)
  else
    Result := False;
end;

function TCmmDevice.GetErrStr(Code: TStatus): string;
var
  txt: AnsiString;
begin
  if Code = stOk then
    Result := 'Ok'
  else if Code = stNoImpl then
    Result := 'Unknown function'
  else
  begin
    setlength(txt, 200);
    if GetErrStr(Code, pAnsiChar(txt), length(txt) - 1) then
    begin
      setlength(txt, strlen(pAnsiChar(txt)));
      Result := String(txt);
    end
    else
      Result := Format('ErrNr=%u', [Code]);
  end;
end;

function TCmmDevice.GetDrvParamList(ToSet: boolean): string; stdcall;
var
  _GetDrvParamList: TGetDrvParamList;
begin
  @_GetDrvParamList := GetProcAddress(DllHandle, 'GetDrvParamList');
  if Assigned(_GetDrvParamList) then
    Result := _GetDrvParamList(ToSet)
  else
    Result := '';
end;

function TCmmDevice.SetDrvParam(ParamName, ParamValue: string): TStatus; stdcall;
var
  _SetDrvParam: TSetDrvParam;
begin
  @_SetDrvParam := GetProcAddress(DllHandle, 'SetDrvParam');
  if Assigned(_SetDrvParam) then
    Result := _SetDrvParam(FID, pAnsiChar(ParamName), pAnsiChar(ParamValue))
  else
    Result := stNoImpl;
end;

function TCmmDevice.GetDrvStatus(ParamName: string; var ParamValue: string): TStatus; stdcall;
var
  _GetDrvStatus: TGetDrvStatus;
begin
  @_GetDrvStatus := GetProcAddress(DllHandle, 'GetDrvStatus');
  if Assigned(_GetDrvStatus) then
  begin
    setlength(ParamValue, 100);
    Result := _GetDrvStatus(FID, pAnsiChar(ParamName), pAnsiChar(ParamValue), length(ParamValue) - 1);
    setlength(ParamValue, strlen(pchar(ParamValue)));
  end
  else
    Result := stNoImpl;
end;

procedure TCmmDevice.SetProgress(Ev: integer; R: real);
var
  P: integer;
begin
  if (ProgressHandle <> INVALID_HANDLE_VALUE) then
  begin
    case Ev of
      0:
        begin
          P := round(10 * R);
          SendMessage(ProgressHandle, wm_TrnsProgress, P, 0);
        end;
      1:
        begin

        end;
      2:
        begin

        end;
      3:
        begin

        end;
      4:
        begin
          if R = 0 then
            SendMessage(ProgressHandle, wm_TrnsStartStop, 0, 0)
          else
            SendMessage(ProgressHandle, wm_TrnsStartStop, 1, 0);
        end;
    end;
  end;
end;

// ----- TMemoryObj ---------------------------------------------------------------------------------------------

constructor TMemoryObj.Create;
begin
  inherited;
  mMemory := nil;
  mSize := 0;
end;

destructor TMemoryObj.Destroy;
begin
  if Assigned(mMemory) then
    System.Freemem(mMemory);
  inherited;
end;

procedure TMemoryObj.AllocMemory(size: integer);
begin
  mSize := size;
  System.GetMem(mMemory, size);
end;

class function TMemoryObj.AllocMemObject(size: integer): TMemoryObj;
begin
  Result := TMemoryObj.Create;
  Result.AllocMemory(size);
end;


// ----- TCmmLibrary ---------------------------------------------------------------------------------------------

function LibGetMemFunction(LibID: integer; MemSize: integer): pointer; stdcall;
begin
  Result := CmmLibraryList.LibraryGetMemFunc(LibID, MemSize);
end;

procedure TCmmLibrary.RegisterMe;
var
  _GetLibProperty: TGetLibProperty;
  _SetGetMemFunction: TSetGetMemFunction;
  pLibProp: pAnsiChar;
begin
  @_SetGetMemFunction := GetProcAddress(CmmHandle, 'SetGetMemFunction');
  if Assigned(_SetGetMemFunction) then
  begin
    _SetGetMemFunction(LibID, LibGetMemFunction);
  end;

  @_GetLibProperty := GetProcAddress(CmmHandle, 'GetLibProperty');
  if Assigned(_GetLibProperty) then
  begin
    pLibProp := _GetLibProperty;
    SetLibProperty(String(pLibProp));
  end;
end;

function TCmmLibrary.LibraryGetMemFunc(size: integer): pointer;
var
  MemoryObj: TMemoryObj;
begin
  MemoryObj := TMemoryObj.AllocMemObject(size);
  MemList.Add(MemoryObj);
  Result := MemoryObj.mMemory;
end;

function TCmmLibrary.FindMemoryObj(ptr: pointer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to MemList.Count - 1 do
  begin
    if (MemList.Items[i] as TMemoryObj).mMemory = ptr then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TCmmLibrary.FreeLibMemory(ptr: pointer): boolean;
var
  idx: integer;
begin
  Result := False;
  idx := FindMemoryObj(ptr);
  if idx >= 0 then
  begin
    MemList.Delete(idx);
    Result := true;
  end;
end;

procedure TCmmLibrary.SetLibProperty(txt: string);
var
  lib: TLibPropertyBuilder;
begin
  LibProperty := txt;
  lib := TLibPropertyBuilder.Create;
  try
    lib.LoadFromTxt(txt);
    LibParams := lib.Params;
    lib.Params.ConnectionParams := nil;
  finally
    lib.free;
  end;
end;

procedure TCmmLibrary.SetLoggerHandle(H: THandle);
var
  _SetLoggerHandle: TSetLoggerHandle;
begin
  @_SetLoggerHandle := GetProcAddress(CmmHandle, 'SetLoggerHandle');
  if Assigned(_SetLoggerHandle) then
  begin
    _SetLoggerHandle(H);
  end;
end;

// ----- TCmmLibraryList ---------------------------------------------------------------------------------------------
constructor TCmmLibraryList.Create;
begin
  inherited;
  Me := self;
end;

function TCmmLibraryList.FGetItem(Index: integer): TCmmLibrary;
begin
  Result := inherited GetItem(index) as TCmmLibrary;
end;

procedure TCmmLibraryList.SetLoggerHandle(H: THandle);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    (Items[i] as TCmmLibrary).SetLoggerHandle(H);
end;

function TCmmLibraryList.FindLibraryByName(Name: string): THandle;
var
  i: integer;
begin
  Result := INVALID_HANDLE_VALUE;
  for i := 0 to Count - 1 do
  begin
    if (Items[i] as TCmmLibrary).LibParams.shortName = Name then
    begin
      Result := (Items[i] as TCmmLibrary).CmmHandle;
      break;
    end;
  end;
end;

function TCmmLibraryList.FindLibraryByLibID(LibID: integer): TCmmLibrary;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if (Items[i] as TCmmLibrary).LibID = LibID then
    begin
      Result := (Items[i] as TCmmLibrary);
      break;
    end;
  end;
end;

function TCmmLibraryList.LibraryGetMemFunc(LibID: integer; size: integer): pointer;
var
  lib: TCmmLibrary;
begin
  Result := nil;
  lib := FindLibraryByLibID(LibID);
  if Assigned(lib) then
    Result := lib.LibraryGetMemFunc(size);
end;

procedure TCmmLibraryList.LoadDriverList(LibList: TStrings);
var
  i: integer;
begin
  LibList.Clear;
  for i := 0 to Count - 1 do
  begin
    LibList.Add(Items[i].LibParams.shortName);
  end;
end;

function TCmmLibraryList.TryToAddLibrary(FName: string): boolean;
var
  H: THandle;
  _LibIdentify: TLibIdentify;
  pRdGuid: PGUID;
  CmmLibrary: TCmmLibrary;
begin
  Result := False;
  H := LoadLibrary(pchar(FName));

  @_LibIdentify := GetProcAddress(H, 'LibIdentify');
  if Assigned(_LibIdentify) then
  begin
    pRdGuid := _LibIdentify;
    if pRdGuid^ = CommLibGuid then
    begin
      CmmLibrary := TCmmLibrary.Create;
      CmmLibrary.CmmHandle := H;
      CmmLibrary.FileName := FName;
      CmmLibrary.LibID := LIB_ID_OFFEST + Count;
      Add(CmmLibrary);
      CmmLibrary.RegisterMe;

      Result := true;
    end;
  end;

end;

procedure TCmmLibraryList.ScanLibrary;
var
  Path: string;
  FName: string;
  F: TSearchRec;
  st: integer;
begin
  Path := ParamStr(0);
  Path := IncludeTrailingPathDelimiter(ExtractFilePath(Path));
  st := FindFirst(Path + '*.cmm64', faAnyFile, F);
  while st = 0 do
  begin
    FName := Path + F.Name;
    TryToAddLibrary(FName);
    st := FindNext(F);
  end;
  FindClose(F);
end;

function GetComNr(S: string): integer;
begin
  Result := StrToInt(copy(S, 4, length(S) - 3));
end;

function MyCompare(List: TStringList; Index1, Index2: integer): integer;
var
  nr1, nr2: integer;
begin
  nr1 := GetComNr(List.Strings[Index1]);
  nr2 := GetComNr(List.Strings[Index2]);
  Result := 0;
  if nr1 > nr2 then
    Result := 1;
  if nr1 < nr2 then
    Result := -1;
end;

function LoadRsPorts: TStrings;
var
  Reg: TRegistry;
  SL: TStringList;
  S: string;
  i: integer;
begin
  SL := TStringList.Create;
  Result := TStringList.Create;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly('\HARDWARE\DEVICEMAP\SERIALCOMM\') then
    begin
      Reg.GetValueNames(SL);
      for i := 0 to SL.Count - 1 do
      begin
        S := Reg.ReadString(SL.Strings[i]);
        Result.Add(S);
      end;
    end;
    (Result as TStringList).CustomSort(MyCompare);
  finally
    Reg.free;
    SL.free;
  end;
end;

procedure RsdSetLoggerHandle(H: THandle);
begin
  CmmLibraryList.SetLoggerHandle(H);
end;

initialization

CmmDevList := TCmmDevList.Create(False);
CmmLibraryList := TCmmLibraryList.Create;
CmmLibraryList.ScanLibrary;

finalization

FreeAndNil(CmmDevList);
FreeAndNil(CmmLibraryList);

end.
