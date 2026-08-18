import '/core/result.dart';
import '/domain/payment_models.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/repositories/payments_repository.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_h_c_l_i_e_n_t_planes_model.dart';
export 'd_h_c_l_i_e_n_t_planes_model.dart';

/// Tarjetas de los planes de DOVIA Home Premium.
///
/// Nombre, precio e intervalo salen de `GET /subscriptions/plans`; el `id` del
/// plan tapeado es lo que después se cobra. Los beneficios que lista cada
/// tarjeta siguen siendo texto fijo: son copy de marketing y el backend no los
/// modela.
///
/// El bloque se embebe en [DHCLIENTPlanesPageWidget] y en
/// [DCFormaPagoSuscripcion1Widget], así que no trae scaffold propio.
class DHCLIENTPlanesWidget extends StatefulWidget {
  const DHCLIENTPlanesWidget({super.key, this.onPlanSelected});

  /// Qué hacer cuando el cliente elige un plan.
  ///
  /// Lo decide la pantalla que embebe el bloque porque el paso siguiente
  /// depende de dónde esté parado el cliente: entrando por Planes hay que
  /// verificar la dirección antes de cobrar, pero en el paso de pago eso ya
  /// pasó y volver a pedirla deja al cliente dando vueltas sin poder
  /// contratar. Sin callback se asume la entrada por Planes.
  final void Function(SubscriptionPlan plan)? onPlanSelected;

  /// Plan que el cliente tapeó, para que la pantalla de pago sepa qué cobrar.
  ///
  /// Va en un campo estático porque la navegación de la app es sólo por nombre
  /// de ruta y no lleva argumentos; es el mismo mecanismo de
  /// [DHCLIENTPlanesPageWidget.pendingReturnRoute] y
  /// [DHCLIENTUbicacionWidget.pendingNextRoute].
  static SubscriptionPlan? selectedPlan;

  @override
  State<DHCLIENTPlanesWidget> createState() => _DHCLIENTPlanesWidgetState();
}

class _DHCLIENTPlanesWidgetState extends State<DHCLIENTPlanesWidget> {
  late DHCLIENTPlanesModel _model;

  /// Todavía no se sabe qué planes hay. Arranca en `true` para no parpadear un
  /// estado de error antes de la primera respuesta.
  bool _loading = true;
  bool _failed = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTPlanesModel());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlans();
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    safeSetState(() {
      _loading = true;
      _failed = false;
    });
    final result = await context.read<PaymentsRepository>().loadPlans();
    if (!mounted) return;
    safeSetState(() {
      _loading = false;
      _failed = result.isFailure;
    });
  }

  /// Los planes que un cliente puede contratar, en el orden del diseño
  /// (mensual y después anual). El orden no depende del que use el backend.
  List<SubscriptionPlan> _sellablePlans(List<SubscriptionPlan> plans) {
    final sellable = plans.where((p) => p.isSellable).toList();
    sellable
        .sort((a, b) => _intervalRank(a.interval) - _intervalRank(b.interval));
    return sellable;
  }

  static int _intervalRank(String? interval) =>
      interval?.toLowerCase() == 'month' ? 0 : 1;

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 16.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 10.0,
                ),
              ),
              Flexible(
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                  child: Text(
                    text,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.publicSans(),
                          fontSize: 14.0,
                          lineHeight: 1.4,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 4.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
            child: Text(
              title,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(
                      fontWeight: FontWeight.w600,
                    ),
                    fontSize: 20.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiosBadgeIcon({required double size, required IconData icon}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB900), Color(0xFFFE9A00)],
          begin: AlignmentDirectional(-1.0, -1.0),
          end: AlignmentDirectional(1.0, 1.0),
        ),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  Widget _buildBeneficiosCard(List<String> additionals) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
            begin: AlignmentDirectional(-1.0, -1.0),
            end: AlignmentDirectional(1.0, 1.0),
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFFEF3C6),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildBeneficiosBadgeIcon(
                      size: 20.0, icon: Icons.card_giftcard),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        8.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Beneficios adicionales',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                            ),
                            color: const Color(0xFF0A7A7A),
                            fontSize: 17.6,
                            letterSpacing: -0.44,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: additionals
                    .map((text) => Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              _buildBeneficiosBadgeIcon(
                                  size: 20.0, icon: Icons.check),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      8.0, 0.0, 0.0, 0.0),
                                  child: Text(
                                    text,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.publicSans(
                                            fontWeight:
                                                text.contains('2 meses gratis')
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                          color: const Color(0xCC0A7A7A),
                                          fontSize: 14.0,
                                          letterSpacing: -0.15,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlcanceSection() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F8F8),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Alcance de los servicios',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(
                      fontWeight: FontWeight.w600,
                    ),
                    color: FlutterFlowTheme.of(context).primary,
                    fontSize: 14.0,
                  ),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
              child: Text(
                'Cada servicio cubre un alcance estándar. Si durante la visita se detecta que el trabajo requiere más tiempo, materiales o un proyecto mayor, DOVIA te enviará una propuesta clara antes de continuar. Nada se hace sin tu aprobación.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(),
                      color: const Color(0xFF00444B),
                      fontSize: 13.0,
                      lineHeight: 1.4,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required String title,
    required String price,
    required String period,
    required List<String> includes,
    required List<String> additionals,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        // La pantalla de pago lee esto para saber qué plan cobrar.
        DHCLIENTPlanesWidget.selectedPlan = plan;

        final onSelected = widget.onPlanSelected;
        if (onSelected != null) {
          onSelected(plan);
          return;
        }

        // Entrada por Planes: antes de cobrar hay que saber dónde se va a
        // prestar el servicio.
        DHCLIENTUbicacionWidget.pendingNextRoute =
            DCFormaPagoSuscripcion1Widget.routeName;
        context.pushNamed(DHCLIENTUbicacionWidget.routeName);
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 10.0,
              color: Color(0x33000000),
              offset: Offset(0.0, 2.0),
            )
          ],
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A7A7A), Color(0xFF0D9F9F)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    20.0, 20.0, 20.0, 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                            ),
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 8.0, 0.0, 0.0),
                      child: RichText(
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: price,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    color: Colors.white,
                                    fontSize: 32.0,
                                  ),
                            ),
                            TextSpan(
                              text: period,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(),
                                    color: const Color(0xCDFFFFFF),
                                    fontSize: 16.0,
                                  ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 4.0, 0.0, 0.0),
                      child: Text(
                        'Tu propiedad, siempre al día.',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.publicSans(),
                              color: const Color(0xCDFFFFFF),
                              fontSize: 12.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                    child: Text(
                      'Plan diseñado para 1 propiedad registrada en DOVIA. Mantén tu hogar en perfectas condiciones con nuestro servicio integral.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.publicSans(),
                            color: const Color(0xFF0A7A7A),
                            fontSize: 14.0,
                            lineHeight: 1.5,
                          ),
                    ),
                  ),
                  _buildSectionTitle('Incluye:'),
                  ...includes.map((text) => _buildBullet(text)),
                  _buildBeneficiosCard(additionals),
                  _buildAlcanceSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lo que incluye cualquier plan. Es el mismo texto en mensual y anual.
  static const List<String> _includes = [
    '1 servicios mensuales',
    'Acceso a cotizaciones',
    'Atención programada con minimo de 24 horas',
    '10% de descuento en cualquier cotización adicional',
    'Acceso a servicios de emergencia',
    'Garantía DOVIA en todos los trabajos',
  ];

  /// Los beneficios adicionales sí cambian: el anual regala meses de
  /// renovación donde el mensual ofrece descuento.
  static List<String> _additionalsFor(String? interval) => [
        'Prioridad en reservas',
        if (interval?.toLowerCase() == 'year')
          '2 meses gratis en tu renovacion'
        else
          'Descuento en tus servicios',
        'Historial detallado de servicios',
      ];

  /// No se pudo traer el catálogo. No se muestran tarjetas: los precios viven
  /// en el backend, así que cualquier monto que pusiéramos acá sería inventado
  /// y el cliente no tendría un plan real que contratar.
  Widget _plansUnavailable() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No pudimos cargar los planes. Revisa tu conexión e intenta de nuevo.',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                color: const Color(0xFF00444B),
                fontSize: 16.0,
                letterSpacing: 0.32,
              ),
        ),
        const SizedBox(height: 20.0),
        FFButtonWidget(
          onPressed: () async => _loadPlans(),
          text: 'Reintentar',
          options: FFButtonOptions(
            width: double.infinity,
            height: 44.0,
            color: FlutterFlowTheme.of(context).primary,
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: Colors.white,
                  fontSize: 16.0,
                ),
            elevation: 0.0,
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = _sellablePlans(context.watch<PaymentsRepository>().plans);

    if (_loading && plans.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60.0),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF007376)),
        ),
      );
    }

    if (plans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: _plansUnavailable(),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final plan in plans) ...[
            _buildPlanCard(
              plan: plan,
              title: plan.name,
              price: plan.formattedAmount,
              // Non-null: `isSellable` ya descartó los intervalos sin etiqueta.
              period: plan.periodLabel!,
              includes: _includes,
              additionals: _additionalsFor(plan.interval),
            ),
            const SizedBox(height: 24.0),
          ],
          // El fallo posterior a un primer catálogo cargado no borra las
          // tarjetas que ya se están mostrando; sólo lo dice.
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'No pudimos actualizar los planes.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.publicSans(),
                      color: const Color(0xFF00444B),
                      fontSize: 13.0,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
