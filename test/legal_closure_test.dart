import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/legal_closure_models.dart';

Map<String, dynamic> _profile({
  String fullName = 'Ana Lopez',
  String? avatar = 'https://cdn/ana.png',
  Map<String, dynamic>? phone = const {
    'countryCode': '+502',
    'number': '55555555',
  },
  String? email = 'ana@dovia.com',
}) =>
    {
      'id': 'user-1',
      'fullName': fullName,
      'avatar': avatar,
      'phone': phone,
      'email': email,
    };

Map<String, dynamic> _document({
  String label = 'Copia de Contratos',
  String? url = 'https://cdn/contrato.pdf',
  String status = 'approved',
}) =>
    {
      'id': 'doc-1',
      'kind': 'SYSTEM',
      'type': 'CONTRACT_COPY',
      'label': label,
      'required': true,
      'status': status,
      'url': url,
    };

void main() {
  group('Profesionales del cierre', () {
    test('arma las dos tarjetas, el asociado primero', () {
      final closure = LegalProcessClosure.fromJson({
        'legalAssociateProfile': _profile(fullName: 'Ana Lopez'),
        'legalHqProfile': _profile(fullName: 'Luis Ruiz'),
        'documents': const [],
      });

      expect(
        closure.professionals.map((p) => p.role),
        [
          LegalProfessionalRole.legalAssociate,
          LegalProfessionalRole.legalOfficer,
        ],
      );
      expect(closure.professionals.first.fullName, 'Ana Lopez');
      expect(closure.professionals.last.fullName, 'Luis Ruiz');
    });

    test('junta el código de país con el número para el contacto rápido', () {
      final closure = LegalProcessClosure.fromJson({
        'legalAssociateProfile': _profile(),
      });

      expect(closure.professionals.single.phone, '+50255555555');
      expect(closure.professionals.single.hasPhone, isTrue);
      expect(closure.professionals.single.hasEmail, isTrue);
    });

    test('un rol sin asignar no dibuja tarjeta', () {
      final closure = LegalProcessClosure.fromJson({
        'legalAssociateProfile': _profile(),
        'legalHqProfile': null,
      });

      expect(closure.professionals, hasLength(1));
      expect(
        closure.professionals.single.role,
        LegalProfessionalRole.legalAssociate,
      );
    });

    test('sin teléfono ni correo no se ofrece contacto que no lleva a ningún lado',
        () {
      final closure = LegalProcessClosure.fromJson({
        'legalAssociateProfile': _profile(phone: null, email: null),
      });

      expect(closure.professionals.single.hasPhone, isFalse);
      expect(closure.professionals.single.hasEmail, isFalse);
    });

    test('los roles hablan el vocabulario del backend y del diseño', () {
      expect(
        LegalProfessionalRole.legalAssociate.apiValue,
        'LEGAL_ASSOCIATE',
      );
      expect(LegalProfessionalRole.legalOfficer.apiValue, 'LEGAL_OFFICER');
      expect(
        LegalProfessionalRole.legalAssociate.label,
        'Dovia Legal Associate',
      );
      expect(LegalProfessionalRole.legalOfficer.label, 'Dovia legal HQ');
    });
  });

  group('Bóveda de documentos', () {
    test('con archivo aprobado se puede descargar', () {
      final closure = LegalProcessClosure.fromJson({
        'documents': [_document()],
      });

      expect(closure.documents.single.isReady, isTrue);
      expect(closure.documents.single.label, 'Copia de Contratos');
    });

    test('sin archivo todavía queda en reloj', () {
      final closure = LegalProcessClosure.fromJson({
        'documents': [_document(url: null, status: 'missing')],
      });

      expect(closure.documents.single.isReady, isFalse);
    });

    test('un documento rechazado vuelve a estar pendiente para el cliente', () {
      final closure = LegalProcessClosure.fromJson({
        'documents': [_document(status: 'rejected')],
      });

      expect(
        closure.documents.single.isReady,
        isFalse,
        reason: 'lo rechazado se re-sube: no es el archivo final',
      );
    });

    test('mantiene el orden en el que Legal HQ arma el expediente', () {
      final closure = LegalProcessClosure.fromJson({
        'documents': [
          _document(label: 'Copia de Contratos'),
          _document(label: 'Copia de ingreso de inscripción en registro'),
          _document(label: 'Copia de aviso a municipalidad', status: 'missing'),
          _document(label: 'Copia de certificación registro', status: 'missing'),
        ],
      });

      expect(closure.documents.map((d) => d.label), [
        'Copia de Contratos',
        'Copia de ingreso de inscripción en registro',
        'Copia de aviso a municipalidad',
        'Copia de certificación registro',
      ]);
      expect(closure.documents.map((d) => d.isReady), [
        true,
        true,
        false,
        false,
      ]);
    });
  });

  group('Tolerancia al envoltorio de la respuesta', () {
    test('acepta el proceso dentro de `data`', () {
      final closure = LegalProcessClosure.fromJson({
        'data': {
          'legalAssociateProfile': _profile(),
          'documents': [_document()],
        },
      });

      expect(closure.professionals, hasLength(1));
      expect(closure.documents, hasLength(1));
    });

    test('un proceso sin nada devuelve un cierre vacío', () {
      expect(LegalProcessClosure.fromJson(const {}).isEmpty, isTrue);
    });
  });
}
