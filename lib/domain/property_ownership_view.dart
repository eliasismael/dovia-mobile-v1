/// Lectura del dueño de la propiedad (`ownership`) para Listing HQ.
///
/// El backend tiene dos formatos:
/// - viejo: `{ isCompanyOwned, companyName, legalRepresentative }`;
/// - nuevo (registro de inmueble de oct-2026, `ownership.vo.ts`):
///   `{ type: { value: SELF | THIRD_PARTY | COMPANY, label }, owner, company,
///   legalRepresentative, ... }`.
///
/// El detalle de la visita solo trae `type` del formato nuevo; los nombres y
/// documentos vienen en `GET /properties/{id}/backoffice`.
class OwnershipView {
  const OwnershipView({
    this.typeLabel = '',
    required this.ownerName,
    this.representative = '',
    this.relationship = '',
    this.documents = const [],
  });

  /// "A mi nombre", "A nombre de otra persona"... Vacío en el formato viejo.
  final String typeLabel;
  final String ownerName;

  /// Representante legal, solo si es de una sociedad.
  final String representative;

  /// Relación de quien publicó con el dueño ("Hijo(a)"...), si es de otra persona.
  final String relationship;

  /// Documentos del dueño del formato nuevo (la URL puede venir vacía).
  final List<({String name, String url})> documents;
}

/// `true` si [ownership] tiene el formato nuevo (con `type`).
bool isClassifiedOwnership(dynamic ownership) =>
    ownership is Map && ownership['type'] is Map;

/// Arma lo que muestra Listing HQ. [accountName] es el nombre de quien publicó:
/// se usa cuando el dueño es él mismo o cuando no hay más datos.
OwnershipView ownershipView(dynamic ownership, {String accountName = ''}) {
  if (ownership is! Map) return OwnershipView(ownerName: accountName);

  if (!isClassifiedOwnership(ownership)) {
    if (ownership['isCompanyOwned'] == true) {
      return OwnershipView(
        ownerName: '${_str(ownership['companyName'])} (empresa)',
        representative: _str(ownership['legalRepresentative']),
      );
    }
    return OwnershipView(ownerName: accountName);
  }

  final type = ownership['type'] as Map;
  final typeLabel = _str(type['label']);
  final owner = _map(ownership['owner']);
  switch (_str(type['value'])) {
    case 'THIRD_PARTY':
      return OwnershipView(
        typeLabel: typeLabel,
        ownerName: _or(_str(owner['fullName']), accountName),
        relationship: _str(_map(ownership['relationshipToOwner'])['label']),
        documents: [
          (name: 'DPI del dueño', url: _str(owner['identificationDocumentUrl'])),
        ],
      );
    case 'COMPANY':
      final company = _str(_map(ownership['company'])['name']);
      final rep = _map(ownership['legalRepresentative']);
      return OwnershipView(
        typeLabel: typeLabel,
        ownerName: company.isEmpty ? accountName : '$company (empresa)',
        representative: _str(rep['fullName']),
        documents: [
          (
            name: 'DPI del representante legal',
            url: _str(rep['identificationDocumentUrl'])
          ),
          (
            name: 'Nombramiento del representante',
            url: _str(rep['notarizedAppointmentCertificate'])
          ),
        ],
      );
    default:
      return OwnershipView(
        typeLabel: typeLabel,
        ownerName: _or(_str(owner['fullName']), accountName),
      );
  }
}

String _str(dynamic v) => v == null ? '' : v.toString().trim();
Map _map(dynamic v) => v is Map ? v : const {};
String _or(String a, String b) => a.isNotEmpty ? a : b;
