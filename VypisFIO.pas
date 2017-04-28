unit VypisFIO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, IniFiles, Forms,
  Dialogs, StdCtrls, Grids, AdvObj, BaseGrid, AdvGrid, StrUtils, //DEShelpers
  DB, ComObj, AdvEdit, DateUtils, Math, ExtCtrls,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection,
  uTVypis, uTPlatbaZVypisu, uTParovatko, DesUtils;

type
  TForm1 = class(TForm)

    btnNacti: TButton;
    btnZapisDoAbry: TButton;
    editVstupniSoubor: TEdit;
    editVystupniSoubor: TEdit;
    Memo1: TMemo;
    asgMain: TAdvStringGrid;
    NactiGpcDialog: TOpenDialog;
    dbAbra: TZConnection;
    qrAbra: TZQuery;
    asgPredchoziPlatby: TAdvStringGrid;
    asgPredchoziPlatbyVs: TAdvStringGrid;
    asgNalezeneDoklady: TAdvStringGrid;
    labelNalezeneDoklady: TLabel;
    chbVsechnyDoklady: TCheckBox;
    btnSparujPlatby: TButton;
    editPocetPredchPlateb: TEdit;
    btnReconnect: TButton;
    Memo2: TMemo;
    Button2: TButton;
    chbZobrazitBezproblemove: TCheckBox;
    lblHlavicka: TLabel;
    chbZobrazitDebety: TCheckBox;

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

  public
    procedure vyplnPrichoziPlatby;
    procedure vyplnPredchoziPlatby;
    procedure vyplnDoklady;
    procedure sparujPrichoziPlatbu(i : integer);
    procedure sparujVsechnyPrichoziPlatby;
    procedure urciCurrPlatbaZVypisu();
    procedure filtrujZobrazeniPlateb;    
    procedure Zprava(TextZpravy : string);

  end;

var
  Form1 : TForm1;
  Vypis : TVypis;
  currPlatbaZVypisu : TPlatbaZVypisu;
  PROGRAM_PATH: string;
  AbraOLE: variant;
  Parovatko : TParovatko;

implementation

uses AbraEntities;

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
var
  FIIni: TIniFile;
begin
  PROGRAM_PATH := ExtractFilePath(ParamStr(0));

  if FileExists(ExtractFilePath(ParamStr(0)) + 'FI.ini') then begin         // existuje FI.ini ?
    FIIni := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'FI.ini');
    with FIIni do try
      dbAbra.HostName := ReadString('Preferences', 'AbraHN', '');
      dbAbra.Database := ReadString('Preferences', 'AbraDB', '');
      dbAbra.User := ReadString('Preferences', 'AbraUN', '');

      dbAbra.Password := ReadString('Preferences', 'AbraPW', '');
    finally
      FIIni.Free;
    end;
  end else begin
    Application.MessageBox('Neexistuje soubor FI.ini, program ukonèen', 'FI.ini', MB_OK + MB_ICONERROR);
    Application.Terminate;
  end;
  try
    dbAbra.Connect;
  except on E: exception do
    begin
      Application.MessageBox(PChar('Nedá se pøipojit k databázi Abry, program ukonèen.' + ^M + E.Message), 'Abra', MB_ICONERROR + MB_OK);
      Application.Terminate;
    end;
  end;
  asgMain.CheckFalse := '0';
  asgMain.CheckTrue := '1';


// pøipojení k Abøe
  if VarIsEmpty(AbraOLE) then try
    AbraOLE := CreateOLEObject('AbraOLE.Application');
    if not AbraOLE.Connect('@DES') then begin
      Zprava('Problém s Abrou (connect DES).');
      //Screen.Cursor := crDefault;
      Exit;
    end;
    Zprava('Pøipojeno k Abøe (connect DES).');
    if not AbraOLE.Login('Supervisor', '') then begin
      Zprava('Problém s Abrou (login Supervisor).');
      //Screen.Cursor := crDefault;
      Exit;
    end;
    Zprava('Pøihlášeno k Abøe (login Supervisor).');
  except on E: exception do
    begin
      Application.MessageBox(PChar('Problém s Abrou.' + ^M + E.Message), 'Abra', MB_ICONERROR + MB_OK);
      Zprava('Problém s Abrou - ' + E.Message);
      //btKonec.Caption := '&Konec';
      //Screen.Cursor := crDefault;
      Exit;
    end;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if assigned (Vypis.Platby) then
    Vypis.Platby.Free;
end;


procedure TForm1.btnNactiClick(Sender: TObject);
var
  GpcInputFile : TextFile;
  GpcFileLine : string;
  iPlatbaZVypisu : TPlatbaZVypisu;
  i, pocetPlatebGpc: integer;
begin
// *** naètení GPC na základì dialogu
  NactiGpcDialog.InitialDir := 'J:\Eurosignal\HB\';
  NactiGpcDialog.Filter := 'Bankovní výpisy (*.gpc)|*.gpc';
	if NactiGpcDialog.Execute then
  try
    Screen.Cursor := crHourGlass;
    asgMain.ClearNormalCells;   //clear ostatnich todo
    asgPredchoziPlatby.ClearNormalCells;
    asgPredchoziPlatbyVs.ClearNormalCells;
    asgNalezeneDoklady.ClearNormalCells;
    btnNacti.Enabled := false;
    Application.ProcessMessages;
    AssignFile(GpcInputFile, NactiGpcDialog.Filename);

  { // naètení GPC na základì dialogu
  NactiGpcDialog.InitialDir := ExtractFilePath(ParamStr(0));
  if NactiGpcDialog.Execute then
  begin
    AssignFile(GpcInputFile, NactiGpcDialog.Filename);
{
  // naètení GPC na základì vstupního pole
  if FileExists(PROGRAM_PATH  + 'HB\' +  EditVstupniSoubor.Text) then
  begin
    AssignFile(GpcInputFile, PROGRAM_PATH + 'HB\' + EditVstupniSoubor.Text);
}

    Reset(GpcInputFile);
    pocetPlatebGpc := pocetRadkuTxtSouboru(NactiGpcDialog.Filename) - 1;

    Vypis := nil;
    i := 0;
    while not Eof(GpcInputFile) do
    begin
      lblHlavicka.Caption := '... naèítání ' + IntToStr(i) + '. z ' + IntToStr(pocetPlatebGpc);
      Application.ProcessMessages;
      ReadLn(GpcInputFile, GpcFileLine);
      
      Inc(i);
      if i = 1 then //první øádek musí být hlavièka výpisu
      begin
        if copy(GpcFileLine, 1, 3) = '074' then
          Vypis := TVypis.Create(GpcFileLine, qrAbra)
        else
        begin
          MessageDlg('Neplatný GPC soubor, 1. øádek není hlavièka', mtInformation, [mbOk], 0);
          Break;
        end;
      end;

      if copy(GpcFileLine, 1, 3) = '075' then //radek vypisu zacina 075
      begin
        iPlatbaZVypisu := TPlatbaZVypisu.Create(GpcFileLine, qrAbra);
        iPlatbaZVypisu.init(StrToInt(editPocetPredchPlateb.text));
        Vypis.Platby.Add(iPlatbaZVypisu);
      end;

    end;

    if assigned(Vypis) then
      if (Vypis.Platby.Count > 0) then
      begin
        Vypis.init();
        currPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[0]);
        vyplnPrichoziPlatby;
        sparujVsechnyPrichoziPlatby;
      end;
  finally
    btnNacti.Enabled := true;
    btnZapisDoAbry.Enabled := true;
    CloseFile(GpcInputFile);
    Screen.Cursor := crDefault;
    lblHlavicka.Caption := Vypis.abraBankaccount.name + ', ' + Vypis.abraBankaccount.number + ', è.'
                    + IntToStr(Vypis.poradoveCislo) + ' (max è. je ' + IntToStr(Vypis.maxExistujiciPoradoveCislo) + '). Plateb: '
                    + IntToStr(Vypis.Platby.Count);
    if not Vypis.isNavazujeNaRadu() then
      Dialogs.MessageDlg('Doklad è. '+ IntToStr(Vypis.poradoveCislo) + ' nenavazuje na øadu!',mtInformation, [mbOK], 0);                   
  end;

  Memo1.Lines.Add('Vypis porad. cislo: ' + IntToStr(Vypis.PoradoveCislo)); //todo odstranit
  Memo1.Lines.Add(IntToStr(asgMain.row));

end;


procedure TForm1.vyplnPrichoziPlatby;
var
  i : integer;
  iPlatbaZVypisu : TPlatbaZVypisu;
begin

  with asgMain do
  begin
    ClearNormalCells;
    RowCount := Vypis.Platby.Count + 1;
    Row := 1;

    for i := 0 to Vypis.Platby.Count - 1 do
    begin
      iPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[i]);
      //AddCheckBox(0, i+1, True, True);
      if (iPlatbaZVypisu.kredit) then
        Cells[1, i+1] := format('%m', [iPlatbaZVypisu.castka])
      else
        Cells[1, i+1] := format('%m', [-iPlatbaZVypisu.castka]);
      if iPlatbaZVypisu.debet then asgMain.FontColors[1, i+1] := clRed;
      Cells[2, i+1] := iPlatbaZVypisu.VS;
      Cells[3, i+1] := iPlatbaZVypisu.SS;
      Cells[4, i+1] := iPlatbaZVypisu.cisloUctuBezNul;
      Cells[5, i+1] := iPlatbaZVypisu.nazevKlienta;
      Cells[6, i+1] := DateToStr(iPlatbaZVypisu.Datum);

    end;
  end;

  filtrujZobrazeniPlateb;

end;

procedure TForm1.filtrujZobrazeniPlateb;
var
  i : integer;
  iPlatbaZVypisu : TPlatbaZVypisu;
  zobrazitRadek : boolean;
begin

  for i := 0 to Vypis.Platby.Count - 1 do
  begin
    iPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[i]);
    zobrazitRadek := true;

    if not chbZobrazitBezproblemove.Checked AND (iPlatbaZVypisu.vysledekParovani = 1)
    AND (iPlatbaZVypisu.getPocetPredchozichPlatebNaStejnyVS() > 1) then
      zobrazitRadek := false;

    if not chbZobrazitDebety.Checked AND iPlatbaZVypisu.debet then
      zobrazitRadek := false;

    if zobrazitRadek then
      asgMain.RowHeights[i+1] := asgMain.DefaultRowHeight
    else
      asgMain.RowHeights[i+1] := 0;
  end;

end;

procedure TForm1.sparujPrichoziPlatbu(i : integer);
var
  iPlatbaZVypisu : TPlatbaZVypisu;
  VysledekParovani : integer;
begin
  iPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[i]);

  VysledekParovani := Parovatko.sparujPlatbu(iPlatbaZVypisu);

  case VysledekParovani of
    0: asgMain.Colors[2, i+1] := $AAAAFF;
    1: asgMain.Colors[2, i+1] := $AAFFAA;
    2: asgMain.Colors[2, i+1] := $FFAAAA;
  end;

  asgMain.Cells[7, i+1] := iPlatbaZVypisu.zprava;
  
end;

procedure TForm1.sparujVsechnyPrichoziPlatby;
var
  i : integer;
begin
  Parovatko := TParovatko.create(AbraOLE, Vypis);
  for i := 0 to Vypis.Platby.Count - 1 do
    sparujPrichoziPlatbu(i);
end;



procedure TForm1.vyplnPredchoziPlatby;
var
  i : integer;
  iPredchoziPlatba : TPredchoziPlatba;
begin

  with asgPredchoziPlatby do begin
    ClearNormalCells;
    if currPlatbaZVypisu.PredchoziPlatbyList.Count > 0 then
    begin
      RowCount := currPlatbaZVypisu.PredchoziPlatbyList.Count + 1;
      for i := 0 to RowCount - 2 do begin
        iPredchoziPlatba := TPredchoziPlatba(currPlatbaZVypisu.PredchoziPlatbyList[RowCount - 2 - i]);
        //Cells[0, i+1] := IntToStr(i+1);
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
    ClearNormalCells;
    if currPlatbaZVypisu.PredchoziPlatbyVsList.Count > 0 then
    begin
      RowCount := currPlatbaZVypisu.PredchoziPlatbyVsList.Count + 1;
      for i := 0 to RowCount - 2 do begin
        iPredchoziPlatba := TPredchoziPlatba(currPlatbaZVypisu.PredchoziPlatbyVsList[RowCount - 2 - i]);

        Cells[0, i+1] := iPredchoziPlatba.VS;
        Cells[1, i+1] := format('%m', [iPredchoziPlatba.Castka]);
        if iPredchoziPlatba.Castka < 0 then asgPredchoziPlatbyVs.FontColors[1, i+1] := clRed;
        Cells[2, i+1] := DateToStr(iPredchoziPlatba.Datum);
        Cells[3, i+1] := removeLeadingZeros(iPredchoziPlatba.cisloUctu);
        Cells[4, i+1] := iPredchoziPlatba.FirmName;
      end;
    end else
      RowCount := 2;
  end;
end;


procedure TForm1.vyplnDoklady;
var
  tempList : TList;
  iDoklad : TDoklad;
  iPDPar : TPlatbaDokladPar;
  i : integer;
begin

  currPlatbaZVypisu.loadDokladyPodleVS(not chbVsechnyDoklady.Checked);
  tempList := currPlatbaZVypisu.DokladyList;

  if chbVsechnyDoklady.Checked then
  begin
    labelNalezeneDoklady.Caption := 'Všechny doklady podle VS ' +  currPlatbaZVypisu.VS;
  end else
  begin
    labelNalezeneDoklady.Caption := 'Nezaplacené doklady podle VS ' +  currPlatbaZVypisu.VS;

  end;

  with asgNalezeneDoklady do begin
    ClearNormalCells;
    if tempList.Count > 0 then
    begin
      RowCount := tempList.Count + 1;
      for i := 0 to RowCount - 2 do begin
        iDoklad := TDoklad(tempList[i]);
        Cells[0, i+1] := iDoklad.CisloDokladu;
        Cells[1, i+1] := DateToStr(iDoklad.DatumDokladu);
        Cells[2, i+1] := iDoklad.FirmName;
        Cells[3, i+1] := format('%m', [iDoklad.Castka]);
        Cells[4, i+1] := format('%m', [iDoklad.CastkaZaplaceno]);
        Cells[5, i+1] := format('%m', [iDoklad.CastkaDobropisovano]);
        Cells[6, i+1] := format('%m', [iDoklad.CastkaNezaplaceno]);
        Cells[7, i+1] := iDoklad.ID;

        iPDPar := Parovatko.getPDPar(currPlatbaZVypisu, iDoklad.ID);
        if Assigned(iPDPar) then
          Cells[8, i+1] := iPDPar.Popis; // + floattostr(iPDPar.CastkaPouzita) ;
    end;
    end else
      RowCount := 2;
  end;
end;


procedure TForm1.urciCurrPlatbaZVypisu();
begin
  if assigned(Vypis) then
    if assigned(Vypis.Platby[asgMain.row - 1]) then
      currPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[asgMain.row - 1]);
end;


procedure TForm1.btnZapisDoAbryClick(Sender: TObject);
var
  OutputFile : TextFile;
  vysledek  : string;
  casStart, dobaZapisu: double;

begin

  if not Vypis.isNavazujeNaRadu() then
    if Dialogs.MessageDlg('Èíslo dokladu ' + IntToStr(Vypis.poradoveCislo)
        + ' nenavazuje na existující øadu. Opravdu zapsat do Abry?',
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
  Memo1.Lines.Add('Doba trvání: ' + floattostr(RoundTo(dobaZapisu, -2)) + ' s (' + floattostr(RoundTo(dobaZapisu / 60, -2)) + ' min)');

  AssignFile(OutputFile, PROGRAM_PATH + EditVystupniSoubor.Text);
  ReWrite(OutputFile);
  WriteLn(OutputFile, vysledek);
  CloseFile(OutputFile);

  dbAbra.Reconnect;
  MessageDlg('Zápis do Abry dokonèen', mtInformation, [mbOk], 0);

end;



{*** akce Input elementù ***}

procedure TForm1.asgMainClick(Sender: TObject);
begin
  urciCurrPlatbaZVypisu();
  vyplnPredchoziPlatby;
  vyplnDoklady;

  Memo2.Clear;
  Memo2.Lines.Add(Parovatko.getPDParyPlatbyAsText(currPlatbaZVypisu));
end;


procedure TForm1.asgMainCellsChanged(Sender: TObject; R: TRect);
begin
  if asgMain.col = 2 then //zmìna VS
  begin
     //asgMain.Colors[asgMain.col, asgMain.row] := clMoneyGreen;
     TPlatbaZVypisu(Vypis.Platby[asgMain.row - 1]).VS := asgMain.Cells[2, asgMain.row]; //do pøíslušného objektu platby zapíšu zmìnìný VS
     TPlatbaZVypisu(Vypis.Platby[asgMain.row - 1]).loadPredchoziPlatby(StrToInt(editPocetPredchPlateb.text)); //naèíst znova pøedchozí platby kvùli zmìnìnému VS (staèilo by jen pr.pl podle vs ale neni to rozdelene)

    vyplnPredchoziPlatby;
    vyplnDoklady;
    sparujVsechnyPrichoziPlatby;

  end;
  if asgMain.col = 5 then //zmìna textu (názvu klienta)
  begin
     //asgMain.Colors[asgMain.col, asgMain.row] := clMoneyGreen;
     TPlatbaZVypisu(Vypis.Platby[asgMain.row - 1]).nazevKlienta := asgMain.Cells[5, asgMain.row]; //do pøíslušného objektu platby zapíšu zmìnìný text
  end;
end;


procedure TForm1.chbVsechnyDokladyClick(Sender: TObject);
begin
  vyplnDoklady;
end;


procedure TForm1.btnSparujPlatbyClick(Sender: TObject);
begin
  sparujVsechnyPrichoziPlatby;
end;


procedure TForm1.Zprava(TextZpravy: string);
// do listboxu a logfile uloží èas a text zprávy
begin
  Memo1.Lines.Add(FormatDateTime('dd.mm.yy hh:nn  ', Now) + TextZpravy);
  {lbxLog.ItemIndex := lbxLog.Count - 1;
  Application.ProcessMessages;
  Append(F);
  Writeln (F, FormatDateTime('dd.mm.yy hh:nn  ', Now) + TextZpravy);
  CloseFile(F);  }
end;

procedure TForm1.asgMainGetAlignment(Sender: TObject; ARow, ACol: Integer;
  var HAlign: TAlignment; var VAlign: TVAlignment);
begin
  if (ARow = 0) then HAlign := taCenter
  else case ACol of
    0,6: HAlign := taCenter;
    1..4: HAlign := taRightJustify;
    //4: HAlign := taLeftJustify;
  end;
end;

procedure TForm1.asgNalezeneDokladyGetAlignment(Sender: TObject; ARow,
  ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
begin
  if (ARow = 0) then HAlign := taCenter
  else case ACol of
    //0,6: HAlign := taCenter;
    1,3..6: HAlign := taRightJustify;
    //4: HAlign := taLeftJustify;
  end;
end;

procedure TForm1.asgPredchoziPlatbyGetAlignment(Sender: TObject; ARow,
  ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
begin
  case ACol of
    1..3: HAlign := taRightJustify;
  end;
end;

procedure TForm1.asgPredchoziPlatbyVsGetAlignment(Sender: TObject; ARow,
  ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
begin
  case ACol of
    0..3: HAlign := taRightJustify;
  end;
end;

procedure TForm1.btnReconnectClick(Sender: TObject);
begin
    dbAbra.Reconnect;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  Memo2.Clear;
  Memo2.Lines.Add(Parovatko.getPDParyAsText());
end;

procedure TForm1.asgPredchoziPlatbyButtonClick(Sender: TObject; ACol,
  ARow: Integer);
begin
  urciCurrPlatbaZVypisu();
  currPlatbaZVypisu.VS := TPredchoziPlatba(currPlatbaZVypisu.PredchoziPlatbyList[currPlatbaZVypisu.PredchoziPlatbyList.Count - ARow]).VS;
  asgMain.Cells[2, asgMain.row] := currPlatbaZVypisu.VS;


  currPlatbaZVypisu.loadPredchoziPlatby(StrToInt(editPocetPredchPlateb.text));
  vyplnPredchoziPlatby;
  vyplnDoklady;
  sparujVsechnyPrichoziPlatby;
  //sparujPrichoziPlatbu(asgMain.row - 1);

  Memo2.Clear;
  Memo2.Lines.Add(Parovatko.getPDParyPlatbyAsText(currPlatbaZVypisu));
end;

procedure TForm1.chbZobrazitBezproblemoveClick(Sender: TObject);
begin
  filtrujZobrazeniPlateb;
end;

procedure TForm1.chbZobrazitDebetyClick(Sender: TObject);
begin
  filtrujZobrazeniPlateb;
end;

procedure TForm1.asgMainCanEditCell(Sender: TObject; ARow, ACol: Integer;
  var CanEdit: Boolean);
begin
  case ACol of
    1: CanEdit := false;
  end;
end;

procedure TForm1.asgMainKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //showmessage('Stisknuto: ' + IntToStr(Key));
  if Key = 27 then
  begin
    TPlatbaZVypisu(Vypis.Platby[asgMain.row - 1]).VS := TPlatbaZVypisu(Vypis.Platby[asgMain.row - 1]).VS_orig;
    asgMain.Cells[2, asgMain.row]  := TPlatbaZVypisu(Vypis.Platby[asgMain.row - 1]).VS;

    currPlatbaZVypisu.loadPredchoziPlatby(StrToInt(editPocetPredchPlateb.text));
    vyplnPredchoziPlatby;
    vyplnDoklady;
    sparujVsechnyPrichoziPlatby;
    //sparujPrichoziPlatbu(asgMain.row - 1);

    Memo2.Clear;
    Memo2.Lines.Add(Parovatko.getPDParyPlatbyAsText(currPlatbaZVypisu));
  end;
end;

end.
