import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lieu.dart';
import '../providers/ville_provider.dart';
import '../widgets/ecran_detail/comments_section.dart';
import '../widgets/ecran_detail/lieu_header.dart';

/// Détail d'un lieu favori (nom, type, adresse, coordonnées + commentaires).
/// Attend un `int` (id du lieu) passé via `Navigator.pushNamed(..., arguments: id)`.
class EcranDetailLieu extends StatefulWidget {
  final int? lieuId;
  const EcranDetailLieu({super.key, required this.lieuId});

  @override
  State<EcranDetailLieu> createState() => _EcranDetailLieuState();
}

class _EcranDetailLieuState extends State<EcranDetailLieu> {
  // Pas de contrôleurs ici : l'ajout/édition de commentaires
  // se fait uniquement dans l'écran d’édition pour éviter les doublons.

  @override
  Widget build(BuildContext context) {
    // Si aucun id n'est fourni, on affiche une erreur simple.
    if (widget.lieuId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail du lieu')),
        body: const Center(child: Text('Aucun identifiant de lieu fourni.')),
      );
    }

    final lieuProvider = context.read<VilleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du lieu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier le lieu',
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/edit_lieu',
                arguments: widget.lieuId,
              );
              if (result == true && mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Lieu?>(
        future: lieuProvider.getLieuById(widget.lieuId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
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
          final lieu = snapshot.data;
          if (lieu == null) {
            return const Center(child: Text('Lieu introuvable.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête du lieu (nom/type/coordonnées)
                LieuHeader(lieu: lieu),

                
                const Divider(height: 24),

                // Liste des commentaires (lecture seule)
                CommentsSection(lieuId: lieu.id!),
              ],
            ),
          );
        },
      ),
    );
  }
}
