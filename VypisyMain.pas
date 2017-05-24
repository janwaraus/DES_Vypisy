// do FI.ini p�idat ��dek 
// GpcPath = J:\Eurosignal\HB\

unit VypisyMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, IniFiles, Forms,
  Dialogs, StdCtrls, Grids, AdvObj, BaseGrid, AdvGrid, StrUtils, //DEShelpers
  DB, ComObj, AdvEdit, DateUtils, Math, ExtCtrls,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection,
  uTVypis, uTPlatbaZVypisu, uTParovatko;

type
  TfmMain = class(TForm)

    btnNacti: TButton;
    btnZapisDoAbry: TButton;
    editVstupniSoubor: TEdit;
    Memo1: TMemo;
    asgMain: TAdvStringGrid;
    NactiGpcDialog: TOpenDialog;
    dbAbra: TZConnection;
    qrAbra: TZQuery;
    asgPredchoziPlatby: TAdvStringGrid;
    asgPredchoziPlatbyVs: TAdvStringGrid;
    asgNalezeneDoklady: TAdvStringGrid;
    lblNalezeneDoklady: TLabel;
    chbVsechnyDoklady: TCheckBox;
    btnSparujPlatby: TButton;
    editPocetPredchPlateb: TEdit;
    btnReconnect: TButton;
    Button2: TButton;
    chbZobrazitBezproblemove: TCheckBox;
    lblHlavicka: TLabel;
    chbZobrazitDebety: TCheckBox;
    chbZobrazitStandardni: TCheckBox;
    lblPrechoziPlatbySVs: TLabel;
    lblPrechoziPlatbyZUctu: TLabel;
    Memo2: TMemo;
    btnShowPrirazeniPnpForm: TButton;
    btnVypisFio: TButton;
    lblVypisFioGpc: TLabel;
    lblVypisFioInfo: TLabel;
    btnVypisFioSporici: TButton;
    btnVypisCsob: TButton;
    btnVypisPayU: TButton;
    lblVypisFioSporiciGpc: TLabel;
    lblVypisFioSporiciInfo: TLabel;
    lblVypisCsobInfo: TLabel;
    lblVypisCsobGpc: TLabel;
    Button1: TButton;

    procedure btnNactiClick(Sender: TObject);
    procedure btnZapisDoAbryClick(Sender: TObject);
    procedure asgMainGetAlignment(Sender: TObject; ARow, ACol: Integer;
              var HAlign: TAlignment; var VAlign: TVAlignment);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure asgMainClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chbVsechnyDokladyClick(Sender: TObject);
    procedure btnSparujPlatbyClick(Sender: TObject);
    procedure asgMainCellsChanged(Sender: TObject; R: TRect);
    procedure asgNalezeneDokladyGetAlignment(Sender: TObject; ARow,
      ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
    procedure asgPredchoziPlatbyGetAlignment(Sender: TObject; ARow,
      ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
    procedure asgPredchoziPlatbyVsGetAlignment(Sender: TObject; ARow,
      ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
    procedure btnReconnectClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure asgPredchoziPlatbyButtonClick(Sender: TObject; ACol,
      ARow: Integer);
    procedure chbZobrazitBezproblemoveClick(Sender: TObject);
    procedure chbZobrazitDebetyClick(Sender: TObject);
    procedure asgMainCanEditCell(Sender: TObject; ARow, ACol: Integer;
      var CanEdit: Boolean);
    procedure asgMainKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure chbZobrazitStandardniClick(Sender: TObject);
    procedure asgMainGetEditorType(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TEditorType);
    procedure asgMainGetCellColor(Sender: TObject; ARow, ACol: Integer;
      AState: TGridDrawState; ABrush: TBrush; AFont: TFont);
    procedure btnShowPrirazeniPnpFormClick(Sender: TObject);
    procedure asgMainButtonClick(Sender: TObject; ACol, ARow: Integer);
    procedure btnVypisFioClick(Sender: TObject);
    procedure btnVypisFioSporiciClick(Sender: TObject);
    procedure btnVypisCsobClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  public
    procedure nactiGpc(GpcFilename : string);
    procedure vyplnNacitaciButtony;
    procedure vyplnPrichoziPlatby;
    procedure vyplnPredchoziPlatby;
    procedure vyplnDoklady;
    procedure vyplnVysledekParovaniPP(i : integer);
    procedure sparujPrichoziPlatbu(i : integer);
    procedure sparujVsechnyPrichoziPlatby;
    procedure urciCurrPlatbaZVypisu;
    procedure filtrujZobrazeniPlateb;
    procedure provedAkcePoZmeneVS;
    procedure Zprava(TextZpravy : string);

  end;

var
  fmMain : TfmMain;
  Vypis : TVypis;
  currPlatbaZVypisu : TPlatbaZVypisu;
  PROGRAM_PATH: string;
  GPC_PATH: string;
  AbraOLE: variant;
  Parovatko : TParovatko;

implementation

uses AbraEntities, DesUtils, PrirazeniPNP;

{$R *.dfm}

procedure TfmMain.FormShow(Sender: TObject);
var
  FIIni: TIniFile;
begin
  PROGRAM_PATH := ExtractFilePath(ParamStr(0));

  if FileExists(PROGRAM_PATH + 'FI.ini') then begin         // existuje FI.ini ?
    FIIni := TIniFile.Create(PROGRAM_PATH + 'FI.ini');
    with FIIni do try
      dbAbra.HostName := ReadString('Preferences', 'AbraHN', '');
      dbAbra.Database := ReadString('Preferences', 'AbraDB', '');
      dbAbra.User := ReadString('Preferences', 'AbraUN', '');
      dbAbra.Password := ReadString('Preferences', 'AbraPW', '');
      GPC_PATH := ReadString('Preferences', 'GpcPath', '');
    finally
      FIIni.Free;
    end;
  end else begin
    Application.MessageBox('Neexistuje soubor FI.ini, program ukon�en', 'FI.ini', MB_OK + MB_ICONERROR);
    Application.Terminate;
  end;
  try
    dbAbra.Connect;
  except on E: exception do
    begin
      Application.MessageBox(PChar('Ned� se p�ipojit k datab�zi Abry, program ukon�en.' + ^M + E.Message), 'Abra', MB_ICONERROR + MB_OK);
      Application.Terminate;
    end;
  end;
  asgMain.CheckFalse := '0';
  asgMain.CheckTrue := '1';


// p�ipojen� k Ab�e
  if VarIsEmpty(AbraOLE) then try
    AbraOLE := CreateOLEObject('AbraOLE.Application');
    if not AbraOLE.Connect('@DES') then begin
      Zprava('Probl�m s Abrou (connect DES).');
      //Screen.Cursor := crDefault;
      Exit;
    end;
    Zprava('P�ipojeno k Ab�e (connect DES).');
    if not AbraOLE.Login('Supervisor', '') then begin
      Zprava('Probl�m s Abrou (login Supervisor).');
      //Screen.Cursor := crDefault;
      Exit;
    end;
    Zprava('P�ihl�eno k Ab�e (login Supervisor).');
  except on E: exception do
    begin
      Application.MessageBox(PChar('Probl�m s Abrou.' + ^M + E.Message), 'Abra', MB_ICONERROR + MB_OK);
      Zprava('Probl�m s Abrou - ' + E.Message);
      //btKonec.Caption := '&Konec';
      //Screen.Cursor := crDefault;
      Exit;
    end;
  end;

  vyplnNacitaciButtony;

end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if assigned (Vypis) then
    if assigned (Vypis.Platby) then
      Vypis.Platby.Free;
end;

procedure TfmMain.vyplnNacitaciButtony;
var
  maxCisloVypisu : integer;
  fRok, nalezenyGpcSoubor, hledanyGpcSoubor : string;
  abraBankaccount : TAbraBankaccount;
begin
  fRok := IntToStr(SysUtils.CurrentYear);
  abraBankAccount := TAbraBankaccount.create(qrAbra);

  //Fio
  abraBankaccount.loadByNumber('2100098382/2010');
  maxCisloVypisu := abraBankaccount.getMaxPoradoveCisloVypisu(fRok);
  hledanyGpcSoubor := 'Vypis_z_uctu-2100098382_' + fRok + '*-' + IntToStr(maxCisloVypisu + 1) + '.gpc';
  nalezenyGpcSoubor := FindInFolder(GPC_PATH, hledanyGpcSoubor, true);

  Memo2.Lines.Add('Hled�m soubor ' + hledanyGpcSoubor);
  Memo2.Lines.Add('Na�el jsem ' + nalezenyGpcSoubor);

  if nalezenyGpcSoubor = '' then begin //nena�el se
    lblVypisFioGpc.caption := hledanyGpcSoubor + ' nenalezen';
    btnVypisFio.Enabled := false;
  end else begin
    lblVypisFioGpc.caption := nalezenyGpcSoubor;
  end;

  lblVypisFioInfo.Caption := format('Po�et v�pis�: %d, max. ��slo v�pisu: %d', [abraBankaccount.getPocetVypisu(fRok), abraBankaccount.getMaxPoradoveCisloVypisu(fRok)]);


  /// Fio Spo�ic�
  abraBankaccount.loadByNumber('2800098383/2010');
  maxCisloVypisu := abraBankaccount.getMaxPoradoveCisloVypisu(fRok);
  hledanyGpcSoubor := 'Vypis_z_uctu-2800098383_' + fRok + '*-' + IntToStr(maxCisloVypisu + 1) + '.gpc';
  nalezenyGpcSoubor := FindInFolder(GPC_PATH, hledanyGpcSoubor, true);

  Memo2.Lines.Add('Hled�m soubor ' + hledanyGpcSoubor);
  Memo2.Lines.Add('Na�el jsem ' + nalezenyGpcSoubor);

  if nalezenyGpcSoubor = '' then begin //nena�el se
    lblVypisFioSporiciGpc.caption := hledanyGpcSoubor + ' nenalezen';
    btnVypisFioSporici.Enabled := false;
  end else begin
    lblVypisFioSporiciGpc.caption := nalezenyGpcSoubor;
  end;

  lblVypisFioSporiciInfo.Caption := format('Po�et v�pis�: %d, max. ��slo v�pisu: %d', [abraBankaccount.getPocetVypisu(fRok), abraBankaccount.getMaxPoradoveCisloVypisu(fRok)]);


  /// �SOB Spo�ic�
  abraBankaccount.loadByNumber('171336270/0300');
  maxCisloVypisu := abraBankaccount.getMaxPoradoveCisloVypisu(fRok);
  hledanyGpcSoubor := 'BB117641_171336270_' + fRok + '*_' + IntToStr(maxCisloVypisu + 1) + '.gpc';
  nalezenyGpcSoubor := FindInFolder(GPC_PATH, hledanyGpcSoubor, true);

  Memo2.Lines.Add('Hled�m soubor ' + hledanyGpcSoubor);
  Memo2.Lines.Add('Na�el jsem ' + nalezenyGpcSoubor);

  if nalezenyGpcSoubor = '' then begin //nena�el se
    lblVypisCsobGpc.caption := hledanyGpcSoubor + ' nenalezen';
    btnVypisCsob.Enabled := false;
  end else begin
    lblVypisCsobGpc.caption := nalezenyGpcSoubor;
  end;

  lblVypisCsobInfo.Caption := format('Po�et v�pis�: %d, max. ��slo v�pisu: %d', [abraBankaccount.getPocetVypisu(fRok), abraBankaccount.getMaxPoradoveCisloVypisu(fRok)]);

  //Pay U   2389210008000000/0300
end;

procedure TfmMain.nactiGpc(GpcFilename : string);
var
  GpcInputFile : TextFile;
  GpcFileLine : string;
  iPlatbaZVypisu : TPlatbaZVypisu;
  i, pocetPlatebGpc: integer;
begin
  try
    AssignFile(GpcInputFile, GpcFilename);
    Reset(GpcInputFile);

    Screen.Cursor := crHourGlass;
    asgMain.Visible := true;
    asgMain.ClearNormalCells;
    asgPredchoziPlatby.ClearNormalCells;
    asgPredchoziPlatbyVs.ClearNormalCells;
    asgNalezeneDoklady.ClearNormalCells;
    btnNacti.Enabled := false;
    Application.ProcessMessages;

    pocetPlatebGpc := 0;
    while not Eof(GpcInputFile) do
    begin
      ReadLn(GpcInputFile, GpcFileLine);
      if copy(GpcFileLine, 1, 3) = '075' then
        Inc(pocetPlatebGpc);
    end;
    CloseFile(GpcInputFile);


    //pocetPlatebGpc := pocetRadkuTxtSouboru(NactiGpcDialog.Filename) - 1;

    Reset(GpcInputFile);
    Vypis := nil;
    i := 0;
    while not Eof(GpcInputFile) do
    begin
      lblHlavicka.Caption := '... na��t�n� ' + IntToStr(i) + '. z ' + IntToStr(pocetPlatebGpc);
      Application.ProcessMessages;
      ReadLn(GpcInputFile, GpcFileLine);

      if i = 0 then //prvn� ��dek mus� b�t hlavi�ka v�pisu
      begin
        Inc(i);
        if copy(GpcFileLine, 1, 3) = '074' then begin
          Vypis := TVypis.Create(GpcFileLine, qrAbra);
          Parovatko := TParovatko.create(Vypis, AbraOLE, qrAbra);
        end else begin
          MessageDlg('Neplatn� GPC soubor, 1. ��dek nen� hlavi�ka', mtInformation, [mbOk], 0);
          Break;
        end;
      end;

      if copy(GpcFileLine, 1, 3) = '075' then //radek vypisu zacina 075
      begin
        Inc(i);
        iPlatbaZVypisu := TPlatbaZVypisu.Create(GpcFileLine, qrAbra);
        iPlatbaZVypisu.init(StrToInt(editPocetPredchPlateb.text));
        Parovatko.sparujPlatbu(iPlatbaZVypisu);
        iPlatbaZVypisu.automatickyOpravVS();
        Vypis.Platby.Add(iPlatbaZVypisu);
      end;

    end;

    if assigned(Vypis) then
      if (Vypis.Platby.Count > 0) then
      begin
        Vypis.init();
        Vypis.setridit();
        sparujVsechnyPrichoziPlatby;
        vyplnPrichoziPlatby;
        filtrujZobrazeniPlateb;
        lblHlavicka.Caption := Vypis.abraBankaccount.name + ', ' + Vypis.abraBankaccount.number + ', �.'
                        + IntToStr(Vypis.poradoveCislo) + ' (max �. je ' + IntToStr(Vypis.maxExistujiciPoradoveCislo) + '). Plateb: '
                        + IntToStr(Vypis.Platby.Count);
        if not Vypis.isNavazujeNaRadu() then
          Dialogs.MessageDlg('Doklad �. '+ IntToStr(Vypis.poradoveCislo) + ' nenavazuje na �adu!', mtInformation, [mbOK], 0);
        //currPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[0]); //m��e b�t ale nem�lo by b�t pot�eba
        asgMainClick(nil);
      end;
  finally
    btnNacti.Enabled := true;
    btnZapisDoAbry.Enabled := true;
    CloseFile(GpcInputFile);
    Screen.Cursor := crDefault;

  end;

end;


procedure TfmMain.vyplnPrichoziPlatby;
var
  i : integer;
  iPlatbaZVypisu : TPlatbaZVypisu;
begin

  with asgMain do
  begin
    Enabled := true;
    ControlLook.NoDisabledButtonLook := true;
    ClearNormalCells;
    RowCount := Vypis.Platby.Count + 1;
    Row := 1;

    for i := 0 to Vypis.Platby.Count - 1 do
    begin
      RemoveButton(0, i+1);
      iPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[i]);
      //AddCheckBox(0, i+1, True, True);
      if iPlatbaZVypisu.VS <> iPlatbaZVypisu.VS_orig then
        AddButton(0, i+1, 76, 16, iPlatbaZVypisu.VS_orig, haCenter, vaCenter);
      if (iPlatbaZVypisu.kredit) then
        Cells[1, i+1] := format('%m', [iPlatbaZVypisu.castka])
      else
        Cells[1, i+1] := format('%m', [-iPlatbaZVypisu.castka]);
      if iPlatbaZVypisu.debet then asgMain.FontColors[1, i+1] := clRed;
      Cells[2, i+1] := iPlatbaZVypisu.VS;
      Cells[3, i+1] := iPlatbaZVypisu.SS;
      Cells[4, i+1] := iPlatbaZVypisu.cisloUctuKZobrazeni;
      //Cells[5, i+1] := Format('%8.2f', [iPlatbaZVypisu.getProcentoPredchozichPlatebNaStejnyVS]) + Format('%8.2f', [iPlatbaZVypisu.getProcentoPredchozichPlatebZeStejnehoUctu]) + iPlatbaZVypisu.nazevKlienta;
      Cells[5, i+1] := iPlatbaZVypisu.nazevKlienta;
      Cells[6, i+1] := DateToStr(iPlatbaZVypisu.Datum);

      vyplnVysledekParovaniPP(i);

    end;
  end;

end;

procedure TfmMain.vyplnVysledekParovaniPP(i : integer);
var
  iPlatbaZVypisu : TPlatbaZVypisu;
begin
  iPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[i]);

  case iPlatbaZVypisu.problemLevel of
    0: asgMain.Colors[2, i+1] := $AAFFAA;
    1: asgMain.Colors[2, i+1] := $CDFAFF;
    2: asgMain.Colors[2, i+1] := $60A4F4;
    5: asgMain.Colors[2, i+1] := $BBBBFF;
  end;

  if iPlatbaZVypisu.rozdeleniPlatby > 0 then
    asgMain.Cells[7, i+1] := IntToStr (iPlatbaZVypisu.rozdeleniPlatby) + ' d�len�, ' + iPlatbaZVypisu.zprava
  else
    asgMain.Cells[7, i+1] := iPlatbaZVypisu.zprava;
end;

procedure TfmMain.filtrujZobrazeniPlateb;
var
  i : integer;
  iPlatbaZVypisu : TPlatbaZVypisu;
  zobrazitRadek : boolean;
begin

  for i := 0 to Vypis.Platby.Count - 1 do
  begin
    iPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[i]);
    zobrazitRadek := false;

    if iPlatbaZVypisu.problemLevel > 1 then
      zobrazitRadek := true;

    if chbZobrazitBezproblemove.Checked AND (iPlatbaZVypisu.problemLevel = 0) then
      zobrazitRadek := true;

    if chbZobrazitStandardni.Checked AND (iPlatbaZVypisu.problemLevel = 1) then
      zobrazitRadek := true;

    if iPlatbaZVypisu.debet then
      if chbZobrazitDebety.Checked then
        zobrazitRadek := true
      else
        zobrazitRadek := false;

    if zobrazitRadek then
      asgMain.RowHeights[i+1] := asgMain.DefaultRowHeight
    else
      asgMain.RowHeights[i+1] := 0;
  end;
end;


procedure TfmMain.sparujVsechnyPrichoziPlatby;
var
  i : integer;
begin
  Parovatko := TParovatko.create(Vypis, AbraOLE, qrAbra);
  for i := 0 to Vypis.Platby.Count - 1 do
    sparujPrichoziPlatbu(i);
end;


procedure TfmMain.sparujPrichoziPlatbu(i : integer);
var
  iPlatbaZVypisu : TPlatbaZVypisu;
begin
  iPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[i]);
  Parovatko.sparujPlatbu(iPlatbaZVypisu);
  vyplnVysledekParovaniPP(i);
end;


procedure TfmMain.vyplnPredchoziPlatby;
var
  i : integer;
  iPredchoziPlatba : TPredchoziPlatba;
begin

  with asgPredchoziPlatby do begin
    Enabled := true;
    ClearNormalCells;
    lblPrechoziPlatbyZUctu.Caption := 'P�edchoz� platby z ��tu '
        + currPlatbaZVypisu.cisloUctuKZobrazeni;
    if currPlatbaZVypisu.PredchoziPlatbyList.Count > 0 then
    begin
      RowCount := currPlatbaZVypisu.PredchoziPlatbyList.Count + 1;
      for i := 0 to RowCount - 2 do begin
        iPredchoziPlatba := TPredchoziPlatba(currPlatbaZVypisu.PredchoziPlatbyList[i]);
        if iPredchoziPlatba.VS <> currPlatbaZVypisu.VS then
          AddButton(0,i+1,25,18,'<--',haCenter,vaCenter);
        Cells[1, i+1] := iPredchoziPlatba.VS;
        Cells[2, i+1] := format('%m', [iPredchoziPlatba.Castka]);
        if iPredchoziPlatba.Castka < 0 then asgPredchoziPlatby.FontColors[2, i+1] := clRed;
        Cells[3, i+1] := DateToStr(iPredchoziPlatba.Datum);
        Cells[4, i+1] := iPredchoziPlatba.FirmName;
      end;
    end else
       RowCount := 2;
  end;

  with asgPredchoziPlatbyVs do begin
    Enabled := true;
    ClearNormalCells;
    lblPrechoziPlatbySVs.Caption := 'P�edchoz� platby s VS ' + currPlatbaZVypisu.VS;
    if currPlatbaZVypisu.PredchoziPlatbyVsList.Count > 0 then
    begin
      RowCount := currPlatbaZVypisu.PredchoziPlatbyVsList.Count + 1;
      for i := 0 to RowCount - 2 do begin
        iPredchoziPlatba := TPredchoziPlatba(currPlatbaZVypisu.PredchoziPlatbyVsList[i]);

        Cells[0, i+1] := iPredchoziPlatba.cisloUctuKZobrazeni;
        Cells[1, i+1] := format('%m', [iPredchoziPlatba.Castka]);
        if iPredchoziPlatba.Castka < 0 then asgPredchoziPlatbyVs.FontColors[1, i+1] := clRed;
        Cells[2, i+1] := DateToStr(iPredchoziPlatba.Datum);
        Cells[3, i+1] := iPredchoziPlatba.FirmName;
      end;
    end else
      RowCount := 2;
  end;
end;


procedure TfmMain.vyplnDoklady;
var
  iDoklad : TDoklad;
  iPDPar : TPlatbaDokladPar;
  i : integer;
begin

  //currPlatbaZVypisu.loadDokladyPodleVS(); //bylo v minulosti

  with asgNalezeneDoklady do begin
    Enabled := true;
    ClearNormalCells;
    if currPlatbaZVypisu.DokladyList.Count > 0 then
    begin
      RowCount := currPlatbaZVypisu.DokladyList.Count + 1;
      for i := 0 to RowCount - 2 do begin
        iDoklad := TDoklad(currPlatbaZVypisu.DokladyList[i]);
        Cells[0, i+1] := iDoklad.CisloDokladu;
        Cells[1, i+1] := DateToStr(iDoklad.DatumDokladu);
        Cells[2, i+1] := iDoklad.FirmName;
        Cells[3, i+1] := format('%m', [iDoklad.Castka]);
        Cells[4, i+1] := format('%m', [iDoklad.CastkaZaplaceno]);
        Cells[5, i+1] := format('%m', [iDoklad.CastkaDobropisovano]);
        Cells[6, i+1] := format('%m', [iDoklad.CastkaNezaplaceno]);
        Cells[7, i+1] := iDoklad.ID;

        iPDPar := Parovatko.getPDPar(currPlatbaZVypisu, iDoklad.ID);
        if Assigned(iPDPar) then begin
          Cells[8, i+1] := iPDPar.Popis; // + floattostr(iPDPar.CastkaPouzita);
          if iPDPar.CastkaPouzita = iDoklad.CastkaNezaplaceno then
            Colors[6, i+1] := $AAFFAA
          else
            Colors[6, i+1] := $CDFAFF;
        end;

        if iDoklad.CastkaNezaplaceno = 0 then Colors[6, i+1] := $BBBBFF;
      end;

      chbVsechnyDoklady.Checked := currPlatbaZVypisu.vsechnyDoklady;
      if chbVsechnyDoklady.Checked then
        lblNalezeneDoklady.Caption := 'Doklady s VS ' +  currPlatbaZVypisu.VS
      else
        lblNalezeneDoklady.Caption := 'Doklady s VS ' +  currPlatbaZVypisu.VS;

    end else begin
      RowCount := 2;
      lblNalezeneDoklady.Caption := '��dn� vystaven� doklady s VS ' +  currPlatbaZVypisu.VS;
    end;
  end;
end;


procedure TfmMain.urciCurrPlatbaZVypisu();
begin
  if assigned(Vypis) then
    if assigned(Vypis.Platby[asgMain.row - 1]) then
      currPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[asgMain.row - 1]);
end;


procedure TfmMain.btnZapisDoAbryClick(Sender: TObject);
var
  OutputFile : TextFile;
  vysledek  : string;
  casStart, dobaZapisu: double;

begin

  if not Vypis.isNavazujeNaRadu() then
    if Dialogs.MessageDlg('��slo dokladu ' + IntToStr(Vypis.poradoveCislo)
        + ' nenavazuje na existuj�c� �adu. Opravdu zapsat do Abry?',
        mtConfirmation, [mbYes, mbNo], 0 ) = mrNo then Exit;

  Screen.Cursor := crHourGlass;
  btnZapisDoAbry.Enabled := False;
  casStart := Now;
  try
    sparujVsechnyPrichoziPlatby;
    vysledek := Parovatko.zapisDoAbry();
  finally
    Screen.Cursor := crDefault;
  end;

  Memo1.Lines.Add(vysledek);
  dobaZapisu := (Now - casStart) * 24 * 3600;
  Memo1.Lines.Add('Doba trv�n�: ' + floattostr(RoundTo(dobaZapisu, -2))
              + ' s (' + floattostr(RoundTo(dobaZapisu / 60, -2)) + ' min)');
  {
  AssignFile(OutputFile, PROGRAM_PATH + EditVystupniSoubor.Text);
  ReWrite(OutputFile);
  WriteLn(OutputFile, vysledek);
  CloseFile(OutputFile);
  }
  dbAbra.Reconnect;
  MessageDlg('Z�pis do Abry dokon�en', mtInformation, [mbOk], 0);

end;


procedure TfmMain.provedAkcePoZmeneVS;
begin
  asgMain.Cells[2, asgMain.row] := currPlatbaZVypisu.VS;
  asgMain.RemoveButton(0, asgMain.row);

  if currPlatbaZVypisu.VS <> currPlatbaZVypisu.VS_orig then
    asgMain.AddButton(0, asgMain.row, 76, 16, currPlatbaZVypisu.VS_orig, haCenter, vaCenter);

  currPlatbaZVypisu.loadPredchoziPlatbyPodleVS(StrToInt(editPocetPredchPlateb.text));
  vyplnPredchoziPlatby;
  currPlatbaZVypisu.loadDokladyPodleVS();
  vyplnDoklady;
  sparujVsechnyPrichoziPlatby;
  //sparujPrichoziPlatbu(asgMain.row - 1);
  Memo2.Clear;
  Memo2.Lines.Add(Parovatko.getPDParyPlatbyAsText(currPlatbaZVypisu));
end;



{*********************** akce Input element� **********************************}

procedure TfmMain.asgMainClick(Sender: TObject);
begin
  urciCurrPlatbaZVypisu();
  vyplnPredchoziPlatby;
  vyplnDoklady;

  Memo2.Clear;
  Memo2.Lines.Add(Parovatko.getPDParyPlatbyAsText(currPlatbaZVypisu));
end;


procedure TfmMain.asgMainCellsChanged(Sender: TObject; R: TRect);
begin
  if asgMain.col = 2 then //zm�na VS
  begin
     //asgMain.Colors[asgMain.col, asgMain.row] := clMoneyGreen;
     currPlatbaZVypisu.VS := asgMain.Cells[2, asgMain.row]; //do p��slu�n�ho objektu platby zap�u zm�n�n� VS
     provedAkcePoZmeneVS;
  end;
  if asgMain.col = 5 then //zm�na textu (n�zvu klienta)
  begin
     //asgMain.Colors[asgMain.col, asgMain.row] := clMoneyGreen;
     currPlatbaZVypisu.nazevKlienta := asgMain.Cells[5, asgMain.row]; //do p��slu�n�ho objektu platby zap�u zm�n�n� text
  end;
end;

procedure TfmMain.asgPredchoziPlatbyButtonClick(Sender: TObject; ACol,
  ARow: Integer);
begin
  urciCurrPlatbaZVypisu();
  currPlatbaZVypisu.VS := TPredchoziPlatba(currPlatbaZVypisu.PredchoziPlatbyList[ARow - 1]).VS;
  provedAkcePoZmeneVS;
end;

procedure TfmMain.asgMainKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //showmessage('Stisknuto: ' + IntToStr(Key));
  if Key = 27 then
  begin
    currPlatbaZVypisu.VS := currPlatbaZVypisu.VS_orig;
    provedAkcePoZmeneVS;
  end;
end;


procedure TfmMain.chbVsechnyDokladyClick(Sender: TObject);
begin
  currPlatbaZVypisu.vsechnyDoklady := chbVsechnyDoklady.Checked;
  currPlatbaZVypisu.loadDokladyPodleVS();
  vyplnDoklady;
end;


procedure TfmMain.btnSparujPlatbyClick(Sender: TObject);
begin
  sparujVsechnyPrichoziPlatby;
end;


procedure TfmMain.Zprava(TextZpravy: string);
// do listboxu a logfile ulo�� �as a text zpr�vy
begin
  Memo1.Lines.Add(FormatDateTime('dd.mm.yy hh:nn  ', Now) + TextZpravy);
  {lbxLog.ItemIndex := lbxLog.Count - 1;
  Application.ProcessMessages;
  Append(F);
  Writeln (F, FormatDateTime('dd.mm.yy hh:nn  ', Now) + TextZpravy);
  CloseFile(F);  }
end;

procedure TfmMain.asgMainGetAlignment(Sender: TObject; ARow, ACol: Integer;
  var HAlign: TAlignment; var VAlign: TVAlignment);
begin
  if (ARow = 0) then HAlign := taCenter
  else case ACol of
    0,6: HAlign := taCenter;
    1..4: HAlign := taRightJustify;
    //4: HAlign := taLeftJustify;
  end;
end;

procedure TfmMain.asgNalezeneDokladyGetAlignment(Sender: TObject; ARow,
  ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
begin
  if (ARow = 0) then HAlign := taCenter
  else case ACol of
    //0,6: HAlign := taCenter;
    1,3..6: HAlign := taRightJustify;
    //4: HAlign := taLeftJustify;
  end;
end;

procedure TfmMain.asgPredchoziPlatbyGetAlignment(Sender: TObject; ARow,
  ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
begin
  case ACol of
    1..3: HAlign := taRightJustify;
  end;
end;

procedure TfmMain.asgPredchoziPlatbyVsGetAlignment(Sender: TObject; ARow,
  ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
begin
  case ACol of
    0..2: HAlign := taRightJustify;
  end;
end;

procedure TfmMain.btnReconnectClick(Sender: TObject);
begin
    dbAbra.Reconnect;
end;


procedure TfmMain.Button2Click(Sender: TObject);
begin
  Memo2.Clear;
  Memo2.Lines.Add(Parovatko.getPDParyAsText());
end;


procedure TfmMain.chbZobrazitBezproblemoveClick(Sender: TObject);
begin
  filtrujZobrazeniPlateb;
end;

procedure TfmMain.chbZobrazitDebetyClick(Sender: TObject);
begin
  filtrujZobrazeniPlateb;
end;

procedure TfmMain.chbZobrazitStandardniClick(Sender: TObject);
begin
  filtrujZobrazeniPlateb;
end;

procedure TfmMain.asgMainCanEditCell(Sender: TObject; ARow, ACol: Integer;
  var CanEdit: Boolean);
begin
  case ACol of
    0..1: CanEdit := false;
  end;
end;


procedure TfmMain.asgMainGetEditorType(Sender: TObject; ACol,
  ARow: Integer; var AEditor: TEditorType);
begin
{
  case ACol of
    1..2: AEditor := edRichEdit;
  end;
}
end;

procedure TfmMain.asgMainGetCellColor(Sender: TObject; ARow, ACol: Integer;
  AState: TGridDrawState; ABrush: TBrush; AFont: TFont);
begin
  if (ARow > 0) then
  case ACol of
    1..2: AFont.Style := [];
  end;
end;




procedure TfmMain.btnShowPrirazeniPnpFormClick(Sender: TObject);
begin
  fmPrirazeniPnp.Show;
  {
  with fmPrirazeniPnp.Create(self) do
  try
    ShowModal;
  finally
    Free;
  end;
  }
end;

procedure TfmMain.asgMainButtonClick(Sender: TObject; ACol, ARow: Integer);
begin
  asgMain.row := ARow;
  urciCurrPlatbaZVypisu();
  currPlatbaZVypisu.VS := currPlatbaZVypisu.VS_orig;
  provedAkcePoZmeneVS;
end;

procedure TfmMain.btnNactiClick(Sender: TObject);
begin
  // *** na�ten� GPC na z�klad� dialogu
  NactiGpcDialog.InitialDir := 'J:\Eurosignal\HB\';
  NactiGpcDialog.Filter := 'Bankovn� v�pisy (*.gpc)|*.gpc';
	if NactiGpcDialog.Execute then
    nactiGpc(NactiGpcDialog.Filename);
end;

procedure TfmMain.btnVypisFioClick(Sender: TObject);
begin
  nactiGpc(lblVypisFioGpc.caption);
end;

procedure TfmMain.btnVypisFioSporiciClick(Sender: TObject);
begin
  nactiGpc(lblVypisFioSporiciGpc.caption);
end;

procedure TfmMain.btnVypisCsobClick(Sender: TObject);
begin
  nactiGpc(lblVypisCsobGpc.caption);
end;

procedure TfmMain.Button1Click(Sender: TObject);
begin
  asgMain.Visible := false;
  asgMain.ClearNormalCells;
  asgPredchoziPlatby.ClearNormalCells;
  asgPredchoziPlatbyVs.ClearNormalCells;
  asgNalezeneDoklady.ClearNormalCells;
  lblHlavicka.Caption := '';
end;

end.
