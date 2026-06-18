import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'l_i_s_t_i_n_g_h_q_visor_pdf_widget.dart' show LISTINGHQVisorPdfWidget;
import 'package:flutter/material.dart';

class LISTINGHQVisorPdfModel extends FlutterFlowModel<LISTINGHQVisorPdfWidget> {
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  late LISTINGHQHeaderModel lISTINGHQHeaderModel;
  late LISTINGHQNavbarModel lISTINGHQNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel = createModel(context, () => CornerGradientBackgroundModel());
    lISTINGHQHeaderModel = createModel(context, () => LISTINGHQHeaderModel());
    lISTINGHQNavbarModel = createModel(context, () => LISTINGHQNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    lISTINGHQHeaderModel.dispose();
    lISTINGHQNavbarModel.dispose();
  }
}
