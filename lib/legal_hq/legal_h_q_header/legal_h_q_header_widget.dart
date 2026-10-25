import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'package:flutter/material.dart';
import 'legal_h_q_header_model.dart';
export 'legal_h_q_header_model.dart';

class LegalHQHeaderWidget extends StatefulWidget {
  const LegalHQHeaderWidget({
    super.key,
    required this.text,
    this.showBack = true,
  });

  final String? text;

  /// En el Home no hay pantalla anterior: volver llevaría al login.
  final bool showBack;

  @override
  State<LegalHQHeaderWidget> createState() => _LegalHQHeaderWidgetState();
}

class _LegalHQHeaderWidgetState extends State<LegalHQHeaderWidget> {
  late LegalHQHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LegalHQHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// El mismo header que el cliente: volver (salvo en el inicio), logo,
  /// título centrado y, a la derecha, avisos y ajustes, que salieron de la
  /// barra de abajo. El acceso a Procesos ya está en la barra.
  @override
  Widget build(BuildContext context) {
    return DOVIASHAREDHeaderWidget(
      title: widget.text ?? '',
      showBack: widget.showBack,
      showCurrency: false,
      showMap: false,
      showSupport: false,
      showNotifications: true,
      showSettings: true,
    );
  }
}
