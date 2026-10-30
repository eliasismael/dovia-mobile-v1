import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/core/notification_installation.dart';
import 'package:dovia/index.dart';
import 'package:dovia/notifications/notification_router.dart';
import 'package:dovia/notifications/push_messaging.dart';
import 'package:dovia/notifications/push_notifications_service.dart';
import 'package:dovia/repositories/notifications_repository.dart';
import 'package:dovia/shared_components/notification_badge.dart';

/// Proveedor push falso: el test decide el permiso y los tokens, y dispara
/// los eventos que en la app real manda Firebase.
class _FakePush implements PushMessaging {
  PushPermission permission = PushPermission.granted;
  List<String> tokens = ['token-1'];
  int deletedTokens = 0;
  PushMessage? initialMessage;

  final tokenRefresh = StreamController<String>.broadcast();
  final foreground = StreamController<PushMessage>.broadcast();
  final opened = StreamController<PushMessage>.broadcast();

  @override
  Future<PushPermission> requestPermission() async => permission;

  @override
  Future<String?> getToken() async => tokens.isEmpty ? null : tokens.first;

  @override
  Future<void> deleteToken() async {
    deletedTokens++;
    if (tokens.isNotEmpty) tokens.removeAt(0);
  }

  @override
  Stream<String> get onTokenRefresh => tokenRefresh.stream;

  @override
  Stream<PushMessage> get onForegroundMessage => foreground.stream;

  @override
  Stream<PushMessage> get onMessageOpenedApp => opened.stream;

  @override
  Future<PushMessage?> getInitialMessage() async => initialMessage;
}

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

/// Backend falso de notificaciones: registra cada pedido y responde como el
/// real. [rejectToken] simula el 409 de un token que FCM invalidó.
class _Backend {
  final requests = <http.Request>[];
  String? rejectToken;
  int unreadCount = 0;

  List<http.Request> get devicePuts => requests
      .where((r) => r.method == 'PUT' && r.url.path.contains('/devices/'))
      .toList();

  List<http.Request> get deviceDeletes => requests
      .where((r) => r.method == 'DELETE' && r.url.path.contains('/devices/'))
      .toList();

  int get unreadCountCalls =>
      requests.where((r) => r.url.path.endsWith('/unread-count')).length;

  MockClient get client => MockClient((req) async {
        requests.add(req);
        final path = req.url.path;
        if (path.contains('/notifications/devices/')) {
          final installationId = path.split('/').last;
          if (req.method == 'DELETE') return http.Response('', 204);
          final body = jsonDecode(req.body) as Map;
          if (body['pushToken'] == rejectToken) {
            return _json(409, {
              'errors': [
                {'code': 'INVALID_PUSH_TOKEN_REUSE'}
              ]
            });
          }
          return _json(200, {
            'data': {
              'id': 'device-1',
              'installationId': installationId,
              'platform': body['platform'],
              'enabled': true,
            }
          });
        }
        if (req.method == 'PATCH' && path.endsWith('/read')) {
          return _json(200, {
            'data': {'readAt': '2026-10-16T12:00:00.000Z'}
          });
        }
        if (path.endsWith('/notifications/unread-count')) {
          return _json(200, {
            'data': {'count': unreadCount}
          });
        }
        if (path.endsWith('/notifications')) {
          return _json(200, {
            'data': [],
            'meta': {
              'pagination': {'page': 1, 'hasNextPage': false}
            }
          });
        }
        return _json(404, {});
      });
}

void main() {
  late _FakePush push;
  late _Backend backend;
  late NotificationsRepository repository;
  late PushNotificationsService service;
  final opened = <PushMessage>[];
  final shown = <PushMessage>[];

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await NotificationInstallation.reset();
    await authManager.initialize();
    await authManager.signIn(authenticationToken: 'jwt-a', authUid: 'user-a');

    push = _FakePush();
    backend = _Backend();
    repository = NotificationsRepository();
    opened.clear();
    shown.clear();
    service = PushNotificationsService(
      messaging: push,
      repository: repository,
      onOpen: opened.add,
      onForeground: shown.add,
    );
  });

  tearDown(() => service.dispose());

  Future<T> withBackend<T>(Future<T> Function() body) =>
      http.runWithClient(body, () => backend.client);

  group('registro del dispositivo (la app "manda")', () {
    test('al iniciar sesión registra la instalación con el token', () async {
      final outcome = await withBackend(service.syncForCurrentSession);

      expect(outcome, PushSyncOutcome.registered);
      expect(backend.devicePuts, hasLength(1));
      final put = backend.devicePuts.single;
      final installationId = await NotificationInstallation.id();
      expect(put.url.path, endsWith('/notifications/devices/$installationId'));
      expect(put.headers['Authorization'], 'Bearer jwt-a');
      final body = jsonDecode(put.body) as Map;
      expect(body['pushToken'], 'token-1');
      expect(body['platform'], isNotEmpty);
      expect(service.isRegistered, isTrue);
    });

    test('el installationId no cambia entre sesiones ni cuentas', () async {
      await withBackend(service.syncForCurrentSession);
      await authManager.signOut();
      await authManager.signIn(authenticationToken: 'jwt-b', authUid: 'user-b');
      await withBackend(service.syncForCurrentSession);

      final paths = backend.devicePuts.map((r) => r.url.path).toSet();
      expect(backend.devicePuts, hasLength(2));
      expect(paths, hasLength(1));
      expect(backend.devicePuts.last.headers['Authorization'], 'Bearer jwt-b');
    });

    test('si el registro falló sin conexión, al volver a la app se reintenta',
        () async {
      final first = await http.runWithClient(
        service.syncForCurrentSession,
        () => MockClient((_) async => throw http.ClientException('sin red')),
      );
      expect(first, PushSyncOutcome.failed);
      expect(service.isRegistered, isFalse);

      final retry = await withBackend(service.retryIfNotRegistered);

      expect(retry, PushSyncOutcome.registered);
      expect(backend.devicePuts, hasLength(1));
      expect(service.isRegistered, isTrue);
    });

    test('ya registrado, volver a la app no repite el registro', () async {
      await withBackend(service.syncForCurrentSession);
      await withBackend(service.retryIfNotRegistered);

      expect(backend.devicePuts, hasLength(1));
    });

    test('si el permiso se da después desde Ajustes, se registra al volver',
        () async {
      push.permission = PushPermission.denied;
      await withBackend(service.syncForCurrentSession);
      push.permission = PushPermission.granted;

      final outcome = await withBackend(service.retryIfNotRegistered);

      expect(outcome, PushSyncOutcome.registered);
      expect(backend.devicePuts, hasLength(1));
    });

    test('sin permiso no registra nada', () async {
      push.permission = PushPermission.denied;
      final outcome = await withBackend(service.syncForCurrentSession);

      expect(outcome, PushSyncOutcome.permissionDenied);
      expect(backend.requests, isEmpty);
    });

    test('sin token todavía no registra nada', () async {
      push.tokens = [];
      final outcome = await withBackend(service.syncForCurrentSession);

      expect(outcome, PushSyncOutcome.noToken);
      expect(backend.devicePuts, isEmpty);
    });

    test('sin sesión no hace nada', () async {
      await authManager.signOut();
      final outcome = await withBackend(service.syncForCurrentSession);

      expect(outcome, PushSyncOutcome.notLoggedIn);
      expect(backend.requests, isEmpty);
    });

    test('con 409 de token invalidado pide uno nuevo y repite una vez',
        () async {
      push.tokens = ['token-viejo', 'token-nuevo'];
      backend.rejectToken = 'token-viejo';

      final outcome = await withBackend(service.syncForCurrentSession);

      expect(outcome, PushSyncOutcome.registered);
      expect(push.deletedTokens, 1);
      expect(
        backend.devicePuts.map((r) => (jsonDecode(r.body) as Map)['pushToken']),
        ['token-viejo', 'token-nuevo'],
      );
    });

    test('cuando el proveedor rota el token, lo vuelve a registrar', () async {
      await withBackend(() async {
        await service.start();
        await service.syncForCurrentSession();
        push.tokenRefresh.add('token-rotado');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
      });

      expect(
        backend.devicePuts.map((r) => (jsonDecode(r.body) as Map)['pushToken']),
        ['token-1', 'token-rotado'],
      );
    });

    test('si se revoca el permiso, da de baja el dispositivo', () async {
      await withBackend(service.syncForCurrentSession);
      push.permission = PushPermission.denied;
      final outcome = await withBackend(service.syncForCurrentSession);

      expect(outcome, PushSyncOutcome.permissionDenied);
      expect(backend.deviceDeletes, hasLength(1));
      expect(service.isRegistered, isFalse);
    });

    test('al cerrar sesión da de baja con el JWT todavía vigente', () async {
      await withBackend(service.syncForCurrentSession);
      await withBackend(service.beforeSignOut);

      expect(backend.deviceDeletes, hasLength(1));
      expect(backend.deviceDeletes.single.headers['Authorization'],
          'Bearer jwt-a');
      expect(backend.deviceDeletes.single.url.path,
          backend.devicePuts.single.url.path);
    });

    test(
        'sin sesión (Ej: vencida) descarta el token y al volver registra '
        'uno nuevo', () async {
      await withBackend(service.syncForCurrentSession);
      await authManager.signOut();
      await service.afterSignOut();

      expect(push.deletedTokens, 1);
      expect(service.isRegistered, isFalse);

      push.tokens = ['token-nuevo'];
      await authManager.signIn(authenticationToken: 'jwt-a', authUid: 'user-a');
      await withBackend(service.syncForCurrentSession);
      expect(
        backend.devicePuts.map((r) => (jsonDecode(r.body) as Map)['pushToken']),
        ['token-1', 'token-nuevo'],
      );
    });

    test('si la sesión cambia mientras registra, el resultado no aplica',
        () async {
      final gate = Completer<void>();
      final slow = _SlowPermission(push, gate.future);
      final s =
          PushNotificationsService(messaging: slow, repository: repository);

      final pending = withBackend(s.syncForCurrentSession);
      await authManager.signOut();
      await authManager.signIn(authenticationToken: 'jwt-b', authUid: 'user-b');
      gate.complete();

      expect(await pending, PushSyncOutcome.stale);
      expect(backend.devicePuts, isEmpty);
    });
  });

  group('recepción (la app "recibe")', () {
    test('un push con la app abierta se muestra y actualiza el contador',
        () async {
      backend.unreadCount = 3;
      await withBackend(() async {
        await service.start();
        push.foreground.add(const PushMessage(
          title: 'Visita confirmada',
          body: 'Tu visita fue confirmada.',
          data: {'actionPath': '/visits/v1', 'visitId': 'v1'},
        ));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });

      expect(shown.single.title, 'Visita confirmada');
      expect(backend.unreadCountCalls, 1);
      expect(repository.unreadCount, 3);
    });

    test('tocar un push con la app en segundo plano lo abre', () async {
      await withBackend(() async {
        await service.start();
        push.opened.add(const PushMessage(data: {'actionPath': '/offers/o1'}));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });

      expect(opened.single.actionPath, '/offers/o1');
    });

    test('tocar un push con notificationId la marca como leída', () async {
      await withBackend(() async {
        await service.start();
        push.opened.add(const PushMessage(data: {
          'actionPath': '/offers/o1',
          'type': 'OFFER_ACCEPTED_CLIENT',
          'notificationId': 'n-7',
        }));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });

      final patches = backend.requests.where((r) => r.method == 'PATCH');
      expect(patches.single.url.path, endsWith('/notifications/n-7/read'));
      // El contador se pide después de marcarla, para que ya la descuente.
      expect(backend.requests.last.url.path, endsWith('/unread-count'));
    });

    test('el push que abrió la app desde cerrada también se atiende', () async {
      push.initialMessage =
          const PushMessage(data: {'actionPath': '/dovia-home/x'});
      await withBackend(service.start);

      expect(opened.single.actionPath, '/dovia-home/x');
    });

    test('sin sesión, un push no dispara nada', () async {
      await authManager.signOut();
      await withBackend(() async {
        await service.start();
        push.foreground.add(const PushMessage(title: 'x'));
        push.opened.add(const PushMessage(title: 'y'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });

      expect(shown, isEmpty);
      expect(opened, isEmpty);
      expect(backend.requests, isEmpty);
    });
  });

  group('a dónde lleva tocar una notificación', () {
    test('cada rol tiene su bandeja', () {
      expect(notificationsInboxRouteFor('CLIENT'),
          DOVIACLIENTNotificacionesWidget.routeName);
      expect(notificationsInboxRouteFor('SHOWING_AGENT'),
          SHOWINGNotificationsWidget.routeName);
      expect(notificationsInboxRouteFor('OPERATIVE_LISTER'),
          OPERATIVELISTINGNotificationsWidget.routeName);
      expect(notificationsInboxRouteFor('LISTER_HQ'),
          LISTINGHQNotificationsWidget.routeName);
      expect(notificationsInboxRouteFor('LEGAL_OFFICER'),
          LEGALHQNotificacionesWidget.routeName);
      expect(notificationsInboxRouteFor('LEGAL_ASSOCIATE'),
          LEGALASSOCIATENotificationsWidget.routeName);
      expect(notificationsInboxRouteFor('HOME_ASSOCIATE'),
          DHASSOCIATENotificacionesWidget.routeName);
      expect(notificationsInboxRouteFor('HOME_ASSOCIATE_COMPANY'),
          DHASSOCIATENotificacionesWidget.routeName);
    });

    test('visita del cliente con todos los datos: al detalle', () {
      expect(
        notificationDetailFor(
          role: 'CLIENT',
          type: 'VISIT_CONFIRMED_CLIENT',
          actionPath: '/visits/v1',
          data: {'propertyId': 'p1'},
        ),
        NotificationDestination(DOVIACLIENTSobreMiVisitaWidget.routeName,
            {'visitId': 'v1', 'propertyId': 'p1'}),
      );
    });

    test('solicitud de visita al dueño: a la propuesta de visita', () {
      expect(
        notificationDetailFor(
          role: 'CLIENT',
          type: 'VISIT_REQUESTED_OWNER',
          actionPath: '/visits/v1',
          data: {'propertyId': 'p1'},
        )?.routeName,
        DOVIACLIENTPropuestaDeVisitaWidget.routeName,
      );
    });

    test('proceso legal: el comprador va a Mis ofertas, el dueño a sus '
        'propuestas', () {
      expect(
        notificationDetailFor(
          role: 'CLIENT',
          type: 'LEGAL_PROCESS_PAYMENT_PROOF_REMINDER_CLIENT_12H',
          actionPath: '/legal-processes/lp1',
        )?.routeName,
        DOVIACLIENTMisOfertasWidget.routeName,
      );
      expect(
        notificationDetailFor(
          role: 'CLIENT',
          type: 'LEGAL_PROCESS_FINISHED_OWNER',
          actionPath: '/legal-processes/lp1',
        )?.routeName,
        DOVIACLIENTPropuestasRecientesWidget.routeName,
      );
    });

    test('visita sin propertyId: no hay detalle seguro', () {
      expect(
        notificationDetailFor(
          role: 'CLIENT',
          type: 'VISIT_CONFIRMED_CLIENT',
          actionPath: '/visits/v1',
        ),
        isNull,
      );
    });

    test('ofertas: al tablero del cliente o al del dueño', () {
      expect(
        notificationDetailFor(
                role: 'CLIENT',
                type: 'OFFER_ACCEPTED_CLIENT',
                actionPath: '/offers/o1')
            ?.routeName,
        DOVIACLIENTMisOfertasWidget.routeName,
      );
      expect(
        notificationDetailFor(
                role: 'CLIENT',
                type: 'OFFER_RECEIVED_OWNER',
                actionPath: '/offers/o1')
            ?.routeName,
        DOVIACLIENTPropuestasRecientesWidget.routeName,
      );
    });

    test('Dovia Home del cliente: a su dashboard', () {
      expect(
        notificationDetailFor(
                role: 'CLIENT', actionPath: '/dovia-home/service-requests/s1')
            ?.routeName,
        DHCLIENTHomepageWidget.routeName,
      );
    });

    test('un push de visita sin código del catálogo va a la bandeja', () {
      // Hoy el backend no manda `type` en los datos del push.
      expect(
        destinationForPush(
          role: 'CLIENT',
          message: const PushMessage(data: {
            'actionPath': '/visits/v1',
            'visitId': 'v1',
            'propertyId': 'p1',
          }),
        ),
        NotificationDestination(DOVIACLIENTNotificacionesWidget.routeName),
      );
    });

    test('si el push trae el código, abre el detalle', () {
      expect(
        destinationForPush(
          role: 'CLIENT',
          message: const PushMessage(data: {
            'type': 'VISIT_CONFIRMED_CLIENT',
            'actionPath': '/visits/v1',
            'propertyId': 'p1',
          }),
        ).routeName,
        DOVIACLIENTSobreMiVisitaWidget.routeName,
      );
    });

    test('roles sin mapeo de detalle van a su bandeja', () {
      expect(
        destinationForPush(
          role: 'SHOWING_AGENT',
          message: const PushMessage(data: {'actionPath': '/visits/v1'}),
        ),
        NotificationDestination(SHOWINGNotificationsWidget.routeName),
      );
    });
  });

  group('contador sobre la campana', () {
    Widget badgeWith(NotificationsRepository? repo) {
      const icon = SizedBox(width: 24, height: 24);
      const badge = Directionality(
          textDirection: TextDirection.ltr,
          child: NotificationBadge(child: icon));
      return repo == null
          ? badge
          : ChangeNotifierProvider.value(value: repo, child: badge);
    }

    testWidgets('muestra las no leídas y 9+ desde 10', (tester) async {
      backend.unreadCount = 4;
      await tester.runAsync(() => withBackend(repository.refreshUnreadCount));
      await tester.pumpWidget(badgeWith(repository));
      expect(find.text('4'), findsOneWidget);

      backend.unreadCount = 12;
      await tester.runAsync(() => withBackend(repository.refreshUnreadCount));
      await tester.pump();
      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('sin no leídas no muestra nada', (tester) async {
      await tester.pumpWidget(badgeWith(repository));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('sin repositorio en el árbol muestra solo el ícono',
        (tester) async {
      await tester.pumpWidget(badgeWith(null));
      expect(find.byType(Text), findsNothing);
    });
  });
}

/// Proveedor que demora el permiso hasta que el test lo libera, para simular
/// un cambio de sesión a mitad del registro.
class _SlowPermission extends _FakePush {
  _SlowPermission(_FakePush base, this.gate) {
    tokens = base.tokens;
  }

  final Future<void> gate;

  @override
  Future<PushPermission> requestPermission() async {
    await gate;
    return PushPermission.granted;
  }
}
