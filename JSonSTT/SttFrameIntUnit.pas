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
    { Private declarations }
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    procedure getData(obj: TJSONObject); override;
    procedure setData(obj: TJSONObject); override;
  end;


implementation

{$R *.dfm}


procedure TSttFrameInt.LoadField(ParamList: TSttObjectListJson);
begin
  inherited;
  LoadIntEditItem(SttIntEdit, ParamList, FItemName);
end;

procedure TSttFrameInt.getData(obj: TJSONObject);
begin
  obj.AddPair(TJSONPair.Create(FItemName, SttIntEdit.Text));
end;

procedure TSttFrameInt.setData(obj: TJSONObject);
begin
  LoadValIntEditJSon(obj, FItemName, SttIntEdit);
end;


initialization
  RegisterSttFrame(sttINTEGER,TSttFrameInt);

end.
