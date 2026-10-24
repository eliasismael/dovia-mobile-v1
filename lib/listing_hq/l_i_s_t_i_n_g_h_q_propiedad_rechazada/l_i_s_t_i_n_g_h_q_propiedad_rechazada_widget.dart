import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/flutter_flow/upload_data.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/auth/custom_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/listing_hq/listing_hq_ui.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import 'l_i_s_t_i_n_g_h_q_propiedad_rechazada_model.dart';
import '/shared_components/dovia_spinner.dart';
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
            _rejectionNote = notes.join('\n\n');
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento cargado correctamente.')),
        );
        _fetchProcessData();
      } else {
        debugPrint(
            '[HQ Subir documento] ${response.statusCode}: ${response.bodyText}');
        // POST /legal-processes/{id}/documents es solo para LEGAL_ASSOCIATE.
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response.statusCode == 403
                  ? 'Por ahora solo Dovia Legal puede agregar documentos nuevos. Usa "Resubir" en el documento rechazado.'
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento reemplazado exitosamente.')),
        );
        _fetchProcessData();
      } else {
        if (!mounted) return;
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
              ? 'Todavía hay documentos rechazados o faltantes: reemplázalos antes de reenviar.'
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
        ? ListingHqUi.alert
        : doc['status'] == 'approved'
            ? const Color(0xFF249689)
            : ListingHqUi.pending;
    final statusText = rejected
        ? 'Rechazado, resubir'
        : missing
            ? 'Falta subir'
            : doc['status'] == 'approved'
                ? 'Aprobado'
                : 'Enviado';
    return Container(
      width: 200.0,
      padding: const EdgeInsets.all(14.0),
      decoration: ListingHqUi.cardDecoration(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).accent1,
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.center,
            child: Text(
              'PDF',
              style: GoogleFonts.publicSans(
                color: FlutterFlowTheme.of(context).primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            docName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.publicSans(
              color: ListingHqUi.textDark,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          ListingHqUi.statusPill(statusText, statusColor),
          ListingHqUi.cardButton('Resubir', () => _handleReuploadDoc(index)),
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
      decoration: ListingHqUi.cardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600),
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    name,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600, fontSize: 16.0),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            InkWell(
              onTap: () => _contact(profile),
              customBorder: const CircleBorder(),
              // Mismo ícono de mensajes que el header, en blanco sobre verde.
              child: Container(
                width: 44.0,
                height: 44.0,
                decoration: const BoxDecoration(
                  color: ListingHqUi.aqua,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/images/IconoDoviaHomeClienteMensajes.svg',
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.contain,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                  const LISTINGHQHeaderWidget(
                    titleText: 'Propiedad rechazada',
                  ),

                  // Scrollable Body
                  Expanded(
                    child: _isLoading
                        ? const Center(child: DoviaSpinner())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Arriba del cuerpo (se va con el scroll): el
                                // nombre de la casa completo y su estado.
                                const SizedBox(height: 10.0),
                                Text(
                                  _propertyAddress ?? widget.propertyName,
                                  style: GoogleFonts.publicSans(
                                    color: ListingHqUi.textDark,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 12.0),
                                ListingHqUi.statusPill(
                                    'Rechazada por Dovia Legal',
                                    ListingHqUi.alert),
                                const SizedBox(height: 28.0),
                                // Documentos subidos
                                Text(
                                  'Documentos cargados',
                                  style: ListingHqUi.sectionTitle(context),
                                ),
                                const SizedBox(height: 15.0),
                                if (_remoteDocuments.isEmpty)
                                  ListingHqUi.emptyText(context,
                                      'Todavía no hay documentos cargados.')
                                else
                                  ListingHqCarousel(
                                    height: 200.0,
                                    children: [
                                      for (var i = 0;
                                          i < _remoteDocuments.length;
                                          i++)
                                        _buildDocCard(_remoteDocuments[i], i),
                                    ],
                                  ),
                                const SizedBox(height: 20.0),

                                // Subir nuevo
                                FFButtonWidget(
                                  onPressed: _handleUploadNewDoc,
                                  text: 'Subir otro documento de la propiedad',
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
                                  style: ListingHqUi.sectionTitle(context),
                                ),
                                const SizedBox(height: 10.0),
                                // Sin nota, el aviso en gris de sección vacía,
                                // sin fondo.
                                if (_rejectionNote.isEmpty)
                                  ListingHqUi.emptyText(context,
                                      'Dovia Legal no dejó una nota para este rechazo.')
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8D5D5),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      _rejectionNote,
                                      style: GoogleFonts.publicSans(
                                        color: ListingHqUi.textDark,
                                        fontSize: 14.0,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 30.0),

                                // Contactos
                                Text(
                                  'Involucrados',
                                  style: ListingHqUi.sectionTitle(context),
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
                                // Espacio para el botón de abajo y la barra.
                                const SizedBox(height: 170.0),
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
                            : 'Enviar a revisión de Legal HQ',
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
                          elevation: 0.0,
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
