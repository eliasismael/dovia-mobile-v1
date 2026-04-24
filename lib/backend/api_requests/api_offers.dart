import 'api_manager.dart';
import 'api_helpers.dart';

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
    "proposedAmount": $proposedAmount,
    "considerations": "${escapeStringForJson(considerations)}",
    "buyerInfo": {
      "type": "${escapeStringForJson(buyerType)}",
      "name": "${escapeStringForJson(buyerName)}",
      "legalName": "${escapeStringForJson(buyerLegalName)}",
      "legalRepresentative": "${escapeStringForJson(buyerLegalRepresentative)}"
    },
    "initialReserve": $initialReserve,
    "promiseTimeMonths": $promiseTimeMonths
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer - PURCHASE (Purchase Promise)',
      apiUrl: '$baseUrl/offers/properties/$propertyId',
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

class ListOffersByPropertyCall {
  Future<ApiCallResponse> call({
    String? page = '',
    String? limit = '',
    String? offerStatus = '',
    String? processStatus = '',
    String? propertyId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Offers by Property',
      apiUrl: '$baseUrl/offers/properties/$propertyId',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
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

    const ffApiRequestBody = '''
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
      apiUrl: '$baseUrl/offers/$offerId/counter-offer',
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
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Offer by ID',
      apiUrl: '$baseUrl/offers/$offerId',
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

class AcceptOfferCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    const ffApiRequestBody = '''
{
  "acceptedBy": "OWNER"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Accept Offer',
      apiUrl: '$baseUrl/offers/$offerId/accept',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

class RejectOfferCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
    String? authToken = '',
    String? reason = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "rejectedBy": "OWNER",
  "reason": "${reason?.isNotEmpty == true ? reason : 'Price does not meet expectations'}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Reject Offer',
      apiUrl: '$baseUrl/offers/$offerId/reject',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

class SelectLegalAssociateCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    const ffApiRequestBody = '''
{
  "legalAssociateId": "{{legalAssociateId}}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Select Legal Associate',
      apiUrl: '$baseUrl/offers/$offerId/select-legal-associate',
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

    const ffApiRequestBody = '''
{
  "banco": "Banco de Bogotá",
  "nombre": "María",
  "apellido": "González",
  "telefono": "+57 300 1234567",
  "email": "maria.gonzalez@bancobogota.com"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Submit Bank Agent Data',
      apiUrl: '$baseUrl/offers/$offerId/bank-agent-data',
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
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List My Offers',
      apiUrl: '$baseUrl/offers/my-offers',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
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
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Offers On My Properties',
      apiUrl: '$baseUrl/offers/my-properties',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
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
    String? propertyId = '',
    String? authToken = '',
    String? contractStartDate = '',
    String? contractEndDate = '',
    String? currency = '',
    double? proposedAmount,
    String? propertyUse = '',
    String? considerations = '',
    String? tenantType = '',
    String? tenantName = '',
    String? tenantLegalName = '',
    String? tenantRepresentative = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "offerType": "RENT",
  "offerData": {
    "contractStartDate": "${escapeStringForJson(contractStartDate)}",
    "contractEndDate": "${escapeStringForJson(contractEndDate)}",
    "currency": "${escapeStringForJson(currency)}",
    "propertyUse": "${escapeStringForJson(propertyUse)}",
    "considerations": "${escapeStringForJson(considerations)}",
    "proposedAmount": $proposedAmount,
    "tenantInfo": {
      "type": "${escapeStringForJson(tenantType)}",
      "name": "${escapeStringForJson(tenantName)}",
      "legalName": "${escapeStringForJson(tenantLegalName)}",
      "legalRepresentative": "${escapeStringForJson(tenantRepresentative)}"
    }
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer RENT Individual',
      apiUrl: '$baseUrl/offers/properties/$propertyId',
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

class CreateOfferRENTCompanyCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    const ffApiRequestBody = '''
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
      apiUrl: '$baseUrl/offers/properties/$propertyId',
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
    "proposedAmount": $proposedAmount,
    "considerations": "${escapeStringForJson(considerations)}",
    "buyerInfo": {
      "type": "${escapeStringForJson(buyerType)}",
      "name": "${escapeStringForJson(buyerName)}",
      "legalName": "${escapeStringForJson(legalName)}",
      "legalRepresentative": "${escapeStringForJson(legalRepresentative)}"
    },
    "downPaymentPercentage": $downPaymentPercentage,
    "bankName": "${escapeStringForJson(bankName)}",
    "creditStatus": "${escapeStringForJson(creditStatus)}",
    "estimatedApprovalTime": $estimatedApprovalTime
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer  PURCHASE Mortgage',
      apiUrl: '$baseUrl/offers/properties/$propertyId',
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

class MakeCounterOfferPURCHASEMortgageCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    const ffApiRequestBody = '''
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
      apiUrl: '$baseUrl/offers/$offerId/counter-offer',
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

    const ffApiRequestBody = '''
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
      apiUrl: '$baseUrl/offers/$offerId/counter-offer',
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
    "proposedAmount": $proposedAmount,
    "considerations": "${escapeStringForJson(considerations)}",
    "buyerInfo": {
      "type": "${escapeStringForJson(buyerType)}",
      "name": "${escapeStringForJson(buyerName)}",
      "legalName": "${escapeStringForJson(buyerLegalName)}",
      "legalRepresentative": "${escapeStringForJson(buyerRepresentative)}"
    },
    "estimatedPaymentTime": $estimatedPaymentTime
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Offer  PURCHASE Cash',
      apiUrl: '$baseUrl/offers/properties/$propertyId',
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

class MakeCounterOfferRENTCall {
  Future<ApiCallResponse> call({
    String? offerId = '',
  }) async {
    final baseUrl = DOVIAAPIOfferContextGroup.getBaseUrl();

    const ffApiRequestBody = '''
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
      apiUrl: '$baseUrl/offers/$offerId/counter-offer',
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
