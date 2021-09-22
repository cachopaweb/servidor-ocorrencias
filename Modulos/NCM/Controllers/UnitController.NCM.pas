unit UnitController.NCM;

interface
uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  DB,
  DataSet.Serialize,
  UnitConnection.Model.Interfaces;


type
  TControllerNCM = class
    class procedure Registrar;
    class procedure GetAllNCMs(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure CreateNCMs(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerNCM }

uses UnitDatabase;

class procedure TControllerNCM.GetAllNCMs(Req: THorseRequest; Res: THorseResponse;  Next: TProc);
var
  Query: iQuery;
begin
  Query := TDatabase.Query;
  Query.Add('SELECT NI_CODIGO, ');
  Query.Add('       NI_NCM, ');
  Query.Add('       NI_EXCECAO, ');
  Query.Add('       NI_TABELA, ');
  Query.Add('       NI_DESCRICAO, ');
  Query.Add('       NI_ALIQ_FED_NAC, ');
  Query.Add('       NI_ALIQ_FED_IMP, ');
  Query.Add('       NI_ALIQ_EST, ');
  Query.Add('       NI_ALIQ_MUN, ');
  Query.Add('       NI_CHAVE_IBPT, ');
  Query.Add('       NI_ARQ_IMPORTACAO, ');
  Query.Add('       NI_ALIQ_NAC, ');
  Query.Add('       NI_ALIQ_IMP');
  Query.Add('FROM NCM_IBPT');
  Query.Open;
  Res.Send<TJSONArray>(Query.DataSet.ToJSONArray);
end;

class procedure TControllerNCM.CreateNCMs(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin

end;

class procedure TControllerNCM.Registrar;
begin
  THorse.Get('/ncm', GetAllNCMs)
        .Post('/ncm', CreateNCMs);
end;

end.
