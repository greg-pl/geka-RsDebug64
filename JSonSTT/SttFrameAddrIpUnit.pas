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
    Bevel1: TBevel;
  private
    { Private declarations }
  public
    procedure AddObjectsName(SL: TStrings); override;
    procedure LoadField(ParamList: TSttObjectListJson); override;
    procedure getData(obj: TJSONObject); override;
    procedure setData(obj: TJSONObject); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameAddrIp.AddObjectsName(SL: TStrings);
begin
  SL.Add(IPPARAM_IP);
  SL.Add(IPPARAM_PORT);
end;

procedure TSttFrameAddrIp.LoadField(ParamList: TSttObjectListJson);
begin
  LoadIPEditItem(AddressIpEdit,  ParamList, IPPARAM_IP);
  LoadIntEditItem(PortNrEdit,  ParamList, IPPARAM_PORT);
end;
procedure TSttFrameAddrIp.getData(obj: TJSONObject);
begin
  obj.AddPair(TJSONPair.Create(IPPARAM_IP, AddressIpEdit.Text));
  obj.AddPair(TJSONPair.Create(IPPARAM_PORT, PortNrEdit.Text));
end;

procedure TSttFrameAddrIp.setData(obj: TJSONObject);
begin
  LoadValIPEditJSon(obj, IPPARAM_IP, AddressIpEdit);
  LoadValIntEditJSon(obj, IPPARAM_PORT, PortNrEdit);
end;

end.
