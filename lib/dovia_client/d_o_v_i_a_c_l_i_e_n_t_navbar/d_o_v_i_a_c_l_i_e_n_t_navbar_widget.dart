import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_navbar_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_navbar_model.dart';

class DOVIACLIENTNavbarWidget extends StatefulWidget {
  const DOVIACLIENTNavbarWidget({
    super.key,
    this.activeTab,
  });

  /// Pass the route name of the current page so the matching icon is highlighted.
  /// E.g. DOVIACLIENTMisVisitasWidget.routeName
  final String? activeTab;

  @override
  State<DOVIACLIENTNavbarWidget> createState() =>
      _DOVIACLIENTNavbarWidgetState();
}

class _DOVIACLIENTNavbarWidgetState extends State<DOVIACLIENTNavbarWidget> {
  late DOVIACLIENTNavbarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTNavbarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  ColorFilter? _activeFilter(BuildContext context) => ColorFilter.mode(
        FlutterFlowTheme.of(context).primary,
        BlendMode.srcIn,
      );

  bool _isActive(String routeName) => widget.activeTab == routeName;

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: 70.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(25.0, 0.0, 25.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(DHCLIENTHomepageWidget.routeName);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: SvgPicture.asset(
                  'assets/images/dovia--home-icon.svg',
                  width: 36.0,
                  height: 24.0,
                  fit: BoxFit.none,
                  colorFilter: _isActive(DHCLIENTHomepageWidget.routeName)
                      ? _activeFilter(context)
                      : null,
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(DOVIACLIENTMisFavoritosWidget.routeName);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: SvgPicture.asset(
                  'assets/images/IconoCorazon.svg',
                  width: 24.0,
                  height: 24.0,
                  fit: BoxFit.none,
                  colorFilter:
                      _isActive(DOVIACLIENTMisFavoritosWidget.routeName)
                          ? _activeFilter(context)
                          : null,
                ),
              ),
            ),
            Builder(
              builder: (context) => InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (FFAppState().UserRole != 'VISITOR') {
                    context
                        .pushNamed(DOVIACLIENTMisPropiedadesWidget.routeName);
                  } else {
                    await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return Dialog(
                          elevation: 0,
                          insetPadding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          alignment: const AlignmentDirectional(0.0, 0.0)
                              .resolve(Directionality.of(context)),
                          child: const VisitorRestrictionPopupWidget(),
                        );
                      },
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: SvgPicture.asset(
                    'assets/images/IconoCasaLLave.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.none,
                    colorFilter:
                        _isActive(DOVIACLIENTMisPropiedadesWidget.routeName)
                            ? _activeFilter(context)
                            : null,
                  ),
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(DOVIACLIENTMisVisitasWidget.routeName);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: SvgPicture.asset(
                  'assets/images/IconoCalendario.svg',
                  width: 24.0,
                  height: 24.0,
                  fit: BoxFit.none,
                  colorFilter: _isActive(DOVIACLIENTMisVisitasWidget.routeName)
                      ? _activeFilter(context)
                      : null,
                ),
              ),
            ),
            // Mis ofertas: las propuestas que el usuario envió como cliente.
            Builder(
              builder: (context) => InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (FFAppState().UserRole != 'VISITOR') {
                    context.pushNamed(DOVIACLIENTMisOfertasWidget.routeName);
                  } else {
                    await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return Dialog(
                          elevation: 0,
                          insetPadding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          alignment: const AlignmentDirectional(0.0, 0.0)
                              .resolve(Directionality.of(context)),
                          child: const VisitorRestrictionPopupWidget(),
                        );
                      },
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: SvgPicture.asset(
                    'assets/images/IconoMisOfertas.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.none,
                    colorFilter:
                        _isActive(DOVIACLIENTMisOfertasWidget.routeName)
                            ? _activeFilter(context)
                            : null,
                  ),
                ),
              ),
            ),
            Builder(
              builder: (context) => InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (FFAppState().UserRole != 'VISITOR') {
                    context.pushNamed(DOVIACLIENTAjustesWidget.routeName);
                  } else {
                    await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return Dialog(
                          elevation: 0,
                          insetPadding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          alignment: const AlignmentDirectional(0.0, 0.0)
                              .resolve(Directionality.of(context)),
                          child: const VisitorRestrictionPopupWidget(),
                        );
                      },
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: SvgPicture.asset(
                    'assets/images/DH_icono-navbar-ajustes.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.none,
                    colorFilter: _isActive(DOVIACLIENTAjustesWidget.routeName)
                        ? _activeFilter(context)
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
