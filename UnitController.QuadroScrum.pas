unit UnitController.QuadroScrum;

interface

uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  DB,
  UnitConnection.Model.Interfaces,
  UnitOcorrencia.Model,
  UnitQuadroScrum.Model,
  UnitFuncoesComuns, UnitConstantes;

type
  TPrioridade = (Baixa = 1, Media, Alta);

  THelperPrioridade = record helper for TPrioridade
    function toColorsLabel: string;
  end;

  TControllerQuadroScrum = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class function strToPrioridade(Value: string): TPrioridade;
  private
    class function MontaBacklogs(CodSprint: integer): TArray<TBacklog>;
  end;

implementation

{ TControllerQuadroScrum }

uses UnitDatabase;

class procedure TControllerQuadroScrum.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson        : TJSONObject;
  aJson        : TJSONArray;
  Query        : iQuery;
  QuadroScrum  : TQuadroScrum;
  ListaItens   : TArray<TItem>;
  ListaCards   : TArray<TCards>;
  ListaBacklogs: TArray<TBacklog>;
  ListaImagens : TArray<TImagem>;
  indiceItens  : integer;
  indiceCards  : integer;
  JsonString   : string;
  projeto_id   : string;
begin
  aJson       := TJSONArray.Create;
  QuadroScrum := TQuadroScrum.Create;
  try
    projeto_id := Req.Query.Items['projeto_id'];
    if projeto_id = '' then
      raise Exception.Create('Codigo do projeto Scrum obrigatório');
    // componentes de conexao
    Query   := TDatabase.Query();
    Query.Add('SELECT BP_CODIGO, BP_DESCRICAO, BP_NECESSIDADE, FUN_AVATAR, BP_OCORRENCIA, BP_TITULO ');
    Query.Add('FROM BACKLOG_P JOIN FUNCIONARIOS ON BP_FUN = FUN_CODIGO ');
    Query.Add('WHERE BP_PS = :COD_PROJETO AND BP_CODIGO NOT IN (SELECT BB_BP FROM BS_BP WHERE BB_BP = BP_CODIGO) ORDER BY BP_CODIGO');
    Query.AddParam('COD_PROJETO', projeto_id);
    Query.Open;
    indiceItens := 0;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]               := TItem.Create;
    ListaItens[indiceItens].Title         := 'Backlog';
    ListaItens[indiceItens].CreateBacklog := True;
    indiceCards                           := 0;
    Query.DataSet.First;
    while not Query.DataSet.Eof do
    begin
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]            := TCards.Create;
      ListaCards[indiceCards].Labels     := [TPrioridade(Query.DataSet.FieldByName('BP_NECESSIDADE').AsInteger).toColorsLabel];
      ListaCards[indiceCards].Id         := Query.DataSet.FieldByName('BP_CODIGO').AsInteger;
      ListaCards[indiceCards].Content    := Query.DataSet.FieldByName('BP_DESCRICAO').AsString;
      ListaCards[indiceCards].User       := Query.DataSet.FieldByName('FUN_AVATAR').AsString;
      ListaCards[indiceCards].Ocorrencia := Query.DataSet.FieldByName('BP_OCORRENCIA').AsInteger;
      ListaCards[indiceCards].Titulo     := Query.DataSet.FieldByName('BP_TITULO').AsString;
      ListaItens[indiceItens].Cards      := ListaCards;
      Inc(indiceCards);
      Query.DataSet.Next;
    end;
    Inc(indiceItens);
    // Sprint a fazer
    Query.Clear;
    Query.Add('SELECT BS_CODIGO, BS_DESCRICAO, BS_DATA_SPRINT, BS_DATA_ENT_PROG, ORD_CODIGO');
    Query.Add('FROM BACKLOG_SPRINT LEFT JOIN ORDENS ON BS_CODIGO = ORD_SPRINT WHERE BS_PS = :COD_PROJETO AND BS_ESTADO = :ESTADO');
    Query.Add('ORDER BY BS_CODIGO');
    Query.AddParam('COD_PROJETO', projeto_id);
    Query.AddParam('ESTADO', 'A FAZER');
    Query.Open;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]              := TItem.Create;
    ListaItens[indiceItens].Title        := 'Sprint A Fazer';
    ListaItens[indiceItens].CreateSprint := True;
    ListaItens[indiceItens].EhSprint     := True;
    indiceCards                          := 0;
    Query.DataSet.First;
    while not Query.DataSet.Eof do
    begin
      ListaBacklogs := [];
      ListaImagens  := [];
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]             := TCards.Create;
      ListaCards[indiceCards].Labels      := [];
      ListaCards[indiceCards].Id          := Query.DataSet.FieldByName('BS_CODIGO').AsInteger;
      ListaCards[indiceCards].Content     := Query.DataSet.FieldByName('BS_DESCRICAO').AsString;
      ListaCards[indiceCards].DataEntrega := Query.DataSet.FieldByName('BS_DATA_ENT_PROG').AsString;
      ListaCards[indiceCards].Data        := Query.DataSet.FieldByName('BS_DATA_SPRINT').AsString;
      ListaCards[indiceCards].Ordem       := Query.DataSet.FieldByName('ORD_CODIGO').AsInteger;
      ListaBacklogs                       := MontaBacklogs(Query.DataSet.FieldByName('BS_CODIGO').AsInteger);
      ListaCards[indiceCards].Backlogs    := ListaBacklogs;
      ListaItens[indiceItens].Cards       := ListaCards;
      Inc(indiceCards);
      Query.DataSet.Next;
    end;
    Inc(indiceItens);
    // Sprint em andamento
    Query.Clear;
    Query.Add('SELECT BS_CODIGO, BS_DESCRICAO, BS_DATA_SPRINT, BS_DATA_ENT_PROG, ORD_CODIGO');
    Query.Add('FROM BACKLOG_SPRINT LEFT JOIN ORDENS ON BS_CODIGO = ORD_SPRINT WHERE BS_PS = :COD_PROJETO AND BS_ESTADO = :ESTADO');
    Query.Add('ORDER BY BS_CODIGO');
    Query.AddParam('COD_PROJETO', projeto_id);
    Query.AddParam('ESTADO', 'EM ANDAMENTO');
    Query.Open;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]          := TItem.Create;
    ListaItens[indiceItens].Title    := 'Sprint Em Andamento';
    ListaItens[indiceItens].EhSprint := True;
    indiceCards                      := 0;
    Query.DataSet.First;
    while not Query.DataSet.Eof do
    begin
      ListaBacklogs := [];
      ListaImagens  := [];
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]             := TCards.Create;
      ListaCards[indiceCards].Labels      := [];
      ListaCards[indiceCards].Id          := Query.DataSet.FieldByName('BS_CODIGO').AsInteger;
      ListaCards[indiceCards].Content     := Query.DataSet.FieldByName('BS_DESCRICAO').AsString;
      ListaCards[indiceCards].DataEntrega := Query.DataSet.FieldByName('BS_DATA_ENT_PROG').AsString;
      ListaCards[indiceCards].Data        := Query.DataSet.FieldByName('BS_DATA_SPRINT').AsString;
      ListaCards[indiceCards].Ordem       := Query.DataSet.FieldByName('ORD_CODIGO').AsInteger;
      ListaBacklogs                       := MontaBacklogs(Query.DataSet.FieldByName('BS_CODIGO').AsInteger);
      ListaCards[indiceCards].Backlogs    := ListaBacklogs;
      ListaItens[indiceItens].Cards       := ListaCards;
      Inc(indiceCards);
      Query.DataSet.Next;
    end;
    Inc(indiceItens);
    // Sprint revisão/aprovação
    Query.Clear;
    Query.Add('SELECT BS_CODIGO, BS_DESCRICAO, BS_DATA_SPRINT, BS_DATA_ENT_PROG, ORD_CODIGO');
    Query.Add('FROM BACKLOG_SPRINT LEFT JOIN ORDENS ON BS_CODIGO = ORD_SPRINT WHERE BS_PS = :COD_PROJETO AND BS_ESTADO = :ESTADO');
    Query.Add('ORDER BY BS_CODIGO');
    Query.AddParam('COD_PROJETO', projeto_id);
    Query.AddParam('ESTADO', 'REVISAO');
    Query.Open;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]          := TItem.Create;
    ListaItens[indiceItens].Title    := 'Sprint Revisão/Aprovação';
    ListaItens[indiceItens].EhSprint := True;
    indiceCards                      := 0;
    Query.DataSet.First;
    while not Query.DataSet.Eof do
    begin
      ListaBacklogs := [];
      ListaImagens  := [];
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]             := TCards.Create;
      ListaCards[indiceCards].Labels      := [];
      ListaCards[indiceCards].Id          := Query.DataSet.FieldByName('BS_CODIGO').AsInteger;
      ListaCards[indiceCards].Content     := Query.DataSet.FieldByName('BS_DESCRICAO').AsString;
      ListaCards[indiceCards].DataEntrega := Query.DataSet.FieldByName('BS_DATA_ENT_PROG').AsString;
      ListaCards[indiceCards].Data        := Query.DataSet.FieldByName('BS_DATA_SPRINT').AsString;
      ListaCards[indiceCards].Ordem       := Query.DataSet.FieldByName('ORD_CODIGO').AsInteger;
      ListaBacklogs                       := MontaBacklogs(Query.DataSet.FieldByName('BS_CODIGO').AsInteger);
      ListaCards[indiceCards].Backlogs    := ListaBacklogs;
      ListaItens[indiceItens].Cards       := ListaCards;
      Inc(indiceCards);
      Query.DataSet.Next;
    end;
    Inc(indiceItens);
    // Sprint Entregue
    Query.Clear;
    Query.Add('SELECT BS_CODIGO, BS_DESCRICAO, BS_DATA_SPRINT, BS_DATA_ENT_PROG, ORD_CODIGO');
    Query.Add('FROM BACKLOG_SPRINT LEFT JOIN ORDENS ON BS_CODIGO = ORD_SPRINT WHERE BS_PS = :COD_PROJETO AND BS_ESTADO = :ESTADO');
    Query.Add('ORDER BY BS_CODIGO');
    Query.AddParam('COD_PROJETO', projeto_id);
    Query.AddParam('ESTADO', 'ENTREGUE');
    Query.Open;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]          := TItem.Create;
    ListaItens[indiceItens].Title    := 'Sprint Entregue';
    ListaItens[indiceItens].EhSprint := True;
    indiceCards                      := 0;
    Query.DataSet.First;
    while not Query.DataSet.Eof do
    begin
      ListaBacklogs := [];
      ListaImagens  := [];
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]             := TCards.Create;
      ListaCards[indiceCards].Labels      := [];
      ListaCards[indiceCards].Id          := Query.DataSet.FieldByName('BS_CODIGO').AsInteger;
      ListaCards[indiceCards].Content     := Query.DataSet.FieldByName('BS_DESCRICAO').AsString;
      ListaCards[indiceCards].DataEntrega := Query.DataSet.FieldByName('BS_DATA_ENT_PROG').AsString;
      ListaCards[indiceCards].Data        := Query.DataSet.FieldByName('BS_DATA_SPRINT').AsString;
      ListaCards[indiceCards].Ordem       := Query.DataSet.FieldByName('ORD_CODIGO').AsInteger;
      ListaBacklogs                       := MontaBacklogs(Query.DataSet.FieldByName('BS_CODIGO').AsInteger);
      ListaCards[indiceCards].Backlogs    := ListaBacklogs;
      ListaItens[indiceItens].Cards       := ListaCards;
      Inc(indiceCards);
      Query.DataSet.Next;
    end;
    QuadroScrum.Items := ListaItens;
    Res.Status(200);
    JsonString := QuadroScrum.ToJsonString;
    oJson      := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(JsonString), 0) as TJSONObject;
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

class function TControllerQuadroScrum.MontaBacklogs(CodSprint: integer): TArray<TBacklog>;
var
  indiceBacklogs: integer;
  Query         : iQuery;
begin
  /// //
  indiceBacklogs := 0;
  Query          := TDatabase.Query();
  Query.Clear;
  Query.Add('SELECT BP_CODIGO, BP_DESCRICAO, BP_NECESSIDADE, FUN_AVATAR, BB_CODIGO, BP_OCORRENCIA, BP_TITULO');
  Query.Add('FROM BS_BP LEFT JOIN BACKLOG_P ON BB_BP = BP_CODIGO');
  Query.Add('LEFT JOIN FUNCIONARIOS ON BP_FUN = FUN_CODIGO');
  Query.Add('WHERE BB_BS = :COD_SPRINT');
  Query.Add('ORDER BY BP_CODIGO');
  Query.AddParam('COD_SPRINT', CodSprint);
  Query.Open;
  Query.DataSet.First;
  while not Query.DataSet.Eof do
  begin
    SetLength(Result, indiceBacklogs + 1);
    Result[indiceBacklogs]            := TBacklog.Create;
    Result[indiceBacklogs].Labels     := [TPrioridade(Query.DataSet.FieldByName('BP_NECESSIDADE').AsInteger).toColorsLabel];
    Result[indiceBacklogs].Id         := Query.DataSet.FieldByName('BP_CODIGO').AsInteger;
    Result[indiceBacklogs].Content    := Query.DataSet.FieldByName('BP_DESCRICAO').AsString;
    Result[indiceBacklogs].User       := Query.DataSet.FieldByName('FUN_AVATAR').AsString;
    Result[indiceBacklogs].bb_codigo  := Query.DataSet.FieldByName('BB_CODIGO').AsInteger;
    Result[indiceBacklogs].Ocorrencia := Query.DataSet.FieldByName('BP_OCORRENCIA').AsInteger;
    Result[indiceBacklogs].Titulo     := Query.DataSet.FieldByName('BP_TITULO').AsString;
    Inc(indiceBacklogs);
    Query.DataSet.Next;
  end;
end;

{ THelperPrioridade }

function THelperPrioridade.toColorsLabel: string;
begin
  Result := EnumeradoToStr(Self, ['green', 'blue', 'red'], [Baixa, Media, Alta]);
end;

end.
