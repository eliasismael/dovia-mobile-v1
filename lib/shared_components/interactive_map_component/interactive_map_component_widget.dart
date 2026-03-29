import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'interactive_map_component_model.dart';
export 'interactive_map_component_model.dart';

class InteractiveMapComponentWidget extends StatefulWidget {
  const InteractiveMapComponentWidget({super.key});

  @override
  State<InteractiveMapComponentWidget> createState() =>
      _InteractiveMapComponentWidgetState();
}

class _InteractiveMapComponentWidgetState
    extends State<InteractiveMapComponentWidget> {
  late InteractiveMapComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InteractiveMapComponentModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: MediaQuery.sizeOf(context).height * 1.0,
      child: custom_widgets.InteractiveMap(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: MediaQuery.sizeOf(context).height * 1.0,
        accessToken: FFAppConstants.MapboxAccessToken,
        startLat: -35.0,
        startLng: -58.0,
      ),
    );
  }
}
