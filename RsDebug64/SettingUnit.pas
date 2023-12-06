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
    TabSheet2: TTabSheet;
    AreaGrid: TStringGrid;
    WinTabsBox: TRadioGroup;
    MainPtrSizeGrp: TRadioGroup;
    procedure FormActivate(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure AreaGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure TabSheet2Show(Sender: TObject);
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
  MotorolaBox.ItemIndex := ord(ProgCfg.AreaDefList.MainArea.ByteOrder);
  WinTabsBox.ItemIndex := ord(ProgCfg.WinTab);
  MainPtrSizeGrp.ItemIndex := ord(ProgCfg.AreaDefList.MainArea.PtrSize);

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

  if AreaGrid.RowCount+3<ProgCfg.AreaDefList.Count then
    AreaGrid.RowCount:=ProgCfg.AreaDefList.Count+3;

  AreaGrid.Rows[0].CommaText := 'lp. B/L R.size Nazwa Offset PtrSize';
  for i:=1 to AreaGrid.RowCount-1 do
  begin
    AreaGrid.Rows[i].CommaText := IntToStr(i);
  end;
  for i:=0 to ProgCfg.AreaDefList.Count-1 do
  begin
    AreaGrid.Cells[0,i+1] := IntToStr(i+1);
    AreaGrid.Cells[1,i+1] := ByteOrderName[ProgCfg.AreaDefList.Items[i].ByteOrder];
    AreaGrid.Cells[2,i+1] := IntToStr(ProgCfg.AreaDefList.Items[i].RegSize);
    AreaGrid.Cells[3,i+1] := ProgCfg.AreaDefList.Items[i].Name;
    AreaGrid.Cells[4,i+1] := ProgCfg.AreaDefList.Items[i].Offset;
    AreaGrid.Cells[5,i+1] := GetPtrSizeName(ProgCfg.AreaDefList.Items[i].PtrSize);
  end;
end;

procedure TSettingForm.OkBtnClick(Sender: TObject);
var
  i    : integer;
  Item : TAreaDefItem;
begin
  ProgCfg.SelectAsmVar := SelectAsmBox.Checked;
  ProgCfg.SelectC_Var  := SelectC_Box.Checked;
  ProgCfg.SelectSysVar := SelectSysBox.Checked;
  ProgCfg.AreaDefList.MainArea.ByteOrder := TByteOrder(MotorolaBox.ItemIndex);
  ProgCfg.WinTab := TWinTab(WinTabsBox.ItemIndex);
  ProgCfg.AreaDefList.MainArea.PtrSize := TPtrSize(MainPtrSizeGrp.ItemIndex);

  ProgCfg.AutoSaveCfg    := TYesNoAsk(AutoSaveBox.ItemIndex);
  ProgCfg.AutoRefreshMap := TYesNoAsk(AutoRefreshmapBox.ItemIndex);
  ProgCfg.SelSectionMode := 2;
  if AllSectionBox.Checked then ProgCfg.SelSectionMode := 0;
  if SelSectionBox.Checked then ProgCfg.SelSectionMode := 1;

  ProgCfg.SelSections.Clear;
  ProgCfg.SelSections.AddStrings(SectionsEdit.Lines);
  ProgCfg.ScalmemCnt := ScalMemEdit.Value;
  ProgCfg.MaxVarSize := MaxVarSizeEdit.Value;

  ProgCfg.AreaDefList.Clear;
  for i:=1 to AreaGrid.RowCount-1 do
  begin
    if (AreaGrid.Cells[1,i]<>'') and
       (AreaGrid.Cells[2,i]<>'') and
       (AreaGrid.Cells[3,i]<>'') and
       (AreaGrid.Cells[4,i]<>'') and
       (AreaGrid.Cells[5,i]<>'') then
    begin
      Item := ProgCfg.AreaDefList.NewItem;
      Item.Offset := AreaGrid.Cells[4,i];
      Item.Name := AreaGrid.Cells[3,i];
      Item.RegSize := StrToInt(AreaGrid.Cells[2,i]);
      if AreaGrid.Cells[1,i]=ByteOrderName[boBig] then
        Item.ByteOrder := boBig
      else
        Item.ByteOrder := boLittle;
      Item.PtrSize := GetPtrSize(AreaGrid.Cells[5,i],ps32);
    end;
  end;

  PostMessage(Application.MainForm.Handle,wm_SettingsChg,0,0);
end;

procedure TSettingForm.AreaGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
  s : string;
  N : integer;
begin
  if AreaGrid.EditorMode=false then
  begin
    case ACol of
    1:begin
        s := UpperCase(Value);
        if (s<>'B') and (s<>'L') then s := 'L';
        AreaGrid.Cells[ACol,ARow] := s;
      end;
    2:begin
        s := Value;
        if TryStrToInt(s,N) then
        begin
          if (N<>1) and (N<>2) and (N<>4) then
            s := '1';
        end
        else
          s := '1';

        AreaGrid.Cells[ACol,ARow] := s;
      end;
    3,4: AreaGrid.Cells[ACol,ARow] := Value;
    5  : begin
          s := Value+' ';
               if s[1]='8' then s := PtrSizeName[ps8]
          else if s[1]='1' then s := PtrSizeName[ps16]
          else if s[1]='3' then s := PtrSizeName[ps32]
          else s := PtrSizeName[ps32];
          AreaGrid.Cells[ACol,ARow] := s;
         end;
    end;
  end;
end;

procedure TSettingForm.TabSheet2Show(Sender: TObject);
begin
  AreaGrid.SetFocus;
end;

end.
