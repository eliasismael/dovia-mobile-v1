// Reglas de "Ofertar": qué campos necesita cada oferta antes de salir hacia la
// API.
//
// Las cuatro llamadas de creación arman el cuerpo interpolando strings
// (`"proposedAmount": $proposedAmount`), así que un campo vacío no falla en el
// cliente: viaja como `null` y el backend rechaza la oferta sin decir cuál
// faltaba. Las reglas viven acá, fuera del formulario, para poder probar el
// reparto —qué pide una renta, qué pide cada método de pago— sin montar la UI.

/// Lo que el usuario escribió, tal cual está en los controladores.
class OfferFormInput {
  /// `'compra'`, `'renta'` o `'ambos'`.
  final String offerType;

  /// `'Contado'`, `'Hipoteca'` o `'Promesa de compra'`. Irrelevante en una
  /// oferta de renta pura.
  final String paymentMethod;

  final String purchaseAmount;
  final String rentAmount;

  /// Contado: meses estimados de pago tras la aceptación.
  final String cashPaymentTime;

  /// Hipoteca. `creditStatus` no entra: el contrato lo declara opcional y el
  /// formulario lo resuelve con un desplegable acotado al enum.
  final String downPayment;
  final String bankName;
  final String bankApprovalTime;

  /// Promesa de compra.
  final String initialReserve;
  final String promiseMonths;

  /// Comprador o arrendatario.
  final String buyerName;
  final String legalName;
  final String legalRepresentative;

  /// Renta, en formato `yyyy-MM-dd`.
  final String contractStart;
  final String contractEnd;

  const OfferFormInput({
    required this.offerType,
    this.paymentMethod = 'Contado',
    this.purchaseAmount = '',
    this.rentAmount = '',
    this.cashPaymentTime = '',
    this.downPayment = '',
    this.bankName = '',
    this.bankApprovalTime = '',
    this.initialReserve = '',
    this.promiseMonths = '',
    this.buyerName = '',
    this.legalName = '',
    this.legalRepresentative = '',
    this.contractStart = '',
    this.contractEnd = '',
  });

  bool get isPurchase => offerType != 'renta';
  bool get isRent => offerType == 'renta' || offerType == 'ambos';
}

/// Claves de error, una por campo del formulario.
abstract final class OfferField {
  static const purchaseAmount = 'propuestaEconomica';
  static const rentAmount = 'propuestaRenta';
  static const cashPaymentTime = 'contadoTiempoPago';
  static const downPayment = 'enganche';
  static const bankName = 'banco';
  static const bankApprovalTime = 'tiempoAprobacion';
  static const initialReserve = 'reservaInicial';
  static const promiseMonths = 'tiempoPromesa';
  static const buyerName = 'nombreComprador';
  static const legalRepresentative = 'representanteLegal';
  static const contractStart = 'fechaInicio';
  static const contractEnd = 'fechaFin';
}

const String _requiredMessage = 'Campo obligatorio';

/// Rango que el backend acepta para `promiseTimeMonths`. Fuera de él rechaza la
/// oferta con "El tiempo de la promesa debe estar entre 1 y 36 meses".
const int kPromiseMonthsMin = 1;
const int kPromiseMonthsMax = 36;

/// Devuelve el error de cada campo que impide enviar la oferta. Vacío significa
/// que el formulario está listo.
Map<String, String> validateOfferForm(OfferFormInput input) {
  final errors = <String, String>{};

  void check(String field, String? error) {
    if (error != null) errors[field] = error;
  }

  if (input.isPurchase) {
    check(OfferField.purchaseAmount, _number(input.purchaseAmount, min: 1));

    switch (input.paymentMethod) {
      case 'Hipoteca':
        // `downPaymentPercentage` y `estimatedApprovalTime` se mandan como
        // enteros: un decimal se perdería en el `int.tryParse` del formulario.
        check(
          OfferField.downPayment,
          _number(input.downPayment, integer: true, min: 1, max: 100),
        );
        check(OfferField.bankName, _text(input.bankName));
        check(
          OfferField.bankApprovalTime,
          _number(input.bankApprovalTime, integer: true, min: 1),
        );
        break;
      case 'Promesa de compra':
        check(OfferField.initialReserve, _number(input.initialReserve, min: 1));
        check(
          OfferField.promiseMonths,
          _number(
            input.promiseMonths,
            integer: true,
            min: kPromiseMonthsMin,
            max: kPromiseMonthsMax,
            rangeMessage:
                'El tiempo debe estar entre $kPromiseMonthsMin y $kPromiseMonthsMax meses',
          ),
        );
        break;
      default: // Contado
        check(
          OfferField.cashPaymentTime,
          _number(input.cashPaymentTime,
              integer: true, min: 0, max: kCashPaymentTimeMaxDays),
        );
    }
  }

  if (input.isRent) {
    check(OfferField.rentAmount, _number(input.rentAmount, min: 1));
    check(OfferField.contractStart, _text(input.contractStart));
    check(OfferField.contractEnd, _text(input.contractEnd));

    // Un contrato que termina antes de empezar deja `contractEndDate` por
    // detrás de `contractStartDate` y el backend lo rechaza sin explicar.
    final start = DateTime.tryParse(input.contractStart);
    final end = DateTime.tryParse(input.contractEnd);
    if (!errors.containsKey(OfferField.contractEnd) &&
        start != null &&
        end != null &&
        !end.isAfter(start)) {
      errors[OfferField.contractEnd] =
          'Debe ser posterior a la fecha de inicio';
    }
  }

  // `buyerInfo.name` / `tenantInfo.name` viaja en las cuatro llamadas.
  check(OfferField.buyerName, _text(input.buyerName));

  // La razón social es opcional, pero al declararla la oferta pasa a ser de una
  // empresa y la API espera también a su representante.
  if (input.legalName.trim().isNotEmpty) {
    check(OfferField.legalRepresentative, _text(input.legalRepresentative));
  }

  return errors;
}

String? _text(String value) => value.trim().isEmpty ? _requiredMessage : null;

String? _number(
  String value, {
  bool integer = false,
  num? min,
  num? max,
  String? rangeMessage,
}) {
  final raw = value.trim();
  if (raw.isEmpty) return _requiredMessage;

  final parsed = integer ? int.tryParse(raw) : double.tryParse(raw);
  if (parsed == null) {
    return integer ? 'Ingresa un número entero' : 'Ingresa un número válido';
  }
  // [rangeMessage] reemplaza a los dos avisos genéricos cuando el campo tiene
  // un rango con nombre propio y "entre 1 y 36" dice más que "mayor o igual".
  if (min != null && parsed < min) {
    return rangeMessage ?? 'Debe ser mayor o igual a $min';
  }
  if (max != null && parsed > max) {
    return rangeMessage ?? 'Debe ser menor o igual a $max';
  }
  return null;
}

/// Opciones del tiempo estimado de pago al contado, en días (tope: 1 mes).
/// "Inmediatamente" va como 1: el backend exige entre 1 y 180 días.
const kCashPaymentTimeOptions = <String, int>{
  'Inmediatamente': 1,
  '1 semana': 7,
  '2 semanas': 14,
  '3 semanas': 21,
  '4 semanas': 28,
};
const kCashPaymentTimeMaxDays = 28;

/// Etiqueta de un tiempo de pago guardado en días; `null` si no coincide.
String? cashPaymentTimeLabel(Object? days) {
  var value = int.tryParse('${days ?? ''}'.trim());
  // Ofertas viejas guardaron "Inmediatamente" como 0.
  if (value == 0) value = 1;
  for (final entry in kCashPaymentTimeOptions.entries) {
    if (entry.value == value) return entry.key;
  }
  return null;
}
