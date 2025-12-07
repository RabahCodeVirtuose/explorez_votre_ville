import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'poi_marker_layer.dart';

class MapSection extends StatelessWidget {
  final MapController mapController;
  final LatLng center;
  final List<dynamic> poiMarkers; // LieuApiResult list
  final void Function(dynamic) onPoiTap;
  final LieuType type;

  const MapSection({
    super.key,
    required this.mapController,
    required this.center,
    required this.poiMarkers,
    required this.onPoiTap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: const Color(0xFFF6F1E9),
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(initialCenter: center, initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.explorez.votre.ville',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 36,
                    ),
                  ),
                ],
              ),
              PoiMarkerLayer(
                pois: poiMarkers.cast(),
                onTap: onPoiTap,
                type: type,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
