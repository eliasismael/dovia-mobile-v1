import '/auth/registration_progress.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'create_account_model.dart';
export 'create_account_model.dart';

class CreateAccountWidget extends StatefulWidget {
  const CreateAccountWidget({super.key});

  static String routeName = 'CreateAccount';
  static String routePath = '/createAccount';

  @override
  State<CreateAccountWidget> createState() => _CreateAccountWidgetState();
}

class _CreateAccountWidgetState extends State<CreateAccountWidget> {
  late CreateAccountModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateAccountModel());

    _model.correoElectronicoTextController ??= TextEditingController();
    _model.correoElectronicoFocusNode ??= FocusNode();
    _model.correoElectronicoFocusNode!.addListener(
      () async {
        if (!(_model.correoElectronicoFocusNode?.hasFocus ?? false)) {
          if (!((String mail) {
            return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(mail);
          }(_model.correoElectronicoTextController.text.trim()))) {
            _model.mailInvalid = true;
            safeSetState(() {});
            return;
          } else {
            return;
          }
        } else {
          return;
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
              decoration: const BoxDecoration(),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 50.0, 0.0, 0.0),
                          child: Container(
                            decoration: const BoxDecoration(),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(0.0),
                              child: SvgPicture.asset(
                                'assets/images/D-verde.svg',
                                width: 68.0,
                                height: 88.0,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 53.0, 0.0, 0.0),
                        child: Text(
                          'Crea tu cuenta',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 39.0, 0.0, 0.0),
                        child: Form(
                          key: _model.formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
                                alignment:
                                    const AlignmentDirectional(-1.0, 0.0),
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
                              Align(
                                alignment:
                                    const AlignmentDirectional(-1.0, 0.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 0.0),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    child: TextFormField(
                                      controller: _model
                                          .correoElectronicoTextController,
                                      focusNode:
                                          _model.correoElectronicoFocusNode,
                                      onChanged: (_) => EasyDebounce.debounce(
                                        '_model.correoElectronicoTextController',
                                        const Duration(milliseconds: 2000),
                                        () async {
                                          if (_model.mailInvalid ||
                                              _model.mailAlredyRegistered ||
                                              _model.signUpError != null) {
                                            _model.mailInvalid = false;
                                            _model.mailAlredyRegistered = false;
                                            _model.signUpError = null;
                                            safeSetState(() {});
                                          }
                                        },
                                      ),
                                      autofocus: false,
                                      enabled: true,
                                      obscureText: false,
                                      keyboardType: TextInputType.emailAddress,
                                      autocorrect: false,
                                      autofillHints: const [
                                        AutofillHints.email
                                      ],
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
                                          borderSide: BorderSide(
                                            color: _model.mailAlredyRegistered
                                                ? FlutterFlowTheme.of(context)
                                                    .error
                                                : const Color(0x00000000),
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
                                          .correoElectronicoTextControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 0.0),
                                child: Builder(
                                  builder: (context) {
                                    if (_model.mailInvalid) {
                                      return Text(
                                        'El correo electrónico no es valido',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
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
                                      );
                                    } else if (_model.mailAlredyRegistered) {
                                      return Text(
                                        'El correo electrónico ya está registrado. Inicia sesión.',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
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
                                      );
                                    } else if (_model.signUpError != null) {
                                      return Text(
                                        _model.signUpError!,
                                        style: GoogleFonts.inter(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          fontSize: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontSize,
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        width: 0.0,
                                        height: 0.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 30.0, 0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: ((_model.mailInvalid == true) ||
                                          (_model.correoElectronicoTextController
                                                  .text ==
                                              ''))
                                      ? null
                                      : () async {
                                          var shouldSetState = false;
                                          FFAppState().UserEmail = _model
                                              .correoElectronicoTextController
                                              .text
                                              .trim();
                                          FFAppState().update(() {});
                                          _model.response =
                                              await DOVIAAPIAuthContextGroup
                                                  .signUpStepNEWCall
                                                  .call(
                                            email: FFAppState().UserEmail,
                                          );

                                          shouldSetState = true;
                                          if ((_model.response?.succeeded ??
                                              true)) {
                                            if (!context.mounted) return;
                                            context.pushNamed(
                                                CreateAccount2Widget.routeName);

                                            if (shouldSetState) {
                                              safeSetState(() {});
                                            }
                                            return;
                                          } else {
                                            final errorCode = getJsonField(
                                              _model.response?.jsonBody,
                                              r'''$.errors[0].code''',
                                            )?.toString();
                                            if (errorCode ==
                                                'PASSWORD_RECOVERY_REQUIRED') {
                                              // Ya verificó el correo pero no
                                              // completó sus datos. Se le
                                              // manda un código nuevo (el de
                                              // recuperación, el único que el
                                              // backend acepta para un correo
                                              // confirmado) y sigue como en
                                              // el registro normal.
                                              final email =
                                                  FFAppState().UserEmail;
                                              final forgot =
                                                  await DOVIAAPIAuthContextGroup
                                                      .forgotPasswordNEWCall
                                                      .call(email: email);
                                              if (!mounted) return;
                                              if (!forgot.succeeded) {
                                                _model.signUpError =
                                                    'Tu registro quedó incompleto. Recupera tu contraseña para continuar.';
                                                safeSetState(() {});
                                                return;
                                              }
                                              RegistrationProgress.resumeEmail =
                                                  email;
                                              _model.signUpError = null;
                                              safeSetState(() {});
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Tu registro quedó a medias. Te enviamos un código para continuar.'),
                                              ));
                                              if (!context.mounted) return;
                                              context.pushNamed(
                                                  CreateAccount2Widget
                                                      .routeName);
                                              return;
                                            }
                                            if ((_model.response?.statusCode ??
                                                    200) ==
                                                409) {
                                              _model.mailAlredyRegistered =
                                                  true;
                                              safeSetState(() {});
                                              if (shouldSetState) {
                                                safeSetState(() {});
                                              }
                                              return;
                                            } else {
// El correo puede existir sin confirmar (p. ej. el usuario volvió
// atrás desde la pantalla del código). Si el sign-up no lo
// resolvió, se pide el reenvío del código y se sigue al paso
// del código.
                                              final resend =
                                                  await DOVIAAPIAuthContextGroup
                                                      .resendCodeNEWCall
                                                      .call(
                                                          email: FFAppState()
                                                              .UserEmail);
                                              if (!mounted) return;
                                              if (resend.succeeded) {
                                                _model.signUpError = null;
                                                safeSetState(() {});
                                                if (!context.mounted) return;
                                                context.pushNamed(
                                                    CreateAccount2Widget
                                                        .routeName);
                                                return;
                                              }
                                              final status =
                                                  _model.response?.statusCode ??
                                                      0;
                                              _model.signUpError = status ==
                                                          429 ||
                                                      resend.statusCode == 429
                                                  ? 'Hiciste demasiados intentos. Espera unos minutos e inténtalo de nuevo.'
                                                  : 'No pudimos crear tu cuenta. Intenta de nuevo.';
                                              safeSetState(() {});
                                              return;
                                            }
                                          }
                                        },
                                  text: 'Continuar',
                                  options: FFButtonOptions(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height: 40.0,
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                    iconPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: Colors.white,
                                          fontSize: 15.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(25.0),
                                    disabledColor:
                                        FlutterFlowTheme.of(context).accent1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 39.0, 0.0, 0.0),
                        child: Text(
                          '----------------------  o  ----------------------',
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 39.0, 0.0, 0.0),
                          child: Container(
                            width: 350.0,
                            decoration: const BoxDecoration(),
                            child: Align(
                              alignment: const AlignmentDirectional(0.0, -1.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height: 42.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F4F4),
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: SvgPicture.asset(
                                        'assets/images/AppleLogo.svg',
                                        width: 16.0,
                                        height: 16.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 15.0, 0.0, 0.0),
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 42.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F4F4),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: SvgPicture.asset(
                                          'assets/images/GoogleLogo.svg',
                                          width: 13.0,
                                          height: 13.0,
                                          fit: BoxFit.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 15.0, 0.0, 0.0),
                                    child: Container(
                                      width: 1000.0,
                                      height: 42.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F4F4),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: SvgPicture.asset(
                                          'assets/images/FacebookLogo.svg',
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 0.0),
                        child: RichText(
                          textScaler: MediaQuery.of(context).textScaler,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '¿Ya tienes cuenta? ',
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
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                              TextSpan(
                                text: 'Inicia sesión',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                mouseCursor: SystemMouseCursors.click,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    context.pushNamed(SignInWidget.routeName);
                                  },
                              )
                            ],
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
}
