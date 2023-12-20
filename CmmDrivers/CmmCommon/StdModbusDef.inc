// funkcje podstawowe Modbusa

function  RdOutTable(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  RdInpTable(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  RdReg(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  RdAnalogInp(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  WrOutput(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
function  WrReg(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
function  WrMultiReg(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;

Exports
    RdOutTable,
    RdInpTable,
    RdReg,
    RdAnalogInp,
    WrOutput,
    WrReg,
    WrMultiReg;

