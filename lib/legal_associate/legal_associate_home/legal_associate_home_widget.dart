import '/core/network_image_size.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/legal_associate/legal_associate_header/legal_associate_header_widget.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_i_a_t_e_procesos/l_e_g_a_l_a_s_s_o_c_i_a_t_e_procesos_widget.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_i_a_t_e_procesos_2/l_e_g_a_l_a_s_s_o_c_i_a_t_e_procesos2_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'legal_associate_home_model.dart';
export 'legal_associate_home_model.dart';

// ── Data model for a legal process item ─────────────────────────────────────

class _LegalProcess {
  const _LegalProcess({
    required this.id,
    required this.category,
    required this.status,
    required this.propertyId,
    this.address = '',
    this.imageUrl = '',
    this.propertyType = '',
    this.createdAt = '',
    this.commission,
    this.name = '',
    this.description = '',
    this.ownerName = '',
    this.clientName = '',
  });

  final String name;
  final String description;
  final String ownerName;
  final String clientName;

  /// Coincide con el texto buscado: nombre de la propiedad, dirección,
  /// propietario, cliente, tipo de operación o ID del trámite. Ignora
  /// mayúsculas y acentos, y cada palabra puede estar en cualquier campo.
  bool matches(String q) {
    if (q.isEmpty) return true;
    final operation = switch (category) {
      'SALE' => 'venta',
      'RENT' => 'renta alquiler',
      'PUBLICATION' => 'publicacion',
      _ => '',
    };
    final haystack = _normalize(
        '$name $address $ownerName $clientName $operation $propertyType $id');
    return _normalize(q)
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .every(haystack.contains);
  }

  static String _normalize(String s) {
    const from = 'áàäâéèëêíìïîóòöôúùüûñ';
    const to = 'aaaaeeeeiiiioooouuuun';
    final lower = s.toLowerCase();
    final out = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      out.write(i >= 0 ? to[i] : ch);
    }
    return out.toString();
  }

  final String id;
  final String category; // SALE, RENT, PUBLICATION
  final String status; // PENDING_START, DOCUMENT_COLLECTION, DRAFTING,
  // MEETING_COORDINATION, MEETING_SCHEDULED,
  // HQ_REVIEW, COMPLETED, REJECTED
  final String propertyId;
  final String address;
  final String imageUrl;
  final String propertyType;
  final String createdAt;

  /// Commission the associate can earn for this assignment. Null when the
  /// backend does not (yet) return an amount.
  final double? commission;

  /// Factory from API JSON item
  factory _LegalProcess.fromJson(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>? ?? {};
    return _LegalProcess(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      address: property['fullAddress']?.toString() ?? '',
      imageUrl: property['image']?.toString() ?? '',
      propertyType: property['propertyType']?.toString() ?? '',
      // Fecha en que se le asignó el trámite al asociado.
      createdAt: json['legalAssociateAssignedAt']?.toString() ??
          json['createdAt']?.toString() ??
          '',
      commission: _readCommission(json),
      name: property['name']?.toString() ?? '',
      description: property['description']?.toString() ?? '',
      ownerName: (json['ownerProfile'] is Map
              ? json['ownerProfile']['fullName']?.toString()
              : null) ??
          '',
      clientName: (json['interestedProfile'] is Map
              ? json['interestedProfile']['fullName']?.toString()
              : null) ??
          '',
    );
  }

  /// Reads the commission amount defensively. The exact backend field name is
  /// not yet confirmed, so we try the most likely keys (top-level and nested)
  /// and fall back to null. Adjust the key list once the API contract is set.
  static double? _readCommission(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>? ?? {};
    final candidates = <dynamic>[
      json['commission'],
      json['associateCommission'],
      json['potentialCommission'],
      json['estimatedCommission'],
      property['commission'],
    ];
    for (final value in candidates) {
      if (value == null) continue;
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }
}

// ── Status constants ────────────────────────────────────────────────────────

/// Carousel 1: New assignments (not started yet)
const _kNewStatuses = 'NOT_STARTED';

/// Carousel 2: In progress (all active statuses). APPROVED sigue abierto:
/// falta el comprobante de pago a DOVIA y finalizar el trámite.
const _kInProgressStatuses =
    'IN_PROGRESS,DRAFTING,MEETING_COORDINATION,MEETING_SCHEDULED,LEGAL_HQ_REVIEW,REJECTED,APPROVED';

/// Carousel 3: Completed — sólo trámites finalizados (FINISHED). Antes entraba
/// también APPROVED y se mostraba "Vendido" sin el pago a DOVIA.
const _kCompletedStatuses = 'FINISHED';

// ── Main page widget ────────────────────────────────────────────────────────

class LegalAssociateHomeWidget extends StatefulWidget {
  const LegalAssociateHomeWidget({super.key});

  static String routeName = 'LEGAL_ASSOCIATE_HOME';
  static String routePath = '/legalAssociateHome';

  @override
  State<LegalAssociateHomeWidget> createState() =>
      _LegalAssociateHomeWidgetState();
}

class _LegalAssociateHomeWidgetState extends State<LegalAssociateHomeWidget> {
  late LegalAssociateHomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ── API futures ───────────────────────────────────────────────────────────

  late Future<List<_LegalProcess>> _newAssignmentsFuture;
  late Future<List<_LegalProcess>> _inProgressFuture;
  late Future<List<_LegalProcess>> _completedFuture;

  final _searchController = TextEditingController();
  String _query = '';

  // ── Colors (from existing codebase) ───────────────────────────────────────

  // Primary aqua – used for buttons, text highlights
  static const Color _aqua = Color(0xFF007376);
  // Text dark
  static const Color _textDark = Color(0xFF00444B);
  // Badge: yellow / in-progress
  static const Color _badgeYellowBg = Color(0xFFFFF1BC);
  static const Color _badgeYellowText = Color(0xFFF5A700);
  // Badge: orange / revision HQ
  static const Color _badgeOrangeBg = Color(0xFFFFDBBC);
  static const Color _badgeOrangeText = Color(0xFFF57E00);
  // Badge: completed/success – reusing theme success (#249689) with tinted bg
  static const Color _badgeSuccessBg = Color(0x1A249689);
  static const Color _badgeSuccessText = Color(0xFF249689);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LegalAssociateHomeModel());
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  void _loadData() {
    _newAssignmentsFuture = _fetchProcesses(status: _kNewStatuses);
    _inProgressFuture = _fetchProcesses(status: _kInProgressStatuses);
    _completedFuture = _fetchProcesses(status: _kCompletedStatuses);
  }

  Future<List<_LegalProcess>> _fetchProcesses({required String status}) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPILegalProcessContextGroup
        .listLegalProcessesAssociateCall
        .call(
      authToken: token,
      status: status,
      page: '1',
      limit: '20',
    );

    if (!response.succeeded) return [];

    final raw = getJsonField(response.jsonBody, r'$.data');
    final items = raw is List ? raw : <dynamic>[];

    return items
        .whereType<Map<String, dynamic>>()
        .map((json) => _LegalProcess.fromJson(json))
        .toList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
              // Background gradient
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),

              // Scrollable content
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // ── Header ───────────────────────────────────────────
                    wrapWithModel(
                      model: _model.legalAssociateHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LegalAssociateHeaderWidget(
                        titleText: 'Home',
                      ),
                    ),

                    // ── Search bar ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 16.0, 20.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              15.0, 0.0, 15.0, 0.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (v) =>
                                      safeSetState(() => _query = v.trim()),
                                  style: GoogleFonts.publicSans(
                                      color: _textDark, fontSize: 15.0),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText:
                                        'Propietario, dirección o ID de trámite',
                                    hintStyle: GoogleFonts.publicSans(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                              if (_query.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    _searchController.clear();
                                    safeSetState(() => _query = '');
                                  },
                                  child: const Icon(Icons.close,
                                      size: 20, color: _textDark),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Body with carousels ─────────────────────────────
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 100.0),
                      child: _query.isNotEmpty
                          ? _buildSearchResults(context)
                          : Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ────────────────────────────────────────────────
                                // CAROUSEL 1: Tus siguientes inmuebles asignados
                                // ────────────────────────────────────────────────
                                _buildSectionHeader(
                                  context,
                                  title: 'Tus siguientes inmuebles\nasignados',
                                  onVerMas: () {
                                    context.pushNamed(
                                      LEGALASSOCIATEProcesosWidget.routeName,
                                      queryParameters: {'filter': 'nuevos'},
                                    );
                                  },
                                ),
                                const SizedBox(height: 14.0),
                                _buildFutureCarousel<_LegalProcess>(
                                  future: _newAssignmentsFuture,
                                  height: 158.0,
                                  emptyMessage: 'No tienes nuevas asignaciones',
                                  cardBuilder: (process) =>
                                      _buildAssignedCard(context, process),
                                ),

                                const SizedBox(height: 30.0),

                                // ────────────────────────────────────────────────
                                // CAROUSEL 2: Propiedades pendientes por revisar
                                // ────────────────────────────────────────────────
                                _buildSectionHeader(
                                  context,
                                  title: 'Propiedades pendientes\npor revisar',
                                  onVerMas: () {
                                    context.pushNamed(
                                      LEGALASSOCIATEProcesosWidget.routeName,
                                      queryParameters: {'filter': 'en_curso'},
                                    );
                                  },
                                ),
                                const SizedBox(height: 14.0),
                                _buildFutureCarousel<_LegalProcess>(
                                  future: _inProgressFuture,
                                  height: 136.0,
                                  emptyMessage: 'No tienes procesos en curso',
                                  cardBuilder: (process) => _buildPropertyCard(
                                    context,
                                    process,
                                    isCompleted: false,
                                  ),
                                ),

                                const SizedBox(height: 30.0),

                                // ────────────────────────────────────────────────
                                // CAROUSEL 3: Propiedades Completadas
                                // ────────────────────────────────────────────────
                                _buildSectionHeader(
                                  context,
                                  title: 'Propiedades Completadas',
                                  onVerMas: () {
                                    context.pushNamed(
                                      LEGALASSOCIATEProcesosWidget.routeName,
                                      queryParameters: {'filter': 'aprobados'},
                                    );
                                  },
                                ),
                                const SizedBox(height: 14.0),
                                _buildFutureCarousel<_LegalProcess>(
                                  future: _completedFuture,
                                  height: 136.0,
                                  emptyMessage:
                                      'Aún no tienes procesos completados',
                                  cardBuilder: (process) => _buildPropertyCard(
                                    context,
                                    process,
                                    isCompleted: true,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),

              // ── Bottom navbar ───────────────────────────────────────────
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    wrapWithModel(
                      model: _model.lEGALASSOCAITENavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LEGALASSOCAITENavbarWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Resultados de búsqueda ────────────────────────────────────────────────

  /// Busca en los tres grupos a la vez y muestra una sola lista vertical.
  Widget _buildSearchResults(BuildContext context) {
    return FutureBuilder<List<List<_LegalProcess>>>(
      future: Future.wait(
          [_newAssignmentsFuture, _inProgressFuture, _completedFuture]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: CircularProgressIndicator(color: _aqua)),
          );
        }
        final groups = snapshot.data!;
        final results = <(_LegalProcess, int)>[
          for (var g = 0; g < groups.length; g++)
            for (final p in groups[g])
              if (p.matches(_query)) (p, g),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              results.isEmpty
                  ? 'Sin resultados para "$_query"'
                  : '${results.length} resultado${results.length == 1 ? '' : 's'}',
              style: GoogleFonts.publicSans(
                color: _textDark,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14.0),
            for (final (process, group) in results) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openProcess(process),
                child: SizedBox(
                  height: group == 0 ? 158.0 : 136.0,
                  child: group == 0
                      ? _buildAssignedCard(context, process)
                      : _buildPropertyCard(context, process,
                          isCompleted: group == 2),
                ),
              ),
              const SizedBox(height: 14.0),
            ],
          ],
        );
      },
    );
  }

  // ── Generic FutureBuilder carousel ────────────────────────────────────────

  Widget _buildFutureCarousel<T>({
    required Future<List<T>> future,
    required double height,
    required String emptyMessage,
    required Widget Function(T item) cardBuilder,
  }) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            child: const Center(
              child: CircularProgressIndicator(color: _aqua),
            ),
          );
        }

        final items = (snapshot.data ?? [])
            .where((e) => e is! _LegalProcess || e.matches(_query))
            .toList();

        if (items.isEmpty) {
          return SizedBox(
            height: height,
            child: Center(
              child: Text(
                _query.isNotEmpty
                    ? 'Sin resultados para "$_query"'
                    : emptyMessage,
                style: GoogleFonts.publicSans(
                  color: _textDark,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14.0),
            itemBuilder: (context, index) => cardBuilder(items[index]),
          ),
        );
      },
    );
  }

  // ── Section header (title + "Ver más" pill) ───────────────────────────────

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onVerMas,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w600,
                  ),
                  color: _textDark,
                  fontSize: 17.0,
                  letterSpacing: 0.34,
                  fontWeight: FontWeight.w600,
                  lineHeight: 1.3,
                ),
          ),
        ),
        // "Ver más" como texto sin fondo, igual que en el resto de la app.
        InkWell(
          onTap: onVerMas,
          child: Text(
            'Ver más',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: FlutterFlowTheme.of(context).primary,
                  fontSize: 14.0,
                ),
          ),
        ),
      ],
    );
  }

  // ── Carousel 1: Assigned property card ────────────────────────────────────

  // ── Tarjetas ──────────────────────────────────────────────────────────────

  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 10.0,
      offset: Offset(0.0, 3.0),
    ),
  ];

  /// Marco común: blanco, esquinas redondeadas y sombra suave. Deja margen
  /// vertical para que la sombra no quede cortada por el carrusel.
  Widget _cardFrame({required Widget child, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            width: 290.0,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: _cardShadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _cardTitle(_LegalProcess process) => Text(
        process.name.isNotEmpty
            ? process.name
            : _propertyTypeLabel(process.propertyType),
        style: GoogleFonts.publicSans(
          color: _textDark,
          fontSize: 15.0,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

  Widget _cardLine(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14.0, color: _aqua),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.publicSans(
                color: const Color(0xFF6A6A6A),
                fontSize: 12.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Widget _buildAssignedCard(BuildContext context, _LegalProcess process) {
    final formattedDate = _formatDate(process.createdAt);
    final formattedTime = _formatTime(process.createdAt);

    return _cardFrame(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sólo con fotos subidas: sin foto no se inventa una casa genérica.
          if (process.imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: _buildPropertyImage(process.imageUrl),
            ),
            const SizedBox(width: 12.0),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardTitle(process),
                const SizedBox(height: 4.0),
                _cardLine(
                  Icons.location_on_outlined,
                  process.address.isNotEmpty
                      ? process.address
                      : 'Sin dirección',
                ),
                const SizedBox(height: 2.0),
                _cardLine(
                    Icons.event_outlined, '$formattedDate · $formattedTime'),
                const SizedBox(height: 6.0),
                Text(
                  'Podrás ganar: ${_formatCommission(process.commission)}',
                  style: GoogleFonts.publicSans(
                    color: _aqua,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: double.infinity,
                  height: 32.0,
                  child: ElevatedButton(
                    onPressed: () => _openProcess(process),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _aqua,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    child: Text(
                      'Ver detalles',
                      style: GoogleFonts.publicSans(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
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

  /// Abre el detalle del trámite. Iniciarlo es una decisión que se toma ahí,
  /// después de ver el acuerdo y los documentos.
  Future<void> _openProcess(_LegalProcess process) async {
    await context.pushNamed(
      LEGALASSOCIATEProcesos2Widget.routeName,
      queryParameters: {
        'processId': process.id,
        'propertyName': process.name,
      },
    );
    if (mounted) safeSetState(_loadData);
  }

  // ── Carousel 2 & 3: Property card with status badge ──────────────────────

  Widget _buildPropertyCard(
    BuildContext context,
    _LegalProcess process, {
    required bool isCompleted,
  }) {
    return _cardFrame(
      onTap: () => _openProcess(process),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sólo con fotos subidas: sin foto no se inventa una casa genérica.
          if (process.imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: _buildPropertyImage(process.imageUrl),
            ),
            const SizedBox(width: 12.0),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardTitle(process),
                const SizedBox(height: 4.0),
                _cardLine(
                    Icons.sell_outlined, _categoryLabel(process.category)),
                if (process.address.isNotEmpty) ...[
                  const SizedBox(height: 2.0),
                  _cardLine(Icons.location_on_outlined, process.address),
                ],
                const SizedBox(height: 10.0),
                _buildStatusBadge(
                    process.status, process.category, isCompleted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Property image with fallback ──────────────────────────────────────────

  Widget _buildPropertyImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 80.0,
        height: 92.0,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/casa_card_sobreMiVisita.png',
          width: 80.0,
          height: 92.0,
          fit: BoxFit.cover,
        ),
        cacheWidth: networkImageCacheWidth(width: 80.0, height: 92.0),
      );
    }
    return Image.asset(
      'assets/images/casa_card_sobreMiVisita.png',
      width: 80.0,
      height: 92.0,
      fit: BoxFit.cover,
    );
  }

  // ── Status badge builder ──────────────────────────────────────────────────

  Widget _buildStatusBadge(String status, String category, bool isCompleted) {
    late String label;
    late Color bgColor;
    late Color textColor;

    if (isCompleted) {
      // Completed properties always get a definitive green success badge,
      // worded by deal type (overrides any "pending" state from the mockup).
      label = _completedLabel(category);
      bgColor = _badgeSuccessBg;
      textColor = _badgeSuccessText;
    } else {
      // Map API status to badge appearance
      switch (status) {
        case 'IN_PROGRESS':
          label = 'Proceso de documentación';
          bgColor = _badgeYellowBg;
          textColor = _badgeYellowText;
          break;
        case 'DRAFTING':
          label = 'Redacción de contrato';
          bgColor = _badgeYellowBg;
          textColor = _badgeYellowText;
          break;
        case 'MEETING_COORDINATION':
        case 'MEETING_SCHEDULED':
          label = 'Pendiente';
          bgColor = _badgeYellowBg;
          textColor = _badgeYellowText;
          break;
        case 'LEGAL_HQ_REVIEW':
          label = 'En revisión Legal HQ';
          bgColor = _badgeOrangeBg;
          textColor = _badgeOrangeText;
          break;
        case 'APPROVED':
          label = 'Aprobado – falta finalizar';
          bgColor = _badgeYellowBg;
          textColor = _badgeYellowText;
          break;
        case 'REJECTED':
          label = 'Rechazado – corregir';
          bgColor = _badgeOrangeBg;
          textColor = _badgeOrangeText;
          break;
        default:
          label = 'Pendiente';
          bgColor = _badgeYellowBg;
          textColor = _badgeYellowText;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.publicSans(
          color: textColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Helper: format ISO date to dd/MM/yyyy ─────────────────────────────────

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'Sin fecha';
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return 'Sin fecha';
    }
  }

  String _formatTime(String isoDate) {
    if (isoDate.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(isoDate);
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$h12:$minute $period';
    } catch (_) {
      return '--:--';
    }
  }

  // ── Helper: format commission amount ("Podrás ganar: X") ──────────────────

  String _formatCommission(double? amount) {
    if (amount == null || amount <= 0) return 'Por confirmar';
    final whole = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return 'Q$buffer';
  }

  // ── Helper: definitive completed badge label by deal type ─────────────────

  String _completedLabel(String category) {
    switch (category) {
      case 'SALE':
        return 'Vendido';
      case 'RENT':
        return 'Arrendado';
      default:
        return 'Completado';
    }
  }

  // ── Helper: category display label ────────────────────────────────────────

  String _categoryLabel(String category) {
    switch (category) {
      case 'SALE':
        return 'Compraventa';
      case 'RENT':
        return 'Arrendamiento';
      case 'PUBLICATION':
        return 'Publicación';
      default:
        return category;
    }
  }

  // ── Helper: property type display label ───────────────────────────────────

  String _propertyTypeLabel(String type) {
    switch (type) {
      case 'HOUSE':
        return 'Casa';
      case 'APARTMENT':
        return 'Departamento';
      case 'LAND':
        return 'Terreno';
      case 'COMMERCIAL':
        return 'Comercial';
      default:
        return type.isNotEmpty ? type : 'Propiedad';
    }
  }
}
