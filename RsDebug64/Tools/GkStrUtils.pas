unit GkStrUtils;

interface

uses
  SysUtils;


function  GetTocken(var wsk:pchar; var KodStr :string; var ValStr:string):boolean;
procedure GetTockenOne(Inp : string; var KodStr :string; var ValStr:string);

function  GetSubTocken(var wsk:pchar; var Tocken :string):boolean;
function  GetSubTockens(Inp : string; var sub1 :string; var sub2:string):boolean; overload;
function  GetSubTockens(Inp : string; var sub1 :string; var sub2:string; var sub3:string):boolean; overload;
function  GetSubTockens(Inp : string; var sub1 :string; var sub2:string;
          var sub3:string; var sub4:string):boolean; overload;
function  GetSubTockens(Inp : string; var sub1 :string; var sub2:string;
          var sub3:string; var sub4:string; var sub5:string):boolean; overload;
function  GetSubTockens(Inp : string; var sub1 :string; var sub2:string;
          var sub3:string; var sub4:string; var sub5:string;
          var sub6:string; var sub7:string):boolean; overload;
function  GkStrToDateTime(var DtTm : TDateTime; TmStr: string) : boolean;
function  GkDateTimeToStr(DtTm : TDateTime):string;
function  BoolStr(p: boolean):string;


implementation


const
  DATE_TIME_FORMAT = 'yyyy.mm.dd hh:nn:ss.zzz';

procedure CopyAndTrim(StrWsk: pchar; var OutStr : string; Len : integer);
var
  EndWsk : pchar;
begin
  while (StrWsk^=' ') and (Len>0) do
  begin
    inc(StrWsk);
    dec(Len);
  end;

  EndWsk:= StrWsk;
  inc(EndWsk,Len-1);
  while (EndWsk^=' ') and (Len>0) do
  begin
    dec(EndWsk);
    dec(Len);
  end;

  if (Len>=2) and (StrWsk^='"') and (EndWsk^='"') then
  begin
    inc(StrWsk);
    dec(Len,2);
  end;

  if Len>0 then
  begin
    SetLength(OutStr,Len);
    move(StrWsk^,OutStr[1],Len);
  end
  else
    OutStr:='';
end;


function  GetTocken(var wsk:pchar; var KodStr :string; var ValStr:string):boolean;
var
  StrWsk        : pChar;
  a             : char;
  EquWsk        : pchar;
  L             : integer;
  quote         : boolean;
  DoEnd         : boolean;
begin
  StrWsk := wsk;
  EquWsk := nil;
  quote  := false;
  DoEnd  := false;
  repeat
    a:= Wsk^;
    inc(Wsk);
    if not(quote) then
    begin
      if a='=' then EquWsk:=wsk;
      if a='"' then quote:=true;
      if a=';' then DoEnd:=true;
    end
    else
    begin
      if a='"' then quote:=false;
    end;
  until (a=#0) or DoEnd;
  Result := (a<>#0);
  if EquWsk=nil then  EquWsk:=Wsk;

  // KodStr
  L :=Cardinal(EquWsk)-Cardinal(StrWsk)-1;
  CopyAndTrim(StrWsk,KodStr,L);

  // ValStr
  L :=Integer(Wsk)-Integer(EquWsk)-1;
  CopyAndTrim(EquWsk,ValStr,L);
end;

procedure GetTockenOne(Inp : string; var KodStr :string; var ValStr:string);
var
  p: pchar;
begin
  p := pchar(Inp);
  GetTocken(p,KodStr,ValStr);
end;

function  GetSubTocken(var wsk:pchar; var Tocken :string):boolean;
var
  StrWsk        : pChar;
  a             : char;
  L             : integer;
  quote         : boolean;
  DoEnd         : boolean;
begin
  StrWsk := wsk;
  quote  := false;
  DoEnd  := false;
  repeat
    a:= Wsk^;
    inc(Wsk);
    if not(quote) then
    begin
      if a='"' then quote:=true;
      if a=',' then DoEnd:=true;
    end
    else
    begin
      if a='"' then quote:=false;
    end;
  until (a=#0) or DoEnd;
  Result := (a<>#0);

  L :=Integer(Wsk)-Integer(StrWsk)-1;
  CopyAndTrim(StrWsk,Tocken,L);
end;

function  GetSubTockens(Inp : string; var sub1 :string; var sub2:string):boolean; overload;
var
  Wsk : pchar;
begin
  wsk:=pchar(Inp);
  Result := GetSubTocken(wsk,sub1);
  GetSubTocken(wsk,sub2);
end;

function  GetSubTockens(Inp : string; var sub1 :string; var sub2:string; var sub3:string):boolean; overload;
var
  Wsk : pchar;
begin
  wsk:=pchar(Inp);
  GetSubTocken(wsk,sub1);
  Result := GetSubTocken(wsk,sub2);
  GetSubTocken(wsk,sub3);
end;

function  GetSubTockens(Inp : string; var sub1 :string; var sub2:string;
          var sub3:string; var sub4:string):boolean; overload;
var
  Wsk : pchar;
begin
  wsk:=pchar(Inp);
  GetSubTocken(wsk,sub1);
  GetSubTocken(wsk,sub2);
  Result := GetSubTocken(wsk,sub3);
  GetSubTocken(wsk,sub4);
end;

function  GetSubTockens(Inp : string; var sub1 :string; var sub2:string;
          var sub3:string; var sub4:string; var sub5:string):boolean; overload;
var
  Wsk : pchar;
begin
  wsk:=pchar(Inp);
  GetSubTocken(wsk,sub1);
  GetSubTocken(wsk,sub2);
  GetSubTocken(wsk,sub3);
  Result := GetSubTocken(wsk,sub4);
  GetSubTocken(wsk,sub5);
end;


function  GetSubTockens(Inp : string; var sub1 :string; var sub2:string;
          var sub3:string; var sub4:string; var sub5:string;
          var sub6:string; var sub7:string):boolean; overload;
var
  Wsk : pchar;
begin
  wsk:=pchar(Inp);
  GetSubTocken(wsk,sub1);
  GetSubTocken(wsk,sub2);
  GetSubTocken(wsk,sub3);
  GetSubTocken(wsk,sub4);
  GetSubTocken(wsk,sub5);
  Result := GetSubTocken(wsk,sub6);
  GetSubTocken(wsk,sub7);
end;


// 00000000011111111122222
// 12345678901234567890123
// yyyy.mm.dd hh:nn:ss,zzz

function GkStrToDateTime(var DtTm : TDateTime; TmStr: string) : boolean;
var
  y,m,d,h,n,e,z : integer;
  Tm,Dt         : TDateTime;
begin
  Result := false;
  TmStr := TmStr+'                                   ';
  if (TmStr[5]='.') and (TmStr[8]='.') and (TmStr[11]=' ') and
     (TmStr[14]=':') and (TmStr[17]=':') and (TmStr[20]='.') then
  begin
    try
      y :=  StrToInt(copy(TmStr,1,4));   //rok
      m :=  StrToInt(copy(TmStr,6,2));   //miesiac
      d :=  StrToInt(copy(TmStr,9,2));   //dzien
      h :=  StrToInt(copy(TmStr,12,2));  //godzina
      n :=  StrToInt(copy(TmStr,15,2));  //minuta
      e :=  StrToInt(copy(TmStr,18,2));  //sekunda
      z :=  StrToInt(copy(TmStr,21,3));  //milisekunda
      if TryEncodeDate(y,m,d,dt) and TryEncodeTime(h,n,e,z,tm) then
      begin
        DtTm := Dt+Tm;
        Result := true;
      end;
    except

    end;
  end;
end;

function  GkDateTimeToStr(DtTm : TDateTime):string;
begin
 if DtTm<>0 then
   DateTimeToString(Result,DATE_TIME_FORMAT,DtTm)
 else
   Result := '????.??.?? ??:??:??.???';
end;

function BoolStr(p: boolean):string;
begin
  if p then  Result:='1' else Result :='0';
end;

end.
