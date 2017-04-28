program Vypisy;

uses
  Forms,
  VypisFIO in 'VypisFIO.pas' {Form1},
  DesUtils in 'DesUtils.pas',
  uTVypis in 'uTVypis.pas',
  uTPlatbaZVypisu in 'uTPlatbaZVypisu.pas',
  uTParovatko in 'uTParovatko.pas',
  AbraEntities in 'AbraEntities.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Vypisy';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
