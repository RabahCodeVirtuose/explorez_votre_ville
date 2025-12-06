import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../api/api_villes.dart';
import '../models/lieu_type.dart';

class PoiMarkerLayer extends StatelessWidget {
  final List<LieuApiResult> pois;
  final void Function(LieuApiResult) onTap;
  final LieuType type;

  const PoiMarkerLayer({
    super.key,
    required this.pois,
    required this.onTap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    const double markerHeight = 40.0;
    const double markerWidth = 150.0;
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
                onTap: () => onTap(p),
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
                        overflow: TextOverflow.ellipsis,
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
