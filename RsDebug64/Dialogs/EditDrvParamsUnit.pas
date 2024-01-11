unit EditDrvParamsUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, RmtChildUnit, IniFiles,
  RsdDll, ProgCfgUnit, Rsd64Definitions,
  System.JSON,
  JSonUtils,
  SttObjectDefUnit,
  SttScrollBoxUnit,
  SttFrameBaseUnit, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TEditDrvParamsForm = class(TForm)
    Panel1: TPanel;
    OkBtn: TButton;
    Button2: TButton;
    DefaultBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure DefaultBtnClick(Sender: TObject);
  private
    SttScrollBox: TSttScrollBox;
    FMainWinInterf: IMainWinInterf;
    DriverName : string;
    procedure OnSttItemValueEditedProc(Sender: TObject; itemName, value: string);
  public
    procedure SetMainWinInterf(aMainWinInterf: IMainWinInterf);
  end;

implementation

{$R *.dfm}


procedure TEditDrvParamsForm.FormCreate(Sender: TObject);
begin
  inherited;
  SttScrollBox := TSttScrollBox.Create(self);
  SttScrollBox.Parent := self;
  SttScrollBox.Align := alClient;
  SttScrollBox.SetOnValueEdited(OnSttItemValueEditedProc);
end;

procedure TEditDrvParamsForm.FormDestroy(Sender: TObject);
begin
  inherited;
  // SttScrollBox.Free;
end;


procedure TEditDrvParamsForm.SetMainWinInterf(aMainWinInterf: IMainWinInterf);
begin
  FMainWinInterf := aMainWinInterf;
end;

procedure TEditDrvParamsForm.FormShow(Sender: TObject);
var
  s: string;
  jVal: TJSONValue;
  jObj: TJsonObject;
  jObj2: TJsonObject;
  List: TSttObjectListJson;
  jLoader: TJSONLoader;
begin
  if Assigned(FMainWinInterf) then
  begin
    s := FMainWinInterf.GetDev.GetDrvParams;
    jVal := TJsonObject.ParseJSONValue(s);
    List := TSttObjectListJson.Create;
    try
      jLoader.Init(jVal);
      List.LoadfromArr(jLoader.getArray(DRVPRAM_DEFINITION));
      SttScrollBox.LoadList(List);
      SttScrollBox.setValueArray(jLoader.GetObject(DRVPRAM_VALUES));
      jLoader.Load(DRVPRAM_DRIVER_NAME,DriverName);
      if FMainWinInterf.GetDev.Connected then
        SttScrollBox.setActiveFromUniBool
      else
        SttScrollBox.setAllActive;
    finally
      List.Free;
    end;
  end;
end;


procedure TEditDrvParamsForm.OnSttItemValueEditedProc(Sender: TObject; itemName, value: string);
begin
  FMainWinInterf.Msg(Format('Edited : %s - %s', [itemName, value]));
end;

procedure TEditDrvParamsForm.DefaultBtnClick(Sender: TObject);
begin
  SttScrollBox.LoadDefaultValue;
end;

procedure TEditDrvParamsForm.OkBtnClick(Sender: TObject);
var
  jObj2: TJsonObject;
  s : string;
begin
  jObj2 := TJsonObject.Create;
  if SttScrollBox.getValueArray(jObj2) then
  begin
    s := jObj2.ToString;
    FMainWinInterf.GetDev.SetDrvParams(s);
    ProgCfg.AddDriverSettings(DriverName,jObj2);
  end;
end;


end.
