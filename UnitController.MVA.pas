unit UnitController.MVA;

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
  TControllerMVA = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerMVA }

class procedure TControllerMVA.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
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
  Query.Add('SELECT MVA_CODIGO, MG_DESCRICAO, MVA_DESCRICAO, MVA_NCM, MVA_INTERNA, MVA_CEST');
  Query.Add('FROM MARGEM_VALOR_AGREGADO INNER JOIN MVA_GRUPOS ON MG_CODIGO = MVA_GRU');
  Query.Open;
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('codigo', Dados.DataSet.FieldByName('MVA_CODIGO').AsString);
    oJson.AddPair('grupo', Dados.DataSet.FieldByName('MG_DESCRICAO').AsString);
    oJson.AddPair('descricao', Dados.DataSet.FieldByName('MVA_DESCRICAO').AsString);
    oJson.AddPair('ncm', Dados.DataSet.FieldByName('MVA_NCM').AsString);
    oJson.AddPair('mva_interna', Dados.DataSet.FieldByName('MVA_INTERNA').AsString);
    oJson.AddPair('cest', Dados.DataSet.FieldByName('MVA_CEST').AsString);
    aJson.AddElement(oJson);
    Dados.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TControllerMVA.Registrar(App: THorse);
begin
  App.Get('/mva', Get);
end;

end.
