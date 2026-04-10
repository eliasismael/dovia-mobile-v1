// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

enum PurchasePaymentMethod {
  contado, // Cash payment
  hipoteca, // Mortgage
  promesa, // Purchase promise
}

enum PurchaseCurrency {
  usd,
  quetzales,
}

class PurchaseOfferWidget extends StatefulWidget {
  final double? width;
  final double? height;

  /// Called when the user taps "Ofertar" and the payment method is Contado.
  /// Receives a Map with: offerType, offerData { paymentMethod, currency,
  /// proposedAmount, considerations, buyerInfo, estimatedPaymentTime }.
  final Function(Map<String, dynamic>)? onContado;

  /// Called when the user taps "Ofertar" and the payment method is Hipoteca.
  /// Receives a Map with: offerType, offerData { paymentMethod, currency,
  /// proposedAmount, considerations, buyerInfo, downPaymentPercentage,
  /// bankName, creditStatus, estimatedApprovalTime }.
  final Function(Map<String, dynamic>)? onHipoteca;

  /// Called when the user taps "Ofertar" and the payment method is Promesa.
  /// Receives a Map with: offerType, offerData { paymentMethod, currency,
  /// proposedAmount, considerations, buyerInfo, initialReserve,
  /// promiseTimeMonths }.
  final Function(Map<String, dynamic>)? onPromesa;

  final Function(PurchasePaymentMethod)? onPaymentMethodChanged;
  final Function(PurchaseCurrency)? onCurrencyChanged;

  final PurchasePaymentMethod initialPaymentMethod;
  final PurchaseCurrency initialCurrency;

  // Owner-provided data (read-only fields)
  final String? price;
  final String? availableFrom;
  final String? notAllowedUse;
  final String? otherConsiderations;

  const PurchaseOfferWidget({
    super.key,
    this.width,
    this.height,
    this.onContado,
    this.onHipoteca,
    this.onPromesa,
    this.onPaymentMethodChanged,
    this.onCurrencyChanged,
    this.initialPaymentMethod = PurchasePaymentMethod.contado,
    this.initialCurrency = PurchaseCurrency.usd,
    this.price,
    this.availableFrom,
    this.notAllowedUse,
    this.otherConsiderations,
  });

  @override
  State<PurchaseOfferWidget> createState() => _PurchaseOfferWidgetState();
}

class _PurchaseOfferWidgetState extends State<PurchaseOfferWidget> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color backgroundColor = Color(0xFFF7F7F7);
  static const Color cardBackground = Colors.white;
  static const Color placeholderColor = Color(0xFF888888);
  static const Color selectedButtonColor = Color(0xFF7CB3B5);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color warningBgColor = Color(0xFFE5F5F5);
  static const Color readOnlyFieldColor = Color(0xFFE8E8E8);

  late PurchasePaymentMethod _selectedPaymentMethod;
  late PurchaseCurrency _selectedCurrency;
  bool _isCompany = false;

  // Form controllers - Proposal
  late TextEditingController _proposalAmountController;

  // Form controllers - Hipoteca specific
  late TextEditingController _engancheController;
  late TextEditingController _bankController;
  late TextEditingController _creditStatusController;
  late TextEditingController _bankApprovalTimeController;

  // Form controllers - Contado specific
  late TextEditingController _paymentTimeController;

  // Form controllers - Promesa specific
  late TextEditingController _initialReserveController;
  late TextEditingController _finalPaymentController;
  late TextEditingController _promiseTimeController;

  // Form controllers - Buyer section
  late TextEditingController _buyerNameController;
  late TextEditingController _socialReasonController;
  late TextEditingController _legalRepController;

  // Form controllers - Considerations
  late TextEditingController _considerationsController;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.initialPaymentMethod;
    _selectedCurrency = widget.initialCurrency;

    // Initialize proposal controllers
    _proposalAmountController = TextEditingController();

    // Initialize Hipoteca controllers
    _engancheController = TextEditingController();
    _bankController = TextEditingController();
    _creditStatusController = TextEditingController();
    _bankApprovalTimeController = TextEditingController();

    // Initialize Contado controllers
    _paymentTimeController = TextEditingController();

    // Initialize Promesa controllers
    _initialReserveController = TextEditingController();
    _finalPaymentController = TextEditingController();
    _promiseTimeController = TextEditingController();

    // Initialize buyer controllers
    _buyerNameController = TextEditingController();
    _socialReasonController = TextEditingController();
    _legalRepController = TextEditingController();

    // Initialize considerations controller
    _considerationsController = TextEditingController();
  }

  @override
  void dispose() {
    _proposalAmountController.dispose();
    _paymentTimeController.dispose();
    _engancheController.dispose();
    _bankController.dispose();
    _creditStatusController.dispose();
    _bankApprovalTimeController.dispose();
    _initialReserveController.dispose();
    _finalPaymentController.dispose();
    _promiseTimeController.dispose();
    _buyerNameController.dispose();
    _socialReasonController.dispose();
    _legalRepController.dispose();
    _considerationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: backgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Características que proporcionó el propietario
              _buildOwnerCharacteristicsSection(),

              const SizedBox(height: 24),

              // Divider
              Container(height: 1, color: borderColor),

              const SizedBox(height: 24),

              // Section: Tu propuesta
              _buildProposalSection(),

              // Payment method specific fields
              ..._buildPaymentMethodSpecificFields(),

              // Buyer section (for all payment methods)
              const SizedBox(height: 24),
              _buildBuyerSection(),
              const SizedBox(height: 24),
              _buildConsiderationsField(),

              const SizedBox(height: 24),

              // Warning box
              _buildWarningBox(),

              const SizedBox(height: 16),

              // Info text
              const Text(
                'Al enviar tu propuesta, el propietario podrá aceptarla, rechazarla o solicitar cambios.',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  color: placeholderColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Accept button
              _buildAcceptButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== OWNER CHARACTERISTICS SECTION ====================
  Widget _buildOwnerCharacteristicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Características que proporcionó el propietario',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),

        // Price and Available from row
        Row(
          children: [
            Expanded(
              child: _buildReadOnlyField(
                'Precio',
                widget.price ?? 'x',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildReadOnlyField(
                'Disponible desde',
                widget.availableFrom ?? 'x',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Not allowed use
        _buildReadOnlyFieldMultiline(
          'Uso no permitido de esta propiedad',
          widget.notAllowedUse ?? 'Airbnb',
        ),

        const SizedBox(height: 16),

        // Other considerations
        _buildReadOnlyFieldMultiline(
          'Otras consideraciones',
          widget.otherConsiderations ?? 'Incluye línea blanca',
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: readOnlyFieldColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: placeholderColor,
              letterSpacing: 0.28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyFieldMultiline(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: readOnlyFieldColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: placeholderColor,
              letterSpacing: 0.28,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== PROPOSAL SECTION ====================
  Widget _buildProposalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu propuesta',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),

        // Payment method label
        const Text(
          'Método de pago',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 8),

        // Payment method dropdown selector
        _buildPaymentMethodDropdown(),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return PopupMenuButton<PurchasePaymentMethod>(
      initialValue: _selectedPaymentMethod,
      onSelected: (PurchasePaymentMethod method) {
        setState(() {
          _selectedPaymentMethod = method;
        });
        widget.onPaymentMethodChanged?.call(method);
      },
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: cardBackground,
      itemBuilder: (BuildContext context) {
        return PurchasePaymentMethod.values.map((method) {
          final isSelected = _selectedPaymentMethod == method;
          return PopupMenuItem<PurchasePaymentMethod>(
            value: method,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getPaymentMethodLabel(method),
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? primaryColor : textColor,
                    letterSpacing: 0.28,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check,
                    color: primaryColor,
                    size: 20,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getPaymentMethodLabel(_selectedPaymentMethod),
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor,
                letterSpacing: 0.28,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: placeholderColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodLabel(PurchasePaymentMethod method) {
    switch (method) {
      case PurchasePaymentMethod.contado:
        return 'Contado';
      case PurchasePaymentMethod.hipoteca:
        return 'Hipoteca';
      case PurchasePaymentMethod.promesa:
        return 'Promesa de compra';
    }
  }

  // ==================== PAYMENT METHOD SPECIFIC FIELDS ====================
  List<Widget> _buildPaymentMethodSpecificFields() {
    switch (_selectedPaymentMethod) {
      case PurchasePaymentMethod.contado:
        return _buildContadoFields();
      case PurchasePaymentMethod.hipoteca:
        return _buildHipotecaFields();
      case PurchasePaymentMethod.promesa:
        return _buildPromesaFields();
    }
  }

  // ==================== CONTADO FIELDS ====================
  List<Widget> _buildContadoFields() {
    return [
      const SizedBox(height: 16),

      // Currency selector
      _buildCurrencySelector(),

      const SizedBox(height: 16),

      // Propuesta económica
      _buildInputFieldWithArrow(
        'Propuesta económica',
        _proposalAmountController,
        placeholder: 'x',
      ),

      const SizedBox(height: 16),

      // Tiempo estimado de pago tras aceptación de oferta
      _buildInputFieldWithArrow(
        'Tiempo estimado de pago tras aceptación de oferta',
        _paymentTimeController,
        placeholder: 'x',
      ),
    ];
  }

  // ==================== HIPOTECA FIELDS ====================
  List<Widget> _buildHipotecaFields() {
    return [
      const SizedBox(height: 24),

      // Estructura hipotecaria section
      const Text(
        'Estructura hipotecaria',
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      const SizedBox(height: 16),

      // Currency selector
      _buildCurrencySelector(),

      const SizedBox(height: 16),

      // Enganche
      _buildInputFieldWithArrow(
        'Enganche',
        _engancheController,
        placeholder: '%',
      ),

      const SizedBox(height: 16),

      // Propuesta económica and Banco a utilizar row
      Row(
        children: [
          Expanded(
            child: _buildInputFieldWithArrow(
              'Propuesta económica',
              _proposalAmountController,
              placeholder: 'x',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInputFieldWithArrow(
              'Banco a utilizar',
              _bankController,
              placeholder: 'x',
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      // Estado del crédito
      _buildInputFieldWithArrow(
        'Estado del crédito',
        _creditStatusController,
        placeholder: 'x',
      ),

      const SizedBox(height: 16),

      // Tiempo estimado para aprobación del banco
      _buildInputFieldWithArrow(
        'Tiempo estimado para aprobación del banco',
        _bankApprovalTimeController,
        placeholder: 'x',
      ),
    ];
  }

  // ==================== PROMESA FIELDS ====================
  List<Widget> _buildPromesaFields() {
    return [
      const SizedBox(height: 24),

      // Moneda de pago label
      const Text(
        'Moneda de pago',
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
          letterSpacing: 0.28,
        ),
      ),
      const SizedBox(height: 8),

      // Currency selector
      _buildCurrencySelectorButtons(),

      const SizedBox(height: 16),

      // Propuesta económica
      _buildInputFieldWithArrow(
        'Propuesta económica',
        _proposalAmountController,
        placeholder: 'x',
      ),

      const SizedBox(height: 24),

      // Estructura de pago section
      const Text(
        'Estructura de pago',
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      const SizedBox(height: 16),

      // Reserva inicial
      _buildInputFieldWithArrow(
        'Reserva inicial',
        _initialReserveController,
        placeholder: 'x',
      ),

      const SizedBox(height: 16),

      // Pago final
      _buildInputFieldWithArrow(
        'Pago final',
        _finalPaymentController,
        placeholder: 'x',
      ),

      const SizedBox(height: 16),

      // Tiempo de promesa
      _buildInputFieldWithArrow(
        'Tiempo de promesa',
        _promiseTimeController,
        placeholder: 'x meses',
      ),
    ];
  }

  // ==================== CURRENCY SELECTOR ====================
  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Moneda de pago',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 8),
        _buildCurrencySelectorButtons(),
      ],
    );
  }

  Widget _buildCurrencySelectorButtons() {
    return Row(
      children: [
        // USD button
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedCurrency = PurchaseCurrency.usd;
              });
              widget.onCurrencyChanged?.call(PurchaseCurrency.usd);
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: _selectedCurrency == PurchaseCurrency.usd
                    ? selectedButtonColor
                    : cardBackground,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: _selectedCurrency == PurchaseCurrency.usd
                      ? selectedButtonColor
                      : borderColor,
                ),
              ),
              child: Center(
                child: Text(
                  'USD',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedCurrency == PurchaseCurrency.usd
                        ? Colors.white
                        : textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Quetzales button
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedCurrency = PurchaseCurrency.quetzales;
              });
              widget.onCurrencyChanged?.call(PurchaseCurrency.quetzales);
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: _selectedCurrency == PurchaseCurrency.quetzales
                    ? selectedButtonColor
                    : cardBackground,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: _selectedCurrency == PurchaseCurrency.quetzales
                      ? selectedButtonColor
                      : borderColor,
                ),
              ),
              child: Center(
                child: Text(
                  'Quetzales',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedCurrency == PurchaseCurrency.quetzales
                        ? Colors.white
                        : textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== BUYER SECTION ====================
  Widget _buildBuyerSection() {
    final String buyerLabel =
        _selectedPaymentMethod == PurchasePaymentMethod.promesa
            ? '¿Quién será el comprador?\nNombre del arrendatario'
            : '¿Quién será el comprador?\nNombre del comprador';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          buyerLabel,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),

        // Buyer name field with arrow
        _buildInputFieldWithArrowOnly(_buyerNameController),

        const SizedBox(height: 16),

        // Is company toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Si es empresa',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: textColor,
                letterSpacing: 0.32,
              ),
            ),
            Switch(
              value: _isCompany,
              onChanged: (value) {
                setState(() {
                  _isCompany = value;
                });
              },
              activeThumbColor: primaryColor,
              activeTrackColor: primaryColor.withValues(alpha: 0.5),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ],
        ),

        // Company fields
        if (_isCompany) ...[
          const SizedBox(height: 8),

          // Razón social
          const Text(
            'Razón social',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: 0.28,
            ),
          ),
          const SizedBox(height: 8),
          _buildInputFieldWithArrowOnly(_socialReasonController),

          const SizedBox(height: 16),

          // Representante legal
          const Text(
            'Representante legal',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: 0.28,
            ),
          ),
          const SizedBox(height: 8),
          _buildInputFieldWithArrowOnly(_legalRepController),
        ],
      ],
    );
  }

  // ==================== CONSIDERATIONS FIELD ====================
  Widget _buildConsiderationsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consideraciones o solicitudes',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _considerationsController,
            maxLines: 3,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: textColor,
              letterSpacing: 0.28,
            ),
            decoration: InputDecoration(
              hintText: 'Arreglar tubería',
              hintStyle: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: placeholderColor.withValues(alpha: 0.5),
                letterSpacing: 0.28,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== INPUT FIELD HELPERS ====================
  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    String? placeholder,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: textColor,
              letterSpacing: 0.28,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: placeholderColor.withValues(alpha: 0.5),
                letterSpacing: 0.28,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFieldWithArrow(
    String label,
    TextEditingController controller, {
    String? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    color: textColor,
                    letterSpacing: 0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      color: placeholderColor.withValues(alpha: 0.5),
                      letterSpacing: 0.28,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 15),
                child: Icon(
                  Icons.chevron_right,
                  color: placeholderColor,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputFieldWithArrowOnly(TextEditingController controller) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: textColor,
                letterSpacing: 0.28,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(
              Icons.chevron_right,
              color: placeholderColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WARNING BOX ====================
  Widget _buildWarningBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningBgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Entiendo que en este complejo NO se permite:',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletPoint('Airbnb'),
          if (_selectedPaymentMethod != PurchasePaymentMethod.contado)
            _buildBulletPoint('Subarrendamiento'),
          _buildBulletPoint('Eventos'),
          _buildBulletPoint('Mascotas (si aplica)'),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: textColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================

  String _currencyString() {
    return _selectedCurrency == PurchaseCurrency.usd ? 'USD' : 'GTQ';
  }

  Map<String, dynamic> _buildBuyerInfo() {
    if (_isCompany) {
      return {
        'type': 'company',
        'name': _buyerNameController.text,
        'legalName': _socialReasonController.text,
        'legalRepresentative': _legalRepController.text,
      };
    } else {
      return {
        'type': 'individual',
        'name': _buyerNameController.text,
      };
    }
  }

  double _parseDouble(String text) {
    return double.tryParse(text.replaceAll(',', '')) ?? 0;
  }

  int _parseInt(String text) {
    return int.tryParse(text.replaceAll(',', '')) ?? 0;
  }

  Map<String, dynamic> _buildContadoBody() {
    return {
      'offerType': 'SALE',
      'offerData': {
        'paymentMethod': 'cash',
        'currency': _currencyString(),
        'proposedAmount': _parseInt(_proposalAmountController.text),
        'considerations': _considerationsController.text,
        'buyerInfo': _buildBuyerInfo(),
        'estimatedPaymentTime': _parseInt(_paymentTimeController.text),
      },
    };
  }

  Map<String, dynamic> _buildHipotecaBody() {
    return {
      'offerType': 'SALE',
      'offerData': {
        'paymentMethod': 'mortgage',
        'currency': _currencyString(),
        'proposedAmount': _parseDouble(_proposalAmountController.text),
        'considerations': _considerationsController.text,
        'buyerInfo': _buildBuyerInfo(),
        'downPaymentPercentage': _parseDouble(_engancheController.text),
        'bankName': _bankController.text,
        'creditStatus': _creditStatusController.text,
        'estimatedApprovalTime': _parseInt(_bankApprovalTimeController.text),
      },
    };
  }

  Map<String, dynamic> _buildPromesaBody() {
    return {
      'offerType': 'SALE',
      'offerData': {
        'paymentMethod': 'purchase_promise',
        'currency': _currencyString(),
        'proposedAmount': _parseDouble(_proposalAmountController.text),
        'considerations': _considerationsController.text,
        'buyerInfo': _buildBuyerInfo(),
        'initialReserve': _parseDouble(_initialReserveController.text),
        'promiseTimeMonths': _parseInt(_promiseTimeController.text),
      },
    };
  }

  void _handleOfertar() {
    switch (_selectedPaymentMethod) {
      case PurchasePaymentMethod.contado:
        widget.onContado?.call(_buildContadoBody());
        break;
      case PurchasePaymentMethod.hipoteca:
        widget.onHipoteca?.call(_buildHipotecaBody());
        break;
      case PurchasePaymentMethod.promesa:
        widget.onPromesa?.call(_buildPromesaBody());
        break;
    }
  }

  // ==================== ACCEPT BUTTON ====================
  Widget _buildAcceptButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _handleOfertar,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Ofertar',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
