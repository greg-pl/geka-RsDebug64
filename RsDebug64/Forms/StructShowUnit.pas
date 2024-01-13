unit StructShowUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ComCtrls, ExtCtrls, StdCtrls,Clipbrd,
  ProgCfgUnit,
  MapParserUnit,
  RsdDll,
  ToolsUnit,
  Rsd64Definitions,
  TypeDefUnit, ImgList, Buttons, Spin, ActnList, Menus, ToolWin,
  System.ImageList, System.Actions,
  ErrorDefUnit;

type
  TStructShowForm = class(TChildForm)
    StructTreeView: TTreeView;
    AutoRepTimer: TTimer;
    PopupMenu1: TPopupMenu;
    ActionList1: TActionList;
    ReadMemAct: TAction;
    AutoReadAct: TAction;
    Edytuj1: TMenuItem;
    Kopiujadres1: TMenuItem;
    Pokapami1: TMenuItem;
    ShowWinAct: TAction;
    CopyAdressAct: TAction;
    EditAct: TAction;
    EditTitleAct1: TMenuItem;
    Closewindow1: TMenuItem;
    TypeDefAct: TAction;
    RdMemBtn: TToolButton;
    AutoRepBtn: TToolButton;
    AdresBox: TComboBox;
    VarListBox: TComboBox;
    TypeDefBox: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    RepCntEdit: TSpinEdit;
    AutoRepTmEdit: TComboBox;
    Label6: TLabel;
    ToolButton1: TToolButton;
    procedure FormActivate(Sender: TObject);
    procedure TypeDefBoxChange(Sender: TObject);
    procedure StructTreeViewGetImageIndex(Sender: TObject;
      Node: TTreeNode);
    procedure StructTreeViewGetSelectedIndex(Sender: TObject;
      Node: TTreeNode);
    procedure StructTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure StructTreeViewCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure StructTreeViewCustomDraw(Sender: TCustomTreeView;
      const ARect: TRect; var DefaultDraw: Boolean);
    procedure AdresBoxExit(Sender: TObject);
    procedure VarListBoxDropDown(Sender: TObject);
    procedure StructTreeViewCollapsed(Sender: TObject; Node: TTreeNode);
    procedure StructTreeViewExpanded(Sender: TObject; Node: TTreeNode);
    procedure AutoRepTimerTimer(Sender: TObject);
    procedure AutoRepTmEditExit(Sender: TObject);
    procedure VarListBoxExit(Sender: TObject);
    procedure VarListBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ReadMemActExecute(Sender: TObject);
    procedure ReadMemActUpdate(Sender: TObject);
    procedure AutoReadActExecute(Sender: TObject);
    procedure AutoReadActUpdate(Sender: TObject);
    procedure ShowWinActExecute(Sender: TObject);
    procedure ShowWinActUpdate(Sender: TObject);
    procedure CopyAdressActExecute(Sender: TObject);
    procedure EditActExecute(Sender: TObject);
    procedure EditActUpdate(Sender: TObject);
    procedure StructTreeViewKeyPress(Sender: TObject; var Key: Char);
    procedure StructTreeViewDblClick(Sender: TObject);
    procedure TypeDefActExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    MaxX : integer;
    MemBuf  : array of byte;
    BufSt   : boolean;
    MemBxLeft : integer;
    function  ToNodeText(N :TTreeNode; Coll : boolean; TxMode : TShowMode) : string;
    procedure ReadMem;
    function GetNodeProp(Node: TTreeNode; var Adr : integer; var Ofs : integer; var Size : integer): boolean;
  public
    procedure SaveToIni(Ini : TDotIniFile; SName : string);
    procedure LoadFromIni(Ini : TDotIniFile; SName : string); //todo

    procedure ReloadVarList; override;
    procedure TypeDefChg; override;
    function  GetDefaultCaption : string; override;
    procedure SetStruct(Adr : integer; Typ : THType);
  end;

var
  StructShowForm: TStructShowForm;

implementation

uses Types, MemFrameUnit;

{$R *.dfm}

procedure TStructShowForm.FormCreate(Sender: TObject);
begin
  inherited;
  Width := 400;
end;


procedure TStructShowForm.FormActivate(Sender: TObject);
var
  s : string;
begin
  inherited;
  s := TypeDefBox.Text;
  GlobTypeList.LoadTypeList(TypeDefBox.Items);
  ReloadVarList;
  BufSt := false;
  TypeDefBox.ItemIndex := TypeDefBox.Items.IndexOf(s);
  MemBxLeft := VarListBox.Left;
end;

procedure TStructShowForm.FormShow(Sender: TObject);
begin
  inherited;
  ShowParamAct.Checked := true;
  ShowParamAct.Execute;
end;

procedure TStructShowForm.ReloadVarList;
begin
  inherited;
  MapParser.MapItemList.LoadToList(VarListBox.Items,ProgCfg.SectionsCfg);
end;

procedure TStructShowForm.TypeDefChg;
var
  s : string;
begin
  s := TypeDefBox.Text;
  TypeDefBoxChange(TypeDefBox);
  TypeDefBox.ItemIndex := TypeDefBox.Items.IndexOf(s);
end;

procedure TStructShowForm.SaveToIni(Ini : TDotIniFile; SName : string);
var
  s : string;
begin
  inherited;
  Ini.WriteString(SName,'Adr',AdresBox.Text);
  s := AdresBox.Items.CommaText;
  Ini.WriteString(SName,'Adrs',s);
  Ini.WriteString(SName,'VarType',TypeDefBox.Text);
  Ini.WriteInteger(SName,'RepCnt',RepCntEdit.Value);
  Ini.WriteString(SName,'RepTime',AutoRepTmEdit.Text);
  Ini.WriteString(SName,'RepTimes',AutoRepTmEdit.Items.CommaText);
end;

procedure TStructShowForm.LoadFromIni(Ini : TDotIniFile; SName : string);
var
  s : string;
  n : integer;
begin
  inherited;
  AdresBox.Text := Ini.ReadString(SName,'Adr',AdresBox.Text);

  s := Ini.ReadString(SName,'Adrs','');
  if s<>'' then
    AdresBox.Items.CommaText := s;
  s := Ini.ReadString(SName,'VarType','');
  n := TypeDefBox.Items.IndexOf(s);
  TypeDefBox.ItemIndex := n;
  RepCntEdit.Value := Ini.ReadInteger(SName,'RepCnt',1);
  AutoRepTmEdit.Text := Ini.ReadString(SName,'RepTime','250');
  s := Ini.ReadString(SName,'RepTimes','');
  if s<>'' then
    AutoRepTmEdit.Items.CommaText :=s;
  TypeDefBoxChange(TypeDefBox);
end;

procedure TStructShowForm.SetStruct(Adr : integer; Typ : THType);
var
  N : integer;
begin
  AdresBox.Text := MapParser.IntToVarName(Adr);
  N := TypeDefBox.Items.IndexOf(Typ.FldName);
  if N>=0 then
    TypeDefBox.ItemIndex := N;
  TypeDefAct.Execute;
  ReadMemAct.Execute;
end;

procedure TStructShowForm.TypeDefBoxChange(Sender: TObject);
begin
  inherited;
  TypeDefAct.Execute;
end;

procedure TStructShowForm.TypeDefActExecute(Sender: TObject);
var
  H         : THType;
  StrucType : THType;
  i         : integer;
  MemSize   : integer;
  N         :TTreeNode;
begin
  inherited;
  H := GlobTypeList.FindType(TypeDefBox.Text);
  if H<>nil then
  begin
    StrucType := H.Exploid(GlobTypeList);
    Setlength(MemBuf,RepCntEdit.Value*StrucType.GetSize(GlobTypeList));
    try
      StructTreeView.Items.Clear;
      MemSize := 0;
      for i:=0 to RepCntEdit.Value-1 do
      begin
        StrucType.FillTree(StructTreeView,nil,MemSize);
        MemSize := MemSize+StrucType.GetSize(GlobTypeList);
      end;
    finally
      StrucType.Free;
    end;
    n := StructTreeView.Items[0];
    while N<>nil do
    begin
      N.Expand(false);
      N := N.getNextSibling;
    end;
  end;
  StructTreeView.Refresh;
  ShowCaption;
end;


procedure TStructShowForm.StructTreeViewGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  inherited;
  Node.ImageIndex := THType(Node.Data).GetImageIndex;
end;

procedure TStructShowForm.StructTreeViewGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  inherited;
  Node.SelectedIndex := Node.ImageIndex;
end;

function TStructShowForm.GetNodeProp(Node: TTreeNode; var Adr : integer; var Ofs : integer; var Size : integer): boolean;
var
  HL   : THTypeList;
  HF   : THType;
begin
  inherited;
  Result := false;
  if Node<>nil then
  begin
    HL  := THTypeList.Create(nil);
    try
      HF:=HL.ReadfromTree(StructTreeView,THType(Node.Data));
      if HF<>nil then
      begin
        size := HF.GetSize(GlobTypeList);
        ofs  := HF.GetItemOffset(GlobTypeList,true);
        adr  := MapParser.StrToAdr(AdresBox.Text);
        Result := true;
      end
    finally
      HL.Free;
    end;
  end
end;

procedure TStructShowForm.StructTreeViewChange(Sender: TObject;Node: TTreeNode);
var
  s    : string;
  ofs  : integer;
  adr  : integer;
  size : integer;
  PhAadr : integer;
begin
  inherited;
  s := '';
  if GetNodeProp(Node,Adr,Ofs,Size) then
  begin
    PhAadr := Adr;
    s := Format('PhAdr=0x%.6X  Adr=0x%.6X  ofs=%u  size=%u',[PhAadr+ofs,adr+ofs,ofs,size]);
  end;
  StatusBar.Panels[2].Text := s;
end;

function  TStructShowForm.ToNodeText(N :TTreeNode; Coll : boolean; TxMode : TShowMode) : string;
var
  N1 : TTreeNode;
  p  : pByte;
begin
  if N.HasChildren then
  begin
    Coll := Coll or not(N.Expanded);
    if Coll then
    begin
      Result := '{';
      N1 := N.getFirstChild;
      while N1<>nil do
      begin
        Result := Result + THType(N1.Data).FldName+':'+ToNodeText(N1,Coll,TxMode);
        N1:= N1.getNextSibling;
        if N1<>nil then
          Result := Result + ',';
      end;
      Result := Result + '}';
    end
    else
      Result := '';
  end
  else
  begin
    p := @MemBuf[THType(N.Data).DtOfset];
    //Result := THType(N.Data).SimplToText(p,TxMode)
    Result := THType(N.Data).ToText(ProgCfg.ByteOrder,p,GlobTypeList,TxMode);
  end;
end;


procedure TStructShowForm.StructTreeViewCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  R : TRect;
  s : string;
  C : TColor;
begin
  inherited;
  R := Node.DisplayRect(false);
  R.Top:=R.Top+2;
  R.Bottom:=R.Bottom-2;
  R.Left := MaxX;
  if BufSt then
  begin
    s := ToNodeText(Node,false,smDEFAULT);
    StructTreeView.Canvas.TextOut(R.Left,R.Top-1,s);
  end;  
  C := StructTreeView.Canvas.Pen.Color;
  StructTreeView.Canvas.Pen.Color :=clBlue;
  StructTreeView.Canvas.MoveTo(MaxX,R.Bottom);
  StructTreeView.Canvas.LineTo(R.Right,R.Bottom);
  StructTreeView.Canvas.Pen.Color :=C;
  DefaultDraw := true;
end;


procedure TStructShowForm.StructTreeViewCustomDraw(Sender: TCustomTreeView;
  const ARect: TRect; var DefaultDraw: Boolean);
var
  N : TTreeNode;
  R : TRect;
begin
  inherited;
  MaxX := 0;
  if StructTreeView.Items.Count>0 then
  begin
    N := StructTreeView.Items[0];
    while N<>nil do
    begin
      R := N.DisplayRect(true);
      if R.Right>MaxX then
        MaxX := R.Right;
      N := N.GetNext;
    end;
  end;
  MaxX := MaxX+10;
  DefaultDraw := True;
end;

procedure TStructShowForm.VarListBoxDropDown(Sender: TObject);
begin
  inherited;
  VarListBox.Width := VarListBox.Left - AdresBox.Left +50;
  VarListBox.Left := AdresBox.Left;
end;

procedure TStructShowForm.VarListBoxExit(Sender: TObject);
begin
  inherited;
  VarListBox.Left := MemBxLeft;
  VarListBox.Width := 50
end;

procedure TStructShowForm.VarListBoxChange(Sender: TObject);
var
  N : integer;
  S : string;
begin
  inherited;
  VarListBox.Left := MemBxLeft;
  VarListBox.Width := 50;
  S := VarListBox.Items[VarListBox.ItemIndex];
  N := AdresBox.Items.IndexOf(S);
  if N>=0 then
    AdresBox.Items.Delete(N);
  AdresBox.Items.Insert(0,S);
  AdresBox.Text := S;
  ShowCaption;
end;

procedure TStructShowForm.AdresBoxExit(Sender: TObject);
begin
  inherited;
  AddToList(Sender as TComboBox);
  ShowCaption;
end;


procedure TStructShowForm.StructTreeViewCollapsed(Sender: TObject;
  Node: TTreeNode);
begin
  inherited;
  StructTreeView.Refresh;
end;

procedure TStructShowForm.StructTreeViewExpanded(Sender: TObject;
  Node: TTreeNode);
begin
  inherited;
  StructTreeView.Refresh;
end;

procedure TStructShowForm.ReadMem;
var
  A : integer;
  st  : TStatus;
begin
  inherited;
  ShowCaption;
  A := MapParser.StrToAdr(AdresBox.Text);
  if A<0 then
    raise exception.Create('èle wprowadzony adres');
  if Length(MemBuf)<>0 then
  begin
    st := Dev.ReadDevMem(Handle,MemBuf[0],A,Length(MemBuf));
    BufSt := (St=stOK);
    if not(BufSt) then
      DoMsg(Dev.GetErrStr(St))
    else
      StructTreeView.Refresh;
  end;
end;

procedure TStructShowForm.ReadMemActUpdate(Sender: TObject);
var
  q : boolean;
begin
  inherited;
  q := false;
  if Dev<>nil then
    q :=  Dev.Connected and not(AutoRepBtn.Down);
  (sender as TAction).Enabled := q;
end;

procedure TStructShowForm.ReadMemActExecute(Sender: TObject);
begin
  inherited;
  Readmem;
end;

procedure TStructShowForm.AutoRepTimerTimer(Sender: TObject);
begin
  inherited;
  AutoRepTimer.Enabled:=false;
  ReadMem;
  AutoRepTimer.Enabled:=BufSt;
  AutoRepBtn.Down := BufSt;
end;

procedure TStructShowForm.AutoReadActUpdate(Sender: TObject);
var
  q : boolean;
begin
  inherited;
  q := false;
  if Dev<>nil then
    q :=  Dev.Connected;
  (sender as TAction).Enabled := q;
end;

procedure TStructShowForm.AutoReadActExecute(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Checked := not((Sender as TAction).Checked);
  AutoRepTimer.Enabled := (Sender as TAction).Checked;
  try
    AutoRepTimer.Interval := StrToInt(AutoRepTmEdit.Text);
  except
    ShowMessage('èle wprowadzony czas repetycji');
  end;
end;

procedure TStructShowForm.AutoRepTmEditExit(Sender: TObject);
begin
  inherited;
  AddToList(Sender as TComboBox);
end;

procedure TStructShowForm.ShowWinActUpdate(Sender: TObject);
var
  ofs  : integer;
  adr  : integer;
  size : integer;
begin
  inherited;
  (Sender as TAction).Enabled := GetNodeProp(StructTreeView.Selected,Adr,Ofs,Size);
end;

procedure TStructShowForm.ShowWinActExecute(Sender: TObject);
var
  ofs  : integer;
  adr  : integer;
  size : integer;
begin
  inherited;
  if GetNodeProp(StructTreeView.Selected,Adr,Ofs,Size) then
  begin
    AdrCpx.Adres := Adr+Ofs;
    PostMessage(Application.MainForm.Handle,wm_ShowmemWin,integer(@AdrCpx),0);
  end;
end;


procedure TStructShowForm.CopyAdressActExecute(Sender: TObject);
var
  ofs  : integer;
  adr  : integer;
  size : integer;
begin
  inherited;
  if GetNodeProp(StructTreeView.Selected,Adr,Ofs,Size) then
    ClipBoard.SetTextBuf(pchar('0x'+IntToHex(Adr+Ofs,6)));
end;

procedure TStructShowForm.EditActUpdate(Sender: TObject);
var
  ofs  : integer;
  adr  : integer;
  size : integer;
  p    : boolean;
  M    : THType;
begin
  inherited;
  p := false;
  if StructTreeView.Selected<>nil then
  begin
    if StructTreeView.Selected.Data<>nil then
    begin
      M := THType(StructTreeView.Selected.Data);
      if not(M.IsStruct) then
      begin
        if GetNodeProp(StructTreeView.Selected,Adr,Ofs,Size) and (Dev<>nil) then
          p := dev.Connected;
      end;
    end;
  end;
  (Sender as TAction).Enabled := p;
end;

procedure TStructShowForm.EditActExecute(Sender: TObject);
var
  M   : THType;
  s   : string;
  st  : TStatus;
  ofs  : integer;
  adr  : integer;
  PhAdr: integer;
  size : integer;
  p    : pByte;
begin
  inherited;
  if GetNodeProp(StructTreeView.Selected,Adr,Ofs,Size) then
  begin
    PhAdr := Adr;
    M := THType(StructTreeView.Selected.Data);
    p := pbyte(@MemBuf[Ofs]);
    s := M.ToText(ProgCfg.ByteOrder, p,GlobTypeList,smDEFAULT);
    if InputQuery(M.FldName,'Podaj nowπ wartoúÊ:',s) then
    begin
      p := pbyte(@MemBuf[Ofs]);
      if M.LoadFromText(ProgCfg.ByteOrder, p,GlobTypeList,smDEFAULT,s) then
      begin
        DoMsg(Format('WriteMem, adr=0x%X, size=%u',[Adr+Ofs,Size]));
        st := Dev.WriteDevMem(Handle,MemBuf[ofs],PhAdr+Ofs,Size);
        if st<>stOk then
          DoMsg(Dev.GetErrStr(st));
        StructTreeView.Refresh;
      end
      else
        DoMsg('Niezrozumia≥a wartoúÊ dla zmiennej:'+M.FldName);
    end;
  end;
end;

procedure TStructShowForm.StructTreeViewKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
  if Key=#10 then
  begin
    EditAct.Execute;
    Key := #0;
  end;
end;

function  TStructShowForm.GetDefaultCaption : string;
begin
  Result := 'STRUCT : '+ AdresBox.text+' ('+ TypeDefBox.text+')';
end;

procedure TStructShowForm.StructTreeViewDblClick(Sender: TObject);
begin
  inherited;
  EditAct.Execute;
end;



end.
