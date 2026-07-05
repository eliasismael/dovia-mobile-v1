import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tus_favoritos_carpeta_creada_modal_model.dart';
export 'tus_favoritos_carpeta_creada_modal_model.dart';

class TusFavoritosCarpetaCreadaModalWidget extends StatefulWidget {
  const TusFavoritosCarpetaCreadaModalWidget({super.key, this.folderName = ''});
  final String folderName;

  @override
  State<TusFavoritosCarpetaCreadaModalWidget> createState() =>
      _TusFavoritosCarpetaCreadaModalWidgetState();
}

class _TusFavoritosCarpetaCreadaModalWidgetState
    extends State<TusFavoritosCarpetaCreadaModalWidget> {
  late TusFavoritosCarpetaCreadaModalModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TusFavoritosCarpetaCreadaModalModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 50.0, 20.0, 0.0),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 1.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(10.4),
            ),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(38.0, 75.0, 38.0, 55.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        42.0, 0.0, 42.0, 0.0),
                    child: Text(
                      'Se creó con éxito la carpeta',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize: 25.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 34.0, 0.0, 0.0),
                    child: Text(
                      'Creaste una carpeta llamada ${widget.folderName}. Aquí podrás guardar todos tus favoritos.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: const AlignmentDirectional(0.0, -1.0),
          child: Container(
            width: 104.0,
            height: 104.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: SvgPicture.asset(
                'assets/images/Visto.svg',
                width: 104.0,
                height: 104.0,
                fit: BoxFit.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
