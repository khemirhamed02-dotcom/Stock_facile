// Représente une ligne de la table "produits".
class Produit {
  final int? id; // null tant que le produit n'est pas enregistré en base
  final String nom;
  final double prix;
  final int quantite;
  final bool disponible; // en base : 1 (vrai) ou 0 (faux)
  final DateTime dateAjout; // en base : texte au format ISO 8601
  final int categorieId; // clé étrangère vers categories.id

  const Produit({
    this.id,
    required this.nom,
    required this.prix,
    this.quantite = 0,
    this.disponible = true,
    required this.dateAjout,
    required this.categorieId,
  });

  // Ligne de la base (Map) → objet Dart.
  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      // SQLite peut renvoyer 5 (int) pour un REAL : on passe par num.
      prix: (map['prix'] as num).toDouble(),
      quantite: map['quantite'] as int,
      disponible: map['disponible'] == 1,
      dateAjout: DateTime.parse(map['date_ajout'] as String),
      categorieId: map['categorie_id'] as int,
    );
  }

  // Objet Dart → ligne de la base (Map).
  // Les clés sont exactement les noms des colonnes (snake_case).
  Map<String, dynamic> toMap() {
    return {
      // Sans id, la base en attribue un elle-même (AUTOINCREMENT).
      if (id != null) 'id': id,
      'nom': nom,
      'prix': prix,
      'quantite': quantite,
      'disponible': disponible ? 1 : 0,
      'date_ajout': dateAjout.toIso8601String(),
      'categorie_id': categorieId,
    };
  }

  @override
  String toString() =>
      'Produit(id: $id, nom: $nom, prix: $prix, quantite: $quantite, '
      'disponible: $disponible, categorieId: $categorieId)';
}