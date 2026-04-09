import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'recover_password1_widget.dart' show RecoverPassword1Widget;
import 'package:flutter/material.dart';

class RecoverPassword1Model extends FlutterFlowModel<RecoverPassword1Widget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for Correo widget.
  FocusNode? correoFocusNode;
  TextEditingController? correoTextController;
  String? Function(BuildContext, String?)? correoTextControllerValidator;
  String? _correoTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Introduce un correo';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Correo no válido';
    }
    return null;
  }

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    correoTextControllerValidator = _correoTextControllerValidator;
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    correoFocusNode?.dispose();
    correoTextController?.dispose();
  }
}
