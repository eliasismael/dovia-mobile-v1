// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class HowItWorksWidget extends StatelessWidget {
  static const Color aquaColor = Color(0xFF007376);
  static const Color aquaGradientEnd = Color(0xFF00595C);
  static const Color textColor = Color(0xFF00444B);
  static const Color backgroundColor = Color.fromARGB(0, 0, 0, 0);
  static const Color cardBackground = Colors.white;
  static const Color stepBadgeColor = Color(0xFF007376);
  static const Color paso2BadgeColor = Color(0xFF76A5A7);

  final VoidCallback? onAccept;
  final double? width;
  final double? height;

  const HowItWorksWidget({super.key, this.onAccept, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildInfoHeader(),
              const SizedBox(height: 40),
              _buildStepsTimeline(),
              const SizedBox(height: 48),
              _buildAcceptButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [aquaColor, aquaGradientEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: aquaColor.withOpacity(
              0.2,
            ),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo funciona comercializar tu propiedad con DOVIA?',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'DOVIA es tu aliado para vender o rentar tu propiedad de forma segura, rápida y completamente transparente, respaldado por procesos modernos y tecnología de última generación.\n\nEn venta, nuestra comisión es del 3.5% + impuestos.\n\nEn renta, nuestra comisión es equivalente a un mes de renta.\n\nNuestro objetivo es que todo el proceso sea sin estrés, sin pérdida de tiempo y sin dolores de cabeza.\n\nSolo personas verificadas e interesadas visitan tu propiedad, y cada etapa es supervisada por profesionales Dovia.',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.4,
              letterSpacing: 0.28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTimeline() {
    return Column(
      children: [
        _buildStep(
          id: 1,
          badgeText: 'Paso 1',
          badgeColor: stepBadgeColor,
          title: 'Información básica',
          description:
              'Completa la información básica, nos ayuda a validar y preparar tu publicación.',
          icon: _buildTimelineIcon(Icons.auto_awesome_outlined),
        ),
        _buildStep(
          id: 2,
          badgeText: 'Paso 2',
          badgeColor: paso2BadgeColor,
          title: 'Sesión profesional',
          description:
              'Toma de material comercial, un especialista realizará fotos, recorrido 360°, planos, etc.',
          icon: _buildTimelineIcon(Icons.flash_on_outlined),
        ),
        _buildStep(
          id: 3,
          badgeText: 'Paso 3',
          badgeColor: paso2BadgeColor,
          title: 'Ofertas en tiempo real',
          description: 'Recibe ofertas directas desde tu app.',
          icon: _buildTimelineIcon(Icons.camera_alt_outlined),
          useAltIcon: true,
        ),
        _buildStep(
          id: 4,
          badgeText: 'Paso 4',
          badgeColor: stepBadgeColor,
          title: 'Acompañamiento total',
          description:
              'Dovia verifica y te acompaña en todo el proceso desde la gestión e visitas hasta el cierre legal.',
          icon: _buildTimelineIcon(Icons.check_circle_outline),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineIcon(IconData icon) {
    return Icon(icon, size: 24, color: Colors.white);
  }

  Widget _buildStep({
    required int id,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String description,
    required Widget icon,
    bool isLast = false,
    bool useAltIcon = false,
  }) {
    Widget stepIcon = icon;
    if (id == 3) {
      stepIcon = const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.circle_outlined, size: 24, color: Colors.white),
          Icon(Icons.circle, size: 8, color: Colors.white),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and circle
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF007376),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: stepIcon),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFFACBDBC)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Text Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: aquaColor, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00444B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF76A5A7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: onAccept,
        style: ElevatedButton.styleFrom(
          backgroundColor: aquaColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: aquaColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: const Text(
          'Aceptar',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
