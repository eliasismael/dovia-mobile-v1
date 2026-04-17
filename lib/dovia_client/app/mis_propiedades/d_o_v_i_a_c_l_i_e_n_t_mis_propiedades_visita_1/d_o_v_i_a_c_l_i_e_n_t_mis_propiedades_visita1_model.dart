import 'dart:async';

import '/backend/api_requests/api_calls.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_visita1_widget.dart'
    show DOVIACLIENTMisPropiedadesVisita1Widget;
import 'package:flutter/material.dart';

class DOVIACLIENTMisPropiedadesVisita1Model
    extends FlutterFlowModel<DOVIACLIENTMisPropiedadesVisita1Widget> {
  // ── Loading state ───────────────────────────────────────────────────────
  bool isLoading = false;

  // ── API responses ───────────────────────────────────────────────────────
  ApiCallResponse? visitDetailsResponse;

  // ── Instructions section ────────────────────────────────────────────────
  FocusNode? instructionsFocusNode;
  TextEditingController? instructionsController;
  bool isEditingInstructions = false;
  bool isSavingInstructions = false;

  // ── Contract section ────────────────────────────────────────────────────
  bool contractUploaded = false;
  bool isUploadingContract = false;

  // ── Step 3 polling ──────────────────────────────────────────────────────
  /// Timer that polls visit status while the user is on Step 3.
  Timer? pollingTimer;

  /// Guards against showing the "published" modal more than once.
  bool publishedModalShown = false;

  // ── Sub-component models ────────────────────────────────────────────────
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  late FixedDoviaIconModel fixedDoviaIconModel;
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    fixedDoviaIconModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
    instructionsFocusNode?.dispose();
    instructionsController?.dispose();
  }
}
