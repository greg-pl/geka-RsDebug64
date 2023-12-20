unit SttObjectDefUnit;

interface

uses
  SysUtils, Classes,
  System.AnsiStrings,
  System.Contnrs,
  System.Generics.Collections,
  System.JSON,
  math;

const
  NAN_INT = $7FFFFFFF;
  NAN_TEXT = 'NAN';

type

  TSttType = (sttBOOL, sttINTEGER, sttFLOAT, sttSELECT, sttIP);
  TStringArr = array of string;
  TIntArr = array of integer;

  TSttObjectJson = class(TObject)
    Name: string;
    Description: string;
    SettType: TSttType;
    class function CreateObject(SttTypeNm: string): TSttObjectJson;
    constructor Create(aName, aDescription: string; aTyp: TSttType);
    function getJSonObject: TJsonObject; virtual;
    procedure LoadFromJSonObj(jobj: TJsonObject); virtual;
  public
    class function LoadJsonStr(jobj: TJsonObject; valName: string; defTex: string): string;
    class function LoadJsonInt(jobj: TJsonObject; valName: string; defVal: integer): integer;
    class function LoadJsonFloat(jobj: TJsonObject; valName: string; defVal: single): single;
    class function LoadJsonBool(jobj: TJsonObject; valName: string; defVal: boolean): boolean;
  end;

  TSttObjectListJson = class(TList<TSttObjectJson>)
  protected
  public
    function FindSttObject(aName: string): TSttObjectJson;
    function getJSonObject: TJsonObject; virtual; abstract;
  end;

  TSttBoolObjectJson = class(TSttObjectJson)
    defVal: boolean;
    constructor Create; overload;
    constructor Create(aName, aDescription: string; adef: boolean); overload;
    function getJSonObject: TJsonObject; override;
    procedure LoadFromJSonObj(jobj: TJsonObject); override;
  end;

  TSttIntObjectJson = class(TSttObjectJson)
    MinVal: integer;
    MaxVal: integer;
    defVal: integer;
    constructor Create; overload;
    constructor Create(aName, aDescription: string; aMin, aMax, adef: integer); overload;
    function getJSonObject: TJsonObject; override;
    procedure LoadFromJSonObj(jobj: TJsonObject); override;
  end;

  TSttFloatObjectJson = class(TSttObjectJson)
    MinVal: single;
    MaxVal: single;
    defVal: single;
    FormatStr: string;
    constructor Create; overload;
    constructor Create(aName, aDescription: string; aMin, aMax, adef: single; frm: string); overload;
    function getJSonObject: TJsonObject; override;
    procedure LoadFromJSonObj(jobj: TJsonObject); override;
  end;

  TSttSelectObjectJson = class(TSttObjectJson)
    items: TStringArr;
    defVal: string;
    constructor Create; overload;
    constructor Create(aName, aDescription: string; aItems: TStringArr; aDefVal: string); overload;
    constructor Create(aName, aDescription: string; aItems: TIntArr; aDefVal: integer); overload;
    function getJSonObject: TJsonObject; override;
    procedure LoadFromJSonObj(jobj: TJsonObject); override;
    function GetItemsAsStrings: TStrings;
  end;

  TSttIPObjectJson = class(TSttObjectJson)
    constructor Create; overload;
    constructor Create(aName, aDescription: string); overload;
  end;

function FindStringInArray(item: string; tab: TStringArr; defValue: integer): integer;
function JSonStrToBool(txt: string; var q: boolean): boolean;
function JSonBoolToStr(q: boolean): string;

implementation

const
  SttTypeNames: TStringArr = ['sttBOOL', 'sttINTEGER', 'sttFLOAT', 'sttSELECT', 'sttIP'];

function JSonBoolToStr(q: boolean): string;
begin
  if q then
    Result := 'True'
  else
    Result := 'False';
end;

function JSonStrToBool(txt: string; var q: boolean): boolean;
begin
  txt := UpperCase(txt);
  if (txt = 'TRUE') or (txt = 'YES') or (txt = '1') then
  begin
    q := true;
    Result := true
  end
  else if (txt = 'FALSE') or (txt = 'NO') or (txt = '0') then
  begin
    q := false;
    Result := true
  end
  else
    Result := false
end;

function FindStringInArray(item: string; tab: TStringArr; defValue: integer): integer;
var
  i: integer;
begin
  Result := defValue;
  for i := 0 to length(tab) - 1 do
  begin
    if item = tab[i] then
    begin
      Result := i;
      break;
    end;
  end;
end;

constructor TSttObjectJson.Create(aName, aDescription: string; aTyp: TSttType);
begin
  SettType := aTyp;
  Name := aName;
  Description := aDescription;
end;

class function TSttObjectJson.CreateObject(SttTypeNm: string): TSttObjectJson;
var
  stt: TSttType;
begin
  stt := TSttType(FindStringInArray(SttTypeNm, SttTypeNames, ord(sttINTEGER)));
  case stt of
    sttBOOL:
      Result := TSttBoolObjectJson.Create;
    sttINTEGER:
      Result := TSttIntObjectJson.Create;
    sttSELECT:
      Result := TSttSelectObjectJson.Create;
    sttFLOAT:
      Result := TSttFloatObjectJson.Create;
    sttIP:
      Result := TSttIPObjectJson.Create;
  end;
end;

function TSttObjectJson.getJSonObject: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.AddPair('SttType', SttTypeNames[ord(SettType)]);
  Result.AddPair('Name', Name);
  Result.AddPair('Descr', Description);
end;

procedure TSttObjectJson.LoadFromJSonObj(jobj: TJsonObject);
begin
  Name := LoadJsonStr(jobj, 'Name', '_noName_');
  Description := LoadJsonStr(jobj, 'Descr', '');
end;

class function TSttObjectJson.LoadJsonStr(jobj: TJsonObject; valName: string; defTex: string): string;
var
  jVal: TJSONValue;
begin
  jVal := jobj.GetValue(valName);
  if Assigned(jVal) then
    Result := jVal.Value
  else
    Result := defTex;
end;

class function TSttObjectJson.LoadJsonInt(jobj: TJsonObject; valName: string; defVal: integer): integer;
var
  jVal: TJSONValue;
  txt: string;
begin
  jVal := jobj.GetValue(valName);
  if Assigned(jVal) then
  begin
    txt := jVal.Value;
    if txt = NAN_TEXT then
      Result := NAN_INT
    else
    begin
      if not(TryStrToInt(jVal.Value, Result)) then
        Result := defVal;
    end;
  end
  else
    Result := defVal;
end;

class function TSttObjectJson.LoadJsonFloat(jobj: TJsonObject; valName: string; defVal: single): single;
var
  jVal: TJSONValue;
  txt: string;
begin
  jVal := jobj.GetValue(valName);
  if Assigned(jVal) then
  begin
    txt := jVal.Value;
    if txt = NAN_TEXT then
      Result := nan
    else
    begin
      if not(TryStrToFloat(jVal.Value, Result)) then
        Result := defVal;
    end;
  end
  else
    Result := defVal;
end;

class function TSttObjectJson.LoadJsonBool(jobj: TJsonObject; valName: string; defVal: boolean): boolean;
var
  jVal: TJSONValue;
begin
  Result := defVal;
  jVal := jobj.GetValue(valName);
  if Assigned(jVal) then
  begin
    JSonStrToBool(jVal.Value, Result);
  end;
end;


// ----- TSttObjectListJson ---------------------------------------------------

function TSttObjectListJson.FindSttObject(aName: string): TSttObjectJson;
var
  i: integer;
  stt: TSttObjectJson;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    stt := items[i] as TSttObjectJson;
    if stt.Name = aName then
    begin
      Result := stt;
      break;
    end;
  end;
end;

// ----- TSettIntObjectJson ---------------------------------------------------

constructor TSttBoolObjectJson.Create;
begin
  inherited Create('', '', sttBOOL);
  defVal := false;

end;

constructor TSttBoolObjectJson.Create(aName, aDescription: string; adef: boolean);
begin
  inherited Create(aName, aDescription, sttBOOL);
  defVal := adef;
end;

function TSttBoolObjectJson.getJSonObject: TJsonObject;

begin
  Result := inherited getJSonObject;
  Result.AddPair('DefVal', JSonBoolToStr(defVal));
end;

procedure TSttBoolObjectJson.LoadFromJSonObj(jobj: TJsonObject);
begin
  inherited LoadFromJSonObj(jobj);
  defVal := LoadJsonBool(jobj, 'DefVal', false);
end;

// ----- TSettIntObjectJson ---------------------------------------------------
constructor TSttIntObjectJson.Create;
begin
  inherited Create('', '', sttINTEGER);
  MinVal := NAN_INT;
  MaxVal := NAN_INT;
  defVal := NAN_INT;
end;

constructor TSttIntObjectJson.Create(aName, aDescription: string; aMin, aMax, adef: integer);
begin
  inherited Create(aName, aDescription, sttINTEGER);
  MinVal := aMin;
  MaxVal := aMax;
  defVal := adef;
end;

function TSttIntObjectJson.getJSonObject: TJsonObject;
  function getIntStr(v: integer): string;
  begin
    if v = NAN_INT then
      Result := NAN_TEXT
    else
      Result := IntToStr(v);
  end;

begin
  Result := inherited getJSonObject;
  Result.AddPair('MinVal', getIntStr(MinVal));
  Result.AddPair('MaxVal', getIntStr(MaxVal));
  Result.AddPair('DefVal', getIntStr(defVal));
end;

procedure TSttIntObjectJson.LoadFromJSonObj(jobj: TJsonObject);
begin
  inherited LoadFromJSonObj(jobj);
  MinVal := LoadJsonInt(jobj, 'MinVal', NAN_INT);
  MaxVal := LoadJsonInt(jobj, 'MaxVal', NAN_INT);
  defVal := LoadJsonInt(jobj, 'DefVal', 0);
end;

// ----- TSettFloatObjectJson ---------------------------------------------------

constructor TSttFloatObjectJson.Create;
begin
  inherited Create('', '', sttFLOAT);
  MinVal := nan;
  MaxVal := nan;
  defVal := nan;
end;

constructor TSttFloatObjectJson.Create(aName, aDescription: string; aMin, aMax, adef: single; frm: string);
begin
  inherited Create(aName, aDescription, sttFLOAT);
  MinVal := aMin;
  MaxVal := aMax;
  defVal := adef;
  FormatStr := frm;
end;

function TSttFloatObjectJson.getJSonObject: TJsonObject;
  function getFloatStr(v: single): string;
  begin
    if isnan(v) then
      Result := 'NAN'
    else
      Result := floatToStr(v);
  end;

begin
  Result := inherited getJSonObject;
  Result.AddPair('MinVal', getFloatStr(MinVal));
  Result.AddPair('MaxVal', getFloatStr(MaxVal));
  Result.AddPair('DefVal', getFloatStr(defVal));
end;

procedure TSttFloatObjectJson.LoadFromJSonObj(jobj: TJsonObject);
begin
  inherited LoadFromJSonObj(jobj);
  MinVal := LoadJsonFloat(jobj, 'MinVal', nan);
  MaxVal := LoadJsonFloat(jobj, 'MaxVal', nan);
  defVal := LoadJsonFloat(jobj, 'DefVal', 0);
end;


// ----- TSettSelectObjectJson ---------------------------------------------------

constructor TSttSelectObjectJson.Create;
begin
  inherited Create('', '', sttSELECT);
  items := nil;
end;

constructor TSttSelectObjectJson.Create(aName, aDescription: string; aItems: TStringArr; aDefVal: string);
begin
  inherited Create(aName, aDescription, sttSELECT);
  items := aItems;
  defVal := aDefVal;
end;

constructor TSttSelectObjectJson.Create(aName, aDescription: string; aItems: TIntArr; aDefVal: integer);
var
  i, n: integer;
begin
  inherited Create(aName, aDescription, sttSELECT);
  n := length(aItems);
  setlength(items, n);
  for i := 0 to n - 1 do
    items[i] := IntToStr(aItems[i]);
  defVal := IntToStr(aDefVal);
end;

function TSttSelectObjectJson.getJSonObject: TJsonObject;
var
  jsonArray: TJSONArray;
  i: integer;
begin
  Result := inherited getJSonObject;
  jsonArray := TJSONArray.Create();
  for i := 0 to length(items) - 1 do
    jsonArray.AddElement(TJSONString.Create(items[i]));
  Result.AddPair('Items', jsonArray);
  Result.AddPair('DefVal', defVal);
end;

procedure TSttSelectObjectJson.LoadFromJSonObj(jobj: TJsonObject);
var
  jsonArray: TJSONArray;
  i: integer;
begin
  inherited LoadFromJSonObj(jobj);
  defVal := LoadJsonStr(jobj, 'DefVal', '');
  jsonArray := jobj.Values['Items'] as TJSONArray;
  setlength(items, jsonArray.Count);
  for i := 0 to jsonArray.Count - 1 do
  begin
    items[i] := jsonArray.items[i].Value;
  end;
end;

function TSttSelectObjectJson.GetItemsAsStrings: TStrings;
var
  i: integer;
begin
  Result := TStringList.Create;
  for i := 0 to length(items) - 1 do
  begin
    Result.Add(items[i]);
  end;
end;

// ----- TSettIPObjectJson ---------------------------------------------------

constructor TSttIPObjectJson.Create;
begin
  inherited Create('', '', sttIP);
end;

constructor TSttIPObjectJson.Create(aName, aDescription: string);
begin
  inherited Create(aName, aDescription, sttIP);
end;

end.
