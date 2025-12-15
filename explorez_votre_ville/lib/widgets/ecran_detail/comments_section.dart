import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/commentaire.dart';
import '../../providers/commentaire_provider.dart';

// CommentsSection
// Ici on affiche les commentaires d un lieu en lecture seule
// On reçoit juste l id du lieu
// On appelle le provider pour charger la liste depuis la base
// On utilise FutureBuilder pour gérer les 3 états
// - chargement
// - erreur
// - données prêtes
class CommentsSection extends StatelessWidget {
  // Id du lieu dont on veut afficher les commentaires
  final int lieuId;

  const CommentsSection({super.key, required this.lieuId});

  @override
  Widget build(BuildContext context) {
    // On récupère le provider une seule fois
    // read suffit car on ne veut pas rebuild sur notifyListeners ici
    final commentaireProvider = context.read<CommentaireProvider>();

    // Expanded permet à la liste de prendre tout l espace restant
    // Ça évite les erreurs de layout avec Column
    return Expanded(
      child: FutureBuilder<List<Commentaire>>(
        // On lance le chargement des commentaires du lieu
        future: commentaireProvider.chargerCommentaires(lieuId),

        builder: (context, snapshotCom) {
          // 1) Pendant le chargement on affiche un loader simple
          if (snapshotCom.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) En cas d erreur on affiche un message
          if (snapshotCom.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Erreur commentaires : ${snapshotCom.error}'),
            );
          }

          // 3) Quand tout va bien on récupère la liste
          final list = snapshotCom.data ?? [];

          // Si la liste est vide on affiche un texte simple
          if (list.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Aucun commentaire pour l’instant'),
            );
          }

          // Sinon on affiche une liste séparée par des traits
          return ListView.separated(
            itemCount: list.length,

            // Un Divider entre chaque commentaire
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Colors.grey),

            itemBuilder: (ctx, i) {
              final c = list[i];

              // On construit une date lisible
              // On passe par toLocal pour éviter l affichage en UTC
              final date = c.createdAt.toLocal();
              // On formate la date manuellement pour avoir un affichage lisible
              // Jour et mois sur 2 chiffres avec un zéro si besoin
              // Format final : JJ/MM/AAAA HH:MM
              final dateText =
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
                  '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

              return ListTile(
                // Contenu du commentaire
                // Si contenu est null on affiche une chaîne vide
                title: Text(c.contenu ?? ''),

                // On affiche la note et la date
                subtitle: Text('Note: ${c.note} • $dateText'),
              );
            },
          );
        },
      ),
    );
  }
}
