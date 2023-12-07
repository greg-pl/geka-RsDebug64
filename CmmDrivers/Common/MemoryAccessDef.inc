// odczyt, zapis pamiêci

function  ReadMem(Id :TAccId; var Buffer; adr : Cardinal; size : Cardinal): TStatus; stdcall;
function  WriteMem(Id :TAccId; var Buffer; adr : Cardinal; Size : Cardinal): TStatus; stdcall;


Exports
    ReadMem,
    WriteMem;

