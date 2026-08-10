import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_cotizaciones_widget.dart'
    show DHASSOCIATECotizacionesWidget;
import 'package:flutter/material.dart';

class DHASSOCIATECotizacionesModel
    extends FlutterFlowModel<DHASSOCIATECotizacionesWidget> {
  ///  State fields for stateful widgets in this page.

  FocusNode? searchFocusNode;
  TextEditingController? searchController;

  String searchQuery = '';

  /// Filtro "Rubro": id de una de las especialidades **habilitadas** de la
  /// empresa, o null para no filtrar.
  String? categoryId;
  FormFieldController<String>? categoryController;

  /// Filtro "Estatus": null muestra los tres carriles; con un valor elegido se
  /// muestra sólo ese ([kQuoteFilterActive] / [kQuoteFilterSubmitted] /
  /// [kQuoteFilterApproved]).
  String? statusFilter;
  FormFieldController<String>? statusController;

  /// Filtro "Mes", como clave ordenable (`2026-08`) o null para todos.
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
