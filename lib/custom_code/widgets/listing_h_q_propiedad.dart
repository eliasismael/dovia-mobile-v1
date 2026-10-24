// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import '/core/network_image_size.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '/app_state.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import '/shared_components/dovia_spinner.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class ListingHQPropiedad extends StatefulWidget {
  final double? width;
  final double? height;

  final Future<void> Function()? onGuardar;
  final Future<void> Function()? onPublicar;
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

  // Datos que el formulario no edita pero `PATCH /properties/{id}` reemplaza
  // junto con `features`: se reenvían tal como llegaron.
  Map<String, dynamic> _origGeneral = {};
  String? _origNeighborhoodDescription;

  // Claves del backend para cada opción; lo que no está acá lo agregó el
  // Operative o el HQ y va en `additionalProperties`, igual que en el checklist.
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

  /// Acción en curso ('guardar' o 'publicar'): muestra el spinner en su
  /// botón y bloquea los dos para no mandar dos veces.
  String? _busyAction;

  // Selected criteria (max 3)
  final Set<String> _selectedCriteria = {};

  // ==================== IMAGE UPLOAD SECTIONS ====================
  List<String> _imageSections = [
    // Una sola foto: es la miniatura de la propiedad al publicarla.
    'Foto principal',
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

    // 1. Seed the form from server data first — this is the source of truth
    //    for the pre-filled property data.
    if (widget.initialData != null) {
      _populateFromInitialData(widget.initialData!);
    }

    // 2. Overlay any saved draft ON TOP, but only with values that ADD
    //    information. A stale/empty draft must never blank out the data we
    //    just pre-filled from the server (this was the cause of the checklist
    //    showing empty after a restart).
    final draftJson = _prefs.getString(_draftKey);
    if (draftJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(draftJson);
        bool hasText(dynamic v) => v is String && v.isNotEmpty;
        setState(() {
          if (hasText(data['tipoVivienda']))
            _tipoVivienda = data['tipoVivienda'];
          if (hasText(data['direccion'])) _direccion = data['direccion'];
          if (hasText(data['habitaciones']))
            _habitaciones = data['habitaciones'];
          if (hasText(data['banos'])) _banos = data['banos'];
          if (hasText(data['parqueo'])) _parqueo = data['parqueo'];
          if (hasText(data['pisos'])) _pisos = data['pisos'];
          if (hasText(data['mediosBanos'])) _mediosBanos = data['mediosBanos'];
          if (hasText(data['hasDanos'])) _hasDanos = data['hasDanos'];

          if (hasText(data['descripcion']))
            _descripcionController.text = data['descripcion'];
          if (hasText(data['dudas'])) _dudasController.text = data['dudas'];
          if (hasText(data['consideraciones']))
            _consideracionesController.text = data['consideraciones'];
          if (hasText(data['instrucciones']))
            _instruccionesController.text = data['instrucciones'];
          if (hasText(data['complejo']))
            _complejoController.text = data['complejo'];

          _overlayTrueKeys(
              _generalCharacteristics, data['generalCharacteristics']);
          _overlayTrueKeys(_otherCharacteristics, data['otherCharacteristics']);
          _overlayTrueKeys(_propiedadAmenities, data['propiedadAmenities']);
          _overlayTrueKeys(_areasComunes, data['areasComunes']);
          _overlayTrueKeys(_servicios, data['servicios']);

          if (data['starRatings'] is Map) {
            (data['starRatings'] as Map).forEach((key, value) {
              final v = value is num ? value.toInt() : 0;
              if (v > 0) {
                _starRatings[key.toString()] = v;
                _selectedCriteria.add(key.toString());
              }
            });
          }
        });
      } catch (e) {
        print('Error loading checklist draft: $e');
      }
    }
    _isInit = true;
  }

  /// Applies only the `true` entries of [source] onto [target], so a draft
  /// can add selections but never wipe ones pre-filled from the server.
  void _overlayTrueKeys(Map<String, bool> target, dynamic source) {
    if (source is Map) {
      source.forEach((key, value) {
        if (value == true) target[key.toString()] = true;
      });
    }
  }

  void _populateFromInitialData(Map<String, dynamic> data) {
    // The property object can live in a few places depending on what the
    // /visits/{id}/details endpoint returns. Search the common shapes.
    Map prop = {};
    if (data['property'] is Map) {
      prop = data['property'] as Map;
    } else if (data['features'] is Map || data['propertyType'] != null) {
      // `data` itself is the property.
      prop = data;
    } else if (data['visit'] is Map &&
        (data['visit'] as Map)['property'] is Map) {
      prop = (data['visit'] as Map)['property'] as Map;
    }

    // ── helpers ──────────────────────────────────────────────────────────────
    Map sub(Map m, String key) => m[key] is Map ? m[key] as Map : {};
    bool getBool(Map m, String key) => m[key] == true;

    setState(() {
      // ── Tipo de vivienda ──────────────────────────────────────────────────
      _tipoVivienda =
          _propertyTypeToLabel(prop['propertyType'] ?? prop['type']);

      // ── Dirección (read-only, from property location) ─────────────────────
      final addr = sub(sub(prop, 'location'), 'address');
      _direccion =
          addr['fullAddress']?.toString() ?? addr['street']?.toString();

      // ── Descripción ───────────────────────────────────────────────────────
      final desc = prop['description'];
      final descText = desc is Map
          ? (desc['raw']?.toString() ?? '')
          : (desc?.toString() ?? '');
      if (descText.isNotEmpty) _descripcionController.text = descText;

      // ── Características numéricas ─────────────────────────────────────────
      final gen = sub(sub(prop, 'features'), 'general');
      _origGeneral = Map<String, dynamic>.from(gen);
      _habitaciones = (gen['bedrooms'] ?? gen['habitaciones'])?.toString();
      _banos = (gen['bathrooms'] ?? gen['banos'])?.toString();
      _parqueo =
          (gen['parkingSpots'] ?? gen['parking'] ?? gen['parqueo'])?.toString();
      _pisos = (gen['floors'] ?? gen['pisos'])?.toString();
      _mediosBanos = (gen['halfBathrooms'] ?? gen['mediosBanos'])?.toString();

      // ── Características generales (checkboxes) ────────────────────────────
      final spaces = sub(sub(prop, 'features'), 'spaces');
      _generalCharacteristics['Sala'] = getBool(spaces, 'livingRoom');
      _generalCharacteristics['Comedor'] = getBool(spaces, 'diningRoom');
      _generalCharacteristics['Lavandería'] = getBool(spaces, 'laundryArea');
      _generalCharacteristics['Cuarto de servicio'] =
          getBool(spaces, 'serviceRoom');
      _generalCharacteristics['Amueblado'] = getBool(spaces, 'furnished');
      _generalCharacteristics['Cuota de mantenimiento'] =
          spaces['maintenanceFee'] != null && spaces['maintenanceFee'] != 0;
      _generalCharacteristics['Cocina'] = getBool(spaces, 'kitchen');
      _mergeAdditional(_generalCharacteristics, spaces);

      // ── Otras características ─────────────────────────────────────────────
      final others = sub(sub(prop, 'features'), 'others');
      _otherCharacteristics['Pet Frendly'] = getBool(others, 'petFriendly');
      _otherCharacteristics['Permitido para Airbnb'] =
          getBool(others, 'allowedForAirbnb');
      _otherCharacteristics['Permitido subarrendar'] =
          getBool(others, 'allowedToSublet');
      _mergeAdditional(_otherCharacteristics, others);

      // ── Amenidades de la propiedad ────────────────────────────────────────
      final amenProp = sub(sub(sub(prop, 'features'), 'amenities'), 'property');
      _propiedadAmenities['A/C'] = getBool(amenProp, 'airConditioning');
      _propiedadAmenities['Jardín'] = getBool(amenProp, 'garden');
      _propiedadAmenities['Área de churrasquera'] =
          getBool(amenProp, 'bbqArea');
      _propiedadAmenities['Cocina con isla'] =
          getBool(amenProp, 'islandKitchen');
      _propiedadAmenities['Sala de exterior'] =
          getBool(amenProp, 'outdoorLivingRoom');
      _propiedadAmenities['Tina'] = getBool(amenProp, 'bathtub');
      _mergeAdditional(_propiedadAmenities, amenProp);

      // ── Áreas comunes ─────────────────────────────────────────────────────
      final amenCommon =
          sub(sub(sub(prop, 'features'), 'amenities'), 'commonAreas');
      _areasComunes['Piscina'] = getBool(amenCommon, 'pool');
      _areasComunes['Parque de juegos'] = getBool(amenCommon, 'playground');
      _areasComunes['Gimnasio'] = getBool(amenCommon, 'gym');
      _areasComunes['Coworking'] = getBool(amenCommon, 'coworking');
      _areasComunes['Salón de eventos'] = getBool(amenCommon, 'eventHall');
      _areasComunes['Yoga Deck'] = getBool(amenCommon, 'yogaDeck');
      _areasComunes['Cocina para eventos'] =
          getBool(amenCommon, 'eventKitchen');
      _mergeAdditional(_areasComunes, amenCommon);

      // ── Criterios de calificación (star ratings) ──────────────────────────
      final hood = sub(sub(prop, 'features'), 'neighborhood');
      _origNeighborhoodDescription = hood['description']?.toString();
      void setRating(String label, dynamic raw) {
        if (raw == null) return;
        final val = (raw is num ? raw : num.tryParse(raw.toString()) ?? 0)
            .round()
            .clamp(0, 5);
        if (val > 0) {
          _starRatings[label] = val;
          _selectedCriteria.add(label);
        }
      }

      setRating('Caminabilidad', hood['walkable']);
      setRating('Áreas verdes', hood['greenAreas']);
      setRating('Comercio y servicios', hood['commerceAndServices']);
      setRating('Centros corporativos', hood['corporateCenters']);
      setRating('Tranquilidad y silencio', hood['tranquilityAndSilence']);
      setRating('Recreación', hood['recreation']);
      setRating('Servicios esenciales', hood['essentialServices']);
      setRating('Colegios', hood['schools']);
      setRating('Conectividad vial', hood['roadConnectivity']);
      setRating('Seguridad', hood['security']);
      setRating('Zona turística', hood['touristZone'] ?? hood['touristArea']);
      setRating('Gastronomía', hood['gastronomy']);
      setRating('Vida urbana', hood['urbanLife']);
      setRating('Universidades', hood['universities']);
      setRating('Salud y hospitales', hood['healthAndHospitals']);
      setRating('Movilidad', hood['mobility']);

      // ── Información para HQ ───────────────────────────────────────────────
      final infoHQ = prop['infoHQ'] is Map
          ? prop['infoHQ'] as Map
          : (prop['infoHq'] is Map ? prop['infoHq'] as Map : {});
      final services = sub(infoHQ, 'services');
      const serviceLabels = {
        'gas': 'Gas',
        'agua': 'Agua',
        'luz': 'Luz',
        'internet': 'Internet',
      };
      services.forEach((k, v) {
        if (k == null) return;
        final label =
            serviceLabels[k.toString().toLowerCase()] ?? _cap(k.toString());
        _servicios[label] = v == true;
      });

      final hasDmg = infoHQ['hasDamages'];
      if (hasDmg != null) _hasDanos = hasDmg == true ? 'Si' : 'No';

      final q = infoHQ['questions']?.toString() ?? '';
      if (q.isNotEmpty) _dudasController.text = q;
      final c =
          (infoHQ['showingConsiderations'] ?? infoHQ['teachingConsiderations'])
                  ?.toString() ??
              '';
      if (c.isNotEmpty) _consideracionesController.text = c;
      final i = infoHQ['visitorInstructions']?.toString() ?? '';
      if (i.isNotEmpty) _instruccionesController.text = i;
      final cn = infoHQ['complexNotes']?.toString() ?? '';
      if (cn.isNotEmpty) _complejoController.text = cn;

      // ── Imágenes existentes ───────────────────────────────────────────────
      final propImages = prop['images'];
      if (propImages is Map) {
        propImages.forEach((category, urls) {
          if (urls is List) {
            final key = _getSectionKeyFromCategory(category.toString());
            _images[key] = urls.map((u) => XFile(u.toString())).toList();
            if (!_imageSections.contains(key)) _imageSections.add(key);
          }
        });
      }
      final video360 =
          prop['video360Url']?.toString() ?? prop['video360']?.toString();
      if (video360 != null && video360.isNotEmpty) {
        _images['Recorrido 360'] = [XFile(video360)];
      }
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

    final requiredSections = [
      'Foto principal',
      'Habitaciones',
      'Sala',
      'Comedor',
      'Cocina',
    ];
    for (final section in requiredSections) {
      if (_images[section] == null || _images[section]!.isEmpty) {
        hasError = true;
      }
    }

    if (_tipoVivienda == null || _direccion == null || _habitaciones == null) {
      hasError = true;
    }

    if (_selectedCriteria.length < 3 ||
        _selectedCriteria.any((c) => (_starRatings[c] ?? 0) == 0)) {
      hasError = true;
    }

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor completa todos los campos obligatorios y sube las fotos requeridas.'),
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
      case 'principal':
        return 'Foto principal';
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

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // Backend propertyType enum <-> Spanish dropdown label.
  static const Map<String, String> _propertyTypeLabels = {
    'HOUSE': 'Casa',
    'APARTMENT': 'Apartamento',
    'CONDO': 'Condominio',
    'CONDOMINIUM': 'Condominio',
    'COMMERCIAL': 'Local',
    'STORE': 'Local',
    'LOCAL': 'Local',
    'WAREHOUSE': 'Bodega',
    'OTHER': 'Otro',
  };

  String? _propertyTypeToLabel(dynamic raw) {
    if (raw == null) return null;
    final key = raw.toString().toUpperCase();
    return _propertyTypeLabels[key] ?? raw.toString();
  }

  String? _labelToPropertyType(String? label) {
    if (label == null) return null;
    for (final e in _propertyTypeLabels.entries) {
      if (e.value == label) return e.key;
    }
    return label;
  }

  // Merges a feature group's `additionalProperties` (custom bool flags) into
  // the corresponding checkbox map so nothing the Operative sent is lost.
  void _mergeAdditional(Map<String, bool> target, Map group) {
    final extra = group['additionalProperties'];
    if (extra is Map) {
      extra.forEach((k, v) {
        if (k != null) target[_cap(k.toString())] = v == true;
      });
    }
  }

  int? _count(String? v) =>
      v == null ? null : int.tryParse(v.replaceAll('+', ''));

  String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

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

  /// Cuerpo de `PATCH /properties/{id}` con el formato del backend, el mismo
  /// que envía el checklist del Operative. Las imágenes no van acá: quedan
  /// registradas en la propiedad con `images/confirm`.
  Map<String, dynamic> buildPatchBody() {
    final general = <String, dynamic>{
      ..._origGeneral,
      if (_count(_habitaciones) != null) 'bedrooms': _count(_habitaciones),
      if (_count(_banos) != null) 'bathrooms': _count(_banos),
      if (_count(_mediosBanos) != null) 'halfBathrooms': _count(_mediosBanos),
      if (_count(_parqueo) != null) 'parkingSpots': _count(_parqueo),
      if (_count(_pisos) != null) 'floors': _count(_pisos),
    };
    final neighborhood = <String, dynamic>{
      if (_origNeighborhoodDescription?.isNotEmpty == true)
        'description': _origNeighborhoodDescription,
    };
    _starRatings.forEach((label, stars) {
      final key = _kNeighborhood[label];
      if (key != null && stars > 0) neighborhood[key] = stars;
    });
    final propertyType = _labelToPropertyType(_tipoVivienda);
    return {
      if (propertyType != null) 'propertyType': propertyType,
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
        if (_text(_dudasController) != null)
          'questions': _text(_dudasController),
        if (_text(_consideracionesController) != null)
          'showingConsiderations': _text(_consideracionesController),
        if (_text(_instruccionesController) != null)
          'visitorInstructions': _text(_instruccionesController),
        if (_text(_complejoController) != null)
          'complexNotes': _text(_complejoController),
      },
    };
  }

  // ==================== DATA COLLECTION ====================
  Future<void> _handleAction(Future<void> Function()? actionCallback,
      {bool isPublish = false}) async {
    if (isPublish) {
      if (!validateForm()) return;
    }
    final data = {
      'tipoVivienda': _labelToPropertyType(_tipoVivienda),
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
      'patchBody': buildPatchBody(),
    };

    if (widget.onSave != null) {
      dynamic res = widget.onSave!(data);
      if (res is Future) res = await res;
      // Las fotos ya subidas vuelven como URL: así un segundo Guardar o el
      // Publicar no las suben de nuevo.
      if (res is Map && mounted) {
        setState(() {
          res.forEach((section, urls) {
            if (urls is List) {
              _images[section.toString()] =
                  urls.map((u) => XFile(u.toString())).toList();
            }
          });
        });
      }
    }
    if (actionCallback != null) {
      await actionCallback();
    }
  }

  Future<void> _runAction(String action, Future<void> Function() run) async {
    if (_busyAction != null) return;
    setState(() => _busyAction = action);
    try {
      await run();
    } finally {
      if (mounted) setState(() => _busyAction = null);
    }
  }

  Widget _buttonSpinner(Color color) => DoviaSpinner(small: true, color: color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
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
            options: [
              'Casa',
              'Apartamento',
              'Condominio',
              'Local',
              'Bodega',
              'Otro'
            ],
          ),
          const SizedBox(height: 11),
          // Dirección (read-only, comes from property)
          _buildReadOnlyField('Dirección', _direccion ?? 'N/A'),
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
            'Selecciona mínimo 3 criterios y califica de 1 a 5 estrellas',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_selectedCriteria.length} seleccionados (mínimo 3)',
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              color: placeholderColor,
            ),
          ),
          const SizedBox(height: 12),
          // Dos tarjetas por fila: se tocan para elegirlas y las estrellas
          // marcan el valor.
          LayoutBuilder(builder: (context, constraints) {
            const spacing = 10.0;
            final w = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _starRatings.entries
                  .map((e) => SizedBox(
                        width: w,
                        child: _buildStarRatingItem(e.key, e.value),
                      ))
                  .toList(),
            );
          }),
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
            final newArea = await _askText('Añadir área adicional',
                hint: 'Ej: Jardín trasero');
            if (newArea != null) {
              setState(() {
                if (!_imageSections.contains(newArea)) {
                  _imageSections.add(newArea);
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
        if (label == 'Foto principal') ...[
          const SizedBox(height: 4),
          const Text(
            'Será la miniatura de la propiedad al publicarla.',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 13,
              color: placeholderColor,
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (imagesForSection.isEmpty)
          GestureDetector(
            onTap: () => _pickImagesFor(label),
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
          )
        else
          _buildImageGrid(label, imagesForSection),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _pickImagesFor(String label) async {
    if (label == 'Foto principal') {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _images[label] = [image]);
      }
      return;
    }
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        _images[label] = [...(_images[label] ?? []), ...selectedImages];
      });
    }
  }

  /// Grilla que ocupa todo el ancho: con más fotos hay más columnas (hasta 4)
  /// y cada miniatura se achica. La última celda es el botón + para agregar.
  Widget _buildImageGrid(String label, List<XFile> images) {
    final single = label == 'Foto principal';
    final tiles = images.length + (single ? 0 : 1);
    final columns = tiles.clamp(1, 4);
    const spacing = 8.0;

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final tileWidth = (width - spacing * (columns - 1)) / columns;
      final tileHeight = single ? 180.0 : tileWidth.clamp(0.0, 160.0);

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (int i = 0; i < images.length; i++)
            _imageTile(label, images[i], i, tileWidth, tileHeight),
          if (!single)
            GestureDetector(
              onTap: () => _pickImagesFor(label),
              child: Container(
                width: tileWidth,
                height: tileHeight,
                decoration: BoxDecoration(
                  color: addButtonBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, size: 28, color: primaryColor),
              ),
            ),
        ],
      );
    });
  }

  Widget _imageTile(
      String label, XFile file, int index, double width, double height) {
    final isRemote = kIsWeb || file.path.startsWith('http');
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isRemote
                  ? Image.network(
                      file.path,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return _imagePlaceholder(
                          const Center(
                            child: DoviaSpinner(small: true),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _imagePlaceholder(
                        const Icon(Icons.broken_image_outlined,
                            size: 24, color: Color(0xFF9E9E9E)),
                      ),
                      cacheWidth: networkImageCacheWidth(),
                    )
                  : Image.file(File(file.path), fit: BoxFit.cover),
            ),
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
  }

  Widget _imagePlaceholder(Widget child) {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: child,
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Guardar button (outline)
        Expanded(
          child: GestureDetector(
            onTap: () => _runAction('guardar', () async {
              _saveState();
              try {
                await _handleAction(widget.onGuardar);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Error al guardar: ${e.toString().replaceAll('Exception: ', '')}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor, width: 1),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: _busyAction == 'guardar'
                  ? _buttonSpinner(primaryColor)
                  : const Text(
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
            onTap: () => _runAction('publicar', () async {
              try {
                await _handleAction(widget.onPublicar, isPublish: true);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Error al publicar: ${e.toString().replaceAll('Exception: ', '')}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: primaryColor,
                border: Border.all(color: primaryColor, width: 1),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: _busyAction == 'publicar'
                  ? _buttonSpinner(Colors.white)
                  : const Text(
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
  Future<void> _showAddDialog(
      String displayTitle, Map<String, bool> targetMap) async {
    final value = await _askText(displayTitle);
    if (value != null) {
      setState(() {
        targetMap[value] = true;
      });
    }
  }

  /// Pide un texto con el estilo de los diálogos de la app. Devuelve null si
  /// se cierra sin escribir nada.
  Future<String?> _askText(String displayTitle,
      {String hint = 'Escribe aquí...'}) async {
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
                    border:
                        Border.all(color: const Color(0xFFE9EFF2), width: 1),
                  ),
                  child: TextField(
                    autofocus: true,
                    onChanged: (v) => newValue = v,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: const TextStyle(
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

    final value = newValue.trim();
    return added == true && value.isNotEmpty ? value : null;
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
          height: 35,
          decoration: BoxDecoration(
            color: inputBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: placeholderColor.withValues(alpha: 0.7),
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
    ValueChanged<String?> onChanged, {
    List<String>? options,
  }) {
    final List<String> items = options ??
        ['Casa', 'Apartamento', 'Condominio', 'Local', 'Bodega', 'Otro'];
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value != null && items.contains(value)) ? value : null,
              hint: Text(
                value ?? 'Seleccionar',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  color: placeholderColor.withValues(alpha: 0.5),
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 16, color: placeholderColor),
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 12,
                color: textColor,
              ),
              onChanged: onChanged,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
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
    final List<String> items = List.generate(11, (i) => i.toString()); // 0–10
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: inputBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: (value != null && items.contains(value)) ? value : null,
          hint: Text(
            value ?? '-',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              color: placeholderColor.withValues(alpha: 0.5),
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 10, color: placeholderColor),
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 12,
            color: textColor,
          ),
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
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
    String placeholder = 'Seleccionar',
  }) {
    final List<String> items = options ?? [];
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
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: inputBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value != null && items.contains(value)) ? value : null,
              hint: Text(
                value ?? placeholder,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: placeholderColor.withValues(alpha: 0.5),
                  letterSpacing: 0.28,
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 24, color: placeholderColor),
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: textColor,
              ),
              onChanged: onChanged,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
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
                fontFamily: 'Public Sans',
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
  void _toggleCriterion(String label) {
    setState(() {
      if (_selectedCriteria.remove(label)) {
        _starRatings[label] = 0;
      } else {
        _selectedCriteria.add(label);
      }
    });
  }

  Widget _buildStarRatingItem(String label, int rating) {
    final selected = _selectedCriteria.contains(label);
    return GestureDetector(
      onTap: () => _toggleCriterion(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? alertBg : inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primaryColor : borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? primaryColor : addButtonBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? Icons.check : Icons.star_outline_rounded,
                color: selected ? Colors.white : primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 36,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCriteria.add(label);
                        _starRatings[label] = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2),
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
            ),
          ],
        ),
      ),
    );
  }
}
