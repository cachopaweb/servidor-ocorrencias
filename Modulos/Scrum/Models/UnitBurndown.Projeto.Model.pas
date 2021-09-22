unit UnitBurndown.Projeto.Model;

interface
  uses System.Generics.Collections, Rest.Json;

type
  TBurndownProjeto = class
  private
    FDatas     : TArray<string>;
    FLinhaIdeal: TArray<integer>;
    FLinhaReal : TArray<integer>;
  public
    property Datas     : TArray<string> read FDatas write FDatas;
    property LinhaIdeal: TArray<integer> read FLinhaIdeal write FLinhaIdeal;
    property LinhaReal : TArray<integer> read FLinhaReal write FLinhaReal;
    function ToJsonString: string;
    class function FromJsonString(Value: string): TBurndownProjeto;
  end;

implementation

{ TBurndownProjeto }

class function TBurndownProjeto.FromJsonString(Value: string): TBurndownProjeto;
begin
  Result := TJson.JsonToObject<TBurndownProjeto>(Value);
end;

function TBurndownProjeto.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self)
end;

end.
