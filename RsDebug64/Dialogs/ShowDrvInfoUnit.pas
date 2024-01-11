unit ShowDrvInfoUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, RmtChildUnit, IniFiles,
  RsdDll, ProgCfgUnit, Rsd64Definitions,
  System.JSON,
  JsonUtils, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TShowDrvInfoForm = class(TForm)
    ParamGrid: TStringGrid;
    Panel1: TPanel;
    RefreshBtn: TSpeedButton;
    TimeLabel: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure RefreshBtnClick(Sender: TObject);
  private
    procedure ReloadData;
    procedure SaveDrvParamToIni;
  public
    MainWinInterf: IMainWinInterf;
    constructor CreateIterf(AMainWinInterf: IMainWinInterf; AOwner: TComponent);
  end;

implementation

{$R *.dfm}

constructor TShowDrvInfoForm.CreateIterf(AMainWinInterf: IMainWinInterf; AOwner: TComponent);
begin
  inherited Create(AOwner);
  MainWinInterf := AMainWinInterf;
  // Caption := MainWinInterf.GetDev.ConnectStr; TODO
end;

procedure TShowDrvInfoForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TShowDrvInfoForm.FormActivate(Sender: TObject);
begin
  ParamGrid.Rows[0].CommaText := 'lp. Parameter Description Value';
  ReloadData;
end;

procedure TShowDrvInfoForm.ReloadData;
var
  i: Integer;
  jLoader: TJsonLoader;
  jArr: TJSONArray;
  jItem: TJsonLoader;
  s: string;
begin
  s := MainWinInterf.GetDev.GetDrvInfo;
  jLoader.Init(s);

  if jLoader.Load(DRVINFO_TIME, s) then
    TimeLabel.Caption := s
  else
    TimeLabel.Caption := '???';

  jArr := jLoader.getArray(DRVINFO_LIST);
  if Assigned(jArr) then
  begin
    ParamGrid.RowCount := jArr.Count + 1;
    for i := 0 to jArr.Count - 1 do
    begin
      ParamGrid.Rows[i + 1].CommaText := IntToStr(i + 1);
      jItem.Init(jArr.Items[i]);
      if jItem.Load(DRVINFO_NAME, s) then
        ParamGrid.Cells[1, i + 1] := s;
      if jItem.Load(DRVINFO_DESCR, s) then
        ParamGrid.Cells[2, i + 1] := s;
      if jItem.Load(DRVINFO_VALUE, s) then
        ParamGrid.Cells[3, i + 1] := s;
    end;
  end;

end;

procedure TShowDrvInfoForm.RefreshBtnClick(Sender: TObject);
begin
  ReloadData;
end;

procedure TShowDrvInfoForm.SaveDrvParamToIni;
var
  Ini: TIniFile;
  SecName: string;
  i: Integer;
begin
  SecName := MainWinInterf.FindIniDrvPrmSection(MainWinInterf.GetDev.getDriverName);
  if SecName = '' then
    SecName := MainWinInterf.FindIniDrvPrmSection('');
  {
    Ini := TIniFile.Create(ProgCfg.MainIniFName);
    try
    Ini.WriteString(SecName,INI_PARAM_DEV_STR,MainWinInterf.GetDev.getDriverShortName);
    for i:=1 to ParamGrid.RowCount-1 do
    begin
    if ParamGrid.Cells[1,i]<>'' then
    begin
    Ini.WriteString(SecName,ParamGrid.Cells[1,i],ParamGrid.Cells[2,i]);
    end;
    end;
    finally
    Ini.UpdateFile;
    Ini.Free;
    end;
  }
end;

end.
