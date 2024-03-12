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
  StrUtils,
  System.Json,
  UnitConstantes in 'Utils\UnitConstantes.pas',
  UnitLogin.Model in 'Modulos\Login\Models\UnitLogin.Model.pas',
  Cripto in 'Utils\Cripto.pas',
  UnitContrassenha.Model in 'Modulos\Contrassenha\Models\UnitContrassenha.Model.pas',
  UnitOrdens.Model in 'Modulos\Ordem Servico\Models\UnitOrdens.Model.pas',
  UnitController.Ocorrencias in 'Modulos\Ocorrencias\Controllers\UnitController.Ocorrencias.pas',
  UnitFuncoesComuns in 'Utils\UnitFuncoesComuns.pas' {/  UnitController.Login in 'UnitController.Login.pas',},
  UnitController.Login in 'Modulos\Login\Controllers\UnitController.Login.pas',
  UnitController.Scrum in 'Modulos\Scrum\Controllers\UnitController.Scrum.pas',
  UnitController.Contrassenhas in 'Modulos\Contrassenha\Controllers\UnitController.Contrassenhas.pas',
  UnitController.OrdensServicos in 'Modulos\Ordem Servico\Controllers\UnitController.OrdensServicos.pas',
  UnitController.MVA in 'Modulos\MVA\Controllers\UnitController.MVA.pas',
  UnitController.Clientes in 'Modulos\Clientes\Controllers\UnitController.Clientes.pas',
  UnitController.OS_Modulos in 'Modulos\Ordem Servico\Controllers\UnitController.OS_Modulos.pas',
  UnitController.Backlog.Produto in 'Modulos\Scrum\Controllers\UnitController.Backlog.Produto.pas',
  UnitBacklog.Produto.Model in 'Modulos\Scrum\Models\UnitBacklog.Produto.Model.pas',
  UnitQuadroScrum.Model in 'Modulos\Scrum\Models\UnitQuadroScrum.Model.pas',
  UnitController.QuadroScrum in 'Modulos\Scrum\Controllers\UnitController.QuadroScrum.pas',
  UnitController.Backlog.Sprint in 'Modulos\Scrum\Controllers\UnitController.Backlog.Sprint.pas',
  UnitBacklog.Sprint.Model in 'Modulos\Scrum\Models\UnitBacklog.Sprint.Model.pas',
  UnitOcorrencia.Model in 'Modulos\Ocorrencias\Models\UnitOcorrencia.Model.pas',
  UnitHistoricoPrazoEntrega.Model in 'Modulos\Ordem Servico\Models\UnitHistoricoPrazoEntrega.Model.pas',
  UnitController.Burndown.Projeto in 'Modulos\Scrum\Controllers\UnitController.Burndown.Projeto.pas',
  UnitBurndown.Projeto.Model in 'Modulos\Scrum\Models\UnitBurndown.Projeto.Model.pas',
  UnitProjetoScrum.Model in 'Modulos\Scrum\Models\UnitProjetoScrum.Model.pas',
  UnitAtualizaSprint.Model in 'Modulos\Scrum\Models\UnitAtualizaSprint.Model.pas',
  UnitArquivos_Sprint.Model in 'Modulos\Scrum\Models\UnitArquivos_Sprint.Model.pas',
  UnitRetrospectiva.Model in 'Modulos\Scrum\Models\UnitRetrospectiva.Model.pas',
  UnitController.QuadroKANBAN in 'Modulos\Scrum\Controllers\UnitController.QuadroKANBAN.pas',
  UnitQuadroKANBAN.Model in 'Modulos\Scrum\Models\UnitQuadroKANBAN.Model.pas',
  UnitDatabase in 'Database\UnitDatabase.pas',
  UnitController.NCM in 'Modulos\NCM\Controllers\UnitController.NCM.pas';

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
  TControllerNCM.Registrar;
  //inicia o servidor
  //inicia o servidor
	if GetEnvironmentVariable('PORT').IsEmpty then
		Porta := 9001
	else	
		Porta := GetEnvironmentVariable('PORT').ToInteger;
  THorse.Listen(Porta,
  procedure(App: THorse)
  begin
    Writeln('Server is running on port '+App.Port.ToString);
  end);
end.
