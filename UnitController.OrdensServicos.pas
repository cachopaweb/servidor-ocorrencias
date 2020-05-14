unit UnitController.OrdensServicos;

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
  TControllerOrdensServicos = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

uses
  UnitOrdens.Model;

{ TControllerOrdensServicos }

class procedure TControllerOrdensServicos.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Ordens: TModelOrdens;
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
  Conexao := Fabrica.Conexao('portalsoft.sytes.net:/home/Portal/Dados/PORTAL.FDB');
  Query := Fabrica.Query(Conexao);
  Dados := TDataSource.Create(nil);
  Query.DataSource(Dados);
  Query.Add('SELECT FIRST 10 ORD_CODIGO, FUN_NOME, ORD_OCORRENCIA, ORD_DATAAB, ORD_LAUDOP, CLI_NOME');
  Query.Add('FROM ORDENS INNER JOIN FUNCIONARIOS ON ORD_FUN3 = FUN_CODIGO');
  Query.Add('INNER JOIN CONTRATOS ON CONT_CODIGO = ORD_CONT');
  Query.Add('INNER JOIN CLIENTES ON CLI_CODIGO = CONT_CLI');
  Query.Add('ORDER BY ORD_CODIGO DESC');
  Query.Open;
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    Ordens := TModelOrdens.Create;
    Ordens.Codigo            := Dados.DataSet.FieldByName('ORD_CODIGO').AsInteger;
    Ordens.programador       := Dados.DataSet.FieldByName('FUN_NOME').AsString;
    Ordens.Ocorrencia        := Dados.DataSet.FieldByName('ORD_OCORRENCIA').AsString;
    Ordens.Data              := Dados.DataSet.FieldByName('ORD_DATAAB').AsDateTime;
    Ordens.laudo_programacao := Dados.DataSet.FieldByName('ORD_LAUDOP').AsString;
    Ordens.cli_nome          := Dados.DataSet.FieldByName('CLI_NOME').AsString;
    oJson := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Ordens.ToJsonString), 0) as TJSONObject;
    aJson.AddElement(oJson);
    Dados.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TControllerOrdensServicos.Registrar(App: THorse);
begin
  App.Get('/Ordens', Get);
end;

end.
