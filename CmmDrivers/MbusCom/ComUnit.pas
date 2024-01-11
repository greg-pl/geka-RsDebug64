unit ComUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Math,
  System.AnsiStrings,
  System.Contnrs;

type

  TComItem = class(TObject)
    ComNr: integer;
    SemHandle: THandle;
    ComHandle: THandle;
    destructor Destroy; override;
  end;

  TComList = class(TObjectList)
  private
    FCriSection: TRTLCriticalSection;
    function find(ComNr: integer): TComItem;
  public
    constructor Create;
    destructor Destroy; override;
    function GetComAccessHandle(ComNr: integer; var ComHandle: THandle; var SemHandle: THandle): boolean;
    procedure RemoveCom(ComNr: integer);
  end;

var
  GlobComList: TComList;

implementation

// -----------------------------------------------------------------------------
// ComList
// -----------------------------------------------------------------------------
destructor TComItem.Destroy;
begin
  inherited;
  CloseHandle(SemHandle);
  CloseHandle(ComHandle);
end;

constructor TComList.Create;
begin
  inherited Create;
  InitializeCriticalSection(FCriSection);
end;

destructor TComList.Destroy;
begin
  DeleteCriticalSection(FCriSection);
  inherited;
end;

function TComList.GetComAccessHandle(ComNr: integer; var ComHandle: THandle; var SemHandle: THandle): boolean;
var
  i: integer;
  it: TComItem;
  s: string;
begin
  try
    EnterCriticalSection(FCriSection);
    it := find(ComNr);
    if not(Assigned(it)) then
    begin
      it := TComItem.Create;
      it.ComNr := ComNr;
      s := '\\.\COM' + IntToStr(ComNr);
      it.ComHandle := CreateFile(pchar(s), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING,
        FILE_FLAG_OVERLAPPED, 0);
      if it.ComHandle <> INVALID_HANDLE_VALUE then
      begin
        it.SemHandle := createsemaphore(nil, 1, 1, nil);
        Add(it);
        ComHandle := it.ComHandle;
        SemHandle := it.SemHandle;
        Result := true;
      end
      else
      begin
        it.Free;
        ComHandle := INVALID_HANDLE_VALUE;
        SemHandle := INVALID_HANDLE_VALUE;
        Result := false;
      end;
    end;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

function TComList.find(ComNr: integer): TComItem;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if (Items[i] as TComItem).ComNr = ComNr then
    begin
      Result := Items[i] as TComItem;
      break;
    end;
  end;
end;

procedure TComList.RemoveCom(ComNr: integer);
var
  item: TComItem;
begin
  try
    EnterCriticalSection(FCriSection);
    item := find(ComNr);
    if Assigned(item) then
    begin
      Delete(IndexOf(item));
    end;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

initialization

GlobComList := TComList.Create;

finalization

GlobComList.Free;

end.
