unit UnitOcorrencia.Model;
{ *******************************************************************************
  Generated By   : JsonToDelphiClass - 0.65
  Project link   : https://github.com/PKGeorgiev/Delphi-JsonToDelphiClass
  Generated On   : 2019-10-11 10:58:19

  Created By     : Petar Georgiev - (http://pgeorgiev.com)
  Adapted Web By : Marlon Nardi - (http://jsontodelphi.com)
  ******************************************************************************* }

interface

uses Generics.Collections, Rest.Json;

type

  TOcorrencia = class
  private
    FData            : String;
    FFinalizada      : String;
    Fatendente       : Integer;
    FModulo_Sistema  : Integer;
    FObs             : String;
    FOcorrencia      : String;
    Fcontrato        : Integer;
    Fcli_nome        : string;
    Ffun_nome        : string;
    Fcodigo          : Integer;
    Ffuncionario     : Integer;
    Ffun_atendente   : string;
    FTempoAtendimento: Integer;
    FDataFinalizada  : string;
    FabriuOS         : string;
  public
    property codigo          : Integer read Fcodigo write Fcodigo;
    property data            : String read FData write FData;
    property funcionario     : Integer read Ffuncionario write Ffuncionario;
    property finalizada      : String read FFinalizada write FFinalizada;
    property atendente       : Integer read Fatendente write Fatendente;
    property fun_atendente   : string read Ffun_atendente write Ffun_atendente;
    property modulo_Sistema  : Integer read FModulo_Sistema write FModulo_Sistema;
    property obs             : String read FObs write FObs;
    property ocorrencia      : String read FOcorrencia write FOcorrencia;
    property contrato        : Integer read Fcontrato write Fcontrato;
    property cli_nome        : string read Fcli_nome write Fcli_nome;
    property fun_nome        : string read Ffun_nome write Ffun_nome;
    property TempoAtendimento: Integer read FTempoAtendimento write FTempoAtendimento;
    property DataFinalizada  : string read FDataFinalizada write FDataFinalizada;
    property abriuOS         : string read FabriuOS write FabriuOS;
    function ToJsonString: string;
    class function FromJsonString(AJsonString: string): TOcorrencia;
  end;

implementation

{ TOcorrencia }

function TOcorrencia.ToJsonString: string;
begin
  result := TJson.ObjectToJsonString(self);
end;

class function TOcorrencia.FromJsonString(AJsonString: string): TOcorrencia;
begin
  result := TJson.JsonToObject<TOcorrencia>(AJsonString)
end;

end.
