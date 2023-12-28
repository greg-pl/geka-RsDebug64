// obsluga terminala

function TerminalSendKey(Id: TAccId; key: AnsiChar): TStatus; stdcall;
function TerminalRead(Id: TAccId; buf: PAnsiChar; var rdcnt: integer): TStatus; stdcall;
function TerminalSetPipe(Id: TAccId; TerminalNr: integer; PipeHandle: THandle): TStatus; stdcall;
function TerminalSetRunFlag(Id: TAccId; TerminalNr: integer; RunFlag: boolean): TStatus; stdcall;

      Exports
        TerminalSendKey,
        TerminalSetPipe,
        TerminalSetRunFlag,
        TerminalRead; // deprecated
