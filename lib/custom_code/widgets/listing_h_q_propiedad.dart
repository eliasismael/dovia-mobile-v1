// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '/app_state.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
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
  final Map<String, dynamic>? initialData;

  const ListingHQPropiedad({
    super.key,
    this.width,
    this.height,
    this.onGuardar,
    this.onPublicar,
    this.onAddServicio,
    this.onAddAreaAdicional,
    this.onSave,
    this.initialData,
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
  List<String> _imageSections = [
    'Habitaciones',
    'Sala',
    'Comedor',
    'Cocina',
    'Otras zonas',
    'Plano',
    'Recorrido 360',
  ];

  // Image state
  final Map<String, List<XFile>> _images = {};
  final ImagePicker _picker = ImagePicker();

  late SharedPreferences _prefs;
  String get _draftKey => 'checklist_draft_${FFAppState().lastActiveVisitId}';
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    final draftJson = _prefs.getString(_draftKey);
    if (draftJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(draftJson);
        setState(() {
          _tipoVivienda = data['tipoVivienda'];
          _direccion = data['direccion'];
          _habitaciones = data['habitaciones'];
          _banos = data['banos'];
          _parqueo = data['parqueo'];
          _pisos = data['pisos'];
          _mediosBanos = data['mediosBanos'];
          _hasDanos = data['hasDanos'];
          
          if (data['descripcion'] != null) _descripcionController.text = data['descripcion'];
          if (data['dudas'] != null) _dudasController.text = data['dudas'];
          if (data['consideraciones'] != null) _consideracionesController.text = data['consideraciones'];
          if (data['instrucciones'] != null) _instruccionesController.text = data['instrucciones'];
          if (data['complejo'] != null) _complejoController.text = data['complejo'];

          if (data['generalCharacteristics'] != null) _updateMapFromJson(_generalCharacteristics, data['generalCharacteristics']);
          if (data['otherCharacteristics'] != null) _updateMapFromJson(_otherCharacteristics, data['otherCharacteristics']);
          if (data['propiedadAmenities'] != null) _updateMapFromJson(_propiedadAmenities, data['propiedadAmenities']);
          if (data['areasComunes'] != null) _updateMapFromJson(_areasComunes, data['areasComunes']);
          if (data['servicios'] != null) _updateMapFromJson(_servicios, data['servicios']);
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
    } else if (widget.initialData != null) {
      _populateFromInitialData(widget.initialData!);
    }
    _isInit = true;
  }
  
  void _populateFromInitialData(Map<String, dynamic> data) {
    final prop = data['property'] is Map ? data['property'] as Map : {};
    final checklist = data['checklist'] is Map ? data['checklist'] as Map : data;
    
    setState(() {
      _tipoVivienda = prop['type']?.toString() ?? checklist['tipoVivienda'];
      
      if (prop['location'] != null && prop['location']['address'] != null) {
        _direccion = prop['location']['address']['fullAddress']?.toString() ?? 
                     prop['location']['address']['street']?.toString();
      } else {
        _direccion = checklist['direccion'];
      }
      
      if (prop['description'] != null) _descripcionController.text = prop['description'];
      else if (checklist['descripcion'] != null) _descripcionController.text = checklist['descripcion'];
      
      final chars = prop['characteristics'] is Map ? prop['characteristics'] as Map : (checklist['caracteristicas'] is Map ? checklist['caracteristicas'] as Map : {});
      _habitaciones = chars['bedrooms']?.toString() ?? chars['habitaciones']?.toString();
      _banos = chars['bathrooms']?.toString() ?? chars['banos']?.toString();
      _parqueo = chars['parking']?.toString() ?? chars['parqueo']?.toString();
      _pisos = chars['floors']?.toString() ?? chars['pisos']?.toString();
      _mediosBanos = chars['halfBathrooms']?.toString() ?? chars['mediosBanos']?.toString();
      
      _generalCharacteristics.keys.forEach((k) {
        if (chars[k] == true || chars[k.toLowerCase()] == true) _generalCharacteristics[k] = true;
      });
      
      final otherChars = prop['otherCharacteristics'] is Map ? prop['otherCharacteristics'] as Map : (checklist['otrasCaracteristicas'] is Map ? checklist['otrasCaracteristicas'] as Map : {});
      _otherCharacteristics.keys.forEach((k) {
        if (otherChars[k] == true) _otherCharacteristics[k] = true;
      });

      final amenities = prop['amenities'] is Map ? prop['amenities'] as Map : (checklist['amenidades'] is Map ? checklist['amenidades'] as Map : {});
      final propAm = amenities['property'] is Map ? amenities['property'] as Map : amenities;
      _propiedadAmenities.keys.forEach((k) {
        if (propAm[k] == true) _propiedadAmenities[k] = true;
      });
      
      final comAm = amenities['common'] is Map ? amenities['common'] as Map : (amenities['comunes'] is Map ? amenities['comunes'] as Map : {});
      _areasComunes.keys.forEach((k) {
        if (comAm[k] == true) _areasComunes[k] = true;
      });

      final ratings = prop['urbanCriteria'] is Map ? prop['urbanCriteria'] as Map : (checklist['urbanCriteria'] is Map ? checklist['urbanCriteria'] as Map : {});
      ratings.forEach((key, value) {
        if (_starRatings.containsKey(key)) {
          final val = int.tryParse(value.toString()) ?? 0;
          _starRatings[key] = val;
          if (val > 0) _selectedCriteria.add(key.toString());
        }
      });
      
      final info = checklist['infoHq'] is Map ? checklist['infoHq'] as Map : {};
      final servs = info['servicios'] is Map ? info['servicios'] as Map : {};
      _servicios.keys.forEach((k) {
        if (servs[k] == true) _servicios[k] = true;
      });
      _hasDanos = info['hasDanos'];
      
      final adds = checklist['adicionales'] is Map ? checklist['adicionales'] as Map : {};
      if (adds['dudas'] != null) _dudasController.text = adds['dudas'];
      if (adds['consideraciones'] != null) _consideracionesController.text = adds['consideraciones'];
      if (adds['instrucciones'] != null) _instruccionesController.text = adds['instrucciones'];
      if (adds['complejo'] != null) _complejoController.text = adds['complejo'];

      // Populate existing images from backend
      final propImages = prop['images'];
      if (propImages is Map) {
        propImages.forEach((category, urls) {
          if (urls is List) {
            final String sectionKey = _getSectionKeyFromCategory(category.toString());
            _images[sectionKey] = urls.map((url) => XFile(url.toString())).toList();
            if (!_imageSections.contains(sectionKey)) {
              _imageSections.add(sectionKey);
            }
          }
        });
      }
      final video360 = prop['video360Url']?.toString() ?? checklist['video360Url']?.toString() ?? prop['video360']?.toString();
      if (video360 != null && video360.isNotEmpty) {
        _images['Recorrido 360'] = [XFile(video360)];
      }
    });
  }
  
  void _updateMapFromJson(Map<String, bool> target, Map<String, dynamic> source) {
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

  bool validateForm() {
    bool hasError = false;
    
    final requiredSections = ['Habitaciones', 'Sala', 'Comedor', 'Cocina'];
    for (final section in requiredSections) {
      if (_images[section] == null || _images[section]!.isEmpty) {
        hasError = true;
      }
    }
    
    if (_tipoVivienda == null || _direccion == null || _habitaciones == null) {
      hasError = true;
    }

    if (_selectedCriteria.length < 3) {
       hasError = true;
    }
    
    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios y sube las fotos requeridas.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _dudasController.dispose();
    _consideracionesController.dispose();
    _instruccionesController.dispose();
    _complejoController.dispose();
    super.dispose();
  }

  String _getSectionKeyFromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'habitacion':
      case 'habitaciones':
        return 'Habitaciones';
      case 'sala':
        return 'Sala';
      case 'comedor':
        return 'Comedor';
      case 'cocina':
        return 'Cocina';
      case 'otras':
      case 'otraszonas':
      case 'otras_zonas':
        return 'Otras zonas';
      case 'plano':
      case 'planos':
        return 'Plano';
      case 'recorrido360':
      case 'video360':
        return 'Recorrido 360';
      default:
        if (category.isEmpty) return category;
        return category[0].toUpperCase() + category.substring(1);
    }
  }

  // ==================== DATA COLLECTION ====================
  Future<void> _handleAction(VoidCallback? actionCallback, {bool isPublish = false}) async {
    if (isPublish) {
      if (!validateForm()) return;
    }
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
      'images': _images,
    };

    if (widget.onSave != null) {
      final res = widget.onSave!(data);
      if (res is Future) {
        await res;
      }
    }
    if (actionCallback != null) {
      actionCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      color: Colors.white,
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
          _buildSubSectionHeaderWithAdd(
            'Características generales',
            () => _showAddDialog(
              'Agrega una característica general adicional',
              _generalCharacteristics,
            ),
          ),
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
          _buildSubSectionHeaderWithAdd(
            'Otras características',
            () => _showAddDialog(
              'Agrega otra característica adicional',
              _otherCharacteristics,
            ),
          ),
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
          _buildSubSectionHeaderWithAdd(
            'Propiedad',
            () => _showAddDialog(
              'Agrega una amenidad de propiedad adicional',
              _propiedadAmenities,
            ),
          ),
          const SizedBox(height: 11),
          _buildCheckboxGroup(_propiedadAmenities),
          const SizedBox(height: 16),
          // Áreas comunes header with "Añadir"
          _buildSubSectionHeaderWithAdd(
            'Áreas comunes',
            () => _showAddDialog(
              'Agrega una amenidad de área común adicional',
              _areasComunes,
            ),
          ),
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
          _buildSubSectionHeaderWithAdd(
            'Servicios ',
            () => _showAddDialog(
              'Agrega un servicio adicional',
              _servicios,
            ),
          ),
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
          onTap: () async {
            String newArea = '';
            final added = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Añadir área adicional'),
                content: TextField(
                  onChanged: (v) => newArea = v,
                  decoration: const InputDecoration(hintText: 'Ej: Jardín trasero'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Añadir'),
                  ),
                ],
              ),
            );
            if (added == true && newArea.trim().isNotEmpty) {
              setState(() {
                if (!_imageSections.contains(newArea.trim())) {
                  _imageSections.add(newArea.trim());
                }
              });
            }
          },
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
    final imagesForSection = _images[label] ?? [];

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
          onTap: () async {
            final List<XFile>? selectedImages = await _picker.pickMultiImage();
            if (selectedImages != null && selectedImages.isNotEmpty) {
              setState(() {
                _images[label] = [...imagesForSection, ...selectedImages];
              });
            }
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
        if (imagesForSection.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagesForSection.length,
              itemBuilder: (context, index) {
                final file = imagesForSection[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (kIsWeb || file.path.startsWith('http') || file.path.startsWith('https'))
                            ? Image.network(file.path, height: 80, width: 80, fit: BoxFit.cover)
                            : Image.file(File(file.path), height: 80, width: 80, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images[label]?.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
            onTap: () async {
              _saveState();
              try {
                await _handleAction(widget.onGuardar);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al guardar: ${e.toString().replaceAll('Exception: ', '')}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
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
            onTap: () async {
              try {
                await _handleAction(widget.onPublicar, isPublish: true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al publicar: ${e.toString().replaceAll('Exception: ', '')}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
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
  Widget _buildSubSectionHeaderWithAdd(String title, VoidCallback onAddTap) {
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
          onTap: onAddTap,
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

  // ==================== REUSABLE: DYNAMIC ADD DIALOG ====================
  Future<void> _showAddDialog(String displayTitle, Map<String, bool> targetMap) async {
    String newValue = '';
    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE9EFF2), width: 1),
                  ),
                  child: TextField(
                    autofocus: true,
                    onChanged: (v) => newValue = v,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      color: textColor,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                      hintText: 'Escribe aquí...',
                      hintStyle: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        color: placeholderColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: Container(
                    width: 150,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Agregar',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (added == true && newValue.trim().isNotEmpty) {
      setState(() {
        targetMap[newValue.trim()] = true;
      });
    }
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
