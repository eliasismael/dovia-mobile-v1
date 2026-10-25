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

/// Búsqueda de la barra de los listados del asociado: [asrMatchesQuery] más
/// los oficios del catálogo que habilitan el trabajo, para que escribir
/// "albañilería" o "eléctrico" encuentre un servicio que se llama
/// "Instalación".
bool associateRequestMatchesQuery(
  Map<String, dynamic> request,
  String query,
  List<AssociateServiceCategory> categories,
) =>
    asrMatchesQuery(request, query, extraText: [
      for (final c in categories)
        if (associateRequestMatchesCategory(request, c)) c.label,
    ]);

/// Oficio de una solicitud según el catálogo del asociado (Ej: "Albañilería").
///
/// Las cotizaciones llegan todas con el servicio genérico "Servicio por
/// cotizar", así que el oficio sale de las especialidades que habilitan el
/// trabajo o, si no las declara, de la categoría que eligió el cliente.
String? associateRequestTrade(
  Map<String, dynamic> request,
  List<AssociateServiceCategory> categories,
) {
  if (asrRequiredSpecialtyIds(request).isNotEmpty) {
    for (final c in categories) {
      if (associateRequestMatchesCategory(request, c)) return c.label;
    }
  }
  return asrCategoryName(request);
}

/// Título de la tarjeta: el oficio cuando el servicio es el genérico de
/// cotización; si no, el nombre del servicio.
String associateRequestTitle(
  Map<String, dynamic> request,
  List<AssociateServiceCategory> categories,
) {
  final isQuote = asrRequestType(request) == 'QUOTE' ||
      (asrServiceCode(request) ?? '').contains('QUOTE');
  final trade = associateRequestTrade(request, categories);
  return isQuote && trade != null ? trade : asrServiceName(request);
}

/// Título de las tarjetas del independiente: el servicio con su oficio al
/// lado (Ej: "Instalación · Albañilería"). Sin el oficio, filtrar por
/// Albañilería y ver "Instalación" parecía un error del filtro.
String associateRequestCardTitle(
  Map<String, dynamic> request,
  List<AssociateServiceCategory> categories,
) {
  final title = associateRequestTitle(request, categories);
  final trade = associateRequestTrade(request, categories);
  if (trade == null ||
      trade.trim().isEmpty ||
      title.toLowerCase().contains(trade.trim().toLowerCase())) {
    return title;
  }
  return '$title · ${trade.trim()}';
}

/// Ícono del oficio de la solicitud, con el del servicio como respaldo.
String associateRequestIcon(
  Map<String, dynamic> request,
  List<AssociateServiceCategory> categories,
) {
  final trade = associateRequestTrade(request, categories);
  if (trade != null) {
    final icon = associateCategoryIcon(null, trade);
    if (icon != _fallbackIcon) return icon;
  }
  return associateCategoryIcon(
      asrServiceCode(request), asrServiceName(request));
}

/// Título de una cotización ya enviada: el genérico "Servicio por cotizar"
/// pasa a "Servicio cotizado", porque la empresa ya presupuestó.
String associateSubmittedTitle(String title) =>
    title.toLowerCase().contains('por cotizar') ? 'Servicio cotizado' : title;
