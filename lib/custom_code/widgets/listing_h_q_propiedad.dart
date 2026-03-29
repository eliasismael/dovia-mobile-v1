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

class ListingHQPropiedad extends StatefulWidget {
  final double? width;
  final double? height;

  final VoidCallback? onGuardar;
  final VoidCallback? onPublicar;
  final VoidCallback? onAddServicio;
  final VoidCallback? onAddAreaAdicional;
  final Function(Map<String, dynamic>)? onSave;

  const ListingHQPropiedad({
    super.key,
    this.width,
    this.height,
    this.onGuardar,
    this.onPublicar,
    this.onAddServicio,
    this.onAddAreaAdicional,
    this.onSave,
  });

  @override
  State<ListingHQPropiedad> createState() => _ListingHQPropiedadState();
}

class _ListingHQPropiedadState extends State<ListingHQPropiedad> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color placeholderColor = Color(0xFF888888);
  static const Color borderColor = Color(0xFFE9EFF2);
  static const Color addButtonBg = Color(0xFFCCE3E4);
  static const Color alertBg = Color(0x3370ACAD);

  // ==================== SECTION EXPANSION STATE ====================
  bool _datosGeneralesExpanded = true;
  bool _caracteristicasExpanded = true;
  bool _amenidadesExpanded = true;
  bool _criteriosExpanded = true;
  bool _infoHqExpanded = true;
  bool _adicionalesExpanded = true;

  // ==================== FORM CONTROLLERS ====================
  final _descripcionController = TextEditingController();
  final _dudasController = TextEditingController();
  final _consideracionesController = TextEditingController();
  final _instruccionesController = TextEditingController();
  final _complejoController = TextEditingController();

  // ==================== DROPDOWN VALUES ====================
  String? _tipoVivienda;
  String? _direccion;
  String? _habitaciones;
  String? _banos;
  String? _parqueo;
  String? _pisos;
  String? _mediosBanos;
  String? _hasDanos;

  // ==================== CHECKBOX STATE: CARACTERÍSTICAS GENERALES ====================
  final Map<String, bool> _generalCharacteristics = {
    'Sala': false,
    'Comedor': false,
    'Lavandería': false,
    'Cuarto de servicio': false,
    'Amueblado': false,
    'Cuota de mantenimiento': false,
    'Cocina': false,
  };

  // ==================== CHECKBOX STATE: OTRAS CARACTERÍSTICAS ====================
  final Map<String, bool> _otherCharacteristics = {
    'Pet Frendly': false,
    'Permitido para Airbnb': false,
    'Permitido subarrendar': false,
  };

  // ==================== CHECKBOX STATE: PROPIEDAD (AMENIDADES) ====================
  final Map<String, bool> _propiedadAmenities = {
    'A/C': false,
    'Jardín': false,
    'Área de churrasquera': false,
    'Cocina con isla': false,
    'Sala de exterior': false,
    'Tina': false,
  };

  // ==================== CHECKBOX STATE: ÁREAS COMUNES ====================
  final Map<String, bool> _areasComunes = {
    'Piscina': false,
    'Parque de juegos': false,
    'Gimnasio': false,
    'Coworking': false,
    'Salón de eventos': false,
    'Yoga Deck': false,
    'Cocina para eventos': false,
  };

  // ==================== CHECKBOX STATE: SERVICIOS ====================
  final Map<String, bool> _servicios = {
    'Gas': false,
    'Agua': false,
    'Luz': false,
  };

  // ==================== STAR RATINGS ====================
  final Map<String, int> _starRatings = {
    'Caminabilidad': 0,
    'Áreas verdes': 0,
    'Recreación': 0,
    'Servicios esenciales': 0,
    'Colegios': 0,
    'Comercio y servicios': 0,
    'Conectividad vial': 0,
    'Seguridad': 0,
    'Zona turística': 0,
    'Gastronomía': 0,
    'Vida urbana': 0,
    'Universidades': 0,
    'Centros corporativos': 0,
    'Tranquilidad y silencio': 0,
    'Salud y hospitales': 0,
    'Movilidad': 0,
  };

  // Selected criteria (max 3)
  final Set<String> _selectedCriteria = {};

  // ==================== IMAGE UPLOAD SECTIONS ====================
  final List<String> _imageSections = [
    'Habitaciones',
    'Sala',
    'Comedor',
    'Cocina',
    'Otras zonas',
    'Plano',
    'Recorrido 360',
  ];

  @override
  void dispose() {
    _descripcionController.dispose();
    _dudasController.dispose();
    _consideracionesController.dispose();
    _instruccionesController.dispose();
    _complejoController.dispose();
    super.dispose();
  }

  // ==================== DATA COLLECTION ====================
  void _handleAction(VoidCallback? actionCallback) {
    final data = {
      'tipoVivienda': _tipoVivienda,
      'direccion': _direccion,
      'descripcion': _descripcionController.text,
      'caracteristicas': {
        'habitaciones': _habitaciones,
        'banos': _banos,
        'parqueo': _parqueo,
        'pisos': _pisos,
        'mediosBanos': _mediosBanos,
        ..._generalCharacteristics,
      },
      'otrasCaracteristicas': _otherCharacteristics,
      'amenidades': {
        'propiedad': _propiedadAmenities,
        'comunes': _areasComunes,
      },
      'urbanCriteria': _starRatings,
      'infoHq': {
        'servicios': _servicios,
        'hasDanos': _hasDanos,
      },
      'adicionales': {
        'dudas': _dudasController.text,
        'consideraciones': _consideracionesController.text,
        'instrucciones': _instruccionesController.text,
        'complejo': _complejoController.text,
      },
    };

    if (widget.onSave != null) {
      widget.onSave!(data);
    }
    if (actionCallback != null) {
      actionCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== ALERT BANNER ==========
              _buildAlertBanner(),
              const SizedBox(height: 18),

              // ========== TITLE ==========
              const Text(
                'Revisa y organiza la información sobre la vivienda',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 22 / 16,
                ),
              ),
              const SizedBox(height: 18),

              // ========== SECTION 1: DATOS GENERALES ==========
              _buildDatosGeneralesSection(),

              // ========== SECTION 2: CARACTERÍSTICAS ==========
              _buildCaracteristicasSection(),

              // ========== SECTION 3: AMENIDADES ==========
              _buildAmenidadesSection(),

              // ========== SECTION 4: CRITERIOS DE CALIFICACIÓN ==========
              _buildCriteriosSection(),

              // ========== SECTION 5: INFORMACIÓN PARA HQ ==========
              _buildInfoHqSection(),

              // ========== SECTION 6: ADICIONALES ==========
              _buildAdicionalesSection(),

              const SizedBox(height: 18),

              // ========== SECTION 7: IMAGES ==========
              _buildImagesSection(),

              const SizedBox(height: 18),

              // ========== ACTION BUTTONS ==========
              _buildActionButtons(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ALERT BANNER ====================
  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Puedes organizar, completar o ajustar datos sobre la información de la propiedad.',
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 16 / 16,
        ),
      ),
    );
  }

  // ==================== SECTION 1: DATOS GENERALES ====================
  Widget _buildDatosGeneralesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownHeader(
          'Datos generales',
          _datosGeneralesExpanded,
          () => setState(
              () => _datosGeneralesExpanded = !_datosGeneralesExpanded),
        ),
        if (_datosGeneralesExpanded) ...[
          const SizedBox(height: 11),
          // Tipo de vivienda
          _buildDropdownField(
            'Tipo de vivienda',
            _tipoVivienda,
            (val) => setState(() => _tipoVivienda = val),
          ),
          const SizedBox(height: 11),
          // Dirección
          _buildDropdownField(
            'Dirección',
            _direccion,
            (val) => setState(() => _direccion = val),
          ),
          const SizedBox(height: 12),
          // Descripción sobre la propiedad (text area)
          _buildTextAreaField(
            'Descripción sobre la propiedad',
            _descripcionController,
            placeholder: 'Añade detalles adicionales si es necesario',
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ==================== SECTION 2: CARACTERÍSTICAS ====================
  Widget _buildCaracteristicasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownHeader(
          'Características',
          _caracteristicasExpanded,
          () => setState(
              () => _caracteristicasExpanded = !_caracteristicasExpanded),
        ),
        if (_caracteristicasExpanded) ...[
          const SizedBox(height: 12),
          // Características generales header with "Añadir" button
          _buildSubSectionHeaderWithAdd('Características generales'),
          const SizedBox(height: 12),
          // Habitaciones + Baños
          _buildDoubleDropdownRow(
            'Habitaciones',
            'Baños',
            _habitaciones,
            _banos,
            (v) => setState(() => _habitaciones = v),
            (v) => setState(() => _banos = v),
          ),
          const SizedBox(height: 12),
          // Parqueo + Pisos
          _buildDoubleDropdownRow(
            'Parqueo',
            'Pisos',
            _parqueo,
            _pisos,
            (v) => setState(() => _parqueo = v),
            (v) => setState(() => _pisos = v),
          ),
          const SizedBox(height: 12),
          // Medios baños (single full width)
          _buildSingleDropdownRow(
            'Medios baños',
            _mediosBanos,
            (v) => setState(() => _mediosBanos = v),
          ),
          const SizedBox(height: 11),
          // Checkboxes for general characteristics
          _buildCheckboxGroup(_generalCharacteristics),
          const SizedBox(height: 16),
          // Otras características header with "Añadir" button
          _buildSubSectionHeaderWithAdd('Otras características'),
          const SizedBox(height: 11),
          // Checkboxes for other characteristics
          _buildCheckboxGroup(_otherCharacteristics),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ==================== SECTION 3: AMENIDADES ====================
  Widget _buildAmenidadesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownHeader(
          'Amenidades',
          _amenidadesExpanded,
          () => setState(() => _amenidadesExpanded = !_amenidadesExpanded),
        ),
        if (_amenidadesExpanded) ...[
          const SizedBox(height: 12),
          // Propiedad header with "Añadir"
          _buildSubSectionHeaderWithAdd('Propiedad'),
          const SizedBox(height: 11),
          _buildCheckboxGroup(_propiedadAmenities),
          const SizedBox(height: 16),
          // Áreas comunes header with "Añadir"
          _buildSubSectionHeaderWithAdd('Áreas comunes'),
          const SizedBox(height: 11),
          _buildCheckboxGroup(_areasComunes),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ==================== SECTION 4: CRITERIOS DE CALIFICACIÓN ====================
  Widget _buildCriteriosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownHeader(
          'Criterios de calificación',
          _criteriosExpanded,
          () => setState(() => _criteriosExpanded = !_criteriosExpanded),
          fontSize: 14,
        ),
        if (_criteriosExpanded) ...[
          const SizedBox(height: 12),
          // Instruction text
          const Text(
            'Selecciona máximo 3 criterios y califica de 1 a 5 estrellas',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          // Criteria selector button
          GestureDetector(
            onTap: () {
              // Could open a modal/bottom sheet for criteria selection
            },
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: inputBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                'Selecciona el criterio',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: placeholderColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Star rating items
          ..._starRatings.entries.map(
            (entry) => _buildStarRatingItem(entry.key, entry.value),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ==================== SECTION 5: INFORMACIÓN PARA HQ ====================
  Widget _buildInfoHqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownHeader(
          'Información para HQ',
          _infoHqExpanded,
          () => setState(() => _infoHqExpanded = !_infoHqExpanded),
          fontSize: 14,
        ),
        if (_infoHqExpanded) ...[
          const SizedBox(height: 17),
          // Servicios header with "Añadir" button
          _buildSubSectionHeaderWithAdd('Servicios '),
          const SizedBox(height: 12),
          // Servicios checkboxes in grid layout (2 per row)
          _buildCheckboxGridGroup(_servicios),
          const SizedBox(height: 17),
          // Hay daños en la propiedad
          _buildDropdownFieldWithArrow(
            'Hay daños en la propiedad',
            _hasDanos,
            (val) => setState(() => _hasDanos = val),
            options: ['Si', 'No'],
            placeholder: 'No',
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ==================== SECTION 6: ADICIONALES ====================
  Widget _buildAdicionalesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownHeader(
          'Adicionales',
          _adicionalesExpanded,
          () => setState(() => _adicionalesExpanded = !_adicionalesExpanded),
          fontSize: 14,
        ),
        if (_adicionalesExpanded) ...[
          const SizedBox(height: 18),
          _buildTextAreaField(
            'Anota las dudas que tengas',
            _dudasController,
            placeholder: 'XXX',
            labelFontSize: 14,
          ),
          const SizedBox(height: 18),
          _buildTextAreaField(
            'Anota las consideraciones que tengas para enseñar (información privada)',
            _consideracionesController,
            placeholder: 'XXX',
            labelFontSize: 14,
          ),
          const SizedBox(height: 18),
          _buildTextAreaField(
            'Anota las instrucciones para el visitante',
            _instruccionesController,
            placeholder: 'XXX',
            labelFontSize: 14,
          ),
          const SizedBox(height: 18),
          _buildTextAreaField(
            'Anota sobre el complejo',
            _complejoController,
            placeholder: 'XXX',
            labelFontSize: 14,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ==================== SECTION 7: IMAGES ====================
  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Agrega las imágenes por secciones',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.32,
          ),
        ),
        const SizedBox(height: 12),
        // "Añadir área adicional" button
        GestureDetector(
          onTap: widget.onAddAreaAdicional,
          child: Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
              color: addButtonBg,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 16, color: primaryColor),
                SizedBox(width: 2),
                Text(
                  'Añadir área adicional',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Image upload sections
        ..._imageSections.map(
          (section) => _buildImageUploadSection(section),
        ),
      ],
    );
  }

  // ==================== IMAGE UPLOAD SECTION ====================
  Widget _buildImageUploadSection(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.32,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            // Trigger image picker
          },
          child: Container(
            width: double.infinity,
            height: 104,
            decoration: BoxDecoration(
              color: inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.add_photo_alternate_outlined,
                size: 24,
                color: placeholderColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Guardar button (outline)
        Expanded(
          child: GestureDetector(
            onTap: () => _handleAction(widget.onGuardar),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor, width: 1),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Guardar',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  height: 14 / 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 11),
        // Publicar button (filled)
        Expanded(
          child: GestureDetector(
            onTap: () => _handleAction(widget.onPublicar),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: primaryColor,
                border: Border.all(color: primaryColor, width: 1),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Publicar',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 14 / 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== REUSABLE: DROPDOWN SECTION HEADER ====================
  Widget _buildDropdownHeader(
    String title,
    bool isExpanded,
    VoidCallback onTap, {
    double fontSize = 16,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
          ),
        ),
        padding:
            const EdgeInsets.only(left: 16, right: 12, top: 10, bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  height: 24 / fontSize,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: textColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== REUSABLE: SUBSECTION HEADER WITH "AÑADIR" ====================
  Widget _buildSubSectionHeaderWithAdd(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Add action
          },
          child: Container(
            height: 30,
            width: 91,
            decoration: BoxDecoration(
              color: addButtonBg,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 16, color: primaryColor),
                SizedBox(width: 2),
                Text(
                  'Añadir',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== REUSABLE: DROPDOWN FIELD ====================
  Widget _buildDropdownField(
    String label,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 35,
          decoration: BoxDecoration(
            color: inputBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          alignment: Alignment.centerLeft,
          child: Text(
            value ?? 'x',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: placeholderColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== REUSABLE: DOUBLE DROPDOWN ROW ====================
  Widget _buildDoubleDropdownRow(
    String label1,
    String label2,
    String? value1,
    String? value2,
    ValueChanged<String?> onChanged1,
    ValueChanged<String?> onChanged2,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label1,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label2,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallDropdown(value1, onChanged1),
            ),
            const SizedBox(width: 17),
            Expanded(
              child: _buildSmallDropdown(value2, onChanged2),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== REUSABLE: SINGLE DROPDOWN ROW ====================
  Widget _buildSingleDropdownRow(
    String label,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildSmallDropdown(value, onChanged),
      ],
    );
  }

  // ==================== REUSABLE: SMALL DROPDOWN ====================
  Widget _buildSmallDropdown(String? value, ValueChanged<String?> onChanged) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: inputBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value ?? 'x',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: placeholderColor.withValues(alpha: 0.5),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 10,
            color: placeholderColor,
          ),
        ],
      ),
    );
  }

  // ==================== REUSABLE: DROPDOWN FIELD WITH ARROW ====================
  Widget _buildDropdownFieldWithArrow(
    String label,
    String? value,
    ValueChanged<String?> onChanged, {
    List<String>? options,
    String placeholder = 'x',
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
            height: 49.849 / 14,
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: inputBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value ?? placeholder,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: placeholderColor.withValues(alpha: 0.5),
                  letterSpacing: 0.28,
                  height: 49.849 / 14,
                ),
              ),
              Transform.rotate(
                angle: -1.5708,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 24,
                  color: placeholderColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== REUSABLE: TEXT AREA FIELD ====================
  Widget _buildTextAreaField(
    String label,
    TextEditingController controller, {
    String placeholder = '',
    bool showLabel = true,
    double labelFontSize = 16,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel && label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: labelFontSize,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: labelFontSize == 14 ? 0.28 : 0,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          height: 104,
          decoration: BoxDecoration(
            color: inputBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: labelFontSize == 14 ? 14 : 16,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: labelFontSize == 14 ? 14 : 16,
                color: placeholderColor.withValues(alpha: 0.5),
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

  // ==================== REUSABLE: CHECKBOX GROUP (VERTICAL) ====================
  Widget _buildCheckboxGroup(Map<String, bool> items) {
    final entries = items.entries.toList();
    // Group into pairs for 2-column layout
    final List<Widget> rows = [];
    for (int i = 0; i < entries.length; i += 2) {
      if (i + 1 < entries.length) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(
              children: [
                Expanded(
                  child: _buildCheckboxItem(
                    entries[i].key,
                    entries[i].value,
                    (val) {
                      setState(() {
                        items[entries[i].key] = val ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildCheckboxItem(
                    entries[i + 1].key,
                    entries[i + 1].value,
                    (val) {
                      setState(() {
                        items[entries[i + 1].key] = val ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _buildCheckboxItem(
              entries[i].key,
              entries[i].value,
              (val) {
                setState(() {
                  items[entries[i].key] = val ?? false;
                });
              },
            ),
          ),
        );
      }
    }
    return Column(children: rows);
  }

  // ==================== REUSABLE: CHECKBOX GRID GROUP ====================
  Widget _buildCheckboxGridGroup(Map<String, bool> items) {
    final entries = items.entries.toList();
    final List<Widget> rows = [];
    for (int i = 0; i < entries.length; i += 2) {
      if (i + 1 < entries.length) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(
              children: [
                Expanded(
                  child: _buildCheckboxItem(
                    entries[i].key,
                    entries[i].value,
                    (val) {
                      setState(() {
                        items[entries[i].key] = val ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildCheckboxItem(
                    entries[i + 1].key,
                    entries[i + 1].value,
                    (val) {
                      setState(() {
                        items[entries[i + 1].key] = val ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _buildCheckboxItem(
              entries[i].key,
              entries[i].value,
              (val) {
                setState(() {
                  items[entries[i].key] = val ?? false;
                });
              },
            ),
          ),
        );
      }
    }
    return Column(children: rows);
  }

  // ==================== REUSABLE: SINGLE CHECKBOX ITEM ====================
  Widget _buildCheckboxItem(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
              color: value ? primaryColor : Colors.transparent,
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Avenir',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: textColor,
                height: 24 / 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== REUSABLE: STAR RATING ITEM ====================
  Widget _buildStarRatingItem(String label, int rating) {
    return Container(
      height: 171,
      margin: const EdgeInsets.only(bottom: 23),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon placeholder (circle)
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: addButtonBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: primaryColor,
              size: 27,
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 23.2 / 16,
            ),
          ),
          const SizedBox(height: 8),
          // Star rating row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  if (_selectedCriteria.length < 3 ||
                      _selectedCriteria.contains(label)) {
                    setState(() {
                      _starRatings[label] = index + 1;
                      if (index + 1 > 0) {
                        _selectedCriteria.add(label);
                      }
                    });
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < 4 ? 5 : 0,
                  ),
                  child: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 24,
                    color: index < rating
                        ? const Color(0xFFFFC107)
                        : placeholderColor.withValues(alpha: 0.4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
