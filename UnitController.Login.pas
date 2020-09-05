unit UnitController.Login;

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
  TControllerLogin = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

uses
  UnitLogin.Model;

{ TControllerLogin }

class procedure TControllerLogin.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    Query.Add('SELECT FUN_CODIGO, USU_LOGIN, FUN_CATEGORIA, USU_CODIGO FROM USUARIOS JOIN FUNCIONARIOS ON USU_FUN = FUN_CODIGO AND FUN_ESTADO = ''ATIVO''');
    Query.Add('ORDER BY USU_LOGIN');
    Query.Open;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      oJson := TJSONObject.Create;
      oJson.AddPair('codigo', TJSONNumber.Create(Dados.DataSet.FieldByName('FUN_CODIGO').AsInteger));
      oJson.AddPair('login', Dados.DataSet.FieldByName('USU_LOGIN').AsString);
      oJson.AddPair('categoria', Dados.DataSet.FieldByName('FUN_CATEGORIA').AsString);
      oJson.AddPair('usu_codigo', TJSONNumber.Create(Dados.DataSet.FieldByName('USU_CODIGO').AsInteger));
      aJson.AddElement(oJson);
      Dados.DataSet.Next;
    end;
    Res.Status(200);
    Res.Send<TJSONArray>(aJson);
  except on E: Exception do
    begin
      Res.Status(200);
      Res.Send<TJSONObject>(TJSONObject.Create.AddPair('Erro', 'Erro ao buscar Usuarios.'+sLineBreak+E.Message));
    end;
  end;
end;

class procedure TControllerLogin.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  Login: TLogin;
  ListaUsuarios: TArray<TUsuarios>;
  Usuario: TUsuarios;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
begin
  oJson := TJSONObject.Create;
  if Req.Body <> '' then
  begin
    Usuario := TUsuarios.FromJsonString(Req.Body);
    // componentes de conexao
    Fabrica := TFactoryConexaoFireDAC.New;
    Conexao := Fabrica.Conexao(TConstants.BancoDados);
    Query := Fabrica.Query(Conexao);
    Dados := TDataSource.Create(nil);
    Query.DataSource(Dados);
    Query.Open(Format('SELECT USU_CODIGO FROM USUARIOS WHERE USU_LOGIN = ''%s'' AND USU_SENHA = ''%s''', [Usuario.login.ToUpper,  EnDecryptString(Usuario.senha, 236)]));
    if not Dados.DataSet.IsEmpty then
    begin
      Res.Status(200);
      oJson.AddPair('usu_codigo', dados.DataSet.FieldByName('USU_CODIGO').AsString);
      Res.Send<TJSONObject>(oJson);
    end else
    begin
      Res.Status(401);//nao autorizado
      oJson.AddPair('error', 'falha ao logar');
      Res.Send<TJSONObject>(oJson);
    end;
  end;
end;

class procedure TControllerLogin.Registrar(App: THorse);
begin
   App.Post('/login', Post);
   App.Get('/usuarios', Get);
end;

end.
