program ServidorOS;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  DB,
  Horse,
  Horse.CORS,
  Horse.Jhonson,
  Classes,
  SysUtils,
  System.Json,
  UnitLogin.Model in 'Model\UnitLogin.Model.pas',
  UnitConexao.Model.Interfaces in '..\..\..\FormsComuns\Classes\Fabrica Conexao\UnitConexao.Model.Interfaces.pas',
  UnitOcorrencia.Model in 'Model\UnitOcorrencia.Model.pas',
  UnitConexao.FireDAC.Model in '..\..\..\FormsComuns\Classes\Fabrica Conexao\FireDAC\UnitConexao.FireDAC.Model.pas',
  UnitQuery.FireDAC.Model in '..\..\..\FormsComuns\Classes\Fabrica Conexao\FireDAC\UnitQuery.FireDAC.Model.pas',
  UnitFactory.Conexao.FireDAC in '..\..\..\FormsComuns\Classes\Fabrica Conexao\FireDAC\UnitFactory.Conexao.FireDAC.pas',
  Cripto in 'Model\Cripto.pas',
  UnitContrassenha.Model in 'Model\UnitContrassenha.Model.pas',
  UnitOrdens.Model in 'Model\UnitOrdens.Model.pas',
  UnitController.Ocorrencias in 'UnitController.Ocorrencias.pas',
  UnitFuncoesComuns in 'UnitFuncoesComuns.pas',
  UnitController.Login in 'UnitController.Login.pas',
  UnitController.Scrum in 'UnitController.Scrum.pas',
  UnitController.Contrassenhas in 'UnitController.Contrassenhas.pas',
  UnitController.OrdensServicos in 'UnitController.OrdensServicos.pas',
  UnitController.MVA in 'UnitController.MVA.pas',
  UnitController.Clientes in 'UnitController.Clientes.pas';

var
  App: THorse;

begin
  App := THorse.Create(9000);
  App.Use(Jhonson);
  App.Use(CORS);
  //Controllers
  TControllerOcorrencias.Registrar(App);
  TControllerLogin.Registrar(App);
  TControllerScrum.Registrar(App);
  TControllerContrassenhas.Registrar(App);
  TControllerOrdensServicos.Registrar(App);
  TControllerMVA.Registrar(App);
  TControllerClientes.Registrar(App);
  //inicia o servidor
  App.Start;

end.
