import '/flutter_flow/flutter_flow_util.dart';
import 's_h_o_w_i_n_g_report_popup_widget.dart' show SHOWINGReportPopupWidget;
import 'package:flutter/material.dart';

class SHOWINGReportPopupModel
    extends FlutterFlowModel<SHOWINGReportPopupWidget> {
  // State field(s) for the report description TextField.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
