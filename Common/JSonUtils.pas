unit JSonUtils;

interface

uses
  Winapi.Windows,
  Vcl.Controls,
  Messages, SysUtils, IniFiles, Menus, Forms, Classes,
  graphics, Contnrs, math, StdCtrls,
  System.JSON;

type
  TIntDynArr = array of integer;
  TFloatDynArr = array of double;

function CreateJsonPairBool(valName: string; aVal: boolean): TJSONPair;
function CreateJsonPairInt(valName: string; aVal: integer): TJSONPair;
function CreateJsonPairStrings(valName: string; aVal: TStrings): TJSONPair;


procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: string); overload;
procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: integer); overload;
procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: bool); overload;
procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: TStrings); overload;
procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: TIntDynArr); overload;
procedure JSonAddPair(Obj: TJsonObject; aVal: TPoint); overload;

procedure JSONAddPair_TLWH(Obj: TJsonObject; aVal: TWinControl);
procedure JSonAddPairColor(Obj: TJsonObject; valName: string; aVal: TColor);


function JsonLoadStr(jobj: TJsonObject; valName: string; defTex: string): string;
function JsonLoadInt(jobj: TJsonObject; valName: string; defVal: integer): integer;
function JsonLoadFloat(jobj: TJsonObject; valName: string; defVal: single): single;
function JsonLoadBool(jobj: TJsonObject; valName: string; defVal: boolean): boolean;

function CreateJsonObjectTRect(const R: TRect): TJsonObject;

implementation

const
  NAN_TEXT = 'NAN';

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

function CreateJsonPairBool(valName: string; aVal: boolean): TJSONPair;
begin
  Result := TJSONPair.Create(valName, TJSONBool.Create(aVal));
end;

function CreateJsonPairInt(valName: string; aVal: integer): TJSONPair;
begin
  Result := TJSONPair.Create(valName, TJSONNumber.Create(aVal));
end;

function CreateJsonPairStrings(valName: string; aVal: TStrings): TJSONPair;
var
  jArr: TJSONArray;
  i: integer;
begin
  jArr := TJSONArray.Create();
  for i := 0 to aVal.Count - 1 do
  begin
    jArr.Add(aVal.Strings[i]);
  end;
  Result := TJSONPair.Create(valName, jArr);
end;


procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: string);
begin
  Obj.AddPair(valName, aVal);
end;

procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: integer);
begin
  Obj.AddPair(valName, TJSONNumber.Create(aVal));
end;

procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: bool);
begin
  Obj.AddPair(valName, TJSONBool.Create(aVal));
end;

procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: TStrings);
var
  jArr: TJSONArray;
  i: integer;
begin
  jArr := TJSONArray.Create();
  for i := 0 to aVal.Count - 1 do
    jArr.Add(aVal.Strings[i]);
  Obj.AddPair(TJSONPair.Create(valName, jArr));
end;

procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: TIntDynArr);
var
  jArr: TJSONArray;
  i: integer;
begin
  jArr := TJSONArray.Create();
  for i := 0 to length(aVal) - 1 do
    jArr.Add(aVal[i]);
  Obj.AddPair(TJSONPair.Create(valName, jArr));
end;



procedure JSonAddPair(Obj: TJsonObject; aVal: TPoint);
begin
  JSonAddPair(Obj,'X',aVal.X);
  JSonAddPair(Obj,'Y',aVal.Y);
end;


procedure JSonAddPairColor(Obj: TJsonObject; valName: string; aVal: TColor);
begin
  Obj.AddPair(valName, '0x'+IntToHex(aVal,8));
end;

procedure JSONAddPair_TLWH(Obj: TJsonObject; aVal: TWinControl);
begin
  JSonAddPair(Obj,'Top',aVal.Top);
  JSonAddPair(Obj,'Left',aVal.Left);
  JSonAddPair(Obj,'Width',aVal.Width);
  JSonAddPair(Obj,'Height',aVal.Height);
end;


function JsonLoadStr(jobj: TJsonObject; valName: string; defTex: string): string;
var
  jVal: TJSONValue;
begin
  jVal := jobj.GetValue(valName);
  if Assigned(jVal) then
    Result := jVal.Value
  else
    Result := defTex;
end;

function JsonLoadInt(jobj: TJsonObject; valName: string; defVal: integer): integer;
var
  jVal: TJSONValue;
  txt: string;
begin
  jVal := jobj.GetValue(valName);
  if Assigned(jVal) then
  begin
    txt := jVal.Value;
    if not(TryStrToInt(jVal.Value, Result)) then
      Result := defVal;
  end
  else
    Result := defVal;
end;

function JsonLoadFloat(jobj: TJsonObject; valName: string; defVal: single): single;
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

function JsonLoadBool(jobj: TJsonObject; valName: string; defVal: boolean): boolean;
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

function CreateJsonObjectTRect(const R: TRect): TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.AddPair(CreateJsonPairInt('Top', R.Top));
  Result.AddPair(CreateJsonPairInt('Left', R.Left));
  Result.AddPair(CreateJsonPairInt('Right', R.Right));
  Result.AddPair(CreateJsonPairInt('Bottom', R.Bottom));
end;

end.
