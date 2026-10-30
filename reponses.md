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
## Partie 02

**Q2.1. Rôle des packages**

- `sqflite` : permet d'utiliser une base SQLite dans une application Flutter sur Android et iOS (ouvrir la base, exécuter des requêtes).
- `path` : construit des chemins de fichiers de façon portable (par exemple `join(...)`), pour placer le fichier de la base au bon endroit.

(`sqflite_common_ffi` n'est pas installé : l'application est testée sur Android, pas sur Windows ou Linux, donc `main.dart` n'est pas modifié pour la question Q2.2.)

**Q2.3. Pourquoi `id` est-il de type `int?` ? Pourquoi `toMap()` n'ajoute-t-il `id` que s'il n'est pas null ?**

- Tant que l'objet n'a pas été enregistré, il n'a pas encore d'`id` : c'est la base qui le crée avec `AUTOINCREMENT`. Le type `int?` permet donc la valeur `null`.
- Si `id` est `null`, on ne l'ajoute pas à la `Map` : ainsi la base attribue elle-même le prochain `id` lors de l'`INSERT`.

**Q2.4. `toMap()` de `Produit`**

Les clés de la `Map` portent exactement les noms des colonnes. Les conversions sont : `disponible` devient 1 ou 0, `dateAjout` devient du texte avec `toIso8601String()`, et `categorieId` devient `categorie_id`.

**Question de réflexion : pourquoi un constructeur `factory` ? Pourquoi `(map['prix'] as num).toDouble()` ?**

- Un constructeur `factory` peut faire des calculs et des conversions avant de renvoyer l'objet (ici : lire la `Map`, convertir 1 en `true`, le texte en `DateTime`). Un constructeur classique ne fait qu'affecter les champs.
- SQLite peut renvoyer `5` (un `int`) pour une colonne `REAL` quand la valeur est entière. Écrire `as double` provoquerait alors une erreur à l'exécution. `as num` accepte `int` et `double`, puis `.toDouble()` donne toujours un `double`.
## Partie 03

**Q3.2. Questions sur `DatabaseHelper`**

1. **Deux fois `DatabaseHelper()` :** un seul objet existe. Le constructeur `factory` ne crée pas de nouvel objet à chaque appel : il renvoie toujours la même instance `_instance`, créée une seule fois (c'est un singleton). Les deux appels donnent donc la même référence, et donc la même connexion à la base. Un constructeur classique créerait deux objets, chacun avec sa propre connexion.
2. **`??=` :** « affecter seulement si c'est null ». `_database ??= await _ouvrirBase();` ouvre la base la première fois, puis réutilise la connexion déjà ouverte aux appels suivants.
3. **`PRAGMA foreign_keys = ON` dans `onConfigure` :** ce réglage n'est pas enregistré dans le fichier, il doit être refait à chaque ouverture de la base. `onConfigure` est appelée à chaque ouverture, alors que `onCreate` n'est appelée qu'une seule fois, à la création du fichier : les clés étrangères ne seraient plus activées aux lancements suivants.
4. **`onCreate` :** une seule fois dans toute la vie de l'application, quand le fichier `stock_facile.db` n'existe pas encore. Elle se rappelle seulement si on désinstalle l'application ou si on supprime le fichier.

**Q3.4. Console au premier lancement (clic sur « Ouvrir la base »)**

```
Base SQLite : /data/user/0/com.example.stock_facile/databases/stock_facile.db
onCreate : création des tables (version 1)
Nombre de catégories : 4
```

**Q3.5. Deuxième lancement :** le message `onCreate` ne s'affiche plus. Le fichier de la base existe déjà (en version 1), donc SQLite n'appelle pas `onCreate`. Seuls le chemin et `Nombre de catégories : 4` s'affichent.

**Q3.6. Récupération du fichier `stock_facile.db`**

J'ai travaillé sur l'émulateur Android : j'ai copié la base avec `adb exec-out run-as com.example.stock_facile cat databases/stock_facile.db`, en redirigeant la sortie depuis `cmd` (PowerShell abîme les fichiers binaires), puis j'ai ouvert la copie dans DB Browser. Le fichier copié est ignoré par Git grâce au `.gitignore` (`*.db`).

**Q3.7. Vérifications dans DB Browser**

- Structure : les deux tables `categories` et `produits` existent avec les mêmes colonnes que `brouillon.db`.
- Parcourir les données : `categories` contient les 4 catégories de départ, `produits` est vide.
- Éditer les pragmas : *User Version* vaut 1. Cela correspond à la ligne `version: _version` (avec `_version = 1`) de l'appel à `openDatabase` dans `database_helper.dart`.
## Partie 04

**Q4.3. Quel `id` obtient-on au premier clic ? Pourquoi ?**

L'`id` est **5**. La table `categories` contient déjà 4 lignes (ids 1 à 4). Avec `AUTOINCREMENT`, SQLite attribue le numéro suivant, donc 5 : c'est la base qui choisit l'`id`, pas l'application (l'objet `Categorie` est créé sans `id`).

**Q4.4. Deuxième clic sur le même bouton**

Message d'erreur :

```
UNIQUE constraint failed: categories.nom (code 2067 SQLITE_CONSTRAINT_UNIQUE)
```

C'est la contrainte `UNIQUE` sur la colonne `nom` de la table `categories` (partie 01) : deux catégories ne peuvent pas avoir le même nom. Le `try / catch` intercepte la `DatabaseException`. `isUniqueConstraintError()` reconnaît ce cas et le `SnackBar` « Cette catégorie existe déjà » s'affiche.

**Q4.5. Vérification dans DB Browser**

La ligne `5 | Électroménager | Petits appareils` apparaît dans la table `categories` (capture : `captures/04_insert_categorie.png`).

**Q4.9. Stockage de `disponible` et de `date_ajout`**

`disponible` est stocké en entier : `1` (vrai). `date_ajout` est stockée en texte au format ISO 8601, par exemple `2026-10-30T15:41:46.742952`. C'est conforme à `toMap()`, qui convertit `true` en 1 et appelle `dateAjout.toIso8601String()` (capture : `captures/04_insert_produit.png`).

**Q4.10. Produit avec `categorieId: 99`**

- Avec `PRAGMA foreign_keys = ON`, l'insertion est refusée : `FOREIGN KEY constraint failed (code 787 SQLITE_CONSTRAINT_FOREIGNKEY)`. La catégorie 99 n'existe pas.
- Un *hot reload* ne suffit pas pour tester sans la ligne `PRAGMA` : `DatabaseHelper` est un singleton dont la base reste ouverte, et `onConfigure` ne s'exécute qu'à l'ouverture de la base. Le hot reload conserve l'état de l'application (la connexion déjà ouverte) et ne relance pas l'ouverture. Il faut arrêter puis relancer l'application.
- Après le redémarrage sans la ligne `PRAGMA`, l'insertion **réussit** (le produit reçoit l'id 2) alors que la catégorie 99 n'existe pas : SQLite ne vérifie pas les clés étrangères par défaut. On obtient un produit « orphelin ».
- J'ai remis la ligne, puis j'ai désinstallé l'application pour supprimer le produit orphelin. Après réinstallation, l'erreur de clé étrangère est de nouveau levée.

**Q4.11. Produit avec un prix de `-2`**

La contrainte `CHECK (prix >= 0)` bloque l'insertion : `CHECK constraint failed: prix >= 0 (code 275 SQLITE_CONSTRAINT_CHECK)`. Vérifier aussi le prix dans le formulaire Flutter reste utile : l'utilisateur voit tout de suite un message clair à côté du champ, sans aller-retour avec la base ni message d'erreur technique. La contrainte de la base reste le dernier filet de sécurité, mais ce n'est pas une interface utilisateur.

**Question de réflexion : `ConflictAlgorithm.ignore` et `ConflictAlgorithm.replace`**

- `ignore` : en cas de violation d'une contrainte, la ligne n'est pas insérée, mais aucune erreur n'est levée.
- `replace` : en cas de violation d'une contrainte `UNIQUE` ou de clé primaire, la ou les lignes déjà présentes qui causent le conflit sont **supprimées**, puis la nouvelle ligne est insérée.
- Sur une table référencée par une clé étrangère, `replace` est dangereux : supprimer l'ancienne ligne (par exemple une catégorie du même nom) supprime aussi son `id`. Les produits qui pointaient vers cet `id` ne trouvent plus leur catégorie : avec `ON DELETE RESTRICT` la suppression échoue, et sans vérification des clés étrangères les produits deviennent orphelins. La nouvelle ligne reçoit en plus un nouvel `id`.