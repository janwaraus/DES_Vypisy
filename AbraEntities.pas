unit AbraEntities;

interface

uses
  SysUtils, Variants, Classes, Controls,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection;  

type

  TDoklad = class
  public
    ID : string[10];
    docQueue_ID : string[10];
    firm_ID : string[10];
    firmName : string[100];
    datumDokladu  : double;
    datumSplatnosti  : double;
    //AccDocQueue_ID : string[10];
    //FirmOffice_ID : string[10];
    //DocUUID : string[26];
    documentType : string[2];
    castka  : Currency;
    castkaZaplaceno  : Currency;
    castkaDobropisovano  : Currency;
    castkaNezaplaceno  : Currency;
    cisloDokladu : string[20];
    constructor create(qrAbra : TZQuery);
  end;

  TAbraBankAccount = class
  private
    qrAbra: TZQuery;
  public
    id : string[10];
    name : string[50];
    number : string[42];
    bankstatementDocqueueId : string[10];
    constructor create(qrAbra : TZQuery);
  published
    procedure loadByNumber(baNumber : string);
  end;

implementation

{** class TDoklad **}

constructor TDoklad.create(qrAbra : TZQuery);
begin
 with qrAbra do begin
  self.ID := FieldByName('ID').AsString;
  self.Firm_ID := FieldByName('Firm_ID').AsString;
  self.FirmName := FieldByName('FirmName').AsString;
  self.DatumDokladu := FieldByName('DocDate$Date').asFloat;
  self.Castka := FieldByName('LocalAmount').AsCurrency;
  self.CastkaZaplaceno := FieldByName('LocalPaidAmount').AsCurrency
                                - FieldByName('LocalPaidCreditAmount').AsCurrency;
  self.CastkaDobropisovano := FieldByName('LocalCreditAmount').AsCurrency;
  self.CastkaNezaplaceno := self.Castka - self.CastkaZaplaceno - self.CastkaDobropisovano;
  self.CisloDokladu := FieldByName('CisloDokladu').AsString;
  self.DocumentType := FieldByName('DocumentType').AsString;
 end; 
end;

{** class TAbraBankAccount **}

constructor TAbraBankAccount.create(qrAbra : TZQuery);
begin
  self.qrAbra := qrAbra;
end;

procedure TAbraBankAccount.loadByNumber(baNumber : string);
begin
  with qrAbra do begin

    SQL.Text := 'SELECT ID, NAME, BANKACCOUNT, BANKSTATEMENT_ID '
              + 'FROM BANKACCOUNTS '
              + 'WHERE BANKACCOUNT like ''' + baNumber  + '%'' '
              + 'AND HIDDEN = ''N'' ';

    Open;
    if not Eof then begin
      self.id := FieldByName('ID').AsString;
      self.name := FieldByName('NAME').AsString;
      self.number := FieldByName('BANKACCOUNT').AsString;
      self.bankStatementDocqueueId := FieldByName('BANKSTATEMENT_ID').AsString;
    end;
    Close;
  end;
end;

end.
 