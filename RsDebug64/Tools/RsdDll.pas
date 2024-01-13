unit RsdDll;

interface

uses
  Classes, Windows, Messages, SysUtils, Contnrs, Registry,
  GkStrUtils,
  ProgCfgUnit,
  System.JSON,
  Rsd64Definitions;

type
  TCmmDevice = class(TObject)
  private
    FID: TAccId;
    DllHandle: THandle;
    FConnected: boolean;
    FToTrnsSize: integer;
    ProgressHandle: THandle;
    FDriverName: string;
    SubGroups: TSubGroups;
    procedure FreeLibMemory(pch: pAnsiChar);
  public
    constructor Create(AHandle: THandle; ConnectParamJson: string);
    destructor Destroy; override;
    function OpenDev: TStatus; virtual;
    function CloseDev: TStatus; virtual;

    property ID: TAccId read FID;
    function GetErrStr(Code: TStatus; S: pAnsiChar; Max: integer): boolean; overload;
    function GetErrStr(Code: TStatus): string; overload;
    procedure SetProgress(Ev: integer; R: real);
    property Connected: boolean read FConnected;

    function IsDevReady: boolean;
    function getDriverName: string;

    function GetDrvParams: String;
    function SetDrvParams(jsonParams: string): TStatus;
    function GetDrvInfo: String;
  public
    // funkcje podstawowe Modbusa
    function isStdModbus: boolean;
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
    function isMemFunctions: boolean;
    function ReadDevMem(RHan: THandle; var Buffer; adr: Cardinal; size: Cardinal): TStatus;
    function WriteDevMem(RHan: THandle; const Buffer; adr: Cardinal; size: Cardinal): TStatus;

    // terminal
    function isTerminalFunctions: boolean;
    function TerminalSendKey(RHan: THandle; key: char): TStatus;
    function TerminalRead(RHan: THandle; var Buf; var rdcnt: integer): TStatus;
    function TerminalSetPipe(TerminalNr: integer; PipeHandle: THandle): TStatus;
    function TerminalSetRunFlag(TerminalNr: integer; RunFlag: boolean): TStatus;

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
    constructor Create;
    destructor Destroy; override;
    procedure SetLibProperty(txt: string);
    procedure SetLoggerHandle(H_WideChar, H_AnsiChar: THandle);
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
    procedure SetLoggerHandle(H_WideChar, H_AnsiChar: THandle);
    function FindLibraryByName(Name: string): TCmmLibrary;
    function FindLibraryByLibID(LibID: integer): TCmmLibrary;
    function FindLibraryByHandle(CmmHandle: THandle): TCmmLibrary;

    function LibraryGetMemFunc(LibID: integer; size: integer): pointer;
    procedure LoadDriverList(LibList: TStrings);
  end;

var
  CmmLibraryList: TCmmLibraryList;
  CmmDevList: TCmmDevList;

procedure RsdSetLoggerHandle(H_WideChar, H_AnsiChar: THandle);
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
  TSetLoggerHandle = procedure(H_WideChar, H_AnsiChar: THandle); stdcall;
  TSetGetMemFunction = procedure(LibID: integer; GetMemFunc: TGetMemFunction); stdcall;

  TGetErrStr = function(ID: TAccId; Code: TStatus; S: pAnsiChar; Max: integer): boolean; stdcall;
  TAddDev = function(ConnectStr: pAnsiChar): TAccId; stdcall;
  TDelDev = function(ID: TAccId): TStatus; stdcall;
  TOpenDev = function(ID: TAccId): TStatus; stdcall;
  TCloseDev = procedure(ID: TAccId); stdcall;

  TRegisterCallBackFun = function(ID: TAccId; CmmId: integer; CallBackFunc: TCallBackFunc): TStatus; stdcall;
  TSetBreakFlag = function(ID: TAccId; Val: boolean): TStatus; stdcall;

  TGetDrvInfo = function(ID: TAccId): pAnsiChar; stdcall;
  TGetDrvParams = function(ID: TAccId): pAnsiChar; stdcall;
  TSetDrvParams = function(ID: TAccId; jsonParams: pAnsiChar): TStatus; stdcall;

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
  TTerminalSetPipe = function(ID: TAccId; TerminalNr: integer; PipeHandle: THandle): TStatus; stdcall;
  TTerminalSetRunFlag = function(ID: TAccId; TerminalNr: integer; RunFlag: boolean): TStatus; stdcall;

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

constructor TCmmDevice.Create(AHandle: THandle; ConnectParamJson: string);
var
  _AddDev: TAddDev;
  _RegBeck: TRegisterCallBackFun;
  S: string;
  channel: integer;
  AnsiConnectStr: AnsiString;
  driverName: string;
  CmmLib: TCmmLibrary;
begin
  inherited Create;
  ProgressHandle := AHandle;
  FID := -1;
  DllHandle := INVALID_HANDLE_VALUE;
  FDriverName := '';

  if ExtractDriverName(ConnectParamJson, driverName) then
  begin
    FDriverName := driverName;
    CmmLib := CmmLibraryList.FindLibraryByName(driverName);
    if Assigned(CmmLib) then
    begin
      DllHandle := CmmLib.CmmHandle;
      SubGroups := CmmLib.LibParams.SubGroups;
      AnsiConnectStr := AnsiString(ConnectParamJson);
      @_AddDev := GetProcAddress(DllHandle, 'AddDev');
      if Assigned(_AddDev) then
        FID := _AddDev(pAnsiChar(AnsiConnectStr));
      if FID >= 0 then
      begin
        _RegBeck := GetProcAddress(DllHandle, 'RegisterCallBackFun');
        if Assigned(_RegBeck) then
          _RegBeck(FID, Cardinal(TCmmDevice), CallBackFunc);
        CmmDevList.Add(self);
      end;
    end;
  end
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

function TCmmDevice.getDriverName: string;
begin
  Result := FDriverName;
end;

function TCmmDevice.IsDevReady: boolean;
begin
  Result := (DllHandle <> INVALID_HANDLE_VALUE) and (FID >= 0);
end;

function TCmmDevice.OpenDev: TStatus;
var
  _OpenDev: TOpenDev;
begin
  Result := stNoImpl;
  if IsDevReady then
  begin
    @_OpenDev := GetProcAddress(DllHandle, 'OpenDev');
    if Assigned(_OpenDev) then
    begin
      Result := _OpenDev(FID);
    end;
  end;
  FConnected := (Result = stOk);
end;

function TCmmDevice.CloseDev: TStatus;
var
  _CloseDev: TCloseDev;
begin
  @_CloseDev := GetProcAddress(DllHandle, 'CloseDev');
  if Assigned(_CloseDev) then
    _CloseDev(FID);
  FConnected := false;
  Result := stOk;
end;

function TCmmDevice.isStdModbus: boolean;
begin
  Result := subMODBUS_STD in SubGroups;
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

function TCmmDevice.isMemFunctions: boolean;
begin
  Result := subMEMORY in SubGroups;
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

function TCmmDevice.TerminalSetPipe(TerminalNr: integer; PipeHandle: THandle): TStatus;
var
  _TerminalSetPipe: TTerminalSetPipe;
begin
  @_TerminalSetPipe := GetProcAddress(DllHandle, 'TerminalSetPipe');
  if Assigned(_TerminalSetPipe) then
  begin
    Result := _TerminalSetPipe(FID, TerminalNr, PipeHandle);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.TerminalSetRunFlag(TerminalNr: integer; RunFlag: boolean): TStatus;
var
  _TerminalSetRunFlag: TTerminalSetRunFlag;
begin
  @_TerminalSetRunFlag := GetProcAddress(DllHandle, 'TerminalSetRunFlag');
  if Assigned(_TerminalSetRunFlag) then
  begin
    Result := _TerminalSetRunFlag(FID, TerminalNr, RunFlag);
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

function TCmmDevice.isTerminalFunctions: boolean;
begin
  Result := subTERMINAL in SubGroups;
end;

function TCmmDevice.GetErrStr(Code: TStatus; S: pAnsiChar; Max: integer): boolean;
var
  _GetErrStr: TGetErrStr;
begin
  @_GetErrStr := GetProcAddress(DllHandle, 'GetErrStr');
  if Assigned(_GetErrStr) then
    Result := _GetErrStr(FID, Code, S, Max)
  else
    Result := false;
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

procedure TCmmDevice.FreeLibMemory(pch: pAnsiChar);
var
  CmmLibrary: TCmmLibrary;
begin
  CmmLibrary := CmmLibraryList.FindLibraryByHandle(DllHandle);
  if Assigned(CmmLibrary) then
    CmmLibrary.FreeLibMemory(pch)
  else
    raise Exception.Create('Library not found');
end;

function TCmmDevice.GetDrvParams: String;
var
  _GetDrvParams: TGetDrvParams;
  pch: pAnsiChar;
begin
  @_GetDrvParams := GetProcAddress(DllHandle, 'GetDrvParams');
  if Assigned(_GetDrvParams) then
  begin
    pch := _GetDrvParams(FID);
    Result := String(pch);
    FreeLibMemory(pch)
  end
  else
    Result := '';
end;

function TCmmDevice.SetDrvParams(jsonParams: string): TStatus;
var
  _SetDrvParams: TSetDrvParams;
  s1: AnsiString;
begin
  @_SetDrvParams := GetProcAddress(DllHandle, 'SetDrvParams');
  if Assigned(_SetDrvParams) then
  begin
    s1 := AnsiString(jsonParams);
    Result := _SetDrvParams(FID, pAnsiChar(s1))
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.GetDrvInfo: String;
var
  _GetDrvInfo: TGetDrvInfo;
  pch: pAnsiChar;
begin
  @_GetDrvInfo := GetProcAddress(DllHandle, 'GetDrvInfo');
  if Assigned(_GetDrvInfo) then
  begin
    pch := _GetDrvInfo(FID);
    Result := String(pch);
    FreeLibMemory(pch);
  end
  else
    Result := '';
end;

procedure TCmmDevice.SetProgress(Ev: integer; R: real);
var
  P: integer;
begin
  if (ProgressHandle <> INVALID_HANDLE_VALUE) then
  begin
    case Ev of
      evWorkOnOff:
        begin
          if R = 0 then
            SendMessage(ProgressHandle, wm_TrnsStartStop, 0, 0)
          else
            SendMessage(ProgressHandle, wm_TrnsStartStop, 1, 0);
        end;
      evProgress:
        begin
          P := round(10 * R);
          SendMessage(ProgressHandle, wm_TrnsProgress, P, 0);
        end;
      evFlow:
        begin
          SendMessage(ProgressHandle, wm_TrnsFlow, trunc(R), 0);

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

function GlobLibGetMemFunction(LibID: integer; MemSize: integer): pointer; stdcall;
begin
  Result := CmmLibraryList.LibraryGetMemFunc(LibID, MemSize);
end;

constructor TCmmLibrary.Create;
begin
  inherited;
  MemList := TObjectList.Create;
end;

destructor TCmmLibrary.Destroy;
begin
  inherited;
  MemList.Free;
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
    _SetGetMemFunction(LibID, GlobLibGetMemFunction);
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
  if Assigned(ptr) then
  begin
    Result := false;
    idx := FindMemoryObj(ptr);
    if idx >= 0 then
    begin
      MemList.Delete(idx);
      Result := true;
    end
    else
      raise Exception.Create('Memory to release not found');
  end
  else
    Result := true;
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
    lib.Free;
  end;
end;

procedure TCmmLibrary.SetLoggerHandle(H_WideChar, H_AnsiChar: THandle);
var
  _SetLoggerHandle: TSetLoggerHandle;
begin
  @_SetLoggerHandle := GetProcAddress(CmmHandle, 'SetLoggerHandle');
  if Assigned(_SetLoggerHandle) then
  begin
    _SetLoggerHandle(H_WideChar, H_AnsiChar);
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

procedure TCmmLibraryList.SetLoggerHandle(H_WideChar, H_AnsiChar: THandle);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    (Items[i] as TCmmLibrary).SetLoggerHandle(H_WideChar, H_AnsiChar);
end;

function TCmmLibraryList.FindLibraryByName(Name: string): TCmmLibrary;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if (Items[i] as TCmmLibrary).LibParams.driverName = Name then
    begin
      Result := (Items[i] as TCmmLibrary);
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

function TCmmLibraryList.FindLibraryByHandle(CmmHandle: THandle): TCmmLibrary;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if (Items[i] as TCmmLibrary).CmmHandle = CmmHandle then
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
    LibList.Add(Items[i].LibParams.driverName);
  end;
end;

function TCmmLibraryList.TryToAddLibrary(FName: string): boolean;
var
  H: THandle;
  _LibIdentify: TLibIdentify;
  pRdGuid: PGUID;
  CmmLibrary: TCmmLibrary;
begin
  Result := false;
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
  st := FindFirst(Path + '*.cmm2', faAnyFile, F);
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
    Reg.Free;
    SL.Free;
  end;
end;

procedure RsdSetLoggerHandle(H_WideChar, H_AnsiChar:  THandle);
begin
  CmmLibraryList.SetLoggerHandle(H_WideChar, H_AnsiChar);
end;

initialization

CmmDevList := TCmmDevList.Create(false);
CmmLibraryList := TCmmLibraryList.Create;
CmmLibraryList.ScanLibrary;

finalization

FreeAndNil(CmmDevList);
FreeAndNil(CmmLibraryList);

end.
