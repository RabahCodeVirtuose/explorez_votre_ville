//
// Ici on regroupe toutes les requêtes SQLite liées aux villes
// L objectif est de ne pas écrire du SQL dans les écrans
// Les écrans appellent ce repository et récupèrent des objets Ville

import 'package:explorez_votre_ville/db/database_helper.dart';
import 'package:explorez_votre_ville/models/ville.dart';

class VilleRepository {
  // On utilise l instance unique de la base
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insérer une ville
  // On renvoie l id créé par SQLite
  Future<int> insertVille(Ville ville) async {
    final db = await _dbHelper.database;
    return db.insert('ville', ville.toMap());
  }

  // Récupérer toutes les villes
  // On trie par nom pour un affichage stable
  Future<List<Ville>> getAllVilles() async {
    final db = await _dbHelper.database;

    final maps = await db.query('ville', orderBy: 'nom ASC');

    return maps.map((m) => Ville.fromMap(m)).toList();
  }

  // Récupérer une ville par son id
  // On met limit 1 car on attend une seule ville
  Future<Ville?> getVilleById(int id) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'ville',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Ville.fromMap(maps.first);
  }

  // Recherche locale par nom
  // LIKE permet de retrouver une ville même si on tape seulement une partie du nom
  Future<List<Ville>> searchVillesByName(String pattern) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'ville',
      where: 'nom LIKE ?',
      whereArgs: ['%${pattern.trim()}%'],
      orderBy: 'nom ASC',
    );

    return maps.map((m) => Ville.fromMap(m)).toList();
  }

  // Récupérer les villes favorites
  // is_favorie est un booléen stocké en integer
  // 1 veut dire vrai
  Future<List<Ville>> getVillesFavorites() async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'ville',
      where: 'is_favorie = ?',
      whereArgs: [1],
      orderBy: 'nom ASC',
    );

    return maps.map((m) => Ville.fromMap(m)).toList();
  }

  // Mettre à jour une ville
  // On cible la bonne ligne grâce à ville id
  Future<int> updateVille(Ville ville) async {
    final db = await _dbHelper.database;

    return db.update(
      'ville',
      ville.toMap(),
      where: 'id = ?',
      whereArgs: [ville.id],
    );
  }

  // Supprimer une ville
  // Les lieux et les commentaires liés sont supprimés automatiquement avec ON DELETE CASCADE
  Future<int> deleteVille(int id) async {
    final db = await _dbHelper.database;

    return db.delete('ville', where: 'id = ?', whereArgs: [id]);
  }
}
