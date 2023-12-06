unit EditTypeItemUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  TypeDefUnit, Spin;

type
  TEditTypeItemForm = class(TForm)
    NameEdit: TLabeledEdit;
    Label1: TLabel;
    DisplayTypeBox: TComboBox;
    Label2: TLabel;
    Bevel1: TBevel;
    OkBtn: TButton;
    CancelBtn: TButton;
    TypeNameBox: TComboBox;
    RepeatEdit: TSpinEdit;
    Label3: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    EdH : THtype;
    function TypeList : TStrings;
  end;


implementation

{$R *.dfm}

procedure TEditTypeItemForm.FormActivate(Sender: TObject);
var
  n : TShowMode;
begin
  Caption := 'W³aœciwoœci pola';
  DisplayTypeBox.Items.Clear;
  n := low(TShowMode);
  repeat
    inc(n);
    DisplayTypeBox.Items.Add(ShowModeTxt[n]);
  until n=high(TShowMode);

  NameEdit.Text := EdH.FldName;
  RepeatEdit.Value := EdH.Rep;
  DisplayTypeBox.ItemIndex :=ord(EdH.ShowMode)-1;
  DisplayTypeBox.Text:=DisplayTypeBox.Items[DisplayTypeBox.ItemIndex];
  TypeNameBox.Text := EdH.TName;
end;

function TEditTypeItemForm.TypeList : TStrings;
begin
  Result := TypeNameBox.Items;
end;


procedure TEditTypeItemForm.OkBtnClick(Sender: TObject);
begin
  try
    ModalResult := mrNone;
    EdH.Rep := RepeatEdit.Value;
    EdH.FldName := NameEdit.Text;
    EdH.ShowMode := TShowMode(DisplayTypeBox.ItemIndex+1);
    EdH.TName := TypeNameBox.Text;
    ModalResult := mrOk;
  except
    raise;
  end;
end;

end.
