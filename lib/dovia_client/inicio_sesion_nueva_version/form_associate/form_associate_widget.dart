import '/auth/registration_progress.dart';
import '/auth/custom_auth/auth_util.dart';
import '/auth/sign_out.dart';
import '/backend/api_requests/api_manager.dart';
import '/backend/api_requests/api_users.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/draw_map_component/draw_map_component_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'form_associate_model.dart';
export 'form_associate_model.dart';

class FormAssociateWidget extends StatefulWidget {
  const FormAssociateWidget({super.key});

  static String routeName = 'FormAssociate';
  static String routePath = '/formAssociate';

  @override
  State<FormAssociateWidget> createState() => _FormAssociateWidgetState();
}

class _FormAssociateWidgetState extends State<FormAssociateWidget> {
  late FormAssociateModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormAssociateModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAlreadySent());
  }

  /// Mientras se consulta si el formulario ya se había enviado.
  bool _checkingSent = true;

  /// Si el perfil del backend ya tiene los documentos y la dirección, el
  /// formulario se envió antes (otra sesión, otro teléfono, o un paso
  /// guardado de una versión anterior): se pasa a "solicitud en revisión" en
  /// vez de pedir todo otra vez.
  Future<void> _checkAlreadySent() async {
    final call = DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall;
    final response = await call
        .call(authToken: currentAuthenticationToken)
        .timeout(const Duration(seconds: 6),
            onTimeout: () => const ApiCallResponse(null, {}, -1));
    if (!mounted) return;
    if (response.succeeded &&
        RegistrationProgress.associateFormSentInProfile(response.jsonBody)) {
      await RegistrationProgress.set(RegistrationProgress.pendingReview);
      if (!mounted) return;
      context.goNamed(SolicitudEnRevisionWidget.routeName);
      return;
    }
    safeSetState(() => _checkingSent = false);
  }

  /// No se puede volver a la identificación y los términos, pero sí salir:
  /// se cierra la sesión y el registro se retoma al volver a entrar.
  Future<void> _confirmExit() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('¿Salir del registro?',
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w600, color: const Color(0xFF00444B))),
        content: Text(
          'Lo que ya cargaste queda guardado. Para continuar, vuelve a '
          'iniciar sesión con tu correo.',
          style: GoogleFonts.publicSans(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Seguir completando',
                style: GoogleFonts.publicSans(color: const Color(0xFF007376))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Cerrar sesión',
                style: GoogleFonts.publicSans(
                    color: const Color(0xFF007376),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (exit != true || !mounted) return;
    await signOutAndGoToLogin(context);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  String _roleBadgeText(String role) {
    switch (role) {
      case 'SHOWING_AGENT':
        return 'Dovia Showing Associate';
      case 'OPERATIVE_LISTER':
        return 'Dovia Lister Associate';
      case 'LISTER_HQ':
        return 'Dovia Lister HQ';
      case 'HOME_ASSOCIATE':
        return 'Dovia Home Associate';
      case 'LEGAL_ASSOCIATE':
      case 'LEGAL_OFFICER':
        return 'Dovia Legal Associate';
      default:
        return 'Dovia Associate';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Paso del registro: no se vuelve a la identificación y los términos. El
    // botón atrás ofrece salir (cerrando sesión) en vez de no hacer nada.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                wrapWithModel(
                  model: _model.cornerGradientBackgroundModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const CornerGradientBackgroundWidget(),
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: IconButton(
                    tooltip: 'Salir del registro',
                    onPressed: _confirmExit,
                    icon: SvgPicture.asset(
                      'assets/images/IconoVolverAtras.svg',
                      fit: BoxFit.none,
                    ),
                  ),
                ),
                // Solo el spinner mientras se consulta si ya lo había enviado:
                // el formulario no aparece un instante para irse enseguida.
                if (_checkingSent)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF007376),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 40.0, 20.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Ocupa el alto que queda (y se achica con el teclado
                        // abierto); el formulario scrollea por dentro. Con un
                        // alto fijo del 80 % de la pantalla desbordaba al abrir
                        // el teclado.
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 40.0, 0.0, 24.0),
                            child: custom_widgets.DoviaAssociateFormWidget(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: double.infinity,
                              roleBadgeText:
                                  _roleBadgeText(FFAppState().UserRole),
                              onEnviar: () async {
                                // La sesión queda abierta: hasta que DOVIA lo
                                // apruebe, al abrir la app ve "solicitud en
                                // revisión" en vez del login.
                                await RegistrationProgress.set(
                                    RegistrationProgress.pendingReview);
                                await RegistrationProgress
                                    .markAssociateSubmitted(currentUserUid);
                                if (!context.mounted) return;
                                await showDialog(
                                  context: context,
                                  barrierColor: Colors.black54,
                                  builder: (dialogContext) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: SvgPicture.asset(
                                                'assets/images/D-verde.svg',
                                                width: 48.0,
                                                height: 62.0,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(height: 16.0),
                                            Text(
                                              'Tu cuenta se creó con éxito.',
                                              textAlign: TextAlign.center,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.publicSans(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                    fontSize: 18.0,
                                                    color:
                                                        const Color(0xFF00444B),
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                            const SizedBox(height: 12.0),
                                            Text(
                                              'El equipo de DOVIA se comunicará contigo a la brevedad para continuar con el proceso de incorporación.',
                                              textAlign: TextAlign.center,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.publicSans(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    lineHeight: 1.4,
                                                  ),
                                            ),
                                            const SizedBox(height: 24.0),
                                            FFButtonWidget(
                                              onPressed: () =>
                                                  Navigator.pop(dialogContext),
                                              text: 'Entendido',
                                              options: FFButtonOptions(
                                                width: double.infinity,
                                                height: 42.0,
                                                color: const Color(0xFF007376),
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .publicSans(),
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                elevation: 0.0,
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                                if (context.mounted) {
                                  context.goNamed(
                                      SolicitudEnRevisionWidget.routeName);
                                }
                              },
                              onMapPointSelected:
                                  (latitude, longitude) async {},
                              mapWidget: () => DrawMapComponentWidget(
                                onPointSelected: (latitude, longitude) async {},
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
