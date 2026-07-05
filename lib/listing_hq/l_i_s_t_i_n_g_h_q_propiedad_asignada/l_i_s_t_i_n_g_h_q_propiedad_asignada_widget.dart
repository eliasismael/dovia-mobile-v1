import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/repositories/visits_repository.dart';
import '/core/result.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import 'package:provider/provider.dart';
import 'l_i_s_t_i_n_g_h_q_propiedad_asignada_model.dart';
export 'l_i_s_t_i_n_g_h_q_propiedad_asignada_model.dart';

/// Pantalla "Propiedad pendiente de Operative Listing".
///
/// Se abre desde el botón "Asignar" (Home / Propiedades) para visitas
/// `OPERATIVE_LISTER_VISIT` en substatus `READY_TO_ASSIGN_OPERATIVE_LISTING`
/// (es decir, sin operative lister asignado todavía). HQ elige fecha/hora y un
/// Operative Lister disponible y confirma la visita.
///
/// Nota: el flujo de "desvincular un operative ya asignado / reprogramar" no se
/// implementa porque el backend no expone un endpoint de desvinculación para el
/// rol LISTER_HQ (solo existe la vía admin, no usada por la app).
class LISTINGHQPropiedadAsignadaWidget extends StatefulWidget {
  const LISTINGHQPropiedadAsignadaWidget({
    super.key,
    this.visitId,
  });

  /// Id de la visita a asignar. Llega desde el botón "Asignar".
  final String? visitId;

  static String routeName = 'LISTING_HQ_PropiedadAsignada';
  static String routePath = '/lISTINGHQPropiedadAsignada';

  @override
  State<LISTINGHQPropiedadAsignadaWidget> createState() =>
      _LISTINGHQPropiedadAsignadaWidgetState();
}

class _LISTINGHQPropiedadAsignadaWidgetState
    extends State<LISTINGHQPropiedadAsignadaWidget> {
  late LISTINGHQPropiedadAsignadaModel _model;

  bool _loading = true;
  String? _loadError;

  // Datos de la propiedad / propietario (poblados desde el backend).
  String _ownerName = 'Nombre Apellido';
  String? _ownerAvatar;
  String _ownerPhone = '';
  String _propertyType = '—';
  String _address = '—';
  String _description = '';
  String? _proposedDateText;

  /// Slots propuestos por el propietario (`{ 'date', 'time' }`), para el selector.
  final List<Map<String, String>> _proposedSlots = [];
  final List<String> _rescheduleHistory = [];

  // Lister nuevo elegido para asignar.
  Map<String, dynamic>? _selectedOperative;
  Map<String, dynamic>? _initialLister;
  bool _isReassigning = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _submitting = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQPropiedadAsignadaModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Carga de datos
  // ---------------------------------------------------------------------------

  Future<void> _loadData() async {
    final visitId = widget.visitId ?? '';
    if (visitId.isEmpty) {
      safeSetState(() {
        _loading = false;
        _loadError = 'No se recibió el identificador de la visita.';
      });
      return;
    }

    final token = currentAuthenticationToken ?? '';

    final detailRes = await DOVIAAPIVisitContextGroup.getVisitDetailsCall.call(
      visitId: visitId,
      authToken: token,
    );

    if (!mounted) return;

    if (!detailRes.succeeded) {
      safeSetState(() {
        _loading = false;
        _loadError = 'No se pudo cargar la información de la propiedad.';
      });
      return;
    }

    // El detalle viene envuelto en `data` (convención del backend).
    final data = (getJsonField(detailRes.jsonBody, r'$.data') as Map?) ??
        (detailRes.jsonBody is Map
            ? detailRes.jsonBody as Map
            : <String, dynamic>{});

    final owner = data['ownerProfile'];
    if (owner is Map) {
      _ownerName = owner['fullName']?.toString() ?? _ownerName;
      _ownerAvatar = owner['avatar']?.toString();
      final phone = owner['phone'];
      if (phone is Map) {
        final cc = phone['countryCode']?.toString() ?? '';
        final num = phone['number']?.toString() ?? '';
        _ownerPhone = '$cc $num'.trim();
      }
    }

    final property = data['property'];
    if (property is Map) {
      _propertyType = property['propertyType']?.toString() ??
          property['name']?.toString() ??
          _propertyTypeFromListing(property['listingType']);
      _address =
          _deepString(property, ['location', 'address', 'fullAddress']) ??
              _address;
      _description =
          _deepString(property, ['description', 'raw']) ?? _description;
    }

    // Slots propuestos por el propietario (2 obligatorios + 1 opcional).
    final visit = data['visit'];
    if (visit is Map) {
      final proposed = (visit['proposedTimeSlots'] as List?) ??
          (data['proposedTimeSlots'] as List?) ??
          const [];
      for (final slot in proposed) {
        if (slot is! Map) continue;
        _proposedSlots.add({
          'date': slot['date']?.toString() ?? '',
          'time': slot['time']?.toString() ?? '',
        });
      }

      // Texto resumen para el cuerpo de la pantalla: slot confirmado si existe,
      // de lo contrario las opciones propuestas por el propietario.
      final confirmed = visit['confirmedTimeSlot'] ?? visit['confirmedSlot'];
      if (confirmed is Map) {
        _proposedDateText =
            'Fecha: ${confirmed['date'] ?? '—'}\nHora: ${confirmed['time'] ?? '—'}';
      } else if (_proposedSlots.isNotEmpty) {
        _proposedDateText = _proposedSlots
            .map((s) =>
                [s['date'], s['time']].where((v) => v!.isNotEmpty).join(' '))
            .where((s) => s.isNotEmpty)
            .join('\n');
      }
    }

    final listerData = data['lister'];
    if (listerData is Map) {
      _initialLister = {
        'id': listerData['id'],
        'name':
            '${listerData['firstName'] ?? listerData['name'] ?? ''} ${listerData['lastName'] ?? ''}'
                .trim(),
        'photoUrl': listerData['avatar'] ?? listerData['photoUrl'],
      };
      _selectedOperative = _initialLister;
    }

    // Historial de reagendamiento desde el overview (mensajes del flujo).
    await _loadRescheduleHistory(visitId, token);

    if (!mounted) return;
    safeSetState(() => _loading = false);
  }

  Future<void> _loadRescheduleHistory(String visitId, String token) async {
    final res =
        await DOVIAAPIVisitContextGroup.getListerHqVisitOverviewCall.call(
      visitId: visitId,
      authToken: token,
    );
    if (!res.succeeded) return;

    final body = res.jsonBody;
    final messages = (getJsonField(body, r'$.data.messages') as List?) ??
        (getJsonField(body, r'$.messages') as List?) ??
        const [];

    for (final m in messages) {
      if (m is! Map) continue;
      final process = (m['process']?.toString() ?? '').toLowerCase();
      if (process.contains('reagend')) {
        final author = m['createdBy'] is Map
            ? (m['createdBy']['name']?.toString() ?? '')
            : '';
        final text = m['message']?.toString() ?? '';
        _rescheduleHistory
            .add([author, text].where((s) => s.isNotEmpty).join(': '));
      }
    }
  }

  String _propertyTypeFromListing(dynamic listingType) {
    if (listingType is List && listingType.isNotEmpty) {
      return listingType.map((e) => e.toString()).join(', ');
    }
    return '—';
  }

  String? _deepString(Map map, List<String> path) {
    dynamic current = map;
    for (final key in path) {
      if (current is Map && current[key] != null) {
        current = current[key];
      } else {
        return null;
      }
    }
    final value = current?.toString();
    return (value == null || value.isEmpty) ? null : value;
  }

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  Future<void> _openMatchmaking() async {
    // Se abre como página dedicada (no modal). Al elegir un operative y tocar
    // "Aceptar y Continuar" se asigna al hueco y se vuelve a esta pantalla,
    // donde "Confirmar visita y notificar" hace el commit final.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (pageContext) => Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            child: custom_widgets.ListingHQMatchmakingSelectorWidget(
              width: double.infinity,
              height: double.infinity,
              propertyId: widget.visitId ?? '',
              proposedSlots: _proposedSlots,
              ownerPhone: _ownerPhone,
              onClose: () => Navigator.of(pageContext).pop(),
              onOperativeSelected: (operative, date, time) {
                Navigator.of(pageContext).pop();
                setState(() {
                  _selectedOperative = operative;
                  _selectedDate = date;
                  _selectedTime = time;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAssignment() async {
    if (_selectedOperative == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un Operative Listing, fecha y hora.'),
        ),
      );
      return;
    }

    safeSetState(() => _submitting = true);
    final repo = context.read<VisitsRepository>();
    final res = await repo.assignVisit(
      propertyId: widget.visitId ?? '',
      operativeId: _selectedOperative!['id'],
      date: _selectedDate!,
      time: _selectedTime!,
    );

    if (!mounted) return;
    safeSetState(() => _submitting = false);

    if (res.isSuccess) {
      await showDialog(
        context: context,
        builder: (ctx) => const Dialog(
          backgroundColor: Colors.transparent,
          child: PopupExitoWidget(
            title: '¡Visita Asignada!',
            text:
                'La visita ha sido confirmada y se enviaron las notificaciones.',
          ),
        ),
      );
      if (mounted) {
        context.goNamed('LISTING_HQ_Home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.errorOrNull ?? 'No se pudo asignar.')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Estilos auxiliares
  // ---------------------------------------------------------------------------

  TextStyle _sectionTitleStyle() =>
      FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
            fontSize: 14.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
          );

  TextStyle _subTextStyle() => FlutterFlowTheme.of(context).bodyMedium.override(
        font: GoogleFonts.inter(),
        color: FlutterFlowTheme.of(context).secondaryText,
        fontSize: 13.0,
        letterSpacing: 0.0,
      );

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width * 0.45;

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
                      model: _model.lISTINGHQHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQHeaderWidget(
                        titleText: 'Propiedad pendiente\nde Operative Listing',
                      ),
                    ),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.only(top: 80.0),
                        child: CircularProgressIndicator(),
                      )
                    else if (_loadError != null)
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(_loadError!,
                            textAlign: TextAlign.center,
                            style: _subTextStyle()),
                      )
                    else
                      _buildContent(cardWidth),
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
                      model: _model.lISTINGHQNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQNavbarWidget(),
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

  Widget _buildContent(double cardWidth) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
            child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOwnerCard(cardWidth),
                    _buildListerCard(cardWidth),
                  ],
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOwnerCard(constraints.maxWidth),
                    const SizedBox(height: 16.0),
                    _buildListerCard(constraints.maxWidth),
                  ],
                );
              }
            }),
          ),
          const SizedBox(height: 20.0),
          Text('Tipo de vivienda', style: _sectionTitleStyle()),
          const SizedBox(height: 4.0),
          Text(_propertyType, style: _subTextStyle()),
          const SizedBox(height: 12.0),
          Text('Dirección', style: _sectionTitleStyle()),
          const SizedBox(height: 4.0),
          Text(_address, style: _subTextStyle()),
          if (_description.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Text(_description, style: _subTextStyle()),
          ],
          const SizedBox(height: 20.0),
          Text('Fecha Ingresada por el propietario para la visita',
              style: _sectionTitleStyle()),
          const SizedBox(height: 4.0),
          Text(_proposedDateText ?? 'Por definir', style: _subTextStyle()),
          const SizedBox(height: 12.0),
          Text('Propietario registrado', style: _subTextStyle()),
          if (_rescheduleHistory.isNotEmpty) ...[
            const SizedBox(height: 20.0),
            Text('Fecha De Asignaciones Anteriores',
                style: _sectionTitleStyle()),
            const SizedBox(height: 4.0),
            ..._rescheduleHistory.map(
              (h) => Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(h, style: _subTextStyle()),
              ),
            ),
          ],
          const SizedBox(height: 12.0),
          Text('Documentos', style: _sectionTitleStyle()),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Icon(Icons.description,
                  color: FlutterFlowTheme.of(context).primary, size: 16),
              const SizedBox(width: 4),
              Text('Acuerdo firmado',
                  style: _subTextStyle()
                      .copyWith(color: FlutterFlowTheme.of(context).primary)),
              const SizedBox(width: 16),
              Icon(Icons.verified_user,
                  color: FlutterFlowTheme.of(context).primary, size: 16),
              const SizedBox(width: 4),
              Text('Certificación',
                  style: _subTextStyle()
                      .copyWith(color: FlutterFlowTheme.of(context).primary)),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
            child: wrapWithModel(
              model: _model.primaryButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: _initialLister != null && !_isReassigning
                  ? PrimaryButtonWidget(
                      text: 'Organizar información de la propiedad',
                      onTap: () async {
                        safeSetState(() {
                          _selectedOperative = null;
                          _isReassigning = true;
                        });
                      },
                    )
                  : PrimaryButtonWidget(
                      text: _submitting
                          ? 'Confirmando...'
                          : 'Confirmar visita y notificar',
                      onTap: () async {
                        if (!_submitting && _selectedOperative != null) {
                          await _confirmAssignment();
                        } else if (_selectedOperative == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Debe seleccionar un Operative Lister primero.')),
                          );
                        }
                      },
                    ),
            ),
          ),
          const SizedBox(height: 100.0),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tarjetas
  // ---------------------------------------------------------------------------

  Widget _buildOwnerCard(double width) {
    return Container(
      width: width,
      height: 270.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: FlutterFlowTheme.of(context).primary),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: _ownerAvatar != null && _ownerAvatar!.isNotEmpty
                  ? Image.network(_ownerAvatar!,
                      width: 120.0, height: 120.0, fit: BoxFit.cover)
                  : Image.asset('assets/images/nahid_photo.png',
                      width: 120.0, height: 120.0, fit: BoxFit.cover),
            ),
            _buildCardBadge('Información de propietario'),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
              child: Text(
                _ownerName,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListerCard(double width) {
    final lister = _selectedOperative;

    Widget child;
    if (lister != null) {
      child = Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              lister['photoUrl'] ?? 'https://i.pravatar.cc/150',
              width: 120.0,
              height: 120.0,
              fit: BoxFit.cover,
            ),
          ),
          _buildCardBadge('Información Operative\nListing Associate'),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
            child: Text(
              lister['name'] ?? 'Nombre Apellido',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      );
    } else {
      child = InkWell(
        onTap: _openMatchmaking,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).accent1,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: FlutterFlowTheme.of(context).primary,
                size: 30.0,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
              child: Text(
                'Asignar Operative\nListing Associate',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w500),
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: width,
      height: 270.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: FlutterFlowTheme.of(context).primary),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
        child: child,
      ),
    );
  }

  Widget _buildCardBadge(String label) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).accent1,
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: 12.0,
                letterSpacing: 0.0,
              ),
        ),
      ),
    );
  }
}
