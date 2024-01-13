unit SttFrameStrUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  JsonUtils,
  System.JSON,
  SttFrameBaseUnit,
  SttObjectDefUnit;

type
  TSttFrameStr = class(TSttFrameBase)
    SttStrEdit: TLabeledEdit;
    procedure SttStrEditKeyPress(Sender: TObject; var Key: Char);
    procedure SttStrEditExit(Sender: TObject);
  private
    defVal: string;
  public
    procedure LoadField(ParamList: TSttObjectListJson); override;
    function getSttData(obj: TJSONObject): boolean; override;
    procedure setData(obj: TJSONObject); override;
    procedure LoadDefaultValue; override;
  end;

implementation

{$R *.dfm}

procedure TSttFrameStr.LoadField(ParamList: TSttObjectListJson);
var
  stt : TSttStringObjectJson;
begin
  inherited;
  stt := InitStrEditItem(SttStrEdit, ParamList, FItemName);
  defVal := stt.defVal;
end;

function TSttFrameStr.getSttData(obj: TJSONObject): boolean;
begin
  obj.AddPair(TJSONPair.Create(FItemName, TJSONStringEx.Create(SttStrEdit.Text)));
  Result := true;
end;

procedure TSttFrameStr.setData(obj: TJSONObject);
begin
  LoadValIPEditJSon(obj, FItemName, SttStrEdit);
end;

procedure TSttFrameStr.LoadDefaultValue;
begin
  SttStrEdit.Text := defVal;
end;

procedure TSttFrameStr.SttStrEditExit(Sender: TObject);
begin
  inherited;
  if Assigned(FOnValueEdited) then
    FOnValueEdited(self, ItemName, SttStrEdit.Text);
end;

procedure TSttFrameStr.SttStrEditKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #10 then
  begin
    Key := #0;
    SttStrEditExit(Sender);
  end;

end;

initialization

RegisterSttFrame(sttSTRING, TSttFrameStr);

end.
