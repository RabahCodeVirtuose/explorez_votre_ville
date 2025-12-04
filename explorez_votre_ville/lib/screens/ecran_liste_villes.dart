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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VilleProvider>(); // Ecoute l'etat
    final meteo = provider.weather; // Donnees meteo

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
                    Expanded(child: CarteMeteo(meteo: meteo)), // Carte meteo
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
                              "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png", // Style voyager
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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildLieux(provider)), // Liste des lieux
            ],
          ),
        ),
      ),
    );
  }
}
