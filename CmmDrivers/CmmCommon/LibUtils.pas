unit LibUtils;

interface

uses
  System.SysUtils, Winapi.Windows,
  Rsd64Definitions;

var
  WideChar_LoggerHandle: THandle;
  AnsiChar_LoggerHandle: THandle;

  GlobGetMemFunc: TGetMemFunction;
  GlobLibID: integer;
  GlobLogLevel: integer;

function GetUserMem(MemSize: integer): PAnsiChar;
procedure Logger(LogLevel: integer; Txt: string);
function DSwap(w: cardinal): cardinal;

implementation

function GetUserMem(MemSize: integer): PAnsiChar;
begin
  if Assigned(GlobGetMemFunc) then
    Result := PAnsiChar(GlobGetMemFunc(GlobLibID, MemSize))
  else
    Result := nil;
end;

procedure Logger(LogLevel: integer; Txt: string);
var
  BytesWritten: cardinal;
begin
  if (LogLevel < GlobLogLevel) and (WideChar_LoggerHandle <> INVALID_HANDLE_VALUE) then
  begin
    WriteFile(WideChar_LoggerHandle, Txt[1], length(Txt) * sizeof(char), BytesWritten, nil);
  end;
end;

function DSwap(w: cardinal): cardinal;
begin
  Result := ((w and $000000FF) shl 24) or ((w and $0000FF00) shl 8) or ((w and $00FF0000) shr 8) or
    ((w and $FF000000) shr 24);
end;

initialization

IsMultiThread := True; // Make memory manager thread safe
WideChar_LoggerHandle := INVALID_HANDLE_VALUE;
AnsiChar_LoggerHandle := INVALID_HANDLE_VALUE;

GlobGetMemFunc := nil;
GlobLibID := -1;

GlobLogLevel := 5;

end.
