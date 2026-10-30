import 'package:flutter/material.dart';

import '../models/produit.dart';

// Une ligne de la liste des produits.
class ProduitTile extends StatelessWidget {
  final Produit produit;
  final VoidCallback onTap; // appelé quand on touche la ligne

  const ProduitTile({super.key, required this.produit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enRupture = produit.quantite == 0;

    return ListTile(
      onTap: onTap,
      // Pastille avec la quantité : rouge si le stock est vide, verte sinon.
      leading: CircleAvatar(
        backgroundColor:
            enRupture ? Colors.red.shade100 : Colors.green.shade100,
        foregroundColor:
            enRupture ? Colors.red.shade900 : Colors.green.shade900,
        child: Text('${produit.quantite}'),
      ),
      title: Text(produit.nom),
      // Prix avec 3 décimales (le dinar tunisien se divise en millimes).
      subtitle: Text('${produit.prix.toStringAsFixed(3)} DT'),
      trailing: Icon(
        produit.disponible ? Icons.check_circle : Icons.cancel,
        color: produit.disponible ? Colors.green : Colors.red,
      ),
    );
  }
}
