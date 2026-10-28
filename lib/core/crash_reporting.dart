/// Reporte de errores no capturados (Firebase Crashlytics).
///
/// Igual que con los push, la app trabaja contra [CrashReporter] y no contra
/// el SDK: así se prueba con uno falso y, en web o sin Firebase, queda
/// [NoopCrashReporter], que solo los imprime.
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract class CrashReporter {
  /// Error de Dart fuera del framework (un Future sin `catch`, por ejemplo).
  Future<void> recordError(Object error, StackTrace? stack, {bool fatal});

  /// Error que reportó el framework (build, layout, gestos). También lo
  /// muestra en consola, como hace Flutter por defecto.
  Future<void> recordFlutterError(FlutterErrorDetails details);

  /// Asocia los reportes a quien tiene la sesión abierta; null al cerrarla.
  Future<void> setUser(String? uid);
}

class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> recordError(Object error, StackTrace? stack,
      {bool fatal = false}) async {
    debugPrint('[Crash] $error\n$stack');
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async =>
      FlutterError.presentError(details);

  @override
  Future<void> setUser(String? uid) async {}
}

/// [CrashReporter] sobre Crashlytics. En debug no envía nada: los errores de
/// desarrollo no tienen que mezclarse con los de la gente.
class FirebaseCrashReporter implements CrashReporter {
  FirebaseCrashReporter() {
    _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  @override
  Future<void> recordError(Object error, StackTrace? stack,
          {bool fatal = false}) =>
      _crashlytics.recordError(error, stack, fatal: fatal);

  // Crashlytics ya lo muestra en consola antes de registrarlo.
  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) =>
      _crashlytics.recordFlutterError(details);

  @override
  Future<void> setUser(String? uid) =>
      _crashlytics.setUserIdentifier(uid ?? '');
}

/// El que usa la app. Arranca en [NoopCrashReporter] y pasa a Firebase cuando
/// este se inicializa (ver `main.dart`).
CrashReporter crashReporter = const NoopCrashReporter();

/// Manda a [crashReporter] los errores que hoy se pierden: los del framework
/// (que se siguen mostrando en consola) y los de Dart que nadie capturó.
void installErrorHandlers() {
  FlutterError.onError = (details) => crashReporter.recordFlutterError(details);
  PlatformDispatcher.instance.onError = (error, stack) {
    crashReporter.recordError(error, stack, fatal: true);
    return true;
  };
}
