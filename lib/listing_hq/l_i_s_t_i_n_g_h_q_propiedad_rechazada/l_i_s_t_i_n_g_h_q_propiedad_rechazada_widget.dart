import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'l_i_s_t_i_n_g_h_q_propiedad_rechazada_model.dart';
export 'l_i_s_t_i_n_g_h_q_propiedad_rechazada_model.dart';

class LISTINGHQPropiedadRechazadaWidget extends StatefulWidget {
  const LISTINGHQPropiedadRechazadaWidget({super.key});

  static String routeName = 'LISTING_HQ_PropiedadRechazada';
  static String routePath = '/lISTINGHQPropiedadRechazada';

  @override
  State<LISTINGHQPropiedadRechazadaWidget> createState() =>
      _LISTINGHQPropiedadRechazadaWidgetState();
}

class _LISTINGHQPropiedadRechazadaWidgetState
    extends State<LISTINGHQPropiedadRechazadaWidget> {
  late LISTINGHQPropiedadRechazadaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Mock document list
  List<Map<String, dynamic>> _documents = [
    {'id': '1', 'name': 'Contrato', 'progress': 1.0},
    {'id': '2', 'name': 'Documento', 'progress': 1.0},
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQPropiedadRechazadaModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleUploadNewDoc() async {
    final selectedFiles = await selectFiles(
      multiFile: false,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      setState(() {
        _documents.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': selectedFiles.first.originalFilename ?? 'Nuevo Documento',
          'progress': 1.0,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento cargado correctamente.')),
      );
    }
  }

  Future<void> _handleReuploadDoc(int index) async {
    final selectedFiles = await selectFiles(
      multiFile: false,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      setState(() {
        _documents[index]['name'] = selectedFiles.first.originalFilename ?? 'Documento Actualizado';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento reemplazado correctamente.')),
      );
    }
  }

  Widget _buildDocCard(Map<String, dynamic> doc, int index) {
    return Container(
      width: 160.0,
      margin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2.0),
          )
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryText,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Text(
                      'PDF',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  doc['name'],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                ),
                const SizedBox(height: 12.0),
                LinearPercentIndicator(
                  percent: doc['progress'],
                  lineHeight: 8.0,
                  animation: true,
                  progressColor: FlutterFlowTheme.of(context).primary,
                  backgroundColor: FlutterFlowTheme.of(context).accent1,
                  barRadius: const Radius.circular(50.0),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                if (value == 'eliminar') {
                  setState(() {
                    _documents.removeAt(index);
                  });
                } else if (value == 'resubir') {
                  _handleReuploadDoc(index);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'eliminar',
                  child: Text('Eliminar'),
                ),
                const PopupMenuItem<String>(
                  value: 'resubir',
                  child: Text('Resubir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({required String role, required String name, required String phone}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2.0),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  name,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16.0),
                      ),
                ),
              ],
            ),
            InkWell(
              onTap: () async {
                final url = 'https://wa.me/$phone';
                await launchURL(url);
              },
              child: Container(
                width: 45.0,
                height: 45.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).accent1,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 24.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20.0, 30.0, 20.0, 20.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chevron_left, size: 24.0),
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orchad House',
                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                      font: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18.0),
                                    ),
                              ),
                              Text(
                                'Rechazada por Legal',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(color: FlutterFlowTheme.of(context).error),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Documentos subidos
                          Text(
                            'Documentos cargados',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                          ),
                          const SizedBox(height: 15.0),
                          SizedBox(
                            height: 160.0,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _documents.length,
                              itemBuilder: (context, index) {
                                return _buildDocCard(_documents[index], index);
                              },
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          // Subir nuevo
                          FFButtonWidget(
                            onPressed: _handleUploadNewDoc,
                            text: 'Subir nuevo documentacion de la propiedad',
                            icon: const Icon(Icons.upload_file, size: 15),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                                    color: FlutterFlowTheme.of(context).primaryText,
                                    fontSize: 14.0,
                                  ),
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.0,
                              ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          const SizedBox(height: 30.0),

                          // Feedback Legal
                          Text(
                            'Nota de Dovia Legal',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                          ),
                          const SizedBox(height: 10.0),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              'La propiedad fue rechazada porque las escrituras adjuntas no están notarizadas correctamente. Por favor, solicite el documento original actualizado al propietario.',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 30.0),

                          // Contactos
                          Text(
                            'Involucrados',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                          ),
                          const SizedBox(height: 10.0),
                          _buildContactCard(
                            role: 'Dovia Legal',
                            name: 'Abogado Dovia',
                            phone: '+1234567890',
                          ),
                          _buildContactCard(
                            role: 'Datos del propietario',
                            name: 'María García',
                            phone: '+0987654321',
                          ),
                          const SizedBox(height: 100.0), // Padding for navbar and bottom button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Bottom Buttons & Navbar
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: FFButtonWidget(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Caso enviado a Revisión Legal HQ exitosamente.')),
                          );
                          context.pop();
                        },
                        text: 'Enviar a Revision Legal HQ',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50.0,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                                color: Colors.white,
                              ),
                          elevation: 2.0,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    wrapWithModel(
                      model: _model.lISTINGHQNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQNavbarWidget(),
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
