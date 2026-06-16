import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_documentos/l_i_s_t_i_n_g_h_q_documentos_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedades/l_i_s_t_i_n_g_h_q_propiedades_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_rechazada/l_i_s_t_i_n_g_h_q_propiedad_rechazada_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_widget.dart';
import '/shared_components/popup_asignar_operative/popup_asignar_operative_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_i_s_t_i_n_g_h_q_home_model.dart';
export 'l_i_s_t_i_n_g_h_q_home_model.dart';

class LISTINGHQHomeWidget extends StatefulWidget {
  const LISTINGHQHomeWidget({super.key});

  static String routeName = 'LISTING_HQ_Home';
  static String routePath = '/lISTINGHQHome';

  @override
  State<LISTINGHQHomeWidget> createState() => _LISTINGHQHomeWidgetState();
}

class _LISTINGHQHomeWidgetState extends State<LISTINGHQHomeWidget> {
  late LISTINGHQHomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQHomeModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _buildSectionHeader(String title, String routeToPush,
      {bool isExpanded = false, VoidCallback? onToggle}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                    fontSize: 16.0,
                  ),
            ),
          ),
          FFButtonWidget(
            onPressed: onToggle ??
                () {
                  if (routeToPush.isNotEmpty) {
                    context.pushNamed(routeToPush);
                  }
                },
            text: onToggle != null
                ? (isExpanded ? 'Ver menos' : 'Ver todo')
                : 'Ver todo',
            options: FFButtonOptions(
              height: 30.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              color: FlutterFlowTheme.of(context).accent1,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.publicSans(),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 14.0,
                  ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselCard({
    required String address,
    required String tagText,
    required String statusText,
    required Color statusBgColor,
    required Color statusTextColor,
    required String buttonText,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 250.0,
      margin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2.0),
          ),
        ],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(15.0, 10.0, 15.0, 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dirección: $address',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              height: 22.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).accent1,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: Text(
                    tagText,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.publicSans(),
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 12.0,
                        ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estatus',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        fontSize: 12.0,
                      ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        10.0, 2.0, 10.0, 2.0),
                    child: Text(
                      statusText,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: statusTextColor,
                            fontSize: 12.0,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            FFButtonWidget(
              onPressed: onPressed ?? () {
                print('Button pressed ...');
              },
              text: buttonText,
              options: FFButtonOptions(
                width: double.infinity,
                height: 30.0,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.publicSans(
                        fontWeight: FontWeight.w300,
                      ),
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
          ].divide(const SizedBox(height: 8.0)),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<Widget> cards) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        height: 160.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: cards,
        ),
      ),
    );
  }

  Widget _buildLargeCard(String title, String ownerName, {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 15.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: const [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x1A000000),
                offset: Offset(0.0, 2.0),
              ),
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'assets/images/casa_card_sobreMiVisita.png',
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              fontSize: 16.0,
                            ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Dirección: xxx',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              fontSize: 12.0,
                            ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        ownerName,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              fontSize: 12.0,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      FFButtonWidget(
                        onPressed: onPressed ?? () {
                          print('Button pressed ...');
                        },
                        text: 'Falta información',
                        options: FFButtonOptions(
                          height: 30.0,
                          color: FlutterFlowTheme.of(context).error,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.publicSans(),
                                    color: Colors.white,
                                    fontSize: 13.0,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.lISTINGHQHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQHeaderWidget(
                        titleText: 'Home',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed('LISTING_HQ_BusquedaPropiedad');
                        },
                        child: Container(
                          width: double.infinity,
                          height: 64.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: SvgPicture.asset(
                                    'assets/images/search.svg',
                                    width: 24.0,
                                    height: 24.0,
                                    fit: BoxFit.none,
                                    colorFilter: ColorFilter.mode(
                                      FlutterFlowTheme.of(context).primaryText,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20.0),
                                Text(
                                  'Búsqueda con IA',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.publicSans(),
                                        color: const Color(0xFF888888),
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 80.0), // Padding bottom for navbar
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Fila 1: Propiedades revisar documentacion
                          _buildSectionHeader(
                            'Propiedades revisar documentacion',
                            LISTINGHQDocumentosWidget.routeName,
                          ),
                          _buildHorizontalList([
                            _buildCarouselCard(
                              address: 'xxx',
                              tagText: 'Visita realizada',
                              statusText: 'Pendiente',
                              statusBgColor: const Color(0xFFF4D476),
                              statusTextColor: const Color(0xFFF99F58),
                              buttonText: 'Revisar ahora',
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LISTINGHQPropiedadArchivosPendientesWidget(title: 'Propiedad A'))),
                            ),
                            _buildCarouselCard(
                              address: 'xxx',
                              tagText: 'Visita realizada',
                              statusText: 'Pendiente',
                              statusBgColor: const Color(0xFFF4D476),
                              statusTextColor: const Color(0xFFF99F58),
                              buttonText: 'Revisar ahora',
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LISTINGHQPropiedadArchivosPendientesWidget(title: 'Propiedad B'))),
                            ),
                          ]),

                          // Fila 2: Asignar Operative Listing
                          _buildSectionHeader(
                            'Asignar Operative Listing a una propiedad',
                            LISTINGHQPropiedadesWidget.routeName,
                          ),
                          _buildHorizontalList([
                            _buildCarouselCard(
                              address: 'xxx',
                              tagText: 'Programar',
                              statusText: 'Reciente',
                              statusBgColor: const Color(0xFFF4D476),
                              statusTextColor: const Color(0xFFF99F58),
                              buttonText: 'Asignar',
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (dialogContext) => Dialog(
                                    elevation: 0,
                                    insetPadding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    alignment: const AlignmentDirectional(
                                            0.0, 0.0)
                                        .resolve(
                                            Directionality.of(context)),
                                    child: const PopupAsignarOperativeWidget(
                                      visitId: 'visit-stub-1',
                                      propertyAddress: 'Dirección: xxx',
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildCarouselCard(
                              address: 'xxx',
                              tagText: 'Re-programar',
                              statusText: 'Urgente',
                              statusBgColor: const Color(0xFFFFBCBC),
                              statusTextColor: const Color(0xFFF52100),
                              buttonText: 'Asignar de nuevo',
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (dialogContext) => Dialog(
                                    elevation: 0,
                                    insetPadding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    alignment: const AlignmentDirectional(
                                            0.0, 0.0)
                                        .resolve(
                                            Directionality.of(context)),
                                    child: const PopupAsignarOperativeWidget(
                                      visitId: 'visit-stub-2',
                                      propertyAddress: 'Dirección: xxx',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ]),

                          // Fila 3: Propiedades pendientes por publicar
                          _buildSectionHeader(
                            'Propiedades pendientes por publicar',
                            LISTINGHQPropiedadesWidget.routeName,
                          ),
                          _buildHorizontalList([
                            _buildCarouselCard(
                              address: 'xxx',
                              tagText: 'Visita realizada',
                              statusText: 'Pendiente',
                              statusBgColor: const Color(0xFFF4D476),
                              statusTextColor: const Color(0xFFF99F58),
                              buttonText: 'Revisar checklist',
                              onPressed: () => context.pushNamed('LISTING_HQ_Propiedad'),
                            ),
                            _buildCarouselCard(
                              address: 'xxx',
                              tagText: 'Visita realizada',
                              statusText: 'Pendiente',
                              statusBgColor: const Color(0xFFF4D476),
                              statusTextColor: const Color(0xFFF99F58),
                              buttonText: 'Revisar checklist',
                              onPressed: () => context.pushNamed('LISTING_HQ_Propiedad'),
                            ),
                          ]),

                          // Fila 4: Propiedades Rechazadas por Dovia Legal
                          _buildSectionHeader(
                            'Propiedades Rechazadas por Dovia Legal',
                            '',
                            isExpanded: _model.isRechazadasExpanded,
                            onToggle: () {
                              setState(() {
                                _model.isRechazadasExpanded =
                                    !_model.isRechazadasExpanded;
                              });
                            },
                          ),
                          Column(
                            children: [
                              _buildLargeCard('Orchad House', 'Nombre del propietario', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LISTINGHQPropiedadRechazadaWidget(processId: 'process-stub-1')))),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: _model.isRechazadasExpanded
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildLargeCard('Orchad House 2',
                                              'Nombre del propietario 2', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LISTINGHQPropiedadRechazadaWidget(processId: 'process-stub-1')))),
                                          _buildLargeCard('Orchad House 3',
                                              'Nombre del propietario 3'),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),

                          // Fila 5: Propiedades a la espera de correcciones
                          _buildSectionHeader(
                            'Propiedades a la espera de correcciones',
                            '',
                            isExpanded: _model.isCorreccionesExpanded,
                            onToggle: () {
                              setState(() {
                                _model.isCorreccionesExpanded =
                                    !_model.isCorreccionesExpanded;
                              });
                            },
                          ),
                          Column(
                            children: [
                              _buildLargeCard(
                                  'Orchad House', 'Nombre del propietario', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LISTINGHQPropiedadArchivosPendientesWidget(title: 'Orchad House')))),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: _model.isCorreccionesExpanded
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildLargeCard('Orchad House 2',
                                              'Nombre del propietario 2', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LISTINGHQPropiedadArchivosPendientesWidget(title: 'Orchad House 2')))),
                                          _buildLargeCard('Orchad House 3',
                                              'Nombre del propietario 3', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LISTINGHQPropiedadArchivosPendientesWidget(title: 'Orchad House 3')))),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(
                    0.0, 1.0), // Fix alignment to bottom
                child: wrapWithModel(
                  model: _model.lISTINGHQNavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const LISTINGHQNavbarWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
