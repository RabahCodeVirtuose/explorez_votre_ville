import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'poi_marker_layer.dart';

class MapSection extends StatelessWidget {
  // Palette alignée sur le reste de l'UI
  static const Color _deepGreen = Color(0xFF18534F);
  static const Color _teal = Color(0xFF226D68);
  static const Color _mint = Color(0xFFECF8F6);
  static const Color _amber = Color(0xFFFEEAA1);

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
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _amber, width: 1.5),
        ),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: _mint,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(initialCenter: center, initialZoom: 12),
            children: [
              // Fond de carte
              TileLayer(
                // Palette plus chaleureuse via le style "voyager" de Carto
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
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
                        color: _amber.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: _deepGreen, width: 1.0),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: _deepGreen,
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
