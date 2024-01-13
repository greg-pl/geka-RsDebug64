unit MemUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, MemFrameUnit, RmtChildUnit, IniFiles,
  ImgList, ComCtrls, ActnList, Menus, ToolWin,
  MapParserUnit,
  ProgCfgUnit,
  ToolsUnit,
  CommonDef,
  RsdDll,
  Rsd64Definitions,
  CommThreadUnit, System.Actions, System.ImageList,
  System.JSON,
  JSonUtils;

type
  TMemForm = class(TChildForm)
    MemFrame: TMemFrame;
    AutoRepTimer: TTimer;
    GridPopUp: TPopupMenu;
    ReadMemBtn: TToolButton;
    AutoRepBtn: TToolButton;
    AutoRepTmEdit: TComboBox;
    Label5: TLabel;
    VarListBox: TComboBox;
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
    WrMemBtn: TToolButton;
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
    AdrModeGroup: TRadioGroup;
    ToolButton14: TToolButton;
    SaveMemTxtAct: TAction;
    ToolButton15: TToolButton;
    FillValueEdit: TEdit;
    FillxxAct: TAction;
    procedure FormCreate(Sender: TObject);
    procedure ComboBoxExit(Sender: TObject);
    procedure AutoRepTimerTimer(Sender: TObject);
    procedure VarListBoxChange(Sender: TObject);
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
    procedure MemFramePointsBoxClick(Sender: TObject);
  private
    function ReadMem: TStatus;
    function WriteMem: TStatus;
    function ReadPtrValue(A: cardinal): cardinal;
    procedure GetFromText(var Adr: cardinal; var ShowAdr: cardinal; var Size: cardinal; var RegSize: cardinal);

    procedure wmReadMem1(var Msg: TMessage); message wm_ReadMem1;
    procedure wmWriteMem1(var Msg: TMessage); message wm_WriteMem1;
    procedure wmWriteMem2(var Msg: TMessage); message wm_WriteMem2;
  public
    function GetJSONObject: TJSONBuilder; override;
    procedure LoadfromJson(jLoader: TJSONLoader); override;

    procedure SettingChg; override;
    procedure ReloadVarList; override;
    function GetDefaultCaption: string; override;

    procedure ShowMem(Adr: integer); overload;
    procedure ShowMem(const AdrCpx1: TAdrCpx); overload;
  end;

var
  MemForm: TMemForm;

implementation

{$R *.dfm}

Const
  smfH8_RESET = 0;
  smfDSP_RESET = 6;

procedure TMemForm.FormCreate(Sender: TObject);
begin
  inherited;
  MemFrame.MemSize := $100;
  MemFrame.RegisterSize := 1;
  MemFrame.setByteOrder(ProgCfg.ByteOrder);
end;

function TMemForm.ReadPtrValue(A: cardinal): cardinal;
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

procedure TMemForm.GetFromText(var Adr: cardinal; var ShowAdr: cardinal; var Size: cardinal; var RegSize: cardinal);
var
  S: cardinal;
  A: cardinal;
begin
  A := MapParser.StrToAdr(AdresBox.Text);
  S := MapParser.StrToAdr(SizeBox.Text);
  RegSize := 1;
  if AdrModeGroup.ItemIndex = 1 then
  begin
    Adr := A;
    A := ReadPtrValue(Adr);
  end;
  ShowAdr := A;
  Adr := A;
  Size := RegSize * S;
end;

function TMemForm.ReadMem: TStatus;
var
  Adr: cardinal;
  ShowAdr: cardinal;
  Size: cardinal;
  RegSize: cardinal;
begin
  inherited;
  AddToList(AdresBox);
  Adr := MapParser.StrToAdr(AdresBox.Text);

  GetFromText(Adr, ShowAdr, Size, RegSize);
  MemFrame.MemTypeStr := 'MEM';
  MemFrame.RegisterSize := RegSize;
  MemFrame.MemSize := Size;

  if Size <> 0 then
  begin
    //MemFrame.ClrData;
    CommThread.AddToDoItem(TWorkRdMemItem.Create(Handle, wm_ReadMem1, AdrModeGroup.ItemIndex = 1,
      MemFrame.MemBuf.Buf[0], Adr, Size));
  end;
end;

procedure TMemForm.wmReadMem1(var Msg: TMessage);
var
  item: TCommWorkItem;
begin
  item := TCommWorkItem(Msg.WParam);
  if item.Result = stOK then
  begin
    MemFrame.SrcAdr := (item as TWorkRdMemItem).BufferAdr;
    if ProgCfg.ShowMessageAboutSpeed then
    begin
      if item.WorkTime <> 0 then
        DoMsg(Format('RdMem v=%.2f[kB/sek]', [(MemFrame.MemSize / 1024) / (item.WorkTime / 1000.0)]))
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

function TMemForm.WriteMem: TStatus;
var
  Adr: cardinal;
  ShowAdr: cardinal;
  Size: cardinal;
  RegSize: cardinal;
begin
  GetFromText(Adr, ShowAdr, Size, RegSize);
  CommThread.AddToDoItem(TWorkWrMemItem.Create(Handle, wm_WriteMem1, MemFrame.MemBuf.Buf[0], Adr, Size));
end;

procedure TMemForm.wmWriteMem1(var Msg: TMessage);
var
  item: TCommWorkItem;
begin
  item := TCommWorkItem(Msg.WParam);
  DoMsg(Dev.GetErrStr(item.Result));
  item.Free;
end;

procedure TMemForm.ReadMemActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IsConnected and not(AutoRepAct.Checked);
end;

procedure TMemForm.AutoReadActUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IsConnected
end;

procedure TMemForm.ReadMemActExecute(Sender: TObject);
begin
  inherited;
  AddToList(AdresBox);
  AddToList(SizeBox);
  AddToList(AutoRepTmEdit);
  ReadMem;
end;

procedure TMemForm.RdBackActExecute(Sender: TObject);
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

procedure TMemForm.RdNextActExecute(Sender: TObject);
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

procedure TMemForm.WrMemActExecute(Sender: TObject);
begin
  inherited;
  WriteMem;
  MemFrame.SetNewData;
end;

procedure TMemForm.FillZeroActExecute(Sender: TObject);
begin
  inherited;
  MemFrame.FillZero;
end;

procedure TMemForm.FillFFActExecute(Sender: TObject);
begin
  inherited;
  MemFrame.FillOnes;
end;

procedure TMemForm.FillxxActExecute(Sender: TObject);
var
  A: cardinal;
begin
  inherited;
  MapParser.StrToCInt(FillValueEdit.Text, A);
  MemFrame.Fill(A);
end;

procedure TMemForm.SaveBufActExecute(Sender: TObject);
var
  i, j, n: cardinal;
  st: TStatus;
  Adr: cardinal;
  BufAdr: cardinal;
begin
  BufAdr := MapParser.StrToAdr(AdresBox.Text);
  try
    i := 0;
    while i < MemFrame.MemSize do
    begin
      if MemFrame.MemBuf.MemState[i] = csModify then
      begin
        n := 0;
        while ((i + n) < MemFrame.MemSize) and (MemFrame.MemBuf.MemState[i + n] = csModify) do
        begin
          inc(n);
        end;
        if n <> 0 then
        begin
          Adr := BufAdr + i;
          CommThread.AddToDoItemAllowDouble(TWorkWrMemItem.Create(Handle, wm_WriteMem2, MemFrame.MemBuf.Buf[i], Adr, n));
          DoMsg(Format('WriteMem, adr=0x%X, size=%u', [Adr, n]));

          for j := 0 to n - 1 do
          begin
            MemFrame.MemBuf.MemState[i + j] := csFull;
          end;
        end;
      end;
      inc(i);
    end;
    MemFrame.PaintActivPage;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TMemForm.wmWriteMem2(var Msg: TMessage);
var
  item: TCommWorkItem;
begin
  item := TCommWorkItem(Msg.WParam);
  if item.Result <> stOK then
    DoMsg(Format('WriteMem, st=', [Dev.GetErrStr(item.Result)]));
  item.Free;
end;

procedure TMemForm.ComboBoxExit(Sender: TObject);
begin
  inherited;
  AddToList(Sender as TComboBox);
end;

procedure TMemForm.AutoReadActExecute(Sender: TObject);
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

procedure TMemForm.AutoRepTimerTimer(Sender: TObject);
begin
  inherited;
  AutoRepTimer.Enabled := false;
  if ReadMem = stOK then
    AutoRepTimer.Enabled := True
  else
    AutoRepAct.Checked := false;
end;

function TMemForm.GetJSONObject: TJSONBuilder;
begin
  Result := inherited GetJSONObject;
  Result.Add('Adr', AdresBox.Text);
  Result.Add('Adrs', AdresBox.Items);
  Result.Add('Size', SizeBox.Text);
  Result.Add('Sizes', SizeBox.Items);
  Result.Add('RepTime', AutoRepTmEdit.Text);
  Result.Add('RepTimes', AutoRepTmEdit.Items);
  Result.Add('ViewPage', MemFrame.ActivPage);
  Result.Add('AdrMode', AdrModeGroup.ItemIndex);
  Result.Add('FillValue', FillValueEdit.Text);
  Result.Add('MemFrame', MemFrame.GetJSONObject);
end;

procedure TMemForm.LoadfromJson(jLoader: TJSONLoader);
var
  jChild: TJSONLoader;
begin
  inherited;
  AdresBox.Text := jLoader.LoadDef('Adr', '0');
  SizeBox.Text := jLoader.LoadDef('Size', '100');
  FillValueEdit.Text := jLoader.LoadDef('FillValue', '0x01');
  jLoader.Load('Adrs', AdresBox.Items);
  jLoader.Load('Sizes', SizeBox.Items);
  jLoader.Load('RepTimes', AutoRepTmEdit.Items);
  MemFrame.ActivPage := jLoader.LoadDef('ViewPage', 0);
  AdrModeGroup.ItemIndex := jLoader.LoadDef('AdrMode', 0);
  ShowCaption;
  jChild.Init(jLoader, 'MemFrame');
  MemFrame.LoadfromJson(jChild);
end;

procedure TMemForm.VarListBoxChange(Sender: TObject);
begin
  inherited;
  AdresBox.Text := VarListBox.Items[VarListBox.ItemIndex];
  ShowCaption;
end;

procedure TMemForm.FormActivate(Sender: TObject);
begin
  inherited;
  ReloadVarList;
end;

procedure TMemForm.ReloadVarList;
begin
  inherited;
  MapParser.MapItemList.LoadToList(VarListBox.Items, ProgCfg.SectionsCfg);
end;

procedure TMemForm.SettingChg;
begin
  inherited;
  MemFrame.setByteOrder(ProgCfg.ByteOrder);
end;

procedure TMemForm.ShowMem(Adr: integer);
begin
  AdresBox.Text := MapParser.IntToVarName(Adr);
  ReadMemAct.Execute;
  ShowParamAct.Execute;
end;

procedure TMemForm.ShowMem(const AdrCpx1: TAdrCpx);
begin
  ShowMem(AdrCpx1.Adres);
  PrvTitle := AdrCpx1.Caption;
  ShowCaption;
  SizeBox.Text := Format('0x%X', [AdrCpx1.Size]);

end;

procedure TMemForm.AreaBoxChange(Sender: TObject);
begin
  inherited;
  MemFrame.Refresh;
end;

procedure TMemForm.MemFrameShowTypePageCtrlChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

procedure TMemForm.AdresBoxChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

function TMemForm.GetDefaultCaption: string;
begin
  Result := 'DUMP  : ' + AdresBox.Text + '(' + MemFrame.ShowTypePageCtrl.ActivePage.Caption + ')'
end;

procedure TMemForm.SaveMemActExecute(Sender: TObject);
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
    MemFrame.MemBuf.SaveToFile(Fname);
  end;
end;

procedure TMemForm.LoadMemActExecute(Sender: TObject);
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
    if MemFrame.MemBuf.LoadFromFile(Fname) then
    begin
      MemFrame.MemSize := MemFrame.MemBuf.Size;
      MemFrame.SetNewData;
      SizeBox.Text := Format('0x%X', [MemFrame.MemSize]);
      AddToList(SizeBox);
      DoMsg(Format('Read %u [0x%X] bytes', [MemFrame.MemSize, MemFrame.MemSize]));
    end;
  end;
end;

procedure TMemForm.SaveMemTxtActExecute(Sender: TObject);
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

procedure TMemForm.MemFramePointsBoxClick(Sender: TObject);
begin
  inherited;
  MemFrame.PointsBoxClick(Sender);

end;

end.
