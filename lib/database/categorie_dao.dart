import 'package:sqflite/sqflite.dart';

import '../models/categorie.dart';
import 'database_helper.dart';

// DAO (Data Access Object) : regroupe toutes les requêtes de la table
// "categories". Les écrans n'écrivent jamais de SQL : ils appellent ce DAO.
class CategorieDao {
  static const String table = 'categories';

  // Insère une catégorie et renvoie l'id attribué par la base.
  Future<int> insererCategorie(Categorie categorie) async {
    // 1. On récupère la connexion unique à la base (elle est ouverte et créée
    //    au premier appel, puis réutilisée ensuite).
    final Database db = await DatabaseHelper().database;

    // 2. db.insert() fabrique et exécute l'INSERT INTO categories (...) VALUES
    //    (...) à partir de la Map : les clés de toMap() sont les colonnes.
    final int id = await db.insert(table, categorie.toMap());

    // 3. On renvoie l'id de la nouvelle ligne (celui d'AUTOINCREMENT) pour que
    //    l'appelant sache quelle ligne vient d'être créée.
    return id;
  }

  // Lit toutes les catégories, triées par nom.
  Future<List<Categorie>> lireCategories() async {
    final db = await DatabaseHelper().database;
    final lignes = await db.query(table, orderBy: 'nom ASC');
    // Chaque ligne (Map) est convertie en objet Categorie.
    return lignes.map((ligne) => Categorie.fromMap(ligne)).toList();
  }

  // Lit une catégorie par son id ; renvoie null si elle n'existe pas.
  Future<Categorie?> lireCategorieParId(int id) async {
    final db = await DatabaseHelper().database;
    final lignes = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id], // le ? est remplacé par l'id (pas de concaténation SQL)
      limit: 1,
    );
    return lignes.isEmpty ? null : Categorie.fromMap(lignes.first);
  }
}
