import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dovia/core/amount_input_formatter.dart';

TextEditingValue _type(String old, String next, [int? cursor]) =>
    AmountInputFormatter().formatEditUpdate(
      TextEditingValue(text: old),
      TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: cursor ?? next.length)),
    );

void main() {
  test('agrega separadores de miles', () {
    expect(_type('', '1234567').text, '1,234,567');
    expect(_type('', '1234567.5').text, '1,234,567.5');
    expect(_type('1,234.5', '1,234.56').text, '1,234.56');
  });

  test('rechaza mas de dos decimales o dos puntos', () {
    expect(_type('1,234.56', '1,234.567').text, '1,234.56');
    expect(_type('12.3', '12.3.').text, '12.3');
  });

  test('quita ceros a la izquierda pero conserva 0.x', () {
    expect(_type('', '007').text, '7');
    expect(_type('', '0.5').text, '0.5');
  });

  test('cursor al final tras escribir', () {
    final v = _type('123', '1234');
    expect(v.selection.end, v.text.length);
  });

  test('parseAmount ignora comas', () {
    expect(parseAmount('1,234,567.89'), 1234567.89);
    expect(parseAmount(''), isNull);
  });
}
