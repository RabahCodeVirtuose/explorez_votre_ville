import 'package:explorez_votre_ville/db/repository/commentaire_repository.dart';
import 'package:explorez_votre_ville/models/commentaire.dart';
import 'package:flutter/foundation.dart';

/// Provider dédié aux commentaires d'un lieu.
class CommentaireProvider with ChangeNotifier {
  final CommentaireRepository _repo = CommentaireRepository();

  /// Charge tous les commentaires pour un lieu donné.
  Future<List<Commentaire>> chargerCommentaires(int lieuId) async {
    return _repo.getCommentairesByLieuId(lieuId);
  }

  /// Ajoute un commentaire avec note pour un lieu, puis notifie les listeners.
  Future<void> ajouterCommentaire({
    required int lieuId,
    required String contenu,
    required int note,
  }) async {
    final c = Commentaire(
      lieuId: lieuId,
      contenu: contenu,
      note: note,
      createdAt: DateTime.now(),
    );
    await _repo.insertCommentaire(c);
    notifyListeners();
  }

  /// Met à jour un commentaire existant (contenu/note) puis notifie.
  Future<void> modifierCommentaire(Commentaire commentaire) async {
    await _repo.updateCommentaire(commentaire);
    notifyListeners();
  }

  /// Supprime un commentaire et notifie les listeners.
  Future<void> supprimerCommentaire(int id) async {
    await _repo.deleteCommentaire(id);
    notifyListeners();
  }
}
