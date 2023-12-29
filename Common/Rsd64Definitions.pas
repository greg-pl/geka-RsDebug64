unit Rsd64Definitions;

interface

uses
  Windows, Messages, SysUtils, Classes,
  System.AnsiStrings,
  System.Contnrs,
  System.Generics.Collections,
  System.JSON,
  math,
  SttObjectDefUnit;

const
  CommLibGuid: TGUID = '{82AAD978-C9F1-4214-AD36-943DDA11F72F}';

  // dfinicja b³êdów
  stOk = 0;
  stBadId = 1;
  stTimeErr = 2;
  stNotOpen = 3;
  stSetupErr = 4;
  stUserBreak = 5;
  stNoSemafor = 6;
  stBadRepl = 7;
  stBadArguments = 8;
  stBufferToSmall = 9; // publiczny - rozpoznawany przez warstwê wy¿sza
  stToBigTerminalNr = 10; //
  stEND_OFF_DIR = 11;
  stDelphiError = 12;
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
  CONNECTION_PARAMS_NAME = 'ConnectionParams';
  CONNECTION_DRIVER_NAME = 'DriverName';

  UARTPARAM_COMNR = 'ComNr';
  UARTPARAM_BAUDRATE = 'BaudRate';
  UARTPARAM_PARITY = 'Parity';
  UARTPARAM_BITCNT = 'BitCnt';

  IPPARAM_IP = 'Ip';
  IPPARAM_PORT = 'Port';

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
    shortName: string;
    SubGroups: TSubGroups;
    Description: string;
    ConnectionType: TConnectionType;
    ConnectionParams: TSttObjectListJson;
    procedure Init;
  end;

  TLibPropertyBuilder = class(TObject)
  public
    Params: TLibParams;
    procedure AddChildLibObject(parent: TJsonObject); virtual;
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
  shortName := '';
  ConnectionType := connTypNODEF;
  ConnectionParams := TSttObjectListJson.Create;
end;

constructor TLibPropertyBuilder.Create;
begin
  inherited;
  Params.Init;
end;

procedure TLibPropertyBuilder.AddChildLibObject(parent: TJsonObject);
begin

end;

function TLibPropertyBuilder.Build: String;
var
  tmpObj: TJsonObject;
  jsonArray: TJSONArray;
  jsonSubArray: TJSONArray;
  jsonPair: TJSONPair;
  i: integer;
  gr: TSubGroup;
begin
  tmpObj := TJsonObject.Create;

  AddChildLibObject(tmpObj);

  tmpObj.AddPair(TJSONPair.Create('ShortName', Params.shortName));
  tmpObj.AddPair(TJSONPair.Create('Description', Params.Description));
  tmpObj.AddPair(TJSONPair.Create('ConnectionType', ConnectionTypeName[ord(Params.ConnectionType)]));

  jsonSubArray := TJSONArray.Create();
  for gr := Low(TSubGroup) to High(TSubGroup) do
  begin
    if gr in Params.SubGroups then
    begin
      jsonSubArray.Add(SubGroupName[ord(gr)]);
    end;
  end;
  tmpObj.AddPair(TJSONPair.Create('SubGroups', jsonSubArray));

  jsonArray := TJSONArray.Create();
  for i := 0 to Params.ConnectionParams.Count - 1 do
  begin
    jsonArray.AddElement(Params.ConnectionParams[i].getJSonObject);
  end;

  jsonPair := TJSONPair.Create('ConectionParams', jsonArray);
  tmpObj.AddPair(jsonPair);

  Result := tmpObj.ToString;
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

  procedure ConnectionParamsLoadfromArr(arr: TJSONArray);
  var
    i: integer;
    nm: string;
    sttObj: TSttObjectJson;
    jobj: TJsonObject;
  begin
    for i := 0 to arr.Count - 1 do
    begin
      jobj := arr.items[i] as TJsonObject;
      nm := jobj.GetValue('SttType').Value;
      sttObj := TSttObjectJson.CreateObject(nm);
      sttObj.LoadFromJSonObj(jobj);
      Params.ConnectionParams.Add(sttObj);
    end;
  end;

var
  JSonValue: TJSONValue;
  myObj: TJsonObject;
  arr: TJSONArray;
begin
  try
    JSonValue := TJsonObject.ParseJSONValue(txt);
    myObj := JSonValue as TJsonObject;

    Params.shortName := myObj.Get('ShortName').JSonValue.Value;
    Params.Description := myObj.Get('Description').JSonValue.Value;
    Params.ConnectionType := TConnectionType(FindStringInArray(myObj.Get('ConnectionType').JSonValue.Value,
      ConnectionTypeName, ord(connTypNODEF)));

    arr := myObj.Get('SubGroups').JSonValue as TJSONArray;
    Params.SubGroups := LoadGroups(arr);

    arr := myObj.Get('ConectionParams').JSonValue as TJSONArray;
    ConnectionParamsLoadfromArr(arr);
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
  jVal: TJSONValue;
  jobj: TJsonObject;
  paramObj: TJsonObject;
  item: TJSONPair;
begin
  Result := false;
  try
    jVal := TJsonObject.ParseJSONValue(ConnectJson);
    if Assigned(jVal) then
    begin
      jobj := jVal as TJsonObject;
      paramObj := jobj.Get(CONNECTION_PARAMS_NAME).JSonValue as TJsonObject;
      if Assigned(paramObj) then
      begin
        item := paramObj.Get(UARTPARAM_COMNR);
        if Assigned(item) then
        begin
          ConnInfoStr := item.JSonValue.Value;
          Result := true;
        end
        else
        begin
          item := paramObj.Get(IPPARAM_IP);
          if Assigned(item) then
          begin
            ConnInfoStr := item.JSonValue.Value;
            Result := true;
            item := paramObj.Get(IPPARAM_PORT);
            if Assigned(item) then
              ConnInfoStr := ConnInfoStr + ':' + item.JSonValue.Value;
          end;
        end;
      end;

    end;
  except

  end;
end;

end.
