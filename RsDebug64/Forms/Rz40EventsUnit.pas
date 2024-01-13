unit Rz40EventsUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ImgList, ActnList, ExtCtrls, StdCtrls, ComCtrls,
  ToolWin,
  Contnrs,
  ProgCfgUnit,
  ToolsUnit,
  RsdDll,
  Rsd64Definitions,
  CrcUnit, System.ImageList, System.Actions,
  System.JSON,
  JSonUtils,
  ErrorDefUnit;

const
  EV_IN_PACK = 15;

type
  PRZ40Event = ^TRZ40Event;

  TRZ40Event = packed record
    EvNr: cardinal;
    rk: byte;
    ms: byte;
    dz: byte;
    gd: byte;
    mn: byte;
    sc: byte;
    ml: word;
    Code: word;
    Suma: word;
  end;

  TRZ40RdEvents = packed record
    CurrEventNr: cardinal;
    evTab: array [0 .. EV_IN_PACK - 1] of TRZ40Event;
  end;

  TEventDef = class(TObject)
    Code: integer;
    Text: string;
    Adds: string;
    function LoadFromTxt(txt: string): boolean;
    function ToText: string;
    function EventText: string;
  end;

  TEventDefList = class(TObjectList)
    function getItems(Index: integer): TEventDef;
    property Items[Index: integer]: TEventDef read getItems;
    function FindDef(aCode: integer): TEventDef;
    procedure LoadFromEtManagerDeffile(FName: string);
    procedure DumpToStrings(Sl: TStrings);
    function GetEventText(aCode: integer): string;
  end;

  TRz40EventsForm = class(TChildForm)
    Memo: TMemo;
    ToolButton1: TToolButton;
    actReadEvents: TAction;
    Label5: TLabel;
    AutoRepTmEdit: TComboBox;
    EvNrEdit: TLabeledEdit;
    RepeatReadTimer: TTimer;
    ToolButton2: TToolButton;
    actLoadEvDef: TAction;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    actShowEvendsDef: TAction;
    ToolButton6: TToolButton;
    actClearMemo: TAction;
    ReadRepeatBtn: TToolButton;
    actReadRepeat: TAction;
    procedure actReadEventsExecute(Sender: TObject);
    procedure actLoadEvDefExecute(Sender: TObject);
    procedure actShowEvendsDefExecute(Sender: TObject);
    procedure actClearMemoExecute(Sender: TObject);
    procedure actReadRepeatExecute(Sender: TObject);
    procedure actReadEventsUpdate(Sender: TObject);
    procedure RepeatReadTimerTimer(Sender: TObject);
  private
    mEventDefFName: string;
    EventDefList: TEventDefList;
    procedure ReadEvents;
  protected
    function GetDefaultCaption: string; override;
  public
    constructor CreateIterf(AMainWinInterf: IMainWinInterf; AOwner: TComponent; TemplateWin: TChildForm);
    destructor Destroy; override;

    function GetJSONObject: TJSONBuilder; override;
    procedure LoadfromJson(jParent: TJSONLoader); override;
  end;

implementation

{$R *.dfm}
// 000000000111111111122222222223333333333444444444455555555556666666
// 123456789012345678901234567890123456789012345678901234567890123456
// 7918 : Power supply                                       Failure

function TEventDef.LoadFromTxt(txt: string): boolean;
begin
  Result := false;
  if TryStrToInt('$' + copy(txt, 1, 4), Code) then
  begin
    if txt[6] = ':' then
    begin
      Text := '';
      Adds := '';
      if Length(txt) > 8 then
      begin
        if Length(txt) >= 59 then
        begin
          Text := Trim(copy(txt, 8, 59 - 8));
          Adds := Trim(copy(txt, 59, Length(txt) - 59 + 1));
        end
        else
        begin
          Text := Trim(copy(txt, 8, Length(txt) - 8 + 1));
        end;
      end;
      Result := true;
    end;
  end;
end;

function TEventDef.EventText: string;
begin
  Result := Text;
  if Adds <> '' then
    Result := Result + '|' + Adds;
end;

function TEventDef.ToText: string;
begin
  Result := Format('%6u : %s', [Code, Text]);
  if Adds <> '' then
  begin
    Result := Result + '|' + Adds;

  end;
end;

function TEventDefList.getItems(Index: integer): TEventDef;
begin
  Result := inherited GetItem(Index) as TEventDef;
end;

function TEventDefList.FindDef(aCode: integer): TEventDef;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].Code = aCode then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

procedure TEventDefList.LoadFromEtManagerDeffile(FName: string);
var
  Sl: TStringList;
  i: integer;
  item: TEventDef;
begin
  Clear;
  Sl := TStringList.Create;
  try
    Sl.LoadFromFile(FName);
    for i := 0 to Sl.Count - 1 do
    begin
      item := TEventDef.Create;
      if item.LoadFromTxt(Sl.Strings[i]) then
        Add(item)
      else
        item.Free;
    end;
  finally
    Sl.Free;
  end;
end;

function TEventDefList.GetEventText(aCode: integer): string;
var
  item: TEventDef;
begin
  Result := '';
  item := FindDef(aCode);
  if Assigned(item) then
    Result := item.EventText;
end;

procedure TEventDefList.DumpToStrings(Sl: TStrings);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Sl.Add(Items[i].ToText);
end;

// --------------------------------------------------------
constructor TRz40EventsForm.CreateIterf(AMainWinInterf: IMainWinInterf; AOwner: TComponent; TemplateWin: TChildForm);
begin
  inherited;
  EventDefList := TEventDefList.Create;
end;

destructor TRz40EventsForm.Destroy;
begin
  inherited;
  EventDefList.Free;
end;

function TRz40EventsForm.GetDefaultCaption: string;
begin
  Result := 'RZ40Events';
end;

function TRz40EventsForm.GetJSONObject: TJSONBuilder;
begin
  Result := inherited GetJSONObject;
  Result.Add('EventDefFile', mEventDefFName);
end;

procedure TRz40EventsForm.LoadfromJson(jParent: TJSONLoader);
begin
  inherited;
  jParent.Load('EventDefFile', mEventDefFName);
end;

const
  RZ40_RD_EV_ADR = 220 + 1;
  RZ40_WR_EV_ADR = 200 + 1;

procedure TRz40EventsForm.ReadEvents;
  function D2Swap(W: cardinal): cardinal;
  begin
    Result := ((W shr 16) and $FFFF) or ((W and $FFFF) shl 16)
  end;

  function CheckAndSwapEv(var Ev: TRZ40Event): boolean;
  var
    i: integer;
    pw: PWORD;
    tabW: array [0 .. 7] of word;
    pEv: PRZ40Event;
  begin
    pw := PWORD(@Ev);
    for i := 0 to 7 do
    begin
      tabW[i] := Swap(pw^);
      inc(pw);
    end;

    Result := Tcrc.CheckCRC(tabW, sizeof(tabW));
    if Result then
    begin
      pEv := PRZ40Event(@tabW[0]);
      Ev.EvNr := DSwap(pEv.EvNr);
      Ev.rk := pEv.rk;
      Ev.ms := pEv.ms;
      Ev.dz := pEv.dz;
      Ev.gd := pEv.gd;
      Ev.mn := pEv.mn;
      Ev.sc := pEv.sc;
      Ev.ml := Swap(pEv.ml);
      Ev.Code := Swap(pEv.Code);
      Ev.Suma := Swap(pEv.Suma);

    end;
  end;
  function EventAsTxt(const Ev: TRZ40Event): string;
  begin
    Result := Format('%7u %.4u.%.2u.%.2u %.2u:%.2u:%.2u,%.4u  Cd=%u', [Ev.EvNr, Ev.rk, Ev.ms, Ev.dz, Ev.gd, Ev.mn,
      Ev.sc, Ev.ml, Ev.Code]);
  end;

var
  st: TStatus;
  WrEv: TRZ40Event;
  RdEv: TRZ40RdEvents;
  nW, nR: integer;
  i: integer;
  s: string;

begin
  nW := sizeof(WrEv) div 2;
  nR := sizeof(RdEv) div 2;

  WrEv.EvNr := D2Swap(StrToInt(EvNrEdit.Text));
  st := Dev.ReadWriteRegs(Handle, RdEv, RZ40_RD_EV_ADR, nR, WrEv, RZ40_WR_EV_ADR, nW);
  if st = stOk then
  begin
    for i := 0 to EV_IN_PACK - 1 do
    begin
      if CheckAndSwapEv(RdEv.evTab[i]) then
      begin
        s := EventAsTxt(RdEv.evTab[i]);
        s := s + '  ' + EventDefList.GetEventText(RdEv.evTab[i].Code);
        Memo.Lines.Add(s);
        EvNrEdit.Text := INtToStr(RdEv.evTab[i].EvNr);
      end;
    end;
  end
  else
  begin
    if st <> 32 + 5 then
    begin
      DoMsg('Reading..' + Dev.GetErrStr(st));
      RepeatReadTimer.Enabled := false;
      ReadRepeatBtn.Down := false;
    end;
  end;
end;

procedure TRz40EventsForm.actLoadEvDefExecute(Sender: TObject);
var
  Dlg: TOpenDialog;

begin
  inherited;
  Dlg := TOpenDialog.Create(self);
  try
    if Dlg.Execute then
    begin
      mEventDefFName := Dlg.FileName;
      EventDefList.LoadFromEtManagerDeffile(mEventDefFName);
    end;

  finally
    Dlg.Free;
  end;

end;

procedure TRz40EventsForm.actShowEvendsDefExecute(Sender: TObject);
begin
  inherited;
  Memo.Lines.Clear;
  EventDefList.DumpToStrings(Memo.Lines);

end;

procedure TRz40EventsForm.actClearMemoExecute(Sender: TObject);
begin
  inherited;
  Memo.Lines.Clear;
end;

procedure TRz40EventsForm.actReadRepeatExecute(Sender: TObject);
begin
  inherited;
  RepeatReadTimer.Interval := StrToInt(AutoRepTmEdit.Text);
  RepeatReadTimer.Enabled := ReadRepeatBtn.Down;
end;

procedure TRz40EventsForm.actReadEventsExecute(Sender: TObject);
begin
  inherited;
  ReadEvents;
end;

procedure TRz40EventsForm.actReadEventsUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := isDevConnected;
end;

procedure TRz40EventsForm.RepeatReadTimerTimer(Sender: TObject);
begin
  inherited;
  ReadEvents;
end;

end.
