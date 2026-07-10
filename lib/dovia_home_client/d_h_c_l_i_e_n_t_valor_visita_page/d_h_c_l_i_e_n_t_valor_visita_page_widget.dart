import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_c_l_i_e_n_t_valor_visita_page_model.dart';
export 'd_h_c_l_i_e_n_t_valor_visita_page_model.dart';

/// Página que muestra el valor de la visita individual cuando el cliente omite
/// la suscripción.
class DHCLIENTValorVisitaPageWidget extends StatefulWidget {
  const DHCLIENTValorVisitaPageWidget({super.key});

  static String routeName = 'DH_CLIENT_ValorVisita';
  static String routePath = '/dHCLIENTValorVisita';

  /// Precio regular del servicio (pago por uso, sin plan).
  static const String regularPrice = 'Q449.99';

  /// Precio del servicio con descuento al suscribirse a Dovia Home.
  static const String discountedPrice = 'Q314.99';

  /// Bandera que la pantalla de planes activa al volver a este paso tras
  /// contratar una suscripción. Como la navegación crea una nueva instancia de
  /// esta página, usamos un campo estático para propagar el estado "suscrito"
  /// de regreso (mismo patrón que [DHCLIENTUbicacionWidget.pendingNextRoute]).
  ///
  /// TODO: Cuando exista la pasarela de pago, esta bandera debe activarse solo
  /// tras confirmar la compra del plan y procesar (o eximir con el 1er servicio
  /// incluido) el cobro del servicio a precio con descuento.
  static bool returnedFromSubscription = false;

  @override
  State<DHCLIENTValorVisitaPageWidget> createState() =>
      _DHCLIENTValorVisitaPageWidgetState();
}

class _DHCLIENTValorVisitaPageWidgetState
    extends State<DHCLIENTValorVisitaPageWidget> {
  late DHCLIENTValorVisitaPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Cómo se pagó el servicio: null = sin pagar, 'direct' = pago por uso,
  /// 'subscription' = pagado con descuento tras suscribirse.
  String? _paidMethod;

  bool get _isPaid => _paidMethod != null;

  /// Anticipación mínima para agendar: 24h con suscripción, 36h sin plan.
  int get _minAdvanceHours => _paidMethod == 'subscription' ? 24 : 36;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTValorVisitaPageModel());

    // El cliente regresó desde la contratación del plan: el servicio queda
    // pagado con descuento (simulado hasta integrar la pasarela).
    if (DHCLIENTValorVisitaPageWidget.returnedFromSubscription) {
      DHCLIENTValorVisitaPageWidget.returnedFromSubscription = false;
      _paidMethod = 'subscription';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// Pago por uso a precio regular. Al tapear "Contratar" se abriría la
  /// pasarela de pagos; al confirmarse el cobro, el servicio queda pagado y
  /// se habilita "Siguiente".
  Future<void> _payDirect() async {
    if (_isPaid) return;
    // TODO: Abrir la pasarela de pagos (tarjetas guardadas o nueva tarjeta) por
    // DHCLIENTValorVisitaPageWidget.regularPrice. Marcar como pagado solo tras
    // confirmar el cobro. Mientras no esté integrada, simulamos el éxito.
    safeSetState(() => _paidMethod = 'direct');
  }

  /// Flujo de upsell: redirige a la selección y pago del plan. La pantalla de
  /// planes regresa a este paso marcando el servicio como pagado con descuento.
  void _goToSubscription() {
    if (_isPaid) return;
    DHCLIENTValorVisitaPageWidget.returnedFromSubscription = true;
    context.pushNamed(DHCLIENTPlanesPageWidget.routeName);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _buildPrice(String amount, String period) {
    return RichText(
      textScaler: MediaQuery.of(context).textScaler,
      text: TextSpan(
        children: [
          TextSpan(
            text: amount,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF007376),
                  fontSize: 39.0,
                  letterSpacing: 0.4,
                ),
          ),
          TextSpan(
            text: period,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF6A7282),
                  fontSize: 15.0,
                  letterSpacing: -0.16,
                ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSoftButton(
    String text, {
    required VoidCallback onTap,
    bool paid = false,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: paid ? null : onTap,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: 52.0,
        decoration: BoxDecoration(
          color: paid ? const Color(0xFF007376) : const Color(0xFFCCE3E4),
          borderRadius: BorderRadius.circular(100.0),
        ),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (paid)
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            Text(
              paid ? 'Pagado' : text,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(
                      fontWeight: paid ? FontWeight.w600 : FontWeight.normal,
                    ),
                    color: paid ? Colors.white : const Color(0xFF007376),
                    fontSize: 18.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      title: 'Valor de la visita',
                      hideActions: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 30.0, 20.0, 0.0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8.0,
                            color: Color(0x1A000000),
                            offset: Offset(0.0, 10.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(26.0),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            24.0, 32.0, 24.0, 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Precio del servicio',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.publicSans(),
                                    color: const Color(0xFF00444B),
                                    fontSize: 17.0,
                                    letterSpacing: -0.34,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 8.0, 0.0, 0.0),
                              child: _buildPrice(
                                  DHCLIENTValorVisitaPageWidget.regularPrice,
                                  ' /visita'),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: _buildSoftButton(
                                'Contratar',
                                paid: _paidMethod == 'direct',
                                onTap: _payDirect,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text(
                                'Si te suscribes a Dovia Home,\nse te cobrara:',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.publicSans(),
                                      color: const Color(0xFF00444B),
                                      fontSize: 17.0,
                                      letterSpacing: -0.34,
                                      lineHeight: 1.4,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: _buildPrice(
                                  DHCLIENTValorVisitaPageWidget.discountedPrice,
                                  ' /visita'),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: _buildSoftButton(
                                'Subscribirse',
                                paid: _paidMethod == 'subscription',
                                onTap: _goToSubscription,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 30.0, 20.0, 110.0),
                    child: FFButtonWidget(
                      // Bloqueo duro: no se puede avanzar sin pagar el servicio.
                      onPressed: _isPaid
                          ? () async {
                              // Propaga la anticipación mínima (36h sin plan,
                              // 24h con suscripción) al calendario.
                              DHCLIENTAgendaWidget.minAdvanceHours =
                                  _minAdvanceHours;
                              context
                                  .pushNamed(DHCLIENTAgendaWidget.routeName);
                            }
                          : null,
                      text: 'Siguiente',
                      options: FFButtonOptions(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 50.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: const Color(0xFF007376),
                        disabledColor: const Color(0xFFDFDFDF),
                        disabledTextColor: const Color(0xFF6A6A6A),
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  color: Colors.white,
                                  fontSize: 17.0,
                                  letterSpacing: 0.34,
                                ),
                        elevation: 0.0,
                        borderSide: BorderSide(
                          color: _isPaid
                              ? const Color(0xFF007376)
                              : Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
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
