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

class PropertySelectionWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final VoidCallback? onAgendarCita;
  final VoidCallback? onOfertar;
  final VoidCallback? onSeeAllImages;

  final double? latitude;
  final double? longitude;
  final int mapZoom;

  // Optional: path to a local static map image asset
  final String? staticMapImagePath;

  const PropertySelectionWidget({
    super.key,
    this.width,
    this.height,
    this.onSeeAllImages,
    this.onAgendarCita,
    this.onOfertar,
    this.latitude,
    this.longitude,
    this.mapZoom = 15,
    this.staticMapImagePath,
  });

  @override
  State<PropertySelectionWidget> createState() =>
      _PropertySelectionWidgetState();
}

class _PropertySelectionWidgetState extends State<PropertySelectionWidget> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color darkTextColor = Color(0xFF00444B);
  static const Color lightBackground = Color(0xFFF7F7F7);

  static const Color goldStar = Color(0xFFFFA500);

  int _currentImageIndex = 0;
  int _selectedTab = 0; // 0 = Venta, 1 = Renta

  bool _caracteristicasExpanded = false;
  bool _amenidadesExpanded = false;
  bool _sobreSectorExpanded = false;

  // Page controller for image gallery
  late PageController _pageController;

  // Sample property images
  final List<String> _propertyImages = [
    'assets/images/2d1ef15c43d90e006990ae24967171a402c57acf.png',
    'assets/images/ca7bc2d0f67411e51c0d4d18a1ade26237b279b1.png',
    'assets/images/9a1ffb1271d2dc9f3067aec9ab502f9cdf3e416b.png',
    'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: lightBackground,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            _buildImageGallery(),

            // Property Header
            _buildPropertyHeader(),

            // Venta / Renta Toggle
            _buildToggleTabs(),

            // Action Buttons
            _buildActionButtons(),

            const SizedBox(height: 16),

            // Property Info
            _buildPropertyInfo(),

            const SizedBox(height: 16),

            // Stats Row
            _buildStatsRow(),

            const SizedBox(height: 16),

            // Dropdown Sections
            _buildCaracteristicasDropdown(),
            _buildAmenidadesDropdown(),
            _buildSobreSectorDropdown(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          // Main Image with PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _propertyImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                ),
                child: Image.asset(
                  _propertyImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),

          // Left Arrow Navigation
          Positioned(
            left: 12,
            top: 0,
            bottom: 70,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_currentImageIndex > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: darkTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Right Arrow Navigation
          Positioned(
            right: 12,
            top: 0,
            bottom: 70,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_currentImageIndex < _propertyImages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: darkTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Thumbnail Row at bottom
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0; i < _propertyImages.length; i++)
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _currentImageIndex == i
                              ? primaryColor
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          _propertyImages[i],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey.shade400,
                            child: const Icon(Icons.image,
                                size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Action icons (top right)
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                _buildImageActionButton(Icons.favorite_border),
                const SizedBox(width: 8),
                _buildImageActionButton(Icons.share_outlined),
                const SizedBox(width: 8),
                _buildImageActionButton(Icons.download_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageActionButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: darkTextColor),
    );
  }

  Widget _buildPropertyHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property icon placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.home_outlined, color: primaryColor, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Orchand House',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'USD',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Icons
          Row(
            children: [
              GestureDetector(
                onTap: widget.onSeeAllImages,
                behavior: HitTestBehavior.opaque,
                child: Icon(Icons.visibility_outlined,
                    size: 22, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Icon(Icons.bookmark_border,
                  size: 22, color: Colors.grey.shade600),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        _selectedTab == 0 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: _selectedTab == 0
                        ? Border.all(color: primaryColor.withOpacity(0.3))
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Venta',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: _selectedTab == 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _selectedTab == 0
                            ? primaryColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        _selectedTab == 1 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: _selectedTab == 1
                        ? Border.all(color: primaryColor.withOpacity(0.3))
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Renta',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: _selectedTab == 1
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _selectedTab == 1
                            ? primaryColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onAgendarCita,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Agendar cita',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onOfertar,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: const BorderSide(color: primaryColor),
              ),
              child: const Text(
                'Ofertar',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Código A123B', null),
          _buildInfoRow('Tipo de vivienda', null),
          _buildInfoRow('Dirección', null),
          const SizedBox(height: 8),
          const Text(
            'Descripción sobre la propiedad',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: darkTextColor,
            ),
          ),
          if (value != null) ...[
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('9', 'Área m² / varas²'),
            _buildStatItem('XX', 'XX de áreas'),
            _buildStatItem('XX', 'XX de habitaciones'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCaracteristicasDropdown() {
    return _buildDropdownSection(
      title: 'Características',
      isExpanded: _caracteristicasExpanded,
      onTap: () {
        setState(() {
          _caracteristicasExpanded = !_caracteristicasExpanded;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Características generales',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          // Grid of characteristics
          Row(
            children: [
              Expanded(
                  child: _buildCharacteristicItem(
                      Icons.bed_outlined, 'Habitaciones', '4')),
              Expanded(
                  child: _buildCharacteristicItem(
                      Icons.bathtub_outlined, 'Baños', '3')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildCharacteristicItem(
                      Icons.hot_tub_outlined, 'Medio baños', '1')),
              Expanded(
                  child: _buildCharacteristicItem(
                      Icons.local_parking_outlined, 'Parqueo', '2')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildCharacteristicItem(
                      Icons.stairs_outlined, 'Pisos', '2')),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Incluye',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          // Bullet list
          _buildBulletRow(['Sala', 'Comedor']),
          _buildBulletRow(['Lavandería', 'Cuarto de servicio']),
          _buildBulletRow(['Amueblado', 'Cocina']),
          const SizedBox(height: 16),
          const Text(
            'Otras características',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletRow(['Pet Friendly', 'Permitido para Airbnb']),
        ],
      ),
    );
  }

  Widget _buildCharacteristicItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletRow(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: Row(
              children: [
                const Text('• ', style: TextStyle(color: darkTextColor)),
                Text(
                  item,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    color: darkTextColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmenidadesDropdown() {
    return _buildDropdownSection(
      title: 'Amenidades',
      isExpanded: _amenidadesExpanded,
      onTap: () {
        setState(() {
          _amenidadesExpanded = !_amenidadesExpanded;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Propiedad',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletRow(['A/C', 'Jardín']),
          _buildBulletRow(['Área de churrasquera', 'Cocina con isla']),
          _buildBulletRow(['Tina', '']),
          const SizedBox(height: 16),
          const Text(
            'Áreas comunes',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletRow(['Piscina', 'Parque de juegos']),
          _buildBulletRow(['Gimnasio', 'Coworking']),
          _buildBulletRow(['Salón de eventos', 'Yoga Deck']),
          _buildBulletRow(['Cocina para eventos', '']),
        ],
      ),
    );
  }

  Widget _buildSobreSectorDropdown() {
    return _buildDropdownSection(
      title: 'Sobre el sector',
      isExpanded: _sobreSectorExpanded,
      onTap: () {
        setState(() {
          _sobreSectorExpanded = !_sobreSectorExpanded;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Static Map
          _buildStaticMap(),
          const SizedBox(height: 16),
          Text(
            'Una breve descripción sobre el sector',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          // Rating items
          _buildRatingItem('Caminable'),
          _buildRatingItem('Centro comerciales cerca'),
          _buildRatingItem('Áreas verdes'),
        ],
      ),
    );
  }

  /// Builds a static map using local asset or network image
  Widget _buildStaticMap() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Static map image - prefer local asset if provided
            if (widget.staticMapImagePath != null)
              Image.asset(
                widget.staticMapImagePath!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _buildMapPlaceholder();
                },
              )
            else
              _buildMapPlaceholder(),
            // Semi-transparent overlay circle to indicate area
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fallback map placeholder when network image fails
  Widget _buildMapPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Stack(
        children: [
          Center(
            child:
                Icon(Icons.map_outlined, size: 50, color: Colors.grey.shade500),
          ),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Shopping bag icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.shopping_bag_outlined,
                  color: primaryColor, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return const Icon(Icons.star, size: 20, color: goldStar);
            }),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 13,
              color: darkTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: darkTextColor,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: darkTextColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0, width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: child,
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
