unit SttScrollBoxUnit;

interface

uses
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.JSON,
  JsonUtils,

  SttObjectDefUnit,
  SttFrameBaseUnit,
  SttFrameBoolUnit,
  SttFrameIntUnit,
  SttFrameFloatUnit,
  SttFrameIpUnit,
  SttFrameSelectUnit;

type

  TSttScrollBox = class(TScrollBox)
  private
    FOnSttItemValueEdited: TOnSttItemValueEdited;

  public
    constructor Create(AOwner: TComponent); override;
    procedure RemoveItems;
    procedure LoadList(List: TSttObjectListJson; SkipArr: TStringArr); overload;
    procedure LoadList(List: TSttObjectListJson); overload;
    function AddFrame(SttClass: TSttFrameBaseClass; aItemName: string; ParamList: TSttObjectListJson) : TSttFrameBase;
    function getValueArray(obj: TJSONObject; var errTxt: string): boolean;
    procedure setValueArray(obj: TJSONObject);
    procedure SetOnValueEdited(aOnSttItemValueEdited: TOnSttItemValueEdited);
    procedure LoadDefaultValue;
    procedure setActiveFromUniBool;
    procedure setAllActive;
  end;

implementation

constructor TSttScrollBox.Create(AOwner: TComponent);
begin
  inherited;
  BevelInner := bvNone;
  BorderStyle := bsNone;
end;

procedure TSttScrollBox.RemoveItems;
begin
  while ComponentCount > 0 do
  begin
    Components[0].Free
  end;
end;

function TSttScrollBox.AddFrame(SttClass: TSttFrameBaseClass; aItemName: string; ParamList: TSttObjectListJson) : TSttFrameBase;
var
  Frame: TSttFrameBase;
begin
  Frame := SttClass.Create(self, aItemName);
  Frame.Parent := self;
  Frame.Align := alTop;
  Frame.LoadField(ParamList);
  SetOnValueEdited(FOnSttItemValueEdited);
  Frame.TabOrder := 0;

  Result := Frame;
end;

procedure TSttScrollBox.SetOnValueEdited(aOnSttItemValueEdited: TOnSttItemValueEdited);
var
  i: integer;
begin
  FOnSttItemValueEdited := aOnSttItemValueEdited;
  if Assigned(FOnSttItemValueEdited) then
  begin
    for i := 0 to ComponentCount - 1 do
      (Components[i] as TSttFrameBase).SetOnValueEdited(FOnSttItemValueEdited);
  end
  else
  begin
    for i := 0 to ComponentCount - 1 do
      (Components[i] as TSttFrameBase).SetOnValueEdited(nil);
  end;
end;

procedure TSttScrollBox.LoadList(List: TSttObjectListJson; SkipArr: TStringArr);
var
  i: integer;
  SttClass: TSttFrameBaseClass;
  item : TSttObjectJson;
begin
  RemoveItems;
  for i := List.Count - 1 downto 0 do
  begin
    item := List.Items[i];
    if FindStringInArray(Item.Name, SkipArr, -1) = -1 then
    begin
      SttClass := GetSttFrameClass(Item.SettType);
      if Assigned(SttClass) then
      begin
        AddFrame(SttClass, Item.Name, List);
      end;
    end;
  end;
end;

procedure TSttScrollBox.LoadList(List: TSttObjectListJson);
begin
  LoadList(List, []);
end;

function TSttScrollBox.getValueArray(obj: TJSONObject; var errTxt: string): boolean;
var
  i: integer;
  frame : TSttFrameBase;
begin
  Result := true;
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TSttFrameBase then
    begin
      frame := Components[i] as TSttFrameBase;
      Result := frame.getSttData(obj);
      if not(Result) then
      begin
        errTxt := 'Error data in: '+frame.Description;;
        break;
      end;
    end;
  end;
end;

procedure TSttScrollBox.setValueArray(obj: TJSONObject);
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TSttFrameBase then
    begin
      (Components[i] as TSttFrameBase).setData(obj);
    end;
  end;
end;

procedure TSttScrollBox.LoadDefaultValue;
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TSttFrameBase then
    begin
      (Components[i] as TSttFrameBase).LoadDefaultValue;
    end;
  end;
end;

procedure TSttScrollBox.setAllActive;
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TSttFrameBase then
    begin
      (Components[i] as TSttFrameBase).setActive(true);
    end;
  end;
end;

procedure TSttScrollBox.setActiveFromUniBool;
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TSttFrameBase then
    begin
      (Components[i] as TSttFrameBase).setActiveFromUniBool;
    end;
  end;
end;

end.
