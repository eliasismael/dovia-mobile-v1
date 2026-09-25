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
    this.propertyName = 'Propiedad',
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
  bool _submitting = false;
  String _rejectionNote = '';
  String? _propertyAddress;
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
        final raw = response.jsonBody;
        final body = raw is Map && raw['data'] is Map ? raw['data'] : raw;
        if (body is! Map) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        final docs = body['documents'] as List? ?? [];
        // La nota general del rechazo queda en el historial de estados; las de
        // cada documento rechazado completan el detalle.
        final notes = <String>[
          if ((body['latestStatusNote']?.toString() ?? '').isNotEmpty)
            body['latestStatusNote'].toString(),
          for (final d in docs)
            if (d is Map &&
                (d['hqReviewDecision'] == 'rejected' ||
                    d['status'] == 'rejected') &&
                (d['note']?.toString() ?? '').isNotEmpty)
              '${d['label'] ?? 'Documento'}: ${d['note']}',
        ];
        final property = body['property'];
        if (mounted) {
          setState(() {
            _rejectionNote = notes.isNotEmpty
                ? notes.join('\n\n')
                : 'Dovia Legal no dejó una nota para este rechazo.';
            _remoteDocuments = docs;
            _ownerData = body['ownerProfile'] is Map
                ? Map<String, dynamic>.from(body['ownerProfile'])
                : null;
            // Quien rechaza es Legal HQ; si no está, el asociado del caso.
            final legal =
                body['legalHqProfile'] ?? body['legalAssociateProfile'];
            _legalData = legal is Map ? Map<String, dynamic>.from(legal) : null;
            _propertyAddress =
                property is Map ? property['fullAddress']?.toString() : null;
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
        file: FFUploadedFile(
          name: file.originalFilename,
          bytes: file.bytes,
        ),
      );
      if (response.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento cargado correctamente.')),
        );
        _fetchProcessData();
      } else {
        debugPrint(
            '[HQ Subir documento] ${response.statusCode}: ${response.bodyText}');
        // POST /legal-processes/{id}/documents es solo para LEGAL_ASSOCIATE.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response.statusCode == 403
                  ? 'Por ahora solo Dovia Legal puede agregar documentos nuevos. Usá "Resubir" en el documento rechazado.'
                  : 'Error al cargar documento.')),
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
        file: FFUploadedFile(
          name: selectedFiles.first.originalFilename,
          bytes: selectedFiles.first.bytes,
        ),
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

  String _profileName(Map<String, dynamic>? profile, String fallback) {
    final name = profile?['fullName']?.toString().trim() ?? '';
    return name.isEmpty ? fallback : name;
  }

  /// Número para WhatsApp: código de país y número, solo dígitos.
  String? _profilePhone(Map<String, dynamic>? profile) {
    final phone = profile?['phone'];
    if (phone is! Map) return null;
    final digits = '${phone['countryCode'] ?? ''}${phone['number'] ?? ''}'
        .replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : digits;
  }

  Future<void> _contact(Map<String, dynamic>? profile) async {
    final phone = _profilePhone(profile);
    final email = profile?['email']?.toString() ?? '';
    if (phone != null) {
      await launchURL('https://wa.me/$phone');
    } else if (email.isNotEmpty) {
      await launchURL('mailto:$email');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay un teléfono ni un correo de contacto.')),
      );
    }
  }

  Future<void> _resubmit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final response = await DOVIAAPILegalProcessContextGroup
        .resubmitToHQReviewListerHQCall
        .call(
      processId: widget.processId,
      authToken: currentAuthenticationToken,
    );
    debugPrint(
        '[HQ Reenviar Legal] ${response.statusCode}: ${response.bodyText}');
    if (!mounted) return;
    setState(() => _submitting = false);
    if (response.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Caso enviado a Revisión Legal HQ exitosamente.')),
      );
      context.goNamed('LISTING_HQ_Home');
    } else {
      final msg = getJsonField(response.jsonBody, r'$.message')?.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusCode == 400
              ? 'Todavía hay documentos rechazados o faltantes: reemplazalos antes de reenviar.'
              : (msg ?? 'Error al enviar el caso.')),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Widget _buildDocCard(dynamic doc, int index) {
    final docName = (doc['label'] ??
            doc['originalName'] ??
            doc['title'] ??
            doc['name'] ??
            doc['type'] ??
            'Documento')
        .toString();
    final rejected =
        doc['hqReviewDecision'] == 'rejected' || doc['status'] == 'rejected';
    final missing = doc['status'] == 'missing';
    final statusColor = rejected || missing
        ? FlutterFlowTheme.of(context).error
        : FlutterFlowTheme.of(context).primary;
    final statusText = rejected
        ? 'Rechazado, resubir'
        : missing
            ? 'Falta subir'
            : doc['status'] == 'approved'
                ? 'Aprobado'
                : 'Enviado';
    return Container(
      width: 220.0,
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
                  percent: missing ? 0.0 : 1.0,
                  lineHeight: 8.0,
                  animation: true,
                  progressColor: statusColor,
                  backgroundColor: FlutterFlowTheme.of(context).accent1,
                  barRadius: const Radius.circular(50.0),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 6.0),
                Text(
                  statusText,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        color: statusColor,
                      ),
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
                  // DELETE /legal-processes/{id}/documents/{docId} es solo
                  // para LEGAL_ASSOCIATE: el backend no deja borrar a HQ.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Por ahora solo Dovia Legal puede eliminar documentos. Usá "Resubir" para reemplazarlo.')),
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
      {required String role,
      required String name,
      required Map<String, dynamic>? profile}) {
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
              onTap: () => _contact(profile),
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
                                _propertyAddress ?? widget.propertyName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
                                  height: 190.0,
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
                                  role:
                                      'Dovia Legal (Encargado de los documentos)',
                                  name: _profileName(_legalData, 'Sin asignar'),
                                  profile: _legalData,
                                ),
                                _buildContactCard(
                                  role: 'Datos del propietario',
                                  name: _profileName(_ownerData, 'Sin datos'),
                                  profile: _ownerData,
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
                        onPressed: _submitting ? null : _resubmit,
                        text: _submitting
                            ? 'Enviando...'
                            : 'Enviar a Revision Legal HQ',
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
