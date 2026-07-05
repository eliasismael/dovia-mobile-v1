import '/components/porpiedades_amenidades_widget.dart';
import '/components/propiedad_caracteristicas_widget.dart';
import '/components/propiedades_sobre_el_sector_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import 's_h_o_w_i_n_g_propiedad_detalle_widget.dart'
    show SHOWINGPropiedadDetalleWidget;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class SHOWINGPropiedadDetalleModel
    extends FlutterFlowModel<SHOWINGPropiedadDetalleWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for SHOWING_Header component.
  late SHOWINGHeaderModel sHOWINGHeaderModel;
  // State field(s) for Carousel widget.
  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 0;
  // Model for PropiedadCaracteristicas component.
  late PropiedadCaracteristicasModel propiedadCaracteristicasModel;
  // Model for PorpiedadesAmenidades component.
  late PorpiedadesAmenidadesModel porpiedadesAmenidadesModel;
  // Model for PropiedadesSobreElSector component.
  late PropiedadesSobreElSectorModel propiedadesSobreElSectorModel;
  // Model for SHOWING_Navbar component.
  late SHOWINGNavbarModel sHOWINGNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    sHOWINGHeaderModel = createModel(context, () => SHOWINGHeaderModel());
    propiedadCaracteristicasModel =
        createModel(context, () => PropiedadCaracteristicasModel());
    porpiedadesAmenidadesModel =
        createModel(context, () => PorpiedadesAmenidadesModel());
    propiedadesSobreElSectorModel =
        createModel(context, () => PropiedadesSobreElSectorModel());
    sHOWINGNavbarModel = createModel(context, () => SHOWINGNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    sHOWINGHeaderModel.dispose();
    propiedadCaracteristicasModel.dispose();
    porpiedadesAmenidadesModel.dispose();
    propiedadesSobreElSectorModel.dispose();
    sHOWINGNavbarModel.dispose();
  }
}
