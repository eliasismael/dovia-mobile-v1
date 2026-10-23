// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import '/core/network_image_size.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Property Card Widget - Based on Figma design (node 1034:22675)
// A reusable card component displaying property information with image
import 'package:flutter_svg/flutter_svg.dart';
import '/shared_components/dovia_spinner.dart';

class PropertyCardWidget extends StatelessWidget {
  static const Color textColor = Color(0xFF00444B);
  static const Color secondaryTextColor = Color(0xFF858585);
  static const Color cardBackground = Colors.white;
  static const Color imagePlaceholderColor = Color(0xFFEFEFEF);

  final String? imageUrl;
  final bool isSvg;
  final String propertyName;
  final String propertyType;
  final String price;
  final String area;
  final String size;
  final String bedrooms;
  final String bathrooms;

  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const PropertyCardWidget({
    super.key,
    this.imageUrl,
    this.isSvg = false,
    this.propertyName = "Orchad House",
    this.propertyType = "",
    this.price = "Rp. 2.500.000.000 / Year",
    this.area = "M2",
    this.size = "M2",
    this.bedrooms = "2",
    this.bathrooms = "2",
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPropertyImage(),
            const SizedBox(width: 20),
            Expanded(
              child: _buildPropertyDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImage() {
    return Container(
      width: 74,
      height: 99,
      decoration: BoxDecoration(
        color: imagePlaceholderColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: imagePlaceholderColor,
        child: const Center(
          child: Icon(
            Icons.home,
            color: Color(0xFF858585),
            size: 32,
          ),
        ),
      );
    }

    if (isSvg) {
      if (imageUrl!.startsWith('http')) {
        return SvgPicture.network(
          imageUrl!,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => _buildImagePlaceholder(),
        );
      } else {
        return SvgPicture.asset(
          imageUrl!,
          fit: BoxFit.cover,
        );
      }
    } else {
      if (imageUrl!.startsWith('http')) {
        return Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildImagePlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildImagePlaceholder();
          },
          cacheWidth: networkImageCacheWidth(),
        );
      } else {
        return Image.asset(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildImagePlaceholder(),
        );
      }
    }
  }

  /// Placeholder widget for loading or error states
  Widget _buildImagePlaceholder() {
    return Container(
      color: imagePlaceholderColor,
      child: const Center(
        child: DoviaSpinner(),
      ),
    );
  }

  /// Builds the property details section
  Widget _buildPropertyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Property Name and Type row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                propertyName,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              propertyType,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Price
        Text(
          price,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF007376),
            letterSpacing: 0.24,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFeatureItem(
              icon: Icons.square_foot,
              value: area,
              label: 'M2',
            ),
            const SizedBox(width: 24),
            _buildFeatureItem(
              icon: Icons.crop_square,
              value: size,
              label: 'M2',
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _buildFeatureItem(
              icon: Icons.bed_outlined,
              value: bedrooms,
              label: 'Habitaciones',
            ),
            const SizedBox(width: 24),
            _buildFeatureItem(
              icon: Icons.bathtub_outlined,
              value: bathrooms,
              label: 'Baños',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }
}
