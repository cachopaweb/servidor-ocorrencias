unit UnitController.OS_Modulos;

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
  UnitFuncoesComuns, UnitConstantes;


type
  TControllerOSModulos = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerOSModulos }

class procedure TControllerOSModulos.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    Query.Add('SELECT OM_CODIGO, CASE OM_SISTEMA WHEN ''O'' THEN ''OPERACIONAL'' ELSE ''FINANCEIRO'' END SISTEMA, OM_MODULO FROM OS_MODULO');
    Query.Add('ORDER BY OM_CODIGO');
    Query.Open;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      oJson := TJSONObject.Create;
      oJson.AddPair('codigo', Dados.DataSet.FieldByName('OM_CODIGO').AsString);
      oJson.AddPair('sistema', Dados.DataSet.FieldByName('SISTEMA').AsString);
      oJson.AddPair('modulo', Dados.DataSet.FieldByName('OM_MODULO').AsString);
      aJson.AddElement(oJson);
      Dados.DataSet.Next;
    end;
    Res.Status(200);
    Res.Send<TJSONArray>(aJson);
  except on E: Exception do
    begin
      Res.Status(200);
      Res.Send<TJSONObject>(TJSONObject.Create.AddPair('Erro', 'Erro ao buscar OS MODULOS.'+sLineBreak+E.Message));
    end;
  end;
end;

class procedure TControllerOSModulos.Registrar(App: THorse);
begin
  App.Get('/OS_Modulos', Get);
end;

end.
