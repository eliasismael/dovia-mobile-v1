import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_model.dart';

class OPERATIVELISTINGHeaderWidget extends StatefulWidget {
  const OPERATIVELISTINGHeaderWidget({
    super.key,
    required this.titleText,
    this.onLocationTap,
    this.showBack = true,
    this.showLocation = true,
  });

  final String? titleText;
  final VoidCallback? onLocationTap;

  /// En el Home no hay a dónde volver: atrás llevaba al login.
  final bool showBack;

  /// Pantallas sin propiedad asociada no muestran el localizador.
  final bool showLocation;

  @override
  State<OPERATIVELISTINGHeaderWidget> createState() =>
      _OPERATIVELISTINGHeaderWidgetState();
}

class _OPERATIVELISTINGHeaderWidgetState
    extends State<OPERATIVELISTINGHeaderWidget> {
  late OPERATIVELISTINGHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  bool _searchingNextVisit = false;

  /// Próxima visita asignada y en plazo (hasta 24 h después del horario),
  /// con el mismo criterio que "Tus próximas visitas" del Home.
  Future<String?> _nextVisitId() async {
    final res =
        await DOVIAAPIVisitContextGroup.getOperativeListerVisitsCall.call(
      authToken: currentAuthenticationToken ?? '',
      substatus: 'ASSIGNED',
      page: '1',
      limit: '50',
    );
    if (!res.succeeded) return null;
    final raw = getJsonField(res.jsonBody, r'$.data');
    if (raw is! List) return null;

    final limit = DateTime.now().subtract(const Duration(hours: 24));
    String? bestId;
    DateTime? bestSlot;
    for (final v in raw) {
      if (v is! Map) continue;
      final slot = v['confirmedSlot'];
      if (slot is! Map) continue;
      final d = DateTime.tryParse(slot['date']?.toString() ?? '');
      if (d == null) continue;
      final parts = (slot['time']?.toString() ?? '').split(':');
      final at = DateTime(
        d.year,
        d.month,
        d.day,
        int.tryParse(parts[0]) ?? 0,
        parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      );
      if (at.isBefore(limit)) continue;
      if (bestSlot == null || at.isBefore(bestSlot)) {
        bestSlot = at;
        bestId = v['id']?.toString();
      }
    }
    return bestId;
  }

  Future<void> _goToNextVisit() async {
    if (_searchingNextVisit) return;
    _searchingNextVisit = true;
    try {
      final visitId = await _nextVisitId();
      if (!mounted) return;
      if (visitId == null || visitId.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('No tenés una próxima visita asignada.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ));
        return;
      }
      context.pushNamed(
        OPERATIVELISTINGPrimeraVisitaWidget.routeName,
        queryParameters: {
          'visitId': serializeParam(visitId, ParamType.String),
          'isPrimeraVisita': serializeParam(true, ParamType.bool),
        }.withoutNulls,
      );
    } finally {
      _searchingNextVisit = false;
    }
  }

  /// El mismo header que el cliente: volver, logo, título centrado y, a la
  /// derecha, la próxima visita (si la pantalla la muestra), avisos y ajustes
  /// (que salieron de la barra de abajo).
  @override
  Widget build(BuildContext context) {
    return DOVIASHAREDHeaderWidget(
      title: widget.titleText,
      showBack: widget.showBack,
      showCurrency: false,
      showMap: false,
      showSupport: false,
      showNotifications: true,
      showSettings: true,
      extraActions: [
        if (widget.showLocation)
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              if (widget.onLocationTap != null) {
                widget.onLocationTap!();
              } else {
                await _goToNextVisit();
              }
            },
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/images/position.svg',
                width: 8.0,
                height: 8.0,
                fit: BoxFit.none,
              ),
            ),
          ),
      ],
    );
  }
}
