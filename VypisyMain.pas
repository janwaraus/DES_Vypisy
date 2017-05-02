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
    btnBold: TButton;
    Memo2: TMemo;
    btnNactiRadekVypisu: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    btnShowPrirazeniPnpForm: TButton;

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
    procedure btnNactiRadekVypisuClick(Sender: TObject);
    procedure btnShowPrirazeniPnpFormClick(Sender: TObject);

  public
    procedure vyplnPrichoziPlatby;
    procedure vyplnPredchoziPlatby;
    procedure vyplnDoklady;
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

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if assigned (Vypis) then
    if assigned (Vypis.Platby) then
      Vypis.Platby.Free;
end;


procedure TfmMain.btnNactiClick(Sender: TObject);
var
  GpcInputFile : TextFile;
  GpcFileLine : string;
  iPlatbaZVypisu : TPlatbaZVypisu;
  i, pocetPlatebGpc: integer;
begin
// *** naètení GPC na základì dialogu
  //NactiGpcDialog.InitialDir := 'J:\Eurosignal\HB\';
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
        sparujVsechnyPrichoziPlatby;
        Vypis.setridit();
        vyplnPrichoziPlatby;
        filtrujZobrazeniPlateb;
        lblHlavicka.Caption := Vypis.abraBankaccount.name + ', ' + Vypis.abraBankaccount.number + ', è.'
                        + IntToStr(Vypis.poradoveCislo) + ' (max è. je ' + IntToStr(Vypis.maxExistujiciPoradoveCislo) + '). Plateb: '
                        + IntToStr(Vypis.Platby.Count);
        if not Vypis.isNavazujeNaRadu() then
          Dialogs.MessageDlg('Doklad è. '+ IntToStr(Vypis.poradoveCislo) + ' nenavazuje na øadu!',mtInformation, [mbOK], 0);

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
      Cells[4, i+1] := iPlatbaZVypisu.cisloUctuKZobrazeni;
      //Cells[5, i+1] := Format('%8.2f', [iPlatbaZVypisu.getProcentoPredchozichPlatebNaStejnyVS]) + Format('%8.2f', [iPlatbaZVypisu.getProcentoPredchozichPlatebZeStejnehoUctu]) + iPlatbaZVypisu.nazevKlienta;
      Cells[5, i+1] := iPlatbaZVypisu.nazevKlienta;
      Cells[6, i+1] := DateToStr(iPlatbaZVypisu.Datum);

      if iPlatbaZVypisu.rozdeleniPlatby > 0 then
        asgMain.Cells[7, i+1] := IntToStr (iPlatbaZVypisu.rozdeleniPlatby) + ' dìlení, ' + iPlatbaZVypisu.zprava
      else
        asgMain.Cells[7, i+1] := iPlatbaZVypisu.zprava;

      case iPlatbaZVypisu.problemLevel of
        0: asgMain.Colors[2, i+1] := $AAFFAA;
        1: asgMain.Colors[2, i+1] := $cdfaff;
        2: asgMain.Colors[2, i+1] := $bbbbff;
      end;
      

    end;
  end;

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

procedure TfmMain.sparujPrichoziPlatbu(i : integer);
var
  iPlatbaZVypisu : TPlatbaZVypisu;
begin
  iPlatbaZVypisu := TPlatbaZVypisu(Vypis.Platby[i]);

  Parovatko.sparujPlatbu(iPlatbaZVypisu);

  case iPlatbaZVypisu.problemLevel of
    0: asgMain.Colors[2, i+1] := $AAFFAA;
    1: asgMain.Colors[2, i+1] := $cdfaff;
    2: asgMain.Colors[2, i+1] := $bbbbff;
  end;

  if iPlatbaZVypisu.rozdeleniPlatby > 0 then
    asgMain.Cells[7, i+1] := IntToStr (iPlatbaZVypisu.rozdeleniPlatby) + ' dìlení, ' + iPlatbaZVypisu.zprava
  else
    asgMain.Cells[7, i+1] := iPlatbaZVypisu.zprava;
  
end;

procedure TfmMain.sparujVsechnyPrichoziPlatby;
var
  i : integer;
begin
  Parovatko := TParovatko.create(AbraOLE, Vypis);
  for i := 0 to Vypis.Platby.Count - 1 do
    sparujPrichoziPlatbu(i);
end;



procedure TfmMain.vyplnPredchoziPlatby;
var
  i : integer;
  iPredchoziPlatba : TPredchoziPlatba;
begin
  //lblPrechoziPlatbySVs.Font.Style := [fsBold];

  with asgPredchoziPlatby do begin
    Enabled := true;
    ClearNormalCells;
    if currPlatbaZVypisu.PredchoziPlatbyList.Count > 0 then
    begin
      lblPrechoziPlatbyZUctu.Caption := 'Pøechozí platby z úètu '
        + currPlatbaZVypisu.cisloUctuKZobrazeni;

      RowCount := currPlatbaZVypisu.PredchoziPlatbyList.Count + 1;
      for i := 0 to RowCount - 2 do begin
        iPredchoziPlatba := TPredchoziPlatba(currPlatbaZVypisu.PredchoziPlatbyList[i]);

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
    if currPlatbaZVypisu.PredchoziPlatbyVsList.Count > 0 then
    begin
      lblPrechoziPlatbySVs.Caption := 'Pøechozí platby s VS ' + currPlatbaZVypisu.VS;

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
  tempList : TList;
  iDoklad : TDoklad;
  iPDPar : TPlatbaDokladPar;
  i : integer;
begin

  currPlatbaZVypisu.loadDokladyPodleVS(not chbVsechnyDoklady.Checked);
  tempList := currPlatbaZVypisu.DokladyList;

  if chbVsechnyDoklady.Checked then
    lblNalezeneDoklady.Caption := 'Všechny doklady podle VS ' +  currPlatbaZVypisu.VS
  else
    lblNalezeneDoklady.Caption := 'Nezaplacené doklady podle VS ' +  currPlatbaZVypisu.VS;

  with asgNalezeneDoklady do begin
    Enabled := true;
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
  Memo1.Lines.Add('Doba trvání: ' + floattostr(RoundTo(dobaZapisu, -2))
              + ' s (' + floattostr(RoundTo(dobaZapisu / 60, -2)) + ' min)');
  {
  AssignFile(OutputFile, PROGRAM_PATH + EditVystupniSoubor.Text);
  ReWrite(OutputFile);
  WriteLn(OutputFile, vysledek);
  CloseFile(OutputFile);
  }
  dbAbra.Reconnect;
  MessageDlg('Zápis do Abry dokonèen', mtInformation, [mbOk], 0);

end;


procedure TfmMain.provedAkcePoZmeneVS;
begin
    currPlatbaZVypisu.loadPredchoziPlatby(StrToInt(editPocetPredchPlateb.text));
    vyplnPredchoziPlatby;
    vyplnDoklady;
    sparujVsechnyPrichoziPlatby;
    //sparujPrichoziPlatbu(asgMain.row - 1);

    Memo2.Clear;
    Memo2.Lines.Add(Parovatko.getPDParyPlatbyAsText(currPlatbaZVypisu));
end;



{*********************** akce Input elementù **********************************}

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
  if asgMain.col = 2 then //zmìna VS
  begin
     //asgMain.Colors[asgMain.col, asgMain.row] := clMoneyGreen;
     currPlatbaZVypisu.VS := asgMain.Cells[2, asgMain.row]; //do pøíslušného objektu platby zapíšu zmìnìný VS
     provedAkcePoZmeneVS;

  end;
  if asgMain.col = 5 then //zmìna textu (názvu klienta)
  begin
     //asgMain.Colors[asgMain.col, asgMain.row] := clMoneyGreen;
     currPlatbaZVypisu.nazevKlienta := asgMain.Cells[5, asgMain.row]; //do pøíslušného objektu platby zapíšu zmìnìný text
  end;
end;

procedure TfmMain.asgPredchoziPlatbyButtonClick(Sender: TObject; ACol,
  ARow: Integer);
begin
  urciCurrPlatbaZVypisu();
  currPlatbaZVypisu.VS := TPredchoziPlatba(currPlatbaZVypisu.PredchoziPlatbyList[ARow - 1]).VS;
  asgMain.Cells[2, asgMain.row] := currPlatbaZVypisu.VS;
  provedAkcePoZmeneVS;
end;

procedure TfmMain.asgMainKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //showmessage('Stisknuto: ' + IntToStr(Key));
  if Key = 27 then
  begin
    currPlatbaZVypisu.VS := currPlatbaZVypisu.VS_orig;
    asgMain.Cells[2, asgMain.row]  := currPlatbaZVypisu.VS;
    provedAkcePoZmeneVS;
  end;
end;


procedure TfmMain.chbVsechnyDokladyClick(Sender: TObject);
begin
  vyplnDoklady;
end;


procedure TfmMain.btnSparujPlatbyClick(Sender: TObject);
begin
  sparujVsechnyPrichoziPlatby;
end;


procedure TfmMain.Zprava(TextZpravy: string);
// do listboxu a logfile uloží èas a text zprávy
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
    1: CanEdit := false;
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




procedure TfmMain.btnNactiRadekVypisuClick(Sender: TObject);
var
  i : integer;
  RadekVypisuID : string;
  BStatement_Object,
  BStatement_Data,
  BStatementRow_Object,
  BStatementRow_Data,
  BStatementRow_Coll  : variant;
begin

  //BStatement_Object := AbraOLE.CreateObject('@BankStatement');
  //BStatement_Data := AbraOLE.CreateValues('@BankStatement');
  //BStatement_Data := BStatement_Object.GetValues('29E2000101');



  //Memo2.Lines.Add(BStatementRow_Data.Value[IndexByName(BStatementRow_Data, 'Amount')]);
  //BStatementRow_Data.ValueByName('Amount') := '746';
  //BStatementRow_Data.ValueByName('VarSymbol') := '20082931';  ///kraus
  //BStatementRow_Data.ValueByName('VarSymbol') := '2012020090';  ///dvoracek
  //BStatementRow_Data.ValueByName('VarSymbol') := '20092830';  ///benes 2 nezaplacene



  //BStatementRow_Data.ValueByName('Firm_ID') := 'DPG0000101';  //husner

  //BStatementRow_Data.ValueByName('PDocument_ID') := '884T000101';  //benes leden FO1-1332/17
  //BStatementRow_Data.ValueByName('PDocument_ID') := 'GNET000101';  //benes unor FO1-6908/17

  //BStatementRow_Data.ValueByName('PDocument_ID') := '69HT000101';  //hartman - staci rict na ktery doklad se má párovat a VS a firma se už zmìní/doplní v Abøe automaticky

  //BStatementRow_Data.ValueByName('PDocument_ID') := Edit2.Text;


  RadekVypisuID := Edit1.Text;
  BStatementRow_Object := AbraOLE.CreateObject('@BankStatementRow');
  BStatementRow_Data := AbraOLE.CreateValues('@BankStatementRow');
  BStatementRow_Data := BStatementRow_Object.GetValues(RadekVypisuID);

  //opravRadekVypisuPomociPDocument_ID(AbraOLE, Edit1.Text, Edit2.Text);
  opravRadekVypisuPomociVS(AbraOLE, Edit1.Text, '20092830');

  //BStatementRow_Data.ValueByName('BankStatementRow_ID') := '';
  //BStatementRow_Data.ValueByName('VarSymbol') := '2016021429'; //mleziva
  //Memo2.Lines.Add(BStatementRow_Data.Value[IndexByName(BStatementRow_Data, 'Amount')]);

  for i := 0 to BStatementRow_Data.Count - 1 do
    Memo2.Lines.Add(inttostr(i) + 'r ' + BStatementRow_Data.Names[i] + ': ' + vartostr( BStatementRow_Data.Value[i]));


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

end.
