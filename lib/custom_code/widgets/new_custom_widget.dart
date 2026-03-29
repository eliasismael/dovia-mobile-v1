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

import 'package:flutter_svg/flutter_svg.dart';

enum ImageSourceType {
  asset,
  network,
  svg,
  svgNetwork,
}

class PropertyMatchCardWidget extends StatelessWidget {
  static const Color aquaColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color secondaryTextColor = Color(0xFF858585);
  static const Color cardBackground = Colors.white;
  static const Color imagePlaceholderColor = Color(0xFFEFEFEF);
  static const Color badgeBackground = Color(0xFFE4FCFD);

  final String? image;
  final ImageSourceType imageType;
  final String propertyName;
  final String propertyType;
  final String price;
  final String area;
  final String lotSize;
  final String bedrooms;
  final String bathrooms;
  final int? matchPercentage;

  final VoidCallback? onTap;

  final double? width;

  const PropertyMatchCardWidget({
    super.key,
    this.image,
    this.imageType = ImageSourceType.asset,
    this.propertyName = 'Orchad House',
    this.propertyType = 'Tipo',
    this.price = 'Rp. 2.500.000.000 / Year',
    this.area = 'M2',
    this.lotSize = 'M2',
    this.bedrooms = 'Habitaciones',
    this.bathrooms = 'Baños',
    this.matchPercentage = 100,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 310,
        padding: const EdgeInsets.all(6.68),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(6.68),
          boxShadow: [
            BoxShadow(
              color: aquaColor.withValues(alpha: 0.1),
              blurRadius: 7.5,
              offset: const Offset(0, 3.75),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageSection(),
            const SizedBox(height: 4.01),
            _buildPropertyDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Property Image
        Container(
          width: double.infinity,
          height: 74.81,
          decoration: BoxDecoration(
            color: imagePlaceholderColor,
            borderRadius: BorderRadius.circular(6.68),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16.03,
                offset: const Offset(0, 10.69),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4.01,
                offset: const Offset(0, 1.34),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 0.67,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.68),
            child: _buildImage(),
          ),
        ),
        // Match Badge
        if (matchPercentage != null)
          Positioned(top: 12, right: 12, child: _buildMatchBadge()),
      ],
    );
  }

  Widget _buildImage() {
    if (image == null || image!.isEmpty) {
      return _buildImagePlaceholder();
    }

    switch (imageType) {
      case ImageSourceType.asset:
        return Image.asset(
          image!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
              _buildImagePlaceholder(),
        );
      case ImageSourceType.network:
        return Image.network(
          image!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
              _buildImagePlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder();
          },
        );
      case ImageSourceType.svg:
        return SvgPicture.asset(
          image!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      case ImageSourceType.svgNetwork:
        return SvgPicture.network(
          image!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholderBuilder: (context) => _buildLoadingPlaceholder(),
        );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: imagePlaceholderColor,
      child: const Center(
        child: Icon(Icons.home_outlined, color: Color(0xFF858585), size: 32),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: imagePlaceholderColor,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: aquaColor),
      ),
    );
  }

  /// Builds the match percentage badge
  Widget _buildMatchBadge() {
    return Container(
      height: 17,
      padding: const EdgeInsets.symmetric(horizontal: 9.15, vertical: 3.92),
      decoration: BoxDecoration(
        color: badgeBackground,
        borderRadius: BorderRadius.circular(7390.57),
        border: Border.all(color: aquaColor, width: 0.65),
      ),
      child: Center(
        child: Text(
          'Match $matchPercentage%',
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: aquaColor,
          ),
        ),
      ),
    );
  }

  /// Builds the property details section
  Widget _buildPropertyDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
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
              const SizedBox(width: 8),
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
              color: aquaColor,
              letterSpacing: 0.24,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFeatureItem(icon: Icons.grid_view_outlined, value: area),
              const SizedBox(width: 16),
              _buildFeatureItem(
                icon: Icons.directions_car_outlined,
                value: lotSize,
              ),
              const SizedBox(width: 16),
              _buildFeatureItem(icon: Icons.bed_outlined, value: bedrooms),
              const SizedBox(width: 16),
              _buildFeatureItem(icon: Icons.bathtub_outlined, value: bathrooms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: textColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }
}
