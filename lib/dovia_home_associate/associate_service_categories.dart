/// Categorías de servicio del catálogo de Dovia Home, tal como las pinta el
/// carrusel de filtros rápidos del panel del asociado.
///
/// El catálogo lo sirve `GET /dovia-home/catalog/services`; acá sólo vive el
/// mapeo de cada servicio a su ícono, porque el payload no trae assets.
library;

import 'associate_service_request_fields.dart';

/// Una categoría del carrusel.
class AssociateServiceCategory {
  const AssociateServiceCategory({
    required this.id,
    required this.code,
    required this.label,
    required this.iconPath,
  });

  /// Id del catálogo. Es lo que se manda al backend cuando aplica.
  final String id;

  /// Código del catálogo (Ej: `PLUMBING`). Se cruza contra
  /// [asrServiceCode] para filtrar las tarjetas.
  final String code;

  final String label;
  final String iconPath;
}

/// Ícono por defecto cuando el catálogo agrega una categoría que todavía no
/// tiene asset propio: se prefiere un ícono genérico a no pintar la tarjeta.
const String _fallbackIcon = 'assets/images/IconoCaja.svg';

/// Íconos por código de catálogo. Las claves son los códigos del backend y, como
/// respaldo, la etiqueta normalizada (el catálogo de `dev` no siempre trae
/// `code`).
const Map<String, String> _iconByKey = {
  'PLUMBING': 'assets/images/IconoServicioPlomeria.svg',
  'PLOMERIA': 'assets/images/IconoServicioPlomeria.svg',
  'ELECTRICAL': 'assets/images/IconoServicioElectrico.svg',
  'ELECTRICITY': 'assets/images/IconoServicioElectrico.svg',
  'ELECTRICO': 'assets/images/IconoServicioElectrico.svg',
  'MASONRY': 'assets/images/IconoServicioAlbaileria.svg',
  'ALBANILERIA': 'assets/images/IconoServicioAlbaileria.svg',
  'PAINTING': 'assets/images/IconServicioPintura.svg',
  'PINTURA': 'assets/images/IconServicioPintura.svg',
  'INSTALLATION': 'assets/images/IconServicioInstalacion.svg',
  'INSTALACION': 'assets/images/IconServicioInstalacion.svg',
};

const Map<String, String> _accents = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

String _key(String value) {
  var out = value.toLowerCase();
  _accents.forEach((from, to) => out = out.replaceAll(from, to));
  return out.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}

String _iconFor(String? code, String label) =>
    _iconByKey[_key(code ?? '')] ?? _iconByKey[_key(label)] ?? _fallbackIcon;

/// Convierte el listado de `GET /dovia-home/catalog/services` en categorías del
/// carrusel.
///
/// **Sólo se muestran las categorías habilitadas para el perfil**: se descartan
/// las que el catálogo marca como inactivas (`active` / `enabled` / `isActive`
/// en false). El endpoint responde el catálogo que el backend expone al usuario
/// autenticado, así que ese flag es hoy la única señal de habilitación.
///
/// Este listado es el catálogo **completo** de la plataforma. Para separar lo
/// que el asociado ya tiene aprobado de lo que todavía puede pedir, cruzarlo
/// contra [parseApprovedSpecialtyKeys] con [categoryIsApproved].
List<AssociateServiceCategory> parseAssociateCategories(List<dynamic> raw) {
  final categories = <AssociateServiceCategory>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final data = Map<String, dynamic>.from(item);

    final enabled = data['active'] ?? data['enabled'] ?? data['isActive'];
    if (enabled == false) continue;

    final label = asrString(data['label']) ??
        asrString(data['name']) ??
        asrString(data['title']);
    if (label == null) continue;

    final code = asrString(data['code'])?.toUpperCase();
    categories.add(AssociateServiceCategory(
      id: asrString(data['id']) ?? code ?? label,
      code: code ?? _key(label),
      label: label,
      iconPath: _iconFor(code, label),
    ));
  }
  return categories;
}

/// Estados de una especialidad que **no** habilitan a operar: una solicitud en
/// auditoría o rechazada no es una especialidad aprobada, y pintarla entre los
/// "Servicios actuales" le haría creer al asociado que ya puede tomar esos
/// trabajos.
///
/// Se compara por lista negra y no por lista blanca a propósito: si el endpoint
/// devuelve un estado nuevo que no conocemos, o directamente no manda `status`
/// (ya devuelve sólo las aprobadas), la especialidad cuenta como aprobada. El
/// caso opuesto —esconder una especialidad real— dejaría al asociado pidiendo
/// de nuevo algo que ya tiene.
const Set<String> _kUnapprovedStatuses = {
  'PENDING',
  'IN_REVIEW',
  'REJECTED',
  'REVOKED',
  'EXPIRED',
  'INACTIVE',
};

/// Claves normalizadas de las especialidades **aprobadas** del asociado, tal
/// como las devuelve `GET /dovia-home/associate/specialties`.
///
/// Se guardan todas las referencias que trae cada ítem (id de catálogo, código
/// y etiqueta) porque no está confirmado con cuál de las tres apunta el payload
/// a la categoría; alcanza con que una coincida ([categoryIsApproved]).
Set<String> parseApprovedSpecialtyKeys(List<dynamic> raw) {
  final keys = <String>{};
  for (final item in raw) {
    // Un listado de strings sueltos (Ej: ["PLUMBING"]) también es válido.
    if (item is String) {
      if (item.trim().isNotEmpty) keys.add(_key(item));
      continue;
    }
    if (item is! Map) continue;
    final data = Map<String, dynamic>.from(item);

    final status = asrString(data['status']) ?? asrString(data['state']);
    if (status != null && _kUnapprovedStatuses.contains(status.toUpperCase())) {
      continue;
    }

    // El servicio puede venir plano o anidado, igual que en el marketplace.
    final service = data['service'] is Map
        ? Map<String, dynamic>.from(data['service'] as Map)
        : (data['serviceDetail'] is Map
            ? Map<String, dynamic>.from(data['serviceDetail'] as Map)
            : const <String, dynamic>{});

    for (final candidate in [
      data['serviceId'],
      data['id'],
      data['code'],
      data['label'],
      data['name'],
      service['id'],
      service['code'],
      service['label'],
      service['name'],
    ]) {
      final value = asrString(candidate);
      if (value != null) keys.add(_key(value));
    }
  }
  return keys;
}

/// ¿El asociado ya está aprobado para operar esta categoría? Se cruza por id de
/// catálogo, por código y por etiqueta normalizada.
bool categoryIsApproved(
  AssociateServiceCategory category,
  Set<String> approvedKeys,
) =>
    approvedKeys.contains(_key(category.id)) ||
    approvedKeys.contains(_key(category.code)) ||
    approvedKeys.contains(_key(category.label));

/// ¿La solicitud pertenece a la categoría seleccionada? Compara por código de
/// catálogo y, si el payload no lo trae, por etiqueta.
bool associateRequestMatchesCategory(
  Map<String, dynamic> request,
  AssociateServiceCategory category,
) {
  final code = asrServiceCode(request);
  if (code != null && _key(code) == _key(category.code)) return true;
  return _key(asrServiceName(request)) == _key(category.label);
}
