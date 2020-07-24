unit UnitController.QuadroScrum;

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
  TPrioridade = (Baixa, Media, Alta);

  THelperPrioridade = record helper for TPrioridade
    function toColorsLabel: string;
  end;

  TControllerQuadroScrum = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class function strToPrioridade(Value: string): TPrioridade;
  end;

implementation

{ TControllerQuadroScrum }

uses UnitQuadroScrum.Model;

class procedure TControllerQuadroScrum.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson      : TJSONObject;
  aJson      : TJSONArray;
  Fabrica    : iFactoryConexao;
  Conexao    : iConexao;
  Query      : iQuery;
  Dados      : TDataSource;
  QuadroScrum: TQuadroScrum;
  ListaItens : TArray<TItem>;
  ListaCards : TArray<TCards>;
  indiceItens: integer;
  indiceCards: integer;
  JsonString : string;
  projeto_id : string;
begin
  aJson       := TJSONArray.Create;
  QuadroScrum := TQuadroScrum.Create;
  try
    projeto_id := Req.Query.Items['projeto_id'];
    if projeto_id = '' then
      raise Exception.Create('Codigo do projeto Scrum obrigatório');
    // componentes de conexao
    Fabrica := TFactoryConexaoFireDAC.New;
    Conexao := Fabrica.Conexao(TConstants.BancoDados);
    Query   := Fabrica.Query(Conexao);
    Dados   := TDataSource.Create(nil);
    Query.DataSource(Dados);
    Query.Add('SELECT BP_CODIGO, BP_DESCRICAO, BP_NECESSIDADE, FUN_AVATAR ');
    Query.Add('FROM BACKLOG_P JOIN FUNCIONARIOS ON BP_FUN = FUN_CODIGO ');
    Query.Add('WHERE BP_PS = :COD_PROJETO ORDER BY BP_CODIGO');
    Query.AddParam('COD_PROJETO', projeto_id);
    Query.Open;
    indiceItens := 0;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]           := TItem.Create;
    ListaItens[indiceItens].Title     := 'Backlog';
    ListaItens[indiceItens].CreateBacklog := True;
    indiceCards                       := 0;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]         := TCards.Create;
      ListaCards[indiceCards].Labels  := [TControllerQuadroScrum.strToPrioridade(Dados.DataSet.FieldByName('BP_NECESSIDADE').AsString).toColorsLabel];
      ListaCards[indiceCards].Id      := Dados.DataSet.FieldByName('BP_CODIGO').AsInteger;
      ListaCards[indiceCards].Content := Dados.DataSet.FieldByName('BP_DESCRICAO').AsString;
      ListaCards[indiceCards].User    := Dados.DataSet.FieldByName('FUN_AVATAR').AsString;
      ListaItens[indiceItens].Cards   := ListaCards;
      Inc(indiceCards);
      Dados.DataSet.Next;
    end;
    Inc(indiceItens);
    //Sprint a fazer
    Query.Clear;
    Query.Add('SELECT BS_CODIGO, BS_CONTEUDO, BS_DESCRICAO');
    Query.Add('FROM BACKLOG_SPRINT WHERE BS_PS = :COD_PROJETO AND BS_ESTADO = :ESTADO');
    Query.Add('ORDER BY BS_CODIGO');
    Query.AddParam('COD_PROJETO', projeto_id);
    Query.AddParam('ESTADO', 'ABERTO');
    Query.Open;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]           := TItem.Create;
    ListaItens[indiceItens].Title     := 'Sprint A Fazer';
    ListaItens[indiceItens].CreateSprint := True;
    indiceCards                       := 0;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]         := TCards.Create;
      ListaCards[indiceCards].Labels  := [];
      ListaCards[indiceCards].Id      := Dados.DataSet.FieldByName('BS_CODIGO').AsInteger;
      ListaCards[indiceCards].Content := Dados.DataSet.FieldByName('BS_DESCRICAO').AsString;
      ListaItens[indiceItens].Cards   := ListaCards;
      Inc(indiceCards);
      Dados.DataSet.Next;
    end;
    Inc(indiceItens);
    //Sprint em andamento
    Query.Clear;
    Query.Add('SELECT BS_CODIGO, BS_CONTEUDO, BS_DESCRICAO');
    Query.Add('FROM BACKLOG_SPRINT WHERE BS_PS = :COD_PROJETO AND BS_ESTADO = :ESTADO');
    Query.Add('ORDER BY BS_CODIGO');
    Query.AddParam('COD_PROJETO', projeto_id);
    Query.AddParam('ESTADO', 'EM ANDAMENTO');
    Query.Open;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]           := TItem.Create;
    ListaItens[indiceItens].Title     := 'Sprint Em Andamento';
    indiceCards                       := 0;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]         := TCards.Create;
      ListaCards[indiceCards].Labels  := [];
      ListaCards[indiceCards].Id      := Dados.DataSet.FieldByName('BS_CODIGO').AsInteger;
      ListaCards[indiceCards].Content := Dados.DataSet.FieldByName('BS_DESCRICAO').AsString;
      ListaItens[indiceItens].Cards   := ListaCards;
      Inc(indiceCards);
      Dados.DataSet.Next;
    end;
    Inc(indiceItens);
    //Sprint revisão/aprovação
    Query.Clear;
    Query.Add('SELECT BS_CODIGO, BS_CONTEUDO, BS_DESCRICAO');
    Query.Add('FROM BACKLOG_SPRINT WHERE BS_PS = :COD_PROJETO AND BS_ESTADO = :ESTADO');
    Query.Add('ORDER BY BS_CODIGO');
    Query.AddParam('COD_PROJETO', projeto_id);
    Query.AddParam('ESTADO', 'REVISAO');
    Query.Open;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]           := TItem.Create;
    ListaItens[indiceItens].Title     := 'Sprint Revisão/Aprovação';
    indiceCards                       := 0;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]         := TCards.Create;
      ListaCards[indiceCards].Labels  := [];
      ListaCards[indiceCards].Id      := Dados.DataSet.FieldByName('BS_CODIGO').AsInteger;
      ListaCards[indiceCards].Content := Dados.DataSet.FieldByName('BS_DESCRICAO').AsString;
      ListaItens[indiceItens].Cards   := ListaCards;
      Inc(indiceCards);
      Dados.DataSet.Next;
    end;
    Inc(indiceItens);
    //Sprint Entregue
    Query.Clear;
    Query.Add('SELECT BS_CODIGO, BS_CONTEUDO, BS_DESCRICAO');
    Query.Add('FROM BACKLOG_SPRINT WHERE BS_PS = :COD_PROJETO AND BS_ESTADO = :ESTADO');
    Query.Add('ORDER BY BS_CODIGO');
    Query.AddParam('COD_PROJETO', projeto_id);
    Query.AddParam('ESTADO', 'ENTREGUE');
    Query.Open;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]           := TItem.Create;
    ListaItens[indiceItens].Title     := 'Sprint Entregue';
    indiceCards                       := 0;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]         := TCards.Create;
      ListaCards[indiceCards].Labels  := [];
      ListaCards[indiceCards].Id      := Dados.DataSet.FieldByName('BS_CODIGO').AsInteger;
      ListaCards[indiceCards].Content := Dados.DataSet.FieldByName('BS_DESCRICAO').AsString;
      ListaItens[indiceItens].Cards   := ListaCards;
      Inc(indiceCards);
      Dados.DataSet.Next;
    end;
    QuadroScrum.Items := ListaItens;
    Res.Status(200);
    JsonString := QuadroScrum.ToJsonString;
    oJson      := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JsonString), 0) as TJSONObject;
    aJson      := oJson.GetValue('items') as TJSONArray;
    Res.Send<TJSONArray>(aJson);
  finally
    QuadroScrum.Free;
  end;
end;

class procedure TControllerQuadroScrum.Registrar(App: THorse);
begin
  App.Get('/quadroScrum', Get);
end;

class function TControllerQuadroScrum.strToPrioridade(Value: string): TPrioridade;
var
  ok: Boolean;
begin
  Result := StrToEnumerado(ok, Value, ['BAIXA', 'MÉDIA', 'ALTA'], [Baixa, Media, Alta]);
end;

{ THelperPrioridade }

function THelperPrioridade.toColorsLabel: string;
begin
  Result := EnumeradoToStr(Self, ['green', 'blue', 'red'], [Baixa, Media, Alta]);
end;

end.
