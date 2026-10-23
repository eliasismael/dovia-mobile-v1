import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'd_h_c_l_i_e_n_t_otra_ubicacion_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_h_c_l_i_e_n_t_otra_ubicacion_model.dart';

/// Ruta "Otra ubicación" del flujo de cotización.
///
/// El alta de una dirección nueva **con Coverage Check** vive en
/// [DHCLIENTUbicacionWidget]: es la pantalla que valida la zona elegida contra
/// las zonas operables de DOVIA (`GET /dovia-home/workable-zones`) antes de
/// registrar la dirección, y la que deriva a [DHCLIENTFueraDeAlcanceWidget]
/// cuando queda fuera del área de servicio.
///
/// Esta ruta quedó registrada en nav.dart apuntando a una pantalla generada por
/// FlutterFlow que no tenía nada que ver con su nombre (mostraba el precio de un
/// servicio y un botón sin acción). Para no dejar un callejón sin salida se
/// reenvía al Coverage Check real, conservando la navegación pendiente que haya
/// dejado la pantalla de origen ([DHCLIENTUbicacionWidget.pendingNextRoute]).
class DHCLIENTOtraUbicacionWidget extends StatefulWidget {
  const DHCLIENTOtraUbicacionWidget({super.key});

  static String routeName = 'DH_CLIENT_OtraUbicacion';
  static String routePath = '/dHCLIENTOtraUbicacion';

  @override
  State<DHCLIENTOtraUbicacionWidget> createState() =>
      _DHCLIENTOtraUbicacionWidgetState();
}

class _DHCLIENTOtraUbicacionWidgetState
    extends State<DHCLIENTOtraUbicacionWidget> {
  late DHCLIENTOtraUbicacionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTOtraUbicacionModel());

    // Se reemplaza la ruta (no se apila) para que el botón de volver del
    // Coverage Check regrese a la pantalla que pidió la ubicación.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.pushReplacementNamed(DHCLIENTUbicacionWidget.routeName);
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: const Center(
        child: DoviaSpinner(),
      ),
    );
  }
}
