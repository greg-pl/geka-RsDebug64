unit OpenConnectionDlgUnit;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.JSON,
  SttScrollBoxUnit,
  SttObjectDefUnit;

type
  TOpenConnectionDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    TabControl: TTabControl;
    Panel1: TPanel;
    LibDescrLabel: TLabel;
    procedure TabControlChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure TabControlChanging(Sender: TObject; var AllowChange: Boolean);
  private
    SttScrollBox: TSttScrollBox;
    MemConfig: string;
    memDevStr: array of string;
    procedure SetDevStr(aDevStr: string);

  public
    procedure SetConfig(config: string);
    function GetConfig(var devStr: string): Boolean;
  end;

implementation

{$R *.dfm}

uses
  Rsd64Definitions,
  SttFrameBaseUnit,
  SttFrameUartUnit,
  SttFrameAddrIpUnit,
  RsdDll;

procedure TOpenConnectionDlg.FormCreate(Sender: TObject);
begin
  SttScrollBox := TSttScrollBox.Create(TabControl);
  SttScrollBox.Parent := TabControl;
  SttScrollBox.Align := alClient;
end;

procedure TOpenConnectionDlg.FormShow(Sender: TObject);
var
  driverName: string;
  idx: integer;
begin
  RsdDll.CmmLibraryList.LoadDriverList(TabControl.Tabs);
  setlength(memDevStr, TabControl.Tabs.Count);
  if ExtractDriverName(MemConfig, driverName) then
  begin
    idx := TabControl.Tabs.IndexOf(driverName);
    if idx >= 0 then
    begin
      memDevStr[idx] := MemConfig;
      TabControl.TabIndex := idx;
      TabControlChange(nil);
    end;
  end;
end;

procedure TOpenConnectionDlg.SetConfig(config: string);
begin
  MemConfig := config;
end;

procedure TOpenConnectionDlg.TabControlChange(Sender: TObject);
var
  Params: PLibParams;
  ConnFrameClass: TSttFrameBaseClass;
  RmArr: TStringArr;
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

  SttScrollBox.LoadList(Params.ConnectionParams, RmArr);
  if Assigned(ConnFrameClass) then
  begin
    SttScrollBox.AddFrame(ConnFrameClass, ConnFrameClass.ClassName, Params.ConnectionParams);
  end;
  SetDevStr(memDevStr[TabControl.TabIndex]);
end;

procedure TOpenConnectionDlg.TabControlChanging(Sender: TObject; var AllowChange: Boolean);
var
  dStr: string;
begin
  AllowChange := GetConfig(dStr);
  if AllowChange then
    memDevStr[TabControl.TabIndex] := dStr
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
begin
  try
    jObj2 := TJsonObject.Create;
    Result := SttScrollBox.getValueArray(jObj2);
    jObj := TJsonObject.Create;
    jObj.AddPair(TJSonPair.Create(CONNECTION_PARAMS_NAME, jObj2));
    jObj.AddPair(TJSonPair.Create(CONNECTION_DRIVER_NAME, TabControl.Tabs[TabControl.TabIndex]));
    devStr := jObj.ToString;
  except
    Result := false;
  end;
end;

procedure TOpenConnectionDlg.OKBtnClick(Sender: TObject);
var
  dStr: string;
begin
  if GetConfig(dStr) then
    ModalResult := mrOK
  else
  begin
    Application.MessageBox('Data error', 'Checking', mb_ok);
    ModalResult := mrNone;
  end;
end;

end.
