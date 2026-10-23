import '/core/network_image_size.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/legal_hq/l_e_g_a_l_h_q_navbar/l_e_g_a_l_h_q_navbar_widget.dart';
import '/legal_hq/legal_h_q_header/legal_h_q_header_widget.dart';
import '/legal_hq/legal_hq_process_data.dart';
import '/legal_hq/l_e_g_a_l_h_q_post_venta/l_e_g_a_l_h_q_post_venta_widget.dart';
import '/legal_hq/l_e_g_a_l_h_q_procesos_casos_con_hipoteca/l_e_g_a_l_h_q_procesos_casos_con_hipoteca_widget.dart';
import '/legal_hq/l_e_g_a_l_h_q_revision_documentos_propiedades/l_e_g_a_l_h_q_revision_documentos_propiedades_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_e_g_a_l_h_q_procesos_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_e_g_a_l_h_q_procesos_model.dart';

/// Filtros del listado, tal como los chips del diseño.
enum _ProcesosFilter { todos, propiedades, hipotecas, postVenta, aprobados }

extension _ProcesosFilterX on _ProcesosFilter {
  String get label {
    switch (this) {
      case _ProcesosFilter.todos:
        return 'Todos';
      case _ProcesosFilter.propiedades:
        return 'Propiedades';
      case _ProcesosFilter.hipotecas:
        return 'Hipotecas';
      case _ProcesosFilter.postVenta:
        return 'Post-venta';
      case _ProcesosFilter.aprobados:
        return 'Aprobados';
    }
  }

  /// Parámetro `category` que se manda al backend ('' = sin filtrar).
  String get category {
    switch (this) {
      case _ProcesosFilter.propiedades:
        return kCategoryPublication;
      case _ProcesosFilter.hipotecas:
        return kCategoryMortgage;
      default:
        return '';
    }
  }

  /// Parámetro `status`.
  String get status {
    switch (this) {
      case _ProcesosFilter.aprobados:
        return kClosedStatuses;
      case _ProcesosFilter.postVenta:
        // El backend no modela la post-venta como categoría propia; lo más
        // cercano son los expedientes ya finalizados.
        return 'FINISHED';
      default:
        return '';
    }
  }

  String get emptyMessage {
    switch (this) {
      case _ProcesosFilter.propiedades:
        return 'No hay propiedades pendientes de revisión';
      case _ProcesosFilter.hipotecas:
        return 'No hay trámites hipotecarios';
      case _ProcesosFilter.postVenta:
        return 'No hay expedientes de post-venta';
      case _ProcesosFilter.aprobados:
        return 'Todavía no hay expedientes aprobados';
      case _ProcesosFilter.todos:
        return 'No hay expedientes para revisar';
    }
  }
}

class LEGALHQProcesosWidget extends StatefulWidget {
  const LEGALHQProcesosWidget({super.key, this.filter});

  /// Filtro inicial (`propiedades`, `hipotecas`...) al entrar desde el
  /// "Ver más" de un carril del Home.
  final String? filter;

  static String routeName = 'LEGAL_HQ_Procesos';
  static String routePath = '/lEGALHQProcesos';

  @override
  State<LEGALHQProcesosWidget> createState() => _LEGALHQProcesosWidgetState();
}

class _LEGALHQProcesosWidgetState extends State<LEGALHQProcesosWidget> {
  late LEGALHQProcesosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<LegalHqProcess>> _processesFuture;

  _ProcesosFilter _filter = _ProcesosFilter.todos;
  String _query = '';
  String? _claimingProcessId;

  static const Color _aqua = Color(0xFF007376);
  static const Color _textDark = Color(0xFF00444B);
  static const Color _chipIdleBg = Color(0xFFCCE3E4);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALHQProcesosModel());
    _filter = _ProcesosFilter.values.firstWhere((f) => f.name == widget.filter,
        orElse: () => _ProcesosFilter.todos);
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _loadData() {
    _processesFuture = LegalHqProcessApi.fetchBoth(
      status: _filter.status,
      category: _filter.category,
    );
  }

  void _selectFilter(_ProcesosFilter filter) {
    if (_filter == filter) return;
    safeSetState(() {
      _filter = filter;
      _loadData();
    });
  }

  List<LegalHqProcess> _applySearch(List<LegalHqProcess> processes) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return processes;
    return processes
        .where((process) =>
            process.propertyId.toLowerCase().contains(query) ||
            process.address.toLowerCase().contains(query) ||
            process.propertyName.toLowerCase().contains(query) ||
            process.ownerName.toLowerCase().contains(query) ||
            process.clientName.toLowerCase().contains(query))
        .toList();
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
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.legalHQHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LegalHQHeaderWidget(
                        text: 'Procesos',
                      ),
                    ),
                    _buildSearchBar(context),
                    _buildFilterChips(context),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 100.0),
                      child: _buildList(context),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    wrapWithModel(
                      model: _model.lEGALHQNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LEGALHQNavbarWidget(),
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

  // ── Búsqueda ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
      child: Container(
        width: double.infinity,
        height: 48.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 15.0, 0.0),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextField(
                  controller: _model.textController,
                  focusNode: _model.textFieldFocusNode,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => safeSetState(() => _query = value),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Buscar por propiedad, ID, propietario o cliente',
                    hintStyle: GoogleFonts.publicSans(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  style: GoogleFonts.publicSans(
                    color: _textDark,
                    fontSize: 15.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              if (_query.isNotEmpty)
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    _model.textController?.clear();
                    safeSetState(() => _query = '');
                  },
                  child: Icon(
                    Icons.close,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 20.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Chips de filtro ───────────────────────────────────────────────────────

  Widget _buildFilterChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _ProcesosFilter.values.map((filter) {
            final isSelected = filter == _filter;
            return Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
              child: GestureDetector(
                onTap: () => _selectFilter(filter),
                child: Container(
                  height: 40.0,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _aqua : _chipIdleBg,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(
                    filter.label,
                    style: GoogleFonts.publicSans(
                      color: isSelected ? Colors.white : _aqua,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Listado ───────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context) {
    return FutureBuilder<List<LegalHqProcess>>(
      future: _processesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60.0),
            child: Center(child: DoviaSpinner()),
          );
        }

        final items = _applySearch(snapshot.data ?? []);

        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 60.0),
            child: Center(
              child: Text(
                _query.trim().isEmpty
                    ? _filter.emptyMessage
                    : 'Sin resultados para "${_query.trim()}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.publicSans(
                  color: _textDark,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final process in items)
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 15.0),
                child: _buildProcessCard(context, process),
              ),
          ],
        );
      },
    );
  }

  // ── Tarjeta ───────────────────────────────────────────────────────────────

  Widget _buildProcessCard(BuildContext context, LegalHqProcess process) {
    final statusStyle = legalHqStatusStyle(process.status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de portada
          SizedBox(
            width: double.infinity,
            height: 139.0,
            child: _buildPropertyImage(process.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  process.title,
                  style: GoogleFonts.publicSans(
                    color: _textDark,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                _cardLine(
                    'Tipo: ${legalHqOperationLabel(process.category, process.status)}'),
                if (process.clientName.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  _cardLine('Cliente: ${process.clientName}'),
                ],
                if (process.ownerName.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  _cardLine('Propietario: ${process.ownerName}'),
                ],
                if (process.legalAssociateName.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  _cardLine(
                      'Legal Associate asignado: ${process.legalAssociateName}'),
                ],
                const SizedBox(height: 8.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Estado actual',
                      style: GoogleFonts.publicSans(
                        color: _aqua,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Container(
                          height: 23.0,
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: statusStyle.background,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Text(
                            statusStyle.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.publicSans(
                              color: statusStyle.foreground,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                SizedBox(
                  width: double.infinity,
                  height: 31.0,
                  child: ElevatedButton(
                    onPressed: _claimingProcessId != null
                        ? null
                        : () => _openProcess(process),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _aqua,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _aqua.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: const BorderSide(color: _aqua),
                      ),
                    ),
                    child: _claimingProcessId == process.id
                        ? const DoviaSpinner(small: true, color: Colors.white)
                        : Text(
                            'Revisar',
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

  Widget _cardLine(String text) {
    return Text(
      text,
      style: GoogleFonts.publicSans(
        color: _textDark,
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPropertyImage(String imageUrl) {
    const fallback = Image(
      image: AssetImage('assets/images/casa_card_sobreMiVisita.png'),
      fit: BoxFit.cover,
      width: double.infinity,
      height: 139.0,
    );

    if (imageUrl.isEmpty) return fallback;

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 139.0,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
      cacheWidth: networkImageCacheWidth(width: double.infinity, height: 139.0),
    );
  }

  // ── Abrir expediente ──────────────────────────────────────────────────────

  /// Igual que en la Home: si el expediente no tiene Legal HQ, primero se
  /// reclama, porque el detalle exige ser el HQ asignado.
  Future<void> _openProcess(LegalHqProcess process) async {
    if (!process.isAssignedToMe) {
      safeSetState(() => _claimingProcessId = process.id);
      final response = await LegalHqProcessApi.accept(process.id);
      if (!mounted) return;
      safeSetState(() => _claimingProcessId = null);

      if (!response.succeeded) {
        final message = response.statusCode == 409
            ? 'Otro Legal HQ ya tomó este expediente'
            : 'No se pudo tomar el expediente. Intentá de nuevo';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        safeSetState(_loadData);
        return;
      }
      safeSetState(_loadData);
    }

    if (!mounted) return;

    // Los hipotecarios se trabajan de punta a punta desde la gestión bancaria,
    // que ya cubre el cierre aprobado y el rechazado; el resto de expedientes
    // ya aprobados o finalizados se auditan desde el cierre de operación, y
    // los demás entran a la revisión documental.
    final String routeName;
    if (process.category == kCategoryMortgage) {
      routeName = LEGALHQProcesosCasosConHipotecaWidget.routeName;
    } else if (process.status == 'APPROVED' || process.status == 'FINISHED') {
      routeName = LEGALHQPostVentaWidget.routeName;
    } else {
      routeName = LEGALHQRevisionDocumentosPropiedadesWidget.routeName;
    }

    await context.pushNamed(
      routeName,
      queryParameters: {
        'processId': serializeParam(process.id, ParamType.String),
      }.withoutNulls,
    );

    // Al volver puede haber cambiado el estado del expediente.
    if (mounted) safeSetState(_loadData);
  }
}
