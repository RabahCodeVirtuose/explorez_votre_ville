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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${poi.name} ajouté !')),
          );
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
      appBar: AppBar(title: const Text('Explorer une ville')), // Titre
      floatingActionButton: FloatingActionButton(
        tooltip: 'Mes favoris',
        onPressed: () => Navigator.pushNamed(context, '/favoris'),
        child: const Icon(Icons.favorite),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                onTypeChanged: provider.changerType,
              ),
              if (meteo != null) ...[
                const SizedBox(height: 12),
                WeatherSection(
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
              ],
              const SizedBox(height: 12), // Espacement
              MapSection(
                mapController: _mapController,
                center: _center,
                poiMarkers: poiMarkers,
                onPoiTap: (p) => _showPoiDetailsDialog(context, p),
                type: provider.type,
              ),
              const SizedBox(height: 12),
              FavoritePlacesSection(lieux: favoris),
            ],
          ),
        ),
      ),
    );
  }
}
