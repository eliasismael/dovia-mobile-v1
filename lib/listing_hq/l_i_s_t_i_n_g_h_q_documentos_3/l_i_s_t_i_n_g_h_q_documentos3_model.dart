import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'l_i_s_t_i_n_g_h_q_documentos3_widget.dart'
    show LISTINGHQDocumentos3Widget;
import 'package:flutter/material.dart';

class LISTINGHQDocumentos3Model
    extends FlutterFlowModel<LISTINGHQDocumentos3Widget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for LISTING_HQ_Header component.
  late LISTINGHQHeaderModel lISTINGHQHeaderModel;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel;
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;
  // Model for LISTING_HQ_Navbar component.
  late LISTINGHQNavbarModel lISTINGHQNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    lISTINGHQHeaderModel = createModel(context, () => LISTINGHQHeaderModel());
    secondaryButtonModel = createModel(context, () => SecondaryButtonModel());
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
    lISTINGHQNavbarModel = createModel(context, () => LISTINGHQNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    lISTINGHQHeaderModel.dispose();
    secondaryButtonModel.dispose();
    primaryButtonModel.dispose();
    lISTINGHQNavbarModel.dispose();
  }
}
