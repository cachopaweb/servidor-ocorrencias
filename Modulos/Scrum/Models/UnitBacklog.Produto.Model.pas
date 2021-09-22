unit UnitBacklog.Produto.Model;

interface

uses Rest.Json;

type
  TBacklogProduto = class
  private
    FCodigo           : integer;
    FDescricao        : string;
    FNecessidade      : integer;
    FDataBacklog      : TDateTime;
    FCod_Projeto_Scrum: integer;
    FEstado           : string;
    FDataEntregaReal  : TDateTime;
    FDataEntrega      : TDateTime;
    FFuncionario      : integer;
    FOcorrencia       : integer;
    FTitulo           : string;
  public
    property Codigo           : integer read FCodigo write FCodigo;
    property Descricao        : string read FDescricao write FDescricao;
    property Necessidade      : integer read FNecessidade write FNecessidade;
    property DataBacklog      : TDateTime read FDataBacklog write FDataBacklog;
    property Cod_Projeto_Scrum: integer read FCod_Projeto_Scrum write FCod_Projeto_Scrum;
    property Estado           : string read FEstado write FEstado;
    property DataEntregaReal  : TDateTime read FDataEntregaReal write FDataEntregaReal;
    property DataEntrega      : TDateTime read FDataEntrega write FDataEntrega;
    property Funcionario      : integer read FFuncionario write FFuncionario;
    property Ocorrencia       : integer read FOcorrencia write FOcorrencia;
    property Titulo           : string read FTitulo write FTitulo;
    function ToJsonString: string;
    class function FromJsonString(Value: string): TBacklogProduto;
  end;

implementation

{ TBacklogProduto }

class function TBacklogProduto.FromJsonString(Value: string): TBacklogProduto;
begin
  Result := TJson.JsonToObject<TBacklogProduto>(Value);
end;

function TBacklogProduto.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.
