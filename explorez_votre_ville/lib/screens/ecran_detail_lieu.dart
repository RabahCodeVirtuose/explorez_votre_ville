import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lieu.dart';
import '../providers/ville_provider.dart';
import '../widgets/ecran_detail/comments_section.dart';
import '../widgets/ecran_detail/lieu_header.dart';

/// Écran de détail d’un lieu.
/// Rôle :
/// - récupérer le lieu en base à partir de lieuId
/// - afficher un header (nom/type/infos)
/// - afficher la section commentaires
/// - permettre l’édition du lieu via un bouton (route /edit_lieu)
class EcranDetailLieu extends StatefulWidget {
  /// Id du lieu à afficher (peut être null si mal passé depuis la navigation)
  final int? lieuId;

  const EcranDetailLieu({super.key, required this.lieuId});

  @override
  State<EcranDetailLieu> createState() => _EcranDetailLieuState();
}

class _EcranDetailLieuState extends State<EcranDetailLieu> {
  @override
  Widget build(BuildContext context) {
    // Sécurité : si aucun id fourni, on affiche un écran simple d’erreur
    if (widget.lieuId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail du lieu')),
        body: const Center(child: Text('Aucun identifiant de lieu fourni.')),
      );
    }

    // On récupère le provider (read : pas d’abonnement, car on utilise FutureBuilder)
    final lieuProvider = context.read<VilleProvider>();

    return Scaffold(
      // AppBar classique + action "éditer"
      appBar: AppBar(
        title: const Text('Détail du lieu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier le lieu',
            onPressed: () async {
              // Navigation vers l’écran d’édition
              // arguments : on envoie l’id du lieu
              final result = await Navigator.pushNamed(
                context,
                '/edit_lieu',
                arguments: widget.lieuId,
              );

              // Si l’écran d’édition renvoie true :
              // on rebuild l’écran détail pour recharger le lieu
              if (result == true && mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),

      // FutureBuilder : charge le lieu depuis la base (SQLite)
      body: FutureBuilder<Lieu?>(
        // On va chercher le lieu par id via le provider
        future: lieuProvider.getLieuById(widget.lieuId!),
        builder: (context, snapshot) {
          // 1) Pendant le chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) En cas d’erreur
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erreur lors du chargement : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // 3) Résultat
          final lieu = snapshot.data;

          // Si null -> lieu non trouvé en base
          if (lieu == null) {
            return const Center(child: Text('Lieu introuvable.'));
          }

          // UI principale : header + commentaires
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bloc d’info du lieu (nom, type, description, etc.)
                LieuHeader(lieu: lieu),

                const Divider(height: 24),

                // Section commentaires (affichage + ajout)
                // On passe l’id du lieu (non nul ici)
                CommentsSection(lieuId: lieu.id!),
              ],
            ),
          );
        },
      ),
    );
  }
}
