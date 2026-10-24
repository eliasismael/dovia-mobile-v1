import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'package:flutter/material.dart';
import 'legal_associate_header_model.dart';
export 'legal_associate_header_model.dart';

class LegalAssociateHeaderWidget extends StatefulWidget {
  const LegalAssociateHeaderWidget({
    super.key,
    required this.titleText,
  });

  final String? titleText;

  @override
  State<LegalAssociateHeaderWidget> createState() =>
      _LegalAssociateHeaderWidgetState();
}

class _LegalAssociateHeaderWidgetState
    extends State<LegalAssociateHeaderWidget> {
  late LegalAssociateHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LegalAssociateHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// El mismo header que el cliente: volver (salvo en el inicio), logo,
  /// título centrado y, a la derecha, avisos y ajustes, que salieron de la
  /// barra de abajo. Documentos pasó a la barra.
  @override
  Widget build(BuildContext context) {
    String? route;
    try {
      route = GoRouterState.of(context).name;
    } catch (_) {}
    return DOVIASHAREDHeaderWidget(
      title: widget.titleText,
      showBack: route != LegalAssociateHomeWidget.routeName,
      showCurrency: false,
      showMap: false,
      showSupport: false,
      showNotifications: true,
      showSettings: true,
    );
  }
}
