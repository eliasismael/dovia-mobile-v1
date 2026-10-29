import '/core/network_image_size.dart';
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
import '/operative_listing/operative_debug.dart';
import 'package:url_launcher/url_launcher.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_checklist_model.dart';
import '/shared_components/dovia_spinner.dart';
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
  final String substatus;

  /// Estado del recorrido del operative: ON_MY_WAY o AT_LOCATION.
  final String journey;

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
    this.substatus = '',
    this.journey = '',
  });

  DateTime? get slotStart {
    final d = DateTime.tryParse(date);
    if (d == null) return null;
    final t = time.split(':');
    return DateTime(
        d.year,
        d.month,
        d.day,
        t.isNotEmpty ? int.tryParse(t[0]) ?? 0 : 0,
        t.length > 1 ? int.tryParse(t[1]) ?? 0 : 0);
  }

  /// Checklist por hacer: la visita ya empezó y el operative marcó que llegó
  /// (o el backend ya la pasó a en curso / esperando reporte).
  bool get isChecklistPending {
    if (substatus == 'VISIT_IN_PROGRESS' || substatus == 'AWAITING_REPORT') {
      return true;
    }
    final start = slotStart;
    return journey == 'AT_LOCATION' &&
        start != null &&
        (OperativeDebug.ignoreSchedule || !DateTime.now().isBefore(start));
  }

  bool matches(String q) {
    if (q.isEmpty) return true;
    final t = q.toLowerCase();
    return propertyName.toLowerCase().contains(t) ||
        address.toLowerCase().contains(t) ||
        ownerName.toLowerCase().contains(t);
  }
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

  final _searchController = TextEditingController();
  String _query = '';
  bool _pendingExpanded = false;
  bool _rejectedExpanded = false;

  /// Visitas del operative que pueden tener el checklist por hacer. El backend
  /// hoy no pasa solo a AWAITING_REPORT, así que también se miran las
  /// asignadas donde el operative ya marcó que llegó.
  static const List<String> _kPendingCandidates = [
    'ASSIGNED',
    'VISIT_IN_PROGRESS',
    'AWAITING_REPORT',
  ];

  static const Color _primary = Color(0xFF007376);
  static const Color _dark = Color(0xFF00444B);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGChecklistModel());
    _pendingFuture = Future.wait([
      for (final sub in _kPendingCandidates) _fetchEnriched(substatus: sub),
    ]).then((lists) =>
        lists.expand((l) => l).where((v) => v.isChecklistPending).toList());
    _rejectedFuture = _fetchEnriched(substatus: 'CHANGES_REQUESTED');
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      String journey = '';

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
          final visitData = data['visit'];
          final report =
              visitData is Map ? visitData['operativeLocationReport'] : null;
          if (report is Map) journey = report['status']?.toString() ?? '';
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
        substatus: substatus,
        journey: journey,
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
      return 'Horario de la visita: $dateStr ${d.time}'.trim();
    } catch (_) {
      return 'Horario de la visita: ${d.date} ${d.time}'.trim();
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
          // Sin SafeArea abajo: el contenido pasa por debajo de la barra
          // flotante hasta el borde de la pantalla.
          bottom: false,
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
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: Colors.grey, size: 24),
                          const SizedBox(width: 12),
                          // Filtra ambas secciones por nombre, dirección o
                          // propietario.
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  safeSetState(() => _query = v.trim()),
                              style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 15,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Búsqueda con IA',
                                hintStyle: TextStyle(
                                  fontFamily: 'Public Sans',
                                  color: Color(0xFF888888),
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      // Abajo suma el indicador de inicio (iPhone): la
                      // pantalla no tiene SafeArea abajo.
                      padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom:
                              100 + MediaQuery.viewPaddingOf(context).bottom),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Checklist Pendiente
                          _sectionHeader(
                            'Checklist Pendiente',
                            expanded: _pendingExpanded,
                            onVerMas: () => safeSetState(
                                () => _pendingExpanded = !_pendingExpanded),
                          ),
                          _section(
                            future: _pendingFuture,
                            expanded: _pendingExpanded,
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
                            expanded: _rejectedExpanded,
                            onVerMas: () => safeSetState(
                                () => _rejectedExpanded = !_rejectedExpanded),
                          ),
                          _section(
                            future: _rejectedFuture,
                            expanded: _rejectedExpanded,
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

  /// Carrusel horizontal; con "Ver más" pasa a la lista completa vertical.
  /// El alto sale del contenido para que no desborde con letra grande.
  Widget _section({
    required Future<List<_ChecklistData>>? future,
    required bool expanded,
    required String emptyText,
    required Widget Function(_ChecklistData) cardBuilder,
  }) {
    return FutureBuilder<List<_ChecklistData>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: DoviaSpinner()),
          );
        }
        final items = snap.data!.where((d) => d.matches(_query)).toList();
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _query.isEmpty ? emptyText : 'Sin resultados para "$_query".',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 13,
                color: Color(0xFF888888),
              ),
            ),
          );
        }
        if (expanded) {
          return Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: cardBuilder(item),
                ),
            ],
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width - 56,
                    child: cardBuilder(items[i]),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(
    String title, {
    required bool expanded,
    required VoidCallback onVerMas,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                color: _dark,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Link de texto, con el estilo de los "Ver más" del resto de la app.
          GestureDetector(
            onTap: onVerMas,
            child: Text(
              expanded ? 'Ver menos' : 'Ver más',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                color: _primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Foto de la propiedad a la izquierda de la tarjeta. Sin foto no se muestra
/// nada (ni la casita de relleno): el texto ocupa todo el ancho.
List<Widget> _thumbnail(String imageUrl) {
  if (imageUrl.isEmpty) return const [];
  return [
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 72,
        height: 100,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const ColoredBox(color: Color(0xFFEFEFEF)),
          cacheWidth: networkImageCacheWidth(width: 72, height: 100),
        ),
      ),
    ),
    const SizedBox(width: 14),
  ];
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
          ..._thumbnail(data.imageUrl),
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
                  maxLines: 2,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    color: Color(0xFF007376),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 26,
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
                    height: 34,
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
          ..._thumbnail(data.imageUrl),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data.ownerName.isNotEmpty
                      ? data.ownerName
                      : 'Nombre del propietario',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    color: Color(0xFF007376),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 26,
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
                    height: 34,
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
  String? _fieldError;

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
    if (message.isEmpty) {
      setState(() => _fieldError = 'Escribe tu duda o descargo.');
      return;
    }
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
    const primary = Color(0xFF007376);
    const dark = Color(0xFF00444B);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Envía la solicitud o comunícate con él por teléfono',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              color: dark,
            ),
          ),
          const SizedBox(height: 16),
          // Tarjeta del Lister HQ que audita esta propiedad.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: primary, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hqName,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: dark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _makeCall,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF25D366),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDEBEC),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Dovia HQ (Encargado del proceso)',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 13,
                      color: dark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 5,
            maxLength: 1000,
            onChanged: (_) {
              if (_fieldError != null) setState(() => _fieldError = null);
            },
            decoration: InputDecoration(
              hintText: 'Escribe aquí...',
              errorText: _fieldError,
              counterText: '',
              hintStyle: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: Color(0xFFB0B8C1),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor: primary.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const DoviaSpinner(small: true, color: Colors.white)
                  : const Text(
                      'Aceptar y Enviar',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
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
