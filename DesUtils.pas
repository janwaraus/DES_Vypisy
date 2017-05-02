unit DesUtils;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, StrUtils;
  //RTTI;

function prevedCisloUctuNaText(cisloU : string) : string;
procedure opravRadekVypisuPomociPDocument_ID(AbraOLE : variant; Radek_ID : string; PDocument_ID : string);
procedure opravRadekVypisuPomociVS(AbraOLE : variant; Radek_ID : string; VS : string);
function removeLeadingZeros(const Value: string): string;
function LeftPad(value:integer; length:integer=8; pad:char='0'): string; overload;
function LeftPad(value: string; length:integer=8; pad:char='0'): string; overload;
function Str6digitsToDate(datum : string) : double;
function IndexByName(DataObject: variant; Name: ShortString): integer;
function pocetRadkuTxtSouboru(SName: string): integer;
//function DumpObject( YourObjectInstance : tObject ) : ansistring;


const
  sLineBreak = {$IFDEF LINUX} AnsiChar(#10) {$ENDIF} 
               {$IFDEF MSWINDOWS} AnsiString(#13#10) {$ENDIF};

implementation


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

procedure opravRadekVypisuPomociPDocument_ID(AbraOLE : variant; Radek_ID : string; PDocument_ID : string);
var
  BStatement_Object,
  BStatement_Data,
  BStatementRow_Object,
  BStatementRow_Data,
  BStatementRow_Coll : variant;
begin
  BStatementRow_Object := AbraOLE.CreateObject('@BankStatementRow');
  BStatementRow_Data := AbraOLE.CreateValues('@BankStatementRow');
  BStatementRow_Data := BStatementRow_Object.GetValues(Radek_ID);
  BStatementRow_Data.ValueByName('PDocument_ID') := PDocument_ID;
  BStatementRow_Object.UpdateValues(Radek_ID, BStatementRow_Data);
end;

procedure opravRadekVypisuPomociVS(AbraOLE : variant; Radek_ID : string; VS : string);
var
  BStatement_Object,
  BStatement_Data,
  BStatementRow_Object,
  BStatementRow_Data,
  BStatementRow_Coll : variant;
begin
  BStatementRow_Object := AbraOLE.CreateObject('@BankStatementRow');
  BStatementRow_Data := AbraOLE.CreateValues('@BankStatementRow');
  BStatementRow_Data := BStatementRow_Object.GetValues(Radek_ID);
  BStatementRow_Data.ValueByName('VarSymbol') := VS;
  BStatementRow_Object.UpdateValues(Radek_ID, BStatementRow_Data);
end;

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

end.
