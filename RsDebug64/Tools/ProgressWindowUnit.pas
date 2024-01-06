unit ProgressWindowUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls;



type
  TProgressForm = class(TForm)
    ProgressBar: TProgressBar;
    InfoLabel: TLabel;
    WakeUpTimer: TTimer;
    Bevel1: TBevel;
    BreakBtn: TButton;
    procedure WakeUpTimerTimer(Sender: TObject);
    procedure BreakBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FBreakHandle  : THandle;
    procedure ShowUp;
  public
    procedure Start(ACaption,Info : string; delay : integer);
    procedure SetStageName(Info : string);
    procedure Progress(r : real); overload;
    procedure Progress(cnt,max : integer); overload;
    procedure Finish;
    property  BreakHandle : THandle read FBreakHandle;
  end;

implementation



{$R *.dfm}


procedure TProgressForm.FormCreate(Sender: TObject);
begin
  FBreakHandle := CreateEvent(nil,true,false,nil);
end;

procedure TProgressForm.FormDestroy(Sender: TObject);
begin
  CloseHandle(FBreakHandle);
end;

procedure TProgressForm.Start(ACaption,Info : string; delay : integer);
begin
  Caption := ACaption;
  InfoLabel.Caption := Info;
  if delay<>0 then
  begin
    WakeUpTimer.Interval := delay;
    WakeUpTimer.Enabled:=true;
  end
  else
  begin
    ShowUp;
  end;
  Progress(0);
  Refresh;
end;

procedure TProgressForm.SetStageName(Info : string);
begin
  InfoLabel.Caption := Info;
end;

procedure TProgressForm.ShowUp;
begin
  Show;
end;

procedure TProgressForm.Progress(r : real);
begin
  ProgressBar.Position := round(100*r);
  ProgressBar.Refresh;
  if not(WakeUpTimer.Enabled) then
  begin
    WakeUpTimer.Interval := 100;
    WakeUpTimer.Enabled := true;
  end;
end;

procedure TProgressForm.Progress(cnt,max : integer);
begin
  if max<>0 then
    Progress(cnt/max)
  else
    Progress(0.0);
end;

procedure TProgressForm.Finish;
begin
  Update;
  Hide;
end;

procedure TProgressForm.WakeUpTimerTimer(Sender: TObject);
begin
  WakeUpTimer.Enabled := false;
  ShowUp;
  ProgressBar.Refresh;
end;


procedure TProgressForm.BreakBtnClick(Sender: TObject);
begin
  SetEvent(FBreakHandle);
end;


end.
