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
                                return Wrap(
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
                                    final isRejected = docMap['status']
                                            ?.toString()
                                            .toLowerCase() ==
                                        'rejected';
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
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LISTINGHQVisorPdfWidget(
                                                          documentName: docName,
                                                          documentUrl: fileUrl,
                                                          documentId: docId,
                                                          visitId:
                                                              widget.visitId,
                                                          isPdf: isPdfDoc)));
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
                                              color: isRejected
                                                  ? const Color(0xFFFFE4E4)
                                                  : FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              borderRadius:
                                                  BorderRadius.circular(24.0),
                                              border: Border.all(
                                                color: isRejected
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .error
                                                    : (hasFile
                                                        ? Colors.transparent
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .error),
                                                width: 2.0,
                                              ),
                                            ),
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      0.0, 0.0),
                                              child: Text(
                                                'PDF',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      color: isRejected
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .error
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .tertiary,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
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
                                                        color: isRejected
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .error
                                                            : FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                        fontWeight: isRejected
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
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
