import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

/// Start DOVIA API - Legal Process Context Group Code

class DOVIAAPILegalProcessContextGroup {
  static String getBaseUrl() =>
      'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';
  static Map<String, String> headers = {};

  static ListLegalProcessesAssociateCall listLegalProcessesAssociateCall =
      ListLegalProcessesAssociateCall();
  static ListLegalProcessesHQCall listLegalProcessesHQCall =
      ListLegalProcessesHQCall();
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
  static HQReviewDocumentCall hqReviewDocumentCall = HQReviewDocumentCall();
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
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'scheduledAt': scheduledAt,
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
    String? cancelReason = '',
  }) async {
    final baseUrl = DOVIAAPILegalProcessContextGroup.getBaseUrl();

    final ffApiRequestBody = jsonEncode({
      'newScheduledAt': newScheduledAt,
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
/// Roles: LEGAL_ASSOCIATE
class SubmitToHQReviewCall {
  Future<ApiCallResponse> call({
    String? processId = '',
    String? authToken = '',
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

/// End DOVIA API - Legal Process Context Group Code
