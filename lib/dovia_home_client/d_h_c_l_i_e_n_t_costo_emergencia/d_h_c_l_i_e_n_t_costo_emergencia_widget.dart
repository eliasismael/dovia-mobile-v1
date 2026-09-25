import '/core/result.dart';
import '/domain/payment_models.dart';
import '/dovia_home_client/checkout_launcher.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
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
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';

import 'd_h_c_l_i_e_n_t_costo_emergencia_model.dart';
export 'd_h_c_l_i_e_n_t_costo_emergencia_model.dart';

/// Pasarela de cobro condicional del servicio de emergencia ("Costo fijo mínimo
/// del trabajo"). Según el estatus de la cuenta renderiza:
/// - Premium (suscripción activa): tarjeta de descuento.
/// - Free (sin suscripción): tarjeta de pago regular + upsell.
///
/// **Los montos salen del backend**, no de la app: el precio, el descuento del
/// plan y el ahorro se leen de la solicitud
/// (`serviceRequest.price`), que es además el monto exacto que
/// `POST /payments/custom-checkout` exige recibir. Por eso la solicitud se crea
/// al montar la pantalla y no al cobrar: sin ella no hay precio que mostrar ni
/// `serviceId` con el que abrir el checkout.
///
/// El cobro es un checkout hospedado de Recurrente que se abre en el navegador;
/// la app nunca toca datos de tarjeta. Volver de esa pestaña no prueba nada:
/// quien confirma el pago es el webhook contra el backend, así que la pantalla
/// sondea la orden en vez de darla por cobrada.
///
/// Al confirmar el pago se **omite la selección de fecha/hora** (bypass de
/// calendario): se lanza directamente el modal de éxito y se redirige al
/// Dashboard, donde la solicitud aparece en "Próximas visitas" con estatus
/// "Pendiente" e indicador de alta prioridad (Emergencia).
class DHCLIENTCostoEmergenciaWidget extends StatefulWidget {
  const DHCLIENTCostoEmergenciaWidget({super.key});

  static String routeName = 'DH_CLIENT_CostoEmergencia';
  static String routePath = '/dHCLIENTCostoEmergencia';

  /// Categoría de emergencia elegida en la pantalla de Emergencias. Es
  /// obligatoria: el backend resuelve con ella el servicio de emergencia
  /// activo, así que sin categoría no hay solicitud que crear.
  static String? categoryId;

  /// Descripción del problema capturada en la pantalla de Emergencias.
  static String? description;

  /// Fotos opcionales adjuntadas en la pantalla de Emergencias. Se suben a la
  /// solicitud (presign → PUT → confirm) una vez creada.
  static List<FFUploadedFile> photos = [];

  /// Moneda del cobro. Los pagos custom de Dovia Home sólo aceptan quetzales.
  static const String currency = PaymentCurrency.gtq;

  /// Solicitud de emergencia ya creada en el backend, si la hay.
  ///
  /// Es estática y no del `State` porque la pantalla se remonta de cero al
  /// volver de comprar el plan (`DC_FormaPagoSuscripcion_2` cierra con
  /// `goNamed`, que reemplaza la pila). Con el id en el `State` ese regreso
  /// levantaría una segunda emergencia por el mismo problema.
  static String? serviceRequestId;

  @override
  State<DHCLIENTCostoEmergenciaWidget> createState() =>
      _DHCLIENTCostoEmergenciaWidgetState();
}

/// En qué punto del cobro está la pantalla. Mismo idioma que ValorVisita y que
/// `DC_FormaPagoSuscripcion_2`: el checkout de Recurrente se abre afuera, así
/// que la pantalla no puede dar el pago por hecho al volver.
enum _CheckoutPhase { idle, creating, waiting, failed }

class _DHCLIENTCostoEmergenciaWidgetState
    extends State<DHCLIENTCostoEmergenciaWidget> with WidgetsBindingObserver {
  late DHCLIENTCostoEmergenciaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Cómo se cubrió la emergencia: null = sin pagar, 'direct' = pago por uso,
  /// 'subscription' = cubierta por el plan. Sólo se setea cuando el backend
  /// confirma el cobro: nunca se anticipa un pago que todavía no ocurrió.
  String? _paidMethod;

  bool get _isPaid => _paidMethod != null;

  bool _isLoadingRequest = true;
  String? _loadError;
  Map<String, dynamic>? _requestData;

  _CheckoutPhase _phase = _CheckoutPhase.idle;
  String? _paymentOrderId;
  String? _pendingMethod;
  String? _failureMessage;
  bool _polling = false;

  /// El cobro se lanzó desde [Siguiente] (escenario Premium), así que al
  /// confirmarse hay que cerrar el flujo sin pedir otro tap. Desde [Contratar]
  /// queda en false: ahí el pago sólo desbloquea el botón inferior.
  bool _finishWhenPaid = false;

  num? get _amount =>
      _requestData == null ? null : srPriceAmount(_requestData!);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTCostoEmergenciaModel());
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.dispose();
    super.dispose();
  }

  /// Volver del navegador es la señal más temprana de que el cliente terminó
  /// de pagar.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _phase == _CheckoutPhase.waiting) {
      _pollUntilResolved();
    }
  }

  /// Deja la pantalla lista para cobrar: estado de suscripción, solicitud
  /// creada y su precio leído del backend.
  Future<void> _bootstrap() async {
    final payments = context.read<PaymentsRepository>();
    await payments.loadCurrentSubscription();
    if (!mounted) return;

    final id = await _ensureServiceRequest();
    if (!mounted || id == null) {
      safeSetState(() {
        _isLoadingRequest = false;
        _loadError ??= 'No se pudo registrar la emergencia.';
      });
      return;
    }

    await _loadServiceRequest(id);
    if (!mounted || _requestData == null) return;
    await _resolvePaymentState(payments);
  }

  /// Relee la solicitud para tomar su precio y su estado de pago. El backend ya
  /// aplica el descuento del plan, así que el monto que devuelve es el que hay
  /// que cobrar.
  Future<void> _loadServiceRequest(String serviceRequestId) async {
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

  /// Con qué estado abrir: ya pagada / cubierta por el plan, o con una orden de
  /// un intento anterior que hay que retomar en vez de crear un cobro nuevo.
  Future<void> _resolvePaymentState(PaymentsRepository payments) async {
    final data = _requestData;
    final serviceRequestId = DHCLIENTCostoEmergenciaWidget.serviceRequestId;
    if (data == null || serviceRequestId == null) return;

    final method = payments.hasActiveSubscription ? 'subscription' : 'direct';

    if (srIsPaid(data) || (srPriceAmount(data) ?? 0) <= 0) {
      safeSetState(() => _paidMethod = method);
      return;
    }

    final result = await payments.getPaymentStatus(serviceId: serviceRequestId);
    if (!mounted) return;
    final order = result.dataOrNull;
    if (order == null) return;

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
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Crea la solicitud de emergencia (`POST /dovia-home/service-requests/
  /// emergencies`) con la descripción levantada en la pantalla anterior y la
  /// dirección de servicio del cliente, y le adjunta las fotos. Idempotente:
  /// si ya se creó en este paso devuelve el mismo id.
  Future<String?> _ensureServiceRequest() async {
    final existing = DHCLIENTCostoEmergenciaWidget.serviceRequestId;
    if (existing != null) return existing;

    final categoryId = DHCLIENTCostoEmergenciaWidget.categoryId;
    if (categoryId == null || categoryId.isEmpty) {
      _showError('Elige el tipo de emergencia para continuar.');
      return null;
    }

    final token = currentAuthenticationToken ?? '';
    final addressId = await _resolveAddressId(token);
    if (addressId == null) {
      _showError(
          'No encontramos una ubicación registrada para enviarte el técnico.');
      return null;
    }

    final response = await DOVIAAPIDoviaHomeContextGroup
        .createEmergencyServiceRequestCall
        .call(
      categoryId: categoryId,
      description: DHCLIENTCostoEmergenciaWidget.description ?? '',
      addressId: addressId,
      authToken: token,
    );
    if (!response.succeeded) {
      _showError(doviaHomeErrorMessage(response) ??
          'No se pudo registrar la emergencia. Intenta de nuevo.');
      return null;
    }

    final id = DOVIAAPIDoviaHomeContextGroup.createEmergencyServiceRequestCall
        .id(response.jsonBody);
    if (id == null || id.isEmpty) {
      _showError('No se pudo registrar la emergencia. Intenta de nuevo.');
      return null;
    }

    DHCLIENTCostoEmergenciaWidget.serviceRequestId = id;
    await _uploadPhotos(id, token);
    return id;
  }

  /// Dirección de servicio a la que se envía el técnico: la que el cliente
  /// validó en el paso de Ubicación al entrar al flujo. El levantamiento de la
  /// emergencia no vuelve a pedirla (es urgente).
  ///
  /// Sólo si no hay ninguna verificada (Ej: se llegó acá sin pasar por
  /// Ubicación) se cae a la primera dirección registrada del cliente.
  Future<String?> _resolveAddressId(String token) async {
    final verified = DHCLIENTUbicacionWidget.lastVerifiedAddressId;
    if (verified != null && verified.trim().isNotEmpty) return verified.trim();

    final response =
        await DOVIAAPIDoviaHomeContextGroup.listServiceAddressesCall.call(
      authToken: token,
    );
    if (!response.succeeded) return null;

    final raw = DOVIAAPIDoviaHomeContextGroup.listServiceAddressesCall
            .addressesList(response.jsonBody) ??
        [];
    for (final address in raw.whereType<Map>()) {
      final id = (address['id'] ?? address['addressId'])?.toString();
      if (id != null && id.trim().isNotEmpty) return id.trim();
    }
    return null;
  }

  /// Sube las fotos de la emergencia a S3 (presign → PUT → confirm). Es
  /// best-effort: la solicitud ya existe, un fallo de fotos no la invalida.
  Future<void> _uploadPhotos(String serviceRequestId, String token) async {
    final photos = DHCLIENTCostoEmergenciaWidget.photos;
    if (photos.isEmpty) return;

    final uploads = <Map<String, dynamic>>[];
    for (var i = 0; i < photos.length; i++) {
      uploads.add({
        'clientUploadId': 'upload_$i',
        'contentType': 'image/jpeg',
        'fileName': photos[i].name ?? 'foto_$i.jpg',
      });
    }

    final presignRes = await DOVIAAPIDoviaHomeContextGroup
        .presignServiceRequestImagesCall
        .call(
      serviceRequestId: serviceRequestId,
      uploads: uploads,
      authToken: token,
    );
    if (!presignRes.succeeded) return;

    final items = DOVIAAPIDoviaHomeContextGroup.presignServiceRequestImagesCall
        .items(presignRes.jsonBody);
    if (items == null || items.isEmpty) return;

    final storageKeys = <String>[];
    for (final item in items) {
      if (item is! Map) continue;
      final clientUploadId = item['clientUploadId']?.toString() ?? '';
      final uploadUrl = item['uploadUrl']?.toString();
      final storageKey = item['storageKey']?.toString();
      final index =
          int.tryParse(clientUploadId.replaceAll('upload_', '')) ?? -1;
      if (uploadUrl == null || index < 0 || index >= photos.length) continue;

      final bytes = photos[index].bytes;
      if (bytes == null) continue;

      final putRes = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': 'image/jpeg'},
        body: bytes,
      );
      if (putRes.statusCode >= 200 &&
          putRes.statusCode < 300 &&
          storageKey != null) {
        storageKeys.add(storageKey);
      }
    }

    if (storageKeys.isEmpty) return;
    await DOVIAAPIDoviaHomeContextGroup.confirmServiceRequestImagesCall.call(
      serviceRequestId: serviceRequestId,
      storageKeys: storageKeys,
      authToken: token,
    );
  }

  /// Abre el cobro de la emergencia por Recurrente
  /// (`POST /payments/custom-checkout`, `EMERGENCY_SERVICE`).
  ///
  /// El monto sale de la solicitud, no de la app: el backend rechaza el
  /// checkout si `amount` no coincide con `serviceRequest.price.price.gtq`, que
  /// es además donde ya está aplicado el descuento del plan.
  Future<void> _startCheckout({required bool finishWhenPaid}) async {
    if (_isPaid ||
        _phase == _CheckoutPhase.creating ||
        _phase == _CheckoutPhase.waiting) {
      return;
    }

    final serviceRequestId = DHCLIENTCostoEmergenciaWidget.serviceRequestId;
    final amount = _amount;
    if (serviceRequestId == null || amount == null) {
      _showError('No se pudo cargar el precio del servicio. Intenta de nuevo.');
      return;
    }

    final payments = context.read<PaymentsRepository>();
    _finishWhenPaid = finishWhenPaid;
    safeSetState(() {
      _phase = _CheckoutPhase.creating;
      _failureMessage = null;
    });

    final result = await payments.createCustomCheckout(
      paymentType: PaymentType.emergencyService,
      amount: amount,
      currency: DHCLIENTCostoEmergenciaWidget.currency,
      serviceId: serviceRequestId,
      description: 'Servicio de emergencia',
    );
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        await _openCheckout(
          data,
          method: payments.hasActiveSubscription ? 'subscription' : 'direct',
        );
      case Failure(:final message):
        safeSetState(() => _phase = _CheckoutPhase.idle);
        _showError(message);
    }
  }

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

  /// Reanuda una orden caída. Nunca se crea un checkout nuevo: `resume` genera
  /// una sucesora de la orden existente.
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

  /// Sondea hasta que el backend resuelva la orden: abrir el checkout no cobra,
  /// lo confirma el webhook de Recurrente.
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

      // Se agotó la espera sin novedad: no es un fallo, el pago puede seguir
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
        if (_finishWhenPaid) await _finish();
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

  /// Escenario Free — [Contratar]: cobra el monto total. Sólo al confirmarse el
  /// cobro se desbloquea el botón inferior [Siguiente].
  Future<void> _payDirect() => _startCheckout(finishWhenPaid: false);

  /// Escenario Free — [Subscribirse]: abre el flujo de adquisición del plan
  /// DOVIA Home. Al volver se re-consulta la suscripción y se relee la
  /// solicitud: el backend le aplica el descuento del plan, así que la pantalla
  /// pasa al escenario Premium con el precio ya recalculado. Si el cliente
  /// omitió la compra, el paso sigue bloqueado hasta que pague.
  Future<void> _goToSubscription() async {
    if (_isPaid ||
        _phase == _CheckoutPhase.creating ||
        _phase == _CheckoutPhase.waiting) {
      return;
    }
    // Sin esto, "Omitir" en Planes deriva al flujo de visita estándar (con paso
    // de calendario), que es justo el que la emergencia debe saltear.
    DHCLIENTPlanesPageWidget.pendingReturnRoute =
        DHCLIENTCostoEmergenciaWidget.routeName;
    await context.pushNamed(DHCLIENTPlanesPageWidget.routeName);
    if (!mounted) return;
    DHCLIENTPlanesPageWidget.pendingReturnRoute = null;

    final payments = context.read<PaymentsRepository>();
    await payments.loadCurrentSubscription(forceRefresh: true);
    if (!mounted) return;

    final id = DHCLIENTCostoEmergenciaWidget.serviceRequestId;
    if (id == null) return;
    await _loadServiceRequest(id);
    if (!mounted || _requestData == null) return;
    await _resolvePaymentState(payments);
  }

  /// Confirma la solicitud de emergencia. **Omite el calendario**: no hay paso
  /// de selección de fecha y hora. Cobra si todavía no se cobró (Premium),
  /// registra la solicitud en "Próximas visitas" con alta prioridad, lanza el
  /// modal de éxito y redirige al Dashboard.
  Future<void> _confirmAndSchedule() async {
    // Premium llega acá sin haber pagado: [Siguiente] es su botón de cobro. El
    // modal de éxito lo lanza el sondeo cuando el webhook confirma, vía
    // `_finishWhenPaid`; anunciarlo antes sería dar por agendada una
    // emergencia que nadie pagó.
    if (!_isPaid) {
      await _startCheckout(finishWhenPaid: true);
      return;
    }
    await _finish();
  }

  /// Cierra el flujo con el pago ya confirmado: registra la emergencia en el
  /// Dashboard con alta prioridad, lanza el modal de éxito y redirige.
  Future<void> _finish() async {
    if (_model.isSubmitting) return;
    safeSetState(() => _model.isSubmitting = true);
    try {
      DHCLIENTHomepageWidget.upcomingVisits.insert(
        0,
        ScheduledVisit(
          id: DHCLIENTCostoEmergenciaWidget.serviceRequestId,
          service: 'Servicio de emergencia',
          date: 'Atención prioritaria',
          time: 'respuesta < 18h',
          status: 'Pendiente',
          isEmergency: true,
        ),
      );
      DHCLIENTCostoEmergenciaWidget.categoryId = null;
      DHCLIENTCostoEmergenciaWidget.description = null;
      DHCLIENTCostoEmergenciaWidget.photos = [];
      // La emergencia quedó cerrada: dejar el id pegado haría que la próxima
      // entrada a esta pantalla intente cobrar la solicitud anterior.
      DHCLIENTCostoEmergenciaWidget.serviceRequestId = null;
      // El flujo terminó: la dirección verificada no debe quedar pegada a una
      // emergencia futura que se levante sin pasar por Ubicación.
      DHCLIENTUbicacionWidget.lastVerifiedAddressId = null;
      DHCLIENTUbicacionWidget.lastVerifiedAddressLabel = null;

      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.0),
            child: DHCLIENTExitoProgramarAgendaWidget(
              message: 'Programaste con éxito tu servicio para la Casa',
            ),
          );
        },
      );
      // Al cerrarse el modal (auto o al tapear fuera) redirige al Dashboard.
      if (mounted) {
        context.goNamed(DHCLIENTHomepageWidget.routeName);
      }
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // `hasActiveSubscription` es false mientras el estado no se resolvió:
    // hasta saberlo no se renderiza ninguna de las dos tarjetas, para no
    // mostrarle el upsell de Premium a un cliente que sí paga.
    final payments = context.watch<PaymentsRepository>();
    final premiumResolved = payments.subscriptionLoaded;
    final isPremium = payments.hasActiveSubscription;

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
                    // Además del estatus de la cuenta hace falta el precio: las
                    // dos tarjetas lo pintan y sale de la solicitud, no de la
                    // app.
                    child: (!premiumResolved || _isLoadingRequest)
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _requestData == null
                            ? _loadErrorCard()
                            : isPremium
                                ? _premiumCard()
                                : _freeCard(),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 30.0, 20.0, 110.0),
                    child: _nextButton(
                      isPremium: isPremium,
                      premiumResolved: premiumResolved,
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

  // ---------------------------------------------------------------------------
  // Escenario A: Premium (tarjeta de descuento).
  // ---------------------------------------------------------------------------

  Widget _premiumCard() {
    final data = _requestData!;
    final amount = srPriceAmount(data)!;
    final base = srBasePriceAmount(data);
    final discount = srPlanDiscount(data);

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
          // Precio base tachado, etiqueta de descuento y ahorro: los tres sólo
          // se pintan si el backend expone un precio de lista mayor al que se
          // cobra. Sin ese dato no hay descuento verificable que anunciar, y
          // fabricarlo sería inflar un ahorro inventado.
          if (discount != null) ...[
            _priceLine(_formatAmount(base!), '/el día', struck: true),
            const SizedBox(height: 18.0),
            _premiumPill(
              leading: Text(
                '${discount.percentOff}% OFF',
                style: GoogleFonts.publicSans(
                  color: const Color(0xFF007376),
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
              trailing: 'DOVIA PREMIUM',
            ),
            const SizedBox(height: 18.0),
          ],
          // Precio final a cobrar.
          _priceLine(_formatAmount(amount), '/el día'),
          if (discount != null) ...[
            const SizedBox(height: 18.0),
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
                      text: _formatAmount(discount.savings),
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
          _checkoutStatus(),
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
    final data = _requestData!;
    final amount = srPriceAmount(data)!;
    final subscriberAmount = srSubscriberPriceAmount(data);

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
          _priceLine(_formatAmount(amount), '/el día'),
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
          // Sin precio de suscriptor en el payload no se pinta monto: el
          // incentivo se sostiene solo, y un número inventado acá sería el que
          // el cliente espera que le cobren después.
          if (subscriberAmount != null) ...[
            const SizedBox(height: 12.0),
            _priceLine(_formatAmount(subscriberAmount), '/el día'),
          ],
          const SizedBox(height: 20.0),
          // Nunca queda en estado "Pagado": si la contratación prospera, la
          // pantalla pasa al escenario Premium y esta tarjeta deja de verse.
          _softButton(
            'Subscribirse',
            onTap: _goToSubscription,
          ),
          _checkoutStatus(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers compartidos.
  // ---------------------------------------------------------------------------

  /// La solicitud no se pudo registrar o no trajo precio. No se ofrece ningún
  /// botón de cobro: sin monto confirmado no hay nada que cobrar.
  Widget _loadErrorCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(26.0),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _loadError ?? 'No se pudo cargar el precio del servicio.',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF00444B),
              fontSize: 14.0,
            ),
          ),
          TextButton(
            onPressed: _bootstrap,
            child: Text(
              'Reintentar',
              style: GoogleFonts.publicSans(
                color: const Color(0xFF007376),
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(num amount) => srFormatAmount(
        amount,
        _requestData == null
            ? DHCLIENTCostoEmergenciaWidget.currency
            : srPriceCurrency(_requestData!),
      );

  /// Retroalimentación del checkout externo. Sin esto el cliente no tiene cómo
  /// saber que el pago sigue procesándose (Recurrente abre en otra pestaña) ni
  /// cómo retomar una orden caída.
  Widget _checkoutStatus() {
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
                style: GoogleFonts.publicSans(
                  color: const Color(0xFF00444B),
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
              TextButton(
                onPressed: _pollUntilResolved,
                child: Text(
                  'Ya completé el pago',
                  style: GoogleFonts.publicSans(
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
                style: GoogleFonts.publicSans(
                  color: const Color(0xFFD92D20),
                  fontSize: 13.0,
                ),
              ),
              TextButton(
                onPressed: _resumeCheckout,
                child: Text(
                  'Reintentar el pago',
                  style: GoogleFonts.publicSans(
                    color: const Color(0xFF007376),
                    fontWeight: FontWeight.w600,
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
      onTap: (paid ||
              _model.isSubmitting ||
              _phase == _CheckoutPhase.creating ||
              _phase == _CheckoutPhase.waiting)
          ? null
          : onTap,
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
                child:
                    Icon(Icons.check_circle, color: Colors.white, size: 20.0),
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
  /// - Premium: habilitado apenas hay precio; es su botón de cobro (abre el
  ///   checkout y cierra el flujo cuando el webhook confirma).
  /// - Free: bloqueado hasta que el usuario complete el pago (contratando
  ///   directo o suscribiéndose).
  /// - Mientras no se sepa si es Premium, no haya precio, o un checkout esté
  ///   en curso: bloqueado.
  Widget _nextButton({required bool isPremium, required bool premiumResolved}) {
    final busy = _model.isSubmitting ||
        _phase == _CheckoutPhase.creating ||
        _phase == _CheckoutPhase.waiting;
    final enabled = premiumResolved &&
        _requestData != null &&
        (isPremium || _isPaid) &&
        !busy;
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
