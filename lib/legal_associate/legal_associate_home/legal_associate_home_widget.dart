import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/legal_associate/legal_associate_header/legal_associate_header_widget.dart';
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
  });

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
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

// ── Status constants ────────────────────────────────────────────────────────

/// Carousel 1: New assignments (not started yet)
const _kNewStatuses = 'NOT_STARTED';

/// Carousel 2: In progress (all active statuses)
const _kInProgressStatuses =
    'IN_PROGRESS,DRAFTING,MEETING_COORDINATION,MEETING_SCHEDULED,LEGAL_HQ_REVIEW,REJECTED';

/// Carousel 3: Completed
const _kCompletedStatuses = 'APPROVED';

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
  // "Ver más" pill
  static const Color _verMasBg = Color(0xFFCCE3E4);

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
                                child: Text(
                                  'Búsqueda con IA',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.normal,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        fontSize: 15.0,
                                        letterSpacing: 0.3,
                                      ),
                                ),
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
                      child: Column(
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
                              // TODO: navigate to full list
                            },
                          ),
                          const SizedBox(height: 14.0),
                          _buildFutureCarousel<_LegalProcess>(
                            future: _newAssignmentsFuture,
                            height: 188.0,
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
                              // TODO: navigate to full list
                            },
                          ),
                          const SizedBox(height: 14.0),
                          _buildFutureCarousel<_LegalProcess>(
                            future: _inProgressFuture,
                            height: 155.0,
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
                              // TODO: navigate to history
                            },
                          ),
                          const SizedBox(height: 14.0),
                          _buildFutureCarousel<_LegalProcess>(
                            future: _completedFuture,
                            height: 155.0,
                            emptyMessage: 'Aún no tienes procesos completados',
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

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return SizedBox(
            height: height,
            child: Center(
              child: Text(
                emptyMessage,
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
        GestureDetector(
          onTap: onVerMas,
          child: Container(
            height: 30.0,
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: _verMasBg,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Text(
              'Ver más',
              style: GoogleFonts.publicSans(
                color: _aqua,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Carousel 1: Assigned property card ────────────────────────────────────

  Widget _buildAssignedCard(BuildContext context, _LegalProcess process) {
    final formattedDate = _formatDate(process.createdAt);
    final formattedTime = _formatTime(process.createdAt);
    final categoryLabel = _categoryLabel(process.category);

    return Container(
      width: 280.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          // Property image
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: _buildPropertyImage(process.imageUrl),
          ),
          const SizedBox(width: 14.0),
          // Text column
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dirección: ${process.address.isNotEmpty ? process.address : 'Sin dirección'}',
                  style: GoogleFonts.publicSans(
                    color: _aqua,
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  formattedDate,
                  style: GoogleFonts.publicSans(
                    color: _textDark,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Hora: $formattedTime',
                  style: GoogleFonts.publicSans(
                    color: _textDark,
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  categoryLabel,
                  style: GoogleFonts.publicSans(
                    color: _textDark,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                // "Iniciar Proceso" button
                SizedBox(
                  width: double.infinity,
                  height: 29.0,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: navigate to legal process step-by-step
                      debugPrint('Iniciar Proceso: ${process.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _aqua,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: const BorderSide(color: _aqua),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                    child: Text(
                      'Iniciar Proceso',
                      style: GoogleFonts.publicSans(
                        fontSize: 14.0,
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

  // ── Carousel 2 & 3: Property card with status badge ──────────────────────

  Widget _buildPropertyCard(
    BuildContext context,
    _LegalProcess process, {
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: isCompleted
          ? () {
              // TODO: open read-only history / PDFs
              debugPrint('Ver historial: ${process.id}');
            }
          : null,
      child: Container(
        width: 280.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Property image
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: _buildPropertyImage(process.imageUrl),
            ),
            const SizedBox(width: 14.0),
            // Text column
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    process.address.isNotEmpty
                        ? process.address
                        : _propertyTypeLabel(process.propertyType),
                    style: GoogleFonts.publicSans(
                      color: _textDark,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Categoría:',
                    style: GoogleFonts.publicSans(
                      color: _aqua,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    _categoryLabel(process.category),
                    style: GoogleFonts.publicSans(
                      color: _aqua,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10.0),
                  // Status badge
                  _buildStatusBadge(process.status, isCompleted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Property image with fallback ──────────────────────────────────────────

  Widget _buildPropertyImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 72.0,
        height: 96.0,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/casa_card_sobreMiVisita.png',
          width: 72.0,
          height: 96.0,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      'assets/images/casa_card_sobreMiVisita.png',
      width: 72.0,
      height: 96.0,
      fit: BoxFit.cover,
    );
  }

  // ── Status badge builder ──────────────────────────────────────────────────

  Widget _buildStatusBadge(String status, bool isCompleted) {
    late String label;
    late Color bgColor;
    late Color textColor;

    if (isCompleted) {
      // Approved properties always get success badge
      label = 'Aprobado';
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
      width: double.infinity,
      height: 23.0,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100.0),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.publicSans(
          color: textColor,
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
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
