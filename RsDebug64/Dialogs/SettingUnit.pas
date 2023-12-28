unit SettingUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  Spin, ComCtrls, Grids,
  ProgCfgUnit, ToolsUnit;

type
  TSettingForm = class(TForm)
    OkBtn: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    SelectAsmBox: TCheckBox;
    SelectC_Box: TCheckBox;
    SelectSysBox: TCheckBox;
    Label1: TLabel;
    AutoSaveBox: TComboBox;
    Label2: TLabel;
    AutoRefreshmapBox: TComboBox;
    SectionBox: TGroupBox;
    AllSectionBox: TRadioButton;
    SelSectionBox: TRadioButton;
    SectionsEdit: TMemo;
    MotorolaBox: TRadioGroup;
    Label3: TLabel;
    ScalMemEdit: TSpinEdit;
    Label4: TLabel;
    MaxVarSizeEdit: TSpinEdit;
    SelNoSectionBox: TRadioButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    WinTabsBox: TRadioGroup;
    MainPtrSizeGrp: TRadioGroup;
    procedure FormActivate(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SettingForm: TSettingForm;

implementation

{$R *.dfm}

procedure TSettingForm.FormActivate(Sender: TObject);
var
  i: integer;
begin
  AutoSaveBox.ItemIndex := ord(ProgCfg.AutoSaveCfg);
  AutoRefreshmapBox.ItemIndex := ord(ProgCfg.AutoRefreshMap);
  SelectAsmBox.Checked := ProgCfg.SelectAsmVar;
  SelectC_Box.Checked  := ProgCfg.SelectC_Var;
  SelectSysBox.Checked := ProgCfg.SelectSysVar;
  MotorolaBox.ItemIndex := ord(ProgCfg.ByteOrder);
  WinTabsBox.ItemIndex := ord(ProgCfg.WinTab);
  MainPtrSizeGrp.ItemIndex := ord(ProgCfg.PtrSize);

  case ProgCfg.SelSectionMode of
  0 : AllSectionBox.Checked := true;
  1 : SelSectionBox.Checked := true;
  else
    SelNoSectionBox.Checked := true;
  end;
  SectionsEdit.Lines.Clear;
  SectionsEdit.Lines.AddStrings(ProgCfg.SelSections);
  ScalMemEdit.Value := ProgCfg.ScalmemCnt;
  MaxVarSizeEdit.Value := ProgCfg.MaxVarSize;

end;

procedure TSettingForm.OkBtnClick(Sender: TObject);
var
  i    : integer;
begin
  ProgCfg.SelectAsmVar := SelectAsmBox.Checked;
  ProgCfg.SelectC_Var  := SelectC_Box.Checked;
  ProgCfg.SelectSysVar := SelectSysBox.Checked;
  ProgCfg.ByteOrder := TByteOrder(MotorolaBox.ItemIndex);
  ProgCfg.WinTab := TWinTab(WinTabsBox.ItemIndex);
  ProgCfg.PtrSize := TPtrSize(MainPtrSizeGrp.ItemIndex);

  ProgCfg.AutoSaveCfg    := TYesNoAsk(AutoSaveBox.ItemIndex);
  ProgCfg.AutoRefreshMap := TYesNoAsk(AutoRefreshmapBox.ItemIndex);
  ProgCfg.SelSectionMode := 2;
  if AllSectionBox.Checked then ProgCfg.SelSectionMode := 0;
  if SelSectionBox.Checked then ProgCfg.SelSectionMode := 1;

  ProgCfg.SelSections.Clear;
  ProgCfg.SelSections.AddStrings(SectionsEdit.Lines);
  ProgCfg.ScalmemCnt := ScalMemEdit.Value;
  ProgCfg.MaxVarSize := MaxVarSizeEdit.Value;


  PostMessage(Application.MainForm.Handle,wm_SettingsChg,0,0);
end;

end.
