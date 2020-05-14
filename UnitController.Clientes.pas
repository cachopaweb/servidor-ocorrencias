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
  UnitFuncoesComuns;


type
  TControllerClientes = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    Conexao := Fabrica.Conexao('portalsoft.sytes.net:/home/Portal/Dados/PORTAL.FDB');
    Query := Fabrica.Query(Conexao);
    Dados := TDataSource.Create(nil);
    Query.DataSource(Dados);
    Query.Add('SELECT CONT_CODIGO, CLI_NOME, CLI_CELULAR, CLI_FONE, CLI_RAZAO, CLI_EMAIL FROM CLIENTES JOIN CONTRATOS ON CONT_CLI = CLI_CODIGO AND CONT_ESTADO = 1');
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

class procedure TControllerClientes.Registrar(App: THorse);
begin
  App.Get('/Clientes', Get);
end;

end.
