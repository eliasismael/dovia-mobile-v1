import 'package:flutter/foundation.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_favorites.dart';
import '/backend/api_requests/api_manager.dart';
import '/core/result.dart';
import '/domain/favorite_models.dart';
import '/domain/property_models.dart';

/// Single Source of Truth for the user's favorites.
///
/// Manages an in-memory cache of favorited property IDs and folders so that
/// any widget anywhere in the tree can call [isFavorited] synchronously
/// without hitting the network on every render.
///
/// Usage:
/// ```dart
/// // Read from widget
/// final repo = context.watch<FavoritesRepository>();
/// final isFav = repo.isFavorited(propertyId);
///
/// // Mutate from handler (no rebuild of calling widget)
/// context.read<FavoritesRepository>().toggleFavorite(propertyId);
/// ```
class FavoritesRepository extends ChangeNotifier {
  // ── In-memory cache ──────────────────────────────────────────────────────

  /// IDs of all properties the user has favorited (any folder).
  final Set<String> _favoritedIds = {};

  List<FavoriteFolder> _folders = [];
  List<PropertySummary> _defaultFavorites = [];
  PaginationMeta? _defaultFavoritesMeta;

  bool _isLoading = false;
  String? _error;

  // ── Public state ─────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FavoriteFolder> get folders => List.unmodifiable(_folders);
  List<PropertySummary> get defaultFavorites =>
      List.unmodifiable(_defaultFavorites);
  PaginationMeta? get defaultFavoritesMeta => _defaultFavoritesMeta;

  /// Synchronous check — returns cached value immediately.
  bool isFavorited(String propertyId) => _favoritedIds.contains(propertyId);

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Adds or removes a favorite optimistically, then confirms with the server.
  Future<Result<void>> toggleFavorite(
    String propertyId, {
    String folderId = '',
  }) async {
    final wasAlreadyFavorited = _favoritedIds.contains(propertyId);

    // Optimistic update
    if (wasAlreadyFavorited) {
      _favoritedIds.remove(propertyId);
    } else {
      _favoritedIds.add(propertyId);
    }
    _updatePropertyFavoriteStatus(propertyId, !wasAlreadyFavorited);
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    ApiCallResponse response;

    if (wasAlreadyFavorited) {
      response = await DOVIAAPIFavoriteContextGroup
          .removePropertyFromFavoritesCall
          .call(propertyId: propertyId, authToken: token);
    } else {
      response = await DOVIAAPIFavoriteContextGroup.addPropertyToFavoritesCall
          .call(propertyId: propertyId, folderId: folderId, authToken: token);
    }

    if (!response.succeeded) {
      // Roll back optimistic update on failure
      if (wasAlreadyFavorited) {
        _favoritedIds.add(propertyId);
      } else {
        _favoritedIds.remove(propertyId);
      }
      _updatePropertyFavoriteStatus(propertyId, wasAlreadyFavorited);
      notifyListeners();
      return Failure(
        'No se pudo actualizar favorito',
        statusCode: response.statusCode,
      );
    }

    return const Success(null);
  }

  /// Adds to favorites without toggle semantics (explicit add).
  Future<Result<void>> addFavorite(
    String propertyId, {
    String folderId = '',
  }) async {
    if (_favoritedIds.contains(propertyId)) return const Success(null);

    _favoritedIds.add(propertyId);
    _updatePropertyFavoriteStatus(propertyId, true);
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIFavoriteContextGroup
        .addPropertyToFavoritesCall
        .call(propertyId: propertyId, folderId: folderId, authToken: token);

    if (!response.succeeded) {
      _favoritedIds.remove(propertyId);
      _updatePropertyFavoriteStatus(propertyId, false);
      notifyListeners();
      return Failure(
        'No se pudo agregar a favoritos',
        statusCode: response.statusCode,
      );
    }
    return const Success(null);
  }

  /// Removes from favorites.
  Future<Result<void>> removeFavorite(String propertyId) async {
    if (!_favoritedIds.contains(propertyId)) return const Success(null);

    _favoritedIds.remove(propertyId);
    _updatePropertyFavoriteStatus(propertyId, false);
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIFavoriteContextGroup
        .removePropertyFromFavoritesCall
        .call(propertyId: propertyId, authToken: token);

    if (!response.succeeded) {
      _favoritedIds.add(propertyId);
      _updatePropertyFavoriteStatus(propertyId, true);
      notifyListeners();
      return Failure(
        'No se pudo eliminar de favoritos',
        statusCode: response.statusCode,
      );
    }
    return const Success(null);
  }

  /// Loads the default favorites list (no folder) from the server.
  Future<Result<List<PropertySummary>>> loadDefaultFavorites({
    int page = 1,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIFavoriteContextGroup.getDefaultFavoritesCall.call(
      authToken: token,
      page: page.toString(),
      limit: limit.toString(),
    );

    _isLoading = false;

    if (!response.succeeded) {
      _error = 'Error al cargar favoritos';
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    final rawData = (response.jsonBody?['data'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    _defaultFavorites = rawData.map(PropertySummary.fromJson).toList();

    // Keep the in-memory set in sync
    for (final p in _defaultFavorites) {
      _favoritedIds.add(p.id);
    }

    final rawMeta =
        response.jsonBody?['meta']?['pagination'] as Map<String, dynamic>?;
    if (rawMeta != null) {
      _defaultFavoritesMeta = PaginationMeta.fromJson(rawMeta);
    }

    notifyListeners();
    return Success(List.unmodifiable(_defaultFavorites));
  }

  /// Loads all favorite folders for the user.
  Future<Result<List<FavoriteFolder>>> loadFolders() async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIFavoriteContextGroup
        .getAllFavoriteFoldersCall
        .call(authToken: token);

    if (!response.succeeded) {
      return Failure(
        'Error al cargar carpetas',
        statusCode: response.statusCode,
      );
    }

    final rawFolders = (response.jsonBody?['data']?['folders'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    _folders = rawFolders.map(FavoriteFolder.fromJson).toList();
    notifyListeners();
    return Success(List.unmodifiable(_folders));
  }

  /// Creates a new folder and refreshes the folder list.
  Future<Result<void>> createFolder(String name) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIFavoriteContextGroup.createFavoriteFolderCall
        .call(folderName: name, authToken: token);

    if (!response.succeeded) {
      return Failure(
        'No se pudo crear la carpeta',
        statusCode: response.statusCode,
      );
    }
    await loadFolders();
    return const Success(null);
  }

  /// Deletes a folder and refreshes the folder list.
  Future<Result<void>> deleteFolder(String folderId) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIFavoriteContextGroup.deleteFavoriteFolderCall
        .call(folderId: folderId, authToken: token);

    if (!response.succeeded) {
      return Failure(
        'No se pudo eliminar la carpeta',
        statusCode: response.statusCode,
      );
    }
    _folders.removeWhere((f) => f.id == folderId);
    notifyListeners();
    return const Success(null);
  }

  /// Checks whether a specific property is favorited and caches the result.
  Future<void> refreshFavoriteStatus(String propertyId) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIFavoriteContextGroup
        .checkIfPropertyIsFavoritedCall
        .call(propertyId: propertyId, authToken: token);

    if (response.succeeded) {
      final isFavorited =
          response.jsonBody?['data']?['isFavorited'] as bool? ?? false;
      if (isFavorited) {
        _favoritedIds.add(propertyId);
      } else {
        _favoritedIds.remove(propertyId);
      }
      notifyListeners();
    }
  }

  /// Updates a folder's name.
  Future<Result<void>> updateFolderName(String folderId, String newName) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIFavoriteContextGroup
        .updateFavoriteFolderNameCall
        .call(folderId: folderId, udatedFolderName: newName, authToken: token);

    if (!response.succeeded) {
      return Failure(
        'No se pudo actualizar el nombre de la carpeta',
        statusCode: response.statusCode,
      );
    }
    // Update local cache
    final index = _folders.indexWhere((f) => f.id == folderId);
    if (index != -1) {
      // Assuming FavoriteFolder has a copyWith method or we just reload.
      // Easiest is to reload:
      await loadFolders();
    }
    return const Success(null);
  }

  /// Gets properties inside a specific folder.
  Future<Result<List<dynamic>>> getFavoritesInFolder(String folderId,
      {int page = 1, int limit = 20}) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIFavoriteContextGroup.getFavoritesInFolderCall
        .call(
            folderId: folderId,
            page: page.toString(),
            limit: limit.toString(),
            authToken: token);

    if (!response.succeeded) {
      return Failure(
        'Error al cargar favoritos de la carpeta',
        statusCode: response.statusCode,
      );
    }

    final rawData = (response.jsonBody?['data']?['favorites'] as List? ?? []);
    return Success(rawData);
  }

  /// Removes a property from a specific folder.
  Future<Result<void>> removeFavoriteFromFolder(
      String folderId, String propertyId) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIFavoriteContextGroup
        .removeFavoriteFromFolderCall
        .call(folderId: folderId, propertyId: propertyId, authToken: token);

    if (!response.succeeded) {
      return Failure(
        'No se pudo eliminar de la carpeta',
        statusCode: response.statusCode,
      );
    }
    // Refresh global favorite status just in case it was completely removed
    await refreshFavoriteStatus(propertyId);
    return const Success(null);
  }

  /// Adds a property to a specific folder.
  Future<Result<void>> addFavoriteToFolder(
      String folderId, String propertyId) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIFavoriteContextGroup.addFavoriteToFolderCall
        .call(folderId: folderId, propertyId: propertyId, authToken: token);

    if (!response.succeeded) {
      return Failure(
        'No se pudo agregar a la carpeta',
        statusCode: response.statusCode,
      );
    }
    _favoritedIds.add(propertyId);
    notifyListeners();
    return const Success(null);
  }

  /// Clears all cached state (call on logout).
  void clear() {
    _favoritedIds.clear();
    _folders = [];
    _defaultFavorites = [];
    _defaultFavoritesMeta = null;
    _error = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _updatePropertyFavoriteStatus(String propertyId, bool isFavorite) {
    final index = _defaultFavorites.indexWhere((p) => p.id == propertyId);
    if (index != -1) {
      _defaultFavorites[index] =
          _defaultFavorites[index].copyWith(isFavorite: isFavorite);
    }
  }
}
