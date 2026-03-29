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

class DoviaServicesWidget extends StatelessWidget {
  final VoidCallback? onCotizarPressed;
  final VoidCallback? onServiceTap;
  final VoidCallback? onVerTodoVisitas;
  final VoidCallback? onVerTodoCotizaciones;
  final String? direccion;
  final double? width;
  final double? height;

  const DoviaServicesWidget({
    super.key,
    this.onCotizarPressed,
    this.onServiceTap,
    this.onVerTodoVisitas,
    this.onVerTodoCotizaciones,
    this.direccion,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildServiciosSection(),
            const SizedBox(height: 24),
            _buildOtrosTrabajosCard(),
            const SizedBox(height: 24),
            _buildProximasVisitasSection(),
            const SizedBox(height: 24),
            _buildCotizacionesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dirección: ${direccion ?? "xxx"}',
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF00444B),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF007376),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'DOVIA BASIC',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiciosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios Dovia Basic',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00444B),
            height: 1.36,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF70ACAD).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Precio base para usuarios sin suscripción. Están incluidos si tienes Dovia Basic',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF00444B),
              height: 1.14,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildServiceCard(
                    icon: Icons.build,
                    label: 'Plomería',
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  _buildServiceCard(
                    icon: Icons.flash_on,
                    label: 'Eléctrico',
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  _buildServiceCard(
                    icon: Icons.house,
                    label: 'Albañilería',
                    isSelected: false,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildServiceCard(
                    icon: Icons.format_paint,
                    label: 'Pintura',
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  _buildServiceCard(
                    icon: Icons.inventory_2,
                    label: 'Instalación',
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  _buildServiceCard(
                    icon: Icons.headset_mic,
                    label: 'Servicio de\nemergencia',
                    isSelected: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onServiceTap,
        child: Container(
          height: 99,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF007376) : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF70ACAD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF00444B),
                  height: 1.0,
                  letterSpacing: 0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtrosTrabajosCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B8F92),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Otros trabajos',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.32,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const Text(
            'Para trabajos fuera del alcance estándar o mejoras grandes',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.28,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 316,
            height: 42,
            child: OutlinedButton(
              onPressed: onCotizarPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF007376), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Quiero cotizar',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007376),
                  letterSpacing: 0,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProximasVisitasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Próximas visitas',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00444B),
              ),
            ),
            TextButton(
              onPressed: onVerTodoVisitas,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                backgroundColor: const Color(0xFFF7F7F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF00444B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Revisa y gestiona las visitas ya calendizadas',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 16),
        _buildVisitCard(
          icon: Icons.inventory_2,
          title: 'Instalación de TV',
          date: 'Lunes, 10 de Noviembre',
        ),
        const SizedBox(height: 12),
        _buildVisitCard(
          icon: Icons.bug_report,
          title: 'Fumigación Mensual',
          date: 'Viernes, 14 de Noviembre',
        ),
      ],
    );
  }

  Widget _buildVisitCard({
    required IconData icon,
    required String title,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF70ACAD), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFF666666), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00444B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCotizacionesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cotizaciones recibidas',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00444B),
              ),
            ),
            TextButton(
              onPressed: onVerTodoCotizaciones,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                backgroundColor: const Color(0xFFF7F7F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF00444B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Cotizaciones generadas a partir de diagnósticos',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 16),
        // Quote card
        _buildQuoteCard(
          icon: Icons.build,
          title: 'Reparación de tubería',
          status: 'Visita realizada',
          date: 'DD/MM/AAAA',
        ),
      ],
    );
  }

  Widget _buildQuoteCard({
    required IconData icon,
    required String title,
    required String status,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF70ACAD), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFF666666), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00444B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
