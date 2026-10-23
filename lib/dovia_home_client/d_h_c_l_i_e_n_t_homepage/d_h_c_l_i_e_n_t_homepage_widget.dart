import '/dovia_home_client/pending_payment.dart';
import '/shared_components/status_bar_clip/status_bar_clip.dart';
import '/dovia_home_client/subscription_renewal_notice.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_proximas_visitas/d_h_c_l_i_e_n_t_proximas_visitas_widget.dart';
import '/dovia_home_client/proposal_fields.dart';
import '/dovia_home_client/service_request_fields.dart';
import '/dovia_home_client/upcoming_service_requests.dart';
import '/shared_components/error_state/error_state_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/repositories/payments_repository.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/api_manager.dart';

import 'd_h_c_l_i_e_n_t_homepage_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_h_c_l_i_e_n_t_homepage_model.dart';

/// Solicitud de servicio agendada por el cliente. Se muestra en "Próximas
/// visitas" con estatus "Pendiente".
///
/// TODO: Reemplazar por los datos reales de la solicitud creada en el backend
/// (GET de próximas visitas del cliente) una vez exista el endpoint.
class ScheduledVisit {
  const ScheduledVisit({
    required this.service,
    required this.date,
    required this.time,
    this.status = 'Pendiente',
    this.isEmergency = false,
    this.id,
    this.scheduledAt,
  });

  final String service;
  final String date;
  final String time;
  final String status;

  /// Fecha agendada como dato (no como texto). [date] es solo la etiqueta que
  /// se pinta; esta es la que usan los filtros por fecha del listado completo.
  /// Null cuando la solicitud aún no tiene fecha (Ej: cotización en evaluación).
  final DateTime? scheduledAt;

  /// Solicitud de emergencia: la tarjeta muestra un indicador visual de alta
  /// prioridad para que la red de Home Associates la tome de inmediato.
  final bool isEmergency;

  /// Id de la solicitud creada en el backend, cuando se conoce. Permite que el
  /// listado del backend no vuelva a pintar la misma solicitud que ya se agregó
  /// de forma optimista al volver al Dashboard.
  final String? id;
}

/// Tarjeta del carrusel "Cotizaciones recibidas". Unifica las dos cosas que
/// llegan ahí —una propuesta recibida y un diagnóstico fuera de alcance— para
/// que se pinten iguales aunque cada una salga de un endpoint distinto y abra
/// una pantalla distinta.
class _QuoteCard {
  const _QuoteCard({
    required this.title,
    required this.date,
    required this.status,
    required this.onTap,
    this.serviceRequestId,
  });

  final String title;
  final String date;
  final String status;
  final VoidCallback onTap;

  /// Solicitud que representa la tarjeta, cuando se conoce. Sirve para no
  /// pintar dos veces el mismo trabajo cuando llega por las dos fuentes.
  final String? serviceRequestId;
}

/// Diagnóstico fuera de alcance vivo: el id con el que se abre, la píldora que
/// le corresponde y la solicitud desde la que se pinta la tarjeta.
class _OutOfScopeDiagnosis {
  const _OutOfScopeDiagnosis({
    required this.id,
    required this.statusLabel,
    required this.source,
    this.childServiceRequestId,
  });

  final String id;
  final String statusLabel;

  /// Solicitud de servicio de la que salen el nombre del servicio y la fecha de
  /// la visita: siempre la raíz cuando está disponible.
  final Map<String, dynamic> source;

  /// Hijo `OUT_OF_SCOPE` creado al autorizar, cuando ya existe. Es el id con el
  /// que las propuestas de este trabajo llegan en `/dovia-home/proposals`.
  final String? childServiceRequestId;
}

/// Las dos fuentes de "Cotizaciones recibidas", resueltas juntas.
class _QuotesData {
  const _QuotesData({required this.proposals, required this.diagnoses});

  final ApiCallResponse proposals;
  final List<_OutOfScopeDiagnosis> diagnoses;
}

class DHCLIENTHomepageWidget extends StatefulWidget {
  const DHCLIENTHomepageWidget({super.key});

  static String routeName = 'DH_CLIENT_Homepage';
  static String routePath = '/dHCLIENTHomepage';

  /// Visitas recién agendadas desde el flujo de solicitud. La pantalla de
  /// Agenda agrega aquí la nueva solicitud antes de redirigir al Dashboard.
  static final List<ScheduledVisit> upcomingVisits = [];

  /// Dueño de [upcomingVisits]: la lista es estática y sobrevive al cierre de
  /// sesión, así que se vacía si entra otro usuario.
  static String? _upcomingVisitsOwner;

  /// Ids de solicitudes cuya visita el cliente ya confirmó ("Programada").
  /// Se maneja client-side porque el backend no tiene dónde registrarlo: en el
  /// inventario del contexto (59 rutas, verificado el 2026-08-17) no hay
  /// ninguna confirmación de visita del cliente —las únicas que existen son de
  /// pago, imágenes, propuestas de cotización, fuera de alcance y materiales—,
  /// y el flujo SERVICE no define un subestado dentro de `TAKEN` donde
  /// distinguirlo. Al confirmar en la pantalla de detalle se agrega aquí el id
  /// y la tarjeta pierde el punto rojo y pasa de "Confirmar" a "Programada".
  ///
  /// Respaldado por [FFAppState] para que la confirmación sobreviva al
  /// reinicio de la app. Sigue siendo local al dispositivo: el mismo cliente
  /// en otro teléfono volverá a ver "Confirmar".
  /// TODO: derivar el estatus del backend cuando exista el endpoint.
  static Set<String> get confirmedVisitIds =>
      FFAppState().confirmedServiceRequests.toSet();

  /// Marca la visita como confirmada por el cliente.
  static void markVisitConfirmed(String serviceRequestId) {
    if (serviceRequestId.isEmpty) return;
    FFAppState().addToConfirmedServiceRequests(serviceRequestId);
  }

  @override
  State<DHCLIENTHomepageWidget> createState() => _DHCLIENTHomepageWidgetState();
}

class _DHCLIENTHomepageWidgetState extends State<DHCLIENTHomepageWidget> {
  late DHCLIENTHomepageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<ApiCallResponse> _upcomingVisitsFuture;
  late Future<ApiCallResponse> _completedVisitsFuture;
  late Future<ApiCallResponse> _proposalsFuture;

  /// "Cotizaciones recibidas" se arma con dos fuentes: las propuestas que ya
  /// llegaron y los diagnósticos fuera de alcance que el asociado cargó, que
  /// se referencian desde las solicitudes del cliente (no hay un listado propio
  /// de diagnósticos). Se resuelven juntas para que el carrusel no aparezca
  /// primero con la mitad de las tarjetas.
  late Future<_QuotesData> _quotesSectionFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTHomepageModel());

    if (DHCLIENTHomepageWidget._upcomingVisitsOwner != currentUserUid) {
      DHCLIENTHomepageWidget.upcomingVisits.clear();
      DHCLIENTHomepageWidget._upcomingVisitsOwner = currentUserUid;
    }

    _loadDashboardData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carga el estado de suscripcion (Recurrente) para decidir que UI mostrar.
      // Cacheado en el repo: no re-consulta en cada rebuild.
      context.read<PaymentsRepository>().loadCurrentSubscription();
      safeSetState(() {});
    });
  }

  /// (Re)lanza las consultas del Dashboard. Se vuelve a llamar al volver de una
  /// pantalla que pudo cambiarlas (Ej: decidir sobre un diagnóstico fuera de
  /// alcance), porque los `FutureBuilder` releen el Future, no la API.
  void _loadDashboardData() {
    final token = currentAuthenticationToken ?? '';
    // El endpoint valida `status` contra el enum PENDING/TAKEN/IN_PROGRESS/
    // FINISHED y acepta un único valor (un string multi-valor devuelve 400
    // "status invalido"). Para "Próximas visitas" (varios estados) se traen
    // sin filtro, paginando, y se excluye FINISHED (ver
    // [loadUpcomingServiceRequests]); para las finalizadas se filtra
    // directamente por FINISHED.
    _upcomingVisitsFuture =
        loadUpcomingServiceRequests(authToken: token).then((response) {
      // Cuando el backend ya devuelve una solicitud pintada de forma
      // optimista, manda la del backend (con estado real y detalle
      // navegable) y la optimista se descarta.
      if (response.succeeded) {
        final backendIds = (DOVIAAPIDoviaHomeContextGroup
                    .listServiceRequestsCall
                    .requestsList(response.jsonBody) ??
                [])
            .whereType<Map>()
            .map((e) => srId(Map<String, dynamic>.from(e)))
            .where((id) => id.isNotEmpty)
            .toSet();
        final before = DHCLIENTHomepageWidget.upcomingVisits.length;
        DHCLIENTHomepageWidget.upcomingVisits
            .removeWhere((v) => v.id != null && backendIds.contains(v.id));
        if (DHCLIENTHomepageWidget.upcomingVisits.length != before) {
          safeSetState(() {});
        }
      }
      return response;
    });
    _completedVisitsFuture =
        DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall.call(
      authToken: token,
      status: 'FINISHED',
      limit: 2,
    );
    // Se piden varias porque el carrusel agrupa por solicitud: dos proveedores
    // que cotizaron el mismo trabajo son una sola tarjeta.
    _proposalsFuture =
        DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall.call(
      authToken: token,
      limit: 20,
    );
    // Se pasa el Future en vez de leer el campo: una segunda recarga lo
    // reasigna, y esperarlo por campo mezclaría los de dos cargas distintas.
    _quotesSectionFuture = _loadQuotesSection(_proposalsFuture, token);
  }

  /// Resuelve las dos fuentes de "Cotizaciones recibidas" en un solo Future:
  /// las propuestas recibidas y los diagnósticos fuera de alcance vivos. Las
  /// dos consultas arrancan a la vez.
  Future<_QuotesData> _loadQuotesSection(
    Future<ApiCallResponse> proposalsFuture,
    String token,
  ) async {
    final diagnosesFuture = _loadDiagnoses(token);
    return _QuotesData(
      proposals: await proposalsFuture,
      diagnoses: await diagnosesFuture,
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildServiceCard(String title, String iconPath,
      {bool isEmergency = false, VoidCallback? onTap, double width = 100.0}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: 100.0,
        decoration: BoxDecoration(
          color:
              isEmergency ? FlutterFlowTheme.of(context).success : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 14.0,
              offset: Offset(0.0, 4.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isEmergency
                    ? Colors.white.withOpacity(0.3)
                    : const Color(0xFF007376),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    iconPath,
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.contain,
                    colorFilter: isEmergency
                        ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                        : null,
                  ),
                ),
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: isEmergency
                        ? Colors.white
                        : FlutterFlowTheme.of(context).primaryText,
                    fontSize: 12.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Abre la pantalla de levantamiento del servicio (describir problema y
  /// subir fotos) con el título de la categoría elegida. Al continuar, el
  /// cliente sin suscripción avanza a la pantalla de valor de la visita.
  void _openServiceDetail(String serviceTitle) {
    DHCLIENTInstalacionWidget.serviceTitle = serviceTitle;
    // Solicitud nueva: descarta el levantamiento de una anterior sin enviar
    // (categoría, descripción y fotos).
    DHCLIENTInstalacionWidget.resetDraft();
    context.pushNamed(DHCLIENTInstalacionWidget.routeName);
  }

  String? _str(dynamic v) =>
      (v is String && v.trim().isNotEmpty) ? v.trim() : null;

  /// Etiqueta que ve el cliente en la tarjeta de "Próximas visitas". El mapeo
  /// contra el payload real vive en [service_request_fields.dart], compartido
  /// con el listado completo para que la misma solicitud se pinte igual en
  /// ambas pantallas.
  String _visitStatusLabel(Map<String, dynamic> data) =>
      srStatusLabel(data, DHCLIENTHomepageWidget.confirmedVisitIds);

  /// Abre la pantalla de detalle (Casa A) con los datos de la solicitud. Los
  /// campos son de solo lectura; el botón "Aceptar" aparece únicamente cuando
  /// hay una visita tomada por un asociado pendiente de confirmar. Al volver
  /// refresca el Dashboard.
  void _openVisitDetail(Map<String, dynamic> data) {
    // Sin pagar: se retoma el cobro, no hay visita que mostrar todavía.
    if (srAwaitsPayment(data)) {
      openPendingPayment(context, data).then((_) => safeSetState(() {}));
      return;
    }
    DHCLIENTCasaAWidget.requestData = data;
    DHCLIENTCasaAWidget.houseName = srHouseName(data);
    final id = srId(data);
    // Desde el Dashboard sí se confirma la visita (no es modo consulta).
    DHCLIENTCasaAWidget.readOnly = false;
    DHCLIENTCasaAWidget.alreadyConfirmed =
        DHCLIENTHomepageWidget.confirmedVisitIds.contains(id);
    context
        .pushNamed(DHCLIENTCasaAWidget.routeName)
        .then((_) => safeSetState(() {}));
  }

  Widget _buildTrustItem(String iconPath, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(iconPath,
                  colorFilter: ColorFilter.mode(
                      FlutterFlowTheme.of(context).primary, BlendMode.srcIn)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.publicSans(
                          fontWeight: FontWeight.w600,
                        ),
                        color: FlutterFlowTheme.of(context).primary,
                        fontSize: 14.0,
                      ),
                ),
                Text(
                  subtitle,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Item de beneficio (check naranja + texto blanco) usado en las tarjetas
  /// Premium.
  Widget _buildPremiumCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Caja cuadrada translucida usada como contenedor de icono/contador dentro
  /// de las tarjetas Premium.
  Widget _buildPremiumTile({required Widget child}) {
    return Container(
      width: 64.0,
      height: 64.0,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: child,
    );
  }

  /// Botón blanco tipo pill al pie de las tarjetas Premium.
  Widget _buildPremiumPillButton(String text, VoidCallback onPressed) {
    return FFButtonWidget(
      onPressed: onPressed,
      text: text,
      options: FFButtonOptions(
        width: double.infinity,
        height: 40.0,
        color: Colors.white,
        textStyle: GoogleFonts.publicSans(
          color: FlutterFlowTheme.of(context).primary,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
        borderRadius: BorderRadius.circular(24.0),
      ),
    );
  }

  /// Tarjeta Premium "Servicios incluidos disponibles": contador dinamico de
  /// servicios gratuitos del plan (usados/total) + perks, incluyendo la regla
  /// de negocio del 35% de descuento en cotizaciones.
  ///
  /// TODO: `usedServices`/`totalServices` deben inyectarse desde el plan del
  /// backend cuando exista el endpoint; por ahora son placeholders.
  Widget _buildIncludedServicesCard() {
    const usedServices = 1;
    const totalServices = 2;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Servicios incluidos disponibles',
            style: GoogleFonts.publicSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _buildPremiumTile(
                    child: const Icon(Icons.calendar_month,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 8),
                  _buildPremiumTile(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$usedServices/$totalServices',
                          style: GoogleFonts.publicSans(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'total\ndisponibles',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 8,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPremiumCheckItem('Atención prioritaria'),
                    _buildPremiumCheckItem('Descuentos únicos del 35%'),
                    _buildPremiumCheckItem('Cotización disponible'),
                    _buildPremiumCheckItem('Tiempo de espera reducido'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPremiumPillButton('Califica nuestra app', () {
            // TODO: enlazar a la calificacion de la app (store review).
            print('Califica nuestra app');
          }),
        ],
      ),
    );
  }

  /// Único punto de entrada al flujo de cotización: sólo se renderiza para
  /// clientes con suscripción activa, por lo que "Solicitar" es la vía por la
  /// que el Cliente Premium levanta un requerimiento a medida.
  void _openQuoteRequest() {
    // Cada solicitud arranca limpia: descarta la ubicación verificada y la
    // navegación pendiente que pudiera haber quedado de un intento anterior.
    DHCLIENTCotizacionWidget.verifiedAddressId = null;
    DHCLIENTCotizacionWidget.verifiedAddressLabel = null;
    DHCLIENTUbicacionWidget.pendingNextRoute = null;
    context
        .pushNamed(DHCLIENTCotizacionWidget.routeName)
        .then((_) => safeSetState(() {}));
  }

  /// Tarjeta Premium "Solicita una Cotización": acceso directo al flujo de
  /// cotizacion (trabajos grandes o a medida). El boton "Solicitar" abre el
  /// formulario de cotizacion.
  Widget _buildQuoteRequestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solicita una Cotización',
            style: GoogleFonts.publicSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPremiumTile(
                child: const Icon(Icons.request_quote,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPremiumCheckItem('Atención prioritaria'),
                    _buildPremiumCheckItem('Cotización personalizada'),
                    _buildPremiumCheckItem(
                        'Garantía de Dovia en todos los trabajos'),
                    _buildPremiumCheckItem(
                        '¿Tienes un gran problema? Escríbenos'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPremiumPillButton('Solicitar', _openQuoteRequest),
        ],
      ),
    );
  }

  /// Título de la solicitud a la que pertenece la propuesta. El catálogo la
  /// etiqueta en `serviceDetail.label`; se prueban las otras claves porque el
  /// endpoint de propuestas no siempre anida el detalle completo.
  String _proposalRequestTitle(Map<String, dynamic> proposal) {
    final request = proposal['serviceRequest'];
    final requestMap =
        request is Map ? Map<String, dynamic>.from(request) : null;
    final detail = requestMap?['serviceDetail'];
    return _str(detail is Map ? detail['label'] : null) ??
        _str(requestMap?['title']) ??
        _str(requestMap?['serviceName']) ??
        _str(proposal['serviceName']) ??
        'Cotización de servicio';
  }

  /// Solicitud a la que pertenece la propuesta: es la que abre la pantalla de
  /// comparación al tocar la tarjeta.
  String? _proposalRequestId(Map<String, dynamic> proposal) {
    final request = proposal['serviceRequest'];
    return _str(proposal['serviceRequestId']) ??
        _str(request is Map ? request['id'] : null);
  }

  /// Píldora de la tarjeta. El enum de la propuesta es
  /// `SUBMITTED | REJECTED | ACCEPTED`: mientras el cliente no decida queda en
  /// `SUBMITTED`, que para él es "Pendiente" aunque el proveedor ya la haya
  /// enviado.
  String _proposalStatusLabel(Map<String, dynamic> proposal) =>
      proposalStatusLabel(proposal);

  /// Fecha con el formato del diseño (DD/MM/AAAA). Sin fecha se deja el
  /// placeholder en vez de inventar una.
  String _shortDate(DateTime? date) {
    if (date == null) return 'DD/MM/AAAA';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  DateTime? _parseDate(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw)?.toLocal();

  /// Fecha en la que se recibió la propuesta.
  String _proposalDate(Map<String, dynamic> proposal) => _shortDate(
      _parseDate(_str(proposal['createdAt']) ?? _str(proposal['sentAt'])));

  /// Subestados de la solicitud que delatan un trabajo fuera de alcance vivo,
  /// con la píldora que le corresponde a cada uno.
  ///
  /// El cliente no tiene un listado de diagnósticos: lo que sí expone el
  /// backend es el subestado de la solicitud de servicio. Al crear el
  /// diagnóstico la raíz queda en `OUT_OF_SCOPE_ACCEPTANCE_PENDING` esperando
  /// la decisión del cliente, y al autorizarlo tanto la raíz como el hijo
  /// pasan a `OUT_OF_SCOPE_QUOTING`.
  ///
  /// Más adelante (`OUT_OF_SCOPE_PAYMENT_PENDING`, `..._EXECUTION_ACTIVE`) ya
  /// hay una propuesta aceptada, así que el trabajo llega por el listado de
  /// propuestas y no hace falta buscarlo acá.
  static const Map<String, String> _outOfScopeSubStatuses = {
    'OUT_OF_SCOPE_ACCEPTANCE_PENDING': 'Pendiente',
    'OUT_OF_SCOPE_QUOTING': kPendingQuoteStatusLabel,
  };

  /// Diagnósticos fuera de alcance vivos del cliente.
  ///
  /// Se consulta un subestado por llamada porque el endpoint acepta un único
  /// valor (igual que el filtro de `status` en "Próximas visitas").
  Future<List<_OutOfScopeDiagnosis>> _loadDiagnoses(String token) async {
    final responses = await Future.wait(_outOfScopeSubStatuses.keys.map(
        (subStatus) => DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall
            .call(authToken: token, subStatus: subStatus, limit: 20)));

    // Índice por id de solicitud: una vez autorizado el diagnóstico, la raíz y
    // el hijo vuelven los dos en la misma respuesta. El hijo es el que trae el
    // id del diagnóstico; la raíz, el nombre real del servicio y la fecha de la
    // visita (el hijo se etiqueta "Trabajo fuera de alcance" y llega sin
    // `scheduledAt`), así que hace falta cruzarlos.
    final requests = <String, Map<String, dynamic>>{};
    final order = <String>[];
    for (final response in responses) {
      if (!response.succeeded) continue;
      final list = DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall
              .requestsList(response.jsonBody) ??
          [];
      for (final item in list.whereType<Map>()) {
        final data = Map<String, dynamic>.from(item);
        final id = srId(data);
        if (id.isEmpty || requests.containsKey(id)) continue;
        requests[id] = data;
        order.add(id);
      }
    }

    final diagnoses = <String, _OutOfScopeDiagnosis>{};
    for (final id in order) {
      final data = requests[id]!;
      final statusLabel =
          _outOfScopeSubStatuses[(_str(data['subStatus']) ?? '').toUpperCase()];
      if (statusLabel == null) continue;

      final diagnosisId = _diagnosisIdOf(data);
      // Sin el id del diagnóstico la tarjeta no tendría qué abrir.
      if (diagnosisId == null) continue;

      // Raíz e hijo describen el mismo diagnóstico: gana el hijo, que es el
      // único que aporta el id de la solicitud hija. La tarjeta se pinta con la
      // raíz en los dos casos.
      final isChild = srRequestType(data) == 'OUT_OF_SCOPE';
      if (diagnoses.containsKey(diagnosisId) && !isChild) continue;

      final rootId = _str(data['rootServiceRequestId']);
      diagnoses[diagnosisId] = _OutOfScopeDiagnosis(
        id: diagnosisId,
        statusLabel: statusLabel,
        source: (rootId == null ? null : requests[rootId]) ?? data,
        childServiceRequestId: isChild ? id : null,
      );
    }
    return diagnoses.values.toList();
  }

  /// Id de la solicitud fuera de alcance asociada a una solicitud de servicio.
  ///
  /// El hijo `OUT_OF_SCOPE` lo expone directo en `outOfScopeRequestId`. La raíz
  /// no —ahí los campos de relación llegan en `null`—, así que mientras el
  /// diagnóstico espera la decisión del cliente el único lugar donde puede
  /// venir es `activeAdditionalFlow`, el bloqueo que la raíz mantiene sobre la
  /// unidad mientras hay un flujo adicional activo.
  String? _diagnosisIdOf(Map<String, dynamic> data) {
    final direct = _str(data['outOfScopeRequestId']);
    if (direct != null) return direct;

    final flow = data['activeAdditionalFlow'];
    if (flow is! Map) return null;
    // El bloqueo también lo usan los materiales extras: si declara de qué flujo
    // es, se descarta el que no corresponde.
    final type = (_str(flow['type']) ?? '').toUpperCase();
    if (type.isNotEmpty && !type.contains('OUT_OF_SCOPE')) return null;
    for (final key in [
      'outOfScopeRequestId',
      'requestId',
      'referenceId',
      'id'
    ]) {
      final value = _str(flow[key]);
      if (value != null) return value;
    }
    return null;
  }

  /// Seccion "Cotizaciones recibidas": diagnosticos de trabajos fuera de
  /// alcance que la red de proveedores cotizo para el cliente.
  ///
  /// Las tarjetas van en scroll horizontal, como en el diseño: se muestra una
  /// por solicitud (no una por propuesta, que repetiría la misma cotización
  /// tantas veces como proveedores respondieron).
  ///
  /// El encabezado se pinta siempre que la sección se muestre —igual que
  /// "Visitas Finalizadas"—: tiene que existir en el Dashboard aunque todavía
  /// no haya cotizaciones, si no el cliente no sabe que el espacio está ahí.
  /// "Ver todo" como el "Ver más" del home de Dovia: texto sin fondo.
  Widget _verTodoLink(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        'Ver todo',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).primary,
              fontSize: 14.0,
            ),
      ),
    );
  }

  Widget _quotesSection(Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cotizaciones recibidas',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      fontSize: 16.0,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
              ),
              _verTodoLink(() {
                // Sin solicitud fijada la pantalla lista todas las propuestas
                // recibidas por el cliente.
                _openProposals(null);
              }),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Cotizaciones generadas a partir de diagnósticos',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: FlutterFlowTheme.of(context).secondaryText),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  /// Sección completa, con su contenido resuelto.
  ///
  /// La sección es exclusiva de Premium **salvo** cuando hay un diagnóstico
  /// fuera de alcance esperando decisión: esa tarjeta es el único acceso del
  /// cliente sin plan a la pantalla del diagnóstico, donde puede finalizar el
  /// servicio o suscribirse. El bloqueo de Premium vive dentro de esa pantalla,
  /// al pedir la cotización; ocultarle la tarjeta lo dejaría sin ninguna de las
  /// dos salidas.
  Widget _buildCotizacionesRecibidas(bool hasSubscription) {
    return FutureBuilder<_QuotesData>(
      future: _quotesSectionFuture,
      builder: (context, snapshot) {
        Widget onlyForSubscribers(Widget content) =>
            hasSubscription ? _quotesSection(content) : const SizedBox.shrink();

        if (snapshot.hasError) {
          return onlyForSubscribers(_quotesPlaceholder(
              'No pudimos cargar tus cotizaciones. Intenta de nuevo más tarde.'));
        }
        if (!snapshot.hasData) {
          return onlyForSubscribers(
              const Center(child: DoviaSpinner()));
        }

        final data = snapshot.data!;
        final proposalCards = _proposalCards(data.proposals);
        // Los diagnósticos van primero: son los únicos que le piden una
        // decisión al cliente, y el carrusel corta en 5 tarjetas.
        final cards = [
          ..._outOfScopeCards(
            data.diagnoses,
            proposalCards
                .map((card) => card.serviceRequestId)
                .whereType<String>()
                .toSet(),
          ),
          ...proposalCards,
        ];

        if (cards.isEmpty) {
          return onlyForSubscribers(_quotesPlaceholder(data.proposals.succeeded
              ? 'Todavía no recibiste cotizaciones. Te avisaremos cuando los proveedores envíen sus propuestas.'
              : 'No pudimos cargar tus cotizaciones. Intenta de nuevo más tarde.'));
        }
        return _quotesSection(_buildQuotesCarousel(cards.take(5).toList()));
      },
    );
  }

  /// Tarjetas de las propuestas recibidas. Una por solicitud cotizada: varias
  /// propuestas de la misma solicitud son la *misma* cotización para el
  /// cliente, y al tocarla las compara todas en la pantalla de cotizaciones
  /// recibidas.
  List<_QuoteCard> _proposalCards(ApiCallResponse response) {
    if (!response.succeeded) return [];
    // `proposalsList` resuelve un JsonPath sobre el JSON decodificado, no sobre
    // el ApiCallResponse: hay que pasarle `jsonBody`.
    final proposals = DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall
            .proposalsList(response.jsonBody) ??
        [];

    final cards = <_QuoteCard>[];
    final seenRequestIds = <String>{};
    for (final proposal in proposals.whereType<Map>()) {
      final data = Map<String, dynamic>.from(proposal);
      final requestId = _proposalRequestId(data);
      // Si el backend no informa la solicitud la propuesta se muestra igual (al
      // tocarla se abre el listado completo), pero entonces no hay con qué
      // agruparla: se la trata como una cotización aparte.
      final key = requestId ?? _str(data['id']) ?? 'proposal_${cards.length}';
      if (!seenRequestIds.add(key)) continue;
      cards.add(_QuoteCard(
        title: _proposalRequestTitle(data),
        date: _proposalDate(data),
        status: _proposalStatusLabel(data),
        onTap: () => _openProposals(requestId),
        serviceRequestId: requestId,
      ));
    }
    return cards;
  }

  /// Tarjetas de los diagnósticos fuera de alcance.
  ///
  /// Son el aviso de que un asociado catalogó el trabajo como fuera de alcance:
  /// al tocarla el cliente ve el diagnóstico y decide si quiere que la red se
  /// lo cotice.
  ///
  /// [quotedRequestIds] son los trabajos que ya tienen propuesta: para esos la
  /// tarjeta de la propuesta dice más ("Pendiente de Cotización" cuando ya hay
  /// algo que comparar sería un paso atrás), así que no se duplican.
  List<_QuoteCard> _outOfScopeCards(
      List<_OutOfScopeDiagnosis> diagnoses, Set<String> quotedRequestIds) {
    return [
      for (final diagnosis in diagnoses)
        if (!quotedRequestIds.contains(diagnosis.childServiceRequestId))
          _QuoteCard(
            title: srServiceName(diagnosis.source),
            // La visita ya ocurrió: es en ella donde el asociado levantó el
            // diagnóstico. Si la solicitud no trae fecha agendada se cae a la
            // de creación.
            date: _shortDate(srScheduledAt(diagnosis.source) ??
                srCreatedAt(diagnosis.source)),
            status: diagnosis.statusLabel,
            onTap: () => _openOutOfScopeDiagnosis(diagnosis.id),
            serviceRequestId: diagnosis.childServiceRequestId,
          ),
    ];
  }

  /// Abre la comparación de propuestas. Sin solicitud se listan todas las
  /// recibidas por el cliente.
  void _openProposals(String? serviceRequestId) {
    DHCLIENTCotizacionesRecibidasWidget.serviceRequestId = serviceRequestId;
    context
        .pushNamed(DHCLIENTCotizacionesRecibidasWidget.routeName)
        .then((_) => safeSetState(_loadDashboardData));
  }

  /// Abre el diagnóstico fuera de alcance para que el cliente decida si quiere
  /// que la red le cotice el trabajo. Al volver se recargan los datos: autorizar
  /// o finalizar cambia el estado de la tarjeta.
  void _openOutOfScopeDiagnosis(String requestId) {
    DHCLIENTFueraDeAlcanceWidget.outOfScopeRequestId = requestId;
    context
        .pushNamed(DHCLIENTFueraDeAlcanceWidget.routeName)
        .then((_) => safeSetState(_loadDashboardData));
  }

  Widget _quotesPlaceholder(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 12,
          height: 1.4,
          color: FlutterFlowTheme.of(context).secondaryText,
        ),
      ),
    );
  }

  /// Scroll horizontal de las cotizaciones recibidas (diseño del Dashboard).
  /// La fila sangra hasta el borde derecho —el padding lo pone el propio
  /// scroll— para que se vea que hay más tarjetas.
  Widget _buildQuotesCarousel(List<_QuoteCard> cards) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Con una sola cotización no hay nada que deslizar: ancho completo.
    final cardWidth = cards.length == 1
        ? screenWidth - 40.0
        : (screenWidth * 0.82).clamp(260.0, 340.0).toDouble();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Todas las tarjetas quedan del alto de la más alta, para que la fila se
      // lea pareja.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++)
              Padding(
                padding:
                    EdgeInsets.only(right: i == cards.length - 1 ? 0.0 : 12.0),
                child: SizedBox(
                  width: cardWidth,
                  child: InkWell(
                    onTap: cards[i].onTap,
                    borderRadius: BorderRadius.circular(16.0),
                    child: _buildQuoteResultCard(
                      title: cards[i].title,
                      subtitle: 'Visita realizada',
                      date: cards[i].date,
                      status: cards[i].status,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Colores de la píldora de estatus, con el mismo criterio que las tarjetas
  /// de visitas ([DHCLIENTProximasVisitasWidget]).
  Color _quotePillBackground(String status) {
    switch (status) {
      case 'Aceptada':
        return const Color(0xFFDCF5E3);
      case 'Rechazada':
      case 'Vencida':
        return const Color(0xFFFFE5E5);
      default:
        return const Color(0xFFFFE3D2);
    }
  }

  Color _quotePillText(String status) {
    switch (status) {
      case 'Aceptada':
        return const Color(0xFF1E7A46);
      case 'Rechazada':
      case 'Vencida':
        return Colors.red;
      default:
        return const Color(0xFFC2410C);
    }
  }

  /// Tarjeta de una cotizacion recibida: icono del servicio, titulo del
  /// trabajo, estado de la visita, fecha y pill de estatus abajo a la derecha
  /// (diseño del Dashboard).
  Widget _buildQuoteResultCard({
    required String title,
    required String subtitle,
    required String date,
    String status = 'Pendiente',
  }) {
    final secondaryText = FlutterFlowTheme.of(context).secondaryText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).alternate,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(srServiceIconAsset(title)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.publicSans(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(subtitle,
                    style:
                        GoogleFonts.inter(color: secondaryText, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 13.0, color: secondaryText),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        date,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Estatus',
                        style: GoogleFonts.inter(
                            color: secondaryText, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: _quotePillBackground(status),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w600,
                            color: _quotePillText(status),
                            fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bloque neutro que ocupa el lugar del banner o de las tarjetas Premium
  /// mientras se resuelve la suscripción, para que la pantalla no salte.
  Widget _buildSubscriptionPlaceholder() {
    return Container(
      width: double.infinity,
      height: 140.0,
      decoration: BoxDecoration(
        color: const Color(0x14007376),
        borderRadius: BorderRadius.circular(16.0),
      ),
      alignment: Alignment.center,
      child: const DoviaSpinner(small: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Estado real de suscripcion (Recurrente) desde PaymentsRepository.
    // `hasActiveSubscription` es true para ACTIVE, PAST_DUE y CANCEL_SCHEDULED,
    // que es el criterio con el que el backend habilita los beneficios Premium.
    final payments = context.watch<PaymentsRepository>();
    final hasSubscription = payments.hasActiveSubscription;
    // Mientras no se sabe el estado no se muestra ninguna de las dos
    // variantes: si no, un suscriptor ve un instante el upsell de Premium.
    // Si la consulta falló se sigue como sin plan, igual que antes, en vez de
    // dejar el indicador girando.
    final subscriptionKnown = payments.subscriptionLoaded ||
        (!payments.isLoading && payments.error != null);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            wrapWithModel(
              model: _model.cornerGradientBackgroundModel,
              updateCallback: () => safeSetState(() {}),
              child: const CornerGradientBackgroundWidget(),
            ),
            StatusBarClip(
                child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIASHAREDHeaderWidget(
                      showSupport: false,
                      belowStatusBar: true,
                      showNotifications: true,
                      showSettings: true,
                      title: 'Dovia Home',
                      // Sin el logotipo el titulo entra en una sola linea
                      // junto a los avisos y los ajustes.
                      showLogo: false,
                      showMap: false,
                      showCurrency: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 20.0, 20.0, 100.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Banner
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image:
                                  AssetImage('assets/images/TuHogarBanner.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tu hogar,\nresuelto.",
                                  style: GoogleFonts.publicSans(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Soluciones confiables para\ntu hogar, cuando las necesites.",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Catalogo de Servicios
                        Text(
                          'Servicios que encontraras en Dovia Home',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600),
                                    fontSize: 16.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        // Tres columnas iguales que ocupan todo el ancho: la
                        // grilla queda alineada con el resto del contenido.
                        LayoutBuilder(builder: (context, constraints) {
                          const gap = 12.0;
                          final cardWidth =
                              (constraints.maxWidth - gap * 2) / 3;
                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              _buildServiceCard('Plomería',
                                  'assets/images/IconoServicioPlomeria.svg',
                                  onTap: () => _openServiceDetail('Plomería'),
                                  width: cardWidth),
                              _buildServiceCard('Eléctrico',
                                  'assets/images/IconoServicioElectrico.svg',
                                  onTap: () => _openServiceDetail('Eléctrico'),
                                  width: cardWidth),
                              _buildServiceCard('Albañilería',
                                  'assets/images/IconoServicioAlbaileria.svg',
                                  onTap: () =>
                                      _openServiceDetail('Albañilería'),
                                  width: cardWidth),
                              _buildServiceCard('Pintura',
                                  'assets/images/IconServicioPintura.svg',
                                  onTap: () => _openServiceDetail('Pintura'),
                                  width: cardWidth),
                              _buildServiceCard('Instalación',
                                  'assets/images/IconServicioInstalacion.svg',
                                  onTap: () =>
                                      _openServiceDetail('Instalación'),
                                  width: cardWidth),
                              _buildServiceCard('Servicio de\nemergencia',
                                  'assets/images/warning-triangle.svg',
                                  isEmergency: true, onTap: () {
                                // Abierto a todos los clientes: el estatus de la
                                // cuenta se resuelve más adelante, en el paso de
                                // cobro (descuento Premium vs. pago regular +
                                // upsell para Free).
                                DHCLIENTUbicacionWidget.pendingNextRoute =
                                    DHCLIENTEmergenciasWidget.routeName;
                                context.pushNamed(
                                    DHCLIENTUbicacionWidget.routeName);
                              }, width: cardWidth),
                            ],
                          );
                        }),
                        const SizedBox(height: 30),

                        // Banner Suscripcion
                        if (!subscriptionKnown) ...[
                          _buildSubscriptionPlaceholder(),
                          const SizedBox(height: 30),
                        ],
                        Visibility(
                          visible: subscriptionKnown && !hasSubscription,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Suscribete y aprovecha de todos los beneficios de Dovia Home',
                                  style: GoogleFonts.publicSans(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...[
                                  'Servicios programados con mínimo de 24 horas de anticipación',
                                  'Atención de emergencia con tiempo objetivo menor a 18 horas',
                                  '1 servicio mensual incluido (programado o emergencia)',
                                  'Acceso a cotizaciones',
                                  'Atención prioritaria'
                                ]
                                    .map((benefit) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.check_circle,
                                                  color: Colors.orange,
                                                  size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  benefit,
                                                  style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                const SizedBox(height: 16),
                                FFButtonWidget(
                                  onPressed: () {
                                    context.pushNamed(
                                        DHCLIENTPlanesPageWidget.routeName);
                                  },
                                  text: 'Quiero suscribirme',
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 40.0,
                                    color: Colors.white,
                                    textStyle: GoogleFonts.publicSans(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (subscriptionKnown && !hasSubscription)
                          const SizedBox(height: 30),

                        // Tarjetas Premium (usuario con suscripcion activa)
                        if (subscriptionKnown && hasSubscription) ...[
                          if (payments.subscriptionNeedsRenewal) ...[
                            const SubscriptionRenewalNotice(),
                            const SizedBox(height: 16),
                          ],
                          _buildIncludedServicesCard(),
                          const SizedBox(height: 16),
                          _buildQuoteRequestCard(),
                          const SizedBox(height: 30),
                        ],

                        // Proximas Visitas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Próximas visitas',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600),
                                    fontSize: 16.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                            ),
                            _verTodoLink(() {
                              context.pushNamed(
                                  DHCLIENTProximasVisitasListaWidget.routeName);
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Revisa y gestiona las visitas ya calendizadas',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color:
                                  FlutterFlowTheme.of(context).secondaryText),
                        ),
                        const SizedBox(height: 12),
                        // Solicitudes recién agendadas (estatus Pendiente).
                        ...DHCLIENTHomepageWidget.upcomingVisits.map(
                          (visit) => Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: DHCLIENTProximasVisitasWidget(
                              title: visit.service,
                              date: '${visit.date} · ${visit.time}',
                              status: visit.status,
                              isEmergency: visit.isEmergency,
                              icom: srServiceIconAsset(visit.service),
                            ),
                          ),
                        ),
                        // Regla UI: Lista dinamica del backend
                        FutureBuilder<ApiCallResponse>(
                          future: _upcomingVisitsFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: DoviaSpinner());
                            }
                            final response = snapshot.data!;
                            if (!response.succeeded) {
                              // Antes se ocultaba la sección y parecía que no
                              // había visitas.
                              return ErrorStateWidget.fromResponse(
                                response,
                                onRetry: () =>
                                    safeSetState(_loadDashboardData),
                              );
                            }
                            final rawVisits = DOVIAAPIDoviaHomeContextGroup
                                    .listServiceRequestsCall
                                    .requestsList(response.jsonBody) ??
                                [];
                            // Ids ya pintados de forma optimista al volver de
                            // crear la solicitud: no se repiten desde el backend.
                            final optimisticIds = DHCLIENTHomepageWidget
                                .upcomingVisits
                                .map((v) => v.id)
                                .whereType<String>()
                                .toSet();
                            // Solo próximas: excluye las solicitudes finalizadas
                            // (FINISHED) y toma las 2 primeras.
                            final visits = rawVisits
                                .whereType<Map>()
                                .map((e) => Map<String, dynamic>.from(e))
                                .where((data) =>
                                    !optimisticIds.contains(srId(data)))
                                .where((data) =>
                                    (srString(data['status']) ?? 'PENDING')
                                        .toUpperCase() !=
                                    'FINISHED')
                                .take(2)
                                .toList();
                            if (visits.isEmpty &&
                                DHCLIENTHomepageWidget.upcomingVisits.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: visits.map((data) {
                                final id = srId(data);
                                final status = _visitStatusLabel(data);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: InkWell(
                                    onTap: id.isNotEmpty
                                        ? () => _openVisitDetail(data)
                                        : null,
                                    borderRadius: BorderRadius.circular(14.0),
                                    child: DHCLIENTProximasVisitasWidget(
                                      title: srServiceName(data),
                                      date: srFormattedDate(data),
                                      status: status,
                                      isEmergency: srIsEmergency(data),
                                      showRedDot: status == 'Confirmar',
                                      icom: srIconAsset(data),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 30),

                        // Visitas Finalizadas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Visitas Finalizadas',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600),
                                    fontSize: 16.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                            ),
                            _verTodoLink(() {
                              context.pushNamed(
                                  DHCLIENTVisitasFinalizadasListaWidget
                                      .routeName);
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Revisa y gestiona las visitas ya Finalizadas',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color:
                                  FlutterFlowTheme.of(context).secondaryText),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<ApiCallResponse>(
                          future: _completedVisitsFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: DoviaSpinner());
                            }
                            final response = snapshot.data!;
                            if (!response.succeeded) {
                              return const SizedBox.shrink();
                            }
                            final visits = DOVIAAPIDoviaHomeContextGroup
                                    .listServiceRequestsCall
                                    .requestsList(response.jsonBody) ??
                                [];
                            if (visits.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: visits.take(2).map((visitData) {
                                final data = visitData as Map<String, dynamic>;
                                final title = data['serviceName'] ?? 'Servicio';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SvgPicture.asset(
                                                'assets/images/IconoServicioPlomeria.svg'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(title,
                                                  style: GoogleFonts.publicSans(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14)),
                                              const SizedBox(height: 4),
                                              Text('Visita realizada',
                                                  style: GoogleFonts.inter(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 50),

                        // Cotizaciones recibidas. Exclusiva de Premium, salvo
                        // que haya un diagnóstico fuera de alcance esperando la
                        // decisión del cliente.
                        _buildCotizacionesRecibidas(hasSubscription),

                        // Footer Confianza
                        _buildTrustItem(
                            'assets/images/check.svg',
                            'Asociados verificados',
                            'Ejecutan bajo estándares DOVIA. No improvisamos, operamos.'),
                        _buildTrustItem(
                            'assets/images/position.svg',
                            'Precios claros desde el inicio',
                            'Ves costo real, descuentos y ahorro antes de confirmar.'),
                        _buildTrustItem(
                            'assets/images/IconRayito.svg',
                            'Respuesta en tiempo real',
                            'Emergencias sin espera. Actuamos lo antes posible.'),
                        _buildTrustItem(
                            'assets/images/help-circle.svg',
                            'Sin fricción en el proceso',
                            'Solicitas, apruebas y resuelves sin llamadas ni vueltas.'),
                        _buildTrustItem(
                            'assets/images/IconEscudo.svg',
                            'DOVIA supervisa todo el proceso',
                            'Cada servicio es monitoreado para garantizar calidad.'),

                        const SizedBox(height: 100), // Space for Navbar
                      ],
                    ),
                  ),
                ],
              ),
            )),
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(1.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 15.0, 12.0),
                      child: wrapWithModel(
                        model: _model.fixedDoviaIconModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const FixedDoviaIconWidget(),
                      ),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.dHCLIENTNavbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHCLIENTNavbarWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
