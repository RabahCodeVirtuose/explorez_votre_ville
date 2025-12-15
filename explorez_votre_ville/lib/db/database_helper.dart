import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Cette classe sert à gérer la base SQLite de l application
/// On veut une seule instance dans tout le projet
/// Comme ça on évite d ouvrir plusieurs fois la base en même temps
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // On garde la base en mémoire une fois qu elle est ouverte
  static Database? _database;

  /// Quand on demande database
  /// Si elle existe déjà on la renvoie
  /// Sinon on l ouvre puis on la garde pour la prochaine fois
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Ici on ouvre ou on crée le fichier explorez_ville db
  /// getDatabasesPath donne le dossier système prévu pour SQLite
  /// p join sert juste à construire un chemin propre selon le système
  Future<Database> _initDatabase() async {
    final dbPath = p.join(await getDatabasesPath(), 'explorez_ville.db');

    return openDatabase(
      dbPath,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  /// Ici on active les clés étrangères sur SQLite
  /// Sans ça ON DELETE CASCADE ne marche pas toujours
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Ici on crée les tables au tout premier lancement
  /// On fait simple avec trois tables
  /// ville puis lieu puis commentaire
  Future<void> _onCreate(Database db, int version) async {
    // Table ville
    // id est auto incrémenté
    // is_favorie is_visitee is_exploree sont des booléens stockés en integer
    await db.execute('''
      CREATE TABLE ville (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        pays TEXT,
        latitude REAL,
        longitude REAL,
        is_favorie INTEGER NOT NULL DEFAULT 0,
        is_visitee INTEGER NOT NULL DEFAULT 0,
        is_exploree INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Table lieu
    // Chaque lieu appartient à une ville grâce à ville_id
    // ON DELETE CASCADE veut dire que si on supprime une ville
    // alors ses lieux sont supprimés automatiquement
    await db.execute('''
      CREATE TABLE lieu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        latitude REAL,
        longitude REAL,
        image_path TEXT,
        ville_id INTEGER NOT NULL,
        FOREIGN KEY(ville_id) REFERENCES ville(id) ON DELETE CASCADE
      )
    ''');

    // Table commentaire
    // Chaque commentaire appartient à un lieu grâce à lieu_id
    // ON DELETE CASCADE veut dire que si on supprime un lieu
    // alors ses commentaires sont supprimés automatiquement
    await db.execute('''
      CREATE TABLE commentaire (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contenu TEXT,
        note INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        lieu_id INTEGER NOT NULL,
        FOREIGN KEY(lieu_id) REFERENCES lieu(id) ON DELETE CASCADE
      )
    ''');
  }
}
