import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_califico_exito/d_h_c_l_i_e_n_t_califico_exito_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_c_l_i_e_n_t_calificar_model.dart';
export 'd_h_c_l_i_e_n_t_calificar_model.dart';

/// Superficie de los campos del diseño (#FAFAFA).
const Color _kFieldSurface = Color(0xFFFAFAFA);

/// Calificación del asociado tras un trabajo finalizado. Siempre disponible: la
/// calificación no caduca.
///
/// El contexto del trabajo (título, fecha/hora e ids) viaja por campos
/// estáticos porque las rutas se construyen sin parámetros (ver nav.dart).
class DHCLIENTCalificarWidget extends StatefulWidget {
  const DHCLIENTCalificarWidget({super.key});

  /// Cabecera de contexto: título del trabajo (ej. "Instalación de TV").
  static String? jobTitle;

  /// Cabecera de contexto: fecha/hora en que se realizó (ej. "27 de nov -
  /// 8:35am").
  static String? jobDateLabel;

  /// Para POST /associate-feedback/dovia-home/services/{serviceRequestId}/ratings
  /// — es la vía normal de esta pantalla. El backend resuelve el asociado desde
  /// la solicitud, por eso no se envía `targetRole`.
  static String? serviceRequestId;

  /// Para POST /associate-feedback/visits/{visitId}/ratings
  static String? visitId;

  /// Para POST /associate-feedback/offers/{offerId}/ratings — tiene prioridad
  /// sobre [visitId].
  static String? offerId;

  /// SHOWING_AGENT | LISTER_HQ | OPERATIVE_LISTER | LEGAL_ASSOCIATE |
  /// LEGAL_OFFICER
  static String targetRole = 'SHOWING_AGENT';

  static String routeName = 'DH_CLIENT_Calificar';
  static String routePath = '/dHCLIENTCalificar';

  @override
  State<DHCLIENTCalificarWidget> createState() =>
      _DHCLIENTCalificarWidgetState();
}

class _DHCLIENTCalificarWidgetState extends State<DHCLIENTCalificarWidget> {
  late DHCLIENTCalificarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTCalificarModel());

    _model.comentarioTextController ??= TextEditingController();
    _model.comentarioFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// El botón [Enviar] permanece deshabilitado hasta que se selecciona al menos
  /// una estrella. El comentario es opcional.
  bool get _canSubmit =>
      (_model.ratingBarValue ?? 0.0) >= 1.0 && !_model.isSubmitting;

  /// Envía la calificación.
  ///
  /// NOTA: el comentario opcional se captura (lo exige el AC) pero **no viaja**:
  /// los tres endpoints de ratings sólo aceptan `stars` (y `targetRole` donde
  /// aplica), no hay campo para el texto. Queda pendiente que el backend acepte
  /// `comment` para poder adjuntarlo; hasta entonces se descarta.
  Future<void> _submit() async {
    final stars = _model.ratingBarValue ?? 0.0;
    if (stars < 1.0) return;

    safeSetState(() => _model.isSubmitting = true);
    try {
      final token = currentAuthenticationToken ?? '';
      final serviceRequestId = DHCLIENTCalificarWidget.serviceRequestId;
      final offerId = DHCLIENTCalificarWidget.offerId;
      final visitId = DHCLIENTCalificarWidget.visitId;

      ApiCallResponse? response;
      if (serviceRequestId != null && serviceRequestId.isNotEmpty) {
        response = await DOVIAAPIAssociateFeedbackContextGroup
            .createDoviaHomeAssociateRatingCall
            .call(
          serviceRequestId: serviceRequestId,
          stars: stars,
          authToken: token,
        );
      } else if (offerId != null && offerId.isNotEmpty) {
        response = await DOVIAAPIAssociateFeedbackContextGroup
            .createOfferAssociateRatingCall
            .call(
          offerId: offerId,
          targetRole: DHCLIENTCalificarWidget.targetRole,
          stars: stars,
          authToken: token,
        );
      } else if (visitId != null && visitId.isNotEmpty) {
        response = await DOVIAAPIAssociateFeedbackContextGroup
            .createVisitAssociateRatingCall
            .call(
          visitId: visitId,
          targetRole: DHCLIENTCalificarWidget.targetRole,
          stars: stars,
          authToken: token,
        );
      }

      if (response != null && !response.succeeded) {
        if (mounted) {
          final message = associateFeedbackErrorMessage(
            response,
            // El 409 no siempre viaja con código de error, y el duplicado es el
            // único conflicto posible aquí: la calificación es inmutable y
            // única por cliente + servicio.
            fallback: response.statusCode == 409
                ? 'Ya calificaste este servicio.'
                : 'No se pudo enviar la calificación. Intenta de nuevo.',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
        return;
      }

      if (!mounted) return;
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: const DHCLIENTCalificoExitoWidget(),
            ),
          );
        },
      );

      // Tras cerrar el modal, de vuelta al Dashboard.
      if (mounted) {
        context.goNamed(DHCLIENTHomepageWidget.routeName);
      }
    } finally {
      if (mounted) {
        safeSetState(() => _model.isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobTitle = DHCLIENTCalificarWidget.jobTitle;
    final jobDateLabel = DHCLIENTCalificarWidget.jobDateLabel;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            wrapWithModel(
              model: _model.cornerGradientBackgroundModel,
              updateCallback: () => safeSetState(() {}),
              child: const CornerGradientBackgroundWidget(),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIASHAREDHeaderWidget(
                      showNotifications: true,
                      showSettings: true,
                      title: 'Calificar',
                      showMap: false,
                      showCurrency: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 120.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cabecera de contexto: qué trabajo se está calificando
                        // y cuándo se realizó.
                        Text(
                          'Trabajo - ${jobTitle ?? 'Servicio'}',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.w600),
                                fontSize: 16.0,
                                letterSpacing: 0.32,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (jobDateLabel != null) ...[
                          const SizedBox(height: 12.0),
                          Text(
                            jobDateLabel,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.publicSans(),
                                  fontSize: 16.0,
                                  letterSpacing: 0.32,
                                ),
                          ),
                        ],
                        const SizedBox(height: 28.0),
                        Text(
                          '¿Cómo estuvo el trabajo que solicitaste?',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.publicSans(),
                                fontSize: 16.0,
                                letterSpacing: 0.32,
                              ),
                        ),
                        const SizedBox(height: 26.0),
                        // 5 estrellas seleccionables (1 a 5). Arranca sin
                        // selección para que [Enviar] nazca deshabilitado.
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: RatingBar.builder(
                            onRatingUpdate: (newValue) => safeSetState(
                                () => _model.ratingBarValue = newValue),
                            itemBuilder: (context, index) => Icon(
                              Icons.star_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                            direction: Axis.horizontal,
                            initialRating: _model.ratingBarValue ?? 0.0,
                            minRating: 1.0,
                            unratedColor: FlutterFlowTheme.of(context).alternate,
                            itemCount: 5,
                            itemSize: 48.0,
                            glowColor: FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                        const SizedBox(height: 28.0),
                        Text(
                          'Si deseas, puedes dejar un comentario',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.w500),
                                fontSize: 16.0,
                                letterSpacing: 0.32,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 12.0),
                        _buildComentario(),
                        const SizedBox(height: 30.0),
                        FFButtonWidget(
                          onPressed: _canSubmit ? _submit : null,
                          text: _model.isSubmitting ? 'Enviando...' : 'Enviar',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 42.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 10.0, 20.0, 10.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w600),
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                            disabledColor: FlutterFlowTheme.of(context).alternate,
                            disabledTextColor:
                                FlutterFlowTheme.of(context).secondaryText,
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(1.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 15.0, 100.0),
                      child: wrapWithModel(
                        model: _model.fixedDoviaIconModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const FixedDoviaIconWidget(),
                      ),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.dHCLIENTNavbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHCLIENTNavbarWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Campo de texto libre "Escribe aquí..." (opcional).
  Widget _buildComentario() {
    return SizedBox(
      height: 104.0,
      child: TextFormField(
        controller: _model.comentarioTextController,
        focusNode: _model.comentarioFocusNode,
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Escribe aquí...',
          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: 16.0,
                letterSpacing: 0.32,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: _kFieldSurface,
          contentPadding:
              const EdgeInsetsDirectional.fromSTEB(15.0, 16.0, 15.0, 16.0),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(),
              fontSize: 16.0,
              letterSpacing: 0.32,
            ),
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.top,
        maxLines: null,
        expands: true,
        cursorColor: FlutterFlowTheme.of(context).primaryText,
        validator:
            _model.comentarioTextControllerValidator.asValidator(context),
      ),
    );
  }
}
