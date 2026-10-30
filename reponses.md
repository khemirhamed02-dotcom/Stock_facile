# Réponses du TP StockFacile

## Partie 00

**Q0.5. Pourquoi ne faut-il pas envoyer les fichiers `.db` sur GitHub alors qu'on envoie `schema.sql` ?**

Un fichier `.db` est un fichier binaire local : il contient des données de test propres à chaque poste, change à chaque modification (Git ne peut pas en afficher les différences lisibles ni les fusionner) et peut contenir des données personnelles. `schema.sql` est un fichier texte qui décrit la structure ; il est lisible, comparable d'un commit à l'autre, et permet à n'importe qui de recréer la base identique.

**Question de réflexion : si l'application ne fonctionne plus après la partie 07, comment l'historique des commits permet-il de retrouver la dernière version qui marchait ?**

Avec un commit à la fin de chaque partie, `git log --oneline` liste les versions successives. On repère le dernier commit qui fonctionnait (par exemple la partie 06), puis on compare avec `git diff` ou on revient dessus avec `git checkout <hash>` (ou `git revert`) pour retrouver le code qui marchait.
## Partie 01

**Q1.3. Comment stocke-t-on `disponible` et `date_ajout` ?**

- `disponible` est un `INTEGER` : 1 pour vrai, 0 pour faux.
- `date_ajout` est un `TEXT` au format ISO 8601 (par exemple `2026-10-01T09:00:00`). Ce format se trie dans l'ordre chronologique.

**Rôle de `AUTOINCREMENT`, de `UNIQUE` sur `nom` et de `CHECK (prix >= 0)`**

- `AUTOINCREMENT` : SQLite attribue lui-même un `id` croissant, qui n'est jamais réutilisé après une suppression.
- `UNIQUE` sur `nom` : deux catégories ne peuvent pas porter le même nom.
- `CHECK (prix >= 0)` : la base refuse un prix négatif.

**Que signifie `ON DELETE RESTRICT` ?**

On ne peut pas supprimer une catégorie tant qu'au moins un produit y est rattaché. La base refuse la suppression.

**Q1.4. Pourquoi écrit-on `'Huile d''olive'` avec deux apostrophes ?**

L'apostrophe délimite les textes en SQL. Pour mettre une apostrophe dans un texte, on la double : `''` donne une seule apostrophe dans la valeur enregistrée.

**Q1.6. Messages d'erreur des tests de contraintes**

- a) Prix négatif : `CHECK constraint failed: prix >= 0`
- b) Catégorie inexistante (99) : `FOREIGN KEY constraint failed`
- c) Suppression de la catégorie 1, qui contient des produits : `FOREIGN KEY constraint failed`

**Q1.7. Que contient `schema.sql` ?**

Uniquement la structure de la base : les instructions `CREATE TABLE` des deux tables, `categories` et `produits`, avec leurs contraintes. Il ne contient aucune donnée.

**Q1.8. Pourquoi fermer la base avant qu'un autre programme écrive dans le même fichier ?**

Si DB Browser a des modifications non écrites ou garde le fichier ouvert, il peut le verrouiller (erreur « database is locked »). Deux programmes qui écrivent en même temps risquent aussi de perdre des modifications ou d'abîmer le fichier.