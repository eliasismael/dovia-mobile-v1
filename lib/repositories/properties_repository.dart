import 'package:flutter/foundation.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_properties.dart';
import '/core/result.dart';
import '/domain/property_models.dart';

/// Single Source of Truth for property data.
///
/// Caches property lists and detail pages so that navigating back and forth
/// doesn't trigger redundant network calls.
///
/// Widgets should call [loadHomeProperties] or [loadMapProperties] on init,
/// then listen to [isLoading], [homeProperties], [error] for reactive updates.
class PropertiesRepository extends ChangeNotifier {
  // ── Cache ─────────────────────────────────────────────────────────────────

  List<PropertySummary> _homeProperties = [];
  List<MapPropertyMarker> _mapMarkers = [];
  final Map<String, dynamic> _detailCache = {};

  bool _isLoadingHome = false;
  bool _isLoadingMap = false;
  String? _homeError;
  String? _mapError;

  // ── Public state ─────────────────────────────────────────────────────────

  bool get isLoadingHome => _isLoadingHome;
  bool get isLoadingMap => _isLoadingMap;
  String? get homeError => _homeError;
  String? get mapError => _mapError;

  List<PropertySummary> get homeProperties =>
      List.unmodifiable(_homeProperties);
  List<MapPropertyMarker> get mapMarkers => List.unmodifiable(_mapMarkers);

  /// Se cerró sesión o entró otra cuenta mientras se esperaba la respuesta:
  /// es de la sesión anterior y no se guarda en el caché.
  bool _stale(int generation) => authManager.sessionGeneration != generation;
  static const _sessionChangedMessage = 'La sesión cambió mientras se cargaba';

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Loads the property listing shown on the client home page.
  Future<Result<List<PropertySummary>>> loadHomeProperties({
    Map<String, String> filters = const {},
    bool forceRefresh = false,
  }) async {
    if (_homeProperties.isNotEmpty && !forceRefresh) {
      return Success(List.unmodifiable(_homeProperties));
    }

    _isLoadingHome = true;
    _homeError = null;
    notifyListeners();

    final generation = authManager.sessionGeneration;
    final response =
        await DOVIAAPIPropertyContextGroup.getPropertiesForHomeCall.call();
    if (_stale(generation)) return const Failure(_sessionChangedMessage);

    _isLoadingHome = false;

    if (!response.succeeded) {
      _homeError = 'Error al cargar propiedades';
      notifyListeners();
      return Failure(_homeError!, statusCode: response.statusCode);
    }

    final rawData = (response.jsonBody?['data'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    _homeProperties = rawData.map(PropertySummary.fromJson).toList();
    notifyListeners();
    return Success(List.unmodifiable(_homeProperties));
  }

  /// Loads lightweight property markers for the map view.
  Future<Result<List<MapPropertyMarker>>> loadMapMarkers({
    bool forceRefresh = false,
  }) async {
    if (_mapMarkers.isNotEmpty && !forceRefresh) {
      return Success(List.unmodifiable(_mapMarkers));
    }

    _isLoadingMap = true;
    _mapError = null;
    notifyListeners();

    final generation = authManager.sessionGeneration;
    final response =
        await DOVIAAPIPropertyContextGroup.getPropertiesForMapCall.call();
    if (_stale(generation)) return const Failure(_sessionChangedMessage);

    _isLoadingMap = false;

    if (!response.succeeded) {
      _mapError = 'Error al cargar el mapa';
      notifyListeners();
      return Failure(_mapError!, statusCode: response.statusCode);
    }

    final rawData = (response.jsonBody?['data'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    _mapMarkers = rawData.map(MapPropertyMarker.fromJson).toList();
    notifyListeners();
    return Success(List.unmodifiable(_mapMarkers));
  }

  /// Returns raw property detail JSON, using an in-memory cache to avoid
  /// repeated network calls for the same property during a session.
  Future<Result<Map<String, dynamic>>> getPropertyDetail(
      String propertyId) async {
    if (_detailCache.containsKey(propertyId)) {
      return Success(_detailCache[propertyId] as Map<String, dynamic>);
    }

    final generation = authManager.sessionGeneration;
    final response =
        await DOVIAAPIPropertyContextGroup.getPropertyByIDCall.call(
      propertyId: propertyId,
    );
    if (_stale(generation)) return const Failure(_sessionChangedMessage);

    if (!response.succeeded) {
      return Failure(
        'No se pudo cargar la propiedad',
        statusCode: response.statusCode,
      );
    }

    final data = response.jsonBody?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return const Failure('Respuesta inesperada del servidor');
    }

    _detailCache[propertyId] = data;
    return Success(data);
  }

  /// Updates the favorite status of a cached home property (called by
  /// [FavoritesRepository] so the two caches stay in sync).
  void updateFavoriteStatus(String propertyId, bool isFavorite) {
    final index = _homeProperties.indexWhere((p) => p.id == propertyId);
    if (index != -1) {
      _homeProperties[index] =
          _homeProperties[index].copyWith(isFavorite: isFavorite);
      notifyListeners();
    }
  }

  // ── Extended Actions ────────────────────────────────────────────────────────

  /// Fetches paginated properties created by the current user.
  Future<Result<List<dynamic>>> getMyProperties({
    String? page,
    String? limit,
    String? status,
  }) async {
    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIPropertyContextGroup.getMyPropertiesCall.call(
      page: page,
      limit: limit,
      status: status,
      authToken: token,
    );

    if (!response.succeeded) {
      return Failure('Error al cargar mis propiedades',
          statusCode: response.statusCode);
    }
    final rawData = (response.jsonBody?['data'] as List? ?? []);
    return Success(rawData);
  }

  /// Lists all public properties with filters and pagination.
  Future<Result<List<dynamic>>> listProperties({
    String? page,
    String? limit,
    String? propertyType,
    String? minPrice,
    String? maxPrice,
    String? location,
  }) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIPropertyContextGroup.listPropertiesCall.call(
      page: page,
      limit: limit,
      propertyType: propertyType,
      minPrice: minPrice,
      maxPrice: maxPrice,
      location: location,
      // Inventario real: los proyectos nuevos (`isMock`) no tienen ficha.
      isMock: 'false',
      authToken: token,
    );

    if (!response.succeeded) {
      return Failure('Error al listar propiedades',
          statusCode: response.statusCode);
    }
    final rawData = (response.jsonBody?['data'] as List? ?? []);
    return Success(rawData);
  }

  /// Zonas donde se puede publicar (`GET /properties/publishable-zones`).
  /// La respuesta trae el array en `data`; cada zona tiene `id`, `name`,
  /// `cityOrPlace` e `isActive`.
  Future<Result<List<dynamic>>> getPublishableZones() async {
    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIPropertyContextGroup.getPublishableZonesCall.call(
      authToken: token,
    );

    if (!response.succeeded) {
      return Failure('Error al cargar zonas de publicación',
          statusCode: response.statusCode);
    }
    final body = response.jsonBody;
    final data = body is Map ? body['data'] : body;
    return Success(data is List ? data : const []);
  }

  /// Changes the status of a property.
  Future<Result<bool>> changePropertyStatus(String propertyId, String status,
      {String? note}) async {
    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIPropertyContextGroup.changePropertyStatusCall.call(
      propertyId: propertyId,
      status: status,
      note: note,
      authToken: token,
    );

    if (!response.succeeded) {
      return Failure('Error al cambiar el estado de la propiedad',
          statusCode: response.statusCode);
    }
    // Optionally remove from cache if status is DELETED
    if (status == 'DELETED' || status == 'ARCHIVED') {
      _detailCache.remove(propertyId);
      _homeProperties.removeWhere((p) => p.id == propertyId);
      _mapMarkers.removeWhere((p) => p.id == propertyId);
      notifyListeners();
    }
    return const Success(true);
  }

  /// Updates a property.
  Future<Result<bool>> updateProperty({
    required String propertyId,
    String? name,
    String? description,
    List<String>? listingType,
    String? propertyType,
    dynamic location,
    dynamic legalInfo,
    dynamic ownership,
    double? salePrice,
    double? maintenanceFee,
    double? singlePropertyTax,
    double? monthlyRent,
    int? minimumTimeRent,
    String? othersRent,
    String? allowedUses,
    String? availableFrom,
    dynamic features,
    dynamic infoHQ,
  }) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIPropertyContextGroup.updatePropertyCall.call(
      propertyId: propertyId,
      authToken: token,
      name: name,
      description: description,
      listingType: listingType,
      propertyType: propertyType,
      location: location,
      legalInfo: legalInfo,
      ownership: ownership,
      salePrice: salePrice,
      maintenanceFee: maintenanceFee,
      singlePropertyTax: singlePropertyTax,
      monthlyRent: monthlyRent,
      minimumTimeRent: minimumTimeRent,
      othersRent: othersRent,
      allowedUses: allowedUses,
      availableFrom: availableFrom,
      features: features,
      infoHQ: infoHQ,
    );

    if (!response.succeeded) {
      return Failure('Error al actualizar propiedad',
          statusCode: response.statusCode);
    }
    _detailCache.remove(propertyId);
    return const Success(true);
  }

  /// Invalidates all caches (e.g. after logout or a major state change).
  void clear() {
    _homeProperties = [];
    _mapMarkers = [];
    _detailCache.clear();
    _homeError = null;
    _mapError = null;
    // Una carga de la sesión anterior se descarta al volver: no queda "cargando".
    _isLoadingHome = false;
    _isLoadingMap = false;
    notifyListeners();
  }
}
