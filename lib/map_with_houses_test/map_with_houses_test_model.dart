import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/components/map_with_houses_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'map_with_houses_test_widget.dart' show MapWithHousesTestWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MapWithHousesTestModel extends FlutterFlowModel<MapWithHousesTestWidget> {
  ///  Local state fields for this page.

  List<MapPropertyMarkerStruct> dataFotMap = [];
  void addToDataFotMap(MapPropertyMarkerStruct item) => dataFotMap.add(item);
  void removeFromDataFotMap(MapPropertyMarkerStruct item) =>
      dataFotMap.remove(item);
  void removeAtIndexFromDataFotMap(int index) => dataFotMap.removeAt(index);
  void insertAtIndexInDataFotMap(int index, MapPropertyMarkerStruct item) =>
      dataFotMap.insert(index, item);
  void updateDataFotMapAtIndex(
          int index, Function(MapPropertyMarkerStruct) updateFn) =>
      dataFotMap[index] = updateFn(dataFotMap[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Get Properties for Map)] action in MapWithHousesTest widget.
  ApiCallResponse? apiResultob5;
  // Model for MapWithHouses component.
  late MapWithHousesModel mapWithHousesModel;

  @override
  void initState(BuildContext context) {
    mapWithHousesModel = createModel(context, () => MapWithHousesModel());
  }

  @override
  void dispose() {
    mapWithHousesModel.dispose();
  }
}
