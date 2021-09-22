unit UnitProjetoScrum.Model;

interface

type
  TProjetoScrum = class
  private
    FCodigo: integer;
    FNome: string;
    FEstado: string;
    FData: string;
    FContrato: integer;
  public
    property Codigo: integer read FCodigo write FCodigo;
    property Nome: string read FNome write FNome;
    property Estado: string read FEstado write FEstado;
    property Data: string read FData write FData;
    property Contrato: integer read FContrato write FContrato;
    function ToJsonString: string;
    class function FromJsonString(Value: string): TProjetoScrum;
  end;

implementation
uses Rest.Json;

{ TProjetoScrum }

class function TProjetoScrum.FromJsonString(Value: string): TProjetoScrum;
begin
  Result := TJson.JsonToObject<TProjetoScrum>(Value);
end;

function TProjetoScrum.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.
