unit UnitConstantes;

interface
  type
    TConstants = class
      class function BancoDados: string;
    end;
implementation

const
  BD_Teste: string = 'D:/Projetos/Operacional Portal/Dados/PORTAL.FDB';
  BD_Producao: string = '/home/Portal/Dados/PORTAL.FDB';

{ TConstants }

class function TConstants.BancoDados: string;
begin
  Result := BD_Teste;
end;

end.
