unit MemUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, MemFrameUnit, RmtChildUnit,IniFiles,
  ImgList, ComCtrls, ActnList, Menus, ToolWin,
  MapParserUnit,
  ProgCfgUnit,
  ToolsUnit,
  CommonDef,
  RsdDll,
  CommThreadUnit;

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
    MemBxLeft : integer;
    function  OnToValueProc(MemName : string; Buf : pByte; TypeSign:char; var Val:OleVariant): integer;
    function  OnToBinProc(MemName : string; Mem : pbyte; Size:integer; TypeSign:char; Val:OleVariant): integer;
    function  ReadMem : TStatus;
    function  WriteMem : TStatus;
    function  GetPhAdr(Adr : cardinal):cardinal;
    function  ReadPtrValue(A : cardinal): cardinal;
    procedure GetFromText(var Adr : cardinal; var ShowAdr : cardinal; var Size : cardinal; var RegSize : cardinal);

    procedure wmReadMem1(var Msg: TMessage);message wm_ReadMem1;
    procedure wmWriteMem1(var Msg: TMessage);message wm_WriteMem1;
    procedure wmWriteMem2(var Msg: TMessage);message wm_WriteMem2;
  public
    procedure SaveToIni(Ini : TDotIniFile; SName : string); override;
    procedure LoadFromIni(Ini : TDotIniFile; SName : string); override;
    procedure SettingChg; override;
    procedure ReloadMapParser; override;
    function  GetDefaultCaption : string; override;

    procedure ShowMem(Adr : integer); overload;
    procedure ShowMem(const AdrCpx1 : TAdrCpx); overload;
  end;

var
  MemForm: TMemForm;

implementation


{$R *.dfm}

Const
  smfH8_RESET  = 0;
  smfDSP_RESET = 6;

procedure TMemForm.FormCreate(Sender: TObject);
begin
  inherited;
  MemFrame.OnToValue  := OnToValueProc;
  MemFrame.OnToBin := OnToBinProc;
  MemFrame.MemSize := $100;
  MemFrame.RegisterSize := 1;
end;

type
  PByteAr = ^TByteAr;
  TByteAr = array[0..7] of byte;


function TMemForm.OnToBinProc(MemName : string; Mem : pbyte; Size:integer; TypeSign:char; Val:OleVariant): integer;

procedure SetDWord(Mem : pbyte; W :cardinal);
begin
  if AreaDefItem.ByteOrder=boBig then
  begin
    PByteAr(Mem)^[0] := byte(w shr 24);
    PByteAr(Mem)^[1] := byte(w shr 16);
    PByteAr(Mem)^[2] := byte(w shr 8);
    PByteAr(Mem)^[3] := byte(w);
  end
  else
    pCardinal(Mem)^ := w;
end;

procedure SetWord(Mem : pbyte; W :cardinal);
begin
  if AreaDefItem.ByteOrder=boBig then
  begin
    PByteAr(Mem)^[0] := byte(w shr 8);
    PByteAr(Mem)^[1] := byte(w);
  end
  else
    pWord(Mem)^ := w;
end;

var
  W : word;
  D : cardinal;
  f : Single;
begin
  case  TypeSign of
  'B' : PByteAr(Mem)^[0] := Val;
  'W' : begin
          W :=Val;
          SetWord(Mem,W);
        end;
  'D' : begin
          D :=Val;
          SetDWord(Mem,D);
        end;
  'F' : begin
          f := Val;
          D := PCardinal(addr(f))^;
          SetDWord(Mem,D);
        end;
  end;
  Result := 0;
end;


function TMemForm.OnToValueProc(MemName : string; Buf : pByte; TypeSign:char; var Val:OleVariant): integer;

function GetDWord(Buf : pByte):Cardinal;
begin
  if AreaDefItem.ByteOrder=boBig then
  begin
    Result := (Buf^) shl 24;
    inc(Buf);
    Result := Result or ((Buf^) shl 16);
    inc(Buf);
    Result := Result or ((Buf^) shl 8);
    inc(Buf);
    Result  := Result or Buf^;
  end
  else
    Result  := pCardinal(Buf)^;
end;

function GetWord(Dt : pbyte): word;
begin
  if AreaDefItem.ByteOrder=boBig then
  begin
    Result := (Dt^) shl 8;
    inc(Dt);
    Result  := result or Dt^;
  end
  else
    Result := pWord(Dt)^;
end;

type
  pDouble = ^Double;
var
  X : Cardinal;
  XT :  array[0..1] of cardinal;
begin
  Result := 0;
  case  TypeSign of
  'B' : Val := PByteAr(buf)^[0];
  'W' : Val := GetWord(buf);
  'D' : Val := GetDWord(buf);
  'F' : begin
          X := GetDWord(buf);
          Val := psingle(addr(X))^;
        end;
  'E' : begin
          XT[0] := GetDWord(buf);
          inc(buf,4);
          XT[1] := GetDWord(buf);
          Val := pdouble(addr(XT))^;
        end;
  else
    Val := 0;
    Result := 1;
  end;
end;

function TMemForm.GetPhAdr(Adr : cardinal):cardinal;
begin
  Result := AreaDefItem.GetPhAdr(Adr);
end;

function  TMemForm.ReadPtrValue(A : cardinal): cardinal;
var
  Size : integer;
  tab  : array[0..3] of byte;
begin
  case AreaDefItem.PtrSize of
  ps8  : Size:=1;
  ps16 : Size:=2;
  ps32 : Size:=4;
  else
    raise Exception.Create('Nieproawidlowa wartosc PtrSize');
  end;
  if Dev.ReadDevMem(Handle,tab[0],A,Size)<>stOK then
    raise Exception.Create('Blad odczytu wskaznika');

  case AreaDefItem.PtrSize of
  ps8  : Result := Tab[0];
  ps16 : Result := GetWord(@Tab,AreaDefItem.ByteOrder);
  ps32 : Result := GetDWord(@Tab,AreaDefItem.ByteOrder);
  else
    raise Exception.Create('Nieproawidlowa wartosc PtrSize');
  end;
end;


procedure TMemForm.GetFromText(var Adr : cardinal; var ShowAdr : cardinal; var Size : cardinal; var RegSize : cardinal);
var
  S   : cardinal;
  A   : cardinal;
begin
  A := MapParser.StrToAdr(AdresBox.Text);
  S := MapParser.StrToAdr(SizeBox.Text);
  RegSize := AreaDefItem.RegSize;
  if AdrModeGroup.ItemIndex=1 then
  begin
    Adr  := AreaDefItem.GetPhAdr(A);
    A := ReadPtrValue(Adr);
  end;
  ShowAdr := A;
  Adr  := AreaDefItem.GetPhAdr(A);
  Size := RegSize*S;
end;

function TMemForm.ReadMem : TStatus;
var
  Adr     : cardinal;
  ShowAdr : cardinal;
  Size    : cardinal;
  RegSize : cardinal;
begin
  inherited;
  AddToList(AdresBox);
  adr := MapParser.StrToAdr(AdresBox.Text);
  adr  := AreaDefItem.GetPhAdr(adr);

  GetFromText(Adr,ShowAdr,Size,RegSize);
  MemFrame.MemTypeStr   := AreaDefItem.Name;
  MemFrame.RegisterSize := RegSize;
  MemFrame.MemSize      := Size;

  if Size<>0 then
  begin
    MemFrame.ClrData;
    CommThread.AddToDoItem(
    TWorkRdMemItem.Create(Handle,wm_ReadMem1,AdrModeGroup.ItemIndex=1,
      AreaDefItem,MemFrame.MemBuf[0],Adr,Size));
  end;
end;

procedure TMemForm.wmReadMem1(var Msg: TMessage);
var
  item : TCommWorkItem;
begin
  item := TCommWorkItem(Msg.WParam);
  if item.Result=stOK then
  begin
    MemFrame.SrcAdr := (item as TWorkRdMemItem).BufferAdr;
    if item.WorkTime<>0 then
      DoMsg(Format('RdMem v=%.2f[kB/sek]',[(MemFrame.MemSize/1024)/(item.WorkTime/1000.0)]))
    else
      DoMsg('RdMem OK');
    MemFrame.SetNewData;
  end
  else
  begin
    DoMsg(Dev.GetErrStr(item.Result));
    MemFrame.ClrData;
  end;
  item.Free;
end;

function TMemForm.WriteMem : TStatus;
var
  Adr     : cardinal;
  ShowAdr : cardinal;
  Size    : cardinal;
  RegSize : cardinal;
begin
  GetFromText(Adr,ShowAdr,Size,RegSize);
  CommThread.AddToDoItem(
    TWorkWrMemItem.Create(Handle,wm_WriteMem1,MemFrame.MemBuf[0],Adr,Size));
end;

procedure TMemForm.wmWriteMem1(var Msg: TMessage);
var
  item : TCommWorkItem;
begin
  item := TCommWorkItem(Msg.WParam);
  DoMsg(Dev.GetErrStr(item.Result));
  item.Free;
end;

procedure TMemForm.ReadMemActUpdate(Sender: TObject);
begin
  (Sender  as TAction).Enabled := IsConnected and not(AutoRepAct.Checked);
end;

procedure TMemForm.AutoReadActUpdate(Sender: TObject);
begin
 (Sender  as TAction).Enabled := IsConnected
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
  Adr     : cardinal;
  Size    : cardinal;
  RegSize : cardinal;
  ShowAdr : cardinal;
begin
  inherited;
  GetFromText(Adr,ShowAdr,Size,RegSize);
  Adr := ShowAdr-(Size div RegSize);
  AdresBox.Text := '0x'+IntToHex(Adr,8);
  ReadMem;
end;


procedure TMemForm.RdNextActExecute(Sender: TObject);
var
  Adr     : cardinal;
  Size    : cardinal;
  RegSize : cardinal;
  ShowAdr : cardinal;
begin
  inherited;
  GetFromText(Adr,ShowAdr,Size,RegSize);
  Adr := ShowAdr+(Size div RegSize);
  AdresBox.Text := '0x'+IntToHex(Adr,8);
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
  a : cardinal;
begin
  inherited;
  MapParser.StrToCInt(FillValueEdit.Text,a);
  MemFrame.Fill(a);
end;



procedure TMemForm.SaveBufActExecute(Sender: TObject);
var
  i,j,n   : Cardinal;
  st      : TStatus;
  Adr     : cardinal;
  BufAdr  : cardinal;
begin
  BufAdr := MapParser.StrToAdr(AdresBox.Text);
  try
    i := 0;
    while i<MemFrame.MemSize do
    begin
      if MemFrame.MemState[i]=csModify then
      begin
        n:=0;
        while ((i+n)<MemFrame.MemSize) and (MemFrame.MemState[i+n]=csModify) do
        begin
          inc(n);
        end;
        if n<>0 then
        begin
          Adr := GetPhAdr(BufAdr)+i;
          CommThread.AddToDoItem(
            TWorkWrMemItem.Create(Handle,wm_WriteMem2,MemFrame.MemBuf[i],Adr,n));
          DoMsg(Format('WriteMem, adr=0x%X, size=%u',[Adr,n]));

          for j:=0 to n-1 do
          begin
            MemFrame.MemState[i+j] := csFull;
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
  item : TCommWorkItem;
begin
  item := TCommWorkItem(Msg.WParam);
  if item.Result<>stOK then
    DoMsg(Format('WriteMem, st=',[Dev.GetErrStr(item.Result)]));
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
  (Sender as Taction).Checked := not (Sender as Taction).Checked;
  AutoRepTimer.Enabled := (Sender as Taction).Checked;
  try
    AutoRepTimer.Interval := StrToInt(AutoRepTmEdit.Text);
  except
    ShowMessage('èle wprowadzony czas repetycji');
  end;
end;

procedure TMemForm.AutoRepTimerTimer(Sender: TObject);
begin
  inherited;
  AutoRepTimer.Enabled:=false;
  if ReadMem=stOk then
    AutoRepTimer.Enabled:=True
  else
    AutoRepAct.Checked := false;
end;

procedure TMemForm.SaveToIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  Ini.WriteString(SName,'Adr',AdresBox.Text);
  Ini.WriteString(SName,'Adrs',AdresBox.Items.CommaText);
  Ini.WriteString(SName,'Size',SizeBox.Text);
  Ini.WriteString(SName,'Sizes',SizeBox.Items.CommaText);
  Ini.WriteString(SName,'RepTime',AutoRepTmEdit.Text);
  Ini.WriteString(SName,'RepTimes',AutoRepTmEdit.Items.CommaText);
  Ini.WriteInteger(SName,'ViewPage',MemFrame.ActivPage);
  Ini.WriteInteger(SName,'AdrMode',AdrModeGroup.ItemIndex);
  Ini.WriteString(SName,'FillValue',FillValueEdit.Text);
  MemFrame.SaveToIni(Ini,SName);
end;

procedure TMemForm.LoadFromIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  AdresBox.Text        := Ini.ReadString(SName,'Adr','0');
  SizeBox.Text         := Ini.ReadString(SName,'Size','100');
  FillValueEdit.Text   := Ini.ReadString(SName,'FillValue','0x01');
  AdresBox.Items.CommaText:=Ini.ReadString(SName,'Adrs','0,4000,8000,800000');
  SizeBox.Items.CommaText :=Ini.ReadString(SName,'Sizes','100,200,400,1000');
  AutoRepTmEdit.Items.CommaText := Ini.ReadString(SName,'RepTimes','');
  MemFrame.ActivPage := Ini.ReadInteger(SName,'ViewPage',0);
  AdrModeGroup.ItemIndex := Ini.ReadInteger(SName,'AdrMode',0);
  MemFrame.LoadFromIni(Ini,SName);
  ShowCaption;

end;

procedure TMemForm.VarListBoxChange(Sender: TObject);
begin
  inherited;
  AdresBox.Text :=VarListBox.Items[VarListBox.ItemIndex];
  ShowCaption;
end;

procedure TMemForm.FormActivate(Sender: TObject);
begin
  inherited;
  ReloadMapParser;
  MemBxLeft := VarListBox.Left;
end;


procedure TMemForm.ReloadMapParser;
begin
  inherited;
  MapParser.MapItemList.LoadToList(VarListBox.Items);
end;

procedure TMemForm.SettingChg;
begin
  inherited;
end;


procedure TMemForm.ShowMem(Adr : integer);
begin
  AdresBox.Text := MapParser.IntToVarName(Adr);
  ReadMemAct.Execute;
  ShowParamAct.Execute;
end;

procedure TMemForm.ShowMem(const AdrCpx1 : TAdrCpx);
begin
  ShowMem(AdrCpx1.Adres);
  SetArea(AdrCpx1.AreaName);
  Title := AdrCpx1.Caption;
  ShowCaption;
  SizeBox.Text := Format('0x%X',[AdrCpx1.Size]);

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

function  TMemForm.GetDefaultCaption : string;
begin
  Result :=  'DUMP  : ' +AdresBox.Text+'('+MemFrame.ShowTypePageCtrl.ActivePage.Caption+')'
end;


procedure TMemForm.SaveMemActExecute(Sender: TObject);
var
  Dlg : TSaveDialog;
  Fname : string;
  Strm  : TmemoryStream;
begin
  inherited;
  Fname := '';
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.DefaultExt := '.bin';
    Dlg.Filter := 'pliki binarne|*.bin|Wszystkie pliki|*.*';
    Dlg.Options := Dlg.Options +[ofOverwritePrompt];
    if Dlg.Execute then
      Fname :=Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if Fname<>'' then
  begin
    Strm := TmemoryStream.Create;
    try
      Strm.Write(MemFrame.MemBuf[0],MemFrame.MemSize);
      Strm.SaveToFile(Fname);
    finally
      Strm.Free;
    end;
  end;
end;

procedure TMemForm.LoadMemActExecute(Sender: TObject);
var
  Dlg   : TOpenDialog;
  Fname : string;
  Strm  : TmemoryStream;
begin
  inherited;
  Fname := '';
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.DefaultExt := '.bin';
    Dlg.Filter := 'pliki binarne|*.bin|Wszystkie pliki|*.*';
    if Dlg.Execute then
      Fname :=Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if Fname<>'' then
  begin
    Strm := TmemoryStream.Create;
    try
      Strm.LoadFromFile(Fname);
      MemFrame.MemSize := Strm.Size;
      Strm.Read(MemFrame.MemBuf[0],MemFrame.MemSize);
      MemFrame.SetNewData;
      SizeBox.Text := Format('0x%X',[MemFrame.MemSize]);
      AddToList(SizeBox);

      DoMsg(Format('Wczytano %u [0x%X] bajtÛw',[MemFrame.MemSize,MemFrame.MemSize]));
    finally
      Strm.Free;
    end;
  end;
end;






procedure TMemForm.SaveMemTxtActExecute(Sender: TObject);
var
  Dlg : TSaveDialog;
  Fname : string;
  SL  : TStringList;
begin
  inherited;
  Fname := '';
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.DefaultExt := '.txt';
    Dlg.Filter := 'pliki textowe|*.txt|Wszystkie pliki|*.*';
    Dlg.Options := Dlg.Options +[ofOverwritePrompt];
    if Dlg.Execute then
      Fname :=Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if Fname<>'' then
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
