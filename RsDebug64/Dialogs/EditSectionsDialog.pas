unit EditSectionsDialog;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, SectionsDefUnit,
  ProgCfgUnit;

type
  TEditSectionsDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    SectionsDefFrame: TSectionsDefFrame;
  private
    { Private declarations }
  public
    procedure setSectionDef(const ShowVarCfg: TSectionsCfg);
    procedure getSectionDef(var ShowVarCfg: TSectionsCfg);
  end;

implementation

{$R *.dfm}

procedure TEditSectionsDlg.setSectionDef(const ShowVarCfg: TSectionsCfg);
begin
  SectionsDefFrame.SelSectionModeBox.ItemIndex := ord(ShowVarCfg.SelSectionMode);
  SectionsDefFrame.SectionsListMemo.Lines.Clear;
  SectionsDefFrame.SectionsListMemo.Lines.AddStrings(ShowVarCfg.SelSections);

end;

procedure TEditSectionsDlg.getSectionDef(var ShowVarCfg: TSectionsCfg);
begin
  ShowVarCfg.SelSectionMode := TSelSectionMode (SectionsDefFrame.SelSectionModeBox.ItemIndex);
  ShowVarCfg.SelSections.Clear;
  ShowVarCfg.SelSections.AddStrings(SectionsDefFrame.SectionsListMemo.Lines);
end;

end.
