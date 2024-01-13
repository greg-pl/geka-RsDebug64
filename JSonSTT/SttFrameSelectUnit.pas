unit SttFrameSelectUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.JSON,
  SttFrameBaseUnit,
  SttObjectDefUnit;

type
  TSttFrameSelect = class(TSttFrameBase)
    SttLabel: TLabel;
    SttComboBox: TComboBox;
    procedure SttComboBoxChange(Sender: TObject);
  private
    defVal: string;
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getSttData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
    procedure LoadDefaultValue; override;
    procedure setActive(active: boolean); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameSelect.LoadField(ParamList: TSttObjectListJson);
var
  stt : TSttSelectObjectJson;
begin
  inherited;
  stt := InitComboBoxItem(SttComboBox, SttLabel, ParamList, ItemName);
  if Assigned(stt) then
    defVal := stt.defVal;
end;

function TSttFrameSelect.getSttData(obj: TJSONObject): boolean;
begin
  obj.AddPair(TJSONPair.Create(FItemName, SttComboBox.Text));
  Result := true;
end;

procedure TSttFrameSelect.setData(obj: TJSONObject);
begin
  LoadValComboBoxJSon(obj, FItemName, SttComboBox);
end;

procedure TSttFrameSelect.LoadDefaultValue;
begin
  SttComboBox.ItemIndex := SttComboBox.Items.IndexOf(defVal);
end;

procedure TSttFrameSelect.setActive(active: boolean);
begin
  SttComboBox.Enabled := active;
end;

procedure TSttFrameSelect.SttComboBoxChange(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, ItemName, SttComboBox.Text);
end;

initialization

RegisterSttFrame(sttSELECT, TSttFrameSelect);

end.
