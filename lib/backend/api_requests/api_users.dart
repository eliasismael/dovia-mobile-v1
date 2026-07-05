import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_helpers.dart';

/// Start DOVIA API - User Context Group Code

class DOVIAAPIUserContextGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};
  static GetAuthenticatedUserProfileCall getAuthenticatedUserProfileCall =
      GetAuthenticatedUserProfileCall();
  static ListUsersByRoleCall listUsersByRoleCall = ListUsersByRoleCall();
  static GetUserByIDNEWCall getUserByIDNEWCall = GetUserByIDNEWCall();
  static UpdateUserPreferencesNEWCall updateUserPreferencesNEWCall =
      UpdateUserPreferencesNEWCall();
  static UploadUserDocumentCall uploadUserDocumentCall =
      UploadUserDocumentCall();
  static UploadProfilePictureCall uploadProfilePictureCall =
      UploadProfilePictureCall();
  static UpdateUserProfileCall updateUserProfileCall = UpdateUserProfileCall();
  static AdminVerifyUserCall adminVerifyUserCall = AdminVerifyUserCall();
  static GetPerformanceSummaryCall getPerformanceSummaryCall =
      GetPerformanceSummaryCall();
  static DeactivateMyAccountCall deactivateMyAccountCall =
      DeactivateMyAccountCall();
}

class GetAuthenticatedUserProfileCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Authenticated User Profile',
      apiUrl: '$baseUrl/users/me',
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

  String? userRole(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.roles[0]''',
      ));
  bool? isUserActive(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.active''',
      ));
  bool? isVerified(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.verified''',
      ));
  String? userId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.id''',
      ));
  String? avatar(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.avatar''',
      ));
  String? name(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.fullName.name''',
      ));
  String? lastname(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.fullName.lastname''',
      ));
}

class ListUsersByRoleCall {
  Future<ApiCallResponse> call({
    String? role = '',
    String? page = '',
    String? limit = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Users by Role',
      apiUrl: '$baseUrl/users',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        'role': role,
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

class GetUserByIDNEWCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get User by ID NEW',
      apiUrl: '$baseUrl/users/$userId',
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

class UpdateUserPreferencesNEWCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? authToken = '',
    String? propertyType,
    String? acquisitionModality,
    String? coordinates,
    String? description,
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  ${propertyType != null ? '"propertyType": "${escapeStringForJson(propertyType)}",' : '"propertyType": null,'}
  ${acquisitionModality != null ? '"acquisitionModality": "${escapeStringForJson(acquisitionModality)}",' : '"acquisitionModality": null,'}
  ${coordinates != null ? '"coordinates": $coordinates,' : '"coordinates": null,'}
  ${description != null ? '"description": "${escapeStringForJson(description)}"' : '"description": null'}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update User Preferences NEW',
      apiUrl: '$baseUrl/users/$userId/preferences',
      callType: ApiCallType.PUT,
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

class UploadUserDocumentCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? documentType = '',
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Upload User Document',
      apiUrl: '$baseUrl/users/$userId/documents/$documentType',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {
        'file': file,
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

  String? storageKey(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.storageKey''',
      ));
  String? url(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.url''',
      ));
}

class UploadProfilePictureCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Upload Profile Picture',
      apiUrl: '$baseUrl/users/profile-picture',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {
        'file': file,
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
}

class UpdateUserProfileCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? authToken = '',
    String? name,
    String? lastname,
    String? gender,
    String? nationality,
    String? phoneCountryCode,
    String? phoneNumber,
    String? address,
    String? workArea,
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  ${name != null ? '"name": "${escapeStringForJson(name)}",' : ''}
  ${lastname != null ? '"lastname": "${escapeStringForJson(lastname)}",' : ''}
  ${gender != null ? '"gender": "${escapeStringForJson(gender)}",' : ''}
  ${nationality != null ? '"nationality": "${escapeStringForJson(nationality)}",' : ''}
  ${(phoneCountryCode != null && phoneNumber != null) ? '"phone": { "countryCode": "${escapeStringForJson(phoneCountryCode)}", "number": "${escapeStringForJson(phoneNumber)}" },' : ''}
  ${address != null ? '"address": "${escapeStringForJson(address)}",' : ''}
  ${workArea != null ? '"workArea": $workArea,' : ''}
  "_placeholder": null
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update User Profile',
      apiUrl: '$baseUrl/users/$userId',
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

class AdminVerifyUserCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Admin Verify User',
      apiUrl: '$baseUrl/admin/users/$userId/verify',
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
}

class GetPerformanceSummaryCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Performance Summary',
      apiUrl: '$baseUrl/users/me/performance-summary',
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

  double? averageStars(dynamic response) =>
      castToType<double>(getJsonField(response, r'''$.data.averageStars''')) ??
      castToType<double>(getJsonField(response, r'''$.averageStars'''));
  double? totalEarned(dynamic response) =>
      castToType<double>(getJsonField(response, r'''$.data.totalEarned''')) ??
      castToType<double>(getJsonField(response, r'''$.totalEarned'''));
}

class DeactivateMyAccountCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? reason,
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    final ffApiRequestBody = reason != null && reason.isNotEmpty
        ? '{ "reason": "${escapeStringForJson(reason)}" }'
        : '{}';

    return ApiManager.instance.makeApiCall(
      callName: 'Deactivate My Account',
      apiUrl: '$baseUrl/users/me/deactivation',
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

  bool? active(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.active''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

/// End DOVIA API - User Context Group Code
