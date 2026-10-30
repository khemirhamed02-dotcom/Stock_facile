import 'package:flutter/material.dart';

import 'screens/tests_screen.dart';

// Point d'entrée de l'application.
void main() {
  runApp(const StockFacileApp());
}

// Widget racine : configure le thème et choisit la page d'accueil.
class StockFacileApp extends StatelessWidget {
  const StockFacileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockFacile',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      // Banc d'essai pour tester la base (supprimé en partie 11).
      home: const TestsScreen(),
    );
  }
}