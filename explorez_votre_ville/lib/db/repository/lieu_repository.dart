//
// Ici on met toutes les requêtes SQLite liées aux lieux
// L écran ne doit pas écrire du SQL directement
// On passe par ce repository pour garder le code organisé

import 'package:explorez_votre_ville/db/database_helper.dart';
import 'package:explorez_votre_ville/models/lieu.dart';

class LieuRepository {
  // On utilise l instance unique de la base
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insérer un lieu
  // SQLite renvoie l id créé
  Future<int> insertLieu(Lieu lieu) async {
    final db = await _dbHelper.database;
    return db.insert('lieu', lieu.toMap());
  }

  // Récupérer tous les lieux d une ville
  // On filtre avec ville_id
  // On trie par nom pour avoir une liste stable
  Future<List<Lieu>> getLieuxByVilleId(int villeId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'lieu',
      where: 'ville_id = ?',
      whereArgs: [villeId],
      orderBy: 'nom ASC',
    );

    return maps.map((m) => Lieu.fromMap(m)).toList();
  }

  // Récupérer un lieu par son id
  // On met limit 1 car on attend un seul résultat
  Future<Lieu?> getLieuById(int id) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'lieu',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Lieu.fromMap(maps.first);
  }

  // Mettre à jour un lieu
  // On cible la ligne grâce à lieu id
  Future<int> updateLieu(Lieu lieu) async {
    final db = await _dbHelper.database;

    return db.update(
      'lieu',
      lieu.toMap(),
      where: 'id = ?',
      whereArgs: [lieu.id],
    );
  }

  // Supprimer un lieu
  // Les commentaires liés seront supprimés automatiquement grâce à ON DELETE CASCADE
  Future<int> deleteLieu(int id) async {
    final db = await _dbHelper.database;

    return db.delete('lieu', where: 'id = ?', whereArgs: [id]);
  }

  // Récupérer un lieu par son nom dans une ville
  // On utilise ça pour éviter les doublons lors des imports ou ajouts
  Future<Lieu?> getLieuByNomEtVille(String nom, int villeId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'lieu',
      where: 'nom = ? AND ville_id = ?',
      whereArgs: [nom, villeId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Lieu.fromMap(maps.first);
  }

  // Récupérer tous les lieux
  // Utile surtout pour debug ou tests
  Future<List<Lieu>> getAllLieux() async {
    final db = await _dbHelper.database;

    final maps = await db.query('lieu', orderBy: 'nom ASC');

    return maps.map((m) => Lieu.fromMap(m)).toList();
  }
}
