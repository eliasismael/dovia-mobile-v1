import '/dovia_home_associate/associate_header_actions.dart';
import '/dovia_home_associate/associate_nav.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_header_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_header_model.dart';

class DHASSOCIATEHeaderWidget extends StatefulWidget {
  const DHASSOCIATEHeaderWidget({
    super.key,
    required this.tittleText,
  });

  final String? tittleText;

  @override
  State<DHASSOCIATEHeaderWidget> createState() =>
      _DHASSOCIATEHeaderWidgetState();
}

class _DHASSOCIATEHeaderWidgetState extends State<DHASSOCIATEHeaderWidget> {
  late DHASSOCIATEHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Algunas pantallas envuelven el cuerpo en SafeArea y otras no. Dentro
    // de un SafeArea `padding.top` es 0; fuera, es el alto de la barra de
    // estado. Sumarlo deja el header siempre a la misma distancia de ella.
    final statusBar = MediaQuery.paddingOf(context).top;
    return Padding(
      padding:
          EdgeInsetsDirectional.fromSTEB(20.0, statusBar + 42.0, 20.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Volver: toda el área del círculo responde al toque.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.safePop(),
                  child: Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/images/IconoVolverAtras.svg',
                      fit: BoxFit.none,
                    ),
                  ),
                ),
                // La D lleva al panel del asociado (limpia la pila).
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => goAssociateHome(context),
                  child: SvgPicture.asset(
                    'assets/images/D-verde.svg',
                    width: 28.0,
                    height: 36.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ].divide(const SizedBox(width: 8.0)),
            ),
          ),
          // Flexible: un título largo ("Tu trabajo realizado") no entra al lado
          // de los dos grupos de íconos en una pantalla angosta. Sin esto la
          // fila desborda y el título queda cortado tras las rayas amarillas.
          Flexible(
            // Aire a los lados para que un título largo baje de línea antes
            // de tocar los íconos.
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: RichText(
                textScaler: MediaQuery.of(context).textScaler,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: valueOrDefault<String>(
                        widget.tittleText,
                        '[tittle]',
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                            lineHeight: 1.4,
                          ),
                    )
                  ],
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.4,
                      ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const AssociateHeaderActions(),
        ],
      ),
    );
  }
}
