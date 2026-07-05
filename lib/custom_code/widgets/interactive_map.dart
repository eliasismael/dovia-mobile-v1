// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

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
  });

  final double? width;
  final double? height;
  final String accessToken;
  final double startLat;
  final double startLng;

  @override
  _InteractiveMapState createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: latLng.LatLng(widget.startLat, widget.startLng),
          initialZoom: 13.0,
          onTap: (tapPosition, point) {
            print("Lat: ${point.latitude}, Lng: ${point.longitude}");
          },
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
                point: latLng.LatLng(widget.startLat, widget.startLng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    print("Marcador tocado");
                  },
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
