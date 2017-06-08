program Vypisy;

uses
  Forms,
  VypisyMain in 'VypisyMain.pas' {fmMain},
  DesUtils in 'DesUtils.pas',
  uTVypis in 'uTVypis.pas',
  uTPlatbaZVypisu in 'uTPlatbaZVypisu.pas',
  uTParovatko in 'uTParovatko.pas',
  AbraEntities in 'AbraEntities.pas',
  PrirazeniPNP in 'PrirazeniPNP.pas' {fmPrirazeniPnp},
  Customers in 'Customers.pas' {fmCustomers},
  superobject in '..\Libs\superobject.pas',
  supertypes in '..\Libs\supertypes.pas',
  superdate in '..\Libs\superdate.pas',
  supertimezone in '..\Libs\supertimezone.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Vypisy';
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmPrirazeniPnp, fmPrirazeniPnp);
  Application.CreateForm(TfmCustomers, fmCustomers);
  Application.Run;
end.
