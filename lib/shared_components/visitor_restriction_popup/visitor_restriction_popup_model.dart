import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'visitor_restriction_popup_widget.dart'
    show VisitorRestrictionPopupWidget;
import 'package:flutter/material.dart';

class VisitorRestrictionPopupModel
    extends FlutterFlowModel<VisitorRestrictionPopupWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel;
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;

  @override
  void initState(BuildContext context) {
    secondaryButtonModel = createModel(context, () => SecondaryButtonModel());
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
  }

  @override
  void dispose() {
    secondaryButtonModel.dispose();
    primaryButtonModel.dispose();
  }
}
