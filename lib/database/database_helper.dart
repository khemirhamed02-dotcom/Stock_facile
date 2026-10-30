// =============================================================================
// database_helper.dart
//
// Rôle de cette classe :
//   - ouvrir (ou créer) le fichier stock_facile.db sur l'appareil ;
//   - créer les tables au tout premier lancement ;
//   - fournir la même connexion à tout le reste de l'application ;
//   - permettre de fermer proprement la base.
//
// Utilisation typique ailleurs dans le code :
//   final db = await DatabaseHelper().database;
//   final produits = await db.query('produits');
// =============================================================================

// debugPrint : comme print(), mais n'inonde pas la console (messages limités)
// et reste pratique pour les logs de développement.
import 'package:flutter/foundation.dart';

// join() : construit un chemin de fichier correct quel que soit le système
// (Android, iOS...) sans se soucier des "/" ou "\".
import 'package:path/path.dart';

// sqflite : le plugin Flutter qui donne accès à SQLite.
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // (1) Une seule instance, créée une fois pour toute l'application.
  static final DatabaseHelper _instance = DatabaseHelper._interne();

  // Le constructeur factory renvoie toujours cette même instance.
  factory DatabaseHelper() => _instance;

  // Constructeur privé : personne d'autre ne peut créer un DatabaseHelper.
  DatabaseHelper._interne();

  static const String _nomBase = 'stock_facile.db';
  static const int _version = 1;

  Database? _database;

  // (2) Ouvre la base la première fois, puis réutilise la même connexion.
  Future<Database> get database async {
    _database ??= await _ouvrirBase();
    return _database!;
  }

  Future<Database> _ouvrirBase() async {
    final dossier = await getDatabasesPath();
    final chemin = join(dossier, _nomBase);
    debugPrint('Base SQLite : $chemin');

    return openDatabase(
      chemin,
      version: _version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  // (3) Appelée à chaque ouverture, avant onCreate : on active ici les clés
  // étrangères, car SQLite les ignore par défaut à chaque nouvelle connexion.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // (4) Appelée une seule fois : quand le fichier de la base n'existe pas
  // encore. Les CREATE TABLE sont ceux de sql/schema.sql.
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('onCreate : création des tables (version $version)');

    await db.execute('''
      CREATE TABLE categories (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nom         TEXT    NOT NULL UNIQUE,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE produits (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        nom          TEXT    NOT NULL,
        prix         REAL    NOT NULL CHECK (prix >= 0),
        quantite     INTEGER NOT NULL DEFAULT 0 CHECK (quantite >= 0),
        disponible   INTEGER NOT NULL DEFAULT 1,
        date_ajout   TEXT    NOT NULL,
        categorie_id INTEGER NOT NULL,
        FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE RESTRICT
      )
    ''');

    // Les 4 catégories de départ (celles de la partie 01).
    await db.execute('''
      INSERT INTO categories (nom, description) VALUES
        ('Alimentation', 'Produits secs et conserves'),
        ('Boissons',     'Eaux, jus et sodas'),
        ('Hygiène',      'Savons et produits d''entretien'),
        ('Papeterie',    'Cahiers, stylos et fournitures')
    ''');
  }

  // Ferme proprement la base (et force une nouvelle ouverture au prochain appel).
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
