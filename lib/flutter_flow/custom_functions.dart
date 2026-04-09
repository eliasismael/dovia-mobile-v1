
import '/backend/schema/structs/index.dart';

/// Function to convert the response of GetPropertiesForMap to a model for the
/// map component
List<MapPropertyMarkerStruct> parseMapMarkers(dynamic apiResponse) {
  final List data = apiResponse['data'];

  return data.map((dynamicRaw) {
    final item = dynamicRaw as Map<String, dynamic>;

    final coords = item['location']['geo']['coordinates'] as List;
    final listing = (item['listingType'] as List).first as String;

    // Extracción 100% segura a prueba de fallos de tipo en Dart
    final features = item['features'];
    final general = features != null ? features['general'] : null;
    final landAreaRaw = general != null ? general['landArea'] : null;

    return MapPropertyMarkerStruct(
      id: item['id'] as String,
      name: item['name'] as String,
      longitude: (coords[0] as num).toDouble(),
      latitude: (coords[1] as num).toDouble(),
      price: (item['price'] as num).toDouble(),
      listingType: listing,
      propertyType: item['propertyType'] as String,
      isFavorite: item['isFavorite'] == true,
      landArea: landAreaRaw != null ? (landAreaRaw as num).toDouble() : null,
    );
  }).toList();
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
