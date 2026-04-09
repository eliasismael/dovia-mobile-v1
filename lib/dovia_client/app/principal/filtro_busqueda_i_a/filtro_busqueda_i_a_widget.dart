import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'filtro_busqueda_i_a_model.dart';
export 'filtro_busqueda_i_a_model.dart';

/// Casas que se muestran en un modal desde abajo de la pantalla cuando hacen
/// match con la busqueda
class FiltroBusquedaIAWidget extends StatefulWidget {
  const FiltroBusquedaIAWidget({super.key});

  @override
  State<FiltroBusquedaIAWidget> createState() => _FiltroBusquedaIAWidgetState();
}

class _FiltroBusquedaIAWidgetState extends State<FiltroBusquedaIAWidget> {
  late FiltroBusquedaIAModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FiltroBusquedaIAModel());

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
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: 160.0,
              child: custom_widgets.DoviaClientHouseCard(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: 160.0,
                imageUrl:
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/kbm95ashhb4z/casa_card_sobreMiVisita.png',
                onAddToFavorites: () async {},
                onRemoveFromFavorites: () async {},
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: 160.0,
              child: custom_widgets.DoviaClientHouseCard(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: 160.0,
                imageUrl:
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/kbm95ashhb4z/casa_card_sobreMiVisita.png',
                onAddToFavorites: () async {},
                onRemoveFromFavorites: () async {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
