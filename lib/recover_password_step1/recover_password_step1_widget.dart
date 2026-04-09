import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'recover_password_step1_model.dart';
export 'recover_password_step1_model.dart';

class RecoverPasswordStep1Widget extends StatefulWidget {
  const RecoverPasswordStep1Widget({super.key});

  static String routeName = 'RecoverPasswordStep1';
  static String routePath = '/recoverPasswordStep1';

  @override
  State<RecoverPasswordStep1Widget> createState() =>
      _RecoverPasswordStep1WidgetState();
}

class _RecoverPasswordStep1WidgetState
    extends State<RecoverPasswordStep1Widget> {
  late RecoverPasswordStep1Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecoverPasswordStep1Model());

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
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: MediaQuery.sizeOf(context).height * 1.0,
            child: custom_widgets.CustomRecoverPassword1(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
