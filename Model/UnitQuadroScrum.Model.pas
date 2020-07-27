unit UnitQuadroScrum.Model;

interface

uses
  System.Generics.Collections, REST.Json.Types, Rest.Json;

{$M+}

type
  TBacklog = class
  private
    FContent: string;
    FId: integer;
    FLabels: TArray<string>;
    FUser: string;
    Fbb_codigo: integer;
  published
    property Content: string read FContent write FContent;
    property Id: integer read FId write FId;
    property Labels: TArray<string> read FLabels write FLabels;
    property User: string read FUser write FUser;
    property bb_codigo: integer read Fbb_codigo write Fbb_codigo;
  end;

  TCards = class
  private
    FContent: string;
    FId: Integer;
    FLabels: TArray<string>;
    FUser: string;
    FBacklogs: TArray<TBacklog>;
    FDataEntrega: string;
  published
    property Content: string read FContent write FContent;
    property Id: Integer read FId write FId;
    property Labels: TArray<string> read FLabels write FLabels;
    property User: string read FUser write FUser;
    property Backlogs: TArray<TBacklog> read FBacklogs write FBacklogs;
    property DataEntrega: string read FDataEntrega write FDataEntrega;
  end;

  TItem = class
  private
    FCards: TArray<TCards>;
    FTitle: string;
    FCreateBacklog: Boolean;
    FCreateSprint: Boolean;
    FEhSprint: Boolean;
  published
    property Cards: TArray<TCards> read FCards write FCards;
    property Title: string read FTitle write FTitle;
    property CreateBacklog: Boolean read FCreateBacklog write FCreateBacklog;
    property CreateSprint: Boolean read FCreateSprint write FCreateSprint;
    property EhSprint: Boolean read FEhSprint write FEhSprint;
  end;

  TQuadroScrum = class
  private
    FItems: TArray<TItem>;
  published
    property Items: TArray<TItem> read FItems write FItems;
    function ToJsonString: string;
    class function FromJsonString(Value: string): TQuadroScrum;
  end;

implementation

class function TQuadroScrum.FromJsonString(Value: string): TQuadroScrum;
begin
  Result := TJson.JsonToObject<TQuadroScrum>(Value);
end;

function TQuadroScrum.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.
