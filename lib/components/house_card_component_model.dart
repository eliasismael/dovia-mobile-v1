import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'house_card_component_widget.dart' show HouseCardComponentWidget;
import 'package:flutter/material.dart';

class HouseCardComponentModel
    extends FlutterFlowModel<HouseCardComponentWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;

  @override
  void initState(BuildContext context) {
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
  }

  @override
  void dispose() {
    primaryButtonModel.dispose();
  }
}
