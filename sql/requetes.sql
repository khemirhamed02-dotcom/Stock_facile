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