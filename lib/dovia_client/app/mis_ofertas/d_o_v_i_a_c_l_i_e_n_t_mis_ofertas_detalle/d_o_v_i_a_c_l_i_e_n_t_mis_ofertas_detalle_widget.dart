import '/core/result.dart';
import '/domain/client_offer_detail.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/repositories/offers_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../cancelar_oferta_modal_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_detalle_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_detalle_model.dart';

/// Detalle de una oferta que el cliente envió: la propuesta congelada, en sólo
/// lectura.
///
/// La pantalla no edita nada —para cambiar el trato están la contraoferta y el
/// retiro—, así que los campos se dibujan como cajas de texto inhabilitadas.
/// El pie depende del desenlace:
/// - en juego → [Retirar Oferta] y [Aceptar], que sólo vuelve al listado;
/// - rechazada → sin acciones, con el motivo que escribió el propietario.
class DOVIACLIENTMisOfertasDetalleWidget extends StatefulWidget {
  const DOVIACLIENTMisOfertasDetalleWidget({super.key, this.offerId});

  final String? offerId;

  static String routeName = 'DOVIA_CLIENT_MisOfertasDetalle';
  static String routePath = '/dOVIACLIENTMisOfertasDetalle';

  @override
  State<DOVIACLIENTMisOfertasDetalleWidget> createState() =>
      _DOVIACLIENTMisOfertasDetalleWidgetState();
}

class _DOVIACLIENTMisOfertasDetalleWidgetState
    extends State<DOVIACLIENTMisOfertasDetalleWidget> {
  late DOVIACLIENTMisOfertasDetalleModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _aqua = Color(0xFF007376);
  static const Color _text = Color(0xFF00444B);
  static const Color _destructive = Color(0xFFE44444);
  static const Color _ownerFieldBg = Color(0xFFD9D7D7);
  static const Color _proposalFieldBg = Color(0xFFFAFAFA);
  static const Color _fieldText = Color(0xFF888888);

  ClientOfferDetail? _detail;
  bool _isLoading = true;
  bool _isWithdrawing = false;
  bool _requirementsExpanded = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisOfertasDetalleModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
      _loadOffer();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadOffer() async {
    final offerId = widget.offerId;
    final result = await context.read<OffersRepository>().loadMyOfferDetail(
          offerId ?? '',
        );
    if (!mounted) return;

    safeSetState(() {
      _isLoading = false;
      switch (result) {
        case Success(:final data):
          _detail = data;
          _errorMessage = null;
          break;
        case Failure(:final message):
          _detail = null;
          _errorMessage = message;
          break;
      }
    });
  }

  /// Retirar es rechazar la negociación desde el lado del cliente, con el
  /// motivo obligatorio del modal: el mismo camino que la tarjeta del listado.
  Future<void> _withdraw() async {
    final offerId = widget.offerId;
    if (offerId == null || offerId.isEmpty) return;

    final reason = await showCancelarOfertaModal(context);
    if (reason == null || !mounted) return;

    safeSetState(() => _isWithdrawing = true);
    final result = await context.read<OffersRepository>().withdrawMyOffer(
          offerId: offerId,
          reason: reason,
        );
    if (!mounted) return;
    safeSetState(() => _isWithdrawing = false);

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Retiramos tu oferta.'),
            backgroundColor: Color(0xFF555555),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.safePop();
        break;
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFE85D75),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
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
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: DOVIASHAREDHeaderWidget(
                      title: _detail?.title ?? 'Oferta realizada',
                      showMap: false,
                      showCurrency: false,
                      showLogo: false,
                    ),
                  ),
                  Expanded(child: _buildBody()),
                ],
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          0.0,
                          15.0,
                          100.0,
                        ),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIACLIENTNavbarWidget(
                        activeTab: DOVIACLIENTMisOfertasWidget.routeName,
                      ),
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _aqua));
    }

    if (_errorMessage != null || _detail == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage ?? 'No pudimos cargar tu oferta.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14.0, color: _text),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  safeSetState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadOffer();
                },
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w600,
                    color: _aqua,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 130.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final section in detail.ownerSections)
            _section(section, background: _ownerFieldBg),
          const Padding(
            padding: EdgeInsets.only(bottom: 18.0),
            child: Divider(height: 1.0, thickness: 1.0, color: _aqua),
          ),
          Text(
            'Tu propuesta',
            style: GoogleFonts.publicSans(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: _aqua,
            ),
          ),
          const SizedBox(height: 18.0),
          for (final section in detail.proposalSections)
            _section(section, background: _proposalFieldBg),
          if (detail.isRent) ...[
            _complexRequirements(detail),
            const SizedBox(height: 18.0),
          ],
          if (detail.isRejected) _rejectionBanner(detail) else _actions(detail),
        ],
      ),
    );
  }

  Widget _section(OfferDetailSection section, {required Color background}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null) ...[
          Text(
            section.title!,
            style: GoogleFonts.publicSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: _text,
            ),
          ),
          const SizedBox(height: 12.0),
        ],
        ..._rows(section.fields, background),
      ],
    );
  }

  /// Los campos marcados como medios se aparean de a dos, como en el diseño.
  List<Widget> _rows(List<OfferDetailField> fields, Color background) {
    final rows = <Widget>[];
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      final next = i + 1 < fields.length ? fields[i + 1] : null;
      if (field.half && next != null && next.half) {
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _field(field, background)),
              const SizedBox(width: 17.0),
              Expanded(child: _field(next, background)),
            ],
          ),
        );
        i++;
        continue;
      }
      rows.add(_field(field, background));
    }
    return rows;
  }

  Widget _field(OfferDetailField field, Color background) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: GoogleFonts.publicSans(
            fontSize: 14.0,
            letterSpacing: 0.28,
            color: _text,
          ),
        ),
        const SizedBox(height: 12.0),
        if (field.kind == OfferDetailFieldKind.currency)
          _currencyChips(field.value)
        else
          Container(
            width: double.infinity,
            height: field.kind == OfferDetailFieldKind.textArea ? 104.0 : 42.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Align(
              alignment: field.kind == OfferDetailFieldKind.textArea
                  ? Alignment.topLeft
                  : Alignment.centerLeft,
              child: Text(
                field.value,
                style: GoogleFonts.publicSans(
                  fontSize: 14.0,
                  letterSpacing: 0.28,
                  color: _fieldText,
                  height:
                      field.kind == OfferDetailFieldKind.textArea ? 1.5 : null,
                ),
              ),
            ),
          ),
        const SizedBox(height: 18.0),
      ],
    );
  }

  /// El selector de moneda del formulario, congelado: se ve cuál eligió el
  /// cliente pero no se puede cambiar.
  Widget _currencyChips(String selected) {
    return Row(
      children: [
        Expanded(child: _currencyChip('USD', selected == 'USD')),
        const SizedBox(width: 17.0),
        Expanded(child: _currencyChip('Quetzales', selected == 'Quetzales')),
      ],
    );
  }

  Widget _currencyChip(String label, bool isSelected) {
    return Container(
      height: 42.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? _aqua : Colors.white,
        border: Border.all(color: _aqua),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Text(
        label,
        style: GoogleFonts.publicSans(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : _aqua,
        ),
      ),
    );
  }

  /// Requisitos del complejo que el inquilino aceptó al enviar la propuesta:
  /// el desplegable con lo que declaró el listado y, debajo, la lista fija de
  /// usos prohibidos que firma toda oferta de renta.
  Widget _complexRequirements(ClientOfferDetail detail) {
    const prohibited = [
      'Airbnb',
      'Subarrendamiento',
      'Eventos',
      'Mascotas',
      'Otros (según listing)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: const Color(0xFFDFDFDF)),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => safeSetState(
                    () => _requirementsExpanded = !_requirementsExpanded),
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 14.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Requisitos del complejo',
                          style: GoogleFonts.publicSans(
                              fontSize: 14.0, color: _text),
                        ),
                      ),
                      Icon(
                        _requirementsExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: _aqua,
                        size: 22.0,
                      ),
                    ],
                  ),
                ),
              ),
              if (_requirementsExpanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 12.0),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFDFDFDF))),
                  ),
                  child: Text(
                    detail.complexRequirements.isNotEmpty
                        ? detail.complexRequirements
                        : 'El listado no declaró requisitos adicionales.',
                    style: GoogleFonts.publicSans(
                        fontSize: 14.0, height: 1.5, color: _fieldText),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFDDE9E9),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entiendo que en este complejo NO se permite:',
                style: GoogleFonts.publicSans(
                    fontSize: 14.0, fontWeight: FontWeight.w600, color: _text),
              ),
              const SizedBox(height: 8.0),
              for (final rule in prohibited)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    '• $rule',
                    style: GoogleFonts.publicSans(fontSize: 14.0, color: _text),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actions(ClientOfferDetail detail) {
    final accept = SizedBox(
      height: 42.0,
      child: OutlinedButton(
        onPressed: _isWithdrawing ? null : () => context.safePop(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _aqua),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Text(
          'Aceptar',
          style: GoogleFonts.publicSans(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: _aqua,
          ),
        ),
      ),
    );

    if (!detail.canWithdraw) {
      return SizedBox(width: double.infinity, child: accept);
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42.0,
            child: OutlinedButton(
              onPressed: _isWithdrawing ? null : _withdraw,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _destructive),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              child: _isWithdrawing
                  ? const SizedBox(
                      width: 18.0,
                      height: 18.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: _destructive,
                      ),
                    )
                  : Text(
                      'Retirar Oferta',
                      style: GoogleFonts.publicSans(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: _destructive,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 17.0),
        Expanded(child: accept),
      ],
    );
  }

  /// Motivo que redactó el propietario. Es lo único que reemplaza a los
  /// botones cuando la oferta ya no está en juego.
  Widget _rejectionBanner(ClientOfferDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE9E9),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Oferta Rechazada:',
            style: GoogleFonts.publicSans(
              fontSize: 14.0,
              letterSpacing: 0.28,
              color: _text,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            detail.rejectionReason.isNotEmpty
                ? detail.rejectionReason
                : 'El propietario no dejó un motivo.',
            style: GoogleFonts.publicSans(
              fontSize: 14.0,
              letterSpacing: 0.28,
              height: 1.5,
              color: _text,
            ),
          ),
        ],
      ),
    );
  }
}
