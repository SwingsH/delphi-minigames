program MarioBarMachine;

uses
  Forms,
  Unit_Main in 'Unit_Main.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
