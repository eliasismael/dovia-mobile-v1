import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_properties.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart'; // To get OPERATIVELISTINGChecklistFormWidget and Agenda
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_checklist_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_checklist_model.dart';

// Data model for an enriched checklist item
class _ChecklistData {
  final String visitId;
  final String propertyId;
  final String propertyName;
  final String address;
  final String ownerName;
  final String imageUrl;
  final String date; // "2026-06-15"
  final String time; // "10:00"
  // HQ auditor (assigned LISTER_HQ) — used by the contact popup
  final String hqName;
  final String hqPhone; // full dial string, e.g. "+573000000000"

  const _ChecklistData({
    required this.visitId,
    required this.propertyId,
    required this.propertyName,
    required this.address,
    required this.ownerName,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.hqName,
    required this.hqPhone,
  });
}

class OPERATIVELISTINGChecklistWidget extends StatefulWidget {
  const OPERATIVELISTINGChecklistWidget({super.key});

  static String routeName = 'OPERATIVE_LISTING_Checklist';
  static String routePath = '/oPERATIVELISTINGChecklist';

  @override
  State<OPERATIVELISTINGChecklistWidget> createState() =>
      _OPERATIVELISTINGChecklistWidgetState();
}

class _OPERATIVELISTINGChecklistWidgetState
    extends State<OPERATIVELISTINGChecklistWidget> {
  late OPERATIVELISTINGChecklistModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Pendiente  -> IN_PROGRESS / AWAITING_REPORT  (24h window to submit)
  // Rechazados -> COMPLETED   / CHANGES_REQUESTED (HQ requested changes)
  Future<List<_ChecklistData>>? _pendingFuture;
  Future<List<_ChecklistData>>? _rejectedFuture;

  static const Color _primary = Color(0xFF007376);
  static const Color _dark = Color(0xFF00444B);
  static const Color _pillBg = Color(0xFFCCE3E4);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGChecklistModel());
    _pendingFuture = _fetchEnriched(substatus: 'AWAITING_REPORT');
    _rejectedFuture = _fetchEnriched(substatus: 'CHANGES_REQUESTED');
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Fetch list by substatus, then enrich each visit ──────────────────────
  // List response carries id/propertyId/confirmedSlot. The overview adds the
  // address, owner name and the assigned LISTER_HQ (auditor); the property
  // endpoint adds the thumbnail.
  Future<List<_ChecklistData>> _fetchEnriched(
      {required String substatus}) async {
    final token = currentAuthenticationToken ?? '';

    final listRes =
        await DOVIAAPIVisitContextGroup.getOperativeListerVisitsCall.call(
      authToken: token,
      substatus: substatus,
      page: '1',
      limit: '20',
    );

    if (!listRes.succeeded) return [];

    final raw = getJsonField(listRes.jsonBody, r'$.data');
    final visits = raw is List ? raw : <dynamic>[];

    // Sort ascending by slot date+time (closest deadline first)
    visits.sort((a, b) {
      final da = _slotStr(a, 'confirmedSlot', 'date');
      final ta = _slotStr(a, 'confirmedSlot', 'time');
      final db = _slotStr(b, 'confirmedSlot', 'date');
      final tb = _slotStr(b, 'confirmedSlot', 'time');
      final cmp = da.compareTo(db);
      return cmp != 0 ? cmp : ta.compareTo(tb);
    });

    // Overview (address, owner, listerHq) per visit — in parallel
    final overviewFutures = visits.map((v) {
      final id = v is Map ? v['id']?.toString() ?? '' : '';
      return DOVIAAPIVisitContextGroup.getOperativeListerVisitOverviewCall
          .call(authToken: token, visitId: id);
    }).toList();

    // Property thumbnail per visit — in parallel
    final propertyFutures = visits.map((v) {
      final pid = v is Map ? v['propertyId']?.toString() ?? '' : '';
      return DOVIAAPIPropertyContextGroup.getPropertyByIDCall
          .call(propertyId: pid);
    }).toList();

    final overviews = await Future.wait(overviewFutures);
    final properties = await Future.wait(propertyFutures);

    final result = <_ChecklistData>[];
    for (int i = 0; i < visits.length; i++) {
      final v = visits[i];
      final visitId = v is Map ? v['id']?.toString() ?? '' : '';
      final propertyId = v is Map ? v['propertyId']?.toString() ?? '' : '';
      final date = _slotStr(v, 'confirmedSlot', 'date');
      final time = _slotStr(v, 'confirmedSlot', 'time');

      String propertyName = '';
      String address = '';
      String ownerName = '';
      String hqName = '';
      String hqPhone = '';

      final ov = overviews[i];
      if (ov.succeeded) {
        final data = getJsonField(ov.jsonBody, r'$.data');
        if (data is Map) {
          final prop = data['property'];
          if (prop is Map) {
            propertyName =
                prop['name']?.toString() ?? prop['title']?.toString() ?? '';
            final locAddr = _deepMap(prop, ['location', 'address']);
            address = locAddr?['fullAddress']?.toString() ??
                locAddr?['street']?.toString() ??
                '';
          }
          final owner = data['ownerProfile'];
          if (owner is Map) {
            ownerName = owner['fullName']?.toString() ?? '';
          }
          final hq = data['listerHq'];
          if (hq is Map) {
            hqName = hq['fullName']?.toString() ?? '';
            final phone = hq['phone'];
            if (phone is Map) {
              final cc = phone['countryCode']?.toString() ?? '';
              final num = phone['number']?.toString() ?? '';
              hqPhone = '$cc$num'.trim();
            }
          }
        }
      }

      String imageUrl = '';
      final propRes = properties[i];
      if (propRes.succeeded) {
        imageUrl = DOVIAAPIPropertyContextGroup.getPropertyByIDCall
                .image(propRes.jsonBody) ??
            '';
      }

      // Fallback: surface the address as the title when no name exists
      if (propertyName.isEmpty && address.isNotEmpty) {
        propertyName = address;
        address = '';
      }

      result.add(_ChecklistData(
        visitId: visitId,
        propertyId: propertyId,
        propertyName: propertyName,
        address: address,
        ownerName: ownerName,
        imageUrl: imageUrl,
        date: date,
        time: time,
        hqName: hqName,
        hqPhone: hqPhone,
      ));
    }
    return result;
  }

  String _slotStr(dynamic visit, String slotKey, String field) {
    if (visit is! Map) return '';
    final slot = visit[slotKey];
    if (slot is! Map) return '';
    return slot[field]?.toString() ?? '';
  }

  Map<String, dynamic>? _deepMap(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur is Map ? cur as Map<String, dynamic> : null;
  }

  String _formatVisitTime(_ChecklistData d) {
    if (d.date.isEmpty && d.time.isEmpty) return 'Horario de la visita: —';
    try {
      final dt = DateTime.parse(d.date);
      final dateStr =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      return 'Visita: $dateStr ${d.time}'.trim();
    } catch (_) {
      return 'Visita: ${d.date} ${d.time}'.trim();
    }
  }

  void _showContactPopup(_ChecklistData data) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _ContactHQPopup(
          visitId: data.visitId,
          hqName: data.hqName,
          hqPhone: data.hqPhone,
        ),
      ),
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
                    model: _model.oPERATIVELISTINGHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const OPERATIVELISTINGHeaderWidget(
                      titleText: 'Checklist',
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Búsqueda con IA',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                color: Color(0xFF888888),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Checklist Pendiente
                          _sectionHeader(
                            'Checklist Pendiente',
                            onVerMas: () => context.pushNamed(
                                OPERATIVELISTINGAgendaWidget.routeName),
                          ),
                          _section(
                            future: _pendingFuture,
                            emptyText: 'No tienes checklists pendientes.',
                            cardBuilder: (data) => _PendingCard(
                              data: data,
                              subtitle: _formatVisitTime(data),
                              onChecklistTap: () {
                                context.pushNamed(
                                  OPERATIVELISTINGChecklistFormWidget.routeName,
                                  queryParameters: {
                                    'visitId': serializeParam(
                                        data.visitId, ParamType.String),
                                  }.withoutNulls,
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Checklist Rechazados
                          _sectionHeader(
                            'Checklist Rechazados',
                            onVerMas: () => context.pushNamed(
                                OPERATIVELISTINGAgendaWidget.routeName),
                          ),
                          _section(
                            future: _rejectedFuture,
                            emptyText: 'No tienes checklists rechazados.',
                            cardBuilder: (data) => _RejectedCard(
                              data: data,
                              onContactTap: () => _showContactPopup(data),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.oPERATIVELISTINGNavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const OPERATIVELISTINGNavbarWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Horizontal carousel for a section, driven by its future.
  Widget _section({
    required Future<List<_ChecklistData>>? future,
    required String emptyText,
    required Widget Function(_ChecklistData) cardBuilder,
  }) {
    return SizedBox(
      height: 180,
      child: FutureBuilder<List<_ChecklistData>>(
        future: future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                emptyText,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: Color(0xFF888888),
                ),
              ),
            );
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (ctx, i) => cardBuilder(items[i]),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(
    String title, {
    required VoidCallback onVerMas,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w600,
              color: _dark,
              fontSize: 17,
            ),
          ),
          GestureDetector(
            onTap: onVerMas,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _pillBg,
                borderRadius: BorderRadius.circular(100),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Ver más',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  color: _primary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Shared thumbnail with graceful fallback to a placeholder icon.
Widget _thumbnail(String imageUrl) {
  Widget placeholder() => Container(
        width: 72,
        height: 100,
        color: const Color(0xFFEFEFEF),
        child: const Icon(Icons.home, color: Colors.grey, size: 40),
      );
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: SizedBox(
      width: 72,
      height: 100,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder(),
            )
          : placeholder(),
    ),
  );
}

class _PendingCard extends StatelessWidget {
  final _ChecklistData data;
  final String subtitle;
  final VoidCallback onChecklistTap;

  const _PendingCard({
    required this.data,
    required this.subtitle,
    required this.onChecklistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _thumbnail(data.imageUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.propertyName.isNotEmpty
                      ? data.propertyName
                      : 'Dirección',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF00444B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (data.address.isNotEmpty) ...[
                  Text(
                    data.address,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 12,
                      color: Color(0xFF007376),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: Color(0xFF007376),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECCC), // Light orange
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Pendiente',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 12,
                      color: Color(0xFFF57E00), // Orange text
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onChecklistTap,
                  child: Container(
                    width: double.infinity,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007376),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Checklist',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectedCard extends StatelessWidget {
  final _ChecklistData data;
  final VoidCallback onContactTap;

  const _RejectedCard({required this.data, required this.onContactTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _thumbnail(data.imageUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.propertyName.isNotEmpty
                      ? data.propertyName
                      : 'Dirección',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF00444B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data.ownerName.isNotEmpty
                      ? data.ownerName
                      : 'Nombre del propietario',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: Color(0xFF007376),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8D5D5), // Light pink
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Falta información',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 12,
                      color: Color(0xFFBC0000), // Dark red
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onContactTap,
                  child: Container(
                    width: double.infinity,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007376),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Contacta con HQ',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Popup Contact HQ
class _ContactHQPopup extends StatefulWidget {
  final String visitId;
  final String hqName;
  final String hqPhone;

  const _ContactHQPopup({
    required this.visitId,
    required this.hqName,
    required this.hqPhone,
  });

  @override
  State<_ContactHQPopup> createState() => _ContactHQPopupState();
}

class _ContactHQPopupState extends State<_ContactHQPopup> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _makeCall() async {
    if (widget.hqPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay un teléfono disponible para el auditor')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: widget.hqPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _submit() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    setState(() => _loading = true);

    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPIVisitContextGroup.sendVisitMessageCall.call(
      visitId: widget.visitId,
      authToken: token,
      message: message,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (res.succeeded) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensaje enviado a HQ con éxito')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se pudo enviar el mensaje. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hqName =
        widget.hqName.isNotEmpty ? widget.hqName : 'Auditor de DOVIA HQ';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HQ Auditor Card (assigned LISTER_HQ for this visit)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFCCE3E4),
                  child: Icon(Icons.person, color: Color(0xFF007376)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hqName,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF00444B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Dovia HQ - Encargado del proceso',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _makeCall,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366), // Green phone color
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.phone, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Escribe tu duda o descargo:',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00444B),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 6,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: 'Ej: El dueño no me dejó sacarle fotos al baño...',
              hintStyle: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: Color(0xFFB0B8C1),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007376),
                disabledBackgroundColor:
                    const Color(0xFF007376).withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Aceptar y Enviar',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
