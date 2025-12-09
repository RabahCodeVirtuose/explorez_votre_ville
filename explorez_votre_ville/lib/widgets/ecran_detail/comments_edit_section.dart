import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/commentaire.dart';
import '../../providers/commentaire_provider.dart';

/// Section d’édition des commentaires : liste + ajout + édition/suppression.
class CommentsEditSection extends StatelessWidget {
  final int lieuId;
  final TextEditingController commentCtrl;
  final ValueNotifier<int> noteNotifier;
  final VoidCallback onChanged; // appelé pour signaler un changement

  const CommentsEditSection({
    super.key,
    required this.lieuId,
    required this.commentCtrl,
    required this.noteNotifier,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final comProvider = context.read<CommentaireProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Commentaires', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<Commentaire>>(
            future: comProvider.chargerCommentaires(lieuId),
            builder: (context, snapCom) {
              if (snapCom.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapCom.hasError) {
                return Text('Erreur commentaires : ${snapCom.error}');
              }
              final list = snapCom.data ?? [];
              if (list.isEmpty) {
                return const Text('Aucun commentaire pour ce lieu.');
              }
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final c = list[i];
                  return ListTile(
                    title: Text(c.contenu ?? ''),
                    subtitle: Text('Note : ${c.note} • ${c.createdAt.toLocal()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await _editComment(context, comProvider, c);
                            onChanged();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await _confirm(context, 'Supprimer ce commentaire ?');
                            if (ok == true) {
                              await comProvider.supprimerCommentaire(c.id!);
                              onChanged();
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
        ),
        const Divider(),
        _buildAddCommentSection(comProvider),
      ],
    );
  }

  /// Bloc d’ajout de commentaire + note.
  Widget _buildAddCommentSection(CommentaireProvider comProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ajouter un commentaire', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: commentCtrl,
          decoration: const InputDecoration(
            labelText: 'Commentaire',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: noteNotifier,
                builder: (context, note, _) {
                  return Slider(
                    min: 0,
                    max: 5,
                    divisions: 5,
                    value: note.toDouble(),
                    label: '$note',
                    onChanged: (v) {
                      noteNotifier.value = v.round();
                    },
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Publier'),
              onPressed: () async {
                final texte = commentCtrl.text.trim();
                if (texte.isEmpty) return;
                await comProvider.ajouterCommentaire(
                  lieuId: lieuId,
                  contenu: texte,
                  note: noteNotifier.value,
                );
                commentCtrl.clear();
                onChanged();
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _editComment(
    BuildContext context,
    CommentaireProvider provider,
    Commentaire c,
  ) async {
    final ctrl = TextEditingController(text: c.contenu ?? '');
    int currentNote = c.note;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) => AlertDialog(
            title: const Text('Modifier le commentaire'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Commentaire',
                    border: OutlineInputBorder(),
                  ),
                ),
                Slider(
                  min: 0,
                  max: 5,
                  divisions: 5,
                  value: currentNote.toDouble(),
                  label: '$currentNote',
                  onChanged: (v) {
                    setStateDialog(() => currentNote = v.round());
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );
    if (ok == true) {
      final updated = c.copyWith(
        contenu: ctrl.text.trim(),
        note: currentNote,
      );
      await provider.modifierCommentaire(updated);
    }
  }

  Future<bool?> _confirm(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
