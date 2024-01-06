unit SettingUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  Spin, ComCtrls, Grids,
  ProgCfgUnit, ToolsUnit,
  JSonUtils, SectionsDefUnit;

type
  TSettingForm = class(TForm)
    OkBtn: TButton;
    Button2: TButton;
    Label1: TLabel;
    AutoSaveBox: TComboBox;
    Label2: TLabel;
    AutoRefreshmapBox: TComboBox;
    MotorolaBox: TRadioGroup;
    Label3: TLabel;
    ScalMemEdit: TSpinEdit;
    Label4: TLabel;
    MaxVarSizeEdit: TSpinEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    WinTabsBox: TRadioGroup;
    MainPtrSizeGrp: TRadioGroup;
    ObjdumpPathEdit: TLabeledEdit;
    SectionsDefFrame: TSectionsDefFrame;
    LoadOnStartUpBox: TCheckBox;
    procedure FormActivate(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

procedure TSettingForm.FormActivate(Sender: TObject);
begin
  AutoSaveBox.ItemIndex := ord(ProgCfg.AutoSaveCfg);
  AutoRefreshmapBox.ItemIndex := ord(ProgCfg.AutoRefreshMap);
  MotorolaBox.ItemIndex := ord(ProgCfg.ByteOrder);
  WinTabsBox.ItemIndex := ord(ProgCfg.WinTab);
  MainPtrSizeGrp.ItemIndex := ord(ProgCfg.PtrSize);

  ScalMemEdit.Value := ProgCfg.ScalmemCnt;
  MaxVarSizeEdit.Value := ProgCfg.MaxVarSize;
  ObjdumpPathEdit.Text := ProgCfg.ObjDumpPath;
  SectionsDefFrame.SectionsListMemo.Lines.Clear;
  SectionsDefFrame.SectionsListMemo.Lines.AddStrings(ProgCfg.SectionsCfg.SelSections);
  SectionsDefFrame.SelSectionModeBox.ItemIndex := ord(ProgCfg.SectionsCfg.SelSectionMode);
  LoadOnStartUpBox.Checked := ProgCfg.LoadMapFileOnStartUp;

end;

procedure TSettingForm.OkBtnClick(Sender: TObject);
begin
  ProgCfg.ByteOrder := TByteOrder(MotorolaBox.ItemIndex);
  ProgCfg.WinTab := TWinTab(WinTabsBox.ItemIndex);
  ProgCfg.PtrSize := TPtrSize(MainPtrSizeGrp.ItemIndex);

  ProgCfg.AutoSaveCfg    := TYesNoAsk(AutoSaveBox.ItemIndex);
  ProgCfg.AutoRefreshMap := TYesNoAsk(AutoRefreshmapBox.ItemIndex);
  ProgCfg.ScalmemCnt := ScalMemEdit.Value;
  ProgCfg.MaxVarSize := MaxVarSizeEdit.Value;
  ProgCfg.ObjDumpPath := ObjdumpPathEdit.Text;
  ProgCfg.SectionsCfg.SelSections.Clear;
  ProgCfg.SectionsCfg.SelSections.AddStrings(SectionsDefFrame.SectionsListMemo.Lines);
  ProgCfg.SectionsCfg.SelSectionMode := TSelSectionMode(SectionsDefFrame.SelSectionModeBox.ItemIndex);
  ProgCfg.LoadMapFileOnStartUp := LoadOnStartUpBox.Checked;

  PostMessage(Application.MainForm.Handle,wm_SettingsChg,0,0);
end;

end.
