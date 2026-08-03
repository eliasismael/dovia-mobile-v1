import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_config.dart';

/// Start DOVIA API - Associate Specialties Context Group Code
///
/// Especialidades del Dovia Home Associate: las categorías en las que ya está
/// **aprobado** para operar, las que todavía puede pedir, y la solicitud con la
/// que pide que se le sume una nueva.
///
/// La solicitud no habilita nada por sí sola: cae en el panel administrativo de
/// DOVIA (Backoffice) como un pendiente de auditoría, y recién cuando un admin
/// aprueba la evidencia la categoría pasa a las especialidades del asociado.
///
/// Las dos rutas cuelgan del usuario autenticado (`/users/me/...`): el asociado
/// se resuelve del claim `custom:id` del JWT, así que ninguna de las dos recibe
/// un id de usuario. Las dos exigen el permiso `HOME_ASSOCIATE_ACCESS` y un
/// usuario activo, verificado y con rol `HOME_ASSOCIATE` o
/// `HOME_ASSOCIATE_COMPANY`.

class DOVIAAPIAssociateSpecialtiesContextGroup {
  static String getBaseUrl() => kApiBaseUrl;
  static Map<String, String> headers = {};

  static GetMySpecialtiesCall getMySpecialtiesCall = GetMySpecialtiesCall();
  static CreateSpecialtyRequestCall createSpecialtyRequestCall =
      CreateSpecialtyRequestCall();
}

/// El arreglo en [path], o null si el campo falta o no es un arreglo.
///
/// Se pide el valor crudo (sin `isForList`) porque `getJsonField` envuelve en
/// una lista cualquier valor suelto, y eso convertiría un campo ausente o un
/// `null` en una lista de un elemento inválido.
List? _listAt(dynamic response, String path) {
  final value = getJsonField(response, path);
  return value is List ? value : null;
}

// ---------------------------------------------------------------------------
// GET /users/me/specialties
//
// Especialidades del asociado autenticado. Sin body ni query. El objeto llega
// directo en `data`, con las tres colecciones que necesita la pantalla de
// Servicios:
//   - currentSpecialties:   en las que ya está aprobado para operar.
//   - availableSpecialties: las que todavía puede solicitar. El backend ya
//                           descuenta las aprobadas **y las que tienen una
//                           solicitud pendiente**, y excluye las especialidades
//                           reservadas de CLIENT y PROPIETARIO.
//   - pendingRequests:      solicitudes esperando auditoría del Backoffice.
//
// Cada especialidad es `{ id, code, label }`. Cada solicitud pendiente es
// `{ id, specialty, status, submittedAt, statusUpdatedAt }`, donde `id` es el de
// la **solicitud** y la especialidad va anidada en `specialty`.
// ---------------------------------------------------------------------------

class GetMySpecialtiesCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIAssociateSpecialtiesContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get My Specialties',
      apiUrl: '$baseUrl/users/me/specialties',
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

  /// Especialidades aprobadas.
  List? currentSpecialties(dynamic response) =>
      _listAt(response, r'''$.data.currentSpecialties''');

  /// Especialidades que el asociado todavía puede solicitar.
  List? availableSpecialties(dynamic response) =>
      _listAt(response, r'''$.data.availableSpecialties''');

  /// Solicitudes en auditoría del Backoffice.
  List? pendingRequests(dynamic response) =>
      _listAt(response, r'''$.data.pendingRequests''');
}

// ---------------------------------------------------------------------------
// POST /users/me/specialty-requests
// Solicitud de alta de una especialidad nueva. Queda pendiente hasta que la
// audita el Backoffice.
//
// Multipart, y **sólo** estos tres campos:
//   - specialtyId: id de la especialidad solicitada. Debe estar activa, ser
//                  asignable y no estar reservada.
//   - experience:  texto libre, no vacío, máximo 2000 caracteres.
//   - file:        exactamente uno, no vacío, de hasta 5 MB, con MIME
//                  `application/pdf`, `image/jpeg`, `image/jpg`, `image/png` o
//                  `image/webp`. Uno solo — la regla del flujo es "1 formulario
//                  por especialización".
//
// El 409 cubre los tres choques del flujo: la especialidad ya está asignada, ya
// tiene una solicitud pendiente, o no es asignable.
//
// Respuesta 201: la solicitud creada directamente en `data`, con `specialty`
// anidada y `document: { url, originalName, mimeType, size }` — nunca la
// storage key.
// ---------------------------------------------------------------------------

class CreateSpecialtyRequestCall {
  Future<ApiCallResponse> call({
    String? specialtyId = '',
    String? experience = '',
    FFUploadedFile? file,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPIAssociateSpecialtiesContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Create Specialty Request',
      apiUrl: '$baseUrl/users/me/specialty-requests',
      callType: ApiCallType.POST,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      },
      params: {
        'specialtyId': specialtyId,
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

  /// Id de la solicitud creada, no el de la especialidad.
  String? id(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.data.id'''));

  /// `PENDING` al crearse.
  String? status(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.data.status'''));

  /// Id de la especialidad solicitada, para cruzar contra el listado.
  String? specialtyId(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.data.specialty.id'''));
}
