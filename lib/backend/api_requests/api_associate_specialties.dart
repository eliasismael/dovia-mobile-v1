import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_config.dart';

/// Start DOVIA API - Associate Specialties Context Group Code
///
/// Especialidades del Dovia Home Associate: las categorías del catálogo en las
/// que ya está **aprobado** para operar, y la solicitud con la que pide que se
/// le sume una nueva.
///
/// La solicitud no habilita nada por sí sola: cae en el panel administrativo de
/// DOVIA (Backoffice) como un pendiente de auditoría, y recién cuando un admin
/// aprueba la evidencia la categoría pasa a las especialidades del asociado.
///
/// ⚠️ Contrato pendiente de confirmación con backend. Al día de hoy el swagger
/// de `dev` no expone estos dos endpoints (el catálogo
/// `GET /dovia-home/catalog/services` sí existe y es el que lista las
/// categorías de la plataforma). Las rutas de acá siguen la convención del
/// resto del contexto Dovia Home (`/dovia-home/associate/...`, Bearer token, el
/// asociado se resuelve del claim `custom:id` del JWT). La UI está escrita para
/// degradar sin romperse mientras no respondan:
///   - [ListAssociateSpecialtiesCall] falla -> la pantalla asume que todavía no
///     hay especialidades aprobadas y ofrece el catálogo completo.
///   - [CreateAssociateSpecialtyRequestCall] falla -> se avisa al asociado y el
///     formulario conserva lo que había cargado.

class DOVIAAPIAssociateSpecialtiesContextGroup {
  static String getBaseUrl() => kApiBaseUrl;
  static Map<String, String> headers = {};

  static ListAssociateSpecialtiesCall listAssociateSpecialtiesCall =
      ListAssociateSpecialtiesCall();
  static CreateAssociateSpecialtyRequestCall
      createAssociateSpecialtyRequestCall =
      CreateAssociateSpecialtyRequestCall();
}

// ---------------------------------------------------------------------------
// GET /dovia-home/associate/specialties
// Especialidades aprobadas del asociado autenticado. Sin body ni query.
// Respuesta esperada: { data: [ { id, code, label, status } ] }.
// ---------------------------------------------------------------------------

class ListAssociateSpecialtiesCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIAssociateSpecialtiesContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Associate Specialties',
      apiUrl: '$baseUrl/dovia-home/associate/specialties',
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

  List? specialtiesList(dynamic response) =>
      (getJsonField(response, r'''$.data''', true) ??
          getJsonField(response, r'''$''', true)) as List?;
}

// ---------------------------------------------------------------------------
// POST /dovia-home/associate/specialty-requests
// Solicitud de alta de una especialidad nueva. Queda PENDING hasta que la
// audita el Backoffice.
//
// Multipart (mismo criterio que `UploadUserDocumentCall`, porque el certificado
// puede ser una foto o un PDF y viaja en el mismo request):
//   - serviceId:  id de la categoría del catálogo.
//   - experience: texto libre con el background del asociado.
//   - file:       certificado o título. Uno solo — la regla del flujo es
//                 "1 formulario por especialización".
// ---------------------------------------------------------------------------

class CreateAssociateSpecialtyRequestCall {
  Future<ApiCallResponse> call({
    String? serviceId = '',
    String? experience = '',
    FFUploadedFile? file,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIAssociateSpecialtiesContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Create Associate Specialty Request',
      apiUrl: '$baseUrl/dovia-home/associate/specialty-requests',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        'serviceId': serviceId,
        'experience': experience,
        if (file != null) 'file': file,
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

  String? id(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.id''') ??
            getJsonField(response, r'''$.id'''),
      );
  String? status(dynamic response) => castToType<String>(
        getJsonField(response, r'''$.data.status''') ??
            getJsonField(response, r'''$.status'''),
      );
}
