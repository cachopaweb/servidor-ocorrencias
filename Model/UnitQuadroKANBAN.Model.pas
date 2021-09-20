unit UnitQuadroKANBAN.Model;

interface

uses
  System.Generics.Collections, REST.Json.Types, Rest.Json;

{$M+}

type
  TCards = class
  private
    FContent: string;
    FId: Integer;
    FLabels: TArray<string>;
    FUser: string;
    FDataEntrega: string;
    FOcorrencia: integer;
    FOrdem: integer;
    FTitulo: string;
  published
    property Content: string read FContent write FContent;
    property Id: Integer read FId write FId;
    property Labels: TArray<string> read FLabels write FLabels;
    property User: string read FUser write FUser;
    property DataEntrega: string read FDataEntrega write FDataEntrega;
    property Ocorrencia: integer read FOcorrencia write FOcorrencia;
    property Ordem: integer read FOrdem write FOrdem;
    property Titulo: string read FTitulo write FTitulo;
  end;

  TItem = class
  private
    FCards: TArray<TCards>;
    FTitle: string;
    FCreateOcorrencia: Boolean;
  published
    property Cards: TArray<TCards> read FCards write FCards;
    property Title: string read FTitle write FTitle;
    property CreateOcorrencia: Boolean read FCreateOcorrencia write FCreateOcorrencia;
  end;

  TQuadroKanban = class
  private
    FItems: TArray<TItem>;
  published
    property Items: TArray<TItem> read FItems write FItems;
    function ToJsonString: string;
    class function FromJsonString(Value: string): TQuadroKanban;
  end;

implementation

class function TQuadroKanban.FromJsonString(Value: string): TQuadroKanban;
begin
  Result := TJson.JsonToObject<TQuadroKanban>(Value);
end;

function TQuadroKanban.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.
