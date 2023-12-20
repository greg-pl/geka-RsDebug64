unit OpenConnectionDlgUnit;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.JSON,
  SttScrollBoxUnit,
  Rsd64Definitions,
  SttObjectDefUnit,
  RsdDll;

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
  private
    SttScrollBox: TSttScrollBox;
    MemConfig: string;
    procedure ExecConfig;
  public
    procedure SetConfig(config: string);
    function GetConfig: string;
  end;

implementation

{$R *.dfm}

uses
  SttFrameBaseUnit,
  SttFrameUartUnit,
  SttFrameAddrIpUnit;

procedure TOpenConnectionDlg.FormCreate(Sender: TObject);
begin
  SttScrollBox := TSttScrollBox.Create(TabControl);
  SttScrollBox.Parent := TabControl;
  SttScrollBox.Align := alClient;
end;

procedure TOpenConnectionDlg.FormShow(Sender: TObject);
begin
  RsdDll.CmmLibraryList.LoadDriverList(TabControl.Tabs);
  ExecConfig;
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

end;



procedure TOpenConnectionDlg.ExecConfig;
var
  jVal: TJSONValue;
  jObj: TJsonObject;
  jObj2: TJsonObject;
  DriverName: string;
  idx: integer;
begin
  try
    jVal := TJsonObject.ParseJSONValue(MemConfig);
    jObj := jVal as TJsonObject;

    DriverName := jObj.Get(CONNECTION_DRIVER_NAME).JSonValue.Value;
    idx := TabControl.Tabs.IndexOf(DriverName);
    if idx >= 0 then
    begin
      TabControl.TabIndex := idx;
      TabControlChange(nil);
      jObj2 := jObj.Get(CONNECTION_PARAMS_NAME).JSonValue as TJsonObject;
      SttScrollBox.setValueArray(jObj2);
    end;
  except

  end;
end;

function TOpenConnectionDlg.GetConfig: string;
var
  jObj: TJsonObject;
  jObj2: TJsonObject;
begin
  try
    jObj2 := TJsonObject.Create;

    SttScrollBox.getValueArray(jObj2);
    jObj := TJsonObject.Create;
    jObj.AddPair(TJSonPair.Create(CONNECTION_PARAMS_NAME, jObj2));
    jObj.AddPair(TJSonPair.Create(CONNECTION_DRIVER_NAME, TabControl.Tabs[TabControl.TabIndex]));
    Result := jObj.ToString;
  except

  end;
end;

end.
