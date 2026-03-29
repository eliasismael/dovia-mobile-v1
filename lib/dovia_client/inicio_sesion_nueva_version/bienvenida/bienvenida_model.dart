import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'bienvenida_widget.dart' show BienvenidaWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BienvenidaModel extends FlutterFlowModel<BienvenidaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel;

  @override
  void initState(BuildContext context) {
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
    secondaryButtonModel = createModel(context, () => SecondaryButtonModel());
  }

  @override
  void dispose() {
    primaryButtonModel.dispose();
    secondaryButtonModel.dispose();
  }
}
