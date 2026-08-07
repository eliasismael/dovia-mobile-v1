import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'd_h_c_l_i_e_n_t_materiales_widget.dart' show DHCLIENTMaterialesWidget;
import 'package:flutter/material.dart';

class DHCLIENTMaterialesModel
    extends FlutterFlowModel<DHCLIENTMaterialesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;

  /// True mientras se lee la solicitud de materiales del backend.
  bool isLoading = false;

  /// True cuando la lectura falló: la pantalla avisa en vez de mostrarse vacía
  /// como si el asociado no hubiera pedido nada.
  bool loadFailed = false;

  /// True mientras se aprueba o se rechaza, para que la decisión contraria no
  /// pueda dispararse al mismo tiempo.
  bool isSubmitting = false;

  /// Descripción del material que el Home Associate cargó desde su app.
  String? materialText;

  /// Monto de la cotización de DOVIA, ya formateado en GTQ (Ej: "Q350"). Null
  /// mientras la solicitud siga en `QUOTE_PENDING`: recién con la cotización
  /// cargada hay un monto que mostrar.
  String? estimatedPrice;

  /// Desglose que HQ escribió junto al PDF de la cotización.
  String? quoteDetails;

  /// PDF de la cotización. Es lo que el cliente tiene que leer antes de aceptar
  /// el cobro, así que la pantalla lo ofrece cuando existe.
  String? quoteDocumentUrl;

  /// Fotos que el asociado tomó como evidencia de dónde se usará el material.
  List<String> imageUrls = [];

  /// Estatus de la solicitud de materiales extra. El enum del contrato es
  /// `QUOTE_PENDING | QUOTE_SENT | PAYMENT_PENDING | PAID | REJECTED`; null si
  /// todavía no se leyó.
  String? materialsStatus;

  /// Solicitud de materiales vigente, para las rutas que la piden por id.
  String? extraMaterialsId;

  /// Orden de pago creada al aceptar la cotización. Es la que se reanuda con
  /// `POST /payments/{paymentOrderId}/resume` cuando el checkout queda a medias.
  String? paymentOrderId;

  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DH_CLIENT_Navbar component.
  late DHCLIENTNavbarModel dHCLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dHCLIENTNavbarModel = createModel(context, () => DHCLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    fixedDoviaIconModel.dispose();
    dHCLIENTNavbarModel.dispose();
  }
}
