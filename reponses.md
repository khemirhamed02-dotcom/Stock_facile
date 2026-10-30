# Réponses du TP StockFacile

## Partie 00

**Q0.5. Pourquoi ne faut-il pas envoyer les fichiers `.db` sur GitHub alors qu'on envoie `schema.sql` ?**

Un fichier `.db` est un fichier binaire local : il contient des données de test propres à chaque poste, change à chaque modification (Git ne peut pas en afficher les différences lisibles ni les fusionner) et peut contenir des données personnelles. `schema.sql` est un fichier texte qui décrit la structure ; il est lisible, comparable d'un commit à l'autre, et permet à n'importe qui de recréer la base identique.

**Question de réflexion : si l'application ne fonctionne plus après la partie 07, comment l'historique des commits permet-il de retrouver la dernière version qui marchait ?**

Avec un commit à la fin de chaque partie, `git log --oneline` liste les versions successives. On repère le dernier commit qui fonctionnait (par exemple la partie 06), puis on compare avec `git diff` ou on revient dessus avec `git checkout <hash>` (ou `git revert`) pour retrouver le code qui marchait.