import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_config.dart';

/// Start DOVIA API - Legal Process Context Group Code

class DOVIAAPILegalProcessContextGroup {
  static String getBaseUrl() => kApiBaseUrl;
  static Map<String, String> headers = {};

  static ListLegalProcessesAssociateCall listLegalProcessesAssociateCall =
      ListLegalProcessesAssociateCall();
  static ListLegalProcessesHQCall listLegalProcessesHQCall =
      ListLegalProcessesHQCall();
  static ListLegalProcessesHQUnassignedCall listLegalProcessesHQUnassignedCall =
      ListLegalProcessesHQUnassignedCall();
  static AcceptLegalHQProcessCall acceptLegalHQProcessCall =
      AcceptLegalHQProcessCall();
  static ListLegalHQDocumentsCall listLegalHQDocumentsCall =
      ListLegalHQDocumentsCall();
  static ListLegalProcessesListerHQCall listLegalProcessesListerHQCall =
      ListLegalProcessesListerHQCall();
  static ListListerHQDocumentsCall listListerHQDocumentsCall =
      ListListerHQDocumentsCall();
  static GetListerHQLegalProcessOverviewCall
      getListerHQLegalProcessOverviewCall =
      GetListerHQLegalProcessOverviewCall();
  static GetLegalProcessByIDCall getLegalProcessByIDCall =
      GetLegalProcessByIDCall();
  static StartLegalProcessCall startLegalProcessCall = StartLegalProcessCall();
  static CreateLegalProcessDocumentCall createLegalProcessDocumentCall =
      CreateLegalProcessDocumentCall();
  static UploadLegalProcessDocumentCall uploadLegalProcessDocumentCall =
      UploadLegalProcessDocumentCall();
  static ReviewLegalProcessDocumentCall reviewLegalProcessDocumentCall =
      ReviewLegalProcessDocumentCall();
  static DeleteLegalProcessDocumentCall deleteLegalProcessDocumentCall =
      DeleteLegalProcessDocumentCall();
  static UploadPaymentProofCall uploadPaymentProofCall =
      UploadPaymentProofCall();
  static AdvanceToDraftingCall advanceToDraftingCall = AdvanceToDraftingCall();
  static UploadUnsignedContractCall uploadUnsignedContractCall =
      UploadUnsignedContractCall();
  static AdvanceToMeetingCoordinationCall advanceToMeetingCoordinationCall =
      AdvanceToMeetingCoordinationCall();
  static ScheduleAppointmentCall scheduleAppointmentCall =
      ScheduleAppointmentCall();
  static RescheduleAppointmentCall rescheduleAppointmentCall =
      RescheduleAppointmentCall();
  static CancelAppointmentCall cancelAppointmentCall = CancelAppointmentCall();
  static UploadSignedContractCall uploadSignedContractCall =
      UploadSignedContractCall();
  static SubmitToHQReviewCall submitToHQReviewCall = SubmitToHQReviewCall();
  static ResubmitToHQReviewCall resubmitToHQReviewCall =
      ResubmitToHQReviewCall();
  static ResubmitToHQReviewListerHQCall resubmitToHQReviewListerHQCall =
      ResubmitToHQReviewListerHQCall();
  static HQReviewDocumentCall hqReviewDocumentCall = HQReviewDocumentCall();
  static MortgageUpdateStatusCall mortgageUpdateStatusCall =
      MortgageUpdateStatusCall();
  static MortgageUploadUnsignedAgreementCall
      mortgageUploadUnsignedAgreementCall =
      MortgageUploadUnsignedAgreementCall();
  static MortgageCompleteDocumentsCall mortgageCompleteDocumentsCall =
      MortgageCompleteDocumentsCall();
  static MortgageFinishCall mortgageFinishCall = MortgageFinishCall();
  static FinishLegalProcessCall finishLegalProcessCall =
      FinishLegalProcessCall();
}

/// GET /legal-processes/associate
/// Roles: LEGAL_ASSOCIATE
class ListLegalProcessesAssociateCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? page = '',
    String? limit = '',
    String? status = '',
    String? category = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Legal Processes (Associate)',
      apiUrl: '$baseUrl/legal-processes/associate',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null && page.isNotEmpty) 'page': page,
        if (limit != null && limit.isNotEmpty) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (category != null && category.isNotEmpty) 'category': category,
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

/// GET /legal-processes/legal-hq
/// Roles: LEGAL_OFFICER
class ListLegalProcessesHQCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? page = '',
    String? limit = '',
    String? status = '',
    String? category = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Legal Processes (HQ)',
      apiUrl: '$baseUrl/legal-processes/legal-hq',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null && page.isNotEmpty) 'page': page,
        if (limit != null && limit.isNotEmpty) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (category != null && category.isNotEmpty) 'category': category,
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

/// GET /legal-processes/legal-hq/unassigned
/// Roles: LEGAL_OFFICER — procesos todavía sin `legalHqId` que el HQ puede
/// reclamar con `POST /legal-processes/{processId}/legal-hq/accept`.
class ListLegalProcessesHQUnassignedCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? page = '',
    String? limit = '',
    String? status = '',
    String? category = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Legal Processes (HQ Unassigned)',
      apiUrl: '$baseUrl/legal-processes/legal-hq/unassigned',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null && page.isNotEmpty) 'page': page,
        if (limit != null && limit.isNotEmpty) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (category != null && category.isNotEmpty) 'category': category,
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

/// POST /legal-processes/{processId}/legal-hq/accept
/// Roles: LEGAL_OFFICER — autoasigna el proceso al HQ autenticado. Sin este
/// paso el HQ recibe 403 USER_NOT_RELATED_TO_PROCESS al abrir el expediente.
/// 409 LEGAL_PROCESS_LEGAL_HQ_ALREADY_ASSIGNED si otro HQ lo reclamó antes.
class AcceptLegalHQProcessCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Accept Legal HQ Process',
      apiUrl: '$baseUrl/legal-processes/$processId/legal-hq/accept',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// GET /legal-processes/legal-hq/documents
/// Roles: LEGAL_OFFICER — procesos asignados al HQ con su checklist de documentos
class ListLegalHQDocumentsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? page = '',
    String? limit = '',
    String? status = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Legal HQ Documents',
      apiUrl: '$baseUrl/legal-processes/legal-hq/documents',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null && page.isNotEmpty) 'page': page,
        if (limit != null && limit.isNotEmpty) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
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

/// GET /legal-processes/lister-hq
/// Roles: LISTING_HQ
class ListLegalProcessesListerHQCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? page = '',
    String? limit = '',
    String? status = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Legal Processes (Lister HQ)',
      apiUrl: '$baseUrl/legal-processes/lister-hq',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null && page.isNotEmpty) 'page': page,
        if (limit != null && limit.isNotEmpty) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
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

/// GET /legal-processes/lister-hq/documents
/// Roles: LISTER_HQ — procesos PUBLICATION asignados con su checklist de documentos
class ListListerHQDocumentsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? page = '',
    String? limit = '',
    String? status = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Lister HQ Documents',
      apiUrl: '$baseUrl/legal-processes/lister-hq/documents',
      callType: ApiCallType.GET,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null && page.isNotEmpty) 'page': page,
        if (limit != null && limit.isNotEmpty) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
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

/// GET /legal-processes/{processId}/lister-hq/overview
/// Roles: LISTER_HQ — overview de un proceso PUBLICATION rechazado asignado
class GetListerHQLegalProcessOverviewCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Lister HQ Legal Process Overview',
      apiUrl: '$baseUrl/legal-processes/$processId/lister-hq/overview',
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

/// GET /legal-processes/{processId}
/// Roles: LEGAL_OFFICER, LEGAL_ASSOCIATE
class GetLegalProcessByIDCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Legal Process by ID',
      apiUrl: '$baseUrl/legal-processes/$processId',
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

/// POST /legal-processes/{processId}/start
/// Roles: LEGAL_ASSOCIATE
class StartLegalProcessCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Start Legal Process',
      apiUrl: '$baseUrl/legal-processes/$processId/start',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// POST /legal-processes/{processId}/documents
/// Roles: LEGAL_ASSOCIATE — crea un documento CUSTOM subiendo 1 archivo
class CreateLegalProcessDocumentCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Create Legal Process Document',
      apiUrl: '$baseUrl/legal-processes/$processId/documents',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// PUT /legal-processes/{processId}/documents/{documentId}/upload
/// Roles: LEGAL_ASSOCIATE — sube o reemplaza el archivo de un documento existente
class UploadLegalProcessDocumentCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? documentId = '',
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Upload Legal Process Document',
      apiUrl:
          '$baseUrl/legal-processes/$processId/documents/$documentId/upload',
      callType: ApiCallType.PUT,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// PUT /legal-processes/{processId}/documents/{documentId}/review
/// Roles: LEGAL_ASSOCIATE — aprueba o rechaza un documento
class ReviewLegalProcessDocumentCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? documentId = '',
    String? authToken = '',
    String? status = '',
    String? note = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'status': status,
      if (note != null && note.isNotEmpty) 'note': note,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Review Legal Process Document',
      apiUrl:
          '$baseUrl/legal-processes/$processId/documents/$documentId/review',
      callType: ApiCallType.PUT,
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

/// DELETE /legal-processes/{processId}/documents/{documentId}
/// Roles: LEGAL_ASSOCIATE — elimina un documento CUSTOM
class DeleteLegalProcessDocumentCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? documentId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Legal Process Document',
      apiUrl: '$baseUrl/legal-processes/$processId/documents/$documentId',
      callType: ApiCallType.DELETE,
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

/// POST /legal-processes/{processId}/payment-proof
/// Roles: CLIENT, LEGAL_ASSOCIATE — sube el comprobante de pago de comisión
class UploadPaymentProofCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Upload Payment Proof',
      apiUrl: '$baseUrl/legal-processes/$processId/payment-proof',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// POST /legal-processes/{processId}/advance-to-drafting
/// Roles: LEGAL_ASSOCIATE
class AdvanceToDraftingCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Advance to Drafting',
      apiUrl: '$baseUrl/legal-processes/$processId/advance-to-drafting',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// PUT /legal-processes/{processId}/unsigned-contract
/// Roles: LEGAL_ASSOCIATE — disponible solo en estado DRAFTING
class UploadUnsignedContractCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Upload Unsigned Contract',
      apiUrl: '$baseUrl/legal-processes/$processId/unsigned-contract',
      callType: ApiCallType.PUT,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// POST /legal-processes/{processId}/advance-to-meeting-coordination
/// Roles: LEGAL_ASSOCIATE — requiere que unsignedContractUrl exista
class AdvanceToMeetingCoordinationCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Advance to Meeting Coordination',
      apiUrl:
          '$baseUrl/legal-processes/$processId/advance-to-meeting-coordination',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// POST /legal-processes/{processId}/appointments
/// Roles: LEGAL_ASSOCIATE
class ScheduleAppointmentCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
    String? scheduledAt = '',
    String? address = '',
    String? arrivalInstructions = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'scheduledAt': scheduledAt,
      if (address != null && address.isNotEmpty) 'address': address,
      if (arrivalInstructions != null && arrivalInstructions.isNotEmpty)
        'arrivalInstructions': arrivalInstructions,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Schedule Appointment',
      apiUrl: '$baseUrl/legal-processes/$processId/appointments',
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

/// PUT /legal-processes/{processId}/appointments/{appointmentId}/reschedule
/// Roles: LEGAL_ASSOCIATE
class RescheduleAppointmentCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? appointmentId = '',
    String? authToken = '',
    String? newScheduledAt = '',
    String? address = '',
    String? arrivalInstructions = '',
    String? cancelReason = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'newScheduledAt': newScheduledAt,
      if (address != null && address.isNotEmpty) 'address': address,
      if (arrivalInstructions != null && arrivalInstructions.isNotEmpty)
        'arrivalInstructions': arrivalInstructions,
      if (cancelReason != null && cancelReason.isNotEmpty)
        'cancelReason': cancelReason,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Reschedule Appointment',
      apiUrl:
          '$baseUrl/legal-processes/$processId/appointments/$appointmentId/reschedule',
      callType: ApiCallType.PUT,
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

/// POST /legal-processes/{processId}/appointments/{appointmentId}/cancel
/// Roles: LEGAL_ASSOCIATE
class CancelAppointmentCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? appointmentId = '',
    String? authToken = '',
    String? cancelReason = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      if (cancelReason != null && cancelReason.isNotEmpty)
        'cancelReason': cancelReason,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Cancel Appointment',
      apiUrl:
          '$baseUrl/legal-processes/$processId/appointments/$appointmentId/cancel',
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

/// POST /legal-processes/{processId}/signed-contract
/// Roles: LEGAL_ASSOCIATE — disponible solo en estado MEETING_SCHEDULED
class UploadSignedContractCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Upload Signed Contract',
      apiUrl: '$baseUrl/legal-processes/$processId/signed-contract',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// POST /legal-processes/{processId}/submit-to-hq-review
/// Roles: LEGAL_ASSOCIATE — body opcional `{ meetingNotes }` con las notas de
/// la reunión de firma (vacío se guarda como `null`).
class SubmitToHQReviewCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
    String? meetingNotes,
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Submit to HQ Review',
      apiUrl: '$baseUrl/legal-processes/$processId/submit-to-hq-review',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: jsonEncode({
        if (meetingNotes != null && meetingNotes.trim().isNotEmpty)
          'meetingNotes': meetingNotes.trim(),
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

/// POST /legal-processes/{processId}/resubmit-to-hq-review
/// Roles: LEGAL_ASSOCIATE — solo cuando el proceso está en REJECTED y todos los docs != missing/rejected
class ResubmitToHQReviewCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Resubmit to HQ Review',
      apiUrl: '$baseUrl/legal-processes/$processId/resubmit-to-hq-review',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// PUT /legal-processes/{processId}/documents/{documentId}/hq-review
/// Roles: LEGAL_OFFICER — aprueba o rechaza un documento en revisión HQ
class HQReviewDocumentCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? documentId = '',
    String? authToken = '',
    String? status = '',
    String? note = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'status': status,
      if (note != null && note.isNotEmpty) 'note': note,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'HQ Review Document',
      apiUrl:
          '$baseUrl/legal-processes/$processId/documents/$documentId/hq-review',
      callType: ApiCallType.PUT,
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

/// POST /legal-processes/{processId}/lister-hq/resubmit-to-hq-review
/// Roles: LISTING_HQ
class ResubmitToHQReviewListerHQCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Resubmit to HQ Review (Lister HQ)',
      apiUrl:
          '$baseUrl/legal-processes/$processId/lister-hq/resubmit-to-hq-review',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// PUT /legal-processes/{processId}/mortgage/status
/// Roles: LEGAL_OFFICER asignado — única transición del flujo SALE_MORTGAGE.
///
/// `status` acepta BANK_MANAGEMENT_STARTED | BANK_DOCUMENTATION_SUBMITTED |
/// BANK_EVALUATION | APPROVED | REJECTED; `FINISHED` no se acepta acá, se
/// cierra con `POST .../mortgage/finish`. Requiere `documentsComplete=true` y
/// rechaza repetir el estado actual. `note` es opcional, pero el backend
/// rechaza la cadena vacía: por eso se omite del body cuando no hay texto.
class MortgageUpdateStatusCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
    String? status = '',
    String? note = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'status': status,
      if (note != null && note.isNotEmpty) 'note': note,
    });

    return ApiManager.instance.makeApiCall(
      callName: 'Mortgage Update Status',
      apiUrl: '$baseUrl/legal-processes/$processId/mortgage/status',
      callType: ApiCallType.PUT,
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

/// POST /legal-processes/{processId}/mortgage/unsigned-agreement
/// Roles: LEGAL_OFFICER asignado — crea o reemplaza `DOVIA_AGREEMENT_UNSIGNED`.
/// Solo antes de `documentsComplete=true`.
class MortgageUploadUnsignedAgreementCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Mortgage Upload Unsigned Agreement',
      apiUrl: '$baseUrl/legal-processes/$processId/mortgage/unsigned-agreement',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
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

/// POST /legal-processes/{processId}/mortgage/documents/complete
/// Roles: LEGAL_OFFICER asignado — confirma los seis documentos obligatorios.
///
/// Es **irreversible**: marca `documentsComplete=true`, congela los
/// obligatorios y habilita las transiciones de `mortgage/status`.
class MortgageCompleteDocumentsCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Mortgage Complete Documents',
      apiUrl: '$baseUrl/legal-processes/$processId/mortgage/documents/complete',
      callType: ApiCallType.POST,
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

/// POST /legal-processes/{processId}/mortgage/finish
/// Roles: LEGAL_OFFICER asignado — cierra `APPROVED -> FINISHED`.
///
/// Exige comprobante de pago cargado. Completa la oferta y deja la propiedad
/// en `SOLD`, lo que auto-rechaza el resto de ofertas pendientes.
class MortgageFinishCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Mortgage Finish',
      apiUrl: '$baseUrl/legal-processes/$processId/mortgage/finish',
      callType: ApiCallType.POST,
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

/// POST /legal-processes/{processId}/finish
/// Roles: LEGAL_ASSOCIATE o LEGAL_OFFICER asignado — cierra un `SALE`/`RENT`
/// `APPROVED -> FINISHED`.
///
/// Exige un `DOVIA_PAYMENT_PROOF` con archivo (lo sube el cliente). Completa
/// la oferta y deja la propiedad en `SOLD` o `RENTED`.
class FinishLegalProcessCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Finish Legal Process',
      apiUrl: '$baseUrl/legal-processes/$processId/finish',
      callType: ApiCallType.POST,
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

/// End DOVIA API - Legal Process Context Group Code
