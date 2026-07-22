import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_proximas_visitas/d_h_c_l_i_e_n_t_proximas_visitas_widget.dart';
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
  });

  final String service;
  final String date;
  final String time;
  final String status;
}

class DHCLIENTHomepageWidget extends StatefulWidget {
  const DHCLIENTHomepageWidget({super.key});

  static String routeName = 'DH_CLIENT_Homepage';
  static String routePath = '/dHCLIENTHomepage';

  /// Visitas recién agendadas desde el flujo de solicitud. La pantalla de
  /// Agenda agrega aquí la nueva solicitud antes de redirigir al Dashboard.
  static final List<ScheduledVisit> upcomingVisits = [];

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
    _upcomingVisitsFuture = DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall.call(
      authToken: token,
      status: 'PENDING,ASSIGNED,IN_TRANSIT,IN_PROGRESS',
      limit: 2,
    );
    _completedVisitsFuture = DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall.call(
      authToken: token,
      status: 'COMPLETED,CLOSED,CANCELED',
      limit: 2,
    );
    _proposalsFuture = DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall.call(
      authToken: token,
      limit: 2,
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
              ? FlutterFlowTheme.of(context).primary
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
                    ? const Color(0x551ACDD3)
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
    context.pushNamed(DHCLIENTInstalacionWidget.routeName);
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
          _buildPremiumPillButton('Solicitar', () {
            context.pushNamed(DHCLIENTCotizacionWidget.routeName);
          }),
        ],
      ),
    );
  }

  /// Seccion "Cotizaciones recibidas" (exclusivo Premium): diagnosticos de
  /// trabajos fuera de alcance que la red de proveedores cotizo para el cliente.
  ///
  /// TODO: Poblar con el listado real (GET /dovia-home/proposals o fuera de
  /// alcance) cuando se conecte el flujo; por ahora es un placeholder.
  Widget _buildCotizacionesRecibidas() {
    return FutureBuilder<ApiCallResponse>(
      future: _proposalsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final response = snapshot.data!;
        if (!response.succeeded) {
          return const SizedBox.shrink(); // No mostrar si hay error
        }

        final proposals = DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall.proposalsList(response) ?? [];
        if (proposals.isEmpty) {
          return const SizedBox.shrink();
        }

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
                    context.pushNamed(DHCLIENTCotizacionesRecibidasWidget.routeName);
                  },
                  text: 'Ver todo',
                  options: FFButtonOptions(
                    height: 30.0,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    color: const Color(0xFFCCE3E4),
                    textStyle: GoogleFonts.publicSans(
                        color: FlutterFlowTheme.of(context).primary, fontSize: 14.0),
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
            ...proposals.take(2).map((proposal) {
              final data = proposal as Map<String, dynamic>;
              final title = data['serviceRequest']?['serviceName'] ?? 'Cotización de servicio';
              final dateStr = data['createdAt'] as String? ?? '';
              final date = dateStr.isNotEmpty ? dateStr.split('T').first : 'DD/MM/AAAA';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildQuoteResultCard(
                  title: title,
                  subtitle: 'Diagnóstico generado',
                  date: date,
                  status: data['status'] ?? 'Pendiente',
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  /// Tarjeta de una cotizacion recibida (titulo, estado de la visita, fecha y
  /// pill de estatus).
  Widget _buildQuoteResultCard({
    required String title,
    required String subtitle,
    required String date,
    String status = 'Pendiente',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
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
              child: SvgPicture.asset(
                  'assets/images/IconoServicioPlomeria.svg'),
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
                Text(subtitle,
                    style: GoogleFonts.inter(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text(date,
                    style: GoogleFonts.inter(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFDECC8),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Text(
              status,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9A6700),
                  fontSize: 12.0),
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
                              if (hasSubscription) {
                                DHCLIENTUbicacionWidget.pendingNextRoute =
                                    DHCLIENTEmergenciasWidget.routeName;
                                context.pushNamed(
                                    DHCLIENTUbicacionWidget.routeName);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Este servicio es solo para usuarios con suscripción.')),
                                );
                              }
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
                              // TODO: enlazar a la vista completa de "Próximas
                              // visitas" cuando exista esa pantalla de listado.
                              onPressed: () {},
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
                            final visits = DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall.requestsList(response) ?? [];
                            if (visits.isEmpty && DHCLIENTHomepageWidget.upcomingVisits.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            
                            return Column(
                              children: visits.take(2).map((visitData) {
                                final data = visitData as Map<String, dynamic>;
                                final title = data['serviceName'] ?? 'Servicio';
                                // Obtener fecha del appointment o del createdAt
                                final apt = data['appointment'];
                                final dateStr = (apt != null && apt['scheduledAt'] != null) 
                                    ? apt['scheduledAt'] as String 
                                    : (data['createdAt'] as String? ?? '');
                                final date = dateStr.isNotEmpty ? dateStr.split('T').first : 'Fecha pendiente';
                                final status = data['status'] ?? 'Pendiente';
                                
                                // Regla UI: si la solicitud requiere accion del usuario, mostrar punto rojo.
                                // Ejemplo: si el estado es PENDING, marcamos como requiere atencion.
                                final needsAction = status == 'PENDING';
                                
                                final card = DHCLIENTProximasVisitasWidget(
                                  title: title,
                                  date: date,
                                  status: status,
                                );
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: needsAction
                                      ? Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            card,
                                            PositionedDirectional(
                                              top: -4,
                                              end: -4,
                                              child: Container(
                                                width: 14,
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE53935),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 2),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : card,
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
                              // TODO: enlazar a la vista completa de "Visitas
                              // finalizadas" cuando exista esa pantalla de listado.
                              onPressed: () {},
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
                            final visits = DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall.requestsList(response) ?? [];
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
