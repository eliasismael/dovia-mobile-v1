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
      final submitter = _map(ownership['submitter']);
      return OwnershipView(
        typeLabel: typeLabel,
        ownerName: _or(_str(owner['fullName']), accountName),
        relationship: _str(_map(ownership['relationshipToOwner'])['label']),
        documents: [
          (
            name: '${_idName(owner)} del propietario',
            url: _str(owner['identificationDocumentUrl'])
          ),
          (
            name: '${_idName(submitter)} de quien registra',
            url: _str(submitter['identificationDocumentUrl'])
          ),
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
            name: '${_idName(rep)} del representante legal',
            url: _str(rep['identificationDocumentUrl'])
          ),
          (
            name: 'Acta notarial de nombramiento',
            url: _str(rep['notarizedAppointmentCertificate'])
          ),
        ],
      );
    default:
      return OwnershipView(
        typeLabel: typeLabel,
        ownerName: _or(_str(owner['fullName']), accountName),
        documents: [
          (
            name: '${_idName(owner)} del propietario',
            url: _str(owner['identificationDocumentUrl'])
          ),
        ],
      );
  }
}

/// Bloque de datos del dueño para la ficha de Listing HQ.
typedef OwnershipSection = ({String title, List<(String, String)> rows});

/// Todos los datos que cargó quien publicó, agrupados como en el registro:
/// - a mi nombre: los datos del titular;
/// - a nombre de otra persona: los del propietario y los de quien registra;
/// - a nombre de una sociedad: la sociedad, su inscripción, el representante
///   legal, el acta notarial y la inscripción del nombramiento.
///
/// Vacío en el formato viejo, que solo tiene el nombre. Las filas sin valor
/// se dejan igual: la pantalla las salta.
List<OwnershipSection> ownershipSections(
  dynamic ownership, {
  String accountName = '',
}) {
  if (!isClassifiedOwnership(ownership)) return const [];
  final type = _str((ownership as Map)['type']['value']);
  final owner = _map(ownership['owner']);

  switch (type) {
    case 'THIRD_PARTY':
      return [
        (
          title: 'Datos del propietario',
          rows: [
            ('Nombre completo', _str(owner['fullName'])),
            ('Sexo', _label(owner['sex'])),
            ..._personRows(owner),
            ('Teléfono', _str(owner['phone'])),
          ],
        ),
        (
          title: 'Datos de quien registra',
          rows: [
            (
              'Relación con el propietario',
              _label(ownership['relationshipToOwner'])
            ),
            ('Nombre', accountName),
            ..._personRows(_map(ownership['submitter'])),
          ],
        ),
      ];
    case 'COMPANY':
      final company = _map(ownership['company']);
      final companyRegistry = _map(company['commercialRegistry']);
      final rep = _map(ownership['legalRepresentative']);
      final appointment = _map(ownership['legalRepresentativeAppointment']);
      final act = _map(appointment['notarialAct']);
      final appointmentRegistry = _map(appointment['commercialRegistry']);
      final electronic = companyRegistry['isElectronicBook'];
      return [
        (
          title: 'Datos de la sociedad',
          rows: [
            ('Nombre de la sociedad', _str(company['name'])),
            ('NIT de la sociedad', _str(company['nit'])),
          ],
        ),
        (
          title: 'Inscripción en el Registro Mercantil',
          rows: [
            ('Número', _str(companyRegistry['number'])),
            ('Folio', _str(companyRegistry['folio'])),
            ('Libro', _str(companyRegistry['book'])),
            (
              'Libro electrónico',
              electronic is bool ? (electronic ? 'Sí' : 'No') : ''
            ),
          ],
        ),
        (
          title: 'Representante legal',
          rows: [
            ('Nombre completo', _str(rep['fullName'])),
            ('Sexo', _label(rep['sex'])),
            ..._personRows(rep),
          ],
        ),
        (
          title: 'Acta notarial',
          rows: [
            ('Ciudad', _str(act['city'])),
            ('Fecha', _str(act['date'])),
            ('Nombre del notario', _str(act['notaryName'])),
          ],
        ),
        (
          title: 'Inscripción del nombramiento',
          rows: [
            ('Número', _str(appointmentRegistry['number'])),
            ('Folio', _str(appointmentRegistry['folio'])),
            ('Libro', _str(appointmentRegistry['book'])),
            ('Fecha', _str(appointmentRegistry['registrationDate'])),
            ('Plazo en años', _str(appointment['termYears'])),
          ],
        ),
      ];
    default:
      return [
        (
          title: 'Datos del titular',
          rows: [
            ('Nombre', _or(_str(owner['fullName']), accountName)),
            ..._personRows(owner),
          ],
        ),
      ];
  }
}

/// Datos personales comunes a todos los tipos (`PersonalInput` del backend).
List<(String, String)> _personRows(Map person) {
  final id = _map(person['identification']);
  return [
    ('Edad', _str(person['age'])),
    ('Nacionalidad', _str(person['nationality'])),
    ('Estado civil', _label(person['maritalStatus'])),
    ('Tipo de documento', _label(id['type'])),
    ('Número de documento', _str(id['number'])),
    ('Profesión u oficio', _str(person['occupation'])),
    ('NIT', _str(person['nit'])),
  ];
}

/// "DPI" o "Pasaporte" según el documento que declaró la persona.
String _idName(Map person) =>
    _or(_label(_map(person['identification'])['type']), 'DPI');

/// Etiqueta de un enum del backend (`{ value, label }`), o el valor suelto.
String _label(dynamic v) => v is Map ? _or(_str(v['label']), _str(v['value'])) : _str(v);

String _str(dynamic v) => v == null ? '' : v.toString().trim();
Map _map(dynamic v) => v is Map ? v : const {};
String _or(String a, String b) => a.isNotEmpty ? a : b;
