unit SttFrameBoolUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.JSON,
  SttFrameBaseUnit,
  SttObjectDefUnit;

type
  TSttFrameBool = class(TSttFrameBase)
    SttCheckBox: TCheckBox;
    procedure SttCheckBoxClick(Sender: TObject);
  private
    defVal: boolean;
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
    procedure LoadDefaultValue; override;
    procedure setActive(active: boolean); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameBool.LoadField(ParamList: TSttObjectListJson);
var
  stt: TSttBoolObjectJson;
begin
  inherited;
  stt := InitCheckBoxItem(SttCheckBox, ParamList,itemName);
  if Assigned(stt) then
    defVal := stt.defVal;
end;

procedure TSttFrameBool.LoadDefaultValue;
begin
  SttCheckBox.Checked := defVal;
end;

procedure TSttFrameBool.setActive(active: boolean);
begin
  SttCheckBox.Enabled := active;
end;

function TSttFrameBool.getData(obj: TJSONObject): boolean;
begin
  obj.AddPair(TJSONPair.Create(FItemName, JSonBoolToStr(SttCheckBox.Checked)));
  Result := true;
end;

procedure TSttFrameBool.setData(obj: TJSONObject);
begin
  LoadValCheckBoxJSon(obj, FItemName, SttCheckBox);
end;

procedure TSttFrameBool.SttCheckBoxClick(Sender: TObject);
var
  obj: TJSONBool;
begin
  inherited;
  if Assigned(FOnValueEdited) then
  begin
    obj := TJSONBool.Create(SttCheckBox.Checked);
    try
      FOnValueEdited(self, ItemName, obj.Value);
    finally
      obj.Free;
    end;
  end;
end;

initialization

RegisterSttFrame(sttBOOL, TSttFrameBool);

end.
