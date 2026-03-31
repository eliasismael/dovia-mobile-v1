import '../schema/structs/index.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_helpers.dart';

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
  static HardScheduleVisitCall hardScheduleVisitCall = HardScheduleVisitCall();
  static GetMyVisitsCall getMyVisitsCall = GetMyVisitsCall();
  static GetVisitDetailsCall getVisitDetailsCall = GetVisitDetailsCall();
  static CancelVisitCall cancelVisitCall = CancelVisitCall();
  static RescheduleVisitCall rescheduleVisitCall = RescheduleVisitCall();
  static GetListerHqVisitsCall getListerHqVisitsCall = GetListerHqVisitsCall();
  static GetListerHqVisitDocumentsCall getListerHqVisitDocumentsCall =
      GetListerHqVisitDocumentsCall();
  static GetOperativeListerVisitsCall getOperativeListerVisitsCall =
      GetOperativeListerVisitsCall();
  static GetOperativeListerScheduleCall getOperativeListerScheduleCall =
      GetOperativeListerScheduleCall();
  static GetAdminOperativeListingVisitsCall getAdminOperativeListingVisitsCall =
      GetAdminOperativeListingVisitsCall();
  static AdminAssignListerHqCall adminAssignListerHqCall =
      AdminAssignListerHqCall();
  static UploadListerHqChecklistDocumentCall uploadListerHqChecklistDocumentCall =
      UploadListerHqChecklistDocumentCall();
  static ReviewChecklistDocumentsCall reviewChecklistDocumentsCall =
      ReviewChecklistDocumentsCall();
  static LegalApprovalCall legalApprovalCall = LegalApprovalCall();
  static AssignOperativeListerCall assignOperativeListerCall =
      AssignOperativeListerCall();
  static MarkVisitedCall markVisitedCall = MarkVisitedCall();
  static PublishPropertyAfterVisitCall publishPropertyAfterVisitCall =
      PublishPropertyAfterVisitCall();
  static GetOwnerPropertyVisitsCall getOwnerPropertyVisitsCall =
      GetOwnerPropertyVisitsCall();
  static OwnerConfirmSlotCall ownerConfirmSlotCall = OwnerConfirmSlotCall();
  static GetShowingAgentUnassignedVisitsCall
      getShowingAgentUnassignedVisitsCall =
      GetShowingAgentUnassignedVisitsCall();
  static GetShowingAgentVisitsCall getShowingAgentVisitsCall =
      GetShowingAgentVisitsCall();
  static ShowingAgentAcceptVisitCall showingAgentAcceptVisitCall =
      ShowingAgentAcceptVisitCall();
  static ShowingReportProblemCall showingReportProblemCall =
      ShowingReportProblemCall();
  static ShowingNotCompletedReportCall showingNotCompletedReportCall =
      ShowingNotCompletedReportCall();
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

class HardScheduleVisitCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    int? timeSlotIndex,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "visitId": "${escapeStringForJson(visitId)}",
  "timeSlotIndex": ${timeSlotIndex}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Hard Schedule Visit',
      apiUrl: '${baseUrl}/visits/hard',
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

class GetMyVisitsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? filter = '',
    String? today = '',
    String? status = '',
    String? substatus = '',
    String? page = '',
    String? limit = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get My Visits',
      apiUrl: '${baseUrl}/visits/me',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
      },
      params: {
        'filter': filter,
        'today': today,
        'status': status,
        'substatus': substatus,
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

class GetVisitDetailsCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Visit Details',
      apiUrl: '${baseUrl}/visits/${visitId}/details',
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
}

class CancelVisitCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Cancel Visit',
      apiUrl: '${baseUrl}/visits/${visitId}/cancel',
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

class RescheduleVisitCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
    String? dateOne = '',
    String? hourOne = '',
    String? dateTwo = '',
    String? hourTwo = '',
    String? dateThree = '',
    String? hourThree = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "proposedTimeSlots": [
    { "date": "${escapeStringForJson(dateOne)}", "time": "${escapeStringForJson(hourOne)}" },
    { "date": "${escapeStringForJson(dateTwo)}", "time": "${escapeStringForJson(hourTwo)}" },
    { "date": "${escapeStringForJson(dateThree)}", "time": "${escapeStringForJson(hourThree)}" }
  ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Reschedule Visit',
      apiUrl: '${baseUrl}/visits/${visitId}/visit-reschedule',
      callType: ApiCallType.PATCH,
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

class GetListerHqVisitsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? substatus = '',
    String? page = '',
    String? limit = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Lister HQ Visits',
      apiUrl: '${baseUrl}/visits/lister-hq',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
      },
      params: {
        'substatus': substatus,
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

class GetListerHqVisitDocumentsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? status = '',
    String? page = '',
    String? limit = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Lister HQ Visit Documents',
      apiUrl: '${baseUrl}/visits/lister-hq/documents',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
      },
      params: {
        'status': status,
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

class GetOperativeListerVisitsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? substatus = '',
    String? page = '',
    String? limit = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Operative Lister Visits',
      apiUrl: '${baseUrl}/visits/operative-lister',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
      },
      params: {
        'substatus': substatus,
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

class GetOperativeListerScheduleCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    int? year,
    int? month,
    int? day,
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Operative Lister Schedule',
      apiUrl: '${baseUrl}/visits/operative-lister/schedule',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
      },
      params: {
        'year': year,
        'month': month,
        'day': day,
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

class GetAdminOperativeListingVisitsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? withoutListerHq = '',
    String? page = '',
    String? limit = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Admin Operative Listing Visits',
      apiUrl: '${baseUrl}/admin/visits/operative-listing',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
      },
      params: {
        'withoutListerHq': withoutListerHq,
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

class AdminAssignListerHqCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? listerHqId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "listerHqId": "${escapeStringForJson(listerHqId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Admin Assign Lister HQ',
      apiUrl: '${baseUrl}/admin/visits/${visitId}/assign-lister-hq',
      callType: ApiCallType.PATCH,
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

class UploadListerHqChecklistDocumentCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? checklistType = '',
    String? authToken = '',
    FFUploadedFile? file,
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Upload Lister HQ Checklist Document',
      apiUrl:
          '${baseUrl}/visits/${visitId}/lister-hq/documents/${checklistType}',
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

class ReviewChecklistDocumentsCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
    dynamic? items,
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "items": ${serializeJson(items, true)}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Review Checklist Documents',
      apiUrl:
          '${baseUrl}/visits/${visitId}/lister-hq/document-checklist/review',
      callType: ApiCallType.PATCH,
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

class LegalApprovalCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Legal Approval',
      apiUrl: '${baseUrl}/visits/${visitId}/legal-approval',
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

class AssignOperativeListerCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
    String? operativeListerId = '',
    String? date = '',
    String? startTime = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "operativeListerId": "${escapeStringForJson(operativeListerId)}",
  "date": "${escapeStringForJson(date)}",
  "startTime": "${escapeStringForJson(startTime)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Assign Operative Lister',
      apiUrl: '${baseUrl}/visits/${visitId}/assign-operative-lister',
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

class MarkVisitedCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Mark Visited',
      apiUrl: '${baseUrl}/visits/${visitId}/mark-visited',
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

class PublishPropertyAfterVisitCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Publish Property After Visit',
      apiUrl: '${baseUrl}/visits/${visitId}/publish',
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

class GetOwnerPropertyVisitsCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    String? authToken = '',
    String? filter = '',
    String? today = '',
    String? status = '',
    String? substatus = '',
    String? page = '',
    String? limit = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Owner Property Visits',
      apiUrl: '${baseUrl}/visits/properties/${propertyId}/owner',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
      },
      params: {
        'filter': filter,
        'today': today,
        'status': status,
        'substatus': substatus,
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

class OwnerConfirmSlotCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
    String? date = '',
    String? time = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "date": "${escapeStringForJson(date)}",
  "time": "${escapeStringForJson(time)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Owner Confirm Slot',
      apiUrl: '${baseUrl}/visits/${visitId}/owner/confirm',
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

class GetShowingAgentUnassignedVisitsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? page = '',
    String? limit = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Showing Agent Unassigned Visits',
      apiUrl: '${baseUrl}/visits/showing-agent/unassigned',
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

class GetShowingAgentVisitsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
    String? filter = '',
    String? today = '',
    String? status = '',
    String? substatus = '',
    String? page = '',
    String? limit = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Showing Agent Visits',
      apiUrl: '${baseUrl}/visits/showing-agent',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${authToken}',
      },
      params: {
        'filter': filter,
        'today': today,
        'status': status,
        'substatus': substatus,
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

class ShowingAgentAcceptVisitCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Showing Agent Accept Visit',
      apiUrl: '${baseUrl}/visits/${visitId}/showing-agent/accept',
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

class ShowingReportProblemCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
    String? message = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "message": "${escapeStringForJson(message)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Showing Report Problem',
      apiUrl: '${baseUrl}/visits/${visitId}/showing/report-problem',
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

class ShowingNotCompletedReportCall {
  Future<ApiCallResponse> call({
    String? visitId = '',
    String? authToken = '',
    String? reason = '',
  }) async {
    final baseUrl = DOVIAAPIVisitContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "reason": "${escapeStringForJson(reason)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Showing Not Completed Report',
      apiUrl: '${baseUrl}/visits/${visitId}/showing/not-completed-report',
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

/// End DOVIA API - Visit Context Group Code
