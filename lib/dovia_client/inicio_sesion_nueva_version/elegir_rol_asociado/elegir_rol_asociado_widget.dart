import '/auth/custom_auth/token_refresher.dart';
import '/auth/pending_associate_role.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'elegir_rol_asociado_model.dart';
export 'elegir_rol_asociado_model.dart';

class ElegirRolAsociadoWidget extends StatefulWidget {
  const ElegirRolAsociadoWidget({super.key});

  static String routeName = 'ElegirRolAsociado';
  static String routePath = '/elegirRolAsociado';

  @override
  State<ElegirRolAsociadoWidget> createState() =>
      _ElegirRolAsociadoWidgetState();
}

class _ElegirRolAsociadoWidgetState extends State<ElegirRolAsociadoWidget> {
  late ElegirRolAsociadoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ElegirRolAsociadoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Sin sesión (viene de "Regístrate como asociado"): guarda el rol en el
  /// teléfono y sigue con el registro normal; la solicitud se manda al final,
  /// después de la identificación y los términos. Con sesión (ya registrado,
  /// eligiendo cómo usar la cuenta): selecciona el rol en el momento.
  Future<void> _chooseRole(String role) async {
    if (!loggedIn) {
      await PendingAssociateRole.set(role);
      if (mounted) context.pushNamed(CreateAccountWidget.routeName);
      return;
    }
    final result = await DOVIAAPIAuthContextGroup.selectRoleCall.call(
      role: role,
      authToken: currentAuthenticationToken,
    );
    if (!result.succeeded) return;
    // La API recibe el ID token (antes se guardaba el access token).
    final newToken =
        DOVIAAPIAuthContextGroup.selectRoleCall.idToken(result.jsonBody);
    final newRefreshToken =
        DOVIAAPIAuthContextGroup.selectRoleCall.refreshToken(result.jsonBody);
    if (newToken != null && newToken.isNotEmpty) {
      authManager.updateAuthUserData(
        authenticationToken: newToken,
        refreshToken: newRefreshToken ?? currentAuthRefreshToken,
        tokenExpiration: currentAuthTokenExpiration,
        authUid: currentUserUid,
      );
    } else {
      // Sin tokens en la respuesta (siempre con Google): se renuevan según la
      // sesión para que traigan el rol.
      await refreshSession();
    }
    FFAppState().UserRole = role;
    if (mounted) context.pushNamed(FormAssociateWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 40.0, 0.0, 0.0),
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: const BoxDecoration(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0.0),
                            child: SvgPicture.asset(
                              'assets/images/D-verde.svg',
                              fit: BoxFit.none,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 32.0, 0.0, 0.0),
                        child: Text(
                          '¿Cómo quieres generar ingresos con DOVIA?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.publicSans(
                            color: const Color(0xFF00444B),
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 0.0),
                        child: custom_widgets.DoviaAssociateDropdownWidget(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 1.0,
                          onShowingAssociateTap: () =>
                              _chooseRole('SHOWING_AGENT'),
                          onListerAssociateTap: () =>
                              _chooseRole('OPERATIVE_LISTER'),
                          onHomeAssociateTap: () =>
                              _chooseRole('HOME_ASSOCIATE'),
                          onLegalAssociateTap: () =>
                              _chooseRole('LEGAL_ASSOCIATE'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 12.0, 0.0, 0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          child: wrapWithModel(
                            model: _model.secondaryButtonModel,
                            updateCallback: () => safeSetState(() {}),
                            child: SecondaryButtonWidget(
                              text: 'Volver',
                              onTap: () async {
                                // Vuelve a la pantalla desde la que se llegó (p. ej. el sign in).
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.goNamed(SignInWidget.routeName);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
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
