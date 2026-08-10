import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_trabajo_realizado_widget.dart'
    show DHASSOCIATETrabajoRealizadoWidget;
import 'package:flutter/material.dart';

class DHASSOCIATETrabajoRealizadoModel
    extends FlutterFlowModel<DHASSOCIATETrabajoRealizadoWidget> {
  ///  State fields for stateful widgets in this page.

  /// Trabajo a mostrar. Nace con lo que inyecta la tarjeta de "Trabajos
  /// terminados" (un item del listado, que es un resumen) y se completa con el
  /// detalle del servicio.
  Map<String, dynamic>? requestData;

  /// El detalle todavía se está leyendo.
  bool isLoading = false;

  /// El detalle no se pudo leer. Importa para no confundir "el cliente no
  /// calificó" con "no pudimos traer la calificación".
  bool loadFailed = false;

  /// El detalle ya se leyó bien: recién ahí la pantalla puede afirmar que algo
  /// no existe (evidencia, calificación, comentario).
  bool detailLoaded = false;

  // Model for DH_ASSOCIATE_Header component.
  late DHASSOCIATEHeaderModel dHASSOCIATEHeaderModel;
  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DH_ASSOCIATE_Navbar component.
  late DHASSOCIATENavbarModel dHASSOCIATENavbarModel;

  @override
  void initState(BuildContext context) {
    dHASSOCIATEHeaderModel =
        createModel(context, () => DHASSOCIATEHeaderModel());
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dHASSOCIATENavbarModel =
        createModel(context, () => DHASSOCIATENavbarModel());
  }

  @override
  void dispose() {
    dHASSOCIATEHeaderModel.dispose();
    cornerGradientBackgroundModel.dispose();
    fixedDoviaIconModel.dispose();
    dHASSOCIATENavbarModel.dispose();
  }
}
