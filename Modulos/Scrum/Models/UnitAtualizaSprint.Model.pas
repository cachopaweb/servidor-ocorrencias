unit UnitAtualizaSprint.Model;

interface
uses UnitConnection.Model.Interfaces;

type
  TEstadoSprint = (teAberto, teAFazer, teEmAndamento, teRevisao, teEntregue);

  THelperEstadoSprint = record helper for TEstadoSprint
    function toString: string;
  end;

  iAtualizarSprint = interface
    ['{921675C4-C109-4859-95D0-D58618342F2E}']
    function SetCodigoOrdem(Value: integer): iAtualizarSprint;
    function Atualizar(Estado: TEstadoSprint): iAtualizarSprint;
  end;

  TAtualizarSprint = class(TInterfacedObject, iAtualizarSprint)
  private
    FCodigoOrdem: integer;
    FQuery: iQuery;
  public
    function SetCodigoOrdem(Value: integer): iAtualizarSprint;
    function Atualizar(Estado: TEstadoSprint): iAtualizarSprint;
    class function New(Query: iQuery): iAtualizarSprint;
    constructor Create(Query: iQuery);
  end;


implementation

{ TAtualizarSprint }

uses System.SysUtils, UnitFuncoesComuns;

function TAtualizarSprint.Atualizar(Estado: TEstadoSprint): iAtualizarSprint;
var
  CodigoSprint: Integer;
begin
  Result := Self;
  try
    FQuery.Clear;
    FQuery.Add('SELECT ORD_SPRINT FROM ORDENS WHERE ORD_CODIGO = :CODIGO');
    FQuery.AddParam('CODIGO', FCodigoOrdem);
    FQuery.Open;
    CodigoSprint := 0;
    if not FQuery.DataSet.IsEmpty then
      CodigoSprint := FQuery.DataSet.FieldByName('ORD_SPRINT').AsInteger;
    if CodigoSprint > 0 then
    begin
      FQuery.Clear;
      FQuery.Add('UPDATE BACKLOG_SPRINT SET BS_ESTADO = :ESTADO WHERE BS_CODIGO = :CODIGO');
      FQuery.AddParam('ESTADO', Estado.toString);
      FQuery.AddParam('CODIGO', CodigoSprint);
      FQuery.ExecSQL;
    end;
  except on E: Exception do
    begin
      raise Exception.Create('Erro ao atualizar estado da sprint!'+SlineBreak+E.Message);
    end;
  end;
end;

constructor TAtualizarSprint.Create(Query: iQuery);
begin
  FQuery := Query;
end;

class function TAtualizarSprint.New(Query: iQuery): iAtualizarSprint;
begin
  Result := Self.Create(Query);
end;

function TAtualizarSprint.SetCodigoOrdem(Value: integer): iAtualizarSprint;
begin
  Result := Self;
  FCodigoOrdem := Value;
end;

{ THelperEstadoSprint }

function THelperEstadoSprint.toString: string;
begin
  Result := EnumeradoToStr(Self, ['ABERTO', 'A FAZER', 'EM ANDAMENTO', 'REVISAO', 'ENTREGUE'], [teAberto, teAFazer, teEmAndamento, teRevisao, teEntregue])
end;

end.
