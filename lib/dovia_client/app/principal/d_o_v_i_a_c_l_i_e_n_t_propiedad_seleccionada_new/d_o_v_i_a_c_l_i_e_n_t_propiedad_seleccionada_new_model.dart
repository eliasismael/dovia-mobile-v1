import '/components/porpiedades_amenidades_widget.dart';
import '/components/propiedad_caracteristicas_widget.dart';
import '/components/propiedades_sobre_el_sector_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_propiedad_seleccionada_new_widget.dart'
    show DOVIACLIENTPropiedadSeleccionadaNewWidget;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DOVIACLIENTPropiedadSeleccionadaNewModel
    extends FlutterFlowModel<DOVIACLIENTPropiedadSeleccionadaNewWidget> {
  ///  Local state fields for this page.

  String ventaORenta = 'venta';

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for Carousel widget.
  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 0;

  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel;
  // Model for PropiedadCaracteristicas component.
  late PropiedadCaracteristicasModel propiedadCaracteristicasModel;
  // Model for PorpiedadesAmenidades component.
  late PorpiedadesAmenidadesModel porpiedadesAmenidadesModel;
  // Model for PropiedadesSobreElSector component.
  late PropiedadesSobreElSectorModel propiedadesSobreElSectorModel;
  // Model for DOVIA_CLIENT_Navbar component.
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
    secondaryButtonModel = createModel(context, () => SecondaryButtonModel());
    propiedadCaracteristicasModel =
        createModel(context, () => PropiedadCaracteristicasModel());
    porpiedadesAmenidadesModel =
        createModel(context, () => PorpiedadesAmenidadesModel());
    propiedadesSobreElSectorModel =
        createModel(context, () => PropiedadesSobreElSectorModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    primaryButtonModel.dispose();
    secondaryButtonModel.dispose();
    propiedadCaracteristicasModel.dispose();
    porpiedadesAmenidadesModel.dispose();
    propiedadesSobreElSectorModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
