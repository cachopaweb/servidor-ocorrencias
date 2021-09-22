unit UnitController.Backlog.Produto;

interface
uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  Horse.Commons,
  DB,
  UnitConnection.Model.Interfaces,
  UnitFuncoesComuns, UnitConstantes;


type
  TControllerBacklogProduto = class
    class procedure Registrar(App: THorse);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerBacklogProduto }

uses UnitBacklog.Produto.Model, UnitDatabase;

class procedure TControllerBacklogProduto.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  Backlog: TBacklogProduto;
  Codigo: integer;
  Query: iQuery;
begin
  // componentes de conexao
  Query := TDatabase.Query();
  oJson := TJSONObject.Create;
  if Req.Body <> '' then
  begin
    Backlog := TBacklogProduto.FromJsonString(Req.Body);
    try
      Codigo := GeraCodigo('BACKLOG_P', 'BP_CODIGO');
      Query.Add('INSERT INTO BACKLOG_P (BP_CODIGO, BP_DESCRICAO, BP_NECESSIDADE, BP_DATA_BACKLOG, BP_PS, BP_ESTADO, BP_DATA_ENT, BP_FUN, BP_OCORRENCIA, BP_TITULO)');
      Query.Add('VALUES (:CODIGO, :DESCRICAO, :NECESSIDADE, :DATA_BACKLOG, :PS, :ESTADO, :DATA_ENT, :FUN, :COD_OCORRENCIA, :TITULO)');
      Query.AddParam('CODIGO', Codigo);
      Query.AddParam('DESCRICAO', Backlog.Descricao, true);
      Query.AddParam('NECESSIDADE', Backlog.Necessidade);
      Query.AddParam('DATA_BACKLOG', Date);
      Query.AddParam('ESTADO', Backlog.Estado);
      Query.AddParam('PS', Backlog.Cod_Projeto_Scrum);
      Query.AddParam('DATA_ENT', Backlog.DataEntrega);
      Query.AddParam('FUN', Backlog.Funcionario);
      Query.AddParam('COD_OCORRENCIA', Backlog.Ocorrencia);
      Query.AddParam('TITULO', Backlog.Titulo);
      Query.ExecSQL;
      oJson.AddPair('BACKLOG', Codigo.ToString);
      Res.Send<TJSONObject>(oJson).Status(THTTPStatus.Created);
    except
      on E: exception do
      begin
        raise exception.Create('Erro ao inserir backlog' + E.Message);
        Res.Status(THTTPStatus.BadRequest);
        oJson.AddPair('Error', 'Backlog não informado corretamente!'+sLineBreak+e.Message);
        Res.Send<TJSONObject>(oJson);
      end
    end;
  end
  else
  begin
    Res.Status(THTTPStatus.BadRequest);
    oJson.AddPair('Error', 'Backlog não encontrado!');
    Res.Send<TJSONObject>(oJson);
  end;
end;

class procedure TControllerBacklogProduto.Registrar(App: THorse);
begin
  App.Post('/backlog', Post);
end;

end.
