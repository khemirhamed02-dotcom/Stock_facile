import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../database/categorie_dao.dart';
import '../database/database_helper.dart';
import '../database/produit_dao.dart';
import '../models/categorie.dart';
import '../models/produit.dart';
import 'produits_screen.dart';

// Banc d'essai : sert à tester chaque méthode avant de créer la vraie interface.
class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  // Q4.3 / Q4.4 : insère la catégorie « Électroménager ». Une deuxième
  // insertion viole la contrainte UNIQUE sur categories.nom.
  Future<void> _ajouterCategorie(BuildContext context) async {
    const nouvelle = Categorie(
      nom: 'Électroménager',
      description: 'Petits appareils',
    );
    try {
      final id = await CategorieDao().insererCategorie(nouvelle);
      debugPrint("Catégorie insérée avec l'id $id");
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        debugPrint('UNIQUE constraint failed : $e');
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cette catégorie existe déjà')),
        );
      } else {
        debugPrint('Erreur SQLite : $e');
      }
    }
  }

  // Q4.8 : insère le produit « Stylo bleu » dans la catégorie 4 (Papeterie).
  Future<void> _ajouterProduit() async {
    final stylo = Produit(
      nom: 'Stylo bleu',
      prix: 0.5,
      quantite: 100,
      disponible: true,
      dateAjout: DateTime.now(),
      categorieId: 4,
    );
    await _insererProduitEtAfficher(stylo);
  }

  // Q4.10 : catégorie qui n'existe pas -> violation de la clé étrangère.
  Future<void> _ajouterProduitCategorie99() async {
    final orphelin = Produit(
      nom: 'Produit orphelin',
      prix: 1,
      quantite: 1,
      dateAjout: DateTime.now(),
      categorieId: 99,
    );
    await _insererProduitEtAfficher(orphelin);
  }

  // Q4.11 : prix négatif -> violation de CHECK (prix >= 0).
  Future<void> _ajouterProduitPrixNegatif() async {
    final negatif = Produit(
      nom: 'Produit prix négatif',
      prix: -2,
      quantite: 1,
      dateAjout: DateTime.now(),
      categorieId: 4,
    );
    await _insererProduitEtAfficher(negatif);
  }

  // Q5.3 : lecture brute (a, b) puis lecture avec conversion en objets (c).
  Future<void> _lireProduits() async {
    final db = await DatabaseHelper().database;

    // a) Résultat brut : une liste de Map.
    final lignes = await db.query('produits');
    debugPrint('Type : ${lignes.runtimeType}');
    debugPrint(lignes.toString());

    // b) Les Map renvoyées par sqflite sont en lecture seule.
    if (lignes.isNotEmpty) {
      try {
        lignes.first['nom'] = 'Test';
      } catch (e) {
        debugPrint('Modification impossible : $e');
      }
    }

    // c) Avec conversion : une liste d'objets Produit.
    final produits = await ProduitDao().lireProduits();
    for (final produit in produits) {
      debugPrint(produit.toString());
    }
  }

  // Q5.4 : un produit qui existe, puis un produit qui n'existe pas.
  Future<void> _lireProduitParId() async {
    final existant = await ProduitDao().lireProduitParId(1);
    debugPrint('lireProduitParId(1) : $existant');
    final inexistant = await ProduitDao().lireProduitParId(999);
    debugPrint('lireProduitParId(999) : $inexistant');
  }

  // Insère un produit et affiche l'id ou l'erreur SQLite dans la console.
  Future<void> _insererProduitEtAfficher(Produit produit) async {
    try {
      final id = await ProduitDao().insererProduit(produit);
      debugPrint("Produit inséré avec l'id $id");
    } on DatabaseException catch (e) {
      debugPrint('Erreur SQLite : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final styleTitre = Theme.of(context).textTheme.titleSmall;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Banc d'essai"),
        actions: const [Icon(Icons.bug_report), SizedBox(width: 12)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Base de données', style: styleTitre),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              // Ouvre la base (la crée au tout premier lancement)...
              final db = await DatabaseHelper().database;
              // ...puis compte les catégories pour vérifier qu'elle répond.
              final resultat = await db.rawQuery(
                'SELECT COUNT(*) AS nb FROM categories',
              );
              debugPrint('Nombre de catégories : ${resultat.first['nb']}');
            },
            child: const Text('Ouvrir la base'),
          ),
          const SizedBox(height: 16),
          Text('Insertion (Create)', style: styleTitre),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _ajouterCategorie(context),
            child: const Text('Test : ajouter une catégorie'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _ajouterProduit,
            child: const Text('Test : ajouter un produit'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _ajouterProduitCategorie99,
            child: const Text('Test : produit catégorie 99'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _ajouterProduitPrixNegatif,
            child: const Text('Test : prix négatif'),
          ),
          const SizedBox(height: 16),
          Text('Lecture (Read)', style: styleTitre),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _lireProduits,
            child: const Text('Test : lire les produits'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _lireProduitParId,
            child: const Text('Test : lire par id'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProduitsScreen()),
            ),
            child: const Text('Ouvrir la liste des produits'),
          ),
        ],
      ),
    );
  }
}
