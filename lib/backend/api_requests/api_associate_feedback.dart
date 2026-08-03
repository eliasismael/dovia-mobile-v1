import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_config.dart';

/// Start DOVIA API - Associate Feedback Context Group Code

class DOVIAAPIAssociateFeedbackContextGroup {
  static String getBaseUrl() => kApiBaseUrl;
  static Map<String, String> headers = {};

  static CreateVisitAssociateRatingCall createVisitAssociateRatingCall =
      CreateVisitAssociateRatingCall();
  static CreateVisitAssociateReportCall createVisitAssociateReportCall =
      CreateVisitAssociateReportCall();
  static CreateOfferAssociateRatingCall createOfferAssociateRatingCall =
      CreateOfferAssociateRatingCall();
  static CreateOfferAssociateReportCall createOfferAssociateReportCall =
      CreateOfferAssociateReportCall();
  static CreateDoviaHomeAssociateRatingCall
      createDoviaHomeAssociateRatingCall = CreateDoviaHomeAssociateRatingCall();
  static CreateDoviaHomeAssociateReportCall
      createDoviaHomeAssociateReportCall = CreateDoviaHomeAssociateReportCall();
  static PresignDoviaHomeReportImagesCall presignDoviaHomeReportImagesCall =
      PresignDoviaHomeReportImagesCall();
  static ConfirmDoviaHomeReportImagesCall confirmDoviaHomeReportImagesCall =
      ConfirmDoviaHomeReportImagesCall();
}

/// POST /associate-feedback/visits/{visitId}/ratings
/// Crea una calificación inmutable de un asociado relacionado con una visita.
/// targetRole: CLIENT_VISIT -> SHOWING_AGENT; OPERATIVE_LISTER_VISIT -> LISTER_HQ | OPERATIVE_LISTER
class CreateVisitAssociateRatingCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
    String? targetRole = '',
    double? stars,
  }) async {
    final baseUrl = DOVIAAPIAssociateFeedbackContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'targetRole': targetRole,
      'stars': stars,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Create Visit Associate Rating',
      apiUrl: '$baseUrl/associate-feedback/visits/$visitId/ratings',
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

/// POST /associate-feedback/visits/{visitId}/reports
/// Crea un reporte inmutable de un asociado relacionado con una visita.
class CreateVisitAssociateReportCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
    String? targetRole = '',
    String? message = '',
  }) async {
    final baseUrl = DOVIAAPIAssociateFeedbackContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'targetRole': targetRole,
      'message': message,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Create Visit Associate Report',
      apiUrl: '$baseUrl/associate-feedback/visits/$visitId/reports',
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

/// POST /associate-feedback/offers/{offerId}/ratings
/// Crea una calificación inmutable de un asociado relacionado con una oferta.
/// targetRole: LEGAL_ASSOCIATE | LEGAL_OFFICER. Solo si offer.processStatus === completed.
class CreateOfferAssociateRatingCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
    String? authToken = '',
    String? targetRole = '',
    double? stars,
  }) async {
    final baseUrl = DOVIAAPIAssociateFeedbackContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'targetRole': targetRole,
      'stars': stars,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer Associate Rating',
      apiUrl: '$baseUrl/associate-feedback/offers/$offerId/ratings',
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

/// POST /associate-feedback/offers/{offerId}/reports
/// Crea un reporte inmutable de un asociado relacionado con una oferta.
class CreateOfferAssociateReportCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
    String? authToken = '',
    String? targetRole = '',
    String? message = '',
  }) async {
    final baseUrl = DOVIAAPIAssociateFeedbackContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'targetRole': targetRole,
      'message': message,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer Associate Report',
      apiUrl: '$baseUrl/associate-feedback/offers/$offerId/reports',
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
// DOVIA Home — feedback del asociado asignado a una solicitud de servicio.
// A diferencia de visitas/ofertas, el backend resuelve el target desde
// `serviceRequest.associate.userId` (targetRole = DOVIA_HOME_ASSOCIATE), así que
// estos endpoints no reciben `targetRole`.
// ---------------------------------------------------------------------------

/// POST /associate-feedback/dovia-home/services/{serviceRequestId}/ratings
/// El servicio debe pertenecer al cliente autenticado y estar FINISHED / null.
/// Sólo se permite una calificación por cliente + servicio (409 si se repite).
class CreateDoviaHomeAssociateRatingCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? authToken = '',
    double? stars,
  }) async {
    final baseUrl = DOVIAAPIAssociateFeedbackContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'stars': stars,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Create Dovia Home Associate Rating',
      apiUrl:
          '$baseUrl/associate-feedback/dovia-home/services/$serviceRequestId/ratings',
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

/// POST /associate-feedback/dovia-home/services/{serviceRequestId}/reports
/// Se permiten múltiples reportes. El reporte nace con `imageUrls: []`; las
/// imágenes se adjuntan después con presign + confirm usando el `id` devuelto.
class CreateDoviaHomeAssociateReportCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? authToken = '',
    String? message = '',
  }) async {
    final baseUrl = DOVIAAPIAssociateFeedbackContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'message': message,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Create Dovia Home Associate Report',
      apiUrl:
          '$baseUrl/associate-feedback/dovia-home/services/$serviceRequestId/reports',
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

  String? id(dynamic response) =>
      (getJsonField(response, r'''$.data.id''') ??
              getJsonField(response, r'''$.id'''))
          ?.toString();
}

/// POST /associate-feedback/dovia-home/services/{serviceRequestId}/reports/images/presign
/// Body: { uploads: [{ fileName, mimeType, sizeBytes, clientUploadId? }] }.
/// Sólo se aceptan imágenes.
class PresignDoviaHomeReportImagesCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    List<dynamic>? uploads,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIAssociateFeedbackContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'uploads': uploads ?? [],
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Presign Dovia Home Report Images',
      apiUrl:
          '$baseUrl/associate-feedback/dovia-home/services/$serviceRequestId/reports/images/presign',
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

/// POST /associate-feedback/dovia-home/services/{serviceRequestId}/reports/{reportId}/images/confirm
/// Valida que los `storageKeys` pertenezcan al servicio/reporte y adjunta las
/// URLs públicas al reporte en `imageUrls`.
class ConfirmDoviaHomeReportImagesCall {
  Future<ApiCallResponse> call({
    String? serviceRequestId = '',
    String? reportId = '',
    List<String>? storageKeys,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIAssociateFeedbackContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'storageKeys': storageKeys ?? [],
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Confirm Dovia Home Report Images',
      apiUrl:
          '$baseUrl/associate-feedback/dovia-home/services/$serviceRequestId/reports/$reportId/images/confirm',
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

/// End DOVIA API - Associate Feedback Context Group Code
