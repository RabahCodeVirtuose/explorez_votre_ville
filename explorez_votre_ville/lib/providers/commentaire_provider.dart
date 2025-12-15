//
// Ce provider sert à gérer les actions liées aux commentaires
// L UI appelle ce provider au lieu d appeler directement la base
// On utilise notifyListeners pour rafraîchir l écran quand on change quelque chose

import 'package:explorez_votre_ville/db/repository/commentaire_repository.dart';
import 'package:explorez_votre_ville/models/commentaire.dart';
import 'package:flutter/foundation.dart';

class CommentaireProvider with ChangeNotifier {
  // Le repository fait les requêtes SQLite
  final CommentaireRepository _repo = CommentaireRepository();

  // On charge les commentaires d un lieu
  // On renvoie la liste pour que l écran puisse l afficher
  Future<List<Commentaire>> chargerCommentaires(int lieuId) async {
    return _repo.getCommentairesByLieuId(lieuId);
  }

  // On ajoute un commentaire
  // On crée l objet avec la date actuelle
  // Ensuite on insère en base puis on notifie l UI
  Future<void> ajouterCommentaire({
    required int lieuId,
    required String contenu,
    required int note,
  }) async {
    final commentaire = Commentaire(
      lieuId: lieuId,
      contenu: contenu,
      note: note,
      createdAt: DateTime.now(),
    );

    await _repo.insertCommentaire(commentaire);

    // On prévient les widgets qui écoutent ce provider
    notifyListeners();
  }

  // On modifie un commentaire existant
  // L objet contient déjà son id donc le repository sait quelle ligne changer
  Future<void> modifierCommentaire(Commentaire commentaire) async {
    await _repo.updateCommentaire(commentaire);
    notifyListeners();
  }

  // On supprime un commentaire par son id
  // Ensuite on notifie pour que la liste se mette à jour
  Future<void> supprimerCommentaire(int id) async {
    await _repo.deleteCommentaire(id);
    notifyListeners();
  }
}
