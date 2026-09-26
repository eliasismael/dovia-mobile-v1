import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_c_l_i_e_n_t_proximas_visitas_model.dart';
export 'd_h_c_l_i_e_n_t_proximas_visitas_model.dart';

class DHCLIENTProximasVisitasWidget extends StatefulWidget {
  const DHCLIENTProximasVisitasWidget({
    super.key,
    this.title,
    this.date,
    this.icom,
    this.status,
    this.showRedDot = false,
    this.isEmergency = false,
  });

  final String? title;
  final String? date;
  final String? icom;
  final bool showRedDot;

  /// Solicitud de emergencia: muestra un indicador de alta prioridad.
  final bool isEmergency;

  /// Estatus de la solicitud (Ej: "Pendiente"). Si es null no se muestra.
  final String? status;

  @override
  State<DHCLIENTProximasVisitasWidget> createState() =>
      _DHCLIENTProximasVisitasWidgetState();
}

class _DHCLIENTProximasVisitasWidgetState
    extends State<DHCLIENTProximasVisitasWidget> {
  late DHCLIENTProximasVisitasModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTProximasVisitasModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// Color de fondo de la píldora de estatus según el label.
  /// - "Confirmar" / "Reportado" → rojo
  /// - "Finalizada" → verde
  /// - "Pendiente" (nadie tomó el trabajo) → naranja/salmón (diseño)
  /// - resto (p. ej. "Programada") → ámbar
  Color get _pillBackgroundColor {
    switch (widget.status) {
      case 'Confirmar':
      case 'Reportado':
        return const Color(0xFFFFE5E5);
      case 'Finalizada':
        return const Color(0xFFDCF5E3);
      case 'Pendiente':
        return const Color(0xFFFFE3D2);
      case 'Pago pendiente':
        return const Color(0xFFFFE5E5);
      default:
        return const Color(0xFFFDECC8);
    }
  }

  Color get _pillTextColor {
    switch (widget.status) {
      case 'Confirmar':
      case 'Reportado':
        return Colors.red;
      case 'Finalizada':
        return const Color(0xFF1E7A46);
      case 'Pendiente':
        return const Color(0xFFC2410C);
      case 'Pago pendiente':
        return const Color(0xFFB42318);
      default:
        return const Color(0xFF9A6700);
    }
  }

  /// Ícono del servicio en blanco sobre el verde oscuro de Dovia. Sin
  /// ícono propio (cotización u otro servicio) se usa uno genérico.
  Widget _buildIcon() {
    final asset = widget.icom ??
        (widget.title == 'Solicitud de cotización'
            ? 'quote'
            : 'assets/images/IconoCaja.svg');
    final Widget icon;
    if (asset == 'quote') {
      icon = const Icon(Icons.request_quote_outlined,
          color: Colors.white, size: 24.0);
    } else if (asset.endsWith('IconoCaja.svg')) {
      icon = const Icon(Icons.home_repair_service_outlined,
          color: Colors.white, size: 24.0);
    } else {
      icon = SvgPicture.asset(
        asset,
        width: 24.0,
        height: 24.0,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    }
    return Container(
      width: 48.0,
      height: 48.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF007376),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: icon,
    );
  }

  Widget _buildStatusPill() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showRedDot)
          Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.only(right: 6.0),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        Flexible(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: _pillBackgroundColor,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Text(
              widget.status!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w600,
                color: _pillTextColor,
                fontSize: 11.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Título, fecha y estatus apilados a la derecha del ícono: el estatus ya
    // no le quita ancho al texto y los títulos largos no se parten en tres.
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10.0,
            offset: Offset(0.0, 3.0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title ?? 'Servicio',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.publicSans(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                    if (widget.isEmergency) ...[
                      const SizedBox(width: 6.0),
                      const Icon(Icons.priority_high_rounded,
                          color: Colors.red, size: 16.0),
                    ],
                  ],
                ),
                const SizedBox(height: 3.0),
                Text(
                  widget.date ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
                if (widget.status != null) ...[
                  const SizedBox(height: 8.0),
                  _buildStatusPill(),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6.0),
          Icon(Icons.chevron_right_rounded,
              color: FlutterFlowTheme.of(context).secondaryText, size: 22.0),
        ],
      ),
    );
  }
}
