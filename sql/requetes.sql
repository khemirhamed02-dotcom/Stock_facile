-- Q1.5.1 : tous les produits
SELECT * FROM produits;

-- Q1.5.2 : produits en rupture de stock
SELECT * FROM produits WHERE quantite = 0;

-- Q1.5.3 : produits du plus cher au moins cher
SELECT * FROM produits ORDER BY prix DESC;

-- Q1.5.4 : nom du produit et nom de sa catégorie
SELECT p.nom, p.prix, p.quantite, c.nom AS categorie
FROM produits p
INNER JOIN categories c ON c.id = p.categorie_id
ORDER BY c.nom, p.nom;

-- Q1.5.5 : nombre de produits par catégorie
SELECT c.nom AS categorie, COUNT(p.id) AS nb_produits
FROM categories c
LEFT JOIN produits p ON p.categorie_id = c.id
GROUP BY c.id;

-- Q1.5.6 : valeur totale du stock
SELECT SUM(prix * quantite) AS valeur_stock FROM produits;
-- Q1.4 : données de départ (4 catégories et 6 produits)
INSERT INTO categories (nom, description) VALUES
  ('Alimentation', 'Produits secs et conserves'),
  ('Boissons',     'Eaux, jus et sodas'),
  ('Hygiène',      'Savons et produits d''entretien'),
  ('Papeterie',    'Cahiers, stylos et fournitures');

INSERT INTO produits (nom, prix, quantite, disponible, date_ajout, categorie_id) VALUES
  ('Huile d''olive 1 L',   18.500,  24, 1, '2026-10-01T09:00:00', 1),
  ('Couscous moyen 1 kg',   2.300,  40, 1, '2026-10-01T09:05:00', 1),
  ('Eau minérale 1,5 L',    0.850, 120, 1, '2026-10-02T10:00:00', 2),
  ('Jus d''orange 1 L',     3.200,   0, 0, '2026-10-02T10:10:00', 2),
  ('Savon de Marseille',    2.900,  15, 1, '2026-10-03T11:00:00', 3),
  ('Cahier 96 pages',       1.600,  60, 1, '2026-10-04T08:30:00', 4);

-- Q1.6 a) : prix négatif -> CHECK constraint failed: prix >= 0
-- INSERT INTO produits (nom, prix, quantite, date_ajout, categorie_id)
-- VALUES ('Test prix', -5, 1, '2026-10-05T08:00:00', 1);

-- Q1.6 b) : catégorie inexistante -> FOREIGN KEY constraint failed
-- INSERT INTO produits (nom, prix, quantite, date_ajout, categorie_id)
-- VALUES ('Test catégorie', 1, 1, '2026-10-05T08:00:00', 99);

-- Q1.6 c) : supprimer une catégorie qui contient des produits
--          -> FOREIGN KEY constraint failed
-- DELETE FROM categories WHERE id = 1;