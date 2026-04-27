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

import 'd_o_v_i_a_c_l_i_e_n_t_visita_aceptada_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_visita_aceptada_model.dart';

class DOVIACLIENTVisitaAceptadaWidget extends StatefulWidget {
  const DOVIACLIENTVisitaAceptadaWidget({
    super.key,
    required this.propertyId,
    required this.visitId,
  });

  final String propertyId;
  final String visitId;

  static String routeName = 'DOVIA_CLIENT_VisitaAceptada';
  static String routePath = '/dOVIACLIENTVisitaAceptada';

  @override
  State<DOVIACLIENTVisitaAceptadaWidget> createState() =>
      _DOVIACLIENTVisitaAceptadaWidgetState();
}

class _DOVIACLIENTVisitaAceptadaWidgetState
    extends State<DOVIACLIENTVisitaAceptadaWidget> {
  late DOVIACLIENTVisitaAceptadaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  dynamic _visitData;
  List<dynamic> _proposedSlots = [];
  dynamic _confirmedSlot;
  dynamic _showingAgent;

  static const Color _primary = Color(0xFF007376);
  static const Color _primaryDark = Color(0xFF00444B);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTVisitaAceptadaModel());
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
      final visitObj = data is Map ? data['visit'] as Map? : null;
      
      safeSetState(() {
        _visitData = data;
        _proposedSlots = (visitObj?['proposedTimeSlots'] as List?) ?? [];
        // Match JSON field 'confirmedTimeSlot'
        _confirmedSlot = visitObj?['confirmedTimeSlot'] ?? visitObj?['confirmedSlot'];
        // Match JSON path data['showing']
        _showingAgent = data?['showing'] ?? visitObj?['showingAgent'] ?? visitObj?['advisor'];
        _isLoading = false;
      });
      debugPrint('[VisitaAceptada] visitObj: $visitObj');
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

  bool _isConfirmed(dynamic slot) {
    if (_confirmedSlot == null || slot == null) return false;
    return slot['date'] == _confirmedSlot['date'] && slot['time'] == _confirmedSlot['time'];
  }

  Future<void> _enviarNotificacion() async {
    final res = await DOVIAAPIVisitContextGroup.notifyVisitReminderCall.call(
      visitId: widget.visitId,
      authToken: currentAuthenticationToken,
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
              title: 'Éxito',
              text: 'Se envió con éxito. Se envió un recordatorio al interesado y al agente Showing.',
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
            content: Text('Error al enviar la notificación.'),
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
                  child: DOVIASHAREDHeaderWidget(
                    title: 'Visita aceptada',
                    showMap: false,
                    showCurrency: false,
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: _primary))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Fecha elegida',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_proposedSlots.isEmpty && _confirmedSlot != null)
                                _slotCard(_confirmedSlot, 0, true)
                              else
                                ..._proposedSlots.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final slot = entry.value;
                                  final isConfirmed = _isConfirmed(slot);
                                  return _slotCard(slot, idx, isConfirmed);
                                }),
                              const SizedBox(height: 32),
                              Text(
                                'Asesor asignado',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _advisorCard(),
                              const SizedBox(height: 48),
                              ElevatedButton(
                                onPressed: _enviarNotificacion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(25)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Enviar notificación',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
    );
  }

  Widget _slotCard(dynamic slot, int index, bool isConfirmed) {
    final date = _formatDate((slot is Map ? slot['date'] : null)?.toString() ?? '');
    final time = (slot is Map ? slot['time'] : null)?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConfirmed
            ? _primary
            : const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConfirmed
              ? _primary
              : const Color(0xFFE0E3E7),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Opción ${index + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isConfirmed
                        ? Colors.white70
                        : const Color(0xFF57636C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date • $time hrs',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isConfirmed
                        ? Colors.white
                        : const Color(0xFF14181B),
                  ),
                ),
              ],
            ),
          ),
          if (isConfirmed)
            const Icon(Icons.check_circle, color: Colors.white, size: 24)
          else
            const Icon(Icons.lock_outline, color: Color(0xFF95A1AC), size: 20),
        ],
      ),
    );
  }

  Widget _advisorCard() {
    String name = 'Asignando asesor...';
    String? photo;

    if (_showingAgent != null && _showingAgent is Map) {
      // Robust name extraction
      final fullName = _showingAgent['fullName'];
      if (fullName is String) {
        name = fullName;
      } else if (fullName is Map) {
        final fName = fullName['name']?.toString() ?? '';
        final lName = fullName['lastname']?.toString() ?? fullName['lastName']?.toString() ?? '';
        name = '$fName $lName'.trim();
      } else {
        final fName = _showingAgent['firstName']?.toString() ?? _showingAgent['name']?.toString() ?? '';
        final lName = _showingAgent['lastName']?.toString() ?? _showingAgent['lastname']?.toString() ?? '';
        name = '$fName $lName'.trim();
      }
      
      if (name.isEmpty) name = 'Asesor Dovia';

      // Robust photo extraction
      photo = _showingAgent['avatar']?.toString() ?? 
              _showingAgent['profilePicture']?.toString() ?? 
              _showingAgent['profilePictureUrl']?.toString();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFE0E3E7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F4F8),
              image: photo != null && photo.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(photo),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: NetworkImage('https://ui-avatars.com/api/?name=Showing&background=007376&color=fff'),
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
            name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryDark,
            ),
          ),
          if (_showingAgent == null) ...[
            const SizedBox(height: 16),
            Text(
              'Estamos asignando al mejor asesor para tu visita. Te notificaremos en cuanto esté confirmado.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF57636C),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

}
