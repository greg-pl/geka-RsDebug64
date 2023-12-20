unit SttScrollBoxUnit;

interface

uses
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.JSON,

  SttObjectDefUnit,
  SttFrameBaseUnit,
  SttFrameBoolUnit,
  SttFrameIntUnit,
  SttFrameFloatUnit,
  SttFrameIpUnit,
  SttFrameSelectUnit;

type
  TSttScrollBox = class(TScrollBox)
    procedure RemoveItems;
    procedure LoadList(List: TSttObjectListJson; RmArr: TStringArr);
    procedure AddFrame(SttClass: TSttFrameBaseClass; SttName: string; List: TSttObjectListJson);
    procedure getValueArray(arr: TJSONObject);
    procedure setValueArray(arr: TJSONObject);
  end;

implementation

procedure TSttScrollBox.RemoveItems;
begin
  while ComponentCount > 0 do
  begin
    Components[0].Free
  end;
end;

procedure TSttScrollBox.AddFrame(SttClass: TSttFrameBaseClass; SttName: string; List: TSttObjectListJson);
var
  Frame: TSttFrameBase;
begin
  Frame := SttClass.Create(self, SttName);
  Frame.Parent := self;
  Frame.Align := alTop;
  Frame.LoadField(List);
end;

procedure TSttScrollBox.LoadList(List: TSttObjectListJson; RmArr: TStringArr);
var
  i: integer;
  SttClass: TSttFrameBaseClass;
begin
  RemoveItems;
  for i := List.Count - 1 downto 0 do
  begin
    if FindStringInArray(List.Items[i].Name, RmArr, -1) = -1 then
    begin
      SttClass := GetSttFrameClass(List.Items[i].SettType);
      if Assigned(SttClass) then
      begin
        AddFrame(SttClass, List.Items[i].Name, List);
      end;
    end;

  end;

end;

procedure TSttScrollBox.getValueArray(arr: TJSONObject);
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TSttFrameBase then
    begin
      (Components[i] as TSttFrameBase).getData(arr);
    end;
  end;
end;

procedure TSttScrollBox.setValueArray(arr: TJSONObject);
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TSttFrameBase then
    begin
      (Components[i] as TSttFrameBase).setData(arr);
    end;
  end;
end;

end.
