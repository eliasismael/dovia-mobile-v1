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
import '/backend/api_requests/api_offers.dart';
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

/// Los seis slots que `POST /mortgage/documents/complete` exige con archivo
/// antes de habilitar cualquier transición de estado. El orden es el de la
/// documentación del backend.
const List<String> kMortgageRequiredDocumentTypes = [
  'OWNER_CLIENT_ID_DOCUMENT',
  'INTERESTED_CLIENT_ID_DOCUMENT',
  'OWNER_ID_DOCUMENT',
  'PROPERTY_CERTIFICATION',
  'DOVIA_AGREEMENT_UNSIGNED',
  'DOVIA_AGREEMENT_SIGNED',
];

/// Etiquetas visibles de los slots obligatorios, para poder decirle al HQ qué
/// le falta en vez de mostrarle el nombre técnico.
const Map<String, String> kMortgageRequiredDocumentLabels = {
  'OWNER_CLIENT_ID_DOCUMENT': 'Identificación del propietario',
  'INTERESTED_CLIENT_ID_DOCUMENT': 'Identificación del comprador',
  'OWNER_ID_DOCUMENT': 'Documento de identidad del titular',
  'PROPERTY_CERTIFICATION': 'Certificación de la propiedad',
  'DOVIA_AGREEMENT_UNSIGNED': 'Convenio de DOVIA sin firmar',
  'DOVIA_AGREEMENT_SIGNED': 'Convenio de DOVIA firmado',
};

const Set<String> kMortgageStatuses = {
  'BANK_MANAGEMENT_STARTED',
  'BANK_DOCUMENTATION_SUBMITTED',
  'BANK_EVALUATION',
};

// ── Modelo ──────────────────────────────────────────────────────────────────

/// Una transición del historial append-only que devuelve el detalle en
/// `stateHistory`. Cada llamada a `mortgage/status` agrega una entrada.
class LegalHqStatusChange {
  const LegalHqStatusChange({
    this.fromStatus = '',
    this.toStatus = '',
    this.note = '',
    this.changedAt = '',
    this.changedBy = '',
  });

  final String fromStatus;
  final String toStatus;

  /// Nota con la que el HQ explicó el cambio. Es el texto que llega al
  /// cliente y, en el rechazo, el motivo que pinta el banner rojo.
  final String note;

  final String changedAt;
  final String changedBy;

  factory LegalHqStatusChange.fromJson(Map<String, dynamic> json) =>
      LegalHqStatusChange(
        fromStatus: json['fromStatus']?.toString() ?? '',
        toStatus: json['toStatus']?.toString() ?? '',
        note: json['note']?.toString() ?? '',
        changedAt: json['changedAt']?.toString() ?? '',
        changedBy: json['changedBy']?.toString() ?? '',
      );

  static List<LegalHqStatusChange> listFromJson(dynamic raw) =>
      (raw is List ? raw : const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LegalHqStatusChange.fromJson)
          .toList();
}

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
    this.updatedAt = '',
    this.ownerName = '',
    this.clientName = '',
    this.legalAssociateName = '',
    this.documentsComplete = false,
    this.latestStatusNote = '',
    this.latestStatusUpdatedAt = '',
    this.closedAt = '',
    this.stateHistory = const [],
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

  /// Última modificación del expediente. Es lo más cercano que expone el
  /// backend a la fecha en que se envió la documentación al banco.
  final String updatedAt;

  final String ownerName;
  final String clientName;
  final String legalAssociateName;

  /// Confirmación documental irreversible del flujo hipotecario. Mientras sea
  /// `false`, `mortgage/status` rechaza cualquier transición.
  final bool documentsComplete;

  /// Última nota del historial y su fecha: es lo que el backend expone como
  /// "última actualización" del trámite bancario.
  final String latestStatusNote;
  final String latestStatusUpdatedAt;

  /// Informado solo en `REJECTED` y `FINISHED`; `null` en los intermedios y en
  /// `APPROVED`, que sigue abierto.
  final String closedAt;

  /// Historial append-only de transiciones del expediente.
  final List<LegalHqStatusChange> stateHistory;

  /// `true` cuando el expediente ya está cerrado y no admite más acciones.
  bool get isClosed => closedAt.isNotEmpty;

  /// Fecha de la última novedad del trámite. Cae a `updatedAt` solo mientras
  /// no haya ninguna transición registrada.
  String get lastActivityAt =>
      latestStatusUpdatedAt.isNotEmpty ? latestStatusUpdatedAt : updatedAt;

  /// Fecha en que el expediente entró a [status], leída del historial. Permite
  /// fechar un hito concreto en vez de usar el `updatedAt` del expediente, que
  /// se mueve con cualquier cambio posterior.
  String statusReachedAt(String status) {
    for (final change in stateHistory.reversed) {
      if (change.toStatus == status) return change.changedAt;
    }
    return '';
  }

  /// Motivo con el que el banco rechazó el crédito: la nota de la transición a
  /// `REJECTED`. Es lo que ve el cliente.
  String get rejectionNote {
    for (final change in stateHistory.reversed) {
      if (change.toStatus == 'REJECTED' && change.note.isNotEmpty) {
        return change.note;
      }
    }
    // El historial puede venir recortado; en un expediente ya rechazado la
    // última nota es, por definición, la del rechazo.
    return status == 'REJECTED' ? latestStatusNote : '';
  }

  /// Motivos en forma de lista, que es como los pinta el banner de rechazo.
  List<String> get rejectionReasons => rejectionNote
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

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
      // `operationType` distingue contado y promesa de compra; `category`
      // queda para respuestas que todavía no lo mandan.
      category: (json['operationType'] ?? json['category'])?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      isAssignedToMe: isAssignedToMe,
      hasLegalAssociate:
          (json['legalAssociateId']?.toString() ?? '').isNotEmpty,
      address: property['fullAddress']?.toString() ?? '',
      propertyName: property['name']?.toString() ?? '',
      imageUrl: property['image']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      ownerName: _profileName(json['ownerProfile']),
      clientName: _profileName(json['interestedProfile']),
      legalAssociateName: _profileName(json['legalAssociateProfile']),
      documentsComplete: json['documentsComplete'] == true,
      latestStatusNote: json['latestStatusNote']?.toString() ?? '',
      latestStatusUpdatedAt: json['latestStatusUpdatedAt']?.toString() ?? '',
      closedAt: json['closedAt']?.toString() ?? '',
      stateHistory: LegalHqStatusChange.listFromJson(json['stateHistory']),
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

/// Datos de contacto de una de las partes. El Legal HQ los ve completos y sin
/// enmascarar, porque necesita llamar al cliente y al propietario cuando el
/// convenio no se firma.
class LegalHqParty {
  const LegalHqParty({
    this.fullName = '',
    this.gender = '',
    this.nationality = '',
    this.age = '',
    this.phone = '',
  });

  final String fullName;

  /// `MALE` | `FEMALE` | `OTHER`, tal como lo devuelve el backend.
  final String gender;

  final String nationality;
  final String age;

  /// Teléfono ya compuesto: `+57 3001234567`.
  final String phone;

  bool get isEmpty => fullName.isEmpty && phone.isEmpty;

  String get nameLabel => fullName.isNotEmpty ? fullName : 'Sin datos';

  String get genderLabel {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return 'Masculino';
      case 'FEMALE':
        return 'Femenino';
      case 'OTHER':
        return 'Otro';
      default:
        return gender.isNotEmpty ? gender : '—';
    }
  }

  String get nationalityLabel => nationality.isNotEmpty ? nationality : '—';
  String get ageLabel => age.isNotEmpty ? '$age años' : '—';
  String get phoneLabel => phone.isNotEmpty ? phone : '—';

  /// Número listo para `tel:`, sin espacios ni separadores.
  String get dialablePhone => phone.replaceAll(RegExp(r'[^0-9+]'), '');

  factory LegalHqParty.fromJson(dynamic profile) {
    if (profile is! Map) return const LegalHqParty();

    // Los perfiles del proceso legal mandan `fullName` como string, pero
    // `/users/me` lo parte en `{name, lastname}`: aceptamos las dos formas.
    final rawName = profile['fullName'];
    final name = rawName is Map
        ? [rawName['name'], rawName['lastname']]
            .map((part) => part?.toString() ?? '')
            .where((part) => part.isNotEmpty)
            .join(' ')
        : rawName?.toString() ?? '';

    final rawPhone = profile['phone'];
    final phone = rawPhone is Map
        ? [rawPhone['countryCode'], rawPhone['number']]
            .map((part) => part?.toString() ?? '')
            .where((part) => part.isNotEmpty)
            .join(' ')
        : rawPhone?.toString() ?? '';

    return LegalHqParty(
      fullName: name,
      gender: profile['gender']?.toString() ?? '',
      nationality: profile['nationality']?.toString() ?? '',
      age: profile['age']?.toString() ?? '',
      phone: phone,
    );
  }
}

/// Condiciones de la oferta aceptada que originó el expediente: es lo que el
/// acordeón "Acuerdo" muestra en modo lectura.
class LegalHqAgreement {
  const LegalHqAgreement({
    this.paymentMethod = '',
    this.currency = '',
    this.proposedAmount,
    this.downPaymentPercentage,
    this.termMonths,
    this.bankName = '',
  });

  final String paymentMethod;
  final String currency;
  final num? proposedAmount;

  /// Enganche, en porcentaje del monto total.
  final num? downPaymentPercentage;

  /// Plazo en meses pactado con el banco.
  final num? termMonths;

  final String bankName;

  bool get isEmpty =>
      paymentMethod.isEmpty &&
      proposedAmount == null &&
      downPaymentPercentage == null &&
      termMonths == null &&
      bankName.isEmpty;

  String get paymentMethodLabel {
    switch (paymentMethod.toLowerCase()) {
      case 'mortgage':
        return 'Compra con hipoteca';
      case 'cash':
        return 'Compra de contado';
      case 'purchase_promise':
        return 'Promesa de compra';
      default:
        return paymentMethod;
    }
  }

  /// Monto con separador de miles: `Q 1,250,000` o `1,250,000 USD`.
  String get amountLabel {
    final amount = proposedAmount;
    if (amount == null) return '';
    final digits = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return currency.isEmpty || currency.toUpperCase() == 'GTQ'
        ? 'Q $digits'
        : '$digits $currency';
  }

  String get downPaymentLabel => downPaymentPercentage == null
      ? ''
      : '${_trimZeros(downPaymentPercentage!)} %';

  String get termLabel =>
      termMonths == null ? '' : '${_trimZeros(termMonths!)} meses';

  static String _trimZeros(num value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

  /// Lee la oferta, que llega plana o anidada en `activeOfferData` /
  /// `offerData` según el endpoint que la devuelva.
  factory LegalHqAgreement.fromOfferJson(Map<String, dynamic> offer) {
    dynamic pick(String key) {
      for (final source in [
        offer['activeOfferData'],
        offer['offerData'],
        offer,
      ]) {
        if (source is Map && source[key] != null) return source[key];
      }
      return null;
    }

    return LegalHqAgreement(
      paymentMethod: pick('paymentMethod')?.toString() ?? '',
      currency: pick('currency')?.toString() ?? '',
      proposedAmount: _toNum(pick('proposedAmount')),
      downPaymentPercentage: _toNum(pick('downPaymentPercentage')),
      // El plazo hipotecario viaja como tiempo estimado de aprobación; los
      // otros dos nombres son los que usan promesa de compra y arrendamiento.
      termMonths: _toNum(pick('estimatedApprovalTime') ??
          pick('mortgageTermMonths') ??
          pick('promiseTimeMonths')),
      bankName: pick('bankName')?.toString() ?? '',
    );
  }

  static num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

/// Ejecutivo de la entidad financiera que sigue el crédito. Lo carga el Legal
/// HQ al enviar los papeles al banco.
class LegalHqBankAgent {
  const LegalHqBankAgent({
    this.bank = '',
    this.bankAddress = '',
    this.fullName = '',
    this.phone = '',
    this.email = '',
  });

  final String bank;

  /// Sucursal o dirección de la sucursal. Es parte del snapshot del gestor,
  /// no de las condiciones de la oferta.
  final String bankAddress;

  final String fullName;
  final String phone;
  final String email;

  bool get isEmpty =>
      bank.isEmpty && fullName.isEmpty && phone.isEmpty && email.isEmpty;

  /// Etiquetas —las del diseño— de los campos obligatorios que todavía están
  /// vacíos. La sucursal queda afuera: no es un campo del formulario, viene
  /// con el snapshot del backend.
  List<String> get missingFieldLabels => [
        if (bank.trim().isEmpty) 'Banco',
        if (phone.trim().isEmpty) 'Numero de telefono',
        if (fullName.trim().isEmpty) 'Nombre y Apellido',
        if (email.trim().isEmpty) 'Email',
      ];

  /// `true` cuando DOVIA ya tiene a quién contactar para el seguimiento, que
  /// es lo que exige la etapa 2 antes de dejar avanzar el expediente.
  bool get isComplete => missingFieldLabels.isEmpty;

  /// El mismo shape que devuelve el backend en `bankAgentData`, así lo que se
  /// guarda vuelve a entrar por [fromJson] sin una rama aparte.
  Map<String, dynamic> toJson() => {
        'bankName': bank,
        'bankAddress': bankAddress,
        'name': fullName,
        'phone': phone,
        'email': email,
      };

  factory LegalHqBankAgent.fromJson(dynamic json) {
    if (json is! Map) return const LegalHqBankAgent();

    final name = [json['firstName'], json['lastName'], json['name']]
        .map((part) => part?.toString() ?? '')
        .where((part) => part.isNotEmpty)
        .join(' ');

    return LegalHqBankAgent(
      bank: json['bankName']?.toString() ?? json['bank']?.toString() ?? '',
      bankAddress: json['bankAddress']?.toString() ?? '',
      fullName: name,
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
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

/// Reunión de firma que agenda el asociado legal.
class LegalHqAppointment {
  const LegalHqAppointment({
    required this.id,
    required this.scheduledAt,
    this.address = '',
    this.arrivalInstructions = '',
    this.status = '',
    this.cancelReason = '',
  });

  final String id;
  final DateTime? scheduledAt;
  final String address;
  final String arrivalInstructions;

  /// `SCHEDULED` | `COMPLETED` | `CANCELLED` | `RESCHEDULED`
  final String status;
  final String cancelReason;

  factory LegalHqAppointment.fromJson(Map<String, dynamic> json) =>
      LegalHqAppointment(
        id: json['id']?.toString() ?? '',
        scheduledAt:
            DateTime.tryParse(json['scheduledAt']?.toString() ?? '')?.toLocal(),
        address: json['address']?.toString() ?? '',
        arrivalInstructions: json['arrivalInstructions']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        cancelReason: json['cancelReason']?.toString() ?? '',
      );
}

/// Detalle completo de un expediente.
class LegalHqProcessDetail {
  const LegalHqProcessDetail({
    required this.process,
    required this.documents,
    this.unsignedContractUrl = '',
    this.paymentProofUrl = '',
    this.offerId = '',
    this.agreement = const LegalHqAgreement(),
    this.bankAgent = const LegalHqBankAgent(),
    this.owner = const LegalHqParty(),
    this.client = const LegalHqParty(),
    this.appointments = const [],
    this.unsignedContractName = '',
    this.meetingNotes = '',
  });

  /// Nombre original del contrato sin firmar (`unsignedContractDetail`).
  final String unsignedContractName;

  /// Notas de la reunión de firma que el asociado envió junto con el
  /// contrato firmado al pasar a revisión de HQ.
  final String meetingNotes;

  final LegalHqProcess process;
  final List<LegalHqDocument> documents;

  /// Reuniones de firma, en el orden en que se crearon. Re-agendar deja la
  /// anterior como `RESCHEDULED` y suma una nueva.
  final List<LegalHqAppointment> appointments;

  /// Reunión vigente (`SCHEDULED`), si hay una.
  LegalHqAppointment? get activeAppointment {
    for (final a in appointments.reversed) {
      if (a.status == 'SCHEDULED') return a;
    }
    return null;
  }

  /// Última dirección usada, para pre-llenar el re-agendamiento.
  String get lastAppointmentAddress =>
      appointments.isEmpty ? '' : appointments.last.address;

  /// Borrador de contrato que el asociado dejó en el proceso.
  final String unsignedContractUrl;

  /// Comprobante con el que el propietario pagó los honorarios de DOVIA,
  /// cuando el backend lo expone suelto en vez de como documento.
  final String paymentProofUrl;

  /// Comprobante de honorarios dentro del checklist. El backend lo crea
  /// siempre con el tipo `DOVIA_PAYMENT_PROOF` al subirlo el comprador.
  LegalHqDocument? get paymentProofDocument =>
      documentOfType('DOVIA_PAYMENT_PROOF');

  /// URL del comprobante, venga como documento del expediente o como campo
  /// suelto del proceso.
  String get paymentProofLink {
    final document = paymentProofDocument;
    if (document != null && document.hasFile) return document.url;
    return paymentProofUrl;
  }

  bool get hasPaymentProof => paymentProofLink.isNotEmpty;

  /// Oferta que originó el expediente. Los datos del gestor bancario se
  /// guardan contra la oferta, no contra el proceso legal.
  final String offerId;

  /// Condiciones pactadas en la oferta que originó el expediente.
  final LegalHqAgreement agreement;

  /// Ejecutivo del banco ya registrado, si el HQ lo cargó antes.
  final LegalHqBankAgent bankAgent;

  /// Contacto completo de las partes.
  final LegalHqParty owner;
  final LegalHqParty client;

  /// Confirmación documental irreversible: mientras sea `false` el expediente
  /// no puede cambiar de estado.
  bool get documentsComplete => process.documentsComplete;

  /// Documento del expediente por tipo de slot.
  LegalHqDocument? documentOfType(String type) {
    for (final document in documents) {
      if (document.type == type) return document;
    }
    return null;
  }

  /// Slot del convenio de DOVIA que carga el Legal HQ. Es un documento de
  /// sistema con tipo estable, así que no hace falta adivinarlo por nombre.
  LegalHqDocument? get doviaAgreementDocument =>
      documentOfType('DOVIA_AGREEMENT_UNSIGNED');

  /// Convenio ya firmado. **Lo sube el comprador** desde la oferta
  /// (`POST /offers/{offerId}/dovia-agreement`), no el Legal HQ.
  LegalHqDocument? get doviaAgreementSignedDocument =>
      documentOfType('DOVIA_AGREEMENT_SIGNED');

  /// `true` cuando el HQ ya adjuntó el convenio sin firmar.
  bool get hasDoviaAgreement => doviaAgreementDocument?.hasFile ?? false;

  /// `true` cuando el comprador ya devolvió el convenio firmado.
  bool get hasSignedDoviaAgreement =>
      doviaAgreementSignedDocument?.hasFile ?? false;

  /// Punto del ciclo del convenio, que es lo que anuncia su tarjeta en la
  /// grilla. Son dos slots distintos —el que sube el HQ y el que devuelve
  /// firmado el comprador— pero una sola tarjeta para el que audita.
  LegalHqAgreementState get doviaAgreementState {
    if (hasSignedDoviaAgreement) return LegalHqAgreementState.signed;
    if (hasDoviaAgreement) return LegalHqAgreementState.awaitingSignature;
    return LegalHqAgreementState.pending;
  }

  /// Archivo que abre la tarjeta del convenio: la versión firmada manda,
  /// porque es la que cierra la auditoría.
  LegalHqDocument? get doviaAgreementCardDocument =>
      doviaAgreementSignedDocument?.hasFile ?? false
          ? doviaAgreementSignedDocument
          : doviaAgreementDocument;

  /// Slots obligatorios que todavía no tienen archivo, con su etiqueta
  /// visible. Vacío significa que `documents/complete` va a pasar.
  List<String> get missingRequiredDocuments => [
        for (final type in kMortgageRequiredDocumentTypes)
          if (!(documentOfType(type)?.hasFile ?? false))
            kMortgageRequiredDocumentLabels[type] ?? type,
      ];

  /// `true` cuando están los seis obligatorios y se puede confirmar el
  /// expediente para habilitar las transiciones de estado.
  bool get canCompleteDocuments => missingRequiredDocuments.isEmpty;

  /// Comprobantes que el HQ audita antes de generar el convenio: copias de
  /// contratos, depósitos a la cuenta de DOVIA y demás archivos ya cargados.
  ///
  /// Los dos slots del convenio quedan fuera: viven en su propia tarjeta, que
  /// habla del ciclo completo en vez de repetirlo como dos archivos sueltos.
  List<LegalHqDocument> mortgageEvidenceDocuments() {
    final agreementIds = {
      doviaAgreementDocument?.id,
      doviaAgreementSignedDocument?.id,
    }..remove(null);
    return documents
        .where((document) =>
            document.hasFile && !agreementIds.contains(document.id))
        .toList();
  }

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

    var offer = data['offer'] is Map<String, dynamic>
        ? data['offer'] as Map<String, dynamic>
        : null;
    final offerId =
        data['offerId']?.toString() ?? offer?['id']?.toString() ?? '';

    // El detalle no siempre trae la oferta embebida; cuando solo llega el id
    // hay que pedirla aparte para poder mostrar el acuerdo y el gestor.
    if (offer == null && offerId.isNotEmpty) {
      offer = await _fetchOffer(offerId);
    }

    return LegalHqProcessDetail(
      // El detalle solo se puede leer siendo el HQ asignado, así que llegar
      // acá implica que el expediente ya es propio.
      process: LegalHqProcess.fromJson(data, isAssignedToMe: true),
      documents: documents,
      unsignedContractUrl: data['unsignedContractUrl']?.toString() ?? '',
      paymentProofUrl:
          (data['paymentProofUrl'] ?? data['paymentProof'])?.toString() ?? '',
      offerId: offerId,
      agreement: offer == null
          ? const LegalHqAgreement()
          : LegalHqAgreement.fromOfferJson(offer),
      // El gestor bancario es un snapshot del propio expediente: llega con el
      // evento que lo crea, no se lee de la oferta.
      bankAgent: LegalHqBankAgent.fromJson(data['bankAgentData']),
      owner: LegalHqParty.fromJson(data['ownerProfile']),
      client: LegalHqParty.fromJson(data['interestedProfile']),
      appointments: [
        for (final raw in data['appointments'] is List
            ? data['appointments'] as List
            : const [])
          if (raw is Map<String, dynamic>) LegalHqAppointment.fromJson(raw),
      ],
      unsignedContractName: data['unsignedContractDetail'] is Map
          ? (data['unsignedContractDetail'] as Map)['originalName']
                  ?.toString() ??
              ''
          : '',
      meetingNotes: data['meetingNotes']?.toString() ?? '',
    );
  }

  /// Las condiciones pactadas y el gestor bancario viven en la oferta, no en
  /// el proceso legal.
  static Future<Map<String, dynamic>?> _fetchOffer(String offerId) async {
    final response = await DOVIAAPIOfferContextGroup.getOfferByIDCall.call(
      offerId: offerId,
      authToken: currentAuthenticationToken ?? '',
    );
    if (!response.succeeded) return null;

    final data = getJsonField(response.jsonBody, r'$.data');
    return data is Map<String, dynamic> ? data : null;
  }

  /// Adjunta el convenio de DOVIA sin firmar. Escribe el slot de sistema
  /// `DOVIA_AGREEMENT_UNSIGNED`, asi que reemplaza el archivo si ya existia.
  ///
  /// Solo se acepta antes de confirmar los documentos: despues del freeze el
  /// backend rechaza la carga.
  static Future<ApiCallResponse> uploadDoviaAgreement({
    required String processId,
    required FFUploadedFile file,
  }) {
    return DOVIAAPILegalProcessContextGroup.mortgageUploadUnsignedAgreementCall
        .call(
      processId: processId,
      authToken: currentAuthenticationToken ?? '',
      file: file,
    );
  }

  /// Confirma los seis documentos obligatorios del expediente.
  ///
  /// Es **irreversible** y es la precondicion de cualquier cambio de estado:
  /// sin esto `mortgage/status` devuelve 400.
  static Future<ApiCallResponse> completeMortgageDocuments(String processId) {
    return DOVIAAPILegalProcessContextGroup.mortgageCompleteDocumentsCall.call(
      processId: processId,
      authToken: currentAuthenticationToken ?? '',
    );
  }

  /// Unica transicion del flujo hipotecario. `status` es uno de
  /// `BANK_MANAGEMENT_STARTED` | `BANK_DOCUMENTATION_SUBMITTED` |
  /// `BANK_EVALUATION` | `APPROVED` | `REJECTED`, y `note` queda registrada en
  /// `stateHistory` como la novedad que ve el cliente.
  ///
  /// El backend rechaza repetir el estado actual y no acepta `FINISHED`.
  static Future<ApiCallResponse> updateMortgageStatus({
    required String processId,
    required String status,
    String note = '',
  }) {
    return DOVIAAPILegalProcessContextGroup.mortgageUpdateStatusCall.call(
      processId: processId,
      authToken: currentAuthenticationToken ?? '',
      status: status,
      note: note,
    );
  }

  /// Cierra la venta exitosa: `APPROVED -> FINISHED`.
  ///
  /// El backend completa la oferta y pone la propiedad en `SOLD`, lo que
  /// ademas auto-rechaza las otras ofertas pendientes. No hay que tocar la
  /// propiedad por separado.
  static Future<ApiCallResponse> finishMortgageProcess(String processId) {
    return DOVIAAPILegalProcessContextGroup.mortgageFinishCall.call(
      processId: processId,
      authToken: currentAuthenticationToken ?? '',
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

// Estados con el estilo del cliente: color sólido y el texto en blanco.
const Color _badgeYellowBg = Color(0xFFF5A700);
const Color _badgeYellowText = Colors.white;
const Color _badgeOrangeBg = Color(0xFFF57600);
const Color _badgeOrangeText = Colors.white;
const Color _badgePurpleBg = Color(0xFF5B4BB7);
const Color _badgePurpleText = Colors.white;
const Color _badgeGreenBg = Color(0xFF249689);
const Color _badgeGreenText = Colors.white;
const Color _badgeRedBg = Color(0xFFD92D20);
const Color _badgeRedText = Colors.white;
const Color _badgeBlueBg = Color(0xFF065EDA);
const Color _badgeBlueText = Colors.white;

/// Etiqueta y colores del "Estado actual" que muestra cada tarjeta.
LegalHqStatusStyle legalHqStatusStyle(String status) {
  switch (status) {
    // Las etapas del Legal Associate se nombran igual que en su pantalla: antes
    // todas decían "En revisión" y parecía que ya le tocaba a Legal HQ.
    case 'NOT_STARTED':
      return const LegalHqStatusStyle(
          'Sin iniciar', _badgeYellowBg, _badgeYellowText);
    case 'IN_PROGRESS':
      return const LegalHqStatusStyle(
          'En documentación', _badgeYellowBg, _badgeYellowText);
    case 'DRAFTING':
      return const LegalHqStatusStyle(
          'En redacción', _badgeYellowBg, _badgeYellowText);
    case 'MEETING_COORDINATION':
      return const LegalHqStatusStyle(
          'Coordinando reunión', _badgeYellowBg, _badgeYellowText);
    case 'MEETING_SCHEDULED':
      return const LegalHqStatusStyle(
          'Reunión agendada', _badgeYellowBg, _badgeYellowText);
    case 'LEGAL_HQ_REVIEW':
      return const LegalHqStatusStyle(
          'Pendiente de tu revisión', _badgeOrangeBg, _badgeOrangeText);
    case 'REJECTED':
      return const LegalHqStatusStyle('Rechazado', _badgeRedBg, _badgeRedText);
    case 'APPROVED':
      return const LegalHqStatusStyle(
          'Aprobado', _badgeGreenBg, _badgeGreenText);
    case 'BANK_MANAGEMENT_STARTED':
      return const LegalHqStatusStyle(
          'Gestión bancaria iniciada', _badgePurpleBg, _badgePurpleText);
    case 'BANK_DOCUMENTATION_SUBMITTED':
      return const LegalHqStatusStyle(
          'Documentación enviada al banco', _badgeBlueBg, _badgeBlueText);
    case 'BANK_EVALUATION':
      // Naranja, como el diseño de la etapa 3: es lo que la distingue de la
      // gestión bancaria iniciada, que también es morada.
      return const LegalHqStatusStyle(
          'En evaluación bancaria', _badgeOrangeBg, _badgeOrangeText);
    case 'FINISHED':
      return const LegalHqStatusStyle(
          'Finalizado', _badgeGreenBg, _badgeGreenText);
    default:
      return const LegalHqStatusStyle(
          'Pendiente de revisión', _badgeYellowBg, _badgeYellowText);
  }
}

/// "Tipo" de operación que muestra la tarjeta. "Post-venta" no es una
/// operación del backend: es una compraventa ya finalizada.
String legalHqOperationLabel(String category, [String status = '']) {
  if (status == 'FINISHED' &&
      category != kCategoryPublication &&
      category != kCategoryRent) {
    return 'Post-venta';
  }
  switch (category) {
    case kCategoryRent:
      return 'Arrendamiento';
    case kCategorySale:
    case 'SALE_CASH':
      return 'Compra de contado';
    case 'SALE_PURCHASE_PROMISE':
      return 'Promesa de compra';
    case kCategoryMortgage:
      return 'Compra con hipoteca';
    case kCategoryPublication:
      return 'Revisión de propiedad (pre-publicación)';
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
  // El comprobante de pago a DOVIA no pasa por la revisión de Legal HQ: el
  // backend lo acepta con el proceso ya aprobado y sólo exige que exista para
  // finalizar. Mostrarlo "en revisión" hacía pensar que faltaba aprobarlo.
  if (document.type == 'DOVIA_PAYMENT_PROOF') {
    return document.hasFile
        ? const LegalHqDocumentProgress('Cargado por el cliente', 5)
        : const LegalHqDocumentProgress('Pendiente de carga', 1);
  }
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
      return const LegalHqDocumentProgress('Aprobado por el asociado', 3);
    case 'rejected':
      return const LegalHqDocumentProgress('Rechazado por revisión previa', 3);
    default:
      return const LegalHqDocumentProgress('En proceso de revisión', 2);
  }
}

// ── Gestión bancaria (SALE_MORTGAGE) ────────────────────────────────────────

/// Tramos llenos de un comprobante del expediente hipotecario.
///
/// Este flujo no usa la revisión documental de Legal HQ: sus documentos se
/// miden por DISPONIBILIDAD (`missing` / `submitted`) y nunca llevan
/// `hqReviewDecision`, así que la escala de cinco pasos de
/// [legalHqDocumentProgress] —pensada para el ciclo de revisión— dejaría toda
/// la grilla a media barra. Acá el archivo está o no está.
int legalHqMortgageDocumentSegments(LegalHqDocument document) =>
    document.hasFile ? kDocumentProgressSegments : 1;

/// Estado del convenio de DOVIA tal como lo ve el Legal HQ en la grilla: lo
/// carga él sin firmar, el comprador lo devuelve firmado y recién ahí el
/// expediente puede avanzar.
enum LegalHqAgreementState {
  pending('Convenio debe ser firmado', 1),
  awaitingSignature('Convenio cargado, falta la firma', 3),
  signed('Convenio firmado', kDocumentProgressSegments);

  const LegalHqAgreementState(this.label, this.filledSegments);

  /// Texto de la tarjeta.
  final String label;

  /// Tramos llenos de la barra segmentada.
  final int filledSegments;
}

/// Pasos del stepper "Proceso de Documentación" del expediente hipotecario.
const List<String> kMortgageStepLabels = [
  'Gestión bancaria iniciada',
  'Documentación',
  'En evaluación bancaria',
];

/// Nota con la que el gestor bancario viaja al historial del expediente.
///
/// Es el único registro de servidor que hoy admite estos datos: el backend
/// expone `bankAgentData` como snapshot de solo lectura —lo escribe el evento
/// `BankAgentDataSubmitted` que crea el expediente hipotecario— y ninguna de
/// las 39 rutas de `legal-processes` lo actualiza. Hasta que exista ese
/// endpoint, `PUT /mortgage/status` deja el contacto en `stateHistory`, que es
/// append-only.
String legalHqBankAgentNote(LegalHqBankAgent agent) => [
      'Documentación entregada al banco.',
      'Gestor bancario: ${agent.fullName}',
      'Banco: ${agent.bank}',
      'Teléfono: ${agent.phone}',
      'Email: ${agent.email}',
    ].join('\n');

/// Fecha en formato DD/MM/AAAA a partir del ISO 8601 del backend. Devuelve ''
/// cuando la fecha no vino o no se puede leer.
String legalHqShortDate(String isoDate) {
  if (isoDate.isEmpty) return '';
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return '';
  final local = parsed.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

/// Paso activo del stepper (1..3) según el estado del expediente.
int legalHqMortgageStep(String status) {
  switch (status) {
    case 'BANK_DOCUMENTATION_SUBMITTED':
      return 2;
    case 'BANK_EVALUATION':
    case 'APPROVED':
    case 'FINISHED':
    // El rechazo del banco cierra el trámite en la última etapa, así que el
    // stepper se queda ahí en vez de volver al principio.
    case 'REJECTED':
      return 3;
    default:
      return 1;
  }
}

/// Resolución que el Legal HQ elige en el seguimiento de la evaluación. Cada
/// opción es un `status` real de `PUT /mortgage/status`.
enum LegalHqEvaluationOutcome {
  /// El trámite sigue abierto en el banco. Es una transición como cualquier
  /// otra: el backend la rechaza si el expediente ya está en `BANK_EVALUATION`,
  /// porque no acepta repetir el estado actual.
  stillEvaluating('Sigue en evaluacion bancaria', 'BANK_EVALUATION'),

  /// El banco aprobó el crédito. No cierra el expediente: habilita la carga
  /// del comprobante y después el cierre con `mortgage/finish`.
  approved('Aceptado', 'APPROVED'),

  /// El banco rechazó el crédito. Cierra el expediente, rechaza la oferta y
  /// deja la propiedad publicada.
  rejected('Rechazado', 'REJECTED');

  const LegalHqEvaluationOutcome(this.label, this.status);

  /// Texto de la opción en el desplegable.
  final String label;

  /// Estado que viaja en `PUT /mortgage/status`.
  final String status;

  /// `true` cuando la elección cierra el ciclo de evaluación bancaria.
  bool get resolvesEvaluation =>
      this != LegalHqEvaluationOutcome.stillEvaluating;
}
