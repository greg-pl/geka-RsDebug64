//obsluga terminala

function  TerminalSendKey(Id :TAccId; key : AnsiChar):TStatus; stdcall;
function  TerminalRead(Id :TAccId; buf : PAnsiChar; var rdcnt : integer):TStatus; stdcall;

Exports
    TerminalSendKey,
    TerminalRead;
