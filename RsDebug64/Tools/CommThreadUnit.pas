unit CommThreadUnit;

interface

uses
  Classes, Windows, Messages, SysUtils, Contnrs,
  RsdDll,
  GkStrUtils,
  ProgCfgUnit,
  Rsd64Definitions,
  ToolsUnit;

type
  TSafeList = class(TObject)
  private
    CriSection: TRTLCriticalSection;
    Flist: TObjectList;
    procedure Lock;
    procedure Unlock;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(AObject: TObject): Integer;
    procedure Delete(index: Integer); overload;
    procedure Delete(AObject: TObject); overload;
    procedure Remove(AObject: TObject);
    function getFirst: TObject;
  end;

  TCommWorkItem = class(TObject)
    OwnerHandle: THandle;
    ReturnMsg: UINT;
    WorkTime: cardinal;
    Result: TStatus;
    constructor Create(H: THandle; Msg: UINT);
  end;

  TWorkRdWrMemItem = class(TCommWorkItem)
    FBuffer: pByte;
    FAdr: cardinal;
    FSize: cardinal;
    FAsPtr: boolean;
    BufferAdr: cardinal; // faktyczny adres pamiêci
    Tmp: Integer;

    constructor Create(H: THandle; Msg: UINT; var Buf; adr, size: cardinal); overload;
    constructor Create(H: THandle; Msg: UINT; asPtr: boolean; var Buf; UniAdr: cardinal; size: cardinal); overload;

  end;

  TWorkRdMemItem = class(TWorkRdWrMemItem)
  end;

  TWorkWrMemItem = class(TWorkRdWrMemItem)
  end;

  // ---------------------------------
  TWorkWrMdbRegItem = class(TCommWorkItem)
    FVal: word;
    FAdr: word;
    constructor Create(H: THandle; Msg: UINT; adr, val: word);
  end;

  TWorkRdWrMdbRegItem = class(TCommWorkItem)
    FRdBuffer: pByte;
    FRdAdr: word;
    FRdCnt: word;
    FWrBuffer: pByte;
    FWrAdr: word;
    FWrCnt: word;
    constructor Create(H: THandle; Msg: UINT; var RdBuf; RdAdr, RdCnt: word; var WrBuf; WrAdr, WrCnt: word);
  end;

  TWorkModbusMultiItem = class(TCommWorkItem)
    FBuffer: pByte;
    FAdr: word;
    FSize: word;
    constructor Create(H: THandle; Msg: UINT; var Buf; adr, size: word);
  end;

  TWorkRdMdbRegItem = class(TWorkModbusMultiItem)
  end;

  TWorkWrMultiMdbRegItem = class(TWorkModbusMultiItem)
  end;

  TWorkRdMdbAnalogInputItem = class(TWorkModbusMultiItem)
  end;

  TWorkModbusMultiBoolItem = class(TCommWorkItem)
    FBuffer: pBool;
    FAdr: word;
    FSize: word;
    constructor Create(H: THandle; Msg: UINT; var Buf; adr, size: word);
  end;


  TWorkRdMdbInputTableItem = class(TWorkModbusMultiBoolItem)

  end;

  TWorkRdMdbOutputTableItem = class(TWorkModbusMultiBoolItem)

  end;

  TWorkWrMultiMdbOutputTableItem = class(TWorkModbusMultiBoolItem)

  end;

  TWorkWrMdbOutputTableItem = class(TCommWorkItem)
    FAdr: word;
    FVal: boolean;
    constructor Create(H: THandle; Msg: UINT; adr: word; val: boolean);
  end;

  TCommThread = class(TThread)
  private
    FAsyncMutex: THandle;
    FThDev: TCmmDevice;
    FToDoList: TSafeList;
    function ReadPtr(OwnerH: THandle; ptrAdr: cardinal; var addr: cardinal): TStatus;
    function doReadPtrMem(rd: TWorkRdMemItem): TStatus;
    function doWritePtrMem(wr: TWorkWrMemItem): TStatus;
    function doRdMdbReg(rd: TWorkRdMdbRegItem): TStatus;
    function doWrMdbReg(wr: TWorkWrMdbRegItem): TStatus;
    function doRdWrMdbReg(wr: TWorkRdWrMdbRegItem): TStatus;

    function doRdMdbInputTab(rd: TWorkRdMdbInputTableItem): TStatus;
    function doRdMdbOutputTab(rd: TWorkRdMdbOutputTableItem): TStatus;
    function doWrMdbOutputTab(wr: TWorkWrMdbOutputTableItem): TStatus;

    function doWrMultiMdbReg(wr: TWorkWrMultiMdbRegItem): TStatus;
    function doRdMdbAnalogReg(rd: TWorkRdMdbAnalogInputItem): TStatus;

  protected
    procedure Execute; override;
  public
    mThreadId: THandle;
    constructor Create;
    destructor Destroy; override;
    procedure AddToDoItem(WorkItem: TCommWorkItem);
    procedure SetDev(Dev: TCmmDevice);
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
  Flist.Free;
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
    Flist.Add(AObject);
  finally
    Unlock;
  end;
end;

procedure TSafeList.Delete(index: Integer);
begin
  Lock;
  try
    Flist.Delete(index);
  finally
    Unlock;
  end;
end;

procedure TSafeList.Delete(AObject: TObject);
var
  index: Integer;
begin
  Lock;
  try
    index := Flist.IndexOf(AObject);
    Flist.Delete(index);
  finally
    Unlock;
  end;
end;

procedure TSafeList.Remove(AObject: TObject);
var
  index: Integer;
begin
  Lock;
  try
    Flist.Remove(AObject);
  finally
    Unlock;
  end;
end;

function TSafeList.getFirst: TObject;
begin
  Result := nil;
  Lock;
  try
    if Flist.Count > 0 then
      Result := Flist.Items[0];
  finally
    Unlock;
  end;
end;


// -- TCommWorkItem ---------------------------------------------------------------

constructor TCommWorkItem.Create(H: THandle; Msg: UINT);
begin
  inherited Create;
  OwnerHandle := H;
  ReturnMsg := Msg;
end;

constructor TWorkRdWrMemItem.Create(H: THandle; Msg: UINT; var Buf; adr, size: cardinal);
begin
  inherited Create(H, Msg);
  FBuffer := @Buf;
  FAdr := adr;
  FSize := size;
  FAsPtr := False;
  Tmp := 0;
end;

constructor TWorkRdWrMemItem.Create(H: THandle; Msg: UINT; asPtr: boolean; var Buf; UniAdr: cardinal; size: cardinal);
begin
  inherited Create(H, Msg);
  FBuffer := @Buf;
  FAdr := UniAdr;
  FSize := size;
  FAsPtr := asPtr;
  Tmp := 0;
end;

constructor TWorkWrMdbRegItem.Create(H: THandle; Msg: UINT; adr, val: word);
begin
  inherited Create(H, Msg);
  FVal := val;
  FAdr := adr;
end;

constructor TWorkRdWrMdbRegItem.Create(H: THandle; Msg: UINT; var RdBuf; RdAdr, RdCnt: word; var WrBuf;
  WrAdr, WrCnt: word);
begin
  inherited Create(H, Msg);
  FRdBuffer := @RdBuf;
  FRdAdr := RdAdr;
  FRdCnt := RdCnt;
  FWrBuffer := @WrBuf;
  FWrAdr := WrAdr;
  FWrCnt := WrCnt;
end;

constructor TWorkModbusMultiItem.Create(H: THandle; Msg: UINT; var Buf; adr, size: word);
begin
  inherited Create(H, Msg);
  FBuffer := @Buf;
  FAdr := adr;
  FSize := size;
end;

constructor TWorkModbusMultiBoolItem.Create(H: THandle; Msg: UINT; var Buf; adr, size: word);
begin
  inherited Create(H, Msg);
  FBuffer := @Buf;
  FAdr := adr;
  FSize := size;
end;

constructor TWorkWrMdbOutputTableItem.Create(H: THandle; Msg: UINT; adr: word; val: boolean);
begin
  inherited Create(H, Msg);
  FAdr := adr;
  FVal := val;
end;

// ------------------------------------------------------------------------------------
constructor TCommThread.Create;
begin
  inherited Create(true);
  NameThreadForDebugging('TCommThread');
  FToDoList := TSafeList.Create;
  FThDev := nil;
  FAsyncMutex := CreateEvent(Nil, true, False, 'FRE_EVENT');
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

procedure TCommThread.SetDev(Dev: TCmmDevice);
begin
  FThDev := Dev;
end;

function TCommThread.ReadPtr(OwnerH: THandle; ptrAdr: cardinal; var addr: cardinal): TStatus;
var
  ptrSize: Integer;
  st: TStatus;
  TabPtr: array [0 .. 3] of byte;
begin
  if Assigned(FThDev) then
  begin
    case ProgCfg.ptrSize of
      ps8:
        ptrSize := 1;
      ps16:
        ptrSize := 2;
      ps32:
        ptrSize := 4;
    else
      Result := stError;
    end;
    if Result = stOk then
    begin
      Result := FThDev.ReadDevMem(OwnerH, TabPtr[0], ptrAdr, ptrSize);
      if Result = stOk then
      begin
        case ProgCfg.ptrSize of
          ps8:
            addr := TabPtr[0];
          ps16:
            addr := GetWord(@TabPtr, ProgCfg.ByteOrder);
          ps32:
            addr := GetDWord(@TabPtr, ProgCfg.ByteOrder);
        end;
      end;
    end;
  end
  else
    Result := stNotOpen;
end;

function TCommThread.doReadPtrMem(rd: TWorkRdMemItem): TStatus;
begin
  if Assigned(FThDev) then
  begin
    Result := stOk;
    if rd.FAsPtr = False then
      rd.BufferAdr := rd.FAdr
    else
    begin
      Result := ReadPtr(rd.OwnerHandle, rd.FAdr, rd.BufferAdr);
    end;

    if Result = stOk then
      Result := FThDev.ReadDevMem(rd.OwnerHandle, rd.FBuffer^, rd.BufferAdr, rd.FSize);
  end
  else
    Result := stNotOpen;
end;

function TCommThread.doWritePtrMem(wr: TWorkWrMemItem): TStatus;
begin
  if Assigned(FThDev) then
  begin
    Result := stOk;
    if wr.FAsPtr = False then
      wr.BufferAdr := wr.FAdr
    else
      Result := ReadPtr(wr.OwnerHandle, wr.FAdr, wr.BufferAdr);

    if Result = stOk then
      Result := FThDev.WriteDevMem(wr.OwnerHandle, wr.FBuffer^, wr.BufferAdr, wr.FSize);
  end
  else
    Result := stNotOpen;
end;

function TCommThread.doRdMdbReg(rd: TWorkRdMdbRegItem): TStatus;
begin
  Result := FThDev.RdReg(rd.OwnerHandle, rd.FBuffer^, rd.FAdr, rd.FSize);
end;

function TCommThread.doWrMdbReg(wr: TWorkWrMdbRegItem): TStatus;
begin
  Result := FThDev.WrReg(wr.OwnerHandle, wr.FAdr, wr.FVal);
end;

function TCommThread.doRdWrMdbReg(wr: TWorkRdWrMdbRegItem): TStatus;
begin
  Result := FThDev.ReadWriteRegs(wr.OwnerHandle, wr.FRdBuffer^, wr.FRdAdr, wr.FRdCnt, wr.FWrBuffer^, wr.FWrAdr,
    wr.FWrCnt);
end;

function TCommThread.doWrMultiMdbReg(wr: TWorkWrMultiMdbRegItem): TStatus;
begin
  Result := FThDev.WrMultiReg(wr.OwnerHandle, wr.FBuffer^, wr.FAdr, wr.FSize);
end;

function TCommThread.doRdMdbAnalogReg(rd: TWorkRdMdbAnalogInputItem): TStatus;
begin
  Result := FThDev.RdAnalogInp(rd.OwnerHandle, rd.FBuffer^, rd.FAdr, rd.FSize);
end;

function TCommThread.doRdMdbInputTab(rd: TWorkRdMdbInputTableItem): TStatus;
begin
  Result := FThDev.RdInpTable(rd.OwnerHandle, rd.FBuffer^, rd.FAdr, rd.FSize);
end;

function TCommThread.doRdMdbOutputTab(rd: TWorkRdMdbOutputTableItem): TStatus;
begin
  Result := FThDev.RdOutTable(rd.OwnerHandle, rd.FBuffer^, rd.FAdr, rd.FSize);
end;

function TCommThread.doWrMdbOutputTab(wr: TWorkWrMdbOutputTableItem): TStatus;
begin
  Result := FThDev.WrOutput(wr.OwnerHandle, wr.FAdr, wr.FVal);
end;

procedure TCommThread.Execute;
var
  Msg: TMsg;
  st: TStatus;
  obj: TObject;
  item: TCommWorkItem;
  rd: TWorkRdMemItem;
  wr: TWorkWrMemItem;
  TT: cardinal;
begin
  mThreadId := ThreadID;
  while not(Terminated) do
  begin
    ResetEvent(FAsyncMutex);
    if WaitForSingleObject(FAsyncMutex, 100) = WAIT_OBJECT_0 then
    begin
      while true do
      begin
        obj := FToDoList.getFirst;
        if Assigned(obj) then
        begin
          item := obj as TCommWorkItem;
          if Assigned(FThDev) then
          begin
            if FThDev.Connected then
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
              end
              else if item is TWorkRdMdbRegItem then
              begin
                st := doRdMdbReg(item as TWorkRdMdbRegItem);
              end
              else if item is TWorkWrMdbRegItem then
              begin
                st := doWrMdbReg(item as TWorkWrMdbRegItem);
              end
              else if item is TWorkWrMultiMdbRegItem then
              begin
                st := doWrMultiMdbReg(item as TWorkWrMultiMdbRegItem);
              end
              else if item is TWorkRdMdbAnalogInputItem then
              begin
                st := doRdMdbAnalogReg(item as TWorkRdMdbAnalogInputItem);
              end

              else if item is TWorkRdMdbInputTableItem then
              begin
                st := doRdMdbInputTab(item as TWorkRdMdbInputTableItem);
              end
              else if item is TWorkRdMdbOutputTableItem then
              begin
                st := doRdMdbOutputTab(item as TWorkRdMdbOutputTableItem);
              end
              else if item is TWorkWrMdbOutputTableItem then
              begin
                st := doWrMdbOutputTab(item as TWorkWrMdbOutputTableItem);
              end;



              item.WorkTime := GetTickCount - TT;
              item.Result := st;
            end
            else
            begin
              item.WorkTime := 0;
              item.Result := stNotOpen;
            end;
          end
          else
          begin
            item.WorkTime := 0;
            item.Result := stNotOpen;
          end;
          FToDoList.Remove(obj);
          PostMessage(item.OwnerHandle, item.ReturnMsg, Integer(item), 0);
        end
        else
          break;
      end;
    end;
  end;
end;

procedure TCommThread.AddToDoItem(WorkItem: TCommWorkItem);
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
