unit UpLoadDefUnit;

interface

uses
  SysUtils, Contnrs,
  System.JSON,
  JSonUtils,
  ProgCfgUnit;

type
  TUpLoadItem = class(TObject)
    Name: string;
    FileName: string;
    Adres: string;
    MaxSize: integer;
    StoreWin: boolean;
    StoreMenu: boolean;
    procedure SaveToIni(Ini: TDotIniFile; SName: string);
    procedure LoadFromIni(Ini: TDotIniFile; SName: string);

    function GetJSONObject: TJSONBuilder;
    procedure LoadfromJson(jLoader: TJSONLoader);

  end;

  TUpLoadList = class(TObjectList)
  private
    function GetSName(nr: integer): string;
    function GetItem(Index: integer): TUpLoadItem;
  public
    property Items[Index: integer]: TUpLoadItem read GetItem;

    procedure SaveToIni(Ini: TDotIniFile);
    procedure LoadFromIni(Ini: TDotIniFile);

    function GetJSONObject: TJSonValue;
    procedure LoadfromJson(jArr: TJSONArray);
  end;

var
  UpLoadList: TUpLoadList;

implementation

procedure TUpLoadItem.SaveToIni(Ini: TDotIniFile; SName: string);
begin
  Ini.WriteString(SName, 'Name', Name);
  Ini.WriteString(SName, 'FileName', FileName);
  Ini.WriteString(SName, 'Adres', Adres);
  Ini.WriteInteger(SName, 'MaxSize', MaxSize);
  Ini.WriteBool(SName, 'StoreWin', StoreWin);
  Ini.WriteBool(SName, 'StoreMenu', StoreMenu);
end;

function TUpLoadItem.GetJSONObject: TJSONBuilder;
begin
  Result.init;
  Result.Add('Name', Name);
  Result.Add('FileName', FileName);
  Result.Add('Adres', Adres);
  Result.Add('MaxSize', MaxSize);
  Result.Add('StoreWin', StoreWin);
  Result.Add('StoreMenu', StoreMenu);
end;

procedure TUpLoadItem.LoadfromJson(jLoader: TJSONLoader);
begin
  jLoader.Load('Name', Name);
  jLoader.Load('FileName', FileName);
  jLoader.Load('Adres', Adres);
  jLoader.Load('MaxSize', MaxSize);
  jLoader.Load('StoreWin', StoreWin);
  jLoader.Load('StoreMenu', StoreMenu);
end;

procedure TUpLoadItem.LoadFromIni(Ini: TDotIniFile; SName: string);
begin
  Name := Ini.ReadString(SName, 'Name', Name);
  FileName := Ini.ReadString(SName, 'FileName', FileName);
  Adres := Ini.ReadString(SName, 'Adres', Adres);
  MaxSize := Ini.ReadInteger(SName, 'MaxSize', MaxSize);
  StoreWin := Ini.ReadBool(SName, 'StoreWin', StoreWin);
  StoreMenu := Ini.ReadBool(SName, 'StoreMenu', StoreMenu);
end;

function TUpLoadList.GetItem(Index: integer): TUpLoadItem;
begin
  Result := inherited Items[Index] as TUpLoadItem;
end;

function TUpLoadList.GetSName(nr: integer): string;
begin
  Result := 'UPLOAD_DEF_' + IntToStr(nr);
end;

function TUpLoadList.GetJSONObject: TJSonValue;
var
  i: integer;
begin
  Result := TJSONArray.Create;
  for i := 0 to Count - 1 do
  begin
    (Result as TJSONArray).AddElement(Items[i].GetJSONObject.jobj);
  end;
end;

procedure TUpLoadList.LoadfromJson(jArr: TJSONArray);
var
  i: integer;
  item: TUpLoadItem;
  jLoader: TJSONLoader;
begin
  for i := 0 to jArr.Count - 1 do
  begin
    jLoader.init(jArr.Items[i]);
    item := TUpLoadItem.Create;
    item.LoadfromJson(jLoader);
    Add(item);
  end;
end;

procedure TUpLoadList.SaveToIni(Ini: TDotIniFile);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[i].SaveToIni(Ini, GetSName(i));
  end;
  i := Count;
  while Ini.SectionExists(GetSName(i)) do
  begin
    Ini.EraseSection(GetSName(i));
    inc(i);
  end;
end;

procedure TUpLoadList.LoadFromIni(Ini: TDotIniFile);
var
  i: integer;
  V: TUpLoadItem;
begin
  i := 0;
  while Ini.SectionExists(GetSName(i)) do
  begin
    V := TUpLoadItem.Create;
    V.LoadFromIni(Ini, GetSName(i));
    Add(V);
    inc(i);
  end;
end;

initialization

UpLoadList := TUpLoadList.Create;

finalization

UpLoadList.Free;

end.
