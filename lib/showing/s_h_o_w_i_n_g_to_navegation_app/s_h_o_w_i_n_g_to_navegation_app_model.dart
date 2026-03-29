import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'dart:ui';
import 's_h_o_w_i_n_g_to_navegation_app_widget.dart'
    show SHOWINGToNavegationAppWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SHOWINGToNavegationAppModel
    extends FlutterFlowModel<SHOWINGToNavegationAppWidget> {
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
