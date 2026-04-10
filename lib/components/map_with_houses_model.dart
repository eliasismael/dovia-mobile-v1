import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'map_with_houses_widget.dart' show MapWithHousesWidget;
import 'package:flutter/material.dart';

class MapWithHousesModel extends FlutterFlowModel<MapWithHousesWidget> {
  ///  Local state fields for this component.

  List<MapPropertyMarkerStruct> allProperties = [];
  void addToAllProperties(MapPropertyMarkerStruct item) =>
      allProperties.add(item);
  void removeFromAllProperties(MapPropertyMarkerStruct item) =>
      allProperties.remove(item);
  void removeAtIndexFromAllProperties(int index) =>
      allProperties.removeAt(index);
  void insertAtIndexInAllProperties(int index, MapPropertyMarkerStruct item) =>
      allProperties.insert(index, item);
  void updateAllPropertiesAtIndex(
          int index, Function(MapPropertyMarkerStruct) updateFn) =>
      allProperties[index] = updateFn(allProperties[index]);

  List<MapPropertyMarkerStruct> filteredProperties = [];
  void addToFilteredProperties(MapPropertyMarkerStruct item) =>
      filteredProperties.add(item);
  void removeFromFilteredProperties(MapPropertyMarkerStruct item) =>
      filteredProperties.remove(item);
  void removeAtIndexFromFilteredProperties(int index) =>
      filteredProperties.removeAt(index);
  void insertAtIndexInFilteredProperties(
          int index, MapPropertyMarkerStruct item) =>
      filteredProperties.insert(index, item);
  void updateFilteredPropertiesAtIndex(
          int index, Function(MapPropertyMarkerStruct) updateFn) =>
      filteredProperties[index] = updateFn(filteredProperties[index]);

  String? filterType;

  /// "SALE" or "RENT" or ""
  String? filterListing;

  double? filterMinPrice;

  double? filterMaxPricewe;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (Get Properties for Map)] action in MapWithHouses widget.
  ApiCallResponse? apiResultob5;
  // State field(s) for DropDownListing widget.
  String? dropDownListingValue;
  FormFieldController<String>? dropDownListingValueController;
  // State field(s) for DropDownPropertyType widget.
  String? dropDownPropertyTypeValue;
  FormFieldController<String>? dropDownPropertyTypeValueController;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}
