import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'recover_password2_widget.dart' show RecoverPassword2Widget;
import 'package:flutter/material.dart';

class RecoverPassword2Model extends FlutterFlowModel<RecoverPassword2Widget> {
  ///  Local state fields for this page.
  /// True if both password fields contains the same content
  bool areBothPasswordsEqual = true;

  bool isValidEmailCode = true;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for PinCode widget.
  TextEditingController? pinCodeController;
  FocusNode? pinCodeFocusNode;
  String? Function(BuildContext, String?)? pinCodeControllerValidator;
  // State field(s) for PasswordInput widget.
  FocusNode? passwordInputFocusNode;
  TextEditingController? passwordInputTextController;
  late bool passwordInputVisibility;
  String? Function(BuildContext, String?)? passwordInputTextControllerValidator;
  String? _passwordInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Contraseña no válida';
    }

    if (val.length < 8) {
      return 'La contraseña debe tener al menos 8 carácteres';
    }

    return null;
  }

  // State field(s) for ConfirmPasswordInput widget.
  FocusNode? confirmPasswordInputFocusNode;
  TextEditingController? confirmPasswordInputTextController;
  late bool confirmPasswordInputVisibility;
  String? Function(BuildContext, String?)?
      confirmPasswordInputTextControllerValidator;
  String? _confirmPasswordInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Confirma la contraseña';
    }

    return null;
  }

  // State field(s) for Checkbox widget.
  bool? checkboxValue;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    pinCodeController = TextEditingController();
    passwordInputVisibility = false;
    passwordInputTextControllerValidator =
        _passwordInputTextControllerValidator;
    confirmPasswordInputVisibility = false;
    confirmPasswordInputTextControllerValidator =
        _confirmPasswordInputTextControllerValidator;
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    pinCodeFocusNode?.dispose();
    pinCodeController?.dispose();

    passwordInputFocusNode?.dispose();
    passwordInputTextController?.dispose();

    confirmPasswordInputFocusNode?.dispose();
    confirmPasswordInputTextController?.dispose();
  }
}
