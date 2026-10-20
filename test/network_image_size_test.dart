import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/core/network_image_size.dart';

/// Las fotos de internet se decodifican al tamaño en que se ven, no al
/// original: en un teléfono de 384 dp a 3x.
void main() {
  testWidgets('decodifica al lado mayor de la caja por la densidad',
      (tester) async {
    tester.view.physicalSize = const Size(384 * 3, 832 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Tarjeta de 210 de ancho: 630 px.
    expect(networkImageCacheWidth(width: 210, height: 150), 630);
    // Más alta que ancha: alcanza el alto para BoxFit.cover.
    expect(networkImageCacheWidth(width: 72, height: 108), 324);
    // Sin tamaño o infinito: el ancho de la pantalla.
    expect(networkImageCacheWidth(), 384 * 3);
    expect(networkImageCacheWidth(width: double.infinity, height: 220), 384 * 3);
    // Nunca más que el lado mayor de la pantalla.
    expect(networkImageCacheWidth(width: 5000), 832 * 3);
  });
}
