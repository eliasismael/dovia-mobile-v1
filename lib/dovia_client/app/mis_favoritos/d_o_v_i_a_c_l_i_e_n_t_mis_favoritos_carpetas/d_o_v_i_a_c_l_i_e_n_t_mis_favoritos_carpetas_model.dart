import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_favoritos_carpetas_widget.dart'
    show DOVIACLIENTMisFavoritosCarpetasWidget;
import 'package:flutter/material.dart';

class DOVIACLIENTMisFavoritosCarpetasModel
    extends FlutterFlowModel<DOVIACLIENTMisFavoritosCarpetasWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;

  @override
  void initState(BuildContext context) {
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
  }

  @override
  void dispose() {
    fixedDoviaIconModel.dispose();
  }
}
