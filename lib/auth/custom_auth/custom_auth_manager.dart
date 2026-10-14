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

/// Marca en preferencias de que hay tokens en el almacenamiento seguro. Hace
/// falta porque en iOS el Keychain sobrevive a la desinstalación: sin la
/// marca, una reinstalación levantaría la sesión anterior.
const _kSecureSessionKey = '_auth_secure_session_';

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

  /// Donde se guardan el token y el refresh token (Keystore / Keychain), en
  /// vez de las preferencias sin cifrar.
  static FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  /// Sube en cada inicio y cierre de sesión. Quien espera una respuesta del
  /// backend la compara antes y después: si cambió, la respuesta es de otra
  /// sesión y se descarta.
  int sessionGeneration = 0;

  Future signOut() async {
    sessionGeneration++;
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
    sessionGeneration++;
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
      authProvider = _prefs.getString(_kProviderKey);
      if (_prefs.containsKey(_kAuthTokenKey)) {
        // Sesión guardada por una versión anterior, con los tokens en las
        // preferencias (el refresh de Google ya iba al almacenamiento seguro).
        authenticationToken = _prefs.getString(_kAuthTokenKey);
        refreshToken = isGoogleSession
            ? await _readSecure(_kRefreshTokenKey)
            : _prefs.getString(_kRefreshTokenKey);
        await _migrateToSecureStorage();
      } else if (_prefs.getBool(_kSecureSessionKey) ?? false) {
        authenticationToken = await _readSecure(_kAuthTokenKey);
        refreshToken = await _readSecure(_kRefreshTokenKey);
      } else {
        authenticationToken = null;
        refreshToken = null;
        _writeSecure(_kAuthTokenKey, null);
        _writeSecure(_kRefreshTokenKey, null);
      }
      tokenExpiration = _prefs.getInt(_kTokenExpirationKey) != null
          ? DateTime.fromMillisecondsSinceEpoch(
              _prefs.getInt(_kTokenExpirationKey)!)
          : null;
      uid = _prefs.getString(_kUidKey);
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
    _writeSecure(_kAuthTokenKey, authenticationToken);
    _writeSecure(_kRefreshTokenKey, refreshToken);
    _prefs.remove(_kAuthTokenKey);
    _prefs.remove(_kRefreshTokenKey);
    authenticationToken != null
        ? _prefs.setBool(_kSecureSessionKey, true)
        : _prefs.remove(_kSecureSessionKey);
    authProvider != null
        ? _prefs.setString(_kProviderKey, authProvider!)
        : _prefs.remove(_kProviderKey);
    tokenExpiration != null
        ? _prefs.setInt(
            _kTokenExpirationKey, tokenExpiration!.millisecondsSinceEpoch)
        : _prefs.remove(_kTokenExpirationKey);
    uid != null ? _prefs.setString(_kUidKey, uid!) : _prefs.remove(_kUidKey);
  }
}

extension on CustomAuthManager {
  Future<String?> _readSecure(String key) async {
    try {
      return await CustomAuthManager.secureStorage.read(key: key);
    } catch (e) {
      if (kDebugMode) print('No se pudo leer $key: $e');
      return null;
    }
  }

  Future<void> _secureOp(String key, String? value) {
    final storage = CustomAuthManager.secureStorage;
    return value != null
        ? storage.write(key: key, value: value)
        : storage.delete(key: key);
  }

  void _writeSecure(String key, String? value) {
    _secureOp(key, value).catchError((Object e) {
      if (kDebugMode) print('No se pudo guardar $key: $e');
    });
  }

  /// Pasa los tokens de las preferencias al almacenamiento seguro. Si falla,
  /// quedan donde estaban y se reintenta en el próximo arranque.
  Future<void> _migrateToSecureStorage() async {
    try {
      await _secureOp(_kAuthTokenKey, authenticationToken);
      await _secureOp(_kRefreshTokenKey, refreshToken);
    } catch (e) {
      if (kDebugMode) print('No se pudieron migrar los tokens: $e');
      return;
    }
    await _prefs.remove(_kAuthTokenKey);
    await _prefs.remove(_kRefreshTokenKey);
    if (authenticationToken != null) {
      await _prefs.setBool(_kSecureSessionKey, true);
    }
  }
}

DoviaAuthUser? currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;
