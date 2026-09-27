import '/backend/api_requests/api_legal_process.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'subir_archivo_model.dart';
export 'subir_archivo_model.dart';

class SubirArchivoWidget extends StatefulWidget {
  const SubirArchivoWidget({
    super.key,
    this.processId,
    this.authToken,
  });

  /// ID del proceso legal. Si se provee junto con authToken, el botón "Subir"
  /// llama POST /legal-processes/{processId}/payment-proof en lugar de solo
  /// mostrar el popup de éxito.
  final String? processId;
  final String? authToken;

  @override
  State<SubirArchivoWidget> createState() => _SubirArchivoWidgetState();
}

class _SubirArchivoWidgetState extends State<SubirArchivoWidget> {
  late SubirArchivoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubirArchivoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<void> _handleUpload() async {
    final file = _model.uploadedLocalFile_documentoFirmado;
    final hasFile = file.bytes != null && file.bytes!.isNotEmpty;

    if (!hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná un archivo primero')),
      );
      return;
    }

    final processId = widget.processId;
    final authToken = widget.authToken;

    if (processId != null &&
        processId.isNotEmpty &&
        authToken != null &&
        authToken.isNotEmpty) {
      safeSetState(() => _model.isUploading = true);

      final res =
          await DOVIAAPILegalProcessContextGroup.uploadPaymentProofCall.call(
        processId: processId,
        authToken: authToken,
        file: file,
      );

      if (!mounted) return;
      safeSetState(() => _model.isUploading = false);

      if (res.succeeded) {
        await showDialog(
          context: context,
          builder: (dialogContext) {
            return Dialog(
              elevation: 0,
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              alignment: const AlignmentDirectional(0.0, 0.0)
                  .resolve(Directionality.of(context)),
              child: const PopupExitoWidget(
                title: 'Comprobante enviado',
                text:
                    'Tu comprobante de pago fue enviado a Dovia. Una vez validado, se habilitará la descarga de los documentos firmados.',
              ),
            );
          },
        );
        if (mounted) Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No se pudo enviar el comprobante. Intentá nuevamente.'),
          ),
        );
      }
    } else {
      // Fallback: sin processId/authToken, solo muestra popup de éxito
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            alignment: const AlignmentDirectional(0.0, 0.0)
                .resolve(Directionality.of(context)),
            child: const PopupExitoWidget(
              title: 'Se subió el documento con éxito',
              text:
                  'Se subió el documento de convenio entre Dovia y el propietario con éxito.',
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tarjeta centrada del alto de su contenido: se abre como popup en el
    // medio de la pantalla, no como una hoja que la ocupa entera.
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 28.0, 20.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sube el documento firmado',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  final selectedFiles = await selectFiles(
                    multiFile: false,
                  );
                  if (selectedFiles != null) {
                    safeSetState(
                        () => _model.isDataUploading_documentoFirmado = true);
                    var selectedUploadedFiles = <FFUploadedFile>[];

                    try {
                      selectedUploadedFiles = selectedFiles
                          .map((m) => FFUploadedFile(
                                name: m.storagePath.split('/').last,
                                bytes: m.bytes,
                                originalFilename: m.originalFilename,
                              ))
                          .toList();
                    } finally {
                      _model.isDataUploading_documentoFirmado = false;
                    }
                    if (selectedUploadedFiles.length == selectedFiles.length) {
                      safeSetState(() {
                        _model.uploadedLocalFile_documentoFirmado =
                            selectedUploadedFiles.first;
                      });
                    } else {
                      safeSetState(() {});
                      return;
                    }
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SvgPicture.asset(
                    'assets/images/AddMediaImage.svg',
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: wrapWithModel(
                model: _model.primaryButtonModel,
                updateCallback: () => safeSetState(() {}),
                child: PrimaryButtonWidget(
                  text: _model.isUploading ? 'Enviando...' : 'Subir Documento',
                  onTap: _model.isUploading ? null : _handleUpload,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
