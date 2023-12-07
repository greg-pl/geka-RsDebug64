unit PictureView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ImgList, ActnList, ExtCtrls, StdCtrls, ComCtrls,
  ToolWin,IniFiles,ShellApi,
  ProgCfgUnit,
  RsdDll,
  CommThreadUnit;

type
  TBytes = array of byte;
  TPictureViewForm = class(TChildForm)
    ScrollBox1: TScrollBox;
    DrukImage: TImage;
    StretchBox: TCheckBox;
    ProportionalBox: TCheckBox;
    AdresBox: TComboBox;
    VarListBox: TComboBox;
    AdrModeGroup: TRadioGroup;
    Label2: TLabel;
    WidthBoxEdit: TComboBox;
    Label1: TLabel;
    HeightBoxEdit: TComboBox;
    Label3: TLabel;
    ActionList1: TActionList;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton1: TToolButton;
    ToolButton5: TToolButton;
    ReadAct: TAction;
    WriteAct: TAction;
    SaveAct: TAction;
    OpenAct: TAction;
    BppGroup: TRadioGroup;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ClearAct: TAction;
    HLGroup: TRadioGroup;
    EditColorAct: TAction;
    ToolButton8: TToolButton;
    Color1Box: TPaintBox;
    Color2Box: TPaintBox;
    Color4Box: TPaintBox;
    Color3Box: TPaintBox;
    ZoomBox: TComboBox;
    Label4: TLabel;
    OpenInPaintAct: TAction;
    ToolButton9: TToolButton;
    procedure StretchBoxClick(Sender: TObject);
    procedure ProportionalBoxClick(Sender: TObject);
    procedure ReadActUpdate(Sender: TObject);
    procedure ReadActExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OpenActExecute(Sender: TObject);
    procedure SaveActExecute(Sender: TObject);
    procedure BppGroupClick(Sender: TObject);
    procedure WriteActExecute(Sender: TObject);
    procedure ClearActExecute(Sender: TObject);
    procedure WidthBoxEditExit(Sender: TObject);
    procedure HeightBoxEditExit(Sender: TObject);
    procedure BoxEditKeyPress(Sender: TObject; var Key: Char);
    procedure VarListBoxChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure EditColorActExecute(Sender: TObject);
    procedure Color1BoxClick(Sender: TObject);
    procedure Color1BoxDblClick(Sender: TObject);
    procedure Color1BoxPaint(Sender: TObject);
    procedure BoxEditSelect(Sender: TObject);
    procedure DrukImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ZoomBoxExit(Sender: TObject);
    procedure OpenInPaintActExecute(Sender: TObject);
  private
    bmp       : TBitmap;
    PenColor  : TColor;
    ColorTab  : array[0..3] of TColor;
    PicBuffer : TBytes;

    function  GetZoom : double;
    function  GetWidth : integer;
    function  GetHeight : integer;
    function  GetBitPerPixel: integer;

    function  GetBitPerPixelFrm: TPixelFormat;
    procedure SetBitPerPixel(abpp: integer); overload;
    procedure SetBitPerPixel(bfrm: TPixelFormat); overload;
    function  GetIntPerPixel(bfrm: TPixelFormat) : integer;
    function  getHL : boolean;

    function  GetPicSize(w,h:integer; bpp:TPixelFormat): integer; overload;
    function  GetPicSize(w,h,bpp:integer): integer; overload;
    function  GetPicSize: integer; overload;
    procedure UpdateStatusBar;
    function  GetBufferVal(PicBuffer : TBytes; frm :TPixelFormat; w,x,y : integer): integer;
    procedure SetBufferVal(var PicBuffer : TBytes; frm :TPixelFormat; w,x,y,val : integer);
    function  GetColor(frm :TPixelFormat; a : integer):TColor;
    function  SetColor(frm :TPixelFormat; c : TColor): integer;
    procedure FillBitmap(PicBuffer : TBytes);
    procedure ReadBitmap(var PicBuffer : TBytes);
    function  GetColorNr(Sender: TObject) : integer;
    procedure wmReadMem1(var Msg: TMessage);message  wm_ReadMem1;
    procedure wmWriteMem1(var Msg: TMessage);message wm_WriteMem1;
  public
    procedure SaveToIni(Ini : TDotIniFile; SName : string); override;
    procedure LoadFromIni(Ini : TDotIniFile; SName : string); override;
    procedure ReloadMapParser; override;
    function  GetDefaultCaption : string; override;
  end;

var
  PictureViewForm: TPictureViewForm;

implementation

{$R *.dfm}

uses
  Math,
  ToolsUnit,
  MapParserUnit;


procedure TPictureViewForm.FormCreate(Sender: TObject);
begin
  inherited;
  bmp := TBitmap.Create;
  ColorTab[0]:=clBlack;
  ColorTab[1]:=clWhite;
  ColorTab[2]:=clRed;
  ColorTab[3]:=clBlue;
end;

procedure TPictureViewForm.FormDestroy(Sender: TObject);
begin
  inherited;
  bmp.Free;
end;

procedure TPictureViewForm.FormActivate(Sender: TObject);
begin
  inherited;
  ReloadMapParser;
end;

function  TPictureViewForm.GetZoom : double;
begin
  if not(TryStrToFloat(ZoomBox.Text,Result)) then
  begin
    ZoomBox.Text := '1';
    Result := 1;
  end;
end;


function TPictureViewForm.GetWidth : integer;
var
  v : cardinal;
begin
  if StrToCInt(WidthBoxEdit.Text,v) then
    Result := v
  else
  begin
    WidthBoxEdit.Text := '120';
    Result := 120;
  end;
end;

function TPictureViewForm.GetHeight : integer;
var
  v : cardinal;
begin
  if StrToCInt(HeightBoxEdit.Text,v) then
    Result := v
  else
  begin
    HeightBoxEdit.Text := '120';
    Result := 120;
  end;
end;

function TPictureViewForm.GetBitPerPixel: integer;
begin
  case BppGroup.ItemIndex of
  0 : Result := 1;
  1 : Result := 4;
  2 : Result := 8;
  3 : Result := 16;
  4 : Result := 24;
  else
    Result := -1;
  end;
end;

function  TPictureViewForm.GetBitPerPixelFrm: TPixelFormat;
begin
  case BppGroup.ItemIndex of
  0 : Result := pf1bit;
  1 : Result := pf4bit;
  2 : Result := pf8bit;
  3 : Result := pf16bit;
  4 : Result := pf24bit;
  else
    Result := pfCustom;
  end;
end;

procedure TPictureViewForm.SetBitPerPixel(bfrm: TPixelFormat);
begin
  case bfrm of
  pf1bit : BppGroup.ItemIndex:=0;
  pf4bit : BppGroup.ItemIndex:=1;
  pf8bit : BppGroup.ItemIndex:=2;
  pf24bit: BppGroup.ItemIndex:=3;
  else
    BppGroup.ItemIndex:=-1;
  end;
end;

function TPictureViewForm.GetIntPerPixel(bfrm: TPixelFormat) : integer;
begin
  case bfrm of
  pf1bit : Result := 1;
  pf4bit : Result := 4;
  pf8bit : Result := 8;
  pf24bit: Result := 24;
  else
    raise Exception.Create('Nieproawidlowa wartosc PtrSize');
  end;
end;

procedure TPictureViewForm.SetBitPerPixel(abpp: integer);
begin
  case abpp of
  1 : BppGroup.ItemIndex:=0;
  4 : BppGroup.ItemIndex:=1;
  8 : BppGroup.ItemIndex:=2;
  16 : BppGroup.ItemIndex:=3;
  24: BppGroup.ItemIndex:=4;
  else
    BppGroup.ItemIndex:=-1;
  end;
end;


function  TPictureViewForm.GetPicSize(w,h,bpp:integer): integer;
begin
  case bpp of
  1 : Result := ((w+7) div 8)*h;
  4 : Result := ((w+1) div 2)*h;
  8 : Result := w*h;
  16: Result := 2*w*h;
  24: Result := 3*w*h;
  else
    raise Exception.Create('Nieproawidlowa wartosc PtrSize');
  end;
end;

function  TPictureViewForm.GetPicSize(w,h:integer; bpp:TPixelFormat): integer;
begin
  Result := GetPicSize(w,h,GetIntPerPixel(bpp));
end;

function TPictureViewForm.GetPicSize: integer;
var
  w,h : integer;
  bpp : integer;
begin
  w := GetWidth;
  h := GetHeight;
  bpp := GetBitPerPixel;
  Result := GetPicSize(w,h,bpp);
  UpdateStatusBar;
end;

procedure TPictureViewForm.UpdateStatusBar;
var
  w,h : integer;
  bpp : integer;
begin
  w := GetWidth;
  h := GetHeight;
  bpp := GetBitPerPixel;
  StatusBar.Panels[2].Text := format('%ux%u',[w,h]);
  StatusBar.Panels[3].Text := format('%ubpp',[bpp]);
  StatusBar.Panels[4].Text := format('%u bytes',[GetPicSize(w,h,bpp)]);
end;

procedure TPictureViewForm.StretchBoxClick(Sender: TObject);
var
  z : double;
begin
  inherited;
  z := GetZoom;
  if not(StretchBox.Checked) then
  begin
    DrukImage.Stretch := (z<>1);
    DrukImage.Align := alNone;
    DrukImage.Width := round(GetWidth*z);
    DrukImage.Height := round(GetHeight*z);
  end
  else
  begin
    DrukImage.Stretch := true;
    DrukImage.Align := alClient
  end;
  ZoomBox.Enabled := not(StretchBox.Checked);
end;

procedure TPictureViewForm.ProportionalBoxClick(Sender: TObject);
begin
  inherited;
  DrukImage.Proportional := (sender as TCheckBox).Checked;
end;

procedure TPictureViewForm.ReloadMapParser;
begin
  inherited;
  MapParser.MapItemList.LoadToList(VarListBox.Items);
end;

function  TPictureViewForm.GetDefaultCaption : string;
begin
  Result :=  'PIC : ' +AdresBox.Text;
end;

procedure TPictureViewForm.SaveToIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  Ini.WriteString(SName,'Adr',AdresBox.Text);
  Ini.WriteString(SName,'Adrs',AdresBox.Items.CommaText);
  Ini.WriteInteger(SName,'AdrMode',AdrModeGroup.ItemIndex);

  Ini.WriteString(SName,'PicWidth',WidthBoxEdit.Text);
  Ini.WriteString(SName,'PicWidths',WidthBoxEdit.Items.CommaText);

  Ini.WriteString(SName,'PicHeight',HeightBoxEdit.Text);
  Ini.WriteString(SName,'PicHeights',HeightBoxEdit.Items.CommaText);

  Ini.WriteInteger(SName,'PicZoomBox',ZoomBox.ItemIndex);

  Ini.WriteBool(SName,'Stretch',StretchBox.Checked);
  Ini.WriteBool(SName,'Proportional',ProportionalBox.Checked);
  Ini.WriteInteger(SName,'BitPerPixel',GetBitPerPixel);

  Ini.WriteInteger(SName,'Color1',ColorTab[0]);
  Ini.WriteInteger(SName,'Color2',ColorTab[1]);
  Ini.WriteInteger(SName,'Color3',ColorTab[2]);
  Ini.WriteInteger(SName,'Color4',ColorTab[3]);

  Ini.WriteInteger(SName,'LH',HLGroup.ItemIndex);
end;


procedure TPictureViewForm.LoadFromIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  AdresBox.Items.CommaText:=Ini.ReadString(SName,'Adrs','0,4000,8000,800000');
  AdresBox.Text        := Ini.ReadString(SName,'Adr','0');
  AdrModeGroup.ItemIndex := Ini.ReadInteger(SName,'AdrMode',0);

  WidthBoxEdit.Items.CommaText := Ini.ReadString(SName,'PicWidths',WidthBoxEdit.Items.CommaText);
  WidthBoxEdit.Text := Ini.ReadString(SName,'PicWidth',WidthBoxEdit.Text);

  HeightBoxEdit.Items.CommaText := Ini.ReadString(SName,'PicHeights',HeightBoxEdit.Items.CommaText);
  HeightBoxEdit.Text := Ini.ReadString(SName,'PicHeight',HeightBoxEdit.Text);

  ZoomBox.ItemIndex := Ini.ReadInteger(SName,'PicZoomBox',ZoomBox.ItemIndex);

  StretchBox.Checked := Ini.ReadBool(SName,'Stretch',StretchBox.Checked);
  ProportionalBox.Checked := Ini.ReadBool(SName,'Proportional',ProportionalBox.Checked);
  SetBitPerPixel(Ini.ReadInteger(SName,'BitPerPixel',GetBitPerPixel));

  ColorTab[0] := Ini.ReadInteger(SName,'Color1',ColorTab[0]);
  ColorTab[1] := Ini.ReadInteger(SName,'Color2',ColorTab[1]);
  ColorTab[2] := Ini.ReadInteger(SName,'Color3',ColorTab[2]);
  ColorTab[3] := Ini.ReadInteger(SName,'Color4',ColorTab[3]);

  HLGroup.ItemIndex := Ini.ReadInteger(SName,'LH',HLGroup.ItemIndex);

  Bmp.Width := GetWidth;
  Bmp.Height := GetHeight;
  StretchBoxClick(nil);
  DrukImage.Picture.Assign(bmp);
end;

procedure TPictureViewForm.VarListBoxChange(Sender: TObject);
begin
  inherited;
  AdresBox.Text :=VarListBox.Items[VarListBox.ItemIndex];
end;


procedure TPictureViewForm.ReadActUpdate(Sender: TObject);
begin
  inherited;
  (Sender  as TAction).Enabled := IsConnected and (GetBitPerPixel>0);
end;

procedure TPictureViewForm.SetBufferVal(var PicBuffer : TBytes; frm :TPixelFormat; w,x,y,val : integer);
var
  wsk   : integer;
  mask  : byte;
  q     : boolean;
begin
  try
  case frm of
  pf1bit :
    begin
      wsk := ((w+7) div 8) * y + x div 8;
      if getHL then mask := ($80 shr (x mod 8))
               else mask := ($01 shl (x mod 8));
      if val<>0 then
        PicBuffer[wsk] := PicBuffer[wsk] or mask
      else
        PicBuffer[wsk] := PicBuffer[wsk] and not(mask);
    end;
  pf4bit :
    begin
      wsk := ((w+1) div 2) * y + x div 2;
      val := val and $0f;
      q := ((x mod 2)=0);
      if not(getHL) then
        q := not(q);
      if q then
      begin
        val := val shl 4;
        PicBuffer[wsk] := (PicBuffer[wsk] and $0f) or val;
      end
      else
      begin
        PicBuffer[wsk] := (PicBuffer[wsk] and $f0) or val;
      end;
    end;
  pf8bit :
    begin
      wsk := w * y + x;
      PicBuffer[wsk] := val;
    end;
  pf24bit:
    begin
      wsk := 3*(w * y + x);
      PicBuffer[wsk]   := val and $ff;
      PicBuffer[wsk+1] := (val shr 8) and $ff;
      PicBuffer[wsk+2] := (val shr 16) and $ff;
    end;
  end;
  except
  end;
end;

function TPictureViewForm.GetBufferVal(PicBuffer : TBytes; frm :TPixelFormat; w,x,y : integer): integer;
var
  wsk  : integer;
  a    : integer;
  mask : byte;
  q    : boolean;
begin
  case frm of
  pf1bit :
    begin
      wsk := ((w+7) div 8) * y + x div 8;
      a := PicBuffer[wsk];

      if getHL then  mask := ($80 shr (x mod 8))
               else  mask := ($01 shl (x mod 8));

      if (a and mask)<>0 then
        Result := 1
      else
        Result := 0;
    end;
  pf4bit :
    begin
      wsk := ((w+1) div 2) * y + x div 2;
      a := PicBuffer[wsk];
      q := ((x mod 2)=0);
      if not(getHL) then
        q := not(q);
      if q then
        Result := (a shr 4) and $0f
      else
        Result := a and $0f;
    end;
  pf8bit :
    begin
      wsk := w * y + x;
      result := PicBuffer[wsk];
    end;
  pf16bit :
    begin
      wsk := 2*(w * y + x);
      result := PicBuffer[wsk];
      result := result + $100 * PicBuffer[wsk+1];
    end;
  pf24bit:
    begin
      wsk := 3*(w * y + x);
      result := PicBuffer[wsk];
      result := result + $100 * PicBuffer[wsk+1];
      result := result + $10000 * PicBuffer[wsk+2];
    end;
  else
    raise exception.Create('Niesaportowany format pixla');
  end;
end;

const
  Tab16Color : array[0..15] of TColor = (clBlack,clMaroon,clGreen,clOlive,
                                         clNavy,clPurple,clTeal,clGray,
                                         clSilver,clRed,clLime,clYellow,
                                         clBlue,clFuchsia,clAqua,clLtGray);

function TPictureViewForm.GetColor(frm :TPixelFormat; a : integer):TColor;
  function E2C(b : byte):byte;
  begin
    Result:=0;
    if (b and $01)<>0 then Result := Result or $08;
    if (b and $02)<>0 then Result := Result or $80;
  end;
  function E3C(b : byte):byte;
  begin
    Result:=0;
    if (b and $01)<>0 then Result := Result or $04;
    if (b and $02)<>0 then Result := Result or $20;
    if (b and $04)<>0 then Result := Result or $80;
  end;

begin
  case frm of
  pf1bit :
    if a<>0 then  Result := clBlack
            else  Result := clWhite;
  pf4bit :
    Result := Tab16Color[a and $0f];
  pf8bit :
    begin
      Result := RGB(E2C((a shr 6) and $03),E3C((a shr 3) and $07),E3C(a and $07));
    end;
  pf24bit :
    Result := TColor(a);
  else
    raise exception.Create('Niesaportowany format pixla');
  end;
end;


function TPictureViewForm.SetColor(frm :TPixelFormat; c : TColor): integer;
  function C2B(b : byte):byte;
  begin
    Result:=0;
    if b>=$80 then
    begin
      Result := Result or $02;
      b := b-$80;
    end;
    if b>=$08 then
    begin
      Result := Result or $01;
    end;
  end;
  function C3B(b : byte):byte;
  begin
    Result:=0;
    if b>=$80 then
    begin
      Result := Result or $04;
      b := b-$80;
    end;
    if b>=$20 then
    begin
      Result := Result or $02;
      b := b-$20;
    end;
    if b>=$04 then
    begin
      Result := Result or $01;
    end;
  end;

var
  i: integer;  
begin
  case frm of
  pf1bit :
    if c=clWhite then  Result := 0
                 else  Result := 1;
  pf4bit :
    begin
      Result := clWhite;
      for i:=0 to 15 do
      begin
        if Tab16Color[i]=c then
        begin
          result := i;
          break;
        end;
      end;
    end;
  pf8bit :
    begin
      Result := (C2B(GetRValue(c)) shl 6) or
                (C3B(GetGValue(c)) shl 3) or
                 C3B(GetBValue(c));
    end;
  pf24bit :
    Result := integer(c) and $ffffff;
  else
    raise exception.Create('Niesaportowany format pixla');
  end;
end;


procedure TPictureViewForm.FillBitmap(PicBuffer : TBytes);
var
  w,h : integer;
  x,y : integer;
  frm : TPixelFormat;
  a   : integer;

begin
  w := GetWidth;
  h := GetHeight;
  frm := GetBitPerPixelFrm;
  Bmp.Width := w;
  Bmp.Height := h;
  Bmp.PixelFormat := frm;
  for y:=0 to h-1 do
  begin
    for x:=0 to w-1 do
    begin
      a := GetBufferVal(PicBuffer,frm,w,x,y);
      bmp.Canvas.Pixels[x,y] := GetColor(frm,a);
    end;
  end;
end;

procedure TPictureViewForm.ReadBitmap(var PicBuffer : TBytes);
var
  w,h : integer;
  x,y : integer;
  frm : TPixelFormat;
  a   : integer;
begin
  w := GetWidth;
  h := GetHeight;
  frm := GetBitPerPixelFrm;
  SetLength(PicBuffer,GetPicSize(w,h,frm));
  UpdateStatusBar;

  for y:=0 to h-1 do
  begin
    for x:=0 to w-1 do
    begin
      a := SetColor(frm,bmp.Canvas.Pixels[x,y]);
      SetBufferVal(PicBuffer,frm,w,x,y,a);
    end;
  end;
end;


procedure TPictureViewForm.OpenActExecute(Sender: TObject);
var
  Dlg : TOpenDialog;
begin
  inherited;
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.Filter := 'Bitmaps|*.bmp';
    if Dlg.Execute then
    begin
      bmp.LoadFromFile(Dlg.FileName);
      DrukImage.Picture.Assign(Bmp);
      WidthBoxEdit.Text := IntToStr(Bmp.Width-1);
      HeightBoxEdit.Text := IntToStr(Bmp.Height-1);
      SetBitPerPixel(Bmp.PixelFormat);
      UpdateStatusBar;
      StretchBoxClick(nil);
    end;
  finally
    Dlg.Free;
  end;

end;

procedure TPictureViewForm.SaveActExecute(Sender: TObject);
var
  Dlg : TSaveDialog;
begin
  inherited;
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.Filter := 'Bitmaps|*.bmp';
    Dlg.DefaultExt := '.bmp';
    if Dlg.Execute then
    begin
      bmp.SaveToFile(Dlg.FileName);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TPictureViewForm.BppGroupClick(Sender: TObject);
var
  frm : TPixelFormat;
begin
  inherited;
  frm := GetBitPerPixelFrm;
  Bmp.Monochrome := (frm=pf1bit);
  Bmp.PixelFormat := frm;
  Bmp.TransparentColor := clWhite;
  Bmp.TransparentMode := tmFixed; 

  DrukImage.Picture.Assign(bmp);
  UpdateStatusBar;
end;

procedure TPictureViewForm.ReadActExecute(Sender: TObject);
var
  addr : cardinal;
  MemSize : integer;
begin
  inherited;
  AddToList(AdresBox);
  addr := MapParser.StrToAdr(AdresBox.Text);
  addr  := AreaDefItem.GetPhAdr(addr);
  MemSize := GetPicSize;
  SetLength(PicBuffer,MemSize);
  CommThread.AddToDoItem(
    TWorkRdMemItem.Create(Handle,wm_ReadMem1,AdrModeGroup.ItemIndex=1,
      AreaDefItem,PicBuffer[0],addr,MemSize));
end;

procedure TPictureViewForm.wmReadMem1(var Msg: TMessage);
var
  Sm : TMemoryStream;
  item : TCommWorkItem;
begin
  item := TCommWorkItem(msg.WParam);
  FillBitmap(PicBuffer);
  DrukImage.Picture.Assign(bmp);
  DoMsg(Format('RdPic=%s',[Dev.GetErrStr(item.Result)]));
  Sm := TMemoryStream.Create;
  SM.Write(PicBuffer[0],length(PicBuffer));
  SM.SaveToFile('buf.bin');
  SM.Free;
  item.free;
end;

function TPictureViewForm.getHL : boolean;
begin
  Result := (HLGroup.ItemIndex=0);
end;

procedure TPictureViewForm.WriteActExecute(Sender: TObject);
var
  addr : cardinal;
  MemSize : integer;
begin
  inherited;
  AddToList(AdresBox);
  addr := MapParser.StrToAdr(AdresBox.Text);
  addr  := AreaDefItem.GetPhAdr(addr);

  MemSize := GetPicSize;
  SetLength(PicBuffer,MemSize);
  ReadBitmap(PicBuffer);
  CommThread.AddToDoItem(
   TWorkWrMemItem.Create(Handle,wm_WriteMem1,AdrModeGroup.ItemIndex=1,
     AreaDefItem,PicBuffer[0],addr,length(PicBuffer)));
end;

procedure TPictureViewForm.wmWriteMem1(var Msg: TMessage);
var
  item : TCommWorkItem;
begin
  item := TCommWorkItem(msg.WParam);
  DoMsg(Format('WrPic=%s',[Dev.GetErrStr(item.Result)]));
  item.Free;
end;

procedure TPictureViewForm.WidthBoxEditExit(Sender: TObject);
begin
  inherited;
  bmp.Width := GetWidth;
  DrukImage.Picture.Assign(bmp);
end;

procedure TPictureViewForm.HeightBoxEditExit(Sender: TObject);
begin
  inherited;
  bmp.Height := GetHeight;
  DrukImage.Picture.Assign(bmp);
end;

procedure TPictureViewForm.ClearActExecute(Sender: TObject);
begin
  inherited;
  bmp.Width := 0;
  bmp.Height := 0;
  bmp.Width := GetWidth;
  bmp.Height := GetHeight;
  DrukImage.Picture.Assign(bmp);
end;



procedure TPictureViewForm.BoxEditKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
  if Key=#13 then
    (Sender as TComboBox).OnExit(Sender);
end;

procedure TPictureViewForm.BoxEditSelect(Sender: TObject);
begin
  inherited;
  (Sender as TComboBox).OnExit(Sender);
end;


procedure TPictureViewForm.EditColorActExecute(Sender: TObject);
var
  Dlg : TColorDialog;
begin
  inherited;
  Dlg := TColorDialog.Create(self);
  try
    Dlg.Options := Dlg.Options + [cdSolidColor];
    if Dlg.Execute then
    begin
      PenColor := Dlg.Color;
    end;
  finally
    Dlg.Free;
  end;
end;

function TPictureViewForm.GetColorNr(Sender: TObject) : integer;
begin
       if Sender = Color1Box then Result := 0
  else if Sender = Color2Box then Result := 1
  else if Sender = Color3Box then Result := 2
  else if Sender = Color4Box then Result := 3
  else
    raise Exception.Create('Error Color object');
end;

procedure TPictureViewForm.Color1BoxClick(Sender: TObject);
begin
  inherited;
  PenColor := ColorTab[GetColorNr(Sender)];
  Color1Box.Refresh;
  Color2Box.Refresh;
  Color3Box.Refresh;
  Color4Box.Refresh;
end;

procedure TPictureViewForm.Color1BoxDblClick(Sender: TObject);
var
  Dlg : TColorDialog;
  nr  : integer;
begin
  inherited;
  nr := GetColorNr(sender);
  Dlg := TColorDialog.Create(self);
  try
    Dlg.Options := Dlg.Options + [cdSolidColor];
    Dlg.Color := colortab[nr];
    if Dlg.Execute then
    begin
      colortab[nr] := Dlg.Color;
      (Sender as TPaintBox).Refresh;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TPictureViewForm.Color1BoxPaint(Sender: TObject);
var
  px : TPaintBox;
  nr  : integer;
  cl  : TColor;
  R   : TRect;
  x,y : integer;
begin
  inherited;
  px := Sender as TPaintBox;
  nr := GetColorNr(Sender);
  px.Canvas.Brush.Color := ColorTab[nr];
  px.Canvas.Pen.Color := clBLACK;
  px.Canvas.FillRect(Rect(0,0,px.Width,px.Height));
  if ColorTab[nr]=PenColor then
  begin
    cl := RGB(255-GetRValue(PenColor),
              255-GetGValue(PenColor),
              255-GetBValue(PenColor));
    x := px.Width div 2;
    y := px.Height div 2;
    R := Rect(x-5,y-5,x+5,y+5);
    px.Canvas.Brush.Color := cl;
    px.Canvas.Ellipse(R);
  end;



end;

procedure TPictureViewForm.DrukImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  rx,ry : double;
  rr    : double;
begin
  inherited;
  if DrukImage.Stretch then
  begin
    if (bmp.Width<>0) and (bmp.Height<>0) then
    begin
      rx := DrukImage.Width / bmp.Width;
      ry := DrukImage.Height / bmp.Height;
      if DrukImage.Proportional then
      begin
        rr := Min(rx,ry);
        rx := rr;
        ry := rr;
      end;
      x := round(x/rx);
      y := round(y/ry);
    end;
  end;
  if ssLeft in Shift then
  begin
    if (x>=0) and (x<Bmp.Width) and
       (y>=0) and (y<Bmp.Height) then
    begin
      bmp.Canvas.Pixels[x,y]:=PenColor;
      DrukImage.Picture.Assign(Bmp);
    end;
  end;
  StatusBar.Panels[5].Text := format('x:%u y:%u',[x,y]);
end;

procedure TPictureViewForm.ZoomBoxExit(Sender: TObject);
begin
  inherited;
  StretchBoxClick(nil);
end;

procedure TPictureViewForm.OpenInPaintActExecute(Sender: TObject);
var
  FName : string;
begin
  inherited;
  FName := GetTempFile('.bmp');
  bmp.SaveToFile(FName);
  ShellExecute(0, 'edit', pchar(FName), nil, nil, SW_SHOWNORMAL);
end;

end.
