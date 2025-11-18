// lib/db/lieu_repository.dart

import 'package:explorez_votre_ville/db/database_helper.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:sqflite/sqflite.dart';


class LieuRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insérer un lieu
  Future<int> insertLieu(Lieu lieu) async {
    final db = await _dbHelper.database;
    return await db.insert('lieu', lieu.toMap());
  }

  // Récupérer tous les lieux d'une ville
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
  Future<int> updateLieu(Lieu lieu) async {
    final db = await _dbHelper.database;
    return await db.update(
      'lieu',
      lieu.toMap(),
      where: 'id = ?',
      whereArgs: [lieu.id],
    );
  }

  // Supprimer un lieu (les commentaires seront supprimés via ON DELETE CASCADE)
  Future<int> deleteLieu(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'lieu',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // (Optionnel) Récupérer tous les lieux (debug, tests)
  Future<List<Lieu>> getAllLieux() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'lieu',
      orderBy: 'nom ASC',
    );
    return maps.map((m) => Lieu.fromMap(m)).toList();
  }
}
