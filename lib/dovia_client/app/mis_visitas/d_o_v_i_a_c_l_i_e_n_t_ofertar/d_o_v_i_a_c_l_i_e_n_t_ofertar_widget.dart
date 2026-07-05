import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_ofertar_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_ofertar_model.dart';

class DOVIACLIENTOfertarWidget extends StatefulWidget {
  const DOVIACLIENTOfertarWidget({
    super.key,
    required this.propertyId,
  });

  final String? propertyId;

  static String routeName = 'DOVIA_CLIENT_Ofertar';
  static String routePath = '/dOVIACLIENTOfertar';

  @override
  State<DOVIACLIENTOfertarWidget> createState() =>
      _DOVIACLIENTOfertarWidgetState();
}

class _DOVIACLIENTOfertarWidgetState extends State<DOVIACLIENTOfertarWidget> {
  late DOVIACLIENTOfertarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _selectVenta = false;
  bool _selectRenta = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTOfertarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _onContinuar() {
    if (!_selectVenta && !_selectRenta) return;

    String offerType;
    bool isAmbosFlow = false;
    if (_selectVenta && _selectRenta) {
      offerType = 'compra';
      isAmbosFlow = true;
    } else if (_selectVenta) {
      offerType = 'compra';
    } else {
      offerType = 'renta';
    }

    context.pushNamed(
      DOVIACLIENTOfertaCompraWidget.routeName,
      queryParameters: {
        'propertyId': serializeParam(widget.propertyId, ParamType.String),
        'offerType': serializeParam(offerType, ParamType.String),
        'fromSelectionScreen': serializeParam(true, ParamType.bool),
        'isAmbosFlow': serializeParam(isAmbosFlow, ParamType.bool),
      }.withoutNulls,
    );
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
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIASHAREDHeaderWidget(
                      title: 'Ofertar',
                      hideActions: true,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          24.0, 40.0, 24.0, 40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Qué te gustaría hacer?',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Puedes seleccionar una o ambas opciones.',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 32),
                          _ToggleOptionButton(
                            label: 'Venta',
                            selected: _selectVenta,
                            onTap: () => safeSetState(
                                () => _selectVenta = !_selectVenta),
                          ),
                          const SizedBox(height: 16),
                          _ToggleOptionButton(
                            label: 'Renta',
                            selected: _selectRenta,
                            onTap: () => safeSetState(
                                () => _selectRenta = !_selectRenta),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (_selectVenta || _selectRenta)
                                  ? _onContinuar
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    FlutterFlowTheme.of(context).primary,
                                disabledBackgroundColor:
                                    FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.4),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: Text(
                                'Continuar',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleOptionButton extends StatelessWidget {
  const _ToggleOptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: selected
              ? FlutterFlowTheme.of(context).primary.withOpacity(0.08)
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? FlutterFlowTheme.of(context).primary
                : const Color(0xFFDDDDDD),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    color: selected
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).primaryText,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    letterSpacing: 0.0,
                  ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? FlutterFlowTheme.of(context).primary
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? FlutterFlowTheme.of(context).primary
                      : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
