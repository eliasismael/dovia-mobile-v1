import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/user_type_card/user_type_card_widget.dart';
import '/index.dart';
import 'como_usaras_tu_cuenta_widget.dart' show ComoUsarasTuCuentaWidget;
import 'package:flutter/material.dart';

class ComoUsarasTuCuentaModel
    extends FlutterFlowModel<ComoUsarasTuCuentaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for UserTypeCard component.
  late UserTypeCardModel userTypeCardModel1;
  // Model for UserTypeCard component.
  late UserTypeCardModel userTypeCardModel2;
  // Stores action output result for [Backend Call - API (Select Role)] action in UserTypeCard widget.
  ApiCallResponse? apiResultcnl;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    userTypeCardModel1 = createModel(context, () => UserTypeCardModel());
    userTypeCardModel2 = createModel(context, () => UserTypeCardModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    userTypeCardModel1.dispose();
    userTypeCardModel2.dispose();
  }
}
