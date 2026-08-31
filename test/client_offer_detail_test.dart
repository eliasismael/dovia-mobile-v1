import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/client_offer_detail.dart';

Map<String, dynamic> _saleOffer({
  String status = 'SENT',
  String? rejectedBy,
  String? reason,
}) =>
    {
      'offerId': 'offer-sale',
      'propertyId': 'property-sale',
      'offerType': 'SALE',
      'offerStatus': status,
      if (rejectedBy != null) 'rejectedBy': rejectedBy,
      if (reason != null) 'rejectionReason': reason,
      'offerData': {
        'paymentMethod': 'mortgage',
        'currency': 'USD',
        'proposedAmount': 250000,
        'downPaymentPercentage': 25,
        'bankName': 'Banco Dovia',
        'creditStatus': 'approved',
        'estimatedApprovalTime': 2,
        'buyerInfo': {
          'name': 'Ana Compradora',
          'legalName': 'Compras Ana, S.A.',
          'legalRepresentative': 'Ana Pérez',
        },
        'considerations': 'Reparar la tubería',
      },
    };

Map<String, dynamic> _propertyResponse(Map<String, dynamic> property) => {
      'data': {'data': property},
    };

String _value(ClientOfferDetail detail, String label) =>
    detail.allFields.singleWhere((field) => field.label == label).value;

void main() {
  group('Detalle de compra enviado', () {
    test('mapea la propiedad y la propuesta a campos de solo lectura', () {
      final detail = ClientOfferDetail.fromJson(
        _saleOffer(),
        propertyJson: _propertyResponse({
          'name': 'Casa Central',
          'saleInfo': {'salePrice': 300000},
          'rentInfo': {
            'rentalConditions': {'availableFrom': '2026-09-15T00:00:00.000Z'},
          },
        }),
      );

      expect(detail.title, 'Oferta de compra realizada');
      expect(detail.isRejected, isFalse);
      expect(detail.canWithdraw, isTrue);
      expect(_value(detail, 'Precio'), 'USD 300,000');
      expect(_value(detail, 'Disponible desde'), '15/09/2026');
      expect(_value(detail, 'Método de pago'), 'Hipoteca');
      expect(_value(detail, 'Enganche'), '25%');
      expect(_value(detail, 'Propuesta económica'), 'USD 250,000');
      expect(_value(detail, 'Nombre del comprador'), 'Ana Compradora');
      expect(
        _value(detail, 'Consideraciones o solicitudes'),
        'Reparar la tubería',
      );
    });
  });

  group('Detalle rechazado', () {
    test(
      'expone exactamente el motivo del propietario y elimina el retiro',
      () {
        final detail = ClientOfferDetail.fromJson(
          _saleOffer(
            status: 'REJECTED',
            rejectedBy: 'OWNER',
            reason: 'El enganche propuesto es muy bajo',
          ),
        );

        expect(detail.title, 'Oferta de compra rechazada');
        expect(detail.isRejected, isTrue);
        expect(detail.canWithdraw, isFalse);
        expect(detail.rejectionReason, 'El enganche propuesto es muy bajo');
      },
    );

    test(
      'un retiro del cliente no se presenta como rechazo del propietario',
      () {
        final detail = ClientOfferDetail.fromJson(
          _saleOffer(
            status: 'REJECTED_BY_CLIENT',
            rejectedBy: 'CLIENT',
            reason: 'Cambié de opinión',
          ),
        );

        expect(detail.isRejected, isFalse);
        expect(detail.title, 'Oferta de compra realizada');
      },
    );
  });

  group('Detalle de renta enviado', () {
    test('lee condiciones reales de la propiedad y datos del arrendatario', () {
      final detail = ClientOfferDetail.fromJson(
        {
          'offerId': 'offer-rent',
          'propertyId': 'property-rent',
          'offerType': 'RENT',
          'offerStatus': 'SENT',
          'offerData': {
            'currency': 'GTQ',
            'contractStartDate': '2026-09-01T00:00:00.000Z',
            'contractEndDate': '2027-09-01T00:00:00.000Z',
            'propertyUse': 'Vivienda personal',
            'considerations': 'Pintar la pared principal',
            'tenantInfo': {'name': 'Luis Arrendatario'},
          },
        },
        propertyJson: _propertyResponse({
          'name': 'Apartamento Norte',
          'rentInfo': {
            'monthlyRent': 7500,
            'rentalConditions': {
              'minimumTime': 12,
              'others': 'No se permiten mascotas',
              'allowedUses': 'Vivienda personal',
              'prohibitedUses': 'Airbnb',
              'availableFrom': '2026-09-01T00:00:00.000Z',
            },
          },
        }),
      );

      expect(detail.title, 'Oferta de renta realizada');
      expect(_value(detail, 'Precio mensual'), 'USD 7,500');
      expect(_value(detail, 'Tiempo mínimo de contrato en meses'), '12 meses');
      expect(
        _value(detail, 'Otras consideraciones'),
        'No se permiten mascotas',
      );
      expect(_value(detail, 'Uso no permitido en esta propiedad'), 'Airbnb');
      expect(_value(detail, 'Duración del contrato'), '12 meses');
      expect(_value(detail, 'Moneda de pago'), 'Quetzales');
      expect(_value(detail, 'Quien será el arrendatario'), 'Luis Arrendatario');
    });

    test('los requisitos del complejo sólo viajan en la renta', () {
      final rent = ClientOfferDetail.fromJson(
        {
          'offerId': 'offer-rent',
          'propertyId': 'property-rent',
          'offerType': 'RENT',
          'offerStatus': 'SENT',
          'offerData': const {'currency': 'USD'},
        },
        propertyJson: _propertyResponse({
          'name': 'Apartamento Norte',
          'rentInfo': {
            'rentalConditions': {
              'complexRequirements': 'Depósito de un mes en administración',
            },
          },
        }),
      );
      final sale = ClientOfferDetail.fromJson({
        'offerId': 'offer-sale',
        'propertyId': 'property-sale',
        'offerType': 'SALE',
        'offerStatus': 'SENT',
        'offerData': const {'currency': 'USD'},
      });

      expect(rent.isRent, isTrue);
      expect(rent.complexRequirements, 'Depósito de un mes en administración');
      expect(sale.isRent, isFalse);
      expect(sale.complexRequirements, isEmpty);
    });
  });
}
