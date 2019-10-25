# SnakeARM

Si tu sais pas utiliser les commandes git :
https://www.hostinger.com/tutorials/basic-git-commands

***STP : Pour chaque modification du programme -> commit (en fr le msg on s'en blc)***


Comme ça on comprends c'qu'on fait avec les commit


# Commandes de base :
- git init -> dans un nouveau dossier que tu appelles comme tu veux, UNIQUEMENT A LA CREATION
- git remote add origin https://github.com/Airels/SnakeARM -> pour définir la repo, UNIQUEMENT A LA CREATION
- git pull origin master -> tu connais déjà
- git add [fichier] -> pour ajouter un fichier modifié ou crée (techniquement on aura que snake.s à la place de [fichier])
- git commit -m "ton message" -> tu connais déjà
- git push origin master -> tu connais aussi

#### Tu dois dans l'ordre faire :
- git add snake.s
- git commit -m "msg"
- git push origin master
- ***ET A CHAQUE FOIS QUE TU UPDATE (oui c'est chiant mais faut le faire stp, au pire tu fais un script qui le fais à ta place)***


#### S'il refuse de pull/push alors que t'as tout bien fait :
- Supprime tout et refait de zéro (garde évidemment le snake.s si tu dois le push HEIN JE DIS CA ON SAIS JAMAIS)
