/// Especialidades del Dovia Home Associate, tal como las sirve
/// `GET /users/me/specialties`.
///
/// El endpoint resuelve del lado del backend las tres colecciones que la
/// pantalla de Servicios necesita distinguir:
///   - **actuales** (`currentSpecialties`): en las que ya está aprobado para
///     operar. Informativas.
///   - **disponibles** (`availableSpecialties`): las que todavía puede
///     solicitar. El backend ya descuenta las aprobadas y las que tienen una
///     solicitud pendiente, y excluye las reservadas de `CLIENT` y
///     `PROPIETARIO`, así que la pantalla no vuelve a filtrarlas.
///   - **pendientes** (`pendingRequests`): solicitudes en auditoría del
///     Backoffice. Como el backend ya las sacó de las disponibles, es la única
///     fuente para mostrarlas: sin ellas la especialidad recién solicitada
///     desaparecería de la pantalla y se leería como que la solicitud se perdió.
///
/// Una especialidad es `{ id, code, label }`. Una solicitud pendiente es
/// `{ id, specialty, status, submittedAt, statusUpdatedAt }`, donde **`id` es el
/// de la solicitud** y la especialidad viaja anidada en `specialty`.
library;

import '/backend/api_requests/api_associate_specialties.dart';
import 'associate_service_categories.dart';
import 'associate_service_request_fields.dart';

/// Una especialidad del listado.
class AssociateSpecialty {
  const AssociateSpecialty({
    required this.id,
    required this.code,
    required this.label,
    required this.iconPath,
  });

  /// Id de la especialidad. Es lo que viaja como `specialtyId` al solicitarla.
  final String id;

  /// Código del oficio (Ej: `ELECTRICISTA`).
  final String code;

  final String label;
  final String iconPath;
}

/// Las tres colecciones ya resueltas, más el estado de la carga.
class AssociateSpecialties {
  const AssociateSpecialties({
    required this.current,
    required this.available,
    required this.pending,
    this.errorStatus,
  });

  /// Especialidades aprobadas. Se pintan arriba y no son accionables.
  final List<AssociateSpecialty> current;

  /// Especialidades que todavía puede solicitar.
  final List<AssociateSpecialty> available;

  /// Especialidades con una solicitud esperando auditoría.
  final List<AssociateSpecialty> pending;

  /// Status HTTP con el que falló la carga, o null si respondió bien. Se guarda
  /// el código y no un booleano porque un 403 y una caída se le explican
  /// distinto al usuario ([errorMessage]).
  final int? errorStatus;

  bool get failed => errorStatus != null;

  /// ¿Esta especialidad ya tiene una solicitud esperando auditoría?
  ///
  /// Se compara por id porque los dos listados salen del mismo catálogo de
  /// especialidades.
  bool isPending(AssociateSpecialty specialty) =>
      pending.any((p) => p.id == specialty.id);

  /// Pendientes que **no** vienen repetidas dentro de [available].
  ///
  /// Hoy son todas —el backend descuenta de las disponibles lo que está en
  /// auditoría—, pero se filtra igual para que un cambio de criterio del
  /// backend no termine pintando la misma tarjeta dos veces.
  List<AssociateSpecialty> get pendingOutsideAvailable {
    final listed = available.map((s) => s.id).toSet();
    return [
      for (final specialty in pending)
        if (!listed.contains(specialty.id)) specialty,
    ];
  }

  /// Mensaje para el usuario cuando el listado no cargó.
  ///
  /// El 403 se distingue a propósito: cubre tanto la falta del permiso
  /// `HOME_ASSOCIATE_ACCESS` como la cuenta todavía inactiva o sin verificar, y
  /// decirle "intentá de nuevo" lo manda a reintentar algo que nunca va a
  /// funcionar solo.
  String get errorMessage => errorStatus == 403
      ? 'Tu cuenta todavía no está habilitada para gestionar especialidades. '
          'Revisá que tu perfil esté verificado o contactá al equipo de DOVIA.'
      : 'No pudimos cargar tus especialidades. Intentá de nuevo en un momento.';
}

/// Una especialidad `{ id, code, label }`, o null si el ítem no la trae.
///
/// El ícono no viene en el payload: se resuelve por oficio desde el código y,
/// como respaldo, desde la etiqueta.
AssociateSpecialty? _parseSpecialty(dynamic item) {
  if (item is! Map) return null;
  final data = Map<String, dynamic>.from(item);

  final id = asrString(data['id']);
  final label = asrString(data['label']);
  if (id == null || label == null) return null;

  final code =
      asrString(data['code'])?.toUpperCase() ?? associateCategoryKey(label);

  return AssociateSpecialty(
    id: id,
    code: code,
    label: label,
    iconPath: associateCategoryIcon(code, label),
  );
}

/// Convierte `currentSpecialties` o `availableSpecialties` en especialidades.
List<AssociateSpecialty> parseAssociateSpecialties(List<dynamic> raw) {
  final specialties = <AssociateSpecialty>[];
  final seen = <String>{};
  for (final item in raw) {
    final specialty = _parseSpecialty(item);
    if (specialty == null) continue;
    if (seen.add(specialty.id)) specialties.add(specialty);
  }
  return specialties;
}

/// Convierte `pendingRequests` en las especialidades que están en auditoría.
///
/// Se lee `specialty` y no la raíz del ítem: el `id` de la raíz es el de la
/// solicitud, y usarlo dejaría a la pendiente sin cruzar contra su especialidad.
List<AssociateSpecialty> parsePendingSpecialties(List<dynamic> raw) =>
    parseAssociateSpecialties([
      for (final item in raw)
        if (item is Map) item['specialty'],
    ]);

/// Pide `GET /users/me/specialties` y devuelve las tres colecciones.
///
/// Si el endpoint falla no hay nada que mostrar —ni las aprobadas ni las
/// solicitables— y se devuelve el status para que la pantalla lo explique en vez
/// de quedarse en blanco.
Future<AssociateSpecialties> loadAssociateSpecialties({
  required String authToken,
}) async {
  final call = DOVIAAPIAssociateSpecialtiesContextGroup.getMySpecialtiesCall;
  final response = await call.call(authToken: authToken);

  if (!response.succeeded) {
    return AssociateSpecialties(
      current: const [],
      available: const [],
      pending: const [],
      errorStatus: response.statusCode,
    );
  }

  return AssociateSpecialties(
    current: parseAssociateSpecialties(
      call.currentSpecialties(response.jsonBody) ?? const [],
    ),
    available: parseAssociateSpecialties(
      call.availableSpecialties(response.jsonBody) ?? const [],
    ),
    pending: parsePendingSpecialties(
      call.pendingRequests(response.jsonBody) ?? const [],
    ),
  );
}
