import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/components/map_with_houses_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'map_with_houses_test_model.dart';
export 'map_with_houses_test_model.dart';

class MapWithHousesTestWidget extends StatefulWidget {
  const MapWithHousesTestWidget({super.key});

  static String routeName = 'MapWithHousesTest';
  static String routePath = '/mapWithHousesTest';

  @override
  State<MapWithHousesTestWidget> createState() =>
      _MapWithHousesTestWidgetState();
}

class _MapWithHousesTestWidgetState extends State<MapWithHousesTestWidget> {
  late MapWithHousesTestModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MapWithHousesTestModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.apiResultob5 =
          await DOVIAAPIPropertyContextGroup.getPropertiesForMapCall.call();

      if ((_model.apiResultob5?.succeeded ?? true)) {
        _model.dataFotMap = functions
            .parseMapMarkers((_model.apiResultob5?.jsonBody ?? ''))
            .toList()
            .cast<MapPropertyMarkerStruct>();
        safeSetState(() {});
        await showDialog(
          context: context,
          builder: (alertDialogContext) {
            return AlertDialog(
              content: Text(
                  (_model.dataFotMap.take(2).toList().isNotEmpty).toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(alertDialogContext),
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      } else {
        await showDialog(
          context: context,
          builder: (alertDialogContext) {
            return AlertDialog(
              title: const Text('err'),
              content: Text((_model.apiResultob5?.jsonBody ?? '').toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(alertDialogContext),
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      }
    });

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
          child: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: wrapWithModel(
              model: _model.mapWithHousesModel,
              updateCallback: () => safeSetState(() {}),
              child: const MapWithHousesWidget(),
            ),
          ),
        ),
      ),
    );
  }
}
