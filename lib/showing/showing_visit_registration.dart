/// Qué puede hacer el Showing con una de sus visitas, según el estado del
/// backend y la hora de inicio.
enum ShowingRegistration {
  /// Todavía no empezó: se muestra la ruta y los detalles.
  upcoming,

  /// Ya empezó y falta el registro: "Registrar visita".
  register,

  /// Vencida: pasaron 24 h desde el fin sin registro (el backend la pasa a
  /// NO_SHOW/REPORT_EXPIRED) y se envía la razón con "Reportar".
  overdue,

  /// Completada, cancelada, reportada o reasignada: ya no hay nada que hacer.
  closed,
}

/// Substatus en los que el backend acepta el registro de la visita.
const _registrable = {'ASSIGNED', 'VISIT_IN_PROGRESS', 'AWAITING_REPORT'};

/// Substatus que se piden al listar: las que se pueden registrar y las
/// vencidas. Sin filtro el backend manda también las cerradas.
const showingPendingSubstatuses =
    'ASSIGNED,VISIT_IN_PROGRESS,AWAITING_REPORT,REPORT_EXPIRED';

/// Inicio de la visita: `confirmedTimeSlot.utcTimestamp` en hora local o, si
/// no viene, `date` + `time` tal cual.
DateTime? showingVisitStart(String date, String time, {String? utcTimestamp}) {
  final utc = DateTime.tryParse(utcTimestamp ?? '');
  if (utc != null) return utc.toLocal();
  final d = date.split('-');
  if (d.length != 3) return null;
  final t = time.split(':');
  final year = int.tryParse(d[0]);
  final month = int.tryParse(d[1]);
  final day = int.tryParse(d[2]);
  if (year == null || month == null || day == null) return null;
  return DateTime(
    year,
    month,
    day,
    int.tryParse(t[0]) ?? 0,
    t.length > 1 ? int.tryParse(t[1]) ?? 0 : 0,
  );
}

ShowingRegistration showingRegistration({
  required String status,
  required String substatus,
  required DateTime? start,
  DateTime? now,
}) {
  final s = status.toUpperCase();
  final sub = substatus.toUpperCase();
  if (sub == 'REPORT_EXPIRED') return ShowingRegistration.overdue;
  if (s == 'COMPLETED' || s == 'CANCELLED' || s == 'NO_SHOW') {
    return ShowingRegistration.closed;
  }
  if (sub.isNotEmpty && !_registrable.contains(sub)) {
    return ShowingRegistration.closed;
  }
  // El backend la pasa a "en curso" 1 h antes del fin; el botón aparece
  // desde la hora de inicio, que es cuando empieza la visita.
  if (sub == 'VISIT_IN_PROGRESS' || sub == 'AWAITING_REPORT') {
    return ShowingRegistration.register;
  }
  if (start == null) return ShowingRegistration.upcoming;
  return (now ?? DateTime.now()).isBefore(start)
      ? ShowingRegistration.upcoming
      : ShowingRegistration.register;
}
