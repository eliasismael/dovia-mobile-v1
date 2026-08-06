import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_proximas_visitas/d_h_c_l_i_e_n_t_proximas_visitas_widget.dart';
import '/dovia_home_client/service_request_fields.dart';
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

class DHCLIENTHomepageWidget extends StatefulWidget {
  const DHCLIENTHomepageWidget({super.key});

  static String routeName = 'DH_CLIENT_Homepage';
  static String routePath = '/dHCLIENTHomepage';

  /// Visitas recién agendadas desde el flujo de solicitud. La pantalla de
  /// Agenda agrega aquí la nueva solicitud antes de redirigir al Dashboard.
  static final List<ScheduledVisit> upcomingVisits = [];

  /// Ids de solicitudes cuya visita el cliente ya confirmó ("Programada").
  /// Se maneja client-side porque aún no existe endpoint de confirmación en el
  /// backend; al confirmar en la pantalla de detalle se agrega aquí el id y la
  /// tarjeta pierde el punto rojo y pasa de "Confirmar" a "Programada".
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTHomepageModel());
    
    final token = currentAuthenticationToken ?? '';
    // El endpoint valida `status` contra el enum PENDING/TAKEN/IN_PROGRESS/
    // FINISHED y acepta un único valor (un string multi-valor devuelve 400
    // "status invalido"). Para "Próximas visitas" (varios estados) se traen
    // todas sin filtro y se excluye FINISHED client-side; para las finalizadas
    // se filtra directamente por FINISHED.
    _upcomingVisitsFuture = DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall.call(
      authToken: token,
      limit: 20,
    );
    _completedVisitsFuture = DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall.call(
      authToken: token,
      status: 'FINISHED',
      limit: 2,
    );
    // Se piden varias porque el carrusel agrupa por solicitud: dos proveedores
    // que cotizaron el mismo trabajo son una sola tarjeta.
    _proposalsFuture = DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall.call(
      authToken: token,
      limit: 20,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carga el estado de suscripcion (Recurrente) para decidir que UI mostrar.
      // Cacheado en el repo: no re-consulta en cada rebuild.
      context.read<PaymentsRepository>().loadCurrentSubscription();
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildServiceCard(String title, String iconPath,
      {bool isEmergency = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          color: isEmergency
              ? FlutterFlowTheme.of(context).success
              : FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(8.0),
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
                    : const Color(0x98007376),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
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
    DHCLIENTInstalacionWidget.alcanzables = [];
    // Solicitud nueva: descarta el levantamiento de una anterior sin enviar.
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
    DHCLIENTCasaAWidget.requestData = data;
    DHCLIENTCasaAWidget.houseName = srHouseName(data);
    final id = srId(data);
    // Desde el Dashboard sí se confirma la visita (no es modo consulta).
    DHCLIENTCasaAWidget.readOnly = false;
    DHCLIENTCasaAWidget.alreadyConfirmed = DHCLIENTHomepageWidget.confirmedVisitIds.contains(id);
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
    final requestMap = request is Map ? Map<String, dynamic>.from(request) : null;
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

  /// Píldora de la tarjeta. Mientras el cliente no acepte ninguna propuesta la
  /// cotización sigue "Pendiente" para él, aunque el proveedor ya la haya
  /// enviado.
  String _proposalStatusLabel(Map<String, dynamic> proposal) {
    switch ((_str(proposal['status']) ?? '').toUpperCase()) {
      case 'ACCEPTED':
        return 'Aceptada';
      case 'REJECTED':
        return 'Rechazada';
      case 'EXPIRED':
        return 'Vencida';
      default:
        return 'Pendiente';
    }
  }

  /// Fecha en la que se recibió la propuesta, con el formato del diseño
  /// (DD/MM/AAAA).
  String _proposalDate(Map<String, dynamic> proposal) {
    final raw = _str(proposal['createdAt']) ?? _str(proposal['sentAt']);
    final parsed = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    if (parsed == null) return 'DD/MM/AAAA';
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day/$month/${parsed.year}';
  }

  /// Seccion "Cotizaciones recibidas" (exclusivo Premium): diagnosticos de
  /// trabajos fuera de alcance que la red de proveedores cotizo para el cliente.
  ///
  /// Las tarjetas van en scroll horizontal, como en el diseño: se muestra una
  /// por solicitud (no una por propuesta, que repetiría la misma cotización
  /// tantas veces como proveedores respondieron) y al tocarla se abre la
  /// pantalla de comparación de esa solicitud.
  ///
  /// El encabezado se pinta siempre —igual que "Visitas Finalizadas"—: la
  /// sección tiene que existir en el Dashboard aunque todavía no haya
  /// cotizaciones, si no el cliente no sabe que el espacio está ahí.
  Widget _buildCotizacionesRecibidas() {
    return Column(
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
            FFButtonWidget(
              onPressed: () {
                // Sin solicitud fijada la pantalla lista todas las propuestas
                // recibidas por el cliente.
                DHCLIENTCotizacionesRecibidasWidget.serviceRequestId = null;
                context
                    .pushNamed(DHCLIENTCotizacionesRecibidasWidget.routeName);
              },
              text: 'Ver todo',
              options: FFButtonOptions(
                height: 30.0,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                color: const Color(0xFFCCE3E4),
                textStyle: GoogleFonts.publicSans(
                    color: FlutterFlowTheme.of(context).primary,
                    fontSize: 14.0),
                borderRadius: BorderRadius.circular(24.0),
                elevation: 0,
              ),
            ),
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
        _buildQuotesContent(),
      ],
    );
  }

  /// Contenido de la sección: el carrusel de cotizaciones o, mientras no haya
  /// ninguna, una línea que explica por qué está vacía.
  Widget _buildQuotesContent() {
    return FutureBuilder<ApiCallResponse>(
      future: _proposalsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final response = snapshot.data!;
        if (!response.succeeded) {
          return _quotesPlaceholder(
              'No pudimos cargar tus cotizaciones. Intenta de nuevo más tarde.');
        }

        // `proposalsList` resuelve un JsonPath sobre el JSON decodificado, no
        // sobre el ApiCallResponse: hay que pasarle `jsonBody`.
        final proposals = DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall
                .proposalsList(response.jsonBody) ??
            [];

        // Una tarjeta por solicitud cotizada: varias propuestas de la misma
        // solicitud son la *misma* cotización para el cliente, y al tocarla las
        // compara todas en la pantalla de cotizaciones recibidas.
        final cards = <Map<String, dynamic>>[];
        final seenRequestIds = <String>{};
        for (final proposal in proposals.whereType<Map>()) {
          final data = Map<String, dynamic>.from(proposal);
          // Si el backend no informa la solicitud la propuesta se muestra
          // igual (al tocarla se abre el listado completo), pero entonces no
          // hay con qué agruparla: se la trata como una cotización aparte.
          final key = _proposalRequestId(data) ??
              _str(data['id']) ??
              'proposal_${cards.length}';
          if (!seenRequestIds.add(key)) continue;
          cards.add(data);
          if (cards.length == 5) break;
        }

        if (cards.isEmpty) {
          return _quotesPlaceholder(
              'Todavía no recibiste cotizaciones. Te avisaremos cuando los proveedores envíen sus propuestas.');
        }
        return _buildQuotesCarousel(cards);
      },
    );
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
  Widget _buildQuotesCarousel(List<Map<String, dynamic>> cards) {
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
                    onTap: () {
                      DHCLIENTCotizacionesRecibidasWidget.serviceRequestId =
                          _proposalRequestId(cards[i]);
                      context
                          .pushNamed(
                              DHCLIENTCotizacionesRecibidasWidget.routeName)
                          .then((_) => safeSetState(() {}));
                    },
                    borderRadius: BorderRadius.circular(16.0),
                    child: _buildQuoteResultCard(
                      title: _proposalRequestTitle(cards[i]),
                      subtitle: 'Visita realizada',
                      date: _proposalDate(cards[i]),
                      status: _proposalStatusLabel(cards[i]),
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
              child:
                  SvgPicture.asset(srServiceIconAsset(title)),
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

  @override
  Widget build(BuildContext context) {
    // Estado real de suscripcion (Recurrente) desde PaymentsRepository.
    // `hasActiveSubscription` es true para ACTIVE, PAST_DUE y CANCEL_SCHEDULED,
    // que es el criterio con el que el backend habilita los beneficios Premium.
    final hasSubscription =
        context.watch<PaymentsRepository>().hasActiveSubscription;

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
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIASHAREDHeaderWidget(
                      title: 'Dovia Home',
                      showCart: true,
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
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildServiceCard('Plomería',
                                'assets/images/IconoServicioPlomeria.svg',
                                onTap: () => _openServiceDetail('Plomería')),
                            _buildServiceCard('Eléctrico',
                                'assets/images/IconoServicioElectrico.svg',
                                onTap: () => _openServiceDetail('Eléctrico')),
                            _buildServiceCard('Albañilería',
                                'assets/images/IconoServicioAlbaileria.svg',
                                onTap: () => _openServiceDetail('Albañilería')),
                            _buildServiceCard('Pintura',
                                'assets/images/IconServicioPintura.svg',
                                onTap: () => _openServiceDetail('Pintura')),
                            _buildServiceCard('Instalación',
                                'assets/images/IconServicioInstalacion.svg',
                                onTap: () => _openServiceDetail('Instalación')),
                            _buildServiceCard('Servicio de\nemergencia',
                                'assets/images/warning-triangle.svg',
                                isEmergency: true, onTap: () {
                              // Abierto a todos los clientes: el estatus de la
                              // cuenta se resuelve más adelante, en el paso de
                              // cobro (descuento Premium vs. pago regular +
                              // upsell para Free).
                              DHCLIENTUbicacionWidget.pendingNextRoute =
                                  DHCLIENTEmergenciasWidget.routeName;
                              context
                                  .pushNamed(DHCLIENTUbicacionWidget.routeName);
                            }),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Banner Suscripcion
                        Visibility(
                          visible: !hasSubscription,
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
                        if (!hasSubscription) const SizedBox(height: 30),

                        // Tarjetas Premium (usuario con suscripcion activa)
                        if (hasSubscription) ...[
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
                            FFButtonWidget(
                              onPressed: () {
                                context.pushNamed(
                                    DHCLIENTProximasVisitasListaWidget
                                        .routeName);
                              },
                              text: 'Ver todo',
                              options: FFButtonOptions(
                                height: 30.0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                color: const Color(0xFFCCE3E4),
                                textStyle: GoogleFonts.publicSans(
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontSize: 14.0),
                                borderRadius: BorderRadius.circular(24.0),
                                elevation: 0,
                              ),
                            ),
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
                            ),
                          ),
                        ),
                        // Regla UI: Lista dinamica del backend
                        FutureBuilder<ApiCallResponse>(
                          future: _upcomingVisitsFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final response = snapshot.data!;
                            if (!response.succeeded) {
                              return const SizedBox.shrink();
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
                            FFButtonWidget(
                              onPressed: () {
                                context.pushNamed(
                                    DHCLIENTVisitasFinalizadasListaWidget
                                        .routeName);
                              },
                              text: 'Ver todo',
                              options: FFButtonOptions(
                                height: 30.0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                color: const Color(0xFFCCE3E4),
                                textStyle: GoogleFonts.publicSans(
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontSize: 14.0),
                                borderRadius: BorderRadius.circular(24.0),
                                elevation: 0,
                              ),
                            ),
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
                              return const Center(child: CircularProgressIndicator());
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
                                      border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
                                    ),
                                    child: Row(
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
                                            child: SvgPicture.asset('assets/images/IconoServicioPlomeria.svg'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(title,
                                                  style: GoogleFonts.publicSans(
                                                      fontWeight: FontWeight.w600, fontSize: 14)),
                                              const SizedBox(height: 4),
                                              Text('Visita realizada',
                                                  style: GoogleFonts.inter(
                                                      color: FlutterFlowTheme.of(context).secondaryText,
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

                        // Cotizaciones recibidas (exclusivo Premium)
                        if (hasSubscription) ...[
                          _buildCotizacionesRecibidas(),
                          const SizedBox(height: 50),
                        ],

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
            ),
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
                          0.0, 0.0, 15.0, 100.0),
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
