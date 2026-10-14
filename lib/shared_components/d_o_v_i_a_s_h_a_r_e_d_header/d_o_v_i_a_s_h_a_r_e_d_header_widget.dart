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
    this.onChatTap,
    this.topPadding = 42.0,
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

  /// Destino alternativo del ícono de chat. Sin este callback el ícono abre el
  /// soporte de DOVIA; las pantallas donde el interlocutor es otro (Ej: el
  /// asociado que está en la casa del cliente) lo redirigen con este parámetro.
  final VoidCallback? onChatTap;

  /// Margen superior del header. Dovia Home lo usa más bajo para quedar a
  /// la altura del resto de la app.
  final double topPadding;

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsetsDirectional.fromSTEB(20.0, widget.topPadding, 20.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(),
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
              // Aire de sobra a los costados: un título largo baja de línea
              // antes de acercarse a la flecha o a los íconos.
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          if (widget.hideActions)
            // Mismo ancho que la flecha (y el logo) de la izquierda, para
            // que el título quede centrado en la pantalla.
            SizedBox(width: widget.showLogo ? 71.0 : 35.0)
          else
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        await showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          enableDrag: false,
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: const DoviaSupportWidget(),
                            );
                          },
                        ).then((value) => safeSetState(() {}));
                      },
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
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
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            shape: BoxShape.circle,
                          ),
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: NotificationBadge(
                              child: SvgPicture.asset(
                            'assets/images/DH_icono-navbar-notificaciones.svg',
                            width: 22.0,
                            height: 22.0,
                            fit: BoxFit.contain,
                          )),
                        ),
                      ),
                    if (widget.showSettings)
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(DOVIACLIENTAjustesWidget.routeName);
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
                      textStyle:
                          FlutterFlowTheme.of(context).bodyMedium.override(
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
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
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
        ],
      ),
    );
  }
}
