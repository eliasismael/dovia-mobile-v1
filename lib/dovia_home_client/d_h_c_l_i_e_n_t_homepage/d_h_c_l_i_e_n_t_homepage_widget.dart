import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_proximas_visitas/d_h_c_l_i_e_n_t_proximas_visitas_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_c_l_i_e_n_t_homepage_model.dart';
export 'd_h_c_l_i_e_n_t_homepage_model.dart';

class DHCLIENTHomepageWidget extends StatefulWidget {
  const DHCLIENTHomepageWidget({super.key});

  static String routeName = 'DH_CLIENT_Homepage';
  static String routePath = '/dHCLIENTHomepage';

  @override
  State<DHCLIENTHomepageWidget> createState() => _DHCLIENTHomepageWidgetState();
}

class _DHCLIENTHomepageWidgetState extends State<DHCLIENTHomepageWidget> {
  late DHCLIENTHomepageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTHomepageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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

  @override
  Widget build(BuildContext context) {
    // Variable mock para la logica de subscripcion
    bool hasSubscription = false;

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
                                'assets/images/IconoServicioPlomeria.svg'),
                            _buildServiceCard('Eléctrico',
                                'assets/images/IconoServicioElectrico.svg'),
                            _buildServiceCard('Albañilería',
                                'assets/images/IconoServicioAlbaileria.svg'),
                            _buildServiceCard('Pintura',
                                'assets/images/IconServicioPintura.svg'),
                            _buildServiceCard('Instalación',
                                'assets/images/IconServicioInstalacion.svg',
                                onTap: () {
                              DHCLIENTUbicacionWidget.pendingNextRoute =
                                  DHCLIENTInstalacionWidget.routeName;
                              context
                                  .pushNamed(DHCLIENTUbicacionWidget.routeName);
                            }),
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
                                    DHCLIENTUbicacionWidget.pendingNextRoute =
                                        'DC_Forma_Pago_Suscripcion1';
                                    context.pushNamed(
                                        DHCLIENTUbicacionWidget.routeName);
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
                        wrapWithModel(
                          model: _model.dHCLIENTProximasVisitasModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: const DHCLIENTProximasVisitasWidget(
                            title: 'Instalación de TV',
                            date: 'Lunes, 10 de Noviembre',
                          ),
                        ),
                        const SizedBox(height: 10),
                        wrapWithModel(
                          model: _model.dHCLIENTProximasVisitasModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: const DHCLIENTProximasVisitasWidget(),
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1),
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
                                    Text('Reparación de tubería',
                                        style: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('Visita realizada',
                                        style: GoogleFonts.inter(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),

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
