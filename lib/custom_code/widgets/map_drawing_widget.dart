// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// import '/backend/schema/structs/index.dart';

// import '/backend/schema/structs/index.dart';
// import 'index.dart'; // Imports other custom widgets

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll hide Path;
import 'dart:math' as math;

class MapDrawingWidget extends StatefulWidget {
  const MapDrawingWidget({
    super.key,
    this.width,
    this.height,
    required this.mapboxToken,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialZoom,
    this.drawingColorHex,
    this.confirmButtonLabel,
    this.singlePointMode,
    this.onPointSelected,
    this.interactive = true,
    this.circleRadius = 500,
    this.useRadiusInMeter = true,
  });

  final double? width;
  final double? height;
  final String mapboxToken;
  final double initialLatitude;
  final double initialLongitude;
  final double? initialZoom;
  final String? drawingColorHex;
  final String? confirmButtonLabel;

  /// When true, the widget switches to single-point selection mode:
  /// tap the map to place/move a marker. Drawing tools are hidden.
  final bool? singlePointMode;

  /// Callback invoked when a point is selected in single-point mode.
  /// Receives the latitude and longitude of the selected point.
  /// Use this in FlutterFlow to set page/app state variables.
  final Future Function(double latitude, double longitude)? onPointSelected;

  final bool interactive;
  final double circleRadius;
  final bool useRadiusInMeter;

  @override
  State<MapDrawingWidget> createState() => _MapDrawingWidgetState();
}

class _MapDrawingWidgetState extends State<MapDrawingWidget>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  // ── Drawing mode state ──
  List<Offset> _currentDrawingPoints = <Offset>[];
  List<ll.LatLng> _currentDrawingLatLngs = <ll.LatLng>[];
  List<ll.LatLng> _completedPolygonCoords = <ll.LatLng>[];
  bool _isDrawMode = false;
  bool _hasCompletedDrawing = false;

  // ── Single-point mode state ──
  ll.LatLng? _selectedPoint;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── Pin drop animation ──
  late AnimationController _pinDropController;
  late Animation<double> _pinDropAnimation;
  late Animation<double> _pinBounceAnimation;

  bool get _isSinglePoint => widget.singlePointMode == true;

  Color get _drawingColor {
    if (widget.drawingColorHex != null && widget.drawingColorHex!.isNotEmpty) {
      try {
        final hex = widget.drawingColorHex!.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    return const Color(0xFF007376);
  }

  Color get _fillColor => _drawingColor.withOpacity(0.2);

  static const Color _textColor = Color(0xFF1A1A2E);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _dangerColor = Color(0xFFEF4444);
  static const Color _successColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pinDropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pinDropAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(parent: _pinDropController, curve: Curves.bounceOut),
    );
    _pinBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pinDropController, curve: Curves.easeOut),
    );

    if (_isSinglePoint &&
        widget.initialLatitude != 0 &&
        widget.initialLongitude != 0) {
      _selectedPoint = ll.LatLng(widget.initialLatitude, widget.initialLongitude);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pinDropController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String _buildTileUrl() {
    return 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x'
        '?access_token=${widget.mapboxToken}';
  }

  // ══════════════════════════════════════════════
  //  DRAWING MODE helpers
  // ══════════════════════════════════════════════

  void _toggleDrawMode() {
    setState(() {
      _isDrawMode = !_isDrawMode;
    });
    if (_isDrawMode) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _clearDrawing() {
    setState(() {
      _currentDrawingPoints = <Offset>[];
      _currentDrawingLatLngs = <ll.LatLng>[];
      _completedPolygonCoords = <ll.LatLng>[];
      _hasCompletedDrawing = false;
    });
  }

  void _confirmArea() {
    if (!_hasCompletedDrawing || _completedPolygonCoords.isEmpty) return;
    debugPrint('=== Área Confirmada ===');
    for (final ll.LatLng coord in _completedPolygonCoords) {
      debugPrint('  Lat: ${coord.latitude}, Lng: ${coord.longitude}');
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Área guardada con ${_completedPolygonCoords.length} puntos',
          ),
          backgroundColor: _drawingColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  ll.LatLng? _screenToLatLng(Offset screenPoint) {
    try {
      final camera = _mapController.camera;
      final point = math.Point<double>(screenPoint.dx, screenPoint.dy);
      return camera.pointToLatLng(point);
    } catch (e) {
      return null;
    }
  }

  List<ll.LatLng> _simplifyPoints(List<ll.LatLng> points, double tolerance) {
    if (points.length <= 2) return List<ll.LatLng>.from(points);
    double maxDist = 0;
    int maxIndex = 0;
    final ll.LatLng first = points.first;
    final ll.LatLng last = points.last;
    for (int i = 1; i < points.length - 1; i++) {
      final dist = _perpDist(points[i], first, last);
      if (dist > maxDist) {
        maxDist = dist;
        maxIndex = i;
      }
    }
    if (maxDist > tolerance) {
      final List<ll.LatLng> left =
          _simplifyPoints(points.sublist(0, maxIndex + 1), tolerance);
      final List<ll.LatLng> right =
          _simplifyPoints(points.sublist(maxIndex), tolerance);
      return <ll.LatLng>[...left.sublist(0, left.length - 1), ...right];
    }
    return <ll.LatLng>[first, last];
  }

  double _perpDist(ll.LatLng point, ll.LatLng lineStart, ll.LatLng lineEnd) {
    final dx = lineEnd.longitude - lineStart.longitude;
    final dy = lineEnd.latitude - lineStart.latitude;
    final mag = math.sqrt(dx * dx + dy * dy);
    if (mag == 0) {
      return math.sqrt(math.pow(point.latitude - lineStart.latitude, 2) +
          math.pow(point.longitude - lineStart.longitude, 2));
    }
    final u = ((point.longitude - lineStart.longitude) * dx +
            (point.latitude - lineStart.latitude) * dy) /
        (mag * mag);
    return math.sqrt(
        math.pow(point.latitude - (lineStart.latitude + u * dy), 2) +
            math.pow(point.longitude - (lineStart.longitude + u * dx), 2));
  }

  void _onDrawStart(DragStartDetails details) {
    if (!_isDrawMode) return;
    final ll.LatLng? latLng = _screenToLatLng(details.localPosition);
    if (latLng == null) return;
    setState(() {
      _currentDrawingPoints = <Offset>[details.localPosition];
      _currentDrawingLatLngs = <ll.LatLng>[latLng];
      _completedPolygonCoords = <ll.LatLng>[];
      _hasCompletedDrawing = false;
    });
  }

  void _onDrawUpdate(DragUpdateDetails details) {
    if (!_isDrawMode) return;
    final ll.LatLng? latLng = _screenToLatLng(details.localPosition);
    if (latLng == null) return;
    setState(() {
      _currentDrawingPoints.add(details.localPosition);
      _currentDrawingLatLngs.add(latLng);
    });
  }

  void _onDrawEnd(DragEndDetails details) {
    if (!_isDrawMode) return;
    if (_currentDrawingLatLngs.length < 3) {
      setState(() {
        _currentDrawingPoints = <Offset>[];
        _currentDrawingLatLngs = <ll.LatLng>[];
      });
      return;
    }
    final List<ll.LatLng> simplified =
        _simplifyPoints(_currentDrawingLatLngs, 0.00005);
    setState(() {
      _completedPolygonCoords = simplified;
      _currentDrawingPoints = <Offset>[];
      _currentDrawingLatLngs = <ll.LatLng>[];
      _hasCompletedDrawing = true;
      _isDrawMode = false;
    });
    _pulseController.stop();
    _pulseController.reset();
  }

  // ══════════════════════════════════════════════
  //  SINGLE-POINT MODE helpers
  // ══════════════════════════════════════════════

  void _onMapTapSinglePoint(TapPosition tapPosition, ll.LatLng latLng) {
    if (!widget.interactive) return;
    _pinDropController.reset();
    setState(() {
      _selectedPoint = latLng;
    });
    _pinDropController.forward();

    // Invoke the callback so FlutterFlow can capture lat/lng
    widget.onPointSelected?.call(latLng.latitude, latLng.longitude);
  }

  void _clearPoint() {
    setState(() {
      _selectedPoint = null;
    });
  }

  void _confirmPoint() {
    if (_selectedPoint == null) return;
    debugPrint('=== Punto Confirmado ===');
    debugPrint(
        '  Lat: ${_selectedPoint!.latitude}, Lng: ${_selectedPoint!.longitude}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ubicación guardada: ${_selectedPoint!.latitude.toStringAsFixed(5)}, ${_selectedPoint!.longitude.toStringAsFixed(5)}',
          ),
          backgroundColor: _drawingColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // ══════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildMapArea()),
          if (_isSinglePoint) ...[
            const SizedBox(height: 12),
            _buildSinglePointToolbar(),
            if (_selectedPoint != null) ...[
              const SizedBox(height: 12),
              _buildPointInfo(),
            ],
          ] else ...[
            const SizedBox(height: 12),
            _buildToolbar(),
            if (_hasCompletedDrawing) ...[
              const SizedBox(height: 12),
              _buildAreaInfo(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDrawMode ? _drawingColor : _borderColor,
          width: _isDrawMode ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_isDrawMode ? 10 : 11),
        child: Stack(
          children: [
            _isSinglePoint ? _buildFlutterMapSinglePoint() : _buildFlutterMap(),
            if (!_isSinglePoint && (_isDrawMode || _hasCompletedDrawing))
              _buildDrawingOverlay(),
            if (!_isSinglePoint && _isDrawMode) _buildDrawModeIndicator(),
            if (_isSinglePoint && _selectedPoint == null)
              _buildSinglePointHint(),
          ],
        ),
      ),
    );
  }

  // ── Map for Drawing mode (original) ──

  Widget _buildFlutterMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter:
            ll.LatLng(widget.initialLatitude, widget.initialLongitude),
        initialZoom: widget.initialZoom ?? 13,
        minZoom: 3,
        maxZoom: 20,
        interactionOptions: InteractionOptions(
          flags: _isDrawMode
              ? InteractiveFlag.none
              : InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: _buildTileUrl(),
          userAgentPackageName: 'com.dovia.dovia_home',
          maxZoom: 20,
          tileSize: 256,
        ),
        if (_hasCompletedDrawing && _completedPolygonCoords.isNotEmpty)
          PolygonLayer(
            polygons: [
              Polygon(
                points: List<ll.LatLng>.from(_completedPolygonCoords),
                color: _fillColor,
                borderColor: _drawingColor,
                borderStrokeWidth: 3,
                isFilled: true,
              ),
            ],
          ),
        if (_hasCompletedDrawing && _completedPolygonCoords.isNotEmpty)
          MarkerLayer(
            markers: _completedPolygonCoords
                .map((ll.LatLng coord) => Marker(
                      point: coord,
                      width: 12,
                      height: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _drawingColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  // ── Map for Single-point mode ──

  Widget _buildFlutterMapSinglePoint() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter:
            ll.LatLng(widget.initialLatitude, widget.initialLongitude),
        initialZoom: widget.initialZoom ?? 15,
        minZoom: 3,
        maxZoom: 20,
        interactionOptions: InteractionOptions(
          flags: widget.interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
        ),
        onTap: _onMapTapSinglePoint,
      ),
      children: [
        TileLayer(
          urlTemplate: _buildTileUrl(),
          userAgentPackageName: 'com.dovia.dovia_home',
          maxZoom: 20,
          tileSize: 256,
        ),
        if (_selectedPoint != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedPoint!,
                width: 48,
                height: 48,
                alignment: Alignment.topCenter,
                child: AnimatedBuilder(
                  animation: _pinDropAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _pinDropAnimation.value),
                      child: child,
                    );
                  },
                  child: _buildPinMarker(),
                ),
              ),
            ],
          ),
        if (_selectedPoint != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: _selectedPoint!,
                radius: widget.circleRadius,
                useRadiusInMeter: widget.useRadiusInMeter,
                color: _drawingColor.withOpacity(0.15),
                borderColor: _drawingColor.withOpacity(0.5),
                borderStrokeWidth: 2,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPinMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _drawingColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: _drawingColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 18,
          ),
        ),
        // Pin tail / triangle
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTailPainter(color: _drawingColor),
        ),
      ],
    );
  }

  Widget _buildSinglePointHint() {
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_rounded, size: 16, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Toca el mapa para marcar la ubicación',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Drawing-mode overlays (unchanged) ──

  Widget _buildDrawingOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        behavior:
            _isDrawMode ? HitTestBehavior.opaque : HitTestBehavior.translucent,
        onPanStart: _isDrawMode ? _onDrawStart : null,
        onPanUpdate: _isDrawMode ? _onDrawUpdate : null,
        onPanEnd: _isDrawMode ? _onDrawEnd : null,
        child: CustomPaint(
          painter: _MapDrawingPainter(
            currentPoints: _currentDrawingPoints,
            strokeColor: _drawingColor,
            fillColor: _fillColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawModeIndicator() {
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _drawingColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _drawingColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.draw_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Dibuja el área con tu dedo',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  TOOLBARS
  // ══════════════════════════════════════════════

  /// Toolbar for drawing mode (original)
  Widget _buildToolbar() {
    return Row(
      children: [
        Expanded(
          child: _buildBtn(
            icon: _isDrawMode ? Icons.pan_tool_rounded : Icons.draw_rounded,
            label: _isDrawMode ? 'Mover mapa' : 'Dibujar área',
            color: _isDrawMode ? const Color(0xFF005A5C) : _drawingColor,
            isActive: _isDrawMode,
            onPressed: _toggleDrawMode,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildBtn(
            icon: Icons.delete_outline_rounded,
            label: 'Limpiar',
            color: _dangerColor,
            isActive: false,
            onPressed: _hasCompletedDrawing ? _clearDrawing : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildBtn(
            icon: Icons.check_circle_outline_rounded,
            label: widget.confirmButtonLabel ?? 'Confirmar área',
            color: _successColor,
            isActive: false,
            isPrimary: true,
            onPressed: _hasCompletedDrawing ? _confirmArea : null,
          ),
        ),
      ],
    );
  }

  /// Toolbar for single-point mode
  Widget _buildSinglePointToolbar() {
    return Row(
      children: [
        Expanded(
          child: _buildBtn(
            icon: Icons.delete_outline_rounded,
            label: 'Limpiar',
            color: _dangerColor,
            isActive: false,
            onPressed: _selectedPoint != null ? _clearPoint : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _buildBtn(
            icon: Icons.check_circle_outline_rounded,
            label: widget.confirmButtonLabel ?? 'Confirmar ubicación',
            color: _successColor,
            isActive: false,
            isPrimary: true,
            onPressed: _selectedPoint != null ? _confirmPoint : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBtn({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    bool isPrimary = false,
    VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;
    final bgColor = isActive
        ? color
        : isPrimary && !isDisabled
            ? color
            : Colors.white;
    final fgColor = isActive || (isPrimary && !isDisabled)
        ? Colors.white
        : isDisabled
            ? _textSecondary.withOpacity(0.5)
            : color;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      elevation: isActive ? 0 : 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? color
                  : isDisabled
                      ? _borderColor
                      : color.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: fgColor),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  INFO PANELS
  // ══════════════════════════════════════════════

  Widget _buildAreaInfo() {
    final List<ll.LatLng> coords = _completedPolygonCoords;
    final int n = coords.length;
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;
    for (final ll.LatLng c in coords) {
      if (c.latitude < minLat) minLat = c.latitude;
      if (c.latitude > maxLat) maxLat = c.latitude;
      if (c.longitude < minLng) minLng = c.longitude;
      if (c.longitude > maxLng) maxLng = c.longitude;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _drawingColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _drawingColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, size: 18, color: _successColor),
              const SizedBox(width: 8),
              const Text(
                'Área seleccionada',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _drawingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$n puntos',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _drawingColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lat: ${minLat.toStringAsFixed(5)} → ${maxLat.toStringAsFixed(5)}\n'
            'Lng: ${minLng.toStringAsFixed(5)} → ${maxLng.toStringAsFixed(5)}',
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              color: _textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _drawingColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _drawingColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: _drawingColor),
              const SizedBox(width: 8),
              const Text(
                'Ubicación seleccionada',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lat: ${_selectedPoint!.latitude.toStringAsFixed(6)}\n'
            'Lng: ${_selectedPoint!.longitude.toStringAsFixed(6)}',
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              color: _textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Toca en otro lugar para cambiar la ubicación',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: _textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  PAINTERS
// ══════════════════════════════════════════════

/// Paints the pin tail / triangle below the pin marker
class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _MapDrawingPainter extends CustomPainter {
  final List<Offset> currentPoints;
  final Color strokeColor;
  final Color fillColor;

  _MapDrawingPainter({
    required this.currentPoints,
    required this.strokeColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (currentPoints.length < 2) return;

    final path = Path();
    path.moveTo(currentPoints.first.dx, currentPoints.first.dy);
    for (int i = 1; i < currentPoints.length; i++) {
      path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (currentPoints.length > 2) {
      final closedPath = Path.from(path);
      closedPath.close();
      canvas.drawPath(
        closedPath,
        Paint()
          ..color = fillColor.withOpacity(0.2)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawCircle(
      currentPoints.first,
      6,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      currentPoints.first,
      8,
      Paint()
        ..color = strokeColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _MapDrawingPainter oldDelegate) {
    return currentPoints != oldDelegate.currentPoints;
  }
}
