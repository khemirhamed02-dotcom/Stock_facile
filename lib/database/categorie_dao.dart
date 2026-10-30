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
}
