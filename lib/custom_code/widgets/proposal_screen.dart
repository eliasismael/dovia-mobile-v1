// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
import 'dart:convert';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_offers.dart';
import '/backend/api_requests/api_manager.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/flutter_flow/uploaded_file.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!
// Force refresh: 2026-05-04 17:15

import '/domain/counter_offer_view.dart';
import '/domain/offer_json.dart';
import '/dovia_client/app/mis_ofertas/cierre_legal/cierre_legal_section_widget.dart';
import '/dovia_client/app/mis_ofertas/contraoferta/negociacion_contraoferta_widget.dart';

enum NegotiationState { negotiation, structuring, signing, completed }

enum PaymentMethod { hipoteca, contado, promesa }

class ProposalScreen extends StatefulWidget {
  final String stateString;
  final String paymentMethodString;
  final double? width;
  final double? height;
  final dynamic offerData;

  /// Roles legales ya calificados, separados por coma. Sus tarjetas nacen sin
  /// acciones: es lo que distingue "Calificadas" de "Finalizadas".
  final String ratedRoles;

  const ProposalScreen({
    super.key,
    this.width,
    this.height,
    required String state,
    required String paymentMethod,
    this.offerData,
    this.ratedRoles = '',
  })  : stateString = state,
        paymentMethodString = paymentMethod;

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  // TEMPORAL: resalta el Legal Associate de pruebas para encontrarlo rápido.
  // Borrar cuando termine el testing.
  static const String _testLegalAssociateEmail =
      'legal_associate_gato222@dovia.com';

  bool _isUploadingPaymentProof = false;

  String? _selectedLegalAssociateId;
  bool _isSelectingAssociate = false;
  bool _associateSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initLegalAssociateState();
  }

  void _initLegalAssociateState() {
    final data = widget.offerData;
    if (data == null || data is! Map) return;

    // Check for an already-assigned legal associate from the backend
    final associate = data['legalAssociate'] ??
        data['legalAssociateProfile'] ??
        data['legalProcess']?['legalAssociate'];

    if (associate != null && associate is Map) {
      final id = associate['id']?.toString() ??
          associate['userId']?.toString() ??
          associate['_id']?.toString();
      if (id != null && id.isNotEmpty) {
        _selectedLegalAssociateId = id;
        _associateSubmitted = true;
      }
    }

    // Also check if there's a legalAssociateId directly on the offer
    if (!_associateSubmitted) {
      final directId = data['legalAssociateId']?.toString() ??
          data['legalProcess']?['legalAssociateId']?.toString();
      if (directId != null && directId.isNotEmpty) {
        _selectedLegalAssociateId = directId;
        _associateSubmitted = true;
      }
    }

    // Fallback: if processStatus is already 'agreement_structuring', the client
    // already sent the request — no need to allow re-sending.
    if (!_associateSubmitted) {
      final processStatus = data['processStatus']?.toString().toLowerCase() ??
          data['legalProcess']?['status']?.toString().toLowerCase();
      if (processStatus == 'agreement_structuring') {
        _associateSubmitted = true;
      }
    }
  }

  @override
  void didUpdateWidget(covariant ProposalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // offerData starts as null (async load) — re-initialize when it arrives
    if (oldWidget.offerData == null && widget.offerData != null) {
      setState(() {
        _initLegalAssociateState();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  NegotiationState get state {
    try {
      if (widget.offerData != null && widget.offerData is Map) {
        // El cierre llega por dos caminos con dos vocabularios: el propio de
        // la oferta y el enum del proceso legal, cuando el payload sólo
        // embebe `legalProcess`. Sin traducirlo, un trato ya cerrado no
        // coincidía con ninguna rama y caía en la de `accepted`: la pantalla
        // mostraba la estructuración del acuerdo en vez del cierre, así que
        // no había nada que calificar ni documentos que descargar.
        final pStatus =
            offerProcessStatus(Map<String, dynamic>.from(widget.offerData));
        if (pStatus == 'agreement_structuring')
          return paymentMethod == PaymentMethod.hipoteca
              ? NegotiationState.signing
              : NegotiationState.structuring;
        if (pStatus == 'contract_signing') return NegotiationState.signing;
        if (pStatus == 'completed') return NegotiationState.completed;

        final oStatus =
            widget.offerData['offerStatus']?.toString().toLowerCase() ??
                widget.offerData['status']?.toString().toLowerCase();
        if (oStatus == 'counter_offered' ||
            oStatus == 'counter_offer_sent' ||
            oStatus == 'countered') return NegotiationState.negotiation;
        if (oStatus == 'accepted')
          return paymentMethod == PaymentMethod.hipoteca
              ? NegotiationState.signing
              : NegotiationState.structuring;
      }

      final s = widget.stateString.toLowerCase();
      if (s == 'accepted')
        return paymentMethod == PaymentMethod.hipoteca
            ? NegotiationState.signing
            : NegotiationState.structuring;
      if (s == 'structuring' || s == 'agreement_structuring')
        return paymentMethod == PaymentMethod.hipoteca
            ? NegotiationState.signing
            : NegotiationState.structuring;
      if (s == 'signing' ||
          s == 'contract_signing' ||
          s == 'contract_upload' ||
          s == 'contract_uploaded') return NegotiationState.signing;
      if (s == 'completed' || s == 'finished')
        return NegotiationState.completed;

      return NegotiationState.values.firstWhere(
        (e) => e.name.toLowerCase() == s,
        orElse: () => NegotiationState.negotiation,
      );
    } catch (_) {
      return NegotiationState.negotiation;
    }
  }

  PaymentMethod get paymentMethod {
    try {
      String pmStr = widget.paymentMethodString;
      if (widget.offerData != null) {
        dynamic extractPm(dynamic data) {
          if (data == null) return null;
          if (data is String) {
            try {
              final parsed = jsonDecode(data);
              return extractPm(parsed);
            } catch (_) {
              return null;
            }
          }
          if (data is Map) {
            if (data.containsKey('paymentMethod') &&
                data['paymentMethod'] != null) {
              return data['paymentMethod'];
            }
            if (data.containsKey('paymentType') &&
                data['paymentType'] != null) {
              return data['paymentType'];
            }
            if (data.containsKey('activeOfferData')) {
              final nested = extractPm(data['activeOfferData']);
              if (nested != null) return nested;
            }
            if (data.containsKey('originalOfferData')) {
              final nested = extractPm(data['originalOfferData']);
              if (nested != null) return nested;
            }
            if (data.containsKey('counterOfferData')) {
              final nested = extractPm(data['counterOfferData']);
              if (nested != null) return nested;
            }
            if (data.containsKey('offerData')) {
              final nested = extractPm(data['offerData']);
              if (nested != null) return nested;
            }
            if (data.containsKey('offer')) {
              final nested = extractPm(data['offer']);
              if (nested != null) return nested;
            }
            if (data.containsKey('data')) {
              final nested = extractPm(data['data']);
              if (nested != null) return nested;
            }
          }
          return null;
        }

        final pmFromOffer = extractPm(widget.offerData);
        if (pmFromOffer != null && pmFromOffer.toString().isNotEmpty) {
          pmStr = pmFromOffer.toString();
        }
      }

      final s = pmStr.toLowerCase();
      if (s.contains('cash') || s.contains('contado'))
        return PaymentMethod.contado;
      if (s.contains('mortgage') || s.contains('hipoteca'))
        return PaymentMethod.hipoteca;
      if (s.contains('purchase_promise') || s.contains('promesa'))
        return PaymentMethod.promesa;

      return PaymentMethod.values.firstWhere(
        (e) => e.name.toLowerCase() == s,
        orElse: () => PaymentMethod.hipoteca,
      );
    } catch (_) {
      return PaymentMethod.hipoteca;
    }
  }

  /// Reads a field from offerData, checking activeOfferData first then root.
  /// Returns a formatted string or '—' if not found.
  String _offerVal(String key, {String prefix = '', String suffix = ''}) {
    final data = widget.offerData;
    if (data == null || data is! Map) return '—';

    dynamic val;
    // 1. Check activeOfferData
    final active = data['activeOfferData'];
    if (active is Map && active[key] != null) {
      val = active[key];
    }
    // 2. Fall back to root
    if (val == null && data[key] != null) {
      val = data[key];
    }
    if (val == null) return '—';
    return '$prefix$val$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Abajo deja lugar para la navbar flotante, que tapa el último botón.
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildProcessStatus(),
          const SizedBox(height: 24),
          _buildStepContent(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    bool isContractSigned = false;
    if (widget.offerData != null && widget.offerData is Map) {
      final val = widget.offerData['contractSigned'];
      if (val == true || val == 'true') {
        isContractSigned = true;
      }
    }

    switch (state) {
      case NegotiationState.negotiation:
        return _buildNegotiationComparison();
      case NegotiationState.structuring:
        return _buildStructuringContent();
      case NegotiationState.signing:
        return _buildSigningContent(
            isCompleted: false, isContractSigned: isContractSigned);
      case NegotiationState.completed:
        return _buildClosureContent();
    }
  }

  /// Las dos propuestas enfrentadas y el trilema que define el rumbo.
  ///
  /// El reparto de campos según el método de pago vive en [CounterOfferView],
  /// así que acá sólo se decide si ya hay datos que comparar.
  Widget _buildNegotiationComparison() {
    final data = widget.offerData;
    if (data is! Map) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: Color(0xFF007376)),
        ),
      );
    }

    final json = Map<String, dynamic>.from(data);
    return NegociacionContraofertaWidget(
      offerId: json['offerId']?.toString() ?? '',
      view: CounterOfferView.fromJson(json),
      onResolved: () => context.safePop(),
    );
  }

  /// Cierre del trámite: los profesionales que lo acompañaron y la bóveda de
  /// documentos.
  ///
  /// Reemplaza al detalle de la firma —que ya no tiene nada que pedirle al
  /// cliente— por lo que el diseño pone debajo del stepter una vez que Legal
  /// HQ terminó: calificar, reportar y descargar el expediente.
  Widget _buildClosureContent() {
    final data = widget.offerData;
    final json = data is Map ? Map<String, dynamic>.from(data) : null;
    // La oferta identifica su id con las tres llaves según el endpoint que la
    // devuelva; leer sólo `offerId` dejaba la calificación y el reporte
    // apuntando a una ruta sin id.
    final offerId = json == null
        ? ''
        : (offerStr(json['offerId']) ??
            offerStr(json['id']) ??
            offerStr(json['_id']) ??
            '');
    final legalProcessId = json == null
        ? ''
        : (offerStr(json['legalProcessId']) ??
            offerStr(offerAsMap(json['legalProcess'])?['id']) ??
            '');

    return CierreLegalSectionWidget(
      offerId: offerId,
      legalProcessId: legalProcessId,
      ratedRoles: widget.ratedRoles
          .split(',')
          .map((role) => role.trim())
          .where((role) => role.isNotEmpty)
          .toList(),
    );
  }

  String _getPaymentLabel(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.hipoteca:
        return "Hipoteca";
      case PaymentMethod.contado:
        return "Contado";
      case PaymentMethod.promesa:
        return "Promesa de compra";
    }
  }

  Widget _buildProcessStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estado de tu proceso",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF004D4F),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepItem("PASO 1", "Negociación", 0),
              _buildStepDivider(0),
              _buildStepItem("PASO 2", "Estructuración\nde acuerdo", 1),
              _buildStepDivider(1),
              _buildStepItem("PASO 3", "Firma de\ncontrato", 2),
              _buildStepDivider(2),
              _buildStepItem("PASO 4", "Finaliza\nproceso", 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String step, String label, int index) {
    bool isCompleted = index < state.index;
    bool isCurrent = index == state.index;
    bool isPending = index > state.index;
    Color primaryColor = const Color(0xFF007376);
    Color pendingColor = const Color(0xFFE0E0E0);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isPending ? pendingColor : primaryColor,
                width: 2,
              ),
              color: isCompleted ? primaryColor : Colors.white,
            ),
            child: isCurrent
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            step,
            style: TextStyle(
              fontSize: 8,
              color: isPending ? Colors.grey : primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              color: isPending ? Colors.grey : const Color(0xFF004D4F),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFE0F2F1)
                  : isCurrent
                      ? const Color(0xFFE0F7FA)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isPending ? Border.all(color: pendingColor) : null,
            ),
            child: Text(
              isCompleted
                  ? "Completado"
                  : isCurrent
                      ? "En Proceso"
                      : "Pendiente",
              style: TextStyle(
                fontSize: 7,
                color: isCompleted
                    ? const Color(0xFF00796B)
                    : isCurrent
                        ? primaryColor
                        : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(int index) {
    bool isCompleted = index < state.index;
    return Container(
      width: 30,
      height: 2,
      color: isCompleted ? const Color(0xFF007376) : const Color(0xFFE0E0E0),
    );
  }

  Widget _buildStructuringContent() {
    if (paymentMethod == PaymentMethod.hipoteca) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNegotiationSummary(showAdditionalRequest: true),
          const SizedBox(height: 32),
          const Text(
            "Ingresa los datos de tu agente bancario",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D4F),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Dovia se pondrá en contacto para enviarle toda la información que necesita:",
            style: TextStyle(fontSize: 12, color: Color(0xFF004D4F)),
          ),
          const SizedBox(height: 16),
          _buildField("Banco", "x", isEditable: true),
          _buildField("Nombre", "x", isEditable: true),
          _buildField("Apellido", "x", isEditable: true),
          _buildField("Teléfono", "x", isEditable: true),
          _buildField("Correo electrónico", "x", isEditable: true),
          const SizedBox(height: 24),
          _buildAceptarButton(),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNegotiationSummary(showAdditionalRequest: false),
          if (paymentMethod == PaymentMethod.promesa) ...[
            const SizedBox(height: 24),
            const Text(
              "Estructura de pago",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D4F),
              ),
            ),
            const SizedBox(height: 16),
            _buildField(
              "Reserva inicial",
              _offerVal('initialReserve', prefix: 'Q'),
              hasChevron: false,
              isEditable: false,
            ),
            _buildField("Pago final", _offerVal('finalPayment', prefix: 'Q'),
                isEditable: false),
            _buildField(
              "Tiempo de promesa",
              _offerVal('promiseTimeMonths', suffix: ' meses'),
              hasChevron: false,
              isEditable: false,
            ),
          ],
          const SizedBox(height: 32),
          const Text(
            "Selecciona tu DOVIA Legal Associate",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D4F),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "DOVIA Legal Associates son abogados verificados y especializados en procesos de compraventa, seleccionados por DOVIA para asegurar que tu escrituración sea rápida, segura y sin errores.",
            style: TextStyle(fontSize: 12, color: Color(0xFF004D4F)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ellos se encargan de todo el proceso legal, mientras DOVIA supervisa cada etapa para proteger tus intereses y mantener la transparencia total.",
            style: TextStyle(fontSize: 12, color: Color(0xFF004D4F)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: FutureBuilder<ApiCallResponse>(
              future: DOVIAAPIUserContextGroup.listUsersByRoleCall.call(
                role: 'LEGAL_ASSOCIATE',
                page: '1',
                limit: '50',
                authToken: currentAuthenticationToken,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF007376)),
                    ),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !(snapshot.data?.succeeded ?? false)) {
                  return const Center(
                      child: Text("Error al cargar los asociados legales."));
                }

                final jsonBody = snapshot.data!.jsonBody;
                dynamic rawData = jsonBody['data'];
                if (rawData is String) {
                  try {
                    rawData = jsonDecode(rawData);
                  } catch (_) {}
                }
                final List<dynamic> items = List<dynamic>.of(rawData is List
                    ? rawData
                    : (rawData is Map
                        ? rawData['items'] as List<dynamic>? ?? []
                        : []));
                bool isTestAssociate(dynamic user) =>
                    user is Map &&
                    user['email']?.toString().toLowerCase() ==
                        _testLegalAssociateEmail;
                // TEMPORAL: el de pruebas va primero.
                items.sort((a, b) =>
                    (isTestAssociate(b) ? 1 : 0) -
                    (isTestAssociate(a) ? 1 : 0));

                if (items.isEmpty) {
                  return const Center(
                      child: Text(
                          "No hay asociados disponibles en este momento."));
                }

                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: items.map((user) {
                    final id = user['id']?.toString();
                    final fullName = user['fullName'];
                    final name = fullName is Map
                        ? "${fullName['name'] ?? ''} ${fullName['lastname'] ?? ''}"
                            .trim()
                        : "${user['name'] ?? ''} ${user['lastname'] ?? ''}"
                            .trim();
                    final isSelected = _selectedLegalAssociateId == id;

                    return _buildLegalAssociateCard(
                      name,
                      isTest: isTestAssociate(user),
                      isSelected ||
                          (_associateSubmitted &&
                              _selectedLegalAssociateId == id),
                      () {
                        if (id != null && !_associateSubmitted) {
                          setState(() {
                            _selectedLegalAssociateId = id;
                          });
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Siguientes pasos:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D4F),
            ),
          ),
          const SizedBox(height: 8),
          _buildNextStepItem("Serás contactado por X para definir detalles."),
          _buildNextStepItem("El propietario será contactado."),
          _buildNextStepItem("X preparará documentación"),
          _buildNextStepItem("Se compartirá documentación con ambos"),
          _buildNextStepItem(
            "Se establecerá lugar, fecha y hora para firma de contratos.",
          ),
          if (_associateSubmitted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0x3370ACAD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Tu selección fue enviada. Estamos esperando la confirmación del Legal Associate seleccionado.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF00444B),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            )
          else
            _buildAceptarButton(
              enabled: _selectedLegalAssociateId != null,
              isLoading: _isSelectingAssociate,
              onPressed: _selectLegalAssociate,
            ),
        ],
      );
    }
  }

  Widget _buildSigningContent(
      {required bool isCompleted, required bool isContractSigned}) {
    if (paymentMethod == PaymentMethod.hipoteca) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Así avanzará tu proceso legal",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00444B),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Como la compra se realizará a través de una hipoteca bancaria, el proceso legal será gestionado por el abogado asignado por el banco.\n\nDOVIA enviará toda la documentación necesaria y te mantendrá informado en cada etapa.\n\nNuestro equipo de DOVIA HQ estará en contacto contigo para resolver dudas, coordinar documentos y asegurarse de que todo avance de manera segura, rápida y sin retrasos.",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF00444B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "¿Qué sigue?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00444B),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
              "Firma el acuerdo de reconocimiento de honorarios de DOVIA.",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00444B))),
          const SizedBox(height: 4),
          _buildCustomBullet(
              "Este documento aparecerá aquí mismo en la app para tu firma digital (se compartirá al banco)"),
          const SizedBox(height: 16),
          const Text("DOVIA comparte tu expediente al banco",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00444B))),
          const SizedBox(height: 4),
          _buildCustomBullet(
              "Verificamos toda la información y la enviamos al abogado del banco."),
          const SizedBox(height: 16),
          const Text("Revisión del banco",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00444B))),
          const SizedBox(height: 4),
          _buildCustomBullet(
              "El banco revisará la documentación y validará que todo esté en orden."),
          const SizedBox(height: 16),
          const Text("Contacto del abogado del banco",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00444B))),
          const SizedBox(height: 4),
          _buildCustomBullet(
              "Te llamará para continuar con el proceso hipotecario y coordinar la cita de firma."),
          const SizedBox(height: 16),
          const Text("Firma con el banco y entrega del enganche.",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00444B))),
          const SizedBox(height: 4),
          _buildCustomBullet(
              "Al momento de la firma del contrato hipotecario, el banco solicitará el enganche."),
          _buildCustomBullet(
              "En ese mismo momento se debe cancelar el fee DOVIA"),
          const SizedBox(height: 16),
          const Text("Acompañamiento DOVIA",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00444B))),
          const SizedBox(height: 4),
          _buildCustomBullet(
              "Supervisamos todo el proceso para que la compra sea clara, segura y sin complicaciones."),
          const SizedBox(height: 32),
          const Text(
            "Avances",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00444B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Aquí Dovia desplegar avances sobre procesos y documento para firmar",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00444B),
            ),
          ),
          const SizedBox(height: 24),
          _buildDocumentItem(
            "Documento a firmar",
            isCompleted: isCompleted,
            status: isCompleted ? "done" : "upload_download",
          ),
          const SizedBox(height: 32),
          _buildAceptarButton(
              enabled: true,
              onPressed: () {
                // Enviar documentos subidos al backend
              }),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectedAssociateCard(),
        const SizedBox(height: 24),
        if (!isCompleted && !isContractSigned) ...[
          _buildMobileField("Firma de acuerdo", "x"),
          _buildMobileField("Dirección exacta", "x"),
          const Text(
            "Fecha",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF00444B),
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMobileSmallField("DD")),
              const SizedBox(width: 17),
              Expanded(child: _buildMobileSmallField("MM")),
              const SizedBox(width: 17),
              Expanded(child: _buildMobileSmallField("AAAA")),
            ],
          ),
          const SizedBox(height: 18),
          _buildMobileField("Instrucciones para llegar", "x\nx\nx",
              isTextArea: true),
          const SizedBox(height: 5),
          _buildMobileSecondaryButton("Abrir ubicación"),
          const SizedBox(height: 24),
        ],
        if (isCompleted)
          _buildPaymentProofUpload(
            isUploading: false,
            onTap: null, // Ya subido
          ),
        if (!isCompleted && isContractSigned) ...[
          _buildPaymentProofUpload(
            isUploading: _isUploadingPaymentProof,
            onTap: _isUploadingPaymentProof ? null : _uploadPaymentProof,
          ),
          const SizedBox(height: 18),
          _buildPaymentNotification(),
          const SizedBox(height: 24),
        ],
        if (!isCompleted && !isContractSigned)
          _buildDocumentItem(
            "Acuerdo legal",
            isCompleted: false,
            status: "view",
          ),
        if (!isCompleted && isContractSigned)
          _buildDocumentItem(
            "Acuerdo legal",
            isCompleted: true,
            status: "view",
          ),
        _buildDocumentItem(
          "Copia de contratos",
          isCompleted: isCompleted,
          status: isCompleted ? "done" : "pending",
        ),
        _buildDocumentItem(
          "Copia de ingreso de inscripción en registro",
          isCompleted: isCompleted,
          status: isCompleted ? "done" : "pending",
        ),
        _buildDocumentItem(
          "Copia de aviso a municipalidad",
          isCompleted: isCompleted,
          status: isCompleted ? "done" : "pending",
        ),
        _buildDocumentItem(
          "Copia de certificación de registro",
          isCompleted: isCompleted,
          status: isCompleted ? "done" : "pending",
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    String value, {
    bool isTextArea = false,
    bool hasChevron = false,
    bool isEditable = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF004D4F),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: isEditable
              ? const EdgeInsets.symmetric(horizontal: 0, vertical: 0)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isEditable
              ? TextFormField(
                  initialValue: value,
                  maxLines: isTextArea ? 4 : 1,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: hasChevron
                        ? const Icon(Icons.chevron_right, color: Colors.grey)
                        : null,
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    if (hasChevron)
                      const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSmallField(String placeholder) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(placeholder, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Moneda de pago",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF004D4F),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF7CB3B5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Text(
              "USD",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildOwnerProposalFields(bool hasOwnerResponded) {
    String valueIfResponded(String original) =>
        hasOwnerResponded ? original : "";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildField(
                  "Método de pago",
                  valueIfResponded(_getPaymentLabel(paymentMethod)),
                ),
              ),
              const SizedBox(width: 12),
              if (paymentMethod == PaymentMethod.hipoteca)
                Expanded(child: _buildField("Banco", valueIfResponded("x"))),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: _buildField(
                      "Propuesta económica", valueIfResponded("x"))),
              const SizedBox(width: 12),
              if (paymentMethod == PaymentMethod.hipoteca)
                Expanded(child: _buildField("Enganche", valueIfResponded("%"))),
            ],
          ),
          if (paymentMethod == PaymentMethod.promesa)
            Row(
              children: [
                Expanded(
                    child:
                        _buildField("Reserva inicial", valueIfResponded("x"))),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildField("Pago final", valueIfResponded("x"))),
              ],
            ),
          _buildField("Solicitud adicional", valueIfResponded("x\nx\nx"),
              isTextArea: true),
        ],
      ),
    );
  }

  Widget _buildNegotiationSummary({bool showAdditionalRequest = true}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildField(
                "Método de pago",
                _getPaymentLabel(paymentMethod),
              ),
            ),
            const SizedBox(width: 12),
            if (paymentMethod == PaymentMethod.hipoteca)
              Expanded(child: _buildField("Banco", "x")),
          ],
        ),
        _buildCurrencySelector(),
        _buildField(
            "Propuesta económica", _offerVal('proposedAmount', prefix: 'Q')),
        if (paymentMethod == PaymentMethod.hipoteca)
          _buildField("Enganche", "%"),
        if (showAdditionalRequest)
          _buildField("Solicitud adicional", "x\nx\nx", isTextArea: true),
      ],
    );
  }

  Widget _buildActionButtons(bool hasOwnerResponded) {
    return Column(
      children: [
        _buildOutlinedButton("Rechazar", enabled: hasOwnerResponded),
        const SizedBox(height: 12),
        _buildOutlinedButton("Contraoferta", enabled: hasOwnerResponded),
        const SizedBox(height: 12),
        _buildAceptarButton(enabled: hasOwnerResponded),
      ],
    );
  }

  Widget _buildOutlinedButton(String text, {bool enabled = true}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: enabled ? () {} : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: enabled ? const Color(0xFF007376) : Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: enabled ? const Color(0xFF007376) : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAceptarButton(
      {bool enabled = true, VoidCallback? onPressed, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? (onPressed ?? () {}) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? const Color(0xFF007376) : Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Aceptar",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildMobileField(String label, String placeholder,
      {bool isTextArea = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xFF00444B),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: isTextArea ? 104 : 42,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: isTextArea
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("x",
                        style:
                            TextStyle(color: Color(0xFF888888), fontSize: 14)),
                    Text("x",
                        style:
                            TextStyle(color: Color(0xFF888888), fontSize: 14)),
                    Text("x",
                        style:
                            TextStyle(color: Color(0xFF888888), fontSize: 14)),
                  ],
                )
              : Text(
                  placeholder,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                  ),
                ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildMobileSmallField(String placeholder) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          placeholder,
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileSecondaryButton(String text) {
    return Container(
      height: 27,
      width: 134,
      decoration: BoxDecoration(
        color: const Color(0x3370ACAD),
        borderRadius: BorderRadius.circular(65),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF00444B),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentProofUpload(
      {required bool isUploading, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEAE3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Comprobante de pago a Dovia",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF00444B),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4.19),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(99),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3370ACAD),
                    blurRadius: 1.35,
                    offset: Offset(0, 2.7),
                  )
                ],
              ),
              child: isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF007376))))
                  : const Icon(Icons.upload_outlined,
                      color: Color(0xFF007376), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentNotification() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0x3370ACAD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Podrás ver los archivos pero no puedes descargarlos hasta realizar el pago a Dovia. El pago será revisado y aprobado.",
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF00444B),
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text) {
    return SizedBox(
      width: 150,
      height: 36,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDDEEEF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF007376),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandingTextField(String hint) {
    return Container(
      height: 100,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(hint, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildLegalAssociateCard(
      String name, bool isSelected, VoidCallback onTap,
      {bool isTest = false}) {
    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF007376) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                'assets/images/ae3f449657ae0dc947fdf904e0ea70a030a118f3.png',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Licenciado",
                style: TextStyle(fontSize: 10, color: Color(0xFF00796B)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D4F),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
    if (!isTest) return card;
    // TEMPORAL: etiqueta del Legal Associate de pruebas.
    return Stack(
      children: [
        card,
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF57E00),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Pruebas',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedAssociateCard() {
    final associate = widget.offerData?['legalAssociate'] ??
        widget.offerData?['legalProcess']?['legalAssociate'];

    String name = "Nombre Apellido";
    String phone = "Teléfono";
    String email = "Mail";

    if (associate != null && associate is Map) {
      if (associate['fullName'] != null) {
        if (associate['fullName'] is Map) {
          name =
              "${associate['fullName']['name'] ?? ''} ${associate['fullName']['lastname'] ?? ''}"
                  .trim();
        } else {
          name = associate['fullName'].toString();
        }
      } else if (associate['name'] != null || associate['lastname'] != null) {
        name =
            "${associate['name'] ?? ''} ${associate['lastname'] ?? ''}".trim();
      }
      if (name.isEmpty) name = "Nombre Apellido";

      phone = associate['phoneNumber']?.toString() ??
          associate['phone']?.toString() ??
          "Teléfono";
      email = associate['email']?.toString() ?? "Mail";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
          top: 23.9, bottom: 15.9, left: 15.9, right: 15.9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.47),
        border: Border.all(color: const Color(0xFF007376), width: 0.5),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 49.8,
            backgroundImage: AssetImage(
              'assets/images/ae3f449657ae0dc947fdf904e0ea70a030a118f3.png',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x3370ACAD),
              borderRadius: BorderRadius.circular(65),
            ),
            child: const Text(
              "Dovia Legal",
              style: TextStyle(fontSize: 14, color: Color(0xFF00444B)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00444B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Text(
                  phone,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF00444B)),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  email,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF00444B)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF004D4F)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style: TextStyle(fontSize: 16, color: Color(0xFF00444B))),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 16, color: Color(0xFF00444B), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(
    String label, {
    required bool isCompleted,
    required String status,
    VoidCallback? onTap,
  }) {
    IconData? leftIcon;
    Color? leftIconColor;
    if (status == "done") {
      leftIcon = Icons.check_circle;
      leftIconColor = const Color(0xFF007376);
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10.7),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF00444B),
                ),
              ),
            ),
            if (status == "done")
              Icon(leftIcon, color: leftIconColor, size: 32),
            const SizedBox(width: 8),
            if (status == "uploading")
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007376)),
                ),
              )
            else if (status == "upload_download")
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCE3E4),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Icon(Icons.download_outlined,
                        color: Color(0xFF007376), size: 20),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCE3E4),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Icon(Icons.upload_file,
                        color: Color(0xFF007376), size: 20),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCE3E4),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Icon(
                  status == "upload"
                      ? Icons.upload_file
                      : status == "view"
                          ? Icons.visibility_outlined
                          : status == "done"
                              ? Icons.download_outlined
                              : Icons.access_time,
                  color: const Color(0xFF007376),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadPaymentProof() async {
    final processId = widget.offerData?['legalProcessId']?.toString();
    if (processId == null || processId.isEmpty || processId == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: No se encontró el proceso legal.')),
      );
      return;
    }

    final files = await selectFiles(multiFile: false);
    if (files == null || files.isEmpty) return;

    final uploaded = FFUploadedFile(
      name: files.first.storagePath.split('/').last,
      bytes: files.first.bytes,
      originalFilename: files.first.originalFilename,
    );

    setState(() => _isUploadingPaymentProof = true);

    final res =
        await DOVIAAPILegalProcessContextGroup.uploadPaymentProofCall.call(
      processId: processId,
      authToken: currentAuthenticationToken,
      file: uploaded,
    );

    if (mounted) {
      setState(() => _isUploadingPaymentProof = false);
      if (res.succeeded) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: PopupExitoWidget(
              title: '¡Subido!',
              text: 'Tu comprobante de pago ha sido cargado con éxito.',
              onContinue: () => Navigator.pop(context),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir documento.')),
        );
      }
    }
  }

  Future<void> _selectLegalAssociate() async {
    if (_selectedLegalAssociateId == null) return;

    final offerId = widget.offerData?['offerId']?.toString();
    if (offerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: No se encontró el ID de la oferta.')),
      );
      return;
    }

    setState(() => _isSelectingAssociate = true);

    final res = await DOVIAAPIOfferContextGroup.selectLegalAssociateCall.call(
      offerId: offerId,
      authToken: currentAuthenticationToken,
      legalAssociateId: _selectedLegalAssociateId,
    );

    if (!mounted) return;
    setState(() => _isSelectingAssociate = false);

    if (res.succeeded) {
      setState(() => _associateSubmitted = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asociado legal seleccionado con éxito')),
      );
      // Wait for 2 seconds and call success popup
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: PopupExitoWidget(
            title: '¡Éxito!',
            text: 'Asociado legal seleccionado correctamente.',
            onContinue: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: ${res.jsonBody['message'] ?? 'Hubo un problema'}')),
      );
    }
  }
}
