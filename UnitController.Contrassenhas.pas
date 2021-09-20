unit UnitController.Contrassenhas;

interface

uses
  Horse,
  Classes,
  SysUtils,
  System.Json,
  System.DateUtils,
  DB,
  UnitConnection.Model.Interfaces,
  UnitFactory.Connection.FireDAC,
  UnitFuncoesComuns,
  UnitContrassenha.Model,
  Cripto, UnitConstantes;

type
  TControllerContrassenhas = class
    class procedure Registrar(App: THorse);
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

uses
  Horse.Commons, UnitDatabase;

{ TControllerContrassenhas }

class procedure TControllerContrassenhas.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson     : TJSONObject;
  aJson     : TJSONArray;
  Query     : iQuery;
  Senha     : string;
  DataLimite: string;
  Dias: Integer;
  Ano: Integer;
  Data: TDateTime;
begin
  aJson := TJSONArray.Create;
  if Req.Query.Count > 0 then
  begin
    Dias  := Req.Query.Items['dias'].ToInteger;
    // componentes de conexao
    Query   := TFactoryConnectionFiredac.New(TConstants.BancoDadosLicencas.Caminho, TConstants.BancoDadosLicencas.Usuario, TConstants.BancoDadosLicencas.Senha, false).Query();
    Query.Add('SELECT LIC_CODIGO, LIC_SENHA, LIC_CONTRA_SENHA, LIC_DATA_USO, ');
    Query.Add('LIC_PC, LIC_NOME_CLIENTE, LIC_NUM_USOS, COUNT(ACE_SENHA) NUM_PCS FROM LICENCAS ');
    Query.Add('LEFT JOIN ACESSOS ON LIC_SENHA = ACE_SENHA');
    Query.Add('GROUP BY LIC_CODIGO, LIC_SENHA, LIC_CONTRA_SENHA, LIC_DATA_USO, LIC_PC, LIC_NOME_CLIENTE, LIC_NUM_USOS');
    Query.Add('ORDER BY LIC_NOME_CLIENTE');
    Query.Open;
    Query.DataSet.First;
    while not Query.DataSet.Eof do
    begin
      Senha      := Cripto.PreparaDescriptografia(Query.DataSet.FieldByName('LIC_CONTRA_SENHA').AsString, 0);
      DataLimite := Copy(Senha, 7, 2) + '/' + Copy(Senha, 9, 2) + '/' + Copy(Senha, 11, 2);
      Data := FormatarData(DataLimite);
      Ano := YearOf(Data);
      if (Data <= IncDay(Date, Dias)) and (Ano = 2020) then
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('codigo', Query.DataSet.FieldByName('LIC_CODIGO').AsString);
        oJson.AddPair('senha', Query.DataSet.FieldByName('LIC_SENHA').AsString);
        oJson.AddPair('contra_senha', Query.DataSet.FieldByName('LIC_CONTRA_SENHA').AsString);
        oJson.AddPair('data_uso', Query.DataSet.FieldByName('LIC_DATA_USO').AsString);
        oJson.AddPair('pc', Query.DataSet.FieldByName('LIC_PC').AsString);
        oJson.AddPair('nome_cliente', Query.DataSet.FieldByName('LIC_NOME_CLIENTE').AsString);
        oJson.AddPair('num_usos', Query.DataSet.FieldByName('LIC_NUM_USOS').AsString);
        oJson.AddPair('pcs', Query.DataSet.FieldByName('NUM_PCS').AsString);
        oJson.AddPair('data_limite', DataLimite);
        aJson.AddElement(oJson);
      end;
      Query.DataSet.Next;
    end;
    Res.Send<TJSONArray>(aJson).Status(THTTPStatus.OK);
  end else
  begin
    // componentes de conexao
    Query   := TFactoryConnectionFiredac.New('firebird.db5.net2.com.br:/firebird/portalsoft2.gdb', 'PORTALSOFT2', 'portal3694', false).Query();
    Query.Add('SELECT LIC_CODIGO, LIC_SENHA, LIC_CONTRA_SENHA, LIC_DATA_USO, LIC_PC, LIC_NOME_CLIENTE, LIC_NUM_USOS, COUNT(ACE_SENHA) NUM_PCS');
    Query.Add('FROM LICENCAS LEFT JOIN ACESSOS ON LIC_SENHA = ACE_SENHA');
    Query.Add('GROUP BY LIC_CODIGO, LIC_SENHA, LIC_CONTRA_SENHA, LIC_DATA_USO, LIC_PC, LIC_NOME_CLIENTE, LIC_NUM_USOS');
    Query.Add('ORDER BY LIC_NOME_CLIENTE');
    Query.Open;
    Query.DataSet.First;
    while not Query.DataSet.Eof do
    begin
      oJson := TJSONObject.Create;
      oJson.AddPair('codigo', Query.DataSet.FieldByName('LIC_CODIGO').AsString);
      oJson.AddPair('senha', Query.DataSet.FieldByName('LIC_SENHA').AsString);
      oJson.AddPair('contra_senha', Query.DataSet.FieldByName('LIC_CONTRA_SENHA').AsString);
      oJson.AddPair('data_uso', Query.DataSet.FieldByName('LIC_DATA_USO').AsString);
      oJson.AddPair('pc', Query.DataSet.FieldByName('LIC_PC').AsString);
      oJson.AddPair('nome_cliente', Query.DataSet.FieldByName('LIC_NOME_CLIENTE').AsString);
      oJson.AddPair('num_usos', Query.DataSet.FieldByName('LIC_NUM_USOS').AsString);
      oJson.AddPair('pcs', Query.DataSet.FieldByName('NUM_PCS').AsString);
      Senha      := Cripto.PreparaDescriptografia(Query.DataSet.FieldByName('LIC_CONTRA_SENHA').AsString, 0);
      DataLimite := Copy(Senha, 7, 2) + '/' + Copy(Senha, 9, 2) + '/' + Copy(Senha, 11, 2);
      oJson.AddPair('data_limite', DataLimite);
      aJson.AddElement(oJson);
      Query.DataSet.Next;
    end;
    Res.Send<TJSONArray>(aJson).Status(THTTPStatus.OK);
  end;
end;

class procedure TControllerContrassenhas.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson        : TJSONObject;
  Codigo       : integer;
  Contrassenha : string;
  oContrassenha: TContrassenha;
  Query        : iQuery;
begin
  oJson := TJSONObject.Create;
  if Req.Body <> '' then
  begin
    try
      oContrassenha := TContrassenha.FromJsonString(Req.Body);
      Query   := TFactoryConnectionFiredac.New(TConstants.BancoDadosLicencas.Caminho, TConstants.BancoDadosLicencas.Usuario, TConstants.BancoDadosLicencas.Senha, false).Query();
      Contrassenha  := PreparaCriptografia(oContrassenha.Senha + oContrassenha.limite.Replace('/', ''), 0);
      Query.Add(Format('UPDATE LICENCAS SET LIC_SENHA = %s, LIC_CONTRA_SENHA = %s WHERE LIC_CODIGO = %d', [oContrassenha.Senha.QuotedString, Contrassenha.QuotedString, oContrassenha.Codigo]));
      Query.ExecSQL;
    except
      on E: exception do
      begin
        raise exception.Create('Erro ao inserir contrassenha' + E.Message);
      end
    end;
    Res.Status(200);
    oJson.AddPair('Ok', 'Contrassenha atualizada!');
    Res.Send<TJSONObject>(oJson);
  end
  else
  begin
    Res.Status(401);
    oJson.AddPair('Erro', 'Senha ou data limete não informada corretamente!');
    Res.Send<TJSONObject>(oJson);
  end;
end;

class procedure TControllerContrassenhas.Registrar(App: THorse);
begin
  App.Get('/contrassenha', Get);
  App.Post('/contrassenha', Post);
  App.Get('/constrassenha/:dias', Get);
end;

end.
