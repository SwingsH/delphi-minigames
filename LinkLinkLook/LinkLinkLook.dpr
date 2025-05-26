program LinkLinkLook;

uses
  Forms,
  main in 'main.pas' {Form1},
  image in 'image.pas',
  LLK in 'llk.pas' ;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
