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
  UnitConnection.Model.Interfaces,
  UnitFuncoesComuns;

type
  TControllerBurndownProjeto = class
  private
    class function CalculaPontoReal(DataEntrega, DataEntregaReal: TDateTime): integer;
  public
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerBurndownProjeto }

uses UnitBacklog.Produto.Model, UnitDatabase;

class function TControllerBurndownProjeto.CalculaPontoReal(DataEntrega, DataEntregaReal: TDateTime): integer;
begin
  Result := DaysBetween(DataEntrega, DataEntregaReal);
end;

class procedure TControllerBurndownProjeto.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  aDatas: TJSONArray;
  aLinhaIdeal: TJSONArray;
  aLinhaReal: TJSONArray;
  Query: iQuery;
  Dados: TDataSource;
  CodProjeto: integer;
  i: integer;
  NaoEntregues: integer;
  DataEntregaProgramada: string;
begin
  // componentes de conexao
  Query       := TDatabase.Query();
  Dados       := TDataSource.Create(nil);
  CodProjeto  := Req.Params.Items['id'].ToInteger();
  aDatas      := TJSONArray.Create;
  aLinhaIdeal := TJSONArray.Create;
  aLinhaReal  := TJSONArray.Create;
  Query.Clear;
  Query.Add('SELECT BS_DATA_ENT_PROG, BS_DATA_SPRINT, BS_ESTADO, BS_DATA_ENT_REAL FROM BACKLOG_SPRINT ');
  Query.Add('WHERE BS_PS = :PROJETO ORDER BY BS_DATA_SPRINT');
  Query.AddParam('PROJETO', CodProjeto);
  Query.Open;
  Dados.DataSet := Query.DataSet;
  oJson         := TJSONObject.Create;
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do
  begin
    aDatas.Add(FormatDateTime('yyyy-mm-dd', Dados.DataSet.FieldByName('BS_DATA_ENT_PROG').AsDateTime));
    Dados.DataSet.Next;
  end;
  for i := aDatas.Count downto 0 do
    aLinhaIdeal.Add(i);
  NaoEntregues := aDatas.Count;
  aLinhaReal.Add(NaoEntregues);
  Dados.DataSet.First;
  while not Dados.DataSet.Eof do  
  begin
    if not Dados.DataSet.FieldByName('BS_DATA_ENT_REAL').IsNull then
    begin
      if Dados.DataSet.FieldByName('BS_DATA_ENT_PROG').AsDateTime = Dados.DataSet.FieldByName('BS_DATA_ENT_REAL').AsDateTime then
      begin
        Dec(NaoEntregues, 1);
      end;
      if Dados.DataSet.FieldByName('BS_DATA_ENT_REAL').AsDateTime > Dados.DataSet.FieldByName('BS_DATA_ENT_PROG').AsDateTime then
      begin
        Inc(NaoEntregues, CalculaPontoReal(Dados.DataSet.FieldByName('BS_DATA_ENT_PROG').AsDateTime, Dados.DataSet.FieldByName('BS_DATA_ENT_REAL').AsDateTime))
      end;
      if Dados.DataSet.FieldByName('BS_DATA_ENT_REAL').AsDateTime < Dados.DataSet.FieldByName('BS_DATA_ENT_PROG').AsDateTime then
      begin        
        Dec(NaoEntregues, CalculaPontoReal(Dados.DataSet.FieldByName('BS_DATA_ENT_PROG').AsDateTime, Dados.DataSet.FieldByName('BS_DATA_ENT_REAL').AsDateTime));
      end;
    end;
    aLinhaReal.Add(NaoEntregues);
    Dados.DataSet.Next;
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
