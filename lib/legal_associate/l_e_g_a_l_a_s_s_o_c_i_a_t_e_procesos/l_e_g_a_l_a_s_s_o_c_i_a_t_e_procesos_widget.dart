import '/core/network_image_size.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/legal_associate/legal_associate_header/legal_associate_header_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_procesos_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_procesos_model.dart';

/// Filtro de la lista: etiqueta del pill y estados que pide al backend
/// (vacío = todos).
class _Filter {
  const _Filter(this.key, this.label, this.statuses);
  final String key;
  final String label;
  final String statuses;
}

const _kFilters = [
  _Filter('todos', 'Todos', ''),
  _Filter('redaccion', 'En redacción', 'DRAFTING'),
  _Filter('revision', 'En revisión Legal HQ', 'LEGAL_HQ_REVIEW'),
  _Filter('rechazados', 'Rechazados', 'REJECTED'),
  _Filter('aprobados', 'Aprobados', 'APPROVED,FINISHED'),
];

/// Filtros a los que solo se llega desde los "Ver más" del Home.
const _kHomeFilters = [
  _Filter('nuevos', 'Nuevas asignaciones', 'NOT_STARTED'),
  _Filter(
      'en_curso',
      'En curso',
      'IN_PROGRESS,DRAFTING,MEETING_COORDINATION,MEETING_SCHEDULED,'
          'LEGAL_HQ_REVIEW,REJECTED'),
];

class _Process {
  _Process(Map<String, dynamic> json)
      : id = json['id']?.toString() ?? '',
        status = json['status']?.toString() ?? '',
        name = _prop(json, 'name'),
        address = _prop(json, 'fullAddress'),
        image = _prop(json, 'image'),
        propertyType = _prop(json, 'propertyType');

  final String id;
  final String status;
  final String name;
  final String address;
  final String image;
  final String propertyType;

  static String _prop(Map<String, dynamic> json, String key) {
    final p = json['property'];
    return p is Map ? (p[key]?.toString() ?? '') : '';
  }
}

class LEGALASSOCIATEProcesosWidget extends StatefulWidget {
  const LEGALASSOCIATEProcesosWidget({super.key, this.filter});

  /// Filtro inicial: todos, redaccion, revision, rechazados, aprobados,
  /// nuevos o en_curso.
  final String? filter;

  static String routeName = 'LEGAL_ASSOCIATE_Procesos';
  static String routePath = '/lEGALASSOCIATEProcesos';

  @override
  State<LEGALASSOCIATEProcesosWidget> createState() =>
      _LEGALASSOCIATEProcesosWidgetState();
}

class _LEGALASSOCIATEProcesosWidgetState
    extends State<LEGALASSOCIATEProcesosWidget> {
  late LEGALASSOCIATEProcesosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _scroll = ScrollController();

  static const _pageSize = 20;

  late List<_Filter> _filters;
  late _Filter _filter;
  final List<_Process> _items = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALASSOCIATEProcesosModel());

    final home = _kHomeFilters.where((f) => f.key == widget.filter);
    _filters = [..._kFilters];
    if (home.isNotEmpty) _filters.insert(1, home.first);
    _filter = _filters.firstWhere((f) => f.key == widget.filter,
        orElse: () => _kFilters.first);

    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _model.dispose();
    super.dispose();
  }

  void _select(_Filter f) {
    if (f.key == _filter.key) return;
    setState(() {
      _filter = f;
      _items.clear();
      _page = 0;
      _hasMore = true;
      _loading = false;
      _requestId++;
    });
    _loadMore();
  }

  /// Trae la página siguiente. El backend ordena por updatedAt DESC.
  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    final id = _requestId;
    safeSetState(() => _loading = true);
    final res = await DOVIAAPILegalProcessContextGroup
        .listLegalProcessesAssociateCall
        .call(
      authToken: currentAuthenticationToken ?? '',
      status: _filter.statuses,
      page: '${_page + 1}',
      limit: '$_pageSize',
    );
    if (!mounted || id != _requestId) return;
    final raw = res.succeeded ? getJsonField(res.jsonBody, r'$.data') : null;
    final chunk = raw is List
        ? raw.whereType<Map<String, dynamic>>().map(_Process.new).toList()
        : <_Process>[];
    setState(() {
      _loading = false;
      if (!res.succeeded) {
        _hasMore = false;
        return;
      }
      _page++;
      _items.addAll(chunk);
      _hasMore = chunk.length == _pageSize;
    });
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
              CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverToBoxAdapter(
                    child: wrapWithModel(
                      model: _model.legalAssociateHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LegalAssociateHeaderWidget(
                        titleText: 'Procesos',
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildFilters(context)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                    sliver: SliverLayoutBuilder(builder: (context, c) {
                      // Tablet: dos columnas como en el diseño.
                      final cols = c.crossAxisExtent >= 700 ? 2 : 1;
                      final rows = (_items.length / cols).ceil();
                      return SliverList.separated(
                        itemCount: rows + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, row) {
                          if (row == rows) return _buildFooter(context);
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var k = 0; k < cols; k++) ...[
                                  if (k > 0) const SizedBox(width: 16),
                                  Expanded(
                                    child: row * cols + k < _items.length
                                        ? _buildCard(
                                            context, _items[row * cols + k])
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.lEGALASSOCAITENavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const LEGALASSOCAITENavbarWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          for (final f in _filters)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _select(f),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: f.key == _filter.key
                        ? theme.primary
                        : const Color(0xFFCFE3E3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    f.label,
                    style: GoogleFonts.publicSans(
                      fontSize: 14,
                      fontWeight: f.key == _filter.key
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: f.key == _filter.key
                          ? Colors.white
                          : const Color(0xFF1F5F63),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: DoviaSpinner()),
      );
    }
    if (_items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No tienes procesos en este estado',
          textAlign: TextAlign.center,
          style: GoogleFonts.publicSans(
            fontSize: 14,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCard(BuildContext context, _Process p) {
    final theme = FlutterFlowTheme.of(context);
    final value =
        GoogleFonts.publicSans(fontSize: 14, color: theme.primaryText);
    final badge = _badge(p.status);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 150,
            child: p.image.isNotEmpty
                ? Image.network(
                    p.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                    cacheWidth: networkImageCacheWidth(),
                  )
                : _placeholder(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  p.name.isNotEmpty ? p.name : 'Propiedad',
                  style: GoogleFonts.publicSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: theme.primaryText),
                ),
                const SizedBox(height: 4),
                Text(p.address.isNotEmpty ? p.address : 'Sin dirección',
                    style: value),
                const SizedBox(height: 2),
                Text(_typeLabel(p.propertyType), style: value),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Estatus', style: value),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: badge.$2,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge.$1,
                        style: GoogleFonts.publicSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: badge.$3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      // La pantalla del trámite muestra el paso que
                      // corresponde al estado.
                      context.pushNamed(
                        LEGALASSOCIATEProcesos2Widget.routeName,
                        queryParameters: {
                          'processId': p.id,
                          'propertyName': p.name,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(
                      'Detalle del proceso',
                      style: GoogleFonts.publicSans(
                          fontSize: 14, color: Colors.white),
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

  Widget _placeholder() => Container(
        color: const Color(0xFFE3ECEC),
        child:
            const Icon(Icons.home_outlined, size: 48, color: Color(0xFF2F6F73)),
      );

  /// (texto, fondo, color de texto) según el estado del trámite.
  static (String, Color, Color) _badge(String status) {
    switch (status) {
      case 'DRAFTING':
        return (
          'En redacción',
          const Color(0xFFD6E4FF),
          const Color(0xFF1D5FD1)
        );
      case 'MEETING_SCHEDULED':
        return (
          'Reunión agendada',
          const Color(0xFFEFE3FF),
          const Color(0xFF7B3FD1)
        );
      case 'LEGAL_HQ_REVIEW':
        return (
          'En revisión Legal HQ',
          const Color(0xFFFFE7D1),
          const Color(0xFFE06A00)
        );
      case 'REJECTED':
        return ('Rechazado', const Color(0xFFFFE1E1), const Color(0xFFC90A0A));
      case 'APPROVED':
      case 'FINISHED':
        return ('Aprobado', const Color(0xFFE6F4EA), const Color(0xFF1E8E3E));
      default:
        return ('Pendiente', const Color(0xFFFFF3CC), const Color(0xFFD59E08));
    }
  }

  static String _typeLabel(String type) {
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
