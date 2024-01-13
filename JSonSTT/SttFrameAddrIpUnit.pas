unit SttFrameAddrIpUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.JSON,
  Vcl.ExtCtrls,
  Rsd64Definitions,
  SttFrameBaseUnit,
  SttObjectDefUnit;

type
  TSttFrameAddrIp = class(TSttFrameBase)
    AddressIpEdit: TLabeledEdit;
    PortNrEdit: TLabeledEdit;
    procedure AddressIpEditExit(Sender: TObject);
    procedure PortNrEditKeyPress(Sender: TObject; var Key: Char);
    procedure PortNrEditExit(Sender: TObject);
  private
    defIP: string;
    defport: integer;
  public
    procedure AddObjectsName(SL: TStrings); override;
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getSttData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
    procedure LoadDefaultValue; override;
    procedure setActive(active: boolean); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameAddrIp.AddObjectsName(SL: TStrings);
begin
  SL.Add(IPPARAM_IP);
  SL.Add(IPPARAM_PORT);
end;

procedure TSttFrameAddrIp.LoadField(ParamList: TSttObjectListJson);
var
  sttIP: TSttIPObjectJson;
  sttInt: TSttIntObjectJson;
begin
  sttIP:= InitIPEditItem(AddressIpEdit, ParamList, IPPARAM_IP);
  if Assigned(sttIP) then
    defIP := sttIP.defVal;

  sttInt := InitIntEditItem(PortNrEdit, ParamList, IPPARAM_PORT);
  if Assigned(sttInt) then
    defport := sttInt.defVal;
end;

procedure TSttFrameAddrIp.LoadDefaultValue;
begin
  if defIP <> '' then
    AddressIpEdit.Text := defIP;
  if defport <> 0 then
    PortNrEdit.Text := IntToStr(defport);
end;

procedure TSttFrameAddrIp.setActive(active: boolean);
begin
  AddressIpEdit.Enabled := active;
  PortNrEdit.Enabled := active;
end;

procedure TSttFrameAddrIp.AddressIpEditExit(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, IPPARAM_IP, AddressIpEdit.Text);
end;

procedure TSttFrameAddrIp.PortNrEditExit(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, IPPARAM_PORT, PortNrEdit.Text);
end;

procedure TSttFrameAddrIp.PortNrEditKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #10 then
  begin
    Key := #0;
    (Sender as TLabeledEdit).OnExit(Sender);
  end;

end;

function TSttFrameAddrIp.getSttData(obj: TJSONObject): boolean;
begin
  obj.AddPair(TJSONPair.Create(IPPARAM_IP, AddressIpEdit.Text));
  obj.AddPair(TJSONPair.Create(IPPARAM_PORT, PortNrEdit.Text));
  Result := True;
end;

procedure TSttFrameAddrIp.setData(obj: TJSONObject);
begin
  LoadValIPEditJSon(obj, IPPARAM_IP, AddressIpEdit);
  LoadValIntEditJSon(obj, IPPARAM_PORT, PortNrEdit);
end;

end.
