import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/domain/listing_hq_documents.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/popup_rechazar_documento/popup_rechazar_documento_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'l_i_s_t_i_n_g_h_q_visor_pdf_model.dart';
export 'l_i_s_t_i_n_g_h_q_visor_pdf_model.dart';

class LISTINGHQVisorPdfWidget extends StatefulWidget {
  const LISTINGHQVisorPdfWidget({
    super.key,
    required this.documentName,
    this.uploadedFile,
    this.documentUrl,
    this.visitId,
    this.documentId,
    this.isPdf,
  });

  final String documentName;
  final FFUploadedFile? uploadedFile;

  /// URL de S3 para documentos ya subidos por el owner (legalInfo.ownerIdDocument,
  /// legalInfo.propertyCertification). Tiene prioridad sobre [uploadedFile].
  final String? documentUrl;

  /// ID de la visita — necesario para PUT /visits/{visitId}/lister-hq/documents/{documentId}/review
  final String? visitId;

  /// ID del documento dentro del checklist de la visita.
  final String? documentId;
  final bool? isPdf;

  static String routeName = 'LISTING_HQ_VisorPdf';
  static String routePath = '/lISTINGHQVisorPdf';

  @override
  State<LISTINGHQVisorPdfWidget> createState() =>
      _LISTINGHQVisorPdfWidgetState();
}

class _LISTINGHQVisorPdfWidgetState extends State<LISTINGHQVisorPdfWidget> {
  late LISTINGHQVisorPdfModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQVisorPdfModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Aprueba todos los documentos de la visita que faltan aprobar, como el
  /// "Aceptar y enviar a Dovia Legal" de la web: el backend solo aprueba de a
  /// uno. Devuelve `false` si alguno falló (los que salieron quedan aprobados).
  Future<bool> _approvePendingDocs() async {
    final token = currentAuthenticationToken ?? '';
    final visitId = widget.visitId ?? '';
    final currentId = widget.documentId ?? '';

    var ids = [currentId];
    final details = await DOVIAAPIVisitContextGroup.getVisitDetailsCall.call(
      visitId: visitId,
      authToken: token,
    );
    if (details.succeeded) {
      ids = listerHqDocIdsToApprove(
        listerHqVisitDocs(getJsonField(details.jsonBody, r'$.data')),
        currentId,
      );
    } else {
      // Sin el checklist se aprueba al menos el abierto.
      debugPrint(
          '[HQ Aprobar] details ${details.statusCode}: ${details.bodyText}');
    }

    final results = await Future.wait(ids
        .map((id) => DOVIAAPIVisitContextGroup.reviewListerHqDocumentCall.call(
              visitId: visitId,
              documentId: id,
              authToken: token,
              status: 'approved',
            )));
    for (final res in results.where((r) => !r.succeeded)) {
      debugPrint('[HQ Aprobar] ${res.statusCode}: ${res.bodyText}');
    }
    return results.every((r) => r.succeeded);
  }

  Widget _buildDocumentViewer() {
    final url = widget.documentUrl;
    final file = widget.uploadedFile;

    if (url != null && url.isNotEmpty) {
      final isPdf = widget.isPdf ??
          (url.toLowerCase().contains('.pdf') ||
              url.toLowerCase().contains('/pdf'));
      if (isPdf) {
        return SfPdfViewer.network(url);
      }
      return Image.network(
        url,
        width: double.infinity,
        height: 500.0,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _unsupportedPlaceholder(),
      );
    }

    if (file != null) {
      final name = file.name?.toLowerCase() ?? '';
      if (name.endsWith('.pdf')) return SfPdfViewer.memory(file.bytes!);
      if (name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.png')) {
        return Image.memory(
          file.bytes!,
          width: double.infinity,
          height: 500.0,
          fit: BoxFit.cover,
        );
      }
      return _unsupportedPlaceholder();
    }

    return Image.asset(
      'assets/images/casa_card_sobreMiVisita.png',
      width: double.infinity,
      height: 500.0,
      fit: BoxFit.cover,
    );
  }

  Widget _unsupportedPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.insert_drive_file_outlined,
            size: 40.0, color: FlutterFlowTheme.of(context).primary),
        const SizedBox(height: 10.0),
        const Text('Archivo no soportado para previsualización'),
      ],
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
          // Sin SafeArea abajo: el contenido pasa por debajo de la barra
          // flotante hasta el borde de la pantalla.
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
                      model: _model.lISTINGHQHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: LISTINGHQHeaderWidget(
                        titleText: widget.documentName,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 120.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              height: 500.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: _buildDocumentViewer(),
                              ),
                            ),
                          ),
                          // Sin documentId es solo lectura (ej. lo que subió el propietario).
                          if ((widget.documentId ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 24.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        final note = await showDialog<String>(
                                          context: context,
                                          builder: (dialogContext) {
                                            return Dialog(
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
                                              child:
                                                  const PopupRechazarDocumentoWidget(),
                                            );
                                          },
                                        );
                                        if (note != null && note.isNotEmpty) {
                                          final token =
                                              currentAuthenticationToken ?? '';
                                          final res =
                                              await DOVIAAPIVisitContextGroup
                                                  .reviewListerHqDocumentCall
                                                  .call(
                                            visitId: widget.visitId ?? '',
                                            documentId: widget.documentId,
                                            authToken: token,
                                            status: 'rejected',
                                            note: note,
                                          );
                                          debugPrint(
                                              '[HQ Rechazar] ${res.statusCode}: ${res.bodyText}');
                                          if (res.succeeded) {
                                            // Volver al checklist para seguir
                                            // revisando el resto de documentos.
                                            if (context.mounted) {
                                              Navigator.of(context).pop(true);
                                            }
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Error al rechazar el documento')),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      text: 'Rechazar',
                                      options: FFButtonOptions(
                                        height: 48.0,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: const Color(0xFFE85D75),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.publicSans(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              fontSize: 14.0,
                                              color: Colors.white,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        final approved =
                                            await _approvePendingDocs();
                                        if (approved) {
                                          if (context.mounted) {
                                            await showDialog(
                                              context: context,
                                              builder: (dialogContext) {
                                                return Dialog(
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
                                                  // `PopupExitoWidget` solo
                                                  // dibuja el botón de cierre si
                                                  // recibe `onContinue`; sin él
                                                  // el popup queda sin salida.
                                                  child: PopupExitoWidget(
                                                    title:
                                                        'Se envió con éxito al Equipo Legal',
                                                    text:
                                                        'Los documentos se enviaron al equipo de legal para que los revisen.',
                                                    continueText: 'Continuar',
                                                    onContinue: () =>
                                                        Navigator.pop(
                                                            dialogContext),
                                                  ),
                                                );
                                              },
                                            );
                                            // Volver al checklist, que se
                                            // recarga con todo aprobado.
                                            if (context.mounted) {
                                              Navigator.of(context).pop(true);
                                            }
                                          }
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Algunos documentos no se pudieron aprobar. Intentá de nuevo.')),
                                            );
                                          }
                                        }
                                      },
                                      text: 'Aceptar y enviar a Dovia Legal',
                                      options: FFButtonOptions(
                                        height: 48.0,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(12.0, 0.0, 12.0, 0.0),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.publicSans(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              color: Colors.white,
                                              fontSize: 14.0,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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
