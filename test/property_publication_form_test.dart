import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar/property_publication_form.dart';

/// Lo común a las tres titularidades, completo.
const _base = {
  'description': 'Apartamento en zona 10',
  'salePrice': '1,850,000',
  'monthlyRent': '8,000.50',
  'address': '10 avenida 12-34',
  'zone': 'zona-10',
  'finca': '12',
  'folio': '34',
  'libro': '56',
};

const _me = {
  'me.age': '45',
  'me.maritalStatus': 'MARRIED',
  'me.idType': 'DPI',
  'me.idNumber': '1234567890101',
  'me.occupation': 'Comerciante',
};

const _owner = {
  'relationship': 'CHILD',
  'owner.fullName': 'María López',
  'owner.sex': 'FEMALE',
  'owner.age': '60',
  'owner.nationality': 'Guatemalteca',
  'owner.maritalStatus': 'WIDOWED',
  'owner.idType': 'DPI',
  'owner.idNumber': '9876543210101',
  'owner.occupation': 'Comerciante',
  'owner.phone': '5555 5555',
};

const _company = {
  'company.name': 'Inversiones Altamira, S.A.',
  'company.regNumber': '12345',
  'company.regFolio': '67',
  'company.regBook': '89',
  'rep.fullName': 'Carlos Pérez',
  'rep.sex': 'MALE',
  'rep.age': '45',
  'rep.nationality': 'Guatemalteca',
  'rep.maritalStatus': 'MARRIED',
  'rep.idType': 'PASSPORT',
  'rep.idNumber': 'A123',
  'rep.occupation': 'Abogado',
  'rep.nit': '7654321-0',
  'appt.city': 'Guatemala',
  'appt.date': '15/01/2025',
  'appt.notary': 'Ana García',
  'appt.regNumber': '456',
  'appt.regFolio': '12',
  'appt.regBook': '34',
  'appt.regDate': '20/01/2025',
  'appt.termYears': '3',
};

PublicationInput _input(
  OwnershipKind ownership,
  Map<String, String> values, {
  bool sale = true,
  bool rent = false,
  bool identity = true,
  Set<String> files = const {},
}) =>
    PublicationInput(
      sale: sale,
      rent: rent,
      ownership: ownership,
      values: {..._base, ...values},
      latitude: 14.5995,
      longitude: -90.5069,
      accountIdentityReady: identity,
      attachedFiles: files,
    );

void main() {
  group('validatePublication', () {
    test('a mi nombre completo no tiene errores', () {
      expect(validatePublication(_input(OwnershipKind.self, _me)), isEmpty);
    });

    test('sin identificación en la cuenta no se puede enviar', () {
      final errors =
          validatePublication(_input(OwnershipKind.self, _me, identity: false));
      expect(errors.keys, ['identity']);
    });

    test('pide zona, punto en el mapa y el precio según la operación', () {
      final errors = validatePublication(PublicationInput(
        sale: false,
        rent: true,
        ownership: OwnershipKind.self,
        values: {..._base, ..._me, 'zone': '', 'monthlyRent': ''},
        accountIdentityReady: true,
      ));
      expect(errors.keys, ['monthlyRent', 'zone', 'location']);
    });

    test('a nombre de otra persona exige sus datos y su identificación', () {
      final errors = validatePublication(_input(
        OwnershipKind.thirdParty,
        {..._me, ..._owner, 'owner.phone': '123'},
      ));
      expect(errors, {
        'owner.phone': 'Ingresá un teléfono válido.',
        'ownerIdFile': 'Subí el archivo.',
      });
    });

    test('sociedad completa con sus dos archivos no tiene errores', () {
      expect(
        validatePublication(_input(OwnershipKind.company, _company,
            identity: false, files: {'repIdFile', 'apptFile'})),
        isEmpty,
      );
    });

    test('las fechas del nombramiento tienen que ser reales', () {
      final errors = validatePublication(_input(
        OwnershipKind.company,
        {..._company, 'appt.date': '31/02/2025'},
        files: {'repIdFile', 'apptFile'},
      ));
      expect(errors.keys, ['appt.date']);
    });

    test('finca, folio y libro son opcionales y sin ellos no va legalInfo',
        () {
      final input = _input(OwnershipKind.self,
          {..._me, 'finca': '', 'folio': '', 'libro': ''});
      expect(validatePublication(input), isEmpty);
      expect(buildCreatePropertyBody(input).containsKey('legalInfo'), isFalse);
    });
  });

  group('buildCreatePropertyBody', () {
    test('a mi nombre: owner sin nombre ni documento (los pone el backend)',
        () {
      final body =
          buildCreatePropertyBody(_input(OwnershipKind.self, _me, rent: true));
      expect(body['listingType'], ['SALE', 'RENT']);
      expect(body['zone'], 'zona-10');
      expect(body['saleInfo'], {'salePrice': 1850000});
      expect(body['rentInfo'], {'monthlyRent': 8000.5});
      expect(body['legalInfo'], {'finca': '12', 'folio': '34', 'libro': '56'});
      expect(body['ownership'], {
        'type': 'SELF',
        'owner': {
          'age': 45,
          'maritalStatus': 'MARRIED',
          'identification': {'type': 'DPI', 'number': '1234567890101'},
          'occupation': 'Comerciante',
        },
      });
    });

    test('renta con condiciones manda tiempo mínimo en meses y otros', () {
      final body = buildCreatePropertyBody(_input(
        OwnershipKind.self,
        {..._me, 'minimumTime': '12', 'rentOthers': 'Acepta mascotas'},
        sale: false,
        rent: true,
      ));
      expect(body.containsKey('saleInfo'), isFalse);
      expect(body['rentInfo'], {
        'monthlyRent': 8000.5,
        'rentalConditions': {'minimumTime': 12, 'others': 'Acepta mascotas'},
      });
    });

    test('a nombre de otra persona: submitter, owner con teléfono y relación',
        () {
      final ownership = buildCreatePropertyBody(
          _input(OwnershipKind.thirdParty, {..._me, ..._owner}))['ownership'];
      expect(ownership['type'], 'THIRD_PARTY');
      expect(ownership['relationshipToOwner'], 'CHILD');
      expect(ownership['submitter']['age'], 45);
      expect(ownership['owner'], {
        'fullName': 'María López',
        'sex': 'FEMALE',
        'age': 60,
        'nationality': 'Guatemalteca',
        'maritalStatus': 'WIDOWED',
        'identification': {'type': 'DPI', 'number': '9876543210101'},
        'occupation': 'Comerciante',
        'phone': '+50255555555',
      });
    });

    test('sociedad: empresa, representante y nombramiento, sin datos propios',
        () {
      final ownership = buildCreatePropertyBody(
          _input(OwnershipKind.company, {..._me, ..._company}))['ownership'];
      expect(ownership.keys, [
        'type',
        'company',
        'legalRepresentative',
        'legalRepresentativeAppointment',
      ]);
      expect(ownership['company'], {
        'name': 'Inversiones Altamira, S.A.',
        'commercialRegistry': {
          'number': '12345',
          'folio': '67',
          'book': '89',
          'isElectronicBook': false,
        },
      });
      expect(ownership['legalRepresentative']['nit'], '7654321-0');
      expect(ownership['legalRepresentativeAppointment'], {
        'notarialAct': {
          'city': 'Guatemala',
          'date': '15/01/2025',
          'notaryName': 'Ana García',
        },
        'commercialRegistry': {
          'number': '456',
          'folio': '12',
          'book': '34',
          'registrationDate': '20/01/2025',
        },
        'termYears': 3,
      });
    });
  });

  test('documentos y comisiones', () {
    expect(OwnershipDocument.requiredFor(OwnershipKind.self), isEmpty);
    expect(
      OwnershipDocument.requiredFor(OwnershipKind.company)
          .map((d) => d.purpose),
      [
        'LEGAL_REPRESENTATIVE_IDENTIFICATION',
        'NOTARIZED_APPOINTMENT_CERTIFICATE'
      ],
    );
    expect(documentMimeType('dpi.PDF'), 'application/pdf');
    expect(documentMimeType('foto.heic'), isNull);
    // El ejemplo del diseño: Q1,850,000 -> comisión Q72,520.
    expect(saleCommission(1850000), closeTo(72520, 0.001));
    expect(rentCommission(8000), closeTo(8960, 0.001));
  });
}
