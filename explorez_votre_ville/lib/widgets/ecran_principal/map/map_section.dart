import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'poi_marker_layer.dart';

/// MapSection (version simple, sans 3D) :
/// - Mode "carte" : FlutterMap + marqueur centre + POI
/// - Mode "recherche" : champ + bouton + résultats cliquables
///
/// Le bouton en bas à droite permet juste de basculer entre les deux vues.
class MapSection extends StatefulWidget {
  final MapController mapController;
  final LatLng center;
  final List<dynamic> poiMarkers; // idéalement List<LieuApiResult>
  final void Function(dynamic) onPoiTap;
  final LieuType type;

  /// Callback optionnel : recherche via API.
  /// Si null => on fait une recherche locale dans poiMarkers.
  final Future<List<dynamic>> Function(String nom, LieuType type)? onSearchByName;

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

class _MapSectionState extends State<MapSection> {
  // true => on affiche la carte, false => on affiche la recherche
  bool _isMapVisible = true;

  final TextEditingController _searchCtrl = TextEditingController();
  String? _searchMessage;
  List<dynamic> _searchResults = const [];
  bool _searchLoading = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Change simplement la vue affichée (sans animation, sans rotation).
  void _toggleView() {
    setState(() => _isMapVisible = !_isMapVisible);
  }

  /// Recherche un POI soit localement, soit via onSearchByName si fourni.
  Future<void> _searchPoi() async {
    final query = _searchCtrl.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() => _searchMessage = 'Entre un nom de lieu à chercher');
      return;
    }

    // Fallback local si aucun callback API
    if (widget.onSearchByName == null) {
      final match = widget.poiMarkers.cast<dynamic>().firstWhere(
        (p) => (p.name as String).toLowerCase().contains(query),
        orElse: () => null,
      );

      if (match == null) {
        setState(() {
          _searchResults = const [];
          _searchMessage = 'Aucun lieu trouvé pour "$query"';
        });
        return;
      }

      setState(() {
        _searchResults = [match];
        _searchMessage = 'Lieu trouvé : ${match.name}';
      });

      // Option : on déclenche directement l’action (ex : ajout favoris)
      widget.onPoiTap(match);
      return;
    }

    setState(() {
      _searchLoading = true;
      _searchMessage = null;
      _searchResults = const [];
    });

    try {
      final results = await widget.onSearchByName!(query, widget.type);

      setState(() {
        _searchResults = results;
        _searchMessage = results.isEmpty
            ? 'Aucun lieu trouvé pour "$query"'
            : 'Résultats : ${results.length}';
      });
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
          // Affiche simplement l’une des deux faces (aucun flip/3D)
          Positioned.fill(
            child: _isMapVisible ? _buildMapFace(cs) : _buildSearchFace(cs),
          ),

          // Bouton pour switch
          Positioned(
            right: 10,
            bottom: 10,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'toggle_map_section',
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              onPressed: _toggleView,
              child: Icon(_isMapVisible ? Icons.search : Icons.map),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFace(ColorScheme cs) {
    final tileUrl =
        "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png";

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
          options: MapOptions(
            initialCenter: widget.center,
            initialZoom: 12,
          ),
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
                hintText: 'chercher un lieu...',
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: cs.tertiary),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _searchLoading ? null : _searchPoi,
              icon: const Icon(Icons.search),
              label: Text(_searchLoading ? 'Recherche...' : 'Rechercher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
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
                'Résultats (clique pour ajouter)',
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
                        right: index == _searchResults.length - 1 ? 0 : 8,
                      ),
                      child: ActionChip(
                        avatar: Icon(Icons.place, color: cs.primary, size: 18),
                        label: Text(r.name, overflow: TextOverflow.ellipsis),
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
