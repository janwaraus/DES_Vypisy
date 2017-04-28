unit AbraEntities;

interface

uses
  SysUtils, Variants, Classes, Controls,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection;  

type

  TAbraBankAccount = class
  private
    qrAbra: TZQuery;
  public
    id : string[10];
    name : string[50];
    number : string[42];
    bankstatementDocqueueId : string[10];
    constructor create(qrAbra : TZQuery);
  published
    procedure loadByNumber(baNumber : string);
  end;

implementation

constructor TAbraBankAccount.create(qrAbra : TZQuery);
begin
  self.qrAbra := qrAbra;
end;

procedure TAbraBankAccount.loadByNumber(baNumber : string);
begin
  with qrAbra do begin

    SQL.Text := 'SELECT ID, NAME, BANKACCOUNT, BANKSTATEMENT_ID '
              + 'FROM BANKACCOUNTS '
              + 'WHERE BANKACCOUNT like ''' + baNumber  + '%'' '
              + 'AND HIDDEN = ''N'' ';

    Open;
    if not Eof then begin
      self.id := FieldByName('ID').AsString;
      self.name := FieldByName('NAME').AsString;
      self.number := FieldByName('BANKACCOUNT').AsString;
      self.bankStatementDocqueueId := FieldByName('BANKSTATEMENT_ID').AsString;
    end;
    Close;
  end;
end;

end.
 