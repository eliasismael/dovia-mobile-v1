import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_acciones_a_realizar_widget.dart'
    show DOVIACLIENTMisPropiedadesAccionesARealizarWidget;
import 'package:flutter/material.dart';

class DOVIACLIENTMisPropiedadesAccionesARealizarModel
    extends FlutterFlowModel<DOVIACLIENTMisPropiedadesAccionesARealizarWidget> {
  ///  Local state fields for this page.

  bool isSaleSelected = false;

  bool isRentSelected = false;

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel1;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel1;
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel2;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel2;
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel3;
  // Model for DOVIA_CLIENT_Navbar component.
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    primaryButtonModel1 = createModel(context, () => PrimaryButtonModel());
    secondaryButtonModel1 = createModel(context, () => SecondaryButtonModel());
    primaryButtonModel2 = createModel(context, () => PrimaryButtonModel());
    secondaryButtonModel2 = createModel(context, () => SecondaryButtonModel());
    primaryButtonModel3 = createModel(context, () => PrimaryButtonModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    primaryButtonModel1.dispose();
    secondaryButtonModel1.dispose();
    primaryButtonModel2.dispose();
    secondaryButtonModel2.dispose();
    primaryButtonModel3.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
