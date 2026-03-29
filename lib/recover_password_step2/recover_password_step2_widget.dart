import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'recover_password_step2_model.dart';
export 'recover_password_step2_model.dart';

class RecoverPasswordStep2Widget extends StatefulWidget {
  const RecoverPasswordStep2Widget({
    super.key,
    required this.email,
  });

  final String? email;

  static String routeName = 'RecoverPasswordStep2';
  static String routePath = '/recoverPasswordStep2';

  @override
  State<RecoverPasswordStep2Widget> createState() =>
      _RecoverPasswordStep2WidgetState();
}

class _RecoverPasswordStep2WidgetState
    extends State<RecoverPasswordStep2Widget> {
  late RecoverPasswordStep2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecoverPasswordStep2Model());

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
        body: SafeArea(
          top: true,
          child: Container(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: MediaQuery.sizeOf(context).height * 1.0,
            child: custom_widgets.CustomRecoverPassword2(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
              email: widget!.email,
            ),
          ),
        ),
      ),
    );
  }
}
