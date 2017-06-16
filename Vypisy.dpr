program Vypisy;

uses
  Forms,
  VypisyMain in 'VypisyMain.pas' {fmMain},
  uTVypis in 'uTVypis.pas',
  uTPlatbaZVypisu in 'uTPlatbaZVypisu.pas',
  uTParovatko in 'uTParovatko.pas',
  AbraEntities in 'AbraEntities.pas',
  PrirazeniPNP in 'PrirazeniPNP.pas' {fmPrirazeniPnp},
  Customers in 'Customers.pas' {fmCustomers},
  superdate in 'superdate.pas',
  superobject in 'superobject.pas',
  supertimezone in 'supertimezone.pas',
  supertypes in 'supertypes.pas',
  DesUtils in 'DesUtils.pas' {DesU};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Vypisy';
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmPrirazeniPnp, fmPrirazeniPnp);
  Application.CreateForm(TfmCustomers, fmCustomers);
  Application.CreateForm(TDesU, DesU);
  Application.Run;
end.
