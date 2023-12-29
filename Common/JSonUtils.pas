unit JSonUtils;

interface

uses
  Winapi.Windows,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Samples.Spin,
  Vcl.ComCtrls,
  Messages, SysUtils, IniFiles, Menus, Forms, Classes,
  graphics, Contnrs, math, StdCtrls,
  System.JSON;

type
  TIntDynArr = array of integer;
  TFloatDynArr = array of double;
  TYesNoAsk = (crNO, crYES, crASK);

  TJSONStringEx = class(TJSONString)
  public
    function ToString: string; override;
  end;

  TJSONBuilder = record
    jobj: TJsonObject;
    procedure Init;
    procedure Add(valName: string; aVal: boolean); overload;
    procedure Add(valName: string; aVal: integer); overload;
    procedure Add(valName: string; aVal: string); overload;
    procedure Add(valName: string; aVal: TStrings); overload;
    procedure Add(valName: string; aVal: TIntDynArr); overload;
    procedure Add(valName: string; aVal: TJSONValue); overload;
    procedure Add(valName: string; aVal: TJSONBuilder); overload;

    procedure Add(aVal: TPoint); overload;
    procedure Add(R: TRect); overload;
    procedure Add(valName: string; Box: TComboBox); overload;

    procedure Add_TLWH(aVal: TWinControl);
    procedure AddColor(valName: string; aVal: TColor);
  end;

  // ---------------------------

type
  TJSONLoader = record
    jobj: TJsonObject;
    function Init(Obj: TJSONValue): boolean; overload;
    function Init(Parent: TJSONLoader; name: string): boolean; overload;

    function getArray(valName: string): TJSONArray;
    function GetObject(valName: string): TJsonObject;
    function getDynIntArray(valName: string): TIntDynArr;

    function Load(valName: string; var vVal: string): boolean; overload;
    function Load(valName: string; var vVal: integer): boolean; overload;
    function Load(valName: string; var vVal: double): boolean; overload;
    function Load(valName: string; var vVal: boolean): boolean; overload;
    function Load(valName: string; var vVal: TYesNoAsk): boolean; overload;
    function Load(valName: string; var intArr: TIntDynArr): boolean; overload;
    function Load(valName: string; SL: TStrings): boolean; overload;

    function Load(valName: string; CheckBox: TCheckBox): boolean; overload;
    function Load(valName: string; SpinEdit: TSpinEdit): boolean; overload;

    function Load(valName: string; Edit: TLabeledEdit): boolean; overload;
    function Load(valName: string; Group: TRadioGroup): boolean; overload;
    function Load(valName: string; Box: TComboBox): boolean; overload;

    function Load(var R: TRect): boolean; overload;
    function Load(var P: TPoint): boolean; overload;

    function Load_WH(ctrl: TControl): boolean;
    function Load_TLWH(ctrl: TControl): boolean;
    function LoadBtnDown(valName: string; btn: TToolButton): boolean;
    function LoadColor(valName: string; var Color: TColor): boolean;

    function LoadDef(valName: string; vDefault: string = ''): string; overload;
    function LoadDef(valName: string; vDefault: integer): integer; overload;
    function LoadDef(valName: string; vDefault: boolean): boolean; overload;
    function LoadColorDef(valName: string; vDefault: TColor): TColor; overload;

  end;

implementation

const
  NAN_TEXT = 'NAN';

function TJSONStringEx.ToString: string;
var
  Data: TArray<Byte>;
  idx: integer;
  txt: AnsiString;
begin
  Result := inherited ToString;
  setLength(Data, 4 * length(Result));
  idx := ToBytes(Data, 0);
  setLength(txt, idx);
  move(Data[0], txt[1], idx);
  Result := String(txt);
end;

function TryStrToInt0x(txt: string; var n: integer): boolean;
begin
  if (length(txt) > 3) and (copy(txt, 1, 2) = '0x') then
  begin
    txt := '$' + copy(txt, 3, length(txt) - 2);
  end;
  Result := TRyStrToInt(txt, n);
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

procedure TJSONBuilder.Init;
begin
  jobj := TJsonObject.Create;
end;

procedure TJSONBuilder.Add(valName: string; aVal: boolean);
begin
  jobj.AddPair(TJSONPair.Create(valName, TJSONBool.Create(aVal)));
end;

procedure TJSONBuilder.Add(valName: string; aVal: integer);
begin
  jobj.AddPair(TJSONPair.Create(valName, TJSONNumber.Create(aVal)));
end;

procedure TJSONBuilder.Add(valName: string; aVal: string);
begin
  jobj.AddPair(valName, TJSONStringEx.Create(aVal));
end;

procedure TJSONBuilder.Add(valName: string; aVal: TStrings);
var
  jArr: TJSONArray;
  i: integer;
begin
  jArr := TJSONArray.Create();
  for i := 0 to aVal.Count - 1 do
  begin
    jArr.Add(aVal.Strings[i]);
  end;
  jobj.AddPair(TJSONPair.Create(valName, jArr));
end;

procedure TJSONBuilder.Add(valName: string; aVal: TIntDynArr);
var
  jArr: TJSONArray;
  i: integer;
begin
  jArr := TJSONArray.Create();
  for i := 0 to length(aVal) - 1 do
    jArr.Add(aVal[i]);
  jobj.AddPair(TJSONPair.Create(valName, jArr));
end;

procedure TJSONBuilder.Add(valName: string; aVal: TJSONValue);
begin
  jobj.AddPair(valName, aVal);
end;

procedure TJSONBuilder.Add(valName: string; aVal: TJSONBuilder);
begin
  jobj.AddPair(valName, aVal.jobj);
end;

procedure TJSONBuilder.Add(aVal: TPoint);
begin
  Add('X', aVal.X);
  Add('Y', aVal.Y);
end;

procedure TJSONBuilder.Add_TLWH(aVal: TWinControl);
begin
  Add('Top', aVal.Top);
  Add('Left', aVal.Left);
  Add('Width', aVal.Width);
  Add('Height', aVal.Height);
end;

procedure TJSONBuilder.Add(R: TRect);
begin
  Add('Top', R.Top);
  Add('Left', R.Left);
  Add('Right', R.Right);
  Add('Bottom', R.Bottom);
end;

procedure TJSONBuilder.Add(valName: string; Box: TComboBox);
begin
  if Box.Style = csDropDownList then
    Add(valName, Box.ItemIndex)
  else
    Add(valName, Box.Text);
end;

procedure TJSONBuilder.AddColor(valName: string; aVal: TColor);
begin
  jobj.AddPair(valName, '0x' + IntToHex(aVal, 8));
end;

procedure JSonAddPair(Obj: TJsonObject; valName: string; aVal: string);
begin
  Obj.AddPair(valName, TJSONStringEx.Create(aVal));
end;

// --------------------------------------------------------------------------------

function TJSONLoader.Init(Obj: TJSONValue): boolean;
begin
  jobj := nil;
  Result := Assigned(Obj) and (Obj is TJsonObject);
  if Result then
    jobj := Obj as TJsonObject
end;

function TJSONLoader.Init(Parent: TJSONLoader; name: string): boolean;
var
  jVal: TJSONValue;
begin
  jobj := nil;
  jVal := Parent.jobj.GetValue(name);
  Result := Assigned(jVal) and (jVal is TJsonObject);
  if Result then
    jobj := jVal as TJsonObject;
end;

function TJSONLoader.getArray(valName: string): TJSONArray;
var
  jVal: TJSONValue;
begin
  Result := nil;
  jVal := jobj.GetValue(valName);
  if jVal is TJSONArray then
    Result := jVal as TJSONArray;
end;

function TJSONLoader.GetObject(valName: string): TJsonObject;
var
  jVal: TJSONValue;
begin
  Result := nil;
  jVal := jobj.GetValue(valName);
  if jVal is TJsonObject then
    Result := jVal as TJsonObject;
end;

function TJSONLoader.getDynIntArray(valName: string): TIntDynArr;
var
  jArr: TJSONArray;
  i: integer;
begin
  setLength(Result, 0);
  jArr := jobj.GetValue(valName) as TJSONArray;
  if Assigned(jArr) then
  begin
    setLength(Result, jArr.Count);
    for i := 0 to jArr.Count - 1 do
    begin
      Result[i] := StrToInt(jArr.Items[i].Value);
    end;
  end;
end;

function TJSONLoader.Load(valName: string; var vVal: string): boolean;
var
  jVal: TJSONValue;
begin
  jVal := jobj.GetValue(valName);
  Result := Assigned(jVal);
  if Result then
    vVal := jVal.Value;
end;

function TJSONLoader.Load(valName: string; var vVal: integer): boolean;
var
  jVal: TJSONValue;
begin
  jVal := jobj.GetValue(valName);
  Result := Assigned(jVal);
  if Result then
    Result := TRyStrToInt(jVal.Value, vVal);
end;

function TJSONLoader.Load(valName: string; var vVal: double): boolean;
var
  jVal: TJSONValue;
begin
  jVal := jobj.GetValue(valName);
  Result := Assigned(jVal);
  if Result then
    Result := TryStrToFloat(jVal.Value, vVal);
end;

function TJSONLoader.Load(valName: string; var vVal: boolean): boolean;
var
  jVal: TJSONValue;
begin
  jVal := jobj.GetValue(valName);
  Result := Assigned(jVal);
  if Result then
    Result := JSonStrToBool(jVal.Value, vVal);
end;

function TJSONLoader.Load(valName: string; var vVal: TYesNoAsk): boolean;
var
  v: integer;
begin
  v := ord(vVal);
  Result := Load(valName, v);
  Result := Result and (v >= ord(low(TYesNoAsk))) and (v <= ord(high(TYesNoAsk)));
  if Result then
    vVal := TYesNoAsk(v);
end;

function TJSONLoader.Load(valName: string; CheckBox: TCheckBox): boolean;
var
  q: boolean;
begin
  Result := Load(valName, q);
  if Result then
    CheckBox.Checked := q;
end;

function TJSONLoader.Load(valName: string; SpinEdit: TSpinEdit): boolean;
var
  v: integer;
begin
  Result := Load(valName, v);
  if Result then
    SpinEdit.Value := v;
end;

function TJSONLoader.Load(valName: string; Edit: TLabeledEdit): boolean;
var
  v: string;
begin
  Result := Load(valName, v);
  if Result then
    Edit.Text := v;
end;

function TJSONLoader.Load(valName: string; Box: TComboBox): boolean;
var
  v: string;
  c: integer;
begin
  Result := false;
  if Box.Style = csDropDownList then
  begin
    if Load(valName, c) then
    begin
      Result := true;
      Box.ItemIndex := c;
    end;
  end
  else
  begin
    if Load(valName, v) then
    begin
      Result := true;
      Box.Text := v;
    end;
  end;

end;

function TJSONLoader.Load(valName: string; Group: TRadioGroup): boolean;
var
  v: integer;
begin
  Result := Load(valName, v);
  if Result then
    Group.ItemIndex := v;
end;

function TJSONLoader.Load(var R: TRect): boolean;
begin
  Result := Load('Top', R.Top);
  Result := Result and Load('Left', R.Left);
  Result := Result and Load('Right', R.Right);
  Result := Result and Load('Bottom', R.Bottom);
end;

function TJSONLoader.Load(var P: TPoint): boolean;
begin
  Result := Load('X', P.X) and Load('Y', P.Y);
end;

function TJSONLoader.Load(valName: string; var intArr: TIntDynArr): boolean;
var
  jArr: TJSONArray;
  i: integer;
begin
  Result := false;
  setLength(intArr, 0);
  jArr := jobj.GetValue(valName) as TJSONArray;
  if Assigned(jArr) then
  begin
    Result := true;
    setLength(intArr, jArr.Count);
    for i := 0 to jArr.Count - 1 do
    begin
      intArr[i] := StrToInt(jArr.Items[i].Value);
    end;
  end;
end;

function TJSONLoader.Load(valName: string; SL: TStrings): boolean;
var
  jArr: TJSONArray;
  i: integer;
begin
  Result := false;
  jArr := jobj.GetValue(valName) as TJSONArray;
  if Assigned(jArr) then
  begin
    Result := true;
    SL.Clear;
    for i := 0 to jArr.Count - 1 do
    begin
      SL.Add(jArr.Items[i].Value);
    end;
  end;
end;

function TJSONLoader.Load_WH(ctrl: TControl): boolean;
var
  w, h: integer;
begin
  Result := Load('W', w) and Load('H', h);
  if Result then
  begin
    ctrl.Width := w;
    ctrl.Height := h;
  end;
end;

function TJSONLoader.Load_TLWH(ctrl: TControl): boolean;
var
  t, l, w, h: integer;
begin
  Result := Load('Top', t) and Load('Left', l) and Load('Width', w) and Load('Height', h);
  if Result then
  begin
    ctrl.Top := t;
    ctrl.Left := l;
    ctrl.Width := w;
    ctrl.Height := h;
  end;
end;

function TJSONLoader.LoadBtnDown(valName: string; btn: TToolButton): boolean;
var
  q: boolean;
begin
  Result := Load(valName, q);
  if Result then
    btn.Down := q;
end;

function TJSONLoader.LoadColor(valName: string; var Color: TColor): boolean;
var
  txt: string;
  n: integer;
begin
  Result := Load(valName, txt);
  if Result then
  begin
    Result := TryStrToInt0x(txt, n);
    Color := TColor(n);
  end
end;

function TJSONLoader.LoadDef(valName: string; vDefault: string): string;
begin
  Result := vDefault;
  Load(valName, Result);
end;

function TJSONLoader.LoadDef(valName: string; vDefault: integer): integer;
begin
  Result := vDefault;
  Load(valName, Result);
end;

function TJSONLoader.LoadDef(valName: string; vDefault: boolean): boolean;
begin
  Result := vDefault;
  Load(valName, Result);
end;

function TJSONLoader.LoadColorDef(valName: string; vDefault: TColor): TColor;
begin
  Result := vDefault;
  LoadColor(valName, Result);
end;

end.
