// ignore_for_file: deprecated_member_use

import 'package:explorez_votre_ville/api/api_villes.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/dialogs/poi_details_dialog.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/favorites/favorite_places_section.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/info/carte_meteo.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/info/weather_section.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/map/map_section.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/search/place_search_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/ville_provider.dart';

class EcranListeVilles extends StatefulWidget {
  const EcranListeVilles({super.key});

  @override
  State<EcranListeVilles> createState() => _EcranListeVillesState();
}

class _EcranListeVillesState extends State<EcranListeVilles> {
  final TextEditingController _controller = TextEditingController();
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(48.8566, 2.3522);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VilleProvider>();
      provider.reset();
      setState(() => _center = const LatLng(48.8566, 2.3522));
      _mapController.move(_center, 12);
      provider.chargerPinnedDepuisPrefs().then(
        (_) => provider.afficherVilleEpinglee(),
      );
    });
  }

  Future<void> _onSearch(String value) async {
    final provider = context.read<VilleProvider>();
    await provider.chercherVille(value);
    final centre = provider.mapCenter;
    setState(() => _center = centre);
    _mapController.move(centre, 12);
  }

  void _showPoiDetailsDialog(BuildContext context, LieuApiResult poi) {
    showDialog(
      context: context,
      builder: (dialogContext) => PoiDetailsDialog(
        poi: poi,
        onAdd: () {
          _addPlaceToLocalDatabase(poi);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${poi.name} ajouté !')));
        },
      ),
    );
  }

  void _addPlaceToLocalDatabase(LieuApiResult poi) {
    final provider = context.read<VilleProvider>();
    provider.ajouterLieuFavori(poi);
  }

  String _friendlyError(String raw) {
    // Nettoie le préfixe "Exception" pour un message plus pro
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
    final provider = context.watch<VilleProvider>();
    final meteo = provider.weather;
    final poiMarkers = provider.lieux;
    final favoris = provider.lieuxFavoris;
    final currentCenter = provider.mapCenter;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Corrige le centre de la carte si l’état provider change.
    if (_center.latitude != currentCenter.latitude ||
        _center.longitude != currentCenter.longitude) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _center = currentCenter);
        _mapController.move(currentCenter, 12);
      });
    }

    // Dégradé doux basé sur le thème
    final gradientColors = isDark
        ? [cs.tertiary, cs.surface]
        : [cs.tertiary, cs.primary];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Explorer une ville'),
        actions: [
          IconButton(
            tooltip: 'Basculer thème clair/sombre',
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: cs.onPrimary),
            onPressed: () => Navigator.pushNamed(context, '/favoris'),
            icon: const Icon(Icons.favorite),
            label: Text(
              'Mes villes favorites',
              style: TextStyle(color: cs.onPrimary),
            ),
          ),
        ],
      ),
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
              // ConstrainedBox pour forcer un minimum de hauteur et éviter
              // le "trou" blanc quand il y a peu de contenu.
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PlaceSearchSection(
                          controller: _controller,
                          onSubmit: _onSearch,
                          loading: provider.loading,
                          error: provider.error != null
                              ? _friendlyError(provider.error!)
                              : null,
                          selectedType: provider.type,
                          onTypeChanged: (type) async {
                            await provider.changerType(type);
                            final centre = provider.mapCenter;
                            setState(() => _center = centre);
                            _mapController.move(centre, 12);
                          },
                        ),
                        if (meteo != null) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height:
                                262, // un peu plus haut pour éviter l'overflow
                            child: WeatherSection(
                              isFavori: provider.isFavoriActuel,
                              isVisitee: provider.isVisiteeActuelle,
                              isExploree: provider.isExploreeActuelle,
                              onToggleFavori: provider.basculerFavoriActuel,
                              onToggleVisitee: provider.basculerVisiteeActuelle,
                              onToggleExploree:
                                  provider.basculerExploreeActuelle,
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
                        SizedBox(
                          height: 320, // carte plus haute que la section météo
                          child: MapSection(
                            mapController: _mapController,
                            center: _center,
                            poiMarkers: poiMarkers,
                            onPoiTap: (p) => _showPoiDetailsDialog(context, p),
                            type: provider.type,
                          ),
                        ),
                        const SizedBox(height: 4),
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
