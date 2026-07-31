import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_home_page_widget.dart'
    show DHASSOCIATEHomePageWidget;
import 'package:flutter/material.dart';

class DHASSOCIATEHomePageModel
    extends FlutterFlowModel<DHASSOCIATEHomePageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for the "Búsqueda con IA" TextField.
  FocusNode? searchFocusNode;
  TextEditingController? searchController;

  /// Texto de búsqueda aplicado a los dos feeds de trabajos.
  String searchQuery = '';

  /// Categoría seleccionada en el carrusel de filtros rápidos. Null = todas.
  String? selectedCategoryId;

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DH_ASSOCIATE_Navbar component.
  late DHASSOCIATENavbarModel dHASSOCIATENavbarModel;

  @override
  void initState(BuildContext context) {
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
    cornerGradientBackgroundModel.dispose();
    fixedDoviaIconModel.dispose();
    dHASSOCIATENavbarModel.dispose();
  }
}
