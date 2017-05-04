unit uTParovatko;

interface

uses
  SysUtils, Variants, Classes, Controls, StrUtils,
  Windows, Messages, Dialogs, Forms,
  uTVypis, uTPlatbaZVypisu, AbraEntities, DesUtils;


type

  TPlatbaDokladPar = class
  public
    Platba : TPlatbaZVypisu;
    Doklad : TDoklad;
    Doklad_ID : string[10];
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
    procedure sparujPlatbu(Platba : TPlatbaZVypisu);
    procedure odparujPlatbu(currPlatba : TPlatbaZVypisu);
    procedure vytvorPDPar(Platba : TPlatbaZVypisu; Doklad : TDoklad;
                Castka: currency; popis : string; vazbaNaDoklad : boolean);
    function zapisDoAbry() : string;
    function zapisDoAbryNadvakrat() : string;    
    function getUzSparovano(Doklad_ID : string) : currency;
    function getPDParyAsText() : AnsiString;
    function getPDParyPlatbyAsText(currPlatba : TPlatbaZVypisu) : AnsiString;
    function getPDPar(currPlatba : TPlatbaZVypisu; currDoklad_ID: string) : TPlatbaDokladPar;
    procedure postOprava();

  end;




implementation


constructor TParovatko.create(AbraOLE: variant; Vypis: TVypis);
begin
  self.AbraOLE := AbraOLE;
  self.Vypis := Vypis;
  self.listPlatbaDokladPar := TList.Create();
end;


procedure TParovatko.sparujPlatbu(Platba : TPlatbaZVypisu);
var
  i : integer;
  nezaplaceneDoklady : TList;
  iDoklad : TDoklad;
  zbyvaCastka,
  kNaparovani : currency;
begin

  iDoklad := nil;
  Platba.rozdeleniPlatby := 0;
  Platba.castecnaUhrada := 0;

  self.odparujPlatbu(Platba); //není vlastnì už potøeba, protože vždy párujeme nanovo všechny Platby od zaèátku do konce

  if Platba.DokladyList.Count > 0 then
    iDoklad := TDoklad(Platba.DokladyList[0]); //pokud je alespon 1 doklad, priradime si ho pro debety a kredity bez nezaplacenych dokladu

  if Platba.debet then //platba je Debet
  begin
      Platba.zprava := 'debet';
      Platba.problemLevel := 0;
      vytvorPDPar(Platba, iDoklad, Platba.Castka, '', false);
  end else
  begin //platba je Kredit

    // vyrobím si list jen nezaplacených dokladù
    nezaplaceneDoklady := TList.Create;
    for i := 0 to Platba.DokladyList.Count - 1 do
      if TDoklad(Platba.DokladyList[i]).CastkaNezaplaceno <> 0 then
        nezaplaceneDoklady.Add(Platba.DokladyList[i]);


    zbyvaCastka := Platba.Castka;

    if (nezaplaceneDoklady.Count = 0) then begin
      if Platba.znamyPripad then begin
        vytvorPDPar(Platba, iDoklad, zbyvaCastka, '', false);
        Platba.zprava := 'známý kredit';
        Platba.problemLevel := 0;
      end else begin
        if Platba.getProcentoPredchozichPlatebZeStejnehoUctu() > 0.5 then begin
          vytvorPDPar(Platba, iDoklad, zbyvaCastka, 'pøepl. | ' + Platba.VS + ' |', false);
          Platba.zprava := 'známý pøep. ' + FloatToStr(zbyvaCastka) + ' Kè';
          Platba.problemLevel := 1;
        end else begin
          vytvorPDPar(Platba, iDoklad, zbyvaCastka, 'pøepl. | ' + Platba.VS + ' |', false);
          Platba.zprava := 'neznámý pøep. ' + FloatToStr(zbyvaCastka) + ' Kè';
          Platba.problemLevel := 2;
        end;
      end;
      Exit;
    end;


    for i := nezaplaceneDoklady.Count - 1 downto 0 do
    begin
      iDoklad := TDoklad(nezaplaceneDoklady[i]);
      kNaparovani := iDoklad.CastkaNezaplaceno - getUzSparovano(iDoklad.ID);

      if (kNaparovani <> 0) then
      begin
        if (kNaparovani = zbyvaCastka) then
        begin
          vytvorPDPar(Platba, iDoklad, zbyvaCastka, '', true); //pøesnì |
          Platba.zprava := 'pøesnì';
          if Platba.rozdeleniPlatby > 0 then
            Platba.problemLevel := 1
          else
            Platba.problemLevel := 0;
          Exit;
        end;

        if (kNaparovani > zbyvaCastka) AND not(iDoklad.DocumentType = '10') then
        //if (kNaparovani > zbyvaCastka) then
        begin
          vytvorPDPar(Platba, iDoklad, zbyvaCastka, 'èást. ' + floattostr(zbyvaCastka) + ' z ' + floattostr(kNaparovani) + ' Kè |', true);
          Platba.zprava := 'èásteèná úhrada';
          Platba.castecnaUhrada := 1;
          Platba.problemLevel := 1;
          Exit;
        end;

        if (kNaparovani < zbyvaCastka) then
        begin
          vytvorPDPar(Platba, iDoklad, kNaparovani, '', true); //pøesnì (rozpad) |
          zbyvaCastka := zbyvaCastka - kNaparovani;
          Inc(Platba.rozdeleniPlatby);
        end;
      end;
    end;
    vytvorPDPar(Platba, iDoklad, zbyvaCastka, 'pøepl. | ' + Platba.VS + ' |' , false);
    Platba.zprava := 'pøepl. ' + FloatToStr(zbyvaCastka) + ' Kè';
    Platba.problemLevel := 1;
  end;

end;


procedure TParovatko.odparujPlatbu(currPlatba : TPlatbaZVypisu);
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


procedure TParovatko.vytvorPDPar(Platba : TPlatbaZVypisu; Doklad : TDoklad;
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


function TParovatko.zapisDoAbryNadvakrat() : string;
var
  i, j : integer;
  iPDPar : TPlatbaDokladPar;
  BStatement_Object,
  BStatement_Data,
  BStatementRow_Object,
  BStatementRow_Data,
  BStatement_Data_Coll,
  newID, newRadekID  : variant;
  mmm : ansistring;
begin

  if (listPlatbaDokladPar.Count = 0) then Exit;

  Result := 'Zápis do ABRY výpisu pro úèet ' + removeLeadingZeros(self.Vypis.abraBankaccount.name);

  BStatement_Object:= AbraOLE.CreateObject('@BankStatement');
  BStatement_Data:= AbraOLE.CreateValues('@BankStatement');
  BStatement_Object.PrefillValues(BStatement_Data);
  BStatement_Data.ValueByName('DocQueue_ID') := self.Vypis.abraBankaccount.bankStatementDocqueueId;
  BStatement_Data.ValueByName('Period_ID') := '1L20000101'; //rok 2017, TODO automatika
  BStatement_Data.ValueByName('BankAccount_ID') := self.Vypis.abraBankaccount.id;
  BStatement_Data.ValueByName('ExternalNumber') := self.Vypis.PoradoveCislo;
  BStatement_Data.ValueByName('DocDate$DATE') := self.Vypis.Datum;
  BStatement_Data.ValueByName('CreatedAt$DATE') := IntToStr(Trunc(Date));
  try begin
      newID := BStatement_Object.CreateNewFromValues(BStatement_Data); //NewID je ID Abry v BANKSTATEMENTS
      Result := Result + ' Èíslo výpisu je ' + NewID;
    end;
  except on E: exception do
    begin
      Application.MessageBox(PChar('Problemmm ' + ^M + E.Message), 'AbraOLE');
    end;
  end;

  BStatement_Object:= AbraOLE.CreateObject('@BankStatement'); //mozna nemusi byt uz mame
  BStatement_Data:= AbraOLE.CreateValues('@BankStatement');
  BStatement_Data := BStatement_Object.GetValues(newID);

  BStatementRow_Object := AbraOLE.CreateObject('@BankStatementRow');
  BStatement_Data_Coll := BStatement_Data.Value[IndexByName(BStatement_Data, 'Rows')];




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
      //BStatementRow_Data.ValueByName('VarSymbol') := iPDPar.Platba.VS;
      //BStatementRow_Data.ValueByName('PAmount') := iPDPar.CastkaPouzita;
      BStatementRow_Data.ValueByName('PDocumentType') := iPDPar.Doklad.DocumentType;
      BStatementRow_Data.ValueByName('PDocument_ID') := iPDPar.Doklad.ID;
    end;


    for j := 0 to BStatementRow_Data.Count - 1 do begin
      mmm := mmm + inttostr(j) + 'r ' + BStatementRow_Data.Names[j] + ': ' + vartostr( BStatementRow_Data.Value[j]) + sLineBreak;
    end;
    //MessageDlg(mmm, mtInformation, [mbOk], 0);

    if iPDPar.Platba.Debet then
    begin
      BStatementRow_Data.ValueByName('VarSymbol') := iPDPar.Platba.VS; //pro debety aby vždy zùstal VS
    end;

    BStatement_Data_Coll.Add(BStatementRow_Data);
  end;

  try begin
      BStatement_Object.UpdateValues(newID, BStatement_Data);
      //MessageDlg('Updatnul jsem', mtInformation, [mbOk], 0);
    end;
  except on E: exception do
    begin
      MessageDlg('Problem - neupdatnul jsem', mtInformation, [mbOk], 0);
    end;
  end;

  {
  //opravit øádky v Abøe kde se nespárovalo
  for i := 0 to listPlatbaDokladPar.Count - 1 do
  try
    iPDPar := TPlatbaDokladPar(listPlatbaDokladPar[i]);
    if iPDPar.vazbaNaDoklad AND Assigned(iPDPar.Doklad) then
    begin
      opravRadekVypisuPomociPDocument_ID(AbraOLE, iPDPar.AbraBS2_ID, iPDPar.Doklad.ID, iPDPar.Doklad.ID);
      MessageDlg('Øádek ' + iPDPar.AbraBS2_ID + ' byl opraven', mtInformation, [mbOk], 0);
    end;
  except
    on E: Exception do
    MessageDlg('Oprava øádku ' + iPDPar.AbraBS2_ID + ' se nepovedla!', mtInformation, [mbOk], 0);
  end;
  }

end;

function TParovatko.zapisDoAbry() : string;
var
  i, j : integer;
  iPDPar : TPlatbaDokladPar;
  BStatement_Object,
  BStatement_Data,
  BStatementRow_Object,
  BStatementRow_Data,
  BStatement_Data_Coll,
  NewID : variant;
  mmm : ansistring;
begin

  if (listPlatbaDokladPar.Count = 0) then Exit;

  Result := 'Zápis do ABRY výpisu pro úèet ' + self.Vypis.abraBankaccount.name + '.';

  BStatement_Object:= AbraOLE.CreateObject('@BankStatement');
  BStatement_Data:= AbraOLE.CreateValues('@BankStatement');
  BStatement_Object.PrefillValues(BStatement_Data);
  BStatement_Data.ValueByName('DocQueue_ID') := self.Vypis.abraBankaccount.bankStatementDocqueueId;
  BStatement_Data.ValueByName('Period_ID') := '1L20000101'; //rok 2017, TODO automatika
  BStatement_Data.ValueByName('BankAccount_ID') := self.Vypis.abraBankaccount.id;
  BStatement_Data.ValueByName('ExternalNumber') := self.Vypis.PoradoveCislo;
  BStatement_Data.ValueByName('DocDate$DATE') := self.Vypis.Datum;
  BStatement_Data.ValueByName('CreatedAt$DATE') := IntToStr(Trunc(Date));

  BStatementRow_Object := AbraOLE.CreateObject('@BankStatementRow');
  BStatement_Data_Coll := BStatement_Data.Value[IndexByName(BStatement_Data, 'Rows')];

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
    else
      BStatementRow_Data.ValueByName('Firm_ID') := '3Y90000101';  // pokud není doklad, tak a je firma DES. jinak se tam dá jako default "drobný nákup"

    if iPDPar.vazbaNaDoklad AND Assigned(iPDPar.Doklad) then //Doklad vyplnime jen jestli chceme vazbu. Doklad máme i když vazbu nechceme - kvùli Firm_ID
    begin
      //BStatementRow_Data.ValueByName('VarSymbol') := iPDPar.Platba.VS;
      //BStatementRow_Data.ValueByName('PAmount') := iPDPar.CastkaPouzita;
      BStatementRow_Data.ValueByName('PDocumentType') := iPDPar.Doklad.DocumentType;
      BStatementRow_Data.ValueByName('PDocument_ID') := iPDPar.Doklad.ID;
    end;

    if iPDPar.Platba.Debet then
      BStatementRow_Data.ValueByName('VarSymbol') := iPDPar.Platba.VS; //pro debety aby vždy zùstal VS

    {
    mmm := 'ID nového øádku: ' + iPDPar.AbraBS2_ID + sLineBreak;
    for j := 0 to BStatementRow_Data.Count - 1 do begin
      mmm := mmm + inttostr(j) + 'r ' + BStatementRow_Data.Names[j] + ': ' + vartostr( BStatementRow_Data.Value[j]) + sLineBreak;
    end;
    MessageDlg(mmm, mtInformation, [mbOk], 0);
    }

    BStatement_Data_Coll.Add(BStatementRow_Data);
  end;

  try begin
    NewID := BStatement_Object.CreateNewFromValues(BStatement_Data); //NewID je ID Abry v BANKSTATEMENTS
    Result := Result + ' Èíslo výpisu je ' + NewID;
  end;
  except on E: exception do
    begin
      Application.MessageBox(PChar('Problemmm ' + ^M + E.Message), 'AbraOLE');
      Result := 'Chyba pøi zakládání výpisu';
    end;
  end;


  //opravit øádky v Abøe kde se nespárovalo
  {
  for i := 0 to listPlatbaDokladPar.Count - 1 do
  try
    iPDPar := TPlatbaDokladPar(listPlatbaDokladPar[i]);
    if iPDPar.vazbaNaDoklad AND Assigned(iPDPar.Doklad) then
    begin
      opravRadekVypisuPomociPDocument_ID(AbraOLE, iPDPar.AbraBS2_ID, iPDPar.Doklad.ID, iPDPar.Doklad.ID);
      MessageDlg('Øádek ' + iPDPar.AbraBS2_ID + ' byl opraven', mtInformation, [mbOk], 0);
    end;
  except
    on E: Exception do
    MessageDlg('Oprava øádku ' + iPDPar.AbraBS2_ID + ' se nepovedla!', mtInformation, [mbOk], 0);
  end;
  }

end;


procedure TParovatko.postOprava();
var
  i, j : integer;
  iPDPar : TPlatbaDokladPar;
  BStatement_Object,
  BStatement_Data,
  BStatementRow_Object,
  BStatementRow_Data,
  BStatement_Data_Coll,
  NewID : variant;
  mmm : ansistring;
begin
  //opravit øádky v Abøe kde se nespárovalo
  for i := 0 to listPlatbaDokladPar.Count - 1 do
  try
    iPDPar := TPlatbaDokladPar(listPlatbaDokladPar[i]);
    if iPDPar.vazbaNaDoklad AND Assigned(iPDPar.Doklad) then
    begin
      opravRadekVypisuPomociPDocument_ID(AbraOLE, '', iPDPar.Doklad.ID, iPDPar.Doklad.ID);
      //MessageDlg('Øádek ' + iPDPar.AbraBS2_ID + ' byl opraven', mtInformation, [mbOk], 0);
    end;
  except
    on E: Exception do
    //MessageDlg('Oprava øádku ' + iPDPar.AbraBS2_ID + ' se nepovedla!', mtInformation, [mbOk], 0);
  end;
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

function TParovatko.getPDParyPlatbyAsText(currPlatba : TPlatbaZVypisu) : AnsiString;
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


function TParovatko.getPDPar(currPlatba : TPlatbaZVypisu; currDoklad_ID: string) : TPlatbaDokladPar;
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
