// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

// ══════════════════════════════════════════════════════════════
//  DoviaMapExplorerWidget
//  Interactive map with house markers.
//  Uses flutter_map + latlong2 with Mapbox tile layer.
//  FlutterFlow custom widget for the Dovia real estate app.
// ══════════════════════════════════════════════════════════════

class DoviaMapExplorerWidget extends StatefulWidget {
  final double? width;
  final double? height;

  /// Mapbox public access token (used for tile URL)
  final String mapboxAccessToken;

  /// Initial map centre
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;

  /// Callback when user taps a property icon on the map.
  /// Receives the property ID.
  final Future Function(String propertyId, String name, double price,
      String listingType, double landArea, bool isFavorite)? onIconSelected;

  final List<MapPropertyMarkerStruct> filteredProperties;

  const DoviaMapExplorerWidget({
    super.key,
    this.width,
    this.height,
    required this.mapboxAccessToken,
    this.initialLatitude = 19.4326,
    this.initialLongitude = -99.1332,
    this.initialZoom = 12.0,
    this.onIconSelected,
    required this.filteredProperties,
  });

  @override
  State<DoviaMapExplorerWidget> createState() => _DoviaMapExplorerWidgetState();
}

class _DoviaMapExplorerWidgetState extends State<DoviaMapExplorerWidget> {
  // ── Map Controller ───────────────────────────────────────
  final MapController _mapController = MapController();

  // ── Selected Property ────────────────────────────────────
  _PropertyData? _selectedProperty;

  List<_PropertyData> get _properties => widget.filteredProperties.map((p) {
        return _PropertyData(
          id: p.id,
          name: p.name,
          lat: p.latitude,
          lng: p.longitude,
          price: p.price,
          landArea: p.landArea,
          isFavorite: p.isFavorite,
          listingType: p.listingType,
          propertyType: p.propertyType,
        );
      }).toList();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DoviaMapExplorerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filteredProperties != widget.filteredProperties) {
      setState(() {});
    }
  }

  // ══════════════════════════════════════════════════════════
  //  MARKER TAP HANDLER
  // ══════════════════════════════════════════════════════════

  void _onMarkerTapped(_PropertyData property) {
    setState(() {
      _selectedProperty = property;
    });

    // Notify parent to show their own bottom sheet/modal
    widget.onIconSelected?.call(
      property.id,
      property.name,
      property.price,
      property.listingType,
      property.landArea,
      property.isFavorite,
    );

    // Animate camera to property location
    _mapController.move(
      ll.LatLng(property.lat, property.lng),
      15.0,
    );
  }

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // Using streets-v12 for a natural, clear map style instead of dark mode
    final mapboxTileUrl =
        'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=${widget.mapboxAccessToken}';

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 600,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A007376),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ── Flutter Map ─────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: ll.LatLng(
                  widget.initialLatitude,
                  widget.initialLongitude,
                ),
                initialZoom: widget.initialZoom,
                maxZoom: 18.0,
                minZoom: 4.0,
                // Deselect icon when tapping on the map (not a marker)
                onTap: (tapPosition, point) {
                  if (_selectedProperty != null) {
                    setState(() {
                      _selectedProperty = null;
                    });
                  }
                },
              ),
              children: [
                // Mapbox light/natural tile layer
                TileLayer(
                  urlTemplate: mapboxTileUrl,
                  additionalOptions: const {},
                  maxZoom: 18,
                  retinaMode: true,
                  userAgentPackageName: 'com.dovia.app',
                ),

                // Property markers
                // Property markers
                MarkerLayer(
                  markers: _properties.map((prop) {
                    final isSelected = _selectedProperty?.id == prop.id;
                    return Marker(
                      point: ll.LatLng(prop.lat, prop.lng),
                      width: 140, // Aumentado para dar espacio al texto
                      height: 50,
                      alignment:
                          Alignment.center, // Centrado exacto en la coordenada
                      child: GestureDetector(
                        onTap: () => _onMarkerTapped(prop),
                        child: Center(
                          // Asegura que el contenedor se ajuste al contenido
                          child: _HouseMarkerWidget(
                            isSelected: isSelected,
                            price: prop.price, // Pasamos el precio al widget
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // ── Top gradient overlay ────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Count badge ─────────────────────────────────
            Positioned(top: 16, right: 16, child: _buildCountBadge()),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  BADGE WIDGETS
  // ══════════════════════════════════════════════════════════

  Widget _buildCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.home_rounded, color: Color(0xFF4DD0E1), size: 16),
          const SizedBox(width: 6),
          Text(
            '${_properties.length} propiedades',
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  HOUSE MARKER WIDGET
//  A Flutter widget that renders the custom house pin.
//  Highlights when selected.
// ══════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════
//  HOUSE MARKER WIDGET
// ══════════════════════════════════════════════════════════════

class _HouseMarkerWidget extends StatelessWidget {
  final bool isSelected;
  final double price;

  const _HouseMarkerWidget({
    this.isSelected = false,
    required this.price,
  });

  // Formateador rápido para evitar que precios largos desborden el diseño
  String _formatPrice(double value) {
    if (value >= 1000000) {
      return 'Q${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'Q${(value / 1000).toStringAsFixed(0)}k';
    }
    return 'Q${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    const Color aqua = Color(0xFF007376);
    final double scale = isSelected ? 1.1 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? aqua : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: aqua, width: 2),
          boxShadow: [
            BoxShadow(
              color: aqua.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              color: isSelected ? Colors.white : aqua,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              _formatPrice(price),
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : aqua,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DATA MODELS
// ══════════════════════════════════════════════════════════════
class _PropertyData {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double price;
  final double landArea;
  final bool isFavorite;
  final String listingType;
  final String propertyType;

  const _PropertyData({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.price,
    required this.landArea,
    required this.isFavorite,
    required this.listingType,
    required this.propertyType,
  });
}
