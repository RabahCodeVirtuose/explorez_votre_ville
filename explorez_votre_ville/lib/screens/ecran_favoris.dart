import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ville.dart';
import '../providers/ville_provider.dart';

/// Écran qui affiche la liste des villes favorites (stockées en base).
/// Fonctionnalités :
/// - Charger la liste des favoris au démarrage (FutureBuilder)
/// - Afficher la ville "épinglée" (pinned) avec une icône différente
/// - Épingler / désépingler une ville (SharedPreferences via le provider)
/// - Supprimer une ville des favoris (avec confirmation)
class EcranFavoris extends StatefulWidget {
  const EcranFavoris({super.key});

  @override
  State<EcranFavoris> createState() => _EcranFavorisState();
}

class _EcranFavorisState extends State<EcranFavoris> {
  /// Future qui récupère la liste des villes favorites.
  /// On le garde en variable pour pouvoir le "remplacer" quand on veut rafraîchir.
  late Future<List<Ville>> _favorisFuture;

  @override
  void initState() {
    super.initState();

    // On lit le provider une seule fois dans initState (read -> pas d'abonnement).
    final provider = context.read<VilleProvider>();

    // Charge l'id de la ville épinglée depuis SharedPreferences.
    // (utile pour afficher l’icône "push_pin" sur la bonne ville)
    provider.chargerPinnedDepuisPrefs();

    // Lance le chargement des villes favorites depuis la base (SQLite).
    _favorisFuture = provider.chargerFavoris();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre du haut
      appBar: AppBar(title: const Text('Mes villes favorites')),

      // FutureBuilder : construit l'UI en fonction de l'état du Future (_favorisFuture)
      body: FutureBuilder<List<Ville>>(
        future: _favorisFuture,
        builder: (context, snapshot) {
          // 1) Pendant le chargement -> spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // snapshot :
          // - snapshot.data  : la liste si le Future a réussi
          // - snapshot.error : l'erreur si le Future a échoué
          // - snapshot.connectionState : état du Future (waiting / done / ...)
          if (snapshot.hasError) {
            // 2) En cas d'erreur -> message clair
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

          // 3) Sinon -> on récupère la liste (vide si null)
          final favoris = snapshot.data ?? [];

          // Si aucun favori -> message simple
          if (favoris.isEmpty) {
            return const Center(child: Text('Aucune ville favorite.'));
          }

          // watch : on s'abonne au provider pour être rebuild si pinnedVilleId change.
          // Exemple : si on épingle/désépingle une ville, pinnedVilleId change et
          // l'icône "push_pin" s'actualise automatiquement.
          final pinnedId = context.watch<VilleProvider>().pinnedVilleId;

          // Liste des favoris
          return ListView.separated(
            // Nombre d’éléments
            itemCount: favoris.length,

            // Séparateur entre les lignes
            separatorBuilder: (_, __) => const Divider(height: 1),

            // Construction d’une ligne de liste
            itemBuilder: (context, index) {
              // Ville courante
              final v = favoris[index];

              // Est-ce que cette ville est la ville épinglée ?
              final isPinned = pinnedId != null && v.id == pinnedId;

              return ListTile(
                // Icône à gauche
                leading: const Icon(Icons.location_city),

                // Nom de la ville
                title: Text(v.nom),

                // Infos secondaires (pays + coordonnées si présentes)
                subtitle: Text(
                  '${v.pays ?? ''} '
                  'Lat:${v.latitude?.toStringAsFixed(4) ?? '-'} '
                  'Lon:${v.longitude?.toStringAsFixed(4) ?? '-'}',
                ),

                // Actions à droite (épingler / supprimer)
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // -------------------------
                    // 1) Bouton épingler
                    // -------------------------
                    IconButton(
                      tooltip: isPinned ? 'Désépingler' : 'Épingler',
                      icon: Icon(
                        isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: isPinned ? Colors.orange : null,
                      ),
                      onPressed: () async {
                        final provider = context.read<VilleProvider>();

                        // Toggle :
                        // - si déjà épinglée -> on désépingle
                        // - sinon -> on épingle + on affiche la ville épinglée
                        if (isPinned) {
                          await provider.deseEpinglerVille();
                        } else {
                          await provider.epinglerVille(v);
                          await provider.afficherVilleEpinglee();
                        }

                        // Ici, le pinnedId se mettra à jour via notifyListeners()
                        // grâce au context.watch(...) plus haut.
                        // On peut garder setState si tu veux forcer un rebuild immédiat,
                        // mais normalement ce n'est pas indispensable.
                        if (!mounted) return;
                        setState(() {});
                      },
                    ),

                    // -------------------------
                    // 2) Bouton supprimer
                    // -------------------------
                    IconButton(
                      tooltip: 'Supprimer',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final provider = context.read<VilleProvider>();

                        // Demande confirmation avant suppression
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Supprimer cette ville ?'),
                            content: Text(
                              'Voulez-vous retirer "${v.nom}" des favoris ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );

                        // Si confirmé et id non nul -> suppression en base
                        if (confirm == true && v.id != null) {
                          await provider.supprimerVille(v.id!);

                          // Après suppression, on recharge la liste :
                          // on remplace le Future pour que FutureBuilder relance le chargement.
                          if (!mounted) return;
                          setState(() {
                            _favorisFuture = provider.chargerFavoris();
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
