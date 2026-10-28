import '/backend/schema/structs/index.dart';

/// Function to convert the response of GetPropertiesForMap to a model for the
/// map component.
///
/// Una propiedad incompleta (sin id, ubicación, precio u operación) se
/// descarta: antes un solo dato faltante lanzaba y el mapa quedaba sin pines.
List<MapPropertyMarkerStruct> parseMapMarkers(dynamic apiResponse) {
  final data = apiResponse is Map ? apiResponse['data'] : null;
  if (data is! List) return [];
  return data
      .map(_parseMapMarker)
      .whereType<MapPropertyMarkerStruct>()
      .toList();
}

MapPropertyMarkerStruct? _parseMapMarker(dynamic item) {
  if (item is! Map) return null;
  final id = item['id'];
  final location = item['location'];
  final geo = location is Map ? location['geo'] : null;
  final coords = geo is Map ? geo['coordinates'] : null;
  final listingTypes = item['listingType'];
  final listing = listingTypes is List && listingTypes.isNotEmpty
      ? listingTypes.first
      : null;
  final price = item['price'];
  if (id is! String ||
      coords is! List ||
      coords.length < 2 ||
      coords[0] is! num ||
      coords[1] is! num ||
      listing is! String ||
      listing.isEmpty ||
      price is! num) {
    return null;
  }

  final features = item['features'];
  final general = features is Map ? features['general'] : null;
  num? generalNum(String key) =>
      general is Map && general[key] is num ? general[key] as num : null;

  return MapPropertyMarkerStruct(
    id: id,
    name: item['name']?.toString() ?? '',
    longitude: (coords[0] as num).toDouble(),
    latitude: (coords[1] as num).toDouble(),
    price: price.toDouble(),
    listingType: listing,
    propertyType: item['propertyType']?.toString() ?? '',
    isFavorite: item['isFavorite'] == true,
    landArea: generalNum('landArea')?.toDouble(),
    bedrooms: generalNum('bedrooms')?.toInt(),
    bathrooms: generalNum('bathrooms')?.toInt(),
    constructionArea: generalNum('constructionArea')?.toDouble(),
  );
}

List<MapPropertyMarkerStruct> applyFiltersForMap(
  List<MapPropertyMarkerStruct> all,
  String? filterType,
  String? filterListing,
  double? minPrice,
  double? maxPrice,
  int? minBedrooms,
  int? minBathrooms,
  double? minArea,
  double? maxArea,
) {
  return all.where((p) {
    // Si el filtro es nulo o está vacío, no se aplica (match = true)
    final matchType = filterType == null ||
        filterType.isEmpty ||
        p.propertyType == filterType;
    final matchListing = filterListing == null ||
        filterListing.isEmpty ||
        p.listingType == filterListing;

    // Si el precio min/max es nulo, no se aplica el límite
    final matchMinPrice = minPrice == null || p.price >= minPrice;
    final matchMaxPrice = maxPrice == null || p.price <= maxPrice;

    // Filtros avanzados
    final matchBedrooms = minBedrooms == null || p.bedrooms >= minBedrooms;
    final matchBathrooms = minBathrooms == null || p.bathrooms >= minBathrooms;
    final matchMinArea = minArea == null || p.constructionArea >= minArea;
    final matchMaxArea = maxArea == null || p.constructionArea <= maxArea;

    return matchType &&
        matchListing &&
        matchMinPrice &&
        matchMaxPrice &&
        matchBedrooms &&
        matchBathrooms &&
        matchMinArea &&
        matchMaxArea;
  }).toList();
}
