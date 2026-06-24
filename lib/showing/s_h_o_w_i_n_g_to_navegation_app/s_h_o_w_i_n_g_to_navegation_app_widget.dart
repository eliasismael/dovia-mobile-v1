import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 's_h_o_w_i_n_g_to_navegation_app_model.dart';
export 's_h_o_w_i_n_g_to_navegation_app_model.dart';

class SHOWINGToNavegationAppWidget extends StatefulWidget {
  const SHOWINGToNavegationAppWidget({super.key});

  @override
  State<SHOWINGToNavegationAppWidget> createState() =>
      _SHOWINGToNavegationAppWidgetState();
}

class _SHOWINGToNavegationAppWidgetState
    extends State<SHOWINGToNavegationAppWidget> {
  late SHOWINGToNavegationAppModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGToNavegationAppModel());

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
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 40.0, 20.0, 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Te llevaremos a tu app de navegación',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
            Text(
              'Para llegar a la dirección de tu próxima visita, abriremos una app de navegación instalada en tu dispositivo.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              decoration: const BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.4,
                    decoration: const BoxDecoration(),
                    child: wrapWithModel(
                      model: _model.secondaryButtonModel,
                      updateCallback: () => safeSetState(() {}),
                      child: SecondaryButtonWidget(
                        text: 'Cancelar',
                        onTap: () async {
                          Navigator.pop(context, false);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.4,
                    decoration: const BoxDecoration(),
                    child: wrapWithModel(
                      model: _model.primaryButtonModel,
                      updateCallback: () => safeSetState(() {}),
                      child: PrimaryButtonWidget(
                        text: 'Continuar',
                        onTap: () async {
                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ].divide(const SizedBox(height: 8.0)),
        ),
      ),
    );
  }
}
