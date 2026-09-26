import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
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
    this.imageUrl,
    this.propertyType,
    this.bedrooms,
    this.bathrooms,
    this.constructionArea,
  });

  final String? propertyId;
  final String? name;
  final double? price;
  final String? listingType;
  final double? landArea;
  final bool? isFavorite;
  final String? imageUrl;
  final String? propertyType;
  final int? bedrooms;
  final int? bathrooms;
  final int? constructionArea;

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
      width: double.infinity,
      // Se abre desde abajo: el contenido termina sobre los botones de Android.
      padding: EdgeInsets.fromLTRB(
          20.0, 12.0, 20.0, MediaQuery.viewPaddingOf(context).bottom + 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24.0,
            offset: Offset(0.0, -4.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40.0,
            height: 4.0,
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFDFDFDF),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: custom_widgets.DoviaClientHouseCard(
              width: double.infinity,
              height: 0.0,
              // La foto real que ya trae el mapa; la default sólo si no hay.
              imageUrl: widget.imageUrl ?? '',
              propertyType: widget.propertyType,
              bedrooms: widget.bedrooms,
              bathrooms: widget.bathrooms,
              constructionArea: widget.constructionArea,
              landArea: widget.landArea,
              isFavorite: widget.isFavorite,
              propertyId: widget.propertyId,
              authToken: currentAuthenticationToken,
              name: widget.name,
              type: widget.listingType,
              price: widget.price?.toString(),
              onAddToFavorites: () async {
                await DOVIAAPIFavoriteContextGroup.addPropertyToFavoritesCall
                    .call(
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
                          propertyImage: widget.imageUrl ?? '',
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
                          propertyImage: widget.imageUrl ?? '',
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
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
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
                      'initialImageUrl': serializeParam(
                        widget.imageUrl,
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
