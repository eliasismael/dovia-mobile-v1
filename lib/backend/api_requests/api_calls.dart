import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

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
      apiUrl: '${baseUrl}/auth/sign-up',
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
      apiUrl: '${baseUrl}/auth/verify',
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
      apiUrl: '${baseUrl}/auth/resend-code',
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
      apiUrl: '${baseUrl}/auth/complete-registration',
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
  dynamic? idToken(dynamic response) => getJsonField(
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
  dynamic? isUserVerified(dynamic response) => getJsonField(
        response,
        r'''$.data.user.verified''',
      );
  dynamic? isUserActive(dynamic response) => getJsonField(
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
      apiUrl: '${baseUrl}/auth/sign-in',
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
      apiUrl: '${baseUrl}/auth/forgot-password',
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
      apiUrl: '${baseUrl}/auth/forgot-password/confirm',
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
    String? email = '',
  }) async {
    final baseUrl = DOVIAAPIAuthContextGroup.getBaseUrl(
      email: email,
    );

    final ffApiRequestBody = '''
{
  "refreshToken": "${escapeStringForJson(email)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Refresh Token NEW',
      apiUrl: '${baseUrl}/auth/refresh-token',
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
      apiUrl: '${baseUrl}/auth/select-role',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

/// End DOVIA API - Auth Context Group Code

/// Start DOVIA API - Favorite Context Group Code

class DOVIAAPIFavoriteContextGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};
  static AddPropertyToFavoritesCall addPropertyToFavoritesCall =
      AddPropertyToFavoritesCall();
  static RemovePropertyFromFavoritesCall removePropertyFromFavoritesCall =
      RemovePropertyFromFavoritesCall();
  static GetDefaultFavoritesCall getDefaultFavoritesCall =
      GetDefaultFavoritesCall();
  static CheckIfPropertyIsFavoritedCall checkIfPropertyIsFavoritedCall =
      CheckIfPropertyIsFavoritedCall();
  static CreateFavoriteFolderCall createFavoriteFolderCall =
      CreateFavoriteFolderCall();
  static GetAllFavoriteFoldersCall getAllFavoriteFoldersCall =
      GetAllFavoriteFoldersCall();
  static UpdateFavoriteFolderNameCall updateFavoriteFolderNameCall =
      UpdateFavoriteFolderNameCall();
  static DeleteFavoriteFolderCall deleteFavoriteFolderCall =
      DeleteFavoriteFolderCall();
  static GetFavoritesInFolderCall getFavoritesInFolderCall =
      GetFavoritesInFolderCall();
  static RemoveFavoriteFromFolderCall removeFavoriteFromFolderCall =
      RemoveFavoriteFromFolderCall();
  static AddFavoriteToFolderCall addFavoriteToFolderCall =
      AddFavoriteToFolderCall();
}

class AddPropertyToFavoritesCall {
  Future<ApiCallResponse> call({
    String? folderId = '',
    String? propertyId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Add Property to Favorites',
      apiUrl: '${baseUrl}/favorites/${propertyId}${folderId != null && folderId.isNotEmpty ? "?folderId=$folderId" : ""}',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class RemovePropertyFromFavoritesCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Remove Property from Favorites',
      apiUrl: '${baseUrl}/favorites/${propertyId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class GetDefaultFavoritesCall {
  Future<ApiCallResponse> call({
    String? page = '',
    String? limit = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Default Favorites',
      apiUrl: '${baseUrl}/favorites',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  int? statusCode(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.status_code''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
  String? actionRequired(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.action_required''',
      ));
  List? data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
  String? itemId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].id''',
      ));
  String? itemFavoritedAt(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].favoritedAt''',
      ));
  String? itemPropertyId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].propertyId''',
      ));
  String? itemName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].name''',
      ));
  int? itemPrice(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[:].price''',
      ));
  bool? itemIsFavorite(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data[:].isFavorite''',
      ));
  List<String>? itemListingType(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].listingType''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  int? itemConstructionArea(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[:].features.general.constructionArea''',
      ));
  int? itemBedrooms(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[:].features.general.bedrooms''',
      ));
  int? itemBathrooms(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[:].features.general.bathrooms''',
      ));
  int? itemParkingSpot(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[:].features.general.parkingSpots''',
      ));
  dynamic? meta(dynamic response) => getJsonField(
        response,
        r'''$.meta''',
      );
  String? metaTimeStamp(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.meta.timestamp''',
      ));
  String? metaRequestId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.meta.request_id''',
      ));
  String? metaPath(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.meta.path''',
      ));
  dynamic? metaPagination(dynamic response) => getJsonField(
        response,
        r'''$.meta.pagination''',
      );
  int? metaPaginationPage(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.meta.pagination.page''',
      ));
  int? metaPaginationLimit(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.meta.pagination.limit''',
      ));
  int? metaPaginationTotalItems(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'''$.meta.pagination.totalItems''',
      ));
  int? metaPaginationTotalPages(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'''$.meta.pagination.totalPages''',
      ));
  bool? metaPaginationHasNextPage(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.meta.pagination.hasNextPage''',
      ));
  bool? metaPaginationHasPreviousPage(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.meta.pagination.hasPreviousPage''',
      ));
  int? itemLandArea(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[:].features.general.landArea''',
      ));
  dynamic? itemFeaturesGeneral(dynamic response) => getJsonField(
        response,
        r'''$.data[:].features.general''',
      );
  dynamic? itemFeatures(dynamic response) => getJsonField(
        response,
        r'''$.data[:].features''',
      );
  dynamic? itemDescription(dynamic response) => getJsonField(
        response,
        r'''$.data[:].description''',
      );
  List<double>? itemCoordinates(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].location.geo.coordinates''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<double>(x))
          .withoutNulls
          .toList();
  String? itemGeoType(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].location.geo.type''',
      ));
  dynamic? itemGeo(dynamic response) => getJsonField(
        response,
        r'''$.data[:].location.geo''',
      );
  String? itemFullAddress(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].location.address.fullAddress''',
      ));
  dynamic? itemAddress(dynamic response) => getJsonField(
        response,
        r'''$.data[:].location.address''',
      );
  dynamic? itemLocation(dynamic response) => getJsonField(
        response,
        r'''$.data[:].location''',
      );
  int? itemSinglePropertyTax(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[:].saleInfo.singlePropertyTax''',
      ));
  int? itemMaintenanceFee(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[:].saleInfo.maintenanceFee''',
      ));
  int? itemAmountToReceive(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[:].saleInfo.amountToReceive''',
      ));
  int? itemSalePrice(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data[:].saleInfo.salePrice''',
      ));
  dynamic? itemSaleInfo(dynamic response) => getJsonField(
        response,
        r'''$.data[:].saleInfo''',
      );
  bool? itemIsActive(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data[:].active''',
      ));
  String? itemStatus(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].status''',
      ));
}

class CheckIfPropertyIsFavoritedCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Check if Property is Favorited',
      apiUrl: '${baseUrl}/favorites/check/${propertyId}',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

  dynamic? data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );
  List<String>? foledersStoredIn(dynamic response) => (getJsonField(
        response,
        r'''$.data.folderIds''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class CreateFavoriteFolderCall {
  Future<ApiCallResponse> call({
    String? folderName = 'Mis propiedades favoritas',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "name": "${escapeStringForJson(folderName)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Favorite Folder',
      apiUrl: '${baseUrl}/favorites/folders',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class GetAllFavoriteFoldersCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get All Favorite Folders',
      apiUrl: '${baseUrl}/favorites/folders',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

  List? folders(dynamic response) => getJsonField(
        response,
        r'''$.data.folders''',
        true,
      ) as List?;
  List<String>? folderId(dynamic response) => (getJsonField(
        response,
        r'''$.data.folders[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? folderName(dynamic response) => (getJsonField(
        response,
        r'''$.data.folders[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class UpdateFavoriteFolderNameCall {
  Future<ApiCallResponse> call({
    String? folderId = '',
    String? udatedFolderName = 'Nuevo nombre de carpeta',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "name": "${escapeStringForJson(udatedFolderName)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Favorite Folder Name',
      apiUrl: '${baseUrl}/favorites/folders/${folderId}',
      callType: ApiCallType.PATCH,
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

class DeleteFavoriteFolderCall {
  Future<ApiCallResponse> call({
    String? folderId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Favorite Folder',
      apiUrl: '${baseUrl}/favorites/folders/${folderId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class GetFavoritesInFolderCall {
  Future<ApiCallResponse> call({
    String? page = '',
    String? limit = '',
    String? folderId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Favorites in Folder',
      apiUrl: '${baseUrl}/favorites/folders/${folderId}/properties',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class RemoveFavoriteFromFolderCall {
  Future<ApiCallResponse> call({
    String? folderId = '',
    String? propertyId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Remove Favorite from Folder',
      apiUrl:
          '${baseUrl}/favorites/folders/${folderId}/properties/${propertyId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class AddFavoriteToFolderCall {
  Future<ApiCallResponse> call({
    String? folderId = '',
    String? propertyId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Add Favorite to Folder',
      apiUrl:
          '${baseUrl}/favorites/folders/${folderId}/properties/${propertyId}',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

/// End DOVIA API - Favorite Context Group Code

/// Start DOVIA API - Offer Context Group Code

class DOVIAAPIOfferContextGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};
  static CreateOfferPURCHASEPurchasePromiseCall
      createOfferPURCHASEPurchasePromiseCall =
      CreateOfferPURCHASEPurchasePromiseCall();
  static ListOffersByPropertyCall listOffersByPropertyCall =
      ListOffersByPropertyCall();
  static MakeCounterOfferPURCHASEPurchasePromiseCall
      makeCounterOfferPURCHASEPurchasePromiseCall =
      MakeCounterOfferPURCHASEPurchasePromiseCall();
  static GetOfferByIDCall getOfferByIDCall = GetOfferByIDCall();
  static AcceptOfferCall acceptOfferCall = AcceptOfferCall();
  static RejectOfferCall rejectOfferCall = RejectOfferCall();
  static SelectLegalAssociateCall selectLegalAssociateCall =
      SelectLegalAssociateCall();
  static SubmitBankAgentDataCall submitBankAgentDataCall =
      SubmitBankAgentDataCall();
  static ListMyOffersCall listMyOffersCall = ListMyOffersCall();
  static ListOffersOnMyPropertiesCall listOffersOnMyPropertiesCall =
      ListOffersOnMyPropertiesCall();
  static CreateOfferRENTIndividualCall createOfferRENTIndividualCall =
      CreateOfferRENTIndividualCall();
  static CreateOfferRENTCompanyCall createOfferRENTCompanyCall =
      CreateOfferRENTCompanyCall();
  static CreateOfferPURCHASEMortgageCall createOfferPURCHASEMortgageCall =
      CreateOfferPURCHASEMortgageCall();
  static MakeCounterOfferPURCHASEMortgageCall
      makeCounterOfferPURCHASEMortgageCall =
      MakeCounterOfferPURCHASEMortgageCall();
  static MakeCounterOfferPURCHASECashCall makeCounterOfferPURCHASECashCall =
      MakeCounterOfferPURCHASECashCall();
  static CreateOfferPURCHASECashCall createOfferPURCHASECashCall =
      CreateOfferPURCHASECashCall();
  static MakeCounterOfferRENTCall makeCounterOfferRENTCall =
      MakeCounterOfferRENTCall();
}

class CreateOfferPURCHASEPurchasePromiseCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    String? currency = '',
    double? proposedAmount,
    String? considerations = '',
    String? buyerType = '',
    String? buyerName = '',
    String? buyerLegalName = '',
    String? buyerLegalRepresentative = '',
    double? initialReserve,
    int? promiseTimeMonths,
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "offerType": "SALE",
  "offerData": {
    "paymentMethod": "purchase_promise",
    "currency": "${escapeStringForJson(currency)}",
    "proposedAmount": ${proposedAmount},
    "considerations": "${escapeStringForJson(considerations)}",
    "buyerInfo": {
      "type": "${escapeStringForJson(buyerType)}",
      "name": "${escapeStringForJson(buyerName)}",
      "legalName": "${escapeStringForJson(buyerLegalName)}",
      "legalRepresentative": "${escapeStringForJson(buyerLegalRepresentative)}"
    },
    "initialReserve": ${initialReserve},
    "promiseTimeMonths": ${promiseTimeMonths}
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer - PURCHASE (Purchase Promise)',
      apiUrl: '${baseUrl}/offers/properties/${propertyId}',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class ListOffersByPropertyCall {
  Future<ApiCallResponse> call({
    String? page = '',
    String? limit = '',
    String? offerStatus = '',
    String? processStatus = '',
    String? propertyId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Offers by Property',
      apiUrl: '${baseUrl}/offers/properties/${propertyId}',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'page': page,
        'limit': limit,
        'offerStatus': offerStatus,
        'processStatus': processStatus,
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

class MakeCounterOfferPURCHASEPurchasePromiseCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "counterOfferData": {
    "paymentMethod": "purchase_promise",
    "currency": "USD",
    "proposedAmount": 255000,
    "initialReserve": 60000,
    "promiseTimeMonths": 10,
    "considerations": "Ajuste de montos y plazos"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Make Counter Offer - PURCHASE (Purchase Promise)',
      apiUrl: '${baseUrl}/offers/${offerId}/counter-offer',
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

class GetOfferByIDCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Offer by ID',
      apiUrl: '${baseUrl}/offers/${offerId}',
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

class AcceptOfferCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "acceptedBy": "OWNER"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Accept Offer',
      apiUrl: '${baseUrl}/offers/${offerId}/accept',
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

class RejectOfferCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "rejectedBy": "OWNER",
  "reason": "Price does not meet expectations"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Reject Offer',
      apiUrl: '${baseUrl}/offers/${offerId}/reject',
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

class SelectLegalAssociateCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "legalAssociateId": "{{legalAssociateId}}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Select Legal Associate',
      apiUrl: '${baseUrl}/offers/${offerId}/select-legal-associate',
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

class SubmitBankAgentDataCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "banco": "Banco de Bogotá",
  "nombre": "María",
  "apellido": "González",
  "telefono": "+57 300 1234567",
  "email": "maria.gonzalez@bancobogota.com"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Submit Bank Agent Data',
      apiUrl: '${baseUrl}/offers/${offerId}/bank-agent-data',
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

class ListMyOffersCall {
  Future<ApiCallResponse> call({
    String? page = '',
    String? limit = '',
    String? offerType = '',
    String? offerStatus = '',
    String? processStatus = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List My Offers',
      apiUrl: '${baseUrl}/offers/my-offers',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'page': page,
        'limit': limit,
        'offerType': offerType,
        'offerStatus': offerStatus,
        'processStatus': processStatus,
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

class ListOffersOnMyPropertiesCall {
  Future<ApiCallResponse> call({
    String? page = '',
    String? limit = '',
    String? offerType = '',
    String? offerStatus = '',
    String? processStatus = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Offers On My Properties',
      apiUrl: '${baseUrl}/offers/my-properties',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'page': page,
        'limit': limit,
        'offerType': offerType,
        'offerStatus': offerStatus,
        'processStatus': processStatus,
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

class CreateOfferRENTIndividualCall {
  Future<ApiCallResponse> call({
    String? propertyId = '1',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "listingType": [
    "RENT"
  ],
  "name": "Apartamento en el Centro - Calle 123 #45-67",
  "address": "Calle 123 #45-67, Barrio El Centro, Bogotá, Colombia",
  "zone": "Zona 10",
  "geoLocation": {
    "longitude": -74.0721,
    "latitude": 4.711
  },
  "legalInfo": {
    "finca": "12345",
    "folio": "67890",
    "libro": "ABC123"
  },
  "rentInfo": {
    "monthlyRent": 2500000,
    "rentalConditions": {
      "minimumTime": 12,
      "others": "Se requiere fiador o depósito equivalente a 2 meses de renta. No se permiten mascotas. El contrato incluye servicios públicos básicos. Se requiere verificación de ingresos y referencias laborales."
    }
  },
  "ownership": {
    "isCompanyOwned": false,
    "legalRepresentative": "Carlos Alberto Rodríguez Martínez"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer RENT Individual',
      apiUrl: '${baseUrl}/offers/properties/${propertyId}',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class CreateOfferRENTCompanyCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "offerType": "RENT",
  "offerData": {
    "contractStartDate": "2026-03-01T00:00:00.000Z",
    "contractEndDate": "2027-03-01T00:00:00.000Z",
    "currency": "USD",
    "propertyUse": "Commercial Office Space",
    "considerations": "Need to accommodate 50 employees",
    "tenantInfo": {
      "type": "company",
      "name": "Tech Solutions S.A.",
      "legalName": "Tech Solutions Sociedad Anónima",
      "legalRepresentative": "María González"
    }
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer RENT Company',
      apiUrl: '${baseUrl}/offers/properties/${propertyId}',
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

class CreateOfferPURCHASEMortgageCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    String? currency = '',
    double? proposedAmount,
    String? considerations = '',
    String? buyerType = '',
    String? buyerName = '',
    int? downPaymentPercentage,
    String? bankName = '',
    String? creditStatus = '',
    int? estimatedApprovalTime,
    String? legalName = '',
    String? legalRepresentative = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "offerType": "SALE",
  "offerData": {
    "paymentMethod": "mortgage",
    "currency": "${escapeStringForJson(currency)}",
    "proposedAmount": ${proposedAmount},
    "considerations": "${escapeStringForJson(considerations)}",
    "buyerInfo": {
      "type": "${escapeStringForJson(buyerType)}",
      "name": "${escapeStringForJson(buyerName)}",
      "legalName": "${escapeStringForJson(legalName)}",
      "legalRepresentative": "${escapeStringForJson(legalRepresentative)}"
    },
    "downPaymentPercentage": ${downPaymentPercentage},
    "bankName": "${escapeStringForJson(bankName)}",
    "creditStatus": "${escapeStringForJson(creditStatus)}",
    "estimatedApprovalTime": ${estimatedApprovalTime}
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer  PURCHASE Mortgage',
      apiUrl: '${baseUrl}/offers/properties/${propertyId}',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class MakeCounterOfferPURCHASEMortgageCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "counterOfferData": {
    "paymentMethod": "mortgage",
    "currency": "USD",
    "proposedAmount": 300000,
    "bankName": "Banco Industrial",
    "downPaymentPercentage": 25,
    "considerations": "Precio ajustado según inspección"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Make Counter Offer  PURCHASE Mortgage',
      apiUrl: '${baseUrl}/offers/${offerId}/counter-offer',
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

class MakeCounterOfferPURCHASECashCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "counterOfferData": {
    "paymentMethod": "cash",
    "currency": "USD",
    "proposedAmount": 260000,
    "considerations": "Contraoferta con precio mayor, cierre rápido"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Make Counter Offer  PURCHASE Cash',
      apiUrl: '${baseUrl}/offers/${offerId}/counter-offer',
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

class CreateOfferPURCHASECashCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    int? estimatedPaymentTime,
    String? currency = '',
    double? proposedAmount,
    String? considerations = '',
    String? buyerType = '',
    String? buyerName = '',
    String? buyerLegalName = '',
    String? buyerRepresentative = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "offerType": "SALE",
  "offerData": {
    "paymentMethod": "cash",
    "currency": "${escapeStringForJson(currency)}",
    "proposedAmount": ${proposedAmount},
    "considerations": "${escapeStringForJson(considerations)}",
    "buyerInfo": {
      "type": "${escapeStringForJson(buyerType)}",
      "name": "${escapeStringForJson(buyerName)}",
      "legalName": "${escapeStringForJson(buyerLegalName)}",
      "legalRepresentative": "${escapeStringForJson(buyerRepresentative)}"
    },
    "estimatedPaymentTime": ${estimatedPaymentTime}
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer  PURCHASE Cash',
      apiUrl: '${baseUrl}/offers/properties/${propertyId}',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class MakeCounterOfferRENTCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "counterOfferData": {
    "contractStartDate": "2026-04-01T00:00:00.000Z",
    "contractEndDate": "2027-04-01T00:00:00.000Z",
    "currency": "USD",
    "considerations": "Contraoferta con fechas ajustadas"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Make Counter Offer  RENT',
      apiUrl: '${baseUrl}/offers/${offerId}/counter-offer',
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

/// End DOVIA API - Offer Context Group Code

/// Start DOVIA API - Property Context Group Code

class DOVIAAPIPropertyContextGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};
  static UploadPropertyOwnerIDDocumentCall uploadPropertyOwnerIDDocumentCall =
      UploadPropertyOwnerIDDocumentCall();
  static UploadPropertyCertificationCall uploadPropertyCertificationCall =
      UploadPropertyCertificationCall();
  static CreatePropertyBasicSALEAndRENTCall createPropertyBasicSALEAndRENTCall =
      CreatePropertyBasicSALEAndRENTCall();
  static CreatePropertyBasicRENTCall createPropertyBasicRENTCall =
      CreatePropertyBasicRENTCall();
  static CreatePropertyBasicSALECall createPropertyBasicSALECall =
      CreatePropertyBasicSALECall();
  static ListPropertiesCall listPropertiesCall = ListPropertiesCall();
  static GetPropertiesForMapCall getPropertiesForMapCall =
      GetPropertiesForMapCall();
  static GetPropertiesForHomeCall getPropertiesForHomeCall =
      GetPropertiesForHomeCall();
  static GetMyPropertiesCall getMyPropertiesCall = GetMyPropertiesCall();
  static GetPropertyByIDCall getPropertyByIDCall = GetPropertyByIDCall();
  static UpdatePropertyCall updatePropertyCall = UpdatePropertyCall();
  static UploadPropertyDocumentCall uploadPropertyDocumentCall =
      UploadPropertyDocumentCall();
  static CompletePropertyHardcodedTEMPCall completePropertyHardcodedTEMPCall =
      CompletePropertyHardcodedTEMPCall();
}

class UploadPropertyOwnerIDDocumentCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Upload Property Owner ID Document',
      apiUrl: '${baseUrl}/properties/${propertyId}/documents/owner-document',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class UploadPropertyCertificationCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Upload Property Certification',
      apiUrl:
          '${baseUrl}/properties/${propertyId}/documents/property-certification',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class CreatePropertyBasicSALEAndRENTCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? name = '',
    String? address = '',
    double? longitude,
    double? latitude,
    String? finca = '',
    String? follio = '',
    String? libro = '',
    double? salePrice,
    double? maintenanceFee,
    double? singlePropertyTax,
    double? monthlyRent,
    int? minimumTimeRent,
    String? othersRent = '',
    bool? isCompanyOwned,
    String? companyName = '',
    String? legalRepresentative = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "listingType": [
    "SALE",
    "RENT"
  ],
  "name": "${escapeStringForJson(name)}",
  "address": "${escapeStringForJson(address)}",
  "geoLocation": {
    "longitude": ${longitude},
    "latitude": ${latitude}
  },
  "legalInfo": {
    "finca": "${escapeStringForJson(finca)}",
    "folio": "${escapeStringForJson(follio)}",
    "libro": "${escapeStringForJson(libro)}"
  },
  "saleInfo": {
    "salePrice": ${salePrice},
    "maintenanceFee": ${maintenanceFee},
    "singlePropertyTax": ${singlePropertyTax}
  },
  "rentInfo": {
    "monthlyRent": ${monthlyRent},
    "rentalConditions": {
      "minimumTime": ${minimumTimeRent},
      "others": "${escapeStringForJson(othersRent)}"
    }
  },
  "ownership": {
    "isCompanyOwned": ${isCompanyOwned},
    "companyName": "${escapeStringForJson(companyName)}",
    "legalRepresentative": "${escapeStringForJson(legalRepresentative)}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Property Basic SALE and RENT',
      apiUrl: '${baseUrl}/properties/basic',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class CreatePropertyBasicRENTCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? name = '',
    String? address = '',
    double? longitude,
    double? latitude,
    String? finca = '',
    String? follio = '',
    String? libro = '',
    double? monthlyRent,
    int? minimumTimeRent,
    String? othersRent = '',
    bool? isCompanyOwned,
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "listingType": [
    "RENT"
  ],
  "name": "${escapeStringForJson(name)}",
  "address": "${escapeStringForJson(address)}",
  "geoLocation": {
    "longitude": ${longitude},
    "latitude": ${latitude}
  },
  "legalInfo": {
    "finca": "${escapeStringForJson(finca)}",
    "folio": "${escapeStringForJson(follio)}",
    "libro": "${escapeStringForJson(libro)}"
  },
  "rentInfo": {
    "monthlyRent": ${monthlyRent},
    "rentalConditions": {
      "minimumTime": ${minimumTimeRent},
      "others": "${escapeStringForJson(othersRent)}"
    }
  },
  "ownership": {
    "isCompanyOwned": ${isCompanyOwned}
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Property Basic RENT',
      apiUrl: '${baseUrl}/properties/basic',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

  String? propertyId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.property.id''',
      ));
}

class CreatePropertyBasicSALECall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? name = '',
    String? address = '',
    double? longitude,
    double? latitude,
    String? finca = '',
    String? follio = '',
    String? libro = '',
    int? salePrice,
    int? maintenanceFee,
    int? singlePropertyTax,
    bool? isCompanyOwned,
    String? companyName = '',
    String? legalRepresentative = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "listingType": [
    "SALE"
  ],
  "name": "${escapeStringForJson(name)}",
  "address": "${escapeStringForJson(address)}",
  "geoLocation": {
    "longitude": ${longitude},
    "latitude": ${latitude}
  },
  "legalInfo": {
    "finca": "${escapeStringForJson(finca)}",
    "folio": "${escapeStringForJson(follio)}",
    "libro": "${escapeStringForJson(libro)}"
  },
  "saleInfo": {
    "salePrice": ${salePrice},
    "maintenanceFee": ${maintenanceFee},
    "singlePropertyTax": ${singlePropertyTax}
  },
  "ownership": {
    "isCompanyOwned": ${isCompanyOwned},
    "companyName": "${escapeStringForJson(companyName)}",
    "legalRepresentative": "${escapeStringForJson(legalRepresentative)}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Property Basic SALE',
      apiUrl: '${baseUrl}/properties/basic',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

  String? propertyId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.property.id''',
      ));
}

class ListPropertiesCall {
  Future<ApiCallResponse> call({
    String? page = '',
    String? limit = '',
    String? propertyType = '',
    String? minPrice = '',
    String? maxPrice = '',
    String? location = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Properties',
      apiUrl: '${baseUrl}/properties',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
      },
      params: {
        'page': page,
        'limit': limit,
        'propertyType': propertyType,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'location': location,
        'status': "PUBLISHED",
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
  List<String>? itemId(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? itemName(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List? itemListingType(dynamic response) => getJsonField(
        response,
        r'''$.data[:].listingType''',
        true,
      ) as List?;
  List<String>? itemPropertyType(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].propertyType''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? itemDescription(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].description.raw''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<int>? itemPrice(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].price''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<bool>? itemIsFavorite(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].isFavorite''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<bool>(x))
          .withoutNulls
          .toList();
  List<String>? itemFullAdress(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].location.address.fullAddress''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<bool>? itemIsCompanyOwner(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].ownership.isCompanyOwned''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<bool>(x))
          .withoutNulls
          .toList();
  String? itemCompanyName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].ownership.companyName''',
      ));
}

class GetPropertiesForMapCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Properties for Map',
      apiUrl: '${baseUrl}/properties/map',
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

class GetPropertiesForHomeCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Properties for Home',
      apiUrl: '${baseUrl}/properties/home',
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

class GetMyPropertiesCall {
  Future<ApiCallResponse> call({
    String? page = '',
    String? limit = '',
    String? status = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get My Properties',
      apiUrl: '${baseUrl}/properties/my-properties',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
      },
      params: {
        'page': page,
        'limit': limit,
        'status': status,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
  List<String>? itemId(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? itemName(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<int>? itemPrice(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].price''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<bool>? itemIsFavorite(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].isFavorite''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<bool>(x))
          .withoutNulls
          .toList();
  List<String>? itemPropertyType(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].propertyType''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List? itemListingType(dynamic response) => getJsonField(
        response,
        r'''$.data[:].listingType''',
        true,
      ) as List?;
  List<String>? itemStatus(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].status''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<bool>? itemIsActive(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].active''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<bool>(x))
          .withoutNulls
          .toList();
  List? itemSaleInfo(dynamic response) => getJsonField(
        response,
        r'''$.data[:].saleInfo''',
        true,
      ) as List?;
}

class GetPropertyByIDCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Property by ID',
      apiUrl: '${baseUrl}/properties/${propertyId}',
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

  bool? isFavorite(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.data.isFavorite''',
      ));
  int? price(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.data.price''',
      ));
  int? singlePropertyTax(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.data.saleInfo.singlePropertyTax''',
      ));
  int? amountToReceive(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.data.saleInfo.amountToReceive''',
      ));
  int? salePrice(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.data.saleInfo.salePrice''',
      ));
  dynamic? saleInfo(dynamic response) => getJsonField(
        response,
        r'''$.data.data.saleInfo''',
      );
  int? maintenanceFee(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.data.saleInfo.maintenanceFee''',
      ));
  String? showingConsiderations(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.data.infoHQ.showingConsiderations''',
      ));
  String? image(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.data.image''',
      ));
  List<String>? imgHabitacion(dynamic response) => (getJsonField(
        response,
        r'''$.data.data.images.habitacion''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? imgCocina(dynamic response) => (getJsonField(
        response,
        r'''$.data.data.images.cocina''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? imgTerraza(dynamic response) => (getJsonField(
        response,
        r'''$.data.data.images.terraza''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class UpdatePropertyCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Property',
      apiUrl: '${baseUrl}/properties/${propertyId}',
      callType: ApiCallType.PATCH,
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

class UploadPropertyDocumentCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? documentType = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Upload Property Document',
      apiUrl: '${baseUrl}/properties/${propertyId}/documents/${documentType}',
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

class CompletePropertyHardcodedTEMPCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Complete Property (Hardcoded - TEMP)',
      apiUrl: '${baseUrl}/property/hard/completing-property/${propertyId}',
      callType: ApiCallType.POST,
      headers: {},
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

/// End DOVIA API - Property Context Group Code

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
}

class GetAuthenticatedUserProfileCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Authenticated User Profile',
      apiUrl: '${baseUrl}/users/me',
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

class ListUsersByRoleCall {
  Future<ApiCallResponse> call({
    String? role = '',
    String? page = '',
    String? limit = '',
  }) async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Users by Role',
      apiUrl: '${baseUrl}/users',
      callType: ApiCallType.GET,
      headers: {},
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
      apiUrl: '${baseUrl}/users/${userId}',
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

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update User Preferences NEW',
      apiUrl: '${baseUrl}/users/${userId}/preferences',
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

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Upload User Document',
      apiUrl: '${baseUrl}/users/${userId}/documents/${documentType}',
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
  Future<ApiCallResponse> call() async {
    final baseUrl = DOVIAAPIUserContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Upload Profile Picture',
      apiUrl: '${baseUrl}/users/profile-picture',
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

/// End DOVIA API - User Context Group Code

/// Start DOVIA API - Visit Context Group Code

class DOVIAAPIVisitContextGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};
  static CreateVisitRequestCall createVisitRequestCall =
      CreateVisitRequestCall();
  static CreateOperativeListingVisitCall createOperativeListingVisitCall =
      CreateOperativeListingVisitCall();
  static UploadSignedContractCall uploadSignedContractCall =
      UploadSignedContractCall();
  static UpdateVisitInstructionsCall updateVisitInstructionsCall =
      UpdateVisitInstructionsCall();
}

class CreateVisitRequestCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    String? dateOne = '',
    String? hourOne = '',
    String? dateTwo = '',
    String? hourTwo = '',
    String? dateThree = '0000-00-00',
    String? hourThree = '00:00',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "proposedTimeSlots": [
    {
      "date": "${escapeStringForJson(dateOne)}",
      "time": "${escapeStringForJson(hourOne)}"
    },
    {
      "date": "${escapeStringForJson(dateTwo)}",
      "time": "${escapeStringForJson(hourTwo)}"
    },
    {
      "date": "${escapeStringForJson(dateThree)}",
      "time": "${escapeStringForJson(hourThree)}"
    }
  ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Visit Request',
      apiUrl: '${baseUrl}/visits/properties/${propertyId}/visit-requests',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${authToken}',
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

class CreateOperativeListingVisitCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Operative Listing Visit',
      apiUrl:
          '${baseUrl}/visits/properties/${propertyId}/operative-listing-visits',
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

class UploadSignedContractCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Upload Signed Contract',
      apiUrl: '${baseUrl}/visits/${visitId}/documents/signed-contract',
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

class UpdateVisitInstructionsCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Visit Instructions',
      apiUrl: '${baseUrl}/visits/${visitId}/instructions',
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

/// End DOVIA API - Visit Context Group Code

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
      apiUrl: '${baseUrl}/metrics/properties/${propertyId}/view',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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
      apiUrl: '${baseUrl}/metrics/properties/${propertyId}/interact',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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
      apiUrl: '${baseUrl}/metrics/properties/${propertyId}/statistics',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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
      apiUrl: '${baseUrl}/recruitment/settings',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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

    final ffApiRequestBody = '''
{
  "workingDays": [
    "MONDAY"
  ],
  "startHour": 9,
  "endHour": 17
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Recruitment Settings',
      apiUrl: '${baseUrl}/recruitment/settings',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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
      apiUrl: '${baseUrl}/recruitment/slots',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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

    final ffApiRequestBody = '''
{
  "scheduledAt": "2026-02-15T10:00:00Z"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create First Contact',
      apiUrl: '${baseUrl}/recruitment/appointments/first-contact',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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
      apiUrl: '${baseUrl}/settings',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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
      apiUrl: '${baseUrl}/settings/${settingKey}',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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

    final ffApiRequestBody = '''
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
      apiUrl: '${baseUrl}/settings/${settingKey}',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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
      apiUrl: '${baseUrl}/settings/${settingKey}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${bearerAuth}',
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

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
