import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/index.dart';
import 'package:dovia/notifications/notification_catalog.dart';
import 'package:dovia/notifications/notification_router.dart';
import 'package:dovia/notifications/notification_test_sheet.dart';

void main() {
  group('catálogo de notificaciones', () {
    test('trae las 137 y todas tienen un tipo de usuario elegible', () {
      expect(kNotificationCatalog, hasLength(137));
      final total = kNotificationTestRoles.keys
          .map((role) => catalogFor(role).length)
          .fold(0, (a, b) => a + b);
      expect(total, kNotificationCatalog.length);
    });

    test('el texto de prueba no deja variables sin reemplazar', () {
      for (final entry in kNotificationCatalog) {
        expect(entry.sampleBody, isNot(contains('{{')), reason: entry.code);
        expect(entry.sampleActionPath, isNot(contains('{{')),
            reason: entry.code);
      }
      final enCamino = kNotificationCatalog
          .firstWhere((e) => e.code == 'SHOWING_ASSOCIATE_ON_MY_WAY_CLIENT');
      expect(enCamino.sampleBody, startsWith('Juan Pérez está en camino'));
    });

    test('la ruta de prueba lleva el código y los datos fuera de la ruta', () {
      final confirmada = kNotificationCatalog
          .firstWhere((e) => e.code == 'VISIT_CONFIRMED_CLIENT');
      expect(confirmada.sampleActionPath,
          '/visits/VISIT_ID?type=VISIT_CONFIRMED_CLIENT&propertyId=PROPERTY_ID');
    });

    test(
        'un recordatorio con plazo al final se abre como el de su destinatario',
        () {
      final destino = notificationDetailFor(
        role: 'CLIENT',
        actionPath:
            '/visits/v1?type=CLIENT_VISIT_REMINDER_CLIENT_24H&propertyId=p1',
      );
      expect(
          destino,
          NotificationDestination(DOVIACLIENTSobreMiVisitaWidget.routeName,
              const {'visitId': 'v1', 'propertyId': 'p1'}));
    });
  });

  testWidgets('elegir el tipo de usuario lista sus notificaciones',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await FFAppState().initializePersistedState();
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          ctx = context;
          return const SizedBox.expand();
        }),
      ),
    ));
    showNotificationTestSheet(ctx);
    await tester.pumpAndSettle();

    // Arranca en cliente con la primera de las suyas.
    final primeraCliente = catalogFor('CLIENT').first;
    expect(
        find.widgetWithText(TextField, primeraCliente.title), findsOneWidget);

    await tester.tap(find.text('Cliente (interesado / comprador) '
        '(${catalogFor('CLIENT').length})'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dueño (${catalogFor('OWNER').length})').last);
    await tester.pumpAndSettle();

    final primeraDueno = catalogFor('OWNER').first;
    expect(find.widgetWithText(TextField, primeraDueno.sampleBody),
        findsOneWidget);
    expect(find.text('${primeraDueno.code} · ${primeraDueno.recipient}'),
        findsOneWidget);
  });
}
