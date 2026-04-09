import 'api_manager.dart';

/// Start DOVIA API - Metrics Context Group Code

class DOVIAAPIMetricsContextGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};
  static TrackPropertyViewCall trackPropertyViewCall = TrackPropertyViewCall();
  static TrackPropertyInteractionCall trackPropertyInteractionCall =
      TrackPropertyInteractionCall();
  static GetPropertyStatisticsCall getPropertyStatisticsCall =
      GetPropertyStatisticsCall();
}

class TrackPropertyViewCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? bearerAuth = '',
  }) async {
    final baseUrl = DOVIAAPIMetricsContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Track Property View',
      apiUrl: '$baseUrl/metrics/properties/$propertyId/view',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $bearerAuth',
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

class TrackPropertyInteractionCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? bearerAuth = '',
  }) async {
    final baseUrl = DOVIAAPIMetricsContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Track Property Interaction',
      apiUrl: '$baseUrl/metrics/properties/$propertyId/interact',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $bearerAuth',
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

class GetPropertyStatisticsCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? bearerAuth = '',
  }) async {
    final baseUrl = DOVIAAPIMetricsContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Property Statistics',
      apiUrl: '$baseUrl/metrics/properties/$propertyId/statistics',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $bearerAuth',
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

/// End DOVIA API - Metrics Context Group Code
