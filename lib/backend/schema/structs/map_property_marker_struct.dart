// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Data schema for the map that shows the houses
class MapPropertyMarkerStruct extends BaseStruct {
  MapPropertyMarkerStruct({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? price,
    String? listingType,

    /// house or apartment
    String? propertyType,
    double? landArea,
    bool? isFavorite,
    int? bedrooms,
    int? bathrooms,
    double? constructionArea,
  })  : _id = id,
        _name = name,
        _latitude = latitude,
        _longitude = longitude,
        _price = price,
        _listingType = listingType,
        _propertyType = propertyType,
        _landArea = landArea,
        _isFavorite = isFavorite,
        _bedrooms = bedrooms,
        _bathrooms = bathrooms,
        _constructionArea = constructionArea;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "latitude" field.
  double? _latitude;
  double get latitude => _latitude ?? 0.0;
  set latitude(double? val) => _latitude = val;

  void incrementLatitude(double amount) => latitude = latitude + amount;

  bool hasLatitude() => _latitude != null;

  // "longitude" field.
  double? _longitude;
  double get longitude => _longitude ?? 0.0;
  set longitude(double? val) => _longitude = val;

  void incrementLongitude(double amount) => longitude = longitude + amount;

  bool hasLongitude() => _longitude != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  set price(double? val) => _price = val;

  void incrementPrice(double amount) => price = price + amount;

  bool hasPrice() => _price != null;

  // "listingType" field.
  String? _listingType;
  String get listingType => _listingType ?? '';
  set listingType(String? val) => _listingType = val;

  bool hasListingType() => _listingType != null;

  // "propertyType" field.
  String? _propertyType;
  String get propertyType => _propertyType ?? '';
  set propertyType(String? val) => _propertyType = val;

  bool hasPropertyType() => _propertyType != null;

  // "landArea" field.
  double? _landArea;
  double get landArea => _landArea ?? 0.0;
  set landArea(double? val) => _landArea = val;

  void incrementLandArea(double amount) => landArea = landArea + amount;

  bool hasLandArea() => _landArea != null;

  // "isFavorite" field.
  bool? _isFavorite;
  bool get isFavorite => _isFavorite ?? false;
  set isFavorite(bool? val) => _isFavorite = val;

  bool hasIsFavorite() => _isFavorite != null;

  // "bedrooms" field.
  int? _bedrooms;
  int get bedrooms => _bedrooms ?? 0;
  set bedrooms(int? val) => _bedrooms = val;

  void incrementBedrooms(int amount) => bedrooms = bedrooms + amount;

  bool hasBedrooms() => _bedrooms != null;

  // "bathrooms" field.
  int? _bathrooms;
  int get bathrooms => _bathrooms ?? 0;
  set bathrooms(int? val) => _bathrooms = val;

  void incrementBathrooms(int amount) => bathrooms = bathrooms + amount;

  bool hasBathrooms() => _bathrooms != null;

  // "constructionArea" field.
  double? _constructionArea;
  double get constructionArea => _constructionArea ?? 0.0;
  set constructionArea(double? val) => _constructionArea = val;

  void incrementConstructionArea(double amount) =>
      constructionArea = constructionArea + amount;

  bool hasConstructionArea() => _constructionArea != null;

  static MapPropertyMarkerStruct fromMap(Map<String, dynamic> data) =>
      MapPropertyMarkerStruct(
        id: data['id'] as String?,
        name: data['name'] as String?,
        latitude: castToType<double>(data['latitude']),
        longitude: castToType<double>(data['longitude']),
        price: castToType<double>(data['price']),
        listingType: data['listingType'] as String?,
        propertyType: data['propertyType'] as String?,
        landArea: castToType<double>(data['landArea']),
        isFavorite: data['isFavorite'] as bool?,
        bedrooms: castToType<int>(data['bedrooms']),
        bathrooms: castToType<int>(data['bathrooms']),
        constructionArea: castToType<double>(data['constructionArea']),
      );

  static MapPropertyMarkerStruct? maybeFromMap(dynamic data) => data is Map
      ? MapPropertyMarkerStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'name': _name,
        'latitude': _latitude,
        'longitude': _longitude,
        'price': _price,
        'listingType': _listingType,
        'propertyType': _propertyType,
        'landArea': _landArea,
        'isFavorite': _isFavorite,
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
        'constructionArea': _constructionArea,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'latitude': serializeParam(
          _latitude,
          ParamType.double,
        ),
        'longitude': serializeParam(
          _longitude,
          ParamType.double,
        ),
        'price': serializeParam(
          _price,
          ParamType.double,
        ),
        'listingType': serializeParam(
          _listingType,
          ParamType.String,
        ),
        'propertyType': serializeParam(
          _propertyType,
          ParamType.String,
        ),
        'landArea': serializeParam(
          _landArea,
          ParamType.double,
        ),
        'isFavorite': serializeParam(
          _isFavorite,
          ParamType.bool,
        ),
        'bedrooms': serializeParam(
          _bedrooms,
          ParamType.int,
        ),
        'bathrooms': serializeParam(
          _bathrooms,
          ParamType.int,
        ),
        'constructionArea': serializeParam(
          _constructionArea,
          ParamType.double,
        ),
      }.withoutNulls;

  static MapPropertyMarkerStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      MapPropertyMarkerStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        latitude: deserializeParam(
          data['latitude'],
          ParamType.double,
          false,
        ),
        longitude: deserializeParam(
          data['longitude'],
          ParamType.double,
          false,
        ),
        price: deserializeParam(
          data['price'],
          ParamType.double,
          false,
        ),
        listingType: deserializeParam(
          data['listingType'],
          ParamType.String,
          false,
        ),
        propertyType: deserializeParam(
          data['propertyType'],
          ParamType.String,
          false,
        ),
        landArea: deserializeParam(
          data['landArea'],
          ParamType.double,
          false,
        ),
        isFavorite: deserializeParam(
          data['isFavorite'],
          ParamType.bool,
          false,
        ),
        bedrooms: deserializeParam(
          data['bedrooms'],
          ParamType.int,
          false,
        ),
        bathrooms: deserializeParam(
          data['bathrooms'],
          ParamType.int,
          false,
        ),
        constructionArea: deserializeParam(
          data['constructionArea'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'MapPropertyMarkerStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MapPropertyMarkerStruct &&
        id == other.id &&
        name == other.name &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        price == other.price &&
        listingType == other.listingType &&
        propertyType == other.propertyType &&
        landArea == other.landArea &&
        isFavorite == other.isFavorite &&
        bedrooms == other.bedrooms &&
        bathrooms == other.bathrooms &&
        constructionArea == other.constructionArea;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        name,
        latitude,
        longitude,
        price,
        listingType,
        propertyType,
        landArea,
        isFavorite,
        bedrooms,
        bathrooms,
        constructionArea
      ]);
}

MapPropertyMarkerStruct createMapPropertyMarkerStruct({
  String? id,
  String? name,
  double? latitude,
  double? longitude,
  double? price,
  String? listingType,
  String? propertyType,
  double? landArea,
  bool? isFavorite,
  int? bedrooms,
  int? bathrooms,
  double? constructionArea,
}) =>
    MapPropertyMarkerStruct(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      price: price,
      listingType: listingType,
      propertyType: propertyType,
      landArea: landArea,
      isFavorite: isFavorite,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      constructionArea: constructionArea,
    );
