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
    this.visitId = '',
    this.address = '',
  });

  /// Visita del formulario: el borrador local se guarda por visita.
  final String visitId;

  /// Dirección de la propiedad, que ya cargó el propietario.
  final String address;

  @override
  State<OperativeListingCheckList> createState() =>
      OperativeListingCheckListState();
}

class OperativeListingCheckListState extends State<OperativeListingCheckList> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color inputBackground = Colors.white;
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
  final _sectorController = TextEditingController();

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
  bool _errorHabitaciones = false;
  bool _errorCriterios = false;
  bool _errorDanos = false;

  bool validateForm() {
    setState(() {
      _errorTipoVivienda = _tipoVivienda == null;
      _errorHabitaciones = _habitaciones == null;
      _errorCriterios = _selectedCriteria.length < 3;
      _errorDanos =
          _hasDanos == 'Si' && _danosDescripcionController.text.trim().isEmpty;
    });

    if (_errorTipoVivienda) {
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

  static const Map<String, String> _kPropertyTypes = {
    'Casa': 'HOUSE',
    'Apartamento': 'APARTMENT',
    'Penthouse': 'PENTHOUSE',
    'Estudio': 'STUDIO',
    'Finca': 'FARM',
    'Terreno': 'LOT',
  };

  static const Map<String, String> _kSpaces = {
    'Sala': 'livingRoom',
    'Comedor': 'diningRoom',
    'Lavandería': 'laundryArea',
    'Cuarto de servicio': 'serviceRoom',
    'Amueblado': 'furnished',
    'Cocina': 'kitchen',
  };
  static const Map<String, String> _kOthers = {
    'Pet Frendly': 'petFriendly',
    'Permitido para Airbnb': 'allowedForAirbnb',
    'Permitido subarrendar': 'allowedToSublet',
  };
  static const Map<String, String> _kPropertyAmenities = {
    'A/C': 'airConditioning',
    'Jardín': 'garden',
    'Área de churrasquera': 'bbqArea',
    'Cocina con isla': 'islandKitchen',
    'Sala de exterior': 'outdoorLivingRoom',
    'Tina': 'bathtub',
  };
  static const Map<String, String> _kCommonAreas = {
    'Piscina': 'pool',
    'Parque de juegos': 'playground',
    'Gimnasio': 'gym',
    'Coworking': 'coworking',
    'Salón de eventos': 'eventHall',
    'Yoga Deck': 'yogaDeck',
    'Cocina para eventos': 'eventKitchen',
  };
  static const Map<String, String> _kNeighborhood = {
    'Caminabilidad': 'walkable',
    'Áreas verdes': 'greenAreas',
    'Recreación': 'recreation',
    'Servicios esenciales': 'essentialServices',
    'Colegios': 'schools',
    'Comercio y servicios': 'commerceAndServices',
    'Conectividad vial': 'roadConnectivity',
    'Seguridad': 'security',
    'Zona turística': 'touristZone',
    'Gastronomía': 'gastronomy',
    'Vida urbana': 'urbanLife',
    'Universidades': 'universities',
    'Centros corporativos': 'corporateCenters',
    'Tranquilidad y silencio': 'tranquilityAndSilence',
    'Salud y hospitales': 'healthAndHospitals',
    'Movilidad': 'mobility',
  };

  /// "5+" → 5. Null si no se eligió.
  int? _count(String? v) =>
      v == null ? null : int.tryParse(v.replaceAll('+', ''));

  /// Checkboxes conocidos van a su campo; los agregados con [+ Añadir], a
  /// `additionalProperties`.
  Map<String, dynamic> _checks(
      Map<String, bool> items, Map<String, String> keys) {
    final out = <String, dynamic>{};
    final extra = <String, bool>{};
    items.forEach((label, value) {
      final key = keys[label];
      if (key != null) {
        out[key] = value;
      } else {
        extra[label] = value;
      }
    });
    if (extra.isNotEmpty) out['additionalProperties'] = extra;
    return out;
  }

  String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  /// Cuerpo de `PATCH /properties/{id}` con el formato que espera el backend.
  Map<String, dynamic> getFormData() {
    final general = <String, dynamic>{
      if (_count(_habitaciones) != null) 'bedrooms': _count(_habitaciones),
      if (_count(_banos) != null) 'bathrooms': _count(_banos),
      if (_count(_mediosBanos) != null) 'halfBathrooms': _count(_mediosBanos),
      if (_count(_parqueo) != null) 'parkingSpots': _count(_parqueo),
      if (_count(_pisos) != null) 'floors': _count(_pisos),
    };
    final neighborhood = <String, dynamic>{
      if (_text(_sectorController) != null)
        'description': _text(_sectorController),
    };
    _starRatings.forEach((label, stars) {
      final key = _kNeighborhood[label];
      if (key != null && stars > 0) neighborhood[key] = stars;
    });
    // El backend no tiene campo para describir daños: va al inicio de las
    // dudas para que HQ lo lea.
    final danos = _hasDanos == 'Si' ? _text(_danosDescripcionController) : null;
    final dudas = _text(_dudasController);
    final questions = [
      if (danos != null) 'Daños: $danos',
      if (dudas != null) dudas,
    ].join('\n\n');
    return {
      if (_tipoVivienda != null && _kPropertyTypes[_tipoVivienda] != null)
        'propertyType': _kPropertyTypes[_tipoVivienda],
      if (_text(_descripcionController) != null)
        'description': _text(_descripcionController),
      'features': {
        'general': general,
        'spaces': _checks(_generalCharacteristics, _kSpaces),
        'others': _checks(_otherCharacteristics, _kOthers),
        'amenities': {
          'property': _checks(_propiedadAmenities, _kPropertyAmenities),
          'commonAreas': _checks(_areasComunes, _kCommonAreas),
        },
        'neighborhood': neighborhood,
      },
      'infoHQ': {
        'services': _servicios,
        if (_hasDanos != null) 'hasDamages': _hasDanos == 'Si',
        if (questions.isNotEmpty) 'questions': questions,
        if (_text(_consideracionesController) != null)
          'showingConsiderations': _text(_consideracionesController),
        if (_text(_instruccionesController) != null)
          'visitorInstructions': _text(_instruccionesController),
        if (_text(_complejoController) != null)
          'complexNotes': _text(_complejoController),
      },
    };
  }

  /// Tras enviar con éxito, el borrador local ya no hace falta.
  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  // Criterios calificados (mínimo 3)
  final Set<String> _selectedCriteria = {};

  late SharedPreferences _prefs;
  String get _draftKey =>
      'checklist_draft_${widget.visitId.isNotEmpty ? widget.visitId : FFAppState().lastActiveVisitId}';
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
    _sectorController.addListener(_saveState);
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
          if (data['sector'] != null) _sectorController.text = data['sector'];

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
      'sector': _sectorController.text,
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
    _sectorController.dispose();
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
                  options: _kPropertyTypes.keys.toList(),
                  hasError: _errorTipoVivienda,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: _buildReadOnlyField(
                  'Dirección',
                  widget.address.isNotEmpty ? widget.address : '—',
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
          'Sobre el sector',
          _criteriosExpanded,
          () => setState(() => _criteriosExpanded = !_criteriosExpanded),
          fontSize: 14,
        ),
        if (_criteriosExpanded) ...[
          const SizedBox(height: 12),
          _buildTextAreaField(
            'Anota las dudas que tengas',
            _sectorController,
            placeholder: 'Escribe aquí...',
            labelFontSize: 14,
          ),
          const SizedBox(height: 16),
          Text(
            'Selecciona mínimo 3 criterios y califica de 1 a 5 estrellas',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _errorCriterios ? Colors.red : textColor,
            ),
          ),
          if (_errorCriterios)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Calificaste ${_selectedCriteria.length} de 3 como mínimo.',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          // Star rating items
          // Dos columnas del ancho disponible, sea cual sea el padding.
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final cardWidth = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: _starRatings.entries
                    .map((entry) => SizedBox(
                          width: cardWidth,
                          child: _buildStarRatingItem(entry.key, entry.value),
                        ))
                    .toList(),
              );
            },
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
          _addButton(
            'Añadir servicios',
            () => _showAddCustomItemDialog('Servicios', _servicios),
            expand: true,
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
              'Describe los daños *',
              _danosDescripcionController,
              placeholder: 'Escribe aquí...',
              hasError: _errorDanos,
            ),
            if (_errorDanos)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Describe los daños para poder enviar.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
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
            // Sin sangría: el título y la línea van al ancho del contenido.
            const EdgeInsets.only(top: 10, bottom: 10),
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

  /// "+ Añadir": mismo botón que "Ver más" de las tarjetas (verde lleno,
  /// texto blanco). [expand] lo estira a todo el ancho.
  Widget _addButton(String text, VoidCallback onTap, {bool expand = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        height: 30,
        width: expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
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
        _addButton('Añadir', () => _showAddCustomItemDialog(title, targetMap)),
      ],
    );
  }

  void _showAddCustomItemDialog(
      String sectionName, Map<String, bool> targetMap) {
    String titleText = '';
    String hintText = 'Escribe aquí...';

    if (sectionName == 'Características generales') {
      titleText = 'Agrega una característica general adicional';
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
          // Mismas medidas que el diálogo de añadir del formulario de HQ.
          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: inputBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          color: placeholderColor.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
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
        });
  }

  void _showSuccessPopup() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            // Check if still mounted to avoid popping something else
            if (!dialogContext.mounted) return;
            if (mounted && Navigator.of(dialogContext).canPop()) {
              if (!dialogContext.mounted) return;
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
              border: hasError
                  ? Border.all(color: Colors.red, width: 1.5)
                  : Border.all(color: borderColor),
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
          border: hasError
              ? Border.all(color: Colors.red, width: 1.5)
              : Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? '',
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
    String placeholder = '',
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
              border: Border.all(color: borderColor),
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
            border: hasError
              ? Border.all(color: Colors.red, width: 1.5)
              : Border.all(color: borderColor),
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

  static const Map<String, IconData> _kCriteriaIcons = {
    'Caminabilidad': Icons.directions_walk,
    'Áreas verdes': Icons.park_outlined,
    'Recreación': Icons.sports_soccer_outlined,
    'Servicios esenciales': Icons.local_grocery_store_outlined,
    'Colegios': Icons.school_outlined,
    'Comercio y servicios': Icons.storefront_outlined,
    'Conectividad vial': Icons.alt_route,
    'Seguridad': Icons.shield_outlined,
    'Zona turística': Icons.map_outlined,
    'Gastronomía': Icons.restaurant_outlined,
    'Vida urbana': Icons.location_city_outlined,
    'Universidades': Icons.account_balance_outlined,
    'Centros corporativos': Icons.business_center_outlined,
    'Tranquilidad y silencio': Icons.volume_off_outlined,
    'Salud y hospitales': Icons.local_hospital_outlined,
    'Movilidad': Icons.directions_bus_outlined,
  };

  // ==================== REUSABLE: STAR RATING ITEM ====================
  /// Tarjeta de un criterio del sector. Se resalta en teal al calificarla.
  Widget _buildStarRatingItem(String label, int rating) {
    final bool isSelected = rating > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEAF4F4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryColor : borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : addButtonBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _kCriteriaIcons[label] ?? Icons.star_outline_rounded,
              color: isSelected ? Colors.white : primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_starRatings[label] == index + 1) {
                        // Tocar la misma estrella la desmarca.
                        _starRatings[label] = 0;
                        _selectedCriteria.remove(label);
                      } else {
                        _starRatings[label] = index + 1;
                        _selectedCriteria.add(label);
                      }
                      if (_selectedCriteria.length >= 3) {
                        _errorCriterios = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: index < 4 ? 4 : 0),
                    child: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      size: 26,
                      color: index < rating
                          ? primaryColor
                          : placeholderColor.withValues(alpha: 0.4),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== REUSABLE: READ-ONLY FIELD ====================
  Widget _buildReadOnlyField(String label, String value) {
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
          constraints: const BoxConstraints(minHeight: 42),
          width: double.infinity,
          decoration: BoxDecoration(
            color: inputBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
