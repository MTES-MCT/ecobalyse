---
description: >-
  Pour faciliter la lecture une version du score/100 est aussi proposée (pour
  les impacts aggrégés : Score PEF et Score d'impact)
---

# Score/100

Pour passer du score en Pts au score on utilise la méthode détaillée dans [l'annexe 4 du rapport du conseil scientifique](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/f88c4def-8b48-4e8e-818f-9d3b6e477aef/rapport\_final\_CS\_dec\_2021\_Annexe\_4.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256\&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD\&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230111%2Fus-west-2%2Fs3%2Faws4\_request\&X-Amz-Date=20230111T134925Z\&X-Amz-Expires=86400\&X-Amz-Signature=0ff0f06cb5471e364aa5cf8f8fe0138f52916815b4cd11e762f658b2f5c39d0a\&X-Amz-SignedHeaders=host\&response-content-disposition=filename%3D%22rapport%2520final%2520CS%2520dec%25202021\_Annexe%25204.pdf%22\&x-id=GetObject). Des explications sur les choix effectués sont donnés dans cette annexe.

## Calcul

La formule est la suivante :

$$
score/100 = \frac{ln(x_{93,6\%})-ln(x)}{ln(2)}
$$

Avec :

* $$x$$: l'impact du produit en µPt/kg
* $$x_{93,6\%}$$: L'impact du produit du quantile 93,6% des produits CIQUAL. Pour calculer cette valeur, on calcule l'impact en score aggrégé (µPt/kg) des \~2500 produits CIQUAL que l'on ordonne par impact croissant. $$x_{93,6\%}$$est l'impact du produit tel que 93,6% des produits CIQUAL ont un impact inférieur ou égal (parallèlement on a 6,4% des produits CIQUAL ont un impact supérieur ou égal).\
  On a $$x_{93,6\%} = 2270$$ µPt/kg (source : annexe 4 du rapport du conseil scientifique)
* score/100 : le score sur 100 du produit

Etant donné que nous voulons que le score/100 soit compris entre 0 et 100, il faut ajouter ces conditions :&#x20;

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







