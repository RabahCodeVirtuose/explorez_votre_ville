import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'poi_marker_layer.dart';

class MapSection extends StatelessWidget {
  final MapController mapController;
  final LatLng center;
  final List<dynamic> poiMarkers; // LieuApiResult list
  /*final void Function(dynamic) onPoiTap; déclare un callback qui prend un argument de type dynamic (l’élément POI que tu veux passer) et ne retourne rien. Quand la carte détecte un tap sur
  un marker, elle appelle ce callback en lui passant le POI concerné. Le type dynamic est utilisé ici pour rester souple sur ce que on envoie (par exemple un LieuApiResult ou un modèle
  similaire) */
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
              // Fond de carte
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.explorez.votre.ville',
              ),
              // Marker de la ville au centre
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
