unit BinaryMemUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, BinaryFrameUnit, RmtChildUnit, IniFiles,
  ImgList, ComCtrls, ActnList, Menus, ToolWin,
  MapParserUnit,
  ProgCfgUnit,
  ToolsUnit,
  RsdDll,
  Grids,
  CommonDef,
  CommThreadUnit,
  Rsd64Definitions,
  System.Actions, System.ImageList,
  System.JSON,
  JSonUtils;

type
  TBinaryMemType = (bmBINARYINP, bmCOILS);

  TBinaryMemForm = class(TChildForm)
    MemFrame: TBinaryFrame;
    AutoRepTimer: TTimer;
    ReadMemBtn: TToolButton;
    AutoRepBtn: TToolButton;
    AutoRepTmEdit: TComboBox;
    Label5: TLabel;
    AdresBox: TComboBox;
    SizeBox: TComboBox;
    Label4: TLabel;
    Label2: TLabel;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ReadMemAct: TAction;
    AutoRepAct: TAction;
    SaveBufAct: TAction;
    WrMemAct: TAction;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    RdBackAct: TAction;
    RdNextAct: TAction;
    FillFFAct: TAction;
    FillZeroAct: TAction;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    SaveMemAct: TAction;
    LoadMemAct: TAction;
    ToolButton12: TToolButton;
    ToolButton14: TToolButton;
    SaveMemTxtAct: TAction;
    FillxxAct: TAction;
    WrMemBtn: TToolButton;
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
    procedure SaveBufActUpdate(Sender: TObject);
    procedure FillFFActUpdate(Sender: TObject);
  private
    MemType: TBinaryMemType;
    function ReadMem: TStatus;
    procedure wmReadMem1(var Msg: TMessage); message wm_ReadMem1;

    function WriteMem: TStatus;
    procedure wmWriteMem1(var Msg: TMessage); message wm_WriteMem1;

    procedure wmWriteMem2(var Msg: TMessage); message wm_WriteMem2;

    function ReadPtrValue(A: cardinal): cardinal;
    procedure GetFromText(var Adr: cardinal; var ShowAdr: cardinal; var Size: cardinal; var RegSize: cardinal);
  public
    procedure LoadfromJson(jLoader: TJSONLoader); override;
    function GetJSONObject: TJSONBuilder; override;

    procedure SettingChg; override;
    function GetDefaultCaption: string; override;
    procedure doParamsVisible(vis: boolean); override;
    procedure ShowMem(Adr: integer);
    procedure SetMemType(mtype: TBinaryMemType);
  end;

implementation

{$R *.dfm}

uses MemFrameUnit;

Const
  BinaryMemName: array [TBinaryMemType] of string = ('BIN_INP', 'COILS');

function GetMemType(s: string): TBinaryMemType;
begin
  Result := bmCOILS;
  if s = BinaryMemName[bmBINARYINP] then
    Result := bmBINARYINP;
end;

procedure TBinaryMemForm.FormCreate(Sender: TObject);
begin
  inherited;
  MemFrame.MemSize := $100;
  MemFrame.RegisterSize := 1;
end;

procedure TBinaryMemForm.SetMemType(mtype: TBinaryMemType);
begin
  MemType := mtype;
  if MemType = bmBINARYINP then
    MemFrame.ByteGrid.Options := MemFrame.ByteGrid.Options - [goEditing];
  MemFrame.MemTypeName := BinaryMemName[MemType];
  MemFrame.PaintActivPage;
  ShowCaption;
end;

type
  PByteAr = ^TByteAr;
  TByteAr = array [0 .. 7] of byte;

function TBinaryMemForm.ReadPtrValue(A: cardinal): cardinal;
var
  Size: integer;
  tab: array [0 .. 3] of byte;
begin
  case ProgCfg.PtrSize of
    ps8:
      Size := 1;
    ps16:
      Size := 2;
    ps32:
      Size := 4;
  else
    raise Exception.Create('Nieproawidlowa wartosc PtrSize');
  end;
  if Dev.ReadDevMem(Handle, tab[0], A, Size) <> stOK then
    raise Exception.Create('Blad odczytu wskaznika');

  case ProgCfg.PtrSize of
    ps8:
      Result := tab[0];
    ps16:
      Result := GetWord(@tab, ProgCfg.ByteOrder);
    ps32:
      Result := GetDWord(@tab, ProgCfg.ByteOrder);
  else
    raise Exception.Create('Nieproawidlowa wartosc PtrSize');
  end;
end;

procedure TBinaryMemForm.GetFromText(var Adr: cardinal; var ShowAdr: cardinal; var Size: cardinal;
  var RegSize: cardinal);
var
  s: cardinal;
  A: cardinal;
begin
  A := MapParser.StrToAdr(AdresBox.Text);
  s := MapParser.StrToAdr(SizeBox.Text);
  RegSize := 1;
  Size := s;
  if A > 0 then
  begin
    ShowAdr := A - 1;
    Adr := A - 1;
  end
  else
    raise Exception.Create('Register adres = 0');
end;

function TBinaryMemForm.ReadMem: TStatus;
var
  Adr: cardinal;
  ShowAdr: cardinal;
  Size: cardinal;
  RegSize: cardinal;
begin
  inherited;
  GetFromText(Adr, ShowAdr, Size, RegSize);
  MemFrame.RegisterSize := RegSize;
  MemFrame.MemSize := Size;
  MemFrame.SrcAdr := ShowAdr;

  if Size <> 0 then
  begin
    MemFrame.ClrData;
    case MemType of
      bmBINARYINP:
        CommThread.AddToDoItem(TWorkRdMdbInputTableItem.Create(Handle, wm_ReadMem1, MemFrame.MemBuf[0], Adr, Size));
      bmCOILS:
        CommThread.AddToDoItem(TWorkRdMdbOutputTableItem.Create(Handle, wm_ReadMem1, MemFrame.MemBuf[0], Adr, Size));
    end;
  end;
end;

procedure TBinaryMemForm.wmReadMem1(var Msg: TMessage);
var
  item: TWorkModbusMultiBoolItem;
begin
  item := TCommWorkItem(Msg.WParam) as TWorkModbusMultiBoolItem;
  if item.Result = stOK then
  begin
    if ProgCfg.ShowMessageAboutSpeed then
    begin
      if item.WorkTime <> 0 then
        DoMsg(Format('RdMem v=%.2f[kB/sek]', [(item.FSize / 1024) / (item.WorkTime / 1000.0)]))
      else
        DoMsg('RdMem OK');
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

procedure TBinaryMemForm.ReadMemActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IsConnected and not(AutoRepAct.Checked);
end;

procedure TBinaryMemForm.SaveBufActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := IsConnected and not(AutoRepAct.Checked) and (MemType = bmCOILS);
end;

procedure TBinaryMemForm.FillFFActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := not(AutoRepAct.Checked) and (MemType = bmCOILS);
end;

procedure TBinaryMemForm.AutoReadActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IsConnected
end;

procedure TBinaryMemForm.ReadMemActExecute(Sender: TObject);
begin
  inherited;
  AddToList(AdresBox);
  AddToList(SizeBox);
  AddToList(AutoRepTmEdit);
  ReadMem;
end;

procedure TBinaryMemForm.RdBackActExecute(Sender: TObject);
var
  Adr: cardinal;
  Size: cardinal;
  RegSize: cardinal;
  ShowAdr: cardinal;
begin
  inherited;
  GetFromText(Adr, ShowAdr, Size, RegSize);
  Adr := ShowAdr - (Size div RegSize);
  AdresBox.Text := '0x' + IntToHex(Adr, 8);
  ReadMem;
end;

procedure TBinaryMemForm.RdNextActExecute(Sender: TObject);
var
  Adr: cardinal;
  Size: cardinal;
  RegSize: cardinal;
  ShowAdr: cardinal;
begin
  inherited;
  GetFromText(Adr, ShowAdr, Size, RegSize);
  Adr := ShowAdr + (Size div RegSize);
  AdresBox.Text := '0x' + IntToHex(Adr, 8);
  ReadMem;
end;

procedure TBinaryMemForm.WrMemActExecute(Sender: TObject);
begin
  inherited;
  WriteMem;
  MemFrame.SetNewData;
end;

procedure TBinaryMemForm.FillZeroActExecute(Sender: TObject);
begin
  inherited;
  MemFrame.FillZero;
end;

procedure TBinaryMemForm.FillFFActExecute(Sender: TObject);
begin
  inherited;
  MemFrame.FillOnes;
end;

function TBinaryMemForm.WriteMem: TStatus;
var
  Adr: cardinal;
begin
  Adr := MapParser.StrToAdr(AdresBox.Text);
  CommThread.AddToDoItem(TWorkWrMultiMdbOutputTableItem.Create(Handle, wm_WriteMem1, MemFrame.MemBuf[0], Adr,
    MemFrame.MemSize));
end;

procedure TBinaryMemForm.wmWriteMem1(var Msg: TMessage);
var
  item: TWorkWrMultiMdbOutputTableItem;
begin
  item := TWorkWrMultiMdbOutputTableItem(Msg.WParam);
  if item.Result = stOK then
  begin
    if ProgCfg.ShowMessageAboutSpeed then
    begin
      if item.WorkTime <> 0 then
        DoMsg(Format('RdMem v=%.2f[kB/sek]', [(item.FSize / 1024) / (item.WorkTime / 1000.0)]))
      else
        DoMsg('RdMem OK');
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

procedure TBinaryMemForm.SaveBufActExecute(Sender: TObject);
var
  i: cardinal;
  Adr: cardinal;
  BufAdr: cardinal;
  k: integer;
begin
  BufAdr := MapParser.StrToAdr(AdresBox.Text);
  k := 0;
  for i := 0 to MemFrame.MemSize - 1 do
  begin
    if MemFrame.MemState[i] = csModify then
    begin
      Adr := BufAdr + i;
      CommThread.AddToDoItem(TWorkWrMdbOutputTableItem.Create(Handle, wm_WriteMem2, Adr, MemFrame.MemBuf[i]));
      inc(k);
    end;
  end;
end;

procedure TBinaryMemForm.wmWriteMem2(var Msg: TMessage);
var
  item: TWorkWrMdbOutputTableItem;
  idx : integer;
begin
  item := TWorkWrMdbOutputTableItem(Msg.WParam);
  Idx := item.FAdr - MapParser.StrToAdr(AdresBox.Text);
  if item.Result = stOK then
  begin
    if ProgCfg.ShowMessageAboutSpeed then
    begin
      DoMsg('RdMem OK');
    end;
    MemFrame.MemState[idx] := csFull;
  end
  else
  begin
    DoMsg(Dev.GetErrStr(item.Result));
  end;
  item.Free;
end;

procedure TBinaryMemForm.ComboBoxExit(Sender: TObject);
begin
  inherited;
  AddToList(Sender as TComboBox);
end;

procedure TBinaryMemForm.AutoReadActExecute(Sender: TObject);
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

procedure TBinaryMemForm.AutoRepTimerTimer(Sender: TObject);
begin
  inherited;
  AutoRepTimer.Enabled := false;
  if ReadMem = stOK then
    AutoRepTimer.Enabled := True
  else
    AutoRepAct.Checked := false;
end;

function TBinaryMemForm.GetJSONObject: TJSONBuilder;
begin
  Result := inherited GetJSONObject;
  Result.Add('MemType', BinaryMemName[MemType]);
  Result.Add('Adr', AdresBox.Text);
  Result.Add('Adrs', AdresBox.Items);
  Result.Add('Size', SizeBox.Text);
  Result.Add('Sizes', SizeBox.Items);
  Result.Add('RepTime', AutoRepTmEdit.Text);
  Result.Add('RepTimes', AutoRepTmEdit.Items);

  Result.Add('MemFrame', MemFrame.GetJSONObject);
end;

procedure TBinaryMemForm.LoadfromJson(jLoader: TJSONLoader);
var
  jLoader2: TJSONLoader;
begin
  SetMemType(GetMemType(jLoader.LoadDef('MemType', BinaryMemName[MemType])));
  AdresBox.Text := jLoader.LoadDef('Adr', '0');
  jLoader.Load('Adrs', AdresBox.Items);
  SizeBox.Text := jLoader.LoadDef('Size', '100');
  jLoader.Load('Sizes', SizeBox.Items);
  AutoRepTmEdit.Text := jLoader.LoadDef('RepTime', '250');
  jLoader.Load('RepTimes', AutoRepTmEdit.Items);

  if jLoader2.Init(jLoader, 'MemFrame') then
    MemFrame.LoadfromJson(jLoader2);
  ShowCaption;
end;

procedure TBinaryMemForm.FormActivate(Sender: TObject);
begin
  inherited;
  ReloadVarList;
end;

procedure TBinaryMemForm.SettingChg;
begin
  inherited;
end;

procedure TBinaryMemForm.ShowMem(Adr: integer);
begin
  AdresBox.Text := MapParser.IntToVarName(Adr);
  ReadMemAct.Execute;
  ShowParamAct.Execute;
end;

procedure TBinaryMemForm.AreaBoxChange(Sender: TObject);
begin
  inherited;
  MemFrame.Refresh;
end;

procedure TBinaryMemForm.MemFrameShowTypePageCtrlChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

procedure TBinaryMemForm.AdresBoxChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

function TBinaryMemForm.GetDefaultCaption: string;
begin
  Result := BinaryMemName[MemType] + ' : ' + AdresBox.Text;
end;

procedure TBinaryMemForm.doParamsVisible(vis: boolean);
begin
  inherited;
  MemFrame.doParamVisible(vis);
end;

procedure TBinaryMemForm.SaveMemActExecute(Sender: TObject);
var
  Dlg: TSaveDialog;
  Fname: string;
  Strm: TmemoryStream;
begin
  inherited;
  Fname := '';
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.DefaultExt := '.bin';
    Dlg.Filter := 'pliki binarne|*.bin|Wszystkie pliki|*.*';
    Dlg.Options := Dlg.Options + [ofOverwritePrompt];
    if Dlg.Execute then
      Fname := Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if Fname <> '' then
  begin
    Strm := TmemoryStream.Create;
    try
      Strm.Write(MemFrame.MemBuf[0], MemFrame.MemSize);
      Strm.SaveToFile(Fname);
    finally
      Strm.Free;
    end;
  end;
end;

procedure TBinaryMemForm.LoadMemActExecute(Sender: TObject);
var
  Dlg: TOpenDialog;
  Fname: string;
  Strm: TmemoryStream;
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
    Strm := TmemoryStream.Create;
    try
      Strm.LoadFromFile(Fname);
      MemFrame.MemSize := Strm.Size;
      Strm.Read(MemFrame.MemBuf[0], MemFrame.MemSize);
      MemFrame.SetNewData;
      SizeBox.Text := Format('0x%X', [MemFrame.MemSize]);
      AddToList(SizeBox);

      DoMsg(Format('Wczytano %u [0x%X] bajtÛw', [MemFrame.MemSize, MemFrame.MemSize]));
    finally
      Strm.Free;
    end;
  end;
end;

procedure TBinaryMemForm.SaveMemTxtActExecute(Sender: TObject);
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
    Dlg.Filter := 'pliki textowe|*.txt|Wszystkie pliki|*.*';
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
