unit SttFrameIpUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.JSON,
  SttFrameBaseUnit,
  SttObjectDefUnit;

type
  TSttFrameIp = class(TSttFrameBase)
    SttIpEdit: TLabeledEdit;
  private
    { Private declarations }
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    procedure getData(obj: TJSONObject); override;
    procedure setData(obj: TJSONObject); override;
  end;


implementation

{$R *.dfm}

procedure TSttFrameIp.LoadField(ParamList: TSttObjectListJson);
begin
  inherited;
  LoadIpEditItem(SttIpEdit, ParamList, FItemName);
end;

procedure TSttFrameIp.getData(obj: TJSONObject);
begin
  obj.AddPair(TJSONPair.Create(FItemName, SttIpEdit.Text));
end;

procedure TSttFrameIp.setData(obj: TJSONObject);
begin
  LoadValIPEditJSon(obj, FItemName, SttIpEdit);
end;

initialization

RegisterSttFrame(sttIP, TSttFrameIp);

end.
