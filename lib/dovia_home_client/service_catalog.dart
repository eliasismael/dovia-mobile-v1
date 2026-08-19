/// Catálogo de Dovia Home para los flujos del cliente: qué servicios existen,
/// qué categorías se pueden pedir dentro de cada uno y qué entra (o no) en la
/// visita.
///
/// Existe porque el `POST` de una solicitud dejó de aceptar sólo el servicio:
/// ahora exige además la **categoría** elegida, y la categoría sólo se conoce
/// pidiéndosela al backend
/// (`GET /dovia-home/catalog/services/{serviceId}/categories`, o
/// `GET /dovia-home/catalog/emergencies/categories` para el flujo de
/// emergencia). Las dos pantallas que crean solicitudes —Agenda y
/// Emergencias— resuelven lo mismo, así que la lectura del catálogo vive acá y
/// no duplicada en cada una.
library;

import '/backend/api_requests/api_dovia_home.dart';

/// Categoría solicitable dentro de un servicio (Ej: "Reparación de fugas").
/// Es lo que viaja como `categoryId` al crear la solicitud.
class DoviaHomeServiceCategory {
  const DoviaHomeServiceCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  /// Categoría y su alcance en una línea, tal como las redacta el catálogo:
  /// el `description` continúa la frase del `name` ("Reparación de fugas" +
  /// "en tuberías o conexiones visibles..."), no es un párrafo aparte.
  String get scopeLine => description.isEmpty ? name : '$name: $description';

  static DoviaHomeServiceCategory? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final id = _str(raw['id']) ?? _str(raw['categoryId']);
    final name = _str(raw['name']) ?? _str(raw['label']);
    if (id == null || name == null) return null;
    return DoviaHomeServiceCategory(
      id: id,
      name: name,
      description: _str(raw['description']) ?? '',
    );
  }
}

/// Alcance del servicio elegido: sus categorías, lo que lleva el técnico y lo
/// que la visita no cubre.
class DoviaHomeServiceScope {
  const DoviaHomeServiceScope({
    required this.serviceId,
    required this.categories,
    required this.technicianBrings,
    required this.notIncluded,
  });

  final String serviceId;
  final List<DoviaHomeServiceCategory> categories;
  final List<String> technicianBrings;
  final List<String> notIncluded;

  DoviaHomeServiceCategory? categoryById(String? id) {
    if (id == null) return null;
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }
}

String? _str(dynamic value) =>
    (value is String && value.trim().isNotEmpty) ? value.trim() : null;

List<String> _stringList(List? raw) => [
      for (final item in raw ?? const [])
        if (_str(item) != null) _str(item)!,
    ];

List<DoviaHomeServiceCategory> _categories(List? raw) {
  final categories = <DoviaHomeServiceCategory>[];
  for (final item in raw ?? const []) {
    final category = DoviaHomeServiceCategory.fromJson(item);
    if (category != null) categories.add(category);
  }
  return categories;
}

/// Normaliza para comparar nombres de servicio sin depender de mayúsculas ni
/// acentos ("Albañilería" vs "albanileria").
String _normalize(String value) {
  const accents = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  var result = value.toLowerCase().trim();
  accents.forEach((from, to) => result = result.replaceAll(from, to));
  return result.replaceAll(RegExp(r'\s+'), ' ');
}

/// Resuelve el `serviceId` del catálogo a partir del título de la categoría
/// elegida en el Dashboard (que hoy es solo un título). Se compara por nombre
/// normalizado y, si no hay coincidencia exacta, por contención en cualquier
/// sentido.
Future<String?> resolveDoviaHomeServiceId({
  required String serviceTitle,
  required String authToken,
}) async {
  final response =
      await DOVIAAPIDoviaHomeContextGroup.listCatalogServicesCall.call(
    authToken: authToken,
  );
  if (!response.succeeded) return null;

  final services = DOVIAAPIDoviaHomeContextGroup.listCatalogServicesCall
          .servicesList(response.jsonBody) ??
      [];
  final target = _normalize(serviceTitle);

  String? partialMatch;
  for (final service in services.whereType<Map>()) {
    // Un servicio dado de baja no se puede solicitar: el POST lo rechazaría.
    if (service['active'] == false) continue;

    final id = _str(service['id']) ?? _str(service['serviceId']);
    // El catálogo etiqueta los servicios con `label` (Ej: "Plomería") y los
    // identifica con `code` (Ej: "PLOMERIA"); `name`/`title` no existen en la
    // respuesta y leer sólo esos dejaba el id sin resolver, así que la
    // solicitud moría antes del POST con "No se pudo identificar el servicio".
    final name = _str(service['label']) ??
        _str(service['name']) ??
        _str(service['title']) ??
        _str(service['code']);
    if (id == null || name == null) continue;

    final normalized = _normalize(name);
    if (normalized == target) return id;
    if (partialMatch == null &&
        (normalized.contains(target) || target.contains(normalized))) {
      partialMatch = id;
    }
  }
  return partialMatch;
}

/// Alcance del servicio normal elegido en el Dashboard. Null cuando el título
/// no se pudo cruzar contra el catálogo o el listado de categorías falló: en
/// los dos casos la solicitud no se puede crear, porque `categoryId` es
/// obligatorio.
Future<DoviaHomeServiceScope?> loadDoviaHomeServiceScope({
  required String serviceTitle,
  required String authToken,
}) async {
  final serviceId = await resolveDoviaHomeServiceId(
    serviceTitle: serviceTitle,
    authToken: authToken,
  );
  if (serviceId == null) return null;

  final call = DOVIAAPIDoviaHomeContextGroup.listServiceCategoriesCall;
  final response = await call.call(
    serviceId: serviceId,
    authToken: authToken,
  );
  if (!response.succeeded) return null;

  return DoviaHomeServiceScope(
    // El endpoint devuelve el `serviceId` que resolvió; se prefiere sobre el
    // que se mandó para no cablear dos fuentes del mismo dato.
    serviceId: call.serviceId(response.jsonBody) ?? serviceId,
    categories: _categories(call.categoriesList(response.jsonBody)),
    technicianBrings: _stringList(call.technicianBrings(response.jsonBody)),
    notIncluded: _stringList(call.notIncluded(response.jsonBody)),
  );
}

/// Alcance del servicio de emergencia activo. No recibe `serviceId`: el
/// backend resuelve cuál es el servicio `EMERGENCY` vigente, igual que al
/// crear la solicitud.
Future<DoviaHomeServiceScope?> loadDoviaHomeEmergencyScope({
  required String authToken,
}) async {
  final call = DOVIAAPIDoviaHomeContextGroup.listEmergencyCategoriesCall;
  final response = await call.call(authToken: authToken);
  if (!response.succeeded) return null;

  return DoviaHomeServiceScope(
    serviceId: call.serviceId(response.jsonBody) ?? '',
    categories: _categories(call.categoriesList(response.jsonBody)),
    technicianBrings: _stringList(call.technicianBrings(response.jsonBody)),
    notIncluded: _stringList(call.notIncluded(response.jsonBody)),
  );
}
