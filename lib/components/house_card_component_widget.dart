import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/auth/custom_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'house_card_component_model.dart';
export 'house_card_component_model.dart';

class HouseCardComponentWidget extends StatefulWidget {
  const HouseCardComponentWidget({
    super.key,
    required this.propertyId,
    required this.name,
    required this.price,
    required this.listingType,
    required this.landArea,
    required this.isFavorite,
  });

  final String? propertyId;
  final String? name;
  final double? price;
  final String? listingType;
  final double? landArea;
  final bool? isFavorite;

  @override
  State<HouseCardComponentWidget> createState() =>
      _HouseCardComponentWidgetState();
}

class _HouseCardComponentWidgetState extends State<HouseCardComponentWidget> {
  late HouseCardComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HouseCardComponentModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).tertiary,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: 250.0,
            child: custom_widgets.DoviaClientHouseCard(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: 250.0,
              imageUrl:
                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/kbm95ashhb4z/casa_card_sobreMiVisita.png',
              isFavorite: widget.isFavorite,
              propertyId: widget.propertyId,
              authToken: currentAuthenticationToken,
              name: widget.name,
              type: widget.listingType,
              price: widget.price?.toString(),
              onAddToFavorites: () async {
                await DOVIAAPIFavoriteContextGroup.addPropertyToFavoritesCall.call(
                  authToken: currentAuthenticationToken,
                  propertyId: widget.propertyId,
                  folderId: '',
                );
                await showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  enableDrag: false,
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: TusFavoritosCarpetasModalWidget(
                          isCreatingNewFolderPARAM: false,
                          houseId: widget.propertyId,
                          propertyName: widget.name,
                          propertyImage: '',
                          propertyIsFavorite: false,
                        ),
                      ),
                    );
                  },
                ).then((value) => safeSetState(() {}));
              },
              onRemoveFromFavorites: () async {
                await showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  enableDrag: false,
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: TusFavoritosCarpetasModalWidget(
                          isCreatingNewFolderPARAM: false,
                          houseId: widget.propertyId,
                          propertyName: widget.name,
                          propertyImage: '',
                          propertyIsFavorite: true,
                        ),
                      ),
                    );
                  },
                ).then((value) => safeSetState(() {}));
              },
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
            child: wrapWithModel(
              model: _model.primaryButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: PrimaryButtonWidget(
                text: 'Ver propiedad',
                onTap: () async {
                  context.pushNamed(
                    DOVIACLIENTPropiedadSeleccionadaNewWidget.routeName,
                    queryParameters: {
                      'propertyId': serializeParam(
                        widget.propertyId,
                        ParamType.String,
                      ),
                    }.withoutNulls,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
