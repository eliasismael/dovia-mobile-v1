import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_favoritos/favorite_houses_card/favorite_houses_card_widget.dart';
import '/dovia_client/app/mis_propiedades/mis_propiedades_house_card/mis_propiedades_house_card_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_widget.dart'
    show DOVIACLIENTMisPropiedadesWidget;
import 'package:flutter/material.dart';

class DOVIACLIENTMisPropiedadesModel
    extends FlutterFlowModel<DOVIACLIENTMisPropiedadesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // Stores action output result for [Backend Call - API (Add Property to Favorites)] action in DoviaClientHouseCard widget.
  ApiCallResponse? apiResultj56;
  // Stores action output result for [Backend Call - API (Remove Property from Favorites)] action in DoviaClientHouseCard widget.
  ApiCallResponse? apiResultyna;
  // Model for FavoriteHousesCard component.
  late FavoriteHousesCardModel favoriteHousesCardModel;
  // Model for MisPropiedades_HouseCard component.
  late MisPropiedadesHouseCardModel misPropiedadesHouseCardModel;
  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DOVIA_CLIENT_Navbar component.
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    favoriteHousesCardModel =
        createModel(context, () => FavoriteHousesCardModel());
    misPropiedadesHouseCardModel =
        createModel(context, () => MisPropiedadesHouseCardModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    favoriteHousesCardModel.dispose();
    misPropiedadesHouseCardModel.dispose();
    fixedDoviaIconModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
