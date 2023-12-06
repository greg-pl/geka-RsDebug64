unit UpLoadDefUnit;

interface

uses
  SysUtils,Contnrs,
  ProgCfgUnit;

type
  TUpLoadItem = class(TObject)
    Name     : string;
    FileName : string;
    Adres    : string;
    MaxSize  : integer;
    StoreWin : boolean;
    StoreMenu: boolean;
    procedure SaveToIni(Ini : TDotIniFile; SName : string);
    procedure LoadFromIni(Ini : TDotIniFile; SName : string);
  end;

  TUpLoadList = class(TObjectList)
  private
    function  GetSName(nr : integer):string;
    function  GetItem(Index: Integer): TUpLoadItem;
  public
    property Items[Index: Integer]: TUpLoadItem read GetItem;
    procedure SaveToIni(Ini : TDotIniFile);
    procedure LoadFromIni(Ini : TDotIniFile);
  end;

var
 UpLoadList : TUpLoadList;

implementation

procedure TUpLoadItem.SaveToIni(Ini : TDotIniFile; SName : string);
begin
  Ini.WriteString(SName,'Name',Name);
  Ini.WriteString(SName,'FileName',FileName);
  Ini.WriteString(SName,'Adres',Adres);
  Ini.WriteInteger(SName,'MaxSize',MaxSize);
  Ini.WriteBool(SName,'StoreWin',StoreWin);
  Ini.WriteBool(SName,'StoreMenu',StoreMenu);
end;

procedure TUpLoadItem.LoadFromIni(Ini : TDotIniFile; SName : string);
begin
  Name := Ini.ReadString(SName,'Name',Name);
  FileName := Ini.ReadString(SName,'FileName',FileName);
  Adres := Ini.ReadString(SName,'Adres',Adres);
  MaxSize :=  Ini.ReadInteger(SName,'MaxSize',MaxSize);
  StoreWin := Ini.ReadBool(SName,'StoreWin',StoreWin);
  StoreMenu := Ini.ReadBool(SName,'StoreMenu',StoreMenu);
end;

function  TUpLoadList.GetItem(Index: Integer): TUpLoadItem;
begin
  Result := inherited Items[Index] as TUpLoadItem;
end;

function TUpLoadList.GetSName(nr : integer):string;
begin
  Result := 'UPLOAD_DEF_'+IntToStr(nr);
end;

procedure TUpLoadList.SaveToIni(Ini : TDotIniFile);
var
  i     : integer;
begin
  for i:=0 to Count-1 do
  begin
    Items[i].SaveToIni(Ini,GetSName(i));
  end;
  i := Count;
  while Ini.SectionExists(GetSName(i)) do
  begin
    Ini.EraseSection(GetSName(i));
    inc(i);
  end;
end;


procedure TUpLoadList.LoadFromIni(Ini : TDotIniFile);
var
  i  : integer;
  V  : TUpLoadItem;
begin
  i := 0;
  while Ini.SectionExists(GetSName(i)) do
  begin
    V := TUpLoadItem.Create;
    V.LoadFromIni(Ini,GetSname(i));
    Add(V);
    inc(i);
  end;
end;

initialization
  UpLoadList := TUpLoadList.Create;
finalization
  UpLoadList.Free;


end.
