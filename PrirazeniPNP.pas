unit PrirazeniPNP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, IniFiles, Forms,
  Dialogs, StdCtrls, Grids, AdvObj, BaseGrid, AdvGrid, StrUtils,
  DB, ComObj, AdvEdit, DateUtils, Math, ExtCtrls,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection,
  VypisyMain, DesUtils;

type
  TfmPrirazeniPnp = class(TForm)
    asgPNP: TAdvStringGrid;
    btnNactiPnp: TButton;
    btnNajdiPNP: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    btnZmenRadekVypisu: TButton;
    MemoPNP: TMemo;
    procedure btnNactiPnpClick(Sender: TObject);
    procedure btnZmenRadekVypisuClick(Sender: TObject);
    procedure asgPNPButtonClick(Sender: TObject; ACol, ARow: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmPrirazeniPnp: TfmPrirazeniPnp;

implementation

{$R *.dfm}

procedure TfmPrirazeniPnp.btnNactiPnpClick(Sender: TObject);
var
  SQLStr: AnsiString;
  Radek: integer;
begin
// nalezení zákazníkù s pøeplatky na 325 z Abry



  SQLStr := '  SELECT preplatkyVypis.*,'
  + ' ii.ID as Doklad_ID, ii.DOCQUEUE_ID, ii.DOCDATE$DATE, ii.VARSYMBOL as Doklad_VS, ii.FIRM_ID, ii.DESCRIPTION, D.DOCUMENTTYPE,'
  + ' D.Code || ''-'' || II.OrdNumber || ''/'' || substring(P.Code from 3 for 2) as CisloDokladu,'
  + ' (ii.LOCALAMOUNT - ii.LOCALPAIDAMOUNT - ii.LOCALCREDITAMOUNT + ii.LOCALPAIDCREDITAMOUNT) as dluh,'
  + ' ii.LOCALAMOUNT, ii.LOCALPAIDAMOUNT, ii.LOCALCREDITAMOUNT, ii.LOCALPAIDCREDITAMOUNT'
  + ' from'
  + ' (SELECT ADQ.Code || ''-'' || G1.OrdNumber || ''/'' || P.Code AS DokladVypis, G1.Amount, F.Name, G1.Text,'
  + ' bs.ID as Vypis_ID, bs2.ID as RadekVypisu_ID,  bs2.FIRM_ID, bs2.varsymbol as RadekVypisu_VS'
  + ' FROM GENERALLEDGER G1, BANKSTATEMENTS bs, BANKSTATEMENTS2 bs2,'
  + '   AccDocQueues ADQ, Periods P, Firms F'
  + ' WHERE G1.CreditAccount_ID = ''A300000101'''
  + ' AND NOT EXISTS (SELECT * FROM GENERALLEDGER G2 WHERE G2.AccGroup_ID = G1.AccGroup_ID AND G2.ID <> G1.ID)'
  + ' AND ADQ.Id = G1.AccDocQueue_ID'
  + ' AND P.Id = G1.Period_ID'
  + ' AND F.Id = G1.Firm_ID'

  + ' AND G1.AccDocQueue_ID = bs.AccDocQueue_ID'
  + ' AND G1.Period_ID = bs.Period_ID'
  + ' AND G1.ORDNUMBER = bs.ORDNUMBER'

  + ' AND bs2.PARENT_ID = bs.ID'
  + ' AND bs2.FIRM_ID = G1.FIRM_ID'
  + ' AND bs2.AMOUNT = G1.AMOUNT'
  + ' AND bs2.PDOCUMENT_ID IS NULL'
  + ' AND bs2.ISMULTIPAYMENTROW = ''N'''
  + ' AND bs2.Amount > 5) as preplatkyVypis'

  + ' JOIN ISSUEDINVOICES ii ON ii.Firm_ID = preplatkyVypis.Firm_ID'
  + ' JOIN DocQueues D ON ii.DocQueue_ID = D.ID'
  + ' JOIN Periods P ON ii.Period_ID = P.ID'

  //+ ' WHERE preplatkyVypis.amount <= (ii.LOCALAMOUNT - ii.LOCALPAIDAMOUNT - ii.LOCALCREDITAMOUNT + ii.LOCALPAIDCREDITAMOUNT) ' //èástka PNP je menší nebo rovna dluhu
+ ' WHERE preplatkyVypis.amount <= (ii.LOCALAMOUNT - ii.LOCALPAIDAMOUNT - ii.LOCALCREDITAMOUNT + ii.LOCALPAIDCREDITAMOUNT) ' //èástka PNP je menší nebo rovna dluhu

  ;


  with fmMain.qrAbra, asgPNP do begin
    ClearNormalCells;
    RowCount := 2;
    Radek := 0;
    SQL.Text := SQLStr;
    Open;
    while not EOF do begin
      //opravRadekVypisuPomociPDocument_ID(AbraOLE, FieldByName('RadekVypisu_ID').AsString, FieldByName('Doklad_ID').AsString);
      Inc(Radek);
      RowCount := Radek + 1;
      Cells[0, Radek] := FieldByName('DokladVypis').AsString; //ucetni doklad
      Floats[1, Radek] := FieldByName('Amount').AsFloat;
      Cells[2, Radek] := FieldByName('Name').AsString;
      Cells[3, Radek] := FieldByName('Text').AsString;
      Cells[4, Radek] := FieldByName('RadekVypisu_ID').AsString;
      Cells[5, Radek] := FieldByName('CisloDokladu').AsString;
      Cells[6, Radek] := FieldByName('Doklad_ID').AsString;
      Cells[7, Radek] := FieldByName('DocumentType').AsString;
      AddButton(8,Radek,45,18,'zmìò d',haCenter,vaCenter);
      Cells[9, Radek] := FieldByName('Doklad_VS').AsString;
      AddButton(10,Radek,45,18,'zmìò VS',haCenter,vaCenter);
      Application.ProcessMessages;
      Next;
    end;
  end;
end;


procedure TfmPrirazeniPnp.asgPNPButtonClick(Sender: TObject; ACol,
  ARow: Integer);
begin
  with asgPNP do begin
    if ACol = 8 then begin
      opravRadekVypisuPomociPDocument_ID(AbraOLE, Cells[4, ARow], Cells[6, ARow], Cells[7, ARow]);
      MessageDlg('Oprava pøiøazením èísla dokladu hotová', mtInformation, [mbOk], 0);
    end else begin
      opravRadekVypisuPomociVS(AbraOLE, Cells[4, ARow], Cells[9, ARow]);
      MessageDlg('Oprava pøiøazením VS hotová', mtInformation, [mbOk], 0);
    end;
  end;
end;

procedure TfmPrirazeniPnp.btnZmenRadekVypisuClick(Sender: TObject);
var
  i : integer;
  RadekVypisuID : string;
  BStatement_Object,
  BStatement_Data,
  BStatementRow_Object,
  BStatementRow_Data,
  BStatementRow_Coll  : variant;
begin

  RadekVypisuID := Edit1.Text;

  BStatementRow_Object := AbraOLE.CreateObject('@BankStatementRow');
  BStatementRow_Data := AbraOLE.CreateValues('@BankStatementRow');
  BStatementRow_Data := BStatementRow_Object.GetValues(RadekVypisuID);
  BStatementRow_Data.ValueByName('PDocument_ID') := Edit2.Text;

  for i := 0 to BStatementRow_Data.Count - 1 do
    MemoPNP.Lines.Add(inttostr(i) + 'r ' + BStatementRow_Data.Names[i] + ': ' + vartostr( BStatementRow_Data.Value[i]));

  BStatementRow_Object.UpdateValues(RadekVypisuID, BStatementRow_Data);

end;

end.
