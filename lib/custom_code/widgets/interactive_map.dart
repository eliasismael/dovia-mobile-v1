// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;

class InteractiveMap extends StatefulWidget {
  const InteractiveMap({
    super.key,
    this.width,
    this.height,
    required this.accessToken,
    this.startLat = -34.6037,
    this.startLng = -58.3816,
    this.onLocationSelected,
    this.readOnly = false,
  });

  final double? width;
  final double? height;
  final String accessToken;
  final double startLat;
  final double startLng;

  /// Called every time the user picks/changes the point on the map.
  final Future Function(double latitude, double longitude)? onLocationSelected;

  /// Display-only map: the pin marks a fixed location the user is meant to
  /// look at, not choose. Tapping no longer moves it and the "pick a point"
  /// hint is hidden; panning and zooming stay on so the point can still be
  /// explored in context.
  final bool readOnly;

  @override
  _InteractiveMapState createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  final MapController _mapController = MapController();
  late latLng.LatLng _selectedPoint;

  static const double _minZoom = 3.0;
  static const double _maxZoom = 18.0;

  // Map zoom recorded at the start of a trackpad pinch gesture.
  double? _panZoomBaseZoom;

  @override
  void initState() {
    super.initState();
    _selectedPoint = latLng.LatLng(widget.startLat, widget.startLng);
  }

  // Ultimo zoom visto, para detectar gestos de zoom en solo lectura.
  double _lastZoom = 15.0;

  // En solo lectura el zoom siempre se centra en la propiedad.
  latLng.LatLng get _zoomCenter =>
      widget.readOnly ? _selectedPoint : _mapController.camera.center;

  void _zoomBy(double delta) {
    final newZoom =
        (_mapController.camera.zoom + delta).clamp(_minZoom, _maxZoom);
    _mapController.move(_zoomCenter, newZoom);
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    final zoomChanged = (camera.zoom - _lastZoom).abs() > 0.0001;
    _lastZoom = camera.zoom;
    if (widget.readOnly && hasGesture && zoomChanged) {
      // Pellizco, rueda o doble toque: se recentra en el punto.
      _mapController.move(_selectedPoint, camera.zoom);
    }
  }

  @override
  void didUpdateWidget(covariant InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Move the marker when the point is changed from the outside
    // (e.g. after geocoding an address).
    const epsilon = 0.000001;
    if ((widget.startLat - _selectedPoint.latitude).abs() > epsilon ||
        (widget.startLng - _selectedPoint.longitude).abs() > epsilon) {
      _selectedPoint = latLng.LatLng(widget.startLat, widget.startLng);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(_selectedPoint, _mapController.camera.zoom);
        }
      });
    }
  }

  void _updatePoint(latLng.LatLng point) {
    setState(() => _selectedPoint = point);
    widget.onLocationSelected?.call(point.latitude, point.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          children: [
            // Listener adds trackpad pinch-to-zoom support, which
            // flutter_map does not handle natively on desktop.
            Listener(
              onPointerPanZoomStart: (event) {
                _panZoomBaseZoom = _mapController.camera.zoom;
              },
              onPointerPanZoomUpdate: (event) {
                final base = _panZoomBaseZoom;
                if (base == null) return;
                // event.scale is cumulative; log2(scale) -> zoom delta.
                final newZoom = (base + math.log(event.scale) / math.ln2)
                    .clamp(_minZoom, _maxZoom);
                _mapController.move(_zoomCenter, newZoom);
              },
              onPointerPanZoomEnd: (event) {
                _panZoomBaseZoom = null;
              },
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedPoint,
                  initialZoom: 15.0,
                  minZoom: _minZoom,
                  maxZoom: _maxZoom,
                  // En solo lectura el mapa se puede arrastrar, pero el punto
                  // no se mueve y el zoom se centra siempre en el.
                  interactionOptions: InteractionOptions(
                    flags: widget.readOnly
                        ? InteractiveFlag.all &
                            ~InteractiveFlag.rotate &
                            ~InteractiveFlag.pinchMove
                        : InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onPositionChanged: _onPositionChanged,
                  onTap: widget.readOnly
                      ? null
                      : (tapPosition, point) => _updatePoint(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=${widget.accessToken}",
                    userAgentPackageName: 'com.mycompany.myapp',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPoint,
                        width: 44,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF007376),
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Zoom controls (guaranteed way to zoom on any device).
            Positioned(
              right: 10,
              top: 10,
              child: Column(
                children: [
                  _ZoomButton(
                    icon: Icons.add,
                    onTap: () => _zoomBy(1.0),
                  ),
                  const SizedBox(height: 8),
                  _ZoomButton(
                    icon: Icons.remove,
                    onTap: () => _zoomBy(-1.0),
                  ),
                ],
              ),
            ),
            // Recenter the map on the currently selected point.
            Positioned(
              right: 10,
              bottom: 10,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 2.0,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _mapController.move(
                      _selectedPoint, _mapController.camera.zoom),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.my_location,
                      color: Color(0xFF007376),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            // Hint so the user knows the map is interactive.
            if (!widget.readOnly)
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Toca el mapa para elegir el punto',
                    style: TextStyle(
                      color: Color(0xFF00444B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 2.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            icon,
            color: const Color(0xFF007376),
            size: 22,
          ),
        ),
      ),
    );
  }
}
