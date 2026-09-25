import '/core/result.dart';
import '/domain/payment_models.dart';
import '/dovia_home_client/checkout_launcher.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/service_request_fields.dart';
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

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';

import 'd_h_c_l_i_e_n_t_valor_visita_page_model.dart';
export 'd_h_c_l_i_e_n_t_valor_visita_page_model.dart';

/// Página que muestra el valor de la visita individual cuando el cliente omite
/// la suscripción, y cobra el servicio por Recurrente antes de liberar
/// [Siguiente].
///
/// Llega **después** de Agenda: `POST /payments/custom-checkout` exige un
/// `serviceId` (el id de la solicitud) que recién existe una vez agendada la
/// visita, así que el calendario pasa antes del cobro y no al revés.
class DHCLIENTValorVisitaPageWidget extends StatefulWidget {
  const DHCLIENTValorVisitaPageWidget({super.key});

  static String routeName = 'DH_CLIENT_ValorVisita';
  static String routePath = '/dHCLIENTValorVisita';

  /// Solicitud recién creada en Agenda, cuyo pago hay que resolver acá. Campo
  /// estático por la misma razón que el resto del wizard: go_router navega
  /// solo por nombre.
  static String? serviceRequestId;

  @override
  State<DHCLIENTValorVisitaPageWidget> createState() =>
      _DHCLIENTValorVisitaPageWidgetState();
}

/// En qué punto del cobro está la pantalla. Mismo idioma que
/// `DC_FormaPagoSuscripcion_2`, que es la pantalla de referencia para un
/// checkout de Recurrente abierto desde la app.
enum _CheckoutPhase {
  /// Tarjeta normal: ninguno de los dos caminos está pagando en este momento.
  idle,

  /// Creando (o reanudando) la orden en el backend.
  creating,

  /// Checkout abierto en el navegador: se sondea hasta saber si el pago entró.
  waiting,

  /// La última orden terminó mal y se puede reintentar.
  failed,
}

class _DHCLIENTValorVisitaPageWidgetState
    extends State<DHCLIENTValorVisitaPageWidget> with WidgetsBindingObserver {
  late DHCLIENTValorVisitaPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoadingRequest = true;
  String? _loadError;
  Map<String, dynamic>? _requestData;

  /// Cómo se cubrió el servicio: null = sin pagar, 'direct' = pago por uso,
  /// 'subscription' = cubierto por el plan (gratis o con descuento, lo decide
  /// el backend). Sólo se setea contra una respuesta que confirma el pago:
  /// nunca se anticipa uno que todavía no ocurrió.
  String? _paidMethod;

  bool get _isPaid => _paidMethod != null;

  _CheckoutPhase _phase = _CheckoutPhase.idle;

  /// Orden abierta en el navegador (o la última que se intentó). Se guarda
  /// para poder sondearla y, si termina mal, reanudarla.
  String? _paymentOrderId;

  /// A qué camino atribuir la orden en curso cuando se resuelva.
  String? _pendingMethod;

  /// Por qué falló el último intento, para no mandar al cliente de vuelta al
  /// checkout a ciegas.
  String? _failureMessage;

  /// Un sondeo ya está en vuelo. Evita que "Ya completé el pago" y el regreso
  /// a primer plano disparen dos cadenas en paralelo.
  bool _polling = false;

  num? get _amount =>
      _requestData == null ? null : srPriceAmount(_requestData!);
  num? get _subscriberAmount =>
      _requestData == null ? null : srSubscriberPriceAmount(_requestData!);
  String get _currency => _requestData == null
      ? PaymentCurrency.gtq
      : srPriceCurrency(_requestData!);
  String get _serviceName => _requestData == null
      ? 'Servicio Dovia Home'
      : srServiceName(_requestData!);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTValorVisitaPageModel());
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.dispose();

    super.dispose();
  }

  /// En móvil, volver del navegador es la señal más temprana de que el
  /// cliente terminó de pagar.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _phase == _CheckoutPhase.waiting) {
      _pollUntilResolved();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------------
  // Carga de la solicitud (precio + estado de pago).
  // ---------------------------------------------------------------------------

  Future<void> _bootstrap() async {
    await _loadServiceRequest();
    if (!mounted || _requestData == null) return;

    final payments = context.read<PaymentsRepository>();
    await payments.loadCurrentSubscription();
    if (!mounted) return;

    await _resolvePaymentState(payments);
  }

  Future<void> _loadServiceRequest() async {
    final serviceRequestId = DHCLIENTValorVisitaPageWidget.serviceRequestId;
    if (serviceRequestId == null || serviceRequestId.isEmpty) {
      safeSetState(() {
        _isLoadingRequest = false;
        _loadError = 'No se encontró la solicitud de este servicio.';
      });
      return;
    }

    safeSetState(() {
      _isLoadingRequest = true;
      _loadError = null;
    });

    final call = DOVIAAPIDoviaHomeContextGroup.getServiceRequestCall;
    final response = await call.call(
      serviceRequestId: serviceRequestId,
      authToken: currentAuthenticationToken ?? '',
    );
    if (!mounted) return;

    final data = response.succeeded ? call.data(response.jsonBody) : null;
    if (data == null || srPriceAmount(data) == null) {
      safeSetState(() {
        _isLoadingRequest = false;
        _loadError = 'No se pudo cargar el precio del servicio.';
      });
      return;
    }

    safeSetState(() {
      _requestData = data;
      _isLoadingRequest = false;
    });
  }

  /// Resuelve con qué estado abrir la pantalla: ya pagada, o con una orden en
  /// curso (o caída) de un intento anterior que hay que retomar en vez de
  /// crear un cobro nuevo.
  ///
  /// [autoCharge] sólo se activa al volver de comprar el plan, que es cuando
  /// el cliente ya pidió explícitamente que se le cobre el servicio con
  /// descuento. Al montar la pantalla vale `false`: abrir el navegador con el
  /// checkout sin que nadie haya tapeado nada sería secuestrarle la sesión.
  Future<void> _resolvePaymentState(
    PaymentsRepository payments, {
    bool autoCharge = false,
  }) async {
    final data = _requestData;
    if (data == null) return;

    final method = payments.hasActiveSubscription ? 'subscription' : 'direct';

    // Nada que cobrar: o el backend ya la marcó pagada, o la dejó en cero
    // porque el plan la cubre (Ej: el 1er servicio incluido). En los dos casos
    // el paso queda liberado sin pasar por Recurrente.
    if (srIsPaid(data) || (srPriceAmount(data) ?? 0) <= 0) {
      safeSetState(() => _paidMethod = method);
      return;
    }

    final serviceRequestId = DHCLIENTValorVisitaPageWidget.serviceRequestId;
    if (serviceRequestId != null) {
      final result =
          await payments.getPaymentStatus(serviceId: serviceRequestId);
      if (!mounted) return;
      final order = result.dataOrNull;
      if (order != null) {
        if (order.isPaid) {
          safeSetState(() => _paidMethod = method);
          return;
        }
        if (order.status == PaymentStatus.pending ||
            order.status == PaymentStatus.inProcess) {
          safeSetState(() {
            _paymentOrderId = order.id;
            _pendingMethod = method;
            _phase = _CheckoutPhase.waiting;
          });
          _pollUntilResolved();
          return;
        }
        if (order.isResumable) {
          safeSetState(() {
            _paymentOrderId = order.id;
            _pendingMethod = method;
            _phase = _CheckoutPhase.failed;
            _failureMessage = order.failureReason?.isNotEmpty == true
                ? order.failureReason
                : 'El pago no se completó.';
          });
          return;
        }
      }
    }

    // Vuelta de comprar el plan: el cliente ya pidió el servicio con
    // descuento, así que se cobra sin hacerle tapear otra vez. Si el backend
    // ya lo dejó cubierto (1er servicio incluido), no cobra nada.
    if (autoCharge && payments.hasActiveSubscription) {
      await _chargeSubscriberPrice();
    }
  }

  // ---------------------------------------------------------------------------
  // Cobro — pago por uso ("Contratar").
  // ---------------------------------------------------------------------------

  Future<void> _payDirect() async {
    if (_isPaid ||
        _phase == _CheckoutPhase.creating ||
        _phase == _CheckoutPhase.waiting) {
      return;
    }

    final serviceRequestId = DHCLIENTValorVisitaPageWidget.serviceRequestId;
    final amount = _amount;
    if (serviceRequestId == null || amount == null) {
      _showError('No se pudo cargar el precio del servicio. Intenta de nuevo.');
      return;
    }

    safeSetState(() {
      _phase = _CheckoutPhase.creating;
      _failureMessage = null;
    });

    final result =
        await context.read<PaymentsRepository>().createCustomCheckout(
              paymentType: PaymentType.normalService,
              amount: amount,
              currency: _currency,
              serviceId: serviceRequestId,
              description: _serviceName,
            );
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        await _openCheckout(data, method: 'direct');
      case Failure(:final message):
        safeSetState(() => _phase = _CheckoutPhase.idle);
        _showError(message);
    }
  }

  // ---------------------------------------------------------------------------
  // Cobro — upsell ("Subscribirse").
  // ---------------------------------------------------------------------------

  /// Deriva a la selección y pago del plan. Al volver se re-consulta la
  /// suscripción y la solicitud contra el backend: si quedó cubierta o pagada
  /// no hace falta más nada; si no, se cobra el monto (con descuento, o cero
  /// si el cliente usa su primer servicio incluido) que el backend devuelva.
  Future<void> _goToSubscription() async {
    if (_isPaid ||
        _phase == _CheckoutPhase.creating ||
        _phase == _CheckoutPhase.waiting) {
      return;
    }

    final payments = context.read<PaymentsRepository>();
    if (!payments.hasActiveSubscription) {
      await context.pushNamed(DHCLIENTPlanesPageWidget.routeName);
      if (!mounted) return;
      await payments.loadCurrentSubscription(forceRefresh: true);
      if (!mounted) return;
      if (!payments.hasActiveSubscription) return; // Omitió la compra.
    }

    await _loadServiceRequest();
    if (!mounted || _requestData == null) return;
    await _resolvePaymentState(payments, autoCharge: true);
  }

  Future<void> _chargeSubscriberPrice() async {
    final serviceRequestId = DHCLIENTValorVisitaPageWidget.serviceRequestId;
    final amount = _amount;
    if (serviceRequestId == null || amount == null) return;

    if (amount <= 0) {
      // El backend ya lo dejó en cero (1er servicio incluido): no hay nada
      // que cobrar.
      safeSetState(() => _paidMethod = 'subscription');
      return;
    }

    safeSetState(() {
      _phase = _CheckoutPhase.creating;
      _failureMessage = null;
    });

    final result =
        await context.read<PaymentsRepository>().createCustomCheckout(
              paymentType: PaymentType.normalService,
              amount: amount,
              currency: _currency,
              serviceId: serviceRequestId,
              description: _serviceName,
            );
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        await _openCheckout(data, method: 'subscription');
      case Failure(:final message):
        safeSetState(() => _phase = _CheckoutPhase.idle);
        _showError(message);
    }
  }

  // ---------------------------------------------------------------------------
  // Checkout compartido — abrir, sondear, reanudar.
  // ---------------------------------------------------------------------------

  Future<void> _openCheckout(PaymentOrder order,
      {required String method}) async {
    _pendingMethod = method;
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

  /// Reanuda una orden que terminó mal. No se vuelve a crear un checkout de
  /// cero: `resume` genera una sucesora de la orden existente.
  Future<void> _resumeCheckout() async {
    final orderId = _paymentOrderId;
    if (orderId == null) return;

    safeSetState(() {
      _phase = _CheckoutPhase.creating;
      _failureMessage = null;
    });

    final result = await context
        .read<PaymentsRepository>()
        .resumePayment(paymentOrderId: orderId);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        await _openCheckout(data, method: _pendingMethod ?? 'direct');
      case Failure(:final message):
        safeSetState(() => _phase = _CheckoutPhase.failed);
        _showError(message);
    }
  }

  /// Sondea la orden hasta que el backend la resuelva. Abrir el checkout no
  /// cobra: el cobro lo confirma el webhook de Recurrente contra el backend.
  Future<void> _pollUntilResolved() async {
    final orderId = _paymentOrderId;
    if (orderId == null || _polling) return;

    _polling = true;
    try {
      final order = await context
          .read<PaymentsRepository>()
          .awaitPaymentResolution(orderId);
      if (!mounted) return;
      // Pago resuelto: se cierra el checkout (en iOS) para mostrar el
      // resultado sin que el cliente tenga que cerrarlo.
      if (order != null) await closeDoviaHomeCheckout();
      if (!mounted) return;

      // Se agotó la espera sin novedad: no es un fallo, puede seguir
      // procesándose.
      if (order == null) {
        _showError(
            'Seguimos procesando tu pago. Te avisamos apenas se confirme.');
        safeSetState(() => _phase = _CheckoutPhase.idle);
        return;
      }

      if (order.isPaid) {
        safeSetState(() {
          _paidMethod = _pendingMethod ?? 'direct';
          _phase = _CheckoutPhase.idle;
        });
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

  // ---------------------------------------------------------------------------
  // Cierre del flujo — "Siguiente".
  // ---------------------------------------------------------------------------

  /// Con el pago confirmado: registra la visita en el Dashboard, limpia el
  /// borrador del wizard y muestra el modal de éxito. Es el mismo cierre que
  /// antes vivía al final de `_submit` en Agenda; se movió acá porque ahora es
  /// el pago —no el agendamiento— lo último que falta confirmar.
  Future<void> _finish() async {
    final data = _requestData;
    final scheduledAt = data == null ? null : srScheduledAt(data);

    DHCLIENTHomepageWidget.upcomingVisits.insert(
      0,
      ScheduledVisit(
        id: DHCLIENTValorVisitaPageWidget.serviceRequestId,
        service: data == null
            ? DHCLIENTInstalacionWidget.serviceTitle
            : srServiceName(data),
        date: data == null ? '' : srFormattedDate(data),
        time: scheduledAt == null ? '' : _formatTime(scheduledAt),
        scheduledAt: scheduledAt,
      ),
    );
    DHCLIENTInstalacionWidget.resetDraft();
    DHCLIENTValorVisitaPageWidget.serviceRequestId = null;

    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0),
          child: DHCLIENTExitoProgramarAgendaWidget(),
        );
      },
    );

    if (mounted) context.goNamed(DHCLIENTHomepageWidget.routeName);
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  String _formatTime(DateTime dt) =>
      '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';

  // ---------------------------------------------------------------------------
  // UI.
  // ---------------------------------------------------------------------------

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
    required VoidCallback? onTap,
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

  /// Retroalimentación de un checkout externo en curso o recién fallido. Sin
  /// esto el cliente no tiene forma de saber que el pago sigue procesándose
  /// (Recurrente abre en otra pestaña/navegador) ni de reintentar una orden
  /// vencida.
  Widget _buildCheckoutStatus() {
    switch (_phase) {
      case _CheckoutPhase.waiting:
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007376)),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Estamos confirmando tu pago…',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      color: const Color(0xFF00444B),
                      fontSize: 14.0,
                    ),
              ),
              TextButton(
                onPressed: _pollUntilResolved,
                child: Text(
                  'Ya completé el pago',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.publicSans(),
                        color: const Color(0xFF007376),
                        fontSize: 13.0,
                      ),
                ),
              ),
            ],
          ),
        );
      case _CheckoutPhase.failed:
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _failureMessage ?? 'El pago no se completó.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(),
                      color: const Color(0xFFD92D20),
                      fontSize: 13.0,
                    ),
              ),
              TextButton(
                onPressed: _resumeCheckout,
                child: Text(
                  'Reintentar el pago',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font:
                            GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                        color: const Color(0xFF007376),
                        fontSize: 13.0,
                      ),
                ),
              ),
            ],
          ),
        );
      case _CheckoutPhase.idle:
      case _CheckoutPhase.creating:
        return const SizedBox.shrink();
    }
  }

  /// Contenido de la tarjeta central. Mientras no hay precio confirmado no hay
  /// nada seguro que mostrar: ni un monto inventado ni un botón que llevaría a
  /// cobrar de más o de menos.
  Widget _buildCardContent() {
    if (_isLoadingRequest) {
      return const Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
        child: Center(
          child: SizedBox(
            width: 28.0,
            height: 28.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007376)),
            ),
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(),
                    color: const Color(0xFF00444B),
                    fontSize: 14.0,
                  ),
            ),
            TextButton(
              onPressed: _loadServiceRequest,
              child: Text(
                'Reintentar',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      color: const Color(0xFF007376),
                      fontSize: 14.0,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    final busy =
        _phase == _CheckoutPhase.creating || _phase == _CheckoutPhase.waiting;
    final subscriberAmount = _subscriberAmount;

    return Column(
      mainAxisSize: MainAxisSize.max,
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
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
          child: _buildPrice(srFormatAmount(_amount!, _currency), ' /visita'),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: _buildSoftButton(
            'Contratar',
            paid: _paidMethod == 'direct',
            onTap: busy ? null : _payDirect,
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: Text(
            'Si te suscribes a Dovia Home,\nse te cobrara:',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF00444B),
                  fontSize: 17.0,
                  letterSpacing: -0.34,
                  lineHeight: 1.4,
                ),
          ),
        ),
        if (subscriberAmount != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
            child: _buildPrice(
                srFormatAmount(subscriberAmount, _currency), ' /visita'),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: _buildSoftButton(
            'Subscribirse',
            paid: _paidMethod == 'subscription',
            onTap: busy ? null : _goToSubscription,
          ),
        ),
        _buildCheckoutStatus(),
      ],
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
                      showNotifications: true,
                      showSettings: true,
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
                        child: _buildCardContent(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 30.0, 20.0, 110.0),
                    child: FFButtonWidget(
                      // Bloqueo duro: no se puede avanzar sin pagar el servicio.
                      onPressed: _isPaid ? () async => _finish() : null,
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
