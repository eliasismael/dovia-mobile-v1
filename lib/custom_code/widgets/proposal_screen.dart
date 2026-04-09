// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

enum NegotiationState { negotiation, structuring, signing, completed }

enum PaymentMethod { hipoteca, contado, promesa }

class ProposalScreen extends StatelessWidget {
  final String stateString;
  final String paymentMethodString;
  final double? width;
  final double? height;

  const ProposalScreen({
    super.key,
    this.width,
    this.height,
    required String state,
    required String paymentMethod,
  })  : stateString = state,
        paymentMethodString = paymentMethod;

  NegotiationState get state {
    try {
      return NegotiationState.values.firstWhere(
        (e) => e.name == stateString,
        orElse: () => NegotiationState.negotiation,
      );
    } catch (_) {
      return NegotiationState.negotiation;
    }
  }

  PaymentMethod get paymentMethod {
    try {
      return PaymentMethod.values.firstWhere(
        (e) => e.name == paymentMethodString,
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
    switch (state) {
      case NegotiationState.negotiation:
        return _buildNegotiationContent();
      case NegotiationState.structuring:
        return _buildStructuringContent();
      case NegotiationState.signing:
        return _buildSigningContent(isCompleted: false);
      case NegotiationState.completed:
        return _buildSigningContent(isCompleted: true);
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
        _buildOwnerProposalFields(),
        const SizedBox(height: 24),
        _buildActionButtons(),
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
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildLegalAssociateCard("Nombre Apellido"),
                _buildLegalAssociateCard("Nombre Apellido"),
              ],
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
          _buildAceptarButton(),
        ],
      );
    }
  }

  Widget _buildSigningContent({required bool isCompleted}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectedAssociateCard(),
        const SizedBox(height: 24),
        if (!isCompleted) ...[
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
        ],
        if (!isCompleted)
          _buildDocumentItem(
            "Acuerdo legal",
            isCompleted: isCompleted,
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

  Widget _buildOwnerProposalFields() {
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
                  _getPaymentLabel(paymentMethod),
                ),
              ),
              const SizedBox(width: 12),
              if (paymentMethod == PaymentMethod.hipoteca)
                Expanded(child: _buildField("Banco", "x")),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildField("Propuesta económica", "x")),
              const SizedBox(width: 12),
              if (paymentMethod == PaymentMethod.hipoteca)
                Expanded(child: _buildField("Enganche", "%")),
            ],
          ),
          if (paymentMethod == PaymentMethod.promesa)
            Row(
              children: [
                Expanded(child: _buildField("Reserva inicial", "x")),
                const SizedBox(width: 12),
                Expanded(child: _buildField("Pago final", "x")),
              ],
            ),
          _buildField("Solicitud adicional", "x\nx\nx", isTextArea: true),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildOutlinedButton("Rechazar"),
        const SizedBox(height: 12),
        _buildOutlinedButton("Contraoferta"),
        const SizedBox(height: 12),
        _buildAceptarButton(),
      ],
    );
  }

  Widget _buildOutlinedButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF007376)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF007376),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAceptarButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007376),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text(
          "Aceptar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildLegalAssociateCard(String name) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
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
          ),
        ],
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
  }) {
    IconData? leftIcon;
    Color? leftIconColor;
    if (status == "done") {
      leftIcon = Icons.check_circle;
      leftIconColor = const Color(0xFF007376);
    }
    return Container(
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
          if (status == "done") Icon(leftIcon, color: leftIconColor, size: 32),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status == "view"
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
    );
  }
}
