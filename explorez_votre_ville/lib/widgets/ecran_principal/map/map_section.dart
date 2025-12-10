import 'dart:math' as math;

import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'poi_marker_layer.dart';

/// Section carte avec effet "flip" :
/// - Face avant : carte FlutterMap + marqueurs (POI + centre ville)
/// - Face arrière : mini recherche d'un lieu par nom (dans la liste des POI chargés
///   et/ou via API fournie dans onSearchByName) avec ajout possible en favoris via onPoiTap.
class MapSection extends StatefulWidget {
  final MapController mapController;
  final LatLng center;
  final List<dynamic> poiMarkers; // LieuApiResult list
  final void Function(dynamic) onPoiTap;
  final LieuType type;
  final Future<List<dynamic>> Function(String nom, LieuType type)?
      onSearchByName;

  const MapSection({
    super.key,
    required this.mapController,
    required this.center,
    required this.poiMarkers,
    required this.onPoiTap,
    required this.type,
    this.onSearchByName,
  });

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFront = true;
  final TextEditingController _searchCtrl = TextEditingController();
  String? _searchMessage;
  List<dynamic> _searchResults = const [];
  bool _searchLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  Future<void> _searchPoi() async {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _searchMessage = 'Entre un nom de lieu à chercher');
      return;
    }
    // Si aucun callback fourni, fallback local sur la liste actuelle
    if (widget.onSearchByName == null) {
      final match = widget.poiMarkers.cast<dynamic>().firstWhere(
            (p) => (p.name as String).toLowerCase().contains(query),
            orElse: () => null,
          );
      if (match == null) {
        setState(() => _searchMessage = 'Aucun lieu trouvé pour "$query"');
        return;
      }
      setState(() {
        _searchMessage = 'Lieu trouvé : ${match.name}';
        _searchResults = [match];
      });
      widget.onPoiTap(match);
      return;
    }

    setState(() {
      _searchLoading = true;
      _searchMessage = null;
    });
    try {
      final results = await widget.onSearchByName!(query, widget.type);
      if (results.isEmpty) {
        setState(() {
          _searchResults = const [];
          _searchMessage = 'Aucun lieu trouvé pour "$query"';
        });
      } else {
        setState(() {
          _searchResults = results;
          _searchMessage = 'Résultats : ${results.length}';
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = const [];
        _searchMessage = 'Erreur de recherche : $e';
      });
    } finally {
      setState(() => _searchLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          GestureDetector(
            onTap: _toggleCard,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final angle = _animation.value * math.pi;
                final isFrontVisible = angle < math.pi / 2;
                final face =
                    isFrontVisible ? _buildMapFace(cs) : _buildSearchFace(cs);

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateY(isFrontVisible ? 0 : math.pi),
                    child: face,
                  ),
                );
              },
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'flip_map_section',
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              onPressed: _toggleCard,
              child: const Icon(Icons.flip_camera_android),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFace(ColorScheme cs) {
    final tileUrlLight =
        "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png";
    final tileUrlDark =
        "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png";
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileUrl = isDark ? tileUrlDark : tileUrlLight;

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.tertiary, width: 1.5),
      ),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: cs.surface,
        child: FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(initialCenter: widget.center, initialZoom: 12),
          children: [
            TileLayer(
              urlTemplate: tileUrl,
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.explorez.votre.ville',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.center,
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
            PoiMarkerLayer(
              pois: widget.poiMarkers.cast(),
              onTap: widget.onPoiTap,
              type: widget.type,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFace(ColorScheme cs) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.tertiary, width: 1.5),
      ),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: cs.surface,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chercher un lieu par nom',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Ex: Parc, Musée...',
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: cs.tertiary),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _searchLoading ? null : _searchPoi,
                  icon: const Icon(Icons.search),
                  label: _searchLoading
                      ? const Text('Recherche...')
                      : const Text('Rechercher'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tape pour retourner la carte',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_searchMessage != null)
              Text(
                _searchMessage!,
                style: TextStyle(
                  color: cs.onSurface,
                  fontStyle: FontStyle.italic,
                ),
              ),
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Sélectionne un résultat pour l\'ajouter',
                style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final r = _searchResults[index];
                    return Padding(
                      padding: EdgeInsets.only(
                          right: index == _searchResults.length - 1 ? 0 : 8),
                      child: ActionChip(
                        avatar: Icon(
                          Icons.place,
                          color: cs.primary,
                          size: 18,
                        ),
                        label: Text(
                          r.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () => widget.onPoiTap(r),
                        backgroundColor: cs.surfaceVariant.withOpacity(0.7),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
