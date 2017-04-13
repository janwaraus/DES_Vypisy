unit VypisFIO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, IniFiles, Forms,
  Dialogs, StdCtrls, Grids, AdvObj, BaseGrid, AdvGrid, StrUtils, //DEShelpers
  DB, ComObj, AdvEdit, DateUtils, Math, ExtCtrls,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection,
  DesUtils, classPlatbaPrichozi;

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
    btnSparuj1Platbu: TButton;
    editPocetPredchPlateb: TEdit;
    btnReconnect: TButton;
    Memo2: TMemo;
    Button2: TButton;
    chbSkrytBP: TCheckBox;

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
    procedure btnSparuj1PlatbuClick(Sender: TObject);
    procedure asgNalezeneDokladyGetAlignment(Sender: TObject; ARow,
      ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
    procedure asgPredchoziPlatbyGetAlignment(Sender: TObject; ARow,
      ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
    procedure asgPredchoziPlatbyVsGetAlignment(Sender: TObject; ARow,
      ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
    procedure btnReconnectClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure asgPredchoziPlatbyButtonClick(Sender: TObject; ACol,
      ARow: Integer);
    procedure chbSkrytBPClick(Sender: TObject);

  public
    procedure vyplnPrichoziPlatby;
    procedure vyplnPredchoziPlatby;
    procedure vyplnDoklady;
    procedure sparujPrichoziPlatbu(i : integer);
    procedure sparujVsechnyPrichoziPlatby;
    procedure test;
    procedure Zprava(TextZpravy: string);

  end;

var
  Form1: TForm1;
  Vypis : TVypis;
  PlatbaPrichoziList : TList;
  CurrPlatbaPrichozi : TPlatbaPrichozi;
  PROGRAM_PATH: string;
  AbraOLE: variant;
  Parovatko : TParovatko;

implementation

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
  PlatbaPrichoziList.Free;
end;

procedure TForm1.btnNactiClick(Sender: TObject);
var
  GpcInputFile : TextFile;
  GpcFileLine : string;
  tempPlatbaPrichozi : TPlatbaPrichozi;
  Pocet: integer;
begin
// *** naètení GPC na základì dialogu
  NactiGpcDialog.InitialDir := 'J:\Eurosignal\HB\';
  NactiGpcDialog.Filter := 'Bankovní výpisy (*.gpc)|*.gpc';
	if NactiGpcDialog.Execute then try
    Screen.Cursor := crHourGlass;
    asgMain.ClearNormalCells;   //clear ostatnich todo
    btnNacti.Enabled := False;
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
    PlatbaPrichoziList := TList.Create;
    Pocet := 0;
    while not Eof(GpcInputFile) do
    begin
      Inc(Pocet);
      btnNacti.Caption := IntToStr(Pocet);
      ReadLn(GpcInputFile, GpcFileLine);
      
      if copy(GpcFileLine, 1, 3) = '074' then //hlavicka vypisu
      begin
        Vypis := TVypis.Create(GpcFileLine, qrAbra);
      end;

      if copy(GpcFileLine, 1, 3) = '075' then //radek vypisu zacina 075
      begin
        tempPlatbaPrichozi := TPlatbaPrichozi.Create(GpcFileLine, qrAbra);
        tempPlatbaPrichozi.init(StrToInt(editPocetPredchPlateb.text));
        PlatbaPrichoziList.Add(tempPlatbaPrichozi);
      end;

    end;


    if (PlatbaPrichoziList.Count > 0) then
    begin
      //PlatbaPrichoziList.Sort(@CCompareCreditFirst);
      Vypis.Datum := TPlatbaPrichozi(PlatbaPrichoziList[PlatbaPrichoziList.Count - 1]).Datum; //datum vypisy se urci jako datum poslední platby
      DebetyDozadu(PlatbaPrichoziList);
      CurrPlatbaPrichozi := TPlatbaPrichozi(PlatbaPrichoziList[0]);
      vyplnPrichoziPlatby;
    end;
  finally
    btnNacti.Enabled := True;
    btnNacti.Caption := 'Naèti GPC';
    CloseFile(GpcInputFile);
    sparujVsechnyPrichoziPlatby;
    Screen.Cursor := crDefault;
  end;


end;



procedure TForm1.btnZapisDoAbryClick(Sender: TObject);
var
  OutputFile : TextFile;
  vysledek  : string;
  casStart, dobaZapisu: double;

begin
// ***
  Screen.Cursor := crHourGlass;
  btnZapisDoAbry.Enabled := False;
  casStart := Now;
  try
    vysledek := Parovatko.zapisDoAbry();
  finally
    btnZapisDoAbry.Enabled := True;
    Screen.Cursor := crDefault;
  end;


  Memo1.Lines.Add(vysledek);
  dobaZapisu := (Now - casStart) * 24 * 3600;
  Memo1.Lines.Add('Doba trvání: ' + floattostr(RoundTo(dobaZapisu, -2)) + ' s (' + floattostr(RoundTo(dobaZapisu / 60, -2)) + ' min)');

  AssignFile(OutputFile, PROGRAM_PATH + EditVystupniSoubor.Text);
  ReWrite(OutputFile);
  WriteLn(OutputFile, vysledek);
  CloseFile(OutputFile);


//Memo2.Lines.LoadFromFile(PROGRAM_PATH + EditVstupniSoubor.Text);
//Memo2.Lines.SaveToFile(PROGRAM_PATH + EditVystupniSoubor.Text);

end;

procedure TForm1.vyplnPrichoziPlatby;
var
  i : integer;
  iPlatbaPrichozi : TPlatbaPrichozi;
begin

  with asgMain do
  begin
    ClearNormalCells;
    RowCount := PlatbaPrichoziList.Count + 1;
    Row := 1;

    for i := 0 to PlatbaPrichoziList.Count - 1 do
    begin
      iPlatbaPrichozi := TPlatbaPrichozi(platbaPrichoziList[i]);
      AddCheckBox(0, i+1, True, True);
      if (iPlatbaPrichozi.kredit) then
        Cells[1, i+1] := format('%m', [iPlatbaPrichozi.castka])
      else
        Cells[1, i+1] := format('%m', [-iPlatbaPrichozi.castka]);
      if iPlatbaPrichozi.debet then asgMain.FontColors[1, i+1] := clRed;
      Cells[2, i+1] := iPlatbaPrichozi.VS;
      Cells[3, i+1] := iPlatbaPrichozi.SS;
      Cells[4, i+1] := iPlatbaPrichozi.cisloUctuBezNul;
      Cells[5, i+1] := iPlatbaPrichozi.nazevKlienta;
      Cells[6, i+1] := DateToStr(iPlatbaPrichozi.Datum);

    end;
  end;
end;

procedure TForm1.sparujPrichoziPlatbu(i : integer);
var
  iPlatbaPrichozi : TPlatbaPrichozi;
  VysledekParovani : integer;
begin
  iPlatbaPrichozi := TPlatbaPrichozi(platbaPrichoziList[i]);

  VysledekParovani := Parovatko.sparujPlatbu(iPlatbaPrichozi);

  case VysledekParovani of
    0: asgMain.Colors[2, i+1] := $AAAAFF;
    1: asgMain.Colors[2, i+1] := $AAFFAA;
    2: asgMain.Colors[2, i+1] := $FFAAAA;
  end;


  asgMain.Cells[7, i+1] := iPlatbaPrichozi.zprava;
  
end;

procedure TForm1.sparujVsechnyPrichoziPlatby;
var
  i : integer;
begin
  Parovatko := TParovatko.create(AbraOLE, Vypis);
  for i := 0 to PlatbaPrichoziList.Count - 1 do
    sparujPrichoziPlatbu(i);

  //Memo1.Lines.Add(Parovatko.getPDParyAsText);

  Memo1.Lines.Add('Vypis porad. cislo: ' + IntToStr(Vypis.PoradoveCislo));

end;


procedure TForm1.asgMainClick(Sender: TObject);
begin
  CurrPlatbaPrichozi := TPlatbaPrichozi(PlatbaPrichoziList[asgMain.row - 1]);
  vyplnPredchoziPlatby;
  vyplnDoklady;

  Memo2.Clear;
  Memo2.Lines.Add(Parovatko.getPDParyPlatbyAsText(CurrPlatbaPrichozi));
end;


procedure TForm1.chbVsechnyDokladyClick(Sender: TObject);
begin
  vyplnDoklady;
end;


procedure TForm1.vyplnPredchoziPlatby;
var
  i : integer;
  tempPredchoziPlatba : TPredchoziPlatba;
begin

  with asgPredchoziPlatby do begin
    ClearNormalCells;
    if CurrPlatbaPrichozi.PredchoziPlatbyList.Count > 0 then
    begin
      RowCount := CurrPlatbaPrichozi.PredchoziPlatbyList.Count + 1;
      for i := 0 to RowCount - 2 do begin
        tempPredchoziPlatba := TPredchoziPlatba(CurrPlatbaPrichozi.PredchoziPlatbyList[RowCount - 2 - i]);
        //Cells[0, i+1] := IntToStr(i+1);
        AddButton(0,i+1,25,18,'<--',haCenter,vaCenter);
        Cells[1, i+1] := tempPredchoziPlatba.VS;
        Cells[2, i+1] := format('%m', [tempPredchoziPlatba.Castka]);
        if tempPredchoziPlatba.Castka < 0 then asgPredchoziPlatby.FontColors[2, i+1] := clRed;
        Cells[3, i+1] := DateToStr(tempPredchoziPlatba.Datum);
        Cells[4, i+1] := tempPredchoziPlatba.FirmName;
      end;
    end else
       RowCount := 2;
  end;

  with asgPredchoziPlatbyVs do begin
    ClearNormalCells;
    if CurrPlatbaPrichozi.PredchoziPlatbyVsList.Count > 0 then
    begin
      RowCount := CurrPlatbaPrichozi.PredchoziPlatbyVsList.Count + 1;
      for i := 0 to RowCount - 2 do begin
        tempPredchoziPlatba := TPredchoziPlatba(CurrPlatbaPrichozi.PredchoziPlatbyVsList[RowCount - 2 - i]);

        Cells[0, i+1] := tempPredchoziPlatba.VS;
        Cells[1, i+1] := format('%m', [tempPredchoziPlatba.Castka]);
        if tempPredchoziPlatba.Castka < 0 then asgPredchoziPlatbyVs.FontColors[1, i+1] := clRed;
        Cells[2, i+1] := DateToStr(tempPredchoziPlatba.Datum);
        Cells[3, i+1] := removeLeadingZeros(tempPredchoziPlatba.cisloUctu);
        Cells[4, i+1] := tempPredchoziPlatba.FirmName;
      end;
    end else
      RowCount := 2;
  end;
end;


procedure TForm1.vyplnDoklady;
var
  tempList : TList;
  tempDoklad : TDoklad;
  iPDPar : TPlatbaDokladPar;
  i : integer;
begin

  CurrPlatbaPrichozi.loadDokladyPodleVS(not chbVsechnyDoklady.Checked);
  tempList := CurrPlatbaPrichozi.DokladyList;

  if chbVsechnyDoklady.Checked then
  begin
    labelNalezeneDoklady.Caption := 'Všechny doklady podle VS ' +  CurrPlatbaPrichozi.VS;
  end else
  begin
    labelNalezeneDoklady.Caption := 'Nezaplacené doklady podle VS ' +  CurrPlatbaPrichozi.VS;

  end;

  with asgNalezeneDoklady do begin
    ClearNormalCells;
    if tempList.Count > 0 then
    begin
      RowCount := tempList.Count + 1;
      for i := 0 to RowCount - 2 do begin
        tempDoklad := TDoklad(tempList[i]);
        Cells[0, i+1] := tempDoklad.CisloDokladu;
        Cells[1, i+1] := DateToStr(tempDoklad.DatumDokladu);
        Cells[2, i+1] := tempDoklad.FirmName;
        Cells[3, i+1] := format('%m', [tempDoklad.Castka]);
        Cells[4, i+1] := format('%m', [tempDoklad.CastkaZaplaceno]);
        Cells[5, i+1] := format('%m', [tempDoklad.CastkaDobropisovano]);
        Cells[6, i+1] := format('%m', [tempDoklad.CastkaNezaplaceno]);
        Cells[7, i+1] := tempDoklad.ID;

        iPDPar := Parovatko.getPDPar(CurrPlatbaPrichozi, tempDoklad.ID);
        if Assigned(iPDPar) then
          Cells[8, i+1] := iPDPar.Popis; // + floattostr(iPDPar.CastkaPouzita) ;


    end;
    end else
      RowCount := 2;
  end;

end;


procedure TForm1.btnSparujPlatbyClick(Sender: TObject);
begin
  sparujVsechnyPrichoziPlatby;
end;

procedure TForm1.test;
//var
  //ji : integer;
begin

end;


procedure TForm1.asgMainCellsChanged(Sender: TObject; R: TRect);
begin
  if asgMain.col = 2 then
  begin
     asgMain.Colors[asgMain.col, asgMain.row] := clMoneyGreen;
     TPlatbaPrichozi(platbaPrichoziList[asgMain.row - 1]).VS := asgMain.Cells[2, asgMain.row]; //do pøíslušného objektu platby zapíšu zmìnìný VS
  end;

end;

procedure TForm1.btnSparuj1PlatbuClick(Sender: TObject);
begin
  sparujPrichoziPlatbu(asgMain.row - 1);
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

procedure TForm1.Button1Click(Sender: TObject);
begin
  CurrPlatbaPrichozi := TPlatbaPrichozi(PlatbaPrichoziList[asgMain.row - 1]); //pro jistotu
  Parovatko.odparujPlatbu(CurrPlatbaPrichozi);

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Memo2.Clear;
  Memo2.Lines.Add(Parovatko.getPDParyAsText());
end;

procedure TForm1.asgPredchoziPlatbyButtonClick(Sender: TObject; ACol,
  ARow: Integer);
begin
  CurrPlatbaPrichozi := TPlatbaPrichozi(PlatbaPrichoziList[asgMain.row - 1]);
  CurrPlatbaPrichozi.VS := TPredchoziPlatba(CurrPlatbaPrichozi.PredchoziPlatbyList[CurrPlatbaPrichozi.PredchoziPlatbyList.Count - ARow]).VS;
  asgMain.Cells[2, asgMain.row] := CurrPlatbaPrichozi.VS;


  CurrPlatbaPrichozi.loadPredchoziPlatby(StrToInt(editPocetPredchPlateb.text));
  vyplnPredchoziPlatby;
  vyplnDoklady;
  sparujPrichoziPlatbu(asgMain.row - 1);

  Memo2.Clear;
  Memo2.Lines.Add(Parovatko.getPDParyPlatbyAsText(CurrPlatbaPrichozi));  
end;

procedure TForm1.chbSkrytBPClick(Sender: TObject);
var
  i : integer;
  iPlatbaPrichozi : TPlatbaPrichozi;
begin

  for i := 0 to platbaPrichoziList.Count - 1 do
  begin
    iPlatbaPrichozi := TPlatbaPrichozi(platbaPrichoziList[i]);
    if chbSkrytBP.Checked AND (iPlatbaPrichozi.vysledekParovani = 1) then
      asgMain.RowHeights[i+1] := 0
    else
      asgMain.RowHeights[i+1] := 22;
  end;

end;

end.
