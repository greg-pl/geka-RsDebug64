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
  AnalogFrameUnit, System.Actions, System.ImageList,
  System.JSON,
  JSonUtils;

type
  TRegMemType = (rmANALOGINP, rmREGISTERS);

  TRegMemForm = class(TChildForm)
    MemFrame: TAnalogFrame;
    AutoRepTimer: TTimer;
    GridPopUp: TPopupMenu;
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
    ToolButton1: TToolButton;
    ExMemAct: TAction;
    ExchAdresBox: TComboBox;
    Label1: TLabel;
    Label3: TLabel;
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
    function OnToValueProc(MemName: string; Buf: pByte; TypeSign: char; var Val: OleVariant): integer;
    function OnToBinProc(MemName: string; Mem: pByte; Size: integer; TypeSign: char; Val: OleVariant): integer;
    function ReadMem: TStatus;
    function WriteMem: TStatus;
    function ExchangeMem: TStatus;
    procedure GetFromText(var Adr: cardinal; var ShowAdr: cardinal; var Size: cardinal);
  protected
    function ReadPtrValue(A: cardinal): cardinal;
    function GetPhAdr(Adr: cardinal): cardinal;
    function getChildSign: string; override;

  public

    function GetJSONObject: TJSONBuilder; override;
    procedure LoadfromJson(jLoader: TJSONLoader); override;

    procedure SettingChg; override;
    procedure ReloadMapParser; override;
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
  smfH8_RESET = 0;
  smfDSP_RESET = 6;
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
  MemFrame.OnToValue := OnToValueProc;
  MemFrame.OnToBin := OnToBinProc;
  MemFrame.MemSize := $100;
  MemType := rmREGISTERS;
end;

procedure TRegMemForm.SetMemType(mtype: TRegMemType);
begin
  MemType := mtype;
  ShowCaption;
  if MemType = rmANALOGINP then
  begin
    WrMemBtn.Visible := false;
    SaveMemBtn.Visible := false;
    FillFFBtn.Visible := false;
    Fill00Btn.Visible := false;
    FillxxBtn.Visible := false;
    FillValueEdit.Visible := false;
  end;
end;

type
  PByteAr = ^TByteAr;
  TByteAr = array [0 .. 7] of byte;

function TRegMemForm.OnToBinProc(MemName: string; Mem: pByte; Size: integer; TypeSign: char; Val: OleVariant): integer;

  procedure SetDWord(Mem: pByte; W: cardinal);
  begin
    if ProgCfg.ByteOrder = boBig then
    begin
      PByteAr(Mem)^[0] := byte(W shr 24);
      PByteAr(Mem)^[1] := byte(W shr 16);
      PByteAr(Mem)^[2] := byte(W shr 8);
      PByteAr(Mem)^[3] := byte(W);
    end
    else
      pCardinal(Mem)^ := W;
  end;

  procedure SetWord(Mem: pByte; W: cardinal);
  begin
    if ProgCfg.ByteOrder = boBig then
    begin
      PByteAr(Mem)^[0] := byte(W shr 8);
      PByteAr(Mem)^[1] := byte(W);
    end
    else
      pWord(Mem)^ := W;
  end;

var
  W: word;
  D: cardinal;
  f: Single;
begin
  case TypeSign of
    'B':
      PByteAr(Mem)^[0] := Val;
    'W':
      begin
        W := Val;
        SetWord(Mem, W);
      end;
    'D':
      begin
        D := Val;
        SetDWord(Mem, D);
      end;
    'F':
      begin
        f := Val;
        D := pCardinal(addr(f))^;
        SetDWord(Mem, D);
      end;
  end;
  Result := 0;
end;

function TRegMemForm.OnToValueProc(MemName: string; Buf: pByte; TypeSign: char; var Val: OleVariant): integer;

  function GetDWord(Buf: pByte): cardinal;
  begin
    if ProgCfg.ByteOrder = boBig then
    begin
      Result := (Buf^) shl 24;
      inc(Buf);
      Result := Result or ((Buf^) shl 16);
      inc(Buf);
      Result := Result or ((Buf^) shl 8);
      inc(Buf);
      Result := Result or Buf^;
    end
    else
      Result := pCardinal(Buf)^;
  end;

  function GetWord(Dt: pByte): word;
  begin
    if ProgCfg.ByteOrder = boBig then
    begin
      Result := (Dt^) shl 8;
      inc(Dt);
      Result := Result or Dt^;
    end
    else
      Result := pWord(Dt)^;
  end;

type
  pDouble = ^Double;
var
  X: cardinal;
  XT: array [0 .. 1] of cardinal;
begin
  Result := 0;
  case TypeSign of
    'B':
      Val := PByteAr(Buf)^[0];
    'W':
      Val := GetWord(Buf);
    'D':
      Val := GetDWord(Buf);
    'F':
      begin
        X := GetDWord(Buf);
        Val := psingle(addr(X))^;
      end;
    'E':
      begin
        XT[0] := GetDWord(Buf);
        inc(Buf, 4);
        XT[1] := GetDWord(Buf);
        Val := pDouble(addr(XT))^;
      end;
  else
    Val := 0;
    Result := 1;
  end;
end;

function TRegMemForm.getChildSign: string;
begin
  if MemType = rmANALOGINP then
    Result := 'AI'
  else
    Result := 'REG';
end;

function TRegMemForm.GetPhAdr(Adr: cardinal): cardinal;
begin
  Result := Adr;
end;

function TRegMemForm.ReadPtrValue(A: cardinal): cardinal;
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

function TRegMemForm.ReadMem: TStatus;
var
  Adr: cardinal;
  ShowAdr: cardinal;
  Size: cardinal;
  TT: cardinal;
begin
  inherited;
  GetFromText(Adr, ShowAdr, Size);
  MemFrame.MemSize := Size;
  MemFrame.SrcAdr := ShowAdr;

  if Size <> 0 then
  begin
    // MemFrame.ClrData;
    TT := GetTickCount;
    case MemType of
      rmANALOGINP:
        Result := Dev.RdAnalogInp(Handle, MemFrame.MemBuf[0], Adr, Size);
      rmREGISTERS:
        Result := Dev.RdReg(Handle, MemFrame.MemBuf[0], Adr, Size);
    else
      Result := stNoImpl;
    end;

    TT := GetTickCount - TT;
    if Result = stOK then
    begin
      if TT <> 0 then
        DoMsg(Format('RdMem v=%.2f[kB/sek]', [(Size / 1024) / (TT / 1000.0)]))
      else
        DoMsg('RdMem OK');
      MemFrame.SetNewData;
    end
    else
    begin
      DoMsg(Dev.GetErrStr(Result));
      MemFrame.ClrData;
    end;
  end
  else
    Result := -1;
end;

function TRegMemForm.WriteMem: TStatus;
var
  Adr: cardinal;
  ShowAdr: cardinal;
  Size: cardinal;
begin
  GetFromText(Adr, ShowAdr, Size);
  Result := Dev.WrMultiReg(Handle, MemFrame.MemBuf[0], Adr, Size);
  DoMsg(Dev.GetErrStr(Result));
end;

function TRegMemForm.ExchangeMem: TStatus;
var
  Adr: cardinal;
  WrAdr: cardinal;
  ShowAdr: cardinal;
  Size: cardinal;
begin
  AddToList(ExchAdresBox);
  GetFromText(Adr, ShowAdr, Size);
  WrAdr := MapParser.StrToAdr(ExchAdresBox.Text);
  Result := Dev.ReadWriteRegs(Handle, MemFrame.MemBuf[0], Adr, Size, MemFrame.MemBuf[0], WrAdr, Size);
  if Result = stOK then
  begin
    DoMsg('ExchangeMem OK');
    MemFrame.SetNewData;
  end
  else
  begin
    DoMsg(Dev.GetErrStr(Result));
    MemFrame.ClrData;
  end;
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
  MemFrame.SetNewData;
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
  st: TStatus;
  Adr: cardinal;
  BufAdr: cardinal;
begin
  BufAdr := MapParser.StrToAdr(AdresBox.Text);
  try
    i := 0;
    while i < MemFrame.MemSize do
    begin
      if MemFrame.MemState[i] = csModify then
      begin
        Adr := GetPhAdr(BufAdr) + i;
        st := Dev.WrReg(Handle, Adr, MemFrame.MemBuf[i]);
        DoMsg(Format('WriteMem, adr=0x%X  :%s', [Adr, Dev.GetErrStr(st)]));
        MemFrame.MemState[i] := csFull;
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
    ShowMessage('le wprowadzony czas repetycji');
  end;
end;

procedure TRegMemForm.AutoRepTimerTimer(Sender: TObject);
begin
  inherited;
  AutoRepTimer.Enabled := false;
  if ReadMem = stOK then
    AutoRepTimer.Enabled := True
  else
    AutoRepAct.Checked := false;
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
  MemType := GetMemType(jLoader.LoadDef('MemType', RegMemName[MemType]));

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
  ReloadMapParser;
end;

procedure TRegMemForm.ReloadMapParser;
begin
  inherited;
end;

procedure TRegMemForm.SettingChg;
begin
  inherited;
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

procedure TRegMemForm.LoadMemActExecute(Sender: TObject);
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

      DoMsg(Format('Wczytano %u [0x%X] bajtów', [MemFrame.MemSize, MemFrame.MemSize]));
    finally
      Strm.Free;
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
