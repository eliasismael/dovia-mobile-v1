import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_helpers.dart';

/// Start DOVIA API - Auth Context Group Code

class DOVIAAPIAuthContextGroup {
  static String getBaseUrl({
    String? email = '',
  }) =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};
  static SignUpStepNEWCall signUpStepNEWCall = SignUpStepNEWCall();
  static VerifyCodeStepNEWCall verifyCodeStepNEWCall = VerifyCodeStepNEWCall();
  static ResendCodeNEWCall resendCodeNEWCall = ResendCodeNEWCall();
  static CompleteRegistrationStepNEWCall completeRegistrationStepNEWCall =
      CompleteRegistrationStepNEWCall();
  static SignInNEWCall signInNEWCall = SignInNEWCall();
  static ForgotPasswordNEWCall forgotPasswordNEWCall = ForgotPasswordNEWCall();
  static ConfirmForgotPasswordNEWCall confirmForgotPasswordNEWCall =
      ConfirmForgotPasswordNEWCall();
  static RefreshTokenNEWCall refreshTokenNEWCall = RefreshTokenNEWCall();
  static SelectRoleCall selectRoleCall = SelectRoleCall();
  static LogoutAllCall logoutAllCall = LogoutAllCall();
}

class SignUpStepNEWCall {
  Future<ApiCallResponse> call({
    String? email = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl(
      email: email,
    );

    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Sign Up Step  NEW',
      apiUrl: '$baseUrl/auth/sign-up',
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

class VerifyCodeStepNEWCall {
  Future<ApiCallResponse> call({
    String? code = '',
    String? email = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl(
      email: email,
    );

    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}",
  "code": "${escapeStringForJson(code)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Verify Code Step  NEW',
      apiUrl: '$baseUrl/auth/verify',
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

class ResendCodeNEWCall {
  Future<ApiCallResponse> call({
    String? email = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl(
      email: email,
    );

    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Resend Code NEW',
      apiUrl: '$baseUrl/auth/resend-code',
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

class CompleteRegistrationStepNEWCall {
  Future<ApiCallResponse> call({
    String? name = 'juan',
    String? lastname = 'perez',
    String? day = '15',
    String? month = '03',
    String? year = '2000',
    String? gender = 'MALE',
    String? phoneCountryCode = '+54',
    String? phoneNumber = '1234567899',
    String? password = 'Hola123@',
    String? confirmPassword = 'Hola123@',
    String? nationality = 'Colombian',
    String? email = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl(
      email: email,
    );

    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}",
  "name": "${escapeStringForJson(name)}",
  "lastname": "${escapeStringForJson(lastname)}",
  "birthDate": "${escapeStringForJson(day)}/${escapeStringForJson(month)}/${escapeStringForJson(year)}",
  "gender": "${escapeStringForJson(gender)}",
  "phone": {
    "countryCode": "${escapeStringForJson(phoneCountryCode)}",
    "number": "${escapeStringForJson(phoneNumber)}"
  },
  "password": "${escapeStringForJson(password)}",
  "confirm_password": "${escapeStringForJson(confirmPassword)}",
  "nationality": "${escapeStringForJson(nationality)}" 
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Complete Registration Step  NEW',
      apiUrl: '$baseUrl/auth/complete-registration',
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

  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
  dynamic idToken(dynamic response) => getJsonField(
        response,
        r'''$.data.tokens.idToken''',
      );
  String? accessToken(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.tokens.accessToken''',
      ));
  String? refreshToken(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.tokens.refreshToken''',
      ));
  int? expiresIn(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.tokens.expiresIn''',
      ));
  String? userId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.user.id''',
      ));
  String? userEmail(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.user.email''',
      ));
  String? userName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.user.fullName.name''',
      ));
  String? userLastname(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.user.fullName.lastname''',
      ));
  dynamic userRole(dynamic response) => getJsonField(
        response,
        r'''$.data.user.roles[0]''',
      );
  dynamic isUserVerified(dynamic response) => getJsonField(
        response,
        r'''$.data.user.verified''',
      );
  dynamic isUserActive(dynamic response) => getJsonField(
        response,
        r'''$.data.user.active''',
      );
}

class SignInNEWCall {
  Future<ApiCallResponse> call({
    String? password = '',
    String? email = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl(
      email: email,
    );

    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}",
  "password": "${escapeStringForJson(password)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Sign In NEW',
      apiUrl: '$baseUrl/auth/sign-in',
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

  String? accessToken(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.accessToken''',
      ));
  String? refreshToken(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.refreshToken''',
      ));
  String? idToken(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.idToken''',
      ));
  bool? isProfileComplete(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.isProfileComplete''',
      ));
  bool? isRoleSelected(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.isRoleSelected''',
      ));
  bool? verified(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.verified''',
      ));
  bool? isIdentificationDocumentUploaded(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.data.isIdentificationDocumentUploaded''',
      ));
  bool? isAssociateProfileComplete(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.data.isAssociateProfileComplete''',
      ));
  String? userId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.userId''',
      ));
}

class ForgotPasswordNEWCall {
  Future<ApiCallResponse> call({
    String? email = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl(
      email: email,
    );

    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Forgot Password NEW',
      apiUrl: '$baseUrl/auth/forgot-password',
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

class ConfirmForgotPasswordNEWCall {
  Future<ApiCallResponse> call({
    String? code = '',
    String? newPassword = '',
    String? confirmNewPassword = '',
    String? email = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl(
      email: email,
    );

    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}",
  "code": "${escapeStringForJson(code)}",
  "newPassword": "${escapeStringForJson(newPassword)}",
  "confirmPassword": "${escapeStringForJson(confirmNewPassword)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Confirm Forgot Password NEW',
      apiUrl: '$baseUrl/auth/forgot-password/confirm',
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

class RefreshTokenNEWCall {
  Future<ApiCallResponse> call({
    String? refreshToken = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "refreshToken": "${escapeStringForJson(refreshToken)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Refresh Token NEW',
      apiUrl: '$baseUrl/auth/refresh-token',
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

  String? accessToken(dynamic response) => 
      castToType<String>(getJsonField(response, r'''$.data.accessToken''')) ??
      castToType<String>(getJsonField(response, r'''$.data.tokens.accessToken'''));
  
  String? refreshTokenResponse(dynamic response) => 
      castToType<String>(getJsonField(response, r'''$.data.refreshToken''')) ??
      castToType<String>(getJsonField(response, r'''$.data.tokens.refreshToken'''));
      
  String? idToken(dynamic response) => 
      castToType<String>(getJsonField(response, r'''$.data.idToken''')) ??
      castToType<String>(getJsonField(response, r'''$.data.tokens.idToken'''));
}

class SelectRoleCall {
  Future<ApiCallResponse> call({
    String? role = '',
    String? authToken = '',
    String? email = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl(
      email: email,
    );

    final ffApiRequestBody = '''
{
  "role": "${escapeStringForJson(role)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Select Role',
      apiUrl: '$baseUrl/auth/select-role',
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

  String? accessToken(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.data.accessToken''')) ??
      castToType<String>(
          getJsonField(response, r'''$.data.tokens.accessToken'''));

  String? refreshToken(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.data.refreshToken''')) ??
      castToType<String>(
          getJsonField(response, r'''$.data.tokens.refreshToken'''));

  String? idToken(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.data.idToken''')) ??
      castToType<String>(getJsonField(response, r'''$.data.tokens.idToken'''));
}

class LogoutAllCall {
  Future<ApiCallResponse> call({
    String? idToken = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Logout All Sessions',
      apiUrl: '$baseUrl/auth/logout-all',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $idToken',
      },
      params: {},
      body: '',
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

/// End DOVIA API - Auth Context Group Code
