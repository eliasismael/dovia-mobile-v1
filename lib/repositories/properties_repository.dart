import 'package:flutter/foundation.dart';

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

    final response =
        await DOVIAAPIPropertyContextGroup.getPropertiesForHomeCall.call();

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

    final response =
        await DOVIAAPIPropertyContextGroup.getPropertiesForMapCall.call();

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

    final response =
        await DOVIAAPIPropertyContextGroup.getPropertyByIDCall.call(
      propertyId: propertyId,
    );

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

  /// Invalidates all caches (e.g. after logout or a major state change).
  void clear() {
    _homeProperties = [];
    _mapMarkers = [];
    _detailCache.clear();
    _homeError = null;
    _mapError = null;
    notifyListeners();
  }
}
