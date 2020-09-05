unit UnitController.OrdensServicos;

interface

uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  System.StrUtils,
  DB,
  UnitConexao.Model.Interfaces,
  UnitOcorrencia.Model,
  UnitConexao.FireDAC.Model,
  UnitQuery.FireDAC.Model,
  UnitFactory.Conexao.FireDAC,
  UnitFuncoesComuns, UnitConstantes, UnitHistoricoPrazoEntrega.Model;

type
  TControllerOrdensServicos = class
    class procedure Registrar(App: THorse);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure PutTextoOrdem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

uses
  UnitOrdens.Model;

{ TControllerOrdensServicos }

class procedure TControllerOrdensServicos.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Query: iQuery;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Dados: TDataSource;
  oJson: TJSONObject;
  aJson: TJSONArray;
begin
  Fabrica := TFactoryConexaoFireDAC.New;
  Conexao := Fabrica.Conexao(TConstants.BancoDados);
  Query   := Fabrica.Query(Conexao);
  Dados   := TDataSource.Create(nil);
  Query.DataSource(Dados);
  Query.Add('SELECT ORD_PRAZOE, ORD_CODIGO, CLI_NOME, ORD_DATAAB, ORD_ESTADO, ORD_OCORRENCIA, ORD_NOVO_PRAZOE, ');
  Query.Add('CASE WHEN ORD_PRIORIDADE = 1 THEN ''BAIXA''');
  Query.Add('WHEN ORD_PRIORIDADE = 2 THEN ''M�DIA''');
  Query.Add('ELSE ''ALTA'' END PRIORIDADE, FUN_NOME, (SELECT FUN_NOME FROM FUNCIONARIOS WHERE FUN_CODIGO = ORD_FUN1) QUEM_ABRIU');
  Query.Add('FROM ORDENS, CLIENTES, CONTRATOS, FUNCIONARIOS');
  Query.Add('WHERE ORD_FUN3 = FUN_CODIGO AND ORD_CONT = CONT_CODIGO AND CONT_CLI = CLI_CODIGO AND ORD_ESTADO <> ''ENTREGUE''');
  Query.Add('ORDER BY ORD_NOVO_PRAZOE');
  Query.Open();
  aJson := TJSONArray.Create;
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('prazoEntrega', Dados.DataSet.FieldByName('ORD_PRAZOE').AsString);
    oJson.AddPair('ord_codigo', TJSONNumber.Create(Dados.DataSet.FieldByName('ORD_CODIGO').AsInteger));
    oJson.AddPair('cli_nome', Dados.DataSet.FieldByName('CLI_NOME').AsString);
    oJson.AddPair('dataAbertura', Dados.DataSet.FieldByName('ORD_DATAAB').AsString);
    oJson.AddPair('estado', Dados.DataSet.FieldByName('ORD_ESTADO').AsString);
    oJson.AddPair('prioridade', Dados.DataSet.FieldByName('PRIORIDADE').AsString);
    oJson.AddPair('programador', Dados.DataSet.FieldByName('FUN_NOME').AsString);
    oJson.AddPair('quemAbriu', Dados.DataSet.FieldByName('QUEM_ABRIU').AsString);
    oJson.AddPair('ocorrencia', Dados.DataSet.FieldByName('ORD_OCORRENCIA').AsString);
    oJson.AddPair('novo_prazoe', Dados.DataSet.FieldByName('ORD_NOVO_PRAZOE').AsString);
    aJson.AddElement(oJson);
    Dados.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TControllerOrdensServicos.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Ordens: TModelOrdens;
  oJson: TJSONObject;
  aJson: TJSONArray;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
  Codigo: Integer;
begin
  aJson := TJSONArray.Create;
  if Req.Body <> '' then
  begin
    Ordens := TModelOrdens.FromJsonString(Req.Body);
  end
  else
    raise Exception.Create('Ordem n�o passada corretamente');
  // componentes de conexao
  Fabrica := TFactoryConexaoFireDAC.New;
  Conexao := Fabrica.Conexao(TConstants.BancoDados);
  Query   := Fabrica.Query(Conexao);
  Dados   := TDataSource.Create(nil);
  Codigo  := GeraCodigo('ORDENS', 'ORD_CODIGO');
  Query.DataSource(Dados);
  Query.Add('INSERT INTO ORDENS (ORD_CODIGO, ORD_DATAAB, ORD_FUN1, ORD_CONT, ORD_OCORRENCIA, ORD_ANALISE, ORD_DATAAN, ORD_FUN2, ORD_FUN3, ORD_FUN4, ');
  Query.Add('ORD_DATAE, ORD_FUN5, ORD_ESTADO, ORD_NUMPROGRAMACAO, ORD_NUMTESTES, ORD_PRAZOE, ORD_DATA, ORD_HORA, ');
  Query.Add('ORD_TIPO, ORD_DATAE_AN, ORD_DATAE_P, ORD_DATAE_T, ORD_ATENDENTE, ORD_PRIORIDADE, ORD_OCO, ORD_OS_MODULO, ORD_SPRINT, ORD_NOVO_PRAZOE )');
  Query.Add('VALUES (:ORD_CODIGO, :ORD_DATAAB, :ORD_FUN1, :ORD_CONT, :ORD_OCORRENCIA, :ORD_ANALISE, :ORD_DATAAN, :ORD_FUN2, :ORD_FUN3, :ORD_FUN4, ');
  Query.Add(':ORD_DATAE, :ORD_FUN5, :ORD_ESTADO, :ORD_NUMPROGRAMACAO, :ORD_NUMTESTES, :ORD_PRAZOE, :ORD_DATA, :ORD_HORA, ');
  Query.Add(':ORD_TIPO, :ORD_DATAE_AN, :ORD_DATAE_P, :ORD_DATAE_T, :ORD_ATENDENTE, :ORD_PRIORIDADE, :ORD_OCO, :ORD_OS_MODULO, :ORD_SPRINT, :ORD_NOVO_PRAZOE )');
  Query.AddParam('ORD_CODIGO', Codigo);
  Query.AddParam('ORD_DATAAB', Date);
  Query.AddParam('ORD_FUN1', Ordens.fun_Abertura);
  Query.AddParam('ORD_CONT', Ordens.contrato);
  Query.AddParam('ORD_OCORRENCIA', Ordens.ocorrencia, true);
  Query.AddParam('ORD_ANALISE', ifThen(Ordens.estado = 'ANALISADA', 'SEM NECESSIDADE ANALISE', ''), true);
  Query.AddParam('ORD_DATAAN', Date);
  Query.AddParam('ORD_FUN2', Ordens.fun_analise);
  Query.AddParam('ORD_FUN3', Ordens.fun_programador);
  Query.AddParam('ORD_FUN4', Ordens.fun_teste);
  Query.AddParam('ORD_DATAE', FormatarData(Ordens.data_entrega));
  Query.AddParam('ORD_FUN5', Ordens.fun_entrega);
  Query.AddParam('ORD_ESTADO', Ordens.estado);
  Query.AddParam('ORD_NUMPROGRAMACAO', 0);
  Query.AddParam('ORD_NUMTESTES', 0);
  Query.AddParam('ORD_PRAZOE', FormatarData(Ordens.prazo_entrega));
  Query.AddParam('ORD_DATA', Date);
  Query.AddParam('ORD_HORA', Now);
  Query.AddParam('ORD_TIPO', Ordens.Tipo);
  Query.AddParam('ORD_DATAE_AN', FormatarData(Ordens.data_entrega_analise));
  Query.AddParam('ORD_DATAE_P', FormatarData(Ordens.data_entrega_programacao));
  Query.AddParam('ORD_DATAE_T', FormatarData(Ordens.data_entrega_teste));
  Query.AddParam('ORD_ATENDENTE', Ordens.fun_atendente);
  Query.AddParam('ORD_PRIORIDADE', Ordens.prioridade);
  Query.AddParam('ORD_OCO', Ordens.codigo_ocorrencia);
  Query.AddParam('ORD_OS_MODULO', Ordens.os_modulo);
  Query.AddParam('ORD_SPRINT', Ordens.codSprint);
  Query.AddParam('ORD_NOVO_PRAZOE', FormatarData(Ordens.prazo_entrega));
  Query.ExecSQL;
  Res.Status(200);
  Res.Send<TJSONObject>(TJSONObject.Create.AddPair('ordem', Codigo.ToString));
end;

class procedure TControllerOrdensServicos.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  oJson: TJSONObject;
  CodigoOrdem: Integer;
  Historico: THistoricoPrazoEntrega;
  Codigo: Integer;
begin
  // componentes de conexao
  Fabrica     := TFactoryConexaoFireDAC.New;
  Conexao     := Fabrica.Conexao(TConstants.BancoDados);
  Query       := Fabrica.Query(Conexao);
  oJson       := TJSONObject.Create;
  CodigoOrdem := Req.Params.Items['id'].ToInteger;
  if CodigoOrdem > 0 then
  begin
    try
      Codigo    := GeraCodigo('HIS_PRAZO_ORDEM', 'HPO_CODIGO');
      Historico := THistoricoPrazoEntrega.FromJsonString(Req.Body);
      Query.Clear;
      Query.Add('UPDATE ORDENS SET ORD_NOVO_PRAZOE = :NOVO_PRAZO WHERE ORD_CODIGO = :CODIGO ');
      Query.AddParam('NOVO_PRAZO', FormatarData(Historico.PrazoNovo));
      Query.AddParam('CODIGO', CodigoOrdem);
      Query.ExecSQL;
      // Insere Historico
      Query.Clear;
      Query.Add('INSERT INTO HIS_PRAZO_ORDEM (HPO_CODIGO, HPO_FUN, HPO_ORD, HPO_PRAZO_ANTERIOR, HPO_PRAZO_NOVO) ');
      Query.Add('VALUES (:HPO_CODIGO, :HPO_FUN, :HPO_ORD, :HPO_PRAZO_ANTERIOR, :HPO_PRAZO_NOVO) ');
      Query.AddParam('HPO_CODIGO', Codigo);
      Query.AddParam('HPO_FUN', Historico.Funcionario);
      Query.AddParam('HPO_ORD', Historico.Ordem);
      Query.AddParam('HPO_PRAZO_ANTERIOR', FormatarData(Historico.PrazoAnterior));
      Query.AddParam('HPO_PRAZO_NOVO', FormatarData(Historico.PrazoNovo));
      Query.ExecSQL;
      Res.Status(200);
      oJson.AddPair('Historico', TJSONNumber.Create(Codigo));
      Res.Send<TJSONObject>(oJson);
    except
      on E: Exception do
      begin
        raise Exception.Create('Erro ao inserir historico' + E.Message);
        Res.Status(200);
        oJson.AddPair('Ok', 'Historico n�o informado corretamente!' + sLineBreak + E.Message);
        Res.Send<TJSONObject>(oJson);
      end
    end;
  end;
end;

class procedure TControllerOrdensServicos.PutTextoOrdem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  oJson: TJSONObject;
  CodigoOrdem: Integer;
  Ocorrencia: TOcorrencia;
  Codigo: Integer;
begin
  // componentes de conexao
  Fabrica     := TFactoryConexaoFireDAC.New;
  Conexao     := Fabrica.Conexao(TConstants.BancoDados);
  Query       := Fabrica.Query(Conexao);
  oJson       := TJSONObject.Create;
  CodigoOrdem := Req.Params.Items['id'].ToInteger;
  if CodigoOrdem > 0 then
  begin
    Ocorrencia := TOcorrencia.FromJsonString(Req.Body);
    Query.Clear;
    Query.Add('UPDATE ORDENS SET ORD_OCORRENCIA = :OCORRENCIA WHERE ORD_CODIGO = :CODIGO ');
    Query.AddParam('OCORRENCIA', Ocorrencia.ocorrencia);
    Query.AddParam('CODIGO', CodigoOrdem);
    Query.ExecSQL;
  end;
end;

class procedure TControllerOrdensServicos.Registrar(App: THorse);
begin
  App.Get('/Ordens', Get);
  App.Post('/Ordens', Post);
  App.Put('/Ordens/:id', Put);
  App.Put('/AtualizaOrdens/:id', PutTextoOrdem);
end;

end.
