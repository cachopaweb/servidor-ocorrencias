unit UnitFuncoesComuns;

interface
uses
  DB,
  UnitConexao.Model.Interfaces,
  UnitOcorrencia.Model,
  UnitConexao.FireDAC.Model,
  UnitQuery.FireDAC.Model,
  UnitFactory.Conexao.FireDAC;



function EnDecryptString(StrValue: String; Chave: Word): String;
function GeraCodigo(Tabela, Campo: string): integer;

implementation


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
  Conexao := TFactoryConexaoFireDAC.New.Conexao('portalsoft.sytes.net:/home/Portal/Dados/PORTAL.FDB');
  Query := TFactoryConexaoFireDAC.New.Query(Conexao);
  Query.DataSource(Dados);
  Query.Open('SELECT MAX(' + Campo + ') FROM ' + Tabela);
  if Dados.DataSet.IsEmpty then
    Result := 1
  else
    Result := Dados.DataSet.Fields[0].AsInteger + 1;
end;


end.
