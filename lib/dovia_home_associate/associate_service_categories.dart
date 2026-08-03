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

/// Oficio al que pertenece cada código o etiqueta normalizada.
///
/// Existe porque **los dos catálogos del backend no comparten vocabulario**: los
/// servicios (`GET /dovia-home/catalog/services`) nombran el rubro y las
/// especialidades (`GET /users/me/specialties`) nombran el oficio, con ids
/// distintos en cada uno.
///
///     servicio  PLOMERIA / "Plomería"      ←→ especialidad PLOMERO / "Plomero"
///     servicio  ELECTRICO / "Eléctrico"    ←→ especialidad ELECTRICISTA
///     servicio  ALBANILERIA                ←→ especialidad ALBANILERIA
///     servicio  PINTURA                    ←→ especialidad PINTURA
///     servicio  INSTALACION                ←→ (todavía sin especialidad)
///
/// Sin este puente, un asociado aprobado como `PLOMERO` no cruzaría contra el
/// servicio `PLOMERIA` y el filtro "Tipo de Trabajo" le quedaría vacío. Se
/// incluyen también los códigos en inglés que aparecían en versiones anteriores
/// del catálogo.
const Map<String, String> _familyByKey = {
  'PLOMERIA': 'PLOMERIA',
  'PLOMERO': 'PLOMERIA',
  'PLUMBING': 'PLOMERIA',
  'ELECTRICO': 'ELECTRICIDAD',
  'ELECTRICIDAD': 'ELECTRICIDAD',
  'ELECTRICISTA': 'ELECTRICIDAD',
  'ELECTRICAL': 'ELECTRICIDAD',
  'ELECTRICITY': 'ELECTRICIDAD',
  'ALBANILERIA': 'ALBANILERIA',
  'ALBANIL': 'ALBANILERIA',
  'MASONRY': 'ALBANILERIA',
  'PINTURA': 'PINTURA',
  'PINTOR': 'PINTURA',
  'PAINTING': 'PINTURA',
  'INSTALACION': 'INSTALACION',
  'INSTALADOR': 'INSTALACION',
  'INSTALLATION': 'INSTALACION',
};

/// Íconos por oficio. El payload no trae assets, así que el ícono se resuelve
/// desde el código y, como respaldo, desde la etiqueta.
const Map<String, String> _iconByFamily = {
  'PLOMERIA': 'assets/images/IconoServicioPlomeria.svg',
  'ELECTRICIDAD': 'assets/images/IconoServicioElectrico.svg',
  'ALBANILERIA': 'assets/images/IconoServicioAlbaileria.svg',
  'PINTURA': 'assets/images/IconServicioPintura.svg',
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

/// Clave normalizada (sin acentos, mayúsculas, sólo alfanumérico) con la que se
/// cruzan catálogo, especialidades y solicitudes: los tres payloads escriben lo
/// mismo de maneras distintas ("Albañilería", "ALBANILERIA", "albanileria").
String associateCategoryKey(String value) => _key(value);

/// Todas las claves con las que se reconoce a [value]: la normalizada y, cuando
/// el oficio es conocido, la de su familia ([_familyByKey]). Dos referencias al
/// mismo oficio se cruzan si comparten cualquiera de las dos.
Set<String> associateCategoryKeys(String value) {
  final key = _key(value);
  final family = _familyByKey[key];
  return family == null ? {key} : {key, family};
}

/// Ícono de una categoría a partir de su código de catálogo o, como respaldo, de
/// su etiqueta. Lo usa también el listado de especialidades, que trae los mismos
/// oficios sin assets.
String associateCategoryIcon(String? code, String label) {
  for (final value in [code ?? '', label]) {
    for (final key in associateCategoryKeys(value)) {
      final icon = _iconByFamily[key];
      if (icon != null) return icon;
    }
  }
  return _fallbackIcon;
}

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
      iconPath: associateCategoryIcon(code, label),
    ));
  }
  return categories;
}

/// Claves de las especialidades **aprobadas** del asociado, tal como las
/// devuelve `GET /users/me/specialties` en `currentSpecialties`: ítems planos
/// `{ id, code, label }`.
///
/// Se guardan las tres referencias con sus familias de oficio porque el id de
/// una especialidad **no** es el del servicio equivalente del catálogo: el cruce
/// real es por familia ([categoryIsApproved]).
Set<String> parseApprovedSpecialtyKeys(List<dynamic> raw) {
  final keys = <String>{};
  for (final item in raw) {
    if (item is! Map) continue;
    final data = Map<String, dynamic>.from(item);

    for (final candidate in [data['id'], data['code'], data['label']]) {
      final value = asrString(candidate);
      if (value != null) keys.addAll(associateCategoryKeys(value));
    }
  }
  return keys;
}

/// ¿El asociado ya está aprobado para operar esta categoría del catálogo de
/// servicios?
///
/// Se cruza por familia de oficio además de por id, código y etiqueta: el
/// asociado aprobado como `PLOMERO` opera el servicio `PLOMERIA` aunque no
/// compartan ni id ni código.
bool categoryIsApproved(
  AssociateServiceCategory category,
  Set<String> approvedKeys,
) =>
    [category.id, category.code, category.label]
        .expand(associateCategoryKeys)
        .any(approvedKeys.contains);

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
