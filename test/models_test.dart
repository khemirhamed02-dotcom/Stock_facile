import 'package:flutter_test/flutter_test.dart';

import 'package:stock_facile/models/categorie.dart';
import 'package:stock_facile/models/produit.dart';

void main() {
  test('Categorie : toMap puis fromMap redonne les mêmes valeurs', () {
    const c = Categorie(id: 1, nom: 'Boissons', description: 'Eaux et jus');
    final c2 = Categorie.fromMap(c.toMap());
    expect(c2.id, 1);
    expect(c2.nom, 'Boissons');
    expect(c2.description, 'Eaux et jus');
  });

  test('Categorie : toMap sans id quand id est null', () {
    const c = Categorie(nom: 'Papeterie');
    expect(c.toMap().containsKey('id'), isFalse);
  });

  test('Produit : conversions bool, DateTime et snake_case', () {
    final p = Produit(
      nom: 'Jus d\'orange 1 L',
      prix: 3,
      quantite: 0,
      disponible: false,
      dateAjout: DateTime.parse('2026-10-02T10:10:00'),
      categorieId: 2,
    );
    final map = p.toMap();
    expect(map['disponible'], 0);
    expect(map['date_ajout'], '2026-10-02T10:10:00.000');
    expect(map['categorie_id'], 2);
    expect(map.containsKey('id'), isFalse);

    final p2 = Produit.fromMap({...map, 'id': 4, 'prix': 3});
    expect(p2.id, 4);
    expect(p2.prix, 3.0);
    expect(p2.disponible, isFalse);
    expect(p2.dateAjout, DateTime.parse('2026-10-02T10:10:00'));
    expect(p2.categorieId, 2);
  });
}
