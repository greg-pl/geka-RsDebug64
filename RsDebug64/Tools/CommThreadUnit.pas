unit CommThreadUnit;

interface

uses
  Classes, Windows, Messages,SysUtils,Contnrs,
  RsdDll,
  GkStrUtils,
  ProgCfgUnit,
  ToolsUnit;

type
  TSafeList = class(TObject)
  private
    CriSection : TRTLCriticalSection;
    Flist : TObjectList;
    procedure   Lock;
    procedure   Unlock;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(AObject: TObject): Integer;
    procedure Delete(index : integer); overload;
    procedure Delete(aObject : TObject); overload;
    procedure Remove(aObject : TObject);
    function getFirst : TObject;
  end;

  TCommWorkItem = class(TObject)
    OwnerHandle : THandle;
    ReturnMsg   : UINT;
    WorkTime    : cardinal;
    Result      : TStatus;
    constructor Create(H : Thandle; Msg : UINT);
  end;

  TWorkRdWrMemItem = class(TCommWorkItem)
    FBuffer  : pByte;
    FAdr     : Cardinal;
    FSize    : Cardinal;
    FAsPtr   : boolean;
    FAreaDef : TAreaDefItem;
    BufferAdr: Cardinal;       // faktyczny adres pamiêci

    constructor Create(H : Thandle; Msg : UINT; var Buf; adr,size : cardinal); overload;
    constructor Create(H : Thandle; Msg : UINT;
      AreaDef : TAreaDefItem; var Buf; ptrAdr: cardinal; size : cardinal); overload;
    constructor Create(H : Thandle; Msg : UINT;
      asPtr : boolean; AreaDef : TAreaDefItem; var Buf; UniAdr: cardinal; size : cardinal); overload;
  end;

  TWorkRdMemItem = class(TWorkRdWrMemItem)
  end;

  TWorkWrMemItem = class(TWorkRdWrMemItem)
  end;



  TCommThread = class(TThread)
  private
    FAsyncMutex : THandle;
    FDev : TCmmDevice;
    FToDoList   : TSafeList;
    function ReadPtr(OwnerH : THandle; AreaDef : TAreaDefItem; ptrAdr : cardinal; var addr : cardinal):Tstatus;
    function doReadPtrMem(rd :TWorkRdMemItem): TStatus;
    function doWritePtrMem(wr :TWorkWrMemItem): TStatus;
  protected
    procedure Execute; override;
  public
    mThreadId : THandle;
    constructor Create(aDev : TCmmDevice);
    destructor Destroy; override;
    procedure AddToDoItem(WorkItem : TCommWorkItem);
    procedure SetDev(Dev : TCmmDevice);
  end;


implementation

// -- TSafeList ---------------------------------------------------------------

constructor TSafeList.Create;
begin
  inherited;
  Flist := TObjectList.Create(False);
  InitializeCriticalSection(CriSection);
end;

destructor TSafeList.Destroy;
begin
  DeleteCriticalSection(CriSection);
  FList.Free;
  inherited;
end;

procedure TSafeList.Lock;
begin
  EnterCriticalSection(CriSection);
end;
procedure TSafeList.Unlock;
begin
  LeaveCriticalSection(CriSection);
end;

function TSafeList.Add(AObject: TObject): Integer;
begin
  Lock;
  try
    FList.Add(AObject);
  finally
    UnLock;
  end;
end;

procedure TSafeList.Delete(index : integer);
begin
  Lock;
  try
    FList.Delete(index);
  finally
    UnLock;
  end;
end;

procedure TSafeList.Delete(aObject : TObject);
var
  index : integer;
begin
  Lock;
  try
    index := FList.IndexOf(aObject);
    FList.Delete(index);
  finally
    UnLock;
  end;
end;

procedure TSafeList.Remove(aObject : TObject);
var
  index : integer;
begin
  Lock;
  try
    FList.Remove(aObject);
  finally
    UnLock;
  end;
end;


function TSafeList.getFirst : TObject;
begin
  Result := nil;
  Lock;
  try
     if Flist.Count>0 then
       Result := Flist.Items[0];
  finally
    UnLock;
  end;
end;


// -- TCommWorkItem ---------------------------------------------------------------

constructor TCommWorkItem.Create(H : Thandle; Msg : UINT);
begin
  inherited Create;
    OwnerHandle := H;
    ReturnMsg   := Msg;
end;

constructor TWorkRdWrMemItem.Create(H : Thandle; Msg : UINT; var Buf; adr,size : cardinal);
begin
  inherited Create(H,Msg);
  FBuffer := @Buf;
  FAdr := adr;
  FSize := size;
  FAsPtr := false;
  FAreaDef := nil;
end;

constructor TWorkRdWrMemItem.Create(H : Thandle; Msg : UINT;
  AreaDef : TAreaDefItem; var Buf; ptrAdr: cardinal; size : cardinal);
begin
  inherited Create(H,Msg);
  FAreaDef := AreaDef;
  FBuffer := @Buf;
  FAdr := ptrAdr;
  FSize := size;
  FAsPtr := true;
end;

constructor TWorkRdWrMemItem.Create(H : Thandle; Msg : UINT;
  asPtr : boolean; AreaDef : TAreaDefItem; var Buf; UniAdr: cardinal; size : cardinal);
begin
  inherited Create(H,Msg);
  FAreaDef := AreaDef;
  FBuffer := @Buf;
  FAdr := uniAdr;
  FSize := size;
  FAsPtr := asPtr;
end;



constructor TCommThread.Create(aDev : TCmmDevice);
begin
  inherited Create(true);
  FToDoList := TSafeList.Create;
  FDev := aDev;
  FAsyncMutex  := CreateEvent(Nil, True, False, 'FRE_EVENT');
  Resume;
end;

destructor TCommThread.Destroy;
begin
  Terminate;
  WaitFor;
  CloseHandle(FAsyncMutex);
  FToDoList.Free;
  inherited;
end;

procedure TCommThread.SetDev(Dev : TCmmDevice);
begin
  FDev := Dev;
end;


function TCommThread.ReadPtr(OwnerH : THandle; AreaDef : TAreaDefItem; ptrAdr : cardinal; var addr : cardinal):Tstatus;
var
  ptrSize : integer;
  st      : Tstatus;
  TabPtr  : array[0..3] of byte;
begin
  case AreaDef.PtrSize of
  ps8  : ptrSize:=1;
  ps16 : ptrSize:=2;
  ps32 : ptrSize:=4;
  else
    Result := stError;
  end;
  if Result=stOk then
  begin
    Result := FDev.ReadDevMem(OwnerH, TabPtr[0], ptrAdr,ptrSize);
    if Result=stOK then
    begin
      case AreaDef.PtrSize of
      ps8  : addr := TabPtr[0];
      ps16 : addr := GetWord(@TabPtr,AreaDef.ByteOrder);
      ps32 : addr := GetDWord(@TabPtr,AreaDef.ByteOrder);
      end;
      addr  := AreaDef.GetPhAdr(addr);
    end;
  end;
end;


function TCommThread.doReadPtrMem(rd :TWorkRdMemItem): TStatus;
begin
  Result := stOK;
  if rd.FAsPtr=false then
    rd.BufferAdr := rd.FAdr
  else
  begin
    Result := ReadPtr(rd.OwnerHandle, rd.FAreaDef, rd.FAdr, rd.BufferAdr);
  end;

  if Result = stOK then
    Result := FDev.ReadDevMem(rd.OwnerHandle, rd.FBuffer^, rd.BufferAdr,rd.FSize);
end;


function TCommThread.doWritePtrMem(wr :TWorkWrMemItem): TStatus;
begin
  Result := stOK;
  if wr.FAsPtr=false then
    wr.BufferAdr := wr.FAdr
  else
    Result := ReadPtr(wr.OwnerHandle, wr.FAreaDef, wr.FAdr, wr.BufferAdr);

  if Result = stOK then
    Result := FDev.WriteDevMem(wr.OwnerHandle, wr.FBuffer^, wr.BufferAdr,wr.FSize);
end;



procedure TCommThread.Execute;
var
  msg: TMsg;
  st : TStatus;
  obj : TObject;
  item : TCommWorkItem;
  rd : TWorkRdMemItem;
  wr : TWorkWrMemItem;
  TT : cardinal;
begin
  mThreadId := ThreadID;
  while not(Terminated) do
  begin
    ResetEvent(FAsyncMutex);
    if WaitForSingleObject(FAsyncMutex,100) = WAIT_OBJECT_0 then
    begin
      while true do
      begin
        obj := FToDoList.getFirst;
        if assigned(obj) then
        begin
          item := obj as TCommWorkItem;
          if FDev.Connected then
          begin
            TT := GetTickCount;
            st := stUndefCommand;
            if item is TWorkRdMemItem then
            begin
              st := doReadPtrMem(item as TWorkRdMemItem);
            end
            else if item is TWorkWrMemItem then
            begin
              st := doWritePtrMem(item as TWorkWrMemItem);
            end;
            item.WorkTime := GetTickCount-TT;
            item.Result := st;
          end
          else
          begin
            item.WorkTime := 0;
            item.Result := stNotOpen;
          end;
          FToDoList.Remove(obj);
          PostMessage(item.OwnerHandle,item.ReturnMsg,integer(item),0);
        end
        else
          break;
      end;
    end;
  end;
end;

procedure TCommThread.AddToDoItem(WorkItem : TCommWorkItem);
begin
  FToDoList.Add(WorkItem);
  SetEvent(FAsyncMutex);
end;


(*
   //Call PeekMessage to force the system to create the message queue.
   PeekMessage(msg, NULL, WM_USER, WM_USER, PM_NOREMOVE);

   //Start our message pumping loop.
   //GetMessage will return false when it receives a WM_QUIT
   while Longint(GetMessage(msg, 0, 0, 0)) > 0 do
   begin
      case msg.message of
      WM_ReadyATractorBeam: ReadyTractorBeam;
      WM_PleaseEndYourself: PostQuitMessage(0);
      end;
   end;

*)


(*
PostThreadMessage(nThreadID, WM_ReadyATractorBeam, 0, 0);

procedure TCommThread.Execute;
var
  msg: TMsg;
begin

//{$WARN SYMBOL_DEPRECATED OFF}
  FLibHandle := AllocateHWnd(WndProc);
//{$WARN SYMBOL_DEPRECATED ON}
  while not(terminated) do
  begin
    WaitMessage;
    while PeekMessage(msg, 0, 0, 0, PM_REMOVE) do
    begin
      DispatchMessage(msg)
    end;
  end;

{$WARN SYMBOL_DEPRECATED OFF}
  DeallocateHWnd(FLibHandle);
{$WARN SYMBOL_DEPRECATED ON}
end;



      // No point in calling Translate/Dispatch if there's no window associated.
      // Dispatch will just throw the message away
//    else
//       TranslateMessage(Msg);
//       DispatchMessage(Msg);
//    end;
   end;

}
//  PeekMessage
//  GetMessage

*)


end.
