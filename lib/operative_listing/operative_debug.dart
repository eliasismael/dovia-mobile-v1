import 'package:flutter/foundation.dart';

/// Atajos para probar el flujo del Operative Listing sin esperar al horario
/// de la visita. Solo existen en debug: en un build de release [ignoreSchedule]
/// es siempre `false`.
///
/// El horario lo controla solo la app (el backend no rechaza el aviso de
/// llegada ni el checklist fuera de hora), así que alcanza con esto.
class OperativeDebug {
  static bool _ignoreSchedule = false;

  /// Habilita "Notificar que llegué" y el checklist fuera del horario.
  static bool get ignoreSchedule => kDebugMode && _ignoreSchedule;

  /// Se activa con una pulsación larga sobre el aviso del horario.
  static bool toggle() => _ignoreSchedule = kDebugMode && !_ignoreSchedule;
}
