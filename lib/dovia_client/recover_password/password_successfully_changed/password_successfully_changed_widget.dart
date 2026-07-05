import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'password_successfully_changed_model.dart';
export 'password_successfully_changed_model.dart';

class PasswordSuccessfullyChangedWidget extends StatefulWidget {
  const PasswordSuccessfullyChangedWidget({super.key});

  @override
  State<PasswordSuccessfullyChangedWidget> createState() =>
      _PasswordSuccessfullyChangedWidgetState();
}

class _PasswordSuccessfullyChangedWidgetState
    extends State<PasswordSuccessfullyChangedWidget> {
  late PasswordSuccessfullyChangedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PasswordSuccessfullyChangedModel());

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
            height: 166.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(10.4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      42.0, 71.0, 42.0, 34.0),
                  child: Text(
                    'Se actualizó con éxito la contraseña',
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
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ],
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
