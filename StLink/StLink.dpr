program StLink;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form2},
  SimpSock_Tcp in 'SimpSock_Tcp.pas',
  StLinkDriver in 'StLinkDriver.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
