import 'api_manager.dart';

/// Start Dovia API - Recruitment Group Code

class DoviaAPIRecruitmentGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};
  static GetRecruitmentSettingsCall getRecruitmentSettingsCall =
      GetRecruitmentSettingsCall();
  static UpdateRecruitmentSettingsCall updateRecruitmentSettingsCall =
      UpdateRecruitmentSettingsCall();
  static GetAvailableSlotsCall getAvailableSlotsCall = GetAvailableSlotsCall();
  static CreateFirstContactCall createFirstContactCall =
      CreateFirstContactCall();
}

class GetRecruitmentSettingsCall {
  Future<ApiCallResponse> call({
    String? bearerAuth = '',
  }) async {
    final baseUrl = DoviaAPIRecruitmentGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Recruitment Settings',
      apiUrl: '$baseUrl/recruitment/settings',
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

class UpdateRecruitmentSettingsCall {
  Future<ApiCallResponse> call({
    String? bearerAuth = '',
  }) async {
    final baseUrl = DoviaAPIRecruitmentGroup.getBaseUrl();

    const ffApiRequestBody = '''
{
  "workingDays": [
    "MONDAY"
  ],
  "startHour": 9,
  "endHour": 17
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Recruitment Settings',
      apiUrl: '$baseUrl/recruitment/settings',
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

class GetAvailableSlotsCall {
  Future<ApiCallResponse> call({
    String? date = '',
    String? bearerAuth = '',
  }) async {
    final baseUrl = DoviaAPIRecruitmentGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Available Slots',
      apiUrl: '$baseUrl/recruitment/slots',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $bearerAuth',
      },
      params: {
        'date': date,
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

class CreateFirstContactCall {
  Future<ApiCallResponse> call({
    String? bearerAuth = '',
  }) async {
    final baseUrl = DoviaAPIRecruitmentGroup.getBaseUrl();

    const ffApiRequestBody = '''
{
  "scheduledAt": "2026-02-15T10:00:00Z"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create First Contact',
      apiUrl: '$baseUrl/recruitment/appointments/first-contact',
      callType: ApiCallType.POST,
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

/// End Dovia API - Recruitment Group Code
