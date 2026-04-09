import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_notification_card/d_h_a_s_s_o_c_i_a_t_e_notification_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_notificaciones_widget.dart'
    show DHASSOCIATENotificacionesWidget;
import 'package:flutter/material.dart';

class DHASSOCIATENotificacionesModel
    extends FlutterFlowModel<DHASSOCIATENotificacionesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DH_ASSOCIATE_Header component.
  late DHASSOCIATEHeaderModel dHASSOCIATEHeaderModel;
  // Model for DH_ASSOCIATE_NotificationCard component.
  late DHASSOCIATENotificationCardModel dHASSOCIATENotificationCardModel1;
  // Model for DH_ASSOCIATE_NotificationCard component.
  late DHASSOCIATENotificationCardModel dHASSOCIATENotificationCardModel2;
  // Model for DH_ASSOCIATE_NotificationCard component.
  late DHASSOCIATENotificationCardModel dHASSOCIATENotificationCardModel3;
  // Model for DH_ASSOCIATE_NotificationCard component.
  late DHASSOCIATENotificationCardModel dHASSOCIATENotificationCardModel4;
  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DH_ASSOCIATE_Navbar component.
  late DHASSOCIATENavbarModel dHASSOCIATENavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dHASSOCIATEHeaderModel =
        createModel(context, () => DHASSOCIATEHeaderModel());
    dHASSOCIATENotificationCardModel1 =
        createModel(context, () => DHASSOCIATENotificationCardModel());
    dHASSOCIATENotificationCardModel2 =
        createModel(context, () => DHASSOCIATENotificationCardModel());
    dHASSOCIATENotificationCardModel3 =
        createModel(context, () => DHASSOCIATENotificationCardModel());
    dHASSOCIATENotificationCardModel4 =
        createModel(context, () => DHASSOCIATENotificationCardModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dHASSOCIATENavbarModel =
        createModel(context, () => DHASSOCIATENavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dHASSOCIATEHeaderModel.dispose();
    dHASSOCIATENotificationCardModel1.dispose();
    dHASSOCIATENotificationCardModel2.dispose();
    dHASSOCIATENotificationCardModel3.dispose();
    dHASSOCIATENotificationCardModel4.dispose();
    fixedDoviaIconModel.dispose();
    dHASSOCIATENavbarModel.dispose();
  }
}
