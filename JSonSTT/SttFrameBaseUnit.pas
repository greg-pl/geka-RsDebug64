unit SttFrameBaseUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.JSON,
  JsonUtils,
  SttObjectDefUnit;

type
  TOnSttItemValueEdited = procedure(Sender: TObject; itemName, value: string) of object;

  TSttFrameBase = class(TFrame)
    BevelAll: TBevel;
  private
    FActiveWhileOpen: boolean;
  protected
    FItemName: string;
    FOnValueEdited: TOnSttItemValueEdited;
  protected
    class function InitComboBoxItem(Box: TComboBox; aLabel: TLabel; ParamList: TSttObjectListJson; SttName: string)
      : TSttSelectObjectJson;
    class function InitCheckBoxItem(Box: TCheckBox; ParamList: TSttObjectListJson; SttName: string): TSttBoolObjectJson;

    class function InitIntEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string)
      : TSttIntObjectJson;
    class function InitFloatEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string)
      : TSttFloatObjectJson;
    class function InitIPEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string): TSttIPObjectJson;
    class function InitStrEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string): TSttStringObjectJson;

  protected
    class function LoadValComboBoxJSon(obj: TJSONObject; Name: String; combo: TComboBox): boolean;
    class function LoadValCheckBoxJSon(obj: TJSONObject; Name: String; Box: TCheckBox): boolean;
    class function LoadValIntEditJSon(obj: TJSONObject; Name: String; Box: TLabeledEdit): boolean;
    class function LoadValFloatEditJSon(obj: TJSONObject; Name: String; Box: TLabeledEdit): boolean;
    class function LoadValIPEditJSon(obj: TJSONObject; Name: String; Box: TLabeledEdit): boolean;

  public
    Description : string;
    constructor Create(AOwner: TComponent; aItemName: string); virtual;
    procedure AddObjectsName(SL: TStrings); virtual;
    procedure LoadField(ParamList: TSttObjectListJson); virtual; // --
    function getSttData(arr: TJSONObject): boolean; virtual;
    procedure setData(arr: TJSONObject); virtual;
    procedure SetOnValueEdited(aOnValueEdited: TOnSttItemValueEdited); virtual;
    procedure LoadDefaultValue; virtual;
    procedure setActive(active: boolean); virtual;
    procedure setActiveFromUniBool;

    property itemName: string read FItemName;

  end;

  TSttFrameBaseClass = class of TSttFrameBase;

procedure RegisterSttFrame(sttTyp: TSttType; SttClass: TSttFrameBaseClass);
function GetSttFrameClass(sttType: TSttType): TSttFrameBaseClass;

implementation

{$R *.dfm}

type
  TMemClassObj = class(TObject)
    sttTyp: TSttType;
    SttClass: TSttFrameBaseClass;
  end;

  TSttClassList = TList<TMemClassObj>;

var
  SttClassList: TSttClassList;

procedure RegisterSttFrame(sttTyp: TSttType; SttClass: TSttFrameBaseClass);
var
  obj: TMemClassObj;
begin
  obj := TMemClassObj.Create;
  obj.sttTyp := sttTyp;
  obj.SttClass := SttClass;
  SttClassList.Add(obj);
end;

function GetSttFrameClass(sttType: TSttType): TSttFrameBaseClass;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to SttClassList.Count - 1 do
  begin
    if SttClassList.Items[i].sttTyp = sttType then
    begin
      Result := SttClassList.Items[i].SttClass;
      break;
    end;
  end;
end;

constructor TSttFrameBase.Create(AOwner: TComponent; aItemName: string);
begin
  inherited Create(AOwner);
  FItemName := aItemName;
  Name := 'Comp_' + aItemName;
end;

procedure TSttFrameBase.AddObjectsName(SL: TStrings);
begin
  SL.Add(FItemName);
end;

procedure TSttFrameBase.LoadField(ParamList: TSttObjectListJson);
var
  stt: TSttObjectJson;
begin
  stt := ParamList.FindSttObject(itemName);
  if Assigned(stt) then
  begin
    Description := stt.Description;
    if stt.UniBoolValid then
      FActiveWhileOpen := stt.UniBool
    else
      FActiveWhileOpen := true;
  end;
end;

function TSttFrameBase.getSttData(arr: TJSONObject): boolean;
begin

end;

procedure TSttFrameBase.setData(arr: TJSONObject);
begin

end;

procedure TSttFrameBase.SetOnValueEdited(aOnValueEdited: TOnSttItemValueEdited);
begin
  FOnValueEdited := aOnValueEdited;
end;

procedure TSttFrameBase.LoadDefaultValue;
begin

end;

procedure TSttFrameBase.setActive(active: boolean);
begin

end;

procedure TSttFrameBase.setActiveFromUniBool;
begin
  setActive(FActiveWhileOpen);
end;

class function TSttFrameBase.InitComboBoxItem(Box: TComboBox; aLabel: TLabel; ParamList: TSttObjectListJson;
  SttName: string): TSttSelectObjectJson;
var
  SL: TStrings;
  idx: integer;
  stt: TSttObjectJson;
begin
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
    Box.Enabled := true;
    Result := stt as TSttSelectObjectJson;
    SL := Result.GetItemsAsStrings;
    Box.Items.SetStrings(SL);
    Box.Style := csDropDownList;
    idx := SL.IndexOf(Result.defVal);
    if idx < 0 then
      idx := 0;
    Box.ItemIndex := idx;
    SL.free;
    if Assigned(aLabel) then
      aLabel.Caption := stt.Description;
  end
  else
    Box.Enabled := false;
end;

class function TSttFrameBase.InitCheckBoxItem(Box: TCheckBox; ParamList: TSttObjectListJson; SttName: string)
  : TSttBoolObjectJson;
var
  stt: TSttObjectJson;
begin
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
    Result := stt as TSttBoolObjectJson;
    Box.Enabled := true;
    Box.Caption := stt.Description;
    Box.Checked := Result.defVal;
  end
  else
    Box.Enabled := false;
end;

class function TSttFrameBase.InitIntEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string)
  : TSttIntObjectJson;
var
  stt: TSttObjectJson;
begin
  Result := nil;
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
    Box.Enabled := true;
    Box.EditLabel.Caption := stt.Description;
    Result := stt as TSttIntObjectJson;
    Box.Text := IntToStr(Result.defVal);
  end
  else
    Box.Enabled := false;
end;

class function TSttFrameBase.InitFloatEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string)
  : TSttFloatObjectJson;
var
  stt: TSttObjectJson;
begin
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
    Result := stt as TSttFloatObjectJson;
    Box.Enabled := true;
    Box.EditLabel.Caption := stt.Description;
    Box.Text := FormatFloat(Result.FormatStr, Result.defVal);
  end
  else
    Box.Enabled := false;
end;

class function TSttFrameBase.InitIPEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string)
  : TSttIPObjectJson;
var
  stt: TSttObjectJson;
begin
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
    Result := stt as TSttIPObjectJson;
    Box.Enabled := true;
    Box.EditLabel.Caption := stt.Description;
    Box.Text := '';
  end
  else
    Box.Enabled := false;
end;


class function TSttFrameBase.InitStrEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string)
  : TSttStringObjectJson;
var
  stt: TSttObjectJson;
begin
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
    Result := stt as TSttStringObjectJson;
    Box.Enabled := true;
    Box.EditLabel.Caption := stt.Description;
    Box.Text := '';
  end
  else
    Box.Enabled := false;
end;


class function TSttFrameBase.LoadValComboBoxJSon(obj: TJSONObject; Name: String; combo: TComboBox): boolean;
var
  jPair: TJsonPair;
  txt: string;
  idx: integer;
begin
  Result := false;
  jPair := obj.Get(Name);
  if Assigned(jPair) then
  begin
    txt := jPair.JsonValue.value;
    idx := combo.Items.IndexOf(txt);
    if idx >= 0 then
    begin
      combo.ItemIndex := idx;
      Result := true;
    end;
  end;
end;

class function TSttFrameBase.LoadValCheckBoxJSon(obj: TJSONObject; Name: String; Box: TCheckBox): boolean;
var
  jPair: TJsonPair;
  q: boolean;
begin
  Result := false;
  jPair := obj.Get(Name);
  if Assigned(jPair) then
  begin
    if JSonStrToBool(jPair.JsonValue.value, q) then
    begin
      Result := true;
      Box.Checked := q;
    end;
  end;
end;

class function TSttFrameBase.LoadValIntEditJSon(obj: TJSONObject; Name: String; Box: TLabeledEdit): boolean;
var
  jPair: TJsonPair;
begin
  Result := false;
  jPair := obj.Get(Name);
  if Assigned(jPair) then
  begin
    Box.Text := jPair.JsonValue.value;
  end;
end;

class function TSttFrameBase.LoadValFloatEditJSon(obj: TJSONObject; Name: String; Box: TLabeledEdit): boolean;
var
  jPair: TJsonPair;
begin
  Result := false;
  jPair := obj.Get(Name);
  if Assigned(jPair) then
  begin
    Box.Text := jPair.JsonValue.value;
  end;
end;

class function TSttFrameBase.LoadValIPEditJSon(obj: TJSONObject; Name: String; Box: TLabeledEdit): boolean;
var
  jPair: TJsonPair;
begin
  Result := false;
  jPair := obj.Get(Name);
  if Assigned(jPair) then
  begin
    Box.Text := jPair.JsonValue.value;
  end;
end;

initialization

SttClassList := TSttClassList.Create;

end.
