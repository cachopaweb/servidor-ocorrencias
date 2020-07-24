unit UnitController.Clientes;

interface
uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  DB,
  UnitConexao.Model.Interfaces,
  UnitOcorrencia.Model,
  UnitConexao.FireDAC.Model,
  UnitQuery.FireDAC.Model,
  UnitFactory.Conexao.FireDAC,
  UnitFuncoesComuns,
  UnitConstantes;


type
  TControllerClientes = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetContaReceber(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerClientes }

class procedure TControllerClientes.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aJson: TJSONArray;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
begin
  aJson := TJSONArray.Create;
  try
    // componentes de conexao
    Fabrica := TFactoryConexaoFireDAC.New;
    Conexao := Fabrica.Conexao(TConstants.BancoDados);
    Query := Fabrica.Query(Conexao);
    Dados := TDataSource.Create(nil);
    Query.DataSource(Dados);
    Query.Add('SELECT CONT_CODIGO, CLI_NOME, CLI_CELULAR, CLI_FONE, CLI_RAZAO, CLI_EMAIL, CLI_CNPJ_CPF, CLI_INSC_ESTADUAL FROM CLIENTES JOIN CONTRATOS ON CONT_CLI = CLI_CODIGO AND CONT_ESTADO = 1');
    Query.Add('ORDER BY CLI_NOME');
    Query.Open;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      oJson := TJSONObject.Create;
      oJson.AddPair('contrato', Dados.DataSet.FieldByName('CONT_CODIGO').AsString);
      oJson.AddPair('nome', Dados.DataSet.FieldByName('CLI_NOME').AsString);
      oJson.AddPair('celular', Dados.DataSet.FieldByName('CLI_CELULAR').AsString);
      oJson.AddPair('fone', Dados.DataSet.FieldByName('CLI_FONE').AsString);
      oJson.AddPair('razao', Dados.DataSet.FieldByName('CLI_RAZAO').AsString);
      oJson.AddPair('email', Dados.DataSet.FieldByName('CLI_EMAIL').AsString);
      oJson.AddPair('cnpj_cpf', Dados.DataSet.FieldByName('CLI_CNPJ_CPF').AsString);
      oJson.AddPair('insc_estadual', Dados.DataSet.FieldByName('CLI_INSC_ESTADUAL').AsString);
      aJson.AddElement(oJson);
      Dados.DataSet.Next;
    end;
    Res.Status(200);
    Res.Send<TJSONArray>(aJson);
  except on E: Exception do
    begin
      Res.Status(200);
      Res.Send<TJSONObject>(TJSONObject.Create.AddPair('Erro', 'Erro ao buscar clientes.'+sLineBreak+E.Message));
    end;
  end;
end;

class procedure TControllerClientes.GetContaReceber(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aJson: TJSONArray;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
  Contrato: String;
  Data1: TDateTime;
  Data2: TDateTime;
begin
  aJson := TJSONArray.Create;
  try
    Contrato := Req.Params.Items['contrato'];
    Data1 := FormatarData(Req.Query.Items['data1']);
    Data2 := FormatarData(Req.Query.Items['data2']);
    if Contrato <> '' then
    begin
      // componentes de conexao
      Fabrica := TFactoryConexaoFireDAC.New;
      Conexao := Fabrica.Conexao(TConstants.BancoDados);
      Query := Fabrica.Query(Conexao);
      Dados := TDataSource.Create(nil);
      Query.DataSource(Dados);
      Query.Add('SELECT SUM(RP.RP_DINHEIRO+RP.RP_CHEQUE) VALORPG,  REC_DUPLICATA, R.REC_CODIGO, R.REC_VALOR, R.REC_JUROS,');
      Query.Add('R.REC_DESCONTOS, R.REC_VENCIMENTO, CONT_CODIGO, C.CLI_NOME, REC_TIPO');
      Query.Add('FROM RECEBIMENTOS R, FATURAMENTOS F, CLIENTES C, REC_PGM RP, CONTRATOS');
      Query.Add('WHERE C.CLI_CODIGO = F.FAT_CLI AND F.FAT_CODIGO = R.REC_FAT AND R.REC_CODIGO = RP.RP_REC');
      Query.Add('AND R.REC_ESTADO = 1 AND (R.REC_SITUACAO >= 0 AND R.REC_SITUACAO < 2) AND CONT_CLI = CLI_CODIGO AND CONT_ESTADO = 1');
      Query.Add('AND REC_VENCIMENTO BETWEEN :DATA1 AND :DATA2 AND CONT_CODIGO = :CONTRATO');
      Query.Add('GROUP BY REC_DUPLICATA, R.REC_CODIGO, R.REC_VALOR, R.REC_JUROS, R.REC_DESCONTOS, R.REC_VENCIMENTO,');
      Query.Add('C.CLI_NOME, R.REC_DATAR, REC_TIPO, CONT_CODIGO');
      Query.AddParam('DATA1', Data1);
      Query.AddParam('DATA2', Data2);
      Query.AddParam('CONTRATO', Contrato);
      Query.Open;
      Dados.DataSet.First;
      while not Dados.DataSet.Eof do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('contrato', Dados.DataSet.FieldByName('CONT_CODIGO').AsString);
        oJson.AddPair('nome', AnsiToUtf8(Dados.DataSet.FieldByName('CLI_NOME').AsString));
        oJson.AddPair('valorpg', Dados.DataSet.FieldByName('VALORPG').AsString);
        oJson.AddPair('duplicata', Dados.DataSet.FieldByName('REC_DUPLICATA').AsString);
        oJson.AddPair('valor', Dados.DataSet.FieldByName('REC_VALOR').AsString);
        oJson.AddPair('juros', Dados.DataSet.FieldByName('REC_JUROS').AsString);
        oJson.AddPair('descontos', Dados.DataSet.FieldByName('REC_DESCONTOS').AsString);
        oJson.AddPair('vencimento', Dados.DataSet.FieldByName('REC_VENCIMENTO').AsString);
        oJson.AddPair('tipo', Dados.DataSet.FieldByName('REC_TIPO').AsString);
        aJson.AddElement(oJson);
        Dados.DataSet.Next;
      end;
      Res.Status(200);
      Res.Send<TJSONArray>(aJson);
    end else
    begin
      Res.Status(401);
      Res.Send<TJSONObject>(TJSONObject.Create.AddPair('Error','CONTRATO NÃO PASSADO COMO PARAMETRO'));
    end;
  except on E: Exception do
    begin
      Res.Status(200);
      Res.Send<TJSONObject>(TJSONObject.Create.AddPair('Erro', 'Erro ao buscar clientes.'+sLineBreak+E.Message));
    end;
  end;
end;

class procedure TControllerClientes.Registrar(App: THorse);
begin
  App.Get('/Clientes', Get);
  App.Get('/Clientes/:contrato', GetContaReceber);
end;

end.
