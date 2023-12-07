unit GlobalMan;

interface

uses
  Windows,SysUtils;
//  Classes;

const
  MAX_COMM_NOTIFY   = 100;  // tylko 100 comów

  stOk              = 0;
  stAttSemError     = 1;
  stMaxAttachCom    = 2;
  stSemafErr        = 3;
  stCommErr         = 4;
  stDelphiError     = 5;

  // statusy zwracane przez urz¹dzenie 
  stEND_OFF_DIR     = -25;


type
  TCommVar = record
    CommNr         : integer;
    OwnerID        : Cardinal;   // ID procesu rezerwuj¹cego dostêp do portu COM
    ComHandle      : THandle;    // Handle dostêpu do portu COM. Wartoœc inna dla ka¿dego
                                 // procesu korzystaj¹cego z danego portu
    ComSemHandle   : THandle;    // Handle Semaphora blokuj¹cego dostêp do portu
                                 // inne dla kazdego procesu
  end;

  PGlobalData = ^TGlobalData;
  TGlobalData = record
    DllGuid         : TGUID;
    ComTab          : array[0..MAX_COMM_NOTIFY-1] of TCommVar;
  end;


function  OpenSharedData: boolean;
procedure CloseSharedData;
function  GetCommHandle(AComNr : integer; var ComH : THandle; var SemH: THandle): integer;
procedure CloseCommHandle(AComNr : integer);
function  GetGlobPtr : Pointer; stdcall;

Exports
  GetGlobPtr;

implementation

const
  MMFileName = '__MapSharedMbusData__';
  AttachSemName = '__AttachMbusSemDll__';
  DDL_GUID : TGUID ='{8C452FDC-2C4D-4F86-BE6B-E3961DB3D9A4}';

var
  MapHandle   : THandle;
  GlobalData  : PGlobalData;
  ErrStr      : ShortString;
  AttachSem   : THandle;

function  GetGlobPtr : Pointer; stdcall;
begin
  Result := Globaldata;
end;

function GetSystemErrText(Code : integer):string;
var
  n: integer;
begin
  SetLength(Result,200);
  n:=FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil,GetLastError(),
                   0,pchar(Result),length(Result),nil);
  while(Result[n]=#13) or (Result[n]=#10) do dec(n);
  SetLength(Result,n);
end;


function GetCommHandle(AComNr : integer; var ComH : THandle; var SemH: THandle): integer;
var
  FndPos   : integer;
  FreePos  : integer;
  i        : integer;
  OwnerAppHandle  : THandle;
  ID              : Cardinal;
  s               : string;
begin
  ID   := GetCurrentProcessId;
  SemH := INVALID_HANDLE_VALUE;
  ComH := INVALID_HANDLE_VALUE;
  Result := stOk;

  if WaitForSingleObject(AttachSem,2000)=WAIT_OBJECT_0	then
  begin
    // jesli otwarty Com dla tego procesu
    for i:=0 to MAX_COMM_NOTIFY-1 do
    begin
      if (GlobalData.ComTab[i].CommNr=AComNr) and  (GlobalData.ComTab[i].OwnerID=ID) then
      begin
        ComH := GlobalData.ComTab[i].ComHandle;
        SemH := GlobalData.ComTab[i].ComSemHandle;
        Result := stOk;
      end;
    end;

    if ComH=INVALID_HANDLE_VALUE then
    begin
      // odszukanie wolnej pozycji w tabeli GlobalData
      FreePos:=-1;
      for i:=0 to MAX_COMM_NOTIFY-1 do
      begin
        if GlobalData.ComTab[i].CommNr=0 then
        begin
          FreePos:=i;
          GlobalData.ComTab[FreePos].CommNr:=AComNr;
          Break;
        end;
      end;
      if FreePos>=0 then
      begin
        // odszukanie pozycji , na której jest ju¿ u¿ywany ten COM
        FndPos := -1;
        for i:=0 to MAX_COMM_NOTIFY-1 do
        begin
          if (i<>FreePos) and (GlobalData.ComTab[i].CommNr=AComnr) then
          begin
            FndPos := i;
            break;
          end;
        end;
        if FndPos = -1 then
        begin
          // Otwarcie Com'a i Semapora jako pierwszy
          SemH := createsemaphore(nil,1,1,nil);
          s:='\\.\COM'+IntToStr(AComNr);
          ComH :=CreateFile(pchar(s),GENERIC_READ or GENERIC_WRITE,
                             0,nil,OPEN_EXISTING,FILE_FLAG_OVERLAPPED,0);
        end
        else
        begin
          // pod³aczenie siê do otwartego portu
          OwnerAppHandle := OpenProcess(PROCESS_ALL_ACCESS,False,GlobalData.ComTab[FndPos].OwnerID);
          DuplicateHandle(OwnerAppHandle,
                          GlobalData.ComTab[FndPos].ComHandle,
                          GetCurrentProcess,@ComH,0,true,DUPLICATE_SAME_ACCESS);
          DuplicateHandle(OwnerAppHandle,
                          GlobalData.ComTab[FndPos].ComSemHandle,
                          GetCurrentProcess,@SemH,0,true,DUPLICATE_SAME_ACCESS);
          CloseHandle(OwnerAppHandle);
        end;

        if (ComH <>INVALID_HANDLE_VALUE) and (SemH<>INVALID_HANDLE_VALUE) then
        begin
          GlobalData.ComTab[FreePos].OwnerID := ID;
          GlobalData.ComTab[FreePos].ComHandle := ComH;
          GlobalData.ComTab[FreePos].ComSemHandle := SemH;
          Result := stOk;
        end
        else
        begin
          GlobalData.ComTab[FreePos].CommNr:=0;
          if SemH<>INVALID_HANDLE_VALUE then
            CloseHandle(semH)
          else
            Result := stSemafErr;
          if ComH<>INVALID_HANDLE_VALUE then
            CloseHandle(ComH)
          else
            Result := stCommErr;
        end;
      end
      else
        Result := stMaxAttachCom;
    end;
    ReleaseSemaphore(AttachSem,1,nil);
  end
  else
    Result := stAttSemError;
end;

procedure CloseCommHandle(AComNr : integer);
var
  i        : integer;
  ID       : cardinal;
begin
  ID := GetCurrentProcessId;
  if WaitForSingleObject(AttachSem,2000)=WAIT_OBJECT_0	then
  begin
    for i:=0 to MAX_COMM_NOTIFY-1 do
    begin
      if (GlobalData.ComTab[i].CommNr=AComNr) and (GlobalData.ComTab[i].OwnerId=ID) then
      begin
        GlobalData.ComTab[i].CommNr :=0;
        GlobalData.ComTab[i].OwnerId :=0;
        CloseHandle(GlobalData.ComTab[i].ComHandle);
        CloseHandle(GlobalData.ComTab[i].ComSemHandle);
        GlobalData.ComTab[i].ComHandle    := INVALID_HANDLE_VALUE;
        GlobalData.ComTab[i].ComSemHandle := INVALID_HANDLE_VALUE;
      end;
    end;
    ReleaseSemaphore(AttachSem,1,nil);
  end;
end;


procedure DoneGlobalData;
var
  i   : integer;
  ID  : Cardinal;
begin
  ID   := GetCurrentProcessId;
  if WaitForSingleObject(AttachSem,2000)=WAIT_OBJECT_0	then
  begin
    for i:=0 to MAX_COMM_NOTIFY-1 do
    begin
      if GlobalData.ComTab[i].OwnerID = ID then
      begin
        if GlobalData.ComTab[i].ComHandle <> INVALID_HANDLE_VALUE then
          CloseHandle(GlobalData.ComTab[i].ComHandle);
        if GlobalData.ComTab[i].ComSemHandle <> INVALID_HANDLE_VALUE then
          CloseHandle(GlobalData.ComTab[i].ComSemHandle);
        GlobalData.ComTab[i].ComHandle:=INVALID_HANDLE_VALUE;
        GlobalData.ComTab[i].ComSemHandle:=INVALID_HANDLE_VALUE;
        GlobalData.ComTab[i].OwnerID := 0;
        GlobalData.ComTab[i].CommNr:=0;
      end;
    end;
    ReleaseSemaphore(AttachSem,1,nil);
  end;
  CloseHandle(AttachSem);
end;

procedure InitGlobalData(FirstAttach : boolean);
var
  i   : integer;
begin
  if FirstAttach then
  begin
    for i:=0 to MAX_COMM_NOTIFY-1 do
    begin
      GlobalData.ComTab[i].CommNr:=0;
      GlobalData.ComTab[i].OwnerID := 0;
      GlobalData.ComTab[i].ComHandle := INVALID_HANDLE_VALUE;
      GlobalData.ComTab[i].ComSemHandle := INVALID_HANDLE_VALUE;
    end;
    AttachSem  := CreateSemaphore(nil,1,1,AttachSemName);
  end
  else
  begin
    AttachSem  := OpenSemaphore(EVENT_ALL_ACCESS,false,AttachSemName);
  end;
end;

function CompareGuid(G1,G2 :TGUID): boolean;
begin
  Result := (Int64(G1.D1) = Int64(G2.D1)) and
            (Int64(G1.D4) = Int64(G2.D4));
end;

function  OpenSharedData: boolean;
var
  Size : integer;
  p    : boolean;
begin
  Result := True;
  Size := sizeof(TGlobalData);
  MapHandle := CreateFileMapping($ffffffff,nil,PAGE_READWRITE,0,Size,MMFileName);
  if MapHandle=0 then
  begin
    Result := False;
    ErrStr := 'Niemo¿liwe utworzenie obiektu odwzorowania,b³¹d: '+IntToStr(GetLastError);
  end;
  GlobalData := MapViewOfFile(MapHandle,FILE_MAP_ALL_ACCESS,0,0,Size);
  if GlobalData=nil then
  begin
    CloseHandle(MapHandle);
    Result := False;
    ErrStr := 'B³¹d odwzorowania pliku: '+IntToStr(GetLastError);
  end;
  p := not(CompareGuid(GlobalData.DllGuid,DDL_GUID));
  if p then
  begin
    GlobalData.DllGuid:=DDL_GUID;
  end;
  InitGlobalData(p);
end;

procedure CloseSharedData;
begin
  DoneGlobalData;
  UnMapViewOfFile(GlobalData);
  CloseHandle(MapHandle);
end;

initialization
  OpenSharedData;
finalization
  CloseSharedData;
end.
