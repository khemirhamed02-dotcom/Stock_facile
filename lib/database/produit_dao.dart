import 'package:sqflite/sqflite.dart';

import '../models/produit.dart';
import 'database_helper.dart';

// DAO de la table "produits" : toutes les requêtes sur les produits sont ici.
class ProduitDao {
  static const String table = 'produits';

  // Insère un produit et renvoie l'id attribué par la base.
  Future<int> insererProduit(Produit produit) async {
    // Connexion unique à la base.
    final Database db = await DatabaseHelper().database;

    // toMap() convertit le produit en ligne de table : disponible devient
    // 1 ou 0, dateAjout devient du texte ISO 8601, categorieId devient
    // categorie_id.
    final int id = await db.insert(table, produit.toMap());

    // id de la nouvelle ligne.
    return id;
  }
}
