import 'package:explorez_votre_ville/api/api_villes.dart';
import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Couche de markers pour afficher les POI sur FlutterMap.
/// Chaque marker affiche une icône colorée (selon le type) et le nom du lieu.
/// Un tap sur un marker déclenche le callback [onTap] avec le POI concerné.
class PoiMarkerLayer extends StatelessWidget {
  /// Liste des POI (résultats Geoapify/Nominatim encapsulés).
  final List<LieuApiResult> pois;

  /// Callback déclenché au tap sur un marker, reçoit le LieuApiResult.
  final void Function(LieuApiResult) onTap;

  /// Type courant (permet de choisir icône/couleur pour cette série de markers).
  final LieuType type;

  const PoiMarkerLayer({
    super.key,
    required this.pois,
    required this.onTap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // Dimensions du marker visuel
    const double markerHeight = 40.0;
    const double markerWidth = 150.0;

    // Icône et couleur issues du type (helpers définis dans LieuTypeHelper).
    final iconData = LieuTypeHelper.icon(type);
    final iconColor = LieuTypeHelper.color(type);

    return MarkerLayer(
      markers: pois
          .map(
            (p) => Marker(
              point: LatLng(p.lat, p.lon),
              width: markerWidth,
              height: markerHeight,
              child: GestureDetector(
                onTap: () => onTap(p), // Propager le POI cliqué au parent
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconData, color: iconColor, size: 26),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        p.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          backgroundColor: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis, // coupe avec "..."
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
