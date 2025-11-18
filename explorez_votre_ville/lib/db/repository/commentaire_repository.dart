// lib/db/commentaire_repository.dart

import 'package:explorez_votre_ville/db/database_helper.dart';
import 'package:explorez_votre_ville/models/commentaire.dart';
import 'package:sqflite/sqflite.dart';


class CommentaireRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insérer un commentaire
  Future<int> insertCommentaire(Commentaire commentaire) async {
    final db = await _dbHelper.database;
    return await db.insert('commentaire', commentaire.toMap());
  }

  // Récupérer tous les commentaires d'un lieu
  Future<List<Commentaire>> getCommentairesByLieuId(int lieuId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'commentaire',
      where: 'lieu_id = ?',
      whereArgs: [lieuId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Commentaire.fromMap(m)).toList();
  }

  // Supprimer un commentaire
  Future<int> deleteCommentaire(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'commentaire',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // (Optionnel) Mettre à jour un commentaire (contenu ou note)
  Future<int> updateCommentaire(Commentaire commentaire) async {
    final db = await _dbHelper.database;
    return await db.update(
      'commentaire',
      commentaire.toMap(),
      where: 'id = ?',
      whereArgs: [commentaire.id],
    );
  }

  // (Optionnel) Calculer la note moyenne d'un lieu
  Future<double?> getAverageNoteForLieu(int lieuId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT AVG(note) as avg_note FROM commentaire WHERE lieu_id = ?',
      [lieuId],
    );
    if (result.isEmpty || result.first['avg_note'] == null) {
      return null;
    }
    return (result.first['avg_note'] as num).toDouble();
  }
}
