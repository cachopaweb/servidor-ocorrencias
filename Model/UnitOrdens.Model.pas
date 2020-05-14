unit UnitOrdens.Model;

interface

uses Rest.Json;

type
  TModelOrdens = class
  private
    Fcodigo           : integer;
    Fprogramador      : string;
    Focorrencia       : string;
    Fdata             : TDateTime;
    Flaudo_programacao: string;
    Fcli_nome         : string;
  public
    property codigo           : integer read Fcodigo write Fcodigo;
    property programador      : string read Fprogramador write Fprogramador;
    property ocorrencia       : string read Focorrencia write Focorrencia;
    property data             : TDateTime read Fdata write Fdata;
    property laudo_programacao: string read Flaudo_programacao write Flaudo_programacao;
    property cli_nome         : string read Fcli_nome write Fcli_nome;
    function ToJsonString: string;
    class function FromJsonString(Value: string): TModelOrdens;
  end;

implementation

{ TModelOrdens }

class function TModelOrdens.FromJsonString(Value: string): TModelOrdens;
begin
  Result := TJson.JsonToObject<TModelOrdens>(Value);
end;

function TModelOrdens.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.
