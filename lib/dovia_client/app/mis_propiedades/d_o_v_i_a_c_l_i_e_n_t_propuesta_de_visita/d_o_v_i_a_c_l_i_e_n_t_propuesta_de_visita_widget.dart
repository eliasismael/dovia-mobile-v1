import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/backend/api_requests/api_visits.dart';
import '/auth/custom_auth/auth_util.dart';
import '/app_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'd_o_v_i_a_c_l_i_e_n_t_propuesta_de_visita_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_propuesta_de_visita_model.dart';

class DOVIACLIENTPropuestaDeVisitaWidget extends StatefulWidget {
  const DOVIACLIENTPropuestaDeVisitaWidget({
    super.key,
    required this.propertyId,
    required this.visitId,
  });

  final String propertyId;
  final String visitId;

  static String routeName = 'DOVIA_CLIENT_PropuestaDeVisita';
  static String routePath = '/dOVIACLIENTPropuestaDeVisita';

  @override
  State<DOVIACLIENTPropuestaDeVisitaWidget> createState() =>
      _DOVIACLIENTPropuestaDeVisitaWidgetState();
}

class _DOVIACLIENTPropuestaDeVisitaWidgetState
    extends State<DOVIACLIENTPropuestaDeVisitaWidget> {
  late DOVIACLIENTPropuestaDeVisitaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  dynamic _visitData;
  List<dynamic> _proposedSlots = [];

  static const Color _primary = Color(0xFF007376);
  static const Color _primaryDark = Color(0xFF00444B);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTPropuestaDeVisitaModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVisitData());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadVisitData() async {
    final res = await DOVIAAPIVisitContextGroup.getVisitDetailsCall.call(
      visitId: widget.visitId,
      authToken: currentAuthenticationToken,
    );

    if (mounted && res.succeeded) {
      final body = res.jsonBody;
      final data = (body is Map && body.containsKey('data')) ? body['data'] : body;
      
      safeSetState(() {
        _visitData = data;
        final visitObj = data is Map ? data['visit'] as Map? : null;
        _proposedSlots = (visitObj?['proposedTimeSlots'] as List?) ?? [];
        _isLoading = false;
      });
    } else {
      if (mounted) safeSetState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  void _solicitarOtraFecha() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: PopupExitoWidget(
          title: 'Solicitud enviada',
          text: 'Se envió la solicitud de cambio de fecha al interesado.',
          continueText: 'Aceptar',
          onContinue: () {
            FFAppState().addToRequestedDateChangesVisits(widget.visitId);
            Navigator.pop(ctx);
            context.pop(); // return to dashboard
          },
        ),
      ),
    );
  }

  Future<void> _aceptarFecha() async {
    if (_model.selectedDateIndex == null) return;
    final slot = _proposedSlots[_model.selectedDateIndex!];
    final date = (slot is Map ? slot['date'] : null)?.toString() ?? '';
    final time = (slot is Map ? slot['time'] : null)?.toString() ?? '';

    // Call OwnerConfirmSlotCall
    final res = await DOVIAAPIVisitContextGroup.ownerConfirmSlotCall.call(
      visitId: widget.visitId,
      authToken: currentAuthenticationToken,
      date: date,
      time: time,
    );

    if (mounted) {
      if (res.succeeded) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black45,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: PopupExitoWidget(
              title: 'Visita Confirmada',
              text: 'La visita ha sido confirmada y se asignará a un asesor Showing.',
              continueText: 'Aceptar',
              onContinue: () {
                Navigator.pop(ctx);
                context.pop(); // return to dashboard
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al confirmar la visita.'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              children: [
                wrapWithModel(
                  model: _model.dOVIASHAREDHeaderModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const DOVIASHAREDHeaderWidget(
                    title: 'Propuesta de visita',
                    showMap: false,
                    showCurrency: false,
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: _primary))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (FFAppState().requestedDateChangesVisits.contains(widget.visitId))
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF81C784)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: Color(0xFF388E3C), size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Ya has solicitado un cambio de fecha para esta visita. Estamos esperando la respuesta del interesado.',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: const Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                'El interesado propuso estas fechas para visitar tu propiedad. Selecciona una o solicita otras fechas:',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText),
                              ),
                              const SizedBox(height: 20),
                              if (_proposedSlots.isEmpty)
                                Text('No hay fechas propuestas disponibles.',
                                    style: GoogleFonts.inter(fontSize: 14))
                              else
                                ..._proposedSlots.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final slot = entry.value;
                                  final date = _formatDate(
                                      (slot is Map ? slot['date'] : null)?.toString() ?? '');
                                  final time = (slot is Map ? slot['time'] : null)?.toString() ?? '';
                                  final isSelected =
                                      _model.selectedDateIndex == idx;

                                  return GestureDetector(
                                    onTap: () {
                                      safeSetState(() {
                                        _model.selectedDateIndex = idx;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _primary
                                            : FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? _primary
                                              : const Color(0x4D9E9E9E),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Opción ${idx + 1}',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: isSelected
                                                        ? Colors.white70
                                                        : _primaryDark,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '$date • $time hrs',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade400,
                                                width: 2,
                                              ),
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.transparent,
                                            ),
                                            child: isSelected
                                                ? const Icon(Icons.check,
                                                    size: 16, color: _primary)
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              if (_model.selectedDateIndex != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFF007376)),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey.shade300,
                                          image: const DecorationImage(
                                            image: NetworkImage(
                                                'https://ui-avatars.com/api/?name=Showing&background=random'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE5F1F1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          'Showing',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Se asignará un asesor', // Placeholder
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _primaryDark,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Nuestro equipo de HQ te contactará para:\n'
                                          '• Revisar y completar la información inicial.\n'
                                          '• Resolver cualquier duda que tengas.\n'
                                          '• Acompañarte durante todo el proceso de publicación y venta.',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: _primaryDark,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                              if (!FFAppState().requestedDateChangesVisits.contains(widget.visitId)) ...[
                                // Botón Secundario: Solicitar otra fecha
                                OutlinedButton(
                                  onPressed: _solicitarOtraFecha,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    side: const BorderSide(
                                        color: _primary, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                  ),
                                  child: Text(
                                    'Solicitar otra fecha para la visita',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Botón Primario: Aceptar y enviar notificación
                                ElevatedButton(
                                  onPressed: _model.selectedDateIndex != null
                                      ? _aceptarFecha
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    disabledBackgroundColor: Colors.grey.shade300,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Aceptar y enviar notificación',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
