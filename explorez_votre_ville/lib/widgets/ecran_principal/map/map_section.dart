import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../providers/ville_provider.dart';
import 'poi_marker_layer.dart';

// MapSection version 
// On a deux vues
// 1 la carte avec les markers et la possibilité d ajouter un lieu personnalisé
// 2 une vue recherche avec un champ et des résultats cliquables
// Le bouton en bas à droite sert juste à basculer entre les deux vues
class MapSection extends StatefulWidget {
  // Contrôleur de carte passé par le parent
  // Comme ça le parent peut  déplacer la carte si besoin
  final MapController mapController;

  // Centre courant de la carte
  final LatLng center;

  // Liste de POI à afficher sur la carte
  // Ici c est dynamic pour rester compatible avec ton code actuel
  // Mais idéalement on mettrait List<LieuApiResult>
  final List<dynamic> poiMarkers;

  // Callback quand on tape sur un POI (marker ou résultat de recherche)
  final void Function(dynamic) onPoiTap;

  // Type courant sélectionné dans l appli
  // Il sert à afficher les bons markers et à créer un lieu personnalisé du bon type
  final LieuType type;

  // Callback optionnel pour rechercher par nom via une API
  // Si null on fait une recherche locale dans la liste poiMarkers
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

class _MapSectionState extends State<MapSection> {
  // true on affiche la carte
  // false on affiche la recherche
  bool _isMapVisible = true;

  // Controller du champ de recherche
  final TextEditingController _searchCtrl = TextEditingController();

  // Message affiché après une recherche (succès ou erreur)
  String? _searchMessage;

  // Liste des résultats de recherche
  // On garde dynamic pour rester cohérent avec widget.onSearchByName
  List<dynamic> _searchResults = const [];

  // Permet de désactiver le bouton quand on est en train de charger
  bool _searchLoading = false;

  @override
  void dispose() {
    // On libère le controller pour éviter une fuite mémoire
    _searchCtrl.dispose();
    super.dispose();
  }

  // On bascule juste la vue affichée
  void _toggleView() {
    setState(() => _isMapVisible = !_isMapVisible);
  }

  // Quand on tape sur la carte on propose d ajouter un lieu personnalisé
  // On ouvre un dialog pour saisir le nom
  Future<void> _onMapTap(BuildContext context, LatLng pos) async {
    final cs = Theme.of(context).colorScheme;

    // Controller du champ du dialog
    // On le crée ici car il sert seulement pendant la fenêtre de confirmation
    final nameCtrl = TextEditingController();

    // showDialog renvoie true si on confirme l ajout
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter un lieu ici ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // On affiche les coordonnées pour que l utilisateur comprenne où on ajoute
            Text(
              'Lat: ${pos.latitude.toStringAsFixed(5)} | '
              'Lon: ${pos.longitude.toStringAsFixed(5)}',
              style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),

            // Champ pour le nom du lieu
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom du lieu',
                hintText: 'Ex : Lieu personnalisé',
              ),
            ),
          ],
        ),
        actions: [
          // Annuler renvoie false
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),

          // Ajouter renvoie true
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    // Si on annule on ne fait rien
    if (confirmed != true) return;

    // On appelle le provider pour faire la logique métier
    // Le provider vérifie le bbox et insère en base
    final provider = context.read<VilleProvider>();
    final err = await provider.ajouterLieuPersonnalise(
      lat: pos.latitude,
      lon: pos.longitude,
      nom: nameCtrl.text.trim(),
      type: widget.type,
    );

    // mounted permet de vérifier qu on est toujours sur la page
    if (!mounted) return;

    // On affiche un message simple selon le résultat
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lieu ajouté et sauvegardé')),
      );
    }
  }

  // Recherche un POI soit en local soit via l API si onSearchByName est fourni
  Future<void> _searchPoi() async {
    final query = _searchCtrl.text.trim().toLowerCase();

    // Petite validation simple
    if (query.isEmpty) {
      setState(() => _searchMessage = 'Entre un nom de lieu à chercher');
      return;
    }

    // Si on n a pas de callback API on fait un match local dans la liste
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

      // Ici on déclenche directement l action du parent
      // Par exemple le parent peut ajouter le lieu en favoris
      widget.onPoiTap(match);
      return;
    }

    // Mode API
    // On affiche un état chargement
    setState(() {
      _searchLoading = true;
      _searchMessage = null;
      _searchResults = const [];
    });

    try {
      // On lance la recherche via le callback fourni
      final results = await widget.onSearchByName!(query, widget.type);

      // On met à jour l UI avec le nombre de résultats
      setState(() {
        _searchResults = results;
        _searchMessage = results.isEmpty
            ? 'Aucun lieu trouvé pour "$query"'
            : 'Résultats : ${results.length}';
      });
    } catch (e) {
      // En cas d erreur on affiche un message simple
      setState(() {
        _searchResults = const [];
        _searchMessage = 'Erreur de recherche : $e';
      });
    } finally {
      // On enlève l état chargement
      setState(() => _searchLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // On fixe une hauteur stable pour la carte
    // On utilise Stack pour superposer la vue et le bouton en bas à droite
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // On affiche soit la carte soit la recherche
          // Positioned.fill force le widget à prendre toute la place
          Positioned.fill(
            child: _isMapVisible ? _buildMapFace(cs) : _buildSearchFace(cs),
          ),

          // Bouton flottant mini pour basculer entre les deux
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
    // URL du fond de carte
    // Ici on utilise Carto Voyager car c est léger et lisible
    final tileUrl =
        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

    // Material donne un rendu type carte avec bordure et ombre
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
            // Centre initial de la carte
            initialCenter: widget.center,
            initialZoom: 12,

            // Tap sur la carte pour ajouter un lieu personnalisé
            onTap: (tapPos, latlng) => _onMapTap(context, latlng),
          ),
          children: [
            // Couche du fond de carte
            TileLayer(
              urlTemplate: tileUrl,
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.explorez.votre.ville',
            ),

            // Marker central (la ville)
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

            // Couche des POI (markers dynamiques)
            // PoiMarkerLayer s occupe de dessiner l icône et le nom
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
    // Même look que la carte pour rester cohérent
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
            // Titre simple de la section recherche
            Text(
              'Chercher un lieu par nom',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            // Champ de saisie de la recherche
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

            // Bouton de recherche
            // On le désactive pendant le chargement
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

            // Message de statut si on en a un
            if (_searchMessage != null)
              Text(
                _searchMessage!,
                style: TextStyle(
                  color: cs.onSurface,
                  fontStyle: FontStyle.italic,
                ),
              ),

            // Résultats cliquables
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Résultats (clique pour ajouter)',
                style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
              ),
              const SizedBox(height: 6),

              // Liste horizontale de chips
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final r = _searchResults[index];

                    // Padding à droite sauf pour le dernier élément
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
