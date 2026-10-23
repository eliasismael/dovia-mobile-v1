import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'corner_gradient_background_model.dart';
export 'corner_gradient_background_model.dart';

class CornerGradientBackgroundWidget extends StatefulWidget {
  const CornerGradientBackgroundWidget({super.key});

  @override
  State<CornerGradientBackgroundWidget> createState() =>
      _CornerGradientBackgroundWidgetState();
}

class _CornerGradientBackgroundWidgetState
    extends State<CornerGradientBackgroundWidget> {
  late CornerGradientBackgroundModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CornerGradientBackgroundModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Casi todas las pantallas ponen el fondo dentro de un SafeArea: la franja
    // de la barra de estado quedaba con el color liso del Scaffold y el
    // brillo de arriba empezaba recién debajo, como un techo. Si arriba hay un
    // SafeArea, el fondo sube hasta el borde de la pantalla. Se corre al
    // pintar (no en el layout), así el Stack de la pantalla no lo recorta.
    final consumedTop = MediaQuery.viewPaddingOf(context).top -
        MediaQuery.paddingOf(context).top;
    if (consumedTop <= 0) return _background(context);
    return Transform.translate(
      offset: Offset(0.0, -consumedTop),
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: double.infinity,
        child: _background(context),
      ),
    );
  }

  Widget _background(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: MediaQuery.sizeOf(context).height * 1.0,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: MediaQuery.sizeOf(context).height * 1.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).alternate,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: const AlignmentDirectional(-1.0, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/Ellipse_17.png',
                        width: 350.0,
                        height: 350.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(1.0, -1.0),
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/Ellipse_16.png',
                        width: 350.0,
                        height: 350.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
