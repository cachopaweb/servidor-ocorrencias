unit UnitController.Scrum;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Json,
  DB,
  UnitConnection.Model.Interfaces,
  UnitFuncoesComuns, UnitConstantes;


type
  TControllerScrum = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetEmAndamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetPrazoSprint(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure PostRetrospectiva(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetRetrospectiva(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerScrum }

uses UnitProjetoScrum.Model, UnitRetrospectiva.Model, UnitDatabase;

class procedure TControllerScrum.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  Projeto: TProjetoScrum;
  Codigo: integer;
  Query: iQuery;
begin
  // componentes de conexao
  Query := TDatabase.Query;
  oJson := TJSONObject.Create;
  if Req.Body <> '' then
  begin
    Projeto := TProjetoScrum.FromJsonString(Req.Body);
    try
      Codigo := GeraCodigo('PROJETO_SCRUM', 'PS_CODIGO');
      Query.Clear;
      Query.Add('INSERT INTO PROJETO_SCRUM (PS_CODIGO, PS_DATA, PS_CONT, PS_ESTADO, PS_NOME, PS_META)');
      Query.Add('VALUES (:CODIGO, :DATA, :CONTRATO, :ESTADO, :NOME, :META)');
      Query.AddParam('CODIGO', Codigo);
      Query.AddParam('DATA', Date);
      Query.AddParam('CONTRATO', Projeto.Contrato);
      Query.AddParam('ESTADO', Projeto.Estado);
      Query.AddParam('NOME', Projeto.Nome);
      Query.AddParam('META', 'INICIO DO PROJETO SCRUM');
      Query.ExecSQL;
      Res.Status(THttpStatus.Created);
      oJson.AddPair('PROJETO_SCRUM', Codigo.ToString);
      Res.Send<TJSONObject>(oJson);
    except
      on E: exception do
      begin
        raise exception.Create('Erro ao inserir Projeto Scrum' + E.Message);
        Res.Status(THttpStatus.BadRequest);
        oJson.AddPair('Error', 'Projeto Scrum não informado corretamente!'+sLineBreak+e.Message);
        Res.Send<TJSONObject>(oJson);
      end
    end;
  end
  else
  begin
    Res.Status(THttpStatus.NotFound);
    oJson.AddPair('Error', 'Projeto Scrum não encontrado!');
    Res.Send<TJSONObject>(oJson);
  end;
end;

class procedure TControllerScrum.PostRetrospectiva(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Query: iQuery;
  Retrospectiva: TRetrospectiva;
begin
  if Req.Body <> '' then
  begin
    Retrospectiva := TRetrospectiva.FromJson(Req.Body);
    Query   := TDatabase.Query;
    if Retrospectiva.codigo = 0 then
      Retrospectiva.codigo := GeraCodigo('RETROSPECTIVA', 'RET_CODIGO');
    Query.Clear;
    Query.Add('UPDATE OR INSERT INTO RETROSPECTIVA (RET_CODIGO, RET_DATA, RET_PS, RET_ANALISE_INTEGRANTES, RET_ANALISE_PROCESSO, RET_ANALISE_FERRAMENTAS, RET_ANALISE_COMUNICACAO, RET_ANALISE_PRONTO)');
    Query.Add('VALUES (:CODIGO, :DATA, :PS, :ANALISE_INTEGRANTES, :ANALISE_PROCESSO, :ANALISE_FERRAMENTAS, :ANALISE_COMUNICACAO, :ANALISE_PRONTO)');
    Query.Add('MATCHING (RET_CODIGO)');
    Query.AddParam('CODIGO', Retrospectiva.codigo);
    Query.AddParam('DATA', Date);
    Query.AddParam('PS', Retrospectiva.projeto_scrum);
    Query.AddParam('ANALISE_INTEGRANTES', Retrospectiva.analise_integrantes);
    Query.AddParam('ANALISE_PROCESSO', Retrospectiva.analise_processo);
    Query.AddParam('ANALISE_FERRAMENTAS', Retrospectiva.analise_ferramentas);
    Query.AddParam('ANALISE_COMUNICACAO', Retrospectiva.analise_comunicacao);
    Query.AddParam('ANALISE_PRONTO', Retrospectiva.analise_pronto);
    Query.ExecSQL;
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('Retrospectiva', TJSONNumber.Create(Retrospectiva.codigo))).Status(THTTPStatus.Created);
  end else
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('error', 'Dados não informados')).Status(THTTPStatus.BadRequest);
end;

class procedure TControllerScrum.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aJson: TJSONArray;
  Query: iQuery;
  Dados: TDataSource;
begin
  // componentes de conexao
  Query := TDatabase.Query;
  aJson := TJSONArray.Create;
  Query.Open('SELECT PS_CODIGO, CLI_NOME, PS_NOME, CONT_CODIGO FROM PROJETO_SCRUM INNER JOIN CONTRATOS ON PS_CONT = CONT_CODIGO INNER JOIN CLIENTES ON CONT_CLI = CLI_CODIGO ORDER BY CLI_NOME');
  Dados := TDataSource.Create(nil);
  Dados.DataSet := Query.DataSet;
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('ps_codigo', TJSONNumber.Create(Dados.DataSet.FieldByName('PS_CODIGO').AsInteger));
    oJson.AddPair('cli_nome', Dados.DataSet.FieldByName('CLI_NOME').AsString);
    oJson.AddPair('ps_nome',  Dados.DataSet.FieldByName('PS_NOME').AsString);
    oJson.AddPair('contrato', TJSONNumber.Create(Dados.DataSet.FieldByName('CONT_CODIGO').AsInteger));
    aJson.AddElement(oJson);
    Dados.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TControllerScrum.GetEmAndamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aJson: TJSONArray;
  Query: iQuery;
  Dados: TDataSource;
begin
  // componentes de conexao
  Query := TDatabase.Query;
  Dados := TDataSource.Create(nil);
  aJson := TJSONArray.Create;
  Query.Clear;
  Query.Add('SELECT DISTINCT PS_CODIGO, CLI_NOME, PS_NOME, CONT_CODIGO, BS_ESTADO, BS_DATA_ENT_PROG,');
  Query.Add('(SELECT FIRST 1 FUN_NOME FROM FUNCIONARIOS JOIN BACKLOG_P ON BP_FUN = FUN_CODIGO');
  Query.Add('JOIN BS_BP ON BB_BS = BS_CODIGO AND BB_BP = BP_CODIGO ORDER BY BB_CODIGO) FUNCIONARIO');
  Query.Add('FROM PROJETO_SCRUM');
  Query.Add('JOIN BACKLOG_SPRINT ON PS_CODIGO = BS_PS');
  Query.Add('JOIN CONTRATOS ON CONT_CODIGO = PS_CONT');
  Query.Add('JOIN CLIENTES ON CONT_CLI = CLI_CODIGO WHERE BS_ESTADO <> ''ENTREGUE'' ORDER BY BS_DATA_ENT_PROG');
  Query.Open();
  Dados.DataSet := Query.DataSet;
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('ps_codigo', TJSONNumber.Create(Dados.DataSet.FieldByName('PS_CODIGO').AsInteger));
    oJson.AddPair('cli_nome', Dados.DataSet.FieldByName('CLI_NOME').AsString);
    oJson.AddPair('ps_nome',  Dados.DataSet.FieldByName('PS_NOME').AsString);
    oJson.AddPair('contrato', TJSONNumber.Create(Dados.DataSet.FieldByName('CONT_CODIGO').AsInteger));
    oJson.AddPair('estado', Dados.DataSet.FieldByName('BS_ESTADO').AsString);
    oJson.AddPair('data_entrega', Dados.DataSet.FieldByName('BS_DATA_ENT_PROG').AsString);
    oJson.AddPair('funcionario', Dados.DataSet.FieldByName('FUNCIONARIO').AsString);
    aJson.AddElement(oJson);
    Dados.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TControllerScrum.GetPrazoSprint(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aJson: TJSONArray;
  Query: iQuery;
  Dados: TDataSource;
begin
  // componentes de conexao
  Query := TDatabase.Query;
  Dados := TDataSource.Create(nil);
  aJson := TJSONArray.Create;
  Query.Open('SELECT PS_CODIGO, PS_DESCRICAO, PS_DIAS FROM PRAZO_SPRINT ORDER BY PS_CODIGO');
  Dados.DataSet := Query.DataSet;
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('codigo', TJSONNumber.Create(Dados.DataSet.FieldByName('PS_CODIGO').AsInteger));
    oJson.AddPair('descricao', Dados.DataSet.FieldByName('PS_DESCRICAO').AsString);
    oJson.AddPair('dias', TJSONNumber.Create(Dados.DataSet.FieldByName('PS_DIAS').AsInteger));
    aJson.AddElement(oJson);
    Dados.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TControllerScrum.GetRetrospectiva(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  Query: iQuery;
  Dados: TDataSource;
  Codigo: Integer;
begin
  // componentes de conexao
  if Req.Params.Count = 0 then
    raise Exception.Create('Codigo do projeto scrum não passado!');
  Codigo := Req.Params.Items['codigo'].ToInteger;
  Query := TDatabase.Query;
  Dados := TDataSource.Create(nil);
  Query.Add('SELECT RET_CODIGO, RET_DATA, RET_PS, RET_ANALISE_INTEGRANTES, RET_ANALISE_PROCESSO, RET_ANALISE_FERRAMENTAS,');
  Query.Add('RET_ANALISE_COMUNICACAO, RET_ANALISE_PRONTO FROM RETROSPECTIVA WHERE RET_PS = :CODIGO');
  Query.AddParam('CODIGO', Codigo);
  Query.Open();
  Dados.DataSet := Query.DataSet;
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('codigo', TJSONNumber.Create(Dados.DataSet.FieldByName('RET_CODIGO').AsInteger));
    oJson.AddPair('data', Dados.DataSet.FieldByName('RET_DATA').AsString);
    oJson.AddPair('projeto_scrum', TJSONNumber.Create(Dados.DataSet.FieldByName('RET_PS').AsInteger));
    oJson.AddPair('analise_integrantes', Dados.DataSet.FieldByName('RET_ANALISE_INTEGRANTES').AsString);
    oJson.AddPair('analise_processo', Dados.DataSet.FieldByName('RET_ANALISE_PROCESSO').AsString);
    oJson.AddPair('analise_ferramentas', Dados.DataSet.FieldByName('RET_ANALISE_FERRAMENTAS').AsString);
    oJson.AddPair('analise_comunicacao', Dados.DataSet.FieldByName('RET_ANALISE_COMUNICACAO').AsString);
    oJson.AddPair('analise_pronto', Dados.DataSet.FieldByName('RET_ANALISE_PRONTO').AsString);
    Dados.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONObject>(oJson);
end;

class procedure TControllerScrum.Registrar(App: THorse);
begin
  App.Get('projetos_scrum', Get);
  App.Get('prazo_sprint', GetPrazoSprint);
  App.Get('projetos_scrum/EmAndamento', GetEmAndamento);
  App.Post('projetos_scrum', Post);
  App.Post('projetos_scrum/Retrospectiva', PostRetrospectiva);
  App.Get('projetos_scrum/Retrospectiva/:codigo', GetRetrospectiva);
end;

end.
