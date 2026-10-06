import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'terminos_y_condiciones_scrolleable_model.dart';
export 'terminos_y_condiciones_scrolleable_model.dart';

class TerminosYCondicionesScrolleableWidget extends StatefulWidget {
  const TerminosYCondicionesScrolleableWidget({
    super.key,
    this.onAccept,
  });

  final Future Function()? onAccept;

  @override
  State<TerminosYCondicionesScrolleableWidget> createState() =>
      _TerminosYCondicionesScrolleableWidgetState();
}

class _TerminosYCondicionesScrolleableWidgetState
    extends State<TerminosYCondicionesScrolleableWidget> {
  late TerminosYCondicionesScrolleableModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TerminosYCondicionesScrolleableModel());

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
        color: FlutterFlowTheme.of(context).tertiary,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
            child: Text(
              'Términos y condiciones',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 26.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
            child: Row(
              children: [
                Icon(
                  _model.hasCompletedScroll
                      ? Icons.check_circle_outline_rounded
                      : Icons.keyboard_double_arrow_down_rounded,
                  size: 18.0,
                  color: FlutterFlowTheme.of(context).primary,
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    _model.hasCompletedScroll
                        ? 'Ya puedes aceptar los términos y condiciones.'
                        : 'Desplázate hasta el final para poder aceptar.',
                    style: GoogleFonts.inter(
                      fontSize: 13.0,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: MediaQuery.sizeOf(context).height * 0.45,
                child: custom_widgets.TermsScroller(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: MediaQuery.sizeOf(context).height * 0.45,
                  titulo: 'Términos y condiciones de uso de Dovia',
                  terminos: FFAppConstants.TermsAndConditions,
                  onBottomReached: () async {
                    _model.hasCompletedScroll = true;
                    safeSetState(() {});
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0.0, 1.0),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              decoration: const BoxDecoration(),
              // Sin alto fijo: el texto de aceptación puede ocupar varias
              // líneas y empujaba el botón fuera del diálogo.
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 30.0, 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 20.0, 0.0, 0.0),
                      child: Text(
                        'Al aceptar, significa que he leído y acepto los términos y condiciones de uso',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 14.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 16.0, 0.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: !_model.hasCompletedScroll
                            ? null
                            : () async {
                                await widget.onAccept?.call();
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              },
                        text: 'Aceptar',
                        options: FFButtonOptions(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: 40.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(24.0),
                          disabledColor: FlutterFlowTheme.of(context).accent1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
