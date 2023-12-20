unit SttFrameBaseUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.JSON,
  SttObjectDefUnit;

type
  TSttFrameBase = class(TFrame)
  private
    { Private declarations }
  protected
    FItemName: string;
  protected
    class procedure LoadComboBoxItem(Box: TComboBox; aLabel: TLabel; ParamList: TSttObjectListJson; SttName: string);
    class procedure LoadCheckBoxItem(Box: TCheckBox; ParamList: TSttObjectListJson; SttName: string);
    class procedure LoadIntEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string);
    class procedure LoadFloatEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string);
    class procedure LoadIPEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string);
  protected
    class function LoadValComboBoxJSon(obj: TJSONObject; Name: String; combo: TComboBox): boolean;
    class function LoadValCheckBoxJSon(obj: TJSONObject; Name: String; Box: TCheckBox): boolean;
    class function LoadValIntEditJSon(obj: TJSONObject; Name: String; Box: TLabeledEdit): boolean;
    class function LoadValFloatEditJSon(obj: TJSONObject; Name: String; Box: TLabeledEdit): boolean;
    class function LoadValIPEditJSon(obj: TJSONObject; Name: String; Box: TLabeledEdit): boolean;

  public
    constructor Create(AOwner: TComponent; aItemName: string); virtual;
    procedure AddObjectsName(SL: TStrings); virtual;
    procedure LoadField(ParamList: TSttObjectListJson); virtual;
    procedure getData(arr: TJSONObject); virtual;
    procedure setData(arr: TJSONObject); virtual;
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
begin

end;

procedure TSttFrameBase.getData(arr: TJSONObject);
begin

end;

procedure TSttFrameBase.setData(arr: TJSONObject);
begin

end;

class procedure TSttFrameBase.LoadComboBoxItem(Box: TComboBox; aLabel: TLabel; ParamList: TSttObjectListJson;
  SttName: string);
var
  stt: TSttObjectJson;
  SL: TStrings;
  idx: integer;
begin
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
    Box.Enabled := true;
    SL := (stt as TSttSelectObjectJson).GetItemsAsStrings;
    Box.Items.SetStrings(SL);
    Box.Style := csDropDownList;
    idx := SL.IndexOf((stt as TSttSelectObjectJson).DefVal);
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

class procedure TSttFrameBase.LoadCheckBoxItem(Box: TCheckBox; ParamList: TSttObjectListJson; SttName: string);
var
  stt: TSttObjectJson;
begin
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
    Box.Enabled := true;
    Box.Caption := stt.Description;
    Box.Checked := (stt as TSttBoolObjectJson).DefVal;
  end
  else
    Box.Enabled := false;
end;

class procedure TSttFrameBase.LoadIntEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string);
var
  stt: TSttObjectJson;
begin
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
    Box.Enabled := true;
    Box.EditLabel.Caption := stt.Description;
    Box.Text := IntToStr((stt as TSttIntObjectJson).DefVal);
  end
  else
    Box.Enabled := false;
end;

class procedure TSttFrameBase.LoadFloatEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string);
var
  stt: TSttObjectJson;
  f_Stt: TSttFloatObjectJson;
begin
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
    f_Stt := stt as TSttFloatObjectJson;
    Box.Enabled := true;
    Box.EditLabel.Caption := stt.Description;
    Box.Text := FormatFloat(f_Stt.FormatStr, f_Stt.DefVal);
  end
  else
    Box.Enabled := false;
end;

class procedure TSttFrameBase.LoadIPEditItem(Box: TLabeledEdit; ParamList: TSttObjectListJson; SttName: string);
var
  stt: TSttObjectJson;
begin
  stt := ParamList.FindSttObject(SttName);
  if Assigned(stt) then
  begin
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
    txt := jPair.JsonValue.Value;
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
    if JSonStrToBool(jPair.JsonValue.Value, q) then
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
    Box.Text := jPair.JsonValue.Value;
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
    Box.Text := jPair.JsonValue.Value;
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
    Box.Text := jPair.JsonValue.Value;
  end;
end;

initialization

SttClassList := TSttClassList.Create;

end.
