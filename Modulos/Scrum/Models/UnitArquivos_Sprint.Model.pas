unit UnitArquivos_Sprint.Model;

interface

type
  TArquivosSprint = class
  private
    FCodigo : integer;
    FCaminho: string;
    FData   : TDateTime;
    FHora   : TDateTime;
  public
    property Codigo : integer read FCodigo write FCodigo;
    property Caminho: string read FCaminho write FCaminho;
    property Data   : TDateTime read FData write FData;
    property Hora   : TDateTime read FHora write FHora;
    function ToJsonString: string;
    class function FromJsonString(Value: string): TArquivosSprint;
  end;

implementation

uses Rest.Json;

{ TArquivosSprint }

class function TArquivosSprint.FromJsonString(Value: string): TArquivosSprint;
begin
  Result := TJson.JsonToObject<TArquivosSprint>(Value);
end;

function TArquivosSprint.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.
