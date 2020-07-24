unit UnitController.Backlog.Produto;

interface
uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  Horse.Commons,
  DB,
  UnitConexao.Model.Interfaces,
  UnitConexao.FireDAC.Model,
  UnitQuery.FireDAC.Model,
  UnitFactory.Conexao.FireDAC,
  UnitFuncoesComuns, UnitConstantes;


type
  TControllerBacklogProduto = class
    class procedure Registrar(App: THorse);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerBacklogProduto }

uses UnitBacklog.Produto.Model;

class procedure TControllerBacklogProduto.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  Backlog: TBacklogProduto;
  Codigo: integer;
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
  oJson := TJSONObject.Create;
  if Req.Body <> '' then
  begin
    Backlog := TBacklogProduto.FromJsonString(Req.Body);
    try
      Codigo := GeraCodigo('BACKLOG_P', 'BP_CODIGO');
      Query.Add('INSERT INTO BACKLOG_P (BP_CODIGO, BP_DESCRICAO, BP_NECESSIDADE, BP_DATA_BACKLOG, BP_PS, BP_ESTADO, BP_DATA_ENT, BP_FUN)');
      Query.Add('VALUES (:CODIGO, :DESCRICAO, :NECESSIDADE, :DATA_BACKLOG, :PS, :ESTADO, :DATA_ENT, :FUN)');
      Query.AddParam('CODIGO', Codigo);
      Query.AddParam('DESCRICAO', Backlog.Descricao);
      Query.AddParam('NECESSIDADE', Backlog.Necessidade);
      Query.AddParam('DATA_BACKLOG', Date);
      Query.AddParam('ESTADO', Backlog.Estado);
      Query.AddParam('PS', Backlog.Cod_Projeto_Scrum);
      Query.AddParam('DATA_ENT', Backlog.DataEntrega);
      Query.AddParam('FUN', Backlog.Funcionario);
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
