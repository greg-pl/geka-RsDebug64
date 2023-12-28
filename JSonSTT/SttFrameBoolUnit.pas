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
    function getData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameBool.LoadField(ParamList: TSttObjectListJson);
begin
  inherited;
  InitCheckBoxItem(SttCheckBox, ParamList, FItemName);
end;

function TSttFrameBool.getData(obj: TJSONObject): boolean;
begin
  obj.AddPair(TJSONPair.Create(FItemName, JSonBoolToStr(SttCheckBox.Checked)));
  Result :=true;
end;

procedure TSttFrameBool.setData(obj: TJSONObject);
begin
  LoadValCheckBoxJSon(obj, FItemName, SttCheckBox);
end;

initialization

RegisterSttFrame(sttBOOL, TSttFrameBool);

end.
