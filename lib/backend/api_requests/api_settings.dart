import 'api_manager.dart';

/// Start DOVIA API - Settings Context Group Code

class DOVIAAPISettingsContextGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};
  static ListSettingsCall listSettingsCall = ListSettingsCall();
  static GetSettingByKeyCall getSettingByKeyCall = GetSettingByKeyCall();
  static UpsertSettingByKeyCall upsertSettingByKeyCall =
      UpsertSettingByKeyCall();
  static DeleteSettingByKeyCall deleteSettingByKeyCall =
      DeleteSettingByKeyCall();
}

class ListSettingsCall {
  Future<ApiCallResponse> call({
    int? page,
    int? limit,
    String? bearerAuth = '',
  }) async {
    final baseUrl = DOVIAAPISettingsContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Settings',
      apiUrl: '$baseUrl/settings',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $bearerAuth',
      },
      params: {
        'page': page,
        'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetSettingByKeyCall {
  Future<ApiCallResponse> call({
    String? bearerAuth = '',
    String? settingKey = '',
  }) async {
    final baseUrl = DOVIAAPISettingsContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Setting By Key',
      apiUrl: '$baseUrl/settings/$settingKey',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $bearerAuth',
      },
      params: {
        'settingKey': settingKey,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpsertSettingByKeyCall {
  Future<ApiCallResponse> call({
    String? bearerAuth = '',
    String? settingKey = '',
  }) async {
    final baseUrl = DOVIAAPISettingsContextGroup.getBaseUrl();

    const ffApiRequestBody = '''
{
  "name": "Horarios operativos de visitas",
  "valueType": "array",
  "value": [
    ""
  ],
  "description": "Rangos de disponibilidad laboral de operative listers para asignación de visitas"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Upsert Setting By Key',
      apiUrl: '$baseUrl/settings/$settingKey',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer $bearerAuth',
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

class DeleteSettingByKeyCall {
  Future<ApiCallResponse> call({
    String? bearerAuth = '',
    String? settingKey = '',
  }) async {
    final baseUrl = DOVIAAPISettingsContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Setting By Key',
      apiUrl: '$baseUrl/settings/$settingKey',
      callType: ApiCallType.DELETE,
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

/// End DOVIA API - Settings Context Group Code
