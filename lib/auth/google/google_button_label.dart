import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Contenido del botón "Continuar con Google" del login y del registro.
class GoogleButtonLabel extends StatelessWidget {
  const GoogleButtonLabel({super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/GoogleLogo.svg',
            width: 19.0,
            height: 19.0,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10.0),
          Flexible(
            child: Text(
              'Continuar con Google',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.publicSans(
                color: const Color(0xFF1F1F1F),
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
}
