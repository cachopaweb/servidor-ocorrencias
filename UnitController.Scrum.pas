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
  UnitFuncoesComuns;


type
  TControllerScrum = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
  Conexao := Fabrica.Conexao('portalsoft.sytes.net:/home/Portal/Dados/PORTAL.FDB');
  Query := Fabrica.Query(Conexao);
  Dados := TDataSource.Create(nil);
  Query.DataSource(Dados);
  aJson := TJSONArray.Create;
  Query.Open('SELECT PS_CODIGO, CLI_NOME, PS_NOME FROM PROJETO_SCRUM INNER JOIN CONTRATOS ON PS_CONT = CONT_CODIGO INNER JOIN CLIENTES ON CONT_CLI = CLI_CODIGO');
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('ps_codigo', Dados.DataSet.FieldByName('PS_CODIGO').AsString);
    oJson.AddPair('cli_nome', Dados.DataSet.FieldByName('CLI_NOME').AsString);
    oJson.AddPair('ps_nome', Dados.DataSet.FieldByName('PS_NOME').AsString);
    aJson.AddElement(oJson);
    Dados.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TControllerScrum.Registrar(App: THorse);
begin
  App.Get('projetos_scrum', Get);
end;

end.
