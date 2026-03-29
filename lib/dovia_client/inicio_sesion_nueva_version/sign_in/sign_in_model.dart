import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'sign_in_widget.dart' show SignInWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignInModel extends FlutterFlowModel<SignInWidget> {
  ///  Local state fields for this page.

  bool invalidMailOrPassword = false;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for CorreoInput widget.
  FocusNode? correoInputFocusNode;
  TextEditingController? correoInputTextController;
  String? Function(BuildContext, String?)? correoInputTextControllerValidator;
  String? _correoInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Introduce un correo';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Introduce un correo válido';
    }
    return null;
  }

  // State field(s) for PasswordInput widget.
  FocusNode? passwordInputFocusNode;
  TextEditingController? passwordInputTextController;
  late bool passwordInputVisibility;
  String? Function(BuildContext, String?)? passwordInputTextControllerValidator;
  String? _passwordInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Introduce tu contraseña';
    }

    return null;
  }

  // Stores action output result for [Validate Form] action in Button widget.
  bool? resultForm;
  // Stores action output result for [Backend Call - API (Sign In NEW)] action in Button widget.
  ApiCallResponse? apiResultbr7;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    correoInputTextControllerValidator = _correoInputTextControllerValidator;
    passwordInputVisibility = false;
    passwordInputTextControllerValidator =
        _passwordInputTextControllerValidator;
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    correoInputFocusNode?.dispose();
    correoInputTextController?.dispose();

    passwordInputFocusNode?.dispose();
    passwordInputTextController?.dispose();
  }
}
