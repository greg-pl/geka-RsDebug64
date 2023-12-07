unit Wykres3Unit;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,Menus,
  ExtCtrls, StdCtrls,Math,printers,Clipbrd,ShellAPI,Contnrs,
  WykresEngUnit;


type

  TElWykres = class(TCustomControl)   //TCustomPanel)
  private
    FEngine           : TWykresEng;
    FRefreshLockCnt   : integer;
    FOnDropFiles      : TNotifyEvent;
  protected
    procedure MouseDown(Button: TMouseButton;  Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Paint; override;
    procedure Resize; override;


    procedure DoEnter; override;
    procedure DoExit; override;

    procedure WndProc(var Message: TMessage); override;
private
    function  OnHasFocusProc(Sender: TObject): boolean;
    function  OnGetParentHandleProc(Sender: TObject): THandle;
    procedure OnInvalidateProc(Sender: TObject);
    procedure EndUpdateProc;
public
    procedure Invalidate; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    function  IsUpDating(Sender: TObject) : boolean;
    function  RealToTime(P: Nrml):double;
public
    DropFilesList     : TStringList;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property   Engine : TWykresEng read FEngine;

    procedure  SetZoomToInvert;
    procedure  Print;
    function   AddAnalogPanel : TAnalogPanel;

    procedure  TimeZoomIn;
    procedure  TimeZoomInPt(x : integer);
    procedure  TimeZoomOut;
    procedure  TimeZoomOutPt(x : integer);
    procedure  TimeShiftLeft;
    procedure  TimeShiftRight;

  private
    ZommTimeItem   : TMenuItem;
    ZommValItem    : TMenuItem;
    CursorModeItem : TMenuItem;
    BoxModeItem    : TMenuItem;
    TagModeItem    : TMenuItem;
    DelTagModeItem : TMenuItem;
    WkPopupMenu    : TPopupMenu;


    procedure ZoomTimeOnClickProc(Sender: TObject);
    procedure ZoomValOnClickProc(Sender: TObject);
    procedure UndoTimeZoomClickProc(Sender: TObject);
    procedure CursorModeOnClickProc(Sender: TObject);
    procedure BoxModeOnClickProc(Sender: TObject);
    procedure TagModeOnClickProc(Sender: TObject);
    procedure DelTagModeOnClickProc(Sender: TObject);

    procedure OnPopupProc(Sender: TObject);

  private
    function FGetProbCnt : integer;
    procedure FSetProbCnt(k : integer);
    function FGetDtPerProbka : real;
    procedure FSetDtPerProbka(dt : real);
    function FGetBottomBoxHeight : integer;
    procedure FSetBottomBoxHeight(ABottomOpisHeight : integer);
    function FGetSplitWidth : real;
    procedure FSetInfoBoxWidth(AInfoBoxWidth : real);
    function FGetTitleBoxHeight : integer;
    procedure FSetTitleBoxHeight(ATitleBoxHeight : integer);
    function FGetWorkMode : TWorkMode;
    procedure FSetWorkMode(mode : TWorkMode);

    function FGetDrawMode : TDrawMode;
    procedure FSetDrawMode(ADrawMode : TDrawMode);
    function FGetColorMode : TColorMode;
    procedure FSetColorMode(AColorMode :TColorMode);
    function FGetShowPoints :Boolean;
    procedure FSetShowPoints(AShowPoints : boolean);
    function FGetInfoFields : TInfoFields;
    procedure FSetInfoFields(AInfoFields: TInfoFields);
    function FGetForceMiliSek : boolean;
    procedure FSetForceMiliSek(q : boolean);
    function FGetflWyrownOkres : boolean;
    procedure FSetflWyrownOkres(q : boolean);
    function FGetWyrownOkres : real;
    procedure FSetWyrownOkres(r : real);
    function  FGetTitle : TStrings;
    procedure FSetPanelTags(q : boolean);
    function  FGetPanelTags : boolean;
    function  FGetMaxRagCnt : integer;
    procedure FSetMaxRagCnt(Cnt  : integer);

  published
    property ProbCnt             : integer    read FGetProbCnt         write FSetProbCnt;
    property DtPerProbka         : real       read FGetDtPerProbka     write FSetDtPerProbka;
    property BottomBoxHeight     : integer    read FGetBottomBoxHeight write FSetBottomBoxHeight;
    property TitleBoxHeight      : integer    read FGetTitleBoxHeight  write FSetTitleBoxHeight;
    property InfoBoxWidth        : real       read FGetSplitWidth      write FSetInfoBoxWidth;
    property WorkMode            : TWorkMode  read FGetWorkMode        write FSetWorkMode;
    property DrawMode            : TDrawMode  read FGetDrawMode        write FSetDrawMode;
    property ColorMode           : TColorMode read FGetColorMode       write FSetColorMode;
    property ShowPoints          : boolean    read FGetShowPoints      write FSetShowPoints;
    property InfoFileds          : TInfoFields read FGetInfoFields     write FSetInfoFields;
    property ForceMiliSek        : boolean    read FGetForceMiliSek    write FSetForceMiliSek;
    property flWyrownOkres       : boolean    read FGetflWyrownOkres   write FSetflWyrownOkres;
    property WyrownOkres         : real       read FGetWyrownOkres     write FSetWyrownOkres;
    property Title               : TStrings   read FGetTitle;
    property PanelTags           : boolean    read FGetPanelTags       write FSetPanelTags;
    property MaxTagCnt          : integer     read FGetMaxRagCnt       write FSetMaxRagCnt;


  private
    function FGetOnGetAnValue : TGetValAnEvent;
    procedure FSetOnGetAnValue(Event : TGetValAnEvent);
    function FGetOnGetDgValue : TGetValDgEvent;
    procedure FSetOnGetDgValue(Event : TGetValDgEvent);
    function FGetOnGetGroupAnValue : TGetGroupAnEvent;
    procedure FSetOnGetGroupAnValue(Event : TGetGroupAnEvent);
    function FGetOnGetGroupDgValue : TGetGroupDgEvent;
    procedure FSetOnGetGroupDgValue(Event : TGetGroupDgEvent);
    function FGetOnSetPomiarBlok : TSetPomiarBlok;
    procedure FSetOnSetPomiarBlok(Event : TSetPomiarBlok);
    function FGetOnTitleMouseDown : TMouseEvent;
    procedure FSetOnTitleMouseDown(Event : TMouseEvent);
    function FGetOnHidenNotify : TPanelNotify;
    procedure FSetOnHidenNotify(Event : TPanelNotify);
    function FGetOnNewTimeZoom : TNotifyEvent;
    procedure FSetOnNewTimeZoom(Event : TNotifyEvent);
    function FGetOnNewValZoom : TPanelNotify;
    procedure FSetOnNewValZoom(Event : TPanelNotify);
    function FGetOnTagNotify : TTagNotifyEvent;
    procedure FSetOnTagNotify(Event : TTagNotifyEvent);

  published
    property OnGetAnValue        : TGetValAnEvent   read FGetOnGetAnValue       write FSetOnGetAnValue;
    property OnGetDgValue        : TGetValDgEvent   read FGetOnGetDgValue       write FSetOnGetDgValue;
    property OnGetGroupAnValue   : TGetGroupAnEvent read FGetOnGetGroupAnValue  write FSetOnGetGroupAnValue;
    property OnGetGroupDgValue   : TGetGroupDgEvent read FGetOnGetGroupDgValue  write FSetOnGetGroupDgValue;
    property OnSetPomiarBlok     : TSetPomiarBlok   read FGetOnSetPomiarBlok    write FSetOnSetPomiarBlok;
    property OnTitleMouseDown    : TMouseEvent      read FGetOnTitleMouseDown   write FSetOnTitleMouseDown;
    property OnHidenNotify       : TPanelNotify     read FGetOnHidenNotify      write FSetOnHidenNotify;
    property OnNewTimeZoom       : TNotifyEvent     read FGetOnNewTimeZoom      write FSetOnNewTimeZoom;
    property OnNewValZoom        : TPanelNotify     read FGetOnNewValZoom       write FSetOnNewValZoom;
    property OnDropFiles         : TNotifyEvent     read FOnDropFiles           write FOnDropFiles;
    property OnTagNotify         : TTagNotifyEvent  read FGetOnTagNotify        write FSetOnTagNotify;

  published
    property Align;

  end;

procedure Register;

implementation


uses Types;



//---------------------------------------------------------------------------
// TElWykres
//---------------------------------------------------------------------------

constructor TElWykres.Create(AOwner: TComponent);
  function AddPopUpMenuItem(Caption: string; Proc : TNotifyEvent):TMenuItem;
  begin
    Result := TMenuItem.Create(self);
    Result.Caption := Caption;
    WkPopupMenu.Items.Add(Result);
    Result.OnClick := Proc;
  end;

begin
  inherited Create(AOwner);
  Parent := Aowner as TWinControl;
  FEngine := TWykresEng.Create(Self.Canvas);
  DropFilesList    := TStringList.Create;

  FRefreshLockCnt :=0;
  DoubleBuffered  := True;
  TabStop         := True;
  FOnDropFiles    :=nil;

  FEngine.OnIsUpDating := IsUpDating;
  FEngine.OnHasFocus := OnHasFocusProc;
  FEngine.OnGetParentHandle := OnGetParentHandleProc;
  FEngine.OnInvalidate := OnInvalidateProc;

  WkPopupMenu := TPopupMenu.Create(self);
  WkPopupMenu.OnPopup := OnPopupProc;
  WkPopupMenu.Images := TImageList.Create(self);

  CursorModeItem := AddPopUpMenuItem('Cursor Mode',CursorModeOnClickProc);
  BoxModeItem    := AddPopUpMenuItem('Rectangle Mode',BoxModeOnClickProc);
  ZommTimeItem   := AddPopUpMenuItem('Zoom time',ZoomTimeOnClickProc);
  ZommValItem    := AddPopUpMenuItem('Zoom Val',ZoomValOnClickProc);
  AddPopUpMenuItem('-',nil);
  TagModeItem    := AddPopUpMenuItem('New TAG',TagModeOnClickProc);
  DelTagModeItem := AddPopUpMenuItem('Del TAG',DelTagModeOnClickProc);
  AddPopUpMenuItem('-',nil);
  AddPopUpMenuItem('Undo zoom time',UndoTimeZoomClickProc);
  PostMessage(Handle,WM_SIZE,0,0);
end;

destructor TElWykres.Destroy;
begin
  DropFilesList.Free;
  FEngine.Free;
  inherited Destroy;
end;

procedure TElWykres.OnPopupProc(Sender: TObject);
begin
  ZommTimeItem.Checked := (FEngine.WorkMode=wmZoomTime);
  ZommValItem.Checked := (FEngine.WorkMode=wmZoomVal);
  CursorModeItem.Checked := (FEngine.WorkMode=wmCursor);
  BoxModeItem.Checked := (FEngine.WorkMode=wmBox);
  TagModeItem.Checked := (FEngine.WorkMode=wmNewTag);
  TagModeItem.Enabled := FEngine.CanAddTag;
  DelTagModeItem.Checked := (FEngine.WorkMode=wmDelTag);
  DelTagModeItem.Enabled := FEngine.CanDelTag;
end;

procedure TElWykres.ZoomTimeOnClickProc(Sender: TObject);
begin
  FEngine.WorkMode := wmZoomTime;
end;

procedure TElWykres.ZoomValOnClickProc(Sender: TObject);
begin
  FEngine.WorkMode := wmZoomVal;
end;

procedure TElWykres.UndoTimeZoomClickProc(Sender: TObject);
begin
  FEngine.TimeZoomSet(0,1);
end;

procedure TElWykres.CursorModeOnClickProc(Sender: TObject);
begin
  FEngine.WorkMode := wmCursor;
end;

procedure TElWykres.BoxModeOnClickProc(Sender: TObject);
begin
  FEngine.WorkMode := wmBox;
end;

procedure TElWykres.TagModeOnClickProc(Sender: TObject);
begin
  FEngine.WorkMode := wmNewTag;
end;

procedure TElWykres.DelTagModeOnClickProc(Sender: TObject);
begin
  FEngine.WorkMode := wmDelTag;
end;


function TElWykres.OnHasFocusProc(Sender: TObject): boolean;
begin
  Result := Focused;
end;

function TElWykres.OnGetParentHandleProc(Sender: TObject): THandle;
begin
  Result := Parent.Handle;
end;

procedure TElWykres.OnInvalidateProc(Sender: TObject);
begin
  Invalidate;
end;


procedure  TElWykres.BeginUpdate;
begin
  inc(FRefreshLockCnt);
end;


function  TElWykres.IsUpDating(Sender: TObject) : boolean;
begin
  Result := (FRefreshLockCnt<>0);
end;

procedure  TElWykres.EndUpdate;
begin
  if FRefreshLockCnt<>0 then
    dec(FRefreshLockCnt);
  if FRefreshLockCnt=0 then
  begin
    EndUpdateProc;
    Refresh;
  end;
end;

procedure TElWykres.EndUpdateProc;
begin
  FEngine.LiczWymiary(rsmNoChange);
end;


function TElWykres.FGetProbCnt : integer;
begin
  Result:= FEngine.ProbCnt;
end;
procedure TElWykres.FSetProbCnt(k : integer);
begin
  FEngine.ProbCnt := k;
end;

function TElWykres.FGetDtPerProbka : real;
begin
  Result:= FEngine.DtPerProbka;
end;
procedure TElWykres.FSetDtPerProbka(dt : real);
begin
  FEngine.DtPerProbka := dt;
end;

function TElWykres.FGetBottomBoxHeight : integer;
begin
  Result:= FEngine.BottomBoxHeight;
end;


procedure TElWykres.FSetBottomBoxHeight(ABottomOpisHeight : integer);
begin
  FEngine.BottomBoxHeight := ABottomOpisHeight;
end;

function TElWykres.FGetSplitWidth : Real;
begin
  Result:= FEngine.SplitWidth;
end;


procedure TElWykres.FSetInfoBoxWidth(AInfoBoxWidth : Real);
begin
  FEngine.SplitWidth := AInfoBoxWidth;
end;

function TElWykres.FGetTitleBoxHeight : integer;
begin
  Result:= FEngine.TitleBoxHeight;
end;

procedure TElWykres.FSetTitleBoxHeight(ATitleBoxHeight : integer);
begin
  FEngine.TitleBoxHeight:=ATitleBoxHeight;
end;


function TElWykres.FGetWorkMode : TWorkMode;
begin
  Result := FEngine.WorkMode;
end;

procedure TElWykres.FSetWorkMode(mode : TWorkMode);
begin
  FEngine.WorkMode := mode;
end;

function TElWykres.FGetColorMode : TColorMode;
begin
  Result := FEngine.ColorMode;
end;

procedure TElWykres.FSetColorMode(AColorMode :TColorMode);
begin
  FEngine.ColorMode := AColorMode;
end;
function TElWykres.FGetDrawMode : TDrawMode;
begin
  Result := FEngine.DrawMode;
end;

procedure TElWykres.FSetDrawMode(ADrawMode : TDrawMode);
begin
  FEngine.DrawMode := ADrawMode;
end;

function TElWykres.FGetShowPoints :Boolean;
begin
  Result := FEngine.ShowPoints;
end;

procedure TElWykres.FSetShowPoints(AShowPoints : boolean);
begin
  FEngine.ShowPoints:=AShowPoints;
end;

function TElWykres.FGetInfoFields : TInfoFields;
begin
  Result := FEngine.InfoFileds;
end;

procedure TElWykres.FSetInfoFields(AInfoFields: TInfoFields);
begin
  FEngine.InfoFileds:=AInfoFields;
end;

function TElWykres.FGetForceMiliSek : boolean;
begin
  Result := FEngine.ForceMiliSek;
end;
procedure TElWykres.FSetForceMiliSek(q : boolean);
begin
  FEngine.ForceMiliSek:=q;
end;

function TElWykres.FGetflWyrownOkres : boolean;
begin
  Result := FEngine.flWyrownOkres;
end;
procedure TElWykres.FSetflWyrownOkres(q : boolean);
begin
  FEngine.flWyrownOkres := q;
end;

function TElWykres.FGetWyrownOkres : real;
begin
  Result := FEngine.WyrownOkres;
end;

procedure TElWykres.FSetWyrownOkres(r : real);
begin
  FEngine.WyrownOkres := r;
end;

function TElWykres.FGetOnGetAnValue : TGetValAnEvent;
begin
  Result := FEngine.OnGetAnValue;
end;
procedure TElWykres.FSetOnGetAnValue(Event : TGetValAnEvent);
begin
  FEngine.OnGetAnValue:=Event;
end;
function TElWykres.FGetOnGetDgValue : TGetValDgEvent;
begin
  Result := FEngine.OnGetDgValue;
end;
procedure TElWykres.FSetOnGetDgValue(Event : TGetValDgEvent);
begin
  FEngine.OnGetDgValue:=Event;
end;
function TElWykres.FGetOnGetGroupAnValue : TGetGroupAnEvent;
begin
  Result := FEngine.OnGetGroupAnValue;
end;
procedure TElWykres.FSetOnGetGroupAnValue(Event : TGetGroupAnEvent);
begin
  FEngine.OnGetGroupAnValue:=Event;
end;
function TElWykres.FGetOnGetGroupDgValue : TGetGroupDgEvent;
begin
  Result := FEngine.OnGetGroupDgValue;
end;
procedure TElWykres.FSetOnGetGroupDgValue(Event : TGetGroupDgEvent);
begin
  FEngine.OnGetGroupDgValue:=Event;
end;
function TElWykres.FGetOnSetPomiarBlok : TSetPomiarBlok;
begin
  Result := FEngine.OnSetPomiarBlok;
end;
procedure TElWykres.FSetOnSetPomiarBlok(Event : TSetPomiarBlok);
begin
  FEngine.OnSetPomiarBlok:=Event;
end;
function TElWykres.FGetOnTitleMouseDown : TMouseEvent;
begin
  Result := FEngine.OnTitleMouseDown;
end;
procedure TElWykres.FSetOnTitleMouseDown(Event : TMouseEvent);
begin
  FEngine.OnTitleMouseDown:=Event;
end;
function TElWykres.FGetOnHidenNotify : TPanelNotify;
begin
  Result := FEngine.OnHidenNotify;
end;
procedure TElWykres.FSetOnHidenNotify(Event : TPanelNotify);
begin
  FEngine.OnHidenNotify:=Event;
end;
function TElWykres.FGetOnNewTimeZoom : TNotifyEvent;
begin
  Result := FEngine.OnNewTimeZoom;
end;
procedure TElWykres.FSetOnNewTimeZoom(Event : TNotifyEvent);
begin
  FEngine.OnNewTimeZoom:=Event;
end;
function TElWykres.FGetOnNewValZoom : TPanelNotify;
begin
  Result := FEngine.OnNewValZoom;
end;
procedure TElWykres.FSetOnNewValZoom(Event : TPanelNotify);
begin
  FEngine.OnNewValZoom:=Event;
end;

function TElWykres.FGetOnTagNotify : TTagNotifyEvent;
begin
  Result := FEngine.OnTagNotify;
end;

procedure TElWykres.FSetOnTagNotify(Event : TTagNotifyEvent);
begin
  FEngine.OnTagNotify:=Event;
end;


function  TElWykres.FGetTitle : TStrings;
begin
  Result:=FEngine.Title;
end;

procedure TElWykres.FSetPanelTags(q : boolean);
begin
  FEngine.PanelTags:=q;
end;

function  TElWykres.FGetPanelTags : boolean;
begin
  Result := FEngine.PanelTags;
end;

function  TElWykres.FGetMaxRagCnt : integer;
begin
  Result := Engine.MaxTagCnt;
end;

procedure TElWykres.FSetMaxRagCnt(Cnt  : integer);
begin
  Engine.MaxTagCnt := cnt;
end;


procedure  TElWykres.TimeZoomIn;
begin
  FEngine.TimeZoomIn;
end;

procedure  TElWykres.TimeZoomInPt(x : integer);
begin
  FEngine.TimeZoomInPt(x);
end;

procedure  TElWykres.TimeZoomOut;
begin
  FEngine.TimeZoomOut;
end;

procedure  TElWykres.TimeZoomOutPt(x : integer);
begin
  FEngine.TimeZoomOutPt(x);
end;

procedure  TElWykres.TimeShiftLeft;
begin
  FEngine.TimeShiftLeft;
end;

procedure  TElWykres.TimeShiftRight;
begin
  FEngine.TimeShiftRight;
end;

procedure  TElWykres.SetZoomToInvert;
begin
  FEngine.SetZoomToInvert;
end;

//wejœcie - pozycha wzgl¹dna dla osi czasu w zakresie 0..1
//wyjœcie - czas w sekundach
function  TElWykres.RealToTime(P: Nrml):double;
begin
  Result := FEngine.RealToTime(p);
end;

procedure TElWykres.Invalidate;
var
  R : TRect;
begin
  inherited;
  if Assigned(FEngine) then
  begin
    R := Bounds(0,0,Width,Height);
    FEngine.LiczWymiary(R,rsmProportional,toSCR);
  end;
end;

procedure TElWykres.Resize;
begin
  inherited;
  Invalidate;
end;

procedure TElWykres.MouseDown(Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
begin
  SetFocus;
  inherited;
  if Assigned(FEngine) then
    FEngine.MouseDown(Button,Shift,X,Y);
end;

procedure TElWykres.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Assigned(FEngine) then
    FEngine.MouseMove(Shift, X, Y);
end;

procedure TElWykres.MouseUp(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);
var
  Pt : TPoint;
begin
  inherited;
  if Assigned(FEngine) then
  begin
    if not(FEngine.MouseUp(Button,Shift,X,Y)) then
    begin
      if Button=mbRight then
      begin
        Pt := ClientToScreen(Point(x,y));
        WkPopupMenu.Popup(Pt.x,Pt.y);
      end;
    end;
  end;
end;

procedure TElWykres.Paint;
begin
  if Assigned(FEngine) and not(IsUpDating(nil)) then
  begin
    inherited;
    FEngine.Paint;
  end;
end;

procedure TElWykres.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Assigned(FEngine) then
    FEngine.KeyDown(Key,Shift);
end;

procedure TElWykres.Print;
var
  R : TRect;
begin
  Printer.Title := 'Wykres3';
  Printer.Orientation := poPortrait;

  Printer.BeginDoc;
  FEngine.Canvas := Printer.Canvas;
  R := Bounds(0,0,Printer.PageWidth,Printer.PageHeight);
  FEngine.LiczWymiary(R,rsmNoChange,toPRN);
  FEngine.Paint;
  Printer.EndDoc;

  R := Bounds(0,0,Width,Height);
  FEngine.LiczWymiary(R,rsmNoChange,toPRN);
  FEngine.Canvas := Canvas;

  FEngine.LiczWymiary(rsmNoChange);
  Refresh;
end;

function TElWykres.AddAnalogPanel : TAnalogPanel;
begin
  Result := FEngine.AddAnalogPanel;
end;

procedure TElWykres.DoEnter;
begin
  FEngine.DoEnter;
end;

procedure TElWykres.DoExit;
begin
  FEngine.DoExit;
end;

procedure TElWykres.WndProc(var Message: TMessage);
Var
  TotalNumberOfFiles,nFileLength : Integer;
  pszFileName                    : PChar;
  i                              : Integer;
  hDrop                          : Cardinal;
  MouseWheel                     : TWMMouseWheel;
  Shift                          : TShiftState;
  Dir                            : boolean;
  FocusedPanel                   : TChartPanel;
  Pt                             : TPoint;
begin
  case Message.Msg of
    WM_GETDLGCODE : begin
                      Message.Result := DLGC_WANTARROWS or DLGC_WANTTAB;
                      Exit;
                    end;
    WM_DROPFILES  :  if Assigned(FOnDropFiles) then
                     begin
                       DropFilesList.Clear;
                       hDrop := Message.WParam;
                       TotalNumberOfFiles := DragQueryFile(hDrop , $FFFFFFFF, Nil, 0);
                       for i := 0 to TotalNumberOfFiles - 1 do
                       begin
                         nFileLength := DragQueryFile (hDrop, i , Nil, 0) + 1;
                         GetMem (pszFileName, nFileLength);
                         DragQueryFile (hDrop , i, pszFileName, nFileLength);
                         DropFilesList.Add(pszFileName);
                         FreeMem (pszFileName, nFileLength);
                       end;
                       DragFinish (hDrop);
                       FOnDropFiles(Self);
                     end;
    WM_MOUSEWHEEL :  begin
                       MouseWheel := TWMMouseWheel(Message);
                       Shift := KeysToShiftState(MouseWheel.Keys);
                       Dir := (MouseWheel.WheelDelta>0);
                       Pt := Point(MouseWheel.XPos,MouseWheel.YPos);
                       Pt := ScreenToClient(Pt);

                       if ssShift in Shift then
                       begin
                         FocusedPanel := FEngine.FocusedPanel;
                         if Assigned(FocusedPanel) then
                         begin
                           if NOT(ssCtrl in Shift) then
                           begin
                             if Dir then FocusedPanel.ShiftUp
                                    else FocusedPanel.ShiftDn;
                           end
                           else
                           begin
                             if Dir then  FocusedPanel.ZoomInPt(Pt.Y)
                                    else  FocusedPanel.ZoomOutPt(Pt.Y);
                           end;
                         end;
                       end
                       else
                       begin
                         if not(ssCtrl in Shift) then
                         begin
                           if Dir then TimeShiftRight
                                  else TimeShiftLeft;
                         end
                         else
                         begin
                           if Dir then TimeZoomInPt(Pt.X )
                                  else TimeZoomOutPt(Pt.X )

                         end;
                       end;
                     end;
  else
    inherited WndProc(Message);
  end;
end;


procedure Register;
begin
  RegisterComponents('GK', [TElWykres]);
end;


end.


