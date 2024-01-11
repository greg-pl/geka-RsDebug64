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
    procedure ComNrBoxClick(Sender: TObject);
    procedure BoudRateBoxClick(Sender: TObject);
    procedure ParityBoxClick(Sender: TObject);
    procedure BitCntBoxClick(Sender: TObject);
  private
    defBaudRate: string;
    defParity: string;
    defBitCnt: string;
  public
    procedure AddObjectsName(SL: TStrings); override;
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
    procedure LoadDefaultValue; override;
    procedure setActive(active: boolean); override;
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
  stt: TSttSelectObjectJson;
begin
  SL := LoadRsPorts;
  ComNrBox.Items.AddStrings(SL);
  SL.Free;
  ComNrBox.Style := csDropDownList;
  if ComNrBox.Items.Count > 0 then
    ComNrBox.ItemIndex := 0;

  stt := InitComboBoxItem(BoudRateBox, nil, ParamList, UARTPARAM_BAUDRATE);
  if Assigned(stt) then
    defBaudRate := stt.defVal;

  stt := InitComboBoxItem(ParityBox, nil, ParamList, UARTPARAM_PARITY);
  if Assigned(stt) then
    defParity := stt.defVal;

  stt := InitComboBoxItem(BitCntBox, nil, ParamList, UARTPARAM_BITCNT);
  if Assigned(stt) then
    defBitCnt := stt.defVal;
end;

procedure TSttFrameUart.LoadDefaultValue;
  procedure SetBox(Box: TComboBox; val: string);
  begin
    Box.ItemIndex := Box.Items.IndexOf(val);
  end;

begin
  SetBox(BoudRateBox, defBaudRate);
  SetBox(ParityBox, defParity);
  SetBox(BitCntBox, defBitCnt);
end;

procedure TSttFrameUart.setActive(active: boolean);
begin
  ComNrBox.Enabled := active;
  BoudRateBox.Enabled := active;
  ParityBox.Enabled := active;
  BitCntBox.Enabled := active;
end;

procedure TSttFrameUart.ComNrBoxClick(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, UARTPARAM_COMNR, ComNrBox.Text);
end;

procedure TSttFrameUart.BoudRateBoxClick(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, UARTPARAM_BAUDRATE, BoudRateBox.Text);
end;

procedure TSttFrameUart.ParityBoxClick(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, UARTPARAM_PARITY, ParityBox.Text);
end;

procedure TSttFrameUart.BitCntBoxClick(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, UARTPARAM_BITCNT, BitCntBox.Text);
end;

function TSttFrameUart.getData(obj: TJSONObject): boolean;
begin
  obj.AddPair(TJSONPair.Create(UARTPARAM_COMNR, ComNrBox.Text));
  obj.AddPair(TJSONPair.Create(UARTPARAM_BAUDRATE, BoudRateBox.Text));
  obj.AddPair(TJSONPair.Create(UARTPARAM_PARITY, ParityBox.Text));
  obj.AddPair(TJSONPair.Create(UARTPARAM_BITCNT, BitCntBox.Text));
  Result := true;
end;

procedure TSttFrameUart.setData(obj: TJSONObject);
begin
  LoadValComboBoxJSon(obj, UARTPARAM_COMNR, ComNrBox);
  LoadValComboBoxJSon(obj, UARTPARAM_BAUDRATE, BoudRateBox);
  LoadValComboBoxJSon(obj, UARTPARAM_PARITY, ParityBox);
  LoadValComboBoxJSon(obj, UARTPARAM_BITCNT, BitCntBox);
end;

end.
