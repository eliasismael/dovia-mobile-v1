// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// CUSTOM RECOVER PASSWORD 1
import '/backend/api_requests/api_calls.dart';
import '/core/api_error.dart';
import '/index.dart' show RecoverPasswordStep2Widget;
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRecoverPassword1 extends StatefulWidget {
  const CustomRecoverPassword1({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<CustomRecoverPassword1> createState() => _CustomRecoverPassword1State();
}

class _CustomRecoverPassword1State extends State<CustomRecoverPassword1> {
  final formKey = GlobalKey<FormState>();
  TextEditingController? correoTextController;
  FocusNode? correoFocusNode;
  bool isEmailValid = false;

  @override
  void initState() {
    super.initState();
    correoTextController = TextEditingController();
    correoFocusNode = FocusNode();
    correoTextController!.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final val = correoTextController!.text.trim();
    final isValid =
        val.isNotEmpty && RegExp(kTextValidatorEmailRegex).hasMatch(val);
    if (isValid != isEmailValid) {
      if (mounted) {
        setState(() {
          isEmailValid = isValid;
        });
      }
    }
  }

  @override
  void dispose() {
    correoTextController?.removeListener(_onEmailChanged);
    correoTextController?.dispose();
    correoFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        width: widget.width ?? MediaQuery.sizeOf(context).width * 1.0,
        height: widget.height ?? MediaQuery.sizeOf(context).height * 1.0,
        color: FlutterFlowTheme.of(context).secondaryBackground,
        child: Stack(
          children: [
            // BACKGROUND INLINED
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).alternate,
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: const AlignmentDirectional(-1.0, 1.0),
                    child: Container(
                      decoration:
                          const BoxDecoration(shape: BoxShape.rectangle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/Ellipse_17.png',
                          width: 350.0,
                          height: 350.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(1.0, -1.0),
                    child: Container(
                      decoration: const BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/Ellipse_16.png',
                          width: 350.0,
                          height: 350.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // MAIN UI
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
              decoration: const BoxDecoration(),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 111.0, 0.0, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: SvgPicture.asset(
                          'assets/images/D-verde.svg',
                          width: 68.0,
                          height: 88.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 53.0, 0.0, 0.0),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                          0.0, 41.0, 0.0, 0.0),
                      child: Container(
                        width: 350.0,
                        decoration: const BoxDecoration(),
                        alignment: const AlignmentDirectional(-1.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Por favor escribe tu correo electrónico para restablecer la contraseña',
                              textAlign: TextAlign.start,
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
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 30.0, 0.0, 0.0),
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
                            Form(
                              key: formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 12.0, 0.0, 0.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        child: TextFormField(
                                          controller: correoTextController,
                                          focusNode: correoFocusNode,
                                          autofocus: false,
                                          enabled: true,
                                          obscureText: false,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                            hintText: 'ej: jon.smith@email.com',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFF007376),
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .alternate,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          enableInteractiveSelection: true,
                                          validator: (val) {
                                            val = val?.trim();
                                            if (val == null || val.isEmpty) {
                                              return 'Ingresa un correo electrónico';
                                            }
                                            if (!RegExp(
                                                    kTextValidatorEmailRegex)
                                                .hasMatch(val)) {
                                              return 'Tiene que ser un correo electrónico válido';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 67.0, 0.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: isEmailValid
                                          ? () async {
                                              if (formKey.currentState ==
                                                      null ||
                                                  !formKey.currentState!
                                                      .validate()) {
                                                return;
                                              }
                                              final email =
                                                  correoTextController!.text
                                                      .trim();
                                              final res =
                                                  await DOVIAAPIAuthContextGroup
                                                      .forgotPasswordNEWCall
                                                      .call(email: email);
                                              if (!context.mounted) return;
                                              // Antes se pasaba al paso 2
                                              // aunque el correo no hubiera
                                              // salido, y el usuario esperaba
                                              // un código que nunca llegaba.
                                              if (!res.succeeded) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(apiErrorMessage(
                                                      res,
                                                      'No pudimos enviarte el código. Inténtalo de nuevo.')),
                                                ));
                                                return;
                                              }

                                              context.pushNamed(
                                                RecoverPasswordStep2Widget
                                                    .routeName,
                                                queryParameters: {
                                                  'email': serializeParam(
                                                    email,
                                                    ParamType.String,
                                                  ),
                                                },
                                              );
                                            }
                                          : null,
                                      text: 'Restablecer contraseña',
                                      options: FFButtonOptions(
                                        width: 349.0,
                                        height: 42.0,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(20.0, 10.0, 20.0, 10.0),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: isEmailValid
                                            ? const Color(0xFF00444B)
                                            : FlutterFlowTheme.of(context)
                                                .alternate,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.publicSans(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color: isEmailValid
                                                  ? Colors.white
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 15.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(25.0),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
