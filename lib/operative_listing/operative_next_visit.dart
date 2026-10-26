import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Próxima visita del Operative Listing: la asignada más cercana que todavía
/// está en plazo (hasta 24 h después del horario), con el mismo criterio que
/// "Tus próximas visitas" del Home.
///
/// Cada pantalla tiene su propia navbar: [lastKnown] deja el último resultado
/// para que el botón aparezca enseguida mientras se vuelve a consultar.
class OperativeNextVisit {
  static String? lastKnown;

  static Future<String?> fetch() async {
    final res =
        await DOVIAAPIVisitContextGroup.getOperativeListerVisitsCall.call(
      authToken: currentAuthenticationToken ?? '',
      substatus: 'ASSIGNED',
      page: '1',
      limit: '50',
    );
    if (!res.succeeded) return lastKnown;
    final raw = getJsonField(res.jsonBody, r'$.data');
    if (raw is! List) return lastKnown = null;
    return lastKnown = nextVisitIdFrom(raw, DateTime.now());
  }

  /// Puro para testear: la visita con el horario confirmado más cercano que no
  /// pasó hace más de 24 h.
  static String? nextVisitIdFrom(List visits, DateTime now) {
    final limit = now.subtract(const Duration(hours: 24));
    String? bestId;
    DateTime? bestSlot;
    for (final v in visits) {
      if (v is! Map) continue;
      final slot = v['confirmedSlot'];
      if (slot is! Map) continue;
      final d = DateTime.tryParse(slot['date']?.toString() ?? '');
      if (d == null) continue;
      final parts = (slot['time']?.toString() ?? '').split(':');
      final at = DateTime(
        d.year,
        d.month,
        d.day,
        int.tryParse(parts[0]) ?? 0,
        parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      );
      if (at.isBefore(limit)) continue;
      if (bestSlot == null || at.isBefore(bestSlot)) {
        bestSlot = at;
        bestId = v['id']?.toString();
      }
    }
    return (bestId == null || bestId.isEmpty) ? null : bestId;
  }
}
