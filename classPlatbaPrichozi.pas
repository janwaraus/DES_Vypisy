unit classPlatbaPrichozi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, IniFiles, Forms,
  Dialogs, StdCtrls, Grids, AdvObj, BaseGrid, AdvGrid, StrUtils, //DEShelpers
  DB, ComObj, AdvEdit, DateUtils, Math, ExtCtrls,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection,
  DesUtils;

{
  SysUtils, Classes, DB, StrUtils, ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ZAbstractConnection, ZConnection, Dialogs, DesUtils; }

function CCompareCreditFirst(Item1, Item2: Pointer): Integer;
procedure DebetyDozadu(mPlatbaPrichoziList: TList);

type

  TPlatbaPrichozi = class(TDataModule)
  private
    qrAbra: TZQuery;
  public
    typZaznamu: string[3];
    cisloUctuMoje: string[16];
    cisloUctu: string[21];
    cisloUctuBezNul: string[21];
    cisloDokladu: string[13];
    castka: currency;
    kodUctovani: string[1];
    VS: string[10];
    plnyPodleGpcKS: string[10];
    KS: string[4];
    SS: string[10];
    valuta: string[6];
    nazevKlienta: string[20];
    nulaNavic: string[1];
    kodMeny: string[4];
    Datum: double;
    kredit: boolean;
    debet: boolean;
    zprava : string;

    PredchoziPlatbyList : TList;
    PredchoziPlatbyVsList : TList;
    DokladyList : TList;
    
    constructor create(gpcLine : string; qrAbra : TZQuery);

  published
    procedure init(pocetPredcozichPlateb : integer);
    procedure loadPredchoziPlatby(pocetPlateb : integer);
    procedure loadDokladyPodleVS(jenNezaplacene : boolean);
    function getVSbyBankAccount() : string;
    function getCount() : integer;
    class function CompareCreditFirst(Item1, Item2: Pointer): Integer;    
  end;

  TVypis = class
  private
    qrAbra: TZQuery;
  public
    PoradoveCislo : integer;
    CisloUctuMoje : string[16];
    Datum  : double;
    ObratDebet  : Currency;
    ObratKredit  : Currency;
    constructor create(gpcLine : string; qrAbra : TZQuery);
  end;

  TPredchoziPlatba = class
  public
    VS : string[10];
    Firm_ID  : string[10];
    Castka  : Currency;
    cisloUctu : string[21];
    Datum  : double;
    FirmName : string;
    constructor create(qrAbra : TZQuery);
  end;

  TDoklad = class
  public
    ID : string[10];
    DocQueue_ID : string[10];
    Firm_ID : string[10];
    FirmName : string[100];
    DatumDokladu  : double;
    DatumSplatnosti  : double;
    //AccDocQueue_ID : string[10];
    //FirmOffice_ID : string[10];
    //DocUUID : string[26];
    DocumentType : string[2];
    Castka  : Currency;
    CastkaZaplaceno  : Currency;
    CastkaDobropisovano  : Currency;
    CastkaNezaplaceno  : Currency;
    CisloDokladu : string[20];
    constructor create(qrAbra : TZQuery);
  end;

  TPlatbaDokladPar = class
  public
    Platba : TPlatbaPrichozi;
    Doklad : TDoklad;
    Doklad_ID : string[10];
    //Firm_ID : string[10];
    CastkaPouzita : currency;
    Popis : string;
    vazbaNaDoklad : boolean;
  end;  

  TParovatko = class
  public
    AbraOLE: variant;
    Vypis: TVypis;    
    listPlatbaDokladPar : TList;//<TPlatbaDokladPar>;
    constructor create(AbraOLE: variant; Vypis: TVypis);
  published
    function sparujPlatbu(Platba : TPlatbaPrichozi) : integer;
    procedure odparujPlatbu(currPlatba : TPlatbaPrichozi);
    procedure vytvorPDPar(Platba : TPlatbaPrichozi; Doklad : TDoklad;
                Castka: currency; popis : string; vazbaNaDoklad : boolean);
    function zapisDoAbry() : string;
    function getUzSparovano(Doklad_ID : string) : currency;
    function getPDParyAsText() : AnsiString;
    function getPDParyPlatbyAsText(currPlatba : TPlatbaPrichozi) : AnsiString;
    function getPDPar(currPlatba : TPlatbaPrichozi; currDoklad_ID: string) : TPlatbaDokladPar;

  end;




var
  PlatbaPrichozi: TPlatbaPrichozi;

implementation

{$R *.dfm}

procedure DebetyDozadu(mPlatbaPrichoziList: TList);
var
  i : integer;
  iPP : TPlatbaPrichozi;
begin

  for i := mPlatbaPrichoziList.Count - 1 downto 0 do
  begin
    iPP := TPlatbaPrichozi(mPlatbaPrichoziList[i]);
    if iPP.debet then begin
      mPlatbaPrichoziList.Delete(i);
      mPlatbaPrichoziList.Add(iPP);
    end;
  end;
end;

function CCompareCreditFirst(Item1, Item2: Pointer): Integer;
var
it1 : TPlatbaPrichozi;

begin
//MessageDlg('p1 ' + booltostr(assigned(Item1), true), mtInformation, [mbOk], 0);
//dumpobject(Item1);
{
MessageDlg('I1 ' + booltostr(TPlatbaPrichozi(Item1).debet)
+ ' val ' + floattostr(TPlatbaPrichozi(Item1).castka), mtInformation, [mbOk], 0);
}
  if (TPlatbaPrichozi(Item1).kredit AND TPlatbaPrichozi(Item2).debet) then
    Result := -1
  else if (TPlatbaPrichozi(Item1).debet AND TPlatbaPrichozi(Item2).kredit) then
    Result := 1
  else
    Result := 0

//  MessageDlg('Compare ' + TMyClass(Item1).MyString + ' to ' + TMyClass(Item2).MyString,
//                 mtInformation, [mbOk], 0);
end;

constructor TVypis.create(gpcLine : string; qrAbra : TZQuery);
begin
  self.qrAbra := qrAbra;

  self.PoradoveCislo := StrToInt(copy(gpcLine, 106, 3));
  self.CisloUctuMoje := copy(gpcLine, 4, 16);
  self.ObratDebet := StrToInt(copy(gpcLine, 76, 14)) / 100;
  self.ObratKredit := StrToInt(copy(gpcLine, 91, 14)) / 100;
  self.Datum := Str6digitsToDate(copy(gpcLine, 109, 6));
end;

constructor TPlatbaPrichozi.create(gpcLine : string; qrAbra : TZQuery);
begin
  self.qrAbra := qrAbra;

  self.typZaznamu := copy(gpcLine, 1, 3);
  self.cisloUctuMoje := copy(gpcLine, 4, 16);
  self.cisloUctu := copy(gpcLine, 20, 16) + '/' + copy(gpcLine, 74, 4);
  self.cisloUctuBezNul := removeLeadingZeros(self.cisloUctu);
  self.cisloDokladu := copy(gpcLine, 36, 13);
  self.castka := StrToInt(removeLeadingZeros(copy(gpcLine, 49, 12))) / 100;
  self.kodUctovani := copy(gpcLine, 61, 1);
  self.VS := removeLeadingZeros(copy(gpcLine, 62, 10));
  //self.KSplnyPodleGpc := copy(gpcLine, 72, 10);
  self.KS := copy(gpcLine, 78, 4);
  self.SS := removeLeadingZeros(copy(gpcLine, 82, 10));
  //self.valuta := copy(gpcLine, 92, 6);
  self.nazevKlienta := Trim(copy(gpcLine, 98, 20));
  //self.nulaNavic := copy(gpcLine, 118, 1);
  //self.kodMeny := copy(gpcLine, 119, 4);
  self.Datum := Str6digitsToDate(copy(gpcLine, 123, 6));
  self.kredit := true;

  if self.kodUctovani = '1' then self.kredit := false;
  if self.kodUctovani = '2' then self.kredit := true;
  self.debet := not self.kredit;

  if kredit AND (cisloUctuBezNul = '2100098382/2010') then nazevKlienta := 'z BÚ';
  if kredit AND (cisloUctuBezNul = '2800098383/2010') then nazevKlienta := 'z SÚ';
  if kredit AND (cisloUctuBezNul = '171336270/0300 ') then nazevKlienta := 'z ÈSOB';
  if kredit AND (cisloUctuBezNul = '2107333410/2700') then nazevKlienta := 'z PayU';

  if debet AND (cisloUctuBezNul = '2100098382/2010') then nazevKlienta := 'na BÚ';
  if debet AND (cisloUctuBezNul = '2800098383/2010') then nazevKlienta := 'na SÚ';
  if debet AND (cisloUctuBezNul = '171336270/0300 ') then nazevKlienta := 'na ÈSOB';




end;

procedure TPlatbaPrichozi.init(pocetPredcozichPlateb : integer);
begin
  self.loadPredchoziPlatby(pocetPredcozichPlateb);
  self.loadDokladyPodleVS(true);
end;

procedure TPlatbaPrichozi.loadPredchoziPlatby(pocetPlateb : integer);
//var
  //SQLStr : AnsiString;
begin
  self.PredchoziPlatbyList := TList.Create;
  self.PredchoziPlatbyVsList := TList.Create;

  with qrAbra do begin
  // posledních N plateb ze stejného èísla úètu
    SQL.Text := 'SELECT FIRST ' + IntToStr(pocetPlateb) + ' bs.VarSymbol, bs.Firm_ID, bs.Amount, '
              + 'bs.Credit, bs.BankAccount, bs.DocDate$Date, firms.Name as FirmName '
              + 'FROM BankStatements2 bs '
              + 'JOIN Firms ON bs.Firm_ID = Firms.Id '
              + 'WHERE bs.BankAccount = ''' + self.cisloUctu  + ''' '
              + 'AND bs.BankStatementRow_ID is null '
              + 'ORDER BY DocDate$Date DESC';
    Open;
    while not Eof do begin
      self.PredchoziPlatbyList.Add(TPredchoziPlatba.create(qrAbra));
      Next;
    end;
    Close;

  // posledních N plateb na stejný VS

    SQL.Text := 'SELECT FIRST ' + IntToStr(pocetPlateb) + ' bs.VarSymbol, bs.Firm_ID, bs.Amount, '
              + 'bs.Credit, bs.BankAccount, bs.DocDate$Date, firms.Name as FirmName '
              + 'FROM BankStatements2 bs '
              + 'JOIN Firms ON bs.Firm_ID = Firms.Id '
              + 'WHERE bs.VarSymbol = ''' + self.VS  + ''' '
              + 'AND bs.BankStatementRow_ID is null '
              + 'ORDER BY DocDate$Date DESC';
    Open;
    while not Eof do begin
      self.PredchoziPlatbyVsList.Add(TPredchoziPlatba.create(qrAbra));
      Next;
    end;
    Close;
  end;
end;


procedure TPlatbaPrichozi.loadDokladyPodleVS(jenNezaplacene : boolean);
var
  SQLiiSelect, SQLiiJoin, SQLiiJenNezaplacene, SQLiiWhere, SQLiiOrder,
  SQLidiSelect, SQLidiJoin, SQLidiJenNezaplacene, SQLidiWhere, SQLidiOrder,
  SQLStr : AnsiString;
begin
  self.DokladyList := TList.Create;

  with qrAbra do begin

    // cteni s IssuedInvoices
    SQLiiSelect :=
              'SELECT ii.ID, ii.DOCQUEUE_ID, ii.DOCDATE$DATE, ii.FIRM_ID, ii.DESCRIPTION, D.DOCUMENTTYPE, '
            + 'D.Code || ''-'' || II.OrdNumber || ''/'' || substring(P.Code from 3 for 2) as CisloDokladu, '
            + 'ii.LOCALAMOUNT, ii.LOCALPAIDAMOUNT, ii.LOCALCREDITAMOUNT, ii.LOCALPAIDCREDITAMOUNT, '
            //+ 'ii.DUEDATE$DATE, ii.ACCDOCQUEUE_ID, ii.FIRMOFFICE_ID, ii.DOCUUID, '
            + 'firms.Name as FirmName '
            + 'FROM ISSUEDINVOICES ii ';
    SQLiiJoin :=
              'JOIN Firms ON ii.Firm_ID = Firms.Id '
            + 'JOIN DocQueues D ON ii.DocQueue_ID = D.Id '
            + 'JOIN Periods P ON ii.Period_ID = P.Id ';
    SQLiiWhere := 'WHERE ii.VarSymbol = ''' + self.VS  + ''' ';
    SQLiiJenNezaplacene :=  'AND (ii.LOCALAMOUNT - ii.LOCALPAIDAMOUNT - ii.LOCALCREDITAMOUNT + ii.LOCALPAIDCREDITAMOUNT) <> 0 ';
    SQLiiOrder := 'order by ii.DocDate$Date DESC';

    if jenNezaplacene then
      SQL.Text := SQLiiSelect + SQLiiJoin + SQLiiJenNezaplacene + SQLiiWhere + SQLiiOrder
    else
      SQL.Text := SQLiiSelect + SQLiiJoin + SQLiiWhere + SQLiiOrder;
    Open;
    while not Eof do begin
      self.DokladyList.Add(TDoklad.Create(qrAbra));
      Next;
    end;
    Close;

    // cteni s IssuedDInvoices - zalohove listy
    SQLiiSelect :=
              'SELECT ii.ID, ii.DOCQUEUE_ID, ii.DOCDATE$DATE, ii.FIRM_ID, ii.DESCRIPTION, D.DOCUMENTTYPE, '
            + 'D.Code || ''-'' || II.OrdNumber || ''/'' || substring(P.Code from 3 for 2) as CisloDokladu, '
            + 'ii.LOCALAMOUNT, ii.LOCALPAIDAMOUNT, 0 as LOCALCREDITAMOUNT, 0 as LOCALPAIDCREDITAMOUNT, '
            //+ 'ii.DUEDATE$DATE, ii.ACCDOCQUEUE_ID, ii.FIRMOFFICE_ID, ii.DOCUUID, '
            + 'firms.Name as FirmName '
            + 'FROM ISSUEDDINVOICES ii ';
    SQLiiJoin :=
              'JOIN Firms ON ii.Firm_ID = Firms.Id '
            + 'JOIN DocQueues D ON ii.DocQueue_ID = D.Id '
            + 'JOIN Periods P ON ii.Period_ID = P.Id ';
    SQLiiWhere := 'WHERE ii.VarSymbol = ''' + self.VS  + ''' ';
    SQLiiJenNezaplacene :=  'AND (ii.LOCALAMOUNT - ii.LOCALPAIDAMOUNT) <> 0 ';
    SQLiiOrder := 'order by ii.DocDate$Date DESC';

    if jenNezaplacene then
      SQL.Text := SQLiiSelect + SQLiiJoin + SQLiiJenNezaplacene + SQLiiWhere + SQLiiOrder
    else
      SQL.Text := SQLiiSelect + SQLiiJoin + SQLiiWhere + SQLiiOrder;
    Open;
    while not Eof do begin
      self.DokladyList.Add(TDoklad.Create(qrAbra));
      Next;
    end;
    Close;


    // v RecievedInvoices bych musel hledat vydane faktury
    {
  self.ID := FieldByName('ID').AsString;
  self.Firm_ID := FieldByName('Firm_ID').AsString;
  self.FirmName := FieldByName('FirmName').AsString;
  self.DatumDokladu := FieldByName('DocDate$Date').asFloat;
  self.Castka := FieldByName('LocalAmount').AsCurrency;
  self.CastkaZaplaceno := FieldByName('LocalPaidAmount').AsCurrency
                                - FieldByName('LocalPaidCreditAmount').AsCurrency;;
  self.CastkaDobropisovano := FieldByName('LocalCreditAmount').AsCurrency;
  self.CastkaNezaplaceno := self.Castka - self.CastkaZaplaceno - self.CastkaDobropisovano;
  self.CisloDokladu := FieldByName('CisloDokladu').AsString;

    }

  if DokladyList.Count = 0 then begin

    SQLStr := 'SELECT FIRST 2 ii.ID, ii.DOCQUEUE_ID, ii.DOCDATE$DATE, ii.FIRM_ID, ii.DESCRIPTION, D.DOCUMENTTYPE, '
            + 'D.Code || ''-'' || II.OrdNumber || ''/'' || substring(P.Code from 3 for 2) as CisloDokladu, '
            + 'ii.LOCALAMOUNT, ii.LOCALPAIDAMOUNT, ii.LOCALCREDITAMOUNT, ii.LOCALPAIDCREDITAMOUNT, '
            + 'ii.DUEDATE$DATE, ii.ACCDOCQUEUE_ID, ii.FIRMOFFICE_ID, ii.DOCUUID, firms.Name as FirmName '
            + 'FROM ISSUEDINVOICES ii ';
    SQLStr := SQLStr
            + 'JOIN Firms ON ii.Firm_ID = Firms.Id '
            + 'JOIN DocQueues D ON ii.DocQueue_ID = D.Id '
            + 'JOIN Periods P ON ii.Period_ID = P.Id '
            + 'WHERE ii.VarSymbol = ''' + self.VS  + ''' ';
    SQLStr := SQLStr + 'order by ii.DocDate$Date DESC';
    SQL.Text := SQLStr;
    Open;
    while not Eof do begin
      self.DokladyList.Add(TDoklad.Create(qrAbra));
      Next;
    end;
    Close;

  end;


  end;
end;



function TPlatbaPrichozi.getVSbyBankAccount() : string;
begin
  with qrAbra do begin
    SQL.Text := 'SELECT FIRST 3 VarSymbol, Firm_ID FROM BankStatements2 '
              + 'WHERE BankAccount like ''' + self.cisloUctu  + ''' '
              + 'ORDER BY DocDate$Date DESC';
    Open;
    if not Eof then begin
      result := FieldByName('VarSymbol').AsString + ' a firmID: ' + FieldByName('Firm_ID').AsString;
      Next;
    end;

    Close;
  end;

end;


class function TPlatbaPrichozi.CompareCreditFirst(Item1, Item2: Pointer): Integer;
var
i: integer;
begin
i :=3;
  if (TPlatbaPrichozi(Item1).kredit AND TPlatbaPrichozi(Item2).debet) then
    Result := 1
  else
    Result := -1;
//  MessageDlg('Compare ' + TMyClass(Item1).MyString + ' to ' + TMyClass(Item2).MyString,
//                 mtInformation, [mbOk], 0);
end;

function TPlatbaPrichozi.getCount() : integer;
begin
  result := 1;
end;

{** class TPredchoziPlatba **}

constructor TPredchoziPlatba.create(qrAbra : TZQuery);
begin
 with qrAbra do begin
  self.VS := FieldByName('VarSymbol').AsString;
  self.Firm_ID := FieldByName('Firm_ID').AsString;
  self.Castka := FieldByName('Amount').AsCurrency;
  self.cisloUctu := FieldByName('BankAccount').AsString;
  self.Datum := FieldByName('DocDate$Date').asFloat;
  self.FirmName := FieldByName('FirmName').AsString;

  if (FieldByName('Credit').AsString = 'N') then
    self.Castka := - self.Castka;

 end;
end;

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
                                - FieldByName('LocalPaidCreditAmount').AsCurrency;;
  self.CastkaDobropisovano := FieldByName('LocalCreditAmount').AsCurrency;
  self.CastkaNezaplaceno := self.Castka - self.CastkaZaplaceno - self.CastkaDobropisovano;
  self.CisloDokladu := FieldByName('CisloDokladu').AsString;
  self.DocumentType := FieldByName('DocumentType').AsString;
 end; 
end;

{** class TParovatko ** }

constructor TParovatko.create(AbraOLE: variant; Vypis: TVypis);
begin
  self.AbraOLE := AbraOLE;
  self.Vypis := Vypis;
  self.listPlatbaDokladPar := TList.Create();
end;

function TParovatko.sparujPlatbu(Platba : TPlatbaPrichozi) : integer;
var
  dokladyCount, i : integer;
  NezaplaceneDoklady : TList;
  iDoklad : TDoklad;
  zbyvaCastka,
  kNaparovani : currency;
begin
  NezaplaceneDoklady := TList.Create;
  iDoklad := nil;

  self.odparujPlatbu(Platba);

  if Platba.DokladyList.Count > 0 then
    iDoklad := TDoklad(Platba.DokladyList[0]); //pokud je alespon 1 doklad, priradime si ho pro debety a kredity bez nezaplacenych dokladu

  if Platba.debet then //platba je Debet
  begin
      Platba.zprava := 'debet ' + FloatToStr(Platba.Castka) + ' Kè';
      Result := 0;
      vytvorPDPar(Platba, iDoklad, Platba.Castka, '', false);
  end else
  begin //platba je Kredit

    // vyrobím si list jen nezaplacených dokladù
    for i := 0 to Platba.DokladyList.Count - 1 do
      if TDoklad(Platba.DokladyList[i]).CastkaNezaplaceno <> 0 then
        NezaplaceneDoklady.Add(Platba.DokladyList[i]);

    dokladyCount := NezaplaceneDoklady.Count;

    zbyvaCastka := Platba.Castka;

    if (dokladyCount = 0) then begin
      Platba.zprava := 'žádný doklad, pøeplatek ' + FloatToStr(zbyvaCastka) + ' Kè, VS ' + Platba.VS;
      Result := 0;
      vytvorPDPar(Platba, iDoklad, zbyvaCastka, 'pøepl. | ' + Platba.VS + ' |', false);
      Exit;
    end;


    for i := dokladyCount - 1 downto 0 do
    begin
      iDoklad := TDoklad(NezaplaceneDoklady[i]);
      kNaparovani := iDoklad.CastkaNezaplaceno - getUzSparovano(iDoklad.ID);

      if (kNaparovani <> 0) then
      begin
        if (kNaparovani = zbyvaCastka) then
        begin
          vytvorPDPar(Platba, iDoklad, zbyvaCastka, '', true); //pøesnì |
          Platba.zprava := 'vše použito';
          Result := 1;
          Exit;
        end else

        if (kNaparovani > zbyvaCastka) then
        begin
          vytvorPDPar(Platba, iDoklad, zbyvaCastka, 'èást. ' + floattostr(zbyvaCastka) + ' z ' + floattostr(kNaparovani) + ' Kè |', true);
          Platba.zprava := 'vše použito';
          Result := 1;
          Exit;
        end else

        begin
          vytvorPDPar(Platba, iDoklad, kNaparovani, '', true); //pøesnì (rozpad) |
          zbyvaCastka := zbyvaCastka - kNaparovani;
        end;
      end;
    end;
    Platba.zprava := 'pøeplatek ' + FloatToStr(zbyvaCastka) + ' Kè';
    Result := 2;
    vytvorPDPar(Platba, iDoklad, zbyvaCastka, 'pøepl. | ' + Platba.VS + ' |' , false);
  end;
end;

procedure TParovatko.odparujPlatbu(currPlatba : TPlatbaPrichozi);
var
  i : integer;
  iPDPar : TPlatbaDokladPar;
begin

  for i := listPlatbaDokladPar.Count - 1 downto 0 do
  begin
    iPDPar := TPlatbaDokladPar(listPlatbaDokladPar[i]);
    if iPDPar.Platba = currPlatba then
      listPlatbaDokladPar.Delete(i);
  end;
end;


procedure TParovatko.vytvorPDPar(Platba : TPlatbaPrichozi; Doklad : TDoklad;
            Castka: currency; popis : string; vazbaNaDoklad : boolean);
var
  iPDPar : TPlatbaDokladPar;
begin
  iPDPar := TPlatbaDokladPar.Create();
  iPDPar.Platba := Platba;
  iPDPar.Doklad := Doklad;
  if assigned(iPDPar.Doklad) then
    iPDPar.Doklad_ID := iPDPar.Doklad.ID
  else
    iPDPar.Doklad_ID := '';
  iPDPar.CastkaPouzita := Castka;
  iPDPar.Popis := Popis;
  iPDPar.vazbaNaDoklad := vazbaNaDoklad;
  self.listPlatbaDokladPar.Add(iPDPar);
end;


function TParovatko.zapisDoAbry() : string;
var
  i : integer;
  iPDPar : TPlatbaDokladPar;
  DocQueues_IDs, BankAccounts_IDs : TStrings;
  BStatement_Object,
  BStatement_Data,
  BStatementRow_Object,
  BStatementRow_Data,
  BStatementRow_Coll,
  NewID : variant;
begin

  if (listPlatbaDokladPar.Count = 0) then Exit;
  //iPDPar := TPlatbaDokladPar(listPlatbaDokladPar[0]);

  Result := 'Zapsán do ABRY výpis pro úèet ' + removeLeadingZeros(iPDPar.Platba.cisloUctuMoje);

  DocQueues_IDs := TStringList.Create;
  DocQueues_IDs.Values['2100098382'] := '2S00000101'; //BF Fio
  DocQueues_IDs.Values['171336270'] :='N000000101'; //BV ÈSOB
  DocQueues_IDs.Values['2800098383'] := '1U00000101'; //BS Fio spoøící
  DocQueues_IDs.Values['2389210008000000'] := '1Z00000101'; //BP PayU

  BankAccounts_IDs := TStringList.Create;
  BankAccounts_IDs.Values['2100098382'] := '1400000101'; //BF Fio
  BankAccounts_IDs.Values['171336270'] :='1000000101'; //BV ÈSOB
  BankAccounts_IDs.Values['2800098383'] := '1500000101'; //BS Fio spoøící
  BankAccounts_IDs.Values['2389210008000000'] := '1800000101'; //BP PayU

  BStatement_Object:= AbraOLE.CreateObject('@BankStatement');
  BStatement_Data:= AbraOLE.CreateValues('@BankStatement');
  BStatement_Object.PrefillValues(BStatement_Data);
  BStatement_Data.ValueByName('DocQueue_ID') := DocQueues_IDs.Values[removeLeadingZeros(self.Vypis.CisloUctuMoje)];
  BStatement_Data.ValueByName('Period_ID') := '1L20000101'; //rok 2017, TODO automatika

  BStatement_Data.ValueByName('BankAccount_ID') := BankAccounts_IDs.Values[removeLeadingZeros(self.Vypis.CisloUctuMoje)];
  BStatement_Data.ValueByName('ExternalNumber') := IntToStr(self.Vypis.PoradoveCislo);


  BStatement_Data.ValueByName('DocDate$DATE') := TPlatbaDokladPar(listPlatbaDokladPar[listPlatbaDokladPar.Count - 1]).Platba.Datum; //datum podle data poslední položky výpisu
  BStatement_Data.ValueByName('CreatedAt$DATE') := IntToStr(Trunc(Date));

  BStatementRow_Object := AbraOLE.CreateObject('@BankStatementRow');
  BStatementRow_Coll := BStatement_Data.Value[IndexByName(BStatement_Data, 'Rows')];

  for i := 0 to listPlatbaDokladPar.Count - 1 do
  begin
    iPDPar := TPlatbaDokladPar(listPlatbaDokladPar[i]);

    BStatementRow_Data := AbraOLE.CreateValues('@BankStatementRow');
    BStatementRow_Object.PrefillValues(BStatementRow_Data);
    BStatementRow_Data.ValueByName('Amount') := iPDPar.CastkaPouzita;
    BStatementRow_Data.ValueByName('Credit') := IfThen(iPDPar.Platba.Kredit,'1','0');
    BStatementRow_Data.ValueByName('BankAccount') := iPDPar.Platba.cisloUctu;
    BStatementRow_Data.ValueByName('Text') := iPDPar.popis + ' ' + iPDPar.Platba.nazevKlienta;
    BStatementRow_Data.ValueByName('SpecSymbol') := iPDPar.Platba.SS;
    BStatementRow_Data.ValueByName('DocDate$DATE') := iPDPar.Platba.Datum;
    BStatementRow_Data.ValueByName('AccDate$DATE') := iPDPar.Platba.Datum;

    if Assigned(iPDPar.Doklad) then
      BStatementRow_Data.ValueByName('Firm_ID') := iPDPar.Doklad.Firm_ID
    else // if iPDPar.Platba.Debet then
      BStatementRow_Data.ValueByName('Firm_ID') := '3Y90000101';  // DES
    
    if iPDPar.vazbaNaDoklad AND Assigned(iPDPar.Doklad) then //Doklad vyplnime jen jestli chceme vazbu. Doklad máme i když vazbu nechceme - kvùli Firm_ID
    begin
      BStatementRow_Data.ValueByName('VarSymbol') := iPDPar.Platba.VS;
      //BStatementRow_Data.ValueByName('PAmount') := iPDPar.CastkaPouzita;
      //BStatementRow_Data.ValueByName('PDocument_ID') := iPDPar.Doklad.ID;
      //BStatementRow_Data.ValueByName('PDocumentType') := iPDPar.Doklad.DocumentType; //todo
      //BStatementRow_Data.ValueByName('BusOrder_ID') := '8D00000101'; //todo
      //BStatementRow_Data.ValueByName('BusTransaction_ID') := '4L00000101'; //todo
      //BStatementRow_Data.ValueByName('SpecSymbol') := iPDPar.Platba.SS;
    end;

    if iPDPar.Platba.Debet then
    begin
      BStatementRow_Data.ValueByName('VarSymbol') := iPDPar.Platba.VS; //pro debety aby vždy zùstal VS
    end;

    //BStatementRow_Data.ValueByName('Division_ID') := '1000000101';
    //BStatementRow_Data.ValueByName('Currency_ID') := '0000CZK000';

    BStatementRow_Coll.Add(BStatementRow_Data);
  end;

  try
    NewID := BStatement_Object.CreateNewFromValues(BStatement_Data);
  except on E: exception do
    begin
      Application.MessageBox(PChar('Problemmm ' + ^M + E.Message), 'AbraOLE');
      Application.Terminate;
    end;
  end;

  Result := Result + ' Èíslo výpisu je ' + NewID;
end;



function TParovatko.getUzSparovano(Doklad_ID : string) : currency;
var
  i : integer;
  iPDPar : TPlatbaDokladPar;
begin
  Result := 0;

  if listPlatbaDokladPar.Count > 0 then
    for i := 0 to listPlatbaDokladPar.Count - 1 do
    begin
      iPDPar := TPlatbaDokladPar(listPlatbaDokladPar[i]);
      if Assigned(iPDPar.Doklad) AND (iPDPar.vazbaNaDoklad) then
        if (iPDPar.Doklad.ID = Doklad_ID)  then
          Result := Result + iPDPar.CastkaPouzita;
    end;
end;


function TParovatko.getPDParyAsText() : AnsiString;
var
  i : integer;
  iPDPar : TPlatbaDokladPar;
begin
  Result := '';

  if listPlatbaDokladPar.Count = 0 then exit;

  for i := 0 to listPlatbaDokladPar.Count - 1 do
  begin
    iPDPar := TPlatbaDokladPar(listPlatbaDokladPar[i]);
    Result := Result + 'VS: ' + iPDPar.Platba.VS + ' ';
    if iPDPar.vazbaNaDoklad AND Assigned(iPDPar.Doklad) then
      Result := Result + 'Na doklad ' + iPDPar.Doklad.ID + ' napárováno ' + FloatToStr(iPDPar.CastkaPouzita) + ' Kè ';
    Result := Result + ' | ' + iPDPar.Popis + sLineBreak;
  end;
end;

function TParovatko.getPDParyPlatbyAsText(currPlatba : TPlatbaPrichozi) : AnsiString;
var
  i : integer;
  iPDPar : TPlatbaDokladPar;
begin
  Result := '';
  if listPlatbaDokladPar.Count = 0 then exit;

  for i := 0 to listPlatbaDokladPar.Count - 1 do
  begin
    iPDPar := TPlatbaDokladPar(listPlatbaDokladPar[i]);
    if iPDPar.Platba = currPlatba then begin
      Result := Result + 'VS: ' + iPDPar.Platba.VS + ' ';
      if iPDPar.vazbaNaDoklad AND Assigned(iPDPar.Doklad) then
        Result := Result + 'Na doklad ' + iPDPar.Doklad.ID + ' napárováno ' + FloatToStr(iPDPar.CastkaPouzita) + ' Kè ';
      Result := Result + ' | ' + iPDPar.Popis + sLineBreak;
    end;
  end;
end;

function TParovatko.getPDPar(currPlatba : TPlatbaPrichozi; currDoklad_ID: string) : TPlatbaDokladPar;
var
  i : integer;
  iPDPar : TPlatbaDokladPar;
begin
  Result := nil;
  if listPlatbaDokladPar.Count = 0 then exit;

  for i := 0 to listPlatbaDokladPar.Count - 1 do
  begin
    iPDPar := TPlatbaDokladPar(listPlatbaDokladPar[i]);
    if (iPDPar.Platba = currPlatba) and (iPDPar.Doklad_ID = currDoklad_ID) and
    (iPDPar.vazbaNaDoklad) then
      Result := iPDPar;
  end;
end;


end.
