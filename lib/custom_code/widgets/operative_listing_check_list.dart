// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/app_state.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class OperativeListingCheckList extends StatefulWidget {
  final double? width;
  final double? height;

  final VoidCallback? onAddServicio;
  final Function? onSave;

  const OperativeListingCheckList({
    super.key,
    this.width,
    this.height,
    this.onAddServicio,
    this.onSave,
  });

  @override
  State<OperativeListingCheckList> createState() =>
      OperativeListingCheckListState();
}

class OperativeListingCheckListState extends State<OperativeListingCheckList> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color placeholderColor = Color(0xFF888888);
  static const Color borderColor = Color(0xFFE9EFF2);
  static const Color addButtonBg = Color(0xFFCCE3E4);

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
  final _danosDescripcionController = TextEditingController();

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
  final Map<String, bool> _servicios = {};

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

  // ==================== VALIDATION & KEYS ====================
  final GlobalKey _keyDatosGenerales = GlobalKey();
  final GlobalKey _keyCaracteristicas = GlobalKey();
  final GlobalKey _keyAmenidades = GlobalKey();
  final GlobalKey _keyCriterios = GlobalKey();
  final GlobalKey _keyInfoHq = GlobalKey();
  final GlobalKey _keyAdicionales = GlobalKey();

  bool _errorTipoVivienda = false;
  bool _errorDireccion = false;
  bool _errorHabitaciones = false;
  bool _errorCriterios = false;
  bool _errorDanos = false;

  bool validateForm() {
    setState(() {
      _errorTipoVivienda = _tipoVivienda == null;
      _errorDireccion = _direccion == null;
      _errorHabitaciones = _habitaciones == null;
      _errorCriterios = _selectedCriteria.length < 3;
      _errorDanos =
          _hasDanos == 'Si' && _danosDescripcionController.text.trim().isEmpty;
    });

    if (_errorTipoVivienda || _errorDireccion) {
      if (!_datosGeneralesExpanded)
        setState(() => _datosGeneralesExpanded = true);
      Scrollable.ensureVisible(_keyDatosGenerales.currentContext!,
          duration: const Duration(milliseconds: 300));
      return false;
    }
    if (_errorHabitaciones) {
      if (!_caracteristicasExpanded)
        setState(() => _caracteristicasExpanded = true);
      Scrollable.ensureVisible(_keyCaracteristicas.currentContext!,
          duration: const Duration(milliseconds: 300));
      return false;
    }
    if (_errorCriterios) {
      if (!_criteriosExpanded) setState(() => _criteriosExpanded = true);
      Scrollable.ensureVisible(_keyCriterios.currentContext!,
          duration: const Duration(milliseconds: 300));
      return false;
    }
    if (_errorDanos) {
      if (!_infoHqExpanded) setState(() => _infoHqExpanded = true);
      Scrollable.ensureVisible(_keyInfoHq.currentContext!,
          duration: const Duration(milliseconds: 300));
      return false;
    }

    return true;
  }

  Map<String, dynamic> getFormData() {
    return {
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
      'starRatings': _starRatings,
      'infoHq': {
        'servicios': _servicios,
        'hasDanos': _hasDanos,
        'danosDescripcion': _danosDescripcionController.text,
      },
      'adicionales': {
        'dudas': _dudasController.text,
        'consideraciones': _consideracionesController.text,
        'instrucciones': _instruccionesController.text,
        'complejo': _complejoController.text,
      },
    };
  }

  // Selected criteria (max 3)
  final Set<String> _selectedCriteria = {};

  late SharedPreferences _prefs;
  String get _draftKey => 'checklist_draft_${FFAppState().lastActiveVisitId}';
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _loadState();

    _descripcionController.addListener(_saveState);
    _dudasController.addListener(_saveState);
    _consideracionesController.addListener(_saveState);
    _instruccionesController.addListener(_saveState);
    _complejoController.addListener(_saveState);
    _danosDescripcionController.addListener(_saveState);
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    final draftJson = _prefs.getString(_draftKey);
    if (draftJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(draftJson);
        super.setState(() {
          _tipoVivienda = data['tipoVivienda'];
          _direccion = data['direccion'];
          _habitaciones = data['habitaciones'];
          _banos = data['banos'];
          _parqueo = data['parqueo'];
          _pisos = data['pisos'];
          _mediosBanos = data['mediosBanos'];
          _hasDanos = data['hasDanos'];

          if (data['descripcion'] != null)
            _descripcionController.text = data['descripcion'];
          if (data['dudas'] != null) _dudasController.text = data['dudas'];
          if (data['consideraciones'] != null)
            _consideracionesController.text = data['consideraciones'];
          if (data['instrucciones'] != null)
            _instruccionesController.text = data['instrucciones'];
          if (data['complejo'] != null)
            _complejoController.text = data['complejo'];
          if (data['danosDescripcion'] != null)
            _danosDescripcionController.text = data['danosDescripcion'];

          if (data['generalCharacteristics'] != null)
            _updateMapFromJson(
                _generalCharacteristics, data['generalCharacteristics']);
          if (data['otherCharacteristics'] != null)
            _updateMapFromJson(
                _otherCharacteristics, data['otherCharacteristics']);
          if (data['propiedadAmenities'] != null)
            _updateMapFromJson(_propiedadAmenities, data['propiedadAmenities']);
          if (data['areasComunes'] != null)
            _updateMapFromJson(_areasComunes, data['areasComunes']);
          if (data['servicios'] != null)
            _updateMapFromJson(_servicios, data['servicios']);
          if (data['starRatings'] != null) {
            Map<String, dynamic> ratings = data['starRatings'];
            ratings.forEach((key, value) {
              _starRatings[key] = value as int;
              if (value > 0) _selectedCriteria.add(key);
            });
          }
        });
      } catch (e) {
        print('Error loading checklist draft: $e');
      }
    }
    _isInit = true;
  }

  void _updateMapFromJson(
      Map<String, bool> target, Map<String, dynamic> source) {
    source.forEach((key, value) {
      target[key] = value as bool;
    });
  }

  void _saveState() {
    if (!_isInit) return;
    final Map<String, dynamic> data = {
      'tipoVivienda': _tipoVivienda,
      'direccion': _direccion,
      'habitaciones': _habitaciones,
      'banos': _banos,
      'parqueo': _parqueo,
      'pisos': _pisos,
      'mediosBanos': _mediosBanos,
      'hasDanos': _hasDanos,
      'descripcion': _descripcionController.text,
      'dudas': _dudasController.text,
      'consideraciones': _consideracionesController.text,
      'instrucciones': _instruccionesController.text,
      'complejo': _complejoController.text,
      'danosDescripcion': _danosDescripcionController.text,
      'generalCharacteristics': _generalCharacteristics,
      'otherCharacteristics': _otherCharacteristics,
      'propiedadAmenities': _propiedadAmenities,
      'areasComunes': _areasComunes,
      'servicios': _servicios,
      'starRatings': _starRatings,
    };
    _prefs.setString(_draftKey, jsonEncode(data));
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _saveState();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _dudasController.dispose();
    _consideracionesController.dispose();
    _instruccionesController.dispose();
    _complejoController.dispose();
    _danosDescripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            const SizedBox(height: 16),

            // ========== ALERT ==========
            // _buildAlert(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION 1: DATOS GENERALES ====================
  Widget _buildDatosGeneralesSection() {
    return Column(
      key: _keyDatosGenerales,
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
          // Tipo de vivienda + Dirección side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdownField(
                  'Tipo de vivienda',
                  _tipoVivienda,
                  (val) => setState(() => _tipoVivienda = val),
                  options: const [
                    'Casa',
                    'Apartamento',
                    'Duplex',
                    'Penthouse',
                    'Terreno',
                    'Otro'
                  ],
                  hasError: _errorTipoVivienda,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: _buildDropdownField(
                  'Dirección',
                  _direccion,
                  (val) => setState(() => _direccion = val),
                  options: const [
                    'Av. Reforma 10-00, Z. 9',
                    'Bulevar Vista Hermosa 12-45, Z. 15',
                    '10a Calle A 5-67, Z. 14',
                    'Ruta 4 3-21, Z. 4'
                  ],
                  hasError: _errorDireccion,
                ),
              ),
            ],
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
      key: _keyCaracteristicas,
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
          _buildSubSectionHeaderWithAdd(
              'Características generales', _generalCharacteristics),
          const SizedBox(height: 12),
          // Habitaciones + Baños
          _buildDoubleDropdownRow(
            'Habitaciones',
            'Baños',
            _habitaciones,
            _banos,
            (v) => setState(() => _habitaciones = v),
            (v) => setState(() => _banos = v),
            options1: const ['1', '2', '3', '4', '5+'],
            options2: const ['1', '2', '3', '4', '5+'],
            hasError1: _errorHabitaciones,
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
            options1: const ['0', '1', '2', '3', '4+'],
            options2: const ['1', '2', '3', '4+'],
          ),
          const SizedBox(height: 12),
          // Medios baños (single)
          _buildSingleDropdownRow(
            'Medios baños',
            _mediosBanos,
            (v) => setState(() => _mediosBanos = v),
            options: const ['0', '1', '2', '3+'],
          ),
          const SizedBox(height: 11),
          // Checkboxes for general characteristics
          _buildCheckboxGroup(_generalCharacteristics),
          const SizedBox(height: 16),
          // Otras características header with "Añadir" button
          _buildSubSectionHeaderWithAdd(
              'Otras características', _otherCharacteristics),
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
      key: _keyAmenidades,
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
          _buildSubSectionHeaderWithAdd('Propiedad', _propiedadAmenities),
          const SizedBox(height: 11),
          _buildCheckboxGroup(_propiedadAmenities),
          const SizedBox(height: 16),
          // Áreas comunes header with "Añadir"
          _buildSubSectionHeaderWithAdd('Áreas comunes', _areasComunes),
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
      key: _keyCriterios,
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
          if (_errorCriterios)
            const Text(
              '¡Debes seleccionar al menos 3 criterios!',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          const SizedBox(height: 6),
          // Description input area
          _buildTextAreaField(
            '',
            TextEditingController(),
            placeholder: 'Añade detalles adicionales si es necesario',
            showLabel: false,
          ),
          const SizedBox(height: 12),
          // Instruction text
          const Text(
            'Selecciona máximo 3 criterio y califica de 1 a 5 estrellas',
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
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: _starRatings.entries
                  .map(
                    (entry) => _buildStarRatingItem(entry.key, entry.value),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ==================== SECTION 5: INFORMACIÓN PARA HQ ====================
  Widget _buildInfoHqSection() {
    return Column(
      key: _keyInfoHq,
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
          // Servicios label + button
          const Text(
            'Servicios ',
            style: TextStyle(
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
              _showAddCustomItemDialog('Servicios', _servicios);
            },
            child: Container(
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: primaryColor),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Añadir servicios',
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
          const SizedBox(height: 17),
          _buildCheckboxGroup(_servicios),
          const SizedBox(height: 17),
          // Hay daños en la propiedad
          _buildDropdownFieldWithArrow(
            'Hay daños en la propiedad',
            _hasDanos,
            (val) => setState(() => _hasDanos = val),
            options: ['Si', 'No'],
            placeholder: 'Si/No',
          ),
          if (_hasDanos == 'Si') ...[
            const SizedBox(height: 12),
            _buildTextAreaField(
              'Describe los daños',
              _danosDescripcionController,
              placeholder: 'Escribe aquí...',
              hasError: _errorDanos,
            ),
          ],
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ==================== SECTION 6: ADICIONALES ====================
  Widget _buildAdicionalesSection() {
    return Column(
      key: _keyAdicionales,
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
            placeholder: 'Escribe aquí...',
            labelFontSize: 14,
          ),
          const SizedBox(height: 18),
          _buildTextAreaField(
            'Anota las consideraciones que tengas para enseñar (información privada)',
            _consideracionesController,
            placeholder: 'Escribe aquí...',
            labelFontSize: 14,
          ),
          const SizedBox(height: 18),
          _buildTextAreaField(
            'Anota las instrucciones para el visitante',
            _instruccionesController,
            placeholder: 'Escribe aquí...',
            labelFontSize: 14,
          ),
          const SizedBox(height: 18),
          _buildTextAreaField(
            'Anota sobre el complejo',
            _complejoController,
            placeholder: 'Escribe aquí...',
            labelFontSize: 14,
          ),
          const SizedBox(height: 10),
        ],
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
  Widget _buildSubSectionHeaderWithAdd(
      String title, Map<String, bool> targetMap) {
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
            _showAddCustomItemDialog(title, targetMap);
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

  void _showAddCustomItemDialog(
      String sectionName, Map<String, bool> targetMap) {
    String titleText = '';
    String hintText = 'Escribe aquí...';

    if (sectionName == 'Características generales') {
      titleText = 'Añade una característica general a la propiedad';
    } else if (sectionName == 'Otras características') {
      titleText = 'Añade otra característica a la propiedad';
    } else if (sectionName == 'Propiedad') {
      titleText = 'Añade una amenity a la propiedad';
    } else if (sectionName == 'Áreas comunes') {
      titleText = 'Añade un área común a la propiedad';
    } else if (sectionName == 'Servicios') {
      titleText = 'Agregar un servicio a la propiedad';
    } else {
      titleText = 'Agregar a la propiedad';
    }

    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 20,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 20,
                          color: placeholderColor.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (controller.text.trim().isNotEmpty) {
                          setState(() {
                            targetMap[controller.text.trim()] = true;
                          });
                          Navigator.pop(context);
                          _showSuccessPopup();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Agregar',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showSuccessPopup() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            // Check if still mounted to avoid popping something else
            if (mounted && Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          });
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Se agregó con éxito',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                    weight: 700,
                  ),
                ),
              ],
            ),
          );
        });
  }

  // ==================== REUSABLE: DROPDOWN FIELD ====================
  Widget _buildDropdownField(
    String label,
    String? value,
    ValueChanged<String?> onChanged, {
    required List<String> options,
    bool hasError = false,
  }) {
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
        PopupMenuButton<String>(
          onSelected: onChanged,
          itemBuilder: (context) {
            return options.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: inputBackground,
              borderRadius: BorderRadius.circular(10),
              border:
                  hasError ? Border.all(color: Colors.red, width: 1.5) : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? 'Selecciona',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: value != null
                          ? textColor
                          : placeholderColor.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: placeholderColor,
                ),
              ],
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
    ValueChanged<String?> onChanged2, {
    required List<String> options1,
    required List<String> options2,
    bool hasError1 = false,
    bool hasError2 = false,
  }) {
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
              child: _buildSmallDropdown(value1, onChanged1,
                  options: options1, hasError: hasError1),
            ),
            const SizedBox(width: 17),
            Expanded(
              child: _buildSmallDropdown(value2, onChanged2,
                  options: options2, hasError: hasError2),
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
    ValueChanged<String?> onChanged, {
    required List<String> options,
    bool hasError = false,
  }) {
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
        Row(
          children: [
            Expanded(
              child: _buildSmallDropdown(value, onChanged,
                  options: options, hasError: hasError),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== REUSABLE: SMALL DROPDOWN ====================
  Widget _buildSmallDropdown(
    String? value,
    ValueChanged<String?> onChanged, {
    required List<String> options,
    bool hasError = false,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) {
        return options.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: inputBackground,
          borderRadius: BorderRadius.circular(10),
          border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
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
                color: value != null
                    ? textColor
                    : placeholderColor.withValues(alpha: 0.5),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 10,
              color: placeholderColor,
            ),
          ],
        ),
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
          ),
        ),
        const SizedBox(height: 12),
        PopupMenuButton<String>(
          onSelected: onChanged,
          itemBuilder: (context) {
            return (options ?? []).map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
          child: Container(
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
                    color: value != null
                        ? textColor
                        : placeholderColor.withValues(alpha: 0.5),
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
    bool hasError = false,
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
            border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
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

  // ==================== REUSABLE: CHECKBOX GROUP ====================
  Widget _buildCheckboxGroup(Map<String, bool> items) {
    final entries = items.entries.toList();
    return Column(
      children: entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: _buildCheckboxItem(
            entry.key,
            entry.value,
            (val) {
              setState(() {
                items[entry.key] = val ?? false;
              });
            },
          ),
        );
      }).toList(),
    );
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
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Avenir',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor,
              height: 24 / 16,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== REUSABLE: STAR RATING ITEM ====================
  Widget _buildStarRatingItem(String label, int rating) {
    final bool isSelected = rating > 0;
    return Container(
      width: (MediaQuery.of(context).size.width - 32 - 16) / 2,
      height: 171,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryColor : borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon placeholder (circle)
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : addButtonBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_outline_rounded,
              color: isSelected ? Colors.white : primaryColor,
              size: 27,
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            textAlign: TextAlign.center,
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
                      if (_starRatings[label] == index + 1) {
                        // Toggle off
                        _starRatings[label] = 0;
                        _selectedCriteria.remove(label);
                      } else {
                        _starRatings[label] = index + 1;
                        if (index + 1 > 0) {
                          _selectedCriteria.add(label);
                        }
                      }
                    });
                  } else {
                    // Maximum of 3 reached
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Ya has seleccionado el máximo de 3 criterios.')),
                    );
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
