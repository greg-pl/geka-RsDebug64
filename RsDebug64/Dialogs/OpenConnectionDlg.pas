unit OpenConnectionDlg;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  SttScrollBoxUnit,
  RsdDll;

type
  TOKRightDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    TabControl: TTabControl;
    procedure TabControlChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    SttScrollBox: TSttScrollBox;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TOKRightDlg.FormCreate(Sender: TObject);
begin
  SttScrollBox := TSttScrollBox.Create(TabControl);
  SttScrollBox.Parent := TabControl;
  SttScrollBox.Align := alClient;
end;

procedure TOKRightDlg.TabControlChange(Sender: TObject);
begin
  OutputDebugString(pchar(Format('ControlCount=%d', [SttScrollBox.ControlCount])));

  SttScrollBox.LoadList(RsdDll.CmmLibraryList.Items[0].LibParams.ConnectionParams);

end;

end.
