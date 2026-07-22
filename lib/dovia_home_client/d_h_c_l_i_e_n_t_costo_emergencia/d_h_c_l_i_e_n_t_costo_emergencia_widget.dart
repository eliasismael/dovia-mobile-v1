import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/repositories/payments_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_h_c_l_i_e_n_t_costo_emergencia_model.dart';
export 'd_h_c_l_i_e_n_t_costo_emergencia_model.dart';

/// Pasarela de cobro condicional del servicio de emergencia ("Costo fijo mínimo
/// del trabajo"). Según el estatus de la cuenta renderiza:
/// - Premium (suscripción activa): tarjeta de descuento (35% OFF).
/// - Free (sin suscripción): tarjeta de pago regular + upsell.
///
/// Al confirmar el pago se **omite la selección de fecha/hora** (bypass de
/// calendario): se lanza directamente el modal de éxito y se redirige al
/// Dashboard, donde la solicitud aparece en "Próximas visitas" con estatus
/// "Pendiente" e indicador de alta prioridad (Emergencia).
class DHCLIENTCostoEmergenciaWidget extends StatefulWidget {
  const DHCLIENTCostoEmergenciaWidget({super.key});

  static String routeName = 'DH_CLIENT_CostoEmergencia';
  static String routePath = '/dHCLIENTCostoEmergencia';

  /// Descripción del problema capturada en la pantalla de Emergencias.
  static String? description;

  /// Precio base del servicio de emergencia (sin descuento).
  static const String basePrice = 'Q600';

  /// Precio final con descuento de suscripción (Premium).
  static const String discountedPrice = 'Q390';

  /// Porcentaje de descuento del plan.
  static const String discountLabel = '35% OFF';

  /// Ahorro exacto para la píldora informativa (Premium).
  static const String savingsAmount = 'Q210';

  /// Precio estándar completo (Free, pago por uso).
  static const String regularPrice = 'Q449';

  /// Bandera que la pantalla de planes activa al volver tras contratar el plan.
  /// Propaga el estado "suscrito"/"pagado" de regreso a este paso, ya que la
  /// navegación recrea la instancia (mismo patrón que
  /// [DHCLIENTValorVisitaPageWidget.returnedFromSubscription]).
  static bool returnedFromSubscription = false;

  @override
  State<DHCLIENTCostoEmergenciaWidget> createState() =>
      _DHCLIENTCostoEmergenciaWidgetState();
}

class _DHCLIENTCostoEmergenciaWidgetState
    extends State<DHCLIENTCostoEmergenciaWidget> {
  late DHCLIENTCostoEmergenciaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Cómo se pagó (sólo aplica al escenario Free): null = sin pagar,
  /// 'direct' = pago por uso, 'subscription' = pagado tras suscribirse.
  String? _paidMethod;

  bool get _isPaid => _paidMethod != null;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTCostoEmergenciaModel());

    // Asegura el estado de suscripción cargado (cacheado en el repo).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentsRepository>().loadCurrentSubscription();
      safeSetState(() {});
    });

    // El cliente regresó desde la contratación del plan: el servicio queda
    // pagado con descuento (simulado hasta integrar la pasarela).
    if (DHCLIENTCostoEmergenciaWidget.returnedFromSubscription) {
      DHCLIENTCostoEmergenciaWidget.returnedFromSubscription = false;
      _paidMethod = 'subscription';
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Pago por uso a precio regular (Free). Al integrarse la pasarela, marcar
  /// como pagado sólo tras confirmar el cobro.
  Future<void> _payDirect() async {
    if (_isPaid) return;
    // TODO: Abrir pasarela por [regularPrice] y marcar pagado tras confirmar.
    safeSetState(() => _paidMethod = 'direct');
  }

  /// Upsell: redirige a la contratación del plan; al volver se marca pagado.
  void _goToSubscription() {
    if (_isPaid) return;
    DHCLIENTCostoEmergenciaWidget.returnedFromSubscription = true;
    context.pushNamed(DHCLIENTPlanesPageWidget.routeName);
  }

  /// Confirma el pago de la emergencia. **Omite el calendario**: registra la
  /// solicitud en "Próximas visitas" con alta prioridad, lanza el modal de
  /// éxito y redirige al Dashboard.
  Future<void> _confirmAndSchedule() async {
    // TODO: Cobrar a la tarjeta guardada (Premium) o el monto pagado (Free) y
    // POST /dovia-home/service-requests/emergencies con la descripción.
    DHCLIENTHomepageWidget.upcomingVisits.insert(
      0,
      const ScheduledVisit(
        service: 'Servicio de emergencia',
        date: 'Atención prioritaria',
        time: 'respuesta < 18h',
        status: 'Pendiente',
        isEmergency: true,
      ),
    );
    DHCLIENTCostoEmergenciaWidget.description = null;

    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0),
          child: DHCLIENTExitoProgramarAgendaWidget(
            message: 'Programaste con éxito tu servicio para la Casa.',
          ),
        );
      },
    );
    // Al cerrarse el modal (auto o al tapear fuera) redirige al Dashboard.
    if (context.mounted) {
      context.goNamed(DHCLIENTHomepageWidget.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PaymentsRepository>().hasActiveSubscription;

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
                      title: 'Costo fijo mínimo\ndel trabajo',
                      hideActions: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 30.0, 20.0, 0.0),
                    child: isPremium ? _premiumCard() : _freeCard(),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 30.0, 20.0, 110.0),
                    child: _nextButton(isPremium),
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

  // ---------------------------------------------------------------------------
  // Escenario A: Premium (tarjeta de descuento).
  // ---------------------------------------------------------------------------

  Widget _premiumCard() {
    return Container(
      width: double.infinity,
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
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Precio del servicio',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF00444B),
                  fontSize: 17.0,
                  letterSpacing: -0.34,
                ),
          ),
          const SizedBox(height: 8.0),
          // Precio base tachado.
          _priceLine(
            DHCLIENTCostoEmergenciaWidget.basePrice,
            '/el día',
            struck: true,
          ),
          const SizedBox(height: 18.0),
          // Etiqueta central de descuento.
          _premiumPill(
            leading: Text(
              DHCLIENTCostoEmergenciaWidget.discountLabel,
              style: GoogleFonts.publicSans(
                color: const Color(0xFF007376),
                fontWeight: FontWeight.w700,
                fontSize: 15.0,
              ),
            ),
            trailing: 'DOVIA PREMIUM',
          ),
          const SizedBox(height: 18.0),
          // Precio final a cobrar.
          _priceLine(
            DHCLIENTCostoEmergenciaWidget.discountedPrice,
            '/el día',
          ),
          const SizedBox(height: 18.0),
          // Píldora informativa del ahorro exacto.
          _premiumPill(
            leading: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'AHORRO DEL SERVICIO  ',
                    style: GoogleFonts.publicSans(
                      color: const Color(0xFF6A7282),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.0,
                    ),
                  ),
                  TextSpan(
                    text: DHCLIENTCostoEmergenciaWidget.savingsAmount,
                    style: GoogleFonts.publicSans(
                      color: const Color(0xFF007376),
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            trailing: 'DOVIA PREMIUM',
          ),
        ],
      ),
    );
  }

  Widget _premiumPill({required Widget leading, required String trailing}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFCCE3E4),
        borderRadius: BorderRadius.circular(100.0),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: leading),
          Text(
            trailing,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF6A7282),
              fontWeight: FontWeight.w600,
              fontSize: 9.0,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Escenario B: Free (pago regular + upsell).
  // ---------------------------------------------------------------------------

  Widget _freeCard() {
    return Container(
      width: double.infinity,
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
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Precio del servicio',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF00444B),
                  fontSize: 17.0,
                  letterSpacing: -0.34,
                ),
          ),
          const SizedBox(height: 8.0),
          _priceLine(DHCLIENTCostoEmergenciaWidget.regularPrice, '/el día'),
          const SizedBox(height: 20.0),
          _softButton(
            'Contratar',
            paid: _paidMethod == 'direct',
            onTap: _payDirect,
          ),
          const SizedBox(height: 20.0),
          Text(
            'Si te suscribes a Dovia Home,\nse te cobrará con descuento:',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF00444B),
                  fontSize: 17.0,
                  letterSpacing: -0.34,
                  lineHeight: 1.4,
                ),
          ),
          const SizedBox(height: 12.0),
          _priceLine(DHCLIENTCostoEmergenciaWidget.discountedPrice, '/el día'),
          const SizedBox(height: 20.0),
          _softButton(
            'Subscribirse',
            paid: _paidMethod == 'subscription',
            onTap: _goToSubscription,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers compartidos.
  // ---------------------------------------------------------------------------

  Widget _priceLine(String amount, String period, {bool struck = false}) {
    return RichText(
      textAlign: TextAlign.center,
      textScaler: MediaQuery.of(context).textScaler,
      text: TextSpan(
        children: [
          TextSpan(
            text: amount,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF007376),
              fontSize: struck ? 28.0 : 39.0,
              letterSpacing: 0.4,
              decoration: struck ? TextDecoration.lineThrough : null,
              decorationColor: const Color(0xFF007376),
            ),
          ),
          TextSpan(
            text: period,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF6A7282),
              fontSize: 15.0,
              letterSpacing: -0.16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _softButton(
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
        width: double.infinity,
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
                child: Icon(Icons.check_circle, color: Colors.white, size: 20.0),
              ),
            Text(
              paid ? 'Pagado' : text,
              style: GoogleFonts.publicSans(
                color: paid ? Colors.white : const Color(0xFF007376),
                fontWeight: paid ? FontWeight.w600 : FontWeight.normal,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón inferior [Siguiente].
  /// - Premium: siempre habilitado (cobra a la tarjeta guardada).
  /// - Free: bloqueado hasta que el usuario complete el pago.
  Widget _nextButton(bool isPremium) {
    final enabled = isPremium || _isPaid;
    return FFButtonWidget(
      onPressed: enabled ? () async => _confirmAndSchedule() : null,
      text: 'Siguiente',
      options: FFButtonOptions(
        width: double.infinity,
        height: 50.0,
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        color: const Color(0xFF007376),
        disabledColor: const Color(0xFFDFDFDF),
        disabledTextColor: const Color(0xFF6A6A6A),
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: Colors.white,
              fontSize: 17.0,
              letterSpacing: 0.34,
            ),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(100.0),
      ),
    );
  }
}
