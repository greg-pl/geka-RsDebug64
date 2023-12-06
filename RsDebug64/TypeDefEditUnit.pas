unit TypeDefEditUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, Menus, ComCtrls,StdCtrls, ExtCtrls,ActnList, ToolWin,
  ProgCfgUnit,
  EditTypeItemUnit,
  RmtChildUnit,
  TypeDefUnit;

type
  TTypeDefEditForm = class(TChildForm)
    TypeDefTree: TTreeView;
    TreePopUpMenu: TPopupMenu;
    AddStruktItem: TMenuItem;
    AddFieldItem: TMenuItem;
    DelItem: TMenuItem;
    EditItem: TMenuItem;
    AddSimleType: TMenuItem;
    Panel1: TPanel;
    SaveBtn: TButton;
    EditNameItem: TMenuItem;
    Splitter1: TSplitter;
    Panel2: TPanel;
    InfoMemo: TMemo;
    N1: TMenuItem;
    N2: TMenuItem;
    ExpandTreeView: TTreeView;
    Splitter2: TSplitter;
    procedure TypeDefTreeGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure TypeDefTreeGetSelectedIndex(Sender: TObject;
      Node: TTreeNode);
    procedure TypeDefTreeEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure AddStruktItemClick(Sender: TObject);
    procedure AddFieldItemClick(Sender: TObject);
    procedure DelItemClick(Sender: TObject);
    procedure EditItemClick(Sender: TObject);
    procedure TypeDefTreeDeletion(Sender: TObject; Node: TTreeNode);
    procedure TreePopUpMenuPopup(Sender: TObject);
    procedure AddSimleTypeClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure EditNameItemClick(Sender: TObject);
    procedure TypeDefTreeEdited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure TypeDefTreeDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TypeDefTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TypeDefTreeChange(Sender: TObject; Node: TTreeNode);
    procedure TypeDefTreeDblClick(Sender: TObject);
    procedure ExpandTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
  public
    MyData : boolean;
    procedure LoadTypeDefTree(HList : THTypeList);
    function  GetFromTree(Tree : TTreeView; HList : THTypeList; FindObj :THType) :THType;
    procedure GetFromTypeDefTree(HList : THTypeList);
  end;

var
  TypeDefEditForm: TTypeDefEditForm;

implementation

{$R *.dfm}

procedure TTypeDefEditForm.FormActivate(Sender: TObject);
begin
  inherited;
  ShowParamAct.Execute;
end;

procedure TTypeDefEditForm.LoadTypeDefTree(HList : THTypeList);
begin
  MyData := (HList = GlobTypeList);
  HList.FillTree(TypeDefTree,nil,0);
  SaveBtn.Enabled := MyData;
end;

function  TTypeDefEditForm.GetFromTree(Tree : TTreeView; HList : THTypeList; FindObj :THType) :THType;
begin
  HList.Clear;
  Result := HList.ReadfromTree(Tree,FindObj);
end;

procedure TTypeDefEditForm.GetFromTypeDefTree(HList : THTypeList);
begin
  HList.Clear;
  HList.ReadfromTree(TypeDefTree,nil);
end;


procedure TTypeDefEditForm.TypeDefTreeGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  Node.ImageIndex := THType(Node.Data).GetImageIndex;
end;

procedure TTypeDefEditForm.TypeDefTreeGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TTypeDefEditForm.TypeDefTreeEditing(Sender: TObject;
  Node: TTreeNode; var AllowEdit: Boolean);
begin
  AllowEdit := not(THType(Node.Data).IsSysBase);
end;

procedure TTypeDefEditForm.TypeDefTreeEdited(Sender: TObject;
  Node: TTreeNode; var S: String);
begin
  inherited;
  THType(Node.Data).FldName := S;
end;


procedure TTypeDefEditForm.TypeDefTreeDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  THtype(Node.Data).Free;
end;

procedure TTypeDefEditForm.TreePopUpMenuPopup(Sender: TObject);
var
  H : THType;
  N : TTreeNode;
  q1,q2,q3,q4 : boolean;
begin
  q1 := false;
  q2 := false;
  q3 := false;
  q4 := false;
  N := TypeDefTree.Selected;
  if N<>nil then
  begin
    H := THType(N.Data);
    q1 := not(H.IsSysBase);
    q2 := H.IsStruct or (N.Parent<>nil);
    q3 := not(H.IsSysBase);
    q4 := not(H.IsStruct) and not(H.IsSysBase);
  end;

  AddStruktItem.Enabled := true;
  AddSimleType.Enabled := true;
  AddFieldItem.Enabled := q2;
  DelItem.Enabled := q1;
  EditItem.Enabled := q4;
  EditNameItem.Enabled := q3;
end;


procedure TTypeDefEditForm.EditNameItemClick(Sender: TObject);
begin
  inherited;
  if TypeDefTree.Selected<>nil then
    TypeDefTree.Selected.EditText;
end;


procedure TTypeDefEditForm.AddStruktItemClick(Sender: TObject);
var
  H : THType;
begin
  H := THType.Create;
  H.FldName := 'New_struckt';
  H.IsStruct := true;
  TypeDefTree.Items.AddObject(nil,H.FldName,H);
end;

procedure TTypeDefEditForm.AddSimleTypeClick(Sender: TObject);
var
  H : THType;
begin
  H := THType.Create;
  H.FldName := 'New_type';
  H.TName := SysVarTxt[ssINT];
  TypeDefTree.Items.AddObject(nil,H.FldName,H);
end;


procedure TTypeDefEditForm.AddFieldItemClick(Sender: TObject);
var
  H : THType;
  N : TTreeNode;
begin
  N := TypeDefTree.Selected;
  if N<>nil then
  begin
    H := THType.Create;
    H.TName := SysVarTxt[ssINT];
    H.FldName := 'New_Field';
    if N.Parent=nil then
      TypeDefTree.Items.AddChildObject(N,H.FldName,H)
    else
      TypeDefTree.Items.InsertObject(N,H.FldName,H)
  end;
end;

procedure TTypeDefEditForm.DelItemClick(Sender: TObject);
var
  i : integer;
  L : TList;
begin
  L := TList.Create;
  try
    for i:=0 to TypeDefTree.Items.Count-1 do
    begin
      if TypeDefTree.Items[i].Selected then
        L.Add(TypeDefTree.Items[i]);
    end;
    for i:=0 to L.Count-1 do
    begin
      TTreeNode(L.Items[i]).Delete;
    end;
  finally
    L.Free;
  end;
end;

procedure TTypeDefEditForm.TypeDefTreeDblClick(Sender: TObject);
begin
  inherited;
  EditItemClick(Sender);
end;

procedure TTypeDefEditForm.EditItemClick(Sender: TObject);
var
  Dlg : TEditTypeItemForm;
  N   : TTreeNode;
  H   : THType;
  HL  : THTypeList;
begin
  N := TypeDefTree.Selected;
  if N=nil then exit;
  H := THType(N.Data);
  if H.IsStruct or H.IsSysBase then Exit;
  HL  := THTypeList.CreateSys;
  Dlg := TEditTypeItemForm.Create(self);
  try
    GetFromTypeDefTree(HL);
    HL.LoadTypeList(Dlg.TypeList);
    Dlg.EdH:=H;
    Dlg.ShowModal;
    N.Text := h.FldName;
  finally
    HL.Free;
    Dlg.Free;
  end;
end;

procedure TTypeDefEditForm.SaveBtnClick(Sender: TObject);
begin
  if MyData then
    GetFromTypeDefTree(GlobTypeList);
  PostMessage(Application.MainForm.Handle,wm_TypeDefChg,0,0);
end;

procedure TTypeDefEditForm.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TTypeDefEditForm.TypeDefTreeDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  NT,NS : TTreeNode;
  HT,HS : THType;
begin
  inherited;
  Accept:=false;
  if (Source is TTreeView) and (Sender is TTreeView) then
  begin
    NS := (Source as TTreeView).Selected;
    if NS<>nil then
    begin
      HS := THType(NS.Data);
      if Source=Sender then
      begin
        NT := (Sender as TTreeView).DropTarget;
        if NT<>nil then
        begin
          HT := THType(NT.Data);
          if Sender=Source then
          begin
            if HT.IsSysBase then Exit;
            // pola w ramach jednego typu
            if NS.Parent<>nil then
            begin
              Accept := NS.Parent=NT.Parent;
            end;
            // kolejnoœæ definicji typów
            if (NS.Parent=nil) and (NT.Parent=nil) and  not(HS.IsSysBase) then
            begin
              Accept := NS.Parent=NT.Parent;
            end;
            // tworzenie pol danego typu
            if (NS.Parent=nil) and (NT.Parent<>nil) then
            begin
              Accept := NS<>NT.Parent;
            end;
          end;
        end;
      end
      else
      begin
        // przenoszenie miêdzy roznymi drzewami
        if (NS.Parent=nil)  and  not(HS.IsSysBase) then
        begin
          Accept := true;
        end;
      end;
    end;
  end;
end;

procedure TTypeDefEditForm.TypeDefTreeDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  NT,NS  : TTreeNode;
  HT,HS  : THType;
  HCh    : THType;
  NG     : TTreeNode;
begin
  inherited;
  if (Source is TTreeView) and (Sender is TTreeView) then
  begin
    NT := (Sender as TTreeView).DropTarget;
    NS := (Source as TTreeView).Selected;
    if (NT<>nil) and (NS<>nil) then
    begin
      HT := THType(NT.Data);
      HS := THType(NS.Data);
      if Sender=Source then
      begin
        if HT.IsSysBase then Exit;
        // przesuniêcie pola w ramach jednego typu
        if NS.Parent<>nil then
        begin
          NS.MoveTo(NT,naInsert);
        end;
        // kolejnoœæ definicji typów
        if (NS.Parent=nil) and (NT.Parent=nil) and  not(HS.IsSysBase) then
        begin
          NS.MoveTo(NT,naInsert);
        end;
        // tworzenie pol danego typu
        if (NS.Parent=nil) and (NT.Parent<>nil) then
        begin
          HCh := THType.Create;
          HCh.TName := HS.FldName;
          HCh.FldName := 'A_'+HCh.TName;
          if NT.Parent=nil then
            (Sender as TTreeView).Items.AddChildObjectFirst(NT,HCh.FldName,HCh)
          else
            (Sender as TTreeView).Items.InsertObject(NT,HCh.FldName,HCh);
        end;
      end
      else
      begin
        // przenoszenie miêdzy roznymi drzewami
        HCh := HS.GetFreeCopy;
        NG := (Sender as TTreeView).Items.InsertObject(NT,HCh.FldName,HCh);
        NS := NS.getFirstChild;
        while NS<>nil do
        begin
          HCh := THType(NS.Data).GetFreeCopy;
         (Sender as TTreeView).Items.AddChildObject(NG,HCh.FldName,HCh);
          NS := NS.getNextSibling;
        end;
      end;
    end;
  end;
end;

procedure TTypeDefEditForm.TypeDefTreeChange(Sender: TObject;
  Node: TTreeNode);
var
  HL  : THTypeList;
  HF  : THType;
  HEx : THType;
begin
  inherited;
  HL  := THTypeList.CreateSys;
  try
    HF:=HL.ReadfromTree(Sender as TTreeView,THType(NOde.Data));
    if HF<>nil then
      HF.InfoType(HL,InfoMemo.Lines);
    ExpandTreeView.Items.Clear;
    if Node.Parent=nil then
    begin
      HEx := HF.Exploid(HL);
      HEx.FillTree(ExpandTreeView,nil,0);
      HEx.Free;
      if ExpandTreeView.Items.Count>0 then
        ExpandTreeView.Items[0].Expand(false);
    end;    
  finally
    HL.Free;
  end;
end;


procedure TTypeDefEditForm.ExpandTreeViewChange(Sender: TObject;
  Node: TTreeNode);
var
  HL  : THTypeList;
  HF  : THType;
begin
  inherited;
  HL  := THTypeList.CreateSys;
  try
    HF:=HL.ReadfromTree(Sender as TTreeView,(Sender as TTreeView).Items[0],THType(NOde.Data));
    if HF<>nil then
      HF.InfoType(HL,InfoMemo.Lines)
    else
      InfoMemo.Lines.Clear;
  finally
    HL.Free;
  end;
end;


procedure TTypeDefEditForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
end;


end.
