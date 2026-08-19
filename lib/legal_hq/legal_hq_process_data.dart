// Capa de datos y etiquetas compartida por las pantallas de Legal HQ
// (Home, Procesos y Expediente).
//
// El tablero del HQ se arma con dos bandejas distintas:
//   * `GET /legal-processes/legal-hq`            → expedientes ya asignados
//   * `GET /legal-processes/legal-hq/unassigned` → expedientes libres
// Un expediente solo se puede abrir después de reclamarlo con
// `POST /legal-processes/{id}/legal-hq/accept`; sin eso el backend responde
// 403 USER_NOT_RELATED_TO_PROCESS.

import 'package:flutter/material.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/backend/api_requests/api_manager.dart';
import '/flutter_flow/flutter_flow_util.dart';

// ── Enums confirmados por el backend ────────────────────────────────────────
//
// category: SALE | RENT | PUBLICATION | SALE_MORTGAGE
// status:   NOT_STARTED, IN_PROGRESS, DRAFTING, MEETING_COORDINATION,
//           MEETING_SCHEDULED, LEGAL_HQ_REVIEW, REJECTED, APPROVED,
//           BANK_MANAGEMENT_STARTED, BANK_DOCUMENTATION_SUBMITTED,
//           BANK_EVALUATION, FINISHED

const String kCategoryPublication = 'PUBLICATION';
const String kCategoryMortgage = 'SALE_MORTGAGE';
const String kCategorySale = 'SALE';
const String kCategoryRent = 'RENT';

/// Compraventa al contado y arrendamiento: lo que trabaja el Legal Associate.
const String kAssociateCategories = 'SALE,RENT';

/// Expedientes vivos. Deja fuera `APPROVED` y `FINISHED`, que son terminales.
const String kActiveStatuses = 'NOT_STARTED,IN_PROGRESS,DRAFTING,'
    'MEETING_COORDINATION,MEETING_SCHEDULED,LEGAL_HQ_REVIEW,REJECTED';

/// Expedientes ya cerrados con éxito.
const String kClosedStatuses = 'APPROVED,FINISHED';

const Set<String> kMortgageStatuses = {
  'BANK_MANAGEMENT_STARTED',
  'BANK_DOCUMENTATION_SUBMITTED',
  'BANK_EVALUATION',
};

// ── Modelo ──────────────────────────────────────────────────────────────────

class LegalHqProcess {
  const LegalHqProcess({
    required this.id,
    required this.category,
    required this.status,
    required this.propertyId,
    required this.isAssignedToMe,
    this.hasLegalAssociate = false,
    this.address = '',
    this.propertyName = '',
    this.imageUrl = '',
    this.createdAt = '',
    this.ownerName = '',
    this.clientName = '',
    this.legalAssociateName = '',
  });

  final String id;
  final String category;
  final String status;
  final String propertyId;

  /// `false` mientras el expediente siga sin `legalHqId`.
  final bool isAssignedToMe;

  /// `true` cuando ya hay un Legal Associate trabajándolo.
  final bool hasLegalAssociate;

  final String address;
  final String propertyName;
  final String imageUrl;
  final String createdAt;

  final String ownerName;
  final String clientName;
  final String legalAssociateName;

  /// Nombre visible del expediente: el de la propiedad y, si no hay, la
  /// dirección. `property.name` puede venir null en datos reales.
  String get title {
    if (propertyName.isNotEmpty) return propertyName;
    if (address.isNotEmpty) return address;
    return 'Propiedad sin nombre';
  }

  factory LegalHqProcess.fromJson(
    Map<String, dynamic> json, {
    required bool isAssignedToMe,
  }) {
    final property = json['property'] as Map<String, dynamic>? ?? {};
    return LegalHqProcess(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      isAssignedToMe: isAssignedToMe,
      hasLegalAssociate:
          (json['legalAssociateId']?.toString() ?? '').isNotEmpty,
      address: property['fullAddress']?.toString() ?? '',
      propertyName: property['name']?.toString() ?? '',
      imageUrl: property['image']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      ownerName: _profileName(json['ownerProfile']),
      clientName: _profileName(json['interestedProfile']),
      legalAssociateName: _profileName(json['legalAssociateProfile']),
    );
  }

  static String _profileName(dynamic profile) {
    if (profile is Map<String, dynamic>) {
      return profile['fullName']?.toString() ?? '';
    }
    return '';
  }
}

/// Documento del expediente, tal como lo devuelve `GET /legal-processes/{id}`.
class LegalHqDocument {
  const LegalHqDocument({
    required this.id,
    required this.label,
    required this.status,
    this.type = '',
    this.url = '',
    this.note = '',
    this.hqReviewDecision = '',
    this.mimeType = '',
    this.originalName = '',
    this.uploadedAt = '',
    this.updatedAt = '',
    this.required_ = false,
  });

  final String id;
  final String label;

  /// `missing` | `submitted` | `approved` | `rejected`
  final String status;

  /// Tipo de documento del proceso legal (p. ej. `DOVIA_AGREEMENT_UNSIGNED`).
  final String type;

  final String url;
  final String note;

  /// `approved` | `rejected` | '' cuando el HQ todavía no decidió.
  final String hqReviewDecision;

  final String mimeType;
  final String originalName;
  final String uploadedAt;
  final String updatedAt;
  final bool required_;

  bool get isReviewedByHq => hqReviewDecision.isNotEmpty;
  bool get hasFile => url.isNotEmpty;
  bool get isPdf =>
      mimeType.toLowerCase().contains('pdf') ||
      url.toLowerCase().contains('.pdf');

  /// Nombre del archivo tal como se subió; si no vino, la etiqueta.
  String get fileName => originalName.isNotEmpty ? originalName : label;

  /// Fecha con la que se ordena el historial de versiones.
  String get sortDate => uploadedAt.isNotEmpty ? uploadedAt : updatedAt;

  /// `true` para los documentos que forman el contrato de la operación.
  /// El backend expone dos slots de sistema (`DOVIA_AGREEMENT_UNSIGNED` y
  /// `DOVIA_AGREEMENT_SIGNED`) y el asociado puede sumar borradores como
  /// documentos CUSTOM, cuya etiqueta sale del nombre del archivo.
  bool get isContractVersion {
    final haystack = '$type $label $originalName'.toLowerCase();
    return haystack.contains('agreement') ||
        haystack.contains('contract') ||
        haystack.contains('contrato');
  }

  /// `true` cuando es la versión firmada, que cierra el historial.
  bool get isSignedContract {
    final haystack = '$type $label $originalName'.toLowerCase();
    return haystack.contains('signed') && !haystack.contains('unsigned') ||
        haystack.contains('firmado') ||
        haystack.contains('final');
  }

  factory LegalHqDocument.fromJson(Map<String, dynamic> json) {
    return LegalHqDocument(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Documento',
      status: json['status']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      hqReviewDecision: json['hqReviewDecision']?.toString() ?? '',
      mimeType: json['mimeType']?.toString() ?? '',
      originalName: json['originalName']?.toString() ?? '',
      uploadedAt: json['uploadedAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      required_: json['required'] == true,
    );
  }
}

/// Una entrada del "Historial de versiones del contrato".
class LegalHqContractVersion {
  const LegalHqContractVersion({
    required this.tag,
    required this.document,
  });

  /// `V1`, `V2`, … o `VF` para la versión final firmada.
  final String tag;
  final LegalHqDocument document;
}

/// Detalle completo de un expediente.
class LegalHqProcessDetail {
  const LegalHqProcessDetail({
    required this.process,
    required this.documents,
    this.unsignedContractUrl = '',
  });

  final LegalHqProcess process;
  final List<LegalHqDocument> documents;

  /// Borrador de contrato que el asociado dejó en el proceso.
  final String unsignedContractUrl;

  /// Documentos que el HQ audita en la grilla: todo lo que tiene archivo y no
  /// es una versión intermedia del contrato.
  List<LegalHqDocument> get reviewableDocuments => documents
      .where((document) => document.hasFile && !document.isContractVersion)
      .toList();

  /// Historial de versiones del contrato, en orden de subida. La última
  /// versión firmada queda etiquetada como `VF`.
  ///
  /// Nota: el backend **reemplaza** el archivo al re-subir un mismo documento,
  /// así que acá solo aparecen las versiones que existen como documentos
  /// distintos del expediente, no cada re-subida de un mismo slot.
  List<LegalHqContractVersion> get contractVersions {
    final contracts = documents
        .where((document) => document.hasFile && document.isContractVersion)
        .toList()
      ..sort((a, b) => a.sortDate.compareTo(b.sortDate));

    if (contracts.isEmpty) return const [];

    // La firmada cierra el historial aunque no sea la última por fecha.
    final signedIndex = contracts.lastIndexWhere((d) => d.isSignedContract);
    if (signedIndex >= 0 && signedIndex != contracts.length - 1) {
      final signed = contracts.removeAt(signedIndex);
      contracts.add(signed);
    }

    final versions = <LegalHqContractVersion>[];
    for (var i = 0; i < contracts.length; i++) {
      final isLastAndSigned =
          i == contracts.length - 1 && contracts[i].isSignedContract;
      versions.add(LegalHqContractVersion(
        tag: isLastAndSigned ? 'VF' : 'V${i + 1}',
        document: contracts[i],
      ));
    }
    return versions;
  }
}

// ── Acceso a la API ─────────────────────────────────────────────────────────

class LegalHqProcessApi {
  const LegalHqProcessApi._();

  /// Combina la bandeja de asignados con la de libres, sin duplicados.
  static Future<List<LegalHqProcess>> fetchBoth({
    String status = '',
    String category = '',
  }) async {
    final results = await Future.wait([
      fetchAssigned(status: status, category: category),
      fetchUnassigned(status: status, category: category),
    ]);

    final merged = <String, LegalHqProcess>{};
    for (final process in [...results[0], ...results[1]]) {
      merged.putIfAbsent(process.id, () => process);
    }
    return merged.values.toList();
  }

  static Future<List<LegalHqProcess>> fetchAssigned({
    String status = '',
    String category = '',
  }) async {
    final response =
        await DOVIAAPILegalProcessContextGroup.listLegalProcessesHQCall.call(
      authToken: currentAuthenticationToken ?? '',
      status: status,
      category: category,
      page: '1',
      limit: '50',
    );
    return _parseList(response, isAssignedToMe: true);
  }

  static Future<List<LegalHqProcess>> fetchUnassigned({
    String status = '',
    String category = '',
  }) async {
    final response = await DOVIAAPILegalProcessContextGroup
        .listLegalProcessesHQUnassignedCall
        .call(
      authToken: currentAuthenticationToken ?? '',
      status: status,
      category: category,
      page: '1',
      limit: '50',
    );
    return _parseList(response, isAssignedToMe: false);
  }

  /// Reclama el expediente para el HQ autenticado. Devuelve el status HTTP
  /// para poder distinguir el 409 (ya lo tomó otro HQ).
  static Future<ApiCallResponse> accept(String processId) {
    return DOVIAAPILegalProcessContextGroup.acceptLegalHQProcessCall.call(
      processId: processId,
      authToken: currentAuthenticationToken ?? '',
    );
  }

  /// Detalle con el checklist de documentos. Requiere ser el HQ asignado.
  static Future<LegalHqProcessDetail?> fetchDetail(String processId) async {
    final response =
        await DOVIAAPILegalProcessContextGroup.getLegalProcessByIDCall.call(
      processId: processId,
      authToken: currentAuthenticationToken ?? '',
    );

    if (!response.succeeded) return null;

    final data = getJsonField(response.jsonBody, r'$.data');
    if (data is! Map<String, dynamic>) return null;

    final rawDocuments = data['documents'];
    final documents = (rawDocuments is List ? rawDocuments : <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(LegalHqDocument.fromJson)
        .toList();

    return LegalHqProcessDetail(
      // El detalle solo se puede leer siendo el HQ asignado, así que llegar
      // acá implica que el expediente ya es propio.
      process: LegalHqProcess.fromJson(data, isAssignedToMe: true),
      documents: documents,
      unsignedContractUrl: data['unsignedContractUrl']?.toString() ?? '',
    );
  }

  /// Aprueba o rechaza un documento. `status` es `approved` | `rejected`.
  static Future<ApiCallResponse> reviewDocument({
    required String processId,
    required String documentId,
    required String status,
    String note = '',
  }) {
    return DOVIAAPILegalProcessContextGroup.hqReviewDocumentCall.call(
      processId: processId,
      documentId: documentId,
      authToken: currentAuthenticationToken ?? '',
      status: status,
      note: note,
    );
  }

  static List<LegalHqProcess> _parseList(
    ApiCallResponse response, {
    required bool isAssignedToMe,
  }) {
    if (!response.succeeded) return [];

    final raw = getJsonField(response.jsonBody, r'$.data');
    final items = raw is List ? raw : <dynamic>[];

    return items
        .whereType<Map<String, dynamic>>()
        .map((json) =>
            LegalHqProcess.fromJson(json, isAssignedToMe: isAssignedToMe))
        .toList();
  }
}

// ── Etiquetas y colores de estado ───────────────────────────────────────────

class LegalHqStatusStyle {
  const LegalHqStatusStyle(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

// Paleta de badges del diseño.
const Color _badgeYellowBg = Color(0xFFFFF1BC);
const Color _badgeYellowText = Color(0xFFF5A700);
const Color _badgeOrangeBg = Color(0xFFFFE3C6);
const Color _badgeOrangeText = Color(0xFFF57600);
const Color _badgePurpleBg = Color(0xFFD2CCE4);
const Color _badgePurpleText = Color(0xFF0306B4);
const Color _badgeGreenBg = Color(0x1A249689);
const Color _badgeGreenText = Color(0xFF249689);
const Color _badgeRedBg = Color(0xFFFFE0DB);
const Color _badgeRedText = Color(0xFFD92D20);

/// Etiqueta y colores del "Estado actual" que muestra cada tarjeta.
LegalHqStatusStyle legalHqStatusStyle(String status) {
  switch (status) {
    case 'NOT_STARTED':
      return const LegalHqStatusStyle(
          'Pendiente de revisión', _badgeYellowBg, _badgeYellowText);
    case 'IN_PROGRESS':
    case 'DRAFTING':
    case 'MEETING_COORDINATION':
    case 'MEETING_SCHEDULED':
      return const LegalHqStatusStyle(
          'En revisión', _badgeYellowBg, _badgeYellowText);
    case 'LEGAL_HQ_REVIEW':
      return const LegalHqStatusStyle(
          'En Revisión de Legal HQ', _badgeOrangeBg, _badgeOrangeText);
    case 'REJECTED':
      return const LegalHqStatusStyle(
          'Rechazado', _badgeRedBg, _badgeRedText);
    case 'APPROVED':
      return const LegalHqStatusStyle(
          'Aprobado', _badgeGreenBg, _badgeGreenText);
    case 'BANK_MANAGEMENT_STARTED':
      return const LegalHqStatusStyle(
          'Gestión bancaria iniciada', _badgePurpleBg, _badgePurpleText);
    case 'BANK_DOCUMENTATION_SUBMITTED':
      return const LegalHqStatusStyle(
          'Gestión bancaria', _badgePurpleBg, _badgePurpleText);
    case 'BANK_EVALUATION':
      return const LegalHqStatusStyle(
          'En evaluación bancaria', _badgePurpleBg, _badgePurpleText);
    case 'FINISHED':
      return const LegalHqStatusStyle(
          'Finalizado', _badgeGreenBg, _badgeGreenText);
    default:
      return const LegalHqStatusStyle(
          'Pendiente de revisión', _badgeYellowBg, _badgeYellowText);
  }
}

/// "Tipo" de operación que muestra la tarjeta. El backend maneja cuatro
/// categorías; "Promesa de compra" y "Post-venta", que el diseño lista como
/// tipos, todavía no existen como categoría propia del proceso legal.
String legalHqOperationLabel(String category) {
  switch (category) {
    case kCategoryRent:
      return 'Arrendamiento';
    case kCategorySale:
      return 'Compra de contado';
    case kCategoryMortgage:
      return 'Compra con hipoteca';
    case kCategoryPublication:
      return 'Revisión de propiedad';
    default:
      return category.isNotEmpty ? category : 'Proceso legal';
  }
}

/// Estado del documento dentro del expediente: etiqueta y avance (0..5) de la
/// barra segmentada del diseño.
class LegalHqDocumentProgress {
  const LegalHqDocumentProgress(this.label, this.filledSegments);

  final String label;
  final int filledSegments;
}

const int kDocumentProgressSegments = 5;

LegalHqDocumentProgress legalHqDocumentProgress(LegalHqDocument document) {
  if (document.hqReviewDecision == 'approved') {
    return const LegalHqDocumentProgress('Aprobado', 5);
  }
  if (document.hqReviewDecision == 'rejected') {
    return const LegalHqDocumentProgress('Rechazado', 5);
  }
  switch (document.status) {
    case 'missing':
      return const LegalHqDocumentProgress('Pendiente de carga', 1);
    case 'approved':
      // Aprobado por el asociado o el Lister HQ, pero el Legal HQ todavía no
      // toma su decisión: sigue en revisión desde su punto de vista.
      return const LegalHqDocumentProgress('En proceso de revisión', 3);
    case 'rejected':
      return const LegalHqDocumentProgress('Rechazado por revisión previa', 3);
    default:
      return const LegalHqDocumentProgress('En proceso de revisión', 2);
  }
}
