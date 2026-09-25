import '/dovia_home_associate/associate_role.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/shared_components/navbar_item_indicator/navbar_item_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_navbar_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_navbar_model.dart';

/// Barra de navegación del Dovia Home Associate.
///
/// Es el equivalente mobile del menú lateral del diseño de escritorio, y como
/// él **depende del rol**: con `Role = HOME_ASSOCIATE_COMPANY` se inyecta el
/// ítem "Cotizaciones" —que en el menú lateral va encima de Servicios— y el
/// ítem de inicio lleva al panel de la empresa en vez del panel del
/// profesional independiente. Un independiente no ve ninguno de los dos: los
/// endpoints de cotizaciones son de empresa y le responderían 403.
class DHASSOCIATENavbarWidget extends StatefulWidget {
  const DHASSOCIATENavbarWidget({super.key});

  @override
  State<DHASSOCIATENavbarWidget> createState() =>
      _DHASSOCIATENavbarWidgetState();
}

class _DHASSOCIATENavbarWidgetState extends State<DHASSOCIATENavbarWidget> {
  late DHASSOCIATENavbarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATENavbarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// Ítem de la barra: un ícono que navega. Se extrajo del `build` porque con
  /// el ítem de empresa la barra pasó a tener un número variable de ellos.
  Widget _navItem({
    required String asset,
    required String label,
    required List<String> routeNames,
    required VoidCallback onTap,
  }) =>
      NavbarItemIndicator(
        label: label,
        routeNames: routeNames,
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SvgPicture.asset(
              asset,
              width: 24.0,
              height: 24.0,
              fit: BoxFit.none,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isCompany = isHomeAssociateCompany();

    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: 62.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              2.0,
            ),
          )
        ],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _navItem(
              asset: 'assets/images/DH_icono-navbar-home.svg',
              label: 'Inicio',
              routeNames: [
                DHASSOCIATEEmpresaHomePageWidget.routeName,
                DHASSOCIATEHomePageWidget.routeName
              ],
              onTap: () => context.pushNamed(isCompany
                  ? DHASSOCIATEEmpresaHomePageWidget.routeName
                  : DHASSOCIATEHomePageWidget.routeName),
            ),
            if (isCompany)
              _navItem(
                asset: 'assets/images/page-edit.svg',
                label: 'Cotizaciones',
                routeNames: [DHASSOCIATECotizacionesWidget.routeName],
                onTap: () =>
                    context.pushNamed(DHASSOCIATECotizacionesWidget.routeName),
              ),
            _navItem(
              asset: 'assets/images/DH_icono-navbar-notificaciones.svg',
              label: 'Notificaciones',
              routeNames: [DHASSOCIATENotificacionesWidget.routeName],
              onTap: () =>
                  context.pushNamed(DHASSOCIATENotificacionesWidget.routeName),
            ),
            _navItem(
              asset: 'assets/images/DH_icono-navbar-ajustes.svg',
              label: 'Ajustes',
              routeNames: [DHASSOCIATEAjustesWidget.routeName],
              onTap: () =>
                  context.pushNamed(DHASSOCIATEAjustesWidget.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
