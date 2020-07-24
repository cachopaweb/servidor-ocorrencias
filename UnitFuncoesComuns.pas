unit UnitFuncoesComuns;

interface
uses
  DB,
  UnitConstantes,
  UnitConexao.Model.Interfaces,
  UnitOcorrencia.Model,
  UnitConexao.FireDAC.Model,
  UnitQuery.FireDAC.Model,
  UnitFactory.Conexao.FireDAC,
  System.SysUtils;



function EnDecryptString(StrValue: String; Chave: Word): String;
function GeraCodigo(Tabela, Campo: string): integer;
function FormatarData(Value: string): TDateTime;
//tipos enumerados
function StrToEnumerado(out ok: Boolean; const s: string; const AString: array of string; const AEnumerados: array of variant): variant;
function EnumeradoToStr(const t: variant; const AString: array of string; const AEnumerados: array of variant): variant;


implementation

function FormatarData(Value: string): TDateTime;
var
  Data: TArray<string>;
begin
  Data := Value.Split(['/']);
  Result := StrToDate(Data[1]+'/'+Data[0]+'/'+Data[2]);
end;

function EnDecryptString(StrValue: String; Chave: Word): String;
var
  i       : integer;
  OutValue: String;
begin
  OutValue   := '';
  for i      := 1 to Length(StrValue) do
    OutValue := OutValue + Char(Not(Ord(StrValue[i]) - Chave));
  Result     := OutValue;
end;

function GeraCodigo(Tabela, Campo: string): integer;
var Query: iQuery;
    Dados: TDataSource;
    Conexao: iConexao;
begin
  Dados := TDataSource.Create(nil);
  Conexao := TFactoryConexaoFireDAC.New.Conexao(TConstants.BancoDados);
  Query := TFactoryConexaoFireDAC.New.Query(Conexao);
  Query.DataSource(Dados);
  Query.Open('SELECT MAX(' + Campo + ') FROM ' + Tabela);
  if Dados.DataSet.IsEmpty then
    Result := 1
  else
    Result := Dados.DataSet.Fields[0].AsInteger + 1;
end;

function StrToEnumerado(out ok: Boolean; const s: string; const AString: array of string; const AEnumerados: array of variant): variant;
var
  i: integer;
begin
  Result := -1;
  for i  := Low(AString) to High(AString) do
    if AnsiSameText(s, AString[i]) then
      Result := AEnumerados[i];
  ok         := Result <> -1;
  if not ok then
    Result := AEnumerados[0];
end;

function EnumeradoToStr(const t: variant; const AString: array of string; const AEnumerados: array of variant): variant;
var
  i: integer;
begin
  Result := '';
  for i  := Low(AEnumerados) to High(AEnumerados) do
    if t = AEnumerados[i] then
      Result := AString[i];
end;


end.
