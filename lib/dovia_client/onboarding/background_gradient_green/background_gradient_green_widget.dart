import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'background_gradient_green_model.dart';
export 'background_gradient_green_model.dart';

class BackgroundGradientGreenWidget extends StatefulWidget {
  const BackgroundGradientGreenWidget({super.key});

  @override
  State<BackgroundGradientGreenWidget> createState() =>
      _BackgroundGradientGreenWidgetState();
}

class _BackgroundGradientGreenWidgetState
    extends State<BackgroundGradientGreenWidget> {
  late BackgroundGradientGreenModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BackgroundGradientGreenModel());

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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF007376), Color(0xFF70ACAD)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(141.0, 354.0, 141.0, 354.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0.0),
          child: SvgPicture.asset(
            'assets/images/D-blanca.svg',
            width: 107.0,
            height: 136.0,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
