unit RegMemUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, MemFrameUnit, RmtChildUnit, IniFiles,
  ImgList, ComCtrls, ActnList, Menus, ToolWin,
  MapParserUnit,
  ProgCfgUnit,
  ToolsUnit,
  RsdDll,
  CommonDef,
  Rsd64Definitions,
  System.Actions, System.ImageList,
  CommThreadUnit,
  System.JSON,
  JSonUtils,
  ErrorDefUnit;

type
  TRegMemType = (rmANALOGINP, rmREGISTERS);

  TRegMemForm = class(TChildForm)
    AutoRepTimer: TTimer;
    ReadMemBtn: TToolButton;
    AutoRepBtn: TToolButton;
    AutoRepTmEdit: TComboBox;
    Label5: TLabel;
    AdresBox: TComboBox;
    SizeBox: TComboBox;
    Label4: TLabel;
    Label2: TLabel;
    SaveMemBtn: TToolButton;
    FillFFBtn: TToolButton;
    ToolButton4: TToolButton;
    ReadMemAct: TAction;
    AutoRepAct: TAction;
    SaveBufAct: TAction;
    WrMemBtn: TToolButton;
    WrMemAct: TAction;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    RdBackAct: TAction;
    RdNextAct: TAction;
    FillFFAct: TAction;
    FillZeroAct: TAction;
    Fill00Btn: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    SaveMemAct: TAction;
    LoadMemAct: TAction;
    ToolButton12: TToolButton;
    ToolButton14: TToolButton;
    SaveMemTxtAct: TAction;
    FillxxBtn: TToolButton;
    FillValueEdit: TEdit;
    FillxxAct: TAction;
    WrRdMemBt: TToolButton;
    ExMemAct: TAction;
    ExchAdresBox: TComboBox;
    Label1: TLabel;
    Label3: TLabel;
    MemFrame: TMemFrame;
    procedure FormCreate(Sender: TObject);
    procedure ComboBoxExit(Sender: TObject);
    procedure AutoRepTimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ReadMemActExecute(Sender: TObject);
    procedure ReadMemActUpdate(Sender: TObject);
    procedure MemFrameShowTypePageCtrlChange(Sender: TObject);
    procedure AdresBoxChange(Sender: TObject);
    procedure AutoReadActExecute(Sender: TObject);
    procedure AutoReadActUpdate(Sender: TObject);
    procedure SaveBufActExecute(Sender: TObject);
    procedure WrMemActExecute(Sender: TObject);
    procedure FillZeroActExecute(Sender: TObject);
    procedure FillFFActExecute(Sender: TObject);
    procedure SaveMemActExecute(Sender: TObject);
    procedure RdBackActExecute(Sender: TObject);
    procedure RdNextActExecute(Sender: TObject);
    procedure LoadMemActExecute(Sender: TObject);
    procedure AreaBoxChange(Sender: TObject);
    procedure SaveMemTxtActExecute(Sender: TObject);
    procedure FillxxActExecute(Sender: TObject);
    procedure ExMemActExecute(Sender: TObject);
  private
    MemType: TRegMemType;
    procedure ReadMem;
    procedure WriteMem;
    procedure ExchangeMem;
    procedure GetFromText(var Adr: cardinal; var ShowAdr: cardinal; var Size: cardinal);
    procedure wmReadMem1(var Msg: TMessage); message wm_ReadMem1;
    procedure wmWriteMem1(var Msg: TMessage); message wm_WriteMem1;
    procedure wmWriteMem2(var Msg: TMessage); message wm_WriteMem2;
    procedure wmWriteMem3(var Msg: TMessage); message wm_WriteMem3;

  protected
    function getChildSign: string; override;

  public

    function GetJSONObject: TJSONBuilder; override;
    procedure LoadfromJson(jLoader: TJSONLoader); override;

    procedure SettingChg; override;
    procedure ReloadVarList; override;
    function GetDefaultCaption: string; override;
    procedure doParamsVisible(vis: boolean); override;
    procedure ShowMem(Adr: integer);
    procedure SetMemType(mtype: TRegMemType);
  end;

var
  RegMemForm: TRegMemForm;

implementation

{$R *.dfm}

Const
  RegMemName: array [TRegMemType] of string = ('ANALOG_INP', 'REGISTERS');

function GetMemType(s: string): TRegMemType;
begin
  Result := rmREGISTERS;
  if s = RegMemName[rmANALOGINP] then
    Result := rmANALOGINP;
end;

procedure TRegMemForm.FormCreate(Sender: TObject);
begin
  inherited;
  MemFrame.RegisterSize := 2;
  MemFrame.MemSize := $100;
  MemFrame.Row0AsDec := true;
  SetMemType(rmREGISTERS);
end;

procedure TRegMemForm.SetMemType(mtype: TRegMemType);
var
  q: boolean;
begin
  MemType := mtype;
  ShowCaption;
  MemFrame.MemTypeStr := getChildSign;
  q := (MemType = rmREGISTERS);
  WrMemBtn.Visible := q;
  SaveMemBtn.Visible := q;
  FillFFBtn.Visible := q;
  Fill00Btn.Visible := q;
  FillxxBtn.Visible := q;
  FillValueEdit.Visible := q;
  WrRdMemBt.Visible := q;
end;

type
  PByteAr = ^TByteAr;
  TByteAr = array [0 .. 7] of byte;

function TRegMemForm.getChildSign: string;
begin
  if MemType = rmANALOGINP then
    Result := 'AI'
  else
    Result := 'REG';
end;

procedure TRegMemForm.GetFromText(var Adr: cardinal; var ShowAdr: cardinal; var Size: cardinal);
var
  s: cardinal;
  A: cardinal;
begin
  A := MapParser.StrToAdr(AdresBox.Text);
  s := MapParser.StrToAdr(SizeBox.Text);
  ShowAdr := A - 1;
  Adr := A;
  Size := s;
end;

procedure TRegMemForm.ReadMem;
var
  Adr: cardinal;
  ShowAdr: cardinal;
  RegCnt: cardinal;
begin
  inherited;
  GetFromText(Adr, ShowAdr, RegCnt);
  MemFrame.MemSize := RegCnt;
  MemFrame.SrcAdr := ShowAdr + 1;

  if RegCnt <> 0 then
  begin
    MemFrame.ClrData;
    case MemType of
      rmREGISTERS:
        CommThread.AddToDoItem(TWorkRdMdbRegItem.Create(Handle, wm_ReadMem1, MemFrame.MemBuf.Buf[0], Adr, RegCnt));
      rmANALOGINP:
        CommThread.AddToDoItem(TWorkRdMdbAnalogInputItem.Create(Handle, wm_ReadMem1, MemFrame.MemBuf.Buf[0],
          Adr, RegCnt));
    end;
  end;
end;

procedure TRegMemForm.wmReadMem1(var Msg: TMessage);
var
  item: TCommWorkItem;
begin
  item := TCommWorkItem(Msg.WParam);
  if item.Result = stOK then
  begin
    MemFrame.SrcAdr := (item as TWorkModbusMultiItem).FAdr;
    if ProgCfg.ShowMessageAboutSpeed then
    begin
      if ProgCfg.ShowMessageAboutSpeed then
      begin
        if item.WorkTime <> 0 then
          DoMsg(Format('RdMem v=%.2f[kB/sek]', [(MemFrame.MemSize / 1024) / (item.WorkTime / 1000.0)]))
        else
          DoMsg('RdMem OK');
      end;
    end;
    MemFrame.SetNewData;
  end
  else
  begin
    DoMsg(Dev.GetErrStr(item.Result));
    MemFrame.ClrData;
  end;
  item.Free;
end;

procedure TRegMemForm.WriteMem;
var
  Adr: cardinal;
  ShowAdr: cardinal;
  RegCnt: cardinal;
begin
  GetFromText(Adr, ShowAdr, RegCnt);
  CommThread.AddToDoItem(TWorkWrMultiMdbRegItem.Create(Handle, wm_WriteMem1, MemFrame.MemBuf.Buf[0], Adr, RegCnt));
end;

procedure TRegMemForm.wmWriteMem1(var Msg: TMessage);
var
  item: TWorkWrMultiMdbRegItem;
begin
  item := TWorkWrMultiMdbRegItem(Msg.WParam);
  DoMsg(Dev.GetErrStr(item.Result));
  item.Free;
  MemFrame.SetNewData;
end;

procedure TRegMemForm.ExchangeMem;
var
  Adr: cardinal;
  WrAdr: cardinal;
  ShowAdr: cardinal;
  Size: cardinal;
begin
  AddToList(ExchAdresBox);
  GetFromText(Adr, ShowAdr, Size);
  WrAdr := MapParser.StrToAdr(ExchAdresBox.Text);
  CommThread.AddToDoItem(TWorkRdWrMdbRegItem.Create(Handle, wm_WriteMem3, MemFrame.MemBuf.Buf[0], Adr, Size,
    MemFrame.MemBuf.Buf[0], WrAdr, Size));
end;

procedure TRegMemForm.wmWriteMem3(var Msg: TMessage);
var
  item: TWorkRdWrMdbRegItem;
begin
  item := TWorkRdWrMdbRegItem(Msg.WParam);
  DoMsg(Dev.GetErrStr(item.Result));
  if item.Result = stOK then
    MemFrame.SetNewData
  else
    MemFrame.ClrData;
  item.Free;
end;

procedure TRegMemForm.ReadMemActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IsConnected and not(AutoRepAct.Checked);
end;

procedure TRegMemForm.AutoReadActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IsConnected
end;

procedure TRegMemForm.ReadMemActExecute(Sender: TObject);
begin
  inherited;
  AddToList(AdresBox);
  AddToList(SizeBox);
  AddToList(AutoRepTmEdit);
  ReadMem;
end;

procedure TRegMemForm.RdBackActExecute(Sender: TObject);
var
  Adr: cardinal;
  Size: cardinal;
  ShowAdr: cardinal;
  RegSize: cardinal;
begin
  inherited;
  RegSize := 2;
  GetFromText(Adr, ShowAdr, Size);
  Adr := ShowAdr - (Size div RegSize);
  AdresBox.Text := '0x' + IntToHex(Adr, 8);
  ReadMem;
end;

procedure TRegMemForm.RdNextActExecute(Sender: TObject);
var
  Adr: cardinal;
  Size: cardinal;
  RegSize: cardinal;
  ShowAdr: cardinal;
begin
  inherited;
  RegSize := 2;
  GetFromText(Adr, ShowAdr, Size);
  Adr := ShowAdr + (Size div RegSize);
  AdresBox.Text := '0x' + IntToHex(Adr, 8);
  ReadMem;
end;

procedure TRegMemForm.WrMemActExecute(Sender: TObject);
begin
  inherited;
  WriteMem;
end;

procedure TRegMemForm.ExMemActExecute(Sender: TObject);
begin
  inherited;
  ExchangeMem;
  MemFrame.SetNewData;
end;

procedure TRegMemForm.FillZeroActExecute(Sender: TObject);
begin
  inherited;
  MemFrame.FillZero;
end;

procedure TRegMemForm.FillFFActExecute(Sender: TObject);
begin
  inherited;
  MemFrame.FillOnes;
end;

procedure TRegMemForm.FillxxActExecute(Sender: TObject);
var
  A: cardinal;
begin
  inherited;
  MapParser.StrToCInt(FillValueEdit.Text, A);
  MemFrame.Fill(A);
end;

procedure TRegMemForm.SaveBufActExecute(Sender: TObject);
var
  i: cardinal;
  Adr: cardinal;
  BufAdr: cardinal;
  RegCnt: integer;
begin
  BufAdr := MapParser.StrToAdr(AdresBox.Text);
  try
    RegCnt := MemFrame.MemSize div 2;
    for i := 0 to RegCnt - 1 do
    begin
      if MemFrame.MemBuf.GetState(2 * i, 2) = csModify then
      begin
        Adr := BufAdr + i;
        // st := Dev.WrReg(Handle, Adr, MemFrame.MemBuf.GetWord(2 * i));
        CommThread.AddToDoItem(TWorkWrMdbRegItem.Create(Handle, wm_WriteMem2, Adr, MemFrame.MemBuf.GetWord(2 * i)));
      end;
    end;
    MemFrame.PaintActivPage;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TRegMemForm.wmWriteMem2(var Msg: TMessage);
var
  item: TWorkWrMdbRegItem;
begin
  item := TWorkWrMdbRegItem(Msg.WParam);
  DoMsg(Dev.GetErrStr(item.Result));
  MemFrame.MemBuf.SetState(2 * (item.FAdr - MemFrame.SrcAdr), 2, csFull);
  item.Free;
  MemFrame.PaintActivPage;
end;

procedure TRegMemForm.ComboBoxExit(Sender: TObject);
begin
  inherited;
  AddToList(Sender as TComboBox);
end;

procedure TRegMemForm.AutoReadActExecute(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Checked := not(Sender as TAction).Checked;
  AutoRepTimer.Enabled := (Sender as TAction).Checked;
  try
    AutoRepTimer.Interval := StrToInt(AutoRepTmEdit.Text);
  except
    ShowMessage('èle wprowadzony czas repetycji');
  end;
end;

procedure TRegMemForm.AutoRepTimerTimer(Sender: TObject);
begin
  inherited;
  ReadMem;
end;

function TRegMemForm.GetJSONObject: TJSONBuilder;
begin
  Result := inherited GetJSONObject;
  Result.Add('MemType', RegMemName[MemType]);
  Result.Add('Adr', AdresBox.Text);
  Result.Add('Adrs', AdresBox.Items);
  Result.Add('ExAdr', ExchAdresBox.Text);
  Result.Add('ExAddrs', ExchAdresBox.Items);
  Result.Add('Size', SizeBox.Text);
  Result.Add('Sizes', SizeBox.Items);
  Result.Add('RepTime', AutoRepTmEdit.Text);
  Result.Add('RepTimes', AutoRepTmEdit.Items);
  Result.Add('ViewPage', MemFrame.ActivPage);
  Result.Add('FillValue', FillValueEdit.Text);
  Result.Add('MemFrame', MemFrame.GetJSONObject);
end;

procedure TRegMemForm.LoadfromJson(jLoader: TJSONLoader);
var
  jChild: TJSONLoader;
begin
  inherited;
  SetMemType(GetMemType(jLoader.LoadDef('MemType', RegMemName[MemType])));

  AdresBox.Text := jLoader.LoadDef('Adr', '0');
  SizeBox.Text := jLoader.LoadDef('Size', '100');
  ExchAdresBox.Text := jLoader.LoadDef('ExAdr', '0');
  FillValueEdit.Text := jLoader.LoadDef('FillValue', '0x01');

  jLoader.Load('Adrs', AdresBox.Items);
  jLoader.Load('Sizes', SizeBox.Items);
  jLoader.Load('ExAddrs', ExchAdresBox.Items);
  jLoader.Load('RepTimes', AutoRepTmEdit.Items);

  MemFrame.ActivPage := jLoader.LoadDef('ViewPage', 0);
  ShowCaption;
  if jChild.Init(jLoader, 'MemFrame') then
    MemFrame.LoadfromJson(jChild);
  ShowCaption;

end;

procedure TRegMemForm.FormActivate(Sender: TObject);
begin
  inherited;
  ReloadVarList;
end;

procedure TRegMemForm.ReloadVarList;
begin
  inherited;
end;

procedure TRegMemForm.SettingChg;
begin
  inherited;
  MemFrame.MemBuf.ByteOrder := ProgCfg.ByteOrder;
end;

procedure TRegMemForm.ShowMem(Adr: integer);
begin
  AdresBox.Text := MapParser.IntToVarName(Adr);
  ReadMemAct.Execute;
  ShowParamAct.Execute;
end;

procedure TRegMemForm.AreaBoxChange(Sender: TObject);
begin
  inherited;
  MemFrame.Refresh;
end;

procedure TRegMemForm.MemFrameShowTypePageCtrlChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

procedure TRegMemForm.AdresBoxChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

function TRegMemForm.GetDefaultCaption: string;
begin
  Result := RegMemName[MemType] + ' : ' + AdresBox.Text + '(' + MemFrame.ShowTypePageCtrl.ActivePage.Caption + ')'
end;

procedure TRegMemForm.doParamsVisible(vis: boolean);
begin
  inherited;
  MemFrame.doParamVisible(vis);
end;

procedure TRegMemForm.SaveMemActExecute(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  inherited;
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.DefaultExt := '.bin';
    Dlg.Filter := 'pliki binarne|*.bin|Wszystkie pliki|*.*';
    Dlg.Options := Dlg.Options + [ofOverwritePrompt];
    if Dlg.Execute then
    begin
      MemFrame.MemBuf.SaveToFile(Dlg.FileName);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TRegMemForm.LoadMemActExecute(Sender: TObject);
var
  Dlg: TOpenDialog;
  Fname: string;
begin
  inherited;
  Fname := '';
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.DefaultExt := '.bin';
    Dlg.Filter := 'pliki binarne|*.bin|Wszystkie pliki|*.*';
    if Dlg.Execute then
      Fname := Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if Fname <> '' then
  begin
    if MemFrame.MemBuf.LoadFromFile(Fname) then
    begin
      MemFrame.SetNewData;
      SizeBox.Text := Format('0x%X', [MemFrame.MemSize]);
      AddToList(SizeBox);
      DoMsg(Format('Read %u [0x%X] bytes', [MemFrame.MemSize, MemFrame.MemSize]));
    end;
  end;
end;

procedure TRegMemForm.SaveMemTxtActExecute(Sender: TObject);
var
  Dlg: TSaveDialog;
  Fname: string;
  SL: TStringList;
begin
  inherited;
  Fname := '';
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.DefaultExt := '.txt';
    Dlg.Filter := 'Text files|*.txt|All files|*.*';
    Dlg.Options := Dlg.Options + [ofOverwritePrompt];
    if Dlg.Execute then
      Fname := Dlg.FileName;
  finally
    Dlg.Free;
  end;

  if Fname <> '' then
  begin
    SL := TStringList.Create;
    try
      MemFrame.CopyToStringList(SL);
      SL.SaveToFile(Fname);
    finally
      SL.Free;
    end;
  end;
end;

end.
