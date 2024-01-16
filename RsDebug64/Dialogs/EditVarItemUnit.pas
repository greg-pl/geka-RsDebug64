unit EditVarItemUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  TypeDefUnit, Spin;

type
  TEditVarItemForm = class(TForm)
    Label1: TLabel;
    DisplayTypeBox: TComboBox;
    Label2: TLabel;
    Bevel1: TBevel;
    OkBtn: TButton;
    CancelBtn: TButton;
    TypeNameBox: TComboBox;
    RepeatEdit: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    VarNameEdit: TEdit;
    VarAdresEdit: TEdit;
    Label5: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure SelectBoxKeyPress(Sender: TObject; var Key: Char);
  private
    function CheckName(s : string):string;
  public
    Rep      : Integer;
    Typname  : string;
    ShowMode : TShowMode;
    VarName  : string;
    VarAdress: cardinal;
    Manual   : boolean;
    function TypeList : TStrings;
  end;

var
  EditVarItemForm: TEditVarItemForm;

implementation

{$R *.dfm}

procedure TEditVarItemForm.FormActivate(Sender: TObject);
var
  n : TShowMode;
  k : integer;
begin
  Caption := 'Variable property: '+VarName;
  DisplayTypeBox.Items.Clear;
  for n := low(TShowMode) to high(TShowMode) do
    DisplayTypeBox.Items.Add(ShowModeTxt[n]);

  RepeatEdit.Value := Rep;
  DisplayTypeBox.ItemIndex :=ord(ShowMode);
  k := TypeNameBox.Items.IndexOf(Typname);
  TypeNameBox.ItemIndex := k;
  VarNameEdit.Enabled := Manual;
  VarNameEdit.Text := VarName;
  VarAdresEdit.Enabled := Manual;
  VarAdresEdit.Text := IntToHex(VarAdress,0);
  if not(Manual) then
    TypeNameBox.SetFocus;
end;

function TEditVarItemForm.TypeList : TStrings;
begin
  Result := TypeNameBox.Items;
end;

function TEditVarItemForm.CheckName(s : string):string;
const
  AcceptChar : set of char = ['0'..'9','A'..'Z','a'..'z','_'];
var
  i,L : integer;
begin
  L := length(s);
  for i:=1 to L do 
  begin
    if not(s[i] in AcceptChar) then
      raise exception.Create(Format('char %s is not allowed',[s[1]]));
  end;
  Result := s;
end;

procedure TEditVarItemForm.OkBtnClick(Sender: TObject);
begin
  ModalResult := mrOK;
  Rep       := RepeatEdit.Value;
  ShowMode  := TShowMode(DisplayTypeBox.ItemIndex);
  TypName   := TypeNameBox.Text;
  try
    VarName   := CheckName(VarNameEdit.Text);
  except
    VarNameEdit.SetFocus;
    VarNameEdit.SelectAll;
    ModalResult := mrNone;
    raise;
  end;

  try
    VarAdress := StrToInt64('$'+VarAdresEdit.Text);
  except
    VarAdresEdit.SetFocus;
    VarAdresEdit.SelectAll;
    ModalResult := mrNone;
    raise;
  end;
end;

procedure TEditVarItemForm.EditKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key=#27 then
  begin
    Close;
    Key := #0;
  end;
end;

procedure TEditVarItemForm.SelectBoxKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not((Sender as TComboBox).DroppedDown) then
  begin
    if Key=#27 then
    begin
      Close;
      Key := #0;
    end;
  end;
end;

end.
