import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/legal_hq/legal_hq_process_data.dart';

void main() {
  group('LegalHqParty', () {
    test('compone el telefono y traduce el sexo', () {
      final party = LegalHqParty.fromJson({
        'fullName': 'Ana Perez',
        'gender': 'FEMALE',
        'nationality': 'Guatemalteca',
        'age': 34,
        'phone': {'countryCode': '+502', 'number': '55512345'},
      });

      expect(party.nameLabel, 'Ana Perez');
      expect(party.genderLabel, 'Femenino');
      expect(party.nationalityLabel, 'Guatemalteca');
      expect(party.ageLabel, '34 años');
      expect(party.phoneLabel, '+502 55512345');
      expect(party.dialablePhone, '+50255512345');
      expect(party.isEmpty, isFalse);
    });

    test('acepta el fullName partido de /users/me', () {
      final party = LegalHqParty.fromJson({
        'fullName': {'name': 'Luis', 'lastname': 'Gomez'},
        'phone': '+502 55598765',
      });

      expect(party.nameLabel, 'Luis Gomez');
      expect(party.phoneLabel, '+502 55598765');
    });

    test('queda vacia cuando el perfil no vino', () {
      const party = LegalHqParty();

      expect(LegalHqParty.fromJson(null).isEmpty, isTrue);
      expect(party.nameLabel, 'Sin datos');
      expect(party.genderLabel, '—');
      expect(party.ageLabel, '—');
      expect(party.dialablePhone, isEmpty);
    });
  });

  group('LegalHqAgreement', () {
    test('lee la oferta hipotecaria anidada en activeOfferData', () {
      final agreement = LegalHqAgreement.fromOfferJson({
        'id': 'oferta-1',
        'activeOfferData': {
          'paymentMethod': 'mortgage',
          'currency': 'USD',
          'proposedAmount': 1250000,
          'downPaymentPercentage': 20,
          'estimatedApprovalTime': 24,
          'bankName': 'Banco Industrial',
        },
      });

      expect(agreement.paymentMethodLabel, 'Compra con hipoteca');
      expect(agreement.amountLabel, r'$ 1,250,000 USD');
      expect(agreement.downPaymentLabel, '20 %');
      expect(agreement.termLabel, '24 meses');
      expect(agreement.bankName, 'Banco Industrial');
      expect(agreement.isEmpty, isFalse);
    });

    test('lee la oferta plana y el plazo de promesa de compra', () {
      final agreement = LegalHqAgreement.fromOfferJson({
        'paymentMethod': 'purchase_promise',
        'proposedAmount': '980000',
        'promiseTimeMonths': '6',
      });

      expect(agreement.paymentMethodLabel, 'Promesa de compra');
      expect(agreement.amountLabel, r'$ 980,000');
      expect(agreement.termLabel, '6 meses');
      expect(agreement.downPaymentLabel, isEmpty);
    });

    test('queda vacia cuando la oferta no trae condiciones', () {
      final agreement = LegalHqAgreement.fromOfferJson({'id': 'oferta-2'});

      expect(agreement.isEmpty, isTrue);
      expect(agreement.amountLabel, isEmpty);
      expect(agreement.termLabel, isEmpty);
    });
  });

  group('LegalHqBankAgent', () {
    test('arma el nombre visible con los campos separados del snapshot', () {
      final agent = LegalHqBankAgent.fromJson({
        'bankName': 'Banco Industrial',
        'bankAddress': 'Sucursal Zona 10, 6a Avenida 15-45',
        'firstName': 'Maria',
        'lastName': 'Del Valle',
        'phone': '+502 55511122',
        'email': 'mjdelvalle@banco.test',
      });

      expect(agent.fullName, 'Maria Del Valle');
      expect(agent.bank, 'Banco Industrial');
      expect(agent.bankAddress, 'Sucursal Zona 10, 6a Avenida 15-45');
      expect(agent.email, 'mjdelvalle@banco.test');
      expect(agent.isEmpty, isFalse);
    });

    test('la sucursal viene del gestor, no de la oferta', () {
      final sinSucursal = LegalHqBankAgent.fromJson({
        'bankName': 'Banco Industrial',
        'firstName': 'Maria',
      });

      expect(sinSucursal.bankAddress, isEmpty);
    });

    test('queda vacio cuando el expediente no trae gestor', () {
      expect(LegalHqBankAgent.fromJson(null).isEmpty, isTrue);
      expect(const LegalHqBankAgent().isEmpty, isTrue);
    });
  });

  group('legalHqShortDate', () {
    test('formatea la fecha de envio como DD/MM/AAAA', () {
      expect(legalHqShortDate('2026-03-07T15:04:05.000Z'), matches(r'^\d{2}/\d{2}/2026$'));
    });

    test('vacia cuando la fecha no vino o no se puede leer', () {
      expect(legalHqShortDate(''), isEmpty);
      expect(legalHqShortDate('no-es-fecha'), isEmpty);
    });
  });

  group('legalHqStatusStyle en gestion bancaria', () {
    test('la etiqueta de la etapa 2 es la del diseño', () {
      final style = legalHqStatusStyle('BANK_DOCUMENTATION_SUBMITTED');

      expect(style.label, 'Documentación enviada al banco');
      expect(style.background, const Color(0xFFCAE0FF));
      expect(style.foreground, const Color(0xFF065EDA));
    });
  });

  group('legalHqMortgageStep', () {
    test('mapea cada estado hipotecario a su paso del stepper', () {
      expect(legalHqMortgageStep('BANK_MANAGEMENT_STARTED'), 1);
      expect(legalHqMortgageStep('BANK_DOCUMENTATION_SUBMITTED'), 2);
      expect(legalHqMortgageStep('BANK_EVALUATION'), 3);
      expect(legalHqMortgageStep('APPROVED'), 3);
      // El rechazo del banco cierra el tramite en la ultima etapa.
      expect(legalHqMortgageStep('REJECTED'), 3);
      // Un expediente que todavía no llegó a la gestión bancaria arranca en 1.
      expect(legalHqMortgageStep('IN_PROGRESS'), 1);
    });
  });

  group('LegalHqEvaluationOutcome', () {
    test('las tres opciones son las del comentario de diseño', () {
      expect(
        LegalHqEvaluationOutcome.values.map((o) => o.label),
        ['Sigue en evaluacion bancaria', 'Aceptado', 'Rechazado'],
      );
    });

    test('cada opcion es un status real de mortgage/status', () {
      expect(LegalHqEvaluationOutcome.stillEvaluating.status,
          'BANK_EVALUATION');
      expect(LegalHqEvaluationOutcome.approved.status, 'APPROVED');
      expect(LegalHqEvaluationOutcome.rejected.status, 'REJECTED');
    });

    test('solo aceptado y rechazado cierran la evaluacion', () {
      expect(LegalHqEvaluationOutcome.stillEvaluating.resolvesEvaluation,
          isFalse);
      expect(LegalHqEvaluationOutcome.approved.resolvesEvaluation, isTrue);
      expect(LegalHqEvaluationOutcome.rejected.resolvesEvaluation, isTrue);
    });
  });

  group('LegalHqProcess.rejectionReasons', () {
    LegalHqProcess withNote(String note) => LegalHqProcess(
          id: 'proceso-1',
          category: kCategoryMortgage,
          status: 'REJECTED',
          propertyId: 'propiedad-1',
          isAssignedToMe: true,
          stateHistory: [
            LegalHqStatusChange(
              fromStatus: 'BANK_EVALUATION',
              toStatus: 'REJECTED',
              note: note,
              changedAt: '2026-08-20T10:00:00.000Z',
            ),
          ],
        );

    test('parte la nota en una lista de motivos', () {
      final process = withNote(
        'Ingresos insuficientes\nHistorial crediticio con mora\n\n  Avalúo bajo  ',
      );

      expect(process.rejectionReasons, [
        'Ingresos insuficientes',
        'Historial crediticio con mora',
        'Avalúo bajo',
      ]);
    });

    test('lista vacia cuando no se registraron motivos', () {
      expect(withNote('').rejectionReasons, isEmpty);
      expect(withNote('   \n  \n').rejectionReasons, isEmpty);
    });

    test('lee el motivo de la transicion a REJECTED del historial', () {
      final process = LegalHqProcess.fromJson(
        {
          'id': 'p1',
          'status': 'REJECTED',
          'stateHistory': [
            {
              'fromStatus': 'BANK_DOCUMENTATION_SUBMITTED',
              'toStatus': 'BANK_EVALUATION',
              'note': 'Expediente en analisis',
              'changedAt': '2026-08-10T10:00:00.000Z',
            },
            {
              'fromStatus': 'BANK_EVALUATION',
              'toStatus': 'REJECTED',
              'note': 'Ingresos insuficientes',
              'changedAt': '2026-08-20T10:00:00.000Z',
            },
          ],
        },
        isAssignedToMe: true,
      );

      expect(process.rejectionReasons, ['Ingresos insuficientes']);
    });

    test('cae a latestStatusNote cuando el historial viene recortado', () {
      final process = LegalHqProcess.fromJson(
        {
          'id': 'p2',
          'status': 'REJECTED',
          'latestStatusNote': 'Avalúo bajo',
        },
        isAssignedToMe: true,
      );

      expect(process.rejectionReasons, ['Avalúo bajo']);
    });

    test('un expediente que no esta rechazado no expone motivos', () {
      final process = LegalHqProcess.fromJson(
        {
          'id': 'p3',
          'status': 'BANK_EVALUATION',
          'latestStatusNote': 'El banco pidio un avaluo adicional',
        },
        isAssignedToMe: true,
      );

      expect(process.rejectionReasons, isEmpty);
    });
  });

  group('LegalHqProcess: historial de estados', () {
    final process = LegalHqProcess.fromJson(
      {
        'id': 'p1',
        'status': 'BANK_EVALUATION',
        'updatedAt': '2026-08-24T09:00:00.000Z',
        'documentsComplete': true,
        'latestStatusUpdatedAt': '2026-08-20T10:00:00.000Z',
        'stateHistory': [
          {
            'fromStatus': 'BANK_MANAGEMENT_STARTED',
            'toStatus': 'BANK_DOCUMENTATION_SUBMITTED',
            'changedAt': '2026-08-12T10:00:00.000Z',
          },
          {
            'fromStatus': 'BANK_DOCUMENTATION_SUBMITTED',
            'toStatus': 'BANK_EVALUATION',
            'changedAt': '2026-08-20T10:00:00.000Z',
          },
        ],
      },
      isAssignedToMe: true,
    );

    test('fecha el hito con el historial y no con updatedAt', () {
      expect(process.statusReachedAt('BANK_DOCUMENTATION_SUBMITTED'),
          '2026-08-12T10:00:00.000Z');
      expect(process.statusReachedAt('APPROVED'), isEmpty);
    });

    test('la ultima novedad usa latestStatusUpdatedAt', () {
      expect(process.lastActivityAt, '2026-08-20T10:00:00.000Z');
    });

    test('sin transiciones cae al updatedAt del expediente', () {
      final sinHistorial = LegalHqProcess.fromJson(
        {'id': 'p2', 'updatedAt': '2026-08-24T09:00:00.000Z'},
        isAssignedToMe: true,
      );

      expect(sinHistorial.lastActivityAt, '2026-08-24T09:00:00.000Z');
      expect(sinHistorial.documentsComplete, isFalse);
    });

    test('closedAt marca el expediente como cerrado', () {
      expect(process.isClosed, isFalse);

      final cerrado = LegalHqProcess.fromJson(
        {'id': 'p3', 'status': 'FINISHED', 'closedAt': '2026-08-24T09:00:00Z'},
        isAssignedToMe: true,
      );
      expect(cerrado.isClosed, isTrue);
    });
  });

  group('LegalHqProcessDetail: comprobante de honorarios', () {
    const process = LegalHqProcess(
      id: 'proceso-1',
      category: kCategoryMortgage,
      status: 'APPROVED',
      propertyId: 'propiedad-1',
      isAssignedToMe: true,
    );

    test('encuentra el comprobante entre los documentos', () {
      const comprobante = LegalHqDocument(
        id: 'doc-5',
        label: 'Comprobante de pago',
        status: 'submitted',
        type: 'DOVIA_PAYMENT_PROOF',
        url: 'https://cdn.dovia.test/honorarios.pdf',
        mimeType: 'application/pdf',
      );
      const detail = LegalHqProcessDetail(
        process: process,
        documents: [comprobante],
      );

      expect(detail.paymentProofDocument?.id, 'doc-5');
      expect(detail.paymentProofLink, 'https://cdn.dovia.test/honorarios.pdf');
      expect(detail.hasPaymentProof, isTrue);
    });

    test('cae al campo suelto cuando no es un documento del checklist', () {
      const detail = LegalHqProcessDetail(
        process: process,
        documents: [],
        paymentProofUrl: 'https://cdn.dovia.test/transferencia.pdf',
      );

      expect(detail.paymentProofDocument, isNull);
      expect(detail.paymentProofLink,
          'https://cdn.dovia.test/transferencia.pdf');
      expect(detail.hasPaymentProof, isTrue);
    });

    test('sin comprobante no se puede auditar el cobro', () {
      const otro = LegalHqDocument(
        id: 'doc-1',
        label: 'Copia de contratos',
        status: 'submitted',
        url: 'https://cdn.dovia.test/contratos.pdf',
      );
      const detail = LegalHqProcessDetail(
        process: process,
        documents: [otro],
      );

      expect(detail.paymentProofDocument, isNull);
      expect(detail.paymentProofLink, isEmpty);
      expect(detail.hasPaymentProof, isFalse);
    });

    test('un slot de comprobante sin archivo no cuenta como cargado', () {
      const vacio = LegalHqDocument(
        id: 'doc-5',
        label: 'Comprobante de pago',
        status: 'missing',
        type: 'DOVIA_PAYMENT_PROOF',
      );
      const detail = LegalHqProcessDetail(
        process: process,
        documents: [vacio],
      );

      expect(detail.paymentProofDocument?.id, 'doc-5');
      expect(detail.hasPaymentProof, isFalse);
    });
  });

  group('LegalHqProcessDetail: convenio de DOVIA', () {
    const process = LegalHqProcess(
      id: 'proceso-1',
      category: kCategoryMortgage,
      status: 'BANK_MANAGEMENT_STARTED',
      propertyId: 'propiedad-1',
      isAssignedToMe: true,
    );

    const deposito = LegalHqDocument(
      id: 'doc-1',
      label: 'Copia de deposito a cuenta Dovia',
      status: 'submitted',
      url: 'https://cdn.dovia.test/deposito.pdf',
      mimeType: 'application/pdf',
    );

    test('separa el convenio de los comprobantes a auditar', () {
      const convenio = LegalHqDocument(
        id: 'doc-2',
        label: 'Convenio DOVIA',
        status: 'submitted',
        type: 'DOVIA_AGREEMENT_UNSIGNED',
        url: 'https://cdn.dovia.test/convenio.pdf',
        mimeType: 'application/pdf',
      );
      const detail = LegalHqProcessDetail(
        process: process,
        documents: [deposito, convenio],
      );

      expect(detail.doviaAgreementDocument?.id, 'doc-2');
      expect(detail.hasDoviaAgreement, isTrue);
      expect(
        detail.mortgageEvidenceDocuments().map((d) => d.id),
        ['doc-1'],
      );
    });

    test('sin archivo el convenio bloquea el avance de etapa', () {
      const convenioVacio = LegalHqDocument(
        id: 'doc-2',
        label: 'Convenio DOVIA',
        status: 'missing',
        type: 'DOVIA_AGREEMENT_UNSIGNED',
      );
      const detail = LegalHqProcessDetail(
        process: process,
        documents: [deposito, convenioVacio],
      );

      expect(detail.doviaAgreementDocument?.id, 'doc-2');
      expect(detail.hasDoviaAgreement, isFalse);
      expect(detail.mortgageEvidenceDocuments().map((d) => d.id), ['doc-1']);
    });

    test('sin slot de convenio tampoco se puede avanzar', () {
      const detail = LegalHqProcessDetail(
        process: process,
        documents: [deposito],
      );

      expect(detail.doviaAgreementDocument, isNull);
      expect(detail.hasDoviaAgreement, isFalse);
      expect(detail.mortgageEvidenceDocuments().map((d) => d.id), ['doc-1']);
    });

    test('el convenio firmado es un slot distinto, que sube el comprador', () {
      const sinFirmar = LegalHqDocument(
        id: 'doc-2',
        label: 'Convenio DOVIA',
        status: 'submitted',
        type: 'DOVIA_AGREEMENT_UNSIGNED',
        url: 'https://cdn.dovia.test/convenio.pdf',
      );
      const detail = LegalHqProcessDetail(
        process: process,
        documents: [sinFirmar],
      );

      // El HQ ya hizo lo suyo, pero el expediente sigue esperando la firma.
      expect(detail.hasDoviaAgreement, isTrue);
      expect(detail.hasSignedDoviaAgreement, isFalse);
    });
  });

  group('LegalHqProcessDetail: documentos obligatorios', () {
    const process = LegalHqProcess(
      id: 'proceso-1',
      category: kCategoryMortgage,
      status: 'BANK_MANAGEMENT_STARTED',
      propertyId: 'propiedad-1',
      isAssignedToMe: true,
    );

    LegalHqDocument slot(String type) => LegalHqDocument(
          id: 'doc-$type',
          label: type,
          status: 'submitted',
          type: type,
          url: 'https://cdn.dovia.test/$type.pdf',
        );

    test('los seis slots son los que exige documents/complete', () {
      expect(kMortgageRequiredDocumentTypes, [
        'OWNER_CLIENT_ID_DOCUMENT',
        'INTERESTED_CLIENT_ID_DOCUMENT',
        'OWNER_ID_DOCUMENT',
        'PROPERTY_CERTIFICATION',
        'DOVIA_AGREEMENT_UNSIGNED',
        'DOVIA_AGREEMENT_SIGNED',
      ]);
    });

    test('con los seis cargados el expediente se puede confirmar', () {
      final detail = LegalHqProcessDetail(
        process: process,
        documents: kMortgageRequiredDocumentTypes.map(slot).toList(),
      );

      expect(detail.missingRequiredDocuments, isEmpty);
      expect(detail.canCompleteDocuments, isTrue);
    });

    test('lista lo que falta con la etiqueta visible, no el tipo', () {
      final detail = LegalHqProcessDetail(
        process: process,
        documents: [
          slot('OWNER_CLIENT_ID_DOCUMENT'),
          slot('INTERESTED_CLIENT_ID_DOCUMENT'),
          slot('OWNER_ID_DOCUMENT'),
          slot('PROPERTY_CERTIFICATION'),
          slot('DOVIA_AGREEMENT_UNSIGNED'),
        ],
      );

      expect(detail.canCompleteDocuments, isFalse);
      expect(detail.missingRequiredDocuments, ['Convenio de DOVIA firmado']);
    });

    test('un slot sin archivo cuenta como faltante', () {
      final documentos = kMortgageRequiredDocumentTypes.map(slot).toList()
        ..removeLast()
        ..add(const LegalHqDocument(
          id: 'doc-vacio',
          label: 'Convenio DOVIA firmado',
          status: 'missing',
          type: 'DOVIA_AGREEMENT_SIGNED',
        ));
      final detail = LegalHqProcessDetail(
        process: process,
        documents: documentos,
      );

      expect(detail.canCompleteDocuments, isFalse);
      expect(detail.missingRequiredDocuments, ['Convenio de DOVIA firmado']);
    });

    test('documentsComplete viene del expediente', () {
      const confirmado = LegalHqProcess(
        id: 'proceso-1',
        category: kCategoryMortgage,
        status: 'BANK_DOCUMENTATION_SUBMITTED',
        propertyId: 'propiedad-1',
        isAssignedToMe: true,
        documentsComplete: true,
      );

      expect(
        const LegalHqProcessDetail(process: confirmado, documents: [])
            .documentsComplete,
        isTrue,
      );
      expect(
        const LegalHqProcessDetail(process: process, documents: [])
            .documentsComplete,
        isFalse,
      );
    });
    });
}
