import '/backend/api_requests/presigned_upload.dart';
import '/core/dovia_zones.dart';
import '/core/api_error.dart';
import '/core/result.dart';
import '/domain/user_models.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/core/amount_input_formatter.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import '/repositories/properties_repository.dart';
import '/repositories/user_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/draw_map_component/draw_map_component_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/index.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/header_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_model.dart';
import 'property_publication_form.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_model.dart';

/// Formulario para publicar una propiedad en venta, renta o ambas: precios,
/// ubicación, datos registrales y a nombre de quién está (propio, de otra
/// persona o de una sociedad). Al aceptar crea la propiedad, sube los
/// documentos de titularidad y sigue a agendar la visita.
class DOVIACLIENTMisPropiedadesVenderRentarWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesVenderRentarWidget({
    super.key,
    required this.title,
    required this.transactionType,
  });

  final String? title;
  final PropertyPublicationType? transactionType;

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_VenderRentar';
  static String routePath = '/dOVIACLIENTMisPropiedadesVenderRentar';

  @override
  State<DOVIACLIENTMisPropiedadesVenderRentarWidget> createState() =>
      _DOVIACLIENTMisPropiedadesVenderRentarWidgetState();
}

class _DOVIACLIENTMisPropiedadesVenderRentarWidgetState
    extends State<DOVIACLIENTMisPropiedadesVenderRentarWidget>
    with WidgetsBindingObserver {
  late DOVIACLIENTMisPropiedadesVenderRentarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _isSale => widget.transactionType?.name.contains('SALE') ?? false;
  bool get _isRent => widget.transactionType?.name.contains('RENT') ?? false;

  /// Texto de cada campo, por clave (ver `property_publication_form.dart`).
  final Map<String, TextEditingController> _controllers = {};

  /// Valor elegido en cada desplegable, por clave.
  final Map<String, String> _choices = {};
  final Map<String, FormFieldController<String>> _dropdownControllers = {};

  /// Archivos elegidos para los documentos de titularidad, por clave.
  final Map<String, FFUploadedFile> _files = {};

  OwnershipKind _ownership = OwnershipKind.self;
  bool _companyElectronicBook = false;
  bool _submitting = false;

  /// Datos con los que se creó [DOVIACLIENTMisPropiedadesVenderRentarModel
  /// .createdPropertyId]: el body enviado y los documentos subidos. Si al
  /// volver de agendar la visita el formulario ya no coincide, la propiedad
  /// se vuelve a crear; si no, los cambios se perdían sin aviso.
  String? _createdSignature;
  bool _uploadingAccountId = false;
  String? _accountIdError;

  /// Zonas publicables del backend (`null` mientras cargan). Se envía el id;
  /// el nombre se muestra y sirve para centrar el mapa y la búsqueda.
  List<({String id, String name})>? _zones;
  bool _zonesFailed = false;

  /// Punto que el propietario marca en el mapa. Es la única fuente de las
  /// coordenadas de la propiedad. Al escribir la dirección se geocodifica y el
  /// pin se ubica solo, pero el propietario puede corregirlo tocando el mapa.
  double? _selectedLatitude;
  double? _selectedLongitude;

  /// Último resultado de geocodificar la dirección; se le pasa al mapa para
  /// que mueva el pin.
  double? _geocodedLatitude;
  double? _geocodedLongitude;
  String _lastGeocodedQuery = '';
  bool _keyboardWasOpen = false;
  final FocusNode _addressFocusNode = FocusNode();

  /// Error visible de cada campo tras tocar "Aceptar".
  Map<String, String> _fieldErrors = {};
  final Map<String, GlobalKey> _fieldKeys = {};
  GlobalKey _fieldKey(String field) =>
      _fieldKeys.putIfAbsent(field, () => GlobalKey());

  TextEditingController _c(String key) => _controllers.putIfAbsent(key, () {
        final controller = TextEditingController();
        // Al corregir un campo se le saca el error; los precios además
        // recalculan la comisión que se muestra.
        controller.addListener(() {
          _clearFieldError(key);
          if (key == 'salePrice' || key == 'monthlyRent') safeSetState(() {});
        });
        return controller;
      });

  String? get _zoneName {
    final id = _choices['zone'];
    for (final zone in _zones ?? const <({String id, String name})>[]) {
      if (zone.id == id) return zone.name;
    }
    return null;
  }

  /// Se busca la dirección al salir del input.
  void _onAddressFocusChanged() {
    if (!_addressFocusNode.hasFocus) _geocodeAddress();
  }

  /// En el celular, cerrar el teclado no le quita el foco al input: se
  /// detecta aca y se busca igual.
  @override
  void didChangeMetrics() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return;
    final keyboardOpen = views.first.viewInsets.bottom > 0;
    if (_keyboardWasOpen && !keyboardOpen && _addressFocusNode.hasFocus) {
      _geocodeAddress();
    }
    _keyboardWasOpen = keyboardOpen;
  }

  /// Busca la dirección escrita (dentro de la zona elegida) con Mapbox y
  /// ubica el pin en el resultado.
  Future<void> _geocodeAddress() async {
    final address = _c('address').text.trim();
    if (address.length < 4) return;
    final zone = _zoneName;
    final query = [
      address,
      if (zone != null && zone.isNotEmpty) zone,
      'Guatemala',
    ].join(', ');
    if (query == _lastGeocodedQuery) return;
    _lastGeocodedQuery = query;

    // Con zona elegida, solo se aceptan resultados dentro de ella.
    final zoneFilter = mapboxZoneFilter(zone);
    try {
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/'
        '${Uri.encodeComponent(query)}.json'
        '?access_token=${FFAppConstants.MapboxAccessToken}'
        '&country=gt&limit=5&language=es$zoneFilter',
      );
      final response = await http.get(url);
      if (response.statusCode != 200 || !mounted) return;
      // Si el usuario siguió escribiendo, este resultado ya es viejo.
      if (query != _lastGeocodedQuery) return;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      if (features.isEmpty) return;
      final match = bestAddressMatch(features, address);
      // Mapbox devuelve [longitud, latitud].
      final coords = match['center'] as List<dynamic>;
      final lng = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      safeSetState(() {
        _geocodedLatitude = lat;
        _geocodedLongitude = lng;
        _selectedLatitude = lat;
        _selectedLongitude = lng;
      });
      _clearFieldError('location');
    } catch (_) {
      // Sin resultado el propietario marca el punto a mano.
    }
  }

  Future<void> _loadZones() async {
    safeSetState(() {
      _zones = null;
      _zonesFailed = false;
    });
    final result =
        await context.read<PropertiesRepository>().getPublishableZones();
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        // Solo las activas se pueden elegir.
        final zones = [
          for (final zone in data)
            if (zone is Map && zone['isActive'] == true && zone['id'] != null)
              (
                id: zone['id'].toString(),
                name: (zone['name'] ?? zone['id']).toString(),
              ),
        ];
        safeSetState(() => _zones = zones);
      case Failure():
        safeSetState(() => _zonesFailed = true);
    }
  }

  /// Trae el perfil para mostrar el nombre de la cuenta y saber si ya tiene
  /// su identificación; con la fecha de nacimiento sugiere la edad.
  Future<void> _loadProfile() async {
    final repo = context.read<UserRepository>();
    await repo.loadProfile();
    final age = repo.profile?.age;
    if (!mounted || age == null || _c('me.age').text.isNotEmpty) return;
    _c('me.age').text = '$age';
  }

  bool _accountIdentityReady(UserProfile? profile) =>
      (profile?.firstName?.trim().isNotEmpty ?? false) &&
      (profile?.lastName?.trim().isNotEmpty ?? false) &&
      profile?.identificationDocumentUrl != null;

  PublicationInput _publicationInput() => PublicationInput(
        sale: _isSale,
        rent: _isRent,
        ownership: _ownership,
        values: {
          for (final entry in _controllers.entries) entry.key: entry.value.text,
          ..._choices,
        },
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
        companyElectronicBook: _companyElectronicBook,
        accountIdentityReady:
            _accountIdentityReady(context.read<UserRepository>().profile),
        attachedFiles: {
          for (final entry in _files.entries)
            if (entry.value.bytes?.isNotEmpty ?? false) entry.key,
        },
      );

  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field)) {
      safeSetState(() => _fieldErrors = {..._fieldErrors}..remove(field));
    }
  }

  /// Marca los campos con error y lleva el scroll al primero.
  void _showFieldErrors(Map<String, String> errors) {
    safeSetState(() => _fieldErrors = errors);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _fieldKeys[errors.keys.first]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.3,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _showPublicationError(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('No se pudo publicar la propiedad'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Crea la propiedad, sube los documentos de titularidad y sigue a agendar
  /// la visita.
  ///
  /// Los documentos son obligatorios: si alguno no queda asociado, el
  /// borrador recién creado se descarta y el próximo "Aceptar" crea la
  /// propiedad de nuevo, con lo que haya en el formulario en ese momento.
  ///
  /// Si ya se había creado (se volvió desde agendar la visita) y el
  /// formulario cambió, se descarta ese borrador y se crea otro con los datos
  /// actuales.
  Future<void> _submit() async {
    if (_submitting) return;
    final input = _publicationInput();
    final errors = validatePublication(input);
    if (errors.isNotEmpty) {
      _showFieldErrors(errors);
      return;
    }
    safeSetState(() {
      _fieldErrors = {};
      _submitting = true;
    });

    try {
      final signature = _submissionSignature(input);
      final created = _model.createdPropertyId;
      if (created != null && signature != _createdSignature) {
        final discarded = await _discardDraft(
          created,
          note: 'El propietario cambió los datos antes de agendar la visita.',
        );
        if (!discarded) {
          await _showPublicationError(
            'No pudimos guardar los cambios porque la publicación anterior ya '
            'no se puede reemplazar. Revísala en Mis propiedades.',
          );
          return;
        }
        safeSetState(() {
          _model.createdPropertyId = null;
          _createdSignature = null;
        });
      }

      // Ya creada con estos mismos datos y sus documentos (se volvió desde
      // agendar la visita sin cambiar nada): se sigue con esa.
      var propertyId = _model.createdPropertyId;
      if (propertyId == null) {
        final call = DOVIAAPIPropertyContextGroup.createPropertyBasicCall;
        final response = await call.call(
          authToken: currentAuthenticationToken,
          body: buildCreatePropertyBody(input),
        );
        if (!response.succeeded) {
          await _showPublicationError(apiErrorMessage(
            response,
            'No se pudo crear la publicación. Revisa los datos e inténtalo de nuevo.',
          ));
          return;
        }
        final newId = call.propertyId(response.jsonBody)?.trim();
        if (newId == null || newId.isEmpty) {
          await _showPublicationError(
            'No pudimos confirmar la publicación. Inténtalo de nuevo.',
          );
          return;
        }

        final documentErrors = await _uploadOwnershipDocuments(newId);
        if (documentErrors.isNotEmpty) {
          await _discardDraft(newId);
          await _showPublicationError(
            'Tu propiedad no se publicó porque no pudimos subir los documentos:\n'
            '${documentErrors.join('\n')}\n\n'
            'Revisa los archivos y toca "Aceptar" de nuevo.',
          );
          return;
        }
        propertyId = newId;
        safeSetState(() {
          _model.createdPropertyId = newId;
          _createdSignature = signature;
        });
      }

      if (!mounted) return;
      context.pushNamed(
        DOVIACLIENTMisPropiedadesAgendarVisitaWidget.routeName,
        queryParameters: {
          'propertyId': serializeParam(propertyId, ParamType.String),
        }.withoutNulls,
      );
    } finally {
      safeSetState(() => _submitting = false);
    }
  }

  /// Presign, PUT a S3 y confirm de los documentos que pide la titularidad
  /// elegida. Devuelve un problema por documento que no quedó asociado.
  Future<List<String>> _uploadOwnershipDocuments(String propertyId) async {
    final pending = OwnershipDocument.requiredFor(_ownership);
    if (pending.isEmpty) return const [];

    String fileName(FFUploadedFile file) =>
        file.originalFilename.trim().isNotEmpty
            ? file.originalFilename.trim()
            : (file.name ?? 'documento').trim();

    final presign =
        await DOVIAAPIPropertyContextGroup.presignPropertyDocumentsCall.call(
      propertyId: propertyId,
      authToken: currentAuthenticationToken,
      uploads: [
        for (final doc in pending)
          {
            'purpose': doc.purpose,
            'fileName': fileName(_files[doc.field]!),
            'mimeType': documentMimeType(fileName(_files[doc.field]!)),
            'size': _files[doc.field]!.bytes!.length,
          },
      ],
    );
    if (!presign.succeeded) {
      return [
        apiErrorMessage(presign, 'No pudimos preparar la carga de documentos.'),
      ];
    }
    final slots = getJsonField(presign.jsonBody, r'$.data.uploads', true);

    final problems = <String>[];
    final uploaded = <String, OwnershipDocument>{};
    await Future.wait([
      for (final doc in pending)
        Future(() async {
          final slot = (slots is List ? slots : const [])
              .whereType<Map>()
              .where((s) => s['purpose'] == doc.purpose)
              .firstOrNull;
          final url = slot?['uploadUrl']?.toString();
          final uploadId = slot?['uploadId']?.toString();
          if (url == null || uploadId == null) {
            problems.add('${doc.label}: no se pudo preparar la carga.');
            return;
          }
          final headers = <String, String>{
            for (final entry
                in ((slot!['requiredHeaders'] as Map?) ?? const {}).entries)
              entry.key.toString(): entry.value.toString(),
          };
          try {
            // El body es el archivo tal cual; a S3 no va el token del API.
            final response = await putPresigned(Uri.parse(url),
                headers: headers, body: _files[doc.field]!.bytes);
            if (response.statusCode >= 200 && response.statusCode < 300) {
              uploaded[uploadId] = doc;
            } else {
              problems.add('${doc.label}: no se pudo subir el archivo.');
            }
          } catch (_) {
            problems.add('${doc.label}: no se pudo subir el archivo.');
          }
        }),
    ]);
    if (uploaded.isEmpty) return problems;

    final confirm =
        await DOVIAAPIPropertyContextGroup.confirmPropertyDocumentsCall.call(
      propertyId: propertyId,
      authToken: currentAuthenticationToken,
      uploadIds: uploaded.keys.toList(),
    );
    if (!confirm.succeeded) {
      return [
        ...problems,
        apiErrorMessage(confirm, 'No pudimos asociar los documentos.'),
      ];
    }
    // Un 200 no garantiza que todos se asociaron: se revisa cada resultado.
    final results = getJsonField(confirm.jsonBody, r'$.data.results', true);
    final confirmed = <String>{};
    for (final result
        in (results is List ? results : const []).whereType<Map>()) {
      final id = result['uploadId']?.toString();
      if (id != null && result['status'] == 'confirmed') confirmed.add(id);
    }
    for (final entry in uploaded.entries) {
      if (!confirmed.contains(entry.key)) {
        problems.add('${entry.value.label}: no se pudo asociar el archivo.');
      }
    }
    return problems;
  }

  /// Borra el borrador que quedó sin sus documentos, para que no aparezca en
  /// "Mis propiedades". Si el borrado falla, el borrador queda en DRAFT (sin
  /// publicarse) y el próximo intento igual crea una propiedad nueva.
  /// Da de baja un borrador (status DELETED). Devuelve si el backend lo
  /// aceptó.
  Future<bool> _discardDraft(
    String propertyId, {
    String note = 'No se pudieron subir los documentos de titularidad.',
  }) async {
    final result = await context
        .read<PropertiesRepository>()
        .changePropertyStatus(propertyId, 'DELETED', note: note);
    return result is Success;
  }

  /// Huella de lo que se envía al crear la propiedad: el body y, de cada
  /// documento, nombre y tamaño.
  String _submissionSignature(PublicationInput input) => jsonEncode({
        'body': buildCreatePropertyBody(input),
        'files': {
          for (final entry in _files.entries)
            entry.key: [
              entry.value.originalFilename,
              entry.value.bytes?.length ?? 0,
            ],
        },
      });

  /// Elige un documento de titularidad (PDF o imagen de hasta 10 MB).
  Future<void> _pickDocument(String key) async {
    final selected = await selectFiles(allowedExtensions: kDocumentExtensions);
    if (selected == null || selected.isEmpty) return;
    final picked = selected.first;
    if (documentMimeType(picked.originalFilename) == null) {
      safeSetState(() => _fieldErrors = {
            ..._fieldErrors,
            key: 'Sube un PDF o una imagen (JPG, PNG o WEBP).',
          });
      return;
    }
    if (picked.bytes.length > kMaxDocumentBytes) {
      safeSetState(() => _fieldErrors = {
            ..._fieldErrors,
            key: 'El archivo pesa más de 10 MB.',
          });
      return;
    }
    safeSetState(() {
      _files[key] = FFUploadedFile(
        name: picked.storagePath.split('/').last,
        bytes: picked.bytes,
        originalFilename: picked.originalFilename,
      );
      _fieldErrors = {..._fieldErrors}..remove(key);
    });
  }

  /// Sube la identificación a la cuenta: el backend la toma de ahí para la
  /// propiedad a nombre propio y para quien registra a nombre de otro.
  Future<void> _uploadAccountIdentification() async {
    final selected = await selectFiles(allowedExtensions: kDocumentExtensions);
    if (selected == null || selected.isEmpty || !mounted) return;
    final picked = selected.first;
    safeSetState(() {
      _uploadingAccountId = true;
      _accountIdError = null;
    });
    final result = await context.read<UserRepository>().uploadDocument(
          'identification-document',
          FFUploadedFile(
            name: picked.storagePath.split('/').last,
            bytes: picked.bytes,
            originalFilename: picked.originalFilename,
          ),
        );
    safeSetState(() {
      _uploadingAccountId = false;
      _accountIdError = result.errorOrNull == null
          ? null
          : 'No pudimos subir tu identificación. Inténtalo de nuevo.';
    });
    if (result.isSuccess) _clearFieldError('identity');
  }

  Future<void> _pickDate(String key) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) _c(key).text = DateFormat('dd/MM/yyyy').format(picked);
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(
        context, () => DOVIACLIENTMisPropiedadesVenderRentarModel());

    _addressFocusNode.addListener(_onAddressFocusChanged);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadZones();
      _loadProfile();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _addressFocusNode
      ..removeListener(_onAddressFocusChanged)
      ..dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _model.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Piezas del formulario
  // ---------------------------------------------------------------------------

  TextStyle _text({double? size, FontWeight? weight, Color? color}) =>
      FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: weight),
            fontSize: size,
            fontWeight: weight,
            color: color,
            letterSpacing: 0.0,
          );

  Widget _label(String text, {bool required = false}) => Text.rich(
        TextSpan(text: text, children: [
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(color: FlutterFlowTheme.of(context).error),
            ),
        ]),
        style: _text(),
      );

  /// Etiqueta arriba y el campo debajo, con el espacio entre campos.
  Widget _labeled(String label, Widget field, {bool required = false}) =>
      Padding(
        padding: const EdgeInsetsDirectional.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label(label, required: required),
            const SizedBox(height: 8.0),
            field,
          ],
        ),
      );

  InputDecoration _decoration(String key, {String? hint, String? prefix}) {
    final theme = FlutterFlowTheme.of(context);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        );
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: theme.labelMedium.override(
        font: GoogleFonts.inter(),
        letterSpacing: 0.0,
      ),
      prefixText: prefix,
      errorText: _fieldErrors[key],
      errorMaxLines: 2,
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(Colors.transparent),
      errorBorder: border(theme.error),
      focusedErrorBorder: border(theme.error),
      filled: true,
      fillColor: theme.secondaryBackground,
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
    );
  }

  Widget _textField(
    String key,
    String label, {
    bool required = false,
    String? hint,
    String? prefix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
    int? minLines,
    FocusNode? focusNode,
    VoidCallback? onTap,
  }) =>
      _labeled(
        label,
        required: required,
        TextFormField(
          key: _fieldKey(key),
          controller: _c(key),
          focusNode: focusNode,
          readOnly: onTap != null,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: minLines,
          style: _text(),
          cursorColor: FlutterFlowTheme.of(context).primaryText,
          decoration: _decoration(key, hint: hint, prefix: prefix),
        ),
      );

  Widget _amountField(String key, String label,
          {bool required = false, String? hint, int decimalDigits = 0}) =>
      _textField(
        key,
        label,
        required: required,
        hint: hint,
        prefix: '${currencySymbol()} ',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [AmountInputFormatter(decimalDigits: decimalDigits)],
      );

  Widget _numberField(String key, String label,
          {bool required = false, String? hint}) =>
      _textField(
        key,
        label,
        required: required,
        hint: hint,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );

  Widget _dateField(String key, String label) => _textField(
        key,
        label,
        required: true,
        hint: 'DD/MM/AAAA',
        onTap: () => _pickDate(key),
      );

  /// Texto de error bajo los campos que no son TextFormField.
  Widget _fieldErrorText(String field) {
    final error = _fieldErrors[field];
    return Padding(
      key: _fieldKey(field),
      padding: EdgeInsetsDirectional.fromSTEB(
          12.0, error == null ? 0.0 : 6.0, 0.0, 0.0),
      child: error == null
          ? const SizedBox.shrink()
          : Text(
              error,
              style: TextStyle(
                color: FlutterFlowTheme.of(context).error,
                fontSize: 12.0,
              ),
            ),
    );
  }

  /// Desplegable de [options] (valor que se envía -> etiqueta).
  Widget _dropdown(
    String key,
    String label,
    Map<String, String> options, {
    bool required = true,
    String hint = 'Selecciona',
    bool disabled = false,
    ValueChanged<String?>? onChanged,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final hasError = _fieldErrors.containsKey(key);
    return _labeled(
      label,
      required: required,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlutterFlowDropDown<String>(
            controller: _dropdownControllers.putIfAbsent(
                key, () => FormFieldController<String>(_choices[key])),
            options: options.keys.toList(),
            optionLabels: options.values.toList(),
            onChanged: (val) {
              safeSetState(() {
                if (val == null) {
                  _choices.remove(key);
                } else {
                  _choices[key] = val;
                }
              });
              _clearFieldError(key);
              onChanged?.call(val);
            },
            width: double.infinity,
            height: 50.0,
            textStyle: _text(),
            hintText: hint,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.secondaryText,
              size: 24.0,
            ),
            fillColor: theme.secondaryBackground,
            elevation: 2.0,
            borderColor: hasError ? theme.error : Colors.transparent,
            borderWidth: hasError ? 1.0 : 0.0,
            borderRadius: 8.0,
            margin: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 12.0, 0.0),
            hidesUnderline: true,
            disabled: disabled,
            isOverButton: false,
            isSearchable: false,
            isMultiSelect: false,
          ),
          _fieldErrorText(key),
        ],
      ),
    );
  }

  /// Campos en columnas: en el celular (< 600 px) van [narrow] por fila y en
  /// pantallas anchas [wide].
  Widget _grid(List<Widget> children, {int narrow = 1, int wide = 2}) =>
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600.0 ? wide : narrow;
        if (columns <= 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }
        return Column(
          children: [
            for (var i = 0; i < children.length; i += columns)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var j = i; j < i + columns; j++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: j == i ? 0.0 : 12.0),
                        child: j < children.length
                            ? children[j]
                            : const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
          ],
        );
      });

  /// Sección del formulario: línea divisoria, título y bajada.
  Widget _section(String title,
          {String? subtitle, required List<Widget> children}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.only(top: 24.0, bottom: 20.0),
            child: Divider(height: 1.0, thickness: 1.0),
          ),
          Text(title, style: _text(size: 16.0, weight: FontWeight.w600)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 6.0),
              child: Text(subtitle, style: _text(size: 13.0)),
            ),
          ...children,
        ],
      );

  Widget _subsectionTitle(String title) => Padding(
        padding: const EdgeInsetsDirectional.only(top: 24.0),
        child: Text(title, style: _text(size: 15.0, weight: FontWeight.w600)),
      );

  /// Aviso informativo: fondo suave y texto, sin ícono ni borde.
  Widget _banner(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).accent1,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: child,
      );

  /// Valor que no se edita, con el mismo aspecto que un campo.
  Widget _readOnlyBox(String text, {Widget? trailing}) => Container(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 12.0, 14.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: _text(weight: FontWeight.w600))),
            if (trailing != null) trailing,
          ],
        ),
      );

  /// Vista previa del archivo elegido.
  ///
  /// Sin archivo muestra el placeholder para subir. Con una imagen muestra la
  /// miniatura y con un documento el nombre, porque un PDF no se puede
  /// previsualizar acá. Se reemplaza tocándolo de nuevo.
  Widget _uploadPreview(FFUploadedFile? file) {
    final bytes = file?.bytes;
    if (file == null || bytes == null || bytes.isEmpty) {
      return SvgPicture.asset(
        'assets/images/AddMediaImage.svg',
        width: double.infinity,
        height: 150.0,
        fit: BoxFit.cover,
      );
    }

    final filename = file.originalFilename.trim().isNotEmpty
        ? file.originalFilename.trim()
        : (file.name ?? '').trim();
    final isImage =
        RegExp(r'\.(png|jpe?g|webp)$', caseSensitive: false).hasMatch(filename);

    if (isImage) {
      return Image.memory(
        bytes,
        width: double.infinity,
        height: 150.0,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: double.infinity,
      height: 150.0,
      color: FlutterFlowTheme.of(context).secondaryBackground,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 44.0,
            color: FlutterFlowTheme.of(context).primary,
          ),
          const SizedBox(height: 10.0),
          Text(
            filename.isEmpty ? 'Documento cargado' : filename,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _text(size: 13.0),
          ),
        ],
      ),
    );
  }

  Widget _fileField(String key, String label) => _labeled(
        label,
        required: true,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () => _pickDocument(key),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: _uploadPreview(_files[key]),
              ),
            ),
            _fieldErrorText(key),
          ],
        ),
      );

  /// Datos personales de una persona. [named] agrega nombre y sexo (quien
  /// no es el dueño de la cuenta); [phone], el teléfono.
  List<Widget> _personFields(String prefix,
          {required bool named, bool phone = false}) =>
      [
        if (named) ...[
          _textField('$prefix.fullName', 'Nombre completo',
              required: true, hint: 'Nombre y apellidos'),
          _grid([
            _dropdown('$prefix.sex', 'Sexo', kSexLabels),
            _numberField('$prefix.age', 'Edad',
                required: true, hint: 'Ej.: 45'),
          ]),
          _grid([
            _textField('$prefix.nationality', 'Nacionalidad',
                required: true, hint: 'Ej.: Guatemalteca'),
            _dropdown(
                '$prefix.maritalStatus', 'Estado civil', kMaritalStatusLabels),
          ]),
        ] else
          _grid([
            _numberField('$prefix.age', 'Edad',
                required: true, hint: 'Ej.: 45'),
            _textField('$prefix.nationality', 'Nacionalidad',
                required: true, hint: 'Ej.: Guatemalteca'),
          ]),
        if (!named)
          _dropdown(
              '$prefix.maritalStatus', 'Estado civil', kMaritalStatusLabels),
        _grid([
          _dropdown(
              '$prefix.idType', 'Tipo de documento', kIdentificationLabels),
          _textField('$prefix.idNumber', 'Número de documento',
              required: true, hint: 'Número de DPI o pasaporte'),
        ]),
        _grid([
          _textField('$prefix.occupation', 'Profesión u oficio',
              required: true, hint: 'Ej.: comerciante'),
          _textField('$prefix.nit', 'NIT', hint: 'Número de NIT'),
        ]),
        if (phone)
          _textField('$prefix.phone', 'Teléfono',
              required: true,
              hint: '5555 5555',
              prefix: '+502 ',
              keyboardType: TextInputType.phone),
      ];

  /// "Tus datos": nombre e identificación salen de la cuenta; el resto lo
  /// completa el usuario.
  List<Widget> _accountFields() {
    final repo = context.watch<UserRepository>();
    final profile = repo.profile;
    final theme = FlutterFlowTheme.of(context);
    final name = [profile?.firstName, profile?.lastName]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .join(' ');

    Widget identity;
    if ((profile == null && repo.isLoading) || _uploadingAccountId) {
      identity = const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(child: DoviaSpinner()),
      );
    } else if (profile?.identificationDocumentUrl != null) {
      identity = Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14.0, 14.0, 14.0, 14.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: theme.alternate),
        ),
        child: Row(
          children: [
            Icon(Icons.check_rounded, color: theme.primary, size: 20.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                'Ya la tenemos: la cargaste al crear tu cuenta.',
                style: _text(size: 13.0),
              ),
            ),
          ],
        ),
      );
    } else {
      identity = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tu cuenta todavía no tiene tu identificación. Súbela una vez y la usaremos en tus publicaciones.',
            style: _text(size: 13.0),
          ),
          const SizedBox(height: 8.0),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: _uploadAccountIdentification,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: _uploadPreview(null),
            ),
          ),
          if (_accountIdError != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 6.0, start: 12.0),
              child: Text(
                _accountIdError!,
                style: TextStyle(color: theme.error, fontSize: 12.0),
              ),
            ),
        ],
      );
    }

    final hasName = name.isNotEmpty;
    return [
      _subsectionTitle('Tus datos'),
      _labeled(
        _ownership == OwnershipKind.self
            ? 'Nombre del propietario'
            : 'Tu nombre',
        _readOnlyBox(
          hasName ? name : 'Completa tu nombre y apellido en Ajustes',
          trailing: hasName
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: theme.accent1,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text('De tu cuenta', style: _text(size: 11.0)),
                )
              : null,
        ),
      ),
      _labeled('Identificación', identity),
      _fieldErrorText('identity'),
      ..._personFields('me', named: false),
    ];
  }

  List<Widget> _thirdPartyFields() => [
        _dropdown('relationship', 'Tu relación con el propietario',
            kRelationshipLabels),
        _subsectionTitle('Datos del propietario'),
        ..._personFields('owner', named: true, phone: true),
        _fileField(OwnershipDocument.ownerIdentification.field,
            'Subir identificación del propietario'),
      ];

  List<Widget> _companyFields() => [
        _subsectionTitle('Datos de la sociedad'),
        _textField('company.name', 'Nombre de la sociedad',
            required: true, hint: 'Ej.: Inversiones Altamira, S.A.'),
        _textField('company.nit', 'NIT de la sociedad', hint: 'Número de NIT'),
        _labeled(
          'Inscripción en el Registro Mercantil',
          _grid([
            _numberField('company.regNumber', 'Número', required: true),
            _numberField('company.regFolio', 'Folio', required: true),
            _numberField('company.regBook', 'Libro', required: true),
          ], narrow: 3, wide: 3),
        ),
        CheckboxListTile(
          value: _companyElectronicBook,
          onChanged: (value) =>
              safeSetState(() => _companyElectronicBook = value ?? false),
          title: Text('Inscrita en libro electrónico', style: _text()),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: FlutterFlowTheme.of(context).primary,
        ),
        _subsectionTitle('Representante legal'),
        ..._personFields('rep', named: true),
        _fileField(OwnershipDocument.representativeIdentification.field,
            'Subir identificación del representante legal'),
        _subsectionTitle('Nombramiento del representante legal'),
        _labeled(
          'Acta notarial',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _grid([
                _textField('appt.city', 'Ciudad',
                    required: true, hint: 'Ej.: Guatemala'),
                _dateField('appt.date', 'Fecha'),
              ]),
              _textField('appt.notary', 'Nombre del notario',
                  required: true, hint: 'Nombre completo'),
            ],
          ),
        ),
        _labeled(
          'Inscripción en el Registro Mercantil',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _grid([
                _numberField('appt.regNumber', 'Número', required: true),
                _numberField('appt.regFolio', 'Folio', required: true),
                _numberField('appt.regBook', 'Libro', required: true),
              ], narrow: 3, wide: 3),
              _grid([
                _dateField('appt.regDate', 'Fecha'),
                _numberField('appt.termYears', 'Plazo en años',
                    required: true, hint: 'Ej.: 3'),
              ]),
            ],
          ),
        ),
        _fileField(OwnershipDocument.appointmentCertificate.field,
            'Adjuntar acta notarial de nombramiento'),
      ];

  List<Widget> _saleFields() {
    final price = parseAmount(_c('salePrice').text);
    final commission = price == null ? null : saleCommission(price);
    return [
      _subsectionTitle('Venta'),
      _grid([
        _amountField('salePrice', 'Precio de venta estimado',
            required: true, hint: '1,500,000'),
        _labeled(
          'Cantidad a recibir',
          _readOnlyBox(commission == null
              ? 'Se calcula con el precio de venta'
              : _money(price! - commission)),
        ),
      ]),
      if (commission != null)
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 8.0),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: 'Comisión DOVIA (3.5% + IVA): ',
                style: TextStyle(color: FlutterFlowTheme.of(context).primary),
              ),
              TextSpan(
                text: '${_money(commission)}. ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const TextSpan(
                  text: 'Puede variar si al negociar acuerdas otro precio.'),
            ]),
            style: _text(size: 12.0),
          ),
        ),
      _grid([
        _amountField('maintenance', 'Mantenimiento', hint: '0'),
        _amountField('propertyTax', 'Impuesto único sobre inmuebles',
            hint: '0'),
      ]),
    ];
  }

  List<Widget> _rentFields() {
    final rent = parseAmount(_c('monthlyRent').text);
    return [
      _subsectionTitle('Renta'),
      _amountField('monthlyRent',
          'Precio de renta mensual (incluyendo IVA y mantenimiento)',
          required: true, hint: '8,000', decimalDigits: 2),
      Padding(
        padding: const EdgeInsetsDirectional.only(top: 8.0),
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: 'Comisión DOVIA (1 renta + IVA)',
              style: TextStyle(color: FlutterFlowTheme.of(context).primary),
            ),
            if (rent != null)
              TextSpan(
                text: ': ${_money(rentCommission(rent))}.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )
            else
              const TextSpan(text: '.'),
          ]),
          style: _text(size: 12.0),
        ),
      ),
      _subsectionTitle('Condiciones de renta'),
      _grid([
        _dropdown(
          'minimumTime',
          'Tiempo mínimo',
          {for (final months in kRentMinimumMonths) '$months': '$months meses'},
          required: false,
        ),
        _textField('rentOthers', 'Otros',
            hint: 'Ej.: acepta mascotas, amueblado'),
      ]),
    ];
  }

  String _money(double value) =>
      '${currencySymbol()}${NumberFormat('#,##0.00', 'en_US').format(value)}';

  List<Widget> _locationFields() {
    final zones = _zones;
    final zoneName = _zoneName;
    return [
      _grid([
        _textField('address', 'Dirección de propiedad',
            required: true,
            hint: 'Escribe la dirección',
            focusNode: _addressFocusNode),
        if (_zonesFailed)
          _labeled(
            'Zona',
            required: true,
            InkWell(
              onTap: _loadZones,
              child: _readOnlyBox(
                'No pudimos cargar las zonas. Toca para reintentar.',
              ),
            ),
          )
        else
          _dropdown(
            'zone',
            'Zona',
            {
              for (final zone in zones ?? const <({String id, String name})>[])
                zone.id: zone.name,
            },
            hint: zones == null ? 'Cargando zonas...' : 'Selecciona',
            disabled: zones == null,
            // La zona afina la búsqueda de la dirección.
            onChanged: (_) => _geocodeAddress(),
          ),
      ]),
      _labeled(
        'Marca en el mapa la ubicación',
        required: true,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            wrapWithModel(
              model: _model.drawMapComponentModel,
              updateCallback: () => safeSetState(() {}),
              child: DrawMapComponentWidget(
                height: 300.0,
                singlePointMode: true,
                centerLatitude: kDoviaZoneCenters[zoneName]?.$1,
                centerLongitude: kDoviaZoneCenters[zoneName]?.$2,
                markedLatitude: _geocodedLatitude,
                markedLongitude: _geocodedLongitude,
                // El punto marcado ya es la ubicación.
                showConfirmButton: false,
                onPointSelected: (latitude, longitude) async {
                  safeSetState(() {
                    _selectedLatitude = latitude;
                    _selectedLongitude = longitude;
                  });
                  _clearFieldError('location');
                },
                onPointCleared: () {
                  safeSetState(() {
                    _selectedLatitude = null;
                    _selectedLongitude = null;
                  });
                },
              ),
            ),
            _fieldErrorText('location'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _legalFields() => [
        _grid([
          _textField('finca', 'Finca', hint: 'Número'),
          _textField('folio', 'Folio', hint: 'Número'),
          _textField('libro', 'Libro', hint: 'Número'),
          // El backend asigna el país; acá solo se muestra.
          _labeled('De', _readOnlyBox('Guatemala')),
        ], narrow: 2, wide: 4),
        _dropdown(
          'ownershipType',
          'La propiedad está a nombre de',
          {for (final kind in OwnershipKind.values) kind.apiValue: kind.label},
          // Mientras se envía no cambia. Ya creada sí: cambiarla hace que
          // "Aceptar" vuelva a crear la propiedad.
          disabled: _submitting,
          onChanged: (value) => safeSetState(() {
            _ownership = OwnershipKind.fromApi(value) ?? OwnershipKind.self;
            // Los errores de la variante anterior ya no aplican.
            _fieldErrors = {
              for (final entry in _fieldErrors.entries)
                if (!_isOwnershipField(entry.key)) entry.key: entry.value,
            };
          }),
        ),
        ...switch (_ownership) {
          OwnershipKind.self => _accountFields(),
          OwnershipKind.thirdParty => [
              ..._accountFields(),
              ..._thirdPartyFields(),
            ],
          OwnershipKind.company => _companyFields(),
        },
      ];

  static bool _isOwnershipField(String key) =>
      key.contains('.') ||
      key == 'identity' ||
      key == 'relationship' ||
      OwnershipDocument.values.any((doc) => doc.field == key);

  @override
  Widget build(BuildContext context) {
    // La titularidad arranca en "A mi nombre", como en el diseño.
    _choices.putIfAbsent('ownershipType', () => OwnershipKind.self.apiValue);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIASHAREDHeaderWidget(
                        showLogo: openedFromHome(context),
                        showSupport: false,
                        title: widget.title!,
                        showCurrency: false,
                        showMap: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 16.0, 20.0, 100.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_isSale && _isRent)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  bottom: 16.0),
                              child: _banner(Text(
                                'Seleccionaste venta y renta. Completa ambos apartados en este mismo formulario.',
                                style: _text(size: 13.0),
                              )),
                            ),
                          Text(
                            'Ingresa la información de tu propiedad',
                            style: _text(size: 16.0, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            'Estos datos nos permiten preparar tu publicación y validar detalles antes de enviar a nuestro equipo de producción.',
                            style: _text(size: 13.0),
                          ),
                          _textField(
                            'description',
                            'Describe de manera natural tu propiedad y el complejo',
                            required: true,
                            hint: 'Escribe aquí...',
                            maxLines: null,
                            minLines: 4,
                          ),
                          if (_isSale) ..._saleFields(),
                          if (_isRent) ..._rentFields(),
                          _section('Ubicación', children: _locationFields()),
                          _section(
                            'Información legal',
                            subtitle:
                                'Esta información se mantiene privada y solo se compartirá con tu consentimiento.',
                            children: _legalFields(),
                          ),
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(top: 28.0),
                            child: _banner(Text.rich(
                              const TextSpan(children: [
                                TextSpan(
                                  text:
                                      'Revisaremos la información que ingresaste para asegurar que todo esté correcto y listo para continuar con el proceso.\n\n'
                                      'En la siguiente pantalla podrás descargar el ',
                                ),
                                TextSpan(
                                  text:
                                      'Acuerdo de Autorización de Comercialización',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                    text: ', firmarlo y cargarlo firmado.\n\n'),
                                TextSpan(
                                  text:
                                      'DOVIA no trabaja con intermediarios comisionistas.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text:
                                      '\n\nTodo el proceso es sencillo, guiado y 100% seguro.',
                                ),
                              ]),
                              style: _text(size: 13.0),
                            )),
                          ),
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(top: 20.0),
                            child: IgnorePointer(
                              ignoring: _submitting,
                              child: Opacity(
                                opacity: _submitting ? 0.6 : 1.0,
                                child: wrapWithModel(
                                  model: _model.primaryButtonModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: PrimaryButtonWidget(
                                    text:
                                        _submitting ? 'Enviando...' : 'Aceptar',
                                    onTap: _submit,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 15.0, 12.0),
                        child: FixedDoviaIconWidget(),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIACLIENTNavbarWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
