import 'package:flutter/material.dart';

import '../database/database_helper.dart';

// Banc d'essai : sert à tester chaque méthode avant de créer la vraie interface.
class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Banc d'essai"),
        actions: const [Icon(Icons.bug_report), SizedBox(width: 12)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Base de données',
            style: Theme.of(context).textTheme.titleSmall,
          ),
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
          const Text(
            'Les boutons de test des parties 04 et 05 seront ajoutés ici.',
          ),
        ],
      ),
    );
  }
}