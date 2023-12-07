unit RsdDll;

interface

uses
  Classes, Windows, Messages,SysUtils,Contnrs,
  GkStrUtils,
  ProgCfgUnit;

const
  stOk              = 0;
  stError           = 100;
  stNotOpen         = 101;
  stUndefCommand    = 102;
  stNoImpl          = 217;

type
  TAccId    = integer;
  TStatus   = integer;

  PCmmDevice = ^TCmmDevice;
  TCmmDevice = class(TObject)
  private
    FID        : TAccId;
    DllHandle  : THandle;
    FConnected : boolean;
    FToTrnsSize: integer;
    ProgressHandle : THandle;
    FConnectStr    : string;
    function FGetIsNet : boolean;
  public
    constructor Create(AHandle : THandle; ConnectStr : string);
    destructor Destroy; override;
    function  OpenDev:TStatus; virtual;
    function  CloseDev:TStatus; virtual;
    function  GetDevNr: byte;
    function  SetLoggerHandle(LogerHandle : THandle):TStatus;

    property  ID : TAccID read FID;
    function  GetErrStr(Code : TStatus;S : pAnsiChar; Max: integer): boolean; overload;
    function  GetErrStr(Code : TStatus): string; overload;
    procedure SetProgress(Ev : integer; R : real);
    property  IsNet : boolean read FGetIsNet;
    property  Connected : boolean read FConnected;
    property  ConnectStr : string read  FConnectStr;

    function  IsDevStrOk : boolean;

  public
  // funkcje podstawowe Modbusa
    function  RdOutTable(RHan : THandle; var Buf; Adress : word; Count :word):TStatus;
    function  RdInpTable(RHan : THandle; var Buf; Adress : word; Count :word):TStatus;
    function  RdReg(RHan : THandle; var Buf; Adress : word; Count :word):TStatus;
    function  RdAnalogInp(RHan : THandle; var Buf; Adress : word; Count :word):TStatus;
    function  WrOutput(RHan : THandle; Adress : word; Val : boolean):TStatus;
    function  WrReg(RHan : THandle; Adress : word; Val : word):TStatus;
    function  WrMultiReg(RHan : THandle; var Buf; Adress : word; Count :word):TStatus;
    function  ReadWriteRegs(RHan : THandle; var RdBuf; RdAdress : word; RdCount :word;
                                   const WrBuf; WrAdress : word; WrCount :word ):TStatus;

  //Funkcje dodatkowe
    function  ReadS(RHan : THandle; var S : string; var Vec : Cardinal): TStatus;
    function  ReadDevMem(RHan : THandle; var Buffer; adr : Cardinal; size : Cardinal): TStatus;
    function  ReadDevWord(RHan : THandle; adr : Cardinal;var  w : word):TStatus;
    function  ReadDevByte(RHan : THandle; adr : Cardinal;var  w : byte):TStatus;

    function  WriteDevMem(RHan : THandle; const Buffer; adr : Cardinal; Size : Cardinal): TStatus;
    function  WriteDWord(RHan : THandle; adr : Cardinal; w : Cardinal):TStatus;
    function  WriteWord(RHan : THandle; adr : Cardinal; w : word):TStatus;
    function  WriteByte(RHan : THandle; adr : Cardinal; w : byte):TStatus;

    function  ReadCtrl(RHan : THandle; nr : byte; var  b : byte): TStatus;
    function  WriteCtrl(RHan : THandle; nr: byte; b: byte): TStatus;

    function GetDrvParamList(ToSet : boolean): string; stdcall;
    function SetDrvParam(ParamName,ParamValue :string): TStatus; stdcall;
    function GetDrvStatus(ParamName : string; var ParamValue :string): TStatus; stdcall;
    function TerminalSendKey(RHan : THandle; key : char): TStatus;
    function TerminalRead(RHan : THandle; var buf; var rdcnt : integer):TStatus;
    function CheckTerminalValid : boolean;

    function isStdModbus : boolean;

  end;

implementation




type
  TCallBackFunc = procedure(Id :TAccId; CmmId : integer; Ev : integer; R : real); stdcall;


  TAddDev   = function (ConnectStr : pAnsiChar): TAccId; stdcall;
  TDelDev   = function(Id :TAccId):TStatus; stdcall;
  TOpenDev  = function (Id :TAccId):TStatus; stdcall;
  TCloseDev = procedure (Id :TAccId); stdcall;
  TGetDevNr = function (Id :TAccId):byte; stdcall;
  TSetLoggerHandle = function (H : THandle):TStatus; stdcall;

// funkcje podstawowe Modbusa
  TRdOutTable = function(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
  TRdInpTable = function(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
  TRdReg = function(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
  TRdAnalogInp = function(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
  TWrOutput = function(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
  TWrReg = function(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
  TWrMultiReg = function(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
  TRdWrMultiReg = function(Id :TAccId; var RdBuf; RdAdress : word; RdCount :word;
                                       const WrBuf; WrAdress : word; WrCount :word):TStatus; stdcall;




  //Funkcje dodatkowe
  TReadS    = function (Id :TAccId; var Sign; var Vec : Cardinal): TStatus; stdcall;
  TReadReg  = function (Id :TAccId; var Buffer): TStatus; stdcall;
  TReadMem  = function (Id :TAccId; var Buffer; adr : Cardinal; size : Cardinal): TStatus; stdcall;
  TWriteMem = function (Id :TAccId; const Buffer; adr : Cardinal; Size : Cardinal): TStatus; stdcall;
  TFillMem  = function (Id :TAccId; adr : Cardinal; size : word; Sign : byte): TStatus; stdcall;
  TMoveMem  = function (Id :TAccId; src:Cardinal; Des:Cardinal; size : word): TStatus; stdcall;
  TSemaforWr = function (Id :TAccId; nr: byte; b: byte): TStatus; stdcall;
  TSemaforRd = function (Id :TAccId; nr : byte; var b : byte): TStatus; stdcall;
  TTerminalSendKey = function (Id :TAccId; key : char):TStatus; stdcall;
  TTerminalRead = function  (Id :TAccId; var Buffer; var rdcnt : integer):TStatus; stdcall;
  TGetErrStr = function (Id :TAccId; Code :TStatus; S : pAnsiChar; Max: integer): boolean;  stdcall;
  TRegisterCallBackFun = function(Id :TAccId; CmmId : integer; CallBackFunc : TCallBackFunc): TStatus; stdcall;
  TGetDrvParamList = function(ToSet : boolean): pAnsichar; stdcall;
  TGetDrvStatus = function(Id :TAccId; ParamName : pAnsichar; ParamValue :pAnsichar; MaxRpl:integer): TStatus; stdcall;
  TSetDrvParam = function(Id :TAccId; ParamName : pAnsichar; ParamValue :pAnsichar): TStatus; stdcall;

  TSetBreakFlag = function(Id :TAccId; Val:boolean): TStatus; stdcall;

type
  TCmmDevList = class(TObjectList)
  private
    function  GetItem(Index: Integer): TCmmDevice;
  public
    property Items[Index : integer]: TCmmDevice read GetItem;
    function FindDev(AId : TAccId): TCmmDevice;
  end;

var
  ComDllHandle  : THandle;
  TcpDllHandle  : THandle;
  ModbusComDllHandle : THandle;
  ModbusTcpDllHandle : THandle;
  CanDllHandle : THandle;
  UdtModComDllHandle : THandle;


  CmmDevList : TCmmDevList;

function TCmmDevList.GetItem(Index: Integer): TCmmDevice;
begin
  Result := inherited Items[Index] as TCmmDevice;
end;

function TCmmDevList.FindDev(AId : TAccId): TCmmDevice;
var
  i : integer;
begin
  result := nil;
  for i:=0 to Count-1 do
  begin
    if Items[i].FID=AId then result := Items[i];
  end;
end;


procedure CallBackFunc(Id :TAccId;CmmId : integer; Ev : integer; R : real); stdcall;
var
  Dev : TCmmDevice;
begin
  Dev := CmmDevList.FindDev(id);
  if dev<>nil then
    Dev.SetProgress(Ev,R);
end;


constructor TCmmDevice.Create(AHandle : THandle; ConnectStr : string);
var
  _AddDev    : TAddDev;
  _RegBeck   : TRegisterCallBackFun;
  SL         : TStringList;
  s          : string;
  channel    : integer;
  AnsiConnectStr : AnsiString;
begin
  inherited Create;
  ProgressHandle := AHandle;
  FConnectStr := ConnectStr;
  FID := -1;
  SL := TStringList.Create;
  try
    DllHandle := INVALID_HANDLE_VALUE;
    ExtractStrings([';'],[],pchar(ConnectStr),SL);
    if SL.Count>0 then
    begin
      s := SL.Strings[0];
      if s = 'RCOM' then
        DllHandle := ComDllHandle
      else if s = 'MCOM' then
        DllHandle := ModbusComDllHandle
      else if s = 'MTCP' then
        DllHandle := ModbusTcpDllHandle
      else if s = 'RTCP' then
        DllHandle := TcpDllHandle
      else if s = 'CAN' then
        DllHandle := CanDllHandle
      else if s = 'UCOM' then
        DllHandle := UdtModComDllHandle;


      if DllHandle<>INVALID_HANDLE_VALUE then
      begin
        AnsiConnectStr := AnsiString(ConnectStr);
        @_AddDev := GetProcAddress(DllHandle, 'AddDev');
        if Assigned(_AddDev) then
          FID := _AddDev(pAnsiChar(AnsiConnectStr));
        _RegBeck   := GetProcAddress(DllHandle, 'RegisterCallBackFun');
        if Assigned(_RegBeck) then
          _RegBeck(FID,cardinal(TCmmDevice),CallBackFunc);
        if SL.Count>3 then
        begin
          s := SL.Strings[3];
          if length(s)>=1 then
          begin
            channel := ord(s[1]) - ord('A');
            if (channel>=0) and (channel<10) then
              FID := FID+channel;
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
  _DelDev    : TDelDev;
begin
  CmmDevList.Extract(self);
  @_DelDev := GetProcAddress(DllHandle, 'DelDev');
  if Assigned(_DelDev) then
    _DelDev(FID);
  inherited;
end;

function TCmmDevice.FGetIsNet : boolean;
begin
  Result := (DllHandle=TcpDllHandle);
end;

function  TCmmDevice.IsDevStrOk : boolean;
begin
  Result := (DllHandle<>INVALID_HANDLE_VALUE);
end;


function  TCmmDevice.OpenDev:TStatus;
var
  _OpenDev   : TOpenDev;
begin
  @_OpenDev    := GetProcAddress(DllHandle, 'OpenDev');
  if Assigned(_OpenDev) then
  begin
    Result := _OpenDev(FID);
    FConnected := (Result=stOk);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.CloseDev:TStatus;
var
  _CloseDev  : TCloseDev;
begin
  @_CloseDev   := GetProcAddress(DllHandle, 'CloseDev');
  if Assigned(_CloseDev) then
    _CloseDev(FID);
  FConnected := False;
  Result := stOK;
end;

function TCmmDevice.GetDevNr: byte;
var
  _GetDevNr  : TGetDevNr;
begin
  @_GetDevNr   := GetProcAddress(DllHandle, 'GetDevNr');
  if Assigned(_GetDevNr) then
    Result := _GetDevNr(FID)
  else
    Result := 255;
end;

function  TCmmDevice.SetLoggerHandle(LogerHandle : THandle):TStatus;
var
  _SetLoggerHandle : TSetLoggerHandle;
begin
  if DllHandle<>0 then
  begin
    @_SetLoggerHandle := GetProcAddress(DllHandle, 'SetLoggerHandle');
    if Assigned(_SetLoggerHandle) then
    begin
      Result := _SetLoggerHandle(LogerHandle);
    end
    else
      Result := stNoImpl;
  end;
end;



function  TCmmDevice.isStdModbus : boolean;
var
  _RdOutTable : TRdOutTable;
  _RdInpTable : TRdInpTable;
  _RdReg : TRdReg;
  _RdAnalogInp : TRdAnalogInp;
  _WrOutput : TWrOutput;
  _WrReg : TWrReg;
  _WrMultiReg : TWrMultiReg;
begin
  if DllHandle<>0 then
  begin
    @_RdOutTable := GetProcAddress(DllHandle, 'RdOutTable');
    @_RdInpTable := GetProcAddress(DllHandle, 'RdInpTable');
    @_RdReg := GetProcAddress(DllHandle, 'RdReg');
    @_RdAnalogInp := GetProcAddress(DllHandle, 'RdAnalogInp');
    @_WrOutput := GetProcAddress(DllHandle, 'WrOutput');
    @_WrReg := GetProcAddress(DllHandle, 'WrReg');
    @_WrMultiReg := GetProcAddress(DllHandle, 'WrMultiReg');
    Result := Assigned(_RdOutTable) and Assigned(_RdInpTable) and Assigned(_RdReg)
       and Assigned(_RdAnalogInp) and Assigned(_WrOutput) and Assigned(_WrReg) and Assigned(_WrMultiReg);
  end
  else
    Result := false;     
end;


function  TCmmDevice.RdOutTable(RHan : THandle; var Buf; Adress : word; Count :word):TStatus;
var
  _RdOutTable : TRdOutTable;
begin
  ProgressHandle := RHan;
  @_RdOutTable  := GetProcAddress(DllHandle, 'RdOutTable');
  if Assigned(_RdOutTable) then
  begin
    Result := _RdOutTable(FID,Buf,Adress,Count);
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.RdInpTable(RHan : THandle; var Buf; Adress : word; Count :word):TStatus;
var
  _RdInpTable : TRdInpTable;
begin
  ProgressHandle := RHan;
  @_RdInpTable  := GetProcAddress(DllHandle, 'RdInpTable');
  if Assigned(_RdInpTable) then
  begin
    Result := _RdInpTable(FID,Buf,Adress,Count);
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.RdReg(RHan : THandle; var Buf; Adress : word; Count :word):TStatus;
var
  _RdReg : TRdReg;
begin
  ProgressHandle := RHan;
  @_RdReg  := GetProcAddress(DllHandle, 'RdReg');
  if Assigned(_RdReg) then
  begin
    Result := _RdReg(FID,Buf,Adress,Count);
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.RdAnalogInp(RHan : THandle; var Buf; Adress : word; Count :word):TStatus;
var
  _RdAnalogInp : TRdAnalogInp;
begin
  ProgressHandle := RHan;
  @_RdAnalogInp  := GetProcAddress(DllHandle, 'RdAnalogInp');
  if Assigned(_RdAnalogInp) then
  begin
    Result := _RdAnalogInp(FID,Buf,Adress,Count);
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.WrOutput(RHan : THandle; Adress : word; Val : boolean):TStatus;
var
  _WrOutput : TWrOutput;
  w         : word;
begin
  ProgressHandle := RHan;
  @_WrOutput  := GetProcAddress(DllHandle, 'WrOutput');
  if Assigned(_WrOutput) then
  begin
    w := 0;
    if val then
      w := 1;
    Result := _WrOutput(FID,Adress,w);
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.WrReg(RHan : THandle; Adress : word; Val : word):TStatus;
var
  _WrReg : TWrReg;
begin
  ProgressHandle := RHan;
  @_WrReg  := GetProcAddress(DllHandle, 'WrReg');
  if Assigned(_WrReg) then
  begin
    Result := _WrReg(FID,Adress,Val);
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.WrMultiReg(RHan : THandle; var Buf; Adress : word; Count :word):TStatus;
var
  _WrMultiReg : TWrMultiReg;
begin
  ProgressHandle := RHan;
  @_WrMultiReg  := GetProcAddress(DllHandle, 'WrMultiReg');
  if Assigned(_WrMultiReg) then
  begin
    Result := _WrMultiReg(FID,Buf,Adress,Count);
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.ReadWriteRegs(RHan : THandle; var RdBuf; RdAdress : word; RdCount :word;
                                   const WrBuf; WrAdress : word; WrCount :word ):TStatus;
var
  _RdWrMultiReg : TRdWrMultiReg;
begin
  ProgressHandle := RHan;
  @_RdWrMultiReg  := GetProcAddress(DllHandle, 'RdWrMultiReg');
  if Assigned(_RdWrMultiReg) then
  begin
    Result := _RdWrMultiReg(FID,RdBuf,RdAdress,RdCount,WrBuf,WrAdress,WrCount);
  end
  else
    Result := stNoImpl;
end;


function  TCmmDevice.ReadS(RHan : THandle; var S : string; var Vec : Cardinal): TStatus;
var
  _ReadS     : TReadS;
begin
  ProgressHandle := RHan;
  @_ReadS      := GetProcAddress(DllHandle, 'ReadS');
  if Assigned(_ReadS) then
  begin
    FToTrnsSize:=20;
    setlength(S,20);
    Result := _ReadS(FID,S[1],Vec);
    setlength(S,strlen(pchar(s)));
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.ReadDevMem(RHan : THandle; var Buffer; adr : Cardinal; size : Cardinal): TStatus;
var
  _ReadMem   : TReadMem;
begin
  ProgressHandle := RHan;
  @_ReadMem := GetProcAddress(DllHandle, 'ReadMem');
  if Assigned(_ReadMem) then
  begin
    FToTrnsSize:=size;
    Result := _ReadMem(FID,Buffer,adr,Size);
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.ReadDevWord(RHan : THandle; adr : Cardinal;var  w : word):TStatus;
begin
  Result := ReadDevMem(RHan,w,adr,sizeof(w));
end;
function  TCmmDevice.ReadDevByte(RHan : THandle; adr : Cardinal;var  w : byte):TStatus;
begin
  Result := ReadDevMem(RHan,w,adr,sizeof(w));
end;

function  TCmmDevice.WriteDevMem(RHan : THandle; const Buffer; adr : Cardinal; Size : Cardinal): TStatus;
var
  _WriteMem  : TWriteMem;
begin
  ProgressHandle := RHan;
  @_WriteMem   := GetProcAddress(DllHandle, 'WriteMem');
  if Assigned(_WriteMem) then
  begin
    FToTrnsSize:=size;
    Result := _WriteMem(FID,Buffer,adr,Size);
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.WriteDWord(RHan : THandle; adr : Cardinal; w : Cardinal):TStatus;
begin
  Result := WriteDevMem(RHan,w,adr,sizeof(w));
end;

function TCmmDevice.WriteWord(RHan : THandle; adr : Cardinal; w : word):TStatus;
begin
  Result := WriteDevMem(RHan,w,adr,sizeof(w));
end;

function  TCmmDevice.WriteByte(RHan : THandle; adr : Cardinal; w : byte):TStatus;
begin
  Result := WriteDevMem(RHan,w,adr,sizeof(w));
end;


function  TCmmDevice.WriteCtrl(RHan : THandle; nr: byte; b: byte): TStatus;
var
  _SemaforWr : TSemaforWr;
begin
  ProgressHandle:=RHan;
  @_SemaforWr  := GetProcAddress(DllHandle, 'WriteCtrl');
  if Assigned(_SemaforWr) then
  begin
    Result := _SemaforWr(FID,nr,b);
  end
  else
    Result := stNoImpl;
end;

function  TCmmDevice.ReadCtrl(RHan : THandle; nr : byte;var b : byte): TStatus;
var
  _SemaforRd : TSemaforRd;
begin
  ProgressHandle:=RHan;
  @_SemaforRd  := GetProcAddress(DllHandle, 'ReadCtrl');
  if Assigned(_SemaforRd) then
  begin
    Result := _SemaforRd(FID,nr,b);
  end
  else
    Result := stNoImpl;
end;


function TCmmDevice.TerminalRead(RHan : THandle; var buf; var rdcnt : integer):TStatus;
var
  _TerminalRead : TTerminalRead;
begin
  ProgressHandle:=RHan;
  @_TerminalRead  := GetProcAddress(DllHandle, 'TerminalRead');
  if Assigned(_TerminalRead) then
  begin
    Result := _TerminalRead(FID,buf,rdcnt);
  end
  else
    Result := stNoImpl;
end;

function TCmmDevice.TerminalSendKey(RHan : THandle; key : char): TStatus;
var
  _TerminalSendKey : TTerminalSendKey;
begin
  ProgressHandle:=RHan;
  @_TerminalSendKey  := GetProcAddress(DllHandle, 'TerminalSendKey');
  if Assigned(_TerminalSendKey) then
  begin
    Result := _TerminalSendKey(FID,key);
  end
  else
    Result := stNoImpl;
end;


function TCmmDevice.CheckTerminalValid : boolean;
begin
  Result := (TerminalSendKey(INVALID_HANDLE_VALUE,#0)=stOk);
end;




function  TCmmDevice.GetErrStr(Code : TStatus;S : pAnsiChar; Max: integer): boolean;
var
  _GetErrStr : TGetErrStr;
begin
  @_GetErrStr  := GetProcAddress(DllHandle, 'GetErrStr');
  if Assigned(_GetErrStr) then
    Result := _GetErrStr(FID,Code,S,Max)
  else
    Result := false;
end;

function  TCmmDevice.GetErrStr(Code : TStatus): string;
var
  txt : AnsiString;
begin
  if Code=stOk      then  Result := 'Ok'
  else if Code=stNoImpl  then  Result := 'Unknown function'
  else
  begin
    SetLength(txt,200);
    if GetErrStr(Code,pAnsichar(txt),length(txt)-1) then
    begin
      SetLength(txt,strlen(pAnsichar(txt)));
      Result := String(txt);
    end
    else
      Result := Format('ErrNr=%u',[Code]);
  end;
end;

function TCmmDevice.GetDrvParamList(ToSet : boolean): string; stdcall;
var
  _GetDrvParamList : TGetDrvParamList;
begin
  @_GetDrvParamList  := GetProcAddress(DllHandle, 'GetDrvParamList');
  if Assigned(_GetDrvParamList) then
    Result := _GetDrvParamList(ToSet)
  else
    Result := '';
end;


function TCmmDevice.SetDrvParam(ParamName,ParamValue :string): TStatus; stdcall;
var
  _SetDrvParam : TSetDrvParam;
begin
  @_SetDrvParam  := GetProcAddress(DllHandle, 'SetDrvParam');
  if Assigned(_SetDrvParam) then
    Result := _SetDrvParam(FID,pAnsichar(ParamName),pAnsichar(ParamValue))
  else
    Result := stNoImpl;
end;

function TCmmDevice.GetDrvStatus(ParamName : string; var ParamValue :string): TStatus; stdcall;
var
  _GetDrvStatus : TGetDrvStatus;
begin
  @_GetDrvStatus  := GetProcAddress(DllHandle, 'GetDrvStatus');
  if Assigned(_GetDrvStatus) then
  begin
    Setlength(ParamValue,100);
    Result := _GetDrvStatus(FID,pAnsichar(ParamName),pAnsichar(ParamValue),Length(ParamValue)-1);
    setlength(ParamValue,strlen(pchar(ParamValue)));
  end
  else
    Result := stNoImpl;
end;

procedure TCmmDevice.SetProgress(Ev : integer; R : real);
var
  P : integer;
begin
  if (ProgressHandle<>INVALID_HANDLE_VALUE) then
  begin
    case Ev of
    0 : begin
          P := round(10*R);
          SendMessage(ProgressHandle,wm_TrnsProgress,P,0);
        end;
    1 : begin

        end;
    2 : begin

        end;
    3 : begin

        end;
    4 : begin
          if R=0 then
            SendMessage(ProgressHandle,wm_TrnsStartStop,0,0)
          else
            SendMessage(ProgressHandle,wm_TrnsStartStop,1,0);
        end;
    end;
  end;
end;

initialization
  ComDllHandle := LoadLibrary('RsdCom.cmm');
  TcpDllHandle := LoadLibrary('RsdTcp.cmm');
  ModbusComDllHandle := LoadLibrary('MBusCom.cmm');
  ModbusTcpDllHandle := LoadLibrary('MdbTcp.cmm');
  CanDllHandle := LoadLibrary('CanDrv.cmm');
  UdtModComDllHandle := LoadLibrary('UdtMdbCom.cmm');                      
  CmmDevList := TCmmDevList.Create(false);


finalization
  FreeAndNil(CmmDevList);
  if ComDllHandle <> 0 then
  begin
    FreeLibrary(ComDllHandle);
    ComDllHandle:=0;
  end;
  if TcpDllHandle<> 0 then
  begin
    FreeLibrary(TcpDllHandle);
    TcpDllHandle:=0;
  end;
end.
