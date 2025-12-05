import 'package:explorez_votre_ville/api/api_villes.dart';
import 'package:flutter/material.dart'; // Material
import 'package:flutter_map/flutter_map.dart'; // MapController
import 'package:latlong2/latlong.dart'; // Coordonnees
import 'package:provider/provider.dart'; // Provider

import '../models/lieu_type.dart'; // Types de lieux
import '../providers/ville_provider.dart'; // Etat ville/meteo
import '../widgets/carte_meteo.dart'; // Carte meteo
import '../widgets/error_banner.dart';
import '../widgets/favorite_cards_bar.dart';
import '../widgets/lieu_type_chips.dart';
import '../widgets/map_section.dart';
import '../widgets/search_bar.dart';

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

  Widget _buildLieux(VilleProvider provider) {
    // Liste des lieux pour le type courant
    if (provider.loadingLieux) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.lieux.isEmpty) {
      return const Center(child: Text('Aucun lieu pour ce type.'));
    }
    return ListView.separated(
      itemCount: provider.lieux.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final lieu = provider.lieux[index];
        return ListTile(
          title: Text(lieu.name.isEmpty ? '(Sans nom)' : lieu.name),
          subtitle: Text(lieu.formattedAddress),
          leading: const Icon(Icons.place),
        );
      },
    );
  }

  void _showPoiDetailsDialog(BuildContext context, LieuApiResult poi) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(poi.name), // Le nom du lieu
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Catégorie : ${poi.categories.first}'),
                Text(
                  'Coordonnées : ${poi.lat.toStringAsFixed(4)}, ${poi.lon.toStringAsFixed(4)}',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Ajouter à mes lieux favoris'),
              onPressed: () {
                // ACTION D'AJOUT : Persistance des données
                _addPlaceToLocalDatabase(poi);
                Navigator.of(dialogContext).pop();

                // Optionnel : Afficher un SnackBar de confirmation
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('${poi.name} ajouté !')));
              },
            ),
          ],
        );
      },
    );
  }

  void _addPlaceToLocalDatabase(LieuApiResult poi) {
    // Simple place holder pour le moment, A adapter, passage POI => lieu pour insert dans la BD ?
    // 1. Convertir l'objet Place en Map JSON
    final placeData = {
      'name': poi.name,
      'latitude': poi.lat,
      'longitude': poi.lon,
      'categories': poi.categories,
    };
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

    return Scaffold(
      appBar: AppBar(title: const Text('Explorer une ville')), // Titre
      floatingActionButton: FloatingActionButton(
        tooltip: 'Mes favoris',
        onPressed: () => Navigator.pushNamed(context, '/favoris'),
        child: const Icon(Icons.favorite),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12), // Marges
          child: Column(
            children: [
              SearchBarField(controller: _controller, onSubmitted: _onSearch),
              const SizedBox(height: 12), // Espacement
              if (provider.loading)
                const LinearProgressIndicator(), // Barre chargement
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8), // Marge haute
                  child: ErrorBanner(message: _friendlyError(provider.error!)),
                ),
              if (meteo != null) ...[
                const SizedBox(height: 12), // Espacement
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MeteoCard(
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
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Ajouter aux favoris',
                      icon: Icon(
                        provider.isFavoriActuel
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: provider.isFavoriActuel ? Colors.red : null,
                      ),
                      onPressed: () => provider.basculerFavoriActuel(),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12), // Espacement
              LieuTypeChips(
                selected: provider.type,
                onSelected: provider.changerType,
              ),
              const SizedBox(height: 12), // Espacement
              MapSection(
                mapController: _mapController,
                center: _center,
                poiMarkers: poiMarkers,
                onPoiTap: (p) => _showPoiDetailsDialog(context, p),
              ),
              const SizedBox(height: 12),
              //Expanded(child: _buildLieux(provider)), // Liste des lieux
              const FavoriteCardsBar(),
            ],
          ),
        ),
      ),
    );
  }
}
