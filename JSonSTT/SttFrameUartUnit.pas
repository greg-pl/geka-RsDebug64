unit SttFrameUartUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SttObjectDefUnit,
  SttFrameBaseUnit,
  System.JSON,
  Rsd64Definitions, RsdDll;

type
  TSttFrameUart = class(TSttFrameBase)
    ComNrBox: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    BoudRateBox: TComboBox;
    ParityBox: TComboBox;
    Label3: TLabel;
    BitCntBox: TComboBox;
    Label4: TLabel;
    Bevel1: TBevel;
  private
    { Private declarations }
  public
    procedure AddObjectsName(SL: TStrings); override;
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameUart.AddObjectsName(SL: TStrings);
begin
  SL.Add(UARTPARAM_COMNR);
  SL.Add(UARTPARAM_BAUDRATE);
  SL.Add(UARTPARAM_PARITY);
  SL.Add(UARTPARAM_BITCNT);
end;

procedure TSttFrameUart.LoadField(ParamList: TSttObjectListJson);
var
  SL: TStrings;
begin
  SL := LoadRsPorts;
  ComNrBox.Items.AddStrings(SL);
  SL.Free;
  ComNrBox.Style := csDropDownList;
  if ComNrBox.Items.Count > 0 then
    ComNrBox.ItemIndex := 0;

  InitComboBoxItem(BoudRateBox, nil, ParamList, UARTPARAM_BAUDRATE);
  InitComboBoxItem(ParityBox, nil, ParamList, UARTPARAM_PARITY);
  InitComboBoxItem(BitCntBox, nil, ParamList, UARTPARAM_BITCNT);
end;

function TSttFrameUart.getData(obj: TJSONObject): boolean;
begin
  obj.AddPair(TJSONPair.Create(UARTPARAM_COMNR, ComNrBox.Text));
  obj.AddPair(TJSONPair.Create(UARTPARAM_BAUDRATE, BoudRateBox.Text));
  obj.AddPair(TJSONPair.Create(UARTPARAM_PARITY, ParityBox.Text));
  obj.AddPair(TJSONPair.Create(UARTPARAM_BITCNT, BitCntBox.Text));
  Result :=true;
end;

procedure TSttFrameUart.setData(obj: TJSONObject);

begin
  LoadValComboBoxJSon(obj, UARTPARAM_COMNR, ComNrBox);
  LoadValComboBoxJSon(obj, UARTPARAM_BAUDRATE, BoudRateBox);
  LoadValComboBoxJSon(obj, UARTPARAM_PARITY, ParityBox);
  LoadValComboBoxJSon(obj, UARTPARAM_BITCNT, BitCntBox);
end;

end.
