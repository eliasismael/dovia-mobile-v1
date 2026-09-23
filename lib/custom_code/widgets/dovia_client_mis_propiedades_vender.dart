// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_svg/flutter_svg.dart';

class DoviaClientMisPropiedadesVender extends StatefulWidget {
  final double? width;
  final double? height;

  // Callbacks
  final VoidCallback? onAccept;
  final VoidCallback? onLocationTap;
  final VoidCallback? onUploadDocument;

  // Pre-filled data
  final String? salePrice;
  final String? propertyAddress;

  // Mapbox configuration
  final String? mapboxToken;
  final double? latitude;
  final double? longitude;

  const DoviaClientMisPropiedadesVender({
    super.key,
    this.width,
    this.height,
    this.onAccept,
    this.onLocationTap,
    this.onUploadDocument,
    this.salePrice,
    this.propertyAddress,
    this.mapboxToken,
    this.latitude,
    this.longitude,
  });

  @override
  State<DoviaClientMisPropiedadesVender> createState() =>
      _DoviaClientMisPropiedadesVenderState();
}

class _DoviaClientMisPropiedadesVenderState
    extends State<DoviaClientMisPropiedadesVender> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color backgroundColor = Color(0xFFF7F7F7);
  static const Color cardBackground = Colors.white;
  static const Color placeholderColor = Color(0xFF888888);
  static const Color infoCardColor = Color(0xFF00444B);
  static const Color borderColor = Color(0xFFE8E8E8);

  // Form controllers
  late TextEditingController _descriptionController;
  late TextEditingController _salePriceController;
  late TextEditingController _amountToReceiveController;
  late TextEditingController _maintenanceController;
  late TextEditingController _propertyTaxController;
  late TextEditingController _addressController;
  late TextEditingController _fincaController;
  late TextEditingController _folioController;
  late TextEditingController _libroController;
  late TextEditingController _societyNameController;
  late TextEditingController _legalRepController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _salePriceController = TextEditingController(text: widget.salePrice);
    _amountToReceiveController = TextEditingController();
    _maintenanceController = TextEditingController();
    _propertyTaxController = TextEditingController();
    _addressController = TextEditingController(text: widget.propertyAddress);
    _fincaController = TextEditingController();
    _folioController = TextEditingController();
    _libroController = TextEditingController();
    _societyNameController = TextEditingController();
    _legalRepController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _salePriceController.dispose();
    _amountToReceiveController.dispose();
    _maintenanceController.dispose();
    _propertyTaxController.dispose();
    _addressController.dispose();
    _fincaController.dispose();
    _folioController.dispose();
    _libroController.dispose();
    _societyNameController.dispose();
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
              // Description section
              _buildDescriptionSection(),

              const SizedBox(height: 24),

              // Price section
              _buildPriceSection(),

              const SizedBox(height: 24),

              // Maintenance section
              _buildMaintenanceSection(),

              const SizedBox(height: 24),

              // Address section
              _buildAddressSection(),

              const SizedBox(height: 24),

              // Map section
              _buildMapSection(),

              const SizedBox(height: 24),

              // Legal information section
              _buildLegalInfoSection(),

              const SizedBox(height: 24),

              // Document upload section
              _buildDocumentUploadSection(),

              const SizedBox(height: 24),

              // Info card
              _buildInfoCard(),

              const SizedBox(height: 24),

              // Accept button
              _buildAcceptButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingresa la información de tu propiedad.',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Estos datos nos permiten preparar tu publicación y validar detalles antes de enviar a nuestro equipo de producción.',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor.withAlpha(179),
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Describe de manera natural tu propiedad y el complejo',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: textColor,
              letterSpacing: 0.28,
            ),
            decoration: InputDecoration(
              hintText: 'Escribe aquí...',
              hintStyle: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: placeholderColor.withAlpha(128),
                letterSpacing: 0.28,
              ),
              contentPadding: const EdgeInsets.all(15),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Precio de venta incluyendo comisión Dovia (3.5% + IVA)',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        _buildInputField(controller: _salePriceController, placeholder: 'xxx'),
        const SizedBox(height: 16),
        const Text(
          'Cantidad a recibir',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        _buildInputField(
          controller: _amountToReceiveController,
          placeholder: 'xx',
        ),
      ],
    );
  }

  Widget _buildMaintenanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mantenimiento',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildInputField(
          controller: _maintenanceController,
          placeholder: 'xxx',
        ),
        const SizedBox(height: 16),
        const Text(
          'Impuesto único sobre inmuebles',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        _buildInputField(
          controller: _propertyTaxController,
          placeholder: 'xxx',
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dirección de propiedad',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            _buildInputField(controller: _addressController, placeholder: 'xx'),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: widget.onLocationTap,
                child: Container(
                  width: 42,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SvgPicture.string(
                      '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 2C8.13 2 5 5.13 5 9C5 14.25 12 22 12 22C12 22 19 14.25 19 9C19 5.13 15.87 2 12 2ZM12 11.5C10.62 11.5 9.5 10.38 9.5 9C9.5 7.62 10.62 6.5 12 6.5C13.38 6.5 14.5 7.62 14.5 9C14.5 10.38 13.38 11.5 12 11.5Z" fill="white"/>
                      </svg>''',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    // Build Mapbox static map URL
    String? mapUrl;
    if (widget.mapboxToken != null &&
        widget.latitude != null &&
        widget.longitude != null) {
      final lat = widget.latitude!;
      final lng = widget.longitude!;
      final token = widget.mapboxToken!;
      mapUrl =
          'https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/pin-l+007376($lng,$lat)/$lng,$lat,15,0/350x150@2x?access_token=$token';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marca en el mapa la ubicación',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: widget.onLocationTap,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: mapUrl != null
                  ? Image.network(
                      mapUrl,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: primaryColor,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildMapPlaceholder();
                      },
                    )
                  : _buildMapPlaceholder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: 150,
      color: const Color(0xFFE0E0E0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 40,
              color: placeholderColor.withAlpha(128),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para seleccionar ubicación',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 12,
                color: placeholderColor.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información legal',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Esta información se mantiene privada y solo se compartirá con tu consentimiento',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor.withAlpha(179),
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 16),

        // Finca, Folio, Libro row
        Row(
          children: [
            Expanded(child: _buildLabeledField('Finca', _fincaController)),
            const SizedBox(width: 12),
            Expanded(child: _buildLabeledField('Folio', _folioController)),
            const SizedBox(width: 12),
            Expanded(child: _buildLabeledField('Libro', _libroController)),
          ],
        ),

        const SizedBox(height: 24),

        // Society question
        const Text(
          'Si la propiedad está a nombre de una sociedad:',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),

        // Society name field
        const Text(
          'Nombre del propietario o sociedad',
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
            controller: _societyNameController,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: textColor,
              letterSpacing: 0.28,
            ),
            decoration: InputDecoration(
              hintText: 'Escribe el nombre de la sociedad',
              hintStyle: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: placeholderColor.withAlpha(128),
                letterSpacing: 0.28,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Legal representative
        const Text(
          'En caso de ser una sociedad, indicar el nombre representante legal:',
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
            controller: _legalRepController,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: textColor,
              letterSpacing: 0.28,
            ),
            decoration: InputDecoration(
              hintText: 'Escribe el nombre del la sociedad',
              hintStyle: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: placeholderColor.withAlpha(128),
                letterSpacing: 0.28,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller) {
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
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: textColor,
              letterSpacing: 0.28,
            ),
            decoration: InputDecoration(
              hintText: 'x',
              hintStyle: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: placeholderColor.withAlpha(128),
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

  Widget _buildDocumentUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subir identificación del propietario/representante legal:',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: widget.onUploadDocument,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 40,
                color: placeholderColor.withAlpha(128),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: infoCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revisaremos la información que ingresaste para asegurar que todo esté correcto y listo para continuar con el proceso.',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.28,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Si eres el propietario legal, te enviaremos un Acuerdo de Autorización para que apruebes la comercialización de tu propiedad dentro de DOVIA.',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.28,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Si la cuenta fue creada por un familiar, administrador o representante, te pediremos que confirme la relación con el propietario y que este firme digitalmente la autorización correspondiente.',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.28,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Todo el proceso es sencillo, guiado y 100% seguro.',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.28,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: widget.onAccept,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
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

  Widget _buildInputField({
    required TextEditingController controller,
    String? placeholder,
    bool readOnly = false,
  }) {
    return Container(
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
            color: placeholderColor.withAlpha(128),
            letterSpacing: 0.28,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
