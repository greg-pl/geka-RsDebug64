unit ErrorDefUnit;

interface

type
  TStatus = integer;

const
  // dfinicja b³êdów
  stOk = 0;
  stBadId = 1;
  stTimeErr = 2;
  stNotOpen = 3;
  stNoReplay = 4;
  stSetupErr = 5;
  stUserBreak = 6;
  stNoSemafor = 7;
  stBadRepl = 8;
  stBadArguments = 9;
  stBufferToSmall = 10; // publiczny - rozpoznawany przez warstwê wy¿sza
  stToBigTerminalNr = 11; //
  stEND_OFF_DIR = 12;
  stDelphiError = 13;
  stFrmTooLarge = 14;
  stErrorRecived = 15;

  stReplySumError = 16;
  stReplyFormatError = 17;
  stConnectError = 18;
  stNoLogger = 19;

  stMdbError = 50;
  stMdbExError = 100;

  stAPL_BASE = 500;

  stNoImpl = stAPL_BASE + 0;
  stError = stAPL_BASE + 1;
  stUndefCommand = stAPL_BASE + 2;

  stGDB_error = 1000;

implementation

end.
