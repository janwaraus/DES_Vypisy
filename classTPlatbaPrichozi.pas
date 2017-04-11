unit classTPlatbaPrichozi;

interface

uses
  SysUtils, Classes;

type

  TPlatbaPrichozi = class(TDataModule)
  private
  public
    typZaznamu: string[3];
    cisloUctuMoje: string[16];
    cisloUctu: string[21];
    cisloDokladu: string[13];
    castka: string[12];
    kodUctovani: string[1];
    VS: string[10];
    plnyPodleGpcKS: string[10];
    KS: string[4];
    SS: string[10];
    valuta: string[6];
    nazevKlienta: string[20];
    nulaNavic: string[1];
    kodMeny: string[4];
    datumSplatnosti: string[6];
    stavParovani : string;

    constructor create(gpcLine : string);
    //function isPrirazenoPresne(): Boolean;
    function getCount() : integer;
  end;


implementation


constructor TPlatbaPrichozi.create(gpcLine : string);
begin
  self.typZaznamu := copy(gpcLine, 1, 3);
  self.cisloUctuMoje := copy(gpcLine, 4, 16);
  self.cisloUctu := copy(gpcLine, 20, 16) + '/' + copy(gpcLine, 74, 4);
  self.cisloDokladu := copy(gpcLine, 36, 13);
  self.castka := copy(gpcLine, 49, 12);
  self.kodUctovani := copy(gpcLine, 61, 1);
  self.VS := copy(gpcLine, 62, 10);
  self.plnyPodleGpcKS := copy(gpcLine, 72, 10);
  self.KS := copy(gpcLine, 78, 4);
  self.SS := copy(gpcLine, 82, 10);
  self.valuta := copy(gpcLine, 92, 6);
  self.nazevKlienta := copy(gpcLine, 98, 20);
  self.nulaNavic := copy(gpcLine, 118, 1);
  self.kodMeny := copy(gpcLine, 119, 4);
  self.datumSplatnosti := copy(gpcLine, 123, 6);
end;

function TPlatbaPrichozi.getCount() : integer;
begin
  result := 1;
end;

end.
 