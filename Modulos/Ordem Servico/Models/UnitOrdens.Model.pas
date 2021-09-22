unit UnitOrdens.Model;

interface

uses Rest.Json;

type
  TModelOrdens = class
  private
    Ffun_abertura: integer;
    Fcontrato: integer;
    Focorrencia: string;
    Ffun_analise: integer;
    Ffun_programador: integer;
    Ffun_teste: integer;
    Fdata_entrega: String;
    Ffun_entrega: integer;
    Festado: string;
    Fprazo_entrega: String;
    Ftipo: string;
    Fdata_entrega_analise: String;
    Fdata_entrega_programacao: String;
    Fdata_entrega_teste: String;
    Ffun_atendente: String;
    Fprioridade: integer;
    Fcodigo_ocorrencia: integer;
    Fos_modulo: integer;
    FcodSprint: integer;
    Fnovo_prazoe: string;
    Fcodigo: integer;
    Flaudo: string;
    Ftipo_entrega: string;
    Ffuncionario: integer;
  public
    function ToJsonString: string;
    class function FromJsonString(Value: string): TModelOrdens;
    property codigo: integer read Fcodigo write Fcodigo;
    property fun_abertura: integer read Ffun_abertura write Ffun_abertura;
    property contrato: integer read Fcontrato write Fcontrato;
    property ocorrencia: string read Focorrencia write Focorrencia;
    property fun_analise: integer read Ffun_analise write Ffun_analise;
    property fun_programador: integer read Ffun_programador write Ffun_programador;
    property fun_teste: integer read Ffun_teste write Ffun_teste;
    property data_entrega: String read Fdata_entrega write Fdata_entrega;
    property fun_entrega: integer read Ffun_entrega write Ffun_entrega;
    property estado: string read Festado write Festado;
    property prazo_entrega: String read Fprazo_entrega write Fprazo_entrega;
    property tipo: string read Ftipo write Ftipo;
    property data_entrega_analise: String read Fdata_entrega_analise write Fdata_entrega_analise;
    property data_entrega_programacao: String read Fdata_entrega_programacao write Fdata_entrega_programacao;
    property data_entrega_teste: String read Fdata_entrega_teste write Fdata_entrega_teste;
    property fun_atendente: String read Ffun_atendente write Ffun_atendente;
    property prioridade: integer read Fprioridade write Fprioridade;
    property codigo_ocorrencia: integer read Fcodigo_ocorrencia write Fcodigo_ocorrencia;
    property os_modulo: integer read Fos_modulo write Fos_modulo;
    property codSprint: integer read FcodSprint write FcodSprint;
    property novo_prazoe: string read Fnovo_prazoe write Fnovo_prazoe;
    property laudo: string read Flaudo write Flaudo;
    property tipo_entrega: string read Ftipo_entrega write Ftipo_entrega;
    property funcionario: integer read Ffuncionario write Ffuncionario;
  end;

implementation

{ TModelOrdens }

class function TModelOrdens.FromJsonString(Value: string): TModelOrdens;
begin
  Result := TJson.JsonToObject<TModelOrdens>(Value);
end;

function TModelOrdens.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.
