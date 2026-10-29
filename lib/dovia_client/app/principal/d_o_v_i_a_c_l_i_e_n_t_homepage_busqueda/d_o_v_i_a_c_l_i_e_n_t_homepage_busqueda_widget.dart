import '/components/map_with_houses_widget.dart';
import '/dovia_client/app/principal/filtro_complete_popup/filtro_complete_popup_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/header_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/dovia_client/app/principal/filtro_busqueda_i_a/filtro_busqueda_i_a_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_homepage_busqueda_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_homepage_busqueda_model.dart';

class DOVIACLIENTHomepageBusquedaWidget extends StatefulWidget {
  const DOVIACLIENTHomepageBusquedaWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_Homepage_Busqueda';
  static String routePath = '/dOVIACLIENTHomepageBusqueda';

  @override
  State<DOVIACLIENTHomepageBusquedaWidget> createState() =>
      _DOVIACLIENTHomepageBusquedaWidgetState();
}

class _DOVIACLIENTHomepageBusquedaWidgetState
    extends State<DOVIACLIENTHomepageBusquedaWidget> {
  late DOVIACLIENTHomepageBusquedaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTHomepageBusquedaModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          // Sin SafeArea abajo, como en el inicio: el contenido pasa
          // por debajo de la barra flotante hasta el borde de la pantalla.
          bottom: false,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                // Lo que ocupa el indicador de inicio (iPhone), que ya no
                // descuenta el SafeArea: el final queda sobre la barra.
                padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIASHAREDHeaderWidget(
                        showLogo: openedFromHome(context),
                        showSupport: false,
                        title: 'Búsqueda',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40.0,
                                height: 41.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(25.0),
                                    bottomRight: Radius.circular(0.0),
                                    topLeft: Radius.circular(25.0),
                                    topRight: Radius.circular(0.0),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SvgPicture.asset(
                                    'assets/images/lupa.svg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.none,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: 200.0,
                                  child: TextFormField(
                                    controller: _model.textController,
                                    focusNode: _model.textFieldFocusNode,
                                    autofocus: false,
                                    enabled: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      hintText: 'Busqueda con IA',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(25.0),
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(25.0),
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(25.0),
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(25.0),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(25.0),
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(25.0),
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(25.0),
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(25.0),
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    textInputAction: TextInputAction.search,
                                    onFieldSubmitted: (_) async {
                                      final query =
                                          _model.textController.text.trim();
                                      if (query.isEmpty) return;
                                      await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        enableDrag: true,
                                        context: context,
                                        builder: (context) {
                                          return GestureDetector(
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: SizedBox(
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.5,
                                                child:
                                                    const FiltroBusquedaIAWidget(),
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    enableInteractiveSelection: true,
                                    validator: _model.textControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    4.0, 0.0, 0.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: SizedBox(
                                              height: MediaQuery.sizeOf(context)
                                                      .height *
                                                  0.6,
                                              child: FiltroCompletePopupWidget(
                                                onApplyFilters: () async {
                                                  _model.isFilterModalVisible =
                                                      true;
                                                  safeSetState(() {});
                                                },
                                                onClearFilters: () async {
                                                  _model.isFilterModalVisible =
                                                      false;
                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: Container(
                                    width: 35.0,
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      color: _model.isFilterModalVisible
                                          ? FlutterFlowTheme.of(context)
                                              .primaryText
                                          : FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        if (_model.isFilterModalVisible ==
                                            false) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: SvgPicture.asset(
                                              'assets/images/filter-alt.svg',
                                              width: 20.0,
                                              height: 20.0,
                                              fit: BoxFit.none,
                                            ),
                                          );
                                        } else {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: SvgPicture.asset(
                                              'assets/images/filter-alt-white.svg',
                                              width: 20.0,
                                              height: 20.0,
                                              fit: BoxFit.none,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.mapWithHousesModel,
                              updateCallback: () => safeSetState(() {}),
                              child: const MapWithHousesWidget(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Al usar busqueda con IA entiendo que se muestra el modal inferior con las casas, y solo tocando el logo de al lado de los filtros sale otro modal de los filtros
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 15.0, 5.0),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIACLIENTNavbarWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
