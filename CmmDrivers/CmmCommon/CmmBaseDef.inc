
function LibIdentify:PGUID; stdcall;
function  GetLibProperty:PAnsiChar; stdcall;
procedure SetLoggerHandle (H: THandle); stdcall;
procedure SetGetMemFunction(LibID : integer; GetMemFunc : TGetMemFunction); stdcall;


function  GetErrStr(Id :TAccId; Code :TStatus; S : PAnsiChar; Max: integer): boolean;  stdcall;
function  AddDev(ConnectStr : PAnsiChar): TAccId; stdcall;


function GetDrvInfo(Id: TAccID ): PAnsiChar; stdcall;
function GetDrvParams(Id: TAccId): PAnsiChar; stdcall;
function SetDrvParams(Id: TAccId; jsonParams: PAnsiChar): TStatus; stdcall;



function  DelDev(Id :TAccId):TStatus; stdcall;
function  OpenDev(Id :TAccId):TStatus; stdcall;
procedure CloseDev(Id :TAccId); stdcall;
function  RegisterCallBackFun(Id :TAccId; CmmId : integer; CallBackFunc : TCallBackFunc): TStatus; stdcall;
function  SetBreakFlag(Id :TAccId; Val:boolean): TStatus; stdcall;


Exports
    LibIdentify,
    GetLibProperty,
    SetLoggerHandle,
    SetGetMemFunction,

    GetErrStr,
    AddDev,
    DelDev,
    OpenDev,
    CloseDev,
    RegisterCallBackFun,
    SetBreakFlag,
    GetDrvInfo,
    GetDrvParams,
    SetDrvParams;



