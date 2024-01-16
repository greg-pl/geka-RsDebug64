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
    HexFormat: boolean;
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getSttData(obj: TJSONObject): boolean; override;
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
    HexFormat := obj.HexFormat;
    if (minVal <> NAN_INT) and (maxVal <> NAN_INT) then
    begin
      if not(HexFormat) then
        SttIntEdit.Hint := Format('Range %d-%d default=%d', [minVal, maxVal, defVal])
      else
        SttIntEdit.Hint := Format('Range 0x%X-0x%X default=0x%X', [minVal, maxVal, defVal])
    end;

    SttIntEdit.ShowHint := true;

  end;
end;

function TSttFrameInt.getSttData(obj: TJSONObject): boolean;
var
  v: integer;
begin
  Result := false;
  if tryStrToInt(SttIntEdit.Text, v) then
  begin
    Result := true;
    if minVal <> NAN_INT then
      Result := Result and (v >= minVal);
    if maxVal <> NAN_INT then
      Result := Result and (v <= maxVal);
  end;
  if Result then
  begin
    obj.AddPair(TJSONPair.Create(FItemName, IntToStr(v)));
  end
  else
    SttIntEdit.SetFocus;
end;

procedure TSttFrameInt.setData(obj: TJSONObject);
var
  jPair: TJSONPair;
  addr: cardinal;
begin
  if not(HexFormat) then
    LoadValIntEditJSon(obj, FItemName, SttIntEdit)
  else
  begin
    jPair := obj.Get(FItemName);
    if Assigned(jPair) then
    begin
      if tryStrToUInt(jPair.JsonValue.value, addr) then
      begin
        SttIntEdit.Text := '0x' + IntToHex(addr, 2);
      end;
    end;
  end;
end;

procedure TSttFrameInt.LoadDefaultValue;
begin
  if not(HexFormat) then
    SttIntEdit.Text := IntToStr(defVal)
  else
    SttIntEdit.Text := '0x' + IntToHex(defVal, 2);
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
