
type
  TCallBackFunc = procedure(Id :TAccId; CmmId : integer; Ev : integer; R : real); stdcall;

procedure LibIdentify(var LibGuid :TGUID); stdcall;
function  GetErrStr(Id :TAccId; Code :TStatus; S : PAnsiChar; Max: integer): boolean;  stdcall;
function  AddDev(ConnectStr : PAnsiChar): TAccId; stdcall;
function  DelDev(Id :TAccId):TStatus; stdcall;
function  OpenDev(Id :TAccId):TStatus; stdcall;
procedure CloseDev(Id :TAccId); stdcall;
function  RegisterCallBackFun(Id :TAccId; CmmId : integer; CallBackFunc : TCallBackFunc): TStatus; stdcall;
function  GetLibProperty:PAnsiChar; stdcall;
function  SetBreakFlag(Id :TAccId; Val:boolean): TStatus; stdcall;
function  GetDrvParamList(ToSet : boolean): PAnsiChar; stdcall;
function  GetDrvStatus(Id :TAccId; ParamName : PAnsiChar; ParamValue :PAnsiChar; MaxRpl:integer): TStatus; stdcall;
function  SetDrvParam(Id :TAccId; ParamName : PAnsiChar; ParamValue :PAnsiChar): TStatus; stdcall;


Exports
    LibIdentify,
    GetErrStr,
    AddDev,
    DelDev,
    OpenDev,
    CloseDev,
    RegisterCallBackFun,
    GetLibProperty,
    SetBreakFlag,
    GetDrvStatus,
    SetDrvParam,
    GetDrvParamList;