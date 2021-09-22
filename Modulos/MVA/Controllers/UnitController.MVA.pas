unit UnitController.MVA;

interface
uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  DB,
  UnitConnection.Model.Interfaces,
  UnitOcorrencia.Model,
  UnitFuncoesComuns, UnitConstantes;


type
  TControllerMVA = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerMVA }

uses UnitDatabase;

class procedure TControllerMVA.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aJson: TJSONArray;
  Query: iQuery;
begin
  aJson := TJSONArray.Create;
  // componentes de conexao
  Query := TDatabase.Query();
  Query.Add('SELECT MVA_CODIGO, MG_DESCRICAO, MVA_DESCRICAO, MVA_NCM, MVA_INTERNA, MVA_CEST');
  Query.Add('FROM MARGEM_VALOR_AGREGADO INNER JOIN MVA_GRUPOS ON MG_CODIGO = MVA_GRU');
  Query.Open;
  Query.DataSet.First;
  while not Query.DataSet.Eof do
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('codigo', Query.DataSet.FieldByName('MVA_CODIGO').AsString);
    oJson.AddPair('grupo', Query.DataSet.FieldByName('MG_DESCRICAO').AsString);
    oJson.AddPair('descricao', Query.DataSet.FieldByName('MVA_DESCRICAO').AsString);
    oJson.AddPair('ncm', Query.DataSet.FieldByName('MVA_NCM').AsString);
    oJson.AddPair('mva_interna', Query.DataSet.FieldByName('MVA_INTERNA').AsString);
    oJson.AddPair('cest', Query.DataSet.FieldByName('MVA_CEST').AsString);
    aJson.AddElement(oJson);
    Query.DataSet.Next;
  end;
  Res.Status(200);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TControllerMVA.Registrar(App: THorse);
begin
  App.Get('/mva', Get);
end;

end.
