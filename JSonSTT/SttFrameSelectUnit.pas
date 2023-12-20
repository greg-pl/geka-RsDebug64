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
  private
    { Private declarations }
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    procedure getData(obj: TJSONObject); override;
    procedure setData(obj: TJSONObject); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameSelect.LoadField(ParamList: TSttObjectListJson);
begin
  inherited;
  LoadComboBoxItem(SttComboBox, SttLabel, ParamList, FItemName);
end;

procedure TSttFrameSelect.getData(obj: TJSONObject);
begin
  obj.AddPair(TJSONPair.Create(FItemName, SttComboBox.Text));
end;

procedure TSttFrameSelect.setData(obj: TJSONObject);
begin
  LoadValComboBoxJSon(obj, FItemName, SttComboBox);
end;

initialization

RegisterSttFrame(sttSELECT, TSttFrameSelect);

end.
