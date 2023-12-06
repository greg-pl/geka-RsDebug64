unit DevStrEditUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TDevStrEditForm = class(TForm)
    DevStrEdit1: TComboBox;
    Label1: TLabel;
    Bevel1: TBevel;
    Button1: TButton;
    Button2: TButton;
    DevStrEdit2: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    DevStrEdit3: TComboBox;
    Label6: TLabel;
    DevStrEdit4: TComboBox;
    Label7: TLabel;
    DevStrEdit5: TComboBox;
    Label4: TLabel;
    DevStrEdit6: TComboBox;
    Label5: TLabel;
    DevStrEdit7: TComboBox;
    Label8: TLabel;
    Label9: TLabel;
    procedure Button1Click(Sender: TObject);
  public
    procedure GetHistoryDevStr(SL : TStrings);
    procedure SetHistoryDevStr(SL : TStrings);
    procedure SetDevStrings(SL : TStrings);
    procedure GetDevStrings(SL : TStrings);
  end;

var
  DevStrEditForm: TDevStrEditForm;

implementation

{$R *.dfm}

procedure TDevStrEditForm.GetHistoryDevStr(SL : TStrings);
begin
  SL.Clear;
  SL.AddStrings(DevStrEdit1.Items);
end;

procedure TDevStrEditForm.SetHistoryDevStr(SL : TStrings);
begin
  DevStrEdit1.Items.Clear;
  DevStrEdit1.Items.AddStrings(SL);
  DevStrEdit2.Items.Clear;
  DevStrEdit2.Items.AddStrings(SL);
  DevStrEdit3.Items.Clear;
  DevStrEdit3.Items.AddStrings(SL);
  DevStrEdit4.Items.Clear;
  DevStrEdit4.Items.AddStrings(SL);
  DevStrEdit5.Items.Clear;
  DevStrEdit5.Items.AddStrings(SL);
  DevStrEdit6.Items.Clear;
  DevStrEdit6.Items.AddStrings(SL);
  DevStrEdit7.Items.Clear;
  DevStrEdit7.Items.AddStrings(SL);
end;

procedure TDevStrEditForm.Button1Click(Sender: TObject);
begin
  DevStrEdit1.Items.Add(DevStrEdit1.Text);
end;

procedure TDevStrEditForm.SetDevStrings(SL : TStrings);
begin
  DevStrEdit1.Text := '';
  DevStrEdit2.Text := '';
  DevStrEdit3.Text := '';
  DevStrEdit4.Text := '';
  DevStrEdit5.Text := '';
  DevStrEdit6.Text := '';
  DevStrEdit7.Text := '';
  if SL.Count>0 then DevStrEdit1.Text := SL.Strings[0];
  if SL.Count>1 then DevStrEdit2.Text := SL.Strings[1];
  if SL.Count>2 then DevStrEdit3.Text := SL.Strings[2];
  if SL.Count>3 then DevStrEdit4.Text := SL.Strings[3];
  if SL.Count>4 then DevStrEdit5.Text := SL.Strings[4];
  if SL.Count>5 then DevStrEdit6.Text := SL.Strings[5];
  if SL.Count>6 then DevStrEdit7.Text := SL.Strings[6];
end;

procedure TDevStrEditForm.GetDevStrings(SL : TStrings);
  procedure AddIfNoEmpty(s :string);
  begin
    if s<>'' then
      SL.Add(s);
  end;
begin
  SL.Clear;
  AddIfNoEmpty(DevStrEdit1.Text);
  AddIfNoEmpty(DevStrEdit2.Text);
  AddIfNoEmpty(DevStrEdit3.Text);
  AddIfNoEmpty(DevStrEdit4.Text);
  AddIfNoEmpty(DevStrEdit5.Text);
  AddIfNoEmpty(DevStrEdit6.Text);
  AddIfNoEmpty(DevStrEdit7.Text);
end;

end.





