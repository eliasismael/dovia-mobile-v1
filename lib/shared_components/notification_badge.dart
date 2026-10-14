import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/repositories/notifications_repository.dart';

/// Ícono de notificaciones que usan los headers y navbars de todos los roles.
const kNotificationsIconAsset =
    'assets/images/DH_icono-navbar-notificaciones.svg';

/// Envuelve [icon] con el contador de no leídas si [asset] es el ícono de
/// notificaciones. Para los helpers que arman varios íconos con el mismo
/// código.
Widget withNotificationBadge(String asset, Widget icon) =>
    asset == kNotificationsIconAsset ? NotificationBadge(child: icon) : icon;

/// Contador de notificaciones sin leer sobre el ícono de la campana.
///
/// Va dentro de los límites del ícono (esquina superior derecha) porque en las
/// navbars el ícono está dentro de un `ClipRRect` que recortaría lo de afuera.
///
/// Sale de [NotificationsRepository.unreadCount]. Si no hay repositorio en el
/// árbol (Ej: un test de una pantalla suelta) muestra el ícono solo.
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final int count;
    try {
      count = context
          .select<NotificationsRepository, int>((repo) => repo.unreadCount);
    } on ProviderNotFoundException {
      return child;
    }
    if (count <= 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).error,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Text(
              count > 9 ? '9+' : '$count',
              semanticsLabel: '$count notificaciones sin leer',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
