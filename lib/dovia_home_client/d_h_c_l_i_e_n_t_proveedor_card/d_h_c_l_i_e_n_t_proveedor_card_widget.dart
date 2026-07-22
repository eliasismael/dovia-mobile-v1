import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'd_h_c_l_i_e_n_t_proveedor_card_model.dart';
export 'd_h_c_l_i_e_n_t_proveedor_card_model.dart';

class DHCLIENTProveedorCardWidget extends StatefulWidget {
  const DHCLIENTProveedorCardWidget({
    super.key,
    this.fullName,
    this.age,
    this.avatarUrl,
    this.phoneNumber,
    this.isAssigned = false,
    this.advisorId,
    this.visitDate,
    this.visitTime,
    this.about,
    this.vehicle,
    this.licensePlate,
    this.roleLabel,
    this.showDownloadId = false,
    this.idDocumentUrl,
    this.onDownloadId,
  });

  final String? fullName;
  final String? age;
  final String? avatarUrl;
  final String? phoneNumber;
  final bool isAssigned;
  final String? advisorId;
  final String? visitDate;
  final String? visitTime;
  final String? about;
  final String? vehicle;
  final String? licensePlate;

  /// Texto del badge del rol (Ej: "Dovia Home Associate"). Si es null usa el
  /// valor por defecto de la tarjeta de Showing.
  final String? roleLabel;

  /// Muestra el botón "Descargar ID" (documento de identidad verificado del
  /// asociado). Se usa en la pantalla de confirmación del cliente.
  final bool showDownloadId;

  /// URL/base del documento de identidad a descargar o abrir en pantalla
  /// completa. Si viene null, [onDownloadId] decide el comportamiento.
  final String? idDocumentUrl;

  /// Callback opcional al tapear "Descargar ID". Si es null, se abre
  /// [idDocumentUrl] en el navegador/visor externo.
  final VoidCallback? onDownloadId;

  @override
  State<DHCLIENTProveedorCardWidget> createState() =>
      _DHCLIENTProveedorCardWidgetState();
}

class _DHCLIENTProveedorCardWidgetState
    extends State<DHCLIENTProveedorCardWidget> {
  late DHCLIENTProveedorCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTProveedorCardModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final phone = widget.phoneNumber ?? '';
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  Future<void> _callPhone() async {
    final phone = widget.phoneNumber ?? '';
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar la llamada')),
        );
      }
    }
  }

  /// Descarga / abre en pantalla completa el documento de identidad verificado
  /// del asociado. Si hay un [onDownloadId] se delega en él; si no, se intenta
  /// abrir [idDocumentUrl] con el visor externo.
  Future<void> _downloadId() async {
    if (widget.onDownloadId != null) {
      widget.onDownloadId!();
      return;
    }
    final url = widget.idDocumentUrl ?? '';
    if (url.isEmpty) {
      // TODO: conectar con el endpoint del documento de identidad del asociado
      // cuando exista. Por ahora solo se notifica al usuario.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento de identidad no disponible')),
        );
      }
      return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el documento')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primary,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 16.0),
        child: widget.isAssigned ? _buildAdvisorCard() : _buildPendingState(),
      ),
    );
  }

  Widget _buildPendingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Icon(
          Icons.person_search_outlined,
          size: 48,
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
        ),
        const SizedBox(height: 12),
        Text(
          'Asignando asesor DOVIA...',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAdvisorCard() {
    const primaryColor = Color(0xFF00444B);
    const badgeBg = Color(0x3370ACAD);
    const idBadgeBg = Color(0x4D007376);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
              ? Image.network(
                  widget.avatarUrl!,
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _defaultAvatar(),
                )
              : _defaultAvatar(),
        ),

        const SizedBox(height: 12),

        // Action icons row. En la variante "Descargar ID" (confirmación del
        // cliente) siempre se muestra el ícono de alerta; el chat/teléfono van
        // en la cabecera. En el resto se conserva el comportamiento original:
        // se muestra la fila (alerta + chat) solo si hay teléfono.
        if (widget.showDownloadId ||
            (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty))
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Report / emergency icon (red)
              GestureDetector(
              onTap: () {
                // report/emergency action — placeholder
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Soporte de emergencia')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            if (!widget.showDownloadId &&
                widget.phoneNumber != null &&
                widget.phoneNumber!.isNotEmpty) ...[
              const SizedBox(width: 12),
              // WhatsApp / Chat icon (teal)
              GestureDetector(
                onTap: _openWhatsApp,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 10),

        // Role badge
        Container(
          width: double.infinity,
          height: 29,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(64),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.roleLabel ?? 'Dovia Showing Associate',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(
                    fontWeight: FontWeight.normal,
                  ),
                  color: primaryColor,
                  fontSize: 14.0,
                  letterSpacing: 0.07,
                ),
          ),
        ),

        const SizedBox(height: 4),

        // Name
        Text(
          widget.fullName ?? '',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(
                  fontWeight: FontWeight.bold,
                ),
                color: primaryColor,
                fontSize: 16.0,
                letterSpacing: 0.07,
                fontWeight: FontWeight.bold,
                lineHeight: 1.6,
              ),
        ),

        const SizedBox(height: 4),

        // Details column (Edad, Sobre mi, Programada, Fecha/Hora)
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.age != null && widget.age!.isNotEmpty)
                _detailRow('Edad', '${widget.age} años'),
              if (widget.about != null && widget.about!.isNotEmpty)
                _detailRow('Sobre mi', widget.about!),
              if (widget.visitDate != null && widget.visitDate!.isNotEmpty)
                _detailRow('Programada', widget.visitDate!),
              if (widget.visitTime != null && widget.visitTime!.isNotEmpty)
                _detailRow('Hora', widget.visitTime!),
              if (widget.vehicle != null && widget.vehicle!.isNotEmpty)
                _detailRow('Vehículo', widget.vehicle!),
              if (widget.licensePlate != null &&
                  widget.licensePlate!.isNotEmpty)
                _detailRow('Placa', widget.licensePlate!),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ID badge row
        if (widget.advisorId != null && widget.advisorId!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: idBadgeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ID: ${widget.advisorId!.length > 8 ? widget.advisorId!.substring(0, 8).toUpperCase() : widget.advisorId!.toUpperCase()}',
                    textAlign:
                        widget.showDownloadId ? TextAlign.center : TextAlign.start,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w600,
                          ),
                          color: primaryColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.07,
                        ),
                  ),
                ),
                if (!widget.showDownloadId)
                  GestureDetector(
                    onTap: _callPhone,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x3370ACAD),
                            blurRadius: 2.7,
                            offset: const Offset(0, 2.7),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Botón "Descargar ID": abre/descarga el documento de identidad
        // verificado del asociado.
        if (widget.showDownloadId) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FFButtonWidget(
              onPressed: _downloadId,
              text: 'Descargar',
              options: FFButtonOptions(
                width: double.infinity,
                height: 40.0,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: GoogleFonts.publicSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    const color = Color(0xFF00444B);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.publicSans(
            fontSize: 14,
            color: color,
            letterSpacing: 0.07,
            height: 1.6,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 56, color: Colors.grey),
    );
  }
}
