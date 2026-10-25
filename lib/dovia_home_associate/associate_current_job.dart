import 'package:flutter/foundation.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';

/// Trabajo que el asociado tiene en curso (`IN_PROGRESS`: ya avisó su
/// llegada y todavía no lo cerró), para el acceso "En curso" de la navbar.
///
/// Se guarda un rato en memoria para no pedirlo en cada pantalla: la navbar
/// se reconstruye con cada navegación. Avisar la llegada o cerrar un trabajo
/// lo invalidan.
class AssociateCurrentJob {
  AssociateCurrentJob._();

  static const Duration _ttl = Duration(seconds: 30);

  static Map<String, dynamic>? _job;
  static DateTime? _fetchedAt;
  static Future<Map<String, dynamic>?>? _pending;

  /// Lo último que se sabe, sin pedir nada (null: no hay o no se sabe).
  static Map<String, dynamic>? get cached => _job;

  /// Avisa cada vez que se sabe algo nuevo. La navbar lo escucha: si su
  /// pedido llegó vacío o se descartó (Ej: la sesión todavía se estaba
  /// restaurando al abrir la app), "En curso" aparece apenas otro pedido —el
  /// del inicio, por ejemplo— lo encuentra, sin esperar a cambiar de pantalla.
  static final ValueNotifier<Map<String, dynamic>?> notifier =
      ValueNotifier(null);

  /// Guarda lo que encontró otra pantalla que ya trajo los trabajos del
  /// asociado (el inicio pide todos), así no hace falta otro pedido.
  static void remember(Map<String, dynamic>? job) {
    _job = job;
    _fetchedAt = DateTime.now();
    notifier.value = job;
  }

  /// Si lo guardado sigue vigente. Falso también cuando el último pedido
  /// falló o se descartó.
  static bool get isFresh {
    final fetchedAt = _fetchedAt;
    return fetchedAt != null && DateTime.now().difference(fetchedAt) < _ttl;
  }

  static void invalidate() => _fetchedAt = null;

  /// Olvida el trabajo guardado (al cerrar sesión o cambiar de cuenta): si
  /// no, el próximo asociado veía "En curso" con el trabajo del anterior.
  static void clear() {
    _job = null;
    _fetchedAt = null;
    _pending = null;
    notifier.value = null;
  }

  static Future<Map<String, dynamic>?> load() {
    if (isFresh) return Future.value(_job);
    return _pending ??= _fetch().whenComplete(() => _pending = null);
  }

  static Future<Map<String, dynamic>?> _fetch() async {
    final generation = authManager.sessionGeneration;
    try {
      final response = await DOVIAAPIDoviaHomeContextGroup
          .listAssociateServiceRequestsCall
          .call(
        status: 'IN_PROGRESS',
        authToken: currentAuthenticationToken ?? '',
      );
      // Respuesta de una sesión anterior: no se guarda para la cuenta nueva.
      if (authManager.sessionGeneration != generation) return null;
      if (!response.succeeded) return _job;
      final list = DOVIAAPIDoviaHomeContextGroup
              .listAssociateServiceRequestsCall
              .requestsList(response.jsonBody) ??
          const [];
      Map<String, dynamic>? found;
      for (final item in list) {
        if (item is Map) {
          final data = Map<String, dynamic>.from(item);
          if (asrStatus(data) == 'IN_PROGRESS') {
            found = data;
            break;
          }
        }
      }
      remember(found);
      return found;
    } catch (_) {
      return _job;
    }
  }
}

/// Aviso cuando el asociado intenta arrancar o abrir otro trabajo teniendo uno
/// en curso: primero tiene que cerrar el que está ejecutando.
const String kJobInProgressNotice =
    'Ya tenés un trabajo en curso. Finalizalo antes de iniciar otro; lo '
    'encontrás en "En curso".';
