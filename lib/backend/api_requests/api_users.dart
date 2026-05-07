
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
        r'''$.data.verified''',
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
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get User by ID NEW',
      apiUrl: '$baseUrl/users/$userId',
      callType: ApiCallType.GET,
      headers: {},
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
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    const ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update User Preferences NEW',
      apiUrl: '$baseUrl/users/$userId/preferences',
      callType: ApiCallType.PUT,
      headers: {},
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
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    const ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Upload User Document',
      apiUrl: '$baseUrl/users/$userId/documents/$documentType',
      callType: ApiCallType.POST,
      headers: {},
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
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  ${name != null ? '"name": "${escapeStringForJson(name)}",' : ''}
  ${lastname != null ? '"lastname": "${escapeStringForJson(lastname)}",' : ''}
  ${gender != null ? '"gender": "${escapeStringForJson(gender)}",' : ''}
  ${nationality != null ? '"nationality": "${escapeStringForJson(nationality)}",' : ''}
  ${(phoneCountryCode != null && phoneNumber != null) ? '"phone": { "countryCode": "${escapeStringForJson(phoneCountryCode)}", "number": "${escapeStringForJson(phoneNumber)}" },' : ''}
  ${address != null ? '"address": "${escapeStringForJson(address)}"' : '"_placeholder": null'}
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

/// End DOVIA API - User Context Group Code
