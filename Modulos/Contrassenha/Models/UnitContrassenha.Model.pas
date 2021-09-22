unit UnitContrassenha.Model;
{*******************************************************************************
    Created By     : Alessandro Dutra
    Description    : Cria um templete de classe para usar microservicos REST
*******************************************************************************}

interface

uses Generics.Collections, Rest.Json;

type

TContrassenha = class
private
    Fsenha: string;
    Flimite: string;
    Fcodigo: integer;
public
  property codigo: integer read Fcodigo write Fcodigo;
  property senha: string read Fsenha write Fsenha;
  property limite: string read Flimite write Flimite;
  function ToJsonString: string;
  class function FromJsonString(AJsonString: string): TContrassenha;
end;

implementation

{TContrassenha}


function TContrassenha.ToJsonString: string;
begin
  result := TJson.ObjectToJsonString(self);
end;

class function TContrassenha.FromJsonString(AJsonString: string): TContrassenha;
begin
  result := TJson.JsonToObject<TContrassenha>(AJsonString)
end;

end.
