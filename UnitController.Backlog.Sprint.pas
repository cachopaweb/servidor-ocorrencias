unit UnitController.Backlog.Sprint;

interface
uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  Horse.Commons,
  DB,
  UnitConexao.Model.Interfaces,
  UnitConexao.FireDAC.Model,
  UnitQuery.FireDAC.Model,
  UnitFactory.Conexao.FireDAC,
  UnitFuncoesComuns, UnitConstantes;


type
  TControllerBacklogSprint = class
    class procedure Registrar(App: THorse);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerBacklogSprint }

uses UnitBacklog.Sprint.Model;


class procedure TControllerBacklogSprint.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  BacklogSprint: TBacklogSprint;
  Codigo: integer;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
begin
  // componentes de conexao
  Fabrica := TFactoryConexaoFireDAC.New;
  Conexao := Fabrica.Conexao(TConstants.BancoDados);
  Query := Fabrica.Query(Conexao);
  Dados := TDataSource.Create(nil);
  Query.DataSource(Dados);
  oJson := TJSONObject.Create;
  if Req.Body <> '' then
  begin
    BacklogSprint := TBacklogSprint.FromJsonString(Req.Body);
    try
      Codigo := GeraCodigo('BACKLOG_SPRINT', 'BS_CODIGO');
      Query.Add('INSERT INTO BACKLOG_SPRINT (BS_CODIGO, BS_CONTEUDO, BS_DATA_SPRINT, BS_DATA_ENT_PROG, BS_ESTADO, BS_DESCRICAO, BS_PS)');
      Query.Add('VALUES (:CODIGO, :CONTEUDO, :DATA_SPRINT, :DATA_ENT_PROG, :ESTADO, :DESCRICAO, :COD_PROJETO)');
      Query.AddParam('CODIGO', codigo);
      Query.AddParam('CONTEUDO', BacklogSprint.Conteudo);
      Query.AddParam('DATA_SPRINT', Date);
      Query.AddParam('DATA_ENT_PROG', BacklogSprint.DataEntregaProgramacao);
      Query.AddParam('ESTADO', BacklogSprint.Estado);
      Query.AddParam('DESCRICAO', BacklogSprint.Descricao);
      Query.AddParam('COD_PROJETO', BacklogSprint.Cod_Projeto_Scrum);
      Query.ExecSQL;
      oJson.AddPair('BACKLOG_SPRINT', Codigo.ToString);
      Res.Send<TJSONObject>(oJson).Status(THTTPStatus.Created);
    except
      on E: exception do
      begin
        raise exception.Create('Erro ao inserir Sprint' + E.Message);
        Res.Status(THTTPStatus.BadRequest);
        oJson.AddPair('Error', 'Sprint não informado corretamente!'+sLineBreak+e.Message);
        Res.Send<TJSONObject>(oJson);
      end
    end;
  end
  else
  begin
    Res.Status(THTTPStatus.BadRequest);
    oJson.AddPair('Error', 'Sprint não encontrado!');
    Res.Send<TJSONObject>(oJson);
  end;
end;

class procedure TControllerBacklogSprint.Registrar(App: THorse);
begin
  App.Post('/sprint', Post);
end;

end.
