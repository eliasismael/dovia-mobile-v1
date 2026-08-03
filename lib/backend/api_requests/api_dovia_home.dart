import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_config.dart';

/// Start DOVIA API - Dovia Home Context Group Code
///
/// Cubre los 57 endpoints del contexto Dovia Home, distribuidos en 6
/// controllers:
///   - Address (6): zonas trabajables + CRUD de direcciones de servicio.
///   - Service Request (17): catalogo, creacion SERVICE/EMERGENCY, listados,
///     imagenes, pago fake, marketplace de associate y ciclo de trabajo.
///   - Extra Materials (7): solicitud/cotizacion/aceptacion de materiales extra.
///   - Quote (11): flujo de cotizaciones centrado en ServiceRequest (cliente y
///     empresa).
///   - Out Of Scope (14): trabajo fuera de alcance ligado a la raiz.
///   - Proposal (2): listados unificados de propuestas QUOTE + OUT_OF_SCOPE.
///
/// Todos los endpoints requieren Bearer token. El userId se resuelve del claim
/// `custom:id` del JWT en el backend. `page`/`limit` viajan como query params.

class DOVIAAPIDoviaHomeContextGroup {
  static String getBaseUrl() => kApiBaseUrl;
  static Map<String, String> headers = {};

  // --- Address controller (6) ---
  static ListWorkableZonesCall listWorkableZonesCall = ListWorkableZonesCall();
  static CreateServiceAddressCall createServiceAddressCall =
      CreateServiceAddressCall();
  static ListServiceAddressesCall listServiceAddressesCall =
      ListServiceAddressesCall();
  static GetServiceAddressCall getServiceAddressCall = GetServiceAddressCall();
  static UpdateServiceAddressCall updateServiceAddressCall =
      UpdateServiceAddressCall();
  static DeleteServiceAddressCall deleteServiceAddressCall =
      DeleteServiceAddressCall();

  // --- Service Request controller (17) ---
  static ListCatalogServicesCall listCatalogServicesCall =
      ListCatalogServicesCall();
  static CreateServiceRequestCall createServiceRequestCall =
      CreateServiceRequestCall();
  static CreateEmergencyServiceRequestCall createEmergencyServiceRequestCall =
      CreateEmergencyServiceRequestCall();
  static ListServiceRequestsCall listServiceRequestsCall =
      ListServiceRequestsCall();
  static GetServiceRequestCall getServiceRequestCall = GetServiceRequestCall();
  static PresignServiceRequestImagesCall presignServiceRequestImagesCall =
      PresignServiceRequestImagesCall();
  static ConfirmServiceRequestImagesCall confirmServiceRequestImagesCall =
      ConfirmServiceRequestImagesCall();
  static ConfirmServiceRequestPaymentCall confirmServiceRequestPaymentCall =
      ConfirmServiceRequestPaymentCall();
  static ListAssociateServiceRequestsCall listAssociateServiceRequestsCall =
      ListAssociateServiceRequestsCall();
  static ListAvailableAssociateServiceRequestsCall
      listAvailableAssociateServiceRequestsCall =
      ListAvailableAssociateServiceRequestsCall();
  static GetAssociateServiceRequestCall getAssociateServiceRequestCall =
      GetAssociateServiceRequestCall();
  static TakeServiceRequestCall takeServiceRequestCall =
      TakeServiceRequestCall();
  static StartServiceRequestCall startServiceRequestCall =
      StartServiceRequestCall();
  static PresignCompletionImagesCall presignCompletionImagesCall =
      PresignCompletionImagesCall();
  static ConfirmCompletionImagesCall confirmCompletionImagesCall =
      ConfirmCompletionImagesCall();
  static FinishServiceRequestCall finishServiceRequestCall =
      FinishServiceRequestCall();
  static RefundPaymentOrderTestingCall refundPaymentOrderTestingCall =
      RefundPaymentOrderTestingCall();

  // --- Extra Materials controller (7) ---
  static RequestExtraMaterialsCall requestExtraMaterialsCall =
      RequestExtraMaterialsCall();
  static PresignExtraMaterialsImagesCall presignExtraMaterialsImagesCall =
      PresignExtraMaterialsImagesCall();
  static ConfirmExtraMaterialsImagesCall confirmExtraMaterialsImagesCall =
      ConfirmExtraMaterialsImagesCall();
  static AdminListExtraMaterialsCall adminListExtraMaterialsCall =
      AdminListExtraMaterialsCall();
  static AdminQuoteExtraMaterialsCall adminQuoteExtraMaterialsCall =
      AdminQuoteExtraMaterialsCall();
  static AcceptExtraMaterialsCall acceptExtraMaterialsCall =
      AcceptExtraMaterialsCall();
  static RejectExtraMaterialsCall rejectExtraMaterialsCall =
      RejectExtraMaterialsCall();

  // --- Quote controller (11) ---
  static CreateQuoteServiceRequestCall createQuoteServiceRequestCall =
      CreateQuoteServiceRequestCall();
  static ListQuoteProposalsCall listQuoteProposalsCall =
      ListQuoteProposalsCall();
  static GetQuoteProposalCall getQuoteProposalCall = GetQuoteProposalCall();
  static RejectQuoteProposalCall rejectQuoteProposalCall =
      RejectQuoteProposalCall();
  static AcceptQuoteProposalCall acceptQuoteProposalCall =
      AcceptQuoteProposalCall();
  static CloseQuoteCall closeQuoteCall = CloseQuoteCall();
  static ListCompanyQuoteServiceRequestsCall
      listCompanyQuoteServiceRequestsCall =
      ListCompanyQuoteServiceRequestsCall();
  static GetCompanyQuoteServiceRequestCall getCompanyQuoteServiceRequestCall =
      GetCompanyQuoteServiceRequestCall();
  static SubmitCompanyQuoteProposalCall submitCompanyQuoteProposalCall =
      SubmitCompanyQuoteProposalCall();
  static ListCompanyOwnQuoteProposalsCall listCompanyOwnQuoteProposalsCall =
      ListCompanyOwnQuoteProposalsCall();
  static GetCompanyQuoteProposalCall getCompanyQuoteProposalCall =
      GetCompanyQuoteProposalCall();

  // --- Out Of Scope controller (14) ---
  static CreateOutOfScopeRequestCall createOutOfScopeRequestCall =
      CreateOutOfScopeRequestCall();
  static PresignOutOfScopeImagesCall presignOutOfScopeImagesCall =
      PresignOutOfScopeImagesCall();
  static ConfirmOutOfScopeImagesCall confirmOutOfScopeImagesCall =
      ConfirmOutOfScopeImagesCall();
  static GetOutOfScopeRequestCall getOutOfScopeRequestCall =
      GetOutOfScopeRequestCall();
  static AuthorizeOutOfScopeRequestCall authorizeOutOfScopeRequestCall =
      AuthorizeOutOfScopeRequestCall();
  static CloseOutOfScopeRequestCall closeOutOfScopeRequestCall =
      CloseOutOfScopeRequestCall();
  static ListAssociateOutOfScopeRequestsCall
      listAssociateOutOfScopeRequestsCall =
      ListAssociateOutOfScopeRequestsCall();
  static GetAssociateOutOfScopeRequestCall getAssociateOutOfScopeRequestCall =
      GetAssociateOutOfScopeRequestCall();
  static SubmitOutOfScopeProposalCall submitOutOfScopeProposalCall =
      SubmitOutOfScopeProposalCall();
  static GetAssociateOutOfScopeProposalCall getAssociateOutOfScopeProposalCall =
      GetAssociateOutOfScopeProposalCall();
  static ListClientOutOfScopeProposalsCall listClientOutOfScopeProposalsCall =
      ListClientOutOfScopeProposalsCall();
  static GetOutOfScopeProposalCall getOutOfScopeProposalCall =
      GetOutOfScopeProposalCall();
  static RejectOutOfScopeProposalCall rejectOutOfScopeProposalCall =
      RejectOutOfScopeProposalCall();
  static AcceptOutOfScopeProposalCall acceptOutOfScopeProposalCall =
      AcceptOutOfScopeProposalCall();

  // --- Proposal controller (2) ---
  static ListClientProposalsCall listClientProposalsCall =
      ListClientProposalsCall();
  static ListAssociateProposalsCall listAssociateProposalsCall =
      ListAssociateProposalsCall();
}

// ===========================================================================
// Address controller (6)
// ===========================================================================

// ---------------------------------------------------------------------------
// GET /dovia-home/workable-zones
// Permiso: DOVIA_HOME_CATALOG_READ. Sin body ni query.
// ---------------------------------------------------------------------------

class ListWorkableZonesCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Workable Zones',
      apiUrl: '$baseUrl/dovia-home/workable-zones',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? zonesList(dynamic response) =>
      (getJsonField(response, r'''$.data''', true) ??
          getJsonField(response, r'''$''', true)) as List?;
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-addresses
// Permiso: DOVIA_HOME_ADDRESS_CREATE.
// Body: { address, coordinates:{latitude,longitude}, zone, accessInstructions? }
// ---------------------------------------------------------------------------

class CreateServiceAddressCall {
  Future<ApiCallResponse> call({
    String? address = '',
    double? latitude,
    double? longitude,
    String? zone = '',
    String? accessInstructions,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'address': address,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'zone': zone,
      'accessInstructions': accessInstructions,
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Create Service Address',
      apiUrl: '$baseUrl/dovia-home/service-addresses',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// GET /dovia-home/service-addresses
// Permiso: DOVIA_HOME_ADDRESS_READ. Sin body.
// ---------------------------------------------------------------------------

class ListServiceAddressesCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Service Addresses',
      apiUrl: '$baseUrl/dovia-home/service-addresses',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? addressesList(dynamic response) =>
      (getJsonField(response, r'''$.data''', true) ??
          getJsonField(response, r'''$''', true)) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/service-addresses/{addressId}
// Permiso: DOVIA_HOME_ADDRESS_READ. Path: addressId.
// ---------------------------------------------------------------------------

class GetServiceAddressCall {
  Future<ApiCallResponse> call({
    String? addressId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Service Address',
      apiUrl: '$baseUrl/dovia-home/service-addresses/$addressId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// PATCH /dovia-home/service-addresses/{addressId}
// Permiso: DOVIA_HOME_ADDRESS_UPDATE. Update parcial: al menos un campo.
// Enviar coordinates requiere latitude y longitude juntos.
// ---------------------------------------------------------------------------

class UpdateServiceAddressCall {
  Future<ApiCallResponse> call({
    String? addressId = '',
    String? address,
    double? latitude,
    double? longitude,
    String? zone,
    String? accessInstructions,
    bool includeAccessInstructions = false,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{};
    if (address != null) payload['address'] = address;
    if (latitude != null && longitude != null) {
      payload['coordinates'] = {
        'latitude': latitude,
        'longitude': longitude,
      };
    }
    if (zone != null) payload['zone'] = zone;
    // accessInstructions puede setearse a null explicitamente: usa el flag.
    if (includeAccessInstructions || accessInstructions != null) {
      payload['accessInstructions'] = accessInstructions;
    }
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Update Service Address',
      apiUrl: '$baseUrl/dovia-home/service-addresses/$addressId',
      callType: ApiCallType.PATCH,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// DELETE /dovia-home/service-addresses/{addressId}
// Permiso: DOVIA_HOME_ADDRESS_DELETE. Soft delete. Respuesta: {deleted,addressId}
// ---------------------------------------------------------------------------

class DeleteServiceAddressCall {
  Future<ApiCallResponse> call({
    String? addressId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Service Address',
      apiUrl: '$baseUrl/dovia-home/service-addresses/$addressId',
      callType: ApiCallType.DELETE,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  bool? deleted(dynamic response) => castToType<bool>(
        getJsonField(response, r'''$.data.deleted''') ??
            getJsonField(response, r'''$.deleted'''),
      );
}

// ===========================================================================
// Service Request controller (17)
// ===========================================================================

// ---------------------------------------------------------------------------
// GET /dovia-home/catalog/services
// Permiso: DOVIA_HOME_CATALOG_READ. Sin body.
// ---------------------------------------------------------------------------

class ListCatalogServicesCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Catalog Services',
      apiUrl: '$baseUrl/dovia-home/catalog/services',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? servicesList(dynamic response) =>
      (getJsonField(response, r'''$.data''', true) ??
          getJsonField(response, r'''$''', true)) as List?;
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests
// Permiso: DOVIA_HOME_SERVICE_CREATE.
// Body: { serviceId, description, scheduledAt, addressId } (strings no vacios).
// ---------------------------------------------------------------------------

class CreateServiceRequestCall {
  Future<ApiCallResponse> call({
    String? serviceId = '',
    String? description = '',
    String? scheduledAt = '',
    String? addressId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'serviceId': serviceId,
      'description': description,
      'scheduledAt': scheduledAt,
      'addressId': addressId,
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Create Service Request',
      apiUrl: '$baseUrl/dovia-home/service-requests',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests/emergencies
// Permiso: DOVIA_HOME_SERVICE_CREATE.
// Body: { description, addressId } SOLAMENTE (campos extra son rechazados).
// ---------------------------------------------------------------------------

class CreateEmergencyServiceRequestCall {
  Future<ApiCallResponse> call({
    String? description = '',
    String? addressId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'description': description,
      'addressId': addressId,
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Create Emergency Service Request',
      apiUrl: '$baseUrl/dovia-home/service-requests/emergencies',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// GET /dovia-home/service-requests
// Permiso: DOVIA_HOME_SERVICE_READ_OWN.
// Query: status?, requestType?, subStatus?, scheduledFrom?, scheduledTo?,
//        page?, limit?.
// ---------------------------------------------------------------------------

class ListServiceRequestsCall {
  Future<ApiCallResponse> call({
    String? status,
    String? requestType,
    String? subStatus,
    String? scheduledFrom,
    String? scheduledTo,
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Service Requests',
      apiUrl: '$baseUrl/dovia-home/service-requests',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (requestType != null && requestType.isNotEmpty)
          'requestType': requestType,
        if (subStatus != null && subStatus.isNotEmpty) 'subStatus': subStatus,
        if (scheduledFrom != null && scheduledFrom.isNotEmpty)
          'scheduledFrom': scheduledFrom,
        if (scheduledTo != null && scheduledTo.isNotEmpty)
          'scheduledTo': scheduledTo,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? requestsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/service-requests/{serviceRequestId}
// Permiso: DOVIA_HOME_SERVICE_READ_OWN. Path: serviceRequestId.
// ---------------------------------------------------------------------------

class GetServiceRequestCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Service Request',
      apiUrl: '$baseUrl/dovia-home/service-requests/$serviceRequestId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests/{serviceRequestId}/images/presign
// Permiso: DOVIA_HOME_SERVICE_IMAGE_UPLOAD.
// Body: { uploads: [{clientUploadId?, fileName, mimeType, sizeBytes}] }.
// ---------------------------------------------------------------------------

class PresignServiceRequestImagesCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    List<dynamic>? uploads,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'uploads': uploads ?? [],
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Presign Service Request Images',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/images/presign',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? items(dynamic response) =>
      (getJsonField(response, r'''$.data.items''', true) ??
          getJsonField(response, r'''$.items''', true)) as List?;
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests/{serviceRequestId}/images/confirm
// Permiso: DOVIA_HOME_SERVICE_IMAGE_UPLOAD. Body: { storageKeys: [...] }.
// ---------------------------------------------------------------------------

class ConfirmServiceRequestImagesCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    List<String>? storageKeys,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'storageKeys': storageKeys ?? [],
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Confirm Service Request Images',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/images/confirm',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? imageUrls(dynamic response) =>
      (getJsonField(response, r'''$.data.imageUrls''', true) ??
          getJsonField(response, r'''$.imageUrls''', true)) as List?;
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests/{serviceRequestId}/payment/confirm
// Permiso: DOVIA_HOME_SERVICE_PAYMENT_CONFIRM. Body: { currency: GTQ|USD }.
// ---------------------------------------------------------------------------

class ConfirmServiceRequestPaymentCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? currency = 'GTQ',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'currency': currency,
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Confirm Service Request Payment',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/payment/confirm',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// GET /dovia-home/associate/service-requests
// Permiso: DOVIA_HOME_MARKETPLACE_READ. Solicitudes asignadas al associate.
// Query: status?, subStatus?, requestType?, page?, limit?.
// ---------------------------------------------------------------------------

class ListAssociateServiceRequestsCall {
  Future<ApiCallResponse> call({
    String? status,
    String? subStatus,
    String? requestType,
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Associate Service Requests',
      apiUrl: '$baseUrl/dovia-home/associate/service-requests',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (subStatus != null && subStatus.isNotEmpty) 'subStatus': subStatus,
        if (requestType != null && requestType.isNotEmpty)
          'requestType': requestType,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? requestsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/associate/service-requests/available
// Permiso: DOVIA_HOME_MARKETPLACE_READ. Marketplace SERVICE/EMERGENCY pagadas.
// Query: requestType? (SERVICE|EMERGENCY), status?, page?, limit?.
// ---------------------------------------------------------------------------

class ListAvailableAssociateServiceRequestsCall {
  Future<ApiCallResponse> call({
    String? requestType,
    String? status,
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Available Associate Service Requests',
      apiUrl: '$baseUrl/dovia-home/associate/service-requests/available',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (requestType != null && requestType.isNotEmpty)
          'requestType': requestType,
        if (status != null && status.isNotEmpty) 'status': status,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? requestsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/associate/service-requests/{serviceRequestId}
// Permiso: DOVIA_HOME_MARKETPLACE_READ. Path: serviceRequestId.
// ---------------------------------------------------------------------------

class GetAssociateServiceRequestCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Associate Service Request',
      apiUrl:
          '$baseUrl/dovia-home/associate/service-requests/$serviceRequestId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/service-requests/{serviceRequestId}/take
// Permiso: DOVIA_HOME_SERVICE_TAKE. Sin body. Toma atomica.
// ---------------------------------------------------------------------------

class TakeServiceRequestCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Take Service Request',
      apiUrl:
          '$baseUrl/dovia-home/associate/service-requests/$serviceRequestId/take',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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
}

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/service-requests/{serviceRequestId}/start
// Permiso: DOVIA_HOME_SERVICE_START. Body: { coordinates? } (null si no viene).
// ---------------------------------------------------------------------------

class StartServiceRequestCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    double? latitude,
    double? longitude,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'coordinates': (latitude != null && longitude != null)
          ? {'latitude': latitude, 'longitude': longitude}
          : null,
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Start Service Request',
      apiUrl:
          '$baseUrl/dovia-home/associate/service-requests/$serviceRequestId/start',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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
// POST /dovia-home/associate/service-requests/{serviceRequestId}/completion-images/presign
// Permiso: DOVIA_HOME_SERVICE_COMPLETION_IMAGE_UPLOAD.
// Body: { category: WORK|LEFTOVER_MATERIALS, uploads: [...] }.
// ---------------------------------------------------------------------------

class PresignCompletionImagesCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? category = 'WORK',
    List<dynamic>? uploads,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'category': category,
      'uploads': uploads ?? [],
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Presign Completion Images',
      apiUrl:
          '$baseUrl/dovia-home/associate/service-requests/$serviceRequestId/completion-images/presign',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? items(dynamic response) =>
      (getJsonField(response, r'''$.data.items''', true) ??
          getJsonField(response, r'''$.items''', true)) as List?;
}

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/service-requests/{serviceRequestId}/completion-images/confirm
// Permiso: DOVIA_HOME_SERVICE_COMPLETION_IMAGE_UPLOAD.
// Body: { category: WORK|LEFTOVER_MATERIALS, storageKeys: [...] }.
// ---------------------------------------------------------------------------

class ConfirmCompletionImagesCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? category = 'WORK',
    List<String>? storageKeys,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'category': category,
      'storageKeys': storageKeys ?? [],
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Confirm Completion Images',
      apiUrl:
          '$baseUrl/dovia-home/associate/service-requests/$serviceRequestId/completion-images/confirm',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? imageUrls(dynamic response) =>
      (getJsonField(response, r'''$.data.imageUrls''', true) ??
          getJsonField(response, r'''$.imageUrls''', true)) as List?;
}

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/service-requests/{serviceRequestId}/finish
// Permiso: DOVIA_HOME_SERVICE_FINISH.
// Body: { completionDescription, clientRecommendations? }.
// ---------------------------------------------------------------------------

class FinishServiceRequestCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? completionDescription = '',
    String? clientRecommendations,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'completionDescription': completionDescription,
      'clientRecommendations': clientRecommendations,
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Finish Service Request',
      apiUrl:
          '$baseUrl/dovia-home/associate/service-requests/$serviceRequestId/finish',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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
// POST /dovia-home/testing/payment-orders/{paymentOrderId}/refund
// Permiso: DOVIA_HOME_SERVICE_READ_OWN. Sin body.
// TEMPORARY - remove after Recurrente webhook E2E testing.
// ---------------------------------------------------------------------------

class RefundPaymentOrderTestingCall {
  Future<ApiCallResponse> call({
    String? paymentOrderId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Refund Payment Order (Testing)',
      apiUrl:
          '$baseUrl/dovia-home/testing/payment-orders/$paymentOrderId/refund',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? refundId(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.refundId''') ??
            getJsonField(response, r'''$.refundId'''),
      );
  String? status(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.status''') ??
            getJsonField(response, r'''$.status'''),
      );
}

// ===========================================================================
// Extra Materials controller (7)
// ===========================================================================

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/service-requests/{serviceRequestId}/extra-materials
// Permiso: DOVIA_HOME_EXTRA_MATERIALS_REQUEST. Associate asignado.
// Body: { requestedMaterials }.
// ---------------------------------------------------------------------------

class RequestExtraMaterialsCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? requestedMaterials = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'requestedMaterials': requestedMaterials,
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Request Extra Materials',
      apiUrl:
          '$baseUrl/dovia-home/associate/service-requests/$serviceRequestId/extra-materials',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/service-requests/{serviceRequestId}/extra-materials/{extraMaterialsRequestId}/images/presign
// Permiso: DOVIA_HOME_EXTRA_MATERIALS_IMAGE_UPLOAD. Body: { uploads: [...] }.
// ---------------------------------------------------------------------------

class PresignExtraMaterialsImagesCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? extraMaterialsRequestId = '',
    List<dynamic>? uploads,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'uploads': uploads ?? [],
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Presign Extra Materials Images',
      apiUrl:
          '$baseUrl/dovia-home/associate/service-requests/$serviceRequestId/extra-materials/$extraMaterialsRequestId/images/presign',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? items(dynamic response) =>
      (getJsonField(response, r'''$.data.items''', true) ??
          getJsonField(response, r'''$.items''', true)) as List?;
}

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/service-requests/{serviceRequestId}/extra-materials/{extraMaterialsRequestId}/images/confirm
// Permiso: DOVIA_HOME_EXTRA_MATERIALS_IMAGE_UPLOAD. Body: { storageKeys: [...] }.
// ---------------------------------------------------------------------------

class ConfirmExtraMaterialsImagesCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? extraMaterialsRequestId = '',
    List<String>? storageKeys,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'storageKeys': storageKeys ?? [],
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Confirm Extra Materials Images',
      apiUrl:
          '$baseUrl/dovia-home/associate/service-requests/$serviceRequestId/extra-materials/$extraMaterialsRequestId/images/confirm',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? imageUrls(dynamic response) =>
      (getJsonField(response, r'''$.data.imageUrls''', true) ??
          getJsonField(response, r'''$.imageUrls''', true)) as List?;
}

// ---------------------------------------------------------------------------
// GET /admin/dovia-home/extra-materials
// Permiso: DOVIA_HOME_EXTRA_MATERIALS_ADMIN_READ (HQ_ADMIN).
// Query: subStatus?, materialsStatus?, page?, limit?.
// ---------------------------------------------------------------------------

class AdminListExtraMaterialsCall {
  Future<ApiCallResponse> call({
    String? subStatus,
    String? materialsStatus,
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Admin List Extra Materials',
      apiUrl: '$baseUrl/admin/dovia-home/extra-materials',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (subStatus != null && subStatus.isNotEmpty) 'subStatus': subStatus,
        if (materialsStatus != null && materialsStatus.isNotEmpty)
          'materialsStatus': materialsStatus,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? itemsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// POST /admin/dovia-home/service-requests/{serviceRequestId}/extra-materials/{extraMaterialsRequestId}/quote
// Permiso: DOVIA_HOME_EXTRA_MATERIALS_ADMIN_QUOTE (HQ_ADMIN).
// Multipart: file (PDF), details, totalAmount (GTQ).
// ---------------------------------------------------------------------------

class AdminQuoteExtraMaterialsCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? extraMaterialsRequestId = '',
    FFUploadedFile? file,
    String? details = '',
    num? totalAmount,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Admin Quote Extra Materials',
      apiUrl:
          '$baseUrl/admin/dovia-home/service-requests/$serviceRequestId/extra-materials/$extraMaterialsRequestId/quote',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (file != null) 'file': file,
        if (details != null) 'details': details,
        if (totalAmount != null) 'totalAmount': totalAmount,
      },
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests/{serviceRequestId}/extra-materials/accept
// Permiso: DOVIA_HOME_EXTRA_MATERIALS_ACCEPT (CLIENT). Sin body.
// Opera sobre la ultima solicitud activa. Devuelve PaymentOrderResponseDto.
// ---------------------------------------------------------------------------

class AcceptExtraMaterialsCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Accept Extra Materials',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/extra-materials/accept',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? paymentOrderId(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
  String? checkoutUrl(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.checkoutUrl''') ??
            getJsonField(response, r'''$.checkoutUrl'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests/{serviceRequestId}/extra-materials/reject
// Permiso: DOVIA_HOME_EXTRA_MATERIALS_REJECT (CLIENT). Body opcional: { reason? }.
// ---------------------------------------------------------------------------

class RejectExtraMaterialsCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? reason,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{};
    if (reason != null) payload['reason'] = reason;
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Reject Extra Materials',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/extra-materials/reject',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ===========================================================================
// Quote controller (11)
// ===========================================================================

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests/quotes
// Permiso: CLIENT + DOVIA_HOME_SERVICE_CREATE (suscrito).
// Body: { description, addressId }.
// ---------------------------------------------------------------------------

class CreateQuoteServiceRequestCall {
  Future<ApiCallResponse> call({
    String? description = '',
    String? addressId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'description': description,
      'addressId': addressId,
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Create Quote Service Request',
      apiUrl: '$baseUrl/dovia-home/service-requests/quotes',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// GET /dovia-home/service-requests/{serviceRequestId}/quote-proposals
// Permiso: CLIENT + DOVIA_HOME_QUOTE_PROPOSAL_READ_RECEIVED. Query: page?, limit?.
// ---------------------------------------------------------------------------

class ListQuoteProposalsCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Quote Proposals',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/quote-proposals',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? proposalsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/service-requests/{serviceRequestId}/quote-proposals/{proposalId}
// Permiso: CLIENT + DOVIA_HOME_QUOTE_PROPOSAL_READ_RECEIVED.
// ---------------------------------------------------------------------------

class GetQuoteProposalCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? proposalId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Quote Proposal',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/quote-proposals/$proposalId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests/{serviceRequestId}/quote-proposals/{proposalId}/reject
// Permiso: CLIENT + DOVIA_HOME_QUOTE_PROPOSAL_REJECT. Sin body.
// ---------------------------------------------------------------------------

class RejectQuoteProposalCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? proposalId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Reject Quote Proposal',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/quote-proposals/$proposalId/reject',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests/{serviceRequestId}/quote-proposals/{proposalId}/accept
// Permiso: CLIENT + DOVIA_HOME_QUOTE_PROPOSAL_ACCEPT. Sin body. No cobra plataforma.
// ---------------------------------------------------------------------------

class AcceptQuoteProposalCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? proposalId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Accept Quote Proposal',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/quote-proposals/$proposalId/accept',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? serviceRequestId(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.serviceRequestId''') ??
            getJsonField(response, r'''$.serviceRequestId'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/service-requests/{serviceRequestId}/quote/close
// Permiso: CLIENT + DOVIA_HOME_QUOTE_CLOSE. Sin body. Solo PENDING/QUOTE_QUOTING.
// ---------------------------------------------------------------------------

class CloseQuoteCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Close Quote',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/quote/close',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? status(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.status''') ??
            getJsonField(response, r'''$.status'''),
      );
}

// ---------------------------------------------------------------------------
// GET /dovia-home/company/service-requests
// Permiso: HOME_ASSOCIATE_COMPANY + DOVIA_HOME_QUOTE_MARKETPLACE_READ.
// Query: requestType?, status?, subStatus?, page?, limit?.
// ---------------------------------------------------------------------------

class ListCompanyQuoteServiceRequestsCall {
  Future<ApiCallResponse> call({
    String? requestType,
    String? status,
    String? subStatus,
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Company Quote Service Requests',
      apiUrl: '$baseUrl/dovia-home/company/service-requests',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (requestType != null && requestType.isNotEmpty)
          'requestType': requestType,
        if (status != null && status.isNotEmpty) 'status': status,
        if (subStatus != null && subStatus.isNotEmpty) 'subStatus': subStatus,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? requestsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/company/service-requests/{serviceRequestId}
// Permiso: HOME_ASSOCIATE_COMPANY + DOVIA_HOME_QUOTE_MARKETPLACE_READ.
// ---------------------------------------------------------------------------

class GetCompanyQuoteServiceRequestCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Company Quote Service Request',
      apiUrl: '$baseUrl/dovia-home/company/service-requests/$serviceRequestId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/company/service-requests/{serviceRequestId}/quote-proposals
// Permiso: HOME_ASSOCIATE_COMPANY + DOVIA_HOME_QUOTE_PROPOSAL_SUBMIT.
// Multipart: file (PDF), totalAmount (GTQ).
// ---------------------------------------------------------------------------

class SubmitCompanyQuoteProposalCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    FFUploadedFile? file,
    num? totalAmount,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Submit Company Quote Proposal',
      apiUrl:
          '$baseUrl/dovia-home/company/service-requests/$serviceRequestId/quote-proposals',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (file != null) 'file': file,
        if (totalAmount != null) 'totalAmount': totalAmount,
      },
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// GET /dovia-home/company/service-requests/{serviceRequestId}/quote-proposals
// Permiso: HOME_ASSOCIATE_COMPANY + DOVIA_HOME_QUOTE_PROPOSAL_READ_OWN.
// Query: page?, limit?. Historial propio de la empresa para ese servicio.
// ---------------------------------------------------------------------------

class ListCompanyOwnQuoteProposalsCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Company Own Quote Proposals',
      apiUrl:
          '$baseUrl/dovia-home/company/service-requests/$serviceRequestId/quote-proposals',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? proposalsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/company/quote-proposals/{proposalId}
// Permiso: HOME_ASSOCIATE_COMPANY + DOVIA_HOME_QUOTE_PROPOSAL_READ_OWN.
// ---------------------------------------------------------------------------

class GetCompanyQuoteProposalCall {
  Future<ApiCallResponse> call({
    String? proposalId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Company Quote Proposal',
      apiUrl: '$baseUrl/dovia-home/company/quote-proposals/$proposalId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ===========================================================================
// Out Of Scope controller (14)
// ===========================================================================

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/service-requests/{serviceRequestId}/out-of-scope-requests
// Permiso: HOME_ASSOCIATE/HOME_ASSOCIATE_COMPANY + DOVIA_HOME_OUT_OF_SCOPE_REQUEST_CREATE.
// Body: { description, executionMode: REPORTER_CAN_EXECUTE|OTHER_PROVIDER_REQUIRED }.
// ---------------------------------------------------------------------------

class CreateOutOfScopeRequestCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? description = '',
    String? executionMode = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'description': description,
      'executionMode': executionMode,
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Create Out Of Scope Request',
      apiUrl:
          '$baseUrl/dovia-home/associate/service-requests/$serviceRequestId/out-of-scope-requests',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? requestId(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.requestId''') ??
            getJsonField(response, r'''$.requestId'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/out-of-scope-requests/{requestId}/images/presign
// Permiso: associate creador + DOVIA_HOME_OUT_OF_SCOPE_IMAGE_UPLOAD.
// Body: { uploads: [...] }. Solicitud en CLIENT_APPROVAL_PENDING.
// ---------------------------------------------------------------------------

class PresignOutOfScopeImagesCall {
  Future<ApiCallResponse> call({
    String? requestId = '',
    List<dynamic>? uploads,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'uploads': uploads ?? [],
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Presign Out Of Scope Images',
      apiUrl:
          '$baseUrl/dovia-home/associate/out-of-scope-requests/$requestId/images/presign',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? items(dynamic response) =>
      (getJsonField(response, r'''$.data.items''', true) ??
          getJsonField(response, r'''$.items''', true)) as List?;
}

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/out-of-scope-requests/{requestId}/images/confirm
// Permiso: associate creador + DOVIA_HOME_OUT_OF_SCOPE_IMAGE_UPLOAD.
// Body: { storageKeys: [...] }.
// ---------------------------------------------------------------------------

class ConfirmOutOfScopeImagesCall {
  Future<ApiCallResponse> call({
    String? requestId = '',
    List<String>? storageKeys,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    final payload = <String, dynamic>{
      'storageKeys': storageKeys ?? [],
    };
    final ffApiRequestBody = jsonEncode(payload);

    return ApiManager.instance.makeApiCall(
      callName: 'Confirm Out Of Scope Images',
      apiUrl:
          '$baseUrl/dovia-home/associate/out-of-scope-requests/$requestId/images/confirm',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  List? images(dynamic response) =>
      (getJsonField(response, r'''$.data.images''', true) ??
          getJsonField(response, r'''$.images''', true)) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/out-of-scope-requests/{requestId}
// Permiso: CLIENT + DOVIA_HOME_OUT_OF_SCOPE_REQUEST_READ_OWN.
// ---------------------------------------------------------------------------

class GetOutOfScopeRequestCall {
  Future<ApiCallResponse> call({
    String? requestId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Out Of Scope Request',
      apiUrl: '$baseUrl/dovia-home/out-of-scope-requests/$requestId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/out-of-scope-requests/{requestId}/authorize
// Permiso: CLIENT suscrito + DOVIA_HOME_OUT_OF_SCOPE_AUTHORIZE. Sin body.
// Crea el hijo OUT_OF_SCOPE y mueve la solicitud a QUOTING.
// ---------------------------------------------------------------------------

class AuthorizeOutOfScopeRequestCall {
  Future<ApiCallResponse> call({
    String? requestId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Authorize Out Of Scope Request',
      apiUrl:
          '$baseUrl/dovia-home/out-of-scope-requests/$requestId/authorize',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? serviceRequestId(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.serviceRequestId''') ??
            getJsonField(response, r'''$.serviceRequestId'''),
      );
  String? status(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.status''') ??
            getJsonField(response, r'''$.status'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/out-of-scope-requests/{requestId}/close
// Permiso: CLIENT + DOVIA_HOME_OUT_OF_SCOPE_CLOSE. Sin body. Idempotente.
// ---------------------------------------------------------------------------

class CloseOutOfScopeRequestCall {
  Future<ApiCallResponse> call({
    String? requestId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Close Out Of Scope Request',
      apiUrl: '$baseUrl/dovia-home/out-of-scope-requests/$requestId/close',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? status(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.status''') ??
            getJsonField(response, r'''$.status'''),
      );
}

// ---------------------------------------------------------------------------
// GET /dovia-home/associate/out-of-scope-requests
// Permiso: associate verificado + DOVIA_HOME_OUT_OF_SCOPE_MARKETPLACE_READ.
// Query: page?, limit?. Solo lista QUOTING segun executionMode/rol.
// ---------------------------------------------------------------------------

class ListAssociateOutOfScopeRequestsCall {
  Future<ApiCallResponse> call({
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Associate Out Of Scope Requests',
      apiUrl: '$baseUrl/dovia-home/associate/out-of-scope-requests',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? requestsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/associate/out-of-scope-requests/{requestId}
// Permiso: associate verificado + DOVIA_HOME_OUT_OF_SCOPE_MARKETPLACE_READ.
// Respuesta: { request, clientProfile, hasActiveProposal, ownProposal }.
// ---------------------------------------------------------------------------

class GetAssociateOutOfScopeRequestCall {
  Future<ApiCallResponse> call({
    String? requestId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Associate Out Of Scope Request',
      apiUrl:
          '$baseUrl/dovia-home/associate/out-of-scope-requests/$requestId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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
// POST /dovia-home/associate/out-of-scope-requests/{requestId}/proposals
// Permiso: provider elegible + DOVIA_HOME_OUT_OF_SCOPE_PROPOSAL_SUBMIT.
// Multipart: file (PDF), totalAmount (GTQ). Solicitud en QUOTING.
// ---------------------------------------------------------------------------

class SubmitOutOfScopeProposalCall {
  Future<ApiCallResponse> call({
    String? requestId = '',
    FFUploadedFile? file,
    num? totalAmount,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Submit Out Of Scope Proposal',
      apiUrl:
          '$baseUrl/dovia-home/associate/out-of-scope-requests/$requestId/proposals',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (file != null) 'file': file,
        if (totalAmount != null) 'totalAmount': totalAmount,
      },
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// GET /dovia-home/associate/out-of-scope-proposals/{proposalId}
// Permiso: provider dueno + DOVIA_HOME_OUT_OF_SCOPE_PROPOSAL_READ_OWN.
// ---------------------------------------------------------------------------

class GetAssociateOutOfScopeProposalCall {
  Future<ApiCallResponse> call({
    String? proposalId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Associate Out Of Scope Proposal',
      apiUrl:
          '$baseUrl/dovia-home/associate/out-of-scope-proposals/$proposalId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// GET /dovia-home/service-requests/{serviceRequestId}/out-of-scope-proposals
// Permiso: CLIENT + DOVIA_HOME_OUT_OF_SCOPE_PROPOSAL_READ_RECEIVED.
// {serviceRequestId} debe ser el hijo OUT_OF_SCOPE propio. Query: page?, limit?.
// ---------------------------------------------------------------------------

class ListClientOutOfScopeProposalsCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Client Out Of Scope Proposals',
      apiUrl:
          '$baseUrl/dovia-home/service-requests/$serviceRequestId/out-of-scope-proposals',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? proposalsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/out-of-scope-proposals/{proposalId}
// Permiso: CLIENT + DOVIA_HOME_OUT_OF_SCOPE_PROPOSAL_READ_RECEIVED.
// ---------------------------------------------------------------------------

class GetOutOfScopeProposalCall {
  Future<ApiCallResponse> call({
    String? proposalId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Out Of Scope Proposal',
      apiUrl: '$baseUrl/dovia-home/out-of-scope-proposals/$proposalId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
}

// ---------------------------------------------------------------------------
// POST /dovia-home/out-of-scope-proposals/{proposalId}/reject
// Permiso: CLIENT + DOVIA_HOME_OUT_OF_SCOPE_PROPOSAL_REJECT. Sin body.
// ---------------------------------------------------------------------------

class RejectOutOfScopeProposalCall {
  Future<ApiCallResponse> call({
    String? proposalId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Reject Out Of Scope Proposal',
      apiUrl: '$baseUrl/dovia-home/out-of-scope-proposals/$proposalId/reject',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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
}

// ---------------------------------------------------------------------------
// POST /dovia-home/out-of-scope-proposals/{proposalId}/accept
// Permiso: CLIENT suscrito + DOVIA_HOME_OUT_OF_SCOPE_PROPOSAL_ACCEPT. Sin body.
// Actualiza el hijo, crea checkout OUT_OF_SCOPE_QUOTE (GTQ) y devuelve payment.
// ---------------------------------------------------------------------------

class AcceptOutOfScopeProposalCall {
  Future<ApiCallResponse> call({
    String? proposalId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Accept Out Of Scope Proposal',
      apiUrl: '$baseUrl/dovia-home/out-of-scope-proposals/$proposalId/accept',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

  String? childServiceRequestId(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.childServiceRequestId''') ??
            getJsonField(response, r'''$.childServiceRequestId'''),
      );
  String? paymentOrderId(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.payment.id''') ??
            getJsonField(response, r'''$.payment.id'''),
      );
  String? checkoutUrl(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.payment.checkoutUrl''') ??
            getJsonField(response, r'''$.payment.checkoutUrl'''),
      );
}

// ===========================================================================
// Proposal controller (2) - listados unificados QUOTE + OUT_OF_SCOPE
// ===========================================================================

// ---------------------------------------------------------------------------
// GET /dovia-home/proposals
// Permiso: CLIENT + DOVIA_HOME_PROPOSAL_READ_RECEIVED. Query: status?, page?, limit?.
// ---------------------------------------------------------------------------

class ListClientProposalsCall {
  Future<ApiCallResponse> call({
    String? status,
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Client Proposals',
      apiUrl: '$baseUrl/dovia-home/proposals',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? proposalsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

// ---------------------------------------------------------------------------
// GET /dovia-home/associate/proposals
// Permiso: HOME_ASSOCIATE/HOME_ASSOCIATE_COMPANY + DOVIA_HOME_PROPOSAL_READ_OWN.
// Query: status?, page?, limit?.
// ---------------------------------------------------------------------------

class ListAssociateProposalsCall {
  Future<ApiCallResponse> call({
    String? status,
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIDoviaHomeContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Associate Proposals',
      apiUrl: '$baseUrl/dovia-home/associate/proposals',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? proposalsList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

/// End DOVIA API - Dovia Home Context Group Code
