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
    procedure SttIntEditKeyPress(Sender: TObject; var Key: Char);
    procedure SttIntEditExit(Sender: TObject);
  private
    minVal: integer;
    maxVal: integer;
    defVal: integer;
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
    procedure LoadDefaultValue; override;
    procedure setActive(active: boolean); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameInt.LoadField(ParamList: TSttObjectListJson);
var
  obj: TSttIntObjectJson;
begin
  inherited;
  obj := InitIntEditItem(SttIntEdit, ParamList, itemName);
  if Assigned(obj) then
  begin
    minVal := obj.minVal;
    maxVal := obj.maxVal;
    defVal := obj.defVal;
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

procedure TSttFrameInt.LoadDefaultValue;
begin
  SttIntEdit.Text := IntToStr(defVal);
end;

procedure TSttFrameInt.setActive(active: boolean);
begin
  SttIntEdit.Enabled := active;
end;

procedure TSttFrameInt.SttIntEditExit(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, itemName, SttIntEdit.Text);
end;

procedure TSttFrameInt.SttIntEditKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #10 then
  begin
    Key := #0;
    SttIntEditExit(Sender);
  end;
end;

initialization

RegisterSttFrame(sttINTEGER, TSttFrameInt);

end.
