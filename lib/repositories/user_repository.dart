import 'package:flutter/foundation.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_users.dart';
import '/core/result.dart';
import '/domain/user_models.dart';
import '/flutter_flow/flutter_flow_util.dart' show getJsonField;
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

  // Performance summary (earnings & rating). Backend currently returns 0 for
  // both until the underlying logic is implemented.
  double? _totalEarned;
  double? _averageStars;
  bool _isLoadingSummary = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  double? get totalEarned => _totalEarned;
  double? get averageStars => _averageStars;
  bool get isLoadingSummary => _isLoadingSummary;

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
      debugPrint('[Perfil] GET /users/me -> '
          '${response.statusCode}: ${response.bodyText}');
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
    debugPrint(
        '[Foto de perfil] ${file.name} (${file.bytes?.length ?? 0} bytes) '
        '-> ${response.statusCode}: ${response.bodyText}');

    _isLoading = false;

    if (!response.succeeded) {
      final message = getJsonField(response.jsonBody, r'$.message')?.toString();
      _error = message != null && message.isNotEmpty
          ? 'Error al subir la imagen: $message'
          : 'Error al subir la imagen (${response.statusCode})';
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    // Refresh profile to show new image
    await loadProfile(forceRefresh: true);
    debugPrint(
        '[Foto de perfil] avatar tras recargar: ${_profile?.profilePictureUrl}');
    notifyListeners();
    return const Success(true);
  }

  /// Uploads a user document (identification, criminal/police record, utility
  /// bill). [documentType] must be one of the API slugs:
  /// `identification-document`, `criminal-record`, `police-record`,
  /// `utility-bill`.
  Future<Result<bool>> uploadDocument(
    String documentType,
    FFUploadedFile file,
  ) async {
    // La sesión manda: el perfil en memoria puede ser de la cuenta anterior
    // si se cerró sesión y se entró (o registró) con otra.
    final userId =
        currentUserUid.isNotEmpty ? currentUserUid : (_profile?.uid ?? '');
    if (userId.isEmpty) {
      return const Failure('No se pudo identificar al usuario');
    }

    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIUserContextGroup.uploadUserDocumentCall.call(
      userId: userId,
      documentType: documentType,
      authToken: token,
      file: file,
    );

    if (!response.succeeded) {
      return Failure('Error al subir el documento',
          statusCode: response.statusCode);
    }

    // Refresh profile so newly stored document URLs are reflected.
    await loadProfile(forceRefresh: true);
    return const Success(true);
  }

  /// Loads the performance summary (earnings & average rating).
  Future<Result<bool>> loadPerformanceSummary(
      {bool forceRefresh = false}) async {
    if (_totalEarned != null && _averageStars != null && !forceRefresh) {
      return const Success(true);
    }

    _isLoadingSummary = true;
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIUserContextGroup.getPerformanceSummaryCall
        .call(authToken: token);

    _isLoadingSummary = false;

    if (!response.succeeded) {
      notifyListeners();
      return Failure('No se pudo cargar el resumen',
          statusCode: response.statusCode);
    }

    _averageStars = DOVIAAPIUserContextGroup.getPerformanceSummaryCall
            .averageStars(response.jsonBody) ??
        0;
    _totalEarned = DOVIAAPIUserContextGroup.getPerformanceSummaryCall
            .totalEarned(response.jsonBody) ??
        0;
    notifyListeners();
    return const Success(true);
  }

  /// Updates the user profile fields.
  Future<Result<bool>> updateProfile({
    String? name,
    String? lastname,
    String? gender,
    String? nationality,
    String? phoneCountryCode,
    String? phoneNumber,
    String? address,
    String? workArea,
    String? workZoneId,
  }) async {
    // La sesión manda: el perfil en memoria puede ser de la cuenta anterior
    // si se cerró sesión y se entró (o registró) con otra.
    final userId =
        currentUserUid.isNotEmpty ? currentUserUid : (_profile?.uid ?? '');
    if (userId.isEmpty) {
      return const Failure('No se pudo identificar al usuario');
    }

    _isLoading = true;
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIUserContextGroup.updateUserProfileCall.call(
      userId: userId,
      authToken: token,
      name: name,
      lastname: lastname,
      gender: gender,
      nationality: nationality,
      phoneCountryCode: phoneCountryCode,
      phoneNumber: phoneNumber,
      address: address,
      workArea: workArea,
      workZoneId: workZoneId,
    );
    debugPrint('[Perfil] PATCH /users/$userId -> '
        '${response.statusCode}: ${response.bodyText}');

    _isLoading = false;

    if (!response.succeeded) {
      final message = getJsonField(response.jsonBody, r'$.message')?.toString();
      _error = message != null && message.isNotEmpty
          ? 'Error al actualizar el perfil: $message'
          : 'Error al actualizar el perfil (${response.statusCode})';
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    await loadProfile(forceRefresh: true);
    notifyListeners();
    return const Success(true);
  }

  /// Updates user preferences.
  Future<Result<bool>> updatePreferences({
    String? propertyType,
    String? acquisitionModality,
    String? coordinates,
    String? description,
  }) async {
    // La sesión manda: el perfil en memoria puede ser de la cuenta anterior
    // si se cerró sesión y se entró (o registró) con otra.
    final userId =
        currentUserUid.isNotEmpty ? currentUserUid : (_profile?.uid ?? '');
    if (userId.isEmpty) {
      return const Failure('No se pudo identificar al usuario');
    }

    _isLoading = true;
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIUserContextGroup.updateUserPreferencesNEWCall.call(
      userId: userId,
      authToken: token,
      propertyType: propertyType,
      acquisitionModality: acquisitionModality,
      coordinates: coordinates,
      description: description,
    );

    _isLoading = false;

    if (!response.succeeded) {
      final message = getJsonField(response.jsonBody, r'$.message')?.toString();
      _error = (message != null && message.isNotEmpty)
          ? message
          : 'Error al actualizar preferencias';
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    await loadProfile(forceRefresh: true);
    notifyListeners();
    return const Success(true);
  }

  /// Deactivates the user's account.
  Future<Result<bool>> deactivateAccount({String? reason}) async {
    _isLoading = true;
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIUserContextGroup.deactivateMyAccountCall.call(
      authToken: token,
      reason: reason,
    );

    _isLoading = false;

    if (!response.succeeded) {
      _error = 'Error al desactivar la cuenta';
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    clear();
    return const Success(true);
  }

  /// Clears the cached profile (call on logout).
  void clear() {
    _profile = null;
    _error = null;
    _totalEarned = null;
    _averageStars = null;
    notifyListeners();
  }
}
