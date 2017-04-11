program Vypisy;

uses
  Forms,
  VypisFIO in 'VypisFIO.pas' {Form1},
  classPlatbaPrichozi in 'classPlatbaPrichozi.pas' {PlatbaPrichozi: TDataModule},
  DesUtils in 'DesUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Vypisy';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TPlatbaPrichozi, PlatbaPrichozi);
  Application.Run;
end.
