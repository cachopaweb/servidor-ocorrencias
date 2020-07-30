unit UnitController.Scrum;

interface
uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  DB,
  UnitConexao.Model.Interfaces,
  UnitConexao.FireDAC.Model,
  UnitQuery.FireDAC.Model,
  UnitFactory.Conexao.FireDAC,
  UnitFuncoesComuns, UnitConstantes;


type
  TControllerScrum = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetPrazoSprint(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerScrum }

class procedure TControllerScrum.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aJson: TJSONArray;
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
  aJson := TJSONArray.Create;
  Query.Open('SELECT PS_CODIGO, CLI_NOME, PS_NOME, CONT_CODIGO FROM PROJETO_SCRUM INNER JOIN CONTRATOS ON PS_CONT = CONT_CODIGO INNER JOIN CLIENTES ON CONT_CLI = CLI_CODIGO ORDER BY CLI_NOME');
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('ps_codigo', TJSONNumber.Create(Dados.DataSet.FieldByName('PS_CODIGO').AsInteger));
    oJson.AddPair('cli_nome', UTF8Encode(Dados.DataSet.FieldByName('CLI_NOME').AsString));
    oJson.AddPair('ps_nome', Dados.DataSet.FieldByName('PS_NOME').AsString);
    oJson.AddPair('contrato', TJSONNumber.Create(Dados.DataSet.FieldByName('CONT_CODIGO').AsInteger));
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
  aJson := TJSONArray.Create;
  Query.Open('SELECT PS_CODIGO, PS_DESCRICAO, PS_DIAS FROM PRAZO_SPRINT ORDER BY PS_CODIGO');
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

class procedure TControllerScrum.Registrar(App: THorse);
begin
  App.Get('projetos_scrum', Get);
  App.Get('prazo_sprint', GetPrazoSprint);
end;

end.
