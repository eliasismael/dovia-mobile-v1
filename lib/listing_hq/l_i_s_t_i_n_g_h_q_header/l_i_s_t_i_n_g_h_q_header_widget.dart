import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'package:flutter/material.dart';
import 'l_i_s_t_i_n_g_h_q_header_model.dart';
export 'l_i_s_t_i_n_g_h_q_header_model.dart';

class LISTINGHQHeaderWidget extends StatefulWidget {
  const LISTINGHQHeaderWidget({
    super.key,
    required this.titleText,
    this.showBack = true,
  });

  final String? titleText;

  /// En el home no hay a dónde volver: se oculta la flecha.
  final bool showBack;

  @override
  State<LISTINGHQHeaderWidget> createState() => _LISTINGHQHeaderWidgetState();
}

class _LISTINGHQHeaderWidgetState extends State<LISTINGHQHeaderWidget> {
  late LISTINGHQHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// El mismo header que el cliente: volver, logo, título centrado y, a la
  /// derecha, avisos y ajustes (que salieron de la barra de abajo).
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
