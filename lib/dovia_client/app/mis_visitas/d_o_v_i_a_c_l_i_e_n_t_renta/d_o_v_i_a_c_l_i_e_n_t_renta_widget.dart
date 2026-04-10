import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_renta_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_renta_model.dart';

class DOVIACLIENTRentaWidget extends StatefulWidget {
  const DOVIACLIENTRentaWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_Renta';
  static String routePath = '/dOVIACLIENTRenta';

  @override
  State<DOVIACLIENTRentaWidget> createState() => _DOVIACLIENTRentaWidgetState();
}

class _DOVIACLIENTRentaWidgetState extends State<DOVIACLIENTRentaWidget> {
  late DOVIACLIENTRentaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTRentaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      ),
    );
  }
}
