import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_associate_specialties.dart';
import '/dovia_home_associate/associate_role.dart';
import '/dovia_home_associate/associate_specialties.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_servicios_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_servicios_model.dart';

/// Superficie de los campos del diseño (#FAFAFA).
const Color _kFieldSurface = Color(0xFFFAFAFA);

/// Superficie de las tarjetas de categoría (#F7F7F7).
const Color _kCardSurface = Color(0xFFF7F7F7);

/// Aqua/60 del diseño: el cuadrado que envuelve al ícono de cada categoría.
const Color _kIconSurface = Color(0xFF70ACAD);

/// Límites del certificado, tal como los valida
/// `POST /users/me/specialty-requests`. Se chequean acá para que el asociado se
/// entere antes de esperar un upload que el backend va a rechazar.
const int _kMaxCertificateBytes = 5 * 1024 * 1024;
const List<String> _kCertificateExtensions = [
  'pdf',
  'jpg',
  'jpeg',
  'png',
  'webp',
];

/// Textos que cambian según quién está pidiendo la especialidad.
///
/// La pantalla es la misma para el profesional independiente y para la empresa:
/// mismo endpoint, misma evidencia, misma auditoría del Backoffice. Lo que no es
/// lo mismo es **qué se le pide a cada uno**. Al independiente se le pregunta
/// por su trayectoria y su título; a una empresa, por la trayectoria del equipo
/// y por los permisos, patentes o certificaciones comerciales que la habilitan
/// en el rubro. Pedirle "tu título" a una empresa la deja sin saber qué
/// adjuntar, y es justamente el adjunto lo que decide la auditoría.
class _ServiciosCopy {
  const _ServiciosCopy({
    required this.emptyCurrent,
    required this.experienceHint,
    required this.certificateHelp,
    required this.successText,
  });

  /// Cuando todavía no hay ninguna especialidad aprobada.
  final String emptyCurrent;

  /// Placeholder del área de experiencia: es el ejemplo que fija el tono de lo
  /// que espera leer el auditor.
  final String experienceHint;

  /// Qué documento sirve como respaldo, debajo del rótulo de carga.
  final String certificateHelp;

  /// Cuerpo del modal de éxito.
  final String successText;

  /// Profesional independiente (`HOME_ASSOCIATE`).
  static const associate = _ServiciosCopy(
    emptyCurrent: 'Todavía no tenés especialidades aprobadas. Solicitá la '
        'primera acá abajo y el equipo de DOVIA revisará tu documentación.',
    experienceHint:
        'Ej: Tengo 5 años de experiencia instalando tableros eléctricos...',
    certificateHelp: 'Adjuntá el título, certificado o matrícula que respalde '
        'tu experiencia en el rubro.',
    successText: 'El equipo de DOVIA revisará tu documentación. Te avisaremos '
        'cuando la especialidad quede habilitada en tu perfil.',
  );

  /// Empresa asociada (`HOME_ASSOCIATE_COMPANY`).
  static const company = _ServiciosCopy(
    emptyCurrent: 'Tu empresa todavía no tiene especialidades aprobadas. '
        'Solicitá la primera acá abajo y el equipo de DOVIA revisará la '
        'documentación.',
    experienceHint: 'Ej: La empresa lleva 8 años ejecutando instalaciones '
        'eléctricas en obra nueva, con un equipo de 6 técnicos matriculados...',
    certificateHelp: 'Adjuntá el permiso, la patente o la certificación '
        'comercial que habilita a tu empresa en el rubro.',
    successText: 'El equipo de DOVIA revisará la documentación. Te avisaremos '
        'cuando la especialidad quede habilitada en el perfil de tu empresa.',
  );
}

/// Especialidades del Dovia Home Associate, adaptado a mobile desde el diseño
/// de escritorio.
///
/// Dos bloques bien separados, porque hacen cosas distintas:
///   - **Servicios actuales**: las especialidades en las que ya está aprobado.
///     Son informativas y deliberadamente **no** son tappables — no filtran ni
///     abren nada; que respondan al toque haría creer que se pueden editar.
///   - **Solicitar un servicio nuevo**: especialidades solicitables + evidencia.
///     El flujo exige "1 formulario por especialización", así que el selector se
///     comporta como un radio button: elegir otra desmarca la anterior.
///
/// Las dos listas y las solicitudes en auditoría salen resueltas de
/// `GET /users/me/specialties`: el backend ya descuenta del selector las
/// especialidades aprobadas, para que no pueda pedir dos veces lo mismo.
///
/// El envío no habilita nada por sí solo: genera el pendiente de auditoría en
/// el Backoffice de DOVIA, y la categoría recién aparece arriba cuando un admin
/// aprueba la documentación.
///
/// La misma pantalla sirve al profesional independiente y a la empresa: las dos
/// rutas cuelgan de `/users/me/...` y resuelven al asociado desde el JWT, así
/// que la solicitud queda vinculada al Company ID sin que la UI mande ningún id.
/// Lo único que cambia por rol son los textos ([_ServiciosCopy]) y el menú
/// inferior, que con rol Empresa suma el ítem de Cotizaciones.
class DHASSOCIATEServiciosWidget extends StatefulWidget {
  const DHASSOCIATEServiciosWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_Servicios';
  static String routePath = '/dHASSOCIATEServicios';

  /// De dónde salen las especialidades. En producción es
  /// `GET /users/me/specialties`; los tests la sustituyen para poder ejercitar
  /// las dos grillas y el formulario, que de otro modo nunca se pintan porque el
  /// `FutureBuilder` resuelve siempre en error sin red.
  @visibleForTesting
  static Future<AssociateSpecialties> Function()? specialtiesLoader;

  @override
  State<DHASSOCIATEServiciosWidget> createState() =>
      _DHASSOCIATEServiciosWidgetState();
}

class _DHASSOCIATEServiciosWidgetState
    extends State<DHASSOCIATEServiciosWidget> {
  late DHASSOCIATEServiciosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<AssociateSpecialties> _serviciosFuture;

  /// Textos del rol en sesión. Se fija una sola vez: el rol no cambia mientras
  /// la pantalla está abierta, y releerlo en cada `build` sólo abriría la puerta
  /// a que el formulario cambie de voz a mitad de la carga.
  late final _ServiciosCopy _copy;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEServiciosModel());

    _copy = isHomeAssociateCompany()
        ? _ServiciosCopy.company
        : _ServiciosCopy.associate;

    _model.experienceController ??= TextEditingController();
    _model.experienceFocusNode ??= FocusNode();

    _serviciosFuture = _loadSpecialties();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<AssociateSpecialties> _loadSpecialties() =>
      DHASSOCIATEServiciosWidget.specialtiesLoader?.call() ??
      loadAssociateSpecialties(authToken: currentAuthenticationToken ?? '');

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Formulario.
  // ---------------------------------------------------------------------------

  /// Bloqueo preventivo del botón: especialidad + experiencia + certificado. Las
  /// tres son obligatorias porque el Backoffice audita con la evidencia, no con
  /// la buena fe.
  bool get _canSubmit =>
      _model.selectedSpecialtyId != null &&
      (_model.experienceController?.text.trim().isNotEmpty ?? false) &&
      _model.certificate != null &&
      !_model.isSubmitting;

  /// Selector nativo del dispositivo. El certificado puede ser una foto del
  /// título colgado en la pared o el PDF que le dio el instituto, así que se
  /// ofrecen las tres fuentes: cámara, galería y gestor de archivos.
  Future<void> _pickCertificate() async {
    final source = await showModalBottomSheet<_CertificateSource>(
      context: context,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 8.0),
              child: Text(
                'Carga el certificado o título',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      fontSize: 16.0,
                      letterSpacing: 0.32,
                    ),
              ),
            ),
            // La cámara no existe en web: ahí sólo tiene sentido galería y
            // archivos.
            if (!isWeb)
              _sourceTile(
                sheetContext,
                icon: Icons.photo_camera_outlined,
                label: 'Tomar una foto',
                source: _CertificateSource.camera,
              ),
            _sourceTile(
              sheetContext,
              icon: Icons.photo_library_outlined,
              label: 'Elegir de la galería',
              source: _CertificateSource.gallery,
            ),
            _sourceTile(
              sheetContext,
              icon: Icons.folder_outlined,
              label: 'Subir un archivo (PDF)',
              source: _CertificateSource.file,
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    safeSetState(() => _model.isPickingCertificate = true);
    try {
      final selected = switch (source) {
        _CertificateSource.camera =>
          await selectMedia(mediaSource: MediaSource.camera),
        _CertificateSource.gallery =>
          await selectMedia(mediaSource: MediaSource.photoGallery),
        _CertificateSource.file => await selectFiles(
            multiFile: false,
            allowedExtensions: _kCertificateExtensions,
          ),
      };

      if (selected == null || selected.isEmpty) return;

      // Uno solo: la regla del flujo es "1 formulario por especialización", y
      // el certificado es la evidencia de esa única especialidad.
      final media = selected.first;

      // `name` es el filename con el que viaja el multipart, o sea lo que va a
      // leer el auditor del Backoffice: se conserva el nombre real del archivo
      // ("titulo-electricista.pdf") en vez del `<timestamp>.<ext>` que arma el
      // picker. Ese timestamp queda de respaldo para cuando el origen no trae
      // nombre utilizable — una foto recién tomada con la cámara, típicamente —
      // porque la extensión es lo que define el Content-Type del upload.
      final timestampedName = media.storagePath.split('/').last;
      final originalName = media.originalFilename;
      final name = originalName.contains('.') ? originalName : timestampedName;

      final rejection = _certificateRejection(name, media.bytes);
      if (rejection != null) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(rejection)));
        }
        return;
      }

      safeSetState(() {
        _model.certificate = FFUploadedFile(
          name: name,
          bytes: media.bytes,
          originalFilename: originalName,
        );
      });
    } finally {
      if (mounted) safeSetState(() => _model.isPickingCertificate = false);
    }
  }

  /// Por qué no sirve este archivo como certificado, o null si sirve.
  ///
  /// Reproduce las reglas del endpoint (formato, no vacío y hasta 5 MB) para
  /// explicarle el problema apenas elige el archivo, en vez de hacerle completar
  /// el formulario y comerse el rechazo recién al enviar.
  String? _certificateRejection(String name, Uint8List? bytes) {
    final extension = name.split('.').last.toLowerCase();
    if (!_kCertificateExtensions.contains(extension)) {
      return 'El certificado tiene que ser un PDF o una imagen '
          '(JPG, PNG o WEBP).';
    }
    if (bytes == null || bytes.isEmpty) {
      return 'No pudimos leer el archivo. Probá de nuevo o elegí otro.';
    }
    if (bytes.length > _kMaxCertificateBytes) {
      return 'El certificado no puede pesar más de 5 MB.';
    }
    return null;
  }

  Widget _sourceTile(
    BuildContext sheetContext, {
    required IconData icon,
    required String label,
    required _CertificateSource source,
  }) =>
      ListTile(
        leading: Icon(icon, color: FlutterFlowTheme.of(context).primary),
        title: Text(
          label,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: 15.0,
                letterSpacing: 0.0,
              ),
        ),
        onTap: () => Navigator.pop(sheetContext, source),
      );

  /// Mensaje de error que mandó el backend, si es que mandó uno legible.
  ///
  /// La API envuelve todo en `{ success, message, data, errors }`, con `message`
  /// en castellano y apto para mostrar. Se descarta lo que no sea texto útil
  /// —un body vacío por caída de red, o el `message` genérico de éxito— para no
  /// pasarle al asociado un cartel que no le dice nada.
  String? _errorMessage(dynamic body) {
    for (final path in [r'''$.errors[0].message''', r'''$.message''']) {
      final value = getJsonField(body, path);
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  /// Emite la solicitud al Backoffice de DOVIA para auditoría.
  Future<void> _submit() async {
    final specialtyId = _model.selectedSpecialtyId;
    final experience = _model.experienceController?.text.trim() ?? '';
    final certificate = _model.certificate;
    if (specialtyId == null || experience.isEmpty || certificate == null)
      return;

    safeSetState(() => _model.isSubmitting = true);
    try {
      final response = await DOVIAAPIAssociateSpecialtiesContextGroup
          .createSpecialtyRequestCall
          .call(
        specialtyId: specialtyId,
        experience: experience,
        file: certificate,
        authToken: currentAuthenticationToken ?? '',
      );

      if (!mounted) return;

      if (!response.succeeded) {
        // El formulario conserva lo cargado: hacerle escribir de nuevo la
        // experiencia y volver a buscar el certificado por un error de red
        // sería castigarlo por algo que no hizo.
        //
        // Se prefiere el mensaje del backend cuando viene: "ya tenés una
        // solicitud en revisión" o "el archivo supera el tamaño permitido" le
        // dicen qué corregir, cosa que un "intentá de nuevo" no hace.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _errorMessage(response.jsonBody) ??
                  'No se pudo enviar la solicitud. Intentá de nuevo en un '
                      'momento.',
            ),
          ),
        );
        return;
      }

      await showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: PopupExitoWidget(
            title: 'Solicitud enviada con éxito',
            text: _copy.successText,
            continueText: 'Entendido',
            onContinue: () => Navigator.pop(dialogContext),
          ),
        ),
      );

      if (!mounted) return;
      // La solicitud ya existe del lado del backend: se recarga el listado para
      // que la especialidad aparezca como pendiente con el estado real, y
      // mientras tanto se la marca localmente para que no quede tappable entre
      // el modal de éxito y la respuesta de la recarga.
      safeSetState(() {
        _model.requestedSpecialtyIds.add(specialtyId);
        _model.resetForm();
        _serviciosFuture = _loadSpecialties();
      });
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Bloques de UI.
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String text) => Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 17.0,
              letterSpacing: 0.34,
              lineHeight: 1.3,
            ),
      );

  Widget _fieldLabel(String text) => Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(),
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 16.0,
              letterSpacing: 0.32,
            ),
      );

  /// Aclaración al pie de un rótulo: qué se espera en ese campo.
  Widget _fieldHelp(String text) => Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 12.0,
              letterSpacing: 0.0,
            ),
      );

  Widget _hint(String message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3EF),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          message,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 13.0,
                letterSpacing: 0.0,
              ),
        ),
      );

  /// Tarjeta de especialidad del diseño. `onTap` en null la deja informativa,
  /// que es como se pintan los servicios ya aprobados.
  Widget _categoryCard(
    AssociateSpecialty category, {
    bool isSelected = false,
    bool isPending = false,
    VoidCallback? onTap,
  }) {
    final Widget card = Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: _kCardSurface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary
              : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : _kIconSurface,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                category.iconPath,
                width: 16.0,
                height: 16.0,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              category.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ],
      ),
    );

    if (isPending) {
      return Opacity(
        opacity: 0.45,
        child: Semantics(
          image: true,
          label: '${category.label}, solicitud en revisión',
          child: ExcludeSemantics(child: card),
        ),
      );
    }

    if (onTap == null) {
      // Informativa: sin InkWell ni feedback táctil, y anunciada como imagen
      // para que el lector de pantalla tampoco la ofrezca como accionable.
      return Semantics(
        image: true,
        label: category.label,
        child: ExcludeSemantics(child: card),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Semantics(
        selected: isSelected,
        label: category.label,
        child: ExcludeSemantics(child: card),
      ),
    );
  }

  Widget _categoryGrid(List<Widget> cards) => Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: cards,
      );

  /// Área de texto libre donde el asociado redacta su background en la
  /// especialidad que está pidiendo.
  Widget _buildExperienceField() {
    return SizedBox(
      height: 104.0,
      child: TextFormField(
        controller: _model.experienceController,
        focusNode: _model.experienceFocusNode,
        autofocus: false,
        obscureText: false,
        // Tope duro en el máximo que acepta el endpoint. Se corta al escribir y
        // no se muestra contador: el campo es de texto libre y llegar a 2000
        // caracteres redactando un párrafo de experiencia es improbable, pero
        // pegar un CV entero y comerse un 400 al enviar no lo es.
        inputFormatters: [LengthLimitingTextInputFormatter(2000)],
        // El botón [Solicitar] se reevalúa con cada tecla.
        onChanged: (_) => safeSetState(() {}),
        decoration: InputDecoration(
          isDense: true,
          hintText: _copy.experienceHint,
          // El ejemplo de la empresa es más largo que el del independiente: se
          // acota para que no desborde los 104 px del campo.
          hintMaxLines: 3,
          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: 14.0,
                letterSpacing: 0.28,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: _kFieldSurface,
          contentPadding:
              const EdgeInsetsDirectional.fromSTEB(15.0, 16.0, 15.0, 16.0),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(),
              fontSize: 14.0,
              letterSpacing: 0.28,
            ),
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.top,
        maxLines: null,
        expands: true,
        cursorColor: FlutterFlowTheme.of(context).primaryText,
        validator: _model.experienceControllerValidator.asValidator(context),
      ),
    );
  }

  /// Zona de carga del certificado. Una vez cargado muestra el archivo elegido
  /// —que puede ser un PDF y por lo tanto no se previsualiza— con la opción de
  /// quitarlo.
  Widget _buildCertificateZone() {
    final certificate = _model.certificate;

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: _model.isPickingCertificate ? null : _pickCertificate,
      child: Container(
        width: double.infinity,
        height: 131.0,
        decoration: BoxDecoration(
          color: _kFieldSurface,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: _model.isPickingCertificate
            ? SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            : certificate == null
                ? SvgPicture.asset(
                    'assets/images/AddMediaImage.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.contain,
                  )
                : _buildCertificatePreview(certificate),
      ),
    );
  }

  Widget _buildCertificatePreview(FFUploadedFile certificate) {
    final name = certificate.name ?? 'Certificado';
    final isImage = !name.toLowerCase().endsWith('.pdf');
    final bytes = certificate.bytes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: (isImage && bytes != null)
                ? Image.memory(
                    bytes,
                    width: 72.0,
                    height: 72.0,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _certificateFallbackIcon(),
                  )
                : _certificateFallbackIcon(),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => safeSetState(() => _model.certificate = null),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(
                Icons.close_rounded,
                size: 20.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _certificateFallbackIcon() => Container(
        width: 72.0,
        height: 72.0,
        color: FlutterFlowTheme.of(context).alternate,
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Icon(
          Icons.description_outlined,
          size: 28.0,
          color: FlutterFlowTheme.of(context).secondaryText,
        ),
      );

  /// Cuerpo de la pantalla una vez resueltas las especialidades.
  Widget _buildContent(AssociateSpecialties data) {
    if (data.failed) return _hint(data.errorMessage);

    // Con solicitud en auditoría: las que el backend reporta como pendientes,
    // más las enviadas en esta sesión y todavía no reflejadas en el listado.
    bool isPending(AssociateSpecialty specialty) =>
        data.isPending(specialty) ||
        _model.requestedSpecialtyIds.contains(specialty.id);

    // Las solicitables, y las que sólo se pueden mirar porque ya están en
    // revisión. Las pendientes que el backend descuenta de `available` se
    // agregan al final para que la solicitud recién enviada siga a la vista.
    final selectable =
        data.available.where((s) => !isPending(s)).toList(growable: false);
    final pendingCards = [
      ...data.available.where(isPending),
      ...data.pendingOutsideAvailable,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Servicios actuales'),
        const SizedBox(height: 14.0),
        if (data.current.isEmpty)
          _hint(_copy.emptyCurrent)
        else
          _categoryGrid([
            for (final specialty in data.current) _categoryCard(specialty),
          ]),
        const SizedBox(height: 30.0),
        _sectionTitle('Solicita agregar un nuevo servicio en tu perfil'),
        const SizedBox(height: 14.0),
        if (selectable.isEmpty && pendingCards.isEmpty)
          _hint('No hay nuevas especialidades para solicitar por ahora.')
        else ...[
          _categoryGrid([
            for (final specialty in selectable)
              _categoryCard(
                specialty,
                isSelected: _model.selectedSpecialtyId == specialty.id,
                // Radio button: elegir otra desmarca la anterior, y volver a
                // tocar la elegida limpia la selección.
                onTap: () => safeSetState(() {
                  _model.selectedSpecialtyId =
                      _model.selectedSpecialtyId == specialty.id
                          ? null
                          : specialty.id;
                }),
              ),
            for (final specialty in pendingCards)
              _categoryCard(specialty, isPending: true),
          ]),
          if (pendingCards.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            Text(
              'Las categorías atenuadas ya tienen una solicitud en revisión.',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
          // Sin nada que elegir no hay formulario que completar: el bloqueo del
          // botón nunca se podría levantar y sólo mostraría campos muertos.
          if (selectable.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: _hint('Todas las especialidades que podés sumar ya tienen '
                  'una solicitud en revisión.'),
            )
          else ...[
            const SizedBox(height: 24.0),
            _fieldLabel('Escribe la experiencia en este nuevo servicio'),
            const SizedBox(height: 12.0),
            _buildExperienceField(),
            const SizedBox(height: 18.0),
            _fieldLabel('Carga el certificado o titulo'),
            const SizedBox(height: 6.0),
            // El rótulo del diseño sirve para un título personal, pero no le
            // dice a una empresa que lo que se audita son sus permisos o
            // certificaciones comerciales. Se aclara sin tocar el rótulo.
            _fieldHelp(_copy.certificateHelp),
            const SizedBox(height: 12.0),
            _buildCertificateZone(),
            const SizedBox(height: 30.0),
            FFButtonWidget(
              onPressed: _canSubmit ? _submit : null,
              text: _model.isSubmitting ? 'Enviando...' : 'Solicitar',
              options: FFButtonOptions(
                width: double.infinity,
                height: 42.0,
                padding: const EdgeInsetsDirectional.fromSTEB(
                    20.0, 10.0, 20.0, 10.0),
                iconPadding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      color: Colors.white,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                disabledColor: FlutterFlowTheme.of(context).alternate,
                disabledTextColor: FlutterFlowTheme.of(context).secondaryText,
                elevation: 0.0,
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    wrapWithModel(
                      model: _model.dHASSOCIATEHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DHASSOCIATEHeaderWidget(
                        tittleText: 'Servicios',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 30.0, 20.0, 140.0),
                      child: FutureBuilder<AssociateSpecialties>(
                        future: _serviciosFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return _buildContent(snapshot.data!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(1.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 15.0, 100.0),
                      child: wrapWithModel(
                        model: _model.fixedDoviaIconModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const FixedDoviaIconWidget(),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    child: wrapWithModel(
                      model: _model.dHASSOCIATENavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DHASSOCIATENavbarWidget(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fuentes desde las que se puede cargar el certificado.
enum _CertificateSource { camera, gallery, file }
