import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_config.dart';
import 'api_helpers.dart';

/// Start DOVIA API - Property Context Group Code

class DOVIAAPIPropertyContextGroup {
  static String getBaseUrl() => kApiBaseUrl;
  static Map<String, String> headers = {};
  static UploadPropertyOwnerIDDocumentCall uploadPropertyOwnerIDDocumentCall =
      UploadPropertyOwnerIDDocumentCall();
  static UploadPropertyCertificationCall uploadPropertyCertificationCall =
      UploadPropertyCertificationCall();
  static CreatePropertyBasicCall createPropertyBasicCall =
      CreatePropertyBasicCall();
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
  static GetPropertyBackofficeCall getPropertyBackofficeCall =
      GetPropertyBackofficeCall();
  static ChangePropertyStatusCall changePropertyStatusCall =
      ChangePropertyStatusCall();
  static GetPublishableZonesCall getPublishableZonesCall =
      GetPublishableZonesCall();
  static PresignPropertyImagesCall presignPropertyImagesCall =
      PresignPropertyImagesCall();
  static ConfirmPropertyImagesCall confirmPropertyImagesCall =
      ConfirmPropertyImagesCall();
  static PresignPropertyDocumentsCall presignPropertyDocumentsCall =
      PresignPropertyDocumentsCall();
  static ConfirmPropertyDocumentsCall confirmPropertyDocumentsCall =
      ConfirmPropertyDocumentsCall();
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
      apiUrl: '$baseUrl/properties/$propertyId/documents/owner-document',
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
          '$baseUrl/properties/$propertyId/documents/property-certification',
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
}

/// `POST /properties/basic`: crea la propiedad en DRAFT. El body lo arma
/// `buildCreatePropertyBody` (venta, renta o ambas y la titularidad).
class CreatePropertyBasicCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    required Map<String, dynamic> body,
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Create Property Basic',
      apiUrl: '$baseUrl/properties/basic',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: jsonEncode(body),
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
  /// [isMock]: `'true'` sólo los proyectos del sitio externo de desarrollos,
  /// `'false'` sólo inventario real (incluye registros viejos sin el campo).
  /// Sin pasarlo vienen los dos.
  Future<ApiCallResponse> call({
    String? page = '',
    String? limit = '',
    String? propertyType = '',
    String? minPrice = '',
    String? maxPrice = '',
    String? location = '',
    String? isMock,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Properties',
      apiUrl: '$baseUrl/properties',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {
        'page': page,
        'limit': limit,
        'propertyType': propertyType,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'location': location,
        'status': "PUBLISHED",
        if (isMock != null) 'isMock': isMock,
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
      apiUrl: '$baseUrl/properties/map',
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
      apiUrl: '$baseUrl/properties/home',
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
      apiUrl: '$baseUrl/properties/my-properties',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
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
      apiUrl: '$baseUrl/properties/$propertyId',
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
  dynamic saleInfo(dynamic response) => getJsonField(
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
  List<String>? imgPlanos(dynamic response) => (getJsonField(
        response,
        r'''$.data.data.images.planos''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  String? video360Url(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.data.video360Url''',
      ));
}

class UpdatePropertyCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    String? name,
    String? description,
    List<String>? listingType,
    String? propertyType,
    dynamic location,
    dynamic legalInfo,
    dynamic ownership,
    double? salePrice,
    double? maintenanceFee,
    double? singlePropertyTax,
    double? monthlyRent,
    int? minimumTimeRent,
    String? othersRent,
    String? allowedUses,
    String? availableFrom,
    dynamic features,
    dynamic infoHQ,
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    final Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (propertyType != null) body['propertyType'] = propertyType;
    if (location != null) body['location'] = location;
    if (legalInfo != null) body['legalInfo'] = legalInfo;
    if (ownership != null) body['ownership'] = ownership;
    if (features != null) body['features'] = features;
    if (infoHQ != null) body['infoHQ'] = infoHQ;

    if (listingType != null && listingType.isNotEmpty) {
      body['listingType'] = listingType;
    }

    final bool hasSale = listingType?.contains('SALE') == true ||
        salePrice != null ||
        maintenanceFee != null ||
        singlePropertyTax != null;
    final bool hasRent = listingType?.contains('RENT') == true ||
        monthlyRent != null ||
        minimumTimeRent != null ||
        othersRent != null ||
        allowedUses != null ||
        availableFrom != null;

    if (hasSale) {
      final Map<String, dynamic> saleInfo = {};
      if (salePrice != null) saleInfo['salePrice'] = salePrice;
      if (maintenanceFee != null) saleInfo['maintenanceFee'] = maintenanceFee;
      if (singlePropertyTax != null)
        saleInfo['singlePropertyTax'] = singlePropertyTax;
      if (saleInfo.isNotEmpty) body['saleInfo'] = saleInfo;
    }

    if (hasRent) {
      final Map<String, dynamic> rentInfo = {};
      if (monthlyRent != null) rentInfo['monthlyRent'] = monthlyRent;
      final Map<String, dynamic> conditions = {};
      if (minimumTimeRent != null) conditions['minimumTime'] = minimumTimeRent;
      if (othersRent?.isNotEmpty == true) conditions['others'] = othersRent;
      if (allowedUses?.isNotEmpty == true)
        conditions['allowedUses'] = allowedUses;
      if (availableFrom?.isNotEmpty == true)
        conditions['availableFrom'] = availableFrom;
      if (conditions.isNotEmpty) rentInfo['rentalConditions'] = conditions;
      if (rentInfo.isNotEmpty) body['rentInfo'] = rentInfo;
    }

    final ffApiRequestBody = jsonEncode(body);
    return ApiManager.instance.makeApiCall(
      callName: 'Update Property',
      apiUrl: '$baseUrl/properties/$propertyId',
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

class UploadPropertyDocumentCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? documentType = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    const ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Upload Property Document',
      apiUrl: '$baseUrl/properties/$propertyId/documents/$documentType',
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
      apiUrl: '$baseUrl/property/hard/completing-property/$propertyId',
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

class GetPropertyBackofficeCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Property Backoffice',
      apiUrl: '$baseUrl/properties/$propertyId/backoffice',
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
}

class ChangePropertyStatusCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? status = '',
    String? authToken = '',
    String? note, // optional, max 1000 chars — logged in event log
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    // API accepts: ARCHIVED (pause), DELETED (remove), PUBLISHED (reactivate)
    // `note` is optional — included only when provided
    final body = <String, dynamic>{'status': status};
    if (note != null && note.isNotEmpty) body['note'] = note;
    final ffApiRequestBody = jsonEncode(body);
    return ApiManager.instance.makeApiCall(
      callName: 'Change Property Status',
      apiUrl: '$baseUrl/properties/$propertyId/status',
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

class GetPublishableZonesCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Publishable Zones',
      apiUrl: '$baseUrl/properties/publishable-zones',
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
}

class PresignPropertyImagesCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    dynamic uploads,
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "uploads": ${serializeJson(uploads, true)}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Presign Property Images',
      apiUrl: '$baseUrl/properties/$propertyId/images/presign',
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

class ConfirmPropertyImagesCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    dynamic uploads,
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "uploads": ${serializeJson(uploads, true)}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Confirm Property Images',
      apiUrl: '$baseUrl/properties/$propertyId/images/confirm',
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

/// `POST /properties/{id}/documents/presign`: URLs para subir a S3 los
/// documentos de titularidad (identificación del propietario o del
/// representante y acta de nombramiento). Cada elemento de [uploads] lleva
/// `purpose`, `fileName`, `mimeType` y `size`.
class PresignPropertyDocumentsCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    required List<Map<String, dynamic>> uploads,
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Presign Property Documents',
      apiUrl: '$baseUrl/properties/$propertyId/documents/presign',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: jsonEncode({'uploads': uploads}),
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

/// `POST /properties/{id}/documents/confirm`: asocia a la propiedad los
/// archivos ya subidos. Solo se mandan los `uploadId`.
class ConfirmPropertyDocumentsCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    required List<String> uploadIds,
  }) async {
    final baseUrl = DOVIAAPIPropertyContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Confirm Property Documents',
      apiUrl: '$baseUrl/properties/$propertyId/documents/confirm',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: jsonEncode({
        'uploads': [
          for (final id in uploadIds) {'uploadId': id},
        ],
      }),
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
