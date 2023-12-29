unit WavGenUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ActnList, ImgList, ComCtrls, StdCtrls, CheckLst,
  Spin, Grids, ExtCtrls, Buttons, ToolsUnit, Menus, ToolWin,
  RsdDll,
  CommThreadUnit,
  MapParserUnit,
  ProgCfgUnit,
  ComTradeUnit,
  Wykres3Unit, WykresEngUnit,
  Rsd64Definitions,
  System.ImageList, System.Actions,
  System.JSON,
  JSonUtils;

type
  TWavGenForm = class(TChildForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ChartSheet: TTabSheet;
    LeftPanel: TPanel;
    DataSizeBox: TRadioGroup;
    DataTypeBox: TRadioGroup;
    SerieTypeBox: TRadioGroup;
    HarmonGrid: TStringGrid;
    FreqA1Panel: TPanel;
    SeriesListBox: TCheckListBox;
    IlKanPanel: TPanel;
    Label3: TLabel;
    KanalCntEdit: TSpinEdit;
    IlBitPanel: TPanel;
    Label5: TLabel;
    BitCntEdit: TSpinEdit;
    Panel5: TPanel;
    ChartListMenu: TPopupMenu;
    EditNameItem: TMenuItem;
    EditKolorItem: TMenuItem;
    ColorDialog1: TColorDialog;
    FreqPrPanel: TPanel;
    FreqA1Edit: TLabeledEdit;
    IlHarmPanel: TPanel;
    Label1: TLabel;
    HarmonCntEdit: TSpinEdit;
    FrequProbkEdit: TLabeledEdit;
    RdMemBtn: TToolButton;
    WrMemBtn: TToolButton;
    Label6: TLabel;
    Label7: TLabel;
    AdresBox: TComboBox;
    SizeBox: TComboBox;
    VarListBox: TComboBox;
    GenerujBtn: TToolButton;
    SaveToComtradeBtn: TToolButton;
    GenerujAct: TAction;
    SaveToComtradeAct: TAction;
    RdMemAct: TAction;
    WrMemAct: TAction;
    ToolButton1: TToolButton;
    procedure KanalCntEditChange(Sender: TObject);
    procedure HarmonCntEditChange(Sender: TObject);
    procedure ComboBoxExit(Sender: TObject);
    procedure AdresBoxChange(Sender: TObject);
    procedure VarListBoxDropDown(Sender: TObject);
    procedure VarListBoxChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure EditNameItemClick(Sender: TObject);
    procedure EditKolorItemClick(Sender: TObject);
    procedure GenerBtnClick(Sender: TObject);
    procedure SaveToComtradeBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RdMemActExecute(Sender: TObject);
    procedure WrMemActExecute(Sender: TObject);
  private
    MemBxLeft: integer;
    MemBuf: array of byte;
    GlFreqA1: real;
    GlFreqProb: real;
    GlMemSize: integer;
    GlMemAdr: integer;
    GlProbCnt: integer;
    GlDataSize: integer;
    GlKanCnt: integer;
    GlSerType: integer;
    GlBufRdy: boolean;
    GlMax: integer;
    Wykr: TElWykres;

    procedure WykrGetVal(Sender: TObject; DtNr: integer; NrProb: Cardinal; var Val: double; var Exist: boolean);

    procedure PrepareHarmonGrid;
    procedure SetSeriesCount;
    function CheckBiPolar: boolean;
    procedure ReadFromHarmonGrid(SygNr: integer; HarmNr: integer; var Ampl: real; var Phase: real);
    procedure BildReakVek(SygNr: integer; var Vek: array of real);
    procedure PutVekInMem(SygNr: integer; const Vek: array of real);
    procedure ResolveVariables;
    procedure FillWykres;
    procedure GenerateData;
    procedure wmReadMem1(var Msg: TMessage); message wm_ReadMem1;
    procedure wmWriteMem1(var Msg: TMessage); message wm_WriteMem1;
  public
    procedure ReloadMapParser; override;
    function GetDefaultCaption: string; override;

    function GetJSONObject: TJSONBuilder; override;
    procedure LoadfromJson(jParent: TJSONLoader); override;

  end;

var
  WavGenForm: TWavGenForm;

implementation

uses MemFrameUnit;

{$R *.dfm}

procedure TWavGenForm.FormCreate(Sender: TObject);
begin
  inherited;
  Wykr := TElWykres.Create(self);
  Wykr.Parent := ChartSheet;
  Wykr.Align := alClient;
  Wykr.OnGetAnValue := WykrGetVal;

  MemBxLeft := VarListBox.Left;
  GlBufRdy := false;
end;

procedure TWavGenForm.FormActivate(Sender: TObject);
begin
  inherited;
  ReloadMapParser;
end;

procedure TWavGenForm.PrepareHarmonGrid;
var
  i: integer;
begin
  HarmonGrid.RowCount := KanalCntEdit.Value + 1;
  HarmonGrid.ColCount := 2 * (HarmonCntEdit.Value + 1) - 1 + 1;
  for i := 0 to KanalCntEdit.Value - 1 do
  begin
    HarmonGrid.Cells[0, i + 1] := SeriesListBox.Items[i];
  end;

  HarmonGrid.Cells[1, 0] := 'A(0)';
  for i := 1 to HarmonCntEdit.Value do
  begin
    HarmonGrid.Cells[1 + 2 * i - 1, 0] := Format('A(%u)', [i]);
    HarmonGrid.Cells[1 + 2 * i, 0] := Format('F(%u)', [i]);
  end;
end;

procedure TWavGenForm.SetSeriesCount;
var
  n: integer;
  s: string;
begin
  n := KanalCntEdit.Value;
  while SeriesListBox.Count < n do
  begin
    s := 'Syg_' + IntToStr(SeriesListBox.Count);
    SeriesListBox.AddItem(s, nil);
    SeriesListBox.Checked[SeriesListBox.Count - 1] := True;
  end;
  while SeriesListBox.Count > n do
  begin
    SeriesListBox.Items.Delete(SeriesListBox.Count - 1);
  end;
end;

procedure TWavGenForm.KanalCntEditChange(Sender: TObject);
begin
  inherited;
  SetSeriesCount;
  PrepareHarmonGrid;
end;

procedure TWavGenForm.HarmonCntEditChange(Sender: TObject);
begin
  inherited;
  PrepareHarmonGrid;
  SetSeriesCount;
end;

procedure TWavGenForm.ComboBoxExit(Sender: TObject);
begin
  inherited;
  AddToList(Sender as TComboBox);
end;

procedure TWavGenForm.AdresBoxChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

procedure TWavGenForm.VarListBoxDropDown(Sender: TObject);
begin
  inherited;
  VarListBox.Width := VarListBox.Left - AdresBox.Left + 50;
  VarListBox.Left := AdresBox.Left;
end;

procedure TWavGenForm.VarListBoxChange(Sender: TObject);
begin
  inherited;
  AdresBox.Text := VarListBox.Items[VarListBox.ItemIndex];
  VarListBox.Left := MemBxLeft;
  VarListBox.Width := 50;
  ShowCaption;
end;

procedure TWavGenForm.ReloadMapParser;
begin
  inherited;
  MapParser.MapItemList.LoadToList(VarListBox.Items);
end;

function TWavGenForm.GetDefaultCaption: string;
begin
  Result := 'GENER : ' + AdresBox.Text;
end;

function TWavGenForm.GetJSONObject: TJSONBuilder;
var
  i, j: integer;
  s, sn: string;
  jArr: TJSONArray;
  jArr2: TJSONArray;
  jItem: TJSONBuilder;
  jItem2: TJSONBuilder;
begin
  Result := inherited GetJSONObject;
  Result.Add('Adr', AdresBox.Text);
  Result.Add('Adrs', AdresBox.Items);
  Result.Add('Size', SizeBox.Text);
  Result.Add('Sizes', SizeBox.Items);
  jArr := TJSONArray.Create;
  for i := 0 to SeriesListBox.Count - 1 do
  begin
    jItem.Init;
    jItem.Add('Name', SeriesListBox.Items[i]);
    jItem.Add('Active', SeriesListBox.Checked[i]);
    jItem.AddColor('Color', Cardinal(SeriesListBox.Items.Objects[i]));

    jArr2 := TJSONArray.Create;
    for j := 0 to HarmonCntEdit.Value do
    begin
      jItem2.Init;

      if j = 0 then
      begin
        jItem2.Add('Ampl', HarmonGrid.Cells[1, i + 1]);
      end
      else
      begin
        jItem2.Add('Ampl', HarmonGrid.Cells[2 * j + 0, i + 1]);
        jItem2.Add('Phase', HarmonGrid.Cells[2 * j + 1, i + 1]);
      end;
      jArr2.AddElement(jItem2.jobj);
    end;
    jItem.Add('Harms', jArr2);

    jArr.AddElement(jItem.jobj);
  end;
  Result.Add('Signals', jArr);

  Result.Add('KanCnt', KanalCntEdit.Value);
  Result.Add('BitCnt', BitCntEdit.Value);
  Result.Add('HarmonCnt', HarmonCntEdit.Value);
  Result.Add('SampleFreq', FrequProbkEdit.Text);
  Result.Add('FreqA1', FreqA1Edit.Text);

  Result.Add('DataSize', DataSizeBox.ItemIndex);
  Result.Add('DataType', DataTypeBox.ItemIndex);
  Result.Add('SeriesType', SerieTypeBox.ItemIndex);
  Result.Add('GridColWidth', GetGridColumnWidts(HarmonGrid));

end;

procedure TWavGenForm.LoadfromJson(jParent: TJSONLoader);
var
  i, j: integer;
  s, sn: string;
  jArr: TJSONArray;
  jArr2: TJSONArray;
  jItem: TJSONLoader;
  jItem2: TJSONLoader;
begin
  inherited;

  jParent.Load('Adr', AdresBox);
  jParent.Load('Adrs', AdresBox.Items);
  jParent.Load('Size', SizeBox);
  jParent.Load('Sizes', SizeBox.Items);

  jParent.Load('KanCnt', KanalCntEdit);
  jParent.Load('BitCnt', BitCntEdit);
  jParent.Load('HarmonCnt', HarmonCntEdit);
  jParent.Load('SampleFreq', FrequProbkEdit);
  jParent.Load('FreqA1', FreqA1Edit);

  jParent.Load('DataSize', DataSizeBox);
  jParent.Load('DataType', DataTypeBox);
  jParent.Load('SeriesType', SerieTypeBox);

  SetGridColumnWidts(HarmonGrid, jParent.getDynIntArray('GridColWidth'));

  SetSeriesCount;
  PrepareHarmonGrid;

  jArr := jParent.getArray('Signals');
  if Assigned(jArr) then
  begin
    for i := 0 to jArr.Count - 1 do
    begin
      jItem.Init(jArr.Items[i]);
      SeriesListBox.Items[i] := jItem.LoadDef('Name', '');
      SeriesListBox.Checked[i] := jItem.LoadDef('Active', True);
      SeriesListBox.Items.Objects[i] := Pointer(jItem.LoadColorDef('Color', clBlack));

      jArr2 := jItem.getArray('Harms');
      if Assigned(jArr2) then
      begin
        for j := 0 to jArr2.Count - 1 do
        begin
          jItem2.Init(jArr2.Items[j]);

          if j = 0 then
          begin
            HarmonGrid.Cells[1, i + 1] := jItem2.LoadDef('Ampl', HarmonGrid.Cells[1, i + 1]);
          end
          else
          begin
            HarmonGrid.Cells[2 * j + 0, i + 1] := jItem2.LoadDef('Ampl');
            HarmonGrid.Cells[2 * j + 1, i + 1] := jItem2.LoadDef('Phase');
          end;
        end;
      end;
    end;
  end;
  // Result.Add('Signals', jArr);

  ShowCaption;
end;


procedure TWavGenForm.EditNameItemClick(Sender: TObject);
var
  s: string;
begin
  s := SeriesListBox.Items.Strings[SeriesListBox.ItemIndex];
  if InputQuery('Zmiana nazwy', 'Podaj now¹ nazwê', s) then
  begin
    SeriesListBox.Items.Strings[SeriesListBox.ItemIndex] := s;
  end;
end;

procedure TWavGenForm.EditKolorItemClick(Sender: TObject);
var
  Color: TColor;
begin
  Color := Cardinal(SeriesListBox.Items.Objects[SeriesListBox.ItemIndex]);
  ColorDialog1.Color := Color;
  if ColorDialog1.Execute then
    SeriesListBox.Items.Objects[SeriesListBox.ItemIndex] := Pointer(ColorDialog1.Color);
end;

function TWavGenForm.CheckBiPolar: boolean;
begin
  Result := (DataTypeBox.ItemIndex = 0);
end;

procedure TWavGenForm.ReadFromHarmonGrid(SygNr: integer; HarmNr: integer; var Ampl: real; var Phase: real);
var
  s: string;
begin
  try
    if HarmNr = 0 then
    begin
      s := Trim(HarmonGrid.Cells[1, SygNr + 1]);
      if s <> '' then
      begin
        Ampl := StrToFloat(s);
      end
      else
        Ampl := 0;
      Phase := 0;
    end
    else
    begin
      s := Trim(HarmonGrid.Cells[2 * HarmNr, SygNr + 1]);
      if s <> '' then
      begin
        Ampl := StrToFloat(s);
      end
      else
        Ampl := 0;

      s := Trim(HarmonGrid.Cells[2 * HarmNr + 1, SygNr + 1]);
      if s <> '' then
      begin
        Phase := StrToFloat(s);
      end
      else
        Phase := 0;
    end;
  except
    raise Exception.Create(Format('B³¹d parametru dla sygan³u %u harmoniczna %u :%s',
      [SygNr + 1, HarmNr, (ExceptObject as Exception).Message]));
  end;
end;

// Generacja danych

procedure TWavGenForm.ResolveVariables;
begin
  try
    GlFreqA1 := StrToFloat(FreqA1Edit.Text);
  except
    raise Exception.Create('¯le wprowadzona czêstotliwoœæ A1');
  end;
  try
    GlFreqProb := StrToFloat(FrequProbkEdit.Text);
  except
    raise Exception.Create('¯le wprowadzona czêstotliwoœæ próbkowania');
  end;

  case DataSizeBox.ItemIndex of
    0:
      GlDataSize := 1;
    1:
      GlDataSize := 2;
    2:
      GlDataSize := 4;
  else
    GlDataSize := 2;
  end;

  GlMemSize := MapParser.StrToAdr(SizeBox.Text);
  GlMemAdr := MapParser.StrToAdr(AdresBox.Text);
  GlKanCnt := KanalCntEdit.Value;
  GlProbCnt := GlMemSize div (GlKanCnt * GlDataSize);
  GlSerType := SerieTypeBox.ItemIndex;
  GlMax := $01 shl (BitCntEdit.Value - 1);
  SetLength(MemBuf, GlMemSize);
  GlBufRdy := True;
end;

procedure TWavGenForm.BildReakVek(SygNr: integer; var Vek: array of real);
var
  h: integer;
  Ampl: real;
  Phase: real;
  i: integer;
  Cnt: integer;
  a: real;
  Phase1: real;
  fi: real;
  w: real;
begin
  Cnt := Length(Vek);

  ReadFromHarmonGrid(SygNr, 0, Ampl, Phase);

  for i := 0 to Cnt - 1 do
    Vek[i] := Ampl;

  ReadFromHarmonGrid(SygNr, 1, Ampl, Phase1);

  for h := 1 to HarmonCntEdit.Value do
  begin
    ReadFromHarmonGrid(SygNr, h, Ampl, Phase);
    if h > 1 then
      Phase := Phase - h * Phase1;
    if Ampl <> 0 then
    begin
      fi := pi * Phase / 180;
      w := 2 * pi * h * GlFreqA1 / GlFreqProb;
      for i := 0 to Cnt - 1 do
      begin
        a := Ampl * sin(w * i - fi);
        Vek[i] := Vek[i] + a;
      end;
    end;
  end;
end;

procedure TWavGenForm.PutVekInMem(SygNr: integer; const Vek: array of real);
var
  i: integer;
  Cnt: integer;
  V: integer;
  p: pByte;
  a: real;
begin
  Cnt := Length(Vek);
  p := pByte(@MemBuf[0]);
  case GlSerType of
    0:
      inc(p, SygNr * GlDataSize); // abcabcabc
    1:
      inc(p, SygNr * GlDataSize * Cnt); // aaabbbccc
  end;

  for i := 0 To Cnt - 1 do
  begin
    a := Vek[i];
    if a > 1 then
      a := 1;
    if a < -1 then
      a := -1;
    V := round(GlMax * a);
    if V = GlMax then
      V := GlMax - 1;
    if V = -GlMax then
      V := -GlMax + 1;

    if DataTypeBox.ItemIndex = 1 then
      V := V + GlMax; // Unipolarne

    case DataSizeBox.ItemIndex of
      0:
        p^ := byte(V);
      1:
        SetWord(p, ProgCfg.ByteOrder, word(V));
      2:
        SetDWord(p, ProgCfg.ByteOrder, Cardinal(V));
    end;
    case GlSerType of
      0:
        inc(p, GlDataSize * GlKanCnt); // abcabcabc
      1:
        inc(p, GlDataSize); // aaabbbccc
    end;
  end;
end;

procedure TWavGenForm.GenerateData;
var
  n: integer;
  Vek: array of real;
begin
  inherited;
  SetLength(Vek, GlProbCnt);

  for n := 0 to GlKanCnt - 1 do
  begin
    BildReakVek(n, Vek);
    PutVekInMem(n, Vek);
  end;
end;

procedure TWavGenForm.FillWykres;
var
  i: integer;
  AnP: TAnalogPanel;
  AnS: TAnalogSerie;
begin
  Wykr.Engine.Clear;

  Wykr.Engine.Title.Clear;
  Wykr.Engine.Title.Add(Format('Czêstotliwoœæ %f Hz; Czêstotliwoœc próbkowania=%f Hz', [GlFreqA1, GlFreqProb]));
  Wykr.Engine.Title.Add(Format('Il.Próbek=%u  Max=%u', [GlProbCnt, GlMax]));

  Wykr.DtPerProbka := 1 / GlFreqProb;
  Wykr.ProbCnt := GlProbCnt;

  for i := 0 to GlKanCnt - 1 do
  begin
    AnP := Wykr.AddAnalogPanel;
    AnS := AnP.Series.CreateNew(i);
    AnS.Title := SeriesListBox.Items[i];
    AnP.Units := '';
    AnP.Mnoznik := 1;

    if CheckBiPolar then
    begin
      AnP.MaxR := 1.2 * GlMax;
      AnP.MinR := -1.2 * GlMax;
    end
    else
    begin
      AnP.MaxR := 2.2 * GlMax;
      AnP.MinR := -0.2 * GlMax;
    end;
    AnS.PenColor := TColor(SeriesListBox.Items.Objects[i]);
  end;
  Wykr.Refresh;
end;

procedure TWavGenForm.GenerBtnClick(Sender: TObject);
begin
  inherited;
  ResolveVariables;
  GenerateData;
  FillWykres;
  PageControl1.ActivePageIndex := 1;
end;

// procedure TWavGenForm.WykrGetVal(Sender: TObject; NrKan, NrPan: Byte;
// NrProb: Cardinal; var Val: Real; var Exist: Boolean);

procedure TWavGenForm.WykrGetVal(Sender: TObject; DtNr: integer; NrProb: Cardinal; var Val: double; var Exist: boolean);
var
  wsk: Cardinal;
begin
  inherited;
  if GlBufRdy then
  begin
    case GlSerType of
      0:
        wsk := Cardinal(GlDataSize) * (NrProb * Cardinal(GlKanCnt) + Cardinal(DtNr)); // abcabcabc
      1:
        wsk := Cardinal(GlDataSize) * (Cardinal(GlProbCnt) * DtNr + NrProb); // aaabbbccc
    else
      wsk := 0;
    end;
    if CheckBiPolar then
    begin
      case DataSizeBox.ItemIndex of
        0:
          Val := MemBuf[wsk];
        1:
          Val := smallInt(GetWord(@MemBuf[wsk], ProgCfg.ByteOrder));
        2:
          Val := integer(GetDWord(@MemBuf[wsk], ProgCfg.ByteOrder));
      end;
    end
    else
    begin
      case DataSizeBox.ItemIndex of
        0:
          Val := MemBuf[wsk];
        1:
          Val := GetWord(@MemBuf[wsk], ProgCfg.ByteOrder);
        2:
          Val := GetDWord(@MemBuf[wsk], ProgCfg.ByteOrder);
      end;
    end;
    Exist := True;
  end
  else
    Exist := false;

end;

procedure TWavGenForm.WrMemActExecute(Sender: TObject);
var
  PhAdr: integer;
begin
  inherited;
  if GlBufRdy then
  begin
    ResolveVariables;
    GlBufRdy := True;
    if Length(MemBuf) > 0 then
    begin
      PhAdr := GlMemAdr;
      CommThread.AddToDoItem(TWorkWrMemItem.Create(Handle, wm_WriteMem1, MemBuf[0], PhAdr, GlMemSize));
    end
    else
      DoMsg('Bufor ma dlugoœæ 0 !');
  end
  else
    DoMsg('Dane nie zainicjowane');
end;

procedure TWavGenForm.wmWriteMem1(var Msg: TMessage);
var
  item: TCommWorkItem;
begin
  item := TCommWorkItem(Msg.WParam);
  DoMsg('WriteMem=' + Dev.GetErrStr(item.Result));
  item.Free;
end;

procedure TWavGenForm.RdMemActExecute(Sender: TObject);
var
  st: TStatus;
  PhAdr: integer;
begin
  inherited;
  ResolveVariables;
  if Length(MemBuf) > 0 then
  begin
    PhAdr := GlMemAdr;
    CommThread.AddToDoItem(TWorkRdMemItem.Create(Handle, wm_ReadMem1, MemBuf[0], PhAdr, GlMemSize));
  end
  else
    DoMsg('Bufor ma dlugoœæ 0 !');
end;

procedure TWavGenForm.wmReadMem1(var Msg: TMessage);
var
  item: TCommWorkItem;
begin
  item := TCommWorkItem(Msg.WParam);
  if item.Result = stOK then
  begin
    if item.WorkTime <> 0 then
      DoMsg(Format('RdMem v=%.2f[kB/sek]', [(GlMemSize / 1024) / (item.WorkTime / 1000.0)]))
    else
      DoMsg('RdMem OK');
  end
  else
    DoMsg('ReadMem=' + Dev.GetErrStr(item.Result));
  GlBufRdy := True;
  FillWykres;
  item.Free;
end;

procedure TWavGenForm.SaveToComtradeBtn1Click(Sender: TObject);
var
  Dlg: TSaveDialog;
  Fname: string;
  ComTrade: TComTrade;
  i, j: integer;
  ADscr: TAnalogDescr;
  RDscr: TRateDescr;
  Val: double;
  Exist: boolean;
begin
  inherited;
  if GlBufRdy then
  begin
    Fname := '';
    Dlg := TSaveDialog.Create(self);
    try
      if Dlg.Execute then
        Fname := Dlg.FileName;
    finally
      Dlg.Free;
    end;
    if Fname <> '' then
    begin
      ComTrade := TComTrade.Create;
      try
        ComTrade.FileParam.Rev_Year := 1997;
        ComTrade.FileParam.Rec_Dev_Id := 'RsDebuger';
        ComTrade.FileParam.Station_Name := '';
        ComTrade.FileParam.NominalLineFreq := GlFreqA1;
        ComTrade.FileParam.StartPomTime := Now;
        ComTrade.FileParam.WzwTime := Now;
        ComTrade.FileParam.TimeStamp := 1000000 / GlFreqProb;

        RDscr := ComTrade.RateList.AddRate;
        RDscr.Freq := GlFreqProb;
        RDscr.SamplNumber := GlProbCnt;

        for i := 0 to GlKanCnt - 1 do
        begin
          if GlDataSize = 4 then
            ADscr := ComTrade.AnList.AddSyg(mmINT32)
          else
            ADscr := ComTrade.AnList.AddSyg(mmINT16);
          ADscr.Multipl := 1;
          if CheckBiPolar then
          begin
            ADscr.RangMin := -GlMax;
            ADscr.RangMax := GlMax;
            ADscr.Offset := 0;
          end
          else
          begin
            ADscr.RangMin := 0;
            ADscr.RangMin := 2 * GlMax;
            ADscr.Offset := GlMax;
          end;
          ADscr.PenColor := TColor(SeriesListBox.Items.Objects[i]);
          ADscr.Name := SeriesListBox.Items[i];
        end;
        ComTrade.BuffSize := GlProbCnt;
        for i := 0 to GlKanCnt - 1 do
        begin
          ADscr := ComTrade.AnList.Items[i];
          for j := 0 to GlProbCnt - 1 do
          begin
            WykrGetVal(nil, i, j, Val, Exist);
            if Exist then
            begin
              ADscr.Value[j] := Val;
            end;
          end;
        end;
        ComTrade.SaveToFile(Fname, false, fmASCII, false);
      finally
        ComTrade.Free;
      end;
    end;
  end
  else
    DoMsg('Dane nie zainicjowane');
end;

end.
