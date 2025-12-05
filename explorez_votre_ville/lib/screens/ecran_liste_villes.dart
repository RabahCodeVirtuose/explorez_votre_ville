import 'package:explorez_votre_ville/api/api_villes.dart';
import 'package:flutter/material.dart'; // Material
import 'package:flutter_map/flutter_map.dart'; // Carte OSM
import 'package:latlong2/latlong.dart'; // Coordonnees
import 'package:provider/provider.dart'; // Provider

import '../models/lieu_type.dart'; // Types de lieux
import '../providers/ville_provider.dart'; // Etat ville/meteo
import '../utils/lieu_type_mapper.dart'; // Labels lieux
import '../widgets/carte_meteo.dart'; // Carte meteo

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

  Widget _buildChips(VilleProvider provider) {
    // Liste des types de lieux sous forme de chips
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final t in LieuType.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(LieuTypeHelper.label(t)),
                selected: provider.type == t,
                onSelected: (_) => provider.changerType(t),
              ),
            ),
        ],
      ),
    );
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
              TextField(
                controller: _controller, // Saisie texte
                decoration: InputDecoration(
                  hintText: 'Rechercher une ville…', // Placeholder
                  prefixIcon: const Icon(Icons.search), // Icone
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Coins arrondis
                  ),
                ),
                onSubmitted: _onSearch, // Declenche recherche
              ),
              const SizedBox(height: 12), // Espacement
              if (provider.loading)
                const LinearProgressIndicator(), // Barre chargement
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8), // Marge haute
                  child: Text(
                    provider.error!, // Message erreur
                    style: const TextStyle(color: Colors.red), // Style erreur
                  ),
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
              _buildChips(provider), // Selection type de lieux
              const SizedBox(height: 12), // Espacement
              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12), // Coins arrondis
                  child: Container(
                    color: const Color(0xFFF6F1E9), // Fond beige
                    child: FlutterMap(
                      mapController: _mapController, // Controleur carte
                      options: MapOptions(
                        initialCenter: _center, // Centre initial
                        initialZoom: 12, // Zoom initial
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              //"https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png", // Style voyager // j'ai juste retiré un {r} ici, que donnait un warning au terminal
                              "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png", // Avec ce lien pas de warning sur flutterMap
                          subdomains: const [
                            'a',
                            'b',
                            'c',
                            'd',
                          ], // Sous-domaines
                          userAgentPackageName:
                              'com.explorez.votre.ville', // UA
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _center, // Position du marker
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on, // Icone position
                                color: Colors.red, // Couleur marker
                                size: 36, // Taille
                              ),
                            ),
                          ],
                        ),
                        ///////////////////////////////////MarkerLayer pour les POI
                        MarkerLayer(
                          markers: poiMarkers.map((p) {
                            // -- On pouura eventuellement adapter la taille pour le marqueur ---
                            // La largeur doit être suffisante pour contenir l'icône et le texte.
                            const double markerHeight = 40.0;
                            const double markerWidth = 150.0;

                            return Marker(
                              point: LatLng(p.lat, p.lon),
                              width: markerWidth,
                              height: markerHeight,

                              // Le 'child' contient la combinaison Icône + Texte
                              child: GestureDetector(
                                onTap: () {
                                  // 🚨 IMPORTANT : Déclencher la boîte de dialogue ici
                                  _showPoiDetailsDialog(context, p);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // La Row ne prend que l'espace nécessaire
                                  children: [
                                    // 1. L'Icône du Marqueur (le pin)
                                    const Icon(
                                      Icons.location_pin,
                                      color: Colors.blue,
                                      size: 32,
                                    ),

                                    // 2. Un petit espace
                                    const SizedBox(width: 4),

                                    // 3. Le nom du POI (p.name provient de votre classe Place)
                                    // Le widget Flexible empêche le texte très long de déborder de l'écran.
                                    Flexible(
                                      child: Text(
                                        p.name, // <-- Utilisation du nom
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          backgroundColor: Colors
                                              .white70, // Optionnel : pour que le texte soit lisible sur la carte
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Coupe avec "..." si trop long
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        //////////////////////////////////////////////////////////////////////////////MarkerLayer pour les POI
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              //Expanded(child: _buildLieux(provider)), // Liste des lieux
              buildFavoriteCardsBar(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildFavoriteCardsBar() {
  // Liste statique des lieux favoris (pour la maquette)
  final List<Map<String, dynamic>> staticFavorites = [
    {'name': 'Musée', 'icon': Icons.museum, 'color': Colors.purple},
    {'name': 'Restaurant', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Parc Central', 'icon': Icons.park, 'color': Colors.green},
    {'name': 'Théâtre', 'icon': Icons.theater_comedy, 'color': Colors.red},
    {'name': 'Cinéma', 'icon': Icons.movie, 'color': Colors.blue},
    {'name': 'Musée', 'icon': Icons.museum, 'color': Colors.purple},
    {'name': 'Restaurant', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Parc Central', 'icon': Icons.park, 'color': Colors.green},
    {'name': 'Théâtre', 'icon': Icons.theater_comedy, 'color': Colors.red},
    {'name': 'Cinéma', 'icon': Icons.movie, 'color': Colors.blue},
  ];

  return SizedBox(
    height: 100, // <--- Hauteur Fixe de la barre (ListView)
    child: ListView.builder(
      scrollDirection: Axis.horizontal, // <--- Mode Horizontal
      itemCount: staticFavorites.length,
      itemBuilder: (context, index) {
        final favorite = staticFavorites[index];

        return Padding(
          // Marge pour espacement, le 16.0 au début assure la marge de gauche
          padding: EdgeInsets.fromLTRB(index == 0 ? 16 : 4, 8, 4, 8),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // Utilisation d'un InkWell pour la gestion future du clic (si vous le souhaitez)
            child: InkWell(
              onTap: () {
                // Logique future : naviguer vers la carte ou filtrer
                print('Clic sur favori: ${favorite['name']}');
              },
              child: Container(
                width: 120, // <--- Largeur fixe de la Card
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centrage vertical du contenu
                  children: [
                    // Icône
                    Icon(
                      favorite['icon'] as IconData,
                      color: favorite['color'] as Color,
                      size: 35, // Icône légèrement plus grande
                    ),
                    const SizedBox(height: 4),
                    // Nom du favori
                    Text(
                      favorite['name'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2, // Permet deux lignes de texte
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
