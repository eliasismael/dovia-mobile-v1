import '/core/amount_input_formatter.dart';

/// Reglas del formulario de publicación (venta, renta o ambas) y el body de
/// `POST /properties/basic`. Sin widgets, para poder probarlo solo.
///
/// Los campos se identifican por una clave (`salePrice`, `owner.age`...). La
/// pantalla guarda los textos y los valores de los desplegables con esa clave
/// y se los pasa a [PublicationInput].

/// A nombre de quién está la propiedad: define qué datos pide el formulario y
/// qué documentos se suben después de crearla.
enum OwnershipKind {
  self('SELF', 'A mi nombre'),
  thirdParty('THIRD_PARTY', 'A nombre de otra persona'),
  company('COMPANY', 'A nombre de una sociedad');

  const OwnershipKind(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static OwnershipKind? fromApi(String? value) {
    for (final kind in values) {
      if (kind.apiValue == value) return kind;
    }
    return null;
  }
}

// Valor de la API -> etiqueta que se muestra. Mismos valores que acepta el
// backend; las etiquetas son las suyas (`ownership.vo.ts`).
const Map<String, String> kRelationshipLabels = {
  'CHILD': 'Hijo(a)',
  'SPOUSE': 'Cónyuge',
  'PARENT': 'Padre o madre',
  'SIBLING': 'Hermano(a)',
  'OTHER_FAMILY_MEMBER': 'Otro familiar',
  'PROPERTY_MANAGER': 'Administrador(a)',
};
const Map<String, String> kMaritalStatusLabels = {
  'SINGLE': 'Soltero(a)',
  'MARRIED': 'Casado(a)',
  'DIVORCED': 'Divorciado(a)',
  'WIDOWED': 'Viudo(a)',
};
const Map<String, String> kIdentificationLabels = {
  'DPI': 'DPI',
  'PASSPORT': 'Pasaporte',
};
const Map<String, String> kSexLabels = {
  'MALE': 'Masculino',
  'FEMALE': 'Femenino',
};

/// Opciones de "Tiempo mínimo" de la renta, en meses (regla de negocio).
const List<int> kRentMinimumMonths = [6, 12, 18, 24];

/// Comisión DOVIA: 3.5% del precio de venta, o una renta mensual, más IVA.
const double kSaleCommissionRate = 0.035;
const double kIvaRate = 0.12;
double saleCommission(double salePrice) =>
    salePrice * kSaleCommissionRate * (1 + kIvaRate);
double rentCommission(double monthlyRent) => monthlyRent * (1 + kIvaRate);

/// Documentos que se suben después de crear la propiedad: clave del campo de
/// archivo en el formulario y `purpose` del presign.
enum OwnershipDocument {
  ownerIdentification(
      'ownerIdFile', 'OWNER_IDENTIFICATION', 'Identificación del propietario'),
  representativeIdentification(
      'repIdFile',
      'LEGAL_REPRESENTATIVE_IDENTIFICATION',
      'Identificación del representante legal'),
  appointmentCertificate('apptFile', 'NOTARIZED_APPOINTMENT_CERTIFICATE',
      'Acta notarial de nombramiento');

  const OwnershipDocument(this.field, this.purpose, this.label);
  final String field;
  final String purpose;
  final String label;

  static List<OwnershipDocument> requiredFor(OwnershipKind kind) =>
      switch (kind) {
        OwnershipKind.self => const [],
        OwnershipKind.thirdParty => const [ownerIdentification],
        OwnershipKind.company => const [
            representativeIdentification,
            appointmentCertificate,
          ],
      };
}

/// Formatos y tamaño que acepta el presign de documentos.
const List<String> kDocumentExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];
const int kMaxDocumentBytes = 10 * 1024 * 1024;

/// Tipo MIME del archivo según su extensión, o null si no se acepta.
String? documentMimeType(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot < 0) return null;
  return switch (filename.substring(dot + 1).toLowerCase()) {
    'pdf' => 'application/pdf',
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => null,
  };
}

/// Todo lo que el usuario cargó en el formulario.
class PublicationInput {
  const PublicationInput({
    required this.sale,
    required this.rent,
    required this.ownership,
    required this.values,
    this.latitude,
    this.longitude,
    this.companyElectronicBook = false,
    this.accountIdentityReady = false,
    this.attachedFiles = const {},
  });

  final bool sale;
  final bool rent;
  final OwnershipKind ownership;

  /// Texto (ya sin espacios a los costados) o valor elegido de cada campo.
  final Map<String, String> values;
  final double? latitude;
  final double? longitude;
  final bool companyElectronicBook;

  /// La cuenta ya tiene nombre e identificación: el backend los toma de ahí
  /// para "A mi nombre" y para quien registra a nombre de otra persona.
  final bool accountIdentityReady;

  /// Claves de los campos de archivo que tienen uno elegido.
  final Set<String> attachedFiles;

  String v(String key) => values[key]?.trim() ?? '';
}

const String _requiredMsg = 'Completá este campo.';

/// Problemas del formulario, campo -> mensaje, en el orden en que aparecen en
/// pantalla (así el primero es el más alto).
Map<String, String> validatePublication(PublicationInput input) {
  final errors = <String, String>{};

  void require(String key) {
    if (input.v(key).isEmpty) errors[key] = _requiredMsg;
  }

  void amount(String key, {required bool isRequired}) {
    final raw = input.v(key);
    if (raw.isEmpty) {
      if (isRequired) errors[key] = _requiredMsg;
      return;
    }
    final value = parseAmount(raw);
    if (value == null) {
      errors[key] = 'Ingresá un número, sin letras ni símbolos.';
    } else if (value < 0) {
      errors[key] = 'No puede ser un número negativo.';
    } else if (isRequired && value == 0) {
      errors[key] = 'Tiene que ser mayor que cero.';
    }
  }

  void positiveInt(String key, String message) {
    final raw = input.v(key);
    if (raw.isEmpty) {
      errors[key] = _requiredMsg;
      return;
    }
    final value = int.tryParse(raw);
    if (value == null || value <= 0) errors[key] = message;
  }

  void date(String key) {
    final raw = input.v(key);
    if (raw.isEmpty) {
      errors[key] = _requiredMsg;
    } else if (!isValidDayMonthYear(raw)) {
      errors[key] = 'Usá el formato DD/MM/AAAA.';
    }
  }

  void file(String key) {
    if (!input.attachedFiles.contains(key)) {
      errors[key] = 'Subí el archivo.';
    }
  }

  void person(String prefix, {required bool named, bool phone = false}) {
    if (named) {
      require('$prefix.fullName');
      require('$prefix.sex');
    }
    positiveInt('$prefix.age', 'Ingresá una edad válida.');
    // Los contratos que arma el backend la necesitan de todos: dueño,
    // quien registra y representante legal.
    require('$prefix.nationality');
    require('$prefix.maritalStatus');
    require('$prefix.idType');
    require('$prefix.idNumber');
    require('$prefix.occupation');
    if (phone) {
      final digits = input.v('$prefix.phone').replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) {
        errors['$prefix.phone'] = _requiredMsg;
      } else if (digits.length < 8) {
        errors['$prefix.phone'] = 'Ingresá un teléfono válido.';
      }
    }
  }

  require('description');

  if (input.sale) {
    amount('salePrice', isRequired: true);
    amount('maintenance', isRequired: false);
    amount('propertyTax', isRequired: false);
  }
  if (input.rent) {
    amount('monthlyRent', isRequired: true);
  }

  require('address');
  require('zone');
  // Sin punto en el mapa la propiedad quedaría sin coordenadas y el operative
  // lister no podría llegar.
  if (input.latitude == null || input.longitude == null) {
    errors['location'] = 'Marcá el punto en el mapa.';
  }

  switch (input.ownership) {
    case OwnershipKind.self:
      if (!input.accountIdentityReady) {
        errors['identity'] = 'Subí tu identificación para continuar.';
      }
      person('me', named: false);
    case OwnershipKind.thirdParty:
      if (!input.accountIdentityReady) {
        errors['identity'] = 'Subí tu identificación para continuar.';
      }
      person('me', named: false);
      require('relationship');
      person('owner', named: true, phone: true);
      file(OwnershipDocument.ownerIdentification.field);
    case OwnershipKind.company:
      require('company.name');
      require('company.regNumber');
      require('company.regFolio');
      require('company.regBook');
      person('rep', named: true);
      file(OwnershipDocument.representativeIdentification.field);
      require('appt.city');
      date('appt.date');
      require('appt.notary');
      require('appt.regNumber');
      require('appt.regFolio');
      require('appt.regBook');
      date('appt.regDate');
      positiveInt('appt.termYears', 'Ingresá un número de años válido.');
      file(OwnershipDocument.appointmentCertificate.field);
  }

  return errors;
}

/// `true` si [text] es una fecha real con el formato DD/MM/AAAA.
bool isValidDayMonthYear(String text) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
  if (match == null) return false;
  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final date = DateTime.utc(year, month, day);
  return year > 0 &&
      date.year == year &&
      date.month == month &&
      date.day == day;
}

/// Teléfono con código de país: si no lo trae, se asume Guatemala (+502).
String normalizePhone(String text) {
  final compact = text.replaceAll(RegExp(r'[^\d+]'), '');
  return compact.startsWith('+') ? compact : '+502$compact';
}

/// Body de `POST /properties/basic`. Llamar solo con un [input] que pasó
/// [validatePublication]. No lleva `country` (lo pone el backend) ni datos de
/// otra variante de titularidad: el backend rechaza claves de más.
Map<String, dynamic> buildCreatePropertyBody(PublicationInput input) {
  String? optional(String key) {
    final value = input.v(key);
    return value.isEmpty ? null : value;
  }

  int? optionalInt(String key) => parseAmount(input.v(key))?.round();

  Map<String, dynamic> personal(String prefix,
      {required bool named, bool phone = false}) {
    final nit = optional('$prefix.nit');
    return {
      if (named) 'fullName': input.v('$prefix.fullName'),
      if (named) 'sex': input.v('$prefix.sex'),
      'age': int.parse(input.v('$prefix.age')),
      'nationality': input.v('$prefix.nationality'),
      'maritalStatus': input.v('$prefix.maritalStatus'),
      'identification': {
        'type': input.v('$prefix.idType'),
        'number': input.v('$prefix.idNumber'),
      },
      'occupation': input.v('$prefix.occupation'),
      if (nit != null) 'nit': nit,
      if (phone) 'phone': normalizePhone(input.v('$prefix.phone')),
    };
  }

  Map<String, dynamic> ownership() {
    switch (input.ownership) {
      case OwnershipKind.self:
        return {
          'type': OwnershipKind.self.apiValue,
          'owner': personal('me', named: false),
        };
      case OwnershipKind.thirdParty:
        return {
          'type': OwnershipKind.thirdParty.apiValue,
          'relationshipToOwner': input.v('relationship'),
          'submitter': personal('me', named: false),
          'owner': personal('owner', named: true, phone: true),
        };
      case OwnershipKind.company:
        final companyNit = optional('company.nit');
        return {
          'type': OwnershipKind.company.apiValue,
          'company': {
            'name': input.v('company.name'),
            if (companyNit != null) 'nit': companyNit,
            'commercialRegistry': {
              'number': input.v('company.regNumber'),
              'folio': input.v('company.regFolio'),
              'book': input.v('company.regBook'),
              'isElectronicBook': input.companyElectronicBook,
            },
          },
          'legalRepresentative': personal('rep', named: true),
          'legalRepresentativeAppointment': {
            'notarialAct': {
              'city': input.v('appt.city'),
              'date': input.v('appt.date'),
              'notaryName': input.v('appt.notary'),
            },
            'commercialRegistry': {
              'number': input.v('appt.regNumber'),
              'folio': input.v('appt.regFolio'),
              'book': input.v('appt.regBook'),
              'registrationDate': input.v('appt.regDate'),
            },
            'termYears': int.parse(input.v('appt.termYears')),
          },
        };
    }
  }

  final legalInfo = {
    for (final key in ['finca', 'folio', 'libro'])
      if (optional(key) != null) key: optional(key),
  };
  final minimumTime = int.tryParse(input.v('minimumTime'));
  final rentOthers = optional('rentOthers');
  final maintenance = optionalInt('maintenance');
  final propertyTax = optionalInt('propertyTax');

  return {
    'listingType': [if (input.sale) 'SALE', if (input.rent) 'RENT'],
    'name': input.v('description'),
    'address': input.v('address'),
    'zone': input.v('zone'),
    'geoLocation': {
      'longitude': input.longitude,
      'latitude': input.latitude,
    },
    if (legalInfo.isNotEmpty) 'legalInfo': legalInfo,
    if (input.sale)
      'saleInfo': {
        'salePrice': optionalInt('salePrice'),
        if (maintenance != null) 'maintenanceFee': maintenance,
        if (propertyTax != null) 'singlePropertyTax': propertyTax,
      },
    if (input.rent)
      'rentInfo': {
        'monthlyRent': parseAmount(input.v('monthlyRent')),
        if (minimumTime != null || rentOthers != null)
          'rentalConditions': {
            if (minimumTime != null) 'minimumTime': minimumTime,
            if (rentOthers != null) 'others': rentOthers,
          },
      },
    'ownership': ownership(),
  };
}
