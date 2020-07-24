unit UnitController.Ocorrencias;

interface
uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  DB,
  Variants,
  UnitConexao.Model.Interfaces,
  UnitOcorrencia.Model,
  UnitConexao.FireDAC.Model,
  UnitQuery.FireDAC.Model,
  UnitFactory.Conexao.FireDAC,
  UnitFuncoesComuns, UnitConstantes;


type
  TControllerOcorrencias = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetFinalizadas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerOcorrencias }

class procedure TControllerOcorrencias.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Ocorrencia: TOcorrencia;
  oJson: TJSONObject;
  aJson: TJSONArray;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
begin
  aJson := TJSONArray.Create;
  // componentes de conexao
  Fabrica := TFactoryConexaoFireDAC.New;
  Conexao := Fabrica.Conexao(TConstants.BancoDados);
  Query := Fabrica.Query(Conexao);
  Dados := TDataSource.Create(nil);
  Query.DataSource(Dados);
  Query.Open('SELECT CLI_NOME, OO_CODIGO, OO_DATA, OO_FUN, OO_OCORRENCIAS, OO_CONT, '
            +'OO_SYS_MOD, OO_FINALIZADA, OO_OBS, FUN_NOME, OO_FUN_ATENDENTE, (SELECT FUN_NOME FROM FUNCIONARIOS WHERE OO_FUN_ATENDENTE = FUN_CODIGO) ATENDENTE FROM OCORRENCIAS_OS INNER JOIN CONTRATOS ON OO_CONT = CONT_CODIGO '
            +'INNER JOIN CLIENTES ON CLI_CODIGO = CONT_CLI JOIN FUNCIONARIOS ON OO_FUN = FUN_CODIGO WHERE OO_FINALIZADA IS NULL');
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    Ocorrencia := TOcorrencia.Create;
    Ocorrencia.codigo         := Dados.DataSet.FieldByName('OO_CODIGO').AsInteger;
    Ocorrencia.cli_nome       := Dados.DataSet.FieldByName('CLI_NOME').AsString;
    Ocorrencia.Data           := Dados.DataSet.FieldByName('OO_DATA').AsString;
    Ocorrencia.funcionario    := Dados.DataSet.FieldByName('OO_FUN').AsInteger;
    Ocorrencia.Ocorrencia     := Dados.DataSet.FieldByName('OO_OCORRENCIAS').AsString;
    Ocorrencia.contrato       := Dados.DataSet.FieldByName('OO_CONT').AsInteger;
    Ocorrencia.Modulo_Sistema := Dados.DataSet.FieldByName('OO_SYS_MOD').AsInteger;
    Ocorrencia.Obs            := Dados.DataSet.FieldByName('OO_OBS').AsString;
    Ocorrencia.Finalizada     := Dados.DataSet.FieldByName('OO_FINALIZADA').AsString;
    Ocorrencia.fun_nome       := Dados.DataSet.FieldByName('FUN_NOME').AsString;
    Ocorrencia.atendente      := Dados.DataSet.FieldByName('OO_FUN_ATENDENTE').AsInteger;
    Ocorrencia.fun_atendente  := Dados.DataSet.FieldByName('ATENDENTE').AsString;
    oJson := TJSONObject.ParseJSONValue(TEncoding.ANSI.GetBytes(Ocorrencia.ToJsonString), 0) as TJSONObject;
    aJson.AddElement(oJson);
    Dados.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TControllerOcorrencias.GetFinalizadas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Ocorrencia: TOcorrencia;
  oJson: TJSONObject;
  aJson: TJSONArray;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
  Cliente: Integer;
begin
  aJson := TJSONArray.Create;
  // componentes de conexao
  Fabrica := TFactoryConexaoFireDAC.New;
  Conexao := Fabrica.Conexao(TConstants.BancoDados);
  Query := Fabrica.Query(Conexao);
  Dados := TDataSource.Create(nil);
  Query.DataSource(Dados);
  Query.Add('SELECT FIRST 50 CLI_NOME, OO_CODIGO, OO_DATA, OO_FUN, OO_OCORRENCIAS, OO_CONT, OO_DATA_FINALIZADA,');
  Query.Add('OO_SYS_MOD, OO_FINALIZADA, OO_OBS, FUN_NOME, OO_FUN_ATENDENTE,');
  Query.Add('(SELECT FUN_NOME FROM FUNCIONARIOS WHERE OO_FUN_ATENDENTE = FUN_CODIGO) ATENDENTE,');
  Query.Add('CASE WHEN ORD_CODIGO > 0 THEN ''SIM'' ELSE ''NAO'' END ABRIU_OS');
  Query.Add('FROM OCORRENCIAS_OS INNER JOIN CONTRATOS ON OO_CONT = CONT_CODIGO');
  Query.Add('INNER JOIN CLIENTES ON CLI_CODIGO = CONT_CLI JOIN FUNCIONARIOS ON OO_FUN = FUN_CODIGO');
  Query.Add('LEFT JOIN ORDENS ON ORD_OCO = OO_CODIGO');
  Query.Add('WHERE OO_FINALIZADA = ''S''');
  if Req.Query.Count > 0 then
  begin
    if Req.Query.Items['cliente'] <> '' then
    begin
      Cliente := StrToInt(Req.Query.Items['cliente']);
      Query.Add('AND CLI_CODIGO = :CLIENTE');
      Query.AddParam('CLIENTE', Cliente);
    end else
    begin
      Query.Add('AND OO_DATA_FINALIZADA BETWEEN :DATA1 AND :DATA2');
      Query.AddParam('DATA1', StrToDate(Req.Query.Items['dataInicial']));
      Query.AddParam('DATA2', StrToDate(Req.Query.Items['dataFinal']));
    end;
  end;
  Query.Add('ORDER BY OO_CODIGO DESC');
  Query.Open();
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    Ocorrencia := TOcorrencia.Create;
    Ocorrencia.codigo         := Dados.DataSet.FieldByName('OO_CODIGO').AsInteger;
    Ocorrencia.cli_nome       := Dados.DataSet.FieldByName('CLI_NOME').AsString;
    Ocorrencia.Data           := Dados.DataSet.FieldByName('OO_DATA').AsString;
    Ocorrencia.DataFinalizada := Dados.DataSet.FieldByName('OO_DATA_FINALIZADA').AsString;
    Ocorrencia.funcionario    := Dados.DataSet.FieldByName('OO_FUN').AsInteger;
    Ocorrencia.Ocorrencia     := Dados.DataSet.FieldByName('OO_OCORRENCIAS').AsString;
    Ocorrencia.contrato       := Dados.DataSet.FieldByName('OO_CONT').AsInteger;
    Ocorrencia.Modulo_Sistema := Dados.DataSet.FieldByName('OO_SYS_MOD').AsInteger;
    Ocorrencia.Obs            := Dados.DataSet.FieldByName('OO_OBS').AsString;
    Ocorrencia.Finalizada     := Dados.DataSet.FieldByName('OO_FINALIZADA').AsString;
    Ocorrencia.fun_nome       := Dados.DataSet.FieldByName('FUN_NOME').AsString;
    Ocorrencia.atendente      := Dados.DataSet.FieldByName('OO_FUN_ATENDENTE').AsInteger;
    Ocorrencia.fun_atendente  := Dados.DataSet.FieldByName('ATENDENTE').AsString;
    Ocorrencia.abriuOS        := Dados.DataSet.FieldByName('ABRIU_OS').AsString;
    oJson := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Ocorrencia.ToJsonString), 0) as TJSONObject;
    aJson.AddElement(oJson);
    Dados.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TControllerOcorrencias.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  Ocorrencia: TOcorrencia;
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
    Ocorrencia := TOcorrencia.FromJsonString(Req.Body);
    try
      Codigo := GeraCodigo('OCORRENCIAS_OS', 'OO_CODIGO');
      Query.Add('INSERT INTO OCORRENCIAS_OS (OO_CODIGO, OO_DATA, OO_FUN, OO_OCORRENCIAS, OO_CONT, OO_SYS_MOD, OO_FINALIZADA, OO_OBS) ');
      Query.Add('VALUES (:CODIGO, :DATA, :FUNCIONARIO, :OCORRENCIA, :CONTRATO, :MODULO, :FINALIZADA, :OBS)');
      Query.AddParam('CODIGO', Codigo);
      Query.AddParam('DATA', Date);
      Query.AddParam('FUNCIONARIO', Ocorrencia.funcionario);
      Query.AddParam('OCORRENCIA', Ocorrencia.Ocorrencia);
      Query.AddParam('CONTRATO', Ocorrencia.contrato);
      Query.AddParam('MODULO', Ocorrencia.Modulo_Sistema);
      Query.AddParam('OBS', Ocorrencia.Obs);
      if Ocorrencia.finalizada <> '' then
        Query.AddParam('FINALIZADA', Ocorrencia.Finalizada)
      else
        Query.AddParam('FINALIZADA', null);
      Query.ExecSQL;
      Res.Status(200);
      oJson.AddPair('OCORRENCIA', Codigo.ToString);
      Res.Send<TJSONObject>(oJson);
    except
      on E: exception do
      begin
        raise exception.Create('Erro ao inserir ocorrencia' + E.Message);
        Res.Status(200);
        oJson.AddPair('Error', 'Ocorrencia não informada corretamente!'+sLineBreak+e.Message);
        Res.Send<TJSONObject>(oJson);
      end
    end;
  end
  else
  begin
    Res.Status(401);
    oJson.AddPair('Error', 'Ocorrencia não encontrada!');
    Res.Send<TJSONObject>(oJson);
  end;
end;

class procedure TControllerOcorrencias.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  oJson: TJSONObject;
  CodigoOcorrencia: string;
  ocorrencia: TJSONObject;
  finalizar: string;
  fun_codigo: string;
  tempoAtendimento: string;
begin
  // componentes de conexao
  Fabrica := TFactoryConexaoFireDAC.New;
  Conexao := Fabrica.Conexao(TConstants.BancoDados);
  Query := Fabrica.Query(Conexao);
  oJson := TJSONObject.Create;
  CodigoOcorrencia := Req.Params.Items['id'];
  ocorrencia := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body), 0) as TJSONObject;
  if CodigoOcorrencia <> '' then
  begin
    try
      if ocorrencia.TryGetValue('finalizada', finalizar) then
        finalizar := ocorrencia.GetValue('finalizada').ToString.Replace('"', '');
      ocorrencia.TryGetValue('tempoAtendimento', tempoAtendimento);
      fun_codigo := ocorrencia.GetValue('fun_codigo').ToString;
      if finalizar = 'S' then
      begin
        if tempoAtendimento = '' then
          tempoAtendimento := '1';
        Query.Add('UPDATE OCORRENCIAS_OS SET OO_FUN_ATENDENTE = :FUNCIONARIO, OO_FINALIZADA = :FINALIZADA, OO_DATA_FINALIZADA = :DATA_FINALIZADA, OO_TEMPO_ATENDIMENTO = :TEMPO_ATENDIMENTO WHERE OO_CODIGO = :CODIGO');
        Query.AddParam('FUNCIONARIO', fun_codigo);
        Query.AddParam('FINALIZADA', finalizar);
        Query.AddParam('DATA_FINALIZADA', Date);
        Query.AddParam('TEMPO_ATENDIMENTO', tempoAtendimento.ToInteger);
        Query.AddParam('CODIGO', CodigoOcorrencia);
      end else
      begin
        Query.Add('UPDATE OCORRENCIAS_OS SET OO_FUN_ATENDENTE = :FUNCIONARIO, OO_DATA_ATENDIMENTO = :DATA_ATENDIMENTO WHERE OO_CODIGO = :CODIGO');
        Query.AddParam('FUNCIONARIO', fun_codigo);
        Query.AddParam('DATA_ATENDIMENTO', Date);
        Query.AddParam('CODIGO', CodigoOcorrencia);
      end;
      Query.ExecSQL;
      Res.Status(200);
      oJson.AddPair('fun_codigo', fun_codigo);
      Res.Send<TJSONObject>(oJson);
    except
      on E: exception do
      begin
        raise exception.Create('Erro ao inserir ocorrencia' + E.Message);
        Res.Status(200);
        oJson.AddPair('Ok', 'Ocorrencia não informada corretamente!'+sLineBreak+e.Message);
        Res.Send<TJSONObject>(oJson);
      end
    end;
  end;
end;

class procedure TControllerOcorrencias.Registrar(App: THorse);
begin
  App.Get('/Ocorrencias', Get);
  App.Get('/OcorrenciasFinalizadas', GetFinalizadas);
  App.Post('/Ocorrencias', Post);
  App.Put('/Ocorrencias/:id', Put);
end;

end.
