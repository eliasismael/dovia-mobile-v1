import 'dart:convert';

import 'api_manager.dart';
import 'api_config.dart';

/// Start Dovia API - Recruitment Group Code

class DoviaAPIRecruitmentGroup {
  static String getBaseUrl() => kApiBaseUrl;
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
  /// [scheduledAt]: fecha y hora de la entrevista en ISO 8601 UTC.
  Future<ApiCallResponse> call({
    String? bearerAuth = '',
    required String scheduledAt,
  }) async {
    final baseUrl = DoviaAPIRecruitmentGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({'scheduledAt': scheduledAt});
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
