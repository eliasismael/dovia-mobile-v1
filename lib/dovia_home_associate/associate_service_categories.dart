/// Oficios con los que filtra el asociado, tal como los pinta el carrusel de
/// filtros rápidos de su panel.
///
/// Salen de `GET /users/me/specialties` (ver [loadAssociateCategories]); acá
/// vive el mapeo de cada oficio a su ícono, porque el payload no trae assets.
library;

import 'associate_service_request_fields.dart';

/// Un oficio del carrusel.
class AssociateServiceCategory {
  const AssociateServiceCategory({
    required this.id,
    required this.code,
    required this.label,
    required this.iconPath,
  });

  /// Id de la especialidad. Es con lo que cruzan las solicitudes, que declaran
  /// `serviceDetail.requiredSpecialtyIds`.
  final String id;

  /// Código del oficio (Ej: `ALBANILERIA`). Sólo se usa como respaldo del cruce
  /// cuando la solicitud no declara especialidades.
  final String code;

  final String label;
  final String iconPath;
}

/// Ícono por defecto cuando aparece un oficio que todavía no tiene asset
/// propio: se prefiere un ícono genérico a no pintar la tarjeta.
const String _fallbackIcon = 'assets/images/IconoCaja.svg';

/// Oficio al que pertenece cada código o etiqueta normalizada.
///
/// Existe porque **el nombre del oficio no es el nombre del rubro**: la
/// especialidad se llama `PLOMERO` y el ícono del rubro es el de `PLOMERIA`.
/// Sin este puente, el chip "Plomero" caería al ícono genérico.
///
///     especialidad PLOMERO / "Plomero"   →  ícono PLOMERIA
///     especialidad ELECTRICISTA          →  ícono ELECTRICIDAD
///     especialidad ALBANILERIA           →  ícono ALBANILERIA
///     especialidad PINTURA               →  ícono PINTURA
///
/// Se incluyen también los códigos en inglés que aparecían en versiones
/// anteriores del backend.
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

/// ¿La solicitud le corresponde al oficio seleccionado?
///
/// El criterio es `serviceDetail.requiredSpecialtyIds`: son ids de especialidad
/// y [AssociateServiceCategory.id] también, así que el cruce es exacto. Es lo
/// único que resuelve los servicios cuyo nombre no es un oficio — `INSTALACION`
/// o `EMERGENCIA` no cruzarían por texto contra "Albañilería", pero sí declaran
/// qué especialidades habilitan a tomarlos.
///
/// Si la solicitud no declara especialidades se cae a comparar por código de
/// catálogo y, en última instancia, por etiqueta.
bool associateRequestMatchesCategory(
  Map<String, dynamic> request,
  AssociateServiceCategory category,
) {
  final required = asrRequiredSpecialtyIds(request);
  if (required.isNotEmpty) {
    return required.any((id) => _key(id) == _key(category.id));
  }

  final code = asrServiceCode(request);
  if (code != null && _key(code) == _key(category.code)) return true;
  return _key(asrServiceName(request)) == _key(category.label);
}
