import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_model.dart';

class OPERATIVELISTINGHeaderWidget extends StatefulWidget {
  const OPERATIVELISTINGHeaderWidget({
    super.key,
    required this.titleText,
    this.showBack = true,
  });

  final String? titleText;

  /// En el Home no hay a dónde volver: atrás llevaba al login.
  final bool showBack;

  @override
  State<OPERATIVELISTINGHeaderWidget> createState() =>
      _OPERATIVELISTINGHeaderWidgetState();
}

class _OPERATIVELISTINGHeaderWidgetState
    extends State<OPERATIVELISTINGHeaderWidget> {
  late OPERATIVELISTINGHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// El mismo header que el cliente: volver, logo, título centrado y, a la
  /// derecha, avisos y ajustes. La próxima visita está en la navbar.
  @override
  Widget build(BuildContext context) {
    return DOVIASHAREDHeaderWidget(
      title: widget.titleText,
      showBack: widget.showBack,
      showCurrency: false,
      showMap: false,
      showSupport: false,
      showNotifications: true,
      showSettings: true,
    );
  }
}
