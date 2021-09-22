unit UnitController.QuadroKANBAN;

interface

uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Json,
  DB,
  UnitConnection.Model.Interfaces,
  UnitFuncoesComuns,
  UnitConstantes,
  DataSet.Serialize;

type
  TPrioridade = (Baixa = 1, Media, Alta);

  THelperPrioridade = record helper for TPrioridade
    function toColorsLabel: string;
  end;

  TControllerQuadroKANBAN = class
    class procedure Registrar(App: THorse);
    class procedure GetOcorrencias(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetOrdens(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class function strToPrioridade(Value: string): TPrioridade;
  end;

implementation

{ TControllerQuadroKANBAN }

uses UnitQuadroKANBAN.Model, UnitDatabase;

class procedure TControllerQuadroKANBAN.GetOcorrencias(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aJson: TJSONArray;
  Query: iQuery;
  Dados: TDataSource;
  QuadroKanban: TQuadroKanban;
  ListaItens: TArray<TItem>;
  ListaCards: TArray<TCards>;
  indiceItens: integer;
  indiceCards: integer;
  JsonString: string;
  Cod_Funcionario: integer;
begin
  aJson       := TJSONArray.Create;
  QuadroKanban := TQuadroKanban.Create;
  try
    Cod_Funcionario := 0;
    if Req.Query.Count > 0 then
      Cod_Funcionario := Req.Query.Items['funcionario'].ToInteger;
    // A fazer
    Query := TDatabase.Query();
    Dados := TDataSource.Create(nil);
    Query.Add('SELECT OO_CODIGO, OO_OBS, CLI_NOME, OO_DATA, FUN_NOME');
    Query.Add('FROM OCORRENCIAS_OS JOIN CONTRATOS ON OO_CONT = CONT_CODIGO');
    Query.Add('JOIN CLIENTES ON CLI_CODIGO = CONT_CLI JOIN FUNCIONARIOS ON OO_FUN = FUN_CODIGO');
    Query.Add('WHERE OO_FINALIZADA IS NULL AND OO_FUN_ATENDENTE IS NULL');
    if Cod_Funcionario > 0 then
    begin
      Query.Add('AND OO_FUN = :FUNCIONARIO');
      Query.AddParam('FUNCIONARIO', Cod_Funcionario);
    end;
    Query.Open;
    Dados.DataSet := Query.DataSet;
    indiceItens   := 0;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]               := TItem.Create;
    ListaItens[indiceItens].Title         := 'A Fazer';
    ListaItens[indiceItens].CreateOcorrencia := True;
    indiceCards                           := 0;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]             := TCards.Create;
      ListaCards[indiceCards].Labels      := [];
      ListaCards[indiceCards].Id          := Dados.DataSet.FieldByName('OO_CODIGO').AsInteger;
      ListaCards[indiceCards].Content     := Dados.DataSet.FieldByName('OO_OBS').AsString;
      ListaCards[indiceCards].User        := Dados.DataSet.FieldByName('FUN_NOME').AsString;
      ListaCards[indiceCards].DataEntrega := FormatDateTime('yyyy-mm-dd', Dados.DataSet.FieldByName('OO_DATA').AsDateTime);
      ListaCards[indiceCards].Titulo      := Dados.DataSet.FieldByName('CLI_NOME').AsString;
      ListaCards[indiceCards].Ocorrencia  := Dados.DataSet.FieldByName('OO_CODIGO').AsInteger;
      ListaItens[indiceItens].Cards       := ListaCards;
      Inc(indiceCards);
      Dados.DataSet.Next;
    end;
    Inc(indiceItens);
    //Fazendo
    Query.Clear;
    Query.Add('SELECT OO_CODIGO, OO_OBS, CLI_NOME, OO_DATA, (SELECT FUN_NOME FROM FUNCIONARIOS WHERE OO_FUN_ATENDENTE = FUN_CODIGO) ATENDENTE');
    Query.Add('FROM OCORRENCIAS_OS JOIN CONTRATOS ON OO_CONT = CONT_CODIGO');
    Query.Add('JOIN CLIENTES ON CLI_CODIGO = CONT_CLI WHERE OO_FINALIZADA IS NULL AND OO_FUN_ATENDENTE IS NOT NULL');
    if Cod_Funcionario > 0 then
    begin
      Query.Add('AND OO_FUN_ATENDENTE = :FUNCIONARIO');
      Query.AddParam('FUNCIONARIO', Cod_Funcionario);
    end;
    Query.Open;
    Dados.DataSet := Query.DataSet;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]               := TItem.Create;
    ListaItens[indiceItens].Title         := 'Fazendo';
    ListaItens[indiceItens].CreateOcorrencia := True;
    indiceCards                           := 0;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]             := TCards.Create;
      ListaCards[indiceCards].Labels      := [];
      ListaCards[indiceCards].Id          := Dados.DataSet.FieldByName('OO_CODIGO').AsInteger;
      ListaCards[indiceCards].Content     := Dados.DataSet.FieldByName('OO_OBS').AsString;
      ListaCards[indiceCards].User        := Dados.DataSet.FieldByName('ATENDENTE').AsString;
      ListaCards[indiceCards].DataEntrega := FormatDateTime('yyyy-mm-dd', Dados.DataSet.FieldByName('OO_DATA').AsDateTime);
      ListaCards[indiceCards].Titulo      := Dados.DataSet.FieldByName('CLI_NOME').AsString;
      ListaCards[indiceCards].Ocorrencia  := Dados.DataSet.FieldByName('OO_CODIGO').AsInteger;
      ListaItens[indiceItens].Cards       := ListaCards;
      Inc(indiceCards);
      Dados.DataSet.Next;
    end;
    Inc(indiceItens);
    //Fazendo
    Query.Clear;
    Query.Add('SELECT OO_CODIGO, OO_OBS, CLI_NOME, OO_DATA, (SELECT FUN_NOME FROM FUNCIONARIOS WHERE OO_FUN_ATENDENTE = FUN_CODIGO) ATENDENTE, OO_DATA_FINALIZADA');
    Query.Add('FROM OCORRENCIAS_OS JOIN CONTRATOS ON OO_CONT = CONT_CODIGO');
    Query.Add('JOIN CLIENTES ON CLI_CODIGO = CONT_CLI WHERE OO_FINALIZADA IS NOT NULL');
    Query.Add('AND OO_DATA_FINALIZADA BETWEEN DATEADD(-30 DAY TO CURRENT_DATE) AND CURRENT_DATE');
    if Cod_Funcionario > 0 then
    begin
      Query.Add('AND OO_FUN_ATENDENTE = :FUNCIONARIO');
      Query.AddParam('FUNCIONARIO', Cod_Funcionario);
    end;
    Query.Open;
    Dados.DataSet := Query.DataSet;
    SetLength(ListaItens, indiceItens + 1);
    ListaItens[indiceItens]               := TItem.Create;
    ListaItens[indiceItens].Title         := 'Feito';
    ListaItens[indiceItens].CreateOcorrencia := True;
    indiceCards                           := 0;
    Dados.DataSet.First;
    while not Dados.DataSet.Eof do
    begin
      SetLength(ListaCards, indiceCards + 1);
      ListaCards[indiceCards]             := TCards.Create;
      ListaCards[indiceCards].Labels      := [];
      ListaCards[indiceCards].Id          := Dados.DataSet.FieldByName('OO_CODIGO').AsInteger;
      ListaCards[indiceCards].Content     := Dados.DataSet.FieldByName('OO_OBS').AsString;
      ListaCards[indiceCards].User        := Dados.DataSet.FieldByName('ATENDENTE').AsString;
      ListaCards[indiceCards].DataEntrega := FormatDateTime('yyyy-mm-dd', Dados.DataSet.FieldByName('OO_DATA').AsDateTime);
      ListaCards[indiceCards].Titulo      := Dados.DataSet.FieldByName('CLI_NOME').AsString;
      ListaCards[indiceCards].Ocorrencia  := Dados.DataSet.FieldByName('OO_CODIGO').AsInteger;
      ListaItens[indiceItens].Cards       := ListaCards;
      Inc(indiceCards);
      Dados.DataSet.Next;
    end;
    Inc(indiceItens);
    QuadroKanban.Items := ListaItens;
    JsonString := QuadroKanban.ToJsonString;
    oJson      := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(JsonString), 0) as TJSONObject;
    aJson      := oJson.GetValue('items') as TJSONArray;
    Res.Send<TJSONArray>(aJson)
       .Status(THTTPStatus.OK);
  finally
    QuadroKanban.Free;
  end;
end;

class function TControllerQuadroKANBAN.strToPrioridade(Value: string): TPrioridade;
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

class procedure TControllerQuadroKANBAN.GetOrdens(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var Query: iQuery;
begin
  Query := TDatabase.Query;
  Query.Clear;
  Query.Add('SELECT ORD_CODIGO, CLI_NOME, ORD_NOVO_PRAZOE, COALESCE(ORD_PRIORIDADE, 1) PRIORIDADE, ORD_FUN1, ORD_FUN2, ORD_FUN3, ORD_FUN4, ORD_ESTADO,');
  Query.Add('ORD_OCORRENCIA, ORD_ANALISE, ORD_LAUDOP, ORD_LAUDOT, ORD_OBS');
  Query.Add('FROM CLIENTES INNER JOIN CONTRATOS ON CLI_CODIGO = CONT_CLI');
  Query.Add('INNER JOIN ORDENS ON CONT_CODIGO = ORD_CONT');
  Query.Add('WHERE ORD_DATAAB <= :DATA AND ORD_ESTADO <> ''ENTREGUE''');
  Query.AddParam('DATA', Date);
  Query.Open();
  Res.Send<TJSONArray>(Query.DataSet.ToJSONArray());
end;

class procedure TControllerQuadroKANBAN.Registrar(App: THorse);
begin
  App.Get('/quadroKanban/Ocorrencias', GetOcorrencias);
  App.Get('/quadroKanban/Ordens', GetOrdens);
end;

end.
