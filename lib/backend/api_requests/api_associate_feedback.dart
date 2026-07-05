import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

/// Start DOVIA API - Associate Feedback Context Group Code

class DOVIAAPIAssociateFeedbackContextGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};

  static CreateVisitAssociateRatingCall createVisitAssociateRatingCall =
      CreateVisitAssociateRatingCall();
  static CreateVisitAssociateReportCall createVisitAssociateReportCall =
      CreateVisitAssociateReportCall();
  static CreateOfferAssociateRatingCall createOfferAssociateRatingCall =
      CreateOfferAssociateRatingCall();
  static CreateOfferAssociateReportCall createOfferAssociateReportCall =
      CreateOfferAssociateReportCall();
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

/// End DOVIA API - Associate Feedback Context Group Code
