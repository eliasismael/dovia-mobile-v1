// Domain models para el contexto `notification` del backend.
//
// El backend expone un inbox por usuario (`GET /notifications`) y el registro
// de instalaciones para PUSH (`PUT /notifications/devices/{installationId}`).
// El catalogo de notificaciones vive en el backend: la app solo renderiza el
// `title`/`body` ya resueltos y navega con `actionPath` / `relatedEntity`.

import 'package:flutter/foundation.dart';

/// Recurso al que apunta una notificacion (`{ type, id }`).
///
/// `type` usa los nombres del backend: `VISIT`, `PROPERTY`, `OFFER`,
/// `LEGAL_PROCESS`, `DOVIA_HOME`, etc.
class NotificationRelatedEntity {
  final String type;
  final String id;

  const NotificationRelatedEntity({required this.type, required this.id});

  factory NotificationRelatedEntity.fromJson(Map<String, dynamic> json) =>
      NotificationRelatedEntity(
        type: json['type'] as String? ?? '',
        id: json['id'] as String? ?? '',
      );

  @override
  String toString() => 'NotificationRelatedEntity($type, $id)';
}

/// Destino canonico del backend derivado de `actionPath`.
///
/// El backend entrega rutas propias (`/visits/{id}`, `/offers/{id}`,
/// `/dovia-home/service-requests/{id}`...) que NO coinciden con las rutas
/// generadas por FlutterFlow. Esta clase parte el path para que la UI pueda
/// mapearlo a su propia ruta segun el rol del usuario.
class NotificationTarget {
  /// Primer segmento del path: `visits`, `offers`, `legal-processes`,
  /// `properties`, `favorites`, `notifications`, `dovia-home`, `payments`...
  final String resource;

  /// Sub-recurso cuando el path tiene tres segmentos
  /// (`/dovia-home/service-requests/{id}` -> `service-requests`).
  final String? subResource;

  /// Ultimo segmento cuando el path identifica un recurso concreto.
  final String? id;

  const NotificationTarget({
    required this.resource,
    this.subResource,
    this.id,
  });

  /// Parsea `/visits/abc123` -> resource `visits`, id `abc123`.
  /// Devuelve `null` si el path es vacio o no tiene segmentos utiles.
  static NotificationTarget? parse(String? actionPath) {
    if (actionPath == null || actionPath.trim().isEmpty) return null;

    final segments = actionPath
        .split('?')
        .first
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();
    if (segments.isEmpty) return null;

    if (segments.length == 1) {
      return NotificationTarget(resource: segments.first);
    }
    if (segments.length == 2) {
      return NotificationTarget(resource: segments[0], id: segments[1]);
    }
    return NotificationTarget(
      resource: segments[0],
      subResource: segments[1],
      id: segments.last,
    );
  }

  @override
  String toString() =>
      'NotificationTarget($resource${subResource == null ? '' : '/$subResource'}, $id)';
}

/// Entrada del inbox tal como la devuelve `GET /notifications`.
///
/// El backend nunca expone `catalogId`, `userId` ni el estado de entrega PUSH;
/// solo estos campos forman parte del contrato publico.
class AppNotification {
  final String id;

  /// Tipo de evento notificable, p. ej. `VISIT_UPDATED`.
  final String type;

  /// Categoria funcional, p. ej. `VISIT`, `LEGAL_PROCESS`, `DOVIA_HOME`.
  final String category;

  final String title;
  final String body;
  final NotificationRelatedEntity? relatedEntity;

  /// Ruta canonica del backend. Ver [NotificationTarget].
  final String? actionPath;

  /// `null` mientras la notificacion siga sin leer.
  final DateTime? readAt;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.body,
    this.relatedEntity,
    this.actionPath,
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null;
  bool get isUnread => readAt == null;

  NotificationTarget? get target => NotificationTarget.parse(actionPath);

  /// Etiqueta en espanol de la categoria (slot `label` de la card).
  String get categoryLabel => notificationCategoryLabel(category);

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final related = json['relatedEntity'];
    return AppNotification(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      relatedEntity: related is Map<String, dynamic>
          ? NotificationRelatedEntity.fromJson(related)
          : null,
      actionPath: json['actionPath'] as String?,
      readAt: _parseDate(json['readAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  AppNotification copyWith({
    DateTime? readAt,
    bool clearReadAt = false,
  }) =>
      AppNotification(
        id: id,
        type: type,
        category: category,
        title: title,
        body: body,
        relatedEntity: relatedEntity,
        actionPath: actionPath,
        readAt: clearReadAt ? null : (readAt ?? this.readAt),
        createdAt: createdAt,
      );

  @override
  String toString() => 'AppNotification($id, $type, read: $isRead)';
}

/// Plataforma de la instalacion. El backend solo acepta estos tres valores.
enum NotificationPlatform {
  web('WEB'),
  android('ANDROID'),
  ios('IOS');

  const NotificationPlatform(this.wireValue);

  /// Valor exacto que espera el backend en `platform`.
  final String wireValue;

  static NotificationPlatform fromWire(String? value) {
    switch (value?.toUpperCase()) {
      case 'ANDROID':
        return NotificationPlatform.android;
      case 'IOS':
        return NotificationPlatform.ios;
      default:
        return NotificationPlatform.web;
    }
  }

  /// Plataforma en la que corre esta build.
  ///
  /// Escritorio cae en `WEB` porque el backend no tiene otro valor valido y
  /// esas builds no son objetivo de PUSH en este producto.
  static NotificationPlatform get current {
    if (kIsWeb) return NotificationPlatform.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return NotificationPlatform.android;
      case TargetPlatform.iOS:
        return NotificationPlatform.ios;
      default:
        return NotificationPlatform.web;
    }
  }
}

/// Instalacion registrada, tal como responde
/// `PUT /notifications/devices/{installationId}`.
///
/// La respuesta nunca incluye `pushToken`, `userId` ni `revokedAt`.
class NotificationDevice {
  final String id;
  final String installationId;
  final NotificationPlatform platform;
  final bool enabled;
  final String? appVersion;

  /// Solo cambia cuando cambia el token FCM.
  final DateTime? tokenUpdatedAt;

  /// Se renueva en cada PUT exitoso. El backend deja de enviar PUSH a las
  /// instalaciones sin PUT dentro de la ventana activa (60 dias por defecto).
  final DateTime? lastSeenAt;

  const NotificationDevice({
    required this.id,
    required this.installationId,
    required this.platform,
    required this.enabled,
    this.appVersion,
    this.tokenUpdatedAt,
    this.lastSeenAt,
  });

  factory NotificationDevice.fromJson(Map<String, dynamic> json) =>
      NotificationDevice(
        id: json['id'] as String? ?? '',
        installationId: json['installationId'] as String? ?? '',
        platform: NotificationPlatform.fromWire(json['platform'] as String?),
        enabled: json['enabled'] as bool? ?? false,
        appVersion: json['appVersion'] as String?,
        tokenUpdatedAt: _parseDate(json['tokenUpdatedAt']),
        lastSeenAt: _parseDate(json['lastSeenAt']),
      );

  @override
  String toString() =>
      'NotificationDevice($installationId, ${platform.wireValue}, enabled: $enabled)';
}

/// Etiquetas en espanol por categoria del catalogo del backend.
///
/// Las categorias llegan del catalogo (`VISIT`, `LEGAL_PROCESS`, `offers`...);
/// algunas filas vienen en minusculas, por eso se normaliza.
String notificationCategoryLabel(String category) {
  switch (category.toUpperCase()) {
    case 'VISIT':
      return 'Visita';
    case 'PROPERTY':
      return 'Propiedad';
    case 'OFFER':
    case 'OFFERS':
      return 'Oferta';
    case 'LEGAL_PROCESS':
      return 'Proceso legal';
    case 'DOVIA_HOME':
      return 'Dovia Home';
    case 'PAYMENTS':
    case 'ASSOCIATE_PAYMENT':
      return 'Pagos';
    case 'ASSOCIATE_FEEDBACK':
      return 'Calificación';
    case 'RECRUITMENT':
      return 'Postulación';
    case 'FAVORITE':
      return 'Favoritos';
    case 'USER':
      return 'Cuenta';
    case 'SYSTEM':
      return 'Sistema';
    default:
      return category.isEmpty ? 'Notificación' : category;
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
