import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ville.dart';
import '../providers/ville_provider.dart';

class EcranFavoris extends StatefulWidget {
  const EcranFavoris({super.key});

  @override
  State<EcranFavoris> createState() => _EcranFavorisState();
}

class _EcranFavorisState extends State<EcranFavoris> {
  late Future<List<Ville>> _favorisFuture;

  @override
  void initState() {
    super.initState();
    final provider = context.read<VilleProvider>();
    provider.chargerPinnedDepuisPrefs();
    _favorisFuture = provider.chargerFavoris();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes villes favorites')),
      body: FutureBuilder<List<Ville>>(
        future: _favorisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // snapshot est l’AsyncSnapshot que le FutureBuilder passe au builder. Il contient l’état du Future (connectionState), la donnée (snapshot.data) si elle est
          // dispo, ou l’erreur (snapshot.error) si le Future a échoué.
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erreur lors du chargement des favoris:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          final favoris = snapshot.data ?? [];
          if (favoris.isEmpty) {
            return const Center(child: Text('Aucune ville favorite.'));
          }
          /*context.watch<VilleProvider>() (Provider package) lit le provider et s’abonne aux changements. À chaque notifyListeners() du VilleProvider, le widget est
  reconstruit. Ici, on récupère l’id de la ville épinglée (pinnedVilleId) et on veut que la liste se mette à jour automatiquement si cet id change. */
          final pinnedId = context.watch<VilleProvider>().pinnedVilleId;
          return ListView.separated(
            itemCount: favoris.length, // Nombre d’éléments dans la liste
            separatorBuilder: (_, __) =>
                const Divider(height: 1), // Séparateur entre lignes
            itemBuilder: (context, index) {
              final v = favoris[index]; // Ville courante
              final isPinned =
                  pinnedId != null &&
                  v.id == pinnedId; // Est-ce la ville épinglée ?

              return ListTile(
                leading: const Icon(Icons.location_city), // Icône à gauche
                title: Text(v.nom), // Nom de la ville
                subtitle: Text(
                  // Affiche pays + lat/lon formatés (ou '-' si absent)
                  '${v.pays ?? ''} '
                  'Lat:${v.latitude?.toStringAsFixed(4) ?? '-'} '
                  'Lon:${v.longitude?.toStringAsFixed(4) ?? '-'}',
                ),
                trailing: IconButton(
                  tooltip: isPinned ? 'Désépingler' : 'Épingler', // Infobulle
                  icon: Icon(
                    isPinned
                        ? Icons.push_pin
                        : Icons.push_pin_outlined, // Icône selon statut
                    color: isPinned
                        ? Colors.orange
                        : null, // Couleur si épinglée
                  ),
                  onPressed: () async {
                    final provider = context.read<VilleProvider>();
                    // Toggle épingle : si déjà épinglée → désépingler, sinon épingler
                    if (isPinned) {
                      await provider.deseEpinglerVille();
                    } else {
                      await provider.epinglerVille(v);
                    }
                    // Forcer la reconstruction locale pour rafraîchir l’UI
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
