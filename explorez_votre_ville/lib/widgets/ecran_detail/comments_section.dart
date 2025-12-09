import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/commentaire.dart';
import '../../providers/commentaire_provider.dart';

/// Affiche la liste des commentaires pour un lieu donné (lecture seule).
class CommentsSection extends StatelessWidget {
  final int lieuId;
  const CommentsSection({super.key, required this.lieuId});

  @override
  Widget build(BuildContext context) {
    final commentaireProvider = context.read<CommentaireProvider>();

    return Expanded(
      child: FutureBuilder<List<Commentaire>>(
        future: commentaireProvider.chargerCommentaires(lieuId),
        builder: (context, snapshotCom) {
          if (snapshotCom.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshotCom.hasError) {
            return Text('Erreur commentaires : ${snapshotCom.error}');
          }
          final list = snapshotCom.data ?? [];
          if (list.isEmpty) {
            return const Text('Aucun commentaire pour l’instant.');
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Colors.grey),
            itemBuilder: (ctx, i) {
              final c = list[i];
              return ListTile(
                title: Text(c.contenu ?? ''),
                subtitle: Text('Note: ${c.note} • ${c.createdAt.toLocal()}'),
              );
            },
          );
        },
      ),
    );
  }
}
