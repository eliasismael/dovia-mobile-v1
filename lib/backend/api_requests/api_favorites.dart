import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_helpers.dart';

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
      apiUrl:
          '$baseUrl/favorites/$propertyId${folderId != null && folderId.isNotEmpty ? "?folderId=$folderId" : ""}',
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

class RemovePropertyFromFavoritesCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Remove Property from Favorites',
      apiUrl: '$baseUrl/favorites/$propertyId',
      callType: ApiCallType.DELETE,
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
      apiUrl: '$baseUrl/favorites',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
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
  dynamic meta(dynamic response) => getJsonField(
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
  dynamic metaPagination(dynamic response) => getJsonField(
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
  dynamic itemFeaturesGeneral(dynamic response) => getJsonField(
        response,
        r'''$.data[:].features.general''',
      );
  dynamic itemFeatures(dynamic response) => getJsonField(
        response,
        r'''$.data[:].features''',
      );
  dynamic itemDescription(dynamic response) => getJsonField(
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
  dynamic itemGeo(dynamic response) => getJsonField(
        response,
        r'''$.data[:].location.geo''',
      );
  String? itemFullAddress(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].location.address.fullAddress''',
      ));
  dynamic itemAddress(dynamic response) => getJsonField(
        response,
        r'''$.data[:].location.address''',
      );
  dynamic itemLocation(dynamic response) => getJsonField(
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
  dynamic itemSaleInfo(dynamic response) => getJsonField(
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
      apiUrl: '$baseUrl/favorites/check/$propertyId',
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

  dynamic data(dynamic response) => getJsonField(
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
      apiUrl: '$baseUrl/favorites/folders',
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
}

class GetAllFavoriteFoldersCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get All Favorite Folders',
      apiUrl: '$baseUrl/favorites/folders',
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
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "name": "${escapeStringForJson(udatedFolderName)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Favorite Folder Name',
      apiUrl: '$baseUrl/favorites/folders/$folderId',
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

class DeleteFavoriteFolderCall {
  Future<ApiCallResponse> call({
    String? folderId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIFavoriteContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Favorite Folder',
      apiUrl: '$baseUrl/favorites/folders/$folderId',
      callType: ApiCallType.DELETE,
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
      apiUrl: '$baseUrl/favorites/folders/$folderId/properties',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
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
      apiUrl: '$baseUrl/favorites/folders/$folderId/properties/$propertyId',
      callType: ApiCallType.DELETE,
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
      apiUrl: '$baseUrl/favorites/folders/$folderId/properties/$propertyId',
      callType: ApiCallType.POST,
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
}

/// End DOVIA API - Favorite Context Group Code
