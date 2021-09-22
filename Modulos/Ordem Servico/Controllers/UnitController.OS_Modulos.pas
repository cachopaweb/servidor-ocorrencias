unit UnitController.OS_Modulos;

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
  TControllerOSModulos = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerOSModulos }

uses UnitDatabase;

class procedure TControllerOSModulos.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aJson: TJSONArray;
  Query: iQuery;
begin
  aJson := TJSONArray.Create;
  try
    // componentes de conexao
    Query := TDatabase.Query();
    Query.Add('SELECT OM_CODIGO, CASE OM_SISTEMA WHEN ''O'' THEN ''OPERACIONAL'' ELSE ''FINANCEIRO'' END SISTEMA, OM_MODULO FROM OS_MODULO');
    Query.Add('ORDER BY OM_CODIGO');
    Query.Open;
    Query.DataSet.First;
    while not Query.DataSet.Eof do
    begin
      oJson := TJSONObject.Create;
      oJson.AddPair('codigo', Query.DataSet.FieldByName('OM_CODIGO').AsString);
      oJson.AddPair('sistema', Query.DataSet.FieldByName('SISTEMA').AsString);
      oJson.AddPair('modulo', Query.DataSet.FieldByName('OM_MODULO').AsString);
      aJson.AddElement(oJson);
      Query.DataSet.Next;
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
