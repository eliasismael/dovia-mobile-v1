import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_favoritos/favorite_houses_card/favorite_houses_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_favoritos_carpeta_seleccionada_widget.dart'
    show DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DOVIACLIENTMisFavoritosCarpetaSeleccionadaModel
    extends FlutterFlowModel<DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget> {
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
