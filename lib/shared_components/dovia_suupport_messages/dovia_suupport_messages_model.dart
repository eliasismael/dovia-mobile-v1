import '/flutter_flow/flutter_flow_util.dart';
import 'dovia_suupport_messages_widget.dart' show DoviaSuupportMessagesWidget;
import 'package:flutter/material.dart';

class DoviaSuupportMessagesModel
    extends FlutterFlowModel<DoviaSuupportMessagesWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
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
