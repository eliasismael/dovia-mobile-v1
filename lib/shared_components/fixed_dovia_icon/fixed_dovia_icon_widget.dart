import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/dovia_support/dovia_support_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'fixed_dovia_icon_model.dart';
export 'fixed_dovia_icon_model.dart';

class FixedDoviaIconWidget extends StatefulWidget {
  const FixedDoviaIconWidget({super.key});

  @override
  State<FixedDoviaIconWidget> createState() => _FixedDoviaIconWidgetState();
}

class _FixedDoviaIconWidgetState extends State<FixedDoviaIconWidget> {
  late FixedDoviaIconModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FixedDoviaIconModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: false,
          context: context,
          builder: (context) {
            return Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: DoviaSupportWidget(),
            );
          },
        ).then((value) => safeSetState(() {}));
      },
      child: Container(
        width: 60.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          shape: BoxShape.circle,
        ),
        alignment: AlignmentDirectional(0.0, 0.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0.0),
          child: SvgPicture.asset(
            'assets/images/D-blanca.svg',
            width: 25.0,
            height: 32.0,
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
    );
  }
}
