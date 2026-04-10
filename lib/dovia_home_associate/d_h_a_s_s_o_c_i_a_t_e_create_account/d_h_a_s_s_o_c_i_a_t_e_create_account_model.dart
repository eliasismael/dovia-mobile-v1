import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_create_account_widget.dart'
    show DHASSOCIATECreateAccountWidget;
import 'package:flutter/material.dart';

class DHASSOCIATECreateAccountModel
    extends FlutterFlowModel<DHASSOCIATECreateAccountWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for RoleDropdown widget.
  String? roleDropdownValue;
  FormFieldController<String>? roleDropdownValueController;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
  }
}
