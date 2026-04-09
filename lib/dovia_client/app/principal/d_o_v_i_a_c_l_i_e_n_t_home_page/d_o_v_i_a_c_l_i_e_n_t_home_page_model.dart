import '/backend/api_requests/api_calls.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_home_page_widget.dart'
    show DOVIACLIENTHomePageWidget;
import 'package:flutter/material.dart';

class DOVIACLIENTHomePageModel
    extends FlutterFlowModel<DOVIACLIENTHomePageWidget> {
  ///  Local state fields for this page.

  String comprarORentar = 'comprar';

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
  // Stores action output result for [Backend Call - API (Remove Property from Favorites)] action in DoviaClientHouseCard widget.
  ApiCallResponse? apiResult2;
  // Stores action output result for [Backend Call - API (Add Property to Favorites)] action in DoviaClientHouseCard widget.
  ApiCallResponse? addFavoriteNew;
  // Stores action output result for [Backend Call - API (Remove Property from Favorites)] action in DoviaClientHouseCard widget.
  ApiCallResponse? apiResult4;
  // Stores action output result for [Backend Call - API (Add Property to Favorites)] action in DoviaClientHouseCard widget.
  ApiCallResponse? addFvoriteRecommended;
  // Stores action output result for [Backend Call - API (Remove Property from Favorites)] action in DoviaClientHouseCard widget.
  ApiCallResponse? apiResult6;
  // Stores action output result for [Backend Call - API (Add Property to Favorites)] action in DoviaClientHouseCard widget.
  ApiCallResponse? addFavoriteViewedRecently;
  // Model for DOVIA_CLIENT_Navbar component.
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    dOVIACLIENTNavbarModel.dispose();
  }
}
