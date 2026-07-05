import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_select_role_popup_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_select_role_popup_model.dart';

class DHASSOCIATESelectRolePopupWidget extends StatefulWidget {
  const DHASSOCIATESelectRolePopupWidget({super.key});

  @override
  State<DHASSOCIATESelectRolePopupWidget> createState() =>
      _DHASSOCIATESelectRolePopupWidgetState();
}

class _DHASSOCIATESelectRolePopupWidgetState
    extends State<DHASSOCIATESelectRolePopupWidget> {
  late DHASSOCIATESelectRolePopupModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATESelectRolePopupModel());

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
      width: 300.0,
      height: MediaQuery.sizeOf(context).height * 1.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(26.0, 13.0, 26.0, 13.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: const AlignmentDirectional(-1.0, 0.0),
                  child: Text(
                    'Selecciona el rol',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 13.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          lineHeight: 1.1,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SvgPicture.asset(
                      'assets/images/CloseIcon.svg',
                      width: 10.0,
                      height: 10.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 6.67, 0.0, 0.0),
              child: Text(
                'Cada rol en Dovia tiene funciones diferentes. Elige el que corresponde a tu actividad:',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      fontSize: 10.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
              child: RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '• Dovia Lister: ',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize: 10.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                    TextSpan(
                      text:
                          'Realiza visitas y registra información en campo.\n',
                      style: GoogleFonts.publicSans(
                        fontSize: 10.0,
                      ),
                    ),
                    TextSpan(
                      text: '• Dovia Lister HQ: ',
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                      ),
                    ),
                    TextSpan(
                      text: 'Valida y gestiona información de propiedades.\n',
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 10.0,
                      ),
                    ),
                    TextSpan(
                      text: '• Dovia Home Associate: ',
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                      ),
                    ),
                    TextSpan(
                      text: 'Atiende servicios y carga diagnósticos. \n',
                      style: GoogleFonts.publicSans(
                        fontSize: 10.0,
                      ),
                    ),
                    TextSpan(
                      text: '• Dovia Showing: ',
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Muestra propiedades a los clientes, coordina visitas, marca llegada y reporta novedades durante el recorrido.\n',
                      style: GoogleFonts.publicSans(),
                    ),
                    TextSpan(
                      text: '• Legal Associate: ',
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Acompaña los procesos legales de compra, venta o renta, carga documentos, se comunica con comprador y propietario y coordina la firma de contratos o escrituras.\n',
                      style: GoogleFonts.publicSans(),
                    ),
                    TextSpan(
                      text: '• Dovia Legal HQ: ',
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Revisa y aprueba documentos legales.\n',
                      style: GoogleFonts.publicSans(),
                    ),
                    TextSpan(
                      text: '• Dovia HQ (Administrador): ',
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Administra la plataforma, gestiona usuarios y permisos, supervisa los procesos operativos, legales y comerciales, y asegura el correcto funcionamiento de Dovia.',
                      style: GoogleFonts.publicSans(),
                    )
                  ],
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.publicSans(
                          fontWeight: FontWeight.normal,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 10.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.2,
                      ),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(1.0, 0.0),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 6.67, 0.0, 0.0),
                child: FFButtonWidget(
                  onPressed: () {
                    print('Button pressed ...');
                  },
                  text: 'Siguiente',
                  options: FFButtonOptions(
                    width: 81.0,
                    height: 24.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        11.43, 5.71, 11.43, 5.71),
                    iconPadding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.normal,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          fontSize: 8.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.normal,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                          lineHeight: 0.9,
                        ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(15.0),
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
