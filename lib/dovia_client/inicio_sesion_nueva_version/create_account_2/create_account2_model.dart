import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'create_account2_widget.dart' show CreateAccount2Widget;
import 'package:flutter/material.dart';

class CreateAccount2Model extends FlutterFlowModel<CreateAccount2Widget> {
  ///  Local state fields for this page.

  bool invalidCode = false;

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for PinCode widget.
  TextEditingController? pinCodeController;
  FocusNode? pinCodeFocusNode;
  String? Function(BuildContext, String?)? pinCodeControllerValidator;
  // Stores action output result for [Backend Call - API (Verify Code Step  NEW)] action in PinCode widget.
  ApiCallResponse? apiResultvj1;
  // Stores action output result for [Backend Call - API (Resend Code NEW)] action in Text widget.
  ApiCallResponse? apiResult4de;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    pinCodeController = TextEditingController();
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    pinCodeFocusNode?.dispose();
    pinCodeController?.dispose();
  }
}
