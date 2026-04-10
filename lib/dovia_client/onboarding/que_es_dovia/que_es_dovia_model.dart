import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'que_es_dovia_widget.dart' show QueEsDoviaWidget;
import 'package:flutter/material.dart';

class QueEsDoviaModel extends FlutterFlowModel<QueEsDoviaWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
