unit DesUtils;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, StrUtils;
  //RTTI;

function removeLeadingZeros(const Value: string): string;
function LeftPad(value:integer; length:integer=8; pad:char='0'): string; overload;
function LeftPad(value: string; length:integer=8; pad:char='0'): string; overload;
function Str6digitsToDate(datum : string) : double;
function IndexByName(DataObject: variant; Name: ShortString): integer;
//function DumpObject( YourObjectInstance : tObject ) : ansistring;


const
  sLineBreak = {$IFDEF LINUX} AnsiChar(#10) {$ENDIF} 
               {$IFDEF MSWINDOWS} AnsiString(#13#10) {$ENDIF};

implementation

{
function DumpObject( YourObjectInstance : tObject ) : ansistring;
var
  PropList: PPropList;
  PropCnt: integer;
  iX: integer;
  vValue: Variant;
  sValue: String;
begin
result := '';
  PropCnt := GetPropList(YourObjectInstance,PropList);
  for iX := 0 to PropCnt-1 do
    begin
      vValue := GetPropValue(YourObjectInstance,PropList[ix].Name,True);
      sValue := VarToStr( vValue );
      result := result + PropList[ix].Name+' = '+sValue+';'
    end;
end;
}

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

end.
