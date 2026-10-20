import '/core/result.dart';
import '/domain/payment_models.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/checkout_launcher.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_planes/d_h_c_l_i_e_n_t_planes_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/repositories/payments_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import '/shared_components/header_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_c_forma_pago_suscripcion2_model.dart';
export 'd_c_forma_pago_suscripcion2_model.dart';

/// Último paso de la contratación del plan: confirmar y pagar.
///
/// El cobro no ocurre acá sino en el checkout hospedado de Recurrente, que se
/// abre en el navegador. Volver a la app **no** quiere decir que el pago se
/// completó: quien lo confirma es el webhook de Recurrente contra el backend,
/// que recién ahí mueve la orden a `SUCCEEDED` y crea la suscripción. Por eso,
/// después de abrir el checkout la pantalla queda sondeando el estado de la
/// orden en vez de dar la compra por hecha.
class DCFormaPagoSuscripcion2Widget extends StatefulWidget {
  const DCFormaPagoSuscripcion2Widget({super.key});

  static String routeName = 'DC_FormaPagoSuscripcion_2';
  static String routePath = '/dCFormaPagoSuscripcion2';

  @override
  State<DCFormaPagoSuscripcion2Widget> createState() =>
      _DCFormaPagoSuscripcion2WidgetState();
}

/// En qué punto del cobro está la pantalla.
enum _CheckoutPhase {
  /// Mostrando el resumen del plan, esperando que el cliente confirme.
  idle,

  /// Creando la orden en el backend.
  creating,

  /// Checkout abierto: se sondea hasta saber si el pago entró.
  waiting,

  /// La orden terminó mal y se puede reintentar.
  failed,
}

class _DCFormaPagoSuscripcion2WidgetState
    extends State<DCFormaPagoSuscripcion2Widget> with WidgetsBindingObserver {
  late DCFormaPagoSuscripcion2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  _CheckoutPhase _phase = _CheckoutPhase.idle;

  /// Orden abierta en el navegador. Se guarda para poder sondearla y, si
  /// termina mal, reanudarla.
  String? _paymentOrderId;

  /// Por qué falló el último intento, para no mandar al cliente de vuelta al
  /// checkout a ciegas.
  String? _failureMessage;

  /// Un sondeo ya está en vuelo. Evita que el botón "Ya completé el pago" y el
  /// regreso a primer plano disparen dos cadenas en paralelo.
  bool _polling = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DCFormaPagoSuscripcion2Model());
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.dispose();

    super.dispose();
  }

  /// En móvil, volver del navegador es la señal más temprana de que el cliente
  /// terminó de pagar. En web no hay ciclo de vida que avise —el checkout abre
  /// en otra pestaña—, y ahí sirve el botón "Ya completé el pago".
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _phase == _CheckoutPhase.waiting) {
      _pollUntilResolved();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  PaymentsRepository get _payments => context.read<PaymentsRepository>();

  // ---------------------------------------------------------------------------
  // Cobro
  // ---------------------------------------------------------------------------

  /// Crea la orden y abre el checkout.
  ///
  /// El backend rechaza con `400` a quien ya tiene una suscripción activa, así
  /// que el chequeo previo es sólo para no hacerle dar la vuelta al cliente:
  /// si igual pasa, el mensaje del backend es el que se muestra.
  Future<void> _startCheckout(SubscriptionPlan plan) async {
    if (_payments.hasActiveSubscription) {
      _showError('Ya tenés un plan activo.');
      return;
    }

    safeSetState(() {
      _phase = _CheckoutPhase.creating;
      _failureMessage = null;
    });

    final result = await _payments.createSubscriptionCheckout(planId: plan.id);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        await _openCheckout(data);
      case Failure(:final message):
        safeSetState(() => _phase = _CheckoutPhase.idle);
        _showError(message);
    }
  }

  /// Reanuda una orden que terminó mal.
  ///
  /// No se vuelve a crear un checkout de cero: `resume` genera una sucesora de
  /// la orden existente. Crear una segunda orden dejaría dos cobros vivos por
  /// la misma suscripción.
  Future<void> _resumeCheckout() async {
    final orderId = _paymentOrderId;
    if (orderId == null) return;

    safeSetState(() {
      _phase = _CheckoutPhase.creating;
      _failureMessage = null;
    });

    final result = await _payments.resumePayment(paymentOrderId: orderId);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        await _openCheckout(data);
      case Failure(:final message):
        safeSetState(() => _phase = _CheckoutPhase.failed);
        _showError(message);
    }
  }

  /// Abre la orden en el navegador y pasa a esperar la confirmación.
  Future<void> _openCheckout(PaymentOrder order) async {
    final opened = await launchDoviaHomeCheckout(order.checkoutUrl);
    if (!mounted) return;

    if (!opened) {
      safeSetState(() {
        _phase = _CheckoutPhase.failed;
        _paymentOrderId = order.id;
        _failureMessage = 'No pudimos abrir el pago. Intentá de nuevo.';
      });
      return;
    }

    safeSetState(() {
      _phase = _CheckoutPhase.waiting;
      _paymentOrderId = order.id;
    });
    _pollUntilResolved();
  }

  /// Sondea la orden hasta que el backend la resuelva.
  Future<void> _pollUntilResolved() async {
    final orderId = _paymentOrderId;
    if (orderId == null || _polling) return;

    _polling = true;
    try {
      final order = await _payments.awaitPaymentResolution(orderId);
      if (!mounted) return;
      // Pago resuelto: se cierra el checkout (en iOS) para mostrar el
      // resultado sin que el cliente tenga que cerrarlo.
      if (order != null) await closeDoviaHomeCheckout();
      if (!mounted) return;

      // Se agotó la espera sin novedad. No es un fallo: el pago puede seguir
      // procesándose, así que no se marca nada como comprado ni como perdido.
      if (order == null) {
        _showError(
          'Seguimos procesando tu pago. Te avisamos apenas se confirme.',
        );
        safeSetState(() => _phase = _CheckoutPhase.idle);
        return;
      }

      if (order.isPaid) {
        await _onSubscriptionConfirmed();
        return;
      }

      safeSetState(() {
        _phase = _CheckoutPhase.failed;
        _failureMessage = order.failureReason?.isNotEmpty == true
            ? order.failureReason
            : 'El pago no se completó.';
      });
    } finally {
      _polling = false;
    }
  }

  /// El pago entró: se refresca la suscripción y se vuelve al flujo que trajo
  /// al cliente hasta acá.
  Future<void> _onSubscriptionConfirmed() async {
    await _payments.loadCurrentSubscription(forceRefresh: true);
    if (!mounted) return;

    DHCLIENTPlanesWidget.selectedPlan = null;

    // El flujo que derivó a Planes dejó su pantalla en la pila esperando el
    // resultado; apilar una instancia nueva la dejaría sin enterarse de la
    // compra. Sin flujo previo se mantiene el destino histórico.
    final returnRoute = DHCLIENTPlanesPageWidget.pendingReturnRoute;
    if (returnRoute != null) {
      context.goNamed(returnRoute);
      return;
    }
    context.goNamed(DHCLIENTValorVisitaPageWidget.routeName);
  }

  // ---------------------------------------------------------------------------
  // Cuerpo
  // ---------------------------------------------------------------------------

  /// Se llegó a la pantalla sin plan elegido (Ej: por deep link). No se puede
  /// cobrar nada, así que se vuelve a elegir.
  Widget _noPlanSelected() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 40.0, 20.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Elegí un plan para continuar.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF00444B),
                  fontSize: 16.0,
                ),
          ),
          const SizedBox(height: 20.0),
          _primaryButton(
            'Ver planes',
            () async => context.goNamed(DHCLIENTPlanesPageWidget.routeName),
          ),
        ],
      ),
    );
  }

  /// Checkout abierto. El cobro lo confirma el webhook, así que la pantalla
  /// espera; el botón sólo adelanta el próximo sondeo.
  Widget _waitingForPayment() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 60.0, 20.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF007376)),
          const SizedBox(height: 24.0),
          Text(
            'Estamos confirmando tu pago…',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: const Color(0xFF00444B),
                  fontSize: 16.0,
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Completá el pago en la ventana que abrimos y cerrala al terminar.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF00444B),
                  fontSize: 13.0,
                  lineHeight: 1.4,
                ),
          ),
          const SizedBox(height: 24.0),
          _primaryButton(
              'Ya completé el pago', () async => _pollUntilResolved()),
        ],
      ),
    );
  }

  /// La orden terminó mal. Se reanuda, nunca se crea otra.
  Widget _paymentFailed() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 60.0, 20.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _failureMessage ?? 'El pago no se completó.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF00444B),
                  fontSize: 16.0,
                  lineHeight: 1.4,
                ),
          ),
          const SizedBox(height: 20.0),
          _primaryButton('Reintentar el pago', () async => _resumeCheckout()),
        ],
      ),
    );
  }

  Widget _primaryButton(String text, Future<void> Function() onPressed) {
    return FFButtonWidget(
      onPressed: onPressed,
      text: text,
      options: FFButtonOptions(
        width: double.infinity,
        height: 48.0,
        color: FlutterFlowTheme.of(context).primary,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: Colors.white,
              fontSize: 16.0,
            ),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(25.0),
      ),
    );
  }

  Widget _body() {
    switch (_phase) {
      case _CheckoutPhase.waiting:
        return _waitingForPayment();
      case _CheckoutPhase.failed:
        return _paymentFailed();
      case _CheckoutPhase.idle:
      case _CheckoutPhase.creating:
        final plan = DHCLIENTPlanesWidget.selectedPlan;
        if (plan == null) return _noPlanSelected();
        return custom_widgets.SubscriptionPayment(
          width: MediaQuery.sizeOf(context).width * 1.0,
          planName: plan.name,
          planPrice: plan.formattedAmount,
          planPeriod: plan.periodLabel ?? '',
          isBusy: _phase == _CheckoutPhase.creating,
          onActionPressed: () async => _startCheckout(plan),
          onSeeTerms: () async {},
        );
    }
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
        body: SafeArea(
          top: true,
          child: Stack(
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
                      child: DOVIASHAREDHeaderWidget(
                        showLogo: openedFromHome(context),
                        showSupport: false,
                        title: 'Dovia Home',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 80.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: _body(),
                          ),
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
                            0.0, 0.0, 15.0, 12.0),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIACLIENTNavbarWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
