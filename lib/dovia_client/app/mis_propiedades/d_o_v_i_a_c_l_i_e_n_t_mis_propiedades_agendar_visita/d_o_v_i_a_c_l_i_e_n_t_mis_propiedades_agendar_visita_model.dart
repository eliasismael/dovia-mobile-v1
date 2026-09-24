import '/backend/api_requests/api_calls.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_agendar_visita_widget.dart'
    show DOVIACLIENTMisPropiedadesAgendarVisitaWidget;
import 'package:flutter/material.dart';

class DOVIACLIENTMisPropiedadesAgendarVisitaModel
    extends FlutterFlowModel<DOVIACLIENTMisPropiedadesAgendarVisitaWidget> {
  ///  Local state fields for this page.

  // Selected weekdays: 0=Lun, 1=Mar, 2=Mié, 3=Jue, 4=Vie, 5=Sáb
  Set<int> selectedDays = {};

  // Time range selected by user ("HH:MM" 24h format)
  TimeOfDay? timeFrom;
  TimeOfDay? timeTo;

  // Whether the continue button can be enabled
  bool get canContinue =>
      selectedDays.isNotEmpty &&
      timeFrom != null &&
      timeTo != null &&
      _timeToMinutes(timeTo!) > _timeToMinutes(timeFrom!);

  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // Stores action output result for [Backend Call - API (Create Visit Request)] action.
  ApiCallResponse? apiResCreateVisitRequest;
  // Model for DOVIA_CLIENT_Navbar component.
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
