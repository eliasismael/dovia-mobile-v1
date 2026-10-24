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
Widget withNotificationBadge(String asset, Widget icon,
        {bool onCircle = false}) =>
    asset == kNotificationsIconAsset
        ? NotificationBadge(onCircle: onCircle, child: icon)
        : icon;

/// Contador de notificaciones sin leer sobre el ícono de la campana.
///
/// En las navbars va dentro de los límites del ícono (esquina superior
/// derecha) porque el ícono está dentro de un `ClipRRect` que recortaría lo de
/// afuera. En los headers, con [onCircle], envuelve el círculo blanco del
/// botón y se apoya sobre su borde, arriba a la derecha: así no tapa la
/// campana.
///
/// Sale de [NotificationsRepository.unreadCount]. Si no hay repositorio en el
/// árbol (Ej: un test de una pantalla suelta) muestra el ícono solo.
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.child,
    this.onCircle = false,
  });

  final Widget child;
  final bool onCircle;

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
          top: onCircle ? -4 : 0,
          right: onCircle ? -4 : 0,
          child: Container(
            constraints: BoxConstraints(
              minWidth: onCircle ? 20 : 16,
              minHeight: onCircle ? 20 : 16,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              count > 9 ? '9+' : '$count',
              semanticsLabel: '$count notificaciones sin leer',
              style: TextStyle(
                color: Colors.white,
                fontSize: onCircle ? 11 : 10,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
