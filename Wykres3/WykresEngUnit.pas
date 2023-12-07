unit WykresEngUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Math, printers, Clipbrd, ShellAPI, Contnrs;

const
  MAX_SIATKA = 50;
  clSuwak = clSkyBlue;

  crSizeW = TCursor(-100);
  crSizeE = TCursor(-101);
  crSizeS = TCursor(-102);
  crSizeN = TCursor(-103);
  crZoomT_In = TCursor(-104);
  crZoomV_In = TCursor(-105);
  crCrossBox = TCursor(-106);
  crNewTag = TCursor(-107);
  crTagMove = TCursor(-108);
  crTagEdit = TCursor(-109);
  crTagDel = TCursor(-110);
  crDel = TCursor(-111);

  outLEFT = -1;
  outRIGHT = -2;
  outTop = -3;
  outBOTTOM = -4;

type
  Nrml = double; // wartoœæ rzeczywista z przedzia³u [0..1]

  TCxData = record
    V: double;
    Exist: boolean;
  end;

  TCxDataBuf = array of TCxData;

  TCxDgData = record
    V: boolean;
    Exist: boolean;
  end;

  TCxDgDataBuf = array of TCxDgData;

  TGetValEvent = procedure(Sender: TObject; NrDanych: integer; NrProb: Cardinal; var Val: real; var Exist: boolean) of object;
  TGetValAnEvent = procedure(Sender: TObject; DtNr: integer; NrProb: Cardinal; var Val: double; var Exist: boolean) of object;
  TGetGroupAnEvent = procedure(Sender: TObject; DtNr: integer; NrProb: Cardinal; ProbCnt: integer; Buf: TCxDataBuf) of object;
  TGetValDgEvent = procedure(Sender: TObject; DtNr: integer; NrProb: Cardinal; var Val: boolean; var Exist: boolean) of object;
  TGetGroupDgEvent = procedure(Sender: TObject; DtNr: integer; NrProb: Cardinal; ProbCnt: integer; Buf: TCxDgDataBuf) of object;
  TSplitMoovedEvent = procedure(Sender: TObject; NewPos: integer) of object;
  TOnGetBoolQuery = function(Sender: TObject): boolean of object;
  TOnGetHandle = function(Sender: TObject): THandle of object;

  TChartPanel = class;
  TTag = class;
  TTagFunc = (tgADD, tgDEL, tgMOVE, tgFOCUSED, tgCAPTION, tgMOVING);

  TSetPomiarBlok = procedure(Sender: TObject; DtNr, StartVal, EndVal: integer; SL: TStrings) of object;
  TMouseEvent = procedure(Sender: TObject) of object;
  TPanelNotify = procedure(Sender: TObject; Panel: TChartPanel) of object;
  TTagNotifyEvent = procedure(Sender: TObject; Panel: TChartPanel; Tag: TTag; Func: TTagFunc) of object;
  TPaintDest = (toSCR, toPRN);
  TColorMode = (pmdFullColor, pmdHalfColor, pmdMono);
  TDrawMode = (dmCROSS, dmSTAIRS);
  TResizeMode = (rsmNoChange, rsmEqual, rsmProportional);
  TInfoField = (ifRMS, ifAVR, ifRMZ, ifMAX, ifMIN);
  TInfoFields = set of TInfoField;

  TOrientation = (orHoriz, orVert);
  TTmFormatMode = (tfDay, tfHour, tfMin, tfSec, tfMSec);

  TWorkMode = (wmCursor, wmBox, wmZoomTime, wmZoomVal, wmNewTag, wmDelTag);

  TSplitPanelList = class;
  TGrSplitPanel = class;

  TGrObjectList = class;

  TOrganizer = class(TObject)
  private
    FArea: TRect;
    FPaintDst: TPaintDest;
    FCanvas: TCanvas;
    FMemCanvas: TCanvas;

    procedure FSetSplitWidth(w: real); virtual;
    function CanResizePanel(Panel: TGrSplitPanel): boolean;
    function GetNextPanel(Panel: TGrSplitPanel): TGrSplitPanel;
    procedure Invalidate;
    function HasFocus: boolean;
    function GetParentHandle: THandle;
    function IsUpDating: boolean;
    procedure FSetCanvas(Cn: TCanvas);

  protected
    FSplitWidth: real; // wartoœæ w procentach
    FSplitPanelList: TSplitPanelList;
    procedure PaintDraggedSplit(x: integer);
    procedure PaintTo(Quick: boolean); virtual;
    function SpliterRealToInt(r: real): integer;
    function SpliterIntToReal(r: integer): real;

    function GetSpliterPos: integer;
  public
    OnInvalidate: TNotifyEvent;
    OnHasFocus: TOnGetBoolQuery;
    OnIsUpDating: TOnGetBoolQuery;
    OnGetParentHandle: TOnGetHandle;
    constructor Create; overload;
    constructor Create(Cn: TCanvas); overload;
    destructor Destroy; override;
    procedure RemooveSplitPanel(Ob: TObject);
    property SplitWidth: real read FSplitWidth write FSetSplitWidth;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; virtual;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; virtual;
    function MouseMove(Shift: TShiftState; x, Y: integer): boolean; virtual;
    procedure Paint;
    property Canvas: TCanvas read FCanvas write FSetCanvas;

  end;

  TWykresEng = class;

  TGrObject = class(TObject)
  private
    FClicked: boolean;
    FSavedPos: TRect;
    FScrPos: TRect;
    FOwner: TOrganizer;
    FBkColor: TColor;
    procedure FSetBkColor(aColor: TColor);
  protected
    procedure Invalidate;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer); virtual;
    procedure MouseMove(Shift: TShiftState; x, Y: integer); virtual;
    procedure Paint(Quick: boolean); virtual;
    function MouseOper: boolean; virtual;
    procedure FSetScrPos(r: TRect); virtual;
  public
    property Clicked: boolean read FClicked;
    constructor Create(aOwner: TOrganizer);
    destructor Destroy; override;
    procedure StorePos;
    procedure ReStorePos;
    property ScrPos: TRect read FScrPos write FSetScrPos;
    property BkColor: TColor read FBkColor write FSetBkColor;
  end;

  TGrObjectList = class(TObjectList)
  private
    FOwner: TOrganizer;
    function FGetItem(Index: integer): TGrObject;
  protected
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer); virtual;
    procedure MouseMove(Shift: TShiftState; x, Y: integer); virtual;
    procedure Paint(Quick: boolean); virtual;
  public
    constructor Create(aOwner: TOrganizer); overload;
    constructor Create(aOwner: TOrganizer; AOwnsObjects: boolean); overload;
    property Items[Index: integer]: TGrObject read FGetItem;
    procedure StorePos;
    procedure ReStorePos;
    function MouseOper: boolean;
  end;

  TOnGetPosition = procedure(Sender: TObject; var x: real; var dx: real) of object;
  TNotifyPositionChg = procedure(Sender: TObject; x: real; dx: real) of object;

  TGrScrollBar = class(TGrObject)
  private
    Fdur: real;
    Fur: real;
    FThickness: integer;
    FSliderLength: integer;
    FOrientation: TOrientation;
    Wagon: TRect;
    Mooving: boolean;
    Jumping: boolean;
    MoovingDD: integer;
    JumpingDD: integer;
    Ftimer: TTimer;
    Visible: boolean;
    FParent: TGrObject;

    procedure FSetSliderLength(w: integer);
    procedure ExecOnPositonChg(u, du: real);
    procedure SetTimeVagonDim;
    procedure FOnMoveTime(Sender: TObject);
    procedure FSetThickness(w: integer);
    function DoJump: boolean;
  protected
    procedure Paint(Quick: boolean); override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; x, Y: integer); override;
    function MouseOper: boolean; override;
  public
    OnPositonChg: TNotifyPositionChg;
    OnGetPosition: TOnGetPosition;
    Constructor Create(aOwner: TOrganizer; aParent: TGrObject; aOrientation: TOrientation);
    destructor Destroy; override;

    property SliderLength: integer read FSliderLength write FSetSliderLength;
    property Thickness: integer read FThickness write FSetThickness;
    property Orientation: TOrientation read FOrientation;
    procedure FSetScrPos(r: TRect); override;
    procedure SetPosition(x, Y, aLength: integer);
    procedure UpdatePos;
    function IsZoomed: boolean;
  end;

  TSiatkaItem = class(TObject)
  public
    PosX: integer;
    Txt: string;
    ValR: real;
    Major: boolean;
    function IsZero: boolean;
  end;

  TOnGetItemTxt = function(Sender: TObject; x: real): string of object;

  TSiatka = class(TGrObject)
  private
    FList: TObjectList;
    FOrientation: TOrientation;
    FBegV: real;
    FEndV: real;
    FLinePos: integer;
    FSArea: TRect;
    FTmPrze: TTmFormatMode;
    FMinDx: integer;
    FAlign: TLeftRight;
    function FGetItem(Index: integer): TSiatkaItem;
    function ExecOnGetItemTxt(t: real): string;
  public
    Units: string;
    Xinterval: integer;
    OnGetItemTxt: TOnGetItemTxt;
    property Items[Index: integer]: TSiatkaItem read FGetItem;
    function Count: integer;
    constructor Create(aOwner: TOrganizer; Orien: TOrientation);
    destructor Destroy; override;
    procedure Build(BegV, EndV: real; Area: TRect; BegX, EndX, LinePos: integer; Align: TLeftRight);
    procedure Paint(Quick: boolean); override;
  end;

  TSerie = class(TObject)
  private
    FDtPerProbkaLocal: boolean; // true - rozdzeilczoœæ indywidualna dla tej serii;
    FProbCntLocal: boolean; // true - rozdzeilczoœæ indywidualna dla tej serii;
    FDtPerProbka: real;
    FProbCnt: integer;
    FDtNr: integer;
    FWykres: TWykresEng;
    FPanel: TChartPanel;
    FVisible: boolean;
    function FGetDtPerProbka: real;
    procedure FSetDtPerProbka(aDtPerProbka: real);
    function FGetProbCnt: integer;
    procedure FSetProbCnt(cnt: integer);
  protected
    procedure FSetVisible(q: boolean); virtual;
  public
    Title: string; // opis przebiegu
    Descr: string; // opis przebiegu
    PenColor: TColor; // kolor przebiegu
    ShiftTime: real;
    property DtNr: integer read FDtNr;
    property Visible: boolean read FVisible write FSetVisible;
    constructor Create(Wykres: TWykresEng; Panel: TChartPanel; aDtnr: integer);
    property DtPerProbka: real read FGetDtPerProbka write FSetDtPerProbka;
    property ProbCnt: integer read FGetProbCnt write FSetProbCnt;
    function GetNrPr(Tm: double): integer;
    property Panel: TChartPanel read FPanel;
  end;

  TSerieList = class(TObjectList)
  private
    FWykres: TWykresEng;
    FPanel: TChartPanel;
    function FGetItem(Index: integer): TSerie;
  protected
  public
    constructor Create(Wykres: TWykresEng; Panel: TChartPanel);
    property Items[Index: integer]: TSerie read FGetItem;
    procedure Add(Item: TSerie);
  end;

  TAnalogPanel = class;

  TAnalogSerie = class(TSerie)
  private
    FMaxV: real; // maksymalna wartosc
    FMinV: real; // minimalna  wartosc
    FMinMaxVExist: boolean; // wartosci MinV,MaxV sa aktualne
    procedure Paint(Quick: boolean);
    function LiczY(V: real): integer;
    procedure LiczPomiarBlok(SL: TStrings; StartProb, EndProb: integer);
  protected
    procedure FSetVisible(q: boolean); override;
  public
    constructor Create(Wykres: TWykresEng; Panel: TChartPanel; aDtnr: integer);
    procedure LiczMinMax(StartProb, EndProb: integer); overload;
    procedure LiczMinMax; overload;
    procedure GetValAt(Tm: real; var Val: double; var Exist: boolean);
  end;

  TAnlalogSerieList = class(TSerieList)
  private
    FMaxV: double;
    FMinV: double;
    FminMaxExist: boolean;
    function FGetItem(Index: integer): TAnalogSerie;
    procedure LiczMinMax(StartProb, EndProb: integer); overload;
    procedure LiczMinMax; overload;
  public
    property Items[Index: integer]: TAnalogSerie read FGetItem;
    procedure Add(Serie: TAnalogSerie);
    function CreateNew(aDtnr: integer): TAnalogSerie;
    procedure LiczPomiarBlok(SL: TStrings; StartProb, EndProb: integer);

  end;

  TDigitalSerie = class(TSerie)
  public
    OnGetValue: TGetValDgEvent;

  end;

  TDigitalSerieList = class(TSerieList)
  private
    function FGetItem(Index: integer): TDigitalSerie;
  public
    property Items[Index: integer]: TDigitalSerie read FGetItem;
    procedure Add(Serie: TDigitalSerie);
    function CreateNew(aDtnr: integer): TDigitalSerie;
  end;

  TPanelOption = (pnCanFocus, pnCanZoom, pnCanResize, pnVisible, pnActive, pnZoomed, pnFocused);
  TPanelOptions = set of TPanelOption;

  TGrSplitPanel = class(TGrObject)
  private
    FDragged: boolean;
    FDraggedSplit: integer;
    FpanelResize: boolean;
    FResizePosY: integer;
    function CheckOverSplit(x, Y: integer): boolean;
    function CheckOverBottom(x, Y: integer): boolean;
    procedure ExecPaintDraggedSplit(x: integer);
    procedure PaintDraggedResize(Y: integer);
    function FGetVisible: boolean;
    function FGetFocused: boolean;
    procedure FSetVisible(q: boolean);
  protected
    PanelOptions: TPanelOptions;
    property Focused: boolean read FGetFocused;
    procedure SetFocused;

    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; x, Y: integer); override;
    procedure Paint(Quick: boolean); override;
    function GetWorkArea: TRect;
    function GetInfoArea: TRect;
    function GetDataArea: TRect;
    procedure DoSplitWidthChg; virtual;
    function MouseOper: boolean; override;
  protected
    procedure ReSizePanel(dy: integer); virtual;
    procedure PaintInfoArea(Quick: boolean); virtual;
    procedure PaintWorkArea(Quick: boolean); virtual;
  public
    constructor Create(aOwner: TOrganizer);
    destructor Destroy; override;
    procedure SetSplit(spl: integer);
    procedure SetPosition(aTop, aHeight: integer); virtual;
    procedure UndoZoom; virtual;
    procedure FullZoom; virtual;
    property Visible: boolean read FGetVisible write FSetVisible;
  end;

  TSplitPanelList = class(TGrObjectList)
  private
    function FGetItem(Index: integer): TGrSplitPanel;
    procedure SetZoomed(Panel: TGrSplitPanel);
  protected
    procedure SetFocus(Ob: TGrSplitPanel);
    procedure PaintInfoBox(Quick: boolean); virtual;
  public
    property Items[Index: integer]: TGrSplitPanel read FGetItem;
    function GiveNextPanel(Item: TGrSplitPanel; Opt: TPanelOptions): TGrSplitPanel; overload;
    function GiveNextPanel(Item: TGrSplitPanel): TGrSplitPanel; overload;
    function GivePrevPanel(Item: TGrSplitPanel): TGrSplitPanel;
    function PanelAtYPos(Y: integer): TGrSplitPanel;
    function getCount(Opt: TPanelOptions): integer;

    function FocusedPanel: TGrSplitPanel;
    function FocusedOrFirst: TGrSplitPanel;
    function FocusFirst: TGrSplitPanel;
    function GetFirstPanel(Opt: TPanelOptions): TGrSplitPanel; overload;
    function GetFirstPanel: TGrSplitPanel; overload;
    function GetLastPanel(Opt: TPanelOptions): TGrSplitPanel; overload;
    function GetLastPanel: TGrSplitPanel; overload;
    function AnyVisible: boolean;
    function AnyActivVisible: boolean;
    procedure DoSplitWidthChg;
    procedure UndoZoom;
    procedure FullZoom;
    function ClrFocused: TGrSplitPanel;
    procedure SetAllVisible;
  end;

  TTagList = class;

  TChartPanel = class(TGrSplitPanel)
  private
    ScrollBar: TGrScrollBar;
    FClicked: boolean;
    FZoomingVal: boolean;
    FMeasuring: boolean;
    StartPos: integer;
    EndPos: integer;
    FTagList: TTagList;

    procedure OnGetPositionProc(Sender: TObject; var xr: real; var dxr: real);
    procedure OnPositonChgProc(Sender: TObject; xr: real; dxr: real);
    procedure DrawZoomingVal(y1, y2: integer);
    procedure LiczNewValWindow(var Str: Nrml; var Del: Nrml);
  protected
    function MouseOper: boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; x, Y: integer); override;
    procedure Paint(Quick: boolean); override;
    procedure SetDataArea;
  public
    procedure SetPosition(aTop, aHeight: integer); override;
    procedure ShiftUp; virtual;
    procedure ShiftDn; virtual;
    procedure ZoomIn; virtual;
    procedure ZoomOut; virtual;
    procedure ZoomInPt(Y: integer); virtual;
    procedure ZoomOutPt(Y: integer); virtual;
  protected
    procedure SetNewValZoom(Str, Delt: Nrml); virtual;
  private
    FDataArea: TRect;
  public
    TypWej: string; // typ zrodla danych
    AdresWej: string; // adres wejscia danych
    Title: string; // opis przebiegu
    Units: string; // jednostki
    TriggerH: real; // pozycja wyzwolenia GORA
    TriggerL: real; // pozycja wyzwolenia DOL
    IsTriggerH: boolean; // bylo wyzwolenie gora
    IsTriggerL: boolean; // bylo wyzwolenie dol
    MinDelta: real;

    // Private - robocze
    Zoomed: boolean;
    InfoStrings: TStringList; // stringi do okna INFO
    MinMaxVExist: boolean; // wartosci MinV,MaxV sa aktualne
    WykresHight: real; // procentowy udzial w wysokosci
    R_Box: TRect;
    DrawStart: Nrml;
    DrawDelta: Nrml;
    constructor Create(aWykres: TWykresEng);
    destructor Destroy; override;
    function Parent: TWykresEng;
    function IsDataZoomed: boolean;
    property TagList: TTagList read FTagList;
  end;

  TAnalogPanel = class(TChartPanel)
  private
    FSeries: TAnlalogSerieList;
    FSiatka: TSiatka;
    FMaxR: real; // maksymalna wartosc na osi
    FMinR: real; // minimalna wartosc na osi
    procedure LiczSiatka;
    function OnGetSiatkaItemTxtProc(Sender: TObject; x: real): string;
    procedure FSetMaxR(r: real);
    procedure FSetMinR(r: real);
    procedure SetMinMax(aMin, aMax: real);
  protected
    procedure PaintNames(Quick: boolean);
    procedure PaintInfoArea(Quick: boolean); override;
    procedure PaintWorkArea(Quick: boolean); override;
    procedure Paint(Quick: boolean); override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; x, Y: integer); override;
    procedure ReSizePanel(dy: integer); override;
    procedure DoSplitWidthChg; override;
  public
    procedure ShiftUp; override;
    procedure ZoomIn; override;
    procedure ShiftDn; override;
    procedure ZoomOut; override;
    procedure ZoomInPt(Y: integer); override;
    procedure ZoomOutPt(Y: integer); override;
  public
    PropHeigh: real;
    Mnoznik: double; // tutaj niepotrzebny (tylko edycja)
    constructor Create(aWykres: TWykresEng);
    destructor Destroy; override;
    function LiczY(V: real): integer;
    function LiczYW(V: Nrml): integer;
    function PixelToReal(Y: integer): real;
    function RealToVal(r: Nrml): double;
    property Series: TAnlalogSerieList read FSeries;
    procedure SetNewValZoom(Str, Delt: Nrml); override;
    procedure UndoZoom; override;
    procedure FullZoom; override;
    procedure SetPosition(aTop, aHeight: integer); override;
    property MaxR: real read FMaxR write FSetMaxR;
    property MinR: real read FMinR write FSetMinR;
    procedure LiczPomiarBlok(StartProb, EndProb: integer);
    procedure AutoMinMax;
  end;

  TAnalogPanelList = class(TSplitPanelList)
  private
    function FGetItem(Index: integer): TAnalogPanel;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

  public
    constructor Create(Wykres: TWykresEng);
    property Items[Index: integer]: TAnalogPanel read FGetItem;
    procedure Add(Panel: TAnalogPanel);
    function CreateNew: TAnalogPanel; overload;
    function CreateNew(idx: integer): TAnalogPanel; overload;
    procedure Paint(Quick: boolean); override;
    procedure LiczPomiarBlok(StartProb, EndProb: integer);
    function GetVisibleCnt: integer;
    procedure SetEquHeight(Y0, H: integer);
    procedure SetProportionalHeight(Y0, H: integer);
  end;

  TDigitalPanel = class(TChartPanel)
  private
    FSeries: TDigitalSerieList;
  protected
    procedure Paint(Quick: boolean); override;

  public
    DigiHeight: integer;
    property Series: TDigitalSerieList read FSeries;
    constructor Create(aWykres: TWykresEng);
    destructor Destroy; override;
    function IsAnyDigit: boolean;
  end;

  TTopPanel = class(TGrSplitPanel)
  private
    function GetMyColor: TColor;
  protected
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; override;
    procedure Paint(Quick: boolean); override;
    procedure ReSizePanel(dy: integer); override;
    procedure PaintInfoArea(Quick: boolean); override;
    procedure PaintWorkArea(Quick: boolean); override;
  public
    constructor Create(aOwner: TOrganizer);
  end;

  TBottomPanel = class(TGrSplitPanel)
  private
    TimeBar: TGrScrollBar;
    FSiatka: TSiatka;
    procedure OnGetPositionProc(Sender: TObject; var xr: real; var dxr: real);
    procedure OnPositonChgProc(Sender: TObject; xr: real; dxr: real);

    procedure SetScrollBarPosition;
  protected
    procedure Paint(Quick: boolean); override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; x, Y: integer); override;
    procedure DoSplitWidthChg; override;
    function MouseOper: boolean; override;
    procedure PaintInfoArea(Quick: boolean); override;
    procedure PaintWorkArea(Quick: boolean); override;
  public
    procedure SetPosition(aTop, aHeight: integer); override;
    property Siatka: TSiatka read FSiatka;
    constructor Create(aOwner: TOrganizer);
    destructor Destroy; override;
    procedure SetNewZoom;
    procedure LiczSiatka;

  end;

  TTag = class(TObject)
  private
    FOwner: TWykresEng;
    FPanel: TChartPanel;
    FList: TTagList;
    TextRect: TRect;
    FVisible: boolean;
    FTagX: integer;
    FAlign: TAlign;
    FDeleteMe: boolean;
    FMooving: boolean;
    FSelectVisible: boolean;
    FLastSelectX: integer;
    FCaption: string;

    FUpdateCnt: integer;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure DoNotify(Func: TTagFunc);

  private
    FTagPos: double; // pozycja Tag'a w [sekunda]
    function FGetXPixel: integer;
    procedure FSetXPixel(x: integer);
    procedure FSetTagPos(Tm: double);
    procedure FSetCaption(cap: string);
    function GetOwnerRect: TRect;
    function CheckTagRegion(Pt: Tpoint): boolean;
    procedure EditCaption;
    procedure DrawSelect(DoShow: boolean; x: integer);
    procedure Update;
    procedure PaintTo1(Quick: boolean);
    procedure PaintTo2(Quick: boolean);
    procedure CopyFrom(Src: TTag);
  protected
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
    procedure MouseMove(Shift: TShiftState; x, Y: integer);
  public
    Color: TColor;
    constructor Create(List: TTagList; aOwner: TWykresEng; Panel: TChartPanel);
    destructor Destroy; override;
    property XPixel: integer read FGetXPixel write FSetXPixel;
    property TagPos: double read FTagPos write FSetTagPos;
    property Caption: string read FCaption write FSetCaption;
  end;

  TTagList = class(TObjectList)
  private
    FOwner: TWykresEng;
    FPanel: TChartPanel;
    Counter: integer;
    FFocused: TTag;
    function FGetItem(Index: integer): TTag;
    function CheckCaptionPosition(Item: TTag; CheckR: TRect): boolean;
    procedure PaintTo(Quick: boolean);
    procedure CopyFrom(Src: TTagList);
    procedure Update;
    procedure FSetFocused(Tag: TTag);
  protected
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
    procedure MouseMove(Shift: TShiftState; x, Y: integer);
    procedure KeyDown(var Key: Word; Shift: TShiftState);
  public
    constructor Create(aOwner: TWykresEng); overload;
    constructor Create(aOwner: TWykresEng; aPanel: TChartPanel); overload;
    property Items[Index: integer]: TTag read FGetItem;
    function AddTagAt(x: integer): TTag;
    function AddTag(Tm: real; cap: string): TTag;
    property Focused: TTag read FFocused write FSetFocused;
  end;

  TInvertBoxMode = (ibTIME, ibVAL);

  TInvertBox = class(TObject)
  private
    FOwner: TWykresEng;
    FVisible: boolean;
  public
    Mode: TInvertBoxMode;
    Panel: TAnalogPanel;
    Exist: boolean;
    FRect: TRect; // aktualny rozmiar na ekranie
    TimeStr: real; // wartosc real [0..1]
    TimeEnd: real; // wartosc real [0..1]
    ValStr: real; //
    ValEnd: real;
    constructor Create(Owner: TWykresEng);
    procedure SetValBox(r: TRect; P: TAnalogPanel);
    procedure SetTimeBox(x1, x2: integer);

    procedure Clear;
    function TimeBoxExist: boolean;
    function ValBoxExist: boolean;
    function StartProb: integer;
    function EndProb: integer;
    function GetTimeDelta: real; // zwraca czas w [ms]
    procedure UpdatePos;
    function InTimeBox(x: integer): boolean;
    function InValBox(x, Y: integer): boolean;
    procedure Show(DoShow: boolean); overload;
    procedure Show; overload;
    property Rect: TRect read FRect;
  end;

  TWykresEng = class(TOrganizer)
  private
    PaintDest: TPaintDest;

    FAnyPanelVisible: boolean;
    Zoomed: boolean; // wykres pracuje w trybie ZOOM
    FProbCnt: integer; // ilosc pomiarow do pokazania
    FInfoFields: TInfoFields;

    FBottomBoxHeight: integer;
    FTitleBoxHeight: integer;

    FDataScrollBarWidth: integer;

    GWorkPanelBox: TRect; // pole dla paneli typu TChartPanel
    GDataArea: TRect; // pole kreœlenia przebiegów

    FTimeWindowStart: Nrml; // poczatek okna czasowego
    FTimeWindowDelta: Nrml; // szerokosc okna czasowego
    FInvertBox: TInvertBox;
    FTagList: TTagList;
    FTagKey: boolean;
    FWorkMode: TWorkMode;
    FSavedMode: TWorkMode; // tylko wartoœci wmCursor,wmBox
    FSplitedArea: boolean; // mo¿na wywo³aæ Paint

    // Zmienne robocze do obslugi myszki
    FCurrsorVisible: boolean;
    FSelectBoxVisible: boolean;
    FZoomingTime: boolean;
    FBoxSelect: boolean;
    FMeasuring: boolean;
    MsDownPoint: Tpoint; // pozycja w momencie nacisniecia myszki
    MsLastPoint: Tpoint; // pozycja w oststnim wywo³aniu MouseMove
    FMouseWasWarAway: boolean; // czy myszka odjecha³a od punktu DOWN
    FMouseShifting: boolean;

    // Events
    FOnGetAnValue: TGetValAnEvent;
    FOnGetGroupAnValue: TGetGroupAnEvent;
    FOnGetDgValue: TGetValDgEvent;
    FOnGetGroupDgValue: TGetGroupDgEvent;
    FOnSetPomiarBlok: TSetPomiarBlok;
    FOnDropFiles: TNotifyEvent;
    FOnTitleMouseDown: TMouseEvent;
    FOnHidenNotify: TPanelNotify;
    FOnNewTimeZoom: TNotifyEvent;
    FOnNewValZoom: TPanelNotify;
    FOnTagNotify: TTagNotifyEvent;

    // Parametry pracy
    FDefaultFont: TFont;
    FForceMiliSek: boolean; // wymuszenie czasu w milisekundach
    FDrawMode: TDrawMode;
    FColorMode: TColorMode;
    FShowPoints: boolean;
    FTitleStrings: TStringList;
    FflWyrownOkres: boolean; // zaznaczane tylko wielokrotnosci okresu
    FWyrownOkres: real; // zaznaczany okres

    function FGetInvertEndProb: integer;
    function FGetInvertStartProb: integer;
    function FGetInvertTimeBoxExist: boolean;
    procedure SetZoomed(aZoomed: boolean);
    procedure LiczNewTimeWindow(var Str: real; var Del: real; Regular: boolean);
    function GiveTimeStrTm(Tm: real; Jed: boolean): string;
    function GiveTimeStrDelta(P: Nrml; Jed: boolean): string;
    function GiveTimeStr(P: real; Jed: boolean): string;
    function GiveFullTimeStr(P: real): string;
    function GiveFullDateStr(P: real): string;
    function PixelToReal(x: integer): Nrml;
    procedure FSetPanelTags(Mode: boolean);
    function FgetPanelTags: boolean;
    procedure FSetTagKey(Mode: boolean);
    procedure FSetProbCnt(aProgCnt: integer);

    procedure CopyTags(SrcPanle: TChartPanel);
  public
    function RealToTime(P: Nrml): double;
    function TimeToReal(P: double): Nrml;

    function LiczX(r: Nrml): integer;
    function LiczX_Clip(r: Nrml): integer;
    function GetNrProb4Real(r: Nrml): integer;
    function ProbkaToTime(nrPr: integer): double;

    procedure AddTag(x, Y: integer);
  private
    procedure DrawNoWorking(Quick: boolean);
    procedure DrawCursor(DoShow: boolean);
    function ComputeSelectBox: TRect;
    procedure DrawSelect(DoShow: boolean);
    procedure SetInvertBox(SetIt: boolean);
    procedure SetInvertValBox(SetIt: boolean);
    procedure SetMyPomiarBlok;
    procedure FSetBottomBoxHeight(ABottomOpisHeight: integer);
    procedure FSetTitleBoxHeight(ATitleBoxHeight: integer);
    procedure FSetWorkMode(aWorkMode: TWorkMode);
    procedure FSetColorMode(AColorMode: TColorMode);
    procedure FSetShowPoints(AShowPoints: boolean);
    procedure FSetDrawMode(ADrawMode: TDrawMode);
    procedure FSetInfoFields(AInfoFields: TInfoFields);
    function GetCurrMouseXWzgl: Nrml;
  protected
    procedure FSetSplitWidth(w: real); override;
    procedure PaintTo(Quick: boolean); override;
    function MouseFarAway(Pt: Tpoint): boolean;
  public
    function MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean; override;
    function MouseMove(Shift: TShiftState; x, Y: integer): boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState);
    procedure DoEnter;
    procedure DoExit;
  protected
    function IsZoomingTime(Shift: TShiftState): boolean;
    function IsZoomingVal(Shift: TShiftState): boolean;
  private
    FAnalogPanels: TAnalogPanelList;
    FDigitalPanel: TDigitalPanel;
    FTopPanel: TTopPanel;
    FBottomPanel: TBottomPanel;
    FAnyDataZoomed: boolean;

    procedure GetTimeWindow(var TimeStr: real; var TimeDlt: real);
    function IsAnyPanelDataZoomed: boolean;
    procedure RecalculateDataArea;
    procedure ExecNewValZoom(Panel: TChartPanel);
    procedure UpdateTagList;

  public
    property AnalogPanels: TAnalogPanelList read FAnalogPanels;
    property DigitalPanel: TDigitalPanel read FDigitalPanel;
    function FocusedPanel: TChartPanel;
    function FocusedPanelIdx: integer;

  public
    DtPerProbka: real; // czas w sekundach na probke - okres
    TitleFont: TFont;
    TimeOfset: real; // offset czasu w sekundach
    FullTime: boolean; // true - czas bezwzgledny
    ForHistory: boolean;
    StartTime: TDateTime;
    DropFilesList: TStringList;
    TagColor: TColor;
    TagFont: TFont;
    MaxTagCnt: integer;

    constructor Create(Cn: TCanvas);
    destructor Destroy; override;
    procedure Clear;
    procedure TagClear;
    procedure SetZoomToInvert;
    procedure SetZoomToValInvert;

    procedure Print;
    function AddAnalogPanel: TAnalogPanel;
    function InsertAnalogPanel(Index: integer): TAnalogPanel; overload;
    function InsertAnalogPanel(aPanel: TAnalogPanel): TAnalogPanel; overload;

    function GetDataAreaEnd: integer;
    function TimeZoomSet(Str, Delt: real): boolean;
    function TimeZoomTo(Tm, Delt: real): boolean; // poka¿ odcinek czas

    procedure TimeZoomIn;
    procedure TimeZoomInPt(x: integer);
    procedure TimeZoomOut;
    procedure TimeZoomOutPt(x: integer);
    procedure TimeShiftLeft;
    procedure TimeShiftRight;
    procedure TimeUndoZoom;

    procedure ValShiftUp;
    procedure ValShiftDn;
    procedure ValZoomIn;
    procedure ValZoomOut;
    function ValIsZoomed: boolean;
    procedure ValFullZoom;
    procedure ValUndoZoom;

    procedure ExpandPanel;
    procedure CollapsePanel;
    function CanCollapse: boolean;
    function CanExpand: boolean;
    function IsAnyVZoom: boolean;

    procedure DoTagNotify(Tag: TTag; Panel: TChartPanel; Func: TTagFunc);

    property Title: TStringList read FTitleStrings;
    property TimeWindowStart: Nrml read FTimeWindowStart;
    property TimeWindowDelta: Nrml read FTimeWindowDelta;
    property InvertTimeBoxExist: boolean read FGetInvertTimeBoxExist;
    property InvertStartProb: integer read FGetInvertStartProb;
    property InvertEndProb: integer read FGetInvertEndProb;
    property WorkMode: TWorkMode read FWorkMode write FSetWorkMode;

  published
    property OnSetPomiarBlok: TSetPomiarBlok read FOnSetPomiarBlok write FOnSetPomiarBlok;
    property OnTitleMouseDown: TMouseEvent read FOnTitleMouseDown write FOnTitleMouseDown;
    property OnHidenNotify: TPanelNotify read FOnHidenNotify write FOnHidenNotify;
    property OnDropFiles: TNotifyEvent read FOnDropFiles write FOnDropFiles;
    property OnNewTimeZoom: TNotifyEvent read FOnNewTimeZoom write FOnNewTimeZoom;
    property OnNewValZoom: TPanelNotify read FOnNewValZoom write FOnNewValZoom;
    property OnGetAnValue: TGetValAnEvent read FOnGetAnValue write FOnGetAnValue;
    property OnGetGroupAnValue: TGetGroupAnEvent read FOnGetGroupAnValue write FOnGetGroupAnValue;
    property OnGetDgValue: TGetValDgEvent read FOnGetDgValue write FOnGetDgValue;
    property OnGetGroupDgValue: TGetGroupDgEvent read FOnGetGroupDgValue write FOnGetGroupDgValue;
    property OnTagNotify: TTagNotifyEvent read FOnTagNotify write FOnTagNotify;

    property ProbCnt: integer read FProbCnt write FSetProbCnt;
    property BottomBoxHeight: integer read FBottomBoxHeight write FSetBottomBoxHeight;
    property TitleBoxHeight: integer read FTitleBoxHeight write FSetTitleBoxHeight;
    property DrawMode: TDrawMode read FDrawMode write FSetDrawMode;
    property ColorMode: TColorMode read FColorMode write FSetColorMode;
    property ShowPoints: boolean read FShowPoints write FSetShowPoints;
    property InfoFileds: TInfoFields read FInfoFields write FSetInfoFields;
    property ForceMiliSek: boolean read FForceMiliSek write FForceMiliSek;
    property flWyrownOkres: boolean read FflWyrownOkres write FflWyrownOkres;
    property WyrownOkres: real read FWyrownOkres write FWyrownOkres;
    property PanelTags: boolean read FgetPanelTags write FSetPanelTags;
    property TagKey: boolean read FTagKey write FSetTagKey;
  public
    procedure SetArea(RR: TRect);
    procedure LiczWymiary(aArea: TRect; RMode: TResizeMode; Dst: TPaintDest); overload;
    procedure LiczWymiary(RMode: TResizeMode; Dst: TPaintDest); overload;
    procedure LiczWymiary(RMode: TResizeMode); overload;
  private
    function GetActiveTagList: TTagList;
  public
    CanEditTags: boolean;
    function CanAddTag: boolean; overload;
    function CanAddTag(Tags: TTagList): boolean; overload;

    function CanDelTag: boolean;
  end;

const
  StabWorkMode: set of TWorkMode = [wmCursor, wmBox];

implementation

{$R wykres.res}

uses Types;

Const
  TIME_LWIDTH = 80;
  BAR_WIDTH = 12;
  SecPerDay = 24 * 3600; // ilosc sekund w dniu
  LINE_MARGIN = 2;
  SERIES_COLOR_TAB_LEN = 5;
  PANELS_COLOR_TAB_LEN = 4;
  TabSeriesColor: array [0 .. SERIES_COLOR_TAB_LEN - 1] of TColor = (clRed, clBlue, clGreen, clYellow, clBlack);

  TabPanelColor: array [0 .. PANELS_COLOR_TAB_LEN - 1] of TColor = (TColor($DCF0D2), TColor($DCF0FA), TColor($E6FAFA), TColor($FFF0F0));

  ACTIVE_COLOR = TColor($C8C896);

var
  SerieCnt: integer;
  PanelCnt: integer;

procedure CheckFreeAndNil(var Obj);
var
  Temp: TObject;
begin
  Temp := TObject(Obj);
  if Assigned(Temp) then
  begin
    Pointer(Obj) := nil;
    Temp.Free;
  end;
end;

function GetComplexUnit(Zakr: real; Units: string): string;
begin
  Result := Units;
  if Zakr < 1 then
    Result := 'm' + Units;
  if 1000 <= Zakr then
    Result := 'k' + Units;
  if 1000000 <= Zakr then
    Result := 'M' + Units;
end;

function ValToZakresStr(V, Zakr: real; Units: string): string;
var
  s: string;
begin
  if not(isNan(V)) and not(isNan(Zakr)) then
  begin
    s := '';
    if (Zakr < 0.100) then
      s := Format('%5.5fm', [1000 * V]); // 22.22 mV
    if (0.100 <= Zakr) and (Zakr < 1) then
      s := Format('%5.4f', [V]); // 222.2 mV
    if (1 <= Zakr) and (Zakr < 10) then
      s := Format('%5.3f', [V]); // 2.222 V
    if (10 <= Zakr) and (Zakr < 100) then
      s := Format('%5.2f', [V]); // 22.22 V
    if (100 <= Zakr) and (Zakr < 1000) then
      s := Format('%5.1f', [V]); // 222.2 V
    if (1000 <= Zakr) and (Zakr < 10000) then
      s := Format('%5.3fk', [V / 1000]); // 2.222 kV
    if (10000 <= Zakr) and (Zakr < 100000) then
      s := Format('%5.2fk', [V / 1000]); // 22.22 kV
    if (100000 <= Zakr) and (Zakr < 1000000) then
      s := Format('%5.1fk', [V / 1000]); // 222.2 kV
    if (1000000 <= Zakr) and (Zakr < 10000000) then
      s := Format('%5.3fM', [V / 1000000]); // 2.222 MV
    if (10000000 <= Zakr) then
      s := Format('%5.2fM', [V / 1000000]); // 22.22 MV

    Result := s + Units;
  end
  else
  begin
    Result := '--';
  end;
end;

function MakeMinI(a1, a2: integer): integer;
begin
  if a1 < a2 then
    Result := a1
  else
    Result := a2;
end;

function MakeMaxI(a1, a2: integer): integer;
begin
  if a1 > a2 then
    Result := a1
  else
    Result := a2;
end;

procedure Widelki(var x: integer; Mn, Mx: integer);
begin
  x := Max(x, Mn);
  x := Min(x, Mx);
end;

function HHR(r: TRect): integer;
begin
  Result := r.Bottom - r.Top;
end;

function WWR(r: TRect): integer;
begin
  Result := r.Right - r.Left;
end;

function InRect(r: TRect; x, Y, Margin: integer): boolean; overload;
begin
  Result := (x > r.Left + Margin) and (x < r.Right - Margin) and (Y > r.Top + Margin) and (Y < r.Bottom - Margin);
end;

function InRect(r: TRect; Pt: Tpoint; Margin: integer): boolean; overload;
begin
  Result := InRect(r, Pt.x, Pt.Y, Margin)
end;

function ClipRect(Owner, Clint: TRect): TRect;
begin
  Clint.Left := Max(Clint.Left, Owner.Left);
  Clint.Right := Max(Clint.Right, Owner.Left);
  Clint.Left := Min(Clint.Left, Owner.Right);
  Clint.Right := Min(Clint.Right, Owner.Right);

  Clint.Top := Max(Clint.Top, Owner.Top);
  Clint.Bottom := Max(Clint.Bottom, Owner.Top);
  Clint.Top := Min(Clint.Top, Owner.Bottom);
  Clint.Bottom := Min(Clint.Bottom, Owner.Bottom);
  Result := Clint;
end;

function InLeftLineRect(r: TRect; x, Y: integer): boolean;
begin
  Result := (x >= r.Left - LINE_MARGIN) and (x <= r.Left + LINE_MARGIN) and (Y > r.Top) and (Y < r.Bottom);
end;

function InBottomLineRect(r: TRect; x, Y: integer): boolean;
begin
  Result := (x > r.Left) and (x < r.Right) and (Y > r.Bottom - LINE_MARGIN) and (Y <= r.Bottom + LINE_MARGIN);
end;

procedure XorRectangle(Cv: TCanvas; r: TRect);
begin
  Cv.Pen.Mode := pmNotXor;
  Cv.MoveTo(r.Left, r.Top);
  Cv.LineTo(r.Left, r.Bottom);
  Cv.LineTo(r.Right, r.Bottom);
  Cv.LineTo(r.Right, r.Top);
  Cv.LineTo(r.Left, r.Top);
  Cv.Pen.Mode := pmCopy;
end;

procedure MeasureString(Cn: TCanvas; s: string; var w: integer; var H: integer); overload;
begin
  w := Cn.TextWidth(s);
  H := Cn.TextHeight(s);
end;

procedure MeasureString(Cn: TCanvas; s: string; var Pt: Tpoint); overload;
begin
  Pt.x := Cn.TextWidth(s);
  Pt.Y := Cn.TextHeight(s);
end;

procedure DrawList(Cn: TCanvas; RR: TRect; TS: TStringList; Clear: boolean);
var
  RR1: TRect;
  i: integer;
  w, H: integer;
begin
  if Clear then
  begin
    Cn.Rectangle(RR);
  end;

  i := 0;
  while i < TS.Count do
  begin
    MeasureString(Cn, 'A', w, H);
    RR1 := ClipRect(RR, Bounds(RR.Left + 2, RR.Top + i * H + 2, RR.Right - RR.Left - 4, H));
    Cn.TextRect(RR1, RR1.Left, RR1.Top, TS.Strings[i]);
    inc(i);
  end;
end;

function GetTmPrzedzial(Tm: real): TTmFormatMode; overload;
begin
  if Tm > 24 * 3600 then // gdy czas wiekszy od dnia
    Result := tfDay
  else if Tm > 3600 then // gdy czas wiekszy od godziny
    Result := tfHour
  else if Tm > 120 then // gdy czas wiekszy od 2 minut
    Result := tfMin
  else if Tm > 2 then
    Result := tfSec
  else
    Result := tfMSec;
end;

function GetTmPrzedzial(Tm1, Tm2: real): TTmFormatMode; overload;
var
  Dt: real;
begin
  Dt := abs(Tm2 - Tm1);
  Result := GetTmPrzedzial(Dt);
end;

// wejscie w milisekundach
function WykrTimeStr(Przedzial: TTmFormatMode; Tm: real; Jed: boolean): string;
var
  TmW: integer;
begin
  case Przedzial of
    tfDay:
      begin
        TmW := round(Tm / 3600);
        Result := Format('%ud%02uh', [TmW div 24, TmW mod 24]);
      end;
    tfHour:
      begin
        TmW := round(Tm / 60);
        Result := Format('%uh%02um', [TmW div 60, TmW mod 60]);
      end;
    tfMin:
      begin
        TmW := round(Tm);
        Result := Format('%um%02us', [TmW div 60, TmW mod 60]);
      end;
    tfSec:
      begin
        Result := Format('%.1fs', [Tm]);
      end;
    tfMSec:
      begin
        Tm := Tm * 1000;
        Result := Format('%.1f', [Tm]);
        if Jed then
          Result := Result + '[ms]';
      end;
  end;
end;

function WykrTrueTimeStr(Przedz: TTmFormatMode; Tm: real): string;
begin
  case Przedz of
    tfDay:
      begin
        DateTimeToString(Result, 'dd-hh-nn', Tm);
        Result[3] := 'd';
        Result[6] := 'h';
      end;
    tfHour:
      begin
        DateTimeToString(Result, 'hh-nn-ss', Tm);
        Result[3] := 'h';
        Result[6] := 'm';
      end;
    tfMin:
      begin
        DateTimeToString(Result, 'nn-ss-', Tm);
        Result[3] := 'm';
        Result[6] := 's';
      end;
    tfSec:
      begin
        DateTimeToString(Result, 'ss:zzz', Tm);
        Result[3] := 's';
      end;
  end;
end;

// ---------------------------------------------------------------------------
// TOrganizer
// ---------------------------------------------------------------------------
constructor TOrganizer.Create;
begin
  inherited;
  FSplitPanelList := TSplitPanelList.Create(self, false);
  FMemCanvas := TCanvas.Create;
  FCanvas := FMemCanvas;
  FPaintDst := toSCR;

  OnInvalidate := nil;
  OnHasFocus := nil;
  OnGetParentHandle := nil;
  OnIsUpDating := nil;
end;

constructor TOrganizer.Create(Cn: TCanvas);
begin
  Create;
  FSetCanvas(Cn);
end;

destructor TOrganizer.Destroy;
begin
  FSplitPanelList.Free;
  FMemCanvas.Free;
  inherited;
end;

procedure TOrganizer.FSetCanvas(Cn: TCanvas);
begin
  FCanvas := Cn;
  if FCanvas = nil then
    FCanvas := FMemCanvas;
end;

procedure TOrganizer.Invalidate;
begin
  if Assigned(OnInvalidate) then
    OnInvalidate(self);
end;

function TOrganizer.HasFocus: boolean;
begin
  if Assigned(OnHasFocus) then
    Result := OnHasFocus(self)
  else
    Result := false;
end;

function TOrganizer.GetParentHandle: THandle;
begin
  if Assigned(OnGetParentHandle) then
    Result := OnGetParentHandle(self)
  else
    Result := INVALID_HANDLE_VALUE;
end;

function TOrganizer.IsUpDating: boolean;
begin
  if Assigned(OnIsUpDating) then
    Result := OnIsUpDating(self)
  else
    Result := false;
end;

procedure TOrganizer.RemooveSplitPanel(Ob: TObject);
var
  N: integer;
begin
  N := FSplitPanelList.IndexOf(Ob);
  if N >= 0 then
    FSplitPanelList.Delete(N);
end;

procedure TOrganizer.FSetSplitWidth(w: real);
begin
  FSplitWidth := w;
  FSplitPanelList.DoSplitWidthChg;
  Invalidate;
end;

function TOrganizer.GetNextPanel(Panel: TGrSplitPanel): TGrSplitPanel;
begin
  Result := FSplitPanelList.GiveNextPanel(Panel, []);
end;

function TOrganizer.CanResizePanel(Panel: TGrSplitPanel): boolean;
begin
  Panel := FSplitPanelList.GiveNextPanel(Panel, [pnCanResize, pnActive]);
  Result := Assigned(Panel);
end;

function TOrganizer.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
begin
  Result := FSplitPanelList.MouseDown(Button, Shift, x, Y);
end;

function TOrganizer.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
begin
  inherited;
  FSplitPanelList.MouseUp(Button, Shift, x, Y);
  Result := false;
end;

function TOrganizer.MouseMove(Shift: TShiftState; x, Y: integer): boolean;
begin
  inherited;
  Screen.Cursor := crDefault;
  FSplitPanelList.MouseMove(Shift, x, Y);
  Result := false;
end;

function TOrganizer.SpliterRealToInt(r: real): integer;
begin
  Result := FArea.Left + round((FArea.Right - FArea.Left) * r / 100)
end;

function TOrganizer.SpliterIntToReal(r: integer): real;
begin
  Result := 100 * (r - FArea.Left) / (FArea.Right - FArea.Left);
end;

function TOrganizer.GetSpliterPos: integer;
begin
  Result := SpliterRealToInt(FSplitWidth);
end;

procedure TOrganizer.PaintTo(Quick: boolean);
begin
  FSplitPanelList.Paint(Quick);
end;

procedure TOrganizer.Paint;
begin
  PaintTo(false);
end;

procedure TOrganizer.PaintDraggedSplit(x: integer);
var
  Cn: TCanvas;
begin
  Cn := FCanvas;
  Cn.Pen.Color := clRed;
  Cn.Pen.Mode := pmNotXor;
  Cn.MoveTo(x - LINE_MARGIN, FArea.Top);
  Cn.LineTo(x - LINE_MARGIN, FArea.Bottom);
  Cn.MoveTo(x + LINE_MARGIN, FArea.Top);
  Cn.LineTo(x + LINE_MARGIN, FArea.Bottom);
end;

// ---------------------------------------------------------------------------
// TGrObject
// ---------------------------------------------------------------------------
constructor TGrObject.Create(aOwner: TOrganizer);
begin
  inherited Create;
  FOwner := aOwner;
end;

destructor TGrObject.Destroy;
begin
  inherited Create;
end;

function TGrObject.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
begin
  FClicked := true;
  Result := false;
end;

procedure TGrObject.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
begin
  FClicked := false;
end;

procedure TGrObject.MouseMove(Shift: TShiftState; x, Y: integer);
begin

end;

procedure TGrObject.Invalidate;
begin

end;

procedure TGrObject.FSetBkColor(aColor: TColor);
begin
  FBkColor := aColor;
  Invalidate;
end;

procedure TGrObject.Paint(Quick: boolean);
var
  Cn: TCanvas;
begin
  Cn := FOwner.FCanvas;
  Cn.Pen.Color := clRed;
  Cn.Pen.Style := psSolid;
  Cn.Brush.Style := bsClear;
  // Cn.Rectangle(ScrPos);
end;

function TGrObject.MouseOper: boolean;
begin
  Result := false;
end;

procedure TGrObject.FSetScrPos(r: TRect);
begin
  FScrPos := r;
end;

procedure TGrObject.StorePos;
begin
  FSavedPos := ScrPos;
end;

procedure TGrObject.ReStorePos;
begin
  ScrPos := FSavedPos;
end;

constructor TGrObjectList.Create(aOwner: TOrganizer);
begin
  inherited Create;
  FOwner := aOwner;
end;

constructor TGrObjectList.Create(aOwner: TOrganizer; AOwnsObjects: boolean);
begin
  inherited Create(AOwnsObjects);
  FOwner := aOwner;
end;

function TGrObjectList.FGetItem(Index: integer): TGrObject;
begin
  Result := inherited GetItem(Index) as TGrObject;
end;

function TGrObjectList.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to Count - 1 do
    Result := Result or Items[i].MouseDown(Button, Shift, x, Y);
end;

procedure TGrObjectList.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].MouseUp(Button, Shift, x, Y);
end;

procedure TGrObjectList.MouseMove(Shift: TShiftState; x, Y: integer);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].MouseMove(Shift, x, Y);
end;

procedure TGrObjectList.StorePos;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].StorePos;
end;

procedure TGrObjectList.ReStorePos;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].ReStorePos;
end;

procedure TGrObjectList.Paint(Quick: boolean);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    if not(Items[i] is TChartPanel) then
      Items[i].Paint(Quick);
  end;

  for i := 0 to Count - 1 do
  begin
    if Items[i] is TChartPanel then
      Items[i].Paint(Quick);
  end;
end;

function TGrObjectList.MouseOper: boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to Count - 1 do
  begin
    if Items[i].MouseOper then
    begin
      Result := true;
      break;
    end;
  end;
end;

// ---------------------------------------------------------------------------
// TGrScrollBar
// ---------------------------------------------------------------------------
Constructor TGrScrollBar.Create(aOwner: TOrganizer; aParent: TGrObject; aOrientation: TOrientation);
begin
  inherited Create(aOwner);
  FParent := aParent;
  Ftimer := TTimer.Create(nil);
  Ftimer.Enabled := false;
  Ftimer.OnTimer := FOnMoveTime;
  Ftimer.Interval := 200;
  OnPositonChg := nil;
  OnGetPosition := nil;
  Mooving := false;
  Jumping := false;
  Visible := true;

  FOrientation := aOrientation;
  FThickness := BAR_WIDTH;
  FSliderLength := 60;
  Fur := 0;
  Fdur := 1;

end;

destructor TGrScrollBar.Destroy;
begin
  Ftimer.Free;
  inherited;
end;

procedure TGrScrollBar.FSetThickness(w: integer);
begin
  FThickness := w;
  SetTimeVagonDim;
end;

procedure TGrScrollBar.FOnMoveTime(Sender: TObject);
var
  Str: real;
begin
  if Mooving then
  begin
    Ftimer.Enabled := false;
    Str := 0;
    case FOrientation of
      orHoriz:
        Str := (Wagon.Left - ScrPos.Left) / (ScrPos.Right - ScrPos.Left);
      orVert:
        Str := (Wagon.Top - ScrPos.Top) / (ScrPos.Bottom - ScrPos.Top);
    end;
    ExecOnPositonChg(Str, Fdur);
  end;
  if Jumping then
  begin
    if DoJump then
      Ftimer.Interval := 100
    else
      Ftimer.Enabled := false;
  end;
end;

function TGrScrollBar.DoJump: boolean;
var
  Str: real;
begin
  case FOrientation of
    orHoriz:
      begin
        Result := false;
        Str := 0;
        if JumpingDD < Wagon.Left then
        begin
          Str := Fur - 0.4 * Fdur;
          if Str < 0 then
            Str := 0;
          Result := true;
        end;
        if JumpingDD > Wagon.Right then
        begin
          Str := Fur + 0.4 * Fdur;
          if Str + Fdur > 1.0 then
            Str := 1.0 - Fdur;
          Result := true;
        end;
      end;
    orVert:
      begin
        Result := false;
        Str := 0;
        if JumpingDD < Wagon.Top then
        begin
          Str := Fur - 0.4 * Fdur;
          if Str < 0 then
            Str := 0;
          Result := true;
        end;
        if JumpingDD > Wagon.Bottom then
        begin
          Str := Fur + 0.4 * Fdur;
          if Str + Fdur > 1.0 then
            Str := 1.0 - Fdur;
          Result := true;
        end;
      end;
  else
    Str := Fur;
    Result := false;
  end;
  if Result then
    ExecOnPositonChg(Str, Fdur);
end;

procedure TGrScrollBar.FSetSliderLength(w: integer);
begin
  FSliderLength := w;
  SetTimeVagonDim;
  Invalidate;
end;

procedure TGrScrollBar.ExecOnPositonChg(u, du: real);
begin
  Fur := u;
  Fdur := du;
  if Assigned(OnPositonChg) then
  begin
    OnPositonChg(self, u, du);
  end;
end;

procedure TGrScrollBar.SetTimeVagonDim;
var
  w: integer;
  ur, dur: real;
  u, du: integer;
begin
  ur := Fur;
  dur := Fdur;
  if Assigned(OnGetPosition) then
    OnGetPosition(self, ur, dur);

  if ur < 0 then
    ur := 0;
  if ur > 1 then
    ur := 1;

  if dur < 0 then
    dur := 0;
  if dur > 1 then
    dur := 1;
  if dur > 1 then
    dur := 1;
  if dur + ur > 1 then
    ur := 1 - dur;

  Fur := ur;
  Fdur := dur;

  w := 1; // zeby kompilator siê uspokoi³
  u := 1;
  case FOrientation of
    orHoriz:
      begin
        w := ScrPos.Right - ScrPos.Left;
        u := ScrPos.Left + round(ur * w);
      end;
    orVert:
      begin
        w := ScrPos.Bottom - ScrPos.Top;
        u := ScrPos.Top + round(ur * w);
        // u  := ScrPos.Bottom-round(ur*w);
      end;
  end;

  du := round(dur * w);
  if du < 5 then
    du := 5;
  case FOrientation of
    orHoriz:
      Wagon := Rect(u, ScrPos.Top, u + du, ScrPos.Bottom);
    orVert:
      Wagon := Rect(ScrPos.Left, u, ScrPos.Right, u + du);
  end;
end;

procedure TGrScrollBar.FSetScrPos(r: TRect);
begin
  inherited;
end;

procedure TGrScrollBar.SetPosition(x, Y, aLength: integer);
begin
  case FOrientation of
    orHoriz:
      ScrPos := Bounds(x, Y, aLength, FThickness);
    orVert:
      ScrPos := Bounds(x, Y, FThickness, aLength);
  end;
  SetTimeVagonDim;
end;

procedure TGrScrollBar.UpdatePos;
begin
  SetTimeVagonDim;
  Paint(false);
end;

function TGrScrollBar.IsZoomed: boolean;
const
  MinZero = 1E-8;
begin
  Result := abs(Fdur - 1.0) > MinZero;
end;

procedure TGrScrollBar.Paint(Quick: boolean);
var
  V: integer;
  Wykr: TWykresEng;
  Cn: TCanvas;
begin
  if Quick then
    Exit;
  if Visible then
  begin
    Cn := FOwner.FCanvas;
    Wykr := FOwner as TWykresEng;
    if ScrPos.Top <> ScrPos.Bottom then
    begin
      Cn.Brush.Style := bsSolid;
      if IsZoomed then
      begin
        Cn.Brush.Color := clSilver;
        Cn.Pen.Color := clSilver;
        if Wykr.FColorMode <> pmdFullColor then
        begin
          Cn.Brush.Color := clWhite;
          Cn.Pen.Color := clBlack;
        end;

        case FOrientation of
          orHoriz:
            begin
              Cn.Rectangle(ScrPos.Left, ScrPos.Top, Wagon.Left, ScrPos.Bottom);
              Cn.Rectangle(Wagon.Right, ScrPos.Top, ScrPos.Right, ScrPos.Bottom);
            end;
          orVert:
            begin
              Cn.Rectangle(ScrPos.Left, ScrPos.Top, ScrPos.Right, Wagon.Top);
              Cn.Rectangle(ScrPos.Left, Wagon.Bottom, ScrPos.Right, ScrPos.Bottom);
            end;
        end;

        Cn.Pen.Color := clBlack;
        Cn.Brush.Color := clGray;
        if Wykr.FColorMode <> pmdFullColor then
          Cn.Brush.Color := clBlack;

        case FOrientation of
          orHoriz:
            begin
              V := (ScrPos.Top + ScrPos.Bottom) div 2;
              Cn.Rectangle(ScrPos.Left, V - 2, Wagon.Left, V + 2);
              Cn.Rectangle(Wagon.Right, V - 2, ScrPos.Right, V + 2);
            end;
          orVert:
            begin
              V := (ScrPos.Left + ScrPos.Right) div 2;
              Cn.Rectangle(V - 2, ScrPos.Top, V + 2, Wagon.Top);
              Cn.Rectangle(V - 2, Wagon.Bottom, V + 2, ScrPos.Bottom);
            end;
        end;

        Cn.Brush.Color := clSuwak;
        Cn.Brush.Style := bsSolid;
        if Wykr.FColorMode <> pmdFullColor then
        begin
          Cn.Brush.Color := clBlack;
          if FOwner.FPaintDst = toPRN then
            Cn.Brush.Style := bsDiagCross;
        end;
        Cn.Rectangle(Wagon);
        Cn.Brush.Style := bsSolid;
      end
      else
      begin
        {
          Cn.Pen.Color:=FParent.BkColor;
          Cn.Brush.Color:=FParent.BkColor;
          Cn.Rectangle(ScrPos);
        }
      end;
    end;
  end;
end;

function TGrScrollBar.MouseOper: boolean;
begin
  Result := inherited MouseOper or Mooving or Jumping;
end;

function TGrScrollBar.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
begin
  Result := inherited MouseDown(Button, Shift, x, Y);
  if (Button = mbLeft) and Visible and (Fdur <> 1.0) then
  begin
    if InRect(ScrPos, x, Y, 2) then
    begin
      if InRect(Wagon, x, Y, 0) then
      begin
        Mooving := true;
        case FOrientation of
          orHoriz:
            MoovingDD := x - Wagon.Left;
          orVert:
            MoovingDD := Y - Wagon.Top;
        end;
      end
      else
      begin
        Jumping := true;
        case FOrientation of
          orHoriz:
            JumpingDD := x;
          orVert:
            JumpingDD := Y;
        end;
        Ftimer.Enabled := false;
        Ftimer.Interval := 100;
        Ftimer.Enabled := true;
      end;
      Result := true;
    end;
  end;
end;

procedure TGrScrollBar.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
var
  Str: real;
begin
  inherited;
  if Visible then
  begin
    if Jumping then
    begin
      case FOrientation of
        orHoriz:
          JumpingDD := x;
        orVert:
          JumpingDD := Y;
      end;
    end;
    if Mooving then
    begin
      Str := 0; // zeby kompilator siê uspokoil
      case FOrientation of
        orHoriz:
          Str := (Wagon.Left - ScrPos.Left) / (ScrPos.Right - ScrPos.Left);
        orVert:
          Str := (Wagon.Top - ScrPos.Top) / (ScrPos.Bottom - ScrPos.Top);
      end;
      ExecOnPositonChg(Str, Fdur);
      Mooving := false;
    end;
  end;
end;

procedure TGrScrollBar.MouseMove(Shift: TShiftState; x, Y: integer);
var
  V: integer;
  uu: integer;
  InBar: boolean;
begin
  inherited;
  if Visible and (Fdur <> 1.0) then
  begin
    if Jumping then
    begin
      Jumping := false;
      DoJump;
    end;

    if Mooving then
    begin
      InBar := false;
      case FOrientation of
        orHoriz:
          begin
            V := Wagon.Right - Wagon.Left;
            uu := Wagon.Left;
            Wagon.Left := x - MoovingDD;
            Widelki(Wagon.Left, ScrPos.Left, ScrPos.Right - V);
            Wagon.Right := Wagon.Left + V;
            InBar := abs(uu - Wagon.Left) > 0;
          end;
        orVert:
          begin
            V := Wagon.Bottom - Wagon.Top;
            uu := Wagon.Top;
            Wagon.Top := Y - MoovingDD;
            Widelki(Wagon.Top, ScrPos.Top, ScrPos.Bottom - V);
            Wagon.Bottom := Wagon.Top + V;
            InBar := abs(uu - Wagon.Top) > 0;
          end
      end;
      if InBar then
      begin
        Ftimer.Enabled := false;
        Ftimer.Interval := 100;
        Ftimer.Enabled := true;
      end;
    end;

    if InRect(ScrPos, x, Y, 2) then
    begin
      if InRect(Wagon, x, Y, 0) then
        Screen.Cursor := crHandPoint
      else
      begin
        case FOrientation of
          orHoriz:
            begin
              if x < Wagon.Left + 2 then
                Screen.Cursor := crSizeW
              else
                Screen.Cursor := crSizeE;
            end;
          orVert:
            begin
              Screen.Cursor := crSizeNS;
              if Y < Wagon.Top + 2 then
                Screen.Cursor := crSizeS
              else
                Screen.Cursor := crSizeN;

            end;
        end;
      end;
    end;
  end;
end;

// ---------------------------------------------------------------------------
// TSiatka
// ---------------------------------------------------------------------------
function TSiatkaItem.IsZero: boolean;
begin
  Result := abs(ValR - 0) < 1E-8;
end;

constructor TSiatka.Create(aOwner: TOrganizer; Orien: TOrientation);
begin
  inherited Create(aOwner);
  FList := TObjectList.Create;
  FOrientation := Orien;
  OnGetItemTxt := nil;
  case FOrientation of
    orHoriz:
      Xinterval := 70;
    orVert:
      Xinterval := 30;
  end;
end;

destructor TSiatka.Destroy;
begin
  FList.Free;
  inherited;
end;

function TSiatka.FGetItem(Index: integer): TSiatkaItem;
begin
  Result := FList.Items[index] as TSiatkaItem;
end;

function TSiatka.Count: integer;
begin
  Result := FList.Count;
end;

function TSiatka.ExecOnGetItemTxt(t: real): string;
begin
  if Assigned(OnGetItemTxt) then
    Result := OnGetItemTxt(self, t)
  else
  begin
    Result := WykrTimeStr(FTmPrze, t, false);
  end;
end;

procedure TSiatka.Build(BegV, EndV: real; Area: TRect; BegX, EndX, LinePos: integer; Align: TLeftRight);
const
  MIN_DX = 5;
var
  Dt: double;
  deg: double;
  deg2: double;
  t: double;
  dx: integer;
  dx1: integer;
  Nmax: integer;
  dd, ddt: double;
  k: double;
  Item: TSiatkaItem;
  i: integer;
  impT: double;
  minDiff: double;
  x: integer;
  mjr: boolean;
begin
  FList.Clear;
  FBegV := BegV;
  FEndV := EndV;
  FLinePos := LinePos;
  FSArea := Area;
  FAlign := Align;

  FTmPrze := GetTmPrzedzial(FBegV, FEndV);
  dx := EndX - BegX;

  Nmax := round(dx / Xinterval);
  if Nmax > 0 then
  begin
    Dt := EndV - BegV;
    if Dt <> 0 then
    begin
      ddt := Dt / Nmax;
      dd := log10(ddt);
      if dd > 0 then
        dd := trunc(dd)
      else
        dd := trunc(dd) - 1;

      deg := Power(10, dd);
      k := ddt / deg;
      if k > 5 then
      begin
        deg2 := deg * 2;
        deg := deg * 10;
      end
      else if k > 2 then
      begin
        deg2 := deg;
        deg := deg * 5
      end
      else
      begin
        deg2 := deg;
        deg := deg * 2;
      end;

      if deg = Dt then
      begin
        deg2 := deg2 / 10;
        deg := deg / 10;
      end;

      t := deg * (trunc(BegV / deg));
      while t > BegV do
        t := t - deg;

      impT := t;
      minDiff := 0.1 * deg;
      while t < EndV do
      begin
        if t >= BegV then
        begin
          mjr := false;
          if abs(t - impT) < minDiff then
          begin
            impT := impT + deg;
            mjr := true;
          end;

          x := round((t - BegV) / (EndV - BegV) * (EndX - BegX) + BegX);
          if (abs(x - BegX) > MIN_DX) and (abs(x - EndX) > MIN_DX) then
          begin
            Item := TSiatkaItem.Create;
            FList.Add(Item);
            Item.ValR := t;

            Item.Major := mjr;
            case FOrientation of
              orHoriz:
                begin
                  Item.Txt := ExecOnGetItemTxt(t);
                  Item.PosX := x;
                end;
              orVert:
                begin
                  Item.Txt := ExecOnGetItemTxt(t);
                  Item.PosX := EndX - (x - BegX);
                end;
            end;
          end;
        end;
        t := t + deg2;
        if t - impT > minDiff then
          impT := impT + deg;
      end;

      FMinDx := EndX - BegX;
      for i := 0 to FList.Count - 2 do
      begin
        dx1 := Items[i + 1].PosX - Items[i].PosX;
        if dx1 < FMinDx then
          FMinDx := dx1;
      end;
    end;
  end;
end;

procedure TSiatka.Paint(Quick: boolean);
var
  i: integer;
  w, H: integer;
  s: string;
  L: integer;
  Cn: TCanvas;
begin
  if Quick then
    Exit;
  Cn := FOwner.FCanvas;
  Cn.Brush.Style := bsClear;
  Cn.Pen.Color := clBlack;
  Cn.Pen.Style := psSolid;

  for i := 0 to FList.Count - 1 do
  begin
    s := Items[i].Txt;

    MeasureString(Cn, s, w, H);
    case FOrientation of
      orHoriz:
        begin
          L := 3;
          if Items[i].Major then
          begin
            Cn.TextRect(FSArea, Items[i].PosX - w div 2, FLinePos + 6, s);
            L := 8;
          end;
          Cn.MoveTo(Items[i].PosX, FLinePos);
          Cn.LineTo(Items[i].PosX, FLinePos + L);
        end;
      orVert:
        begin
          case FAlign of
            taLeftJustify:
              begin
                L := 3;
                if Items[i].Major then
                begin
                  Cn.TextRect(FSArea, FLinePos + 2, Items[i].PosX - H, s);
                  L := 5;
                end;
                Cn.MoveTo(FLinePos, Items[i].PosX);
                Cn.LineTo(FLinePos + L, Items[i].PosX);
              end;
            taRightJustify:
              begin
                L := 5;
                if Items[i].Major then
                begin
                  Cn.TextRect(FSArea, FLinePos - 4 - w, Items[i].PosX - H, s);
                  L := 8;
                end;
                Cn.MoveTo(FLinePos - L, Items[i].PosX);
                Cn.LineTo(FLinePos, Items[i].PosX);
              end;
          end;
        end;
    end;
  end;
end;

// ---------------------------------------------------------------------------
// TSeries
// ---------------------------------------------------------------------------
constructor TSerie.Create(Wykres: TWykresEng; Panel: TChartPanel; aDtnr: integer);
begin
  inherited Create;
  FDtNr := aDtnr;
  FWykres := Wykres;
  FPanel := Panel;
  PenColor := TabSeriesColor[SerieCnt mod SERIES_COLOR_TAB_LEN];
  inc(SerieCnt);
  FProbCntLocal := false;
  FDtPerProbkaLocal := false;
  FVisible := true;
  FDtPerProbka := Wykres.DtPerProbka;
end;

function TSerie.FGetDtPerProbka: real;
begin
  if FDtPerProbkaLocal then
    Result := FDtPerProbka
  else
    Result := FWykres.DtPerProbka;
end;

procedure TSerie.FSetDtPerProbka(aDtPerProbka: real);
begin
  FDtPerProbkaLocal := true;
  FDtPerProbka := aDtPerProbka;
end;

procedure TSerie.FSetProbCnt(cnt: integer);
begin
  FProbCntLocal := true;
  FProbCnt := cnt;
end;

procedure TSerie.FSetVisible(q: boolean);
begin
  FVisible := q;
  FWykres.Invalidate;
end;

function TSerie.FGetProbCnt: integer;
begin
  if FProbCntLocal then
    Result := FProbCnt
  else
    Result := FWykres.ProbCnt;
end;

function TSerie.GetNrPr(Tm: double): integer;
var
  Dt: real;
begin
  Result := -1;
  Dt := DtPerProbka;
  if Dt <> 0 then
    Result := round((Tm - ShiftTime) / Dt);
  if Result < 0 then
    Result := -1;
  if Result >= ProbCnt then
    Result := -1;
end;

constructor TSerieList.Create(Wykres: TWykresEng; Panel: TChartPanel);
begin
  inherited Create;
  FWykres := Wykres;
  FPanel := Panel;
end;

function TSerieList.FGetItem(Index: integer): TSerie;
begin
  Result := inherited GetItem(Index) as TSerie;
end;

procedure TSerieList.Add(Item: TSerie);
begin
  inherited Add(Item);
end;

// ---------------------------------------------------------------------------
// TAnalogSeries
// ---------------------------------------------------------------------------

constructor TAnalogSerie.Create(Wykres: TWykresEng; Panel: TChartPanel; aDtnr: integer);
begin
  inherited;
  FMinMaxVExist := false;
end;

procedure TAnalogSerie.LiczMinMax(StartProb, EndProb: integer);
var
  aMin, aMax: double;
  aFirst: boolean;
  aExist: boolean;
  aVal: double;
  i: integer;
begin
  if Assigned(FWykres.FOnGetAnValue) and (ProbCnt > 0) then
  begin
    aExist := false;
    aFirst := false;

    i := StartProb;
    while (i < EndProb) and not(aFirst) do
    begin
      FWykres.FOnGetAnValue(self, FDtNr, i, aVal, aExist);
      if aExist and not(isNan(aVAl)) then
      begin
        aFirst:=true;

      end;
      inc(i);
    end;
    aMin := aVal;
    aMax := aVal;

    while i < EndProb do
    begin
      FWykres.FOnGetAnValue(self, FDtNr, i, aVal, aExist);
      if aExist and not(isNan(aVal)) then
      begin
        if aVal > aMax then
          aMax := aVal;
        if aVal < aMin then
          aMin := aVal;
      end;
      inc(i);
    end;
    if aFirst then
    begin
      FMaxV := aMax;
      FMinV := aMin;
      FMinMaxVExist := true;
    end;
  end;
end;

procedure TAnalogSerie.LiczMinMax;
begin
  LiczMinMax(0, ProbCnt);
end;

// tm - czas w sekundach
procedure TAnalogSerie.GetValAt(Tm: real; var Val: double; var Exist: boolean);
var
  nr: integer;
begin
  nr := GetNrPr(Tm);
  Exist := (nr >= 0);
  if Exist then
  begin
    FWykres.FOnGetAnValue(FWykres, FDtNr, nr, Val, Exist);
  end;
end;

function TAnalogSerie.LiczY(V: real): integer;
begin
  Result := (FPanel as TAnalogPanel).LiczY(V);
end;

procedure TAnalogSerie.Paint(Quick: boolean);
var
  i: integer;
  x: double;
  xi: integer;
  dx: double;
  RR: TRect;
  WW, XX: integer;
  N: integer;
  LastX, LastY: integer;
  NextX: double;
  LastYR: double;
  MaxP, MinP: double;
  V: double;
  Exist: boolean;
  DrawIt: boolean;
  AnyExist: boolean;
  LastExist: boolean;
  LineWidth: integer;
  PtCnt: integer;
  // TT           : cardinal;
  PtCntL: integer;
  PtCntR: double;
  DoGroup: boolean;
  CxDataBuf: TCxDataBuf;
  Cn: TCanvas;
  Dst: TPaintDest;
begin
  if Quick then
    Exit;
  if not(Visible) then
    Exit;

  if not Assigned(FWykres) then
    Exit;
  if not Assigned(FWykres.FOnGetAnValue) then
    Exit;
  if ProbCnt = 0 then
    Exit;

  Cn := FWykres.FCanvas;
  Dst := FWykres.PaintDest;

  DrawIt := true;

  if DrawIt then
  begin
    // TT := GetTickCount;
    RR := FPanel.FDataArea;
    WW := RR.Right - RR.Left;
    XX := RR.Left;

    Cn.Pen.Color := PenColor;
    Cn.Brush.Color := FPanel.FBkColor;
    if FWykres.FColorMode <> pmdFullColor then
      Cn.Brush.Color := clWhite;
    Cn.Brush.Style := bsClear;

    // rysowanie danych    .
    LineWidth := 1;
    if Dst = toPRN then
      LineWidth := (WW div 1000) + 1;

    N := round(ProbCnt * FWykres.FTimeWindowDelta); // iloœæ próbek ba ekranie
    if N = 0 then
      N := 1;
    dx := WW;
    dx := dx / N;
    N := round(FWykres.FTimeWindowStart * ProbCnt);
    x := XX;

    LastExist := false;
    MaxP := 0;
    MinP := 0;
    LastX := trunc(x);
    LastYR := 0;
    LastY := 0;
    while (x < XX + WW - 2) and (N < ProbCnt) do
    begin
      Cn.Pen.Color := PenColor;
      AnyExist := false;
      PtCnt := 0;
      NextX := LastX + 1;

      PtCntL := 0;
      DoGroup := false;
      if Assigned(FWykres.FOnGetGroupAnValue) then
      begin
        PtCntR := (NextX - x) / dx;
        PtCntL := trunc(PtCntR);
        if PtCntL <> PtCntR then
          inc(PtCntL);
        DoGroup := (PtCntL > 2);
      end;

      if not(DoGroup) then
      begin
        FWykres.FOnGetAnValue(FWykres, FDtNr, N, V, Exist);
        MaxP := V;
        MinP := V;

        while (x <= NextX) and (N < ProbCnt) do
        begin
          FWykres.FOnGetAnValue(FWykres, FDtNr, N, V, Exist);
          if Exist and not(isNan(V)) then
          begin
            if V > MaxP then
              MaxP := V;
            if V < MinP then
              MinP := V;
            AnyExist := true;
          end;
          x := x + dx;
          inc(PtCnt);
          inc(N);
        end;
      end
      else
      begin
        if Length(CxDataBuf) < PtCntL then
          SetLength(CxDataBuf, PtCntL + 20); // ma³y zapasik
        FWykres.FOnGetGroupAnValue(FWykres, FDtNr, N, PtCntL, CxDataBuf);
        i := 0;
        while i < PtCntL do
        begin
          if CxDataBuf[i].Exist then
          begin
            V := CxDataBuf[i].V;
            MaxP := V;
            MinP := V;
            AnyExist := true;
          end;
          inc(i);
          if AnyExist then
            break;
        end;
        while i < PtCntL do
        begin
          if CxDataBuf[i].Exist then
          begin
            V := CxDataBuf[i].V;
            if V > MaxP then
              MaxP := V;
            if V < MinP then
              MinP := V;
          end;
          inc(i);
        end;
        inc(N, PtCntL);
        x := x + PtCntL * dx;
      end;

      xi := trunc(x);
      if AnyExist then
      begin
        // rysowanie przebiegu
        Cn.Pen.Width := LineWidth;
        if x < XX + WW - 2 then
        begin
          if FWykres.FColorMode = pmdMono then
            Cn.Pen.Color := clBlack;
          if LastExist then
          begin
            if (FWykres.FDrawMode = dmCROSS) or ((FWykres.FDrawMode = dmSTAIRS) and (PtCnt > 1)) then
            begin
              if abs(LastYR - MinP) < abs(LastYR - MaxP) then
              begin
                Cn.LineTo(xi, LiczY(MinP));
                Cn.LineTo(xi, LiczY(MaxP));
                LastYR := MaxP;
              end
              else
              begin
                Cn.LineTo(xi, LiczY(MaxP));
                Cn.LineTo(xi, LiczY(MinP));
                LastYR := MinP;
              end;
            end;
            if (FWykres.FDrawMode = dmSTAIRS) and (PtCnt = 1) then
            begin
              Cn.LineTo(xi, LiczY(LastYR));
              Cn.LineTo(xi, LiczY(MaxP));
              LastYR := MaxP;
            end;
          end
          else
          begin
            Cn.MoveTo(xi, LiczY(MinP));
            Cn.LineTo(xi, LiczY(MaxP));
            LastYR := MaxP;
          end;
        end;
        // rysowanie koleczek
        if FWykres.FShowPoints then
        begin
          Cn.Pen.Width := 1;
          if LastExist and (dx > 5) then
          begin
            Cn.Pen.Color := clBlack;
            Cn.Rectangle(LastX + 2, LastY + 2, LastX - 2, LastY - 2);
          end;
        end;
        LastY := LiczY(LastYR);
      end;
      LastExist := AnyExist;
      LastX := xi;
    end;
    // TT := GetTickCount-TT;
    // OutputDebugString(pchar(Format('NrD=%u TT=%u',[FDtNr,TT])));
  end;
end;

procedure TAnalogSerie.FSetVisible(q: boolean);
begin
  inherited;
  FWykres.SetMyPomiarBlok;
end;

procedure TAnalogSerie.LiczPomiarBlok(SL: TStrings; StartProb, EndProb: integer);
var
  i: integer;
  V: double;
  Exist: boolean;
  SumaKw: Extended;
  Suma: Extended;
  AVR: Extended;
  SumaDf: Extended;
  aMin, aMax: double;
  First: boolean;
  NN: integer;
begin
  if not Assigned(FWykres) then
    Exit;
  if not Assigned(FWykres.FOnGetAnValue) then
    Exit;
  First := true;

  if (EndProb > StartProb + 1) and (StartProb <> -1) and (EndProb <> -1) then
  begin
    Suma := 0;
    SumaKw := 0;
    aMin := 0;
    aMax := 0;
    NN := 0;
    for i := StartProb to EndProb do
    begin
      FWykres.FOnGetAnValue(self, FDtNr, i, V, Exist);
      if Exist then
      begin
        if (V > aMax) or First then
          aMax := V;
        if (V < aMin) or First then
          aMin := V;
        Suma := Suma + V;
        SumaKw := SumaKw + V * V;
        First := false;
        inc(NN);
      end;
    end;
    if NN <> 0 then
    begin
      AVR := Suma / NN;
      SumaDf := 0;
      for i := StartProb to EndProb do
      begin
        FWykres.FOnGetAnValue(self, FDtNr, i, V, Exist);
        if Exist then
        begin
          V := V - AVR;
          SumaDf := SumaDf + V * V;
        end;
      end;
      SL.Add('');
      if ifRMS in FWykres.FInfoFields then
      begin
        V := sqrt(SumaKw / NN);
        SL.Add('RMS=' + ValToZakresStr(V, abs(V), FPanel.Units));
      end;
      if ifAVR in FWykres.FInfoFields then
      begin
        V := AVR;
        SL.Add('AVR=' + ValToZakresStr(V, abs(V), FPanel.Units));
      end;
      if ifRMZ in FWykres.FInfoFields then
      begin
        V := sqrt(SumaDf / NN);
        SL.Add('RMZ=' + ValToZakresStr(V, abs(V), FPanel.Units));
      end;
      if ifMAX in FWykres.FInfoFields then
      begin
        V := aMax;
        SL.Add('MAX=' + ValToZakresStr(V, abs(V), FPanel.Units));
      end;
      if ifMIN in FWykres.FInfoFields then
      begin
        V := aMin;
        SL.Add('MIN=' + ValToZakresStr(V, abs(V), FPanel.Units));
      end;
    end;
    if Assigned(FWykres.FOnSetPomiarBlok) then
      FWykres.FOnSetPomiarBlok(FWykres, FDtNr, StartProb, EndProb, SL);
  end;
end;

// ---------------------------------------------------------------------------
// TAnlalogSerieList
// ---------------------------------------------------------------------------

function TAnlalogSerieList.FGetItem(Index: integer): TAnalogSerie;
begin
  Result := inherited GetItem(Index) as TAnalogSerie;
end;

procedure TAnlalogSerieList.Add(Serie: TAnalogSerie);
begin
  inherited Add(Serie);
  Serie.FPanel := FPanel;
end;

function TAnlalogSerieList.CreateNew(aDtnr: integer): TAnalogSerie;
begin
  Result := TAnalogSerie.Create(FWykres, FPanel, aDtnr);
  Add(Result);
end;

procedure TAnlalogSerieList.LiczPomiarBlok(SL: TStrings; StartProb, EndProb: integer);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[i].Visible then
      Items[i].LiczPomiarBlok(SL, StartProb, EndProb);
  end;
end;

procedure TAnlalogSerieList.LiczMinMax(StartProb, EndProb: integer);
var
  i: integer;
  First: boolean;
begin
  FminMaxExist := false;
  First := true;
  for i := 0 to Count - 1 do
  begin
    if Items[i].Visible then
    begin
      Items[i].LiczMinMax(StartProb, EndProb);
      if Items[i].FMinMaxVExist then
      begin
        if First or (Items[i].FMaxV > FMaxV) then
          FMaxV := Items[i].FMaxV;
        if First or (Items[i].FMinV < FMinV) then
          FMinV := Items[i].FMinV;
        First := false;
        FminMaxExist := true;
      end;
    end;
  end;
end;

procedure TAnlalogSerieList.LiczMinMax;
begin
  LiczMinMax(0, FWykres.ProbCnt);
end;


// ---------------------------------------------------------------------------
// TDigitalSerie
// ---------------------------------------------------------------------------

function TDigitalSerieList.FGetItem(Index: integer): TDigitalSerie;
begin
  Result := inherited GetItem(Index) as TDigitalSerie;
end;

procedure TDigitalSerieList.Add(Serie: TDigitalSerie);
begin
  inherited Add(Serie);
end;

function TDigitalSerieList.CreateNew(aDtnr: integer): TDigitalSerie;
begin
  Result := TDigitalSerie.Create(FWykres, FPanel, aDtnr);
  Add(Result);
end;


// ---------------------------------------------------------------------------
// TGrSplitPanel
// ---------------------------------------------------------------------------

constructor TGrSplitPanel.Create(aOwner: TOrganizer);
begin
  inherited Create(aOwner);
  FOwner.FSplitPanelList.Add(self);
  FDragged := false;
  PanelOptions := [pnVisible, pnCanResize];
end;

destructor TGrSplitPanel.Destroy;
begin
  inherited;
  if Assigned(FOwner) then
    FOwner.RemooveSplitPanel(self)
end;

function TGrSplitPanel.FGetVisible: boolean;
begin
  Result := (pnVisible in PanelOptions);
end;

function TGrSplitPanel.FGetFocused: boolean;
begin
  Result := (pnFocused in PanelOptions);
end;

procedure TGrSplitPanel.FSetVisible(q: boolean);
begin
  if q <> FGetVisible then
  begin
    if q then
      PanelOptions := PanelOptions + [pnVisible]
    else
      PanelOptions := PanelOptions - [pnVisible];
    (FOwner as TWykresEng).LiczWymiary(rsmProportional);
  end;
end;

procedure TGrSplitPanel.SetSplit(spl: integer);
begin
  Invalidate;
end;

procedure TGrSplitPanel.SetPosition(aTop, aHeight: integer);
var
  x, w: integer;
begin
  x := FOwner.FArea.Left;
  w := FOwner.FArea.Right - FOwner.FArea.Left;
  ScrPos := Bounds(x, aTop, w, aHeight);
end;

function TGrSplitPanel.CheckOverSplit(x, Y: integer): boolean;
var
  r: TRect;
begin
  r := ScrPos;
  r.Left := FOwner.GetSpliterPos;
  Result := InLeftLineRect(r, x, Y);
end;

function TGrSplitPanel.CheckOverBottom(x, Y: integer): boolean;
begin
  Result := InBottomLineRect(ScrPos, x, Y);
  if Result then
    Result := FOwner.CanResizePanel(self);
end;

procedure TGrSplitPanel.PaintDraggedResize(Y: integer);
var
  Cn: TCanvas;
begin
  Cn := FOwner.FCanvas;
  Cn.Pen.Color := clRed;
  Cn.Pen.Mode := pmNotXor;
  Cn.MoveTo(ScrPos.Left, Y - LINE_MARGIN);
  Cn.LineTo(ScrPos.Right, Y - LINE_MARGIN);
  Cn.MoveTo(ScrPos.Left, Y + LINE_MARGIN);
  Cn.LineTo(ScrPos.Right, Y + LINE_MARGIN);
end;

procedure TGrSplitPanel.ExecPaintDraggedSplit(x: integer);
begin
  if Assigned(FOwner) then
    FOwner.PaintDraggedSplit(x);
end;

procedure TGrSplitPanel.SetFocused;
begin
  if pnCanFocus in PanelOptions then
  begin
    FOwner.FSplitPanelList.SetFocus(self);
    FOwner.Invalidate;
  end;
end;

function TGrSplitPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
begin
  Result := inherited MouseDown(Button, Shift, x, Y);
  if Button = mbLeft then
  begin
    if CheckOverSplit(x, Y) then
    begin
      FDragged := true;
      FDraggedSplit := x;
      ExecPaintDraggedSplit(FDraggedSplit);
      Result := true;
    end;
    if CheckOverBottom(x, Y) then
    begin
      FpanelResize := true;
      FResizePosY := Y;
      PaintDraggedResize(FResizePosY);
      Result := true;
    end;
  end;
end;

procedure TGrSplitPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
var
  Panel: TGrSplitPanel;
begin
  inherited;
  if FDragged then
  begin
    if Assigned(FOwner) then
    begin
      FDraggedSplit := x;
      ExecPaintDraggedSplit(FDraggedSplit);
      FOwner.SplitWidth := FOwner.SpliterIntToReal(FDraggedSplit - FOwner.FArea.Left);
    end;
    FDragged := false;
  end;
  if FpanelResize then
  begin
    PaintDraggedResize(FResizePosY);
    Panel := FOwner.GetNextPanel(self);
    if Assigned(Panel) then
    begin
      ReSizePanel(Y - ScrPos.Bottom);
      Panel.ReSizePanel(ScrPos.Bottom - Y);
    end;
    FpanelResize := false;
    (FOwner as TWykresEng).LiczWymiary(rsmProportional);
    (FOwner as TWykresEng).Invalidate;
  end;
end;

procedure TGrSplitPanel.MouseMove(Shift: TShiftState; x, Y: integer);
begin
  inherited;
  if CheckOverSplit(x, Y) or FDragged then
  begin
    Screen.Cursor := crHSplit;
    if FDragged then
    begin
      ExecPaintDraggedSplit(FDraggedSplit);
      FDraggedSplit := x;
      ExecPaintDraggedSplit(FDraggedSplit);
    end;
  end;

  if CheckOverBottom(x, Y) or FpanelResize then
  begin
    Screen.Cursor := crVSplit;
    if FpanelResize then
    begin
      PaintDraggedResize(FResizePosY);
      FResizePosY := Y;
      PaintDraggedResize(FResizePosY);
    end;
  end;
end;

function TGrSplitPanel.MouseOper: boolean;
begin
  Result := inherited MouseOper or FDragged or FpanelResize;
end;

procedure TGrSplitPanel.DoSplitWidthChg;
begin

end;

procedure TGrSplitPanel.ReSizePanel(dy: integer);
begin

end;

procedure TGrSplitPanel.PaintInfoArea(Quick: boolean);
var
  RR: TRect;
  Cn: TCanvas;
begin
  // obwodka dla AKTYWNEGO PANELU
  if not(Quick) then
  begin
    Cn := FOwner.FCanvas;
    RR := GetInfoArea;
    Cn.Brush.Style := bsClear;
    Cn.Pen.Color := clBlack;
    Cn.Rectangle(RR);
    if Focused and FOwner.HasFocus then
    begin
      Cn.Brush.Style := bsClear;
      Cn.Pen.Color := clRed;
      if (FOwner as TWykresEng).FColorMode <> pmdFullColor then
        Cn.Pen.Color := clBlack;
      Cn.Pen.Width := 2;
      Cn.Rectangle(RR.Left + 1, RR.Top + 1, RR.Right - 1, RR.Bottom - 1);
      Cn.Pen.Width := 1
    end;
  end;
end;

procedure TGrSplitPanel.PaintWorkArea(Quick: boolean);
begin

end;

function TGrSplitPanel.GetWorkArea: TRect;
begin
  Result := ScrPos;
  Result.Left := FOwner.GetSpliterPos;
end;

function TGrSplitPanel.GetDataArea: TRect;
begin
  Result := ScrPos;
  Result.Left := (FOwner as TWykresEng).GDataArea.Left;
  Result.Right := (FOwner as TWykresEng).GDataArea.Right;
end;

function TGrSplitPanel.GetInfoArea: TRect;
begin
  Result := ScrPos;
  Result.Right := FOwner.GetSpliterPos;
end;

procedure TGrSplitPanel.Paint(Quick: boolean);
var
  Cn: TCanvas;
  x: integer;
begin
  inherited;
  if Quick then
    Exit;

  x := FOwner.GetSpliterPos;

  Cn := FOwner.FCanvas;

  Cn.Brush.Color := FBkColor;
  Cn.Brush.Style := bsSolid;

  Cn.Pen.Color := clBlack;
  Cn.Pen.Style := psSolid;
  Cn.MoveTo(x, ScrPos.Top);
  Cn.LineTo(x, ScrPos.Bottom);

  Cn.MoveTo(ScrPos.Left, ScrPos.Bottom);
  Cn.LineTo(ScrPos.Right, ScrPos.Bottom);
  Cn.MoveTo(ScrPos.Left, ScrPos.Top);
  Cn.LineTo(ScrPos.Right, ScrPos.Top);
end;

procedure TGrSplitPanel.UndoZoom;
begin

end;

procedure TGrSplitPanel.FullZoom;
begin

end;


// ---------------------------------------------------------------------------
// TSplitPanelList
// ---------------------------------------------------------------------------

function TSplitPanelList.FGetItem(Index: integer): TGrSplitPanel;
begin
  Result := inherited GetItem(index) as TGrSplitPanel;
end;

procedure TSplitPanelList.SetFocus(Ob: TGrSplitPanel);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Ob = Items[i] then
      Items[i].PanelOptions := Items[i].PanelOptions + [pnFocused]
    else
      Items[i].PanelOptions := Items[i].PanelOptions - [pnFocused]
  end;
end;

procedure TSplitPanelList.PaintInfoBox(Quick: boolean);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].PaintInfoArea(Quick);
end;

procedure TSplitPanelList.SetZoomed(Panel: TGrSplitPanel);
var
  i: integer;
begin
  if Panel <> nil then
  begin // w³czenie Zoomed
    for i := 0 to Count - 1 do
    begin
      if Items[i] = Panel then
        Items[i].PanelOptions := Items[i].PanelOptions + [pnZoomed, pnActive]
      else
        Items[i].PanelOptions := Items[i].PanelOptions - [pnZoomed, pnActive];
    end
  end
  else
  begin // wy³czenie Zoomed
    for i := 0 to Count - 1 do
    begin
      if pnCanFocus in Items[i].PanelOptions then
        Items[i].PanelOptions := Items[i].PanelOptions + [pnActive];
      Items[i].PanelOptions := Items[i].PanelOptions - [pnZoomed];
    end;
  end;
end;

procedure TSplitPanelList.SetAllVisible;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].PanelOptions := Items[i].PanelOptions + [pnVisible];
end;

function TSplitPanelList.ClrFocused: TGrSplitPanel;
begin
  Result := FocusedPanel;
  SetFocus(nil);
end;

procedure TSplitPanelList.DoSplitWidthChg;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].DoSplitWidthChg;
end;

procedure TSplitPanelList.UndoZoom;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].UndoZoom;
end;

procedure TSplitPanelList.FullZoom;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].FullZoom;
end;

function TSplitPanelList.getCount(Opt: TPanelOptions): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
  begin
    if Items[i].PanelOptions >= Opt then
    begin
      inc(Result);
    end;
  end;
end;

function TSplitPanelList.GiveNextPanel(Item: TGrSplitPanel; Opt: TPanelOptions): TGrSplitPanel;
var
  nr: integer;
begin
  Result := nil;
  nr := IndexOf(Item);
  while true do
  begin
    inc(nr);
    if nr = Count then
      break;
    if Opt <= Items[nr].PanelOptions then
    begin
      Result := Items[nr];
      break;
    end;
  end;
end;

function TSplitPanelList.GiveNextPanel(Item: TGrSplitPanel): TGrSplitPanel;
begin
  Result := GiveNextPanel(Item, [pnVisible, pnCanFocus]);
end;

function TSplitPanelList.GivePrevPanel(Item: TGrSplitPanel): TGrSplitPanel;
var
  nr: integer;
begin
  Result := nil;
  nr := IndexOf(Item);
  while true do
  begin
    dec(nr);
    if nr < 0 then
      break;
    if (pnCanFocus in Items[nr].PanelOptions) and Items[nr].Visible then
    begin
      Result := Items[nr];
      break;
    end;
  end;
end;

function TSplitPanelList.PanelAtYPos(Y: integer): TGrSplitPanel;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if (Y > Items[i].ScrPos.Top) and (Y < Items[i].ScrPos.Bottom) then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TSplitPanelList.FocusedPanel: TGrSplitPanel;
begin
  Result := GetFirstPanel([pnFocused]);
end;

function TSplitPanelList.FocusedOrFirst: TGrSplitPanel;
begin
  Result := FocusedPanel;
  if Result = nil then
    Result := FocusFirst;
end;

function TSplitPanelList.GetFirstPanel(Opt: TPanelOptions): TGrSplitPanel;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].PanelOptions >= Opt then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TSplitPanelList.GetFirstPanel: TGrSplitPanel;
begin
  Result := GetFirstPanel([pnCanFocus, pnActive, pnVisible]);
end;

function TSplitPanelList.FocusFirst: TGrSplitPanel;
begin
  Result := GetFirstPanel([pnCanFocus, pnVisible]);
  if Result <> nil then
  begin
    Result.SetFocused;
  end;
end;

function TSplitPanelList.GetLastPanel(Opt: TPanelOptions): TGrSplitPanel;
var
  i: integer;
begin
  Result := nil;
  for i := Count - 1 downto 0 do
  begin
    if Items[i].PanelOptions >= Opt then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TSplitPanelList.GetLastPanel: TGrSplitPanel;
begin
  Result := GetLastPanel([pnCanFocus, pnActive, pnVisible]);
end;

function TSplitPanelList.AnyVisible: boolean;
begin
  Result := (GetFirstPanel([pnVisible]) <> nil);
end;

function TSplitPanelList.AnyActivVisible: boolean;
begin
  Result := (GetFirstPanel([pnActive, pnVisible]) <> nil);
end;

// ---------------------------------------------------------------------------
// TChartPanel.
// ---------------------------------------------------------------------------
constructor TChartPanel.Create(aWykres: TWykresEng);
begin
  inherited Create(aWykres);
  ScrollBar := TGrScrollBar.Create(aWykres, self, orVert);
  ScrollBar.Thickness := Parent.FDataScrollBarWidth;

  ScrollBar.OnGetPosition := OnGetPositionProc;
  ScrollBar.OnPositonChg := OnPositonChgProc;

  FBkColor := TabPanelColor[PanelCnt mod PANELS_COLOR_TAB_LEN];
  InfoStrings := TStringList.Create;
  PanelOptions := [pnCanFocus, pnCanZoom, pnCanResize, pnVisible];
  inc(PanelCnt);
  Zoomed := false;
  DrawStart := 0;
  DrawDelta := 1;
  FClicked := false;
  FZoomingVal := false;
  FMeasuring := false;
  MinDelta := 1E-3;
  if Parent.PanelTags then
  begin
    FTagList := TTagList.Create(Parent, self);
  end
  else
    FTagList := nil;
end;

destructor TChartPanel.Destroy;
begin
  InfoStrings.Free;
  ScrollBar.Free;
  CheckFreeAndNil(FTagList);
  inherited;
end;

function TChartPanel.Parent: TWykresEng;
begin
  Result := FOwner as TWykresEng;
end;

function TChartPanel.IsDataZoomed: boolean;
begin
  Result := ScrollBar.IsZoomed;
end;

function TChartPanel.MouseOper: boolean;
begin
  Result := inherited MouseOper or FZoomingVal;
end;

procedure TChartPanel.ShiftUp;
begin

end;

procedure TChartPanel.ZoomIn;
begin

end;

procedure TChartPanel.ShiftDn;
begin

end;

procedure TChartPanel.ZoomOut;
begin

end;

procedure TChartPanel.ZoomInPt(Y: integer);
begin

end;

procedure TChartPanel.ZoomOutPt(Y: integer);
begin

end;

procedure TChartPanel.SetNewValZoom(Str, Delt: Nrml);
begin
  SetDataArea;
end;

procedure TChartPanel.DrawZoomingVal(y1, y2: integer);
begin
  Parent.FCanvas.Pen.Color := clBlack;
  Parent.FCanvas.Pen.Style := psSolid;
  XorRectangle(Parent.FCanvas, Rect(FDataArea.Left, y1, FDataArea.Right, y2));
end;

procedure TChartPanel.LiczNewValWindow(var Str: Nrml; var Del: Nrml);
var
  T1, T2, w: integer;
  r: TRect;
begin
  T1 := StartPos;
  T2 := EndPos;
  if T2 > T1 then
  begin
    r := FDataArea;
    w := r.Bottom - r.Top;
    Str := DrawStart + DrawDelta * (r.Bottom - T2) / w;
    Del := DrawDelta * (T2 - T1) / w;
  end
  else
  begin
    Str := 0;
    Del := 1.0;
  end;
end;

function TChartPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
begin
  Result := false;
  if Visible then
  begin
    Result := inherited MouseDown(Button, Shift, x, Y);
    if not(Result) then
      Result := ScrollBar.MouseDown(Button, Shift, x, Y);
    if not(Result) and Assigned(FTagList) then
      Result := FTagList.MouseDown(Button, Shift, x, Y);
    if not(Result) then
    begin
      if Button = mbLeft then
      begin
        if InRect(FDataArea, x, Y, 2) then
        begin
          FClicked := true;
          if Parent.IsZoomingVal(Shift) then
          begin
            FZoomingVal := true;
            StartPos := Y;
            EndPos := Y;
            DrawZoomingVal(StartPos, EndPos);
            Result := true;
          end
        end;
      end;
    end;
  end;
end;

procedure TChartPanel.MouseMove(Shift: TShiftState; x, Y: integer);
var
  q: boolean;
  ddx: real;
  nStart: real;
begin
  inherited;
  q := InRect(FDataArea, x, Y, 2);
  if q and (Screen.Cursor = crDefault) then
    Screen.Cursor := crCross;

  if FZoomingVal then
  begin
    if q then
    begin
      DrawZoomingVal(StartPos, EndPos);
      // DrawZoomingVal(Parent.MsDownPoint.Y,Parent.MsLastPoint.Y);
      EndPos := Y;
      DrawZoomingVal(StartPos, EndPos);
    end
    else
    begin
      DrawZoomingVal(StartPos, EndPos);
      FZoomingVal := false;
    end;
  end;

  if Parent.FMouseShifting and Parent.FMouseWasWarAway then
  begin
    if InRect(FDataArea, Parent.MsDownPoint, 2) then
    begin
      ddx := 1.0 * (Parent.MsLastPoint.Y - Y) / (FDataArea.Bottom - FDataArea.Top);
      nStart := DrawStart - ddx * DrawDelta;
      SetNewValZoom(nStart, DrawDelta);
    end;
  end;
  ScrollBar.MouseMove(Shift, x, Y);
  if Assigned(FTagList) then
    FTagList.MouseMove(Shift, x, Y);
end;

procedure TChartPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
var
  Str, Del: Nrml;
begin
  inherited;
  if FClicked then
  begin
    FClicked := false;
    if InRect(ScrPos, x, Y, 2) then
    begin
      SetFocused;
    end;
  end;
  if FZoomingVal then
  begin
    FZoomingVal := false;
    DrawZoomingVal(StartPos, EndPos);
    LiczNewValWindow(Str, Del);
    SetNewValZoom(Str, Del);
    if Parent.FWorkMode = wmZoomVal then
      Parent.FWorkMode := Parent.FSavedMode;
  end;
  ScrollBar.MouseUp(Button, Shift, x, Y);
  if Assigned(FTagList) then
    FTagList.MouseUp(Button, Shift, x, Y);
end;

procedure TChartPanel.Paint(Quick: boolean);
var
  r: TRect;
  Cn: TCanvas;
begin
  if Visible then
  begin
    if not(Quick) then
    begin
      Cn := FOwner.FCanvas;
      r := ScrPos;
      r.Right := FDataArea.Right;
      inc(r.Top, 1);
      inc(r.Bottom, -1);
      Cn.Brush.Color := FBkColor;
      Cn.Brush.Style := bsSolid;
      Cn.FillRect(r);
    end;
    PaintInfoArea(Quick);
    PaintWorkArea(Quick);
    ScrollBar.Paint(Quick);
    inherited;
    if Assigned(FTagList) then
      FTagList.PaintTo(Quick);
  end;
end;

procedure TChartPanel.SetDataArea;
begin
  FDataArea := ScrPos;
  FDataArea.Left := Parent.GDataArea.Left;
  FDataArea.Right := Parent.GDataArea.Right;
end;

procedure TChartPanel.SetPosition(aTop, aHeight: integer);
var
  V: integer;
begin
  inherited;
  SetDataArea;

  V := ScrPos.Bottom - ScrPos.Top;
  ScrollBar.Visible := (V > 10);
  ScrollBar.SetPosition(ScrPos.Right - ScrollBar.Thickness, ScrPos.Top, V);
end;

procedure TChartPanel.OnGetPositionProc(Sender: TObject; var xr: real; var dxr: real);
begin
  xr := DrawStart;
  dxr := DrawDelta;
  xr := 1 - (xr + dxr);
end;

procedure TChartPanel.OnPositonChgProc(Sender: TObject; xr: real; dxr: real);
begin
  xr := 1 - (xr + dxr);
  SetNewValZoom(xr, dxr);
  Parent.RecalculateDataArea;
end;

// ---------------------------------------------------------------------------
// TAnalogPanel
// ---------------------------------------------------------------------------
constructor TAnalogPanel.Create(aWykres: TWykresEng);
begin
  inherited;
  FSeries := TAnlalogSerieList.Create(aWykres, self);
  PropHeigh := 1;
  Mnoznik := 1;
  PanelOptions := PanelOptions + [pnActive];
  FSiatka := TSiatka.Create(aWykres, orVert);
end;

destructor TAnalogPanel.Destroy;
begin
  FSeries.Free;
  FSiatka.Free;
  inherited;
end;

function TAnalogPanel.PixelToReal(Y: integer): real;
begin
  with FDataArea do
    Result := DrawStart + DrawDelta * (Bottom - Y) / (Bottom - Top);
end;

// wejscie V - wartoœc fizyczna
// wyjœcie pixle
function TAnalogPanel.LiczY(V: real): integer;
begin
  if FMaxR <> FMinR then
    Result := LiczYW((V - FMinR) / (FMaxR - FMinR))
  else
    Result := LiczYW(0);
end;

// wejscie w - wartoœc wzglêdna [0..1]
// wyjœcie pixle
function TAnalogPanel.LiczYW(V: Nrml): integer;
var
  w: integer;
  RR: TRect;
begin
  if V < DrawStart then
    V := DrawStart;
  if V > (DrawStart + DrawDelta) then
    V := (DrawStart + DrawDelta);
  RR := GetWorkArea;
  w := RR.Bottom - RR.Top;
  Result := RR.Bottom - round(w * (V - DrawStart) / (DrawDelta));
  Widelki(Result, RR.Top + 2, RR.Bottom - 2);
end;

// wejscie r -wartoœc wzgl¹dna [0..1]
// wyjœcie - wielkoœæ fizyczna
function TAnalogPanel.RealToVal(r: Nrml): double;
begin
  Result := FMinR + (FMaxR - FMinR) * r;
end;

function TAnalogPanel.OnGetSiatkaItemTxtProc(Sender: TObject; x: real): string;
begin
  // Result := ValToZakresStr(X,Max(Abs(FMinR),Abs(FMaxR)),Units);
  Result := ValToZakresStr(x, Max(abs(FSiatka.FBegV), abs(FSiatka.FEndV)), Units);
end;

procedure TAnalogPanel.FSetMaxR(r: real);
begin
  FMaxR := r;
  LiczSiatka;
end;

procedure TAnalogPanel.FSetMinR(r: real);
begin
  FMinR := r;
  LiczSiatka;
end;

procedure TAnalogPanel.SetMinMax(aMin, aMax: real);
begin
  FMinR := aMin;
  FMaxR := aMax;
  LiczSiatka;
end;

procedure TAnalogPanel.LiczSiatka;
var
  RR: TRect;
  BegV: double;
  EndV: double;
  SplW: integer;
begin
  FSiatka.OnGetItemTxt := OnGetSiatkaItemTxtProc;
  BegV := RealToVal(DrawStart);
  EndV := RealToVal(DrawStart + DrawDelta);

  SplW := FOwner.GetSpliterPos;
  if SplW < 150 then
  begin
    RR := GetWorkArea;
    FSiatka.Build(BegV, EndV, RR, RR.Top, RR.Bottom, RR.Left, taLeftJustify);
  end
  else
  begin
    RR := GetInfoArea;
    FSiatka.Build(BegV, EndV, RR, RR.Top, RR.Bottom, RR.Right, taRightJustify);
  end;
end;

procedure TAnalogPanel.PaintInfoArea(Quick: boolean);
var
  RR: TRect;
  w, H: integer;
  r: real;
  V: double;
  Exist: boolean;
  DrawIt: boolean;
  TS: TStringList;
  CmpxUnit: string;
  MaxZakr: real;
  y1, y2: real;
  nrs: integer;
  Tm1: double;
  SerName: string;
  Cn: TCanvas;

  procedure MyTextRect(r: TRect; x, Y: integer; s: String);
  begin
    Cn.TextRect(ClipRect(RR, r), x, Y, s);
  end;

begin
  inherited;
  RR := GetInfoArea;
  Cn := FOwner.FCanvas;

  DrawIt := (RR.Left <> RR.Right);
  DrawIt := DrawIt and Assigned((FOwner as TWykresEng).FOnGetAnValue);

  if DrawIt then
  begin
    TS := TStringList.Create;
    try
      Cn.Font.Assign(Parent.FDefaultFont);
      Cn.Brush.Style := bsClear;
      Cn.Brush.Color := FBkColor;
      if Parent.FColorMode <> pmdFullColor then
        Cn.Brush.Color := clWhite;
      Cn.Pen.Color := clBlack;

      MeasureString(Cn, 'A', w, H);

      y1 := FMinR + DrawStart * (FMaxR - FMinR); // wielkosci fizyczne
      y2 := FMinR + (DrawStart + DrawDelta) * (FMaxR - FMinR);
      MaxZakr := Max(abs(y1), abs(y2));
      CmpxUnit := GetComplexUnit(MaxZakr, Units);

      w := RR.Right - RR.Left;
      if FSiatka.FAlign = taRightJustify then
      begin
        w := (w * 2) div 3;
        RR.Right := RR.Left + w;
      end
      else
      begin
        dec(RR.Right, 3);
      end;
      inc(RR.Top, 3);
      inc(RR.Left, 3);
      dec(RR.Bottom, 3);

      r := Parent.GetCurrMouseXWzgl;
      if (r >= 0) and (r <= 1) then
      begin
        Tm1 := Parent.RealToTime(r);
        for nrs := 0 to Series.Count - 1 do
        begin
          if Series.Items[nrs].Visible then
          begin
            if Series.Count = 1 then
              SerName := 'y(t)='
            else
              SerName := Format('y%u(t)=', [nrs + 1]);

            Series.Items[nrs].GetValAt(Tm1, V, Exist);

            if Exist then
            begin
              if not(Parent.ForHistory) then
              begin
                TS.Add(SerName + ValToZakresStr(V, abs(V), Units));
                if Mnoznik <> 1 then
                  TS.Add(Format('M=%f', [Mnoznik]));
              end
              else
              begin
                TS.Add(Title);
                TS.Add(ValToZakresStr(V, MaxZakr, ''));
                TS.Add(CmpxUnit);
              end;
            end
            else
            begin
              if not(Parent.ForHistory) then
              begin
                TS.Add(SerName);
              end
              else
              begin
                TS.Add(Title);
                TS.Add('.');
                TS.Add(CmpxUnit);
              end;
            end;
          end;
        end;
      end;

      if not(Quick) and Parent.FInvertBox.TimeBoxExist then
      begin
        TS.AddStrings(InfoStrings);
      end;
      DrawList(Cn, RR, TS, false);
    finally
      TS.Free;
    end;
  end;
end;

procedure TAnalogPanel.PaintWorkArea(Quick: boolean);
var
  i: integer;
  N: integer;
  RR: TRect;
  TmSiatka: TSiatka;
  Cn: TCanvas;
begin
  inherited;
  if not(Quick) then
  begin
    RR := FDataArea;
    Cn := FOwner.FCanvas;

    Cn.Brush.Style := bsClear;
    Cn.TextRect(RR, RR.Left + 5, RR.Top + 1, Title);

    // rysowanie siatki w pionie
    Cn.Pen.Color := clGray;
    if Parent.FColorMode <> pmdFullColor then
      Cn.Pen.Color := clBlack;

    Cn.Pen.Style := psDot;

    TmSiatka := Parent.FBottomPanel.Siatka;
    for i := 0 to TmSiatka.Count - 1 do
    begin
      if TmSiatka.Items[i].Major then
      begin
        N := TmSiatka.Items[i].PosX;
        Cn.MoveTo(N, RR.Top + 5);
        Cn.LineTo(N, RR.Bottom - 5);
      end;
    end;

    // rysowanie siatki w poziomie
    for i := 0 to FSiatka.Count - 1 do
    begin
      if FSiatka.Items[i].Major then
      begin
        Cn.Pen.Width := 1;
        if FSiatka.Items[i].IsZero then
          Cn.Pen.Width := 2;
        Cn.MoveTo(RR.Left, FSiatka.Items[i].PosX);
        Cn.LineTo(RR.Right, FSiatka.Items[i].PosX);
      end;
    end;

    Cn.Pen.Width := 1;
    Cn.Pen.Style := psSolid;
  end;
end;

procedure TAnalogPanel.PaintNames(Quick: boolean);
var
  i: integer;
  s: string;
  RR: TRect;
  RR1: TRect;
  Cn: TCanvas;
begin
  if not(Quick) then
  begin
    s := '';
    for i := 0 to Series.Count - 1 do
    begin
      if Series.Items[i].Visible then
      begin
        if s <> '' then
          s := s + ', ';
        s := s + Series.Items[i].Title;
      end;
    end;
    if s <> '' then
    begin
      Cn := FOwner.FCanvas;
      RR := FDataArea;
      RR1 := Bounds(RR.Left + 4, RR.Top + 2, Cn.TextWidth(s), Cn.TextHeight(s));
      RR1 := ClipRect(RR, RR1);
      Cn.Brush.Color := clYellow;
      Cn.Brush.Style := bsSolid;
      Cn.Font.Color := clBlack;
      Cn.TextRect(RR1, RR1.Left, RR1.Top, s);
    end;
  end;
end;

procedure TAnalogPanel.Paint(Quick: boolean);
var
  i: integer;
begin
  if (pnActive in PanelOptions) and Visible then
  begin
    inherited;

    for i := 0 to Series.Count - 1 do
      Series.Items[i].Paint(Quick);
    FSiatka.Paint(Quick);
    PaintNames(Quick);
  end;
end;

function TAnalogPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
begin
  Result := false;
  if pnActive in PanelOptions then
  begin
    Result := inherited MouseDown(Button, Shift, x, Y);
  end;
end;

procedure TAnalogPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
begin
  if pnActive in PanelOptions then
  begin
    inherited;
  end;
end;

procedure TAnalogPanel.MouseMove(Shift: TShiftState; x, Y: integer);
begin
  if pnActive in PanelOptions then
  begin
    inherited;
  end;
end;

procedure TAnalogPanel.ReSizePanel(dy: integer);
var
  H: integer;
  r: real;
begin
  H := ScrPos.Bottom - ScrPos.Top;
  r := dy / H;
  PropHeigh := PropHeigh + PropHeigh * r;
end;

procedure TAnalogPanel.ShiftUp;
begin
  SetNewValZoom(DrawStart + 0.1 * DrawDelta, DrawDelta);
end;

procedure TAnalogPanel.ShiftDn;
begin
  SetNewValZoom(DrawStart - 0.1 * DrawDelta, DrawDelta)
end;

procedure TAnalogPanel.ZoomIn;
begin
  SetNewValZoom(DrawStart + 0.25 * DrawDelta, 0.5 * DrawDelta);
end;

procedure TAnalogPanel.ZoomOut;
begin
  SetNewValZoom(DrawStart - 0.5 * DrawDelta, 2 * DrawDelta);
end;

procedure TAnalogPanel.ZoomInPt(Y: integer);
var
  r: real;
  dr: real;
  ds: real;
begin
  if (Y > FDataArea.Top) and (Y < FDataArea.Bottom) then
  begin
    r := PixelToReal(Y);
    ds := (r - DrawStart) / 2;
    dr := 0.5 * DrawDelta;
    r := r - ds;
    if r < 0 then
      r := 0;
    SetNewValZoom(r, dr);
  end
  else
    ZoomIn;
end;

procedure TAnalogPanel.ZoomOutPt(Y: integer);
var
  r: real;
  dr: real;
  ds: real;
begin
  if (Y > FDataArea.Top) and (Y < FDataArea.Bottom) then
  begin
    r := PixelToReal(Y);
    ds := (r - DrawStart) * 2;
    dr := 2 * DrawDelta;
    r := r - ds;
    if r < 0 then
      r := 0;
    SetNewValZoom(r, dr);
  end
  else
    ZoomIn;
end;

procedure TAnalogPanel.DoSplitWidthChg;
begin
  inherited;
  SetDataArea;
  LiczSiatka;
end;

procedure TAnalogPanel.SetNewValZoom(Str, Delt: Nrml);
var
  DoIt: boolean;
begin
  DoIt := true;
  if Delt > 1 then
    Delt := 1;

  if Delt < MinDelta then
  begin
    if DrawDelta = MinDelta then
      DoIt := false;
    Delt := MinDelta
  end;
  if Str < 0 then
    Str := 0;
  if Str > 1.0 - Delt then
    Str := 1.0 - Delt;

  if DoIt then
  begin
    if (DrawStart <> Str) or (DrawDelta <> Delt) then
    begin
      DrawStart := Str;
      DrawDelta := Delt;

      Parent.DrawCursor(false);
      LiczSiatka;
      ScrollBar.UpdatePos;
      Parent.RecalculateDataArea;
      Parent.Invalidate;
      Parent.ExecNewValZoom(self);
    end;
  end;

  inherited;
end;

procedure TAnalogPanel.SetPosition(aTop, aHeight: integer);
begin
  inherited;
  LiczSiatka;
end;

procedure TAnalogPanel.LiczPomiarBlok(StartProb, EndProb: integer);
begin
  InfoStrings.Clear;
  Series.LiczPomiarBlok(InfoStrings, StartProb, EndProb);
end;

procedure TAnalogPanel.UndoZoom;
begin
  SetNewValZoom(0, 1);
end;

procedure TAnalogPanel.AutoMinMax;
var
  Del, Str: real;
begin
  try
    Series.LiczMinMax;
    if Series.FminMaxExist and not(isNan(Series.FMaxV)) and not(isNan(Series.FMinV)) then
    begin

      Del := (Series.FMaxV - Series.FMinV);
      if Del < 1E-6 then
        Del := 1;

      Del := Del * 1.2;
      Str := Series.FMinV - 0.1 * Del;
      SetMinMax(Str, Str + Del);
    end;
  except
    MinR := 0;
    MaxR := 10;

  end;
end;

procedure TAnalogPanel.FullZoom;
var
  StrPr, EndPr: integer;
  Del, Str: real;
  dd: real;
begin
  StrPr := Parent.GetNrProb4Real(Parent.FTimeWindowStart);
  EndPr := Parent.GetNrProb4Real(Parent.FTimeWindowStart + Parent.FTimeWindowDelta);
  Series.LiczMinMax(StrPr, EndPr);
  if Series.FminMaxExist then
  begin
    dd := (FMaxR - FMinR);
    if dd = 0 then
      dd := 1;
    Str := (Series.FMinV - FMinR) / dd;
    Del := (Series.FMaxV - Series.FMinV) / dd;
    Del := Del * 1.2;
    Str := Str - 0.1 * Del;
    SetNewValZoom(Str, Del);
  end;
end;

// ---------------------------------------------------------------------------
// TAnalogPanelList
// ---------------------------------------------------------------------------

constructor TAnalogPanelList.Create(Wykres: TWykresEng);
begin
  inherited Create(Wykres as TOrganizer);
end;

function TAnalogPanelList.FGetItem(Index: integer): TAnalogPanel;
begin
  Result := inherited GetItem(Index) as TAnalogPanel;
end;

procedure TAnalogPanelList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if Action = lnDeleted then
  begin
    // (FOwner as TWykresEng).FSplitPanelList

  end;
end;

procedure TAnalogPanelList.Add(Panel: TAnalogPanel);
begin
  inherited Add(Panel);
end;

function TAnalogPanelList.CreateNew: TAnalogPanel;
begin
  Result := TAnalogPanel.Create(FOwner as TWykresEng);
  Add(Result);
end;

function TAnalogPanelList.CreateNew(idx: integer): TAnalogPanel;
begin
  Result := TAnalogPanel.Create(FOwner as TWykresEng);
  Insert(idx, Result);
end;

procedure TAnalogPanelList.Paint(Quick: boolean);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Paint(Quick);
end;

function TAnalogPanelList.GetVisibleCnt: integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
  begin
    if Items[i].Visible then
      inc(Result);
  end;
end;

procedure TAnalogPanelList.SetEquHeight(Y0, H: integer);
var
  i: integer;
  N: integer;
  Y, dy: real;
  yi: integer;
  hi: integer;
begin
  N := GetVisibleCnt;
  dy := H / N;
  Y := Y0;
  for i := 0 to Count - 1 do
  begin
    if Items[i].Visible then
    begin
      Items[i].PropHeigh := 1;
      yi := round(Y);
      Y := Y + dy;
      hi := round(Y) - yi;
      Items[i].SetPosition(yi, hi);
    end;
  end;
end;

procedure TAnalogPanelList.SetProportionalHeight(Y0, H: integer);
var
  i: integer;
  Y, dy: real;
  yi: integer;
  hi: integer;
  s: real;
begin
  s := 0;
  for i := 0 to Count - 1 do
  begin
    if Items[i].Visible then
      s := s + Items[i].PropHeigh;
  end;

  dy := H / s;
  Y := Y0;
  for i := 0 to Count - 1 do
  begin
    if Items[i].Visible then
    begin
      yi := round(Y);
      Y := Y + Items[i].PropHeigh * dy;
      hi := round(Y) - yi;
      Items[i].SetPosition(yi, hi);
    end;
  end;
end;

procedure TAnalogPanelList.LiczPomiarBlok(StartProb, EndProb: integer);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].LiczPomiarBlok(StartProb, EndProb);
end;

// ---------------------------------------------------------------------------
// TDigitalPanel
// ---------------------------------------------------------------------------
constructor TDigitalPanel.Create(aWykres: TWykresEng);
begin
  inherited;
  FSeries := TDigitalSerieList.Create(aWykres, self);
  DigiHeight := 150;
end;

destructor TDigitalPanel.Destroy;
begin
  FSeries.Free;
  inherited;
end;

function TDigitalPanel.IsAnyDigit: boolean;
begin
  Result := (FSeries.Count > 0);
end;

procedure TDigitalPanel.Paint(Quick: boolean);
begin
  if (pnActive in PanelOptions) and Visible then
  begin
    inherited;
  end;
end;

// ---------------------------------------------------------------------------
// TTopPanel
// ---------------------------------------------------------------------------

constructor TTopPanel.Create(aOwner: TOrganizer);
begin
  inherited;
  PanelOptions := [pnCanResize];
end;

function TTopPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
var
  Wykr: TWykresEng;
begin
  Result := inherited MouseDown(Button, Shift, x, Y);
  if Button = mbLeft then
  begin
    if InRect(ScrPos, x, Y, LINE_MARGIN) then
    begin
      Wykr := FOwner as TWykresEng;
      if (Button = mbRight) and Assigned(Wykr.FOnTitleMouseDown) then
      begin
        Wykr.FOnTitleMouseDown(self);
        Result := true;
      end;
    end;
  end;
end;

function TTopPanel.GetMyColor: TColor;
begin

  if (FOwner as TWykresEng).FColorMode = pmdFullColor then
  begin
    if FOwner.HasFocus then
      Result := ACTIVE_COLOR
    else
      Result := clInactiveBorder;
  end
  else
    Result := clWhite;
end;

procedure TTopPanel.PaintWorkArea(Quick: boolean);
var
  Wykr: TWykresEng;
  i: integer;
  dx: integer;
  Y: integer;
  RR: TRect;
  s: string;
  w, H: integer;
  TmStr: real;
  TmDlt: real;
  M: TTmFormatMode;
  Cn: TCanvas;
begin
  inherited;
  if Quick then
    Exit;
  RR := GetWorkArea;
  Wykr := FOwner as TWykresEng;
  Cn := FOwner.FCanvas;
  if RR.Top <> RR.Bottom then
  begin
    Cn.Brush.Style := bsSolid;
    Cn.FillRect(RR);
    Cn.Rectangle(RR);

    Cn.Brush.Style := bsClear;
    Cn.Brush.Color := GetMyColor;

    Cn.Font.Assign(Wykr.TitleFont);
    Cn.Rectangle(RR);

    Cn.Brush.Style := bsClear;
    Y := RR.Top + 2;
    for i := 0 to Wykr.FTitleStrings.Count - 1 do
    begin
      s := Wykr.FTitleStrings.Strings[i];
      dx := Cn.TextWidth(s);
      Cn.TextRect(RR, RR.Left + ((RR.Right - RR.Left - dx) div 2), Y, s);
      Y := Y + Cn.TextHeight(s);
    end;

    if not(Wykr.FullTime) then
    begin
      Wykr.GetTimeWindow(TmStr, TmDlt);
      M := GetTmPrzedzial(TmStr, TmStr + TmDlt);

      s := WykrTimeStr(M, TmStr, true);
      MeasureString(Cn, s, w, H);
      Cn.TextRect(RR, RR.Left + 10, RR.Bottom - H - 2, s);

      s := WykrTimeStr(M, TmStr + TmDlt, true);
      MeasureString(Cn, s, w, H);
      Cn.TextRect(RR, RR.Right - w - 10, RR.Bottom - H - 2, s);
    end
    else
    begin
      s := Wykr.GiveFullTimeStr(Wykr.FTimeWindowStart);
      MeasureString(Cn, s, w, H);
      Cn.TextRect(RR, RR.Left + 10, RR.Bottom - H - 2, s);
      s := Wykr.GiveFullDateStr(Wykr.FTimeWindowStart);
      MeasureString(Cn, s, w, H);
      Cn.TextRect(RR, RR.Left + 10, RR.Bottom - 2 * H - 2, s);

      s := Wykr.GiveFullTimeStr(Wykr.FTimeWindowStart + Wykr.FTimeWindowDelta);
      MeasureString(Cn, s, w, H);
      Cn.TextRect(RR, RR.Right - w - 10, RR.Bottom - H - 2, s);
      s := Wykr.GiveFullDateStr(Wykr.FTimeWindowStart + Wykr.FTimeWindowDelta);
      MeasureString(Cn, s, w, H);
      Cn.TextRect(RR, RR.Right - w - 10, RR.Bottom - 2 * H - 2, s);
    end;
  end;
end;

procedure TTopPanel.PaintInfoArea(Quick: boolean);
var
  Wykr: TWykresEng;
  RR: TRect;
  Delt, Str, dd: real;
  P: boolean;
  TS: TStringList;
  Tm: real;
  Cn: TCanvas;
  r: real;
begin
  inherited;
  RR := GetInfoArea;
  Wykr := FOwner as TWykresEng;
  Cn := FOwner.FCanvas;

  TS := TStringList.Create;
  try
    if RR.Top <> RR.Bottom then
    begin
      Cn.Brush.Style := bsSolid;
      Cn.Brush.Color := GetMyColor;

      r := Wykr.PixelToReal(Wykr.MsLastPoint.x);
      if not(Wykr.FullTime) then
      begin
        TS.Add('T=' + Wykr.GiveTimeStr(r, true));
      end
      else
      begin
        TS.Add(Wykr.GiveFullDateStr(r));
        TS.Add(Wykr.GiveFullTimeStr(r));
      end;

      P := false;
      Tm := 0;
      if Wykr.FZoomingTime or Wykr.FMeasuring then
      begin
        P := true;
        Wykr.LiczNewTimeWindow(Str, Delt, false);
        Tm := Delt * Wykr.FProbCnt * Wykr.DtPerProbka;
      end;
      if not(Quick) and Wykr.FInvertBox.TimeBoxExist then
      begin
        Tm := (Wykr.FInvertBox.StartProb - Wykr.FInvertBox.EndProb) * Wykr.DtPerProbka;
        P := true;
      end;
      if P then
        TS.Add('mT=' + Wykr.GiveTimeStrTm(Tm, true));

      if not(Quick) then
      begin
        TS.Add('dT=' + Wykr.GiveTimeStrDelta(Wykr.FTimeWindowDelta, true));
        if Wykr.FInvertBox.TimeBoxExist then
        begin
          dd := Wykr.FInvertBox.StartProb / Wykr.FProbCnt;
          if not(Wykr.FullTime) then
            TS.Add('sT=' + Wykr.GiveTimeStr(dd, true))
          else
            TS.Add('sT=' + Wykr.GiveFullTimeStr(dd));

          dd := Wykr.FInvertBox.EndProb / Wykr.FProbCnt;
          if not(Wykr.FullTime) then
            TS.Add('eT=' + Wykr.GiveTimeStr(dd, true))
          else
            TS.Add('eT=' + Wykr.GiveFullTimeStr(dd));
        end;
      end;
      DrawList(Cn, RR, TS, not(Quick));
    end;
  finally
    TS.Free;
  end;
end;

procedure TTopPanel.Paint(Quick: boolean);
var
  Cn: TCanvas;
begin
  Cn := FOwner.FCanvas;
  Cn.Pen.Color := clBlack;
  Cn.Pen.Mode := pmCopy;
  Cn.Pen.Style := psSolid;
  Cn.Brush.Style := bsSolid;

  PaintInfoArea(Quick);
  PaintWorkArea(Quick);
end;

procedure TTopPanel.ReSizePanel(dy: integer);
var
  Wykr: TWykresEng;
begin
  Wykr := FOwner as TWykresEng;
  Wykr.FTitleBoxHeight := Wykr.FTitleBoxHeight + dy;
end;

// ---------------------------------------------------------------------------
// TTopPanel
// ---------------------------------------------------------------------------

constructor TBottomPanel.Create(aOwner: TOrganizer);
var
  Wykr: TWykresEng;
begin
  inherited;
  PanelOptions := [];
  Wykr := aOwner as TWykresEng;
  FBkColor := clSilver;
  TimeBar := TGrScrollBar.Create(Wykr, self, orHoriz);
  TimeBar.OnPositonChg := OnPositonChgProc;
  TimeBar.OnGetPosition := OnGetPositionProc;
  FSiatka := TSiatka.Create(aOwner, orHoriz);
end;

destructor TBottomPanel.Destroy;
begin
  TimeBar.Free;
  FSiatka.Free;
  inherited;
end;

procedure TBottomPanel.SetNewZoom;
begin
  TimeBar.UpdatePos;
  LiczSiatka;
  PaintWorkArea(false);
end;

procedure TBottomPanel.LiczSiatka;
var
  Wykr: TWykresEng;
  TimeStr: real;
  TimeDlt: real;
  RR: TRect;
begin
  Wykr := FOwner as TWykresEng;
  Wykr.GetTimeWindow(TimeStr, TimeDlt);

  RR := GetDataArea;
  Siatka.Build(TimeStr, TimeStr + TimeDlt, RR, RR.Left, RR.Right, RR.Top, taLeftJustify);
end;

procedure TBottomPanel.OnGetPositionProc(Sender: TObject; var xr: real; var dxr: real);
var
  Wykr: TWykresEng;
begin
  Wykr := FOwner as TWykresEng;
  xr := Wykr.FTimeWindowStart;
  dxr := Wykr.FTimeWindowDelta;
end;

procedure TBottomPanel.OnPositonChgProc(Sender: TObject; xr: real; dxr: real);
var
  Wykr: TWykresEng;
begin
  Wykr := FOwner as TWykresEng;
  Wykr.TimeZoomSet(xr, dxr);
  Paint(false);
end;

procedure TBottomPanel.PaintInfoArea(Quick: boolean);
var
  RR: TRect;
  Wykr: TWykresEng;
  Cn: TCanvas;
  sz: TSize;
  Pt: Tpoint;

begin
  inherited;
  if not(Quick) then
  begin
    Wykr := FOwner as TWykresEng;
    RR := GetInfoArea;
    Cn := FOwner.FCanvas;
    Cn.Pen.Color := clBlack;
    Cn.Brush.Color := FBkColor;
    if Wykr.FColorMode <> pmdFullColor then
      Cn.Brush.Color := clWhite;

    Cn.Rectangle(RR);
    Cn.Brush.Style := bsClear;
    Cn.Rectangle(RR);

    if Wykr.FTagKey then
    begin
      sz := Cn.TextExtent('TAG');
      Pt := CenterPoint(RR);
      Cn.TextRect(RR, Pt.x - sz.cx div 2, Pt.Y - sz.cy div 2, 'TAG');
    end;
  end;
end;

procedure TBottomPanel.PaintWorkArea(Quick: boolean);
var
  RR: TRect;
  Wykr: TWykresEng;
  Cn: TCanvas;
begin
  inherited;
  if not(Quick) then
  begin
    RR := GetWorkArea;
    Wykr := FOwner as TWykresEng;
    Cn := FOwner.FCanvas;

    if RR.Top <> RR.Bottom then
    begin
      Cn.Pen.Color := clBlack;
      Cn.Brush.Color := clSilver;
      Cn.Brush.Style := bsSolid;
      if Wykr.FColorMode <> pmdFullColor then
        Cn.Brush.Color := clWhite;
      Cn.Rectangle(RR);

      Cn.Brush.Style := bsClear;
    end;
  end;
  Siatka.Paint(Quick);
end;

procedure TBottomPanel.Paint(Quick: boolean);
begin
  inherited;
  PaintInfoArea(Quick);
  PaintWorkArea(Quick);
  TimeBar.Paint(Quick);
end;

procedure TBottomPanel.SetScrollBarPosition;
var
  x, Y, w: integer;
  RR: TRect;
  Wykr: TWykresEng;
  Dt: integer;
begin
  Wykr := FOwner as TWykresEng;
  RR := Wykr.GDataArea;
  Wykr.FCanvas.Font.Assign(Wykr.FDefaultFont);
  Dt := Wykr.FCanvas.TextHeight('1');

  x := RR.Left + 20;
  w := RR.Right - (x + 20);
  Y := ScrPos.Top + Dt + 6;
  TimeBar.SetPosition(x, Y, w);
end;

function TBottomPanel.MouseOper: boolean;
begin
  Result := inherited MouseOper or TimeBar.MouseOper;
end;

procedure TBottomPanel.DoSplitWidthChg;
begin
  inherited;
  SetScrollBarPosition;
  LiczSiatka;
end;

procedure TBottomPanel.SetPosition(aTop, aHeight: integer);
begin
  inherited;
  SetScrollBarPosition;
  LiczSiatka;
end;

function TBottomPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
begin
  Result := inherited MouseDown(Button, Shift, x, Y);
  Result := Result or TimeBar.MouseDown(Button, Shift, x, Y);
end;

procedure TBottomPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
begin
  inherited;
  TimeBar.MouseUp(Button, Shift, x, Y);
end;

procedure TBottomPanel.MouseMove(Shift: TShiftState; x, Y: integer);
begin
  inherited;
  TimeBar.MouseMove(Shift, x, Y);
end;

// ---------------------------------------------------------------------------
// TTag
// ---------------------------------------------------------------------------
constructor TTag.Create(List: TTagList; aOwner: TWykresEng; Panel: TChartPanel);
begin
  inherited Create;
  FOwner := aOwner;
  FList := List;
  FPanel := Panel;
  Color := FOwner.TagColor;
  FCaption := 'Tag';
  FDeleteMe := false;
  FMooving := false;
  FVisible := true;
  FSelectVisible := false;
  FUpdateCnt := 0;
end;

destructor TTag.Destroy;
begin
  DoNotify(tgDEL);
  inherited;
end;

procedure TTag.BeginUpdate;
begin
  inc(FUpdateCnt);
end;

procedure TTag.EndUpdate;
begin
  if FUpdateCnt > 0 then
    dec(FUpdateCnt);
end;

procedure TTag.DoNotify(Func: TTagFunc);
begin
  if FUpdateCnt = 0 then
    FOwner.DoTagNotify(self, FPanel, Func);
end;

function TTag.FGetXPixel: integer;
var
  r: Nrml;
begin
  r := FOwner.TimeToReal(FTagPos);
  if r < 0 then
    Result := -1
  else
    Result := FOwner.LiczX(r);
end;

procedure TTag.FSetXPixel(x: integer);
begin
  if FOwner.CanEditTags or (FList.IndexOf(self) = -1) then
  begin
    FTagPos := FOwner.RealToTime(FOwner.PixelToReal(x));
    FList.Update;
    DoNotify(tgMOVE);
  end;
end;

procedure TTag.FSetTagPos(Tm: double);
begin
  if FOwner.CanEditTags then
  begin
    FTagPos := Tm;
    FList.Update;
    DoNotify(tgMOVE);
  end;
end;

procedure TTag.FSetCaption(cap: string);
begin
  if FOwner.CanEditTags then
  begin
    FCaption := cap;
    FList.Update;
    FOwner.Invalidate;
    DoNotify(tgCAPTION);
  end;
end;

function TTag.GetOwnerRect: TRect;
begin
  Result := FOwner.GDataArea;
  if FPanel <> nil then
  begin
    Result.Top := FPanel.ScrPos.Top;
    Result.Bottom := FPanel.ScrPos.Bottom;
  end;
end;

function TTag.CheckTagRegion(Pt: Tpoint): boolean;
var
  RR: TRect;
begin
  RR := GetOwnerRect;
  RR.Left := FTagX - LINE_MARGIN;
  RR.Right := FTagX + LINE_MARGIN;
  Result := PtInRect(RR, Pt);
end;

procedure TTag.EditCaption;
var
  s: string;
begin
  s := FCaption;
  if InputQuery('', 'WprowadŸ etykietê', s) then
  begin
    Caption := s;
  end;
end;

function TTag.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
var
  Pt: Tpoint;
begin
  Result := false;
  Pt := Point(x, Y);
  FDeleteMe := false;
  if CheckTagRegion(Pt) then
  begin
    if FOwner.WorkMode = wmDelTag then
    begin
      if FOwner.CanEditTags then
      begin
        FDeleteMe := true;
        Result := true;
      end
    end;
    if FOwner.WorkMode in StabWorkMode then
    begin
      if FOwner.CanEditTags then
      begin
        FMooving := true;
        DoNotify(tgMOVING);
        DrawSelect(true, XPixel);
      end;
      FList.Focused := self;
      Result := true;
    end;
  end;

  if PtInRect(TextRect, Pt) and (FOwner.WorkMode in StabWorkMode) then
  begin
    FList.Focused := self;
    if FOwner.CanEditTags then
    begin
      if not(ssShift in Shift) then
        EditCaption;
    end;
    FOwner.Invalidate;
    Result := true;
  end;
end;

procedure TTag.MouseMove(Shift: TShiftState; x, Y: integer);
var
  Pt: Tpoint;
begin
  Pt := Point(x, Y);
  if CheckTagRegion(Pt) then
  begin
    case FOwner.WorkMode of
      wmCursor, wmBox:
        Screen.Cursor := crTagMove;
      wmDelTag:
        Screen.Cursor := crTagDel;
    end;
  end;
  if PtInRect(TextRect, Pt) and (FOwner.WorkMode in StabWorkMode) then
    Screen.Cursor := crTagEdit;
  if FMooving then
  begin
    XPixel := x;
    DrawSelect(false, -1);
    DrawSelect(true, x);
    Screen.Cursor := crTagMove;
  end;
end;

procedure TTag.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
begin
  if FMooving then
  begin
    XPixel := x;
    FList.Update;
    FOwner.Invalidate;
  end;
  FMooving := false;
  FSelectVisible := false;
end;

procedure TTag.Update;
var
  RR: TRect;
  R1: TRect;
  sz: tagSIZE;
  xt, yt: integer;
  Fnd: boolean;
begin
  FTagX := FGetXPixel;
  FVisible := (FTagX > 0);
  if FVisible then
  begin
    RR := GetOwnerRect;

    sz := FOwner.FCanvas.TextExtent(FCaption);
    inc(sz.cx, 4);
    inc(sz.cy, 2);

    if RR.Right - FTagX > sz.cx then
      FAlign := alRight
    else if FTagX - RR.Left > sz.cx then
      FAlign := alLeft
    else
    begin
      if RR.Left - FTagX > FTagX - RR.Right then
        FAlign := alRight
      else
        FAlign := alLeft;
    end;

    if FAlign = alLeft then
      xt := FTagX - (sz.cx + 3)
    else
      xt := FTagX + 3;

    yt := RR.Top + 6;
    Fnd := false;
    while yt < RR.Bottom - (sz.cy + 4) do
    begin
      R1 := Bounds(xt, yt, sz.cx, sz.cy);
      Fnd := FList.CheckCaptionPosition(self, R1);
      if Fnd then
      begin
        break;
      end;
      yt := yt + (sz.cy + 4)
    end;
    if not(Fnd) then
      yt := RR.Top + 6;
    TextRect := Bounds(xt, yt, sz.cx, sz.cy);
  end;
end;

procedure TTag.DrawSelect(DoShow: boolean; x: integer);
var
  RR: TRect;
begin
  if FSelectVisible xor DoShow then
  begin
    if DoShow then
      FLastSelectX := x;
    RR := GetOwnerRect;
    RR.Left := FLastSelectX - LINE_MARGIN;
    RR.Right := FLastSelectX + LINE_MARGIN;
    XorRectangle(FOwner.FCanvas, RR);
    FSelectVisible := DoShow;
  end;
end;

procedure TTag.CopyFrom(Src: TTag);
begin
  FTagPos := Src.FTagPos;
  FCaption := Src.FCaption;
  Color := Src.Color;
end;

procedure TTag.PaintTo1(Quick: boolean);
var
  RR: TRect;
begin
  if FVisible and not(Quick) then
  begin
    RR := GetOwnerRect;
    FOwner.FCanvas.Pen.Color := Color;
    FOwner.FCanvas.Pen.Style := psDashDot;

    FOwner.FCanvas.MoveTo(FTagX, RR.Top);
    FOwner.FCanvas.LineTo(FTagX, RR.Bottom);
    FOwner.FCanvas.Pen.Style := psSolid;

    if FMooving then
    begin
      DrawSelect(true, FTagX);
      FOwner.FCanvas.Pen.Color := clBlack;
      RR.Left := FTagX - LINE_MARGIN;
      RR.Right := FTagX + LINE_MARGIN;
      XorRectangle(FOwner.FCanvas, RR);
    end;
  end;
end;

procedure TTag.PaintTo2(Quick: boolean);
var
  Pt: Tpoint;
begin
  if FVisible and not(Quick) then
  begin
    FOwner.FCanvas.Font.Assign(FOwner.TagFont);
    FOwner.FCanvas.Brush.Style := bsSolid;
    if FList.Focused = self then
      FOwner.FCanvas.Brush.Color := clFuchsia
    else
      FOwner.FCanvas.Brush.Color := clYellow;
    FOwner.FCanvas.Pen.Color := clBlack;
    FOwner.FCanvas.Pen.Style := psSolid;

    FOwner.FCanvas.Rectangle(TextRect);
    FOwner.FCanvas.Brush.Style := bsClear;
    FOwner.FCanvas.TextRect(TextRect, TextRect.Left + 2, TextRect.Top + 1, FCaption);
    Pt := CenterPoint(TextRect);

    FOwner.FCanvas.MoveTo(FTagX, Pt.Y);
    case FAlign of
      alLeft:
        FOwner.FCanvas.LineTo(TextRect.Right, Pt.Y);
      alRight:
        FOwner.FCanvas.LineTo(TextRect.Left, Pt.Y);
    end;
  end;
end;

// ---------------------------------------------------------------------------
// TTagList
// ---------------------------------------------------------------------------
constructor TTagList.Create(aOwner: TWykresEng; aPanel: TChartPanel);
begin
  inherited Create;
  FOwner := aOwner;
  FPanel := aPanel;
  Counter := 1;
  FFocused := nil;
end;

constructor TTagList.Create(aOwner: TWykresEng);
begin
  Create(aOwner, nil);

end;

function TTagList.FGetItem(Index: integer): TTag;
begin
  Result := inherited GetItem(Index) as TTag
end;

function TTagList.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to Count - 1 do
    Result := Result or Items[i].MouseDown(Button, Shift, x, Y);

  if FOwner.WorkMode = wmDelTag then
  begin
    for i := 0 to Count - 1 do
    begin
      if Items[i].FDeleteMe then
      begin
        Delete(i);
        Update;
        FOwner.Invalidate;
        if not(FOwner.CanDelTag) then
        begin
          if FOwner.FWorkMode = wmDelTag then
            FOwner.FWorkMode := FOwner.FSavedMode;
        end;
        break;
      end;
    end;

    if IndexOf(Focused) < 0 then
    begin
      if Count > 0 then
        Focused := Items[0]
      else
        Focused := nil;
    end;
  end;
end;

procedure TTagList.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].MouseUp(Button, Shift, x, Y)
end;

procedure TTagList.MouseMove(Shift: TShiftState; x, Y: integer);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].MouseMove(Shift, x, Y)
end;

procedure TTagList.KeyDown(var Key: Word; Shift: TShiftState);
  procedure KeyLeftFunc(Shift: TShiftState);
  var
    N: integer;
    x: integer;
  begin
    if ssCtrl in Shift then
    // Focuse dla poprzedniego
    begin
      N := IndexOf(Focused);
      if N > 0 then
      begin
        dec(N);
        Focused := Items[N];
        FOwner.Invalidate;
      end;
    end
    else
    begin
      if Assigned(Focused) then
      begin
        if ssShift in Shift then
          x := Focused.XPixel - 10
        else
          x := Focused.XPixel - 1;
        if x < FOwner.GWorkPanelBox.Left then
          x := FOwner.GWorkPanelBox.Left;
        Focused.XPixel := x;
        Update;
        FOwner.Invalidate;
      end;
    end
  end;

  procedure KeyRightFunc(Shift: TShiftState);
  var
    N: integer;
    x: integer;
  begin
    if ssCtrl in Shift then
    // Focuse dla nastêpnego
    begin
      N := IndexOf(Focused);
      if N < Count - 1 then
      begin
        inc(N);
        Focused := Items[N];
        FOwner.Invalidate;
      end;
    end
    else
    begin
      if Assigned(Focused) then
      begin
        if ssShift in Shift then
          x := Focused.XPixel + 10
        else
          x := Focused.XPixel + 1;
        if x > FOwner.GWorkPanelBox.Right then
          x := FOwner.GWorkPanelBox.Right;
        Focused.XPixel := x;
        Update;
        FOwner.Invalidate;
      end;
    end

  end;

  procedure KeyInsertFunc(Shift: TShiftState);
  var
    x: integer;
    r: TRect;
    Fnd: boolean;
    i: integer;
  begin
    if FOwner.CanAddTag then
    begin
      r := FOwner.GDataArea;
      x := (r.Right - r.Left) div 4 + r.Left;

      Fnd := false;
      while x < r.Right do
      begin
        Fnd := true;
        for i := 0 to Count - 1 do
        begin
          if abs(Items[i].XPixel - x) < 10 then
          begin
            Fnd := false;
            break;
          end;
        end;
        if Fnd then
          break;
        x := x + (r.Right - r.Left) div 16;
      end;
      if not(Fnd) then
        x := CenterPoint(r).x;
      AddTagAt(x);
      FOwner.Invalidate;
      Update;
    end;
  end;

  procedure KeyDeleteFunc(Shift: TShiftState);
  var
    N: integer;
  begin
    if Assigned(Focused) then
    begin
      if not(ssShift in Shift) then
      begin
        N := IndexOf(Focused);
        Delete(N);
        dec(N);
        if N > 0 then
        begin
          Focused := Items[N];
        end
        else
        begin
          if (Focused = nil) and (Count > 0) then
            Focused := Items[0]
          else
            Focused := nil;
        end;
      end
      else
      begin
        Clear;
        Focused := nil;
      end;
      FOwner.Invalidate;
    end;
  end;

  procedure KeyCopy(Shift: TShiftState);
  begin
    if Assigned(Focused) and (ssCtrl in Shift) and (FOwner.PanelTags) then
    begin
      FOwner.CopyTags(FPanel);
    end;
  end;

begin
  if FOwner.CanEditTags then
  begin
    case Key of
      VK_LEFT:
        KeyLeftFunc(Shift);
      VK_RIGHT:
        KeyRightFunc(Shift);
      VK_INSERT:
        KeyInsertFunc(Shift);
      VK_DELETE:
        KeyDeleteFunc(Shift);
      VK_RETURN:
        if Assigned(Focused) then
          Focused.EditCaption;
      ord('C'):
        KeyCopy(Shift);
    end;
  end;
end;

function TTagList.AddTag(Tm: real; cap: string): TTag;
begin
  if FOwner.CanAddTag(self) then
  begin
    Result := TTag.Create(self, FOwner, FPanel);
    Result.BeginUpdate;
    try
      Add(Result);
      Result.FCaption := cap;
      Result.TagPos := Tm;
      inc(Counter);
      Focused := Result;
    finally
      Result.EndUpdate;
    end;
    Result.DoNotify(tgADD);
  end
  else
    Result := nil;
end;

function TTagList.AddTagAt(x: integer): TTag; // x wartoœc w pixlach
begin
  if FOwner.CanAddTag then
  begin
    Result := TTag.Create(self, FOwner, FPanel);
    Result.BeginUpdate;
    try
      Result.XPixel := x;
      Add(Result);
      Result.FCaption := 'Tag-' + IntToStr(Counter);
      inc(Counter);
      Focused := Result;
      if not(FOwner.CanAddTag) then
      begin
        if FOwner.FWorkMode = wmNewTag then
          FOwner.FWorkMode := FOwner.FSavedMode;
      end;
    finally
      Result.EndUpdate;
    end;
    Result.DoNotify(tgADD);
  end
  else
    Result := nil;
end;

procedure TTagList.Update;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Update;
end;

procedure TTagList.FSetFocused(Tag: TTag);
begin
  FFocused := Tag;
  if FFocused <> nil then
    FFocused.DoNotify(tgFOCUSED)
  else
    FOwner.DoTagNotify(nil, FPanel, tgFOCUSED);
end;

procedure TTagList.CopyFrom(Src: TTagList);
var
  i: integer;
  Tag: TTag;
begin
  for i := 0 to Src.Count - 1 do
  begin
    Tag := AddTagAt(0);
    if Assigned(Tag) then
      Tag.CopyFrom(Src.Items[i]);
  end;
  Update;
end;

procedure TTagList.PaintTo;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].PaintTo1(Quick);
  for i := 0 to Count - 1 do
    Items[i].PaintTo2(Quick);
end;

function TTagList.CheckCaptionPosition(Item: TTag; CheckR: TRect): boolean;
var
  i: integer;
  N: integer;
  r: TRect;
begin
  N := IndexOf(Item);
  i := 0;
  Result := true;
  while i < N do
  begin
    if Items[i].FVisible and IntersectRect(r, Items[i].TextRect, CheckR) then
    begin
      Result := false;
      break;
    end;
    inc(i);
  end;
end;

// ---------------------------------------------------------------------------
// TInvertValBox
// ---------------------------------------------------------------------------
constructor TInvertBox.Create(Owner: TWykresEng);
begin
  inherited Create;
  FOwner := Owner;
  Exist := false;
end;

procedure TInvertBox.SetValBox(r: TRect; P: TAnalogPanel);
begin
  Mode := ibVAL;
  Panel := P;
  Exist := true;
  FRect := r;
  ValStr := Panel.PixelToReal(r.Bottom);
  ValEnd := Panel.PixelToReal(r.Top);
  TimeStr := FOwner.PixelToReal(r.Left);
  TimeEnd := FOwner.PixelToReal(r.Right);
end;

procedure TInvertBox.SetTimeBox(x1, x2: integer);
var
  Diff: integer;
  RownyProb: integer;
  k: integer;
  OkrWzg: double;
begin
  Mode := ibTIME;
  Panel := nil;
  Exist := false;
  Diff := x2 - x1;
  if Diff > 10 then
  begin
    Exist := true;
    FRect.Left := x1;
    FRect.Right := x2;
    TimeStr := FOwner.PixelToReal(Rect.Left);
    TimeEnd := FOwner.PixelToReal(Rect.Right);
    if FOwner.FflWyrownOkres and (FOwner.FWyrownOkres <> 0) then
    begin
      RownyProb := round(FOwner.FWyrownOkres / FOwner.DtPerProbka); // ilosc probek na okres sygna³u
      OkrWzg := 1.0 * RownyProb / FOwner.ProbCnt;
      k := round((EndProb - StartProb) / OkrWzg);
      Exist := (k <> 0);
      TimeEnd := TimeStr + k * OkrWzg;
    end
  end
end;

function TInvertBox.StartProb: integer;
begin
  if Exist then
    Result := FOwner.GetNrProb4Real(TimeStr)
  else
    Result := 0;
end;

function TInvertBox.EndProb: integer;
begin
  if Exist then
    Result := FOwner.GetNrProb4Real(TimeEnd)
  else
    Result := FOwner.ProbCnt;
end;

function TInvertBox.GetTimeDelta: real;
begin
  Result := (StartProb - EndProb) * FOwner.DtPerProbka;
end;

procedure TInvertBox.Clear;
begin
  Exist := false;
end;

function TInvertBox.TimeBoxExist: boolean;
begin
  Result := Exist and (Mode = ibTIME);
end;

function TInvertBox.ValBoxExist: boolean;
begin
  Result := Exist and (Mode = ibVAL);
end;

procedure TInvertBox.UpdatePos;
begin
  if Exist then
  begin
    FRect.Left := FOwner.LiczX_Clip(TimeStr);
    FRect.Right := FOwner.LiczX_Clip(TimeEnd);
    if Mode = ibVAL then
    begin
      FRect.Top := Panel.LiczYW(ValStr);
      FRect.Bottom := Panel.LiczYW(ValEnd);
    end;
  end;
end;

function TInvertBox.InTimeBox(x: integer): boolean;
begin
  Result := (x > Rect.Left) and (x < Rect.Right);
end;

function TInvertBox.InValBox(x, Y: integer): boolean;
begin
  Result := (x > Rect.Left) and (x < Rect.Right) and (Y > Rect.Top) and (Y < Rect.Bottom);
end;

procedure TInvertBox.Show;
begin
  Show(Exist);
end;

procedure TInvertBox.Show(DoShow: boolean);
var
  x: integer;
  y1, y2: integer;
begin
  if DoShow xor FVisible then
  begin
    FOwner.FCanvas.Pen.Mode := pmNot;
    if Mode = ibTIME then
    begin
      y1 := FOwner.GDataArea.Top + 1;
      y2 := FOwner.GDataArea.Bottom - 1;
    end
    else
    begin
      y1 := Rect.Top;
      y2 := Rect.Bottom;
    end;
    for x := Rect.Left to Rect.Right do
    begin
      FOwner.FCanvas.MoveTo(x, y1);
      FOwner.FCanvas.LineTo(x, y2);
    end;
    FOwner.FCanvas.Pen.Mode := pmCopy;
  end;
  FVisible := DoShow;
end;


// ---------------------------------------------------------------------------
// TWykresEng
// ---------------------------------------------------------------------------

constructor TWykresEng.Create(Cn: TCanvas);
begin
  inherited Create(Cn);

  FAnalogPanels := TAnalogPanelList.Create(self);
  FTopPanel := TTopPanel.Create(self);
  // kolejnoœæ tworzenia paneli jest WA¯NA
  FDigitalPanel := TDigitalPanel.Create(self);
  FDigitalPanel.Visible := false;

  FBottomPanel := TBottomPanel.Create(self);
  FTagList := TTagList.Create(self);

  TitleFont := TFont.Create;
  FDefaultFont := TFont.Create;
  FDefaultFont.Name := 'Courier';
  TitleFont.Assign(FDefaultFont);

  PaintDest := toSCR;

  FInvertBox := TInvertBox.Create(self);

  FCurrsorVisible := false;
  FSelectBoxVisible := false;

  FAnyPanelVisible := false;
  Zoomed := false;
  FForceMiliSek := false;
  FColorMode := pmdFullColor;
  FInfoFields := [ifRMS, ifAVR, ifRMZ, ifMAX, ifMIN];

  FOnGetAnValue := nil;
  FOnGetDgValue := nil;
  FOnSetPomiarBlok := nil;
  FOnDropFiles := nil;
  FOnTitleMouseDown := nil;
  FOnHidenNotify := nil;
  FOnTagNotify := nil;

  FAnyDataZoomed := false;
  MaxTagCnt := 0;

  FProbCnt := 1000;
  TimeOfset := 0;
  FSplitWidth := 10;

  Cn.Font.Assign(FDefaultFont);
  FBottomBoxHeight := -1;
  FTitleBoxHeight := -1;
  FDataScrollBarWidth := BAR_WIDTH;

  FTitleStrings := TStringList.Create;
  FWorkMode := wmCursor;
  FSavedMode := wmCursor;
  CanEditTags := true;

  DropFilesList := TStringList.Create;

  FSplitedArea := false;
  FZoomingTime := false;
  FMeasuring := false;
  FBoxSelect := false;

  DtPerProbka := 0.001;
  FTimeWindowStart := 0;
  FTimeWindowDelta := 1;

  FflWyrownOkres := false;
  FWyrownOkres := 0.020; // okres dla 50Hz -> 20[ms]

  TagColor := clMaroon;
  TagFont := TFont.Create;
  TagFont.Assign(FDefaultFont);
end;

destructor TWykresEng.Destroy;
begin
  FOnGetAnValue := nil;
  FOnGetDgValue := nil;
  FOnSetPomiarBlok := nil;
  FOnDropFiles := nil;
  FOnTitleMouseDown := nil;
  FOnHidenNotify := nil;
  FOnTagNotify := nil;

  CheckFreeAndNil(FTagList);

  FAnalogPanels.Free;
  FDigitalPanel.Free;
  FTopPanel.Free;
  FBottomPanel.Free;

  FTitleStrings.Free;
  TitleFont.Free;
  FDefaultFont.Free;
  DropFilesList.Free;
  FInvertBox.Free;
  TagFont.Free;

  inherited Destroy;
end;

procedure TWykresEng.Clear;
var
  i: integer;
begin
  for i := FSplitPanelList.Count - 1 downto 0 do
  begin
    if FSplitPanelList.Items[i] is TAnalogPanel then
      FSplitPanelList.Delete(i);
  end;
  FDigitalPanel.Series.Clear;
  if Assigned(FTagList) then
    FTagList.Clear;
end;

procedure TWykresEng.TagClear;
var
  i: integer;
begin
  if PanelTags then
    for i := 0 to FSplitPanelList.Count - 1 do
    begin
      if FSplitPanelList.Items[i] is TChartPanel then
        (FSplitPanelList.Items[i] as TChartPanel).FTagList.Clear;
    end
  else
    FTagList.Clear;
  Invalidate;
end;

function TWykresEng.IsAnyPanelDataZoomed: boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to FSplitPanelList.Count - 1 do
  begin
    if pnActive in FSplitPanelList.Items[i].PanelOptions then
    begin
      if FSplitPanelList.Items[i] is TChartPanel then
      begin
        if (FSplitPanelList.Items[i] as TChartPanel).IsDataZoomed then
        begin
          Result := true;
          break;
        end;
      end;
    end;
  end;
end;

procedure TWykresEng.RecalculateDataArea;
var
  q: boolean;
begin
  q := IsAnyPanelDataZoomed;
  if q <> FAnyDataZoomed then
  begin
    FAnyDataZoomed := q;
    LiczWymiary(rsmNoChange);
    Invalidate;
  end;
end;

procedure TWykresEng.UpdateTagList;
var
  i: integer;
  Pn: TChartPanel;
begin
  if Assigned(FTagList) then
    FTagList.Update
  else
  begin
    for i := 0 to FSplitPanelList.Count - 1 do
    begin
      if FSplitPanelList.Items[i] is TChartPanel then
      begin
        Pn := FSplitPanelList.Items[i] as TChartPanel;
        Pn.FTagList.Update;
      end;
    end;
  end;
end;

procedure TWykresEng.ExecNewValZoom(Panel: TChartPanel);
begin
  UpdateTagList;
  FInvertBox.UpdatePos;
  if Assigned(FOnNewValZoom) then
    FOnNewValZoom(self, Panel);
end;

procedure TWykresEng.GetTimeWindow(var TimeStr: real; var TimeDlt: real);
var
  DL: real;
begin
  DL := DtPerProbka * FProbCnt;
  TimeStr := FTimeWindowStart * DL - TimeOfset;
  TimeDlt := FTimeWindowDelta * DL;
end;

procedure TWykresEng.FSetBottomBoxHeight(ABottomOpisHeight: integer);
begin
  FBottomBoxHeight := ABottomOpisHeight;
  LiczWymiary(rsmNoChange);
  Invalidate;
end;

procedure TWykresEng.FSetTitleBoxHeight(ATitleBoxHeight: integer);
begin
  FTitleBoxHeight := ATitleBoxHeight;
  LiczWymiary(rsmNoChange);
  Invalidate;
end;

procedure TWykresEng.FSetWorkMode(aWorkMode: TWorkMode);
begin
  FWorkMode := aWorkMode;
  if (FWorkMode = wmCursor) or (FWorkMode = wmBox) then
    FSavedMode := FWorkMode;
end;

procedure TWykresEng.FSetColorMode(AColorMode: TColorMode);
begin
  if AColorMode <> FColorMode then
  begin
    FColorMode := AColorMode;
    Invalidate;
  end;
end;

procedure TWykresEng.FSetDrawMode(ADrawMode: TDrawMode);
begin
  if ADrawMode <> FDrawMode then
  begin
    FDrawMode := ADrawMode;
    Invalidate;
  end;
end;

procedure TWykresEng.FSetShowPoints(AShowPoints: boolean);
begin
  if FShowPoints <> AShowPoints then
  begin
    FShowPoints := AShowPoints;
    Invalidate;
  end;
end;

// zamienia wartosc w pixlach na wartosc z przedzialu 0..1
function TWykresEng.PixelToReal(x: integer): Nrml;
begin
  with GDataArea do
    Result := FTimeWindowStart + FTimeWindowDelta * (x - Left) / (Right - Left);
end;

function TWykresEng.GetCurrMouseXWzgl: Nrml;
begin
  Result := PixelToReal(MsLastPoint.x);
end;

function TWykresEng.FgetPanelTags: boolean;
begin
  Result := not(Assigned(FTagList));
end;

procedure TWykresEng.FSetTagKey(Mode: boolean);
begin
  FTagKey := Mode;
  Invalidate;
end;

procedure TWykresEng.FSetProbCnt(aProgCnt: integer);
begin
  FProbCnt := aProgCnt;
  LiczWymiary(rsmNoChange);
end;

procedure TWykresEng.FSetPanelTags(Mode: boolean);
var
  i: integer;
  Pn: TChartPanel;
  Tags: TTagList;
begin
  if CanEditTags then
  begin
    if not(Mode) then
    begin
      FTagList := TTagList.Create(self);
      Pn := FocusedPanel;
      if Assigned(Pn) then
        FTagList.CopyFrom(Pn.FTagList);
      for i := 0 to FSplitPanelList.Count - 1 do
      begin
        if FSplitPanelList.Items[i] is TChartPanel then
        begin
          Pn := FSplitPanelList.Items[i] as TChartPanel;
          CheckFreeAndNil(Pn.FTagList);
        end;
      end;
    end
    else
    begin
      for i := 0 to FSplitPanelList.Count - 1 do
      begin
        if FSplitPanelList.Items[i] is TChartPanel then
        begin
          Pn := FSplitPanelList.Items[i] as TChartPanel;
          Pn.FTagList := TTagList.Create(self, Pn)
        end;
      end;
      Pn := FocusedPanel;
      Tags := FTagList; // tak musi zostaæ, ¿eby dzia³a³a CanAddTag
      FTagList := nil;
      if Assigned(Pn) then
        Pn.FTagList.CopyFrom(Tags);
      CheckFreeAndNil(Tags);
    end;
    Invalidate;
  end;
end;

procedure TWykresEng.CopyTags(SrcPanle: TChartPanel);
var
  FocPanel: TChartPanel;
  i: integer;
begin
  if PanelTags then
  begin
    FocPanel := FocusedPanel;
    if Assigned(FocPanel) then
    begin
      for i := 0 to FSplitPanelList.Count - 1 do
      begin
        if FSplitPanelList.Items[i] <> FocPanel then
        begin
          if FSplitPanelList.Items[i] is TChartPanel then
          begin
            (FSplitPanelList.Items[i] as TChartPanel).FTagList.CopyFrom(FocPanel.FTagList);
          end;
        end;
      end;
    end;
    Invalidate;
  end;
end;

function TWykresEng.GetActiveTagList: TTagList;
var
  Pn: TChartPanel;
begin
  Result := nil;
  if PanelTags then
  begin
    Pn := FocusedPanel;
    if Assigned(Pn) then
      Result := Pn.FTagList;
  end
  else
    Result := FTagList;
end;

function TWykresEng.CanAddTag: boolean;
var
  Tags: TTagList;
begin
  Result := false;
  if CanEditTags then
  begin
    Tags := GetActiveTagList;
    if Assigned(Tags) then
    begin
      Result := true;
      if MaxTagCnt > 0 then
      begin
        Result := Tags.Count < MaxTagCnt
      end;
    end;
  end;
end;

function TWykresEng.CanAddTag(Tags: TTagList): boolean;
begin
  Result := false;
  if CanEditTags then
  begin
    if not(PanelTags) then
      Tags := FTagList;
    if Assigned(Tags) then
    begin
      Result := true;
      if MaxTagCnt > 0 then
      begin
        Result := Tags.Count < MaxTagCnt
      end;
    end;
  end;
end;

function TWykresEng.CanDelTag: boolean;
var
  Tags: TTagList;
begin
  Result := false;
  if CanEditTags then
  begin
    Tags := GetActiveTagList;
    if Assigned(Tags) then
    begin
      Result := Tags.Count > 0;
    end;
  end;
end;

procedure TWykresEng.LiczNewTimeWindow(var Str: real; var Del: real; Regular: boolean);
var
  T1, T2, w: integer;
begin
  T1 := MsDownPoint.x;
  T2 := MsLastPoint.x;
  if T2 > T1 then
  begin
    with GDataArea do
    begin
      w := Right - Left;
      Str := FTimeWindowStart + FTimeWindowDelta * (T1 - Left) / w;
      Del := FTimeWindowDelta * (T2 - T1) / w;
      if Regular then
      begin
        if FTimeWindowDelta > 10 then
        begin
          Str := trunc(Str);
        end;
        if FTimeWindowDelta > 20 then
        begin
          Del := trunc(Del);
        end;
      end;
    end;
  end
  else
  begin
    Str := 0;
    Del := 1;
  end;
end;

function TWykresEng.TimeZoomSet(Str, Delt: real): boolean;
const
  MAX_PIX = 25;
var
  w: integer;
  N: integer;
  DoIt: boolean;
begin
  if Delt > 1 then
    Delt := 1;
  if Str < 0 then
    Str := 0;
  if Str > 1 - Delt then
    Str := 1 - Delt;

  // Ograniczenie Zoom'u w czasie
  if (FTimeWindowDelta = Delt) and (FTimeWindowStart <> Str) then
  begin
    DoIt := true;
  end
  else
  begin
    w := GDataArea.Right - GDataArea.Left;
    N := round(FProbCnt * Delt);
    DoIt := true;
    if w / MAX_PIX > N then
    begin
      Delt := w / (MAX_PIX) / FProbCnt;
      DoIt := (FTimeWindowDelta <> Delt);
    end;
  end;
  if (FTimeWindowStart = Str) and (FTimeWindowDelta = Delt) then
    DoIt := false;

  if DoIt then
  begin
    FTimeWindowStart := Str;
    FTimeWindowDelta := Delt;
    FBottomPanel.SetNewZoom;
    FInvertBox.UpdatePos;
    UpdateTagList;

    Invalidate;
    if Assigned(FOnNewTimeZoom) then
      FOnNewTimeZoom(self);

  end;
  Result := DoIt;
end;

procedure TWykresEng.DoTagNotify(Tag: TTag; Panel: TChartPanel; Func: TTagFunc);
begin
  if Assigned(FOnTagNotify) then
    FOnTagNotify(self, Panel, Tag, Func);
end;

// poka¿ odcinek czasu
function TWykresEng.TimeZoomTo(Tm, Delt: real): boolean;
var
  Dt: real;
begin
  Dt := TimeToReal(Delt);
  if Dt > 0 then
    Result := TimeZoomSet(TimeToReal(Tm), Dt)
  else
    Result := TimeZoomSet(0, 1);
end;

procedure TWykresEng.TimeUndoZoom;
begin
  TimeZoomSet(0, 1);
end;

procedure TWykresEng.TimeZoomIn;
begin
  TimeZoomSet(FTimeWindowStart + 0.25 * FTimeWindowDelta, 0.5 * FTimeWindowDelta);
end;

procedure TWykresEng.ValShiftUp;
var
  FocusedPanel: TChartPanel;
begin
  FocusedPanel := FSplitPanelList.FocusedPanel as TChartPanel;
  if Assigned(FocusedPanel) then
    FocusedPanel.ShiftUp
end;

procedure TWykresEng.ValShiftDn;
var
  FocusedPanel: TChartPanel;
begin
  FocusedPanel := FSplitPanelList.FocusedPanel as TChartPanel;
  if Assigned(FocusedPanel) then
    FocusedPanel.ShiftDn
end;

procedure TWykresEng.ValZoomIn;
var
  FocusedPanel: TChartPanel;
begin
  FocusedPanel := FSplitPanelList.FocusedPanel as TChartPanel;
  if Assigned(FocusedPanel) then
    FocusedPanel.ZoomIn;
end;

procedure TWykresEng.ValZoomOut;
var
  FocusedPanel: TChartPanel;
begin
  FocusedPanel := FSplitPanelList.FocusedPanel as TChartPanel;
  if Assigned(FocusedPanel) then
    FocusedPanel.ZoomOut;
end;

function TWykresEng.ValIsZoomed: boolean;
var
  FocusedPanel: TChartPanel;
begin
  FocusedPanel := FSplitPanelList.FocusedPanel as TChartPanel;
  if Assigned(FocusedPanel) then
    Result := FocusedPanel.Zoomed
  else
    Result := true;
end;

procedure TWykresEng.ValFullZoom;
begin
  FSplitPanelList.FullZoom;
end;

procedure TWykresEng.ValUndoZoom;
begin
  FSplitPanelList.UndoZoom;
end;

procedure TWykresEng.ExpandPanel;
begin
  SetZoomed(true);
end;

procedure TWykresEng.CollapsePanel;
begin
  SetZoomed(false);
end;

function TWykresEng.CanCollapse: boolean;
var
  Pn: TChartPanel;
begin
  Result := false;
  Pn := FocusedPanel;
  if Assigned(Pn) then
    Result := pnZoomed in FocusedPanel.PanelOptions;
end;

function TWykresEng.CanExpand: boolean;
var
  Pn: TChartPanel;
begin
  Result := (FSplitPanelList.getCount([pnCanFocus]) > 1);
  Pn := FocusedPanel;
  if Assigned(Pn) then
    Result := not(pnZoomed in FocusedPanel.PanelOptions);
end;

function TWykresEng.IsAnyVZoom: boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to FSplitPanelList.Count - 1 do
  begin
    if pnVisible in FSplitPanelList.Items[i].PanelOptions then
    begin
      if FSplitPanelList.Items[i] is TChartPanel then
      begin
        Result := Result or ((FSplitPanelList.Items[i] as TChartPanel).DrawDelta < 1);
      end;
    end;
  end;
end;

procedure TWykresEng.TimeZoomInPt(x: integer);
var
  r: real;
  dr: real;
  ds: real;
begin
  if (x > GDataArea.Left) and (x < GDataArea.Right) then
  begin
    r := PixelToReal(x);
    ds := (r - FTimeWindowStart) / 2;
    dr := 0.5 * FTimeWindowDelta;
    r := r - ds;
    if r < 0 then
      r := 0;
    TimeZoomSet(r, dr);
  end
  else
    TimeZoomIn;
end;

procedure TWykresEng.TimeZoomOut;
begin
  TimeZoomSet(FTimeWindowStart - 0.5 * FTimeWindowDelta, 2 * FTimeWindowDelta);
end;

procedure TWykresEng.TimeZoomOutPt(x: integer);
var
  r: real;
  dr: real;
  ds: real;
begin
  if (x > GDataArea.Left) and (x < GDataArea.Right) then
  begin
    r := PixelToReal(x);
    ds := (r - FTimeWindowStart) * 2;
    dr := 2 * FTimeWindowDelta;
    r := r - ds;
    if r < 0 then
      r := 0;
    TimeZoomSet(r, dr);
  end
  else
    TimeZoomOut;
end;

procedure TWykresEng.TimeShiftLeft;
begin
  TimeZoomSet(FTimeWindowStart - 0.1 * FTimeWindowDelta, FTimeWindowDelta);
end;

procedure TWykresEng.TimeShiftRight;
begin
  TimeZoomSet(FTimeWindowStart + 0.1 * FTimeWindowDelta, FTimeWindowDelta)
end;

procedure TWykresEng.SetZoomToValInvert;
var
  Str, Del: double;
  VStr, VDel: double;
begin
  if FInvertBox.ValBoxExist then
  begin
    Str := FInvertBox.TimeStr;
    Del := FInvertBox.TimeEnd - FInvertBox.TimeStr;
    VStr := FInvertBox.ValStr;
    VDel := FInvertBox.ValEnd - FInvertBox.ValStr;
    FInvertBox.Clear;
    TimeZoomSet(Str, Del);
    FInvertBox.Panel.SetNewValZoom(VStr, VDel);
    Invalidate;
  end;
end;

procedure TWykresEng.SetZoomToInvert;
var
  z: boolean;
  Str, Del: double;
begin
  if FInvertBox.TimeBoxExist then
  begin
    Str := FInvertBox.TimeStr;
    Del := FInvertBox.TimeEnd - FInvertBox.TimeStr;
    FInvertBox.Clear;
    z := TimeZoomSet(Str, Del);
    if z then
      FSplitPanelList.PaintInfoBox(false)
    else
      Invalidate;
  end;
end;

function TWykresEng.GetDataAreaEnd: integer;
begin
  Result := FArea.Right - FArea.Left;
  if FAnyDataZoomed then
    Result := Result - FDataScrollBarWidth;
end;

// wejœcie - pozycja wzgl¹dna dla osi czasu w zakresie 0..1
// wyjœcie - czas w sekundach
function TWykresEng.RealToTime(P: Nrml): double;
begin
  Result := FProbCnt * DtPerProbka;
  Result := P * Result - TimeOfset;
end;

// wejœcie - czas w sekundach
// wyjœcie - pozycja wzgl¹dna dla osi czasu w zakresie 0..1
function TWykresEng.TimeToReal(P: double): Nrml;
begin
  Result := (P + TimeOfset) / (FProbCnt * DtPerProbka);
  if Result > 1 then
    Result := -1;
  if Result < 0 then
    Result := -1;
end;

// wejscie w sekundach
function TWykresEng.GiveTimeStrTm(Tm: real; Jed: boolean): string;
var
  M: TTmFormatMode;
begin
  M := GetTmPrzedzial(Tm);
  if FForceMiliSek then
    M := tfSec;
  Result := WykrTimeStr(M, Tm, Jed);
end;

// wejscie w procentach ekranu (uwzglednia przesuniecie)
function TWykresEng.GiveTimeStr(P: real; Jed: boolean): string;
begin
  Result := GiveTimeStrTm(FProbCnt * P * DtPerProbka - TimeOfset, Jed);
end;

// wejscie w procentach ekranu (uwzglednia przesuniecie)
// wyjscie: czas bezwzgledy
function TWykresEng.GiveFullTimeStr(P: real): string;
var
  N: real;
begin
  N := P * FProbCnt * DtPerProbka;
  N := StartTime + N / SecPerDay;
  Result := TimeToStr(N);
end;

function TWykresEng.GiveFullDateStr(P: real): string;
var
  N: real;
begin
  N := P * FProbCnt * DtPerProbka;
  N := StartTime + N / SecPerDay;
  DateTimeToString(Result, 'yyyy-mmm-dd', N);
end;

// wejscie w procentach ekranu (nie uwzglednia przesuniecie)
function TWykresEng.GiveTimeStrDelta(P: Nrml; Jed: boolean): string;
begin
  Result := GiveTimeStrTm(P * FProbCnt * DtPerProbka, Jed);
end;

// wejœcie - wzgl¹dna pozycja czasu [0..1]
// wyjscie - pozycja na ekranie w pixlach
function TWykresEng.LiczX(r: Nrml): integer;
begin
  with GDataArea do
  begin
    if r < FTimeWindowStart then
      Result := outLEFT
    else if r > FTimeWindowStart + FTimeWindowDelta then
      Result := outRIGHT
    else
      Result := round(((r - FTimeWindowStart) / FTimeWindowDelta) * (Right - Left) + Left);
  end;
end;

function TWykresEng.LiczX_Clip(r: Nrml): integer;
begin
  Result := LiczX(r);
  if Result = outLEFT then
    Result := GDataArea.Left;
  if Result = outRIGHT then
    Result := GDataArea.Right;
end;

function TWykresEng.GetNrProb4Real(r: Nrml): integer;
begin
  Result := round(r * FProbCnt);
  if Result < 0 then
    Result := 0;
  if Result > ProbCnt then
    Result := ProbCnt;
end;

function TWykresEng.ProbkaToTime(nrPr: integer): double;
begin
  if nrPr < 0 then
    Result := outLEFT
  else if nrPr > ProbCnt then
    Result := outRIGHT
  else
    Result := nrPr * DtPerProbka;
end;

procedure TWykresEng.AddTag(x, Y: integer);
var
  Pn: TGrSplitPanel;
begin
  if not(Assigned(FTagList)) then
  begin
    Pn := FSplitPanelList.PanelAtYPos(Y);
    if Assigned(Pn) then
      if Pn is TChartPanel then
      begin
        (Pn as TChartPanel).FTagList.AddTagAt(x);
      end;
  end
  else
  begin
    FTagList.AddTagAt(x);
  end;
  UpdateTagList;
end;

function TWykresEng.IsZoomingTime(Shift: TShiftState): boolean;
begin
  Result := (FWorkMode = wmZoomTime) or ((ssCtrl in Shift) and (FWorkMode in StabWorkMode));
end;

function TWykresEng.IsZoomingVal(Shift: TShiftState): boolean;
begin
  Result := (FWorkMode = wmZoomVal) or ((ssShift in Shift) and (FWorkMode in StabWorkMode));
end;

procedure TWykresEng.FSetSplitWidth(w: real);
begin
  GDataArea.Left := FArea.Left + SpliterRealToInt(w);
  inherited;
end;

function TWykresEng.MouseFarAway(Pt: Tpoint): boolean;
begin
  Result := (abs(MsDownPoint.x - Pt.x) > 5) or (abs(MsDownPoint.Y - Pt.Y) > 5);
end;

function TWykresEng.MouseDown(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
var
  FMode: TWorkMode;
  qq: boolean;
begin
  Result := false;

  MsDownPoint := Point(x, Y);
  MsLastPoint := Point(x, Y);
  FMouseWasWarAway := false;

  if Button = mbLeft then
  begin
    qq := FAnyPanelVisible and InRect(GDataArea, x, Y, LINE_MARGIN);
    if qq then
    begin
      if FInvertBox.TimeBoxExist then
      begin
        if FInvertBox.InTimeBox(x) then
        begin
          SetZoomToInvert;
          Result := true;
        end;
        SetInvertBox(false);
      end;

      if FInvertBox.ValBoxExist then
      begin
        if FInvertBox.InValBox(x, Y) then
        begin
          SetZoomToValInvert;
          Result := true;
        end;
        SetInvertBox(false);
      end;

      if not(Result) and Assigned(FTagList) then
        Result := FTagList.MouseDown(Button, Shift, x, Y);
    end;

    if not(Result) then
      Result := inherited MouseDown(Button, Shift, x, Y);

    if qq then
    begin
      if not(Result) then
      begin
        FMode := FWorkMode;
        if FMode in StabWorkMode then
        begin
          if ssShift in Shift then
            FMode := wmZoomVal;
          if ssCtrl in Shift then
            FMode := wmZoomTime;
        end;

        case FMode of
          wmCursor:
            begin
              FMeasuring := true;
              DrawSelect(true);
              Result := true;
            end;
          wmBox:
            begin
              FBoxSelect := true;
              DrawSelect(true);
              Result := true;
            end;
          wmNewTag:
            begin
              AddTag(x, Y);
              Result := true;
            end;
          wmZoomTime:
            begin
              FZoomingTime := true;
              DrawSelect(true);
              Result := true;
            end;
          wmZoomVal:
            begin

            end;
        end;
      end;
    end;
  end
  else if Button = mbRight then
  begin
    Result := true;
    FMouseShifting := true;
  end;

  if Button = mbLeft then
  begin
    if (FWorkMode = wmDelTag) or (FWorkMode = wmNewTag) then
    begin
      if not(ssShift in Shift) then
        WorkMode := FSavedMode;
    end;
  end;
end;

function TWykresEng.MouseMove(Shift: TShiftState; x, Y: integer): boolean;

  function HideCursorCr: boolean;
  begin
    Result := false;
    if Screen.Cursor = crTagEdit then
      Result := true;
    if Screen.Cursor = crTagDel then
      Result := true;
    if Screen.Cursor = crDel then
      Result := true;
    if Screen.Cursor = crSizeAll then
      Result := true;
    if Screen.Cursor = crTagMove then
      Result := true;
  end;

var
  ddx: real;
  nStart: real;
  Pt: Tpoint;
  FMode: TWorkMode;
begin
  Result := true;
  inherited MouseMove(Shift, x, Y);

  Pt := Point(x, Y);

  if MouseFarAway(Point(x, Y)) then
    FMouseWasWarAway := true;

  if Screen.Cursor = crCross then
  begin
    FMode := FWorkMode;
    if FMode in StabWorkMode then
    begin
      if ssShift in Shift then
        FMode := wmZoomVal;
      if ssCtrl in Shift then
        FMode := wmZoomTime;
    end;
    case FMode of
      wmZoomTime:
        Screen.Cursor := crZoomT_In;
      wmZoomVal:
        Screen.Cursor := crZoomV_In;
      wmBox:
        Screen.Cursor := crCrossBox;
      wmNewTag:
        Screen.Cursor := crNewTag;
      wmDelTag:
        Screen.Cursor := crDel;
    end;
  end;

  // ukrycie kursora
  DrawCursor(false);
  DrawSelect(false);

  if not(ssRight in Shift) then
  begin
    FMouseShifting := false;
  end;

  if FAnyPanelVisible and InRect(GDataArea, x, Y, LINE_MARGIN) then
  begin
    if FMouseShifting then
    begin
      if FMouseWasWarAway then
      begin
        Screen.Cursor := crSizeAll;
        ddx := 1.0 * (MsLastPoint.x - x) / (GDataArea.Right - GDataArea.Left);
        nStart := FTimeWindowStart + ddx * FTimeWindowDelta;
        TimeZoomSet(nStart, FTimeWindowDelta)
      end;
    end;

    if Assigned(FTagList) then
      FTagList.MouseMove(Shift, x, Y);

    MsLastPoint := Pt;

    DrawSelect(FZoomingTime or FMeasuring or FBoxSelect);
    DrawCursor(not(HideCursorCr));

    FSplitPanelList.Paint(true);
  end;

end;

function TWykresEng.MouseUp(Button: TMouseButton; Shift: TShiftState; x, Y: integer): boolean;
var
  Delt, Str: real;
begin
  inherited MouseUp(Button, Shift, x, Y);
  Screen.Cursor := crCross;

  if MouseFarAway(Point(x, Y)) then
    FMouseWasWarAway := true;

  if Button = mbLeft then
  begin
    // rozciaganie czasu
    if FZoomingTime then
    begin
      if IsZoomingTime(Shift) then
      begin
        LiczNewTimeWindow(Str, Delt, true);
        TimeZoomSet(Str, Delt);
      end;
      FZoomingTime := false;
      if FWorkMode = wmZoomTime then
        FWorkMode := FSavedMode;
      Invalidate;
    end;

    // wykonywanie pomiarow
    if FMeasuring then
    begin
      FMeasuring := false;
      SetInvertBox(true);
    end;

    if FBoxSelect then
    begin
      SetInvertValBox(true);

    end;
  end
  else if Button = mbRight then
  begin
    if FMouseWasWarAway then
    begin

    end;
  end;

  if Assigned(FTagList) then
    FTagList.MouseUp(Button, Shift, x, Y);

  DrawSelect(false);

  FMouseShifting := false;
  FZoomingTime := false;
  FMeasuring := false;
  FBoxSelect := false;

  Result := FMouseWasWarAway;
end;

procedure TWykresEng.DrawCursor(DoShow: boolean);
begin
  if DoShow xor FCurrsorVisible then
  begin
    FCanvas.Pen.Color := clBlue;
    FCanvas.Pen.Mode := pmNotXor;
    FCanvas.MoveTo(MsLastPoint.x, GDataArea.Top);
    FCanvas.LineTo(MsLastPoint.x, GDataArea.Bottom);
    FCanvas.MoveTo(GDataArea.Left, MsLastPoint.Y);
    FCanvas.LineTo(GDataArea.Right, MsLastPoint.Y);
    FCanvas.Pen.Mode := pmCopy;
  end;
  FCurrsorVisible := DoShow;
end;

procedure TWykresEng.FSetInfoFields(AInfoFields: TInfoFields);
begin
  FInfoFields := AInfoFields;
  SetMyPomiarBlok;
end;

procedure TWykresEng.SetMyPomiarBlok;
begin
  if FInvertBox.TimeBoxExist then
  begin
    FAnalogPanels.LiczPomiarBlok(FInvertBox.StartProb, FInvertBox.EndProb);
  end;
end;

procedure TWykresEng.SetInvertValBox(SetIt: boolean);
var
  Pn: TGrSplitPanel;
begin
  FInvertBox.Clear;
  if SetIt then
  begin
    Pn := FSplitPanelList.PanelAtYPos(MsDownPoint.Y);
    if Assigned(Pn) then
    begin
      if Pn is TAnalogPanel then
      begin
        FInvertBox.SetValBox(ComputeSelectBox, Pn as TAnalogPanel);
      end;
    end;
  end
end;

procedure TWykresEng.SetInvertBox(SetIt: boolean);
begin
  if SetIt then
    FInvertBox.SetTimeBox(MsDownPoint.x, MsLastPoint.x)
  else
    FInvertBox.Clear;
  FInvertBox.Show;
  SetMyPomiarBlok;
  FSplitPanelList.PaintInfoBox(false);
end;

function TWykresEng.ComputeSelectBox: TRect;
var
  B1, B2: TGrSplitPanel;
  Y: integer;
begin
  Y := MsLastPoint.Y;
  B1 := FSplitPanelList.PanelAtYPos(MsDownPoint.Y);
  B2 := FSplitPanelList.PanelAtYPos(Y);
  if B1 = B2 then
  begin
    Result := Rect(MsDownPoint.x, MsDownPoint.Y, MsLastPoint.x, MsLastPoint.Y);
  end
  else
  begin
    if not(Zoomed) then
    begin
      if Y < B1.ScrPos.Top then
        Y := B1.ScrPos.Top;
      if Y > B1.ScrPos.Bottom then
        Y := B1.ScrPos.Bottom;
    end;
    Result := Rect(MsDownPoint.x, MsDownPoint.Y, MsLastPoint.x, Y);
  end;
end;

procedure TWykresEng.DrawSelect(DoShow: boolean);
var
  r: TRect;
begin
  if DoShow xor FSelectBoxVisible then
  begin
    if not(FBoxSelect) then
      r := Rect(MsDownPoint.x, GDataArea.Top + 1, MsLastPoint.x, GDataArea.Bottom - 1)
    else
      r := ComputeSelectBox;
    FCanvas.Pen.Color := clRed;
    XorRectangle(FCanvas, r);
  end;
  FSelectBoxVisible := DoShow;
end;

procedure TWykresEng.DrawNoWorking(Quick: boolean);
var
  RR: TRect;
  w, H: integer;
  Cn: TCanvas;
begin
  if Quick then
    Exit;
  Cn := FCanvas;

  Cn.Brush.Color := clWhite;
  Cn.Brush.Style := bsSolid;
  Cn.Pen.Color := clBlack;
  Cn.Pen.Style := psSolid;

  RR := GWorkPanelBox;
  Cn.Rectangle(RR);
  w := (RR.Right - RR.Left) div 2;
  H := (RR.Bottom - RR.Top) div 2;
  RR := Bounds(RR.Left + w div 2, RR.Top + H div 2, w, H);
  Cn.Rectangle(RR);
  Cn.MoveTo(RR.Left, RR.Top);
  Cn.LineTo(RR.Right, RR.Bottom);
  Cn.MoveTo(RR.Left, RR.Bottom);
  Cn.LineTo(RR.Right, RR.Top);
end;

procedure TWykresEng.SetArea(RR: TRect);
begin
  FArea := RR;
  LiczWymiary(rsmProportional);
end;

procedure TWykresEng.LiczWymiary(RMode: TResizeMode);
begin
  LiczWymiary(RMode, toSCR);
end;

procedure TWykresEng.LiczWymiary(RMode: TResizeMode; Dst: TPaintDest);
begin
  LiczWymiary(FArea, RMode, Dst);
end;

procedure TWykresEng.LiczWymiary(aArea: TRect; RMode: TResizeMode; Dst: TPaintDest);
  function LiczTopBoxHeight: integer;
  begin
    if FTitleBoxHeight = -1 then
      FTitleBoxHeight := 3 * FCanvas.TextHeight('A');
    Result := FTitleBoxHeight;
  end;

  function LiczBottomHeight: integer;
  begin
    if FBottomBoxHeight = -1 then
      FBottomBoxHeight := FDataScrollBarWidth + FCanvas.TextHeight('A') + 8;
    Result := FBottomBoxHeight;
  end;

var
  Y, H: integer;
  y1: integer;
  Panel: TGrSplitPanel;
  SplW: integer;
  TitleH: integer;
  BottomH: integer;
begin
  FArea := aArea;
  FPaintDst := Dst;
  if IsUpDating then
    Exit;
  if IsRectEmpty(FArea) then
    Exit;

  GWorkPanelBox := FArea;
  TitleH := LiczTopBoxHeight;
  BottomH := LiczBottomHeight;

  inc(GWorkPanelBox.Top, TitleH);
  dec(GWorkPanelBox.Bottom, BottomH);

  GDataArea := GWorkPanelBox;
  SplW := SpliterRealToInt(FSplitWidth);
  inc(GDataArea.Left, SplW);

  FTopPanel.SetPosition(FArea.Top, TitleH);
  FBottomPanel.SetPosition(FArea.Bottom - BottomH, BottomH);

  FAnyDataZoomed := IsAnyPanelDataZoomed;
  if FAnyDataZoomed then
    GDataArea.Right := GDataArea.Right - FDataScrollBarWidth;

  Y := GWorkPanelBox.Top;
  H := GWorkPanelBox.Bottom - GWorkPanelBox.Top;

  // miejsce dla panelu Digital
  if FDigitalPanel.IsAnyDigit and FDigitalPanel.Visible then
  begin
    y1 := Y + H - FDigitalPanel.DigiHeight;
    FDigitalPanel.SetPosition(y1, FDigitalPanel.DigiHeight);
    dec(H, FDigitalPanel.DigiHeight);
  end;

  FAnyPanelVisible := FAnalogPanels.AnyActivVisible;
  if FAnyPanelVisible then
  begin
    if not(Zoomed) then
    begin
      case RMode of
        rsmEqual:
          FAnalogPanels.SetEquHeight(Y, H);
        rsmNoChange, rsmProportional:
          FAnalogPanels.SetProportionalHeight(Y, H);
      end;
    end
    else
    begin
      Panel := FAnalogPanels.FocusedOrFirst;
      if Assigned(Panel) then
        Panel.SetPosition(Y, H);
    end;
  end;
  FInvertBox.UpdatePos;
  FSplitedArea := true;
  UpdateTagList;
end;

function TWykresEng.FGetInvertStartProb: integer;
begin
  Result := FInvertBox.StartProb;
end;

function TWykresEng.FGetInvertEndProb: integer;
begin
  Result := FInvertBox.EndProb;
end;

function TWykresEng.FGetInvertTimeBoxExist: boolean;
begin
  Result := FInvertBox.Exist;
end;

// powieksz wykres do calego ekranu
procedure TWykresEng.SetZoomed(aZoomed: boolean);
var
  Panel: TGrSplitPanel;
begin
  Panel := nil;
  if aZoomed then
    Panel := FSplitPanelList.FocusedOrFirst;
  FSplitPanelList.SetZoomed(Panel);
  Zoomed := aZoomed;
  LiczWymiary(rsmNoChange);
  Invalidate;
end;

procedure TWykresEng.KeyDown(var Key: Word; Shift: TShiftState);

  procedure TabKeyFunc(Shift: TShiftState);
  var
    NewPanel: TChartPanel;
    H: THandle;
  begin
    NewPanel := nil;
    if not(ssShift in Shift) then
    begin
      if FocusedPanel <> FSplitPanelList.GetLastPanel then
      begin
        NewPanel := FSplitPanelList.GiveNextPanel(FocusedPanel) as TChartPanel;
      end
      else
      begin
        H := GetParentHandle;
        if H <> INVALID_HANDLE_VALUE then
          PostMessage(H, WM_NEXTDLGCTL, 0, 0);
        Invalidate;
      end;
    end
    else
    begin
      if FocusedPanel <> FSplitPanelList.GetFirstPanel then
      begin
        NewPanel := FSplitPanelList.GivePrevPanel(FocusedPanel) as TChartPanel;
      end
      else
      begin
        H := GetParentHandle;
        if H <> INVALID_HANDLE_VALUE then
          PostMessage(H, WM_NEXTDLGCTL, 0, 0);
        Invalidate;
      end;
    end;

    if Assigned(NewPanel) then
    begin
      DrawCursor(false);
      NewPanel.SetFocused;
      if not(Zoomed) then
      begin
        FocusedPanel.Paint(true);
        NewPanel.Paint(true);
        DrawCursor(true);
      end
      else
      begin
        LiczWymiary(rsmNoChange);
        Invalidate;
      end;
    end
  end;

var
  FocusedPanel: TChartPanel;
  NewPanel: TChartPanel;
  MemCursor: TCursor;
  TgList: TTagList;
begin
  FocusedPanel := FSplitPanelList.FocusedPanel as TChartPanel;
  if ssCtrl in Shift then
  begin
    if Key = ord('A') then
    begin
      FSetTagKey(not(FTagKey));
    end;
  end;

  if Key = VK_TAB then
    TabKeyFunc(Shift);

  if not(FTagKey) then
  begin
    case Key of
      VK_LEFT:
        if not(ssShift in Shift) then
          TimeShiftLeft
        else
          TimeZoomOut;

      VK_RIGHT:
        if not(ssShift in Shift) then
          TimeShiftRight
        else
          TimeZoomIn;
    end;
  end
  else
  begin
    TgList := nil;
    if not(PanelTags) then
      TgList := FTagList
    else
    begin
      if Assigned(FocusedPanel) then
        TgList := FocusedPanel.FTagList;
    end;

    if Assigned(TgList) then
    begin
      TgList.KeyDown(Key, Shift);
    end;
  end;

  if Assigned(FocusedPanel) then
  begin
    case Key of
      VK_UP:
        begin
          if not(ssShift in Shift) then
            FocusedPanel.ShiftUp
          else
            FocusedPanel.ZoomIn;
        end;
      VK_DOWN:
        begin
          if not(ssShift in Shift) then
            FocusedPanel.ShiftDn
          else
            FocusedPanel.ZoomOut;
        end;

      VK_INSERT:
        if not(FTagKey) then
        begin
          FSplitPanelList.SetAllVisible;
          LiczWymiary(rsmEqual);
          Invalidate;
        end;
      VK_DELETE:
        if not(FTagKey) then
        begin
          if FocusedPanel <> FSplitPanelList.GetLastPanel then
            NewPanel := FSplitPanelList.GiveNextPanel(FocusedPanel) as TChartPanel
          else
            NewPanel := FSplitPanelList.GivePrevPanel(FocusedPanel) as TChartPanel;
          FocusedPanel.Visible := false;
          if Assigned(NewPanel) then
            NewPanel.SetFocused
          else
            FAnyPanelVisible := false;
          LiczWymiary(rsmProportional);
          Invalidate;
          if Assigned(FOnHidenNotify) then
            FOnHidenNotify(self, FocusedPanel as TChartPanel);
        end;

      VK_PRIOR:
        SetZoomed(true);
      VK_NEXT:
        SetZoomed(false);
      VK_END:
        begin
          MemCursor := Screen.Cursor;
          Screen.Cursor := crHourGlass;
          if not(ssShift in Shift) then
            FocusedPanel.FullZoom
          else
            FSplitPanelList.FullZoom;
          Screen.Cursor := MemCursor;
        end;

      VK_HOME:
        if not(ssShift in Shift) then
          FocusedPanel.UndoZoom
        else
          FSplitPanelList.UndoZoom;
    end;
  end;
end;

procedure TWykresEng.Print;
begin
  Printer.Title := 'RP3 - Wykres';
  Printer.Orientation := poLandscape;

  Printer.BeginDoc;
  PaintDest := toPRN;

  FSetCanvas(Printer.Canvas);
  LiczWymiary(rsmNoChange, toPRN);
  // PaintAll(Printer.Canvas,toPRN);
  PaintDest := toSCR;
  Printer.EndDoc;

  LiczWymiary(rsmNoChange);
  Invalidate
end;

function TWykresEng.AddAnalogPanel: TAnalogPanel;
var
  insertPos: integer;
begin
  Result := FAnalogPanels.CreateNew;
  // uporz¹dkowanie listy FSplitPanelList
  insertPos := FSplitPanelList.IndexOf(FDigitalPanel);
  FSplitPanelList.Extract(Result); // chyba niepotrzebne
  FSplitPanelList.Insert(insertPos, Result);
  FAnyPanelVisible := true;
  if FAnalogPanels.Count = 1 then
    Result.SetFocused;
  LiczWymiary(rsmProportional, toSCR);
end;

function TWykresEng.InsertAnalogPanel(Index: integer): TAnalogPanel;
var
  insertPos: integer;
begin
  Result := FAnalogPanels.CreateNew(Index);
  // uporz¹dkowanie listy FSplitPanelList
  insertPos := -1;
  if (Index >= 0) and (Index < FAnalogPanels.Count) then
    insertPos := FSplitPanelList.IndexOf(FAnalogPanels.Items[Index]);
  if insertPos < 0 then
    insertPos := FSplitPanelList.IndexOf(FDigitalPanel);
  FSplitPanelList.Extract(Result); // chyba niepotrzebne
  FSplitPanelList.Insert(insertPos, Result);
  FAnyPanelVisible := true;
  if FAnalogPanels.Count = 1 then
    Result.SetFocused;
  LiczWymiary(rsmProportional, toSCR);
end;

function TWykresEng.InsertAnalogPanel(aPanel: TAnalogPanel): TAnalogPanel;
var
  idx: integer;
begin
  idx := FAnalogPanels.IndexOf(aPanel);
  if idx >= 0 then
    Result := InsertAnalogPanel(idx + 1)
  else
    Result := AddAnalogPanel;
end;

procedure TWykresEng.DoEnter;
var
  P: TChartPanel;
begin
  P := FSplitPanelList.GetFirstPanel as TChartPanel;
  if Assigned(P) then
    P.SetFocused;
  Invalidate;
end;

procedure TWykresEng.DoExit;
var
  Panel: TGrSplitPanel;
begin
  DrawCursor(false);
  Panel := FSplitPanelList.ClrFocused;
  if Assigned(Panel) then
    Panel.Paint(true);
  FTopPanel.Paint(true);
end;

procedure TWykresEng.PaintTo(Quick: boolean);
begin
  if FSplitedArea then
  begin
    inherited;
    FCurrsorVisible := false;
    FSelectBoxVisible := false;
    FInvertBox.FVisible := false;
    if FSplitPanelList.GetFirstPanel <> nil then
    begin
      FInvertBox.Show;
      if Assigned(FTagList) then
        FTagList.PaintTo(Quick);
    end
    else
      DrawNoWorking(Quick);
  end;

end;

function TWykresEng.FocusedPanel: TChartPanel;
begin
  Result := FSplitPanelList.FocusedPanel as TChartPanel;
end;

function TWykresEng.FocusedPanelIdx: integer;
begin
  Result := FSplitPanelList.IndexOf(FocusedPanel);
end;

procedure LoadCursors;
begin
  Screen.Cursors[crSizeW] := LoadCursor(HInstance, 'CRSIZEW');
  Screen.Cursors[crSizeE] := LoadCursor(HInstance, 'CRSIZEE');
  Screen.Cursors[crSizeN] := LoadCursor(HInstance, 'CRSIZEN');
  Screen.Cursors[crSizeS] := LoadCursor(HInstance, 'CRSIZES');
  Screen.Cursors[crZoomT_In] := LoadCursor(HInstance, 'ZOOMT_IN');
  Screen.Cursors[crZoomV_In] := LoadCursor(HInstance, 'ZOOMV_IN');
  Screen.Cursors[crCrossBox] := LoadCursor(HInstance, 'CROSS_BOX');
  Screen.Cursors[crNewTag] := LoadCursor(HInstance, 'NEW_TAG');
  Screen.Cursors[crTagMove] := LoadCursor(HInstance, 'MOVE_TAG');
  Screen.Cursors[crTagEdit] := LoadCursor(HInstance, 'EDIT_TAG');
  Screen.Cursors[crTagDel] := LoadCursor(HInstance, 'DEL_TAG');
  Screen.Cursors[crDel] := LoadCursor(HInstance, 'DEL');

end;

initialization

LoadCursors;
SerieCnt := 0;
PanelCnt := 0;

end.
