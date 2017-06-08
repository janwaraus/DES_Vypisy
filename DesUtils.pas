unit DesUtils;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, StrUtils, Dialogs, Forms, IniFiles; //, Grids, AdvObj, StdCtrls,;


procedure nactiIni();
function abraBoGet(abraBo : string) : string;
//function abraBoGetByRowId(abraBo, rowId : string) : string;
function abraBoGetById(abraBo, sId : string) : string;
function abraBoCreate(abraBo, sJson : string) : string;
function abraBoUpdate(abraBo, sJson : string) : string;
function prevedCisloUctuNaText(cisloU : string) : string;
procedure opravRadekVypisuPomociPDocument_ID(Vypis_ID, RadekVypisu_ID, PDocument_ID, PDocumentType : string);
procedure opravRadekVypisuPomociVS(Vypis_ID, RadekVypisu_ID, VS : string);

function removeLeadingZeros(const Value: string): string;
function LeftPad(value:integer; length:integer=8; pad:char='0'): string; overload;
function LeftPad(value: string; length:integer=8; pad:char='0'): string; overload;
function Str6digitsToDate(datum : string) : double;
function IndexByName(DataObject: variant; Name: ShortString): integer;
function pocetRadkuTxtSouboru(SName: string): integer;
function RemoveSpaces(const s: string): string;
function FindInFolder(sFolder, sFile: string; bUseSubfolders: Boolean): string;


const
  Ap = chr(39);
  ApC = Ap + ',';
  ApZ = Ap + ')';
  sLineBreak = {$IFDEF LINUX} AnsiChar(#10) {$ENDIF}
               {$IFDEF MSWINDOWS} AnsiString(#13#10) {$ENDIF};

var
  abraWebApiUrl : string;
  iniNacteno : integer;

implementation

uses IdHTTP, Superobject;

{****************************************************************************}
{**********************     ABRA common functions     ***********************}
{****************************************************************************}

procedure nactiIni();
var
  adpIniFile: TIniFile;
  PROGRAM_PATH: string;
begin
  if iniNacteno > 0 then Exit;

  PROGRAM_PATH := ExtractFilePath(ParamStr(0)) + '../CommonFiles/';
  if FileExists(PROGRAM_PATH + 'abraDesProgramy.ini') then begin
    iniNacteno := 1;
    adpIniFile := TIniFile.Create(PROGRAM_PATH + 'abraDesProgramy.ini');
    with adpIniFile do try
      abraWebApiUrl := ReadString('Preferences', 'AbraWebApiUrl', '');
    finally
      adpIniFile.Free;
    end;
  end else begin
    Application.MessageBox(PChar('Nenalezen soubor ' + PROGRAM_PATH + 'abraDesProgramy.ini, program ukonèen'),
      'abraDesProgramy.ini', MB_OK + MB_ICONERROR);
    Application.Terminate;
  end;
end;

{*** ABRA WebApi IdHTTP functions ***}

function abraBoGet(abraBo : string) : string;
begin
  Result := abraBoGetById(abraBo, '');
end;

{
function abraBoGetByRowId(abraBo, rowId : string) : string;
begin
  Result := abraBoGetById(abraBo, getEnpointPartForRowId(rowId));
end;
}

function abraBoGetById(abraBo, sId : string) : string;
var
  idHTTP: TIdHTTP;
  endpoint : string;
begin
  nactiIni();
  idHTTP := TidHTTP.Create;
  idHTTP.Request.BasicAuthentication := True;
  idHTTP.Request.Username := 'Supervisor';
  idHTTP.Request.Password := '';

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

function abraBoCreate(abraBo, sJson : string) : string;
var
  idHTTP: TIdHTTP;
  sstreamJson: TStringStream;
  endpoint : string;
begin
  nactiIni();
  //sstreamJson := TStringStream.Create(Utf8Encode(pJson)); // D2007 and earlier only
  sstreamJson := TStringStream.Create(sJson, TEncoding.UTF8);

  idHTTP := TidHTTP.Create;
  idHTTP.Request.BasicAuthentication := True;
  idHTTP.Request.Username := 'Supervisor';
  idHTTP.Request.Password := '';

  endpoint := abraWebApiUrl + abraBo;

  try
    idHTTP.Request.ContentType := 'application/json';
    idHTTP.Request.CharSet := 'utf-8';
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

function abraBoUpdate(abraBo, sJson : string) : string;
var
  idHTTP: TIdHTTP;
  sstreamJson: TStringStream;
begin
  nactiIni();
  //sstreamJson := TStringStream.Create(Utf8Encode(pJson)); // D2007 and earlier only
  sstreamJson := TStringStream.Create(sJson, TEncoding.UTF8);

  idHTTP := TidHTTP.Create;
  idHTTP.Request.BasicAuthentication := True;
  idHTTP.Request.Username := 'Supervisor';
  idHTTP.Request.Password := '';

  try
    idHTTP.Request.ContentType := 'application/json';
    idHTTP.Request.CharSet := 'utf-8';
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

function prevedCisloUctuNaText(cisloU : string) : string;
begin
  Result := cisloU;
  if cisloU = '/0000' then Result := '0';
  if cisloU = '2100098382/2010' then Result := 'DES Fio bìžný';
  if cisloU = '2800098383/2010' then Result := 'DES Fio spoøící';
  if cisloU = '171336270/0300' then Result := 'DES ÈSOB';
  if cisloU = '2107333410/2700' then Result := 'PayU';
  if cisloU = '160987123/0300' then Result := 'Èeská Pošta';
end;

procedure opravRadekVypisuPomociPDocument_ID(Vypis_ID, RadekVypisu_ID, PDocument_ID, PDocumentType : string);
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


procedure opravRadekVypisuPomociVS(Vypis_ID, RadekVypisu_ID, VS : string);
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
  while len > 0 do
  begin
  if not (pc^ in WhiteSpace) then
  begin
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
  if SysUtils.FindFirst(sFolder + sFile, faAnyFile - faDirectory, sr) = 0 then
  begin
    Result := sFolder + sr.Name;
    SysUtils.FindClose(sr);
    Exit;
  end;

  //not found .... search in subfolders
  if bUseSubfolders then
  begin
    //find first subfolder
    if SysUtils.FindFirst(sFolder + '*.*', faDirectory, sr) = 0 then
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
        until SysUtils.FindNext(sr) <> 0;  //...next subfolder
      finally
        SysUtils.FindClose(sr);
      end;
    end;
  end;
end;

end.

