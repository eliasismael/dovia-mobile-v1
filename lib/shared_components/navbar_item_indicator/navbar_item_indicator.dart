import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ítem de navbar con el mismo diseño que la del cliente: ícono, nombre de la
/// sección y la curva que marca la sección abierta. La sección activa se
/// deduce de la ruta de la pantalla donde está la navbar, así las pantallas no
/// tienen que indicarla.
class NavbarItemIndicator extends StatelessWidget {
  const NavbarItemIndicator({
    super.key,
    required this.label,
    required this.routeNames,
    required this.child,
  });

  final String label;

  /// Rutas que cuentan como esta sección.
  final List<String> routeNames;

  /// El ícono con su acción al tocarlo.
  final Widget child;

  static String? _currentRoute(BuildContext context) {
    try {
      return GoRouterState.of(context).name;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = routeNames.contains(_currentRoute(context));
    final weight = active ? FontWeight.w600 : FontWeight.normal;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 24.0, height: 24.0, child: Center(child: child)),
          const SizedBox(height: 4.0),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF00444B),
              fontSize: 10.0,
              fontWeight: weight,
            ),
          ),
          const SizedBox(height: 3.0),
          // El hueco se reserva siempre para que las etiquetas no se muevan.
          SizedBox(
            height: 8.0,
            child: active
                ? SvgPicture.asset(
                    'assets/images/navbar-active-indicator.svg',
                    width: 44.0,
                    height: 8.0,
                    fit: BoxFit.contain,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
