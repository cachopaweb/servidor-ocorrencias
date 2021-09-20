unit UnitConstantes;

interface
uses System.SysUtils;

type
  TConfigBancoDados = record
    Caminho: string;
    Usuario: string;
    Senha: string;
  end;

type
  TConstants = class
    class function BancoDados: string;
    class function BancoDadosLicencas: TConfigBancoDados;
  end;

implementation

{ TConstants }

class function TConstants.BancoDados: string;
begin
  Result := GetEnvironmentVariable('DB_HOST');
end;

class function TConstants.BancoDadosLicencas: TConfigBancoDados;
begin
  Result.Caminho := GetEnvironmentVariable('DB_HOST_LICENCAS');
  Result.Usuario := GetEnvironmentVariable('DB_USER');
  Result.Senha   := GetEnvironmentVariable('DB_PASS');
end;

end.
