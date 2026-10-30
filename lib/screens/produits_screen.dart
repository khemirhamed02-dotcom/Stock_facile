import 'package:flutter/material.dart';

import '../database/produit_dao.dart';
import '../models/produit.dart';
import '../widgets/produit_tile.dart';
import 'produit_detail_screen.dart';

// Liste des produits lus dans la base.
class ProduitsScreen extends StatefulWidget {
  const ProduitsScreen({super.key});

  @override
  State<ProduitsScreen> createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends State<ProduitsScreen> {
  final ProduitDao _dao = ProduitDao();

  // Le Future est créé une seule fois (dans initState), pas à chaque build :
  // sinon la requête serait relancée à chaque reconstruction de l'écran.
  late Future<List<Produit>> _futurProduits;

  @override
  void initState() {
    super.initState();
    _futurProduits = _dao.lireProduits();
  }

  // Relance la lecture et reconstruit l'écran avec le nouveau Future.
  void _rafraichir() {
    setState(() {
      _futurProduits = _dao.lireProduits();
    });
  }

  void _ouvrirDetail(Produit produit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // On ne passe que l'id : le détail relit la base lui-même.
        builder: (_) => ProduitDetailScreen(produitId: produit.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: const [Icon(Icons.bug_report), SizedBox(width: 12)],
      ),
      body: FutureBuilder<List<Produit>>(
        future: _futurProduits,
        builder: (context, snapshot) {
          // 1. Chargement en cours
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('FutureBuilder : chargement…'),
                ],
              ),
            );
          }

          // 2. Erreur
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erreur : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final produits = snapshot.data ?? [];

          // 3. Liste vide (dans une ListView pour pouvoir tirer et recharger)
          if (produits.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _rafraichir(),
              child: ListView(
                children: const [
                  SizedBox(height: 160),
                  Icon(Icons.inventory_2_outlined, size: 64),
                  SizedBox(height: 8),
                  Center(child: Text('Aucun produit')),
                ],
              ),
            );
          }

          // 4. Données reçues : tirer la liste vers le bas recharge la base.
          return RefreshIndicator(
            onRefresh: () async {
              _rafraichir();
              await _futurProduits;
            },
            child: ListView.builder(
              itemCount: produits.length,
              itemBuilder: (context, index) {
                final produit = produits[index];
                return ProduitTile(
                  produit: produit,
                  onTap: () => _ouvrirDetail(produit),
                );
              },
            ),
          );
        },
      ),
      // Le formulaire d'ajout sera branché en partie 06.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Le formulaire arrive en partie 06")),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
