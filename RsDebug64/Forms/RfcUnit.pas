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
  JSonUtils,
  ErrorDefUnit;

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
    function GetJSONObject: TJSONBuilder; override;
    procedure LoadfromJson(jParent: TJSONLoader); override;

    procedure ReloadVarList; override;
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
  ReloadVarList;
end;

function TRfcForm.GetDefaultCaption: string;
begin
  result := 'RFC: ' + FunctionSelectBox.Text;
end;

procedure TRfcForm.ReloadVarList;
begin
  RfcInstanceAdr := MapParser.GetVarAdress(RFC_INSTANCE);
  if RfcInstanceAdr = UNKNOWN_ADRESS then
    StatusBar.Panels[2].Text := 'Unknow RfcInstance address'
  else
    StatusBar.Panels[2].Text := Format('RfcInstance: 0x%08x', [RfcInstanceAdr]);
end;

function TRfcForm.GetJSONObject: TJSONBuilder;
var
  i: integer;
  jArr: TJSONArray;
  jObj: TJSONBuilder;
begin
  result := inherited GetJSONObject;
  result.Add('RfcFunc', FunctionSelectBox.ItemIndex);
  result.Add('ID', IdEdit.Text);
  jArr := TJSONArray.Create;
  for i := 0 to MAX_FUNCTION_PARAMETERS - 1 do
  begin
    jObj.Init;
    jObj.Add('Name', ParameterList.Cells[1, i + 1]);
    jObj.Add('Val', ParameterList.Cells[2, i + 1]);
    jArr.AddElement(jObj.jObj);
  end;
  result.Add('Params', jArr);
end;

procedure TRfcForm.LoadfromJson(jParent: TJSONLoader);
var
  i: integer;
  jArr: TJSONArray;
  jLoader: TJSONLoader;
begin
  inherited;
  jParent.Load('RfcFunc', FunctionSelectBox);
  jParent.Load('ID', IdEdit);
  jArr := jParent.getArray('Params');
  if Assigned(jArr) then
  begin
    for i := 0 to jArr.Count - 1 do
    begin
      jLoader.Init(jArr.Items[i]);
      ParameterList.Cells[1, i + 1] := jLoader.LoadDef('Name');
      ParameterList.Cells[2, i + 1] := jLoader.LoadDef('Val');
    end;
  end;
end;

procedure TRfcForm.FunctionSelectBoxDropDown(Sender: TObject);
begin
  inherited;
  MapParser.MapItemList.LoadToList(PREFIX, FunctionSelectBox.Items, progCfg.SectionsCfg);

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
