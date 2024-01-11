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
    procedure SttIpEditKeyPress(Sender: TObject; var Key: Char);
    procedure SttIpEditExit(Sender: TObject);
  private
    defVal: string;
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
    procedure LoadDefaultValue; override;
    procedure setActive(active: boolean); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameIp.LoadField(ParamList: TSttObjectListJson);
begin
  inherited;
  InitIPEditItem(SttIpEdit, ParamList, itemName);
end;

function TSttFrameIp.getData(obj: TJSONObject): boolean;
begin
  obj.AddPair(TJSONPair.Create(FItemName, SttIpEdit.Text));
  Result := true;
end;

procedure TSttFrameIp.setData(obj: TJSONObject);
begin
  LoadValIPEditJSon(obj, FItemName, SttIpEdit);
end;

procedure TSttFrameIp.setActive(active: boolean);
begin
  SttIpEdit.Enabled := active;
end;

procedure TSttFrameIp.LoadDefaultValue;
begin
  SttIpEdit.Text := defVal;
end;

procedure TSttFrameIp.SttIpEditExit(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, itemName, SttIpEdit.Text);
end;

procedure TSttFrameIp.SttIpEditKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #10 then
  begin
    Key := #0;
    SttIpEditExit(Sender);
  end;

end;

initialization

RegisterSttFrame(sttIP, TSttFrameIp);

end.
