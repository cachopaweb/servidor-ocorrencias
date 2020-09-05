program ServidorOS;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  DB,
  Horse,
  Horse.CORS,
  Horse.Jhonson,
  Horse.HandleException,
  Classes,
  SysUtils,
  System.Json,
  UnitConstantes in 'UnitConstantes.pas',
  UnitLogin.Model in 'Model\UnitLogin.Model.pas',
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
  UnitController.Clientes in 'UnitController.Clientes.pas',
  UnitController.OS_Modulos in 'UnitController.OS_Modulos.pas',
  UnitController.Backlog.Produto in 'UnitController.Backlog.Produto.pas',
  UnitBacklog.Produto.Model in 'Model\UnitBacklog.Produto.Model.pas',
  UnitQuadroScrum.Model in 'Model\UnitQuadroScrum.Model.pas',
  UnitController.QuadroScrum in 'UnitController.QuadroScrum.pas',
  UnitController.Backlog.Sprint in 'UnitController.Backlog.Sprint.pas',
  UnitBacklog.Sprint.Model in 'Model\UnitBacklog.Sprint.Model.pas',
  UnitOcorrencia.Model in 'Model\UnitOcorrencia.Model.pas',
  UnitHistoricoPrazoEntrega.Model in 'Model\UnitHistoricoPrazoEntrega.Model.pas',
  UnitController.Burndown.Projeto in 'UnitController.Burndown.Projeto.pas',
  UnitBurndown.Projeto.Model in 'Model\UnitBurndown.Projeto.Model.pas';

var
  App: THorse;

begin
  //ReportMemoryLeaksOnShutdown := true;
  App := THorse.Create(9000);
  App.Use(Jhonson);
  App.Use(HandleException);
  App.Use(CORS);
  //Controllers
  TControllerOcorrencias.Registrar(App);
  TControllerLogin.Registrar(App);
  TControllerScrum.Registrar(App);
  TControllerContrassenhas.Registrar(App);
  TControllerOrdensServicos.Registrar(App);
  TControllerMVA.Registrar(App);
  TControllerClientes.Registrar(App);
  TControllerOSModulos.Registrar(App);
  TControllerBacklogProduto.Registrar(App);
  TControllerQuadroScrum.Registrar(App);
  TControllerBacklogSprint.Registrar(App);
  TControllerBurndownProjeto.Registrar(App);
  //inicia o servidor
  App.Start;
end.
