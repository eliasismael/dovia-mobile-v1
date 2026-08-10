/// Arma el pipeline de cotizaciones de la empresa, ya partido en los tres
/// carriles del diseño.
///
/// Vive fuera de las pantallas porque el panel y el historial ("Ver más")
/// muestran **lo mismo** con distinto recorte: el panel las primeras tarjetas de
/// cada carril, el historial todo con filtros. Duplicar el cruce en las dos era
/// la forma segura de que un día dejaran de coincidir y la empresa viera una
/// oportunidad en el panel que el historial ya no lista.
///
/// Los tres listados se piden **completos** ([loadAllDoviaHomePages]) y no una
/// página: el reparto entre carriles es client-side y depende de cruzar
/// propuestas contra solicitudes. Con una página de cada uno, una propuesta que
/// quedó afuera dejaría su oportunidad en "activas" —invitando a cotizar dos
/// veces lo mismo— y los filtros del historial mostrarían un resultado que
/// parece completo y no lo es.
///
/// Cada carril lleva su propio estado de error: que se caiga el marketplace no
/// tiene por qué borrar de la pantalla los proyectos ya ganados.
library;

import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/dovia_home_paginated_loader.dart';
import '/dovia_home_client/proposal_fields.dart';

import 'associate_service_request_fields.dart';
import 'associate_specialties_loader.dart';
import 'company_quote_fields.dart';

/// Una propuesta enviada, con la solicitud que cotiza ya cruzada contra el
/// marketplace: el sobre de la propuesta no trae ni el nombre del trabajo ni su
/// fecha, y sin ellos la tarjeta no se puede titular ni filtrar.
///
/// [request] es null cuando el servicio ya no está en el marketplace —el cliente
/// cerró la cotización, típicamente—. Ahí queda el [title] de respaldo, pero los
/// filtros por rubro y por mes no tienen contra qué evaluarla.
typedef CompanyQuoteSubmission = ({
  Map<String, dynamic> proposal,
  String title,
  Map<String, dynamic>? request,
});

/// El pipeline completo de la empresa.
class CompanyQuoteBoard {
  const CompanyQuoteBoard({
    required this.categories,
    required this.active,
    required this.submitted,
    required this.approved,
    this.marketplaceErrorStatus,
    this.proposalsErrorStatus,
    this.approvedErrorStatus,
    this.truncated = false,
  });

  /// Rubros habilitados de la empresa, para la sección "Servicios" y para el
  /// filtro por rubro del historial.
  final AssociateCategories categories;

  /// Carril 1: oportunidades abiertas que todavía no presupuestó.
  final List<Map<String, dynamic>> active;

  /// Carril 2: presupuestos enviados, esperando la decisión del cliente.
  final List<CompanyQuoteSubmission> submitted;

  /// Carril 3: proyectos ganados, pendientes de ejecutar.
  final List<Map<String, dynamic>> approved;

  final int? marketplaceErrorStatus;
  final int? proposalsErrorStatus;
  final int? approvedErrorStatus;

  /// Alguno de los listados llegó al tope de páginas: hay elementos que no se
  /// están mostrando y la pantalla lo dice en vez de recortar en silencio.
  final bool truncated;

  bool get marketplaceFailed => marketplaceErrorStatus != null;
  bool get proposalsFailed => proposalsErrorStatus != null;
  bool get approvedFailed => approvedErrorStatus != null;

  /// Mensaje de error de un carril. El 403 se distingue del resto porque no se
  /// resuelve reintentando: es el rol de la cuenta, y hay que hablar con DOVIA.
  static String errorMessage(int? status) => status == 403
      ? 'Tu cuenta no tiene habilitado el módulo de cotizaciones. Contacta al '
          'equipo de DOVIA.'
      : 'No pudimos cargar esta sección. Intenta de nuevo en un momento.';
}

/// Pide los tres listados (más los rubros habilitados) y devuelve el pipeline
/// ya repartido.
Future<CompanyQuoteBoard> loadCompanyQuoteBoard({
  required String authToken,
}) async {
  final marketplaceCall =
      DOVIAAPIDoviaHomeContextGroup.listCompanyQuoteServiceRequestsCall;
  final proposalsCall =
      DOVIAAPIDoviaHomeContextGroup.listAssociateProposalsCall;
  final ownJobsCall =
      DOVIAAPIDoviaHomeContextGroup.listAssociateServiceRequestsCall;

  // Las cuatro llamadas arrancan antes del primer `await`: son independientes
  // entre sí y el cruce se hace recién con todas resueltas.
  final categoriesRequest = loadAssociateCategories(authToken: authToken);
  final marketplaceRequest = loadAllDoviaHomePages(
    fetchPage: (page, limit) => marketplaceCall.call(
      requestType: kCompanyRequestType,
      authToken: authToken,
      page: page,
      limit: limit,
    ),
    extractList: marketplaceCall.requestsList,
    // El endpoint acepta `requestType` como filtro opcional; el descarte
    // client-side cubre que un contrato futuro deje de honrarlo.
    keep: asrIsWorkableByCompany,
  );
  final proposalsRequest = loadAllDoviaHomePages(
    fetchPage: (page, limit) => proposalsCall.call(
      authToken: authToken,
      page: page,
      limit: limit,
    ),
    extractList: proposalsCall.proposalsList,
  );
  final ownJobsRequest = loadAllDoviaHomePages(
    fetchPage: (page, limit) => ownJobsCall.call(
      requestType: kCompanyRequestType,
      authToken: authToken,
      page: page,
      limit: limit,
    ),
    extractList: ownJobsCall.requestsList,
    keep: cqIsWonProject,
  );

  final categories = await categoriesRequest;
  final marketplace = await marketplaceRequest;
  final proposals = await proposalsRequest;
  final ownJobs = await ownJobsRequest;

  final quoted = cqQuotedRequestIds(proposals.items);
  final requestsById = cqRequestsById(marketplace.items);

  final active = marketplace.items
      .where(cqIsOpenForQuoting)
      .where((request) => !quoted.contains(asrId(request)))
      .toList()
    ..sort(_bySoonest);

  final submitted = [
    for (final proposal in cqSubmittedQuoteProposals(proposals.items))
      (
        proposal: proposal,
        title: cqProposalTitle(proposal, requestsById),
        request: requestsById[proposalServiceRequestId(proposal) ?? ''],
      ),
  ];

  final approved = [...ownJobs.items]..sort(_bySoonest);

  return CompanyQuoteBoard(
    categories: categories,
    active: active,
    submitted: submitted,
    approved: approved,
    marketplaceErrorStatus: marketplace.errorStatus,
    proposalsErrorStatus: proposals.errorStatus,
    approvedErrorStatus: ownJobs.errorStatus,
    truncated:
        marketplace.truncated || proposals.truncated || ownJobs.truncated,
  );
}

/// `requestType` con el que se piden los dos listados de solicitudes: la empresa
/// sólo trabaja cotizaciones.
const String kCompanyRequestType = 'QUOTE';

/// Lo más próximo primero. Las solicitudes sin ninguna fecha van al final: no se
/// pueden ordenar contra las demás y colarlas arriba las haría parecer urgentes.
int _bySoonest(Map<String, dynamic> a, Map<String, dynamic> b) {
  final dateA = asrFilterDate(a);
  final dateB = asrFilterDate(b);
  if (dateA == null && dateB == null) return 0;
  if (dateA == null) return 1;
  if (dateB == null) return -1;
  return dateA.compareTo(dateB);
}
