import '/dovia_home_associate/associate_nav.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'package:flutter/material.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_header_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_header_model.dart';

class DHASSOCIATEHeaderWidget extends StatefulWidget {
  const DHASSOCIATEHeaderWidget({
    super.key,
    required this.tittleText,
  });

  final String? tittleText;

  @override
  State<DHASSOCIATEHeaderWidget> createState() =>
      _DHASSOCIATEHeaderWidgetState();
}

class _DHASSOCIATEHeaderWidgetState extends State<DHASSOCIATEHeaderWidget> {
  late DHASSOCIATEHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// El mismo header que el cliente: volver (salvo en el inicio), logo,
  /// título centrado y, a la derecha, avisos y ajustes, que salieron de la
  /// barra de abajo. Servicios y Próximos trabajos pasaron a la barra.
  @override
  Widget build(BuildContext context) {
    String? route;
    try {
      route = GoRouterState.of(context).name;
    } catch (_) {}
    return DOVIASHAREDHeaderWidget(
      title: widget.tittleText ?? '',
      showBack: route != associateHomeRouteName(),
      showCurrency: false,
      showMap: false,
      showSupport: false,
      showNotifications: true,
      showSettings: true,
    );
  }
}
