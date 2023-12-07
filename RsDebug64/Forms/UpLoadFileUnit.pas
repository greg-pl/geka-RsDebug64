unit UpLoadFileUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ImgList, ComCtrls, StdCtrls, ExtCtrls,Contnrs,
  ProgCfgUnit,UpLoadDefUnit, ActnList, ToolWin;

type
  TUpLoadFileForm = class(TChildForm)
    Button1: TButton;
    TypeNameBox: TComboBox;
    Label1: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Button2: TButton;
    Button3: TButton;
    LabeledEdit3: TLabeledEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}





procedure TUpLoadFileForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
end;

end.
