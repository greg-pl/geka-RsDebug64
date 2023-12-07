// dostep do sesji i plików

function  SeOpenSesion(Id :TAccId; var SesId : TSesID) : TStatus; stdcall;
function  SeCloseSesion(Id :TAccId; SesId : TSesID) : TStatus; stdcall;
function  SeOpenFile(Id :TAccId; SesId : TSesID; FName : PAnsiChar; Mode : byte; var FileNr : TFileNr):TStatus; stdcall;
function  SeGetDir(Id :TAccId; SesId : TSesID; FName : PAnsiChar; Attrib : byte; Buffer : PAnsiChar; MaxLen : integer):TStatus; stdcall;
function  SeGetDrvList(Id :TAccId; SesId : TSesID; DrvList : PAnsiChar):TStatus; stdcall;
function  SeShell(Id :TAccId; SesId : TSesID; Command : PAnsiChar; ResultStr : PAnsiChar; MaxLen : integer):TStatus; stdcall;
function  SeGetGuidEx(Id :TAccId; SesId : TSesID; FileName : PAnsiChar; var Guid : TSeGuid):TStatus; stdcall;
function  SeReadFileEx(Id :TAccId; SesId : TSesID; FileName : PAnsiChar; autoclose: boolean; var buf;
              var size: integer; var FileNr: TFileNr):TStatus; stdcall;
function  SeReadFile(Id :TAccId; SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus; stdcall;
function  SeWriteFile(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus; stdcall;
function  SeSeek(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; Offset  : integer; Orgin : byte; var Pos : integer):TStatus; stdcall;
function  SeGetFileSize(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; var FileSize : integer):TStatus; stdcall;
function  SeCloseFile(Id :TAccId; SesId : TSesID;  FileNr : TFileNr):TStatus; stdcall;
function  SeGetGuid(Id :TAccId; SesId : TSesID;  FileNr : TFileNr; var Guid : TSeGuid):TStatus; stdcall;

Exports

    SeOpenSesion,
    SeCloseSesion,
    SeOpenFile,
    SeGetDir,
    SeGetDrvList,
    SeShell,
    SeReadFile,
    SeWriteFile,
    SeSeek,
    SeGetFileSize,
    SeCloseFile,
    SeGetGuid,
    SeGetGuidEx,
    SeReadFileEx;
