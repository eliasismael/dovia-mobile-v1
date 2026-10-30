import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/showing/showing_visit_registration.dart';

void main() {
  final start = DateTime(2026, 10, 30, 15, 0);

  ShowingRegistration at(DateTime now,
          {String status = 'SCHEDULED', String substatus = 'ASSIGNED'}) =>
      showingRegistration(
          status: status, substatus: substatus, start: start, now: now);

  test('antes de la hora de inicio todavía no se registra', () {
    expect(at(DateTime(2026, 10, 30, 14, 59)), ShowingRegistration.upcoming);
  });

  test('desde la hora de inicio aparece registrar visita', () {
    expect(at(start), ShowingRegistration.register);
    expect(at(DateTime(2026, 10, 31, 9)), ShowingRegistration.register);
    expect(
        at(DateTime(2026, 10, 30, 14),
            status: 'IN_PROGRESS', substatus: 'VISIT_IN_PROGRESS'),
        ShowingRegistration.register);
    expect(
        at(DateTime(2026, 10, 31),
            status: 'IN_PROGRESS', substatus: 'AWAITING_REPORT'),
        ShowingRegistration.register);
  });

  test('vencida cuando el backend la marca REPORT_EXPIRED', () {
    expect(
        at(DateTime(2026, 11, 1),
            status: 'NO_SHOW', substatus: 'REPORT_EXPIRED'),
        ShowingRegistration.overdue);
  });

  test('completadas, canceladas o reportadas no piden nada', () {
    final later = DateTime(2026, 11, 1);
    expect(at(later, status: 'COMPLETED', substatus: ''),
        ShowingRegistration.closed);
    expect(at(later, status: 'CANCELLED', substatus: 'CANCELLED'),
        ShowingRegistration.closed);
    expect(at(later, status: 'NO_SHOW', substatus: 'NOT_COMPLETED_REPORTED'),
        ShowingRegistration.closed);
    expect(
        at(later, substatus: 'PROBLEM_REPORTED'), ShowingRegistration.closed);
  });

  group('showingVisitStart', () {
    test('usa utcTimestamp en hora local', () {
      final s = showingVisitStart('2026-04-11', '14:00',
          utcTimestamp: '2026-04-11T20:00:00.000Z');
      expect(s, DateTime.utc(2026, 4, 11, 20).toLocal());
    });

    test('sin utcTimestamp usa fecha y hora', () {
      expect(showingVisitStart('2026-04-11', '14:30'),
          DateTime(2026, 4, 11, 14, 30));
      expect(showingVisitStart('', '14:30'), isNull);
    });
  });
}
