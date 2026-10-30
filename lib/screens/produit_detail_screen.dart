import 'package:flutter/material.dart';

import '../database/categorie_dao.dart';
import '../database/produit_dao.dart';
import '../models/categorie.dart';
import '../models/produit.dart';

// Le produit et sa catégorie, lus ensemble dans la base.
class _DetailProduit {
  final Produit produit;
  final Categorie? categorie;

  const _DetailProduit(this.produit, this.categorie);
}

// Détail d'un produit. Reçoit seulement son id et relit la base.
class ProduitDetailScreen extends StatefulWidget {
  final int produitId;

  const ProduitDetailScreen({super.key, required this.produitId});

  @override
  State<ProduitDetailScreen> createState() => _ProduitDetailScreenState();
}

class _ProduitDetailScreenState extends State<ProduitDetailScreen> {
  late Future<_DetailProduit?> _futurDetail;

  @override
  void initState() {
    super.initState();
    _futurDetail = _charger();
  }

  // Lit le produit par son id, puis sa catégorie par categorie_id.
  Future<_DetailProduit?> _charger() async {
    final produit = await ProduitDao().lireProduitParId(widget.produitId);
    if (produit == null) return null;
    final categorie =
        await CategorieDao().lireCategorieParId(produit.categorieId);
    return _DetailProduit(produit, categorie);
  }

  // Date au format jj/mm/aaaa.
  String _formaterDate(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');
    return '$jour/$mois/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail du produit')),
      body: FutureBuilder<_DetailProduit?>(
        future: _futurDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur : ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final detail = snapshot.data;
          if (detail == null) {
            return const Center(child: Text('Produit introuvable'));
          }

          final produit = detail.produit;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête : numéro et nom du produit.
                  Container(
                    color: Colors.teal.shade800,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Produit n° ${produit.id}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          produit.nom,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ligne('Prix', '${produit.prix.toStringAsFixed(3)} DT'),
                  _ligne('Quantité', '${produit.quantite}'),
                  _ligne(
                    'Disponible',
                    produit.disponible ? 'Oui' : 'Non',
                    couleur: produit.disponible ? Colors.green : Colors.red,
                  ),
                  _ligne('Catégorie', detail.categorie?.nom ?? 'Inconnue'),
                  _ligne('Ajouté le', _formaterDate(produit.dateAjout)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Une ligne « libellé ........ valeur » de la carte.
  Widget _ligne(String libelle, String valeur, {Color? couleur}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle),
          Text(
            valeur,
            style: TextStyle(fontWeight: FontWeight.bold, color: couleur),
          ),
        ],
      ),
    );
  }
}
