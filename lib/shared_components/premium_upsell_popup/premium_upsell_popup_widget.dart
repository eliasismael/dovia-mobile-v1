import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'premium_upsell_popup_model.dart';
export 'premium_upsell_popup_model.dart';

class PremiumUpsellPopupWidget extends StatefulWidget {
  const PremiumUpsellPopupWidget({super.key, this.dismissOnTap = true});

  /// Si el bloque está dentro de un diálogo hay que cerrarlo antes de navegar a
  /// los planes. Las pantallas que lo embeben en el cuerpo (Ej: el bloqueo de
  /// [DHCLIENTCotizacionWidget]) lo desactivan: ahí no hay diálogo que cerrar y
  /// el pop sacaría al cliente de la pantalla.
  final bool dismissOnTap;

  @override
  State<PremiumUpsellPopupWidget> createState() =>
      _PremiumUpsellPopupWidgetState();
}

class _PremiumUpsellPopupWidgetState extends State<PremiumUpsellPopupWidget> {
  late PremiumUpsellPopupModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PremiumUpsellPopupModel());

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
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x33000000),
              offset: Offset(
                0.0,
                2.0,
              ),
            )
          ],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 30.0, 20.0, 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No puedes usar esta función porque no tienes el plan Dovia Premium',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                      color: Colors.white,
                      fontSize: 18.0,
                      letterSpacing: 0.0,
                    ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    if (widget.dismissOnTap) {
                      Navigator.pop(context);
                    }
                    context.pushNamed(DHCLIENTPlanesPageWidget.routeName);
                  },
                  text: 'Adquiere el plan Dovia Premium',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50.0,
                    color: Colors.white,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
