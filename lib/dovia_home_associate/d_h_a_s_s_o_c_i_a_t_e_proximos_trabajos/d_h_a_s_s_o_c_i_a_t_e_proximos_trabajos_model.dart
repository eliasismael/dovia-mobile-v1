import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_proximos_trabajos_widget.dart'
    show DHASSOCIATEProximosTrabajosWidget;
import 'package:flutter/material.dart';

class DHASSOCIATEProximosTrabajosModel
    extends FlutterFlowModel<DHASSOCIATEProximosTrabajosWidget> {
  ///  State fields for stateful widgets in this page.

  FocusNode? searchFocusNode;
  TextEditingController? searchController;

  /// Búsqueda por palabras clave sobre la agenda.
  String searchQuery = '';

  /// Filtro "Tipo de Trabajo". Es el id de catálogo de una de las
  /// **especialidades aprobadas** del asociado, o null para no filtrar. El
  /// desplegable nunca ofrece categorías que no tenga habilitadas.
  String? categoryId;
  FormFieldController<String>? categoryController;

  /// Filtro "Estado del trabajo": null = Todo, true = sólo Urgente
  /// (emergencias), false = sólo Estándar.
  bool? urgentOnly;
  FormFieldController<String>? statusController;

  /// Filtro "Fecha del trabajo", como clave de mes (`2026-08`) o null para
  /// todos los meses. Agrupar por mes es lo que pide el diseño para planificar
  /// a mediano plazo.
  String? monthKey;
  FormFieldController<String>? monthController;

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
    searchFocusNode?.dispose();
    searchController?.dispose();
    dHASSOCIATEHeaderModel.dispose();
    cornerGradientBackgroundModel.dispose();
    fixedDoviaIconModel.dispose();
    dHASSOCIATENavbarModel.dispose();
  }
}
