unit UnitHistoricoPrazoEntrega.Model;

interface

uses Rest.Json;

type
  THistoricoPrazoEntrega = class
  private
    FCodigo: integer;
    FFuncionario: integer;
    FOrdem: integer;
    FPrazoAnterior: string;
    FPrazoNovo: string;
  public
    property Codigo: integer read FCodigo write FCodigo;
    property Funcionario: integer read FFuncionario write FFuncionario;
    property Ordem: integer read FOrdem write FOrdem;
    property PrazoAnterior: string read FPrazoAnterior write FPrazoAnterior;
    property PrazoNovo: string read FPrazoNovo write FPrazoNovo;
    function ToJsonString: string;
    class function FromJsonString(Value: string): THistoricoPrazoEntrega;
  end;

implementation

{ THistoricoPrazoEntrega }

class function THistoricoPrazoEntrega.FromJsonString(Value: string): THistoricoPrazoEntrega;
begin
  Result := TJson.JsonToObject<THistoricoPrazoEntrega>(Value);
end;

function THistoricoPrazoEntrega.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.
