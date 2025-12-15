import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/commentaire.dart';
import '../../providers/commentaire_provider.dart';

///
///  CommentsEditSection
/// 
/// Ce widget gère TOUTE la partie "commentaires" d’un lieu :
/// 1) afficher la liste des commentaires du lieu
/// 2) ajouter un nouveau commentaire (texte + note)
/// 3) modifier un commentaire existant
/// 4) supprimer un commentaire existant
///
/// Point important :
/// - On utilise un FutureBuilder pour charger la liste depuis la base.
/// - Pour forcer le refresh après un ajout/édition/suppression,
///   on stocke le Future dans une variable (_futureCommentaires)
///   puis on le remplace quand on veut recharger.
class CommentsEditSection extends StatefulWidget {
  /// Identifiant du lieu dont on veut gérer les commentaires
  final int lieuId;

  /// Controller de texte fourni par le parent (permet de garder l’état si besoin)
  final TextEditingController commentCtrl;

  /// Notifier de note (0..5) fourni par le parent (idem, état conservable)
  final ValueNotifier<int> noteNotifier;

  /// Callback pour prévenir le parent qu'il y a eu un changement.
  /// Exemple : si le parent veut rafraîchir une moyenne, un compteur, etc.
  final VoidCallback onChanged;

  const CommentsEditSection({
    super.key,
    required this.lieuId,
    required this.commentCtrl,
    required this.noteNotifier,
    required this.onChanged,
  });

  @override
  State<CommentsEditSection> createState() => _CommentsEditSectionState();
}

class _CommentsEditSectionState extends State<CommentsEditSection> {
  /// Le Future qui charge la liste des commentaires depuis le provider.
  /// On le garde en mémoire pour pouvoir le "remplacer" après un CRUD.
  late Future<List<Commentaire>> _futureCommentaires;

  @override
  void initState() {
    super.initState();
    // Premier chargement des commentaires dès que le widget est créé.
    _reloadCommentaires();
  }

  @override
  void didUpdateWidget(covariant CommentsEditSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si le parent reconstruit ce widget avec un autre lieuId,
    // il faut recharger les commentaires du nouveau lieu.
    if (oldWidget.lieuId != widget.lieuId) {
      _reloadCommentaires();
    }
  }

  /// (Re)crée le Future qui chargera les commentaires pour le lieu courant.
  /// => le FutureBuilder recevra un nouveau Future et relancera le chargement.
  void _reloadCommentaires() {
    final provider = context.read<CommentaireProvider>();
    _futureCommentaires = provider.chargerCommentaires(widget.lieuId);
  }

  /// À appeler après un ajout / une édition / une suppression :
  /// 1) on recharge la liste (setState -> rebuild -> FutureBuilder relancé)
  /// 2) on avertit le parent (widget.onChanged)
  void _reloadAndNotify() {
    setState(() => _reloadCommentaires());
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    // On utilise read ici car on ne veut pas rebuild à chaque notifyListeners.
    // Le refresh est contrôlé via _reloadAndNotify().
    final comProvider = context.read<CommentaireProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Text('Commentaires', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        // Expanded : la liste prend tout l’espace vertical disponible.
        // IMPORTANT : doit être dans un parent qui a une hauteur (ex: Column dans un écran).
        Expanded(
          child: FutureBuilder<List<Commentaire>>(
            // Future mémorisé (et remplacé quand on veut refresh)
            future: _futureCommentaires,
            builder: (context, snapCom) {
              // 1) Cas "en cours de chargement"
              if (snapCom.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2) Cas "erreur"
              if (snapCom.hasError) {
                return Text('Erreur commentaires : ${snapCom.error}');
              }

              // 3) Cas "ok"
              final list = snapCom.data ?? [];
              if (list.isEmpty) {
                return const Text('Aucun commentaire pour ce lieu.');
              }

              // Affichage de la liste
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final c = list[i];

                  return ListTile(
                    // Texte du commentaire
                    title: Text(c.contenu ?? ''),

                    // Infos secondaires : note + date
                    subtitle: Text(
                      'Note : ${c.note} • ${c.createdAt.toLocal()}',
                    ),

                    // Boutons à droite : edit + delete
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- Modifier ---
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            // ouvre une popup et met à jour en base si validé
                            await _editComment(context, comProvider, c);

                            // après await : on vérifie que le widget est encore dans l’arbre
                            if (!mounted) return;

                            // recharge la liste + notifie le parent
                            _reloadAndNotify();
                          },
                        ),

                        // --- Supprimer ---
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            // confirmation avant suppression
                            final ok = await _confirm(
                              context,
                              'Supprimer ce commentaire ?',
                            );

                            // si OK et id non nul, on supprime en base
                            if (ok == true && c.id != null) {
                              await comProvider.supprimerCommentaire(c.id!);

                              if (!mounted) return;
                              _reloadAndNotify();
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

        // Bloc d’ajout (en bas)
        _buildAddCommentSection(comProvider),
      ],
    );
  }

  /// -----------------------------
  /// Bloc ajout : champ + slider + bouton
  /// -----------------------------
  Widget _buildAddCommentSection(CommentaireProvider comProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ajouter un commentaire',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // Champ de saisie du commentaire
        TextField(
          controller: widget.commentCtrl,
          decoration: const InputDecoration(
            labelText: 'Commentaire',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),

        Row(
          children: [
            // Slider note (0..5)
            Expanded(
              child: ValueListenableBuilder<int>(
                // On écoute le notifier du parent
                valueListenable: widget.noteNotifier,
                builder: (context, note, _) {
                  return Slider(
                    min: 0,
                    max: 5,
                    divisions: 5,
                    value: note.toDouble(),
                    label: '$note',
                    // Quand on bouge le slider, on met à jour le notifier
                    onChanged: (v) => widget.noteNotifier.value = v.round(),
                  );
                },
              ),
            ),

            // Bouton publier
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Publier'),
              onPressed: () async {
                // 1) récupérer le texte
                final texte = widget.commentCtrl.text.trim();
                if (texte.isEmpty) return; // pas d’ajout si vide

                // 2) insérer en base via provider
                await comProvider.ajouterCommentaire(
                  lieuId: widget.lieuId,
                  contenu: texte,
                  note: widget.noteNotifier.value,
                );

                // 3) sécurité après await
                if (!mounted) return;

                // 4) reset UI et refresh liste
                widget.commentCtrl.clear();
                _reloadAndNotify();
              },
            ),
          ],
        ),
      ],
    );
  }

  /// -----------------------------
  /// Popup d’édition
  /// -----------------------------
  Future<void> _editComment(
    BuildContext context,
    CommentaireProvider provider,
    Commentaire c,
  ) async {
    // Controller local pour préremplir le texte existant
    final ctrl = TextEditingController(text: c.contenu ?? '');

    // Note courante (modifiable via slider dans la popup)
    int currentNote = c.note;

    // showDialog retourne true si "Enregistrer", false si "Annuler"
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        // StatefulBuilder permet de gérer un petit état local
        // (ici: currentNote) uniquement dans la popup.
        return StatefulBuilder(
          builder: (ctx, setStateDialog) => AlertDialog(
            title: const Text('Modifier le commentaire'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Champ texte
                TextField(
                  controller: ctrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Commentaire',
                    border: OutlineInputBorder(),
                  ),
                ),

                // Slider note
                Slider(
                  min: 0,
                  max: 5,
                  divisions: 5,
                  value: currentNote.toDouble(),
                  label: '$currentNote',
                  onChanged: (v) => setStateDialog(() {
                    currentNote = v.round();
                  }),
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

    // Si validé, on met à jour en base
    if (ok == true) {
      final updated = c.copyWith(contenu: ctrl.text.trim(), note: currentNote);
      await provider.modifierCommentaire(updated);
    }
  }

  /// -----------------------------
  /// Popup de confirmation simple
  /// -----------------------------
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
