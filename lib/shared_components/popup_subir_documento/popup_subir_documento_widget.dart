import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'popup_subir_documento_model.dart';
export 'popup_subir_documento_model.dart';

class PopupSubirDocumentoWidget extends StatefulWidget {
  const PopupSubirDocumentoWidget({
    super.key,
    required this.documentName,
  });

  final String documentName;

  @override
  State<PopupSubirDocumentoWidget> createState() =>
      _PopupSubirDocumentoWidgetState();
}

class _PopupSubirDocumentoWidgetState extends State<PopupSubirDocumentoWidget> {
  late PopupSubirDocumentoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopupSubirDocumentoModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 30.0, 20.0, 30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Subir documentacion de la propiedad: ${widget.documentName}',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              fontSize: 16.0,
                            ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                    ),
                  ],
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
                        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
                        multiFile: false,
                      );
                      if (selectedFiles != null) {
                        setState(() {
                          _model.uploadedLocalFile = FFUploadedFile(
                            name: selectedFiles.first.originalFilename,
                            bytes: selectedFiles.first.bytes,
                          );
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1.0,
                        ),
                      ),
                      child: (_model.uploadedLocalFile.bytes?.isNotEmpty ??
                              false)
                          ? ((_model.uploadedLocalFile.name
                                          ?.toLowerCase()
                                          .endsWith('.jpg') ==
                                      true ||
                                  _model.uploadedLocalFile.name
                                          ?.toLowerCase()
                                          .endsWith('.png') ==
                                      true ||
                                  _model.uploadedLocalFile.name
                                          ?.toLowerCase()
                                          .endsWith('.jpeg') ==
                                      true)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.memory(
                                    _model.uploadedLocalFile.bytes!,
                                    width: double.infinity,
                                    height: 150.0,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.insert_drive_file_outlined,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 40.0,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 10.0, 0.0, 0.0),
                                      child: Text(
                                        'Archivo seleccionado: ${_model.uploadedLocalFile.name}',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                      ),
                                    ),
                                  ],
                                ))
                          : Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 40.0,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 10.0, 0.0, 0.0),
                                  child: Text(
                                    'Arrastra y suelta tu archivo aquí\no haz clic para seleccionarlo',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      Navigator.pop(context, _model.uploadedLocalFile);
                    },
                    text: 'Subir documento',
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
        ),
      ),
    );
  }
}
