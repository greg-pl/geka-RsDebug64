unit RfcUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ImgList, ActnList, ExtCtrls, StdCtrls, ComCtrls,
  ToolWin, Grids, Clipbrd,
  RsdDll,
  CommThreadUnit,
  ProgCfgUnit,
  MapParserUnit, Menus, System.ImageList, System.Actions,
  System.JSON,
  JSonUtils;

const
  PREFIX = 'RFC_WRAPPER_';
  RFC_INSTANCE = 'Rfc_Instance';
  MAX_FUNCTION_PARAMETERS = 16;
  MAX_FUNCTION_MEMORY_BUFFER_SIZE = 32768;

  Rfc_StatusReady = 0;
  Rfc_StatusExecute = 1;
  Rfc_StatusPreEntry = 2;
  Rfc_StatusEntered = 3;
  Rfc_StatusErrorNotAligned = 4;
  Rfc_StatusErrorNotWrapper = 5;

type
  TFunctionParametersTab = array [0 .. MAX_FUNCTION_PARAMETERS - 1] of cardinal;

  Rfc_ControlBlock_t = record
    FunctionAddress: cardinal;
    FunctionStatus: cardinal;
    Id: cardinal;
    FunctionReturn: cardinal;
    FunctionParameters: TFunctionParametersTab;
    // FunctionMemoryBuffer: array [0..MAX_FUNCTION_MEMORY_BUFFER_SIZE-1] of  cardinal;
  end;

  TRfcForm = class(TChildForm)
    FunctionSelectBox: TComboBox;
    Label1: TLabel;
    IdEdit: TLabeledEdit;
    ParameterList: TStringGrid;
    ToolButton1: TToolButton;
    RunFunctionAct: TAction;
    ReadResultAct: TAction;
    ShowBufferAct: TAction;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    FunctionStatusEdit: TLabeledEdit;
    FunctionReturnEdit: TLabeledEdit;
    SelectFunPopupMenu: TPopupMenu;
    Copyfullname1: TMenuItem;
    procedure FunctionSelectBoxDropDown(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RunFunctionActExecute(Sender: TObject);
    procedure ReadResultActExecute(Sender: TObject);
    procedure ShowBufferActExecute(Sender: TObject);
    procedure RunFunctionActUpdate(Sender: TObject);
    procedure Copyfullname1Click(Sender: TObject);
  private
    AdrCpx: TAdrCpx;
    RfcInstanceAdr: integer;
    FRfc: Rfc_ControlBlock_t;

    function LoadParamsTab(var tab: TFunctionParametersTab; var errText: string): boolean;
    procedure wmReadMem1(var Msg: TMessage); message wm_ReadMem1;
    procedure wmWriteMem1(var Msg: TMessage); message wm_WriteMem1;
  public
    procedure SaveToIni(Ini: TDotIniFile; SName: string); override;
    function GetJSONObject: TJSONObject; override;

    procedure LoadFromIni(Ini: TDotIniFile; SName: string); override;
    procedure ReloadMapParser; override;
    function GetDefaultCaption: string; override;
  end;

implementation

uses
  Rsd64Definitions,
  IniFiles;

{$R *.dfm}

function getFunctionstatusText(v: integer): string;
begin
  case v of
    Rfc_StatusReady:
      result := 'Ready';
    Rfc_StatusExecute:
      result := 'Execute';
    Rfc_StatusPreEntry:
      result := 'Entry';
    Rfc_StatusEntered:
      result := 'Entered';
    Rfc_StatusErrorNotAligned:
      result := 'ErrorNotAligned';
    Rfc_StatusErrorNotWrapper:
      result := 'ErrorNotWrapper';
  else
    result := Format('Unknow status, code=%u', [v]);
  end;

end;

procedure TRfcForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  inherited;
  ParameterList.Rows[0].CommaText := 'lp. "Parametr name" "Parametr value" Chg';
  for i := 0 to MAX_FUNCTION_PARAMETERS - 1 do
  begin
    ParameterList.Cells[0, i + 1] := IntToStr(i + 1);
  end;
  ReloadMapParser;
end;

function TRfcForm.GetDefaultCaption: string;
begin
  result := 'RFC: ' + FunctionSelectBox.Text;
end;

procedure TRfcForm.ReloadMapParser;
begin
  RfcInstanceAdr := MapParser.GetVarAdress(RFC_INSTANCE);
  if RfcInstanceAdr = UNKNOWN_ADRESS then
    StatusBar.Panels[2].Text := 'Unknow RfcInstance address'
  else
    StatusBar.Panels[2].Text := Format('RfcInstance: 0x%08x', [RfcInstanceAdr]);
end;

procedure TRfcForm.SaveToIni(Ini: TDotIniFile; SName: string);
var
  i: integer;
begin
  inherited;
  Ini.WriteString(SName, 'RfcFunc', FunctionSelectBox.Text);
  Ini.WriteString(SName, 'ID', IdEdit.Text);
  for i := 0 to MAX_FUNCTION_PARAMETERS - 1 do
  begin
    Ini.WriteString(SName, 'ParamName_' + IntToStr(i), ParameterList.Cells[1, i + 1]);
    Ini.WriteString(SName, 'ParamVal_' + IntToStr(i), ParameterList.Cells[2, i + 1]);
  end;
end;

function TRfcForm.GetJSONObject: TJSONObject;
var
  i: integer;
  jArr: TJSONArray;
  jObj : TJSONObject;
begin
  result := inherited GetJSONObject;
  JSonAddPair(result, 'RfcFunc', FunctionSelectBox.Text);
  JSonAddPair(result, 'ID', IdEdit.Text);
  jArr := TJSONArray.Create;
  for i := 0 to MAX_FUNCTION_PARAMETERS - 1 do
  begin
    jObj := TJSONObject.Create;
    JSonAddPair(jObj,'Name',ParameterList.Cells[1, i + 1]);
    JSonAddPair(jObj,'Val',ParameterList.Cells[2, i + 1]);
    jArr.AddElement(jObj);
  end;
  result.AddPair('Params', jArr);
end;

procedure TRfcForm.LoadFromIni(Ini: TDotIniFile; SName: string);
var
  i: integer;
  s: string;
  idx: integer;
begin
  inherited;
  MapParser.MapItemList.LoadToList(PREFIX, FunctionSelectBox.Items);
  s := Ini.ReadString(SName, 'RfcFunc', FunctionSelectBox.Text);
  idx := FunctionSelectBox.Items.IndexOf(s);
  if idx >= 0 then
    FunctionSelectBox.ItemIndex := idx;
  IdEdit.Text := Ini.ReadString(SName, 'ID', IdEdit.Text);
  for i := 0 to MAX_FUNCTION_PARAMETERS - 1 do
  begin
    ParameterList.Cells[1, i + 1] := Ini.ReadString(SName, 'ParamName_' + IntToStr(i), ParameterList.Cells[1, i + 1]);
    ParameterList.Cells[2, i + 1] := Ini.ReadString(SName, 'ParamVal_' + IntToStr(i), ParameterList.Cells[2, i + 1]);
  end;
end;

procedure TRfcForm.FunctionSelectBoxDropDown(Sender: TObject);
begin
  inherited;
  MapParser.MapItemList.LoadToList(PREFIX, FunctionSelectBox.Items);

end;

function TRfcForm.LoadParamsTab(var tab: TFunctionParametersTab; var errText: string): boolean;
label
  ErrorLab;
var
  i: integer;
  s: string;
begin
  result := true;
  for i := 0 to MAX_FUNCTION_PARAMETERS - 1 do
    tab[i] := 0;
  for i := 0 to MAX_FUNCTION_PARAMETERS - 1 do
  begin
    s := ParameterList.Cells[2, i + 1];
    if s <> '' then
    begin
      tab[i] := MapParser.StrToAdr(s);
      if tab[i] = UNKNOWN_ADRESS then
      begin
        errText := Format('Unknow parametr %u', [i + 1]);
        result := false;
        goto ErrorLab;
      end;
    end;
  end;
ErrorLab:

end;

procedure TRfcForm.RunFunctionActExecute(Sender: TObject);
label
  ErrorLab;
var
  errTxt: string;
  st: TStatus;
begin
  inherited;
  errTxt := '';
  FRfc.FunctionAddress := MapParser.GetVarAdress(PREFIX + FunctionSelectBox.Text);
  if FRfc.FunctionAddress = UNKNOWN_ADRESS then
  begin
    errTxt := 'Unknow Rfc function';
    goto ErrorLab;
  end;
  FRfc.Id := MapParser.StrToAdr(IdEdit.Text);
  if FRfc.Id = UNKNOWN_ADRESS then
  begin
    errTxt := 'Unknow Id';
    goto ErrorLab;
  end;

  if not LoadParamsTab(FRfc.FunctionParameters, errTxt) then
    goto ErrorLab;

  FRfc.FunctionStatus := Rfc_StatusExecute;
  FRfc.FunctionReturn := 0;

  CommThread.AddToDoItem(TWorkWrMemItem.Create(Handle, wm_WriteMem1, FRfc, RfcInstanceAdr, sizeof(FRfc)));

ErrorLab:
  if errTxt <> '' then
    Application.MessageBox(pchar(errTxt), 'Error', mb_OK);
end;

procedure TRfcForm.wmWriteMem1(var Msg: TMessage);
var
  item: TCommWorkItem;
begin
  item := TCommWorkItem(Msg.WParam);
  DoMsg(Dev.GetErrStr(item.result));
  item.Free;
end;

procedure TRfcForm.ReadResultActExecute(Sender: TObject);
begin
  inherited;
  CommThread.AddToDoItem(TWorkRdMemItem.Create(Handle, wm_ReadMem1, FRfc, RfcInstanceAdr, sizeof(FRfc)));
end;

procedure TRfcForm.wmReadMem1(var Msg: TMessage);
label
  ErrorLab;
var
  item: TCommWorkItem;
  errTxt: string;
begin
  item := TCommWorkItem(Msg.WParam);
  if item.result = stOK then
  begin
    FunctionStatusEdit.Text := getFunctionstatusText(FRfc.FunctionStatus);
    FunctionReturnEdit.Text := Format('%u', [FRfc.FunctionReturn]);
  end
  else
    DoMsg(Dev.GetErrStr(item.result));
  item.Free;
end;

procedure TRfcForm.ShowBufferActExecute(Sender: TObject);
begin
  inherited;
  AdrCpx.Caption := 'Rfc Buffer';
  AdrCpx.Adres := RfcInstanceAdr + sizeof(Rfc_ControlBlock_t);
  AdrCpx.Size := MAX_FUNCTION_MEMORY_BUFFER_SIZE;
  PostMessage(Application.MainForm.Handle, wm_ShowmemWin, integer(@AdrCpx), 0);

end;

procedure TRfcForm.RunFunctionActUpdate(Sender: TObject);
var
  q: boolean;
begin
  inherited;
  q := false;
  if Dev <> nil then
    q := Dev.Connected and (RfcInstanceAdr <> UNKNOWN_ADRESS);
  (Sender as TAction).Enabled := q;
end;

procedure TRfcForm.Copyfullname1Click(Sender: TObject);
begin
  inherited;
  clipboard.SetTextBuf(pchar(PREFIX + FunctionSelectBox.Text));
end;

end.
