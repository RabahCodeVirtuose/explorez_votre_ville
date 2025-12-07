
import 'package:explorez_votre_ville/db/database_helper.dart';
import 'package:explorez_votre_ville/models/ville.dart';

class VilleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insérer une ville
  Future<int> insertVille(Ville ville) async {
    final db = await _dbHelper.database;
    return await db.insert('ville', ville.toMap());
  }

  // Récupérer toutes les villes (option : ordre alphabétique)
  Future<List<Ville>> getAllVilles() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'ville',
      orderBy: 'nom ASC',
    );
    return maps.map((m) => Ville.fromMap(m)).toList();
  }

  // Récupérer une ville par son id
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

  // Rechercher des villes par nom (recherche locale)
  Future<List<Ville>> searchVillesByName(String pattern) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'ville',
      where: 'nom LIKE ?',
      whereArgs: ['%$pattern%'],
      orderBy: 'nom ASC',
    );
    return maps.map((m) => Ville.fromMap(m)).toList();
  }

  // Récupérer les villes favorites
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

  // Mettre à jour une ville (statuts, coordonnées, etc.)
  Future<int> updateVille(Ville ville) async {
    final db = await _dbHelper.database;
    return await db.update(
      'ville',
      ville.toMap(),
      where: 'id = ?',
      whereArgs: [ville.id],
    );
  }

  // Supprimer une ville (les lieux/commentaires seront supprimés via ON DELETE CASCADE)
  Future<int> deleteVille(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'ville',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
