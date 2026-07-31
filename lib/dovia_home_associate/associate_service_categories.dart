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
/// TODO: cuando exista el endpoint de especialidades del asociado, cruzar este
/// listado contra sus categorías aprobadas en vez de confiar sólo en el flag del
/// catálogo.
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
