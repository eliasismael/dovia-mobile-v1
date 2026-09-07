import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/uploaded_file.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import '/shared_components/popup_subir_documento/popup_subir_documento_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_visor_pdf/l_i_s_t_i_n_g_h_q_visor_pdf_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_model.dart';
export 'l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_model.dart';

class LISTINGHQPropiedadArchivosPendientesWidget extends StatefulWidget {
  const LISTINGHQPropiedadArchivosPendientesWidget({
    super.key,
    required this.title,
    this.visitId,
  });

  final String? title;
  final String? visitId;

  static String routeName = 'LISTING_HQ_PropiedadArchivosPendientes';
  static String routePath = '/lISTINGHQPropiedadArchivosPendientes';

  @override
  State<LISTINGHQPropiedadArchivosPendientesWidget> createState() =>
      _LISTINGHQPropiedadArchivosPendientesWidgetState();
}

class _LISTINGHQPropiedadArchivosPendientesWidgetState
    extends State<LISTINGHQPropiedadArchivosPendientesWidget> {
  late LISTINGHQPropiedadArchivosPendientesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<dynamic>>? _docsFuture;

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => LISTINGHQPropiedadArchivosPendientesModel());

    _docsFuture = _fetchDocs();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  // Paleta del semáforo del checklist.
  static const Color _kMissingBorder = Color(0xFFBC0000);
  static const Color _kMissingFill = Color(0xFFF8D5D5);
  static const Color _kPendingBorder = Color(0xFFE8A200);
  static const Color _kPendingFill = Color(0xFFFFF1CC);
  static const Color _kApprovedBorder = Color(0xFF249689);
  static const Color _kApprovedFill = Color(0xFFDFF1ED);

  /// Estilo de la tarjeta según el estado del documento en el checklist.
  ///
  /// - `missing` y `rejected`: rojo, hay que subir (o volver a subir) el archivo.
  /// - `submitted`: amarillo, el archivo está pero falta que LISTER_HQ lo apruebe.
  /// - `approved`: verde, listo.
  ///
  /// Mientras quede un requerido fuera de `approved`, el backend rechaza
  /// `assign-operative-lister`.
  ({Color border, Color fill, Color text, String label, IconData icon})
      _docStyle(String status, bool hasFile) {
    switch (status) {
      case 'approved':
        return (
          border: _kApprovedBorder,
          fill: _kApprovedFill,
          text: _kApprovedBorder,
          label: 'Aprobado',
          icon: Icons.check_circle,
        );
      case 'rejected':
        return (
          border: _kMissingBorder,
          fill: _kMissingFill,
          text: _kMissingBorder,
          label: 'Rechazado, volver a subir',
          icon: Icons.error,
        );
      case 'submitted':
        return (
          border: _kPendingBorder,
          fill: _kPendingFill,
          text: _kPendingBorder,
          label: 'Falta aprobar',
          icon: Icons.hourglass_top,
        );
      default:
        // Sin estado explícito, la presencia del archivo decide.
        return hasFile
            ? (
                border: _kPendingBorder,
                fill: _kPendingFill,
                text: _kPendingBorder,
                label: 'Falta aprobar',
                icon: Icons.hourglass_top,
              )
            : (
                border: _kMissingBorder,
                fill: _kMissingFill,
                text: _kMissingBorder,
                label: 'Falta subir',
                icon: Icons.upload_file,
              );
    }
  }

  /// Cuenta los documentos **requeridos** por estado, que es lo que decide si
  /// la visita puede avanzar a `READY_TO_ASSIGN_OPERATIVE_LISTING`.
  ({int missing, int pending, int approved}) _requiredTally(List<dynamic> docs) {
    var missing = 0;
    var pending = 0;
    var approved = 0;
    for (final doc in docs) {
      if (doc is! Map) continue;
      if (doc['required'] == false) continue;
      final status = doc['status']?.toString().toLowerCase() ?? '';
      final hasFile =
          (doc['url'] ?? doc['fileUrl'])?.toString().isNotEmpty ?? false;
      if (status == 'approved') {
        approved++;
      } else if (status == 'submitted' || (status.isEmpty && hasFile)) {
        pending++;
      } else {
        missing++;
      }
    }
    return (missing: missing, pending: pending, approved: approved);
  }

  /// Banner de cabecera: dice de una si la propiedad ya puede recibir un
  /// operative lister, o qué falta para llegar ahí.
  Widget _buildChecklistSummary(List<dynamic> docs) {
    final tally = _requiredTally(docs);
    final ready = tally.missing == 0 && tally.pending == 0;

    final Color border;
    final Color fill;
    final IconData icon;
    final String title;
    final String detail;

    if (ready) {
      border = _kApprovedBorder;
      fill = _kApprovedFill;
      icon = Icons.check_circle;
      title = 'Documentación aprobada';
      detail = 'La propiedad ya puede recibir un Operative Listing.';
    } else if (tally.missing > 0) {
      border = _kMissingBorder;
      fill = _kMissingFill;
      icon = Icons.upload_file;
      title = tally.missing == 1
          ? 'Falta subir 1 documento requerido'
          : 'Faltan subir ${tally.missing} documentos requeridos';
      detail = tally.pending == 0
          ? 'Subilos para poder aprobarlos.'
          : 'Además hay ${tally.pending} esperando aprobación.';
    } else {
      border = _kPendingBorder;
      fill = _kPendingFill;
      icon = Icons.hourglass_top;
      title = tally.pending == 1
          ? 'Falta aprobar 1 documento'
          : 'Faltan aprobar ${tally.pending} documentos';
      detail =
          'Abrí cada uno y aprobalo. Al aprobar el último se habilita asignar el Operative Listing.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: border, size: 22.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        color: border,
                        fontSize: 14.0,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  detail,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 12.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> _fetchDocs() async {
    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPIVisitContextGroup.getVisitDetailsCall.call(
      visitId: widget.visitId ?? '',
      authToken: token,
    );
    if (!res.succeeded) return [];

    final data = getJsonField(res.jsonBody, r'$.data');
    if (data is Map) {
      // The visit details DTO nests the checklist under `visit`. Fall back to
      // the top level in case the response is unwrapped.
      final visit = data['visit'];
      final checklist = (visit is Map ? visit['documentChecklist'] : null) ??
          data['documentChecklist'];
      final docs =
          (visit is Map ? visit['documents'] : null) ?? data['documents'];

      List combined = [];
      if (checklist is List) combined.addAll(checklist);
      if (docs is List) {
        for (var doc in docs) {
          if (doc is! Map) continue;
          // Avoid duplicates if they share the same ID
          final cId = doc['id']?.toString() ?? doc['documentId']?.toString();
          if (cId != null && cId.isNotEmpty) {
            final exists = combined.any((c) {
              final existingId = c is Map
                  ? (c['id']?.toString() ?? c['documentId']?.toString())
                  : null;
              return existingId == cId;
            });
            if (!exists) {
              combined.add(doc);
            }
          } else {
            combined.add(doc);
          }
        }
      }
      return combined;
    }
    return [];
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
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 42.0, 20.0, 0.0),
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
                                Container(
                                  width: 35.0,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: SvgPicture.asset(
                                    'assets/images/D-verde.svg',
                                    width: 28.0,
                                    height: 36.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ].divide(const SizedBox(width: 8.0)),
                            ),
                          ),
                          RichText(
                            textScaler: MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.title!,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
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
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
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
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                        OPERATIVELISTINGPrimeraVisitaWidget
                                            .routeName);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: SvgPicture.asset(
                                      'assets/images/search.svg',
                                      width: 8.0,
                                      height: 8.0,
                                      fit: BoxFit.none,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                        OPERATIVELISTINGPrimeraVisitaWidget
                                            .routeName);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: SvgPicture.asset(
                                      'assets/images/folder-alertW.svg',
                                      width: 8.0,
                                      height: 8.0,
                                      fit: BoxFit.none,
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(const SizedBox(width: 8.0)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: FutureBuilder<List<dynamic>>(
                              future: _docsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 40.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                                final docs = snapshot.data ?? [];
                                if (docs.isEmpty) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 40.0),
                                    child: Center(
                                        child: Text('No hay documentos')),
                                  );
                                }
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildChecklistSummary(docs),
                                    const SizedBox(height: 20.0),
                                    Wrap(
                                  spacing: 16.0,
                                  runSpacing: 16.0,
                                  alignment: WrapAlignment.center,
                                  children: docs.map((doc) {
                                    final docMap = doc as Map;
                                    final docName =
                                        docMap['name']?.toString() ??
                                            docMap['label']?.toString() ??
                                            docMap['type']?.toString() ??
                                            'Documento';
                                    final String docId =
                                        docMap['id']?.toString() ??
                                            docMap['documentId']?.toString() ??
                                            docMap['type']?.toString() ??
                                            '';
                                    final fileUrl =
                                        docMap['fileUrl']?.toString() ??
                                            docMap['url']?.toString() ??
                                            '';
                                    final storageKey =
                                        docMap['storageKey']?.toString() ?? '';
                                    final hasFile = fileUrl.isNotEmpty;
                                    final docStatus = docMap['status']
                                            ?.toString()
                                            .toLowerCase() ??
                                        '';
                                    final style = _docStyle(docStatus, hasFile);
                                    final isPdfDoc = fileUrl
                                            .toLowerCase()
                                            .contains('.pdf') ||
                                        fileUrl
                                            .toLowerCase()
                                            .contains('/pdf') ||
                                        storageKey
                                            .toLowerCase()
                                            .contains('.pdf');

                                    return InkWell(
                                      onTap: () async {
                                        if (hasFile) {
                                          // El visor devuelve `true` cuando
                                          // aprobó o rechazó: hay que releer
                                          // el checklist para que la tarjeta
                                          // y el resumen cambien de color.
                                          final reviewed =
                                              await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LISTINGHQVisorPdfWidget(
                                                      documentName: docName,
                                                      documentUrl: fileUrl,
                                                      documentId: docId,
                                                      visitId: widget.visitId,
                                                      isPdf: isPdfDoc),
                                            ),
                                          );
                                          if (reviewed == true && mounted) {
                                            setState(() {
                                              _docsFuture = _fetchDocs();
                                            });
                                          }
                                        } else {
                                          final result =
                                              await showDialog<FFUploadedFile>(
                                            context: context,
                                            builder: (dialogContext) => Dialog(
                                              elevation: 0,
                                              insetPadding: EdgeInsets.zero,
                                              backgroundColor:
                                                  Colors.transparent,
                                              alignment:
                                                  const AlignmentDirectional(
                                                          0.0, 0.0)
                                                      .resolve(
                                                          Directionality.of(
                                                              context)),
                                              child: PopupSubirDocumentoWidget(
                                                  documentName: docName),
                                            ),
                                          );
                                          if (result != null &&
                                              (result.bytes?.isNotEmpty ??
                                                  false)) {
                                            final token =
                                                currentAuthenticationToken ??
                                                    '';
                                            final res =
                                                await DOVIAAPIVisitContextGroup
                                                    .uploadDocumentCall
                                                    .call(
                                              visitId: widget.visitId ?? '',
                                              documentId: docId,
                                              authToken: token,
                                              file: result,
                                            );
                                            if (res.succeeded) {
                                              setState(() {
                                                _docsFuture = _fetchDocs();
                                              });
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Error al subir el documento')),
                                                );
                                              }
                                            }
                                          }
                                        }
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 150.0,
                                            height: 150.0,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .primaryText,
                                              borderRadius:
                                                  BorderRadius.circular(24.0),
                                              border: Border.all(
                                                color: style.border,
                                                width: 3.0,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment:
                                                      const AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Text(
                                                    'PDF',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          color:
                                                              FlutterFlowTheme
                                                                      .of(context)
                                                                  .tertiary,
                                                        ),
                                                  ),
                                                ),
                                                // Distintivo de estado, para
                                                // que el color del borde se
                                                // entienda sin depender solo
                                                // del color.
                                                Align(
                                                  alignment:
                                                      const AlignmentDirectional(
                                                          1.0, -1.0),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      decoration: BoxDecoration(
                                                        color: style.fill,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        style.icon,
                                                        color: style.border,
                                                        size: 18.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 8.0, 0.0, 0.0),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 3.0),
                                              decoration: BoxDecoration(
                                                color: style.fill,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                border: Border.all(
                                                    color: style.border,
                                                    width: 1.0),
                                              ),
                                              child: Text(
                                                style.label,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      color: style.text,
                                                      fontSize: 11.0,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 8.0, 0.0, 0.0),
                                            child: SizedBox(
                                              width: 150.0,
                                              child: Text(
                                                docName,
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryText,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 40.0, 20.0, 100.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          final result = await showDialog<FFUploadedFile>(
                            context: context,
                            builder: (dialogContext) {
                              return Dialog(
                                elevation: 0,
                                insetPadding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                alignment: const AlignmentDirectional(0.0, 0.0)
                                    .resolve(Directionality.of(context)),
                                child: const PopupSubirDocumentoWidget(
                                    documentName: 'Nuevo Documento'),
                              );
                            },
                          );

                          if (result != null &&
                              (result.bytes?.isNotEmpty ?? false)) {
                            final token = currentAuthenticationToken ?? '';
                            final res = await DOVIAAPIVisitContextGroup
                                .createCustomVisitDocumentCall
                                .call(
                              visitId: widget.visitId ?? '',
                              authToken: token,
                              file: result,
                            );
                            if (res.succeeded) {
                              setState(() {
                                _docsFuture = _fetchDocs();
                              });
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Error al crear el documento')),
                                );
                              }
                            }
                          }
                        },
                        text: 'Subir documentacion de la propiedad',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 48.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Colors.white,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
