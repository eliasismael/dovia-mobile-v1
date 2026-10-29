import '/core/network_image_size.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/legal_hq/l_e_g_a_l_h_q_navbar/l_e_g_a_l_h_q_navbar_widget.dart';
import '/legal_hq/legal_h_q_header/legal_h_q_header_widget.dart';
import '/legal_hq/legal_hq_process_data.dart';
import '/legal_hq/l_e_g_a_l_h_q_procesos/l_e_g_a_l_h_q_procesos_widget.dart';
import '/legal_hq/l_e_g_a_l_h_q_procesos_casos_con_hipoteca/l_e_g_a_l_h_q_procesos_casos_con_hipoteca_widget.dart';
import '/legal_hq/l_e_g_a_l_h_q_revision_documentos_propiedades/l_e_g_a_l_h_q_revision_documentos_propiedades_widget.dart';
import '/legal_hq/l_e_g_a_l_h_q_post_venta/l_e_g_a_l_h_q_post_venta_widget.dart';
import '/listing_hq/listing_hq_ui.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_e_g_a_l_h_q_home_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_e_g_a_l_h_q_home_model.dart';

/// Roles autorizados a ver este panel.
const _kLegalHQRoles = <String>{'LEGAL_OFFICER', 'LEGAL_HQ', 'HQ_ADMIN'};

class LEGALHQHomeWidget extends StatefulWidget {
  const LEGALHQHomeWidget({super.key});

  static String routeName = 'LEGAL_HQ_Home';
  static String routePath = '/lEGALHQHome';

  @override
  State<LEGALHQHomeWidget> createState() => _LEGALHQHomeWidgetState();
}

class _LEGALHQHomeWidgetState extends State<LEGALHQHomeWidget> {
  late LEGALHQHomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Futures por carril ────────────────────────────────────────────────────

  late Future<List<LegalHqProcess>> _publicationFuture;
  late Future<List<LegalHqProcess>> _associateFuture;
  late Future<List<LegalHqProcess>> _mortgageFuture;

  /// Texto de la barra de búsqueda (ID de inmueble o dirección).
  String _query = '';

  /// Expediente que se está reclamando ahora mismo, para bloquear el botón.
  String? _claimingProcessId;

  static const Color _aqua = Color(0xFF007376);
  static const Color _textDark = Color(0xFF00444B);

  // ── Ciclo de vida ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALHQHomeModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Validación de rol: este panel es exclusivo del perfil Legal HQ.
      if (!_kLegalHQRoles.contains(FFAppState().UserRole)) {
        context.safePop();
        return;
      }
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  void _loadData() {
    // Carril 1 — inmuebles subidos por propietarios/agentes que requieren
    // auditoría legal antes de ser visibles en el marketplace de DOVIA.
    // Solo las que el Lister HQ ya mandó: el back las pasa a LEGAL_HQ_REVIEW
    // (con los documentos aprobados copiados) cuando aprueba la visita. Antes,
    // en IN_PROGRESS, el expediente existe pero todavía no tiene documentos.
    _publicationFuture = LegalHqProcessApi.fetchBoth(
      status: 'LEGAL_HQ_REVIEW',
      category: kCategoryPublication,
    );

    // Carril 2 — compraventas al contado y arrendamientos que están siendo
    // trabajados por los Legal Associates. El endpoint no filtra por asociado,
    // así que descartamos los que todavía no tienen uno asignado.
    _associateFuture = LegalHqProcessApi.fetchBoth(
      status: kActiveStatuses,
      category: kAssociateCategories,
    ).then((processes) =>
        processes.where((process) => process.hasLegalAssociate).toList());

    // Carril 3 — compraventas con crédito hipotecario. Se piden por categoría
    // (no por estado) para no perder las que aún no entraron al banco.
    _mortgageFuture = LegalHqProcessApi.fetchBoth(category: kCategoryMortgage);
  }

  /// Filtra por ID de inmueble o dirección con el texto de la búsqueda.
  List<LegalHqProcess> _applySearch(List<LegalHqProcess> processes) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return processes;
    return processes
        .where((process) =>
            process.propertyId.toLowerCase().contains(query) ||
            process.address.toLowerCase().contains(query) ||
            process.propertyName.toLowerCase().contains(query))
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
          // Sin SafeArea abajo: el contenido pasa por debajo de la barra
          // flotante hasta el borde de la pantalla.
          bottom: false,
          child: Stack(
            children: [
              // Fondo con gradiente
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),

              // Contenido desplazable
              SingleChildScrollView(
                // Lo que ocupa el indicador de inicio (iPhone), que ya no
                // descuenta el SafeArea: el final queda sobre la barra.
                padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // ── Cabecera: título, avisos y ajustes ───────────────
                    wrapWithModel(
                      model: _model.legalHQHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LegalHQHeaderWidget(
                        text: 'Inicio',
                        showBack: false,
                      ),
                    ),

                    // ── Barra de búsqueda ───────────────────────────────
                    _buildSearchBar(context),

                    // ── Carriles ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 120.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ────────────────────────────────────────────────
                          // CARRIL 1: pendientes por revisión para publicar
                          // ────────────────────────────────────────────────
                          _buildSectionHeader(
                            context,
                            title: 'Propiedades pendientes\n'
                                'por revisión para publicar',
                            onVerMas: () => _openProcesos('propiedades'),
                          ),
                          _buildFutureCarousel(
                            future: _publicationFuture,
                            emptyMessage:
                                'No hay propiedades pendientes por revisar',
                          ),

                          // ────────────────────────────────────────────────
                          // CARRIL 2: revisión del trabajo del Legal Associate
                          // ────────────────────────────────────────────────
                          _buildSectionHeader(
                            context,
                            title: 'Propiedades pendientes\n'
                                'por revisión de Legal Associate',
                            onVerMas: _openProcesos,
                          ),
                          _buildFutureCarousel(
                            future: _associateFuture,
                            emptyMessage:
                                'No hay expedientes en manos de Legal Associates',
                          ),

                          // ────────────────────────────────────────────────
                          // CARRIL 3: pendientes por hipotecas
                          // ────────────────────────────────────────────────
                          _buildSectionHeader(
                            context,
                            title: 'Propiedades pendientes\npor hipotecas',
                            onVerMas: () => _openProcesos('hipotecas'),
                          ),
                          _buildFutureCarousel(
                            future: _mortgageFuture,
                            emptyMessage:
                                'No hay trámites hipotecarios en curso',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Navbar: Inicio / Procesos ──────────────────────────────
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

  // ── Navegación ────────────────────────────────────────────────────────────

  Future<void> _openProcesos([String? filter]) async {
    await context.pushNamed(
      LEGALHQProcesosWidget.routeName,
      queryParameters: {'filter': filter}.withoutNulls,
    );
    if (mounted) safeSetState(_loadData);
  }

  /// Iniciar proceso: si el expediente todavía no tiene Legal HQ, primero lo
  /// reclama para este usuario. Sin ese paso el backend responde 403
  /// USER_NOT_RELATED_TO_PROCESS en el detalle y en las acciones del trámite.
  Future<void> _openProcess(LegalHqProcess process) async {
    if (!process.isAssignedToMe) {
      safeSetState(() => _claimingProcessId = process.id);
      final response = await LegalHqProcessApi.accept(process.id);
      if (!mounted) return;
      safeSetState(() => _claimingProcessId = null);

      if (!response.succeeded) {
        // 409: otro Legal HQ lo reclamó primero.
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

    // Mismo ruteo que el listado de Procesos: aprobados y finalizados se
    // auditan desde el cierre de operación.
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

    if (mounted) safeSetState(_loadData);
  }

  // ── Barra de búsqueda por ID de inmueble o dirección ──────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
      child: ListingHqSearchField(
        controller: _model.textController,
        hintText: 'Buscar por ID o dirección',
        onChanged: (value) => safeSetState(() => _query = value),
        onClear: () {
          _model.textController?.clear();
          safeSetState(() => _query = '');
        },
      ),
    );
  }

  // ── Carrusel con estados de carga / vacío ─────────────────────────────────

  Widget _buildFutureCarousel({
    required Future<List<LegalHqProcess>> future,
    required String emptyMessage,
  }) {
    // Alto de los avisos de carga y vacío. Con tarjetas, el carrusel toma el
    // alto de la más alta (la de hipotecas suma el estado bancario).
    const double height = 120.0;

    return FutureBuilder<List<LegalHqProcess>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: height,
            child: Center(
              child: DoviaSpinner(),
            ),
          );
        }

        final items = _applySearch(snapshot.data ?? []);

        if (items.isEmpty) {
          return ListingHqUi.emptyText(
            context,
            _query.trim().isEmpty
                ? emptyMessage
                : 'Sin resultados para "${_query.trim()}"',
          );
        }

        return ListingHqCarousel(
          height: null,
          children: [
            for (final process in items) _buildProcessCard(context, process),
          ],
        );
      },
    );
  }

  // ── Encabezado de carril (título + píldora "Ver más") ─────────────────────

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onVerMas,
  }) {
    return ListingHqSectionHeader(
      title: title,
      linkText: 'Ver más',
      onLinkTap: onVerMas,
    );
  }

  // ── Tarjeta de expediente ─────────────────────────────────────────────────

  Widget _buildProcessCard(BuildContext context, LegalHqProcess process) {
    final isMortgage = process.category == kCategoryMortgage ||
        kMortgageStatuses.contains(process.status);
    final statusStyle = legalHqStatusStyle(process.status);

    return Container(
      width: 300.0,
      decoration: ListingHqUi.cardDecoration(context),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Miniatura del inmueble
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: _buildPropertyImage(process.imageUrl),
          ),
          const SizedBox(width: 14.0),
          // Datos del expediente
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // El nombre de la casa identifica el expediente de un vistazo;
                // el ID y la dirección quedan como dato secundario.
                Text(
                  process.title,
                  style: GoogleFonts.publicSans(
                    color: _textDark,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6.0),
                Text(
                  'ID ${_shortId(process.propertyId)} · ${_addressLabel(process)}',
                  style: GoogleFonts.publicSans(
                    color: _aqua,
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6.0),
                // Hipotecas: badge de estado bancario. Resto de carriles:
                // método de pago preferido o fecha/hora de la solicitud.
                if (isMortgage)
                  ListingHqUi.statusPill(
                      statusStyle.label, statusStyle.background)
                else
                  Text(
                    _paymentOrRequestLabel(process),
                    style: GoogleFonts.publicSans(
                      color: _textDark,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6.0),
                Text(
                  'Podrás ganar: $_revenueLabel',
                  style: GoogleFonts.publicSans(
                    color: _aqua,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: double.infinity,
                  height: 30.0,
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
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                    child: _claimingProcessId == process.id
                        ? const DoviaSpinner(small: true, color: Colors.white)
                        : Text(
                            // Un expediente sin Legal HQ asignado se reclama al
                            // tocar el botón; uno propio se abre directamente.
                            process.isAssignedToMe
                                ? 'Ver Proceso'
                                : 'Iniciar Proceso',
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

  // ── Miniatura con respaldo local ──────────────────────────────────────────

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
        cacheWidth: networkImageCacheWidth(width: 72.0, height: 96.0),
      );
    }
    return Image.asset(
      'assets/images/casa_card_sobreMiVisita.png',
      width: 72.0,
      height: 96.0,
      fit: BoxFit.cover,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// `property.fullAddress` puede venir vacío; el nombre de la propiedad es el
  /// mejor respaldo antes de rendirse.
  String _addressLabel(LegalHqProcess process) {
    if (process.address.isNotEmpty) return process.address;
    if (process.propertyName.isNotEmpty) return process.propertyName;
    return 'Sin dirección';
  }

  /// El listado del HQ no trae el bloque `offer` (solo lo hace el detalle
  /// `GET /legal-processes/{id}`), así que el método de pago se deduce de la
  /// categoría del expediente. Para publicación, que no tiene comprador, el
  /// diseño muestra en su lugar la fecha y hora de la solicitud.
  String _paymentOrRequestLabel(LegalHqProcess process) {
    switch (process.category) {
      case kCategorySale:
      case 'SALE_CASH':
      case 'SALE_PURCHASE_PROMISE':
        return 'Pago al contado';
      case kCategoryMortgage:
        return 'Pago con hipoteca';
      case kCategoryRent:
        return 'Arrendamiento';
      default:
        return '${_formatDate(process.createdAt)} · ${_formatTime(process.createdAt)}';
    }
  }

  /// El estimado de ganancia que pide el diseño todavía no tiene fuente: ni el
  /// listado ni el detalle del proceso legal devuelven un monto, y las tarifas
  /// (SALE_FIRST_TRANCHE, etc.) viven en Global Settings sin endpoint expuesto
  /// al cliente. Hasta que exista, la tarjeta lo declara pendiente.
  static const String _revenueLabel = 'Por confirmar';

  /// El ID de inmueble del backend es un UUID: mostramos los primeros
  /// caracteres para que quepa en la tarjeta y siga siendo buscable.
  String _shortId(String propertyId) {
    if (propertyId.isEmpty) return 'Sin ID';
    return propertyId.length <= 8
        ? propertyId.toUpperCase()
        : propertyId.substring(0, 8).toUpperCase();
  }

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
}
