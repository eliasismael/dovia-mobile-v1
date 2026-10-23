import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/dovia_support/dovia_support_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_s_h_a_r_e_d_header_model.dart';
import '/shared_components/notification_badge.dart';
export 'd_o_v_i_a_s_h_a_r_e_d_header_model.dart';

class DOVIASHAREDHeaderWidget extends StatefulWidget {
  const DOVIASHAREDHeaderWidget({
    super.key,
    String? title,
    this.hideActions = false,
    this.showCurrency = true,
    this.showMap = true,
    this.mapActive = false,
    this.showLogo = true,
    this.showCart = false,
    this.showNotifications = false,
    this.showSettings = false,
    this.showSupport = true,
    this.onChatTap,
    this.topPadding,
  }) : title = title ?? '[title]';

  final String title;
  final bool hideActions;
  final bool showCurrency;
  final bool showMap;

  /// La pantalla actual es el mapa: el ícono se pinta relleno en verde
  /// oscuro para marcar dónde está el usuario.
  final bool mapActive;
  final bool showLogo;
  final bool showCart;

  /// Las pantallas de Dovia Home sacaron avisos y ajustes de la barra de
  /// abajo, asi que los muestran aca.
  final bool showNotifications;
  final bool showSettings;

  /// Ícono de soporte de DOVIA. Las pantallas que ya tienen la burbuja
  /// flotante lo apagan para no repetirlo y dejarle lugar al título. Con
  /// [onChatTap] el ícono se muestra igual, porque abre otra conversación.
  final bool showSupport;

  /// Destino alternativo del ícono de chat. Sin este callback el ícono abre el
  /// soporte de DOVIA; las pantallas donde el interlocutor es otro (Ej: el
  /// asociado que está en la casa del cliente) lo redirigen con este parámetro.
  final VoidCallback? onChatTap;

  /// Margen superior fijo. Sin él, el header va justo debajo de la barra de
  /// estado ([topBelowStatusBar]).
  final double? topPadding;

  /// Distancia del header al techo: el alto de la barra de estado que todavía
  /// no se descontó, más un poco de aire. Funciona igual con SafeArea arriba
  /// (la barra ya está descontada) y sin ella (Dovia Home, el inicio del
  /// cliente). Antes era un 42 fijo debajo del SafeArea, o un 58 fijo sin
  /// él: quedaba un hueco sobre el header que el inicio no tenía.
  static double topBelowStatusBar(BuildContext context) =>
      MediaQuery.paddingOf(context).top + 12.0;

  @override
  State<DOVIASHAREDHeaderWidget> createState() =>
      _DOVIASHAREDHeaderWidgetState();
}

class _DOVIASHAREDHeaderWidgetState extends State<DOVIASHAREDHeaderWidget> {
  late DOVIASHAREDHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIASHAREDHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  static const double _backSize = 35.0;
  static const double _logoWidth = 28.0;
  static const double _iconSize = 40.0;
  static const double _gap = 8.0;
  static const double _currencyWidth = 90.0;

  bool get _showChat => widget.onChatTap != null || widget.showSupport;

  double get _leadingWidth =>
      _backSize + (widget.showLogo ? _gap + _logoWidth : 0.0);

  double get _actionsWidth {
    if (widget.hideActions) return 0.0;
    final icons = [
      widget.showMap,
      widget.showCart,
      _showChat,
      widget.showNotifications,
      widget.showSettings,
    ].where((shown) => shown).length;
    final iconsWidth =
        icons == 0 ? 0.0 : icons * _iconSize + (icons - 1) * _gap;
    return widget.showCurrency
        ? (iconsWidth > _currencyWidth ? iconsWidth : _currencyWidth)
        : iconsWidth;
  }

  @override
  Widget build(BuildContext context) {
    // Los dos costados reservan el mismo ancho (el del más ancho), así el
    // título queda centrado en la pantalla y no en el hueco que le dejan la
    // flecha y los íconos.
    final sideWidth =
        _leadingWidth > _actionsWidth ? _leadingWidth : _actionsWidth;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          20.0,
          widget.topPadding ??
              DOVIASHAREDHeaderWidget.topBelowStatusBar(context),
          20.0,
          0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: sideWidth,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    context.safePop();
                  },
                  child: Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SvgPicture.asset(
                        'assets/images/IconoVolverAtras.svg',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.none,
                      ),
                    ),
                  ),
                ),
                if (widget.showLogo)
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      final role = FFAppState().UserRole;
                      if (role == 'OPERATIVE_LISTER') {
                        context.pushNamed(OPERATIVELISTINGHomeWidget.routeName);
                      } else {
                        context.pushNamed(DOVIACLIENTHomePageWidget.routeName);
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: SvgPicture.asset(
                        'assets/images/D-verde.svg',
                        width: 28.0,
                        height: 36.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ].divide(const SizedBox(width: 8.0)),
            ),
          ),
          Expanded(
            child: Padding(
              // Aire a los costados: un título largo baja de línea antes de
              // acercarse a la flecha o a los íconos.
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.title,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                            lineHeight: 1.4,
                          ),
                    )
                  ],
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.4,
                      ),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: sideWidth,
            child: widget.hideActions
                ? null
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.showMap)
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: widget.mapActive
                                    ? const Color(0xFF00444B)
                                    : FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: SvgPicture.asset(
                                  'assets/images/IconoDoviaHomeClienteMapa.svg',
                                  width: 8.0,
                                  height: 8.0,
                                  fit: BoxFit.none,
                                  colorFilter: widget.mapActive
                                      ? const ColorFilter.mode(
                                          Colors.white, BlendMode.srcIn)
                                      : null,
                                ),
                              ),
                            ),
                          if (widget.showCart)
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                // TODO: Navigate to cart
                              },
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset(
                                    'assets/images/shopping-bag.svg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          // Chat: abre el soporte de DOVIA (mismo panel que el ícono
                          // flotante), salvo que la pantalla defina otro destino.
                          if (_showChat)
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                if (widget.onChatTap != null) {
                                  widget.onChatTap!();
                                  return;
                                }
                                await showDoviaSupport(context)
                                    .then((value) => safeSetState(() {}));
                              },
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SvgPicture.asset(
                                    'assets/images/IconoDoviaHomeClienteMensajes.svg',
                                    width: 8.0,
                                    height: 8.0,
                                    fit: BoxFit.none,
                                  ),
                                ),
                              ),
                            ),
                          if (widget.showNotifications)
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                    DOVIACLIENTNotificacionesWidget.routeName);
                              },
                              // El contador va sobre el borde del círculo, no
                              // sobre la campana.
                              child: NotificationBadge(
                                onCircle: true,
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment:
                                      const AlignmentDirectional(0.0, 0.0),
                                  child: SvgPicture.asset(
                                    'assets/images/DH_icono-navbar-notificaciones.svg',
                                    width: 22.0,
                                    height: 22.0,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          if (widget.showSettings)
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                    DOVIACLIENTAjustesWidget.routeName);
                              },
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  shape: BoxShape.circle,
                                ),
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: SvgPicture.asset(
                                  'assets/images/DH_icono-navbar-ajustes.svg',
                                  width: 22.0,
                                  height: 22.0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                        ].divide(const SizedBox(width: 8.0)),
                      ),
                      if (widget.showCurrency)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 0.0),
                          child: FlutterFlowDropDown<String>(
                            controller: _model.dropDownValueController ??=
                                FormFieldController<String>(null),
                            options: const ['USD', 'GTQ'],
                            onChanged: (val) =>
                                safeSetState(() => _model.dropDownValue = val),
                            width: 90.0,
                            height: 30.0,
                            textStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.publicSans(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                            hintText: 'USD',
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24.0,
                            ),
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            elevation: 2.0,
                            borderColor: Colors.transparent,
                            borderWidth: 0.0,
                            borderRadius: 67.0,
                            margin: const EdgeInsetsDirectional.fromSTEB(
                                12.0, 0.0, 12.0, 0.0),
                            hidesUnderline: true,
                            isOverButton: false,
                            isSearchable: false,
                            isMultiSelect: false,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
