import 'package:flutter/foundation.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_helpers.dart' show ApiCallResponse;
import '/backend/api_requests/api_payments.dart';
import '/core/result.dart';
import '/domain/payment_models.dart';

/// Single Source of Truth para pagos y suscripciones (Recurrente).
///
/// Envuelve `DOVIAAPIPaymentContextGroup` y expone [Result]-based methods
/// listos para consumir desde la UI. Cachea planes y la suscripcion actual
/// durante la sesion.
///
/// Uso:
/// ```dart
/// final repo = context.read<PaymentsRepository>();
/// final result = await repo.createSubscriptionCheckout(planId: id);
/// switch (result) {
///   case Success(:final data): // abrir data.checkoutUrl con url_launcher
///   case Failure(:final message): // mostrar error
/// }
/// ```
class PaymentsRepository extends ChangeNotifier {
  // ------- Estado cacheado -------
  List<SubscriptionPlan> _plans = [];
  Subscription? _currentSubscription;
  bool _subscriptionLoaded = false; // distingue "no cargado" de "sin sub"
  List<PaymentOrder> _payments = [];

  bool _isLoading = false;
  String? _error;

  List<SubscriptionPlan> get plans => _plans;
  Subscription? get currentSubscription => _currentSubscription;
  bool get hasActiveSubscription =>
      _currentSubscription?.keepsBenefits ?? false;

  /// Sigue suscripto pero el período venció: la UI mantiene la cara de
  /// suscriptor y en los puntos clave pide reactivar el plan, porque el
  /// backend no le aplica los beneficios hasta que se renueve.
  bool get subscriptionNeedsRenewal =>
      hasActiveSubscription && _currentSubscription!.periodExpired;

  /// Si ya se resolvió el estado de suscripción. Permite a la UI distinguir
  /// "todavía no sé" de "no tiene suscripción" y así no mostrarle upsells de
  /// Premium a un cliente que sí paga mientras carga.
  bool get subscriptionLoaded => _subscriptionLoaded;
  List<PaymentOrder> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _token => currentAuthenticationToken ?? '';

  // ---------------------------------------------------------------------------
  // Planes
  // ---------------------------------------------------------------------------

  /// Lista los planes de suscripcion (`GET /subscriptions/plans`).
  Future<Result<List<SubscriptionPlan>>> loadPlans(
      {bool forceRefresh = false}) async {
    if (_plans.isNotEmpty && !forceRefresh) {
      return Success(_plans);
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await DOVIAAPIPaymentContextGroup.listSubscriptionPlansCall
        .call(authToken: _token);

    _isLoading = false;

    if (!response.succeeded) {
      _error = _messageFrom(response, 'No se pudieron cargar los planes');
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    _plans =
        _listFrom(response.jsonBody).map(SubscriptionPlan.fromJson).toList();
    notifyListeners();
    return Success(_plans);
  }

  // ---------------------------------------------------------------------------
  // Suscripcion actual
  // ---------------------------------------------------------------------------

  /// Obtiene la suscripcion con beneficios del usuario
  /// (`GET /subscriptions/current`). Un `404` (sin suscripcion) se trata como
  /// exito con `null`, no como error.
  Future<Result<Subscription?>> loadCurrentSubscription(
      {bool forceRefresh = false}) async {
    if (_subscriptionLoaded && !forceRefresh) {
      return Success(_currentSubscription);
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await DOVIAAPIPaymentContextGroup
        .getCurrentSubscriptionCall
        .call(authToken: _token);

    _isLoading = false;

    if (response.statusCode == 404) {
      _currentSubscription = null;
      _subscriptionLoaded = true;
      notifyListeners();
      return const Success(null);
    }

    if (!response.succeeded) {
      _error = _messageFrom(response, 'No se pudo cargar la suscripcion');
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    final body = response.jsonBody as Map<String, dynamic>?;
    _currentSubscription = body == null ? null : Subscription.fromJson(body);
    _subscriptionLoaded = true;
    notifyListeners();
    return Success(_currentSubscription);
  }

  /// Cancela la suscripcion actual (`DELETE /subscriptions/current`). Marca
  /// `CANCEL_SCHEDULED`; los beneficios se conservan hasta `currentPeriodEnd`.
  Future<Result<Subscription?>> cancelCurrentSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await DOVIAAPIPaymentContextGroup
        .cancelCurrentSubscriptionCall
        .call(authToken: _token);

    _isLoading = false;

    if (!response.succeeded) {
      _error = _messageFrom(response, 'No se pudo cancelar la suscripcion');
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    final body = response.jsonBody as Map<String, dynamic>?;
    if (body != null) {
      _currentSubscription = Subscription.fromJson(body);
    }
    notifyListeners();
    return Success(_currentSubscription);
  }

  // ---------------------------------------------------------------------------
  // Checkouts
  // ---------------------------------------------------------------------------

  /// Crea (o reutiliza) el checkout de suscripcion
  /// (`POST /payments/subscription-checkout`). Devuelve la orden con
  /// `checkoutUrl` para abrir en el navegador.
  Future<Result<PaymentOrder>> createSubscriptionCheckout({
    required String planId,
  }) async {
    return _checkoutCall(
      () => DOVIAAPIPaymentContextGroup.createSubscriptionCheckoutCall.call(
        planId: planId,
        authToken: _token,
      ),
      'No se pudo iniciar el pago de la suscripcion',
    );
  }

  /// Crea (o reutiliza) un checkout custom de Dovia Home
  /// (`POST /payments/custom-checkout`). [amount] debe coincidir con el precio
  /// de la solicitud (`serviceRequest.price.price.gtq`).
  Future<Result<PaymentOrder>> createCustomCheckout({
    required String paymentType,
    required num amount,
    required String serviceId,
    String currency = PaymentCurrency.gtq,
    String? description,
  }) async {
    return _checkoutCall(
      () => DOVIAAPIPaymentContextGroup.createCustomCheckoutCall.call(
        paymentType: paymentType,
        amount: amount,
        currency: currency,
        serviceId: serviceId,
        description: description,
        authToken: _token,
      ),
      'No se pudo iniciar el pago',
    );
  }

  /// Reanuda una orden terminal reanudable o devuelve el checkout activo
  /// (`POST /payments/{paymentOrderId}/resume`).
  Future<Result<PaymentOrder>> resumePayment({
    required String paymentOrderId,
  }) async {
    return _checkoutCall(
      () => DOVIAAPIPaymentContextGroup.resumePaymentCheckoutCall.call(
        paymentOrderId: paymentOrderId,
        authToken: _token,
      ),
      'No se pudo reanudar el pago',
    );
  }

  /// Crea un checkout `mode: setup` para actualizar el metodo de pago de una
  /// suscripcion `PAST_DUE`
  /// (`POST /subscriptions/payment-method/setup-checkout`).
  Future<Result<PaymentOrder>> createSetupCheckout() async {
    return _checkoutCall(
      () => DOVIAAPIPaymentContextGroup.createSetupCheckoutCall
          .call(authToken: _token),
      'No se pudo iniciar la actualizacion del metodo de pago',
    );
  }

  // ---------------------------------------------------------------------------
  // Pagos
  // ---------------------------------------------------------------------------

  /// Lista los pagos del usuario (`GET /payments`).
  Future<Result<List<PaymentOrder>>> loadPayments({
    int? page,
    int? limit,
    String? status,
    String? paymentType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await DOVIAAPIPaymentContextGroup.listPaymentsCall.call(
      page: page,
      limit: limit,
      status: status,
      paymentType: paymentType,
      authToken: _token,
    );

    _isLoading = false;

    if (!response.succeeded) {
      _error = _messageFrom(response, 'No se pudieron cargar los pagos');
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    _payments =
        _listFrom(response.jsonBody).map(PaymentOrder.fromJson).toList();
    notifyListeners();
    return Success(_payments);
  }

  /// Consulta el estado de una orden por `paymentOrderId`, `checkoutId` o
  /// `serviceId` (`GET /payments/status`). Debe enviarse al menos uno.
  Future<Result<PaymentOrder>> getPaymentStatus({
    String? paymentOrderId,
    String? checkoutId,
    String? serviceId,
  }) async {
    final response =
        await DOVIAAPIPaymentContextGroup.getPaymentStatusCall.call(
      paymentOrderId: paymentOrderId,
      checkoutId: checkoutId,
      serviceId: serviceId,
      authToken: _token,
    );

    if (!response.succeeded) {
      return Failure(
        _messageFrom(response, 'No se pudo consultar el estado del pago'),
        statusCode: response.statusCode,
      );
    }

    final body = response.jsonBody as Map<String, dynamic>?;
    if (body == null) {
      return const Failure('Respuesta inesperada del servidor');
    }
    return Success(PaymentOrder.fromJson(body));
  }

  /// Espera a que una orden deje de estar en curso y devuelve su estado final.
  ///
  /// Abrir el checkout no cobra: el cobro lo confirma Recurrente contra el
  /// webhook del backend, que recién ahí mueve la orden a `SUCCEEDED` y crea la
  /// suscripción. Volver del navegador no es señal de nada, así que la UI tiene
  /// que sondear en vez de asumir.
  ///
  /// Devuelve la orden ya resuelta, o `null` si se agotó [timeout] sin que
  /// saliera de `PENDING`/`IN_PROCESS` — que no significa que el pago falló,
  /// sino que todavía no se sabe. Los fallos de consulta (red caída) no cortan
  /// el sondeo: se reintenta hasta el timeout.
  Future<PaymentOrder?> awaitPaymentResolution(
    String paymentOrderId, {
    Duration interval = const Duration(seconds: 3),
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      final result = await getPaymentStatus(paymentOrderId: paymentOrderId);
      final order = result.dataOrNull;
      if (order != null && !_isInFlight(order.status)) return order;
      await Future<void>.delayed(interval);
    }
    return null;
  }

  static bool _isInFlight(String status) =>
      status == PaymentStatus.pending || status == PaymentStatus.inProcess;

  // ---------------------------------------------------------------------------
  // Admin (HQ_ADMIN)
  // ---------------------------------------------------------------------------

  /// Lista todas las suscripciones activas (`GET /admin/subscriptions`).
  Future<Result<List<Subscription>>> loadAllActiveSubscriptions() async {
    final response = await DOVIAAPIPaymentContextGroup
        .adminListActiveSubscriptionsCall
        .call(authToken: _token);

    if (!response.succeeded) {
      return Failure(
        _messageFrom(response, 'No se pudieron cargar las suscripciones'),
        statusCode: response.statusCode,
      );
    }

    return Success(
        _listFrom(response.jsonBody).map(Subscription.fromJson).toList());
  }

  /// Crea un plan y lo sincroniza con Recurrente
  /// (`POST /admin/subscription-plans`).
  Future<Result<SubscriptionPlan>> createPlan({
    required String code,
    required String name,
    required num amount,
    required String interval,
    String currency = PaymentCurrency.gtq,
    String? description,
  }) async {
    final response =
        await DOVIAAPIPaymentContextGroup.adminCreateSubscriptionPlanCall.call(
      code: code,
      name: name,
      amount: amount,
      interval: interval,
      currency: currency,
      description: description,
      authToken: _token,
    );

    if (!response.succeeded) {
      return Failure(
        _messageFrom(response, 'No se pudo crear el plan'),
        statusCode: response.statusCode,
      );
    }

    final body = response.jsonBody as Map<String, dynamic>?;
    final plan = body == null ? null : SubscriptionPlan.fromJson(body);
    await loadPlans(forceRefresh: true);
    return plan != null
        ? Success(plan)
        : const Failure('Respuesta inesperada del servidor');
  }

  /// Actualiza un plan y lo sincroniza con Recurrente
  /// (`PATCH /admin/subscription-plans/{id}`).
  Future<Result<SubscriptionPlan>> updatePlan({
    required String planId,
    String? code,
    String? name,
    num? amount,
    String? currency,
    String? interval,
    String? description,
  }) async {
    final response =
        await DOVIAAPIPaymentContextGroup.adminUpdateSubscriptionPlanCall.call(
      planId: planId,
      code: code,
      name: name,
      amount: amount,
      currency: currency,
      interval: interval,
      description: description,
      authToken: _token,
    );

    if (!response.succeeded) {
      return Failure(
        _messageFrom(response, 'No se pudo actualizar el plan'),
        statusCode: response.statusCode,
      );
    }

    final body = response.jsonBody as Map<String, dynamic>?;
    final plan = body == null ? null : SubscriptionPlan.fromJson(body);
    await loadPlans(forceRefresh: true);
    return plan != null
        ? Success(plan)
        : const Failure('Respuesta inesperada del servidor');
  }

  /// Desactiva un plan (`DELETE /admin/subscription-plans/{id}`).
  Future<Result<bool>> deletePlan({required String planId}) async {
    final response =
        await DOVIAAPIPaymentContextGroup.adminDeleteSubscriptionPlanCall.call(
      planId: planId,
      authToken: _token,
    );

    if (!response.succeeded) {
      return Failure(
        _messageFrom(response, 'No se pudo eliminar el plan'),
        statusCode: response.statusCode,
      );
    }

    await loadPlans(forceRefresh: true);
    return const Success(true);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Ejecuta un endpoint que devuelve una orden con checkout y la mapea a
  /// [PaymentOrder]. Comparte el manejo de loading/error.
  Future<Result<PaymentOrder>> _checkoutCall(
    Future<ApiCallResponse> Function() run,
    String defaultError,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await run();

    _isLoading = false;

    if (!response.succeeded) {
      _error = _messageFrom(response, defaultError);
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    final body = response.jsonBody as Map<String, dynamic>?;
    notifyListeners();
    if (body == null) {
      return const Failure('Respuesta inesperada del servidor');
    }
    return Success(PaymentOrder.fromJson(body));
  }

  /// Normaliza la respuesta de un endpoint de lista, tolerando tanto un
  /// arreglo directo (`[...]`) como uno envuelto en `{ "data": [...] }`.
  Iterable<Map<String, dynamic>> _listFrom(dynamic body) {
    final list = body is List
        ? body
        : (body is Map ? body['data'] as List? : null) ?? const [];
    return list.whereType<Map<String, dynamic>>();
  }

  String _messageFrom(ApiCallResponse response, String fallback) {
    final message = _userMessageFrom(response, fallback);
    if (!kDebugMode) return message;

    // Solo en debug: el backend responde errores internos con un mensaje
    // genérico, así que se suma el origen y código para diagnosticar sin
    // entrar a los logs de AWS.
    debugPrint('[Payments] ${response.statusCode}: ${response.bodyText}');
    final body = response.jsonBody;
    final errors = body is Map ? body['errors'] : null;
    final first = errors is List && errors.isNotEmpty ? errors.first : null;
    final detail = [
      'HTTP ${response.statusCode}',
      if (first is Map && first['source'] != null) '${first['source']}',
      if (first is Map && first['code'] != null) '${first['code']}',
    ].join(' · ');
    return '$message ($detail)';
  }

  String _userMessageFrom(ApiCallResponse response, String fallback) {
    final body = response.jsonBody;
    if (body is Map) {
      final msg = body['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.first.toString();
    }
    return fallback;
  }

  /// Limpia el estado cacheado (llamar al cerrar sesion).
  ///
  /// Sin nada que limpiar no notifica: se invoca desde el stream de auth, que
  /// puede emitir en medio de un build, y un `notifyListeners()` de más ahí
  /// provocaría un rebuild durante el build.
  void clear() {
    final isEmpty = _plans.isEmpty &&
        _currentSubscription == null &&
        !_subscriptionLoaded &&
        _payments.isEmpty &&
        _error == null;
    if (isEmpty) return;

    _plans = [];
    _currentSubscription = null;
    _subscriptionLoaded = false;
    _payments = [];
    _error = null;
    notifyListeners();
  }
}
