import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Ouverture / creation physique du fichier .db (mobile/desktop)
  Future<Database> _initDatabase() async {
    final dbPath = p.join(await getDatabasesPath(), 'explorez_ville.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  // Activation des cles etrangeres (important pour ON DELETE CASCADE)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
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
      );
    ''');

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
      );
    ''');

    await db.execute('''
      CREATE TABLE commentaire (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contenu TEXT,
        note INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        lieu_id INTEGER NOT NULL,
        FOREIGN KEY(lieu_id) REFERENCES lieu(id) ON DELETE CASCADE
      );
    ''');
  }
}
