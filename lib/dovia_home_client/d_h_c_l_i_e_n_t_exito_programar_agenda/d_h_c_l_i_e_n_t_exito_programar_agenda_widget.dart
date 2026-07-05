import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_c_l_i_e_n_t_exito_programar_agenda_model.dart';
export 'd_h_c_l_i_e_n_t_exito_programar_agenda_model.dart';

class DHCLIENTExitoProgramarAgendaWidget extends StatefulWidget {
  const DHCLIENTExitoProgramarAgendaWidget({super.key});

  @override
  State<DHCLIENTExitoProgramarAgendaWidget> createState() =>
      _DHCLIENTExitoProgramarAgendaWidgetState();
}

class _DHCLIENTExitoProgramarAgendaWidgetState
    extends State<DHCLIENTExitoProgramarAgendaWidget> {
  late DHCLIENTExitoProgramarAgendaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTExitoProgramarAgendaModel());

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
                      'Se programó con éxito',
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
                      'Programaste con éxito tu servicio para la Casa A.',
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
