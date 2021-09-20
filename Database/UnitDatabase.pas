unit UnitDatabase;

interface
uses
  UnitConnection.Model.Interfaces,
  UnitFactory.Connection.Firedac;

type
  TDatabase = class
    class function Query: iQuery;
  end;

implementation

{ TDatabase }

uses UnitConstantes;

class function TDatabase.Query: iQuery;
begin
  Result := TFactoryConnectionFiredac.New(TConstants.BancoDados).Query;
end;

end.
