// Domain models for properties.
//
// Clean, typed representations of property data returned by the API.
// These are independent of FlutterFlow internals and safe to use
// across the app without coupling to ApiCallResponse.

class PropertySummary {
  final String id;
  final String name;
  final int price;
  final bool isFavorite;
  final List<String> listingType;
  final int? constructionArea;
  final int? bedrooms;
  final int? bathrooms;
  final int? parkingSpots;
  final int? landArea;
  final String? fullAddress;
  final List<double>? coordinates;
  final String? status;
  final bool? isActive;

  const PropertySummary({
    required this.id,
    required this.name,
    required this.price,
    required this.isFavorite,
    required this.listingType,
    this.constructionArea,
    this.bedrooms,
    this.bathrooms,
    this.parkingSpots,
    this.landArea,
    this.fullAddress,
    this.coordinates,
    this.status,
    this.isActive,
  });

  factory PropertySummary.fromJson(Map<String, dynamic> json) {
    final features = json['features']?['general'] as Map<String, dynamic>?;
    final location = json['location'] as Map<String, dynamic>?;
    final geoCoords =
        (location?['geo']?['coordinates'] as List?)?.cast<double>();

    return PropertySummary(
      id: json['id'] as String? ?? json['propertyId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      listingType: (json['listingType'] as List?)?.cast<String>() ?? const [],
      constructionArea: (features?['constructionArea'] as num?)?.toInt(),
      bedrooms: (features?['bedrooms'] as num?)?.toInt(),
      bathrooms: (features?['bathrooms'] as num?)?.toInt(),
      parkingSpots: (features?['parkingSpots'] as num?)?.toInt(),
      landArea: (features?['landArea'] as num?)?.toInt(),
      fullAddress:
          location?['address']?['fullAddress'] as String?,
      coordinates: geoCoords,
      status: json['status'] as String?,
      isActive: json['active'] as bool?,
    );
  }

  PropertySummary copyWith({bool? isFavorite}) {
    return PropertySummary(
      id: id,
      name: name,
      price: price,
      isFavorite: isFavorite ?? this.isFavorite,
      listingType: listingType,
      constructionArea: constructionArea,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      parkingSpots: parkingSpots,
      landArea: landArea,
      fullAddress: fullAddress,
      coordinates: coordinates,
      status: status,
      isActive: isActive,
    );
  }
}

class MapPropertyMarker {
  final String id;
  final String name;
  final int price;
  final double latitude;
  final double longitude;
  final String? status;

  const MapPropertyMarker({
    required this.id,
    required this.name,
    required this.price,
    required this.latitude,
    required this.longitude,
    this.status,
  });

  factory MapPropertyMarker.fromJson(Map<String, dynamic> json) {
    final coords =
        (json['location']?['geo']?['coordinates'] as List?)?.cast<num>();
    return MapPropertyMarker(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      // GeoJSON convention: [longitude, latitude]
      longitude: coords?.isNotEmpty == true ? coords![0].toDouble() : 0.0,
      latitude: coords?.length == 2 ? coords![1].toDouble() : 0.0,
      status: json['status'] as String?,
    );
  }
}
