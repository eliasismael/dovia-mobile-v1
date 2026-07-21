// Domain models for Payments & Subscriptions (Recurrente).
//
// Los estados/tipos se mantienen como String crudo (consistente con el resto
// de modelos del dominio) y se exponen constantes + getters de conveniencia
// que encapsulan las reglas de negocio del backend.

/// Estados posibles de una `PaymentOrder`.
abstract class PaymentStatus {
  static const pending = 'PENDING';
  static const inProcess = 'IN_PROCESS';
  static const succeeded = 'SUCCEEDED';
  static const failed = 'FAILED';
  static const expired = 'EXPIRED';
  static const canceled = 'CANCELED';
}

/// Tipos de pago (`paymentType`).
abstract class PaymentType {
  static const subscription = 'SUBSCRIPTION';
  static const extraMaterials = 'EXTRA_MATERIALS';
  static const emergencyService = 'EMERGENCY_SERVICE';
  static const normalService = 'NORMAL_SERVICE';
  static const serviceQuote = 'SERVICE_QUOTE'; // solo historico / filtros
  static const outOfScopeQuote = 'OUT_OF_SCOPE_QUOTE';

  /// Tipos aceptados por `POST /payments/custom-checkout`.
  static const customCheckoutTypes = <String>[
    extraMaterials,
    emergencyService,
    normalService,
    outOfScopeQuote,
  ];
}

/// Estados posibles de una `Subscription`.
abstract class SubscriptionStatus {
  static const active = 'ACTIVE';
  static const pastDue = 'PAST_DUE';
  static const cancelScheduled = 'CANCEL_SCHEDULED';
  static const canceledByUser = 'CANCELED_BY_USER';
  static const canceledByRecurrente = 'CANCELED_BY_RECURRENTE';
}

/// Monedas soportadas.
abstract class PaymentCurrency {
  static const gtq = 'GTQ';
  static const usd = 'USD';
}

// ---------------------------------------------------------------------------
// PaymentOrder
// ---------------------------------------------------------------------------

/// Orden de pago / checkout devuelta por los endpoints de `/payments`.
class PaymentOrder {
  final String id;
  final String status;
  final String? paymentType;
  final num? amount;
  final String? currency;
  final String? checkoutUrl;
  final String? checkoutId;
  final String? serviceId;
  final String? planId;
  final String? origin;
  final String? failureReason;
  final String? expiresAt; // ISO 8601
  final String? createdAt;
  final String? updatedAt;

  const PaymentOrder({
    required this.id,
    required this.status,
    this.paymentType,
    this.amount,
    this.currency,
    this.checkoutUrl,
    this.checkoutId,
    this.serviceId,
    this.planId,
    this.origin,
    this.failureReason,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  /// `true` si el checkout ya vencio segun `expiresAt`.
  bool get isExpired {
    if (expiresAt == null) return false;
    final exp = DateTime.tryParse(expiresAt!);
    if (exp == null) return false;
    return DateTime.now().toUtc().isAfter(exp.toUtc());
  }

  /// Hay un checkout vigente que se puede abrir directamente.
  bool get hasActiveCheckout =>
      checkoutUrl != null &&
      checkoutUrl!.isNotEmpty &&
      !isExpired &&
      status != PaymentStatus.succeeded &&
      status != PaymentStatus.canceled;

  /// Una orden terminal reanudable via `POST /payments/{id}/resume`.
  bool get isResumable =>
      status == PaymentStatus.expired ||
      status == PaymentStatus.failed ||
      status == PaymentStatus.canceled ||
      (hasActiveCheckout);

  bool get isPaid => status == PaymentStatus.succeeded;

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return PaymentOrder(
      id: data['id'] as String? ?? data['paymentOrderId'] as String? ?? '',
      status: data['status'] as String? ?? '',
      paymentType: data['paymentType'] as String?,
      amount: data['amount'] as num?,
      currency: data['currency'] as String?,
      checkoutUrl: _nonEmpty(data['checkoutUrl']) ?? _nonEmpty(data['url']),
      checkoutId: _nonEmpty(data['checkoutId']) ?? _nonEmpty(data['checkout_id']),
      serviceId: _nonEmpty(data['serviceId']),
      planId: _nonEmpty(data['planId']),
      origin: _nonEmpty(data['origin']),
      failureReason: _nonEmpty(data['failureReason']),
      expiresAt: _nonEmpty(data['expiresAt']),
      createdAt: _nonEmpty(data['createdAt']),
      updatedAt: _nonEmpty(data['updatedAt']),
    );
  }

  static String? _nonEmpty(dynamic v) {
    if (v is String && v.isNotEmpty) return v;
    return null;
  }
}

// ---------------------------------------------------------------------------
// SubscriptionPlan
// ---------------------------------------------------------------------------

/// Plan de suscripcion (`subscription_plans`).
class SubscriptionPlan {
  final String id;
  final String? code;
  final String name;
  final String? description;
  final num? amount;
  final String? currency;
  final String? interval;
  final String? recurrentePriceId;
  final String? recurrenteProductId;
  final bool active;

  const SubscriptionPlan({
    required this.id,
    this.code,
    required this.name,
    this.description,
    this.amount,
    this.currency,
    this.interval,
    this.recurrentePriceId,
    this.recurrenteProductId,
    this.active = true,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SubscriptionPlan(
      id: data['id'] as String? ?? '',
      code: data['code'] as String?,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      amount: data['amount'] as num?,
      currency: data['currency'] as String?,
      interval: data['interval'] as String?,
      recurrentePriceId: data['recurrentePriceId'] as String?,
      recurrenteProductId: data['recurrenteProductId'] as String?,
      active: data['active'] as bool? ?? true,
    );
  }
}

// ---------------------------------------------------------------------------
// Subscription
// ---------------------------------------------------------------------------

/// Suscripcion del usuario (`SubscriptionResponseDto`).
class Subscription {
  final String id;
  final String? userId;
  final String? planId;
  final String status;
  final String? recurrenteSubscriptionId;
  final String? productId;
  final String? priceId;
  final String? paymentMethodId;
  final String? currentPeriodStart; // ISO 8601
  final String? currentPeriodEnd; // ISO 8601
  final String? nextPaymentAttemptAt; // ISO 8601
  final int? paymentRetries;
  final String? rawStatus;
  final num? amount;
  final String? currency;
  final String? cancellationReason;
  final String? createdAt;
  final String? updatedAt;

  const Subscription({
    required this.id,
    this.userId,
    this.planId,
    required this.status,
    this.recurrenteSubscriptionId,
    this.productId,
    this.priceId,
    this.paymentMethodId,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.nextPaymentAttemptAt,
    this.paymentRetries,
    this.rawStatus,
    this.amount,
    this.currency,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPastDue => status == SubscriptionStatus.pastDue;
  bool get isCancelScheduled => status == SubscriptionStatus.cancelScheduled;

  /// La suscripcion aun conserva beneficios (lo que retorna
  /// `GET /subscriptions/current`).
  bool get keepsBenefits =>
      isActive || isPastDue || isCancelScheduled;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return Subscription(
      id: data['id'] as String? ?? '',
      userId: data['userId'] as String?,
      planId: data['planId'] as String?,
      status: data['status'] as String? ?? '',
      recurrenteSubscriptionId: data['recurrenteSubscriptionId'] as String?,
      productId: data['productId'] as String?,
      priceId: data['priceId'] as String?,
      paymentMethodId: data['paymentMethodId'] as String?,
      currentPeriodStart: data['currentPeriodStart'] as String?,
      currentPeriodEnd: data['currentPeriodEnd'] as String?,
      nextPaymentAttemptAt: data['nextPaymentAttemptAt'] as String?,
      paymentRetries: (data['paymentRetries'] as num?)?.toInt(),
      rawStatus: data['rawStatus'] as String?,
      amount: data['amount'] as num?,
      currency: data['currency'] as String?,
      cancellationReason: data['cancellationReason'] as String?,
      createdAt: data['createdAt'] as String?,
      updatedAt: data['updatedAt'] as String?,
    );
  }
}
