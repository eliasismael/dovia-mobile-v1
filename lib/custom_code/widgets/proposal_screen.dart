// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
import 'dart:convert';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/upload_data.dart';
import '/flutter_flow/uploaded_file.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!
// Force refresh: 2026-05-04 17:15

enum NegotiationState { negotiation, structuring, signing, completed }

enum PaymentMethod { hipoteca, contado, promesa }

class ProposalScreen extends StatefulWidget {
  final String stateString;
  final String paymentMethodString;
  final double? width;
  final double? height;
  final dynamic offerData;

  const ProposalScreen({
    super.key,
    this.width,
    this.height,
    required String state,
    required String paymentMethod,
    this.offerData,
  })  : stateString = state,
        paymentMethodString = paymentMethod;

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  bool _isUploadingPaymentProof = false;

  String? _selectedLegalAssociateId;
  bool _isSelectingAssociate = false;

  NegotiationState get state {
    try {
      if (widget.offerData != null && widget.offerData is Map) {
        final pStatus =
            widget.offerData['processStatus']?.toString().toLowerCase();
        if (pStatus == 'agreement_structuring')
          return NegotiationState.structuring;
        if (pStatus == 'contract_signing') return NegotiationState.signing;
        if (pStatus == 'completed') return NegotiationState.completed;

        final oStatus =
            widget.offerData['offerStatus']?.toString().toLowerCase() ??
                widget.offerData['status']?.toString().toLowerCase();
        if (oStatus == 'accepted') return NegotiationState.structuring;
      }

      final s = widget.stateString.toLowerCase();
      if (s == 'accepted') return NegotiationState.structuring;
      if (s == 'structuring' || s == 'agreement_structuring')
        return NegotiationState.structuring;
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

    try {
      return NegotiationState.signing;
    } catch (e) {
      return NegotiationState.signing;
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildProcessStatus(),
          const SizedBox(height: 24),
          _buildStepContent(),
          const SizedBox(height: 40),
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
        return _buildNegotiationContent();
      case NegotiationState.structuring:
        return _buildStructuringContent();
      case NegotiationState.signing:
        return _buildSigningContent(
            isCompleted: false, isContractSigned: isContractSigned);
      case NegotiationState.completed:
        return _buildSigningContent(isCompleted: true, isContractSigned: true);
    }
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
              _buildStepItem("PASO 4", "Finalizar\nproceso", 3),
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

  Widget _buildNegotiationContent() {
    bool hasOwnerResponded = false;
    if (widget.offerData != null) {
      final status = widget.offerData['offerStatus']?.toString();
      hasOwnerResponded = status == 'counter_offer' ||
          status == 'accepted' ||
          status == 'rejected';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tu propuesta",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004D4F),
          ),
        ),
        const SizedBox(height: 16),
        _buildField(
          "Método de pago",
          _getPaymentLabel(paymentMethod),
          isEditable: true,
        ),
        if (paymentMethod == PaymentMethod.hipoteca)
          _buildField("Banco", "x", isEditable: true),
        _buildField("Propuesta económica", "x", isEditable: true),
        if (paymentMethod == PaymentMethod.hipoteca) ...[
          _buildField("Enganche", "%", isEditable: true),
          _buildField("Estado del crédito", "x", isEditable: true),
        ],
        if (paymentMethod == PaymentMethod.promesa) ...[
          _buildField("Reserva inicial", "x", isEditable: true),
          _buildField("Pago final", "x", isEditable: true),
        ],
        _buildCurrencySelector(),
        _buildField(
          "Solicitud adicional",
          "x\nx\nx",
          isTextArea: true,
          isEditable: true,
        ),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            "Propuesta del propietario",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D4F),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildOwnerProposalFields(hasOwnerResponded),
        const SizedBox(height: 24),
        _buildActionButtons(hasOwnerResponded),
        const SizedBox(height: 24),
        const Text(
          "¿Por qué rechazaste la oferta?",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF004D4F),
          ),
        ),
        const SizedBox(height: 8),
        _buildExpandingTextField("Escribe aquí..."),
      ],
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
              "x",
              hasChevron: true,
              isEditable: true,
            ),
            _buildField("Pago final", "x", isEditable: true),
            _buildField(
              "Tiempo de promesa",
              "x meses",
              hasChevron: true,
              isEditable: true,
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
                limit: '10',
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
                final List<dynamic> items = rawData is List
                    ? rawData
                    : (rawData is Map
                        ? rawData['items'] as List<dynamic>? ?? []
                        : []);

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
                      isSelected,
                      () {
                        if (id != null) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectedAssociateCard(),
        const SizedBox(height: 24),
        if (!isCompleted && !isContractSigned) ...[
          _buildField("Firma de acuerdo", "x"),
          _buildField("Dirección exacta", "x"),
          _buildField("Hora", "xx:xx"),
          const Text(
            "Fecha",
            style: TextStyle(fontSize: 12, color: Color(0xFF004D4F)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: _buildSmallField("DD")),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallField("MM")),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallField("AAAA")),
            ],
          ),
          const SizedBox(height: 16),
          _buildField("Instrucciones para llegar", "x\nx\nx", isTextArea: true),
          _buildSecondaryButton("Abrir ubicación"),
          const SizedBox(height: 24),
          _buildDocumentItem(
            "Comprobante de pago",
            isCompleted: false,
            status: _isUploadingPaymentProof ? "uploading" : "upload",
            onTap: _isUploadingPaymentProof ? null : _uploadPaymentProof,
          ),
          const SizedBox(height: 24),
        ],
        if (isCompleted || isContractSigned)
          _buildDocumentItem(
            "Comprobante de pago",
            isCompleted: true,
            status: "view",
          ),
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
        _buildField("Propuesta económica", "x"),
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
      String name, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
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
  }

  Widget _buildSelectedAssociateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(
              'assets/images/ae3f449657ae0dc947fdf904e0ea70a030a118f3.png',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "Dovia Legal Associate",
                style: TextStyle(fontSize: 14, color: Color(0xFF00796B)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Nombre Apellido",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D4F),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Teléfono",
                style: TextStyle(fontSize: 12, color: Color(0xFF004D4F)),
              ),
              Text(
                "Mail",
                style: TextStyle(fontSize: 12, color: Color(0xFF004D4F)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF004D4F),
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
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
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
