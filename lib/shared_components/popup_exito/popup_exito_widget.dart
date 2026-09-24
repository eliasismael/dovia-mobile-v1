import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'popup_exito_model.dart';
export 'popup_exito_model.dart';

class PopupExitoWidget extends StatefulWidget {
  const PopupExitoWidget({
    super.key,
    required this.title,
    required this.text,
    this.continueText,
    this.onContinue,
  });

  final String? title;
  final String? text;
  final String? continueText;
  final VoidCallback? onContinue;

  @override
  State<PopupExitoWidget> createState() => _PopupExitoWidgetState();
}

class _PopupExitoWidgetState extends State<PopupExitoWidget> {
  late PopupExitoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopupExitoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// Acción del botón de cierre.
  ///
  /// Sin `onContinue` el popup se dibujaba sin ningún botón, y como se abre en
  /// un `Dialog` a pantalla completa tampoco quedaba barrera para tocar afuera:
  /// el usuario quedaba encerrado. Cuando el popup vive dentro de un diálogo
  /// (`PopupRoute`) y quien lo abrió no pasó callback, se cierra solo.
  VoidCallback? get _effectiveOnContinue {
    if (widget.onContinue != null) return widget.onContinue;
    final route = ModalRoute.of(context);
    if (route is PopupRoute) {
      return () => Navigator.of(context).pop();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 36.0, 20.0, 0.0),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 1.0,
            constraints: const BoxConstraints(maxWidth: 340.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(10.4),
            ),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 52.0, 24.0, 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 0.0),
                    child: Text(
                      valueOrDefault<String>(
                        widget.title,
                        'title',
                      ),
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize: 20.0,
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
                        0.0, 12.0, 0.0, 0.0),
                    child: Text(
                      valueOrDefault<String>(
                        widget.text,
                        'text',
                      ),
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
                  if (_effectiveOnContinue != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 32.0, 0.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: _effectiveOnContinue,
                        text: widget.continueText ?? 'Continuar',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50.0,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          child: Container(
            width: 72.0,
            height: 72.0,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: SvgPicture.asset(
                'assets/images/Visto.svg',
                width: 32.0,
                height: 32.0,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
