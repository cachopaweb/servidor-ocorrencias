unit UnitController.Burndown.Projeto;

interface
uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  System.DateUtils,
  Horse.Commons,
  DB,
  UnitConexao.Model.Interfaces,
  UnitConexao.FireDAC.Model,
  UnitQuery.FireDAC.Model,
  UnitFactory.Conexao.FireDAC,
  UnitFuncoesComuns, UnitConstantes;


type
  TControllerBurndownProjeto = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerBurndownProjeto }

uses UnitBacklog.Produto.Model;

class procedure TControllerBurndownProjeto.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aDatas: TJSONArray;
  aLinhaIdeal: TJSONArray;
  aLinhaReal: TJSONArray;
  Fabrica: iFactoryConexao;
  Conexao: iConexao;
  Query: iQuery;
  Dados: TDataSource;
  CodProjeto: Integer;
  Contador: Integer;
  Dias: Integer;
  SomaDias: Integer;
  i: Integer;
  Data: TDateTime;
  Tarefas: Double;
  TarefasIdeal: Double;
  NaoEntregues: Double;
begin
  // componentes de conexao
  Fabrica := TFactoryConexaoFireDAC.New;
  Conexao := Fabrica.Conexao(TConstants.BancoDados);
  Query := Fabrica.Query(Conexao);
  Dados := TDataSource.Create(nil);
  CodProjeto := Req.Params.Items['id'].ToInteger();
  Query.DataSource(Dados);
  aDatas :=  TJSONArray.Create;
  aLinhaIdeal := TJSONArray.Create;
  aLinhaReal := TJSONArray.Create;
  Query.Clear;
  Query.Add('SELECT BS_DATA_ENT_PROG, BS_DATA_SPRINT, BS_ESTADO, BS_DATA_ENT_REAL FROM BACKLOG_SPRINT WHERE BS_PS = :PROJETO');
  Query.AddParam('PROJETO', CodProjeto);
  Query.Open;
  oJson := TJSONObject.Create;
  Dados.DataSet.Last;
  Contador := Dados.DataSet.RecordCount;
  SomaDias := 0;
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    Dias := DaysBetween(Dados.DataSet.FieldByName('BS_DATA_SPRINT').AsDateTime, Dados.DataSet.FieldByName('BS_DATA_ENT_PROG').AsDateTime);
    SomaDias := SomaDias + Dias;
    Dados.DataSet.Next;
  end;
  //primeira data
  Dados.DataSet.First;
  Data := Dados.DataSet.FieldByName('BS_DATA_SPRINT').AsDateTime;
  for i := 0 to Pred(SomaDias) do
  begin
    aDatas.Add(DateToStr(Data));
    Data := IncDay(Data, 1);
  end;
  Tarefas := Contador;
  TarefasIdeal := Tarefas/SomaDias;
  for i := 0 to Pred(SomaDias) do
  begin
    aLinhaIdeal.Add(Arredondar(Tarefas, 2));
    Tarefas := Tarefas - TarefasIdeal;
  end;
  NaoEntregues := Contador;
  for i := 0 to Pred(aDatas.Count) do
  begin
    aLinhaReal.Add(NaoEntregues);
    if Dados.DataSet.Locate('BS_DATA_ENT_REAL', aDatas.Items[i].Value, []) then
    begin
      aLinhaReal.Add(aLinhaIdeal.Items[i].Value.ToDouble);
      NaoEntregues := NaoEntregues - aLinhaIdeal.Items[i].Value.ToDouble;
    end;
  end;
  oJson := TJSONObject.Create;
  oJson.AddPair('datas', aDatas);
  oJson.AddPair('ideal', aLinhaIdeal);
  oJson.AddPair('real', aLinhaReal);
  Res.Status(200);
  Res.Send<TJSONObject>(oJson);
end;

class procedure TControllerBurndownProjeto.Registrar(App: THorse);
begin
  App.Get('/Burndown/:id', Get);
end;

end.
