unit Rsd64Definitions;

interface

uses
  Windows, Messages, SysUtils, Classes,
  System.AnsiStrings,
  System.Contnrs,
  System.Generics.Collections,
  System.JSON,
  JSONUtils,
  math,
  SttObjectDefUnit;

const
  CommLibGuid: TGUID = '{82AAD978-C9F1-4214-AD36-943DDA11F72F}';

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
  stMdbError = 50;
  stMdbExError = 100;

  stAPL_BASE = 500;

  stNoImpl = stAPL_BASE + 0;
  stError = stAPL_BASE + 1;
  stUndefCommand = stAPL_BASE + 2;

  evWorkOnOff = 0;
  evProgress = 1;
  evFlow = 2;

  TERMINAL_ZERO = 0;

const
  // Connection
  CONNECTION_PARAMS_NAME = 'ConnectionParams';
  CONNECTION_DRIVER_NAME = 'DriverName';

  UARTPARAM_COMNR = 'ComNr';
  UARTPARAM_BAUDRATE = 'BaudRate';
  UARTPARAM_PARITY = 'Parity';
  UARTPARAM_BITCNT = 'BitCnt';

  IPPARAM_IP = 'Ip';
  IPPARAM_PORT = 'Port';

  // Driver params
  DRVPRAM_DEFINITION = 'Definition';
  DRVPRAM_VALUES = 'Values';
  DRVPRAM_DRIVER_NAME = 'DriverName';

  // Driver info
  DRVINFO_TIME = 'Time';
  DRVINFO_LIST= 'Values';

  DRVINFO_NAME= 'Name';
  DRVINFO_DESCR= 'Descr';
  DRVINFO_VALUE= 'Value';

  UartParamTab: TStringArr = [UARTPARAM_COMNR, UARTPARAM_PARITY, UARTPARAM_BAUDRATE, UARTPARAM_BITCNT];
  IpParamTab: TStringArr = [IPPARAM_IP, IPPARAM_PORT];

type
  TStatus = integer;
  TAccId = integer;
  TSesID = cardinal;
  TFileNr = byte;

  TSeGuid = record
    d1: cardinal;
    d2: cardinal;
  end;

  TCallBackFunc = procedure(Id: TAccId; CmmId: integer; Ev: integer; R: real); stdcall;
  TGetMemFunction = function(LibID: integer; MemSize: integer): pointer; stdcall;

type
  // ----------------------------------------------------------------------------

  TUartParity = (parityNONE, parityODD, parityEVEN);
  TSubGroup = (subBASE, subMEMORY, subTERMINAL, subMODBUS_STD, subMODBUS_FILE);
  TSubGroups = set of TSubGroup;
  TConnectionType = (connTypNODEF, connTypUART, connTypTCPIP);

  PLibParams = ^TLibParams;

  TLibParams = record
    DriverName: string;
    SubGroups: TSubGroups;
    Description: string;
    ConnectionType: TConnectionType;
    ConnectionParams: TSttObjectListJson;
    procedure Init;
  end;

  TLibPropertyBuilder = class(TObject)
  public
    Params: TLibParams;
    procedure AddChildLibObject(jBuil: TJSONBuilder); virtual;
  public
    constructor Create;
    function Build: String;
    function LoadFromTxt(txt: string): boolean;
  end;

function ExtractDriverName(ConnectJson: string; var driverName: string): boolean;
function ExtractConnInfoStr(ConnectJson: string; var ConnInfoStr: string): boolean;

implementation

const
  ConnectionTypeName: TStringArr = ['connTypNODEF', 'connTypUART', 'connTypTCPIP'];
  SubGroupName: TStringArr = ['subBASE', 'subMEMORY', 'subTERMINAL', 'subMODBUS_STD', 'subMODBUS_FILE'];


  // ----- TUartObjectJson ---------------------------------------------------

procedure TLibParams.Init;
begin
  SubGroups := [subBASE];
  Description := '';
  DriverName := '';
  ConnectionType := connTypNODEF;
  ConnectionParams := TSttObjectListJson.Create;
end;

constructor TLibPropertyBuilder.Create;
begin
  inherited;
  Params.Init;
end;

procedure TLibPropertyBuilder.AddChildLibObject(jBuil: TJSONBuilder);
begin

end;

function TLibPropertyBuilder.Build: String;
var
  jBuil: TJSONBuilder;
  jArr: TJSONArray;
  gr: TSubGroup;
begin
  jBuil.Init;

  AddChildLibObject(jBuil);

  jBuil.Add('DriverName', Params.DriverName);
  jBuil.Add('Description', Params.Description);
  jBuil.Add('ConnectionType', ConnectionTypeName[ord(Params.ConnectionType)]);

  jArr := TJSONArray.Create();
  for gr := Low(TSubGroup) to High(TSubGroup) do
  begin
    if gr in Params.SubGroups then
    begin
      jArr.Add(SubGroupName[ord(gr)]);
    end;
  end;
  jBuil.Add('SubGroups', jArr);
  jBuil.Add('ConectionParams', Params.ConnectionParams.getJSonObject);

  Result := jBuil.jobj.ToString;
end;

function TLibPropertyBuilder.LoadFromTxt(txt: string): boolean;
  function LoadGroups(arr: TJSONArray): TSubGroups;
  var
    i: integer;
    nm: string;
    idx: integer;
    groups: TSubGroups;
  begin
    groups := [];
    for i := 0 to arr.Count - 1 do
    begin
      nm := arr.items[i].Value;
      idx := FindStringInArray(nm, SubGroupName, -1);
      if idx >= 0 then
        groups := groups + [TSubGroup(idx)];
    end;
    Result := groups;
  end;

var
  jLoader: TJSONLoader;
  s1: string;
begin
  try
    jLoader.Init(txt);
    jLoader.Load('DriverName', Params.DriverName);
    jLoader.Load('Description', Params.Description);

    if jLoader.Load('ConnectionType', s1) then
      Params.ConnectionType := TConnectionType(FindStringInArray(s1, ConnectionTypeName, ord(connTypNODEF)));

    Params.SubGroups := LoadGroups(jLoader.getArray('SubGroups'));
    Params.ConnectionParams.LoadfromArr(jLoader.getArray('ConectionParams'));
    Result := true;
  except
    Result := false;
  end;

end;

function ExtractDriverName(ConnectJson: string; var driverName: string): boolean;
var
  jVal: TJSONValue;
  jobj: TJsonObject;
begin
  Result := false;
  try
    jVal := TJsonObject.ParseJSONValue(ConnectJson);
    if Assigned(jVal) then
    begin
      jobj := jVal as TJsonObject;
      driverName := jobj.Get(CONNECTION_DRIVER_NAME).JSonValue.Value;
      Result := true;
    end;
  except
  end;
end;

function ExtractConnInfoStr(ConnectJson: string; var ConnInfoStr: string): boolean;
var
  jLoader: TJSONLoader;
  jParamLoader: TJSONLoader;
  tmp: string;
begin
  Result := false;
  try
    if jLoader.Init(ConnectJson) then
    begin
      if jLoader.Load(CONNECTION_DRIVER_NAME, ConnInfoStr) then
      begin
        ConnInfoStr := ConnInfoStr + ' [ ';
        if jParamLoader.Init(jLoader, CONNECTION_PARAMS_NAME) then
        begin
          if jParamLoader.Load(UARTPARAM_COMNR, tmp) then
          begin
            ConnInfoStr := ConnInfoStr + tmp;
            Result := true;
          end
          else if jParamLoader.Load(IPPARAM_IP, tmp) then
          begin
            ConnInfoStr := ConnInfoStr + tmp;
            if jParamLoader.Load(IPPARAM_PORT, tmp) then
              ConnInfoStr := ConnInfoStr + ':' + tmp;
            Result := true;
          end;
        end;
        ConnInfoStr := ConnInfoStr + ' ]';
      end;
    end;
  except

  end;
end;

end.
