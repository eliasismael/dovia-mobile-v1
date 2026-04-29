import 'package:flutter/foundation.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_users.dart';
import '/core/result.dart';
import '/domain/user_models.dart';
import '/flutter_flow/uploaded_file.dart';

/// Single Source of Truth for the authenticated user's profile.
///
/// Caches the profile for the session so that every screen does not need
/// to issue a separate `/users/me` request.
///
/// Usage:
/// ```dart
/// // In widget build or initState
/// context.read<UserRepository>().loadProfile();
///
/// // Reactive display
/// Consumer<UserRepository>(
///   builder: (_, repo, __) {
///     if (repo.isLoading) return CircularProgressIndicator();
///     return Text(repo.profile?.displayName ?? '');
///   },
/// );
/// ```
class UserRepository extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  /// Loads the authenticated user profile. Returns the cached value if
  /// already loaded, unless [forceRefresh] is true.
  Future<Result<UserProfile>> loadProfile({bool forceRefresh = false}) async {
    if (_profile != null && !forceRefresh) {
      return Success(_profile!);
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIUserContextGroup
        .getAuthenticatedUserProfileCall
        .call(authToken: token);

    _isLoading = false;

    if (!response.succeeded) {
      _error = 'No se pudo cargar el perfil';
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    final body = response.jsonBody as Map<String, dynamic>?;
    if (body == null) {
      _error = 'Respuesta inesperada del servidor';
      notifyListeners();
      return Failure(_error!);
    }

    _profile = UserProfile.fromJson(body);
    notifyListeners();
    return Success(_profile!);
  }

  /// Uploads a new profile picture.
  Future<Result<bool>> uploadAvatar(FFUploadedFile file) async {
    _isLoading = true;
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIUserContextGroup.uploadProfilePictureCall
        .call(authToken: token, file: file);

    _isLoading = false;

    if (!response.succeeded) {
      _error = 'Error al subir la imagen';
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    // Refresh profile to show new image
    await loadProfile(forceRefresh: true);
    notifyListeners();
    return const Success(true);
  }

  /// Clears the cached profile (call on logout).
  void clear() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}
