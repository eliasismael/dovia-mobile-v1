import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'subir_archivo_model.dart';
export 'subir_archivo_model.dart';

class SubirArchivoWidget extends StatefulWidget {
  const SubirArchivoWidget({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 40.0, 20.0, 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
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
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
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
            Builder(
              builder: (context) => Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                child: wrapWithModel(
                  model: _model.primaryButtonModel,
                  updateCallback: () => safeSetState(() {}),
                  child: PrimaryButtonWidget(
                    text: 'Subir Documento',
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return Dialog(
                            elevation: 0,
                            insetPadding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            alignment: AlignmentDirectional(0.0, 0.0)
                                .resolve(Directionality.of(context)),
                            child: PopupExitoWidget(
                              title: 'Se subió el documento con éxito',
                              text:
                                  'Se subió el documento  de convenio entre Dovia y el propietario con éxito.',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
