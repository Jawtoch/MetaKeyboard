#  MetaKeyboard

Algorithme: recuit simulé

On doit calculer le l'énergie d'un clavier.
A l'aide des statistiques fournies, on estime l'énergie d'un clavier en fonction de la distance entre deux lettres d'un bigramme.
Pour chaque bigramme:
	- on calcule la distance entre les deux lettres du bigramme sur le clavier.
	- on pondère ce score en fonction du taux d'apparition du bigramme dans la langue française.

On fait ensuite la somme des valeurs pondérées, et on obtient le score du clavier.
On part du principe d'un touche fait 1U (U = unité). Deux touches voisines auront donc une distance de 1U.
La distance entre deux touches en diagonale sera donc de √2, etc…

La variation entre deux claviers se fera de la façon suivante:
	- On déplace aléatoirement une lettre sur le clavier

Les données statistiques des bigrammes ont été normalisées: cela diminue la charge de calculs, et permet d'éviter des sursauts au niveau de l'énergie du clavier
