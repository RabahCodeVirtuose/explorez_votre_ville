import 'package:explorez_votre_ville/api/api_villes.dart';
import 'package:explorez_votre_ville/widgets/favorites/favorite_places_section.dart';
import 'package:explorez_votre_ville/widgets/info/carte_meteo.dart';
import 'package:explorez_votre_ville/widgets/dialogs/poi_details_dialog.dart';
import 'package:explorez_votre_ville/widgets/map/map_section.dart';
import 'package:explorez_votre_ville/widgets/search/place_search_section.dart';
import 'package:flutter/material.dart'; // Material
import 'package:flutter_map/flutter_map.dart'; // MapController
import 'package:latlong2/latlong.dart'; // Coordonnees
import 'package:provider/provider.dart'; // Provider

// Types de lieux
import '../providers/ville_provider.dart'; // Etat ville/meteo
import 'package:explorez_votre_ville/widgets/info/weather_section.dart';

// Palette commune
const Color _deepGreen = Color(0xFF18534F);
const Color _teal = Color(0xFF226D68);
const Color _amber = Color(0xFFFEEAA1);
const Color _mint = Color(0xFFECF8F6);

class EcranListeVilles extends StatefulWidget {
  const EcranListeVilles({super.key});

  @override
  State<EcranListeVilles> createState() => _EcranListeVillesState();
}

class _EcranListeVillesState extends State<EcranListeVilles> {
  final TextEditingController _controller =
      TextEditingController(); // Saisie ville
  final MapController _mapController = MapController(); // Controleur carte
  LatLng _center = const LatLng(48.8566, 2.3522); // Centre courant

  @override
  void initState() {
    super.initState();
    // Reinitialise l'etat a l'ouverture, centre sur Paris
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VilleProvider>(); // Provider global
      provider.reset(); // Vide la derniere recherche
      setState(() => _center = const LatLng(48.8566, 2.3522)); // Centre defaut
      _mapController.move(_center, 12); // Deplace la carte
      provider.chargerPinnedDepuisPrefs().then(
        (_) => provider.afficherVilleEpinglee(),
      ); // Charge ville épinglée si présente
    });
  }

  Future<void> _onSearch(String value) async {
    // Sequence: recherche (meteo + lieux) puis recentrage carte
    final provider = context.read<VilleProvider>(); // Acces provider
    await provider.chercherVille(value); // Appels backend via provider
    final centre = provider.mapCenter; // Centre calcule
    setState(() => _center = centre); // Met a jour centre local
    _mapController.move(centre, 12); // Deplace la carte
  }

  void _showPoiDetailsDialog(BuildContext context, LieuApiResult poi) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => PoiDetailsDialog(
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
    final provider = context.watch<VilleProvider>(); // Ecoute l'etat
    final meteo = provider.weather; // Donnees meteo
    final poiMarkers = provider.lieux; // Récupère la liste des lieux
    final favoris = provider.lieuxFavoris;
    final currentCenter = provider.mapCenter;
    if (_center.latitude != currentCenter.latitude ||
        _center.longitude != currentCenter.longitude) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _center = currentCenter);
        _mapController.move(currentCenter, 12);
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _mint),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Explorer une ville', style: TextStyle(color: _mint)),
        backgroundColor: _teal,
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: _mint),
            onPressed: () => Navigator.pushNamed(context, '/favoris'),
            icon: const Icon(Icons.favorite),
            label: const Text('Mes villes favorites'),
          ),
        ],
      ), // Titre + action favoris
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_teal, _amber],
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
                    padding: const EdgeInsets.all(12), // Marges
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
                            height: 262, // un peu plus haut pour éviter l'overflow
                            child: WeatherSection(
                              isFavori: provider.isFavoriActuel,
                              onToggleFavori: provider.basculerFavoriActuel,
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
                        const SizedBox(height: 8), // Espacement
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
