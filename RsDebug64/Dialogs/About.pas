unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ImgList, ComCtrls, ShellApi, ToolWin, StrUtils;

type
  TAboutForm = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    Version: TLabel;
    Label2: TLabel;
    Mail2Label: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Mail2LabelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Mail2LabelClick(Sender: TObject);
  private
    procedure SelectLabel(Sender : TObject);
  public
    { Public declarations }
  end;

procedure ShowAboutDlg;


implementation

{$R *.dfm}

procedure ShowAboutDlg;
var
  Dlg : TAboutForm;
begin
  Dlg := TAboutForm.Create(Application.MainForm);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;


function GetFileVersion(FName : string):string;
var
  intSize, intIndice : Integer;
  dwdDummy : DWord;
  uinSize : UINT;
  pchInfo : PChar;
  pntValor : Pointer;
  pntTranslation : Pointer;
  strBegin : String;
begin
  intSize := GetFileVersionInfoSize(PChar(FName),dwdDummy);
  if intSize > 0 then
  begin
    GetMem(pchInfo,intSize);
    GetFileVersionInfo(PChar(FName),0,intSize,pchInfo);
    VerQueryValue(pchInfo,'\\VarFileInfo\\Translation',pntTranslation,uinSize);
    strBegin := '\\StringFileInfo\\'+
    IntToHex(LoWord(LongInt(pntTranslation^)),4)+
    IntToHex(HiWord(LongInt(pntTranslation^)),4)+'\\';
    for intIndice:=1 to 11 do
    begin
      if VerQueryValue(pchInfo,PChar(strBegin+'FileVersion'),pntValor,uinSize) then
        if (uinSize > 0) and (intIndice=3)  then
        begin
          result := String(PChar(pntValor));
        end;
    end;
    FreeMem(pchInfo,intSize);
  end;
end;


procedure TAboutForm.FormActivate(Sender: TObject);
const
  InfoNum = 10;
  InfoStr: array[1..InfoNum] of string = ('CompanyName', 'FileDescription', 'FileVersion', 'InternalName', 'LegalCopyright', 'LegalTradeMarks', 'OriginalFileName', 'ProductName', 'ProductVersion', 'Comments');
var
  f      : file of byte;
  size   : Cardinal;
  tm     : TDateTime;
  MyPath : string;
  Fm     : byte;
  s      : string;
  n, Len, i: DWORD;
  Buf: PChar;
  Value: PChar;
begin
  Caption := 'RsDebuger';
  MyPath:=Application.ExeName;
  fm:=FileMode;
  FileMode := fmOpenRead;
  AssignFile(f, MyPath);
  {$I-}
  Reset(f);
  {$I+}
  size := FileSize(f);
  CloseFile(f);
  Memo1.Clear;

  Tm:=FileDateToDateTime(FileAge(MyPath));
  FileMode:=fm;
  DateTimeToString(s,'dd.mmm.yyyy',Tm);
  Memo1.Lines.Add('Nazwa : '+Application.ExeName);
  Memo1.Lines.Add('Data pliku : '+s);
  Memo1.Lines.Add('Rozmiar pliku: '+IntToStr(size)+' bajtów');
  s := GetFileVersion(Application.ExeName);
  Memo1.Lines.Add('Wersja : '+s);

  for i:=length(s) downto 1 do
  begin
    if s[i]='.' then
    begin
      s := copy(s,1,i-1);
      Break;
    end;
  end;

  Version.Caption := 'ver. '+s;

  n := GetFileVersionInfoSize(PChar(MyPath), n);
  if n > 0 then
  begin
    Buf := AllocMem(n);
    //Memo1.Lines.Add('VersionInfoSize = ' + IntToStr(n));
    GetFileVersionInfo(PChar(S), 0, n, Buf);
    for i := 1 to InfoNum do
      if VerQueryValue(Buf, PChar('\StringFileInfo\040904E4\' + InfoStr[i]), Pointer(Value), Len) then
        Memo1.Lines.Add(InfoStr[i] + ' = ' + Value);
    FreeMem(Buf, n);
  end
end;

procedure TAboutForm.SelectLabel(Sender : TObject);
  procedure DeselectLabel(Sender: TObject;L : TLabel);
  begin
    if Sender<>L then
    begin
      L.Font.Color:=clBlue;
      L.Font.Style:=[];
    end;
  end;
begin
  if Assigned(Sender) then
  begin
    (Sender as TLabel).Font.Color:=clRed;
    (Sender as TLabel).Font.Style:=[fsUnderline];
  end;
  DeselectLabel(Sender,Mail2Label);
end;


procedure TAboutForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  SelectLabel(nil);
end;

procedure TAboutForm.Mail2LabelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SelectLabel(sender);
end;

procedure TAboutForm.Mail2LabelClick(Sender: TObject);
var
  s: string;
  s1: string;
begin
  s:=(Sender as TLabel).Caption;
  if LeftStr(s,6)='email:' then
    s := copy(s,7,length(s)-6);
  s := Trim(s);
  s1 := 'mailto:'+s+'?subject=ANOT&body=Witam.';
  ShellExecute(0, 'open', pchar(s1), nil, nil, SW_SHOWNORMAL);
end;

end.
