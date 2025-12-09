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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileUrl =
        "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png";
    //isDark
    // ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"

    return SizedBox(
      height: 220,
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.tertiary, width: 1.5),
        ),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: cs.surface,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(initialCenter: center, initialZoom: 12),
            children: [
              // Fond de carte (voyager)
              TileLayer(
                urlTemplate: tileUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.explorez.votre.ville',
              ),
              // Marker de la ville au centre
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.tertiary.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.onSurface, width: 1.0),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: cs.onSurface,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              // Markers des POI (colorés/icônés selon le type)
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
