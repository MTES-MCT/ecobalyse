---
description: >-
  Pour faciliter la lecture une version du score/100 est aussi proposée (pour
  les impacts aggrégés : Score PEF et Score d'impact)
---

# Score/100

Pour passer du score en Pts au score/100 on utilise la méthode détaillée dans l'annexe 4 du rapport final du Conseil Scientifique ci-dessous. Des explications sur les choix effectués sont données dans cette annexe.

{% file src="../../.gitbook/assets/rapport final CS dec 2021_Annexe 4.pdf" %}

## Calcul

La formule est la suivante :

$$
score/100 = 20 *\frac{ln(x_{93,6\%})-ln(x)}{ln(2)}
$$

Avec :

* $$x$$: l'impact du produit en µPt/kg
* $$x_{93,6\%}$$: L'impact du produit du quantile 93,6% des produits CIQUAL. Pour calculer cette valeur, on calcule l'impact en score agrégé (µPt/kg) des \~2500 produits CIQUAL que l'on ordonne par impact croissant. $$x_{93,6\%}$$est l'impact du produit tel que 93,6% des produits CIQUAL ont un impact inférieur ou égal (parallèlement, 6,4% des produits CIQUAL ont un impact supérieur ou égal).\
  Pour le score PEF, on a $$x_{93,6\%} = 2270$$ µPt PEF/kg (source : annexe 4 du rapport du conseil scientifique)

{% hint style="danger" %}
Nous n'avons pas la valeur $$x_{93,6\%}$$pour le score d'impacts. On fait pour l'instant l'hypothèse que  $$x_{93,6\%} = 2270$$ µPt d'impacts/kg.
{% endhint %}

* score/100 : le score sur 100 du produit

Étant donné que nous voulons que le score/100 soit compris entre 0 et 100, il faut ajouter ces conditions :&#x20;

* Si score/100 < 0, alors score/100 = 0
* Si score/100 > 100, alors score/100 = 100

## Remarques

* Le score/100 d'un produit varie entre 0 (le plus mauvais) et 100 (le meilleur)
* L'échelle étant logarithmique, l'impact PEF est doublé tous les 20 points sur le score/100 :
  * Un produit de score 40/100 a 2x plus d'impact (score PEF) qu'un produit de score 60/100
  * Un produit de score 20/100 a 8x plus d'impact (score PEF) qu'un produit de score 80/100
* Il existe 5 intervalles de 20 points en 0 et 100, correspondant aux 5 lettres d'un affichage en lettre (A,B,C,D,E)
* Le top 6,4% des produits CIQUAL ont tous score/100 = 100
* Le flop 6,4% des produits CIQUAL ont tous score/100 = 0
* &#x20; $$\frac{x_{93,6\%}}{x_{6,4\%} }   = 2^5 = 32$$
*   Le score/100 permet de représenter un écart de 32 entre le meilleur et le pire produit. Au delà de ces bornes les produits ont tous le même score (0 ou 100). Cela provient du choix de faire une échelle à 5 lettres qui double tous les 20 points.



## \[_Projet_] Déclinaisons du score /100

Le score /100 introduit ci-dessus s'applique :&#x20;

* à un score d'impact agrégé global (score PEF, score d'impacts...)
* à l'ensemble des produits alimentaires

D'autres scores /100 pourraient également être définis et appliqués :&#x20;

* à des sous-scores (ou aires de protection) : biodiversité, climat, ressources \[TODO : lien à ajouter...]
* à des ensembles de produits plus restreints (les fruits et légumes, les viandes...)

Quelle que soit la situation considérée, la définition d'une nouvelle formule de calcul se fait à partir de deux paramètres :&#x20;

* Impact100 -> Impact considéré en dessous duquel tous les niveaux d'impact auraient le score de 100
* Impact0 -> Impact considéré en dessus duquel tous les niveaux d'impact auraient le score de 0

La formule de calcul du score /100 correspondant à un impact x s'écrit alors comme suit :&#x20;

$$
score/100 = 20 *5*\frac{ln(Impact_{0})-ln(x)}{ln(\frac{Impact_{0}}{Impact_{100}})}
$$









