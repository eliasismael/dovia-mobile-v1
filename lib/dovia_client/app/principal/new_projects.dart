import '/domain/property_location.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Listado del sitio externo de desarrollos ("Ver más" de Proyectos Nuevos).
const String kNewProjectsLandingUrl = 'https://doviaapp.com/proyectos-nuevos';

/// Cuántos proyectos pide Inicio (`GET /properties?isMock=true`).
const int kNewProjectsLimit = 10;

/// Proyecto nuevo de la sección de Inicio.
///
/// Son propiedades que crea el sitio externo de desarrollos (`isMock: true`
/// con `externalId`). No tienen ficha en la app (`GET /properties/{id}` da
/// 404): cada tarjeta abre la página del proyecto en ese sitio, igual que en
/// la web.
class NewProject {
  const NewProject({
    required this.id,
    required this.externalId,
    required this.name,
    required this.imageUrl,
    required this.priceUsd,
    this.propertyType,
    this.listingType,
    this.landArea,
    this.constructionArea,
    this.bedrooms,
    this.bathrooms,
    this.parkingSpots,
    this.location,
  });

  final String id;
  final String externalId;
  final String name;
  final String? imageUrl;

  /// Precio de entrada en USD, como lo publica el sitio externo. 0 si el
  /// desarrollo todavía no lo definió.
  final num priceUsd;
  final String? propertyType;
  final String? listingType;
  final double? landArea;
  final int? constructionArea;
  final int? bedrooms;
  final int? bathrooms;
  final int? parkingSpots;
  final String? location;

  /// Sólo los que vienen del sitio externo: `isMock` y un `externalId` no
  /// vacío. Cualquier otro elemento del listado se descarta.
  static NewProject? fromJson(dynamic json) {
    if (json is! Map) return null;
    if (json['isMock'] != true) return null;
    final externalId = json['externalId']?.toString().trim() ?? '';
    final id = json['id']?.toString() ?? '';
    if (externalId.isEmpty || id.isEmpty) return null;

    num? number(String path) {
      final value = getJsonField(json, path);
      return value is num ? value : num.tryParse('${value ?? ''}');
    }

    final image = json['image']?.toString().trim();
    return NewProject(
      id: id,
      externalId: externalId,
      name: (json['name']?.toString().trim().isNotEmpty ?? false)
          ? json['name'].toString().trim()
          : 'Proyecto',
      imageUrl:
          (image == null || image.isEmpty || image == 'null') ? null : image,
      priceUsd: number(r'$.saleInfo.salePrice') ?? number(r'$.price') ?? 0,
      propertyType: json['propertyType']?.toString(),
      listingType: json['listingType']?.toString(),
      landArea: number(r'$.features.general.landArea')?.toDouble(),
      constructionArea: number(r'$.features.general.constructionArea')?.toInt(),
      bedrooms: number(r'$.features.general.bedrooms')?.toInt(),
      bathrooms: number(r'$.features.general.bathrooms')?.toInt(),
      parkingSpots: number(r'$.features.general.parkingSpots')?.toInt(),
      location: propertyLocationLabel(json),
    );
  }

  /// Los proyectos de una respuesta de `GET /properties`.
  static List<NewProject> listFrom(dynamic body) {
    final data = getJsonField(body, r'$.data', true);
    if (data is! List) return const [];
    return data.map(NewProject.fromJson).whereType<NewProject>().toList();
  }

  /// Prefijo con el que el sitio de desarrollos guarda el `externalId`
  /// ("dovia-new-project-bosques-de-cayala"); su página usa sólo el resto
  /// (/proyectos-nuevos/bosques-de-cayala). Con el prefijo, el sitio responde
  /// "Proyecto no encontrado".
  static const _externalIdPrefix = 'dovia-new-project-';

  /// Página del proyecto en el sitio externo.
  String get url {
    final slug = externalId.startsWith(_externalIdPrefix) &&
            externalId.length > _externalIdPrefix.length
        ? externalId.substring(_externalIdPrefix.length)
        : externalId;
    return '$kNewProjectsLandingUrl/${Uri.encodeComponent(slug)}';
  }

  bool get hasPrice => priceUsd > 0;

  /// "USD 165,000" (va debajo de "Precio desde", como en la web), o "Precio
  /// por confirmar" si todavía no tiene.
  String get priceLabel {
    if (!hasPrice) return 'Precio por confirmar';
    final whole = priceUsd.round().toString();
    final grouped = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) grouped.write(',');
      grouped.write(whole[i]);
    }
    return 'USD $grouped';
  }
}
