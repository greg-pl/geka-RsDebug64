unit SttObjectDefUnit;

interface

uses
  SysUtils, Classes,
  System.AnsiStrings,
  System.Contnrs,
  System.Generics.Collections,
  System.JSON,
  JSonUtils,
  math;

const
  NAN_INT = $7FFFFFFF;
  NAN_TEXT = 'NAN';

type

  TSttType = (sttBOOL, sttINTEGER, sttFLOAT, sttSELECT, sttIP);

  TSttObjectJson = class(TObject)
  public
    Name: string;
    Description: string;
    SettType: TSttType;
    ValueValid: boolean;
    class function CreateObject(SttTypeNm: string): TSttObjectJson;
    constructor Create(aName, aDescription: string; aTyp: TSttType);
    function getJSonObject: TJSONBuilder; virtual;
    procedure LoadFromJSonObj(jLoader: TJSONLoader); virtual;
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
    function getJSonObject: TJsonValue;
  end;

  TSttBoolObjectJson = class(TSttObjectJson)
    defVal: boolean;
    Value: boolean;
    constructor Create; overload;
    constructor Create(aName, aDescription: string; adef: boolean); overload;
    function getJSonObject: TJSONBuilder; override;
    procedure LoadFromJSonObj(jLoader: TJSONLoader); override;
  end;

  TSttIntObjectJson = class(TSttObjectJson)
    MinVal: integer;
    MaxVal: integer;
    defVal: integer;
    Value: integer;
    constructor Create; overload;
    constructor Create(aName, aDescription: string; aMin, aMax, adef: integer); overload;
    function getJSonObject: TJSONBuilder; override;
    procedure LoadFromJSonObj(jLoader: TJSONLoader); override;
  end;

  TSttFloatObjectJson = class(TSttObjectJson)
    MinVal: double;
    MaxVal: double;
    defVal: double;
    Value: double;
    FormatStr: string;
    constructor Create; overload;
    constructor Create(aName, aDescription: string; aMin, aMax, adef: single; frm: string); overload;
    function getJSonObject: TJSONBuilder; override;
    procedure LoadFromJSonObj(jLoader: TJSONLoader); override;
  end;

  TSttSelectObjectJson = class(TSttObjectJson)
    items: TStringArr;
    defVal: string;
    Value: string;
    constructor Create; overload;
    constructor Create(aName, aDescription: string; aItems: TStringArr; aDefVal: string); overload;
    constructor Create(aName, aDescription: string; aItems: TIntArr; aDefVal: integer); overload;
    function getJSonObject: TJSONBuilder; override;
    procedure LoadFromJSonObj(jLoader: TJSONLoader); override;
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
  else
    Result := nil;
  end;
  if Assigned(Result) then
  begin
    Result.ValueValid := false;
  end;
end;

function TSttObjectJson.getJSonObject: TJSONBuilder;
begin
  Result.Init;
  Result.Add('SttType', SttTypeNames[ord(SettType)]);
  Result.Add('Name', Name);
  Result.Add('Descr', Description);
end;

procedure TSttObjectJson.LoadFromJSonObj(jLoader: TJSONLoader);
begin
  Name := jLoader.LoadDef('Name', '_noName_');
  Description := jLoader.LoadDef('Descr', '');
end;

class function TSttObjectJson.LoadJsonStr(jobj: TJsonObject; valName: string; defTex: string): string;
var
  jVal: TJsonValue;
begin
  jVal := jobj.GetValue(valName);
  if Assigned(jVal) then
    Result := jVal.Value
  else
    Result := defTex;
end;

class function TSttObjectJson.LoadJsonInt(jobj: TJsonObject; valName: string; defVal: integer): integer;
var
  jVal: TJsonValue;
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
  jVal: TJsonValue;
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
  jVal: TJsonValue;
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

function TSttObjectListJson.getJSonObject: TJsonValue;
var
  jsonArray: TJSONArray;
  i: integer;
begin
  jsonArray := TJSONArray.Create();
  for i := 0 to Count - 1 do
  begin
    jsonArray.AddElement(items[i].getJSonObject.jobj);
  end;
  Result := jsonArray;
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

function TSttBoolObjectJson.getJSonObject: TJSONBuilder;

begin
  Result := inherited getJSonObject;
  Result.Add('DefVal', defVal);
  if ValueValid then
    Result.Add('DefVal', Value);
end;

procedure TSttBoolObjectJson.LoadFromJSonObj(jLoader: TJSONLoader);
begin
  inherited LoadFromJSonObj(jLoader);
  jLoader.Load('DefVal', defVal);
  ValueValid := jLoader.Load('Value', Value);
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

function TSttIntObjectJson.getJSonObject: TJSONBuilder;
begin
  Result := inherited getJSonObject;
  Result.Add('MinVal', MinVal);
  Result.Add('MaxVal', MaxVal);
  Result.Add('DefVal', defVal);
  if ValueValid then
    Result.Add('DefVal', Value);
end;

procedure TSttIntObjectJson.LoadFromJSonObj(jLoader: TJSONLoader);
begin
  inherited LoadFromJSonObj(jLoader);
  MinVal := jLoader.LoadDef('MinVal', NAN_INT);
  MaxVal := jLoader.LoadDef('MaxVal', NAN_INT);
  defVal := jLoader.LoadDef('DefVal', 0);
  ValueValid := jLoader.Load('Value', Value);
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

function TSttFloatObjectJson.getJSonObject: TJSONBuilder;
begin
  Result := inherited getJSonObject;
  Result.Add('MinVal', MinVal);
  Result.Add('MaxVal', MaxVal);
  Result.Add('DefVal', defVal);
end;

procedure TSttFloatObjectJson.LoadFromJSonObj(jLoader: TJSONLoader);
begin
  inherited LoadFromJSonObj(jLoader);
  MinVal := jLoader.LoadDef('MinVal', nan);
  MaxVal := jLoader.LoadDef('MaxVal', nan);
  defVal := jLoader.LoadDef('DefVal', 0);
  ValueValid := jLoader.Load('Value', Value);
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

function TSttSelectObjectJson.getJSonObject: TJSONBuilder;
var
  jsonArray: TJSONArray;
  i: integer;
begin
  Result := inherited getJSonObject;
  jsonArray := TJSONArray.Create();
  for i := 0 to length(items) - 1 do
    jsonArray.AddElement(TJSONString.Create(items[i]));
  Result.Add('Items', jsonArray);

  Result.Add('Items', items);


  Result.Add('DefVal', defVal);
end;

procedure TSttSelectObjectJson.LoadFromJSonObj(jLoader: TJSONLoader);
var
  jsonArray: TJSONArray;
  i: integer;
begin
  inherited LoadFromJSonObj(jLoader);
  defVal := jLoader.LoadDef( 'DefVal', '');
  jLoader.Load('Items',items);

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
