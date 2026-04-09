import '/components/map_with_houses_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_home_page2_mapa_widget.dart'
    show DOVIACLIENTHomePage2MapaWidget;
import 'package:flutter/material.dart';

class DOVIACLIENTHomePage2MapaModel
    extends FlutterFlowModel<DOVIACLIENTHomePage2MapaWidget> {
  ///  Local state fields for this page.

  bool isFilterModalVisible = false;

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for MapWithHouses component.
  late MapWithHousesModel mapWithHousesModel;
  // Model for DOVIA_CLIENT_Navbar component.
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    mapWithHousesModel = createModel(context, () => MapWithHousesModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    mapWithHousesModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
