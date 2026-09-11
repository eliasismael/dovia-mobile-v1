import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Identificador estable de la instalacion de la app para notificaciones PUSH.
///
/// Reglas del backend (`docs/contexts/notification/notification-installations.md`):
///
/// - Lo genera y conserva el cliente; el backend nunca lo emite.
/// - Identifica una instalacion, NO a un usuario, una sesion ni un token FCM.
/// - Se genera una sola vez y se persiste. No se regenera en login, logout,
///   reinicio ni rotacion del token FCM.
/// - En web vive en `localStorage` (via shared_preferences), asi que cambia al
///   limpiar el storage, en incognito y al cambiar de origen (p. ej. una URL
///   de ngrok distinta).
/// - Si otra cuenta inicia sesion en la misma instalacion, su PUT la transfiere
///   automaticamente; no hace falta un ID nuevo.
class NotificationInstallation {
  NotificationInstallation._();

  static const String _kInstallationIdKey = '_notification_installation_id_';

  static String? _cached;

  /// Devuelve el `installationId` persistido, creandolo la primera vez.
  static Future<String> id() async {
    final cached = _cached;
    if (cached != null) return cached;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kInstallationIdKey);
    if (stored != null && stored.isNotEmpty) {
      _cached = stored;
      return stored;
    }

    final created = generateUuidV4();
    await prefs.setString(_kInstallationIdKey, created);
    _cached = created;
    return created;
  }

  /// Valor ya cargado en memoria, o `null` si todavia no se llamo a [id].
  ///
  /// Util en caminos sincronos (p. ej. armar un log) sin forzar un `await`.
  static String? get cachedId => _cached;

  /// Descarta el ID persistido y genera uno nuevo en la proxima llamada.
  ///
  /// Solo para soporte/diagnostico: el uso normal conserva el mismo ID de por
  /// vida. Revocar la instalacion anterior en el backend queda a cargo de quien
  /// llame (`DELETE /notifications/devices/{installationId}`).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kInstallationIdKey);
    _cached = null;
  }

  /// UUID v4 con `Random.secure`, sin sumar dependencias al proyecto.
  static String generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10xx

    final hex =
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
