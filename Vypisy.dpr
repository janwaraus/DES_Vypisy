program Vypisy;

uses
  Forms,
  VypisyMain in 'VypisyMain.pas' {fmMain},
  DesUtils in 'DesUtils.pas',
  uTVypis in 'uTVypis.pas',
  uTPlatbaZVypisu in 'uTPlatbaZVypisu.pas',
  uTParovatko in 'uTParovatko.pas',
  AbraEntities in 'AbraEntities.pas',
  PrirazeniPNP in 'PrirazeniPNP.pas' {fmPrirazeniPnp};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Vypisy';
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmPrirazeniPnp, fmPrirazeniPnp);
  Application.Run;
end.
