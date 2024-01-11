unit SttFrameFloatUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.JSON,
  SttFrameBaseUnit,
  SttObjectDefUnit;

type
  TSttFrameFloat = class(TSttFrameBase)
    SttFloatEdit: TLabeledEdit;
    procedure SttFloatEditExit(Sender: TObject);
    procedure SttFloatEditKeyPress(Sender: TObject; var Key: Char);
  private
    minVal: double;
    maxVal: double;
    defVal: double;
    frmStr: string;
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
    procedure LoadDefaultValue; override;
    procedure setActive(active: boolean); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameFloat.LoadField(ParamList: TSttObjectListJson);
var
  obj: TSttFloatObjectJson;
begin
  inherited;
  obj := InitFloatEditItem(SttFloatEdit, ParamList, itemName);
  if Assigned(obj) then
  begin
    minVal := obj.minVal;
    maxVal := obj.maxVal;
    defVal := obj.defVal;
    frmStr := obj.FormatStr;
  end;
end;

procedure TSttFrameFloat.LoadDefaultValue;
begin
  SttFloatEdit.Text := Formatfloat(frmStr, defVal);
end;

procedure TSttFrameFloat.setActive(active: boolean);
begin
  SttFloatEdit.Enabled := active;
end;

function TSttFrameFloat.getData(obj: TJSONObject): boolean;
var
  v: double;
begin
  Result := false;
  if tryStrToFloat(SttFloatEdit.Text, v) then
  begin
    Result := (v >= minVal) and (v <= maxVal);
  end;
  if Result then
    obj.AddPair(TJSONPair.Create(FItemName, Formatfloat(frmStr, v)))
  else
    SttFloatEdit.SetFocus;
end;

procedure TSttFrameFloat.setData(obj: TJSONObject);
begin
  LoadValFloatEditJSon(obj, FItemName, SttFloatEdit);
end;

procedure TSttFrameFloat.SttFloatEditExit(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, itemName, SttFloatEdit.Text);
end;

procedure TSttFrameFloat.SttFloatEditKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #10 then
  begin
    Key := #0;
    SttFloatEditExit(Sender);
  end;

end;

initialization

RegisterSttFrame(sttFLOAT, TSttFrameFloat);

end.
