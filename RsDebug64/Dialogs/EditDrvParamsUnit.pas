unit EditDrvParamsUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids,RmtChildUnit,IniFiles,
  RsdDll,ProgCfgUnit,Rsd64Definitions;

type
  TEditDrvParamsForm = class(TForm)
    ParamGrid: TStringGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure ParamGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure ParamGridKeyPress(Sender: TObject; var Key: Char);
  private
    procedure SaveDrvParamToIni;
  public
    MainWinInterf  : IMainWinInterf;
    constructor CreateIterf(AMainWinInterf  : IMainWinInterf; AOwner: TComponent);
  end;


implementation

{$R *.dfm}

constructor TEditDrvParamsForm.CreateIterf(AMainWinInterf  : IMainWinInterf; AOwner: TComponent);
begin
  inherited Create(AOwner);
  MainWinInterf := AMainWinInterf;
  //Caption := MainWinInterf.GetDev.ConnectStr; TODO
end;

procedure TEditDrvParamsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TEditDrvParamsForm.FormActivate(Sender: TObject);
var
  s        : string;
  ParValue : string;
  SL       : TStringList;
  i        : integer;
  k        : integer;
begin
  ParamGrid.Rows[0].CommaText := 'lp. Parametr wartoœæ';
  s := MainWinInterf.GetDev.GetDrvParamList(true);
  SL  := TStringList.Create;
  try
    SL.QuoteChar := '"';
    SL.Delimiter := ';';
    SL.DelimitedText := s;
    k:=1;
    for i:=0 to SL.Count-1 do
    begin
      if MainWinInterf.GetDev.GetDrvStatus(SL.Strings[i],ParValue)=stOk then
      begin
        ParamGrid.Cells[0,k]:=IntToStr(k);
        ParamGrid.Cells[1,k]:=SL.Strings[i];
        ParamGrid.Cells[2,k]:=ParValue;
        inc(k);
      end;
    end;
  finally
    Sl.Free;
  end;
  ParamGrid.Row:=1;
  ParamGrid.Col:=2;
end;


procedure TEditDrvParamsForm.ParamGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := (Acol=2);
end;

procedure TEditDrvParamsForm.ParamGridKeyPress(Sender: TObject;
  var Key: Char);
var
  ParamName,ParamVal : string;
  st                 : TStatus;
  Msg                : string;
begin
  if Key=#13 then
  begin
    ParamName := ParamGrid.Cells[1,ParamGrid.Row];
    ParamVal := ParamGrid.Cells[2,ParamGrid.Row];
    st := MainWinInterf.GetDev.SetDrvParam(ParamName,ParamVal);
    Msg := Format('SetParam(%s,%s)=%s',[ParamName,ParamVal,MainWinInterf.GetDev.GetErrStr(st)]);
    MainWinInterf.Msg(Msg);
    SaveDrvParamToIni;
  end;
end;

procedure TEditDrvParamsForm.SaveDrvParamToIni;
var
  Ini : TIniFile;
  SecName : string;
  i       : integer;
begin
  SecName := MainWinInterf.FindIniDrvPrmSection(MainWinInterf.GetDev.getDriverShortName);
  if SecName='' then
    SecName := MainWinInterf.FindIniDrvPrmSection('');
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
end;

end.
