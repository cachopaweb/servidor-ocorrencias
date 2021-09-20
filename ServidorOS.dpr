program ServidorOS;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  DB,
  Horse,
  Horse.CORS,
  Horse.Jhonson,
  Horse.HandleException,
  Horse.Upload,
  Horse.OctetStream,
  Classes,
  SysUtils,
  System.Json,
  UnitConstantes in 'UnitConstantes.pas',
  UnitLogin.Model in 'Model\UnitLogin.Model.pas',
  Cripto in 'Model\Cripto.pas',
  UnitContrassenha.Model in 'Model\UnitContrassenha.Model.pas',
  UnitOrdens.Model in 'Model\UnitOrdens.Model.pas',
  UnitController.Ocorrencias in 'UnitController.Ocorrencias.pas',
  UnitFuncoesComuns in 'UnitFuncoesComuns.pas' {/  UnitController.Login in 'UnitController.Login.pas',},
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
  UnitBurndown.Projeto.Model in 'Model\UnitBurndown.Projeto.Model.pas',
  UnitProjetoScrum.Model in 'Model\UnitProjetoScrum.Model.pas',
  UnitAtualizaSprint.Model in 'Model\UnitAtualizaSprint.Model.pas',
  UnitArquivos_Sprint.Model in 'Model\UnitArquivos_Sprint.Model.pas',
  UnitRetrospectiva.Model in 'Model\UnitRetrospectiva.Model.pas',
  UnitController.QuadroKANBAN in 'UnitController.QuadroKANBAN.pas',
  UnitQuadroKANBAN.Model in 'Model\UnitQuadroKANBAN.Model.pas',
  UnitDatabase in 'Database\UnitDatabase.pas';

var
  App: THorse;

begin
  ReportMemoryLeaksOnShutdown := true;
  App := THorse.Create;
  App.Use(Jhonson)
     .Use(HandleException)
     .Use(CORS)
     .Use(Upload)
     .Use(OctetStream);
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
  TControllerQuadroKANBAN.Registrar(App);
  //inicia o servidor
  App.Listen(9000,
  procedure(Horse: THorse)
    begin
      Writeln(Format('Servidor rodando na porta %s', [Horse.Port.ToString]));
      Writeln('Pressione ESC para parar ...');
      Readln;
      Horse.StopListen;
    end
  );
end.
