// Cierre del proceso legal visto por el cliente: los profesionales que lo
// acompañaron y la bóveda de documentos del trámite.
//
// Todo sale de `GET /legal-processes/{processId}`, el único endpoint que el
// rol CLIENT puede leer y que trae a la vez `legalAssociateProfile`,
// `legalHqProfile` y el arreglo `documents`. La oferta sola no alcanza: expone
// el asociado pero no a Legal HQ ni los archivos.

import 'offer_json.dart';

/// Los dos roles que el cliente ve y califica al cerrar el trato.
enum LegalProfessionalRole { legalAssociate, legalOfficer }

extension LegalProfessionalRoleX on LegalProfessionalRole {
  /// Valor que esperan `targetRole` en calificaciones y reportes.
  String get apiValue {
    switch (this) {
      case LegalProfessionalRole.legalAssociate:
        return 'LEGAL_ASSOCIATE';
      case LegalProfessionalRole.legalOfficer:
        return 'LEGAL_OFFICER';
    }
  }

  /// Etiqueta de la tarjeta, con las mayúsculas del diseño.
  String get label {
    switch (this) {
      case LegalProfessionalRole.legalAssociate:
        return 'Dovia Legal Associate';
      case LegalProfessionalRole.legalOfficer:
        return 'Dovia legal HQ';
    }
  }
}

/// Un profesional asignado al trámite.
class LegalProfessional {
  final LegalProfessionalRole role;
  final String fullName;
  final String avatarUrl;

  /// Teléfono ya armado con su código de país, listo para `wa.me`/`tel:`.
  final String phone;
  final String email;

  const LegalProfessional({
    required this.role,
    required this.fullName,
    required this.avatarUrl,
    required this.phone,
    required this.email,
  });

  bool get hasPhone => phone.isNotEmpty;
  bool get hasEmail => email.isNotEmpty;

  /// El perfil llega `null` mientras el rol no esté asignado: ahí no hay
  /// tarjeta que dibujar.
  static LegalProfessional? fromProfile(
    dynamic profile,
    LegalProfessionalRole role,
  ) {
    final map = offerAsMap(profile);
    if (map == null) return null;

    final name = offerStr(map['fullName']) ?? offerStr(map['name']);
    if (name == null) return null;

    final phone = offerAsMap(map['phone']);
    final number = offerStr(phone?['number']) ?? '';
    final countryCode = offerStr(phone?['countryCode']) ?? '';

    return LegalProfessional(
      role: role,
      fullName: name,
      avatarUrl: offerStr(map['avatar']) ?? '',
      phone: number.isEmpty ? '' : '$countryCode$number',
      email: offerStr(map['email']) ?? '',
    );
  }
}

/// Estados en los que el archivo ya existe y el cliente puede abrirlo. Un
/// documento `rejected` volvió atrás: sigue pendiente para él.
const Set<String> _readyDocumentStatuses = {'approved', 'submitted'};

/// Un documento del expediente.
class LegalDocument {
  final String label;
  final String url;
  final String status;

  const LegalDocument({
    required this.label,
    required this.url,
    required this.status,
  });

  /// Listo para descargar: hay archivo y nadie lo rechazó.
  bool get isReady => url.isNotEmpty && _readyDocumentStatuses.contains(status);

  static LegalDocument? fromJson(dynamic json) {
    final map = offerAsMap(json);
    if (map == null) return null;

    final label = offerStr(map['label']) ?? offerStr(map['type']);
    if (label == null) return null;

    return LegalDocument(
      label: label,
      url: offerStr(map['url']) ?? '',
      status: (offerStr(map['status']) ?? '').toLowerCase(),
    );
  }
}

/// Lo que la pantalla de cierre necesita del proceso legal.
class LegalProcessClosure {
  /// El asociado primero y Legal HQ después, como en el diseño. Sólo van los
  /// roles ya asignados.
  final List<LegalProfessional> professionals;

  final List<LegalDocument> documents;

  const LegalProcessClosure({
    required this.professionals,
    required this.documents,
  });

  const LegalProcessClosure.empty()
      : professionals = const [],
        documents = const [];

  bool get isEmpty => professionals.isEmpty && documents.isEmpty;

  factory LegalProcessClosure.fromJson(Map<String, dynamic> json) {
    final process = unwrapLegalProcessJson(json) ?? json;

    final professionals = <LegalProfessional>[];
    final associate = LegalProfessional.fromProfile(
      process['legalAssociateProfile'],
      LegalProfessionalRole.legalAssociate,
    );
    if (associate != null) professionals.add(associate);
    final hq = LegalProfessional.fromProfile(
      process['legalHqProfile'],
      LegalProfessionalRole.legalOfficer,
    );
    if (hq != null) professionals.add(hq);

    final documents = <LegalDocument>[];
    final raw = process['documents'];
    if (raw is List) {
      for (final item in raw) {
        final document = LegalDocument.fromJson(item);
        if (document != null) documents.add(document);
      }
    }

    return LegalProcessClosure(
      professionals: professionals,
      documents: documents,
    );
  }
}

/// El proceso puede venir directo o envuelto en `data`, según el endpoint.
Map<String, dynamic>? unwrapLegalProcessJson(Map<String, dynamic>? json) {
  var current = json;
  for (var i = 0; i < 2; i++) {
    if (current == null) return null;
    if (current.containsKey('documents') ||
        current.containsKey('legalAssociateProfile') ||
        current.containsKey('legalHqProfile')) {
      return current;
    }
    current = offerAsMap(current['data']);
  }
  return current;
}
