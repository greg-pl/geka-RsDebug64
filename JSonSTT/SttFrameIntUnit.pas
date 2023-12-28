unit SttFrameIntUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.JSON,
  SttFrameBaseUnit,
  SttObjectDefUnit;

type
  TSttFrameInt = class(TSttFrameBase)
    SttIntEdit: TLabeledEdit;
  private
    minVal: integer;
    maxVal: integer;
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameInt.LoadField(ParamList: TSttObjectListJson);
var
  obj: TSttIntObjectJson;
begin
  inherited;
  obj := InitIntEditItem(SttIntEdit, ParamList, FItemName);
  if Assigned(obj) then
  begin
    minVal := obj.minVal;
    maxVal := obj.maxVal;
  end;
end;

function TSttFrameInt.getData(obj: TJSONObject): boolean;
var
  v: integer;
begin
  Result := false;
  if tryStrToInt(SttIntEdit.Text, v) then
  begin
    Result := (v >= minVal) and (v <= maxVal);
  end;
  if Result then
    obj.AddPair(TJSONPair.Create(FItemName, IntToStr(v)))
  else
    SttIntEdit.SetFocus;
end;

procedure TSttFrameInt.setData(obj: TJSONObject);
begin
  LoadValIntEditJSon(obj, FItemName, SttIntEdit);
end;

initialization

RegisterSttFrame(sttINTEGER, TSttFrameInt);

end.
