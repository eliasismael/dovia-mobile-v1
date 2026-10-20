import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Las fuentes vienen en assets/google_fonts: con la descarga apagada (como
/// en main.dart) cada familia y peso que usa la app carga sin internet.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Inter, Public Sans y Raleway cargan desde los assets', () async {
    GoogleFonts.config.allowRuntimeFetching = false;
    for (final weight in [
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
    ]) {
      GoogleFonts.inter(fontWeight: weight);
      GoogleFonts.publicSans(fontWeight: weight);
    }
    GoogleFonts.publicSans(fontStyle: FontStyle.italic);
    // Inter no tiene itálica: se usa la normal del mismo peso.
    GoogleFonts.inter(fontStyle: FontStyle.italic);
    GoogleFonts.inter(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic);
    GoogleFonts.raleway(fontWeight: FontWeight.w400);
    GoogleFonts.raleway(fontWeight: FontWeight.bold);

    // Si alguna faltara en los assets, esto falla en vez de ir a la red.
    await expectLater(GoogleFonts.pendingFonts(), completes);
  });
}
