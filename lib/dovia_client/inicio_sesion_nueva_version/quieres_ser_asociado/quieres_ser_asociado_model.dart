import '/components/que_significa_ser_asociado_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'quieres_ser_asociado_widget.dart' show QuieresSerAsociadoWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class QuieresSerAsociadoModel
    extends FlutterFlowModel<QuieresSerAsociadoWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel1;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel2;

  @override
  void initState(BuildContext context) {
    secondaryButtonModel1 = createModel(context, () => SecondaryButtonModel());
    secondaryButtonModel2 = createModel(context, () => SecondaryButtonModel());
  }

  @override
  void dispose() {
    secondaryButtonModel1.dispose();
    secondaryButtonModel2.dispose();
  }
}
