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
  private
    minVal: double;
    maxVal: double;
    frmStr: string;
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameFloat.LoadField(ParamList: TSttObjectListJson);
var
  obj: TSttFloatObjectJson;
begin
  inherited;
  obj := InitFloatEditItem(SttFloatEdit, ParamList, FItemName);
  if Assigned(obj) then
  begin
    minVal := obj.minVal;
    maxVal := obj.maxVal;
    frmStr := obj.FormatStr;
  end;
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

initialization

RegisterSttFrame(sttFLOAT, TSttFrameFloat);

end.
