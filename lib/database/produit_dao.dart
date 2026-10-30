import 'package:flutter/foundation.dart';
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

  // Lit tous les produits, triés par nom.
  Future<List<Produit>> lireProduits() async {
    debugPrint('ProduitDao.lireProduits : requête exécutée');
    final db = await DatabaseHelper().database;
    final lignes = await db.query(table, orderBy: 'nom ASC');
    // Chaque ligne (Map) est convertie en objet Produit.
    return lignes.map((ligne) => Produit.fromMap(ligne)).toList();
  }

  // Lit un produit par son id ; renvoie null s'il n'existe pas.
  Future<Produit?> lireProduitParId(int id) async {
    final db = await DatabaseHelper().database;
    final lignes = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return lignes.isEmpty ? null : Produit.fromMap(lignes.first);
  }
}
