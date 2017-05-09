unit Customers;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math, IniFiles,
  Dialogs, Grids, AdvObj, BaseGrid, AdvGrid, StdCtrls, DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection,
  ZConnection;

type
  TfmCustomers = class(TForm)
    edJmeno: TEdit;
    edPrijmeni: TEdit;
    btNajdi: TButton;
    lbJmeno: TLabel;
    lbPrijmeni: TLabel;
    asgCustomers: TAdvStringGrid;
    lbVS: TLabel;
    edVS: TEdit;
    dbMain: TZConnection;
    qrMain: TZQuery;
    procedure FormShow(Sender: TObject);
    procedure dbMainAfterConnect(Sender: TObject);
    procedure btNajdiClick(Sender: TObject);
    procedure asgCustomersGetAlignment(Sender: TObject; ARow,
      ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
    procedure edJmenoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edPrijmeniKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edVSKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmCustomers: TfmCustomers;

implementation

{$R *.dfm}

procedure TfmCustomers.FormShow(Sender: TObject);
var
  FIIni: TIniFile;
  FIFileName: AnsiString;
begin
  FIFileName := ExtractFilePath(ParamStr(0)) + 'FI.ini';
  if FileExists(FIFileName) then begin                     // existuje FI.ini ?
    FIIni := TIniFile.Create(FIFileName);
    with FIIni do try
      dbMain.HostName := ReadString('Preferences', 'ZakHN', '');
      dbMain.Database := ReadString('Preferences', 'ZakDB', '');
      dbMain.User := ReadString('Preferences', 'ZakUN', '');
      dbMain.Password := ReadString('Preferences', 'ZakPW', '');
    finally
      FIIni.Free;
    end;
  end else begin
    Application.MessageBox('Neexistuje soubor FI.ini, program ukon�en', 'FI.ini', MB_OK + MB_ICONERROR);
    Application.Terminate;
  end;
  try
    dbMain.Connect;
  except on E: exception do
    begin
      Application.MessageBox(PChar('Ned� se p�ipojit k datab�zi smluv, program ukon�en.' + ^M + E.Message), 'mySQL', MB_ICONERROR + MB_OK);
      Application.Terminate;
    end;
  end;
  edPrijmeni.SetFocus;
end;

procedure TfmCustomers.dbMainAfterConnect(Sender: TObject);
begin
  with qrMain do begin
    SQL.Text := 'SET CHARACTER SET cp1250';                // p�eklad z UTF-8
    ExecSQL;
  end;
end;

procedure TfmCustomers.edJmenoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = 13) then btNajdiClick(Self);
end;

procedure TfmCustomers.edPrijmeniKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = 13) then btNajdiClick(Self);
end;

procedure TfmCustomers.edVSKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = 13) then btNajdiClick(Self);
end;

procedure TfmCustomers.asgCustomersGetAlignment(Sender: TObject; ARow, ACol: Integer; var HAlign: TAlignment; var VAlign: TVAlignment);
begin
  HAlign := taCenter;
  if (ACol = 0) and (ARow > 0) then HAlign := taLeftJustify;
end;

procedure TfmCustomers.btNajdiClick(Sender: TObject);
// jednoduch� hled�n� z tabulek customers a contracts v datab�zi aplikace
var
  Zakaznik,
  PosledniZakaznik,
  SQLStr: AnsiString;
  SirkaOkna,
  Radek: integer;
begin
  SQLStr := 'SELECT DISTINCT Cu.Abra_code, Cu.Variable_symbol, Cu.Title, Cu.First_name, Cu.Surname, Cu.Business_name,'
  + ' C.Number, C.State, C.Invoice, C.Invoice_from, C.Canceled_at'
  + ' FROM customers Cu, contracts C'
  + ' WHERE Cu.Id = C.Customer_Id'
  + ' AND Cu.First_name LIKE ''' + edJmeno.Text + ''''
  + ' AND (Cu.Business_name LIKE ''' + edPrijmeni.Text + ''''
  + ' OR Cu.Surname LIKE ''' + edPrijmeni.Text + ''')'
  + ' AND (Cu.Variable_symbol LIKE ''' + edVS.Text + ''''
  + ' OR C.Number LIKE ''' + edVS.Text + ''')'
  + ' ORDER BY Business_name, Surname, First_name';
  SQLStr := StringReplace(SQLStr, '*', '%', [rfReplaceAll]);      // aby fungovala i *
  with qrMain, asgCustomers do try
    Screen.Cursor := crSQLWait;
    ClearNormalCells;
    RowCount := 2;
    Radek := 0;
    PosledniZakaznik := '';
    SQL.Text := SQLStr;
    Open;
    while not EOF do begin
      Inc(Radek);
      RowCount := Radek + 1;
      Zakaznik := FieldByName('Surname').AsString;
      if (FieldByName('First_name').AsString <> '') then Zakaznik := FieldByName('First_name').AsString + ' ' + Zakaznik;
      if (FieldByName('Title').AsString <> '') then Zakaznik := FieldByName('Title').AsString + ' ' + Zakaznik;
      if (FieldByName('Business_name').AsString <> '') then Zakaznik := FieldByName('Business_name').AsString + ', ' + Zakaznik;
      if (Zakaznik <> PosledniZakaznik) then begin      // pro stejn�ho z�kazn�ka se vypisuj� jen �daje o smlouv�
        Cells[0, Radek] := Zakaznik;
        Cells[1, Radek] := FieldByName('Abra_code').AsString;
        Cells[2, Radek] := FieldByName('Variable_symbol').AsString;
        PosledniZakaznik := Zakaznik;
      end;
      Cells[3, Radek] := FieldByName('Number').AsString;
      Cells[4, Radek] := FieldByName('State').AsString;
      if (FieldByName('Invoice').AsInteger = 1) then Cells[5, Radek] := 'ano'
      else Cells[5, Radek] := 'ne';
      if (Cells[5, Radek] = 'ano') and (FieldByName('Invoice_from').AsString <> '') then
        Cells[5, Radek] := Cells[5, Radek] + ', od ' + FieldByName('Invoice_from').AsString;
      if (Cells[5, Radek] = 'ne') and (FieldByName('Canceled_at').AsString <> '') then
        Cells[5, Radek] := Cells[5, Radek] + ', do ' + FieldByName('Canceled_at').AsString;
      Row := Radek;  
      Application.ProcessMessages;
      Next;
    end;
  finally
    Row := 1;
    AutoSize := True;
    SirkaOkna := 0;
    for Radek := 0 to ColCount-1 do SirkaOkna := SirkaOkna + ColWidths[Radek];
    fmCustomers.ClientWidth := SirkaOkna + 4;
    fmCustomers.Left := Max(0, Round((Screen.Width - fmCustomers.Width) / 2));
    fmCustomers.ClientHeight := Min(RowCount * 18 + 46, Screen.Height - 30);
    if (fmCustomers.ClientHeight = Screen.Height - 30) then fmCustomers.ClientWidth := fmCustomers.ClientWidth + 16;
    fmCustomers.Top := Max(0, Round((Screen.Height - fmCustomers.Height) / 2));
    Screen.Cursor := crDefault;
  end;
end;

end.
