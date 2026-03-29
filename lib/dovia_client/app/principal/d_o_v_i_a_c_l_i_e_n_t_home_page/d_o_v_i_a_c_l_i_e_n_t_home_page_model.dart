import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/agregar_favorito_a_carpeta_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/dovia_suupport_messages/dovia_suupport_messages_widget.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_home_page_widget.dart'
    show DOVIACLIENTHomePageWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
