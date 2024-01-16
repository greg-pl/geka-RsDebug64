unit OpenConnectionDlgUnit;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.JSON,
  JSonUtils,
  System.Contnrs,
  SttScrollBoxUnit,
  SttObjectDefUnit;

type
  TMemObj = class(TObject)
    DrvName: string;
    DrvStr: string;
  end;

  TOpenConnectionDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    TabControl: TTabControl;
    Panel1: TPanel;
    LibDescrLabel: TLabel;
    DefaultBtn: TButton;
    procedure TabControlChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure TabControlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure DefaultBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    SttScrollBox: TSttScrollBox;
    MemDriverName: string;
    MemDrvList: TObjectList;

    procedure SaveDriver(driverName: string; DrvStr: string);
    function LoadDriver(driverName: string; var DrvStr: string): Boolean;
    procedure SetDevStr(aDevStr: string);
  public
    procedure SetConfig(devStr: string);
    function GetConfig(var devStr: string): Boolean;
  end;

implementation

{$R *.dfm}

uses
  Rsd64Definitions,
  SttFrameBaseUnit,
  SttFrameUartUnit,
  SttFrameAddrIpUnit,
  RsdDll,
  ProgCfgUnit,
  Main;

procedure TOpenConnectionDlg.FormCreate(Sender: TObject);
begin
  SttScrollBox := TSttScrollBox.Create(TabControl);
  SttScrollBox.Parent := TabControl;
  SttScrollBox.Align := alClient;
  MemDrvList := TObjectList.Create;
end;

procedure TOpenConnectionDlg.FormDestroy(Sender: TObject);
begin
  MemDrvList.Clear;
end;

procedure TOpenConnectionDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ProgCfg.OpenDialogRect.Save_TLWH(self);
end;

procedure TOpenConnectionDlg.FormShow(Sender: TObject);
var
  idx: integer;
begin
  ProgCfg.OpenDialogRect.Load_TLWH(self);
  RsdDll.CmmLibraryList.LoadDriverList(TabControl.Tabs);
  idx := TabControl.Tabs.IndexOf(MemDriverName);
  if idx >= 0 then
  begin
    TabControl.TabIndex := idx;
    TabControlChange(nil);
  end;
end;

procedure TOpenConnectionDlg.SetConfig(devStr: string);
begin
  MemDriverName := '';
  if ExtractDriverName(devStr, MemDriverName) then
    SaveDriver(MemDriverName, devStr);
end;

function TOpenConnectionDlg.LoadDriver(driverName: string; var DrvStr: string): Boolean;
var
  i: integer;
  item: TMemObj;
begin
  Result := false;
  for i := 0 to MemDrvList.Count - 1 do
  begin
    item := (MemDrvList.Items[i]) as TMemObj;
    if item.DrvName = driverName then
    begin
      Result := true;
      DrvStr := item.DrvStr
    end;
  end;
end;

procedure TOpenConnectionDlg.SaveDriver(driverName: string; DrvStr: string);
var
  i: integer;
  item: TMemObj;
  Fnd: Boolean;
begin
  Fnd := false;
  item := nil;
  for i := 0 to MemDrvList.Count - 1 do
  begin
    item := (MemDrvList.Items[i]) as TMemObj;
    if item.DrvName = driverName then
    begin
      Fnd := true;
      break;
    end;
  end;
  if not(Fnd) then
  begin
    item := TMemObj.Create;
    MemDrvList.Add(item);
    item.DrvName := driverName;
  end;
  item.DrvStr := DrvStr;
end;

procedure TOpenConnectionDlg.TabControlChange(Sender: TObject);
var
  Params: PLibParams;
  ConnFrameClass: TSttFrameBaseClass;
  RmArr: TStringArr;
  DrvName: string;
  DrvStr: string;
  q: Boolean;
begin
  Params := @RsdDll.CmmLibraryList.Items[TabControl.TabIndex].LibParams;
  LibDescrLabel.Caption := Params.Description;

  ConnFrameClass := nil;
  RmArr := nil;
  case Params.ConnectionType of
    connTypUART:
      begin
        ConnFrameClass := TSttFrameUart;
        RmArr := UartParamTab;
      end;
    connTypTCPIP:
      begin
        ConnFrameClass := TSttFrameAddrIp;
        RmArr := IpParamTab;
      end;
  end;

  // Add element not defined in ConnFrameClass
  SttScrollBox.LoadList(Params.ConnectionParams, RmArr);
  // Add ConnFrameClass
  if Assigned(ConnFrameClass) then
    SttScrollBox.AddFrame(ConnFrameClass, ConnFrameClass.ClassName, Params.ConnectionParams);
  DrvName := TabControl.Tabs[TabControl.TabIndex];

  q := LoadDriver(DrvName, DrvStr);
  if not(q) then
    q := ProgCfg.GetDrvSettings(DrvName, DrvStr);
  if q then
    SetDevStr(DrvStr)
  else
    SttScrollBox.LoadDefaultValue;
end;

procedure TOpenConnectionDlg.TabControlChanging(Sender: TObject; var AllowChange: Boolean);
var
  driverName: string;
  DrvStr: string;
begin
  AllowChange := GetConfig(DrvStr);
  if AllowChange then
  begin
    driverName := TabControl.Tabs[TabControl.TabIndex];
    SaveDriver(driverName, DrvStr);
  end
  else
    Application.MessageBox('Data error.Correct.', 'Checking', mb_ok);

end;

procedure TOpenConnectionDlg.SetDevStr(aDevStr: string);
var
  jVal: TJSONValue;
  jObj: TJsonObject;
  jObj2: TJsonObject;
begin
  try
    jVal := TJsonObject.ParseJSONValue(aDevStr);
    jObj := jVal as TJsonObject;
    if Assigned(jObj) then
    begin
      jObj2 := jObj.Get(CONNECTION_PARAMS_NAME).JSonValue as TJsonObject;
      if Assigned(jObj2) then
        SttScrollBox.setValueArray(jObj2);
    end;
  except

  end;
end;

function TOpenConnectionDlg.GetConfig(var devStr: string): Boolean;
var
  jObj: TJsonObject;
  jObj2: TJsonObject;
  errTxt: string;
begin
  try
    jObj2 := TJsonObject.Create;
    Result := SttScrollBox.getValueArray(jObj2, errTxt);
    jObj := TJsonObject.Create;
    jObj.AddPair(TJSonPair.Create(CONNECTION_PARAMS_NAME, jObj2));
    jObj.AddPair(TJSonPair.Create(CONNECTION_DRIVER_NAME, TabControl.Tabs[TabControl.TabIndex]));
    devStr := jObj.ToJSON;
  except
    Result := false;
  end;
end;

procedure TOpenConnectionDlg.OKBtnClick(Sender: TObject);
var
  DrvStr: string;
  driverName: string;
begin
  if GetConfig(DrvStr) then
  begin
    ModalResult := mrOK;
    driverName := TabControl.Tabs[TabControl.TabIndex];
    ProgCfg.AddDrvSettings(driverName, DrvStr);
  end
  else
  begin
    Application.MessageBox('Data error', 'Checking', mb_ok);
    ModalResult := mrNone;
  end;
end;

procedure TOpenConnectionDlg.DefaultBtnClick(Sender: TObject);
begin
  SttScrollBox.LoadDefaultValue;
end;

end.
