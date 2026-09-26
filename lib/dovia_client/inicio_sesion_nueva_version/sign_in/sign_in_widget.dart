import '/auth/registration_progress.dart';
import '/auth/pending_associate_role.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_in_model.dart';
export 'sign_in_model.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  static String routeName = 'SignIn';
  static String routePath = '/signIn';

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  late SignInModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignInModel());

    _model.correoInputTextController ??= TextEditingController();
    _model.correoInputFocusNode ??= FocusNode();

    _model.passwordInputTextController ??= TextEditingController();
    _model.passwordInputFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: Stack(
          children: [
            wrapWithModel(
              model: _model.cornerGradientBackgroundModel,
              updateCallback: () => safeSetState(() {}),
              child: const CornerGradientBackgroundWidget(),
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 64.0, 0.0, 0.0),
                        child: Container(
                          decoration: const BoxDecoration(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0.0),
                            child: SvgPicture.asset(
                              'assets/images/D-verde.svg',
                              width: 52.0,
                              height: 68.0,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: Text(
                            'Ingresa a tu cuenta',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: const Color(0xFF00444B),
                                  fontSize: 26.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                      Form(
                        key: _model.formKey,
                        autovalidateMode: AutovalidateMode.disabled,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Text(
                                  'Correo',
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 16.0,
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
                            ),
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 0.0),
                                child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  child: TextFormField(
                                    controller:
                                        _model.correoInputTextController,
                                    focusNode: _model.correoInputFocusNode,
                                    autofocus: false,
                                    enabled: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      hintText: 'ex: jon.smith@email.com',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
                                          .alternate,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    enableInteractiveSelection: true,
                                    validator: _model
                                        .correoInputTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 14.0, 0.0, 0.0),
                                child: Text(
                                  'Contraseña',
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 16.0,
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
                            ),
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 0.0),
                                child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  child: TextFormField(
                                    controller:
                                        _model.passwordInputTextController,
                                    focusNode: _model.passwordInputFocusNode,
                                    autofocus: false,
                                    enabled: true,
                                    obscureText:
                                        !_model.passwordInputVisibility,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      hintText: '************',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
                                          .alternate,
                                      suffixIcon: InkWell(
                                        onTap: () async {
                                          safeSetState(() => _model
                                                  .passwordInputVisibility =
                                              !_model.passwordInputVisibility);
                                        },
                                        focusNode:
                                            FocusNode(skipTraversal: true),
                                        child: Icon(
                                          _model.passwordInputVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    enableInteractiveSelection: true,
                                    validator: _model
                                        .passwordInputTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(
                                      RecoverPasswordStep1Widget.routeName);
                                },
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Builder(
                          builder: (context) {
                            if (_model.invalidMailOrPassword) {
                              return Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Text(
                                  _model.signInError ?? '',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.3,
                                      ),
                                ),
                              );
                            } else {
                              return Container(
                                width: 0.0,
                                height: 0.0,
                                decoration: const BoxDecoration(),
                              );
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            _model.invalidMailOrPassword = false;
                            safeSetState(() {});
                            _model.resultForm = true;
                            if (_model.formKey.currentState == null ||
                                !_model.formKey.currentState!.validate()) {
                              _model.resultForm = false;
                            }
                            if (_model.resultForm!) {
                              _model.apiResultbr7 =
                                  await DOVIAAPIAuthContextGroup.signInNEWCall
                                      .call(
                                email: _model.correoInputTextController.text,
                                password:
                                    _model.passwordInputTextController.text,
                              );

                              if ((_model.apiResultbr7?.succeeded ?? true)) {
                                // El inicio de sesión se apila sobre esta
                                // pantalla, que sigue viva: sin esto, al
                                // cerrar sesión volvía con el correo y la
                                // contraseña del usuario anterior escritos.
                                _model.correoInputTextController?.clear();
                                _model.passwordInputTextController?.clear();
                                final idToken = DOVIAAPIAuthContextGroup
                                    .signInNEWCall
                                    .idToken(
                                  (_model.apiResultbr7?.jsonBody ?? ''),
                                );
                                GoRouter.of(context).prepareAuthEvent();
                                await authManager.signIn(
                                  authenticationToken: idToken,
                                  refreshToken: DOVIAAPIAuthContextGroup
                                      .signInNEWCall
                                      .refreshToken(
                                    (_model.apiResultbr7?.jsonBody ?? ''),
                                  ),
                                );

                                _model.apiResultProfile =
                                    await DOVIAAPIUserContextGroup
                                        .getAuthenticatedUserProfileCall
                                        .call(
                                  authToken: idToken,
                                );

                                final userRole = DOVIAAPIUserContextGroup
                                    .getAuthenticatedUserProfileCall
                                    .userRole(
                                  (_model.apiResultProfile?.jsonBody ?? ''),
                                );
                                final isActive = DOVIAAPIUserContextGroup
                                    .getAuthenticatedUserProfileCall
                                    .isUserActive(
                                  (_model.apiResultProfile?.jsonBody ?? ''),
                                );

                                final associateRoles = [
                                  'SHOWING_AGENT',
                                  'OPERATIVE_LISTER',
                                  'LISTER_HQ',
                                  'HOME_ASSOCIATE',
                                  // Asociado tipo Empresa: mismo contexto Dovia
                                  // Home, pero su panel es el pipeline de
                                  // cotizaciones y no la bolsa de trabajos.
                                  'HOME_ASSOCIATE_COMPANY',
                                  'LEGAL_ASSOCIATE',
                                  'LEGAL_OFFICER',
                                  'HQ_ADMIN',
                                ];

                                if (!context.mounted) return;

                                // Registro a medias: se retoma el paso que
                                // falta en vez de entrar al home.
                                final signInBody =
                                    _model.apiResultbr7?.jsonBody ?? '';
                                final roleSelected = DOVIAAPIAuthContextGroup
                                    .signInNEWCall
                                    .isRoleSelected(signInBody);
                                if (roleSelected == false) {
                                  await RegistrationProgress.set(
                                      RegistrationProgress.idAndTerms);
                                  RegistrationProgress.resumedAfterRestart =
                                      true;
                                  if (!context.mounted) return;
                                  context.goNamed(Datos2Widget.routeName);
                                  return;
                                }
                                if (associateRoles.contains(userRole)) {
                                  final profileDone = DOVIAAPIAuthContextGroup
                                      .signInNEWCall
                                      .isAssociateProfileComplete(signInBody);
                                  final verified = DOVIAAPIAuthContextGroup
                                      .signInNEWCall
                                      .verified(signInBody);
                                  final submitted = await RegistrationProgress
                                      .associateSubmitted(currentUserUid);
                                  if (!context.mounted) return;
                                  if (RegistrationProgress.step ==
                                          RegistrationProgress.associateForm ||
                                      (profileDone == false &&
                                          verified != true &&
                                          !submitted)) {
                                    FFAppState().UserRole = userRole ?? '';
                                    await RegistrationProgress.set(
                                        RegistrationProgress.associateForm);
                                    if (!context.mounted) return;
                                    context
                                        .goNamed(FormAssociateWidget.routeName);
                                    return;
                                  }
                                }
                                await RegistrationProgress.clear();
                                if (!context.mounted) return;

                                if (associateRoles.contains(userRole)) {
                                  if (isActive != true) {
                                    // Account pending approval — show modal then go to welcome
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
                                                      BorderRadius.circular(
                                                          0.0),
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
                                                        font: GoogleFonts
                                                            .publicSans(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        fontSize: 18.0,
                                                        color: const Color(
                                                            0xFF00444B),
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
                                                        font: GoogleFonts
                                                            .publicSans(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                                const SizedBox(height: 24.0),
                                                FFButtonWidget(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          dialogContext),
                                                  text: 'Entendido',
                                                  options: FFButtonOptions(
                                                    width: double.infinity,
                                                    height: 42.0,
                                                    color:
                                                        const Color(0xFF007376),
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
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
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    await authManager.signOut();
                                    context.pushNamedAuth(
                                        BienvenidaWidget.routeName,
                                        context.mounted);
                                  } else {
                                    // Approved — route to role-specific home
                                    FFAppState().UserRole =
                                        userRole ?? 'HOME_ASSOCIATE';
                                    if (userRole == 'SHOWING_AGENT') {
                                      context.pushNamedAuth(
                                          SHOWINGHomeWidget.routeName,
                                          context.mounted);
                                    } else if (userRole == 'OPERATIVE_LISTER') {
                                      context.pushNamedAuth(
                                          OPERATIVELISTINGHomeWidget.routeName,
                                          context.mounted);
                                    } else if (userRole == 'LISTER_HQ') {
                                      context.pushNamedAuth(
                                          LISTINGHQHomeWidget.routeName,
                                          context.mounted);
                                    } else if (userRole == 'LEGAL_OFFICER') {
                                      // Legal HQ audita y supervisa: su panel es
                                      // el tablero de expedientes, no la bolsa
                                      // de trabajo del asociado.
                                      context.pushNamedAuth(
                                          LEGALHQHomeWidget.routeName,
                                          context.mounted);
                                    } else if (userRole == 'LEGAL_ASSOCIATE') {
                                      context.pushNamedAuth(
                                          LegalAssociateHomeWidget.routeName,
                                          context.mounted);
                                    } else if (userRole ==
                                        'HOME_ASSOCIATE_COMPANY') {
                                      // La empresa no tiene bolsa de trabajos:
                                      // su panel es el pipeline de cotizaciones.
                                      context.pushNamedAuth(
                                          DHASSOCIATEEmpresaHomePageWidget
                                              .routeName,
                                          context.mounted);
                                    } else {
                                      // HOME_ASSOCIATE / HQ_ADMIN
                                      context.pushNamedAuth(
                                          DHASSOCIATEHomePageWidget.routeName,
                                          context.mounted);
                                    }
                                  }
                                } else {
                                  FFAppState().UserRole = 'CLIENT';
                                  context.pushNamedAuth(
                                      DOVIACLIENTHomePageWidget.routeName,
                                      context.mounted);
                                }
                              } else {
                                // Error en texto rojo bajo el form, sin dialog con el JSON.
                                final status =
                                    _model.apiResultbr7?.statusCode ?? 0;
                                _model.signInError = (status == 400 ||
                                        status == 401 ||
                                        status == 404)
                                    ? 'Correo o contraseña incorrectos.\nPor favor, verifica tus datos e Inténtalo nuevamente.'
                                    : 'No pudimos iniciar sesión. Intenta de nuevo en unos minutos.';
                                _model.invalidMailOrPassword = true;
                                safeSetState(() {});
                              }
                            }

                            safeSetState(() {});
                          },
                          text: 'Inicia sesión',
                          options: FFButtonOptions(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: 42.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 10.0, 20.0, 10.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: const Color(0xFF007376),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.publicSans(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 16.0, 0.0, 0.0),
                        child: Text(
                          'O inicia con',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 14.0, 0.0, 0.0),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: 46.6,
                          decoration: const BoxDecoration(),
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, -1.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 6.0, 0.0),
                                    child: Container(
                                      height: 42.0,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F4F4),
                                        borderRadius:
                                            BorderRadius.circular(13.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        child: SvgPicture.asset(
                                          'assets/images/AppleLogo.svg',
                                          width: 19.0,
                                          height: 19.0,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            6.0, 0.0, 6.0, 0.0),
                                    child: Container(
                                      height: 42.0,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F4F4),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: SvgPicture.asset(
                                          'assets/images/GoogleLogo.svg',
                                          width: 19.0,
                                          height: 19.0,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            6.0, 0.0, 0.0, 0.0),
                                    child: Container(
                                      height: 42.0,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F4F4),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        child: SvgPicture.asset(
                                          'assets/images/FacebookLogo.svg',
                                          width: 19.0,
                                          height: 19.0,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '¿Todavía no tienes cuenta?',
                              style: GoogleFonts.publicSans(
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            _footerLink(
                              'Regístrate como usuario',
                              () {
                                PendingAssociateRole.clear();
                                context
                                    .pushNamed(CreateAccountWidget.routeName);
                              },
                            ),
                            _footerDivider(),
                            _footerLink('Ingresa como visita', () {
                              FFAppState().UserRole = Roles.VISITOR.name;
                              context
                                  .goNamed(DOVIACLIENTHomePageWidget.routeName);
                            }),
                            _footerDivider(),
                            _footerLink(
                              'Regístrate como asociado',
                              () => context
                                  .pushNamed(ElegirRolAsociadoWidget.routeName),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(String text, VoidCallback onTap) => InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            text,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF007376),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  Widget _footerDivider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 4.0),
        child: Row(
          children: [
            Expanded(child: Divider(thickness: 1.0, color: Color(0xFFD9D9D9))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('o', style: TextStyle(color: Color(0xFF8A8A8A))),
            ),
            Expanded(child: Divider(thickness: 1.0, color: Color(0xFFD9D9D9))),
          ],
        ),
      );
}
