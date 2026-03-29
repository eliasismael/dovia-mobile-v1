// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class RentalOfferWidget extends StatefulWidget {
  final double? width;
  final double? height;

  final VoidCallback? onAccept;
  final Function? onPropertyUseChanged;
  final Function? onNotAllowedUseChanged;

  final String? monthlyPrice;
  final String? availableFrom;
  final String? contractMonths;
  final String? otherConsiderations;
  final String? allowedUse;
  final String? notAllowedUse;

  const RentalOfferWidget({
    super.key,
    this.width,
    this.height,
    this.onAccept,
    this.onPropertyUseChanged,
    this.onNotAllowedUseChanged,
    this.monthlyPrice,
    this.availableFrom,
    this.contractMonths,
    this.otherConsiderations,
    this.allowedUse,
    this.notAllowedUse,
  });

  @override
  State<RentalOfferWidget> createState() => _RentalOfferWidgetState();
}

class _RentalOfferWidgetState extends State<RentalOfferWidget> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color backgroundColor = Color(0xFFF7F7F7);
  static const Color cardBackground = Colors.white;
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color placeholderColor = Color(0xFF9E9E9E);
  static const Color warningBgColor = Color(0xFFE5F5F5);

  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _durationController;
  late TextEditingController _propertyUseController;
  late TextEditingController _considerationsController;
  late TextEditingController _tenantNameController;
  late TextEditingController _companyController;
  late TextEditingController _socialReasonController;
  late TextEditingController _legalRepController;

  bool _isCompany = false;
  bool _requisitosExpanded = false;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _durationController = TextEditingController(
      text: 'Calculo en base a fechas',
    );
    _propertyUseController = TextEditingController(text: 'Vivienda personal');
    _considerationsController = TextEditingController(
      text: 'Pintar pared del cuarto principal',
    );
    _tenantNameController = TextEditingController();
    _companyController = TextEditingController();
    _socialReasonController = TextEditingController();
    _legalRepController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _durationController.dispose();
    _propertyUseController.dispose();
    _considerationsController.dispose();
    _tenantNameController.dispose();
    _companyController.dispose();
    _socialReasonController.dispose();
    _legalRepController.dispose();
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
              // Section: Características del propietario
              _buildOwnerCharacteristicsSection(),

              const SizedBox(height: 24),

              Container(height: 1, color: borderColor),

              const SizedBox(height: 24),

              _buildProposalSection(),

              const SizedBox(height: 24),

              _buildTenantSection(),

              const SizedBox(height: 24),

              _buildRequisitosDropdown(),

              const SizedBox(height: 24),

              _buildWarningBox(),

              const SizedBox(height: 16),

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

              _buildAcceptButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

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
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildReadOnlyField(
                'Precio mensual',
                widget.monthlyPrice ?? 'x',
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
        _buildReadOnlyField(
          'Tiempo mínimo de contrato por meses',
          widget.contractMonths ?? 'x meses',
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          'Otras consideraciones',
          widget.otherConsiderations ?? 'No se permiten mascotas',
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          'Uso permitido en esta propiedad',
          widget.allowedUse ?? 'Vivienda personal',
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          'Uso no permitido en esta propiedad',
          widget.notAllowedUse ?? 'Airbnb',
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
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              color: placeholderColor,
            ),
          ),
        ),
      ],
    );
  }

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
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                'Fecha de inicio de contrato',
                _startDateController,
                placeholder: 'x',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInputField(
                'Fecha de finalización de contrato',
                _endDateController,
                placeholder: 'x',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInputField(
          'Duración del contrato',
          _durationController,
          placeholder: 'Calculo en base a fechas',
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _buildInputFieldWithArrow(
          '¿Qué uso le darás a la propiedad?',
          _propertyUseController,
          placeholder: 'Vivienda personal',
        ),
        const SizedBox(height: 16),
        _buildInputField(
          'Consideraciones o solicitudes',
          _considerationsController,
          placeholder: 'Pintar pared del cuarto principal',
        ),
      ],
    );
  }

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
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                color: placeholderColor,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
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
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 16,
                      color: placeholderColor,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
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

  Widget _buildTenantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quién será el arrendatario',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildEmptyInputField(_tenantNameController),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Si es empresa',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
            const Spacer(),
            Switch(
              value: _isCompany,
              onChanged: (value) {
                setState(() {
                  _isCompany = value;
                });
              },
              activeTrackColor: primaryColor.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryColor;
                }
                return Colors.grey;
              }),
            ),
          ],
        ),
        if (_isCompany) ...[
          const SizedBox(height: 8),
          const Text(
            'Razón social',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildEmptyInputField(_socialReasonController),
          const SizedBox(height: 16),
          const Text(
            'Representante legal',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildEmptyInputField(_legalRepController),
        ],
      ],
    );
  }

  Widget _buildEmptyInputField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 16,
          color: textColor,
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRequisitosDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _requisitosExpanded = !_requisitosExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Requisitos del complejo',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  Icon(
                    _requisitosExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: placeholderColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_requisitosExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: const Text(
                'Requisitos específicos del complejo...',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: placeholderColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

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
          _buildBulletPoint('Subarrendamiento'),
          _buildBulletPoint('Eventos'),
          _buildBulletPoint('Mascotas'),
          _buildBulletPoint('Otros (según listing)'),
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
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onAccept,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Aceptar',
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
