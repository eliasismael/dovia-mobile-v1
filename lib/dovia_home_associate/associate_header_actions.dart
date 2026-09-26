import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/dovia_home_associate/associate_role.dart';
import '/index.dart';

/// Accesos de la derecha del header del Dovia Home Associate: la bolsa lleva
/// a Servicios (sus especialidades) y la herramienta a Próximos trabajos. El
/// de la pantalla abierta se ve en verde oscuro y no vuelve a abrirla.
class AssociateHeaderActions extends StatelessWidget {
  const AssociateHeaderActions({super.key});

  static const Color _selected = Color(0xFF00444B);

  static String? _currentRoute(BuildContext context) {
    try {
      return GoRouterState.of(context).name;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = _currentRoute(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _action(
          context,
          asset: 'assets/images/IconoServiciosAsignados.svg',
          routeName: DHASSOCIATEServiciosWidget.routeName,
          selected: route == DHASSOCIATEServiciosWidget.routeName,
        ),
        const SizedBox(width: 8.0),
        // La empresa no toma trabajos de la bolsa: su segundo acceso es
        // Cotizaciones; el independiente va a Próximos trabajos.
        if (isHomeAssociateCompany())
          _action(
            context,
            asset: 'assets/images/page-edit.svg',
            routeName: DHASSOCIATECotizacionesWidget.routeName,
            selected: route == DHASSOCIATECotizacionesWidget.routeName,
          )
        else
          _action(
            context,
            asset: 'assets/images/IconoDiagnosticos.svg',
            routeName: DHASSOCIATEProximosTrabajosWidget.routeName,
            selected: route == DHASSOCIATEProximosTrabajosWidget.routeName,
          ),
      ],
    );
  }

  Widget _action(
    BuildContext context, {
    required String asset,
    required String routeName,
    required bool selected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selected ? null : () => context.pushNamed(routeName),
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: selected
              ? _selected
              : FlutterFlowTheme.of(context).secondaryBackground,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          asset,
          width: 22.0,
          height: 22.0,
          colorFilter: ColorFilter.mode(
              selected ? Colors.white : _selected, BlendMode.srcIn),
        ),
      ),
    );
  }
}
