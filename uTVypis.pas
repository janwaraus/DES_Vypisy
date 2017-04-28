unit uTVypis;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, IniFiles, Forms,
  Dialogs, StdCtrls, Grids, AdvObj, BaseGrid, AdvGrid, StrUtils,
  DB, ComObj, AdvEdit, DateUtils, Math, ExtCtrls,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection,
  uTPlatbaZVypisu, AbraEntities, DesUtils;

type

  TVypis = class
  private
    qrAbra: TZQuery;
  public
    Platby : TList;
    abraBankaccount : TAbraBankaccount;
    poradoveCislo : integer;
    cisloUctuVlastni : string[16];
    datum  : double;
    datumZHlavicky  : double;
    obratDebet  : currency;
    obratKredit  : currency;
    maxExistujiciPoradoveCislo : integer;

    constructor create(gpcLine : string; qrAbra : TZQuery);
  published
    procedure init();
    procedure setridit();    
    procedure nactiMaxExistujiciPoradoveCislo();
    function isNavazujeNaRadu() : boolean;
  end;

implementation


constructor TVypis.create(gpcLine : string; qrAbra : TZQuery);
begin
  self.qrAbra := qrAbra;
  self.Platby := TList.create;
  self.AbraBankAccount := TAbraBankaccount.create(qrAbra);

  self.poradoveCislo := StrToInt(copy(gpcLine, 106, 3));
  self.cisloUctuVlastni := removeLeadingZeros(copy(gpcLine, 4, 16));
  self.obratDebet := StrToInt(copy(gpcLine, 76, 14)) / 100;
  self.obratKredit := StrToInt(copy(gpcLine, 91, 14)) / 100;
  self.datumZHlavicky := Str6digitsToDate(copy(gpcLine, 109, 6));
end;


function TVypis.isNavazujeNaRadu() : boolean;
begin
  if self.poradoveCislo - self.maxExistujiciPoradoveCislo = 1 then
    Result := true
  else
    Result := false;
end;

procedure TVypis.nactiMaxExistujiciPoradoveCislo();
begin
  with qrAbra do begin
    SQL.Text := 'SELECT MAX(bs.OrdNumber) as MaxPoradoveCislo '
              + ' FROM BANKSTATEMENTS bs, PERIODS p '
              + 'WHERE bs.DOCQUEUE_ID = ''' + self.AbraBankAccount.bankStatementDocqueueId  + ''''
              + ' AND bs.PERIOD_ID = p.ID AND p.DATEFROM$DATE <= ' + FloatToStr(self.datum)
              + ' AND p.DATETO$DATE > ' + FloatToStr(self.datum);
    Open;
    if not Eof then
      self.maxExistujiciPoradoveCislo := FieldByName('MaxPoradoveCislo').AsInteger
    else
      self.maxExistujiciPoradoveCislo := 0;
    Close;
  end;
end;


procedure TVypis.init();
var
  i : integer;
  iPlatba, payuProvizePP : TPlatbaZVypisu;
  payuProvize : currency;
begin

  self.abraBankaccount.loadByNumber(self.cisloUctuVlastni);

  self.datum := TPlatbaZVypisu(self.Platby[self.Platby.Count - 1]).Datum; //datum vypisy se urci jako datum poslední platby
  self.nactiMaxExistujiciPoradoveCislo();

  payuProvize := 0;
  for i := self.Platby.Count - 1 downto 0 do
  begin
    iPlatba := TPlatbaZVypisu(self.Platby[i]);

    // seèíst PayU provize
    if iPlatba.isPayuProvize then
    begin
      //payuProvizePP := iPlatba;
      payuProvize := payuProvize + iPlatba.castka;
      self.Platby.Delete(i);
    end
    // debety dozadu
    else if iPlatba.debet then
    begin
      self.Platby.Delete(i);
      self.Platby.Add(iPlatba);
    end;
  end;

  if payuProvize > 0 then
  begin
    payuProvizePP := TPlatbaZVypisu.Create(-payuProvize, qrAbra);
    payuProvizePP.datum := self.datum;
    payuProvizePP.nazevKlienta := formatdatetime('myy', payuProvizePP.datum) + ' suma provize';
    self.Platby.Add(payuProvizePP);
  end;

end;

procedure TVypis.setridit();
var
  i : integer;
  iPlatba : TPlatbaZVypisu;

begin

  for i := self.Platby.Count - 1 downto 0 do
  begin
    iPlatba := TPlatbaZVypisu(self.Platby[i]);
    if iPlatba.problemLevel = 1 then begin
      self.Platby.Delete(i);
      self.Platby.Add(iPlatba);
    end;
  end;

  for i := self.Platby.Count - 1 downto 0 do
  begin
    iPlatba := TPlatbaZVypisu(self.Platby[i]);
    if iPlatba.problemLevel = 0 then begin
      self.Platby.Delete(i);
      self.Platby.Add(iPlatba);
    end;
  end;

  // debety dozadu
  for i := self.Platby.Count - 1 downto 0 do
  begin
    iPlatba := TPlatbaZVypisu(self.Platby[i]);
    if iPlatba.debet then begin
      self.Platby.Delete(i);
      self.Platby.Add(iPlatba);
    end;
  end;

end;



end.
