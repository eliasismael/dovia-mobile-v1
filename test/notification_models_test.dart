import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/notification_models.dart';

Map<String, dynamic> _inboxItem({
  Object? relatedEntity = const {'type': 'VISIT', 'id': 'visit-id'},
  String? actionPath = '/visits/visit-id',
  String? readAt,
}) =>
    {
      'id': 'notification-id',
      'type': 'VISIT_UPDATED',
      'category': 'VISIT',
      'title': 'Visita actualizada',
      'body': 'La fecha de tu visita fue actualizada.',
      'relatedEntity': relatedEntity,
      'actionPath': actionPath,
      'readAt': readAt,
      'createdAt': '2026-08-25T12:00:00.000Z',
    };

void main() {
  group('AppNotification.fromJson', () {
    test('mapea el contrato de GET /notifications', () {
      final notification = AppNotification.fromJson(_inboxItem());

      expect(notification.id, 'notification-id');
      expect(notification.type, 'VISIT_UPDATED');
      expect(notification.category, 'VISIT');
      expect(notification.title, 'Visita actualizada');
      expect(notification.relatedEntity?.type, 'VISIT');
      expect(notification.relatedEntity?.id, 'visit-id');
      expect(notification.actionPath, '/visits/visit-id');
      expect(notification.createdAt?.toUtc().hour, 12);
    });

    test('readAt nulo significa no leida', () {
      final unread = AppNotification.fromJson(_inboxItem());
      final read =
          AppNotification.fromJson(_inboxItem(readAt: '2026-08-25T12:05:00.000Z'));

      expect(unread.isUnread, isTrue);
      expect(unread.isRead, isFalse);
      expect(read.isRead, isTrue);
      expect(read.readAt?.toUtc().minute, 5);
    });

    test('relatedEntity y actionPath pueden venir nulos', () {
      final notification = AppNotification.fromJson(
        _inboxItem(relatedEntity: null, actionPath: null),
      );

      expect(notification.relatedEntity, isNull);
      expect(notification.actionPath, isNull);
      expect(notification.target, isNull);
    });

    test('copyWith marca como leida sin tocar el resto', () {
      final original = AppNotification.fromJson(_inboxItem());
      final marked = original.copyWith(readAt: DateTime.utc(2026, 8, 25, 13));

      expect(marked.isRead, isTrue);
      expect(marked.id, original.id);
      expect(marked.title, original.title);
      expect(marked.actionPath, original.actionPath);
    });
  });

  group('NotificationTarget.parse', () {
    test('recurso con id', () {
      final target = NotificationTarget.parse('/offers/offer-1')!;

      expect(target.resource, 'offers');
      expect(target.subResource, isNull);
      expect(target.id, 'offer-1');
    });

    test('recurso sin id', () {
      final target = NotificationTarget.parse('/favorites')!;

      expect(target.resource, 'favorites');
      expect(target.id, isNull);
    });

    test('sub-recurso de Dovia Home', () {
      final target =
          NotificationTarget.parse('/dovia-home/service-requests/sr-1')!;

      expect(target.resource, 'dovia-home');
      expect(target.subResource, 'service-requests');
      expect(target.id, 'sr-1');
    });

    test('path vacio o nulo no produce destino', () {
      expect(NotificationTarget.parse(null), isNull);
      expect(NotificationTarget.parse(''), isNull);
      expect(NotificationTarget.parse('/'), isNull);
    });
  });

  group('NotificationPlatform', () {
    test('usa los valores exactos que acepta el backend', () {
      expect(NotificationPlatform.web.wireValue, 'WEB');
      expect(NotificationPlatform.android.wireValue, 'ANDROID');
      expect(NotificationPlatform.ios.wireValue, 'IOS');
    });

    test('fromWire cae en WEB ante valores desconocidos', () {
      expect(NotificationPlatform.fromWire('IOS'), NotificationPlatform.ios);
      expect(
          NotificationPlatform.fromWire('android'), NotificationPlatform.android);
      expect(NotificationPlatform.fromWire(null), NotificationPlatform.web);
      expect(NotificationPlatform.fromWire('LINUX'), NotificationPlatform.web);
    });
  });

  group('NotificationDevice.fromJson', () {
    test('mapea la respuesta del PUT de instalacion', () {
      final device = NotificationDevice.fromJson({
        'id': 'device-record-id',
        'installationId': '550e8400-e29b-41d4-a716-446655440000',
        'platform': 'WEB',
        'enabled': true,
        'appVersion': null,
        'tokenUpdatedAt': '2026-08-25T12:00:00.000Z',
        'lastSeenAt': '2026-08-25T12:05:00.000Z',
      });

      expect(device.installationId, '550e8400-e29b-41d4-a716-446655440000');
      expect(device.platform, NotificationPlatform.web);
      expect(device.enabled, isTrue);
      expect(device.appVersion, isNull);
      expect(device.lastSeenAt?.toUtc().minute, 5);
    });
  });

  group('notificationCategoryLabel', () {
    test('traduce las categorias del catalogo', () {
      expect(notificationCategoryLabel('VISIT'), 'Visita');
      expect(notificationCategoryLabel('LEGAL_PROCESS'), 'Proceso legal');
      expect(notificationCategoryLabel('DOVIA_HOME'), 'Dovia Home');
    });

    test('normaliza las filas del catalogo que vienen en minusculas', () {
      expect(notificationCategoryLabel('offers'), 'Oferta');
      expect(notificationCategoryLabel('OFFER'), 'Oferta');
    });

    test('una categoria nueva del backend no rompe la UI', () {
      expect(notificationCategoryLabel('ALGO_NUEVO'), 'ALGO_NUEVO');
      expect(notificationCategoryLabel(''), 'Notificación');
    });
  });
}
