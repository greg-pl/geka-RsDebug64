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
    { Private declarations }
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    procedure getData(obj: TJSONObject); override;
    procedure setData(obj: TJSONObject); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameFloat.LoadField(ParamList: TSttObjectListJson);
begin
  inherited;
  LoadFloatEditItem(SttFloatEdit, ParamList, FItemName);
end;


procedure TSttFrameFloat.getData(obj: TJSONObject);
begin
  obj.AddPair(TJSONPair.Create(FItemName, SttFloatEdit.Text));
end;

procedure TSttFrameFloat.setData(obj: TJSONObject);
begin
  LoadValFloatEditJSon(obj, FItemName, SttFloatEdit);
end;


initialization

RegisterSttFrame(sttFLOAT, TSttFrameFloat);

end.
