import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/domain/property_types.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/listing_hq/listing_hq_ui.dart';
import '/listing_hq/listing_hq_visit_property.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad/l_i_s_t_i_n_g_h_q_propiedad_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_i_s_t_i_n_g_h_q_checklists_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_i_s_t_i_n_g_h_q_checklists_model.dart';

class _ChecklistCardData {
  final String visitId;
  final String propertyId;
  final String title;
  final String address;
  final String age;

  _ChecklistCardData({
    required this.visitId,
    required this.propertyId,
    required this.title,
    required this.address,
    required this.age,
  });
}

/// Checklists que mandó el Operative Lister y esperan la revisión de HQ. Es
/// el mismo carril "Propiedades pendientes por publicar" del inicio, entero y
/// en su propia sección de la barra.
class LISTINGHQChecklistsWidget extends StatefulWidget {
  const LISTINGHQChecklistsWidget({super.key});

  static String routeName = 'LISTING_HQ_Checklists';
  static String routePath = '/lISTINGHQChecklists';

  @override
  State<LISTINGHQChecklistsWidget> createState() =>
      _LISTINGHQChecklistsWidgetState();
}

class _LISTINGHQChecklistsWidgetState extends State<LISTINGHQChecklistsWidget>
    with RouteAware {
  late LISTINGHQChecklistsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Visita hecha y checklist cargado: falta que HQ lo revise y publique.
  static const String _kPublishSubstatus = 'READY_TO_PUBLISH';

  Future<List<_ChecklistCardData>>? _checklistsFuture;

  /// Búsqueda local por dirección.
  String _query = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQChecklistsModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _checklistsFuture = _fetchChecklists();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is ModalRoute<void>) {
      appRouteObserver.subscribe(this, route);
    }
  }

  /// Al volver del detalle: publicar o pedir cambios saca la visita de este
  /// substatus, así que la lista se relee.
  @override
  void didPopNext() {
    _handleRefresh();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (!mounted) return;
    setState(() {
      _checklistsFuture = _fetchChecklists();
    });
  }

  /// "Reciente" el primer día y "N Días" después, como en el inicio.
  String _ageLabel(dynamic updatedAt) {
    final parsed = DateTime.tryParse(updatedAt?.toString() ?? '');
    if (parsed == null) return 'Pendiente';
    final days = DateTime.now().toUtc().difference(parsed.toUtc()).inDays;
    if (days <= 0) return 'Reciente';
    return days == 1 ? '1 Día' : '$days Días';
  }

  Map<String, dynamic>? _deepMap(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur is Map ? cur as Map<String, dynamic> : null;
  }

  Future<List<_ChecklistCardData>> _fetchChecklists() async {
    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPIVisitContextGroup.getListerHqVisitsCall.call(
      authToken: token,
      substatus: _kPublishSubstatus,
      page: '1',
      limit: '50',
    );
    if (!res.succeeded) return [];
    return Future.wait(listerHqVisitsFrom(res.jsonBody).map((v) async {
      final propertyId = listerHqVisitPropertyId(v);
      final prop = await listerHqVisitProperty(v, token);
      String address = '';
      String title = 'Propiedad';
      if (prop is Map) {
        final locAddr = _deepMap(prop, ['location', 'address']);
        address = locAddr?['fullAddress']?.toString() ??
            locAddr?['street']?.toString() ??
            '';
        title = propertyShortTitle(prop,
            fallback: prop['name']?.toString() ?? 'Propiedad');
      }
      return _ChecklistCardData(
        visitId: v['id']?.toString() ?? '',
        propertyId: propertyId,
        title: title,
        address: address,
        age: _ageLabel(v['updatedAt']),
      );
    }));
  }

  bool _matches(_ChecklistCardData card) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final haystack = '${card.title} ${card.address}'.toLowerCase();
    return q.split(RegExp(r'\s+')).every(haystack.contains);
  }

  Widget _buildChecklistCard(_ChecklistCardData card) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14.0),
        decoration: ListingHqUi.cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.publicSans(
                          color: ListingHqUi.textDark,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        card.address.isNotEmpty
                            ? card.address
                            : 'Sin dirección registrada',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.publicSans(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 13.0,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                ListingHqUi.statusPill(card.age, ListingHqUi.pending),
              ],
            ),
            const SizedBox(height: 8.0),
            ListingHqUi.tag(context, 'Visita realizada'),
            const SizedBox(height: 12.0),
            ListingHqUi.cardButton(
              'Revisar checklist',
              () => context.pushNamed(
                LISTINGHQPropiedadWidget.routeName,
                queryParameters: {
                  'visitId': serializeParam(card.visitId, ParamType.String),
                  'propertyId': card.propertyId.isEmpty
                      ? null
                      : serializeParam(card.propertyId, ParamType.String),
                }.withoutNulls,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: ListingHqUi.emptyText(context, text)),
      );

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
              RefreshIndicator(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  // Lo que ocupa el indicador de inicio (iPhone), que ya no
                  // descuenta el SafeArea: el final queda sobre la barra.
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.viewPaddingOf(context).bottom),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      wrapWithModel(
                        model: _model.lISTINGHQHeaderModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const LISTINGHQHeaderWidget(
                          titleText: 'Checklists',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 20.0, 20.0, 110.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ListingHqSearchField(
                              hintText: 'Buscar por dirección',
                              controller: _model.textController,
                              onChanged: (v) => setState(() => _query = v),
                              onClear: () {
                                _model.textController?.clear();
                                setState(() => _query = '');
                              },
                            ),
                            const ListingHqSectionHeader(
                                title: 'Checklists por revisar'),
                            FutureBuilder<List<_ChecklistCardData>>(
                              future: _checklistsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 40.0),
                                    child: Center(child: DoviaSpinner()),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return _buildMessage(
                                      'No pudimos cargar los checklists.');
                                }
                                final cards = (snapshot.data ?? [])
                                    .where(_matches)
                                    .toList();
                                if (cards.isEmpty) {
                                  return _buildMessage(_query.trim().isEmpty
                                      ? 'No hay checklists por revisar.'
                                      : 'Ningún checklist coincide con la búsqueda.');
                                }
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      cards.map(_buildChecklistCard).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.lISTINGHQNavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const LISTINGHQNavbarWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
