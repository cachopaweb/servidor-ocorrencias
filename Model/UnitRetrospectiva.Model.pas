unit UnitRetrospectiva.Model;

interface

type
  TRetrospectiva = class
  private
    Fprojeto_scrum      : integer;
    Fanalise_integrantes: string;
    Fanalise_processo   : string;
    Fanalise_ferramentas: string;
    Fanalise_comunicacao: string;
    Fanalise_pronto     : string;
    Fcodigo: integer;
  public
    property projeto_scrum      : integer read Fprojeto_scrum write Fprojeto_scrum;
    property analise_integrantes: string read Fanalise_integrantes write Fanalise_integrantes;
    property analise_processo   : string read Fanalise_processo write Fanalise_processo;
    property analise_ferramentas: string read Fanalise_ferramentas write Fanalise_ferramentas;
    property analise_comunicacao: string read Fanalise_comunicacao write Fanalise_comunicacao;
    property analise_pronto     : string read Fanalise_pronto write Fanalise_pronto;
    property codigo: integer read Fcodigo write Fcodigo;
    class function FromJson(JsonString: string): TRetrospectiva;
    function toJsonString: string;
  end;

implementation
uses Rest.Json;

{ TRetrospectiva }

class function TRetrospectiva.FromJson(JsonString: string): TRetrospectiva;
begin
  Result := TJson.JsonToObject<TRetrospectiva>(JsonString);
end;

function TRetrospectiva.toJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.
