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
  private
    { Private declarations }
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    procedure getData(obj: TJSONObject); override;
    procedure setData(obj: TJSONObject); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameBool.LoadField(ParamList: TSttObjectListJson);
begin
  inherited;
  LoadCheckBoxItem(SttCheckBox, ParamList, FItemName);
end;

procedure TSttFrameBool.getData(obj: TJSONObject);
begin
  obj.AddPair(TJSONPair.Create(FItemName, JSonBoolToStr(SttCheckBox.Checked)));
end;

procedure TSttFrameBool.setData(obj: TJSONObject);
begin
  LoadValCheckBoxJSon(obj, FItemName, SttCheckBox);
end;

initialization

RegisterSttFrame(sttBOOL, TSttFrameBool);

end.
