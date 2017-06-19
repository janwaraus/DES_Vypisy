unit DesUtils;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  //Windows, Messages, SysUtils, Variants, Classes, Dialogs, Forms,
  StrUtils,  IniFiles, ComObj, //, Grids, AdvObj, StdCtrls,
  IdHTTP, Data.DB, ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ZAbstractConnection, ZConnection;


type
  TDesU = class(TForm)
    dbAbra: TZConnection;
    qrAbra: TZQuery;
    dbZakos: TZConnection;
    qrZakos: TZQuery;


    procedure FormCreate(Sender: TObject);
    procedure desUtilsInit(createOptions : string);

    function getAbraOLE() : variant;
    function abraBoGet(abraBo : string) : string;
    //function abraBoGetByRowId(abraBo, rowId : string) : string;
    function abraBoGetById(abraBo, sId : string) : string;
    function abraBoCreate(abraBo, sJson : string) : string;
    function abraBoUpdate(abraBo, sJson : string) : string;
    function prevedCisloUctuNaText(cisloU : string) : string;
    procedure opravRadekVypisuPomociPDocument_ID(Vypis_ID, RadekVypisu_ID, PDocument_ID, PDocumentType : string);
    procedure opravRadekVypisuPomociVS(Vypis_ID, RadekVypisu_ID, VS : string);
    function getOleObjDataDisplay(abraOleObj_Data : variant) : ansistring;
    function vytvorFaZaVoipKredit(VS : string; castka : currency; datum : double) : string;


    public
      PROGRAM_PATH,
      GPC_PATH,
      abraWebApiUrl,
      abraWebApiUN,
      abraWebApiPW : string;
      AbraOLE: variant;

      function getAbraPeriodId(pYear : string) : string; overload;
      function getAbraPeriodId(pDate : double) : string; overload;
      function getAbraDocqueueId(code, documentType : string) : string;
      function getAbraVatrateId(code : string) : string;
      function getAbraVatindexId(code : string) : string;
      function getAbraIncometypeId(code : string) : string;
      function getAbracodeByVs(vs : string) : string;
      function getAbracodeByContractNumber(cnumber : string) : string;
      function getFirmIdByCode(code : string) : string;

    private
      function newAbraIdHttp(timeout : single; isJsonPost : boolean) : TIdHTTP;

  end;





function removeLeadingZeros(const Value: string): string;
function LeftPad(value:integer; length:integer=8; pad:char='0'): string; overload;
function LeftPad(value: string; length:integer=8; pad:char='0'): string; overload;
function Str6digitsToDate(datum : string) : double;
function IndexByName(DataObject: variant; Name: ShortString): integer;
function pocetRadkuTxtSouboru(SName: string): integer;
function RemoveSpaces(const s: string): string;
function FindInFolder(sFolder, sFile: string; bUseSubfolders: Boolean): string;
procedure writeToFile(pFileName, pContent : string);


const
  Ap = chr(39);
  ApC = Ap + ',';
  ApZ = Ap + ')';
  sLineBreak = {$IFDEF LINUX} AnsiChar(#10) {$ENDIF}
               {$IFDEF MSWINDOWS} AnsiString(#13#10) {$ENDIF};


var
  DesU: TDesU;



implementation

{$R *.dfm}

uses Superobject, AbraEntities;

{****************************************************************************}
{**********************     ABRA common functions     ***********************}
{****************************************************************************}

{
constructor TDesU.create;
var
  adpIniFile: TIniFile;
begin

  PROGRAM_PATH := ExtractFilePath(ParamStr(0));

  if FileExists(PROGRAM_PATH + '..\DE$_Common\abraDesProgramy.ini') then begin

    adpIniFile := TIniFile.Create(PROGRAM_PATH + '..\DE$_Common\abraDesProgramy.ini');
    with adpIniFile do try
      dbAbra.HostName := ReadString('Preferences', 'AbraHN', '');
      dbAbra.Database := ReadString('Preferences', 'AbraDB', '');
      dbAbra.User := ReadString('Preferences', 'AbraUN', '');
      dbAbra.Password := ReadString('Preferences', 'AbraPW', '');
      abraWebApiUrl := ReadString('Preferences', 'AbraWebApiUrl', '');
      abraWebApiUN := ReadString('Preferences', 'AbraWebApiUN', '');
      abraWebApiPW := ReadString('Preferences', 'AbraWebApiPW', '');
      GPC_PATH := ReadString('Preferences', 'GpcPath', '');
    finally
      adpIniFile.Free;
    end;
  end else begin
    Application.MessageBox(PChar('Nenalezen soubor ' + PROGRAM_PATH + 'abraDesProgramy.ini, program ukonèen'),
      'abraDesProgramy.ini', MB_OK + MB_ICONERROR);
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

end;
}

procedure TDesU.FormCreate(Sender: TObject);
begin
  desUtilsInit('');
end;

procedure TDesU.desUtilsInit(createOptions : string);
var
  adpIniFile: TIniFile;
begin

  PROGRAM_PATH := ExtractFilePath(ParamStr(0));

  if FileExists(PROGRAM_PATH + '..\DE$_Common\abraDesProgramy.ini') then begin

    adpIniFile := TIniFile.Create(PROGRAM_PATH + '..\DE$_Common\abraDesProgramy.ini');
    with adpIniFile do try
      dbAbra.HostName := ReadString('Preferences', 'AbraHN', '');
      dbAbra.Database := ReadString('Preferences', 'AbraDB', '');
      dbAbra.User := ReadString('Preferences', 'AbraUN', '');
      dbAbra.Password := ReadString('Preferences', 'AbraPW', '');
      abraWebApiUrl := ReadString('Preferences', 'AbraWebApiUrl', '');
      abraWebApiUN := ReadString('Preferences', 'AbraWebApiUN', '');
      abraWebApiPW := ReadString('Preferences', 'AbraWebApiPW', '');
      GPC_PATH := ReadString('Preferences', 'GpcPath', '');


      dbZakos.HostName := ReadString('Preferences', 'ZakHN', '');
      dbZakos.Database := ReadString('Preferences', 'ZakDB', '');
      dbZakos.User := ReadString('Preferences', 'ZakUN', '');
      dbZakos.Password := ReadString('Preferences', 'ZakPW', '');
    finally
      adpIniFile.Free;
    end;
  end else begin
    Application.MessageBox(PChar('Nenalezen soubor ' + PROGRAM_PATH + '..\DE$_Common\abraDesProgramy.ini, program ukonèen'),
      'abraDesProgramy.ini', MB_OK + MB_ICONERROR);
    Application.Terminate;
  end;


  if not dbAbra.Connected then try
    dbAbra.Connect;
  except on E: exception do
    begin
      Application.MessageBox(PChar('Nedá se pøipojit k databázi Abry, program ukonèen.' + ^M + E.Message), 'Abra', MB_ICONERROR + MB_OK);
      Application.Terminate;
    end;
  end;

  if not dbZakos.Connected then try
    dbZakos.Connect;
  except on E: exception do
    begin
      Application.MessageBox(PChar('Nedá se pøipojit k databázi smluv, program ukonèen.' + ^M + E.Message), 'Abra', MB_ICONERROR + MB_OK);
      Application.Terminate;
    end;
  end;


  {
  //if iniNacteno > 0 then Exit;
  if assigned(DesU) then
     //ShowMessage('DesU objekt je již vytvoøen')
  else begin
     DesU := TDesU.Create(createOptions);
     //ShowMessage('DesU objekt není vytvoøen, vytváøíme nyní');
  end;
  }
end;


function TDesU.getAbraOLE() : variant;
begin
  Result := null;
  if VarIsEmpty(AbraOLE) then try
    AbraOLE := CreateOLEObject('AbraOLE.Application');
    if not AbraOLE.Connect('@DES') then begin
      ShowMessage('Problém s Abrou (connect DES).');
      Exit;
    end;
    //Zprava('Pøipojeno k Abøe (connect DES).');
    if not AbraOLE.Login('SW', '') then begin
//    if not AbraOLE.Login(abraWebApiUN, abraWebApiPW) then begin
      ShowMessage('Problém s Abrou (login Supervisor).');
      Exit;
    end;
    //Zprava('Pøihlášeno k Abøe (login Supervisor).');
  except on E: exception do
    begin
      Application.MessageBox(PChar('Problém s Abrou.' + ^M + E.Message), 'Abra', MB_ICONERROR + MB_OK);
      //Zprava('Problém s Abrou - ' + E.Message);
      Exit;
    end;
  end;
  Result := AbraOLE;
end;

{
function TDesU.getQrAbra() : variant;
begin

end;
}





{*** ABRA WebApi IdHTTP functions ***}

function TDesU.newAbraIdHttp(timeout : single; isJsonPost : boolean) : TIdHTTP;
var
  idHTTP: TIdHTTP;
begin
  idHTTP := TidHTTP.Create;

  idHTTP.Request.BasicAuthentication := True;
  idHTTP.Request.Username := abraWebApiUN;
  idHTTP.Request.Password := abraWebApiPW;
  idHTTP.ReadTimeout := Round (timeout * 1000); // ReadTimeout je v milisekundách

  if (isJsonPost) then begin
    idHTTP.Request.ContentType := 'application/json';
    idHTTP.Request.CharSet := 'utf-8';
    //idHTTP.Request.CharSet := 'cp1250';

  end;

  Result := idHTTP;
end;

function TDesU.abraBoGet(abraBo : string) : string;
begin
  Result := abraBoGetById(abraBo, '');
end;

{
function abraBoGetByRowId(abraBo, rowId : string) : string;
begin
  Result := abraBoGetById(abraBo, getEnpointPartForRowId(rowId));
end;
}

function TDesU.abraBoGetById(abraBo, sId : string) : string;
var
  idHTTP: TIdHTTP;
  endpoint : string;
begin
  idHTTP := newAbraIdHttp(900, false);

  endpoint := abraWebApiUrl + abraBo;
  if sId <> '' then
    endpoint := endpoint + '/' + sId;

  try
    try
      Result := idHTTP.Get(endpoint);
    except
      on E: Exception do
        ShowMessage('Error on request: '#13#10 + e.Message);
    end;
  finally
    idHTTP.Free;
  end;
end;

function TDesU.abraBoCreate(abraBo, sJson : string) : string;
var
  idHTTP: TIdHTTP;
  sstreamJson: TStringStream;
begin
  //sstreamJson := TStringStream.Create(Utf8Encode(pJson)); // D2007 and earlier only
  sstreamJson := TStringStream.Create(sJson, TEncoding.ASCII);
  idHTTP := newAbraIdHttp(900, true);
  try
    try
      Result := idHTTP.Post(abraWebApiUrl + abraBo, sstreamJson);
    except
      on E: Exception do begin
        ShowMessage('Error on request: '#13#10 + e.Message);
        ShowMessage(Result);
      end;
    end;
  finally
    sstreamJson.Free;
    idHTTP.Free;
  end;
end;

function TDesU.abraBoUpdate(abraBo, sJson : string) : string;
var
  idHTTP: TIdHTTP;
  sstreamJson: TStringStream;
begin
  //sstreamJson := TStringStream.Create(Utf8Encode(pJson)); // D2007 and earlier only
  sstreamJson := TStringStream.Create(sJson, TEncoding.UTF8);
  idHTTP := newAbraIdHttp(900, true);
  try
    try
      Result := idHTTP.Put(abraWebApiUrl + abraBo, sstreamJson);
    except
      on E: Exception do
        ShowMessage('Error on request: '#13#10 + e.Message);
    end;
  finally
    sstreamJson.Free;
    idHTTP.Free;
  end;
end;



{*** ABRA data manipulating functions ***}

function TDesU.prevedCisloUctuNaText(cisloU : string) : string;
begin
  Result := cisloU;
  if cisloU = '/0000' then Result := '0';
  if cisloU = '2100098382/2010' then Result := 'DES Fio bìžný';
  if cisloU = '2800098383/2010' then Result := 'DES Fio spoøící';
  if cisloU = '171336270/0300' then Result := 'DES ÈSOB';
  if cisloU = '2107333410/2700' then Result := 'PayU';
  if cisloU = '160987123/0300' then Result := 'Èeská Pošta';
end;

procedure TDesU.opravRadekVypisuPomociPDocument_ID(Vypis_ID, RadekVypisu_ID, PDocument_ID, PDocumentType : string);
var
  JsonSO: ISuperObject;
  sResponse: string;
  {
  BStatement_Object,
  BStatement_Data,
  BStatementRow_Object,
  BStatementRow_Data,
  BStatementRow_Coll : variant;
  }

begin
  { takhle to bylo pres OLE
  BStatementRow_Object := AbraOLE.CreateObject('@BankStatementRow');
  BStatementRow_Data := AbraOLE.CreateValues('@BankStatementRow');

  BStatementRow_Data := BStatementRow_Object.GetValues(Radek_ID);
  BStatementRow_Data.ValueByName('PDocumentType') := PDocumentType;
  BStatementRow_Data.ValueByName('PDocument_ID') := PDocument_ID;
  BStatementRow_Object.UpdateValues(Radek_ID, BStatementRow_Data);
  }

  JsonSO := SO;
  JsonSO.S['PDocumentType'] := PDocumentType;
  JsonSO.S['PDocument_ID'] := PDocument_ID;

  sResponse := abraBoUpdate('bankstatements/' + Vypis_ID + '/rows/' + RadekVypisu_ID, JsonSO.AsJSon());

end;


procedure TDesU.opravRadekVypisuPomociVS(Vypis_ID, RadekVypisu_ID, VS : string);
var
  JsonSO: ISuperObject;
  sResponse: string;
begin
  { takhle to bylo pres OLE
  BStatementRow_Object := AbraOLE.CreateObject('@BankStatementRow');
  BStatementRow_Data := AbraOLE.CreateValues('@BankStatementRow');

  BStatementRow_Data := BStatementRow_Object.GetValues(Radek_ID);
  BStatementRow_Data.ValueByName('VarSymbol') := ''; //odstranit VS aby se Abra chytla pøi pøiøazení
  BStatementRow_Object.UpdateValues(Radek_ID, BStatementRow_Data);

  BStatementRow_Data := BStatementRow_Object.GetValues(Radek_ID);
  BStatementRow_Data.ValueByName('VarSymbol') := VS;
  BStatementRow_Object.UpdateValues(Radek_ID, BStatementRow_Data);
  }

  JsonSO := SO;
  JsonSO.S['VarSymbol'] := ''; //odstranit VS aby se Abra chytla pøi pøiøazení
  sResponse := abraBoUpdate('bankstatements/' + Vypis_ID + '/rows/' + RadekVypisu_ID, JsonSO.AsJSon());

  JsonSO := SO;
  JsonSO.S['VarSymbol'] := VS;
  sResponse := abraBoUpdate('bankstatements/' + Vypis_ID + '/rows/' + RadekVypisu_ID, JsonSO.AsJSon());

end;

function TDesU.getOleObjDataDisplay(abraOleObj_Data : variant) : ansistring;
var
  j : integer;
begin
  Result := '';
  for j := 0 to abraOleObj_Data.Count - 1 do begin
    Result := Result + inttostr(j) + 'r ' + abraOleObj_Data.Names[j] + ': ' + vartostr(abraOleObj_Data.Value[j]) + sLineBreak;
  end;
end;

function TDesU.vytvorFaZaVoipKredit(VS : string; castka : currency; datum : double) : string;
var
  newIssuedInvoice : string;
  jsonBo,
  jsonBoRow,
  newJsonBo: ISuperObject;
begin

  jsonBo := SO;
  jsonBo.S['DocQueue_ID'] := self.getAbraDocqueueId('FO2', '03');
  jsonBo.S['Period_ID'] := self.getAbraPeriodId(datum);
  jsonBo.D['DocDate$DATE'] := datum;
  jsonBo.D['AccDate$DATE'] := datum;
  jsonBo.S['Firm_ID'] := self.getFirmIdByCode(self.getAbracodeByContractNumber(VS));
  jsonBo.S['Description'] := 'kredit VoIP ';
  jsonBo.S['Varsymbol'] := VS;
  jsonBo.B['PricesWithVat'] := true;

  jsonBo.O['rows'] := SA([]);

  // 1. øádek
    jsonBoRow := SO;
    jsonBoRow.I['Rowtype'] := 0;
    jsonBoRow.S['Text'] := ' ';
    jsonBoRow.S['Division_Id'] := '1000000101';
    jsonBo.A['rows'].Add(jsonBoRow);

 //2. øádek
    jsonBoRow := SO;
    jsonBoRow.I['Rowtype'] := 1;
    jsonBoRow.D['Totalprice'] := castka;
    jsonBoRow.S['Text'] := 'Kredit VoIP';
    jsonBoRow.S['Vatrate_Id'] := self.getAbraVatrateId('Výst21');
    //jsonBoRow.S['Vatindex_Id'] := self.getAbraVatindexId('Výst21'); //je potøeba?
    jsonBoRow.S['Incometype_Id'] := self.getAbraIncometypeId('SL'); // služby
    jsonBoRow.S['BusOrder_Id'] := '6400000101'; // self.getAbraBusorderId('kredit VoIP');  todo
    jsonBoRow.S['Division_Id'] := '1000000101';
    jsonBo.A['rows'].Add(jsonBoRow);


  writeToFile(ExtractFilePath(ParamStr(0)) + '!json.txt', jsonBo.AsJSon(true));

  try begin
    newIssuedInvoice := DesU.abraBoCreate('issuedinvoices', jsonBo.AsJSon());
    Result := SO(newIssuedInvoice).S['id'];
  end;
  except on E: exception do
    begin
      Application.MessageBox(PChar('Problem ' + ^M + E.Message), 'Vytvoøení fa');
      Result := 'Chyba pøi vytváøení faktury';
    end;
  end;

end;


function TDesU.getAbraPeriodId(pYear : string) : string;
var
    abraPeriod : TAbraPeriod;
begin
  abraPeriod := TAbraPeriod.create(pYear);
  Result := abraPeriod.id;
end;

function TDesU.getAbraPeriodId(pDate : double) : string;
var
    abraPeriod : TAbraPeriod;
begin
  abraPeriod := TAbraPeriod.create(pDate);
  Result := abraPeriod.id;
end;


function TDesU.getAbraDocqueueId(code, documentType : string) : string;
begin

  with DesU.qrAbra do begin
    SQL.Text := 'SELECT Id FROM DocQueues'
              + ' WHERE Hidden = ''N'' AND Code = ''' + code  + ''' AND DocumentType = ''' + documentType + '''';
    Open;
    if not Eof then begin
      Result := FieldByName('Id').AsString;
    end;
    Close;
  end;
end;

function TDesU.getAbraVatrateId(code : string) : string;
begin

  with DesU.qrAbra do begin
    SQL.Text := 'SELECT VatRate_Id FROM VatIndexes'
              + ' WHERE Hidden = ''N'' AND Code = ''' + code + '''';
    Open;
    if not Eof then begin
      Result := FieldByName('VatRate_Id').AsString;
    end;
    Close;
  end;
end;

function TDesU.getAbraVatindexId(code : string) : string;
begin

  with DesU.qrAbra do begin
    SQL.Text := 'SELECT Id FROM VatIndexes'
              + ' WHERE Hidden = ''N'' AND Code = ''' + code  + '''';
    Open;
    if not Eof then begin
      Result := FieldByName('Id').AsString;
    end;
    Close;
  end;
end;

function TDesU.getAbraIncometypeId(code : string) : string;
begin

  with DesU.qrAbra do begin
    SQL.Text := 'SELECT Id FROM IncomeTypes'
              + ' WHERE Code = ''' + code + '''';
    Open;
    if not Eof then begin
      Result := FieldByName('Id').AsString;
    end;
    Close;
  end;
end;

function TDesU.getAbracodeByVs(vs : string) : string;
begin

  with DesU.qrZakos do begin
    SQL.Text := 'SELECT abra_code FROM customers'
              + ' WHERE variable_symbol = ''' + vs + '''';
    Open;
    if not Eof then begin
      Result := FieldByName('abra_code').AsString;
    end;
    Close;
  end;
end;

function TDesU.getAbracodeByContractNumber(cnumber : string) : string;
begin

  with DesU.qrZakos do begin
    SQL.Text := 'SELECT cu.abra_code FROM customers cu, contracts co '
              + ' WHERE co.number = ''' + cnumber + ''''
              + ' AND cu.id = co.customer_id';
    Open;
    if not Eof then begin
      Result := FieldByName('abra_code').AsString;
    end;
    Close;
  end;
end;

function TDesU.getFirmIdByCode(code : string) : string;
begin

  with DesU.qrAbra do begin
    SQL.Text := 'SELECT Id FROM Firms'
              + ' WHERE Code = ''' + code + '''';
    Open;
    if not Eof then begin
      Result := FieldByName('Id').AsString;
    end;
    Close;
  end;
end;



{***************************************************************************}
{********************     General helper functions     *********************}
{***************************************************************************}

// odstraní ze stringu nuly na zaèátku
function removeLeadingZeros(const Value: string): string;
var
  i: Integer;
begin
  for i := 1 to Length(Value) do
    if Value[i]<>'0' then
    begin
      Result := Copy(Value, i, MaxInt);
      exit;
    end;
  Result := '';
end;


//zaplní øetìzec nulama zleva až do celkové délky lenght
function LeftPad(value:integer; length:integer=8; pad:char='0'): string; overload;
begin
   result := RightStr(StringOfChar(pad,length) + IntToStr(value), length );
end;

function LeftPad(value: string; length:integer=8; pad:char='0'): string; overload;
begin
   result := RightStr(StringOfChar(pad,length) + value, length );
end;

function Str6digitsToDate(datum : string) : double;
begin
  Result := strtodate(copy(datum, 1, 2) + '.' + copy(datum, 3, 2) + '.20' + copy(datum, 5, 2));
end;

function IndexByName(DataObject: variant; Name: ShortString): integer;
// náhrada za nefunkèní DataObject.ValuByName(Name)
var
  i: integer;
begin
  Result := -1;
  i := 0;
  while i < DataObject.Count do begin
    if DataObject.Names[i] = Name then begin
      Result := i;
      Break;
    end;
    Inc(i);
  end;
end;

function pocetRadkuTxtSouboru(SName: string): integer;
var
  oSL : TStringlist;
begin
  oSL := TStringlist.Create;
  oSL.LoadFromFile(SName);
  Result := oSL.Count;
  oSL.Free;
end;

function RemoveSpaces(const s: string): string;
var
  len, p: integer;
  pc: PChar;
const
  WhiteSpace = [#0, #9, #10, #13, #32];

begin
  len := Length(s);
  SetLength(Result, len);

  pc := @s[1];
  p := 0;
  while len > 0 do begin
    if not (pc^ in WhiteSpace) then begin
      inc(p);
      Result[p] := pc^;
    end;
  inc(pc);
  dec(len);
  end;

  SetLength(Result, p);
end;


function FindInFolder(sFolder, sFile: string; bUseSubfolders: Boolean): string;
var
  sr: TSearchRec;
  i: Integer;
  sDatFile: String;
begin
  Result := '';
  sFolder := IncludeTrailingPathDelimiter(sFolder);
  if System.SysUtils.FindFirst(sFolder + sFile, faAnyFile - faDirectory, sr) = 0 then
  begin
    Result := sFolder + sr.Name;
    System.SysUtils.FindClose(sr);
    Exit;
  end;

  //not found .... search in subfolders
  if bUseSubfolders then
  begin
    //find first subfolder
    if System.SysUtils.FindFirst(sFolder + '*.*', faDirectory, sr) = 0 then
    begin
      try
        repeat
          if ((sr.Attr and faDirectory) <> 0) and (sr.Name <> '.') and (sr.Name <> '..') then //is real folder?
          begin
            //recursive call!
            //Result := FindInFolder(sFolder + sr.Name, sFile, bUseSubfolders); // plná rekurze
            Result := FindInFolder(sFolder + sr.Name, sFile, false); // rekurze jen do 1. úrovnì

            if Length(Result) > 0 then Break; //found it ... escape
          end;
        until System.SysUtils.FindNext(sr) <> 0;  //...next subfolder
      finally
        System.SysUtils.FindClose(sr);
      end;
    end;
  end;
end;

procedure writeToFile(pFileName, pContent : string);
var
    OutputFile : TextFile;
begin
  AssignFile(OutputFile, pFileName);
  ReWrite(OutputFile);
  WriteLn(OutputFile, pContent);
  CloseFile(OutputFile);
end;


end.
