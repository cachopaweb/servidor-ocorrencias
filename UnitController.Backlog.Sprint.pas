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
  UnitFuncoesComuns, UnitConstantes, UnitBacklog.Produto.Model;


type
  TControllerBacklogSprint = class
    class procedure Registrar(App: THorse);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure PostSprintBacklog(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure DeleteSprintBacklog(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerBacklogSprint }

uses UnitBacklog.Sprint.Model;


class procedure TControllerBacklogSprint.DeleteSprintBacklog(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
  Codigo: Integer;
  oJson: TJSONObject;
begin
  // componentes de conexao
  Fabrica := TFactoryConexaoFireDAC.New;
  Conexao := Fabrica.Conexao(TConstants.BancoDados);
  Query := Fabrica.Query(Conexao);
  Dados := TDataSource.Create(nil);
  Query.DataSource(Dados);
  Codigo := Req.Params.Items['id'].ToInteger;
  try
    Query.Add('DELETE FROM BS_BP WHERE (BB_CODIGO = :CODIGO)');
    Query.AddParam('CODIGO', Codigo);
    Query.ExecSQL;
    Res.Status(THTTPStatus.NoContent);
  except
    on E: exception do
    begin
      raise exception.Create('Erro ao deletar sprint backlog' + E.Message);
      Res.Status(THTTPStatus.BadRequest);
      oJson := TJSONObject.Create;
      oJson.AddPair('Error', 'Sprint backlog não informado corretamente!'+sLineBreak+e.Message);
      Res.Send<TJSONObject>(oJson);
    end
  end;
end;

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
      Query.AddParam('DATA_ENT_PROG', FormatarData(BacklogSprint.DataEntregaProgramacao));
      Query.AddParam('ESTADO', BacklogSprint.Estado);
      Query.AddParam('DESCRICAO', BacklogSprint.Descricao, true);
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

class procedure TControllerBacklogSprint.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
  CodigoSprint: Integer;
  BacklogSprint: TBacklogSprint;
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
    CodigoSprint := Req.Params.Items['id'].ToInteger;
    BacklogSprint := TBacklogSprint.FromJsonString(Req.Body);
    try
      if BacklogSprint.Estado = 'ENTREGUE' then
      begin
        Query.Add('UPDATE BACKLOG_SPRINT SET BS_ESTADO = :ESTADO, BS_DATA_ENT_REAL = :DATA_ENTREGA WHERE (BS_CODIGO = :CODIGO)');
        Query.AddParam('DATA_ENTREGA', Date);
      end else
      begin
        Query.Add('UPDATE BACKLOG_SPRINT SET BS_ESTADO = :ESTADO WHERE (BS_CODIGO = :CODIGO)');
      end;
      Query.AddParam('ESTADO', BacklogSprint.Estado);
      Query.AddParam('CODIGO', CodigoSprint);
      Query.ExecSQL;
      oJson.AddPair('NOVO ESTADO', BacklogSprint.Estado);
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

class procedure TControllerBacklogSprint.PostSprintBacklog(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
  CodigoBS_BP: Integer;
  CodigoSprint: Integer;
  BacklogProduto: TBacklogProduto;
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
    CodigoSprint := Req.Params.Items['id'].ToInteger;
    BacklogProduto := TBacklogProduto.FromJsonString(Req.Body);
    try
      CodigoBS_BP := GeraCodigo('BS_BP', 'BB_CODIGO');
      Query.Add('INSERT INTO BS_BP (BB_CODIGO, BB_BP, BB_BS, BB_PRIORIDADE)');
      Query.Add('VALUES (:CODIGO, :BP, :BS, :PRIORIDADE);');
      Query.AddParam('CODIGO', CodigoBS_BP);
      Query.AddParam('BP', BacklogProduto.Codigo);
      Query.AddParam('BS', CodigoSprint);
      Query.AddParam('PRIORIDADE', BacklogProduto.Necessidade);
      Query.ExecSQL;
      oJson.AddPair('BS_BP', CodigoBS_BP.ToString);
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
  App.Put('/sprint/:id', Put);
  App.Post('/sprint_backlog/:id', PostSprintBacklog);
  App.Delete('/sprint_backlog/:id', DeleteSprintBacklog);
end;

end.
