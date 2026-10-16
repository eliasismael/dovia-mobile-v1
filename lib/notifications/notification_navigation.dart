import 'package:go_router/go_router.dart';

import 'notification_router.dart';

/// Si [path] es la ruta de una pantalla de la app (sin contar los parámetros).
bool isAppRoute(GoRouter router, String path) {
  final match = router.configuration.findMatch(path.split('?').first);
  return !match.isError && match.isNotEmpty;
}

/// Abre [destination]: por nombre de ruta o, en las de prueba, por la ruta.
void openNotificationDestination(
  GoRouter router,
  NotificationDestination destination,
) {
  final location = destination.location;
  if (location != null) {
    router.push(location);
    return;
  }
  router.pushNamed(
    destination.routeName,
    queryParameters: destination.queryParameters,
  );
}
