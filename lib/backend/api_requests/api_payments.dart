import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_helpers.dart';

/// Start DOVIA API - Payments & Subscriptions Context Group Code
///
/// Cubre checkouts de Recurrente (suscripcion y pagos custom de Dovia Home),
/// estado/listado de pagos, reanudacion de checkouts, metodo de pago,
/// planes y gestion de suscripciones (cliente y admin).
///
/// Los endpoints de webhooks (`/webhooks/recurrente`, `/webhooks/success`,
/// `/webhooks/cancel`, `/webhooks/recurrente/signature`) no se incluyen: son
/// server-to-server / URLs de redireccion de Recurrente y no los invoca la app.

class DOVIAAPIPaymentContextGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};

  // Checkouts & pagos (CLIENT)
  static CreateSubscriptionCheckoutCall createSubscriptionCheckoutCall =
      CreateSubscriptionCheckoutCall();
  static CreateCustomCheckoutCall createCustomCheckoutCall =
      CreateCustomCheckoutCall();
  static ListPaymentsCall listPaymentsCall = ListPaymentsCall();
  static GetPaymentStatusCall getPaymentStatusCall = GetPaymentStatusCall();
  static ResumePaymentCheckoutCall resumePaymentCheckoutCall =
      ResumePaymentCheckoutCall();

  // Suscripciones (CLIENT)
  static CreateSetupCheckoutCall createSetupCheckoutCall =
      CreateSetupCheckoutCall();
  static ListSubscriptionPlansCall listSubscriptionPlansCall =
      ListSubscriptionPlansCall();
  static GetCurrentSubscriptionCall getCurrentSubscriptionCall =
      GetCurrentSubscriptionCall();
  static CancelCurrentSubscriptionCall cancelCurrentSubscriptionCall =
      CancelCurrentSubscriptionCall();

  // Admin (HQ_ADMIN)
  static AdminListActiveSubscriptionsCall adminListActiveSubscriptionsCall =
      AdminListActiveSubscriptionsCall();
  static AdminCreateSubscriptionPlanCall adminCreateSubscriptionPlanCall =
      AdminCreateSubscriptionPlanCall();
  static AdminUpdateSubscriptionPlanCall adminUpdateSubscriptionPlanCall =
      AdminUpdateSubscriptionPlanCall();
  static AdminDeleteSubscriptionPlanCall adminDeleteSubscriptionPlanCall =
      AdminDeleteSubscriptionPlanCall();
}

// ---------------------------------------------------------------------------
// POST /payments/subscription-checkout
// ---------------------------------------------------------------------------

class CreateSubscriptionCheckoutCall {
  Future<ApiCallResponse> call({
    String? planId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "planId": "${escapeStringForJson(planId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Subscription Checkout',
      apiUrl: '$baseUrl/payments/subscription-checkout',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? checkoutUrl(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.checkoutUrl''') ??
            getJsonField(response, r'''$.checkoutUrl'''),
      );
  String? orderId(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /payments/custom-checkout
// ---------------------------------------------------------------------------

class CreateCustomCheckoutCall {
  Future<ApiCallResponse> call({
    String? paymentType = '',
    num? amount,
    String? currency = 'GTQ',
    String? serviceId = '',
    String? description,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "paymentType": "${escapeStringForJson(paymentType)}",
  "amount": $amount,
  "currency": "${escapeStringForJson(currency)}",
  "serviceId": "${escapeStringForJson(serviceId)}"${description != null ? ',\n  "description": "${escapeStringForJson(description)}"' : ''}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Custom Checkout',
      apiUrl: '$baseUrl/payments/custom-checkout',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? checkoutUrl(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.checkoutUrl''') ??
            getJsonField(response, r'''$.checkoutUrl'''),
      );
  String? orderId(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// GET /payments
// ---------------------------------------------------------------------------

class ListPaymentsCall {
  Future<ApiCallResponse> call({
    int? page,
    int? limit,
    String? status,
    String? paymentType,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Payments',
      apiUrl: '$baseUrl/payments',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (paymentType != null && paymentType.isNotEmpty)
          'paymentType': paymentType,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? paymentsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /payments/status
// ---------------------------------------------------------------------------

class GetPaymentStatusCall {
  Future<ApiCallResponse> call({
    String? paymentOrderId,
    String? checkoutId,
    String? serviceId,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Payment Status',
      apiUrl: '$baseUrl/payments/status',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {
        if (paymentOrderId != null && paymentOrderId.isNotEmpty)
          'paymentOrderId': paymentOrderId,
        if (checkoutId != null && checkoutId.isNotEmpty) 'checkoutId': checkoutId,
        if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? status(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.status''') ??
            getJsonField(response, r'''$.status'''),
      );
}

// ---------------------------------------------------------------------------
// POST /payments/{paymentOrderId}/resume
// ---------------------------------------------------------------------------

class ResumePaymentCheckoutCall {
  Future<ApiCallResponse> call({
    String? paymentOrderId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Resume Payment Checkout',
      apiUrl: '$baseUrl/payments/$paymentOrderId/resume',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? checkoutUrl(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.checkoutUrl''') ??
            getJsonField(response, r'''$.checkoutUrl'''),
      );
  String? orderId(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /subscriptions/payment-method/setup-checkout
// ---------------------------------------------------------------------------

class CreateSetupCheckoutCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Create Setup Checkout',
      apiUrl: '$baseUrl/subscriptions/payment-method/setup-checkout',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? checkoutUrl(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.checkoutUrl''') ??
            getJsonField(response, r'''$.checkoutUrl'''),
      );
}

// ---------------------------------------------------------------------------
// GET /subscriptions/plans
// ---------------------------------------------------------------------------

class ListSubscriptionPlansCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Subscription Plans',
      apiUrl: '$baseUrl/subscriptions/plans',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? plansList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /subscriptions/current
// ---------------------------------------------------------------------------

class GetCurrentSubscriptionCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Current Subscription',
      apiUrl: '$baseUrl/subscriptions/current',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? status(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.status''') ??
            getJsonField(response, r'''$.status'''),
      );
}

// ---------------------------------------------------------------------------
// DELETE /subscriptions/current
// ---------------------------------------------------------------------------

class CancelCurrentSubscriptionCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Cancel Current Subscription',
      apiUrl: '$baseUrl/subscriptions/current',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ---------------------------------------------------------------------------
// GET /admin/subscriptions
// ---------------------------------------------------------------------------

class AdminListActiveSubscriptionsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Admin List Active Subscriptions',
      apiUrl: '$baseUrl/admin/subscriptions',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? subscriptionsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// POST /admin/subscription-plans
// ---------------------------------------------------------------------------

class AdminCreateSubscriptionPlanCall {
  Future<ApiCallResponse> call({
    String? code = '',
    String? name = '',
    String? description,
    num? amount,
    String? currency = 'GTQ',
    String? interval = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "code": "${escapeStringForJson(code)}",
  "name": "${escapeStringForJson(name)}",${description != null ? '\n  "description": "${escapeStringForJson(description)}",' : ''}
  "amount": $amount,
  "currency": "${escapeStringForJson(currency)}",
  "interval": "${escapeStringForJson(interval)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Admin Create Subscription Plan',
      apiUrl: '$baseUrl/admin/subscription-plans',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ---------------------------------------------------------------------------
// PATCH /admin/subscription-plans/{id}
// ---------------------------------------------------------------------------

class AdminUpdateSubscriptionPlanCall {
  Future<ApiCallResponse> call({
    String? planId = '',
    String? code,
    String? name,
    String? description,
    num? amount,
    String? currency,
    String? interval,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  ${code != null ? '"code": "${escapeStringForJson(code)}",' : ''}
  ${name != null ? '"name": "${escapeStringForJson(name)}",' : ''}
  ${description != null ? '"description": "${escapeStringForJson(description)}",' : ''}
  ${amount != null ? '"amount": $amount,' : ''}
  ${currency != null ? '"currency": "${escapeStringForJson(currency)}",' : ''}
  ${interval != null ? '"interval": "${escapeStringForJson(interval)}",' : ''}
  "_placeholder": null
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Admin Update Subscription Plan',
      apiUrl: '$baseUrl/admin/subscription-plans/$planId',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ---------------------------------------------------------------------------
// DELETE /admin/subscription-plans/{id}
// ---------------------------------------------------------------------------

class AdminDeleteSubscriptionPlanCall {
  Future<ApiCallResponse> call({
    String? planId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPaymentContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Admin Delete Subscription Plan',
      apiUrl: '$baseUrl/admin/subscription-plans/$planId',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End DOVIA API - Payments & Subscriptions Context Group Code
