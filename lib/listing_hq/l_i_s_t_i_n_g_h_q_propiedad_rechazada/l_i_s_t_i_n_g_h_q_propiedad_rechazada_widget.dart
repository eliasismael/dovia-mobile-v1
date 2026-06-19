import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/flutter_flow/upload_data.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/auth/custom_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'l_i_s_t_i_n_g_h_q_propiedad_rechazada_model.dart';
export 'l_i_s_t_i_n_g_h_q_propiedad_rechazada_model.dart';

class LISTINGHQPropiedadRechazadaWidget extends StatefulWidget {
  const LISTINGHQPropiedadRechazadaWidget({
    super.key,
    required this.processId,
    this.propertyName = 'Orchad House',
  });

  /// ID del proceso legal — necesario para:
  /// PUT /legal-processes/{processId}/documents/{documentId}/upload
  /// POST /legal-processes/{processId}/lister-hq/resubmit-to-hq-review
  final String processId;
  final String propertyName;

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

  bool _isLoading = true;
  String _rejectionNote = '';
  List<dynamic> _remoteDocuments = [];
  Map<String, dynamic>? _ownerData;
  Map<String, dynamic>? _legalData;

  Future<void> _fetchProcessData() async {
    try {
      final response =
          await DOVIAAPILegalProcessContextGroup.getLegalProcessByIDCall.call(
        processId: widget.processId,
        authToken: currentAuthenticationToken,
      );
      if (response.succeeded) {
        final body = response.jsonBody;
        if (mounted) {
          setState(() {
            _rejectionNote = body['rejectionNote'] ??
                body['note'] ??
                body['hqReviewNote'] ??
                'No hay nota de rechazo especificada.';
            final docs = body['documents'] as List? ?? [];
            _remoteDocuments = docs;
            _ownerData = body['owner'];
            _legalData = body['legalAssociate'] ?? body['legalOfficer'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQPropiedadRechazadaModel());
    _fetchProcessData();
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
    if (selectedFiles != null && selectedFiles.isNotEmpty && mounted) {
      final file = selectedFiles.first;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subiendo nuevo documento...')),
      );
      final response = await DOVIAAPILegalProcessContextGroup
          .createLegalProcessDocumentCall
          .call(
        processId: widget.processId,
        authToken: currentAuthenticationToken,
        file: file,
      );
      if (response.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento cargado correctamente.')),
        );
        _fetchProcessData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar documento.')),
        );
      }
    }
  }

  /// Reemplaza el archivo de un documento rechazado.
  /// API: PUT /legal-processes/{processId}/documents/{documentId}/upload
  Future<void> _handleReuploadDoc(int index) async {
    final documentId = _remoteDocuments[index]['id']?.toString() ?? '';
    final selectedFiles = await selectFiles(
      multiFile: false,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (selectedFiles != null && selectedFiles.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reemplazando documento...')),
      );
      final response = await DOVIAAPILegalProcessContextGroup
          .uploadLegalProcessDocumentCall
          .call(
        processId: widget.processId,
        documentId: documentId,
        authToken: currentAuthenticationToken,
        file: selectedFiles.first,
      );
      if (response.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento reemplazado exitosamente.')),
        );
        _fetchProcessData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al reemplazar el documento.')),
        );
      }
    }
  }

  Widget _buildDocCard(dynamic doc, int index) {
    final docName = doc['title'] ?? doc['name'] ?? doc['type'] ?? 'Documento';
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
                            font:
                                GoogleFonts.inter(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  docName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                ),
                const SizedBox(height: 12.0),
                LinearPercentIndicator(
                  percent: 1.0,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Función de eliminar no implementada completamente en backend.')),
                  );
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

  Widget _buildContactCard(
      {required String role, required String name, required String phone}) {
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
                        font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 16.0),
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
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 30.0, 20.0, 20.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
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
                                widget.propertyName,
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18.0),
                                    ),
                              ),
                              Text(
                                'Rechazada por Legal',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      font: GoogleFonts.inter(
                                          color: FlutterFlowTheme.of(context)
                                              .error),
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
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                                color: FlutterFlowTheme.of(context).primary))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Documentos subidos
                                Text(
                                  'Documentos cargados',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.0),
                                      ),
                                ),
                                const SizedBox(height: 15.0),
                                SizedBox(
                                  height: 160.0,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _remoteDocuments.length,
                                    itemBuilder: (context, index) {
                                      return _buildDocCard(
                                          _remoteDocuments[index], index);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20.0),

                                // Subir nuevo
                                FFButtonWidget(
                                  onPressed: _handleUploadNewDoc,
                                  text:
                                      'Subir nuevo documentacion de la propiedad',
                                  icon: const Icon(Icons.upload_file, size: 15),
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 50.0,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.publicSans(
                                              fontWeight: FontWeight.w600),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 14.0,
                                        ),
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
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
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.0),
                                      ),
                                ),
                                const SizedBox(height: 10.0),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .error
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .error
                                            .withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    _rejectionNote,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 30.0),

                                // Contactos
                                Text(
                                  'Involucrados',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.0),
                                      ),
                                ),
                                const SizedBox(height: 10.0),
                                _buildContactCard(
                                  role: 'Dovia Legal',
                                  name: _legalData != null
                                      ? "${_legalData!['firstName'] ?? ''} ${_legalData!['lastName'] ?? ''}"
                                      : 'Abogado Dovia',
                                  phone: _legalData != null
                                      ? (_legalData!['phone'] ??
                                          _legalData!['phoneNumber'] ??
                                          '+0000000000')
                                      : '+0000000000',
                                ),
                                _buildContactCard(
                                  role: 'Datos del propietario',
                                  name: _ownerData != null
                                      ? "${_ownerData!['firstName'] ?? ''} ${_ownerData!['lastName'] ?? ''}"
                                      : 'María García',
                                  phone: _ownerData != null
                                      ? (_ownerData!['phone'] ??
                                          _ownerData!['phoneNumber'] ??
                                          '+0000000000')
                                      : '+0000000000',
                                ),
                                const SizedBox(
                                    height:
                                        100.0), // Padding for navbar and bottom button
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
                        onPressed: () async {
                          final response =
                              await DOVIAAPILegalProcessContextGroup
                                  .resubmitToHQReviewCall
                                  .call(
                            processId: widget.processId,
                            authToken: currentAuthenticationToken,
                          );
                          if (response.succeeded) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Caso enviado a Revisión Legal HQ exitosamente.')),
                            );
                            if (mounted) context.pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Error al enviar el caso.')),
                            );
                          }
                        },
                        text: 'Enviar a Revision Legal HQ',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50.0,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600),
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
