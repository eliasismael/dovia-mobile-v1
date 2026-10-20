import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '/index.dart';

/// Inicios desde los que la D del header tiene sentido: el de DOVIA y el de
/// Dovia Home. `_initialize` es la ruta raíz (`/`), que al abrir la app dibuja
/// el inicio que corresponde al rol.
final Set<String> _homeRoutes = {
  '_initialize',
  DOVIACLIENTHomePageWidget.routeName,
  DHCLIENTHomepageWidget.routeName,
};

/// True cuando la pantalla se abrió directo desde un inicio.
///
/// Solo esas pantallas muestran la D para volver al inicio; las que están más
/// adentro (Ej: Agenda, a la que se llega desde Ubicación) vuelven únicamente
/// con la flecha. Se mira la pantalla anterior en la pila y no la pantalla en
/// sí, porque varias (Ubicación, Planes, el detalle de una visita) se abren
/// tanto desde el inicio como desde otras secciones.
bool openedFromHome(BuildContext context) {
  final ValueKey<String> pageKey;
  try {
    pageKey = GoRouterState.of(context).pageKey;
  } catch (_) {
    return false;
  }
  final matches =
      GoRouter.of(context).routerDelegate.currentConfiguration.matches;
  final index = matches.indexWhere((m) => m.pageKey == pageKey);
  if (index <= 0) return false;
  final previous = matches[index - 1].route;
  return previous is GoRoute && _homeRoutes.contains(previous.name);
}
