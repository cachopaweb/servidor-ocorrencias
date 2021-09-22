unit UnitBacklog.Sprint.Model;

interface

uses Rest.Json;

type
  TBacklogSprint = class
  private
    FCodigo  : integer;
    FConteudo: string;
    FDataSprint: TDateTime;
    FDataEntregaProgramacao: string;
    FDataEntregaReal: string;
    FEstado: string;
    FDescricao: String;
    FCod_Projeto_Scrum: integer;
  public
    property Codigo  : integer read FCodigo write FCodigo;
    property Conteudo: string read FConteudo write FConteudo;
    property DataSprint: TDateTime read FDataSprint write FDataSprint;
    property DataEntregaProgramacao: string read FDataEntregaProgramacao write FDataEntregaProgramacao;
    property DataEntregaReal: string read FDataEntregaReal write FDataEntregaReal;
    property Estado: string read FEstado write FEstado;
    property Descricao: String read FDescricao write FDescricao;
    property Cod_Projeto_Scrum: integer read FCod_Projeto_Scrum write FCod_Projeto_Scrum;
    function ToJsonString: string;
    class function FromJsonString(Value: string): TBacklogSprint;
  end;

implementation

{ TBacklogSprint }

class function TBacklogSprint.FromJsonString(Value: string): TBacklogSprint;
begin
  Result := TJson.JsonToObject<TBacklogSprint>(Value);
end;

function TBacklogSprint.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.
