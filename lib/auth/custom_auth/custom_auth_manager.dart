import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_auth_user_provider.dart';

export 'custom_auth_manager.dart';

const _kAuthTokenKey = '_auth_authentication_token_';
const _kRefreshTokenKey = '_auth_refresh_token_';
const _kTokenExpirationKey = '_auth_token_expiration_';
const _kUidKey = '_auth_uid_';
const _kProviderKey = '_auth_provider_';

/// Sesión iniciada con Google (tokens de Cognito con el cliente móvil): se
/// renueva directo en Cognito, no con `/auth/refresh-token`.
const kGoogleAuthProvider = 'google';

class CustomAuthManager {
  // Auth session attributes
  String? authenticationToken;
  String? refreshToken;
  DateTime? tokenExpiration;
  // User attributes
  String? uid;

  /// Cómo se inició la sesión: [kGoogleAuthProvider] o null (correo y
  /// contraseña).
  String? authProvider;
  bool get isGoogleSession => authProvider == kGoogleAuthProvider;

  /// Donde se guarda el refresh token de las sesiones de Google (Keystore /
  /// Keychain), en vez de las preferencias sin cifrar.
  static FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future signOut() async {
    if (isGoogleSession) _writeSecureRefreshToken(null);
    authenticationToken = null;
    refreshToken = null;
    tokenExpiration = null;
    uid = null;
    authProvider = null;

    // Update the current user.
    _setCurrentUser(DoviaAuthUser(loggedIn: false));
    persistAuthData();
  }

  Future<DoviaAuthUser?> signIn({
    String? authenticationToken,
    String? refreshToken,
    DateTime? tokenExpiration,
    String? authUid,
    String? provider,
  }) async {
    // Una sesión de Google anterior no deja su refresh token guardado.
    if (isGoogleSession && provider != kGoogleAuthProvider) {
      _writeSecureRefreshToken(null);
    }
    authProvider = provider;
    return _updateCurrentUser(
      authenticationToken: authenticationToken,
      refreshToken: refreshToken,
      tokenExpiration: tokenExpiration,
      authUid: authUid,
    );
  }

  void updateAuthUserData({
    String? authenticationToken,
    String? refreshToken,
    DateTime? tokenExpiration,
    String? authUid,
  }) {
    assert(
      currentUser?.loggedIn ?? false,
      'User must be logged in to update auth user data.',
    );

    // Renovar tokens no cambia de usuario: sin uid nuevo se conserva el que
    // había, en vez de dejar `currentUserUid` vacío.
    _updateCurrentUser(
      authenticationToken: authenticationToken,
      refreshToken: refreshToken,
      tokenExpiration: tokenExpiration,
      authUid: authUid ?? uid,
    );
  }

  DoviaAuthUser? _updateCurrentUser({
    String? authenticationToken,
    String? refreshToken,
    DateTime? tokenExpiration,
    String? authUid,
  }) {
    this.authenticationToken = authenticationToken;
    this.refreshToken = refreshToken;
    this.tokenExpiration = tokenExpiration;
    uid = authUid;

    // Update the current user stream.
    final updatedUser = DoviaAuthUser(
      loggedIn: true,
      uid: authUid,
    );
    _setCurrentUser(updatedUser);
    persistAuthData();
    return updatedUser;
  }

  late SharedPreferences _prefs;
  Future initialize() async {
    _prefs = await SharedPreferences.getInstance();

    try {
      authenticationToken = _prefs.getString(_kAuthTokenKey);
      refreshToken = _prefs.getString(_kRefreshTokenKey);
      tokenExpiration = _prefs.getInt(_kTokenExpirationKey) != null
          ? DateTime.fromMillisecondsSinceEpoch(
              _prefs.getInt(_kTokenExpirationKey)!)
          : null;
      uid = _prefs.getString(_kUidKey);
      authProvider = _prefs.getString(_kProviderKey);
      if (isGoogleSession) {
        refreshToken = await _readSecureRefreshToken();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth: $e');
      }
      return;
    }

    final authTokenExists = authenticationToken != null;
    final tokenExpired =
        tokenExpiration != null && tokenExpiration!.isBefore(DateTime.now());
    // Con un refreshToken la sesión sigue: `restoreSession()` pide un idToken
    // nuevo al arrancar, y si el backend lo rechaza recién ahí se cierra.
    final canRefresh = refreshToken != null && refreshToken!.isNotEmpty;
    final updatedUser = DoviaAuthUser(
      loggedIn: authTokenExists && (!tokenExpired || canRefresh),
      uid: uid,
    );
    _setCurrentUser(updatedUser);
  }

  /// `currentUser` (y con él `loggedIn`) se actualiza acá mismo y no solo
  /// cuando alguien escucha el stream: al arrancar todavía nadie lo escucha, y
  /// `restoreSession()` veía `loggedIn == false` y no renovaba la sesión.
  void _setCurrentUser(DoviaAuthUser user) {
    currentUser = user;
    doviaAuthUserSubject.add(user);
  }

  void persistAuthData() {
    authenticationToken != null
        ? _prefs.setString(_kAuthTokenKey, authenticationToken!)
        : _prefs.remove(_kAuthTokenKey);
    authProvider != null
        ? _prefs.setString(_kProviderKey, authProvider!)
        : _prefs.remove(_kProviderKey);
    if (isGoogleSession) {
      _prefs.remove(_kRefreshTokenKey);
      _writeSecureRefreshToken(refreshToken);
    } else {
      refreshToken != null
          ? _prefs.setString(_kRefreshTokenKey, refreshToken!)
          : _prefs.remove(_kRefreshTokenKey);
    }
    tokenExpiration != null
        ? _prefs.setInt(
            _kTokenExpirationKey, tokenExpiration!.millisecondsSinceEpoch)
        : _prefs.remove(_kTokenExpirationKey);
    uid != null ? _prefs.setString(_kUidKey, uid!) : _prefs.remove(_kUidKey);
  }
}

extension on CustomAuthManager {
  Future<String?> _readSecureRefreshToken() async {
    try {
      return await CustomAuthManager.secureStorage.read(key: _kRefreshTokenKey);
    } catch (e) {
      if (kDebugMode) print('No se pudo leer el refresh token: $e');
      return null;
    }
  }

  void _writeSecureRefreshToken(String? value) {
    final storage = CustomAuthManager.secureStorage;
    final op = value != null
        ? storage.write(key: _kRefreshTokenKey, value: value)
        : storage.delete(key: _kRefreshTokenKey);
    op.catchError((Object e) {
      if (kDebugMode) print('No se pudo guardar el refresh token: $e');
    });
  }
}

DoviaAuthUser? currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;
