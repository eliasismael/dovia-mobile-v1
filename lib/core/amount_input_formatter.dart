import 'package:flutter/services.dart';

/// Formatea un monto mientras se escribe: `1234567.5` -> `1,234,567.5`.
///
/// Coma para miles y punto para decimales (hasta [decimalDigits]). El cursor
/// se mantiene detrás del mismo dígito aunque se agreguen o quiten comas.
/// Para leer el valor usar [parseAmount], que ignora los separadores.
class AmountInputFormatter extends TextInputFormatter {
  AmountInputFormatter({this.decimalDigits = 2});

  final int decimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) return newValue.copyWith(text: '');
    final pattern = decimalDigits == 0
        ? RegExp(r'^\d*$')
        : RegExp('^\\d*\\.?\\d{0,$decimalDigits}\$');
    if (!pattern.hasMatch(raw)) {
      return oldValue;
    }

    final dot = raw.indexOf('.');
    var integer = dot == -1 ? raw : raw.substring(0, dot);
    final decimals = dot == -1 ? '' : raw.substring(dot);
    // "007" -> "7", pero "0.5" conserva el cero.
    integer = integer.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    final buffer = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) buffer.write(',');
      buffer.write(integer[i]);
    }
    final formatted = '$buffer$decimals';

    // Cuántos caracteres que no son coma había antes del cursor.
    final cursor = newValue.selection.end.clamp(0, newValue.text.length);
    var significant =
        newValue.text.substring(0, cursor).replaceAll(',', '').length;
    // Los ceros a la izquierda que se quitaron no cuentan.
    significant -= raw.length - integer.length - decimals.length;
    var offset = 0;
    while (offset < formatted.length && significant > 0) {
      if (formatted[offset] != ',') significant--;
      offset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// Lee un monto escrito con [AmountInputFormatter] (o sin formato).
double? parseAmount(String? text) =>
    double.tryParse((text ?? '').replaceAll(',', '').trim());

/// Muestra un monto con el mismo formato que [AmountInputFormatter]:
/// `1234567.5` -> `1,234,567.5`. Si no es un número lo devuelve tal cual.
String formatAmountText(String text) {
  final value = parseAmount(text);
  if (value == null) return text;
  final formatter = AmountInputFormatter();
  final plain = value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
  return formatter
      .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: plain))
      .text;
}

/// Símbolo que acompaña a un monto: `Q` para quetzales (y por defecto) y
/// `USD` para dólares. Nunca `$`, que en Guatemala se confunde.
String currencySymbol([String? currency]) =>
    (currency ?? '').toUpperCase() == 'USD' ? 'USD' : 'Q';
