//
// Ici on met toutes les requêtes SQLite liées aux commentaires
// L idée c est que l UI ne manipule pas directement la base
// L UI appelle le repository et récupère des objets Commentaire

import 'package:explorez_votre_ville/db/database_helper.dart';
import 'package:explorez_votre_ville/models/commentaire.dart';

class CommentaireRepository {
  // On récupère l instance unique de DatabaseHelper
  // Comme ça on ouvre la base une seule fois dans l app
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insérer un commentaire
  // On renvoie l id généré par SQLite
  Future<int> insertCommentaire(Commentaire commentaire) async {
    final db = await _dbHelper.database;
    return db.insert('commentaire', commentaire.toMap());
  }

  // Récupérer tous les commentaires d un lieu
  // On filtre par lieu_id
  // On trie du plus récent au plus ancien
  Future<List<Commentaire>> getCommentairesByLieuId(int lieuId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'commentaire',
      where: 'lieu_id = ?',
      whereArgs: [lieuId],
      orderBy: 'created_at DESC',
    );

    // On convertit les Map en objets Commentaire
    return maps.map((m) => Commentaire.fromMap(m)).toList();
  }

  // Supprimer un commentaire avec son id
  // On renvoie le nombre de lignes supprimées
  Future<int> deleteCommentaire(int id) async {
    final db = await _dbHelper.database;

    return db.delete('commentaire', where: 'id = ?', whereArgs: [id]);
  }

  // Mettre à jour un commentaire
  // On utilise l id de l objet pour viser la bonne ligne
  // Ici on peut modifier le contenu ou la note selon ce que toMap envoie
  Future<int> updateCommentaire(Commentaire commentaire) async {
    final db = await _dbHelper.database;

    return db.update(
      'commentaire',
      commentaire.toMap(),
      where: 'id = ?',
      whereArgs: [commentaire.id],
    );
  }

  // Calculer la note moyenne d un lieu
  // AVG renvoie null si aucun commentaire n existe
  // On renvoie null dans ce cas pour que l UI puisse afficher un message simple
  Future<double?> getAverageNoteForLieu(int lieuId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT AVG(note) as avg_note FROM commentaire WHERE lieu_id = ?',
      [lieuId],
    );

    if (result.isEmpty) return null;

    final value = result.first['avg_note'];
    if (value == null) return null;

    return (value as num).toDouble();
  }
}
