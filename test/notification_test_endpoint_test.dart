import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/core/result.dart';
import 'package:dovia/index.dart';
import 'package:dovia/notifications/notification_router.dart';
import 'package:dovia/repositories/notifications_repository.dart';

void main() {
  group('POST /notifications/test', () {
    setUp(() async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      await authManager.initialize();
      await authManager.signIn(authenticationToken: 'jwt', authUid: 'u1');
    });

    test('manda título, texto y ruta, y devuelve el eventId', () async {
      http.Request? sent;
      final result = await http.runWithClient(
        () => NotificationsRepository().sendTestNotification(
          title: 'Hola "Dovia"',
          body: 'Texto',
          actionPath: '/offers/o1?type=OFFER_ACCEPTED_CLIENT',
        ),
        () => MockClient((req) async {
          sent = req;
          return http.Response(
            jsonEncode({
              'data': {'eventId': 'ev-1'}
            }),
            202,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      expect(sent!.method, 'POST');
      expect(sent!.url.path, endsWith('/notifications/test'));
      expect(sent!.headers['Authorization'], 'Bearer jwt');
      expect(jsonDecode(sent!.body), {
        'title': 'Hola "Dovia"',
        'body': 'Texto',
        'actionPath': '/offers/o1?type=OFFER_ACCEPTED_CLIENT',
      });
      expect((result as Success).data, 'ev-1');
    });
  });

  group('tocar una notificación de prueba', () {
    test('el código y los datos en la ruta la resuelven como la real', () {
      expect(
        resolveNotificationTap(
          role: 'CLIENT',
          type: kTestNotificationType,
          actionPath: '/visits/v1?type=VISIT_CONFIRMED_CLIENT&propertyId=p1',
        ),
        NotificationDestination(DOVIACLIENTSobreMiVisitaWidget.routeName,
            {'visitId': 'v1', 'propertyId': 'p1'}),
      );
      expect(
        resolveNotificationTap(
          role: 'CLIENT',
          type: kTestNotificationType,
          actionPath: '/offers/o1?type=OFFER_RECEIVED_OWNER',
        )?.routeName,
        DOVIACLIENTPropuestasRecientesWidget.routeName,
      );
    });

    test('en una real, el código de la notificación manda sobre la ruta', () {
      expect(
        resolveNotificationTap(
          role: 'CLIENT',
          type: 'OFFER_RECEIVED_OWNER',
          actionPath: '/offers/o1?type=OFFER_ACCEPTED_CLIENT',
        )?.routeName,
        DOVIACLIENTPropuestasRecientesWidget.routeName,
      );
    });

    test('una ruta de pantalla de la app abre esa pantalla', () {
      expect(
        resolveNotificationTap(
          role: 'CLIENT',
          type: kTestNotificationType,
          actionPath: '/dHCLIENTHomepage',
          isAppRoute: (path) => path == '/dHCLIENTHomepage',
        ),
        const NotificationDestination.location('/dHCLIENTHomepage'),
      );
    });

    test('una ruta que no es pantalla ni tiene mapeo no navega', () {
      expect(
        resolveNotificationTap(
          role: 'CLIENT',
          type: kTestNotificationType,
          actionPath: '/no-existe',
          isAppRoute: (_) => false,
        ),
        isNull,
      );
    });
  });
}
