unit ExtG2MemoUnit;

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Contnrs, StdCtrls, ComCtrls,
  ExtCtrls, Graphics, Menus, Buttons, Dialogs, RichEdit, System.UITypes;

const

  wm_VisChanged = wm_User + 0;
  wm_DataToStrm = wm_User + 1;

type
  // definicja priorytetów nadsy³anych Message;
  TMsgPriority = (prNODEF, prINFO, prWARNING, prERROR);

  TColorScheme = record
    BackGround: TColor;
    MsgColor: array [TMsgPriority] of TColor;
  end;

const
  ColorSchemeWhite: TColorScheme = (BackGround: clWhite; MsgColor: (clBlack, clGreen, clBlue, clRed););
  ColorSchemeBlue: TColorScheme = (BackGround: clBlue; MsgColor: (clWhite, clLime, TColors.Orange, clRed););

type
  TOnVisChange = procedure(Sender: TObject; AVisible: boolean) of object;
  TExtG2Memo = class;

  TCircularBuffer = class(TObject)
  private
    MemBuf: array of byte;
    HeadPtr: integer;
    TailPtr: integer;
    FMemSize: integer;
    FLock: TRTLCriticalSection;
  public
    constructor Create(Size: integer); reintroduce;
    destructor Destroy; override;
    procedure PushBuf(const Buf; Size: integer);
    function GetBuf(var Buf; Size: integer): integer;
    procedure Clear;
  end;

  TPipeRider = class(TThread)
  private
    FOwner: TExtG2Memo;
    PipeOut: THandle; // handle do odczytu rurki
    PipeIn: THandle; // handle do zapisu otwartej rurki
    function ReadPipe: boolean;
  public
    constructor Create(AOwner: TExtG2Memo);
    destructor Destroy; override;
    procedure Execute; override;
  end;

  TExtG2Memo = class(TPanel) // TCustomPanel)
  private
    LPanel: TPanel;
    REdit: TRichEdit;
    LogBtn: TSpeedButton;
    ScrollBtn: TSpeedButton;
    LogTimer: TTimer;
    FPipeIn: THandle;
    ColorScheme: TColorScheme;
    FTerminalKeyPressEvent: TKeyPressEvent;

    ApendToLine: boolean; // w MEMO twórz now¹ liniê
    WasSlash: boolean; // by³ slash

    BtnTop: integer;
    BtnList: TobjectList;
    FOnVisChange: TOnVisChange;
    FLogFileName: string;
    FLogging: boolean;
    FLogWork: boolean;
    FMaxLogFileSize: integer;
    FLogHistoryDeep: integer;
    LogFile: TextFile;
    LogFileBin: File of byte;
    PipeRider: TPipeRider;
    FAutoShow: boolean;
    FFlat: boolean;
    FDetectSlash: boolean;
    procedure OnHideProc(Sender: TObject);
    procedure OnClearProc(Sender: TObject);
    procedure OnLogChange(Sender: TObject);
    procedure OnScrollChange(Sender: TObject);

    procedure OnEditFontProc(Sender: TObject);
    procedure OnFontApplyProc(Sender: TObject; Wnd: HWND);
    procedure DelFromMemo;
    procedure wmVisChanged(var Message: TMessage); message wm_VisChanged;
    procedure wmDataToStrm(var Message: TMessage); message wm_DataToStrm;
    procedure REditCopyProc(Sender: TObject);
    procedure REditSelectAllProc(Sender: TObject);
    procedure FSetOnLogging(ALogging: boolean);
    function GetLogName(nr: integer): string;
    procedure StartLogFile;
    procedure StopLogFile;
    procedure AddToLog(s: string; AddEOL: boolean);
    procedure TimeToLog;
    procedure LogTimerProc(Sender: TObject);
    procedure FSetFlat(AFlat: boolean);
    procedure REditOnKeyPressProc(Sender: TObject; var Key: Char);

  protected
    CircularBuffer: TCircularBuffer;
    FReady: boolean;
    procedure VisibleChanging; override;
    function GetToolBoxFontColor: TColor;
    procedure SetToolBoxFontColor(NewColor: TColor);
    procedure WndProc(var Message: TMessage); override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddBtn(capt: string; AHint: string; OnClickProc: TNotifyEvent): TSpeedButton;
    procedure ScrollToEnd;
    procedure SetCharSet;
    procedure ScrollToTop;
    procedure ADL(s: string);
    procedure AddStrings(SL: TStrings);
    procedure AddInfoTxt(Prio: TMsgPriority; txt: string);
    procedure Print(s: string);
    procedure PrintToPipe(s: string);
    procedure PrintHd(s: string);
    property PipeInHandle: THandle read FPipeIn;
    procedure Clear;
    procedure SetColorScheme(aColorScheme: TColorScheme);
    property ToolboxFontColor: TColor read GetToolBoxFontColor write SetToolBoxFontColor;

  published
    property OnVisChange: TOnVisChange read FOnVisChange write FOnVisChange;
    property LogFileName: string read FLogFileName write FLogFileName;
    property Logging: boolean read FLogging write FSetOnLogging;
    property MaxLogFileSize: integer read FMaxLogFileSize write FMaxLogFileSize;
    property LogHistoryDeep: integer read FLogHistoryDeep write FLogHistoryDeep;
    property AutoShow: boolean read FAutoShow write FAutoShow;
    property Flat: boolean read FFlat write FSetFlat;
    property TerminalKeyPressEvent: TKeyPressEvent read FTerminalKeyPressEvent write FTerminalKeyPressEvent;
    property DetectSlash: boolean read FDetectSlash write FDetectSlash;
  end;

implementation

uses
  Math;

constructor TCircularBuffer.Create(Size: integer);
begin
  inherited Create;
  SetLength(MemBuf, Size);
  InitializeCriticalSection(FLock);
  HeadPtr := 0;
  TailPtr := 0;
  FMemSize := Size;
end;

destructor TCircularBuffer.Destroy;
begin
  DeleteCriticalSection(FLock);
  SetLength(MemBuf, 0);
  inherited;
end;

procedure TCircularBuffer.Clear;
begin
  HeadPtr := 0;
  TailPtr := 0;
end;

procedure TCircularBuffer.PushBuf(const Buf; Size: integer);
var
  sz: integer;
  Free: integer;
  pCh: pchar;
begin
  pCh := pchar(@Buf);

  EnterCriticalSection(FLock);
  try
    if Size > FMemSize then
    begin
      Size := FMemSize;
      inc(pCh, Size - FMemSize);
    end;

    if HeadPtr + Size < FMemSize then
    begin
      Move(pCh^, MemBuf[HeadPtr], Size);
    end
    else
    begin
      sz := FMemSize - HeadPtr;
      Move(pCh^, MemBuf[HeadPtr], sz);
      inc(pCh, sz);
      Move(pCh^, MemBuf[0], Size - sz);
    end;
    Free := (TailPtr - HeadPtr + FMemSize) mod FMemSize;
    if Free = 0 then
      Free := FMemSize;
    HeadPtr := (HeadPtr + Size) mod FMemSize;
    // jeœli by³o mniej wolnego miejsca niz dane
    if Free <= Size then
      TailPtr := (HeadPtr + 1) mod FMemSize;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

function TCircularBuffer.GetBuf(var Buf; Size: integer): integer;
var
  sz: integer;
  Acp: integer;
  pCh: pchar;
begin
  pCh := pchar(@Buf);
  EnterCriticalSection(FLock);
  try
    if HeadPtr <> TailPtr then
    begin
      Acp := (HeadPtr - TailPtr + FMemSize) mod FMemSize;
      if Acp > Size then
        Acp := Size;
      if TailPtr + Acp < FMemSize then
      begin
        Move(MemBuf[TailPtr], pCh^, Acp);
      end
      else
      begin
        sz := FMemSize - TailPtr;
        Move(MemBuf[TailPtr], pCh^, sz);
        inc(pCh, sz);
        Move(MemBuf[0], pCh^, Size - sz);
      end;
      TailPtr := (TailPtr + Acp) mod FMemSize;
      Result := Acp;
    end
    else
      Result := 0;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

constructor TPipeRider.Create(AOwner: TExtG2Memo);
var
  SecurityAttributes: TSecurityAttributes;
begin
  inherited Create(true);
  FOwner := AOwner;
  FillChar(SecurityAttributes, SizeOf(SecurityAttributes), 0);
  with SecurityAttributes do
  begin
    nLength := SizeOf(SecurityAttributes);
    bInheritHandle := true;
  end;
  CreatePipe(PipeOut, PipeIn, @SecurityAttributes, 100000);
  FOwner.FPipeIn := PipeIn;
  Resume;
end;

destructor TPipeRider.Destroy;
begin
  CloseHandle(PipeIn);
  inherited;
end;

function TPipeRider.ReadPipe: boolean;
var
  BytesRead: Cardinal;
  Buf: array [0 .. $FF] of Char;
begin
  Result := false;
  if ReadFile(PipeOut, Buf[0], SizeOf(Buf), BytesRead, nil) then
  begin
    if BytesRead > 0 then
    begin
      FOwner.CircularBuffer.PushBuf(Buf, BytesRead);
    end;
    Result := (BytesRead <> 0);
  end;
end;

procedure TPipeRider.Execute;
begin
  while not(Terminated) do
  begin
    if ReadPipe then
    begin
      if FOwner.FReady then
        PostMessage(FOwner.Handle, wm_DataToStrm, 0, 0);
    end
    else
      sleep(200);
  end;
  CloseHandle(PipeOut);
end;

constructor TExtG2Memo.Create(AOwner: TComponent);
var
  Menu: TPopUpMenu;
  MItem: TMenuItem;
begin
  inherited Create(AOwner);
  FReady := false;
  FTerminalKeyPressEvent := nil;
  FDetectSlash := true;
  CircularBuffer := TCircularBuffer.Create(32 * 2048);

  BevelInner := bvRaised;
  BevelOuter := bvNone;
  FLogging := false;
  WasSlash := false;

  FLogFileName := ChangeFileExt(ParamStr(0), '.log');
  BtnTop := 4;
  FMaxLogFileSize := 500000;
  FLogHistoryDeep := 3;
  BtnList := TobjectList.Create;
  LPanel := TPanel.Create(self);
  LPanel.Parent := self;
  LPanel.Align := alLeft;
  LPanel.Width := 24;
  LPanel.BevelInner := bvNone;
  LPanel.BevelOuter := bvNone;
  LPanel.Caption := '';
  AddBtn('C', 'Clear', OnClearProc);
  LogBtn := AddBtn('L', 'Save memo to log file', OnLogChange);
  LogBtn.AllowAllUp := true;
  LogBtn.GroupIndex := 1;

  ScrollBtn := AddBtn('S', 'Scroll to end', OnScrollChange);
  ScrollBtn.AllowAllUp := true;
  ScrollBtn.GroupIndex := 2;
  ScrollBtn.Down := true;


  Menu := TPopUpMenu.Create(self);

  MItem := TMenuItem.Create(Menu);
  MItem.Caption := 'Copy';
  MItem.ShortCut := ShortCut(Word('C'), [ssCtrl]);
  MItem.OnClick := REditCopyProc;
  Menu.Items.Add(MItem);

  MItem := TMenuItem.Create(Menu);
  MItem.Caption := 'Select all';
  MItem.ShortCut := ShortCut(Word('A'), [ssCtrl]);
  MItem.OnClick := REditSelectAllProc;
  Menu.Items.Add(MItem);

  MItem := TMenuItem.Create(Menu);
  MItem.Caption := 'Clear';
  MItem.ShortCut := ShortCut(Word('X'), [ssCtrl]);
  MItem.OnClick := OnClearProc;
  Menu.Items.Add(MItem);

  MItem := TMenuItem.Create(Menu);
  MItem.Caption := 'Fonts';
  MItem.ShortCut := ShortCut(Word('F'), [ssCtrl]);
  MItem.OnClick := OnEditFontProc;
  Menu.Items.Add(MItem);

  REdit := TRichEdit.Create(self);
  REdit.Parent := self;
  REdit.Align := alClient;
  REdit.ScrollBars := ssVertical;
  REdit.Font.Name := 'Courier';
  REdit.Font.Size := 10;

  REdit.ReadOnly := true;
  REdit.TabStop := false;
  REdit.PopupMenu := Menu;
  REdit.BevelInner := bvNone;
  REdit.BevelOuter := bvNone;
  REdit.OnKeyPress := REditOnKeyPressProc;

  // GKania - nie rób takich numerów wlasnie tutaj
  // SetCharSet;

  LogTimer := TTimer.Create(self);
  LogTimer.Enabled := true;
  LogTimer.Interval := 5000;
  LogTimer.OnTimer := LogTimerProc;

  PipeRider := TPipeRider.Create(self);
  ColorScheme := ColorSchemeWhite;
end;

destructor TExtG2Memo.Destroy;
begin
  StopLogFile;
  PipeRider.Free;
  CircularBuffer.Free;
  BtnList.Free;
  inherited;
end;

procedure TExtG2Memo.WndProc(var Message: TMessage);
var
  VisibleChanged: boolean;
begin
  VisibleChanged := false;

  Case Message.Msg of
    CM_SHOWINGCHANGED:
      VisibleChanged := true;
  end;

  Inherited WndProc(Message);

  if VisibleChanged and not FReady then
  begin
    FReady := true;
    SetCharSet;
  end;
end;

procedure TExtG2Memo.SetParent(AParent: TWinControl);
begin
  inherited;
end;

function TExtG2Memo.AddBtn(capt: string; AHint: string; OnClickProc: TNotifyEvent): TSpeedButton;
begin
  Result := TSpeedButton.Create(self);
  Result.Parent := LPanel;
  Result.Height := 18;
  Result.Width := 18;
  Result.Left := 3;
  Result.Top := BtnTop;
  Result.Caption := capt;
  Result.Flat := FFlat;
  inc(BtnTop, 20);
  Result.OnClick := OnClickProc;
  Result.Hint := AHint;
  Result.ShowHint := (AHint <> '');
  BtnList.Add(Result);
end;

procedure TExtG2Memo.FSetFlat(AFlat: boolean);
var
  i: integer;
begin
  FFlat := AFlat;
  for i := 0 to BtnList.Count - 1 do
  begin
    (BtnList.Items[i] as TSpeedButton).Flat := FFlat;
  end;
end;

procedure TExtG2Memo.VisibleChanging;
begin
  PostMessage(self.Handle, wm_VisChanged, 0, 0);
end;

function TExtG2Memo.GetToolBoxFontColor: TColor;
var
  i: integer;
begin
  Result := clGreen;
  for i := 0 to BtnList.Count - 1 do
  begin
    Result := (BtnList[i] as TSpeedButton).Font.Color;
    exit;
  end;
end;

procedure TExtG2Memo.SetToolBoxFontColor(NewColor: TColor);
var
  i: integer;
begin
  for i := 0 to BtnList.Count - 1 do
  begin
    (BtnList[i] as TSpeedButton).Font.Color := NewColor;
  end;
end;

procedure TExtG2Memo.wmVisChanged(var Message: TMessage);
begin
  if Assigned(FOnVisChange) then
    FOnVisChange(self, Visible);
  LogBtn.Down := FLogging;
end;

procedure TExtG2Memo.REditOnKeyPressProc(Sender: TObject; var Key: Char);
begin
  if Assigned(FTerminalKeyPressEvent) then
    FTerminalKeyPressEvent(self, Key);
end;

procedure TExtG2Memo.wmDataToStrm(var Message: TMessage);
var
  s: string;
  Rd: integer;
begin
  try

    repeat
      SetLength(s, 200);
      Rd := CircularBuffer.GetBuf(s[1], length(s));    // Rd- size in bytes
      if Rd > 0 then
      begin
        SetLength(s, Rd div SizeOf(Char));  // SizeOf(Char) =? 2 -> WideChar
        Print(s);
      end;
    until Rd <= 0;

  except
{$IFDEF WinDebug}
    OutputDebugString(pchar('Exception in TTExtG2Memo.wmDataToStrm:' + (ExceptObject as Exception).Message));
    OutputDebugString(PAnsiChar(Format('The invalid string length was: %d; hexdump:', [length(s)])));
    OutputDebugString(PAnsiChar(BinToHexString(PAnsiChar(s), Min(length(s), 100))));
{$ENDIF}
    try
      CircularBuffer.Clear;
    except
    end;
  end;
end;

procedure TExtG2Memo.OnHideProc(Sender: TObject);
begin
  Visible := false;
end;

procedure TExtG2Memo.OnClearProc(Sender: TObject);
begin
  REdit.Clear;
end;

procedure TExtG2Memo.OnLogChange(Sender: TObject);
begin
  FSetOnLogging((Sender as TSpeedButton).Down);
end;

procedure TExtG2Memo.OnScrollChange(Sender: TObject);
begin
  ScrollToEnd;
end;


procedure TExtG2Memo.REditCopyProc(Sender: TObject);
begin
  REdit.CopyToClipboard;
end;

procedure TExtG2Memo.REditSelectAllProc(Sender: TObject);
begin
  REdit.SelectAll;
end;

procedure TExtG2Memo.OnFontApplyProc(Sender: TObject; Wnd: HWND);
var
  Dlg: TFontDialog;
begin
  Dlg := Sender as TFontDialog;
  if REdit.SelLength > 0 then
  begin
    REdit.SelAttributes.Name := Dlg.Font.Name;
    REdit.SelAttributes.Color := Dlg.Font.Color;
    REdit.SelAttributes.Style := Dlg.Font.Style;
    REdit.SelAttributes.Height := Dlg.Font.Height;
    REdit.SelAttributes.Size := Dlg.Font.Size;
  end
  else
  begin
    REdit.Font := Dlg.Font;
  end;
end;

procedure TExtG2Memo.OnEditFontProc(Sender: TObject);
var
  Dlg: TFontDialog;
begin
  Dlg := TFontDialog.Create(self);
  try
    Dlg.OnApply := OnFontApplyProc;
    if REdit.SelLength > 0 then
    begin
      Dlg.Font.Name := REdit.SelAttributes.Name;
      Dlg.Font.Color := REdit.SelAttributes.Color;
      Dlg.Font.Style := REdit.SelAttributes.Style;
      Dlg.Font.Height := REdit.SelAttributes.Height;
      Dlg.Font.Size := REdit.SelAttributes.Size;
    end
    else
    begin
      Dlg.Font := REdit.Font;
    end;

    if Dlg.Execute then
    begin
      OnFontApplyProc(Dlg, Dlg.Handle);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TExtG2Memo.SetCharSet;
const
  IMF_UIFONTS = $0020;
  // var
  // W : cardinal;
begin
  // W := SendMessage(REdit.Handle, EM_GETLANGOPTIONS, 0, 0);
  SendMessage(REdit.Handle, EM_SETLANGOPTIONS, 0, 0); // IMF_UIFONTS);
end;

procedure TExtG2Memo.ScrollToEnd;
begin
  if FReady and ScrollBtn.Down then
  begin
    SendMessage(REdit.Handle, WM_VSCROLL, SB_BOTTOM, 0);
    if Win32Platform = VER_PLATFORM_WIN32_WINDOWS then
    begin
      SendMessage(REdit.Handle, WM_VSCROLL, SB_PAGEUP, 0);
    end;
    if FAutoShow and not(Visible) then
      Visible := true;
  end;
end;

procedure TExtG2Memo.ScrollToTop;
begin
  SendMessage(REdit.Handle, WM_VSCROLL, SB_TOP, 0);
  if FAutoShow and not(Visible) then
    Visible := true;
end;

procedure TExtG2Memo.SetColorScheme(aColorScheme: TColorScheme);
begin
  ColorScheme := aColorScheme;
  REdit.Color := ColorScheme.BackGround;
  REdit.Font.Color := ColorScheme.MsgColor[prNODEF];
end;

procedure TExtG2Memo.Clear;
begin
  CircularBuffer.Clear;
  REdit.Clear;
end;

procedure TExtG2Memo.DelFromMemo;
var
  i: integer;
  N: integer;
begin
  N := REdit.Lines.Count;
  if N > 5000 then
  begin
    REdit.Lines.BeginUpdate;
    try
      for i := 1 to 20 do
        REdit.Lines.Delete(0);
    finally
      REdit.Lines.EndUpdate;
    end;
  end;
end;

procedure TExtG2Memo.ADL(s: string);
begin
  DelFromMemo;
  if ApendToLine and (REdit.Lines.Count <> 0) then
  begin
    REdit.Lines.Strings[REdit.Lines.Count - 1] := REdit.Lines.Strings[REdit.Lines.Count - 1] + s;
    AddToLog(s, false);
  end
  else
  begin
    REdit.Lines.Add(s);
    AddToLog(s, true);
  end;
  ApendToLine := false;
  ScrollToEnd;
end;

procedure TExtG2Memo.AddStrings(SL: TStrings);
var
  i: integer;
begin
  for i := 0 to SL.Count - 1 do
  begin
    ADL(SL.Strings[i]);
  end;
  ScrollToEnd;
end;

procedure TExtG2Memo.AddInfoTxt(Prio: TMsgPriority; txt: string);
var
  i: integer;
begin
  REdit.SelAttributes.Color := ColorScheme.MsgColor[Prio];
  case Prio of
    prNODEF:
      begin
        REdit.SelAttributes.Style := [];
      end;
    prINFO:
      begin
        REdit.SelAttributes.Style := [];
      end;
    prWARNING:
      begin
        REdit.SelAttributes.Style := [];
      end;
    prERROR:
      begin
        Visible := true;
        REdit.SelAttributes.Style := [fsBold];
      end;
  end;
  for i := 1 to length(txt) do
  begin
    if ord(txt[i]) < $20 then
      txt[i] := '.';
  end;
  ADL(txt);
end;

procedure TExtG2Memo.PrintToPipe(s: string);
var
  M: Cardinal;
begin
  if (FPipeIn <> INVALID_HANDLE_VALUE) and (length(s) > 0) then
  begin
    Windows.WriteFile(FPipeIn, s[1], length(s), M, nil);
  end;
end;

procedure TExtG2Memo.Print(s: string);
var
  i, L: integer;
  s1: string;
  Prio: TMsgPriority;
begin
  // zabezpieczenie przed wysy³aniem komunikatów, zanim kontrolka bêdzie gotowa
  if Not FReady then
    exit;
  s1 := '';
  REdit.Lines.BeginUpdate;
  try
    L := length(s);
    // s[1]:='*';
    i := 1;
    Prio := prNODEF;
    while i <= L do
    begin
      if FDetectSlash then
      begin
        if WasSlash then
        begin
          case s[i] of
            'n':
              begin
                AddInfoTxt(Prio, s1);
                s1 := '';
                Prio := prNODEF;
              end;
            'e':
              Prio := prERROR;
            'w':
              Prio := prWARNING;
            'i':
              Prio := prINFO;
            '\':
              s1 := s1 + s[i];
          else
            s1 := s1 + '\';
            s1 := s1 + s[i];
          end;
          WasSlash := false;
        end
        else
        begin
          case s[i] of
            '\':
              WasSlash := true;
            #13:
              ;
            #10:
              begin
                AddInfoTxt(Prio, s1);
                s1 := '';
                Prio := prNODEF;
              end;
          else
            s1 := s1 + s[i];
          end
        end;
      end
      else
      begin
        case s[i] of
          #1:
            Prio := prINFO;
          #2:
            Prio := prWARNING;
          #3:
            Prio := prERROR;
          #13:
            ;
          #10:
            begin
              AddInfoTxt(Prio, s1);
              s1 := '';
              Prio := prNODEF;
            end;
        else
          s1 := s1 + s[i];
        end

      end;

      inc(i);
    end;
    if s1 <> '' then
    begin
      AddInfoTxt(Prio, s1);
      ApendToLine := true;
    end;
  finally
    DelFromMemo;
    REdit.Lines.EndUpdate;
    ScrollToEnd;
  end;

end;

procedure TExtG2Memo.PrintHd(s: string);
var
  i, L: integer;
  s1: string;
begin

  REdit.Lines.BeginUpdate;
  try
    L := length(s);
    i := 1;
    while i <= L do
    begin
      case s[i] of
        #13:
          ;
        #10:
          begin
            AddInfoTxt(prNODEF, s1);
            s1 := '';
          end;
      else
        s1 := s1 + s[i];
      end;
      inc(i);
    end;
    if s1 <> '' then
    begin
      AddInfoTxt(prNODEF, s1);
      ApendToLine := true;
    end;

  finally
    REdit.Lines.EndUpdate;
    DelFromMemo;
    ScrollToEnd;
  end;
end;

function TExtG2Memo.GetLogName(nr: integer): string;
begin
  Result := FLogFileName;
  if nr > 0 then
    Result := ChangeFileExt(Result, '.bk' + IntToStr(nr));
end;

procedure TExtG2Memo.TimeToLog;
begin
  Write(LogFile, DateTimeToStr(Now) + '  ');
end;

procedure TExtG2Memo.AddToLog(s: string; AddEOL: boolean);
var
  FSize: integer;
  i: integer;
begin
  if FLogWork then
  begin
    if AddEOL then
      Writeln(LogFile);

    TimeToLog;
    Write(LogFile, s);

    FSize := FileSize(LogFileBin);
    if FSize > FMaxLogFileSize then
    begin
      StopLogFile;
      try
        if FileExists(GetLogName(FLogHistoryDeep)) then
          DeleteFile(pchar(GetLogName(FLogHistoryDeep)));
        for i := FLogHistoryDeep downto 1 do
        begin
          RenameFile(GetLogName(i - 1), GetLogName(i));
        end;
      finally
        StartLogFile;
      end;
    end;
  end;
end;

procedure TExtG2Memo.StartLogFile;
var
  Path: string;
begin
  FLogWork := false;
  try
    if FLogFileName <> '' then
    begin
      Path := ExtractFilePath(LogFileName);
      if not(DirectoryExists(Path)) then
        ForceDirectories(Path);
      AssignFile(LogFile, FLogFileName);
      FileMode := fmOpenReadWrite;
      if FileExists(FLogFileName) then
      begin
        Append(LogFile);
        Writeln(LogFile);
        Writeln(LogFile);
        write(LogFile, '-------------------------------------------------------');
      end
      else
      begin
        Rewrite(LogFile);
      end;
      FileMode := fmOpenRead;
      AssignFile(LogFileBin, FLogFileName);
      Reset(LogFileBin);
      FLogWork := true;
      ADL('*** Start logging to file: ' + FLogFileName);
    end;
  except
  end;
end;

procedure TExtG2Memo.StopLogFile;
begin
  if FLogWork then
  begin
    Writeln(LogFile);
    TimeToLog;
    Writeln(LogFile, '**** Close');
    Flush(LogFile);
    FLogWork := false;
    CloseFile(LogFile);
    CloseFile(LogFileBin);
  end;
end;

procedure TExtG2Memo.FSetOnLogging(ALogging: boolean);
begin
  if FLogging <> ALogging then
  begin
    FLogging := ALogging;
    LogBtn.Down := FLogging;
    if not(csDesigning in ComponentState) then
    begin
      if FLogging then
        StartLogFile
      else
        StopLogFile;
    end;
  end;
end;

procedure TExtG2Memo.LogTimerProc(Sender: TObject);
begin
  if FLogWork then
  begin
    Flush(LogFile);
  end;
end;

end.
