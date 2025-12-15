//
// Écran principal :
// - recherche de ville (Nominatim)
// - affiche météo
// - affiche carte + POI (Geoapify)
// - affiche favoris (lieux en base)
// - permet d’ouvrir le menu (drawer)
//


import 'package:explorez_votre_ville/api/api_villes.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/dialogs/poi_details_dialog.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/favorites/favorite_places_section.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/info/app_menu_drawer.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/info/carte_meteo.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/info/weather_section.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/map/map_section.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/search/place_search_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/ville_provider.dart';

class EcranListeVilles extends StatefulWidget {
  const EcranListeVilles({super.key});

  @override
  State<EcranListeVilles> createState() => _EcranListeVillesState();
}

class _EcranListeVillesState extends State<EcranListeVilles> {
  /// Contrôleur du champ de recherche (ville)
  final TextEditingController _controller = TextEditingController();

  /// Contrôleur de la carte (flutter_map) -> permet de déplacer / zoomer
  final MapController _mapController = MapController();

  /// Centre local de la carte (par défaut : Paris)
  LatLng _center = const LatLng(48.8566, 2.3522);

  @override
  void initState() {
    super.initState();

    // On attend que le premier build soit passé avant d'utiliser context.read().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VilleProvider>();

      // Réinitialise l’état (météo, lieux, favoris locaux, etc.)
      provider.reset();

      // Centre la carte sur Paris au début
      setState(() => _center = const LatLng(48.8566, 2.3522));
      _mapController.move(_center, 12);

      // Charge la ville épinglée (SharedPreferences) puis l’affiche si elle existe
      provider.chargerPinnedDepuisPrefs().then((_) {
        provider.afficherVilleEpinglee();
      });
    });
  }

  /// Recherche de ville :
  /// - on demande à Nominatim une liste de villes possibles
  /// - si une seule => on lance directement la recherche
  /// - si plusieurs => on affiche une dialog pour choisir
  Future<void> _onSearch(String value) async {
    final provider = context.read<VilleProvider>();

    // 1) Propose plusieurs résultats (Nominatim)
    final villes = await provider.proposerVilles(value);

    // 2) Un seul résultat (ou 0) -> recherche simple
    if (villes.length <= 1) {
      await provider.chercherVille(value);

      // Recentrer la carte sur la ville trouvée (via provider.mapCenter)
      final centre = provider.mapCenter;
      setState(() => _center = centre);
      _mapController.move(centre, 12);
      return;
    }

    // 3) Plusieurs résultats -> dialog de sélection
    final selected = await showDialog<VilleApiResult>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Sélectionne la ville'),
        children: villes
            .map(
              (v) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, v),
                child: Text(v.name, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
      ),
    );

    // Si l’utilisateur a choisi une ville
    if (selected != null) {
      await provider.appliquerVilleSelectionnee(selected);

      // Recentrer la carte
      final centre = provider.mapCenter;
      setState(() => _center = centre);
      _mapController.move(centre, 12);
    }
  }

  /// Affiche une popup de détails d’un POI (Point Of Interest).
  /// Si l’utilisateur valide, on l’ajoute aux favoris (SQLite) via le provider.
  void _showPoiDetailsDialog(BuildContext context, LieuApiResult poi) {
    // Le type courant (parc, musée, etc.) vient du provider
    final currentType = context.read<VilleProvider>().type;

    showDialog(
      context: context,
      builder: (dialogContext) => PoiDetailsDialog(
        poi: poi,
        currentType: currentType,
        onAdd: () {
          // Ajout en base locale
          _addPlaceToLocalDatabase(poi);

          // Feedback simple (SnackBar)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${poi.name} ajouté !')));
        },
      ),
    );
  }

  /// Ajoute un lieu en favori (SQLite).
  /// Ici on délègue au provider pour centraliser la logique (getOrInsertVille, etc.)
  void _addPlaceToLocalDatabase(LieuApiResult poi) {
    final provider = context.read<VilleProvider>();
    provider.ajouterLieuFavori(poi);
  }

  /// Rend les erreurs réseau plus lisibles :
  /// - supprime "Exception:"
  /// - traite quelques cas courants (404 / city not found)
  String _friendlyError(String raw) {
    final sanitized = raw.replaceFirst(
      RegExp(r'exception[: ]*', caseSensitive: false),
      '',
    );

    final lower = sanitized.toLowerCase();
    if (lower.contains('city not found') || lower.contains('404')) {
      return 'Ville introuvable. Vérifie l’orthographe ou essaie une autre ville.';
    }
    return 'Oups… $sanitized'.trim();
  }

  @override
  Widget build(BuildContext context) {
    // watch : ce widget se rebuild quand le provider fait notifyListeners()
    final provider = context.watch<VilleProvider>();

    // Données principales
    final meteo = provider.weather;
    final poiMarkers = provider.lieux; // POI récupérés via API
    final favoris =
        provider.lieuxFavoris; // favoris (SQLite) pour la ville courante

    // Centre "source de vérité" : météo > ville > défaut (défini dans provider.mapCenter)
    final currentCenter = provider.mapCenter;

    // Couleurs du thème
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Si le provider change de centre (suite à une recherche), on recadre la carte.
    // On passe par addPostFrameCallback pour éviter setState pendant le build.
    if (_center.latitude != currentCenter.latitude ||
        _center.longitude != currentCenter.longitude) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _center = currentCenter);
        _mapController.move(currentCenter, 12);
      });
    }

    // Dégradé simple pour le fond (adapté au thème clair/sombre)
    final gradientColors = isDark
        ? [cs.tertiary, cs.surface]
        : [cs.tertiary, cs.primary];

    return Scaffold(
      // AppBar avec bouton retour + bouton menu (drawer)
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Explorer une ville'),
        actions: [
          // Builder requis pour utiliser Scaffold.of(ctx) dans l’action
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),

      // Drawer à droite (menu)
      endDrawer: const AppMenuDrawer(),

      // Corps de page (fond en gradient + contenu scrollable)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // SingleChildScrollView : permet de scroller si écran petit
              return SingleChildScrollView(
                child: ConstrainedBox(
                  // minHeight : évite un "trou" blanc si peu de contenu
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ----------------------------
                        // 1) Recherche + types + erreurs
                        // ----------------------------
                        PlaceSearchSection(
                          controller: _controller,
                          onSubmit: _onSearch,
                          loading: provider.loading,
                          error: provider.error != null
                              ? _friendlyError(provider.error!)
                              : null,
                          selectedType: provider.type,
                          onTypeChanged: (type) async {
                            // Change le type (parc, musée, etc.) -> recharge POI
                            await provider.changerType(type);

                            // Recentrer si besoin (mapCenter peut changer)
                            final centre = provider.mapCenter;
                            setState(() => _center = centre);
                            _mapController.move(centre, 12);
                          },
                        ),

                        // ----------------------------
                        // 2) Météo (si disponible)
                        // ----------------------------
                        if (meteo != null) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 262, // hauteur fixée pour éviter overflow
                            child: WeatherSection(
                              // Statuts ville (favori/visité/exploré)
                              isFavori: provider.isFavoriActuel,
                              isVisitee: provider.isVisiteeActuelle,
                              isExploree: provider.isExploreeActuelle,

                              // Actions toggle
                              onToggleFavori: provider.basculerFavoriActuel,
                              onToggleVisitee: provider.basculerVisiteeActuelle,
                              onToggleExploree:
                                  provider.basculerExploreeActuelle,

                              // Carte météo (UI)
                              meteoCard: MeteoCard(
                                temperature: meteo.temperature,
                                windSpeed: meteo.windSpeed,
                                temperatureMin: meteo.temperatureMin,
                                temperatureMax: meteo.temperatureMax,
                                humidity: meteo.humidity,
                                cityName: meteo.cityName,
                                description: meteo.description,
                                icon: meteo.icon,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        // ----------------------------
                        // 3) Carte + POI
                        // ----------------------------
                        SizedBox(
                          height: 320, // carte plus haute
                          child: MapSection(
                            mapController: _mapController,
                            center: _center,

                            // POI affichés sur la carte
                            poiMarkers: poiMarkers,

                            // Quand on clique sur un POI -> popup détails
                            onPoiTap: (p) => _showPoiDetailsDialog(context, p),

                            // Type courant (sert pour l’icône / couleur / filtre)
                            type: provider.type,

                            // Recherche de lieux par nom dans la ville courante
                            onSearchByName: (nom, type) =>
                                provider.chercherLieuxParNom(nom, type: type),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // ----------------------------
                        // 4) Favoris (lieux) de la ville courante
                        // ----------------------------
                        FavoritePlacesSection(lieux: favoris),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
